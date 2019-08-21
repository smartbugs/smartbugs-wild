pragma solidity 0.4.25;

contract TokenConfig {
  string public constant NAME = "MANGO";
  string public constant SYMBOL = "MANG";
  uint8 public constant DECIMALS = 5;
  uint public constant DECIMALSFACTOR = 10 ** uint(DECIMALS);
  uint public constant TOTALSUPPLY = 10000000000 * DECIMALSFACTOR;
}

interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "can't mul");

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, "can't sub with zero.");

    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "can't sub");
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "add overflow");

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "can't mod with zero");
    return a % b;
  }
}

library SafeERC20 {
  using SafeMath for uint256;

  function safeTransfer(IERC20 token, address to, uint256 value) internal {
    require(token.transfer(to, value), "safeTransfer");
  }

  function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
    require(token.transferFrom(from, to, value), "safeTransferFrom");
  }

  function safeApprove(IERC20 token, address spender, uint256 value) internal {
    // safeApprove should only be called when setting an initial allowance,
    // or when resetting it to zero. To increase and decrease it, use
    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
    require((value == 0) || (token.allowance(msg.sender, spender) == 0), "safeApprove");
    require(token.approve(spender, value), "safeApprove");
  }

  function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance), "safeIncreaseAllowance");
  }

  function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance), "safeDecreaseAllowance");
  }
}

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
  /// @dev counter to allow mutex lock with only one SSTORE operation
  uint256 private _guardCounter;

  constructor () internal {
    // The counter starts at one to prevent changing it from zero to a non-zero
    // value, which is a more expensive operation.
    _guardCounter = 1;
  }

  /**
    * @dev Prevents a contract from calling itself, directly or indirectly.
    * Calling a `nonReentrant` function from another `nonReentrant`
    * function is not supported. It is possible to prevent this from happening
    * by making the `nonReentrant` function external, and make it call a
    * `private` function that does the actual work.
    */
  modifier nonReentrant() {
    _guardCounter += 1;
    uint256 localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter, "nonReentrant.");
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

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
    require(msg.sender == owner, "only for owner.");
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "address is zero.");
    owner = newOwner;
    emit OwnershipTransferred(owner, newOwner);
  }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() internal {
    _paused = false;
  }

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused, "paused.");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused, "Not paused.");
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }
}

/**
 * @title Crowdsale white list address
 */
