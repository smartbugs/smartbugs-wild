pragma solidity 0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
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
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override 
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */

contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  function Crowdsale(uint256 _rate, address _wallet, ERC20 _token) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
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
    TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statemens to revert state when conditions are not met. Use super to concatenate validations.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    token.transfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

/**
 * @title AllowanceCrowdsale
 * @dev Extension of Crowdsale where tokens are held by a wallet, which approves an allowance to the crowdsale.
 */
contract AllowanceCrowdsale is Crowdsale {
  using SafeMath for uint256;

  address public tokenWallet;

  /**
   * @dev Constructor, takes token wallet address. 
   * @param _tokenWallet Address holding the tokens, which has approved allowance to the crowdsale
   */
  function AllowanceCrowdsale(address _tokenWallet) public {
    require(_tokenWallet != address(0));
    tokenWallet = _tokenWallet;
  }

  /**
   * @dev Checks the amount of tokens left in the allowance.
   * @return Amount of tokens left in the allowance
   */
  function remainingTokens() public view returns (uint256) {
    return token.allowance(tokenWallet, this);
  }

  /**
   * @dev Overrides parent behavior by transferring tokens from wallet.
   * @param _beneficiary Token purchaser
   * @param _tokenAmount Amount of tokens purchased
   */
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    token.transferFrom(tokenWallet, _beneficiary, _tokenAmount);
  }
}

/**
 * @title WhitelistedCrowdsale
 * @dev Crowdsale in which only whitelisted users can contribute.
 */
