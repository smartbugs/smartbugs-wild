pragma solidity ^0.4.24;

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
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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
* @dev This is a library based implementation of the ERC20 token standard.
* This library allows all values to be set by interface logic. This includes
* the ability to set msg.sender. This allows two distinct advantages:
*  - Access control logic may be layered without the need to change the
*    core logic of the ERC20 system in any way.
*  - Tokens that require administrative action, under some conditions,
*    may take administrative action on an account, without having to
*    create fragile backdoors into the transfer logic of the token. This
*    system makes such administrative priveledge clear, apparent, and
*    more easily auditable to ensure reasonable limitations of power.
*/
library ERC20Lib {


  ////////////////////////////////////////////////////////////////////////////
  //Imports

  /**
  * @dev Prevents underflow and overflow attacks..
  */
  using SafeMath for uint256;
  ///////////////////////////////////////////////////////////////////////////


  ////////////////////////////////////////////////////////////////////////////
  //Events

  /**
  * @dev Transfer event emitted in 3 cases; transfers, minting, and burning.
  * for transfers, all fields set as normal
  * for minting from is set to address(0)
  * for burning is set to address(0)
  */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
  * @dev Specifies an approval being granted from an owner to a spender
  * for the amount specified.
  */
  event Approval(address indexed owner, address indexed spender, uint256 value);
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Declarations

  /**
  * @dev Struct like representation of ERC20 state vairiables.
  * this allows the ERC20 logic to become a library under using for syntax
  */
  struct Token{
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) _allowed;
    uint256 _totalSupply;
  }
  ////////////////////////////////////////////////////////////////////////////


  ////////////////////////////////////////////////////////////////////////////
  //Logic

  /**
  * @dev Returns the total supply of the token.
  */
  function totalSupply(Token storage self)
  internal
  view
  returns (uint256) {
    return self._totalSupply;
  }

  /**
  * @dev Returns the balance of an account.
  */
  function balances(Token storage self, address account)
  internal
  view
  returns (uint256) {
    return self._balances[account];
  }

  /**
  * @dev Returns the total allowance from the account to the spender..
  */
  function allowance(Token storage self, address account, address spender)
  internal
  view
  returns (uint256) {
    return self._allowed[account][spender];
  }

  /**
  * @dev Issues an allowance from an account to another.
  */
  function approve(Token storage self, address sender, address spender, uint256 value)
  internal {
    require(spender != address(0));
    self._allowed[sender][spender] = value;
    emit Approval(sender, spender, value);
  }

  /**
  * @dev Cause a transfer to occur based on an existing allowance.
  */
  function transferFrom(Token storage self, address sender, address from, address to, uint256 value)
  internal {
    require(value <= self._allowed[from][sender]);
    self._allowed[from][sender] = self._allowed[from][sender].sub(value);
    transfer(self,from, to, value);
  }

  /**
  * @dev Increase the allowance from one account to another. Prevents
  * change allowance attack.
  */
  function increaseAllowance(Token storage self, address sender, address spender, uint256 addedValue)
  internal {
    require(spender != address(0));
    self._allowed[sender][spender] = self._allowed[sender][spender].add(addedValue);
    emit Approval(sender, spender, self._allowed[sender][spender]);
  }

  /**
  * @dev Decrease the allowance from one account to another. Prevents
  * the change allowance attack.
  */
  function decreaseAllowance(Token storage self, address sender, address spender, uint256 subtractedValue)
  internal {
    require(spender != address(0));
    self._allowed[sender][spender] = self._allowed[sender][spender].sub(subtractedValue);
    emit Approval(sender, spender, self._allowed[sender][spender]);
  }

  /**
  * @dev Transfer tokens from one account to another.
  */
  function transfer(Token storage self, address sender, address to, uint256 value)
  internal {
    require(value <= self._balances[sender]);
    require(to != address(0));
    self._balances[sender] = self._balances[sender].sub(value);
    self._balances[to] = self._balances[to].add(value);
    emit Transfer(sender, to, value);
  }

  /**
  * @dev Mint new tokens to an account.
  */
  function mint(Token storage self, address account, uint256 value)
  internal {
    require(account != 0);
    self._totalSupply = self._totalSupply.add(value);
    self._balances[account] = self._balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
  * @dev Burn tokens from an account.
  */
  function burn(Token storage self, address account, uint256 value)
  internal {
    require(account != 0);
    require(value <= self._balances[account]);
    self._totalSupply = self._totalSupply.sub(value);
    self._balances[account] = self._balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }
  ////////////////////////////////////////////////////////////////////////////

}



