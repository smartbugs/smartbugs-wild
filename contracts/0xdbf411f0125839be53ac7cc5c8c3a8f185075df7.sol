/**
 *  PERSONO.ID is WEB 3.0 cornerstone.
 *  Human first. UBI out of the box. Inevitable.
 *  This contract is a crowdsale of transitional GUT tokens for ETH.
 *  Join early. Don't miss the rise of the great, and impressive bounties.
 *  Open site() at GUT token address 0xbA01AfF9EF5198B5e691D2ac61E3cC126F25491d
**/

pragma solidity ^0.4.24;

/**
 * @title ERC20 interface
 */
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
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/**
 * @title Standard ERC20 token
 *
 * @notice The full implementation is in the token. Here it is just for correct compilation. 
 */
contract ERC20 is IERC20 {
  /**
   * @dev Internal ERC20 token function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal;
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

contract MinterRole {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private minters;

  constructor() internal {
    _addMinter(msg.sender);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender));
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyMinter {
    _addMinter(account);
  }

  function renounceMinter() public {
    _removeMinter(msg.sender);
  }

  function _addMinter(address account) internal {
    minters.add(account);
    emit MinterAdded(account);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}

/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic. Shortened. Full contract is in the GutTCO.token() contract.
 */
contract ERC20Mintable is ERC20, MinterRole {
  
  /**
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address to,
    uint256 value
  )
    public
    onlyMinter
    returns (bool)
  {
    _mint(to, value);
    return true;
  }
}

/**
 * @title SafeERC20
 * @notice Shortened Wrappers around ERC20 operations that throw on failure.
 */
library SafeERC20 {

  using SafeMath for uint256;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
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

  constructor() internal {
    // The counter starts at one to prevent changing it from zero to a non-zero
    // value, which is a more expensive operation.
    _guardCounter = 1;
  }

  /**
   * @notice Prevents a contract from calling itself, directly or indirectly.
   */
  modifier nonReentrant() {
    _guardCounter += 1;
    uint256 localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter);
  }

}

/**
 * @title Crowdsale
 * @notice Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and is extended by other contracts here to provide additional
 * functionality and custom behavior.
 */
contract Crowdsale is ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  // The token being sold
  IERC20 private _token;

  // Address where funds are collected
  address private _wallet;

  // How many token units a buyer would get per wei. 
  // Usually is the conversion between wei and the smallest and indivisible token unit.
  // Overridden by IcreasingPriceTCO contract logic.
  uint256 private _rate;

  // Amount of wei raised
  uint256 private _weiRaised;

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

  /**
   * @param rate Number of token units a buyer gets per wei
   * @dev The rate is the conversion between wei and the smallest and indivisible
   * token unit. So, if you are using a rate of 1 with a ERC20Detailed token
   * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.
   * @param wallet Address where collected funds will be forwarded to
   * @param token Address of the token being sold
   */
  constructor(uint256 rate, address wallet, IERC20 token) internal {
    require(rate > 0);
    require(wallet != address(0));
    require(token != address(0));

    _rate = rate;
    _wallet = wallet;
    _token = token;
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
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * This function has a non-reentrancy guard, so it shouldn't be called by
   * another `nonReentrant` function.
   * @param beneficiary Recipient of the token purchase
   */
  function buyTokens(address beneficiary) public nonReentrant payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    _weiRaised = _weiRaised.add(weiAmount);

    _processPurchase(beneficiary, tokens);
    emit TokensPurchased(
      msg.sender,
      beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(beneficiary, weiAmount); //check and manage current exchange rate and hard cap
    _forwardFunds(); //save funds to a Persono.id Foundation address
    _postValidatePurchase(beneficiary, weiAmount); 
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
   * Example from CappedCrowdsale.sol's _preValidatePurchase method:
   *   super._preValidatePurchase(beneficiary, weiAmount);
   *   require(weiRaised().add(weiAmount) <= cap);
   * @param beneficiary Address performing the token purchase
   * @param weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal
    view
  {
    require(beneficiary != address(0));
    require(weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param beneficiary Address performing the token purchase
   * @param weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal
    view
  {
    // optional override
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
    _token.safeTransfer(beneficiary, tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send tokens.
   * @param beneficiary Address receiving the tokens
   * @param tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address beneficiary,
    uint256 tokenAmount
  )
    internal
  {
    _deliverTokens(beneficiary, tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param beneficiary Address receiving the tokens
   * @param weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address beneficiary,
    uint256 weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 weiAmount)
    internal view returns (uint256)
  {
    return weiAmount.mul(_rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    _wallet.transfer(msg.value);
  }
}

/**
 * @title IncreasingPriceTCO
 * @notice Extension of Crowdsale contract that increases the price of tokens according to price ranges. 
 * Early adopters get up to 24 times more benefits.
 */
contract IncreasingPriceTCO is Crowdsale {
    using SafeMath for uint256;

    uint256[2][] private _rates; //_rates[i][0] - upper limit of total weiRaised to apply _rates[i][1] exchange rate at the 
    uint8 private _currentRateIndex; // Index of the current rate: _rates[_currentIndex][1] is the current rate index

    event NewRateIsSet(
    uint8 rateIndex,
    uint256 exRate,
    uint256 weiRaisedRange,
    uint256 weiRaised
  );
  /**
   * @param initRates Is an array of pairs [weiRaised, exchangeRate]. Deteremine the exchange rate depending on the total wei raised before the transaction. 
  */
  constructor(uint256[2][] memory initRates) internal {
    require(initRates.length > 1, 'Rates array should contain more then one value');
    _rates = initRates;
    _currentRateIndex = 0;
  }
 
  function getCurrentRate() public view returns(uint256) {
    return _rates[_currentRateIndex][1];
  }

  modifier ifExRateNeedsUpdate {
    if(weiRaised() >= _rates[_currentRateIndex][0] && _currentRateIndex < _rates.length - 1)
      _;
  }

  /**
   * @notice The new exchange rate is set if total weiRased() exceeds the current exchange rate range 
   */
  function _updateCurrentRate() internal ifExRateNeedsUpdate {
    uint256 _weiRaised = weiRaised();
    _currentRateIndex++; //the modifier ifExRateNeedsUpdate means the exchange rate is changed, so we move to the next range right away
    while(_currentRateIndex < _rates.length - 1 && _rates[_currentRateIndex][0] <= _weiRaised) {
      _currentRateIndex++;
    }
    emit NewRateIsSet(_currentRateIndex, //new exchange rate index
                      _rates[_currentRateIndex][1], //new exchange rate 
                      _rates[_currentRateIndex][0], //new exchange rate _weiRaised limit
                      _weiRaised); //amount of _weiRaised by the moment the new exchange rate is applied
  }

  /**
   * @notice The base rate function is overridden to revert, since this crowdsale doens't use it, and
   * all calls to it are a mistake.
   */
  function rate() public view returns(uint256) {
    revert();
  }
  
  /**
   * @notice Overrides function applying multiple increasing price exchange rates concept
   */
  function _getTokenAmount(uint256 weiAmount)
    internal view returns (uint256)
  {
    return getCurrentRate().mul(weiAmount);
  }

  /**
   * @notice Overrides a "hook" from the base Crowdsale contract. Checks and updates the current exchange rate. 
   */
  function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal
  {
    _updateCurrentRate();
  }
}

contract KeeperRole {
  using Roles for Roles.Role;

  event KeeperAdded(address indexed account);
  event KeeperRemoved(address indexed account);

  Roles.Role private keepers;

  constructor() internal {
    _addKeeper(msg.sender);
  }

  modifier onlyKeeper() {
    require(isKeeper(msg.sender), 'Only Keeper is allowed');
    _;
  }

  function isKeeper(address account) public view returns (bool) {
    return keepers.has(account);
  }

  function addKeeper(address account) public onlyKeeper {
    _addKeeper(account);
  }

  function renounceKeeper() public {
    _removeKeeper(msg.sender);
  }

  function _addKeeper(address account) internal {
    keepers.add(account);
    emit KeeperAdded(account);
  }

  function _removeKeeper(address account) internal {
    keepers.remove(account);
    emit KeeperRemoved(account);
  }
}

contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}

/**
 * @title Haltable
 * @dev Base contract which allows children to implement an emergency pause mechanism 
 * and close irreversibly
 */
contract Haltable is KeeperRole, PauserRole {
  event Paused(address account);
  event Unpaused(address account);
  event Closed(address account);

  bool private _paused;
  bool private _closed;

  constructor() internal {
    _paused = false;
    _closed = false;
  }

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
    return _paused;
  }

  /**
   * @return true if the contract is closed, false otherwise.
   */
  function isClosed() public view returns(bool) {
    return _closed;
  }

  /**
   * @return true if the contract is not closed, false otherwise.
   */
  function notClosed() public view returns(bool) {
    return !_closed;
  }

  /**
   * @notice Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused, 'The contract is paused');
    _;
  }

  /**
   * @notice Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused, 'The contract is not paused');
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is closed.
   */
  modifier whenClosed(bool orCondition) {
    require(_closed, 'The contract is not closed');
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is closed or an external condition is met.
   */
  modifier whenClosedOr(bool orCondition) {
    require(_closed || orCondition, "It must be closed or what is set in 'orCondition'");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not closed.
   */
  modifier whenNotClosed() {
    require(!_closed, "Reverted because it is closed");
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }

  /**
   * @dev Called by a Keeper to close a contract. This is irreversible.
   */
  function close() internal whenNotClosed {
    _closed = true;
    emit Closed(msg.sender);
  }
}

/**
 * @title CappedCrowdsale
 * @dev Crowdsale with a limit for total contributions.
 */
contract CappedTCO is Crowdsale {
  using SafeMath for uint256;
  uint256 private _cap;
  
  /**
   * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.
   * @param cap Max amount of wei to be contributed
   */
  constructor(uint256 cap) internal {
      require(cap > 0, 'Hard cap must be > 0');
      _cap = cap;
  }
  
  /**
   * @return the cap of the crowdsale.
   */
  function cap() public view returns(uint256) {
      return _cap;
  }
  
  /**
   * @dev Checks whether the cap has been reached.
   * @return Whether the cap was not reached
   */
  function capNotReached() public view returns (bool) {
      return weiRaised() < _cap;
  }
  
  /**
   * @dev Checks whether the cap has been reached.
   * @return Whether the cap was reached
   */
  function capReached() public view returns (bool) {
      return weiRaised() >= _cap;
  }
}

/**
 * @title PostDeliveryCappedCrowdsale
 * @notice Hardcapped crowdsale with the gained tokens locked from withdrawal until the crowdsale ends.
 */
contract PostDeliveryCappedTCO is CappedTCO, Haltable {
  using SafeMath for uint256;

  mapping(address => uint256) private _balances; //token balances storage until the crowdsale ends

  uint256 private _totalSupply; //total GUT distributed amount

  event TokensWithdrawn(
    address indexed beneficiary,
    uint256 amount
  );

  constructor() internal {}

  /**
   * @notice Withdraw tokens only after the crowdsale ends (closed).
   * @param beneficiary is an address whose tokens will be withdrawn. Allows to use a separate address 
   * @notice Withdrawal is suspended in case the crowdsale is paused.
   */
  function withdrawTokensFrom(address beneficiary) public whenNotPaused whenClosedOr(capReached()) {
    uint256 amount = _balances[beneficiary];
    require(amount > 0, 'The balance should be positive for withdrawal. Please check the balance in the token contract.');
    _balances[beneficiary] = 0;
    _deliverTokens(beneficiary, amount);
    emit TokensWithdrawn(beneficiary, amount);
  }

  /**
   * @notice If calling this function (wothdrawing) from a contract, use withdrawTokensFrom(address beneficiary)
   * Check that crowdsale is finished: GutTCO.isClosed() == true before running this function (withdrawing tokens).
   */
  function withdrawTokens() public {
    withdrawTokensFrom(address(msg.sender));
  }

  /**
   * @notice Total amount of tokens supplied
   */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @return the balance of an account.
   */
  function balanceOf(address account) public view returns(uint256) {
    return _balances[account];
  }

  /**
   * @dev Extend parent behavior requiring purchase to respect the funding cap.
   * @param beneficiary Token purchaser
   * @param weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
      address beneficiary,
      uint256 weiAmount
  )
      internal
      view
  {
      require(capNotReached(),"Hardcap is reached.");
      require(notClosed(), "TCO is finished, sorry.");
      super._preValidatePurchase(beneficiary, weiAmount);
  }

  /**
   * @dev Overrides parent by storing balances instead of issuing tokens right away
   * @param beneficiary Token purchaser
   * @param tokenAmount Amount of tokens purchased
   */
  function _processPurchase(
    address beneficiary,
    uint256 tokenAmount
  )
    internal
  {
    _balances[beneficiary] = _balances[beneficiary].add(tokenAmount);
    _totalSupply = _totalSupply.add(tokenAmount);
  }
}

/**
 * @notice If you transfer funds (ETH) from a contract, the default gas stipend 2300 will not be enough 
 * to complete transaction to your contract address. Please, consider calling buyTokens() directly when
 * purchasing tokens from a contract.
*/
contract GutTCO is 
PostDeliveryCappedTCO, 
IncreasingPriceTCO, 
MinterRole
{
    bool private _finalized;

    event CrowdsaleFinalized();

    constructor(
    uint256 _rate,
    address _wallet,
    uint256 _cap,
    ERC20Mintable _token
  ) public 
  Crowdsale(_rate, _wallet, _token)
  CappedTCO(_cap)
  IncreasingPriceTCO(initRates())
  {
    _finalized = false;
  }

  /**
   * @notice Initializes exchange rates ranges.
   */
  function initRates() internal pure returns(uint256[2][] memory ratesArray) {
     ratesArray = new uint256[2][](4);
     ratesArray[0] = [uint256(100000 ether), 3000]; //first 100000 ether are given 3000 GUT each
     ratesArray[1] = [uint256(300000 ether), 1500]; //next 200000 (up to 300000) ether are exchanged at 1500 GUT/ether 
     ratesArray[2] = [uint256(700000 ether), 500];  //next 400000 ether will go to Persono.id Foundation at 500 GUT/ether
     ratesArray[3] = [uint256(1500000 ether), 125]; //the rest 800000 ether are exchanged at 125 GUT/ether
  }

  function closeTCO() public onlyMinter {
     if(notFinalized()) _finalize();
  }

  /**
   * @return true if the crowdsale is finalized, false otherwise.
   */
  function finalized() public view returns (bool) {
    return _finalized;
  }

  /**
   * @return true if the crowdsale is finalized, false otherwise.
   */
  function notFinalized() public view returns (bool) {
    return !finalized();
  }

  /**
   * @notice Is called after TCO finished to close() TCO and transfer (mint) supplied tokens to the token's contract.
   */
  function _finalize() private {
    require(notFinalized(), 'TCO already finalized');
    if(notClosed()) close();
    _finalization();
    emit CrowdsaleFinalized();
  }

  function _finalization() private {
     if(totalSupply() > 0)
        require(ERC20Mintable(address(token())).mint(address(this), totalSupply()), 'Error when being finalized at minting totalSupply() to the token');
     _finalized = true;
  }

  /**
   * @notice Overrides IncreasingPriceTCO. Auto finalize TCO when the cap is reached.
   */
  function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal 
  {
    super._updatePurchasingState(beneficiary, weiAmount);
    if(capReached()) _finalize();
  }
}