contract Whitelist is Ownable {
  event WhitelistAdded(address addr);
  event WhitelistRemoved(address addr);

  mapping (address => bool) private _whitelist;

  /**
   * @dev add addresses to the whitelist
   * @param addrs addresses
   */
  function addWhiteListAddr(address[] addrs)
    public
  {
    uint256 len = addrs.length;
    for (uint256 i = 0; i < len; i++) {
      _addAddressToWhitelist(addrs[i]);
    }
  }

  /**
   * @dev remove an address from the whitelist
   * @param addr address
   */
  function removeWhiteListAddr(address addr)
    public
  {
    _removeAddressToWhitelist(addr);
  }

  /**
   * @dev getter to determine if address is in whitelist
   */
  function isWhiteListAddr(address addr)
    public
    view
    returns (bool)
  {
    require(addr != address(0), "address is zero");
    return _whitelist[addr];
  }

  modifier onlyAuthorised(address beneficiary) {
    require(isWhiteListAddr(beneficiary),"Not authorised");
    _;
  }

  /**
   * @dev add an address to the whitelist
   * @param addr address
   */
  function _addAddressToWhitelist(address addr)
    internal
    onlyOwner
  {
    require(addr != address(0), "address is zero");
    _whitelist[addr] = true;
    emit WhitelistAdded(addr);
  }

    /**
   * @dev remove an address from the whitelist
   * @param addr address
   */
  function _removeAddressToWhitelist(address addr)
    internal
    onlyOwner
  {
    require(addr != address(0), "address is zero");
    _whitelist[addr] = false;
    emit WhitelistRemoved(addr);
  }
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate
 * behavior.
 */
contract Crowdsale is TokenConfig, Pausable, ReentrancyGuard, Whitelist {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  // The token being sold
  IERC20 private _token;

  // Address where funds are collected
  address private _wallet;

  // Address where funds are collected
  address private _tokenholder;

  // How many token units a buyer gets per wei.
  // The rate is the conversion between wei and the smallest and indivisible token unit.
  // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
  // 1 wei will give you 1 unit, or 0.001 TOK.
  uint256 private _rate;

  // Amount of contribution wei raised
  uint256 private _weiRaised;

  // Amount of token sold
  uint256 private _tokenSoldAmount;

  // Minimum contribution amount of fund
  uint256 private _minWeiAmount;

  // balances of user should be sent
  mapping (address => uint256) private _tokenBalances;

  // balances of user fund
  mapping (address => uint256) private _weiBalances;

  // ICO period timestamp
  uint256 private _openingTime;
  uint256 private _closingTime;

  // Amount of token hardcap
  uint256 private _hardcap;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokensPurchased(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );
  event TokensDelivered(address indexed beneficiary, uint256 amount);
  event RateChanged(uint256 rate);
  event MinWeiChanged(uint256 minWei);
  event PeriodChanged(uint256 open, uint256 close);
  event HardcapChanged(uint256 hardcap);

  constructor(
    uint256 rate,
    uint256 minWeiAmount,
    address wallet,
    address tokenholder,
    IERC20 token,
    uint256 hardcap,
    uint256 openingTime,
    uint256 closingTime
  ) public {
    require(rate > 0, "Rate is lower than zero.");
    require(wallet != address(0), "Wallet address is zero");
    require(tokenholder != address(0), "Tokenholder address is zero");
    require(token != address(0), "Token address is zero");

    _rate = rate;
    _minWeiAmount = minWeiAmount;
    _wallet = wallet;
    _tokenholder = tokenholder;
    _token = token;
    _hardcap = hardcap;
    _openingTime = openingTime;
    _closingTime = closingTime;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   * Note that other contracts will transfer fund with a base gas stipend
   * of 2300, which is not enough to call buyTokens. Consider calling
   * buyTokens directly when purchasing tokens from a contract.
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @return the token being sold.
   */
  function token() public view returns(IERC20) {
    return _token;
  }

  /**
   * @return token hardcap.
   */
  function hardcap() public view returns(uint256) {
    return _hardcap;
  }

  /**
   * @return the address where funds are collected.
   */
  function wallet() public view returns(address) {
    return _wallet;
  }

  /**
   * @return the number of token units a buyer gets per wei.
   */
  function rate() public view returns(uint256) {
    return _rate;
  }

  /**
   * @return the amount of wei raised.
   */
  function weiRaised() public view returns (uint256) {
    return _weiRaised;
  }

  /**
   * @return ICO opening time.
   */
  function openingTime() public view returns (uint256) {
    return _openingTime;
  }

  /**
   * @return ICO closing time.
   */
  function closingTime() public view returns (uint256) {
    return _closingTime;
  }

  /**
   * @return the amount of token raised.
   */
  function tokenSoldAmount() public view returns (uint256) {
    return _tokenSoldAmount;
  }

  /**
   * @return the number of minimum amount buyer can fund.
   */
  function minWeiAmount() public view returns(uint256) {
    return _minWeiAmount;
  }

  /**
   * @return is ICO period
   */
  function isOpen() public view returns (bool) {
     // solium-disable-next-line security/no-block-members
    return now >= _openingTime && now <= _closingTime;
  }

  /**
  * @dev Gets the token balance of the specified address for deliver
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function tokenBalanceOf(address owner) public view returns (uint256) {
    return _tokenBalances[owner];
  }

  /**
  * @dev Gets the ETH balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function weiBalanceOf(address owner) public view returns (uint256) {
    return _weiBalances[owner];
  }

  function setRate(uint256 value) public onlyOwner {
    _rate = value;
    emit RateChanged(value);
  }

  function setMinWeiAmount(uint256 value) public onlyOwner {
    _minWeiAmount = value;
    emit MinWeiChanged(value);
  }

  function setPeriodTimestamp(uint256 open, uint256 close)
    public
    onlyOwner
  {
    _openingTime = open;
    _closingTime = close;
    emit PeriodChanged(open, close);
  }

  function setHardcap(uint256 value) public onlyOwner {
    _hardcap = value;
    emit HardcapChanged(value);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * This function has a non-reentrancy guard, so it shouldn't be called by
   * another `nonReentrant` function.
   * @param beneficiary Recipient of the token purchase
   */
  function buyTokens(address beneficiary)
    public
    nonReentrant
    whenNotPaused
    payable
  {
    uint256 weiAmount = msg.value;
    _preValidatePurchase(beneficiary, weiAmount);

    // Calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    require(_hardcap > _tokenSoldAmount.add(tokens), "Over hardcap");

    // Update state
    _weiRaised = _weiRaised.add(weiAmount);
    _tokenSoldAmount = _tokenSoldAmount.add(tokens);

    _weiBalances[beneficiary] = _weiBalances[beneficiary].add(weiAmount);
    _tokenBalances[beneficiary] = _tokenBalances[beneficiary].add(tokens);

    emit TokensPurchased(
      msg.sender,
      beneficiary,
      weiAmount,
      tokens
    );

    _forwardFunds();
  }

  /**
   * @dev method that deliver token to user
   */
  function deliverTokens(address[] users)
    public
    whenNotPaused
    onlyOwner
  {
    uint256 len = users.length;
    for (uint256 i = 0; i < len; i++) {
      address user = users[i];
      uint256 tokenAmount = _tokenBalances[user];
      _deliverTokens(user, tokenAmount);
      _tokenBalances[user] = 0;

      emit TokensDelivered(user, tokenAmount);
    }
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
   * @param beneficiary Address performing the token purchase
   * @param weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal
    view
    onlyAuthorised(beneficiary)
  {
    require(weiAmount != 0, "Zero ETH");
    require(weiAmount >= _minWeiAmount, "Must be equal or higher than minimum");
    require(beneficiary != address(0), "Beneficiary address is zero");
    require(isOpen(), "Sales is close");
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param beneficiary Address performing the token purchase
   * @param tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address beneficiary,
    uint256 tokenAmount
  )
    internal
  {
    _token.safeTransferFrom(_tokenholder, beneficiary, tokenAmount);
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 weiAmount) internal view returns (uint256)
  {
    uint ethDecimals = 18;
    require(DECIMALS <= ethDecimals, "");

    uint256 covertedTokens = weiAmount;
    if (DECIMALS != ethDecimals) {
      covertedTokens = weiAmount.div((10 ** uint256(ethDecimals - DECIMALS)));
    }
    return covertedTokens.mul(_rate);
  }

  /**
    * @dev Determines how ETH is stored/forwarded on purchases.
    */
  function _forwardFunds() internal {
    _wallet.transfer(msg.value);
  }
}