contract HubCulture{

  ////////////////////////////////////////////////////////////////////////////
  //Imports
  using ERC20Lib for ERC20Lib.Token;
  using SafeMath for uint256;
  ///////////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////
  //Events
  event Pending(address indexed account, uint256 indexed value, uint256 indexed nonce);
  event Deposit(address indexed account, uint256 indexed value, uint256 indexed nonce);
  event Withdraw(address indexed account, uint256 indexed value, uint256 indexed nonce);
  event Decline(address indexed account, uint256 indexed value, uint256 indexed nonce);
  event Registration(address indexed account, bytes32 indexed uuid, uint256 indexed nonce);
  event Unregistered(address indexed account, uint256 indexed nonce);
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Declarations
  mapping(address=>bool) authorities;
  mapping(address=>bool) registered;
  mapping(address=>bool) vaults;
  ERC20Lib.Token token;
  ERC20Lib.Token pending;
  uint256 eventNonce;
  address failsafe;
  address owner;
  bool paused;
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Constructor
  constructor(address _owner,address _failsafe)
  public {
    failsafe = _failsafe;
    owner = _owner;
  }
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Modifiers
  modifier onlyFailsafe(){
    require(msg.sender == failsafe);
    _;
  }

  modifier onlyAdmin(){
    require(msg.sender == owner || msg.sender == failsafe);
    _;
  }

  modifier onlyAuthority(){
    require(authorities[msg.sender]);
    _;
  }

  modifier onlyVault(){
    require(vaults[msg.sender]);
    _;
  }

  modifier notPaused(){
    require(!paused);
    _;
  }
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Failsafe Logic
  function isFailsafe(address _failsafe)
  public
  view
  returns (bool){
    return (failsafe == _failsafe);
  }

  function setFailsafe(address _failsafe)
  public
  onlyFailsafe{
    failsafe = _failsafe;
  }
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Owner Logic
  function isOwner(address _owner)
  public
  view
  returns (bool){
    return (owner == _owner);
  }

  function setOwner(address _owner)
  public
  onlyAdmin{
    owner = _owner;
  }
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Vault Logic
  function isVault(address vault)
  public
  view
  returns (bool) {
    return vaults[vault];
  }

  function addVault(address vault)
  public
  onlyAdmin
  notPaused
  returns (bool) {
    vaults[vault] = true;
    return true;
  }

  function removeVault(address vault)
  public
  onlyAdmin
  returns (bool) {
    vaults[vault] = false;
    return true;
  }
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Authority Logic
  function isAuthority(address authority)
  public
  view
  returns (bool) {
    return authorities[authority];
  }

  function addAuthority(address authority)
  public
  onlyAdmin
  notPaused
  returns (bool) {
    authorities[authority] = true;
    return true;
  }

  function removeAuthority(address authority)
  public
  onlyAdmin
  returns (bool) {
    authorities[authority] = false;
    return true;
  }
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Pause Logic

  /**
  * @dev Administrative lockdown check.
  **/
  function isPaused()
  public
  view
  returns (bool) {
    return paused;
  }

  /**
  * @dev Locks down all actions except administrative actions. Should be used
  * to address security flaws. If this contract has a critical bug, This method
  * should be called to allow for a hault of operations and a migration to occur
  * If this method is called due to a loss of server keys, it will hault
  * operation until root cause may be found.
  **/
  function pause()
  public
  onlyAdmin
  notPaused
  returns (bool) {
    paused = true;
    return true;
  }

  /**
  * @dev Releases system from administrative lockdown. Requires retrieval of
  * failsafe coldwallet.
  **/
  function unpause()
  public
  onlyFailsafe
  returns (bool) {
    paused = false;
    return true;
  }

  /**
  * @dev Locks down all actions FOREVER! This should only be used in
  * manual contract migration due to critical bug. This will halt all
  *operations and allow a new contract to be built by transfering all balances.
  **/
  function lockForever()
  public
  onlyFailsafe
  returns (bool) {
    pause();
    setOwner(address(this));
    setFailsafe(address(this));
    return true;
  }
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Panic Logic

  /**
  * @dev Lets everyone know if something catastrophic has occured. The owner,
  * and failsafe should not ever be the same entity. This combined with a paused
  * state indicates that panic has most likely been called or this contract has
  * been permanently locked for migration.
  */
  function isBadDay()
  public
  view
  returns (bool) {
    return (isPaused() && (owner == failsafe));
  }
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //ERC20Lib Wrappers

  /**
  * @dev These methods act as transparent wrappers around the ERC20Lib. The
  * only changes in logic are as follows:
  *  - The msg.sender must be explicitly set by the wrapper
  *  - The totalSupply has been broken up into 3 functions as totalSupply
  *    pendingSupply, and activeSupply.
  * Pending supply is the supply that has been deposited but not released
  * Active supply is the released deposited supply
  * Total supply is the sum of active and pending.
  */
  function totalSupply()
  public
  view
  returns (uint256) {
    uint256 supply = 0;
    supply = supply.add(pending.totalSupply());
    supply = supply.add(token.totalSupply());
    return supply;
  }

  function pendingSupply()
  public
  view
  returns (uint256) {
    return pending.totalSupply();
  }

  function availableSupply()
  public
  view
  returns (uint256) {
    return token.totalSupply();
  }

  function balanceOf(address account)
  public
  view
  returns (uint256) {
    return token.balances(account);
  }

  function allowance(address account, address spender)
  public
  view
  returns (uint256) {
    return token.allowance(account,spender);
  }

  function transfer(address to, uint256 value)
  public
  notPaused
  returns (bool) {
    token.transfer(msg.sender, to, value);
    return true;
  }

  function approve(address spender, uint256 value)
  public
  notPaused
  returns (bool) {
    token.approve(msg.sender,spender,value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value)
  public
  notPaused
  returns (bool) {
    token.transferFrom(msg.sender,from,to,value);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue)
  public
  notPaused
  returns (bool) {
    token.increaseAllowance(msg.sender,spender,addedValue);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue)
  public
  notPaused
  returns (bool) {
    token.decreaseAllowance(msg.sender,spender,subtractedValue);
    return true;
  }
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Deposit Logic

  /**
  * @dev This logic allows for a delay between a deposit
  * and the release of funds. This is accomplished by maintaining
  * two independant ERC20 contracts in this one contract by using
  * the ERC20Lib library.
  * The first is the token contract that is used to transfer value
  * as is normally expected of an ERC20. The second is the system
  * that allows Ven to be dposited and withdrawn from the
  * blockchain such that no extra priveledge is given to HubCulture
  * for on blockchain actions. This system also allows for the time
  * delay based approval of deposits. Further, the entity that
  * creates a deposit request is an authority, but only a vault
  * may release the deposit into the active balances of the ERC20
  * token.
  */


  /**
  * @dev Deposit value from HubCulture into ERC20
  * This is a pending deposit that must be released.
  * Only an authority may request a deposit.
  */
  function deposit(address account, uint256 value)
  public
  notPaused
  onlyAuthority
  returns (bool) {
    pending.mint(account,value);
    eventNonce+=1;
    emit Pending(account,value,eventNonce);
    return true;
  }

  /**
  * @dev Release a deposit from pending state and credit
  * account with the balance due.
  */
  function releaseDeposit(address account, uint256 value)
  public
  notPaused
  onlyVault
  returns (bool) {
    pending.burn(account,value);
    token.mint(account,value);
    eventNonce+=1;
    emit Deposit(account,value,eventNonce);
    return true;
  }

  /**
  * @dev Cancel a deposit. This prevents the deposit from
  * being released.
  */
  function revokeDeposit(address account, uint256 value)
  public
  notPaused
  onlyVault
  returns (bool) {
    pending.burn(account,value);
    eventNonce+=1;
    emit Decline(account,value,eventNonce);
    return true;
  }
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Withdraw Logic

  /**
  * @dev Withdraw tokens by burning the balance and emitting the event.
  * In order to withdraw the account must be a registered wallet. This is
  * to prevent loss of funds.
  */
  function withdraw(uint256 value)
  public
  notPaused
  returns (bool) {
    require(registered[msg.sender]);
    token.burn(msg.sender,value);
    eventNonce+=1;
    emit Withdraw(msg.sender,value,eventNonce);
    return true;
  }
  ////////////////////////////////////////////////////////////////////////////

  ////////////////////////////////////////////////////////////////////////////
  //Wallet Registration Logic

  /**
  * @dev Allows the registration state of a wallet to be queried.
  */
  function isRegistered(address wallet)
  public
  view
  returns (bool) {
    return registered[wallet];
  }

  /**
  * @dev Allows a HubCulture user to claim thier wallet. This system works
  * as follows:
  *  - User must enter the address they wish to claim on HubCulture
  *  - The user will be provided with a UUID that will be a randomly
  *      generated value (salt) hashed with the user ID for this user.
  *  -  The keccak256 of the uuid and account address will then be
  *      signed by an authority to ensure authenticity.
  *  -  The user must submit a transaction, from the claimed account, with
  *      the uuid, proof, and signature from the authority as arguments to
  *      this method.
  * If all checks pass, the account registration event should be emitted,
  * and this account may now withdraw Ven to HubCulture.
  */
  function register(bytes32 uuid, uint8 v, bytes32 r, bytes32 s)
  public
  notPaused
  returns (bool) {
    require(authorities[ecrecover(keccak256(abi.encodePacked(msg.sender,uuid)),v,r,s)]);
    registered[msg.sender]=true;
    eventNonce+=1;
    emit Registration(msg.sender, uuid, eventNonce);
    return true;
  }

  /**
  * @dev Allows an authority to unregister an account. This will prevent
  * a withdraw comand from being issued by this account unless it is
  * re-registered. This is not a security feature. This is a cleanup
  * function to ensure that closed accounts become zeroed out to minimize
  * chain bloat.
  */
  function unregister(address wallet)
  public
  notPaused
  onlyAuthority
  returns (bool) {
    registered[wallet] = false;
    eventNonce+=1;
    emit Unregistered(wallet, eventNonce);
    return true;
  }
  ////////////////////////////////////////////////////////////////////////////

}