pragma solidity ^0.4.11;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
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


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
  
  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until 
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) 
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) 
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
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

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end blocks, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
  using SafeMath for uint256;
  // The token being sold
  MintableToken public token;

  // start and end blocks where investments are allowed (both inclusive)
  uint256 public startBlock;
  uint256 public endBlock;

  // address where funds are collected
  address public wallet;

  // amount of raised money in wei
  uint256 public weiRaised;

  // how many token units a buyer gets per wei
  uint256 public rate;


  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startBlock, uint256 _endBlock, address _wallet) {
    require(_startBlock >= block.number);
    require(_endBlock >= _startBlock);
    require(_wallet != 0x0);

    token = createTokenContract();
    startBlock = _startBlock;
    endBlock = _endBlock;
    wallet = _wallet;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }


  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }


  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = block.number >= startBlock && block.number <= endBlock;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return block.number > endBlock;
  }


}


/**
 * @title CappedCrowdsale
 * @dev Extension of Crowsdale with a max amount of funds raised
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowsdale where an owner can do extra work
 * after finishing. 
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();
    
    isFinalized = true;
  }

  /**
   * @dev Can be overriden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }
}


/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function RefundVault(address _wallet) {
    require(_wallet != 0x0);
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyOwner {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}


/**
 * @title RefundableCrowdsale
 * @dev Extension of Crowdsale contract that adds a funding goal, and
 * the possibility of users getting a refund if goal is not met.
 * Uses a RefundVault as the crowdsale's vault.
 */
contract RefundableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;

  // minimum amount of funds to be raised in weis
  uint256 public goal;

  // refund vault used to hold funds while crowdsale is running
  RefundVault public vault;

  function RefundableCrowdsale(uint256 _goal) {
    require(_goal > 0);
    vault = new RefundVault(wallet);
    goal = _goal;
  }

  // We're overriding the fund forwarding from Crowdsale.
  // In addition to sending the funds, we want to call
  // the RefundVault deposit function
  function forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }

  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() {
    require(isFinalized);
    require(!goalReached());

    vault.refund(msg.sender);
  }

  // vault finalization task, called when owner calls finalize()
  function finalization() internal {
    if (goalReached()) {
      vault.close();
    } else {
      vault.enableRefunds();
    }

    super.finalization();
  }

  function goalReached() public constant returns (bool) {
    return weiRaised >= goal;
  }

}

contract GlobCoinToken is MintableToken {
  using SafeMath for uint256;
  string public constant name = "GlobCoin Crypto Platform";
  string public constant symbol = "GCP";
  uint8 public constant decimals = 18;

  modifier onlyMintingFinished() {
    require(mintingFinished == true);
    _;
  }
  /// @dev Same ERC20 behavior, but require the token to be unlocked
  /// @param _spender address The address which will spend the funds.
  /// @param _value uint256 The amount of tokens to be spent.
  function approve(address _spender, uint256 _value) public onlyMintingFinished returns (bool) {
      return super.approve(_spender, _value);
  }

  /// @dev Same ERC20 behavior, but require the token to be unlocked
  /// @param _to address The address to transfer to.
  /// @param _value uint256 The amount to be transferred.
  function transfer(address _to, uint256 _value) public onlyMintingFinished returns (bool) {
      return super.transfer(_to, _value);
  }

  /// @dev Same ERC20 behavior, but require the token to be unlocked
  /// @param _from address The address which you want to send tokens from.
  /// @param _to address The address which you want to transfer to.
  /// @param _value uint256 the amount of tokens to be transferred.
  function transferFrom(address _from, address _to, uint256 _value) public onlyMintingFinished returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

}

