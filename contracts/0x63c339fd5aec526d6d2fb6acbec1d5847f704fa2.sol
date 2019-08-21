pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

/**
* @title Crowdsale
* @dev Crowdsale is a base contract for managing a token crowdsale
* behavior.
*/
contract Crowdsale is Ownable{
  using SafeMath for uint256;

  // Address where funds are collected
  address public wallet;

  // Amount of wei raised
  uint256 public weiRaised;

  bool public isFinalized = false;

  uint256 public openingTime;
  uint256 public closingTime;

  event Finalized();

  /**
  * Event for token purchase logging
  * @param purchaser who paid for the tokens
  * @param beneficiary who got the tokens
  * @param value weis paid for purchase
  * @param amount amount of tokens purchased
  */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
  * @dev Reverts if not in crowdsale time range.
  */
  modifier onlyWhileOpen {
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }
  
  /**
  * @param _wallet Address where collected funds will be forwarded to
  * @param _openingTime Crowdsale opening time
  * @param _closingTime Crowdsale closing time
  */
  constructor(address _wallet, uint256 _openingTime, uint256 _closingTime) public {
    require(_wallet != address(0));
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;

    wallet = _wallet;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
  * @dev fallback function ***DO NOT OVERRIDE***
  */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
  * @dev low level token purchase ***DO NOT OVERRIDE***
  * @param _beneficiary Address performing the token purchase
  */
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

    _forwardFunds();
  }

  /**
  * @dev Must be called after crowdsale ends, to do some extra finalization
  * work. Calls the contract's finalization function.
  */
  function finalize() public onlyOwner {
    require(!isFinalized);
    require(hasClosed());

    emit Finalized();

    isFinalized = true;
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
  * @dev Validation of an incoming purchase.
  * @param _beneficiary Address performing the token purchase
  * @param _weiAmount Value in wei involved in the purchase
  */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal view
    onlyWhileOpen
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
  * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
  * @param _beneficiary Address performing the token purchase
  * @param _tokenAmount Number of tokens to be emitted
  */
   function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal;

  /**
  * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
  * @param _beneficiary Address receiving the tokens
  * @param _tokenAmount Number of tokens to be purchased
  */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
  * @dev Determines how ETH is stored/forwarded on purchases.
  */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  /**
  * @dev Override to extend the way in which ether is converted to tokens.
  * @param weiAmount Value in wei to be converted into tokens
  * @return Number of tokens that can be purchased with the specified _weiAmount
  */
  function _getTokenAmount(uint256 weiAmount) internal view returns (uint256);

  /**
  * @dev Checks whether the period in which the crowdsale is open has already elapsed.
  * @return Whether crowdsale period has elapsed
  */
  function hasClosed() public view returns (bool) {
    return block.timestamp > closingTime;
  }

}

contract FieldCoin is MintableToken, BurnableToken{

    using SafeMath for uint256;
    
    //name of token
    string public name;
    //token symbol
    string public symbol;
    //decimals in token
    uint8 public decimals;
    //address of bounty wallet
    address public bountyWallet;
    //address of team wallet
    address public teamWallet;
    //flag to set token release true=> token is ready for transfer
    bool public transferEnabled;
    //token available for offering
    uint256 public TOKEN_OFFERING_ALLOWANCE = 770e6 * 10 **18;//770 million(sale+bonus)
    // Address of token offering
    address public tokenOfferingAddr;
    //address to collect tokens when land is transferred
    address public landCollectorAddr;

    mapping(address => bool) public transferAgents;
    //mapping for blacklisted address
    mapping(address => bool) private blacklist;

    /**
    * Check if transfer is allowed
    *
    * Permissions:
    *                                                       Owner  OffeirngContract    Others
    * transfer (before transferEnabled is true)               y            n              n
    * transferFrom (before transferEnabled is true)           y            y              y
    * transfer/transferFrom after transferEnabled is true     y            n              y
    */    
    modifier canTransfer(address sender) {
        require(transferEnabled || transferAgents[sender], "transfer is not enabled or sender is not allowed");
          _;
    }

    /**
    * Check if token offering address is set or not
    */
    modifier onlyTokenOfferingAddrNotSet() {
        require(tokenOfferingAddr == address(0x0), "token offering address is already set");
        _;
    }

    /**
    * Check if land collector address is set or not
    */
    modifier onlyWhenLandCollectporAddressIsSet() {
        require(landCollectorAddr != address(0x0), "land collector address is not set");
        _;
    }


    /**
    * Check if address is a valid destination to transfer tokens to
    * - must not be zero address
    * - must not be the token address
    * - must not be the owner's address
    * - must not be the token offering contract address
    */
    modifier validDestination(address to) {
        require(to != address(0x0), "receiver can't be zero address");
        require(to != address(this), "receiver can't be token address");
        require(to != owner, "receiver can't be owner");
        require(to != address(tokenOfferingAddr), "receiver can't be token offering address");
        _;
    }

    /**
    * @dev Constuctor of the contract
    *
    */
    constructor () public {
        name    =   "Fieldcoin";
        symbol  =   "FLC";
        decimals    =   18;  
        totalSupply_ =   1000e6 * 10  **  uint256(decimals); //1000 million
        owner   =   msg.sender;
        balances[owner] = totalSupply_;
    }

    /**
    * @dev set bounty wallet
    * @param _bountyWallet address of bounty wallet.
    *
    */
    function setBountyWallet (address _bountyWallet) public onlyOwner returns (bool) {
        require(_bountyWallet != address(0x0), "bounty address can't be zero");
        if(bountyWallet == address(0x0)){  
            bountyWallet = _bountyWallet;
            balances[bountyWallet] = 20e6 * 10   **  uint256(decimals); //20 million
            balances[owner] = balances[owner].sub(20e6 * 10   **  uint256(decimals));
        }else{
            address oldBountyWallet = bountyWallet;
            bountyWallet = _bountyWallet;
            balances[bountyWallet] = balances[oldBountyWallet];
        }
        return true;
    }

    /**
    * @dev set team wallet
    * @param _teamWallet address of bounty wallet.
    *
    */
    function setTeamWallet (address _teamWallet) public onlyOwner returns (bool) {
        require(_teamWallet != address(0x0), "team address can't be zero");
        if(teamWallet == address(0x0)){  
            teamWallet = _teamWallet;
            balances[teamWallet] = 90e6 * 10   **  uint256(decimals); //90 million
            balances[owner] = balances[owner].sub(90e6 * 10   **  uint256(decimals));
        }else{
            address oldTeamWallet = teamWallet;
            teamWallet = _teamWallet;
            balances[teamWallet] = balances[oldTeamWallet];
        }
        return true;
    }

    /**
    * @dev transfer token to a specified address (written due to backward compatibility)
    * @param to address to which token is transferred
    * @param value amount of tokens to transfer
    * return bool true=> transfer is succesful
    */
    function transfer(address to, uint256 value) canTransfer(msg.sender) validDestination(to) public returns (bool) {
        return super.transfer(to, value);
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param from address from which token is transferred 
    * @param to address to which token is transferred
    * @param value amount of tokens to transfer
    * @return bool true=> transfer is succesful
    */
    function transferFrom(address from, address to, uint256 value) canTransfer(msg.sender) validDestination(to) public returns (bool) {
        return super.transferFrom(from, to, value);
    }

    /**
    * @dev add addresses to the blacklist
    * @return true if address was added to the blacklist,
    * false if address were already in the blacklist
    */
    function addBlacklistAddress(address addr) public onlyOwner {
        require(!isBlacklisted(addr), "address is already blacklisted");
        require(addr != address(0x0), "blacklisting address can't be zero");
        // blacklisted so they can withdraw
        blacklist[addr] = true;
    }

    /**
    * @dev Set token offering to approve allowance for offering contract to distribute tokens
    *
    * @param offeringAddr Address of token offerng contract i.e., fieldcoinsale contract
    * @param amountForSale Amount of tokens for sale, set 0 to max out
    */
    function setTokenOffering(address offeringAddr, uint256 amountForSale) external onlyOwner onlyTokenOfferingAddrNotSet {
        require (offeringAddr != address(0x0), "offering address can't be zero");
        require(!transferEnabled, "transfer should be diabled");

        uint256 amount = (amountForSale == 0) ? TOKEN_OFFERING_ALLOWANCE : amountForSale;
        require(amount <= TOKEN_OFFERING_ALLOWANCE);

        approve(offeringAddr, amount);
        tokenOfferingAddr = offeringAddr;
        //start the transfer for offeringAddr
        setTransferAgent(tokenOfferingAddr, true);

    }

    /**
    * @dev set land collector address
    *
    */
    function setLandCollector(address collectorAddr) public onlyOwner {
        require (collectorAddr != address(0x0), "land collecting address can't be set to zero");
        require(!transferEnabled,  "transfer should be diabled");
        landCollectorAddr = collectorAddr;
    }


    /**
    * @dev release tokens for transfer
    *
    */
    function enableTransfer() public onlyOwner {
        transferEnabled = true;
        // End the offering
        approve(tokenOfferingAddr, 0);
        //stop the transfer for offeringAddr
        setTransferAgent(tokenOfferingAddr, false);
    }

    /**
    * @dev Set transfer agent to true for transfer tokens for private investor and exchange
    * @param _addr who will be allowd for transfer
    * @param _allowTransfer true=>allowed
    *
    */
    function setTransferAgent(address _addr, bool _allowTransfer) public onlyOwner {
        transferAgents[_addr] = _allowTransfer;
    }

    /**
    * @dev withdraw if KYC not verified
    * @param _investor investor whose tokens are to be withdrawn
    * @param _tokens amount of tokens to be withdrawn
    */
    function _withdraw(address _investor, uint256 _tokens) external{
        require (msg.sender == tokenOfferingAddr, "sender must be offering address");
        require (isBlacklisted(_investor), "address is not whitelisted");
        balances[owner] = balances[owner].add(_tokens);
        balances[_investor] = balances[_investor].sub(_tokens);
        balances[_investor] = 0;
    }

    /**
    * @dev buy land during ICO
    * @param _investor investor whose tokens are to be transferred
    * @param _tokens amount of tokens to be transferred
    */
    function _buyLand(address _investor, uint256 _tokens) external onlyWhenLandCollectporAddressIsSet{
        require (!transferEnabled, "transfer should be diabled");
        require (msg.sender == tokenOfferingAddr, "sender must be offering address");
        balances[landCollectorAddr] = balances[landCollectorAddr].add(_tokens);
        balances[_investor] = balances[_investor].sub(_tokens);
    }

   /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
    function burn(uint256 _value) public {
        require(transferEnabled || msg.sender == owner, "transfer is not enabled or sender is not owner");
        super.burn(_value);
    }

    /**
    * @dev check address is blacklisted or not
    * @param _addr who will be checked
    * @return true=> if blacklisted, false=> if not
    *
    */
    function isBlacklisted(address _addr) public view returns(bool){
        return blacklist[_addr];
    }

}

contract FieldCoinSale is Crowdsale, Pausable{

    using SafeMath for uint256;

    //To store tokens supplied during CrowdSale
    uint256 public totalSaleSupply = 600000000 *10 **18; // 600 million tokens
    //price of token in cents
    uint256 public tokenCost = 5; //5 cents i.e., .5$
    //1 eth = usd in cents, eg: 1 eth = 107.91$ so, 1 eth = =107,91 cents
    uint256 public ETH_USD;
    //min contribution 
    uint256 public minContribution = 10000; //100,00 cents i.e., 100$
    //max contribution 
    uint256 public maxContribution = 100000000; //100 million cents i.e., 1 million dollar
    //count for bonus
    uint256 public milestoneCount;
    //flag to check bonus is initialized or not
    bool public initialized = false;
    //total number of bonus tokens
    uint256 public bonusTokens = 170e6 * 10 ** 18; //170 millions
    //tokens for sale
    uint256 public tokensSold = 0;
    //object of FieldCoin
    FieldCoin private objFieldCoin;

    struct Milestone {
        uint256 bonus;
        uint256 total;
    }

    Milestone[6] public milestones;
    
    //Structure to store token sent and wei received by the buyer of tokens
    struct Investor {
        uint256 weiReceived;
        uint256 tokenSent;
        uint256 bonusSent;
    }

    //investors indexed by their ETH address
    mapping(address => Investor) public investors;

    //event triggered when tokens are withdrawn
    event Withdrawn();

    /**
    * @dev Constuctor of the contract
    *
    */
    constructor (uint256 _openingTime, uint256 _closingTime, address _wallet, address _token, uint256 _ETH_USD, uint256 _minContribution, uint256 _maxContribution) public
    Crowdsale(_wallet, _openingTime, _closingTime) {
        require(_ETH_USD > 0, "ETH USD rate should be greater than 0");
        minContribution = (_minContribution == 0) ? minContribution : _minContribution;
        maxContribution = (_maxContribution == 0) ? maxContribution : _maxContribution;
        ETH_USD = _ETH_USD;
        objFieldCoin = FieldCoin(_token);
    }

    /**
    * @dev Set eth usd rate
    * @param _ETH_USD stores ether value in cents
    *       i.e., 1 ETH = 107.01 $ so, 1 ETH = 10701 cents
    *
    */
    function setETH_USDRate(uint256 _ETH_USD) public onlyOwner{
        require(_ETH_USD > 0, "ETH USD rate should be greater than 0");
        ETH_USD = _ETH_USD;
    }

    /**
    * @dev Set new coinbase(wallet) address
    * @param _newWallet wallet address
    *
    */
    function setNewWallet(address _newWallet) onlyOwner public {
        wallet = _newWallet;
    }

    /**
    * @dev Set new minimum contribution
    * @param _minContribution minimum contribution in cents
    *
    */
    function changeMinContribution(uint256 _minContribution) public onlyOwner {
        require(_minContribution > 0, "min contribution should be greater than 0");
        minContribution = _minContribution;
    }

    /**
    * @dev Set new maximum contribution
    * @param _maxContribution maximum contribution in cents
    *
    */
    function changeMaxContribution(uint256 _maxContribution) public onlyOwner {
        require(_maxContribution > 0, "max contribution should be greater than 0");
        maxContribution = _maxContribution;
    }

    /**
    * @dev Set new token cost
    * @param _tokenCost price of 1 token in cents
    */
    function changeTokenCost(uint256 _tokenCost) public onlyOwner {
        require(_tokenCost > 0, "token cost can not be zero");
        tokenCost = _tokenCost;
    }

    /**
    * @dev Set new opening time
    * @param _openingTime time in UTX
    *
    */
    function changeOpeningTIme(uint256 _openingTime) public onlyOwner {
        require(_openingTime >= block.timestamp, "opening time is less than current time");
        openingTime = _openingTime;
    }

    /**
    * @dev Set new closing time
    * @param _closingTime time in UTX
    *
    */
    function changeClosingTime(uint256 _closingTime) public onlyOwner {
        require(_closingTime >= openingTime, "closing time is less than opening time");
        closingTime = _closingTime;
    }

    /**
    * @dev initialize bonuses
    * @param _bonus tokens bonus in array depends on their slab
    * @param _total slab of tokens bonuses in array
    */
    function initializeMilestones(uint256[] _bonus, uint256[] _total) public onlyOwner {
        require(_bonus.length > 0 && _bonus.length == _total.length);
        for(uint256 i = 0; i < _bonus.length; i++) {
            milestones[i] = Milestone({ total: _total[i], bonus: _bonus[i] });
        }
        milestoneCount = _bonus.length;
        initialized = true;
    }

    /**
    * @dev function processing tokens and bonuses
    * will over ride the function in Crowdsale.sol
    * @param _beneficiary who will receive tokens
    * @param _tokenAmount amount of tokens to send without bonus
    *
    */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        require(tokensRemaining() >= _tokenAmount, "token need to be transferred is more than the available token");
        uint256 _bonusTokens = _processBonus(_tokenAmount);
        bonusTokens = bonusTokens.sub(_bonusTokens);
        tokensSold = tokensSold.add(_tokenAmount);
        // accumulate total token to be given
        uint256 totalNumberOfTokenTransferred = _tokenAmount.add(_bonusTokens);
        //initializing structure for the address of the beneficiary
        Investor storage _investor = investors[_beneficiary];
        //Update investor's balance
        _investor.tokenSent = _investor.tokenSent.add(totalNumberOfTokenTransferred);
        _investor.weiReceived = _investor.weiReceived.add(msg.value);
        _investor.bonusSent = _investor.bonusSent.add(_bonusTokens);
        super._processPurchase(_beneficiary, totalNumberOfTokenTransferred);
    }

     /**
    * @dev send token manually to people who invest other than ether
    * @param _beneficiary Address performing the token purchase
    * @param weiAmount amount of wei invested
    */
    function createTokenManually(address _beneficiary, uint256 weiAmount) external onlyOwner {
        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);
        
        // update state
        weiRaised = weiRaised.add(weiAmount);
    
        _processPurchase(_beneficiary, tokens);
        emit TokenPurchase(
          msg.sender,
          _beneficiary,
          weiAmount,
          tokens
        );
    }

    /**
    * @dev Source of tokens.
    * @param _beneficiary Address performing the token purchase
    * @param _tokenAmount Number of tokens to be emitted
    */
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        if(!objFieldCoin.transferFrom(objFieldCoin.owner(), _beneficiary, _tokenAmount)){
            revert("token delivery failed");
        }
    }

    /**
    * @dev withdraw if KYC not verified
    */
    function withdraw() external{
        Investor storage _investor = investors[msg.sender];
        //transfer investor's balance to owner
        objFieldCoin._withdraw(msg.sender, _investor.tokenSent);
        //return the ether to the investor balance
        msg.sender.transfer(_investor.weiReceived);
        //set everything to zero after transfer successful
        _investor.weiReceived = 0;
        _investor.tokenSent = 0;
        _investor.bonusSent = 0;
        emit Withdrawn();
    }

    /**
    * @dev buy land during ICO
    * @param _tokens amount of tokens to be transferred
    */
    function buyLand(uint256 _tokens) external{
        Investor memory _investor = investors[msg.sender];
        require (_tokens <= objFieldCoin.balanceOf(msg.sender).sub(_investor.bonusSent), "token to buy land is more than the available number of tokens");
        //transfer investor's balance to land collector
        objFieldCoin._buyLand(msg.sender, _tokens);
    }

    /*
    * @dev Function to add Ether in the contract 
    */
    function fundContractForWithdraw()external payable{
    }

    /**
    * @dev increase bonus allowance if exhausted
    * @param _value amount of token bonus to increase in 18 decimal places
    *
    */
    function increaseBonusAllowance(uint256 _value) public onlyOwner {
        bonusTokens = bonusTokens.add(_value);
    }
    
    // -----------------------------------------
    // Getter interface
    // -----------------------------------------

    /**
    * @dev Validation of an incoming purchase.
    * @param _beneficiary Address performing the token purchase
    * @param _weiAmount Value in wei involved in the purchase
    */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) whenNotPaused internal view{
        require (!hasClosed(), "Sale has been ended");
        require(initialized, "Bonus is not initialized");
        require(_weiAmount >= getMinContributionInWei(), "amount is less than min contribution");
        require(_weiAmount <= getMaxContributionInWei(), "amount is more than max contribution");
        super._preValidatePurchase(_beneficiary, _weiAmount);
    }

    function _processBonus(uint256 _tokenAmount) internal view returns(uint256){
        uint256 currentMilestoneIndex = getCurrentMilestoneIndex();
        uint256 _bonusTokens = 0;
        //get bonus tier
        Milestone memory _currentMilestone = milestones[currentMilestoneIndex];
        if(bonusTokens > 0 && _currentMilestone.bonus > 0) {
          _bonusTokens = _tokenAmount.mul(_currentMilestone.bonus).div(100);
          _bonusTokens = bonusTokens < _bonusTokens ? bonusTokens : _bonusTokens;
        }
        return _bonusTokens;
    }

    /**
    * @dev check whether tokens are remaining are not
    *
    */
    function tokensRemaining() public view returns(uint256) {
        return totalSaleSupply.sub(tokensSold);
    }

    /**
    * @dev gives the bonus milestone index for bonus colculation
    * @return the bonus milestones index
    *
    */
    function getCurrentMilestoneIndex() public view returns (uint256) {
        for(uint256 i = 0; i < milestoneCount; i++) {
            if(tokensSold < milestones[i].total) {
                return i;
            }
        }
    }

    /**
    * @dev gives the token price w.r.t to wei sent 
    * @return the amount of tokens to be given based on wei received
    *
    */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount.mul(ETH_USD).div(tokenCost);
    }

    /**
    * @dev check whether token is left or sale is ended
    * @return true=> sale ended or false=> not ended
    *
    */
    function hasClosed() public view returns (bool) {
        uint256 tokensLeft = tokensRemaining();
        return tokensLeft <= 1e18 || super.hasClosed();
    }

    /**
    * @dev gives minimum contribution in wei
    * @return the min contribution value in wei
    *
    */
    function getMinContributionInWei() public view returns(uint256){
        return (minContribution.mul(1e18)).div(ETH_USD);
    }

    /**
    * @dev gives max contribution in wei
    * @return the max contribution value in wei
    *
    */
    function getMaxContributionInWei() public view returns(uint256){
        return (maxContribution.mul(1e18)).div(ETH_USD);
    }

    /**
    * @dev gives usd raised based on wei raised
    * @return the usd value in cents
    *
    */
    function usdRaised() public view returns (uint256) {
        return weiRaised.mul(ETH_USD).div(1e18);
    }
    
}