contract WhitelistedCrowdsale is Crowdsale, Ownable {

  mapping(address => bool) public whitelist;

  /**
   * @dev Reverts if beneficiary is not whitelisted. Can be used when extending this contract.
   */
  modifier isWhitelisted(address _beneficiary) {
    require(whitelist[_beneficiary]);
    _;
  }

  /**
   * @dev Adds single address to whitelist.
   * @param _beneficiary Address to be added to the whitelist
   */
  function addToWhitelist(address _beneficiary) external onlyOwner {
    whitelist[_beneficiary] = true;
  }
  
  /**
   * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing. 
   * @param _beneficiaries Addresses to be added to the whitelist
   */
  function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {
    for (uint256 i = 0; i < _beneficiaries.length; i++) {
      whitelist[_beneficiaries[i]] = true;
    }
  }

  /**
   * @dev Removes single address from whitelist. 
   * @param _beneficiary Address to be removed to the whitelist
   */
  function removeFromWhitelist(address _beneficiary) external onlyOwner {
    whitelist[_beneficiary] = false;
  }

  /**
   * @dev Extend parent behavior requiring beneficiary to be in whitelist.
   * @param _beneficiary Token beneficiary
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal isWhitelisted(_beneficiary) {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;

  /**
   * @dev Reverts if not in crowdsale time range. 
   */
  modifier onlyWhileOpen {
    require(now >= openingTime && now <= closingTime);
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param _openingTime Crowdsale opening time
   * @param _closingTime Crowdsale closing time
   */
  function TimedCrowdsale(uint256 _openingTime, uint256 _closingTime) public {
    require(_openingTime >= now);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    return now > closingTime;
  }
  
  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal onlyWhileOpen {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is TimedCrowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasClosed());

    finalization();
    Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

/**
 * @title RTEBonusTokenVault
 * @dev Token holder contract that releases tokens to the respective addresses
 * and _lockedReleaseTime
 */
contract RTEBonusTokenVault is Ownable {
  using SafeERC20 for ERC20Basic;
  using SafeMath for uint256;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  bool public vaultUnlocked;

  bool public vaultSecondaryUnlocked;

  // How much we have allocated to the investors invested
  mapping(address => uint256) public balances;

  mapping(address => uint256) public lockedBalances;

  /**
   * @dev Allocation event
   * @param _investor Investor address
   * @param _value Tokens allocated
   */
  event Allocated(address _investor, uint256 _value);

  /**
   * @dev Distribution event
   * @param _investor Investor address
   * @param _value Tokens distributed
   */
  event Distributed(address _investor, uint256 _value);

  function RTEBonusTokenVault(
    ERC20Basic _token
  )
    public
  {
    token = _token;
    vaultUnlocked = false;
    vaultSecondaryUnlocked = false;
  }

  /**
   * @dev Unlocks vault
   */
  function unlock() public onlyOwner {
    require(!vaultUnlocked);
    vaultUnlocked = true;
  }

  /**
   * @dev Unlocks secondary vault
   */
  function unlockSecondary() public onlyOwner {
    require(vaultUnlocked);
    require(!vaultSecondaryUnlocked);
    vaultSecondaryUnlocked = true;
  }

  /**
   * @dev Add allocation amount to investor addresses
   * Only the owner of this contract - the crowdsale can call this function
   * Split half to be locked by timelock in vault, the other half to be released on vault unlock
   * @param _investor Investor address
   * @param _amount Amount of tokens to add
   */
  function allocateInvestorBonusToken(address _investor, uint256 _amount) public onlyOwner {
    require(!vaultUnlocked);
    require(!vaultSecondaryUnlocked);

    uint256 bonusTokenAmount = _amount.div(2);
    uint256 bonusLockedTokenAmount = _amount.sub(bonusTokenAmount);

    balances[_investor] = balances[_investor].add(bonusTokenAmount);
    lockedBalances[_investor] = lockedBalances[_investor].add(bonusLockedTokenAmount);

    Allocated(_investor, _amount);
  }

  /**
   * @dev Transfers bonus tokens held to investor
   * @param _investor Investor address making the claim
   */
  function claim(address _investor) public onlyOwner {
    // _investor is the original initiator
    // msg.sender is the contract that called this.
    require(vaultUnlocked);

    uint256 claimAmount = balances[_investor];
    require(claimAmount > 0);

    uint256 tokenAmount = token.balanceOf(this);
    require(tokenAmount > 0);

    // Empty token balance
    balances[_investor] = 0;

    token.safeTransfer(_investor, claimAmount);

    Distributed(_investor, claimAmount);
  }

  /**
   * @dev Transfers secondary bonus tokens held to investor
   * @param _investor Investor address making the claim
   */
  function claimLocked(address _investor) public onlyOwner {
    // _investor is the original initiator
    // msg.sender is the contract that called this.
    require(vaultUnlocked);
    require(vaultSecondaryUnlocked);

    uint256 claimAmount = lockedBalances[_investor];
    require(claimAmount > 0);

    uint256 tokenAmount = token.balanceOf(this);
    require(tokenAmount > 0);

    // Empty token balance
    lockedBalances[_investor] = 0;

    token.safeTransfer(_investor, claimAmount);

    Distributed(_investor, claimAmount);
  }
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

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
  function balanceOf(address _owner) public view returns (uint256 balance) {
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

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

/**
 * @title Whitelisted Pausable token
 * @dev StandardToken modified with pausable transfers. Enables a whitelist to enable transfers
 * only for certain addresses such as crowdsale contract, issuing account etc.
 **/
contract WhitelistedPausableToken is StandardToken, Pausable {

  mapping(address => bool) public whitelist;

  /**
   * @dev Reverts if the message sender requesting for transfer is not whitelisted when token
   * transfers are paused
   * @param _sender check transaction sender address
   */
  modifier whenNotPausedOrWhitelisted(address _sender) {
    require(whitelist[_sender] || !paused);
    _;
  }

  /**
   * @dev Adds single address to whitelist.
   * @param _whitelistAddress Address to be added to the whitelist
   */
  function addToWhitelist(address _whitelistAddress) external onlyOwner {
    whitelist[_whitelistAddress] = true;
  }

  /**
   * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.
   * @param _whitelistAddresses Addresses to be added to the whitelist
   */
  function addManyToWhitelist(address[] _whitelistAddresses) external onlyOwner {
    for (uint256 i = 0; i < _whitelistAddresses.length; i++) {
      whitelist[_whitelistAddresses[i]] = true;
    }
  }

  /**
   * @dev Removes single address from whitelist.
   * @param _whitelistAddress Address to be removed to the whitelist
   */
  function removeFromWhitelist(address _whitelistAddress) external onlyOwner {
    whitelist[_whitelistAddress] = false;
  }

  // Adding modifier to transfer/approval functions
  function transfer(address _to, uint256 _value) public whenNotPausedOrWhitelisted(msg.sender) returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPausedOrWhitelisted(msg.sender) returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPausedOrWhitelisted(msg.sender) returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPausedOrWhitelisted(msg.sender) returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPausedOrWhitelisted(msg.sender) returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

/**
 * @title RTEToken
 * @dev ERC20 token implementation
 * Pausable
 */
contract RTEToken is WhitelistedPausableToken {
  string public constant name = "Rate3";
  string public constant symbol = "RTE";
  uint8 public constant decimals = 18;

  // 1 billion initial supply of RTE tokens
  // Taking into account 18 decimals
  uint256 public constant INITIAL_SUPPLY = (10 ** 9) * (10 ** 18);

  /**
   * @dev RTEToken Constructor
   * Mints the initial supply of tokens, this is the hard cap, no more tokens will be minted.
   * Allocate the tokens to the foundation wallet, issuing wallet etc.
   */
  function RTEToken() public {
    // Mint initial supply of tokens. All further minting of tokens is disabled
    totalSupply_ = INITIAL_SUPPLY;

    // Transfer all initial tokens to msg.sender
    balances[msg.sender] = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }
}

/**
 * @title RTECrowdsale
 * @dev test
 */
contract RTECrowdsale is AllowanceCrowdsale, WhitelistedCrowdsale, FinalizableCrowdsale {
  using SafeERC20 for ERC20;

  uint256 public constant minimumInvestmentInWei = 0.5 ether;

  uint256 public allTokensSold;

  uint256 public bonusTokensSold;

  uint256 public cap;

  mapping (address => uint256) public tokenInvestments;

  mapping (address => uint256) public bonusTokenInvestments;

  RTEBonusTokenVault public bonusTokenVault;

  /**
   * @dev Contract initialization parameters
   * @param _openingTime Public crowdsale opening time
   * @param _closingTime Public crowdsale closing time
   * @param _rate Initial rate (Maybe remove, put as constant)
   * @param _cap RTE token issue cap (Should be the same amount as approved allowance from issueWallet)
   * @param _wallet Multisig wallet to send ether raised to
   * @param _issueWallet Wallet that approves allowance of tokens to be issued
   * @param _token RTE token address deployed seperately
   */
  function RTECrowdsale(
    uint256 _openingTime,
    uint256 _closingTime,
    uint256 _rate,
    uint256 _cap,
    address _wallet,
    address _issueWallet,
    RTEToken _token
  )
    AllowanceCrowdsale(_issueWallet)
    TimedCrowdsale(_openingTime, _closingTime)
    Crowdsale(_rate, _wallet, _token)
    public
  {
    require(_cap > 0);

    cap = _cap;
    bonusTokenVault = new RTEBonusTokenVault(_token);
  }

  /**
   * @dev Checks whether the cap for RTE has been reached.
   * @return Whether the cap was reached
   */
  function capReached() public view returns (bool) {
    return allTokensSold >= cap;
  }

  /**
   * @dev Calculate bonus RTE percentage to be allocated based on time rules
   * time is calculated by now = block.timestamp, will be consistent across transaction if called
   * multiple times in same transaction
   * @return Bonus percentage in percent value
   */
  function _calculateBonusPercentage() internal view returns (uint256) {
    return 20;
  }

  /**
   * @dev Get current RTE balance of bonus token vault
   */
  function getRTEBonusTokenVaultBalance() public view returns (uint256) {
    return token.balanceOf(address(bonusTokenVault));
  }

  /**
   * @dev Extend parent behavior requiring purchase to respect minimum investment per transaction.
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    require(msg.value >= minimumInvestmentInWei);
  }

  /**
   * @dev Keep track of tokens purchased extension functionality
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Value in amount of token purchased
   */
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    uint256 bonusPercentage = _calculateBonusPercentage();
    uint256 additionalBonusTokens = _tokenAmount.mul(bonusPercentage).div(100);
    uint256 tokensSold = _tokenAmount;

    // Check if exceed token sale cap
    uint256 newAllTokensSold = allTokensSold.add(tokensSold).add(additionalBonusTokens);
    require(newAllTokensSold <= cap);

    // Process purchase
    super._processPurchase(_beneficiary, tokensSold);
    allTokensSold = allTokensSold.add(tokensSold);
    tokenInvestments[_beneficiary] = tokenInvestments[_beneficiary].add(tokensSold);

    if (additionalBonusTokens > 0) {
      // Record bonus tokens allocated and transfer it to RTEBonusTokenVault
      allTokensSold = allTokensSold.add(additionalBonusTokens);
      bonusTokensSold = bonusTokensSold.add(additionalBonusTokens);
      bonusTokenVault.allocateInvestorBonusToken(_beneficiary, additionalBonusTokens);
      bonusTokenInvestments[_beneficiary] = bonusTokenInvestments[_beneficiary].add(additionalBonusTokens);
    }
  }

  /**
   * @dev Unlock secondary tokens, can only be done by owner of contract
   */
  function unlockSecondaryTokens() public onlyOwner {
    require(isFinalized);
    bonusTokenVault.unlockSecondary();
  }

  /**
   * @dev Claim bonus tokens from vault after bonus tokens are released
   * @param _beneficiary Address receiving the tokens
   */
  function claimBonusTokens(address _beneficiary) public {
    require(isFinalized);
    bonusTokenVault.claim(_beneficiary);
  }

  /**
   * @dev Claim timelocked bonus tokens from vault after bonus tokens are released
   * @param _beneficiary Address receiving the tokens
   */
  function claimLockedBonusTokens(address _beneficiary) public {
    require(isFinalized);
    bonusTokenVault.claimLocked(_beneficiary);
  }

  /**
   * @dev Called manually when token sale has ended with finalize()
   */
  function finalization() internal {
    // Credit bonus tokens sold to bonusTokenVault
    token.transferFrom(tokenWallet, bonusTokenVault, bonusTokensSold);

    // Unlock bonusTokenVault for non-timelocked tokens to be claimed
    bonusTokenVault.unlock();

    super.finalization();
  }
}