contract GlobcoinTokenSale is CappedCrowdsale, RefundableCrowdsale {

  //Start of the Actual crowdsale. Starblock is the start of the presale.
  uint256 public startSale;
  uint256 public endPresale;

  // Presale Rate per wei ~30% bonus over rate1
  uint256 public constant PRESALERATE = 17000;

  // new rates
  uint256 public constant RATE1 = 13000;
  uint256 public constant RATE2 = 12000;
  uint256 public constant RATE3 = 11000;
  uint256 public constant RATE4 = 10000;


  // Cap per tier for bonus in wei.
  uint256 public constant TIER1 =  3000000000000000000000;
  uint256 public constant TIER2 =  5000000000000000000000;
  uint256 public constant TIER3 =  7500000000000000000000;

  //Presale
  uint256 public weiRaisedPreSale;
  uint256 public presaleCap;

  function GlobcoinTokenSale(uint256 _startBlock, uint256 _endPresale, uint256 _startSale, uint256 _endBlock, uint256 _goal,uint256 _presaleCap, uint256 _cap, address _wallet) public
  CappedCrowdsale(_cap) FinalizableCrowdsale() RefundableCrowdsale(_goal) Crowdsale(_startBlock, _endBlock, _wallet) {
    require(_goal <= _cap);
    require(_startSale > _startBlock);
    require(_endBlock > _startSale);
    require(_presaleCap > 0);
    require(_presaleCap <= _cap);

    startSale = _startSale;
    endPresale = _endPresale;
    presaleCap = _presaleCap;
  }

  function createTokenContract() internal returns (MintableToken) {
    return new GlobCoinToken();
  }

  //white listed address
  mapping (address => bool) public whiteListedAddress;
  mapping (address => bool) public whiteListedAddressPresale;

  modifier onlyPresaleWhitelisted() {
    require( isWhitelistedPresale(msg.sender) ) ;
    _;
  }

  modifier onlyWhitelisted() {
    require( isWhitelisted(msg.sender) || isWhitelistedPresale(msg.sender) ) ;
    _;
  }

  /**
   * @dev Add a list of address to be whitelisted for the crowdsale only.
   * @param _users , the list of user Address. Tested for out of gas until 200 addresses.
   */
  function whitelistAddresses( address[] _users) onlyOwner {
    for( uint i = 0 ; i < _users.length ; i++ ) {
      whiteListedAddress[_users[i]] = true;
    }
  }

  function unwhitelistAddress( address _users) onlyOwner {
    whiteListedAddress[_users] = false;
  }

  /**
   * @dev Add a list of address to be whitelisted for the Presale And sale.
   * @param _users , the list of user Address. Tested for out of gas until 200 addresses.
   */
  function whitelistAddressesPresale( address[] _users) onlyOwner {
    for( uint i = 0 ; i < _users.length ; i++ ) {
      whiteListedAddressPresale[_users[i]] = true;
    }
  }

  function unwhitelistAddressPresale( address _users) onlyOwner {
    whiteListedAddressPresale[_users] = false;
  }

  function isWhitelisted(address _user) public constant returns (bool) {
    return whiteListedAddress[_user];
  }

  function isWhitelistedPresale(address _user) public constant returns (bool) {
    return whiteListedAddressPresale[_user];
  }

  function () payable {
    if (validPurchasePresale()){
      buyTokensPresale(msg.sender);
    } else {
      buyTokens(msg.sender);
    }
  }

  function buyTokens(address beneficiary) payable onlyWhitelisted {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;
    uint256 tokens = calculateTokenAmount(weiAmount);
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds();
  }

  function buyTokensPresale(address beneficiary) payable onlyPresaleWhitelisted {
    require(beneficiary != 0x0);
    require(validPurchasePresale());

    uint256 weiAmount = msg.value;
    uint256 tokens = weiAmount.mul(PRESALERATE);
    weiRaisedPreSale = weiRaisedPreSale.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds();
  }

  // calculate the amount of token the user is getting - can overlap on multiple tiers.
  function calculateTokenAmount(uint256 weiAmount) internal returns (uint256){
    uint256 amountToBuy = weiAmount;
    uint256 amountTokenBought;
    uint256 currentWeiRaised = weiRaised;
     if (currentWeiRaised < TIER1 && amountToBuy > 0) {
       var (amountBoughtInTier, amountLeftTobuy) = calculateAmountPerTier(amountToBuy,TIER1,RATE1,currentWeiRaised);
       amountTokenBought = amountTokenBought.add(amountBoughtInTier);
       currentWeiRaised = currentWeiRaised.add(amountToBuy.sub(amountLeftTobuy));
       amountToBuy = amountLeftTobuy;
     }
     if (currentWeiRaised < TIER2 && amountToBuy > 0) {
      (amountBoughtInTier, amountLeftTobuy) = calculateAmountPerTier(amountToBuy,TIER2,RATE2,currentWeiRaised);
      amountTokenBought = amountTokenBought.add(amountBoughtInTier);
      currentWeiRaised = currentWeiRaised.add(amountToBuy.sub(amountLeftTobuy));
      amountToBuy = amountLeftTobuy;
     }
     if (currentWeiRaised < TIER3 && amountToBuy > 0) {
      (amountBoughtInTier, amountLeftTobuy) = calculateAmountPerTier(amountToBuy,TIER3,RATE3,currentWeiRaised);
      amountTokenBought = amountTokenBought.add(amountBoughtInTier);
      currentWeiRaised = currentWeiRaised.add(amountToBuy.sub(amountLeftTobuy));
      amountToBuy = amountLeftTobuy;
     }
    if ( currentWeiRaised < cap && amountToBuy > 0) {
      (amountBoughtInTier, amountLeftTobuy) = calculateAmountPerTier(amountToBuy,cap,RATE4,currentWeiRaised);
      amountTokenBought = amountTokenBought.add(amountBoughtInTier);
      currentWeiRaised = currentWeiRaised.add(amountToBuy.sub(amountLeftTobuy));
      amountToBuy = amountLeftTobuy;
    }
    return amountTokenBought;
  }

  // calculate the amount of token within a tier.
  function calculateAmountPerTier(uint256 amountToBuy,uint256 tier,uint256 rate,uint256 currentWeiRaised) internal returns (uint256,uint256) {
    uint256 amountAvailable = tier.sub(currentWeiRaised);
    if ( amountToBuy > amountAvailable ) {
      uint256 amountBoughtInTier = amountAvailable.mul(rate);
      amountToBuy = amountToBuy.sub(amountAvailable);
      return (amountBoughtInTier,amountToBuy);
    } else {
      amountBoughtInTier = amountToBuy.mul(rate);
      return (amountBoughtInTier,0);
    }
  }

  function finalization() internal {
    if (goalReached()) {
      //Globcoin gets 60% of the amount of the total token supply
      uint256 totalSupply = token.totalSupply();
      // total supply
      token.mint(wallet, totalSupply);
      // 50% of tokens generated during crowdsale to make it 60% for GC
      token.mint(wallet, totalSupply.div(2));
      token.finishMinting();
    }
    super.finalization();
  }

  // Override of the validPurchase function so that the new sale periode start at StartSale instead of Startblock.
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = block.number >= startSale && block.number <= endBlock;
    bool nonZeroPurchase = msg.value != 0;
    uint256 totalWeiRaised = weiRaisedPreSale.add(weiRaised);
    bool withinCap = totalWeiRaised.add(msg.value) <= cap;
    return withinCap && withinPeriod && nonZeroPurchase;
  }

  // Sale period start at StartBlock until the sale Start ( startSale )
  function validPurchasePresale() internal constant returns (bool) {
    bool withinPeriod = (block.number >= startBlock) && (block.number <= endPresale);
    bool nonZeroPurchase = msg.value != 0;
    bool withinCap = weiRaisedPreSale.add(msg.value) <= presaleCap;
    return withinPeriod && nonZeroPurchase && withinCap;
  }

  // Override of the goalReached function so that the goal take into account the token raised during the Presale.
  function goalReached() public constant returns (bool) {
    uint256 totalWeiRaised = weiRaisedPreSale.add(weiRaised);
    return totalWeiRaised >= goal || super.goalReached();
  }

}