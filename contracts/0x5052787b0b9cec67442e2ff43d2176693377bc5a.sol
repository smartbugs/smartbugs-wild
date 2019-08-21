pragma solidity ^0.4.15;

/**
 * Pulsar token contract.
 * Date: 2017-11-14.
 */


contract Ownable {

  address public owner;   // The owner of the contract

  event OwnershipTransferred ( address indexed prev_owner, address indexed new_owner );

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership (address new_owner) onlyOwner public {
    require(new_owner != address(0));
    OwnershipTransferred(owner, new_owner);
    owner = new_owner;
  }


} // Ownable


/******************************************/
/*       PULSAR TOKEN STARTS HERE         */
/******************************************/

contract PulsarToken is Ownable {

  /******** Public constants ********/

  // Token decimal scale is the same as Ether to Wei scale = 10^18 (18 decimal digits)
  uint public constant TOKEN_SCALE = 1 ether / 1 wei; // (10 ** 18)

  // Total amount of tokens
  uint public constant TOTAL_SUPPLY = 34540000 * TOKEN_SCALE;

  // 2017-11-13 08:13:00 UTC = 00:13:00 PST
  uint public constant ICO_START_TIME = 1510560780;

  // Minimum accepted contribution is 0.1 Ether
  uint public constant MIN_ACCEPTED_VALUE = 100000000000000000 wei; // 0.1 ether

  // Minimum buyback amount of tokens
  uint public constant MIN_BUYBACK_VALUE = 1 * TOKEN_SCALE;

  // Public identifiers of the token
  string public constant NAME = "Pulsar";       // token name
  string public constant SYMBOL = "PVC";        // token symbol


  /**
   * Contract state machine.                           _____________
   *                                                  ↓             |
   * Deployed -> ICOStarted -> ICOStopped -> BuybackEnabled -> BuybackPaused -> Destroyed.
   */
  enum ContractState { Deployed, ICOStarted, ICOStopped, BuybackEnabled, BuybackPaused, Destroyed }

  // Current state of the contract
  ContractState private contractState = ContractState.Deployed;

  // Contract state change event
  event State ( ContractState state );

  // This generates a public event on the blockchain that will notify clients
  event Transfer ( address indexed from, address indexed to, uint value );


  /******** Public variables *********/

  // This creates an array with all balances
  mapping (address => uint) public balanceOf;

  // Reserved bounty tokens
  uint public bountyTokens = 40000 * TOKEN_SCALE;

  // Selling price of tokens in Wei
  uint public sellingPrice = 0;

  // Buyback price of tokens in Wei
  uint public buybackPrice = 0;

  // Amount of Ether the contract ever received
  uint public etherAccumulator = 0;

  // ICO start time
  uint public icoStartTime = ICO_START_TIME;

  // Trusted (authorized) sender of tokens
  address public trustedSender = address(0);


  /******** Private variables ********/

  uint8[4] private bonuses = [ uint8(15), uint8(10), uint8(5), uint8(3) ];  // these are percents
  uint[4]  private staging = [ 1 weeks,   2 weeks,   3 weeks,  4 weeks ];   // timeframe when the bonuses are effective


  /**
   * The constructor initializes the contract.
   */
  function PulsarToken() public
  {
    // intentionally left empty
  }


  /******** Helper functions ********/

  /* Calculate current bonus percent. */
  function calcBonusPercent() public view returns (uint8) {
    uint8 _bonus = 0;
    uint _elapsed = now - icoStartTime;

    for (uint8 i = 0; i < staging.length; i++) {
      if (_elapsed <= staging[i]) {
          _bonus = bonuses[i];
          break;
      }
    }
    return _bonus;
  }

  /* Add bonus to the amount, for example 200 + 15% bonus = 230. */
  function calcAmountWithBonus(uint token_value, uint8 bonus) public view returns (uint) {
    return  (token_value * (100 + bonus)) / 100;
  }

  /* Convert amount in Wei to tokens. */
  function calcEthersToTokens(uint ether_value, uint8 bonus) public view returns (uint) {
    return calcAmountWithBonus(TOKEN_SCALE * ether_value/sellingPrice, bonus);
  }

  /* Convert amount in tokens to Wei. */
  function calcTokensToEthers(uint token_value) public view returns (uint) {
      return (buybackPrice * token_value) / TOKEN_SCALE;
  }

  /**
   * Internal transfer of tokens, only can be called from within this contract.
   *
   * @param _from   Source address
   * @param _to     Destination address
   * @param _value  Amount of tokens (do not forget to multiply by scale 10^18)
   */
  function _transfer(address _from, address _to, uint _value) internal
  {
    require(_to != address(0x0));                       // prevent transfer to 0x0 address
    require(_value > 0);                                // check if the value is greater than zero
    require(balanceOf[_from] >= _value);                // check if the sender has enough tokens
    require(balanceOf[_to] + _value > balanceOf[_to]);  // check for overflows

    balanceOf[_from]  -= _value;                        // subtract from the sender
    balanceOf[_to]    += _value;                        // add the same to the recipient

    Transfer(_from, _to, _value);                       // fire the event
  }


  /************************* Public interface ********************************/

  /**
   * View current state of the contract.
   *
   * Returns: Current state of the contract as uint8, starting from 0.
   */
  function getContractState() public view returns (uint8) {
    return uint8(contractState);
  }

  /**
   * View current token balance of the contract.
   *
   * Returns: Current amount of tokens in the contract.
   */
  function getContractTokenBalance() public view returns (uint) {
    return balanceOf[this];
  }

  /**
   * View current token balance of the given address.
   *
   * Returns: Current amount of tokens hold by the address
   *
   * @param holder_address Holder of tokens
   */
  function getTokenBalance(address holder_address) public view returns (uint) {
    require(holder_address != address(0));
    return balanceOf[holder_address];
  }

  /**
   * View total amount of currently distributed tokens.
   *
   * Returns: Total amount of distributed tokens.
   */
  function getDistributedTokens() public view returns (uint) {
      return TOTAL_SUPPLY - balanceOf[this];
  }

  /**
   * View current Ether balance of the contract.
   *
   * Returns: Current amount of Wei at the contract's address.
   */
  function getContractEtherBalance() public view returns (uint) {
    return this.balance;
  }

  /**
   * View current Ether balance of the given address.
   *
   * Returns: Current amount of Wei at the given address.
   */
  function getEtherBalance(address holder_address) public view returns (uint) {
    require(holder_address != address(0));
    return holder_address.balance;
  }


  /**
   * Buy tokens for Ether.
   * State must be only ICOStarted.
   */
  function invest() public payable
  {
    require(contractState == ContractState.ICOStarted);   // check state
    require(now >= icoStartTime);                         // check time
    require(msg.value >= MIN_ACCEPTED_VALUE);             // check amount of contribution

    uint8 _bonus  = calcBonusPercent();
    uint  _tokens = calcEthersToTokens(msg.value, _bonus);

    require(balanceOf[this] >= _tokens);                  // check amount of tokens

    _transfer(this, msg.sender, _tokens);                 // tranfer tokens to the investor

    etherAccumulator += msg.value;      // finally update the counter of received Ether
  }


  // Default fallback function handles sending Ether to the contract.
  function () public payable {
    invest();
  }

  /**
   * Token holders withdraw Ether in exchange of their tokens.
   * 
   * @param token_value Amount of tokens being returned (do not forget to multiply by scale 10^18)
   */
  function buyback(uint token_value) public
  {
    require(contractState == ContractState.BuybackEnabled);   // check current state
    require(buybackPrice > 0);                                // buyback price must be set
    require(token_value >= MIN_BUYBACK_VALUE);                // minimum allowed amount of tokens
    require(msg.sender != owner);                             // the owner can't buyback

    uint _ethers = calcTokensToEthers(token_value);

    // Check if the contract has enough ether to buyback the tokens
    require(this.balance >= _ethers);

    // Transfer the tokens back to the contract
    _transfer(msg.sender, this, token_value);

    // Send ether to the seller. It's important to do this last to avoid recursion attacks.
    msg.sender.transfer(_ethers);
  }

  /************************** Owner's interface *****************************/

  /**
   * Set ICO start time
   *
   * Restricted to the owner.
   *
   * @param start_time New start time as number of seconds from Unix Epoch
   */
  function setICOStartTime(uint start_time) onlyOwner external {
    icoStartTime = start_time;
  }

  /**
   * Set token selling price in Wei.
   *
   * Restricted to the owner.
   *
   * @param selling_price New selling price in Wei
   */
  function setSellingPrice(uint selling_price) onlyOwner public {
    require(selling_price != 0);
    sellingPrice = selling_price;
  }

  /**
   * Start selling tokens.
   *
   * Restricted to the owner.
   *
   * @param selling_price New selling price in Wei
   */
  function startICO(uint selling_price) onlyOwner external {
    require(contractState == ContractState.Deployed);
    setSellingPrice(selling_price);

    balanceOf[this] = TOTAL_SUPPLY;

    contractState = ContractState.ICOStarted;
    State(contractState);
  }

  /**
   * Stop selling tokens.
   * Restricted to the owner.
   */
  function stopICO() onlyOwner external {
    require(contractState == ContractState.ICOStarted);

    contractState = ContractState.ICOStopped;
    State(contractState);
  }

  /**
   * Transfer Ether from the contract to the owner.
   * Restricted to the owner.
   *
   * @param ether_value Amount in Wei
   */
  function transferEthersToOwner(uint ether_value) onlyOwner external {
    require(this.balance >= ether_value);
    msg.sender.transfer(ether_value);
  }

  /**
   * Set the trusted sender of tokens.
   * Pass (0) to remove the truster sender.
   * Restricted to the owner.
   *
   * @param trusted_address New trusted sender
   */
  function setTrustedSender(address trusted_address) onlyOwner external {
    trustedSender = trusted_address;
  }

  /**
   * Transfer tokens to an address.
   * Restricted to the owner or to the trusted address.
   *
   * @param recipient_address Recipient address
   * @param token_value Amount of tokens (do not forget to multiply by scale 10^18)
   */
  function transferTokens(address recipient_address, uint token_value) external {
    require( (msg.sender == owner) || (msg.sender == trustedSender) );  // Restricted to the owner or to trustedSender
    require(contractState == ContractState.ICOStarted);                 // check state
    require(now >= icoStartTime);                                       // check time

    _transfer(this, recipient_address, token_value);
  }

  /**
   * Grant bounty tokens to an address.
   * Restricted to the owner.
   * State must be ICOStarted or ICOStopped.
   *
   * @param recipient_address Recipient address
   * @param token_value Amount of tokens (do not forget to multiply by scale 10^18)
   */
  function grantBounty(address recipient_address, uint token_value) onlyOwner external {
    require((contractState == ContractState.ICOStarted) || (contractState == ContractState.ICOStopped));  // check the state
    require(bountyTokens >= token_value);  // check remaining amount of bounty tokens
    require(now >= icoStartTime);     // check time

    _transfer(this, recipient_address, token_value);
    bountyTokens -= token_value;
  }

  /**
   * Refund investment by transferring all tokens back to the contract and sending Ether to the investor.
   *
   * This function is a necessary measure, because maximum 99 accredited US investors are allowed 
   * under exemptions from registration with the U.S. Securities and Exchange Commission 
   * pursuant to Regulation D, Section 506(c) of the Securities Act of 1933, as amended (the “Securities Act”).
   * 
   * We will select 99 accredited US investors and refund investments to all other US accredited investors to comply with this regulation.
   *
   * Investors from other countries (non-US investors) will not be affected.
   *
   * State must be ICOStopped or BuybackPaused.
   *
   * Restricted to the owner.
   *
   * @param investor_address The address of the investor
   * @param ether_value The amount in Wei
   */
  function refundInvestment(address investor_address, uint ether_value) onlyOwner external {
    require((contractState == ContractState.ICOStopped) || (contractState == ContractState.BuybackPaused));   // check the state

    require(investor_address != owner);                   // do not refund to the owner
    require(investor_address != address(this));           // do not refund to the contract
    require(balanceOf[investor_address] > 0);             // investor's token balance must be greater than zero
    require(this.balance >= ether_value);                 // the contract must have enough ether

    // Transfer the tokens back to the contract
    _transfer(investor_address, this, balanceOf[investor_address]);

    // Send ether to the investor. It's important to do this last to avoid recursion attacks.
    investor_address.transfer(ether_value);
  }

  /**
   * Set token buyback price in Wei.
   *
   * Restricted to the owner.
   *
   * @param buyback_price New buyback price in Wei
   */
  function setBuybackPrice(uint buyback_price) onlyOwner public {
    require(buyback_price > 0);
    buybackPrice = buyback_price;
  }

  /**
   * Enable buyback.
   * State must be ICOStopped or BuybackPaused.
   * Buyback can be paused with pauseBuyback().
   *
   * Restricted to the owner.
   *
   * @param buyback_price New buyback price in Wei
   */
  function enableBuyback(uint buyback_price) onlyOwner external {
    require((contractState == ContractState.ICOStopped) || (contractState == ContractState.BuybackPaused));
    setBuybackPrice(buyback_price);

    contractState = ContractState.BuybackEnabled;
    State(contractState);
  }

  /**
   * Pause buyback.
   * State must be BuybackEnabled.
   * Buyback can be re-enabled with enableBuyback().
   *
   * Restricted to the owner.
   */
  function pauseBuyback() onlyOwner external {
      require(contractState == ContractState.BuybackEnabled);

      contractState = ContractState.BuybackPaused;
      State(contractState);
  }

  /**
   * Destroy the contract and send all Ether to the owner.
   * The contract must be in the BuybackPaused state.
   *
   * Restricted to the owner.
   */
  function destroyContract() onlyOwner external {
      require(contractState == ContractState.BuybackPaused);

      contractState = ContractState.Destroyed;
      State(contractState);

      selfdestruct(owner);  // send all money to the owner and destroy the contract!
  }

} /* ------------------------ end of contract ---------------------- */