pragma solidity 0.4.25;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: contracts/MultiOwnable.sol

/**
 * @title MultiOwnable.sol
 * @dev Provide multi-ownable functionality to a smart contract.
 * @dev Note this contract preserves the idea of a master owner where this owner
 * cannot be removed or deleted. Master owner's are the only owner's who can add
 * and remove other owner's. Transfer of master ownership is supported and can 
 * also only be transferred by the current master owner
 * @dev When master ownership is transferred the original master owner is not
 * removed from the additional owners list
 */
pragma solidity 0.4.25;

/**
 * @dev OpenZeppelin Solidity v2.0.0 imports (Using: npm openzeppelin-solidity@2.0.0)
 */


contract MultiOwnable is Ownable {
	/**
	 * @dev Mapping of additional addresses that are considered owners
	 */
	mapping (address => bool) additionalOwners;

	/**
	 * @dev Modifier that overrides 'Ownable' to support multiple owners
	 */
	modifier onlyOwner() {
		// Ensure that msg.sender is an owner or revert
		require(isOwner(msg.sender), "Permission denied [owner].");
		_;
	}

	/**
	 * @dev Modifier that provides additional testing to ensure msg.sender
	 * is master owner, or first address to deploy contract
	 */
	modifier onlyMaster() {
		// Ensure that msg.sender is the master user
		require(super.isOwner(), "Permission denied [master].");
		_;
	}

	/**
	 * @dev Ownership added event for Dapps interested in this event
	 */
	event OwnershipAdded (
		address indexed addedOwner
	);
	
	/**
	 * @dev Ownership removed event for Dapps interested in this event
	 */
	event OwnershipRemoved (
		address indexed removedOwner
	);

  	/**
	 * @dev MultiOwnable .cTor responsible for initialising the masterOwner
	 * or contract super-user
	 * @dev The super user cannot be deleted from the ownership mapping and
	 * can only be transferred
	 */
	constructor() 
	Ownable()
	public
	{
		// Obtain owner of the contract (msg.sender)
		address masterOwner = owner();
		// Add the master owner to the additional owners list
		additionalOwners[masterOwner] = true;
	}

	/**
	 * @dev Returns the owner status of the specified address
	 */
	function isOwner(address _ownerAddressToLookup)
	public
	view
	returns (bool)
	{
		// Return the ownership state of the specified owner address
		return additionalOwners[_ownerAddressToLookup];
	}

	/**
	 * @dev Returns the master status of the specfied address
	 */
	function isMaster(address _masterAddressToLookup)
	public
	view
	returns (bool)
	{
		return (super.owner() == _masterAddressToLookup);
	}

	/**
	 * @dev Add a new owner address to additional owners mapping
	 * @dev Only the master owner can add additional owner addresses
	 */
	function addOwner(address _ownerToAdd)
	onlyMaster
	public
	returns (bool)
	{
		// Ensure the new owner address is not address(0)
		require(_ownerToAdd != address(0), "Invalid address specified (0x0)");
		// Ensure that new owner address is not already in the owners list
		require(!isOwner(_ownerToAdd), "Address specified already in owners list.");
		// Add new owner to additional owners mapping
		additionalOwners[_ownerToAdd] = true;
		emit OwnershipAdded(_ownerToAdd);
		return true;
	}

	/**
	 * @dev Add a new owner address to additional owners mapping
	 * @dev Only the master owner can add additional owner addresses
	 */
	function removeOwner(address _ownerToRemove)
	onlyMaster
	public
	returns (bool)
	{
		// Ensure that the address to remove is not the master owner
		require(_ownerToRemove != super.owner(), "Permission denied [master].");
		// Ensure that owner address to remove is actually an owner
		require(isOwner(_ownerToRemove), "Address specified not found in owners list.");
		// Add remove ownership from address in the additional owners mapping
		additionalOwners[_ownerToRemove] = false;
		emit OwnershipRemoved(_ownerToRemove);
		return true;
	}

	/**
	 * @dev Transfer ownership of this contract to another address
	 * @dev Only the master owner can transfer ownership to another address
	 * @dev Only existing owners can have ownership transferred to them
	 */
	function transferOwnership(address _newOwnership) 
	onlyMaster 
	public 
	{
		// Ensure the new ownership is not address(0)
		require(_newOwnership != address(0), "Invalid address specified (0x0)");
		// Ensure the new ownership address is not the current ownership addressess
		require(_newOwnership != owner(), "Address specified must not match current owner address.");		
		// Ensure that the new ownership is promoted from existing owners
		require(isOwner(_newOwnership), "Master ownership can only be transferred to an existing owner address.");
		// Call into the parent class and transfer ownership
		super.transferOwnership(_newOwnership);
		// If we get here, then add the new ownership address to the additional owners mapping
		// Note that the original master owner address was not removed and is still an owner until removed
		additionalOwners[_newOwnership] = true;
	}

}

// File: openzeppelin-solidity/contracts/access/Roles.sol

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

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

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

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
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
    require(!_paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused);
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
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
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

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    // safeApprove should only be called when setting an initial allowance, 
    // or when resetting it to zero. To increase and decrease it, use 
    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
    require((value == 0) || (token.allowance(msg.sender, spender) == 0));
    require(token.approve(spender, value));
  }

  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).add(value);
    require(token.approve(spender, newAllowance));
  }

  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  )
    internal
  {
    uint256 newAllowance = token.allowance(address(this), spender).sub(value);
    require(token.approve(spender, newAllowance));
  }
}

// File: openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol

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
    require(localCounter == _guardCounter);
  }

}

// File: openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol

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
contract Crowdsale is ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  // The token being sold
  IERC20 private _token;

  // Address where funds are collected
  address private _wallet;

  // How many token units a buyer gets per wei.
  // The rate is the conversion between wei and the smallest and indivisible token unit.
  // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
  // 1 wei will give you 1 unit, or 0.001 TOK.
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

    _updatePurchasingState(beneficiary, weiAmount);

    _forwardFunds();
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

// File: openzeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 private _openingTime;
  uint256 private _closingTime;

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    require(isOpen());
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param openingTime Crowdsale opening time
   * @param closingTime Crowdsale closing time
   */
  constructor(uint256 openingTime, uint256 closingTime) internal {
    // solium-disable-next-line security/no-block-members
    require(openingTime >= block.timestamp);
    require(closingTime > openingTime);

    _openingTime = openingTime;
    _closingTime = closingTime;
  }

  /**
   * @return the crowdsale opening time.
   */
  function openingTime() public view returns(uint256) {
    return _openingTime;
  }

  /**
   * @return the crowdsale closing time.
   */
  function closingTime() public view returns(uint256) {
    return _closingTime;
  }

  /**
   * @return true if the crowdsale is open, false otherwise.
   */
  function isOpen() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > _closingTime;
  }

  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param beneficiary Token purchaser
   * @param weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal
    onlyWhileOpen
    view
  {
    super._preValidatePurchase(beneficiary, weiAmount);
  }

}

// File: contracts/SparkleBaseCrowdsale.sol

/**
 * @dev SparkelBaseCrowdsale: Core crowdsale functionality
 */
contract SparkleBaseCrowdsale is MultiOwnable, Pausable, TimedCrowdsale {
	using SafeMath for uint256;

	/**
	 * @dev CrowdsaleStage enumeration indicating which operational stage this contract is running
	 */
	enum CrowdsaleStage { 
		preICO, 
		bonusICO, 
		mainICO
	}

 	/**
 	 * @dev Internal contract variable stored
 	 */
	ERC20   public tokenAddress;
	uint256 public tokenRate;
	uint256 public tokenCap;
	uint256 public startTime;
	uint256 public endTime;
	address public depositWallet;
	bool    public kycRequired;	
	bool	public refundRemainingOk;

	uint256 public tokensSold;

	/**
	 * @dev Contribution structure representing a token purchase 
	 */
	struct OrderBook {
		uint256 weiAmount;   // Amount of Wei that has been contributed towards tokens by this address
		uint256 pendingTokens; // Total pending tokens held by this address waiting for KYC verification, and user to claim their tokens(pending restrictions)
		bool    kycVerified;   // Has this address been kyc validated
	}

	// Contributions mapping to user addresses
	mapping(address => OrderBook) private orders;

	// Initialize the crowdsale stage to preICO (this stage will change)
	CrowdsaleStage public crowdsaleStage = CrowdsaleStage.preICO;

	/**
	 * @dev Event signaling that a number of addresses have been approved for KYC
	 */
	event ApprovedKYCAddresses (address indexed _appovedByAddress, uint256 _numberOfApprovals);

	/**
	 * @dev Event signaling that a number of addresses have been revoked from KYC
	 */
	event RevokedKYCAddresses (address indexed _revokedByAddress, uint256 _numberOfRevokals);

	/**
	 * @dev Event signalling that tokens have been claimed from the crowdsale
	 */
	event TokensClaimed (address indexed _claimingAddress, uint256 _tokensClaimed);

	/**
	 * @dev Event signaling that tokens were sold and how many were sold
	 */
	event TokensSold(address indexed _beneficiary, uint256 _tokensSold);

	/**
	 * @dev Event signaling that toke burn approval has been changed
	 */
	event TokenRefundApprovalChanged(address indexed _approvingAddress, bool tokenBurnApproved);

	/**
	 * @dev Event signaling that token burn approval has been changed
	 */
	event CrowdsaleStageChanged(address indexed _changingAddress, uint _newStageValue);

	/**
	 * @dev Event signaling that crowdsale tokens have been burned
	 */
	event CrowdsaleTokensRefunded(address indexed _refundingToAddress, uint256 _numberOfTokensBurned);

	/**
	 * @dev SparkleTokenCrowdsale Contract contructor
	 */
	constructor(ERC20 _tokenAddress, uint256 _tokenRate, uint256 _tokenCap, uint256 _startTime, uint256 _endTime, address _depositWallet, bool _kycRequired)
	public
	Crowdsale(_tokenRate, _depositWallet, _tokenAddress)
	TimedCrowdsale(_startTime, _endTime)
	MultiOwnable()
	Pausable()
	{ 
		tokenAddress      = _tokenAddress;
		tokenRate         = _tokenRate;
		tokenCap          = _tokenCap;
		startTime         = _startTime;
		endTime           = _endTime;
		depositWallet     = _depositWallet;
		kycRequired       = _kycRequired;
		refundRemainingOk = false;
	}

	/**
	 * @dev claimPendingTokens() provides users with a function to receive their purchase tokens
	 * after their KYC Verification
	 */
	function claimTokens()
	whenNotPaused
	onlyWhileOpen
	public
	{
		// Ensure calling address is not address(0)
		require(msg.sender != address(0), "Invalid address specified: address(0)");
		// Obtain a copy of the caller's order record
		OrderBook storage order = orders[msg.sender];
		// Ensure caller has been KYC Verified
		require(order.kycVerified, "Address attempting to claim tokens is not KYC Verified.");
		// Ensure caller has pending tokens to claim
		require(order.pendingTokens > 0, "Address does not have any pending tokens to claim.");
		// For security sake grab the pending token value
		uint256 localPendingTokens = order.pendingTokens;
		// zero out pendingTokens to prevent potential re-entrancy vulnverability
		order.pendingTokens = 0;
		// Deliver the callers tokens
		_deliverTokens(msg.sender, localPendingTokens);
		// Emit event
		emit TokensClaimed(msg.sender, localPendingTokens);
	}

	/**
	 * @dev getExchangeRate() provides a public facing manner in which to 
	 * determine the current rate of exchange in the crowdsale
	 * @param _weiAmount is the amount of wei to purchase tokens with
	 * @return number of tokens the specified wei amount would purchase
	 */
	function getExchangeRate(uint256 _weiAmount)
	whenNotPaused
	onlyWhileOpen
	public
	view
	returns (uint256)
	{
		if (crowdsaleStage == CrowdsaleStage.preICO) {
			// Ensure _weiAmount is > than current stage minimum
			require(_weiAmount >= 1 ether, "PreICO minimum ether required: 1 ETH.");
		}
		else if (crowdsaleStage == CrowdsaleStage.bonusICO || crowdsaleStage == CrowdsaleStage.mainICO) {
			// Ensure _weiAmount is > than current stage minimum
			require(_weiAmount >= 500 finney, "bonusICO/mainICO minimum ether required: 0.5 ETH.");
		}

		// Calculate the number of tokens this amount of wei is worth
		uint256 tokenAmount = _getTokenAmount(_weiAmount);
		// Ensure the number of tokens requests will not exceed available tokens
		require(getRemainingTokens() >= tokenAmount, "Specified wei value woudld exceed amount of tokens remaining.");
		// Calculate and return the token amount this amount of wei is worth (includes bonus factor)
		return tokenAmount;
	}

	/**
	 * @dev getRemainingTokens() provides function to return the current remaining token count
	 * @return number of tokens remaining in the crowdsale to be sold
	 */
	function getRemainingTokens()
	whenNotPaused
	public
	view
	returns (uint256)
	{
		// Return the balance of the contract (IE: tokenCap - tokensSold)
		return tokenCap.sub(tokensSold);
	}

	/**
	 * @dev refundRemainingTokens provides functionn to refund remaining tokens to the specified address
	 * @param _addressToRefund is the address in which the remaining tokens will be refunded to
	 */
	function refundRemainingTokens(address _addressToRefund)
	onlyOwner
	whenNotPaused
	public
	{
		// Ensure the specified address is not address(0)
		require(_addressToRefund != address(0), "Specified address is invalid [0x0]");
		// Ensure the crowdsale has closed before burning tokens
		require(hasClosed(), "Crowdsale must be finished to burn tokens.");
		// Ensure that step-1 of the burning process is satisfied (owner set to true)
		require(refundRemainingOk, "Crowdsale remaining token refund is disabled.");
		uint256 tempBalance = token().balanceOf(this);
		// Transfer the remaining tokens to specified address
		_deliverTokens(_addressToRefund, tempBalance);
		// Emit event
		emit CrowdsaleTokensRefunded(_addressToRefund, tempBalance);
	}

	/**
	 * @dev approveRemainingTokenRefund approves the function to withdraw any remaining tokens
	 * after the crowdsale ends
	 * @dev This was put in place as a two-step process to burn tokens so burning was secure
	 */
	function approveRemainingTokenRefund()
	onlyOwner
	whenNotPaused
	public
	{
		// Ensure calling address is not address(0)
		require(msg.sender != address(0), "Calling address invalid [0x0]");
		// Ensure the crowdsale has closed before approving token burning
		require(hasClosed(), "Token burn approval can only be set after crowdsale closes");
		refundRemainingOk = true;
		emit TokenRefundApprovalChanged(msg.sender, refundRemainingOk);
	}

	/**
	 * @dev setStage() sets the current crowdsale stage to the specified value
	 * @param _newStageValue is the new stage to be changed to
	 */
	function changeCrowdsaleStage(uint _newStageValue)
	onlyOwner
	whenNotPaused
	onlyWhileOpen
	public
	{
		// Create temporary stage variable
		CrowdsaleStage _stage;
		// Determine if caller is trying to set: preICO
		if (uint(CrowdsaleStage.preICO) == _newStageValue) {
			// Set the internal stage to the new value
			_stage = CrowdsaleStage.preICO;
		}
		// Determine if caller is trying to set: bonusICO
		else if (uint(CrowdsaleStage.bonusICO) == _newStageValue) {
			// Set the internal stage to the new value
			_stage = CrowdsaleStage.bonusICO;
		}
		// Determine if caller is trying to set: mainICO
		else if (uint(CrowdsaleStage.mainICO) == _newStageValue) {
			// Set the internal stage to the new value
			_stage = CrowdsaleStage.mainICO;
		}
		else {
			revert("Invalid stage selected");
		}

		// Update the internal crowdsale stage to the new stage
		crowdsaleStage = _stage;
		// Emit event
		emit CrowdsaleStageChanged(msg.sender, uint(_stage));
	}

	/**
	 * @dev isAddressKYCVerified() checks the KYV Verification status of the specified address
	 * @param _addressToLookuo address to check status of KYC Verification
	 * @return kyc status of the specified address 
	 */
	function isKYCVerified(address _addressToLookuo) 
	whenNotPaused
	onlyWhileOpen
	public
	view
	returns (bool)
	{
		// Ensure _addressToLookuo is not address(0)
		require(_addressToLookuo != address(0), "Invalid address specified: address(0)");
		// Obtain the addresses order record
		OrderBook storage order = orders[_addressToLookuo];
		// Return the JYC Verification status for the specified address
		return order.kycVerified;
	}

	/**
	 * @dev Approve in bulk the specified addfresses indicating they were KYC Verified
	 * @param _addressesForApproval is a list of addresses that are to be KYC Verified
	 */
	function bulkApproveKYCAddresses(address[] _addressesForApproval) 
	onlyOwner
	whenNotPaused
	onlyWhileOpen
	public
	{

		// Ensure that there are any address(es) in the provided array
		require(_addressesForApproval.length > 0, "Specified address array is empty");
		// Interate through all addresses provided
		for (uint i = 0; i <_addressesForApproval.length; i++) {
			// Approve this address using the internal function
			_approveKYCAddress(_addressesForApproval[i]);
		}

		// Emit event indicating address(es) have been approved for KYC Verification
		emit ApprovedKYCAddresses(msg.sender, _addressesForApproval.length);
	}

	/**
	 * @dev Revoke in bulk the specified addfresses indicating they were denied KYC Verified
	 * @param _addressesToRevoke is a list of addresses that are to be KYC Verified
	 */
	function bulkRevokeKYCAddresses(address[] _addressesToRevoke) 
	onlyOwner
	whenNotPaused
	onlyWhileOpen
	public
	{
		// Ensure that there are any address(es) in the provided array
		require(_addressesToRevoke.length > 0, "Specified address array is empty");
		// Interate through all addresses provided
		for (uint i = 0; i <_addressesToRevoke.length; i++) {
			// Approve this address using the internal function
			_revokeKYCAddress(_addressesToRevoke[i]);
		}

		// Emit event indicating address(es) have been revoked for KYC Verification
		emit RevokedKYCAddresses(msg.sender, _addressesToRevoke.length);
	}

	/**
	 * @dev tokensPending() provides owners the function to retrieve an addresses pending
	 * token amount
	 * @param _addressToLookup is the address to return the pending token value for
	 * @return the number of pending tokens waiting to be claimed from specified address
	 */
	function tokensPending(address _addressToLookup)
	onlyOwner
	whenNotPaused
	onlyWhileOpen
	public
	view
	returns (uint256)
	{
		// Ensure specified address is not address(0)
		require(_addressToLookup != address(0), "Specified address is invalid [0x0]");
		// Obtain the order for specified address
		OrderBook storage order = orders[_addressToLookup];
		// Return the pendingTokens amount
		return order.pendingTokens;
	}

	/**
	 * @dev contributionAmount() provides owners the function to retrieve an addresses total
	 * contribution amount in eth
	 * @param _addressToLookup is the address to return the contribution amount value for
	 * @return the number of ether contribured to the crowdsale by specified address
	 */
	function contributionAmount(address _addressToLookup)
	onlyOwner
	whenNotPaused
	onlyWhileOpen
	public
	view
	returns (uint256)
	{
		// Ensure specified address is not address(0)
		require(_addressToLookup != address(0), "Specified address is Invalid [0x0]");
		// Obtain the order for specified address
		OrderBook storage order = orders[_addressToLookup];
		// Return the contribution amount in wei
		return order.weiAmount;
	}

	/**
	 * @dev _approveKYCAddress provides the function to approve the specified address 
	 * indicating KYC Verified
	 * @param _addressToApprove of the user that is being verified
	 */
	function _approveKYCAddress(address _addressToApprove) 
	onlyOwner
	internal
	{
		// Ensure that _addressToApprove is not address(0)
		require(_addressToApprove != address(0), "Invalid address specified: address(0)");
		// Get this addesses contribution record
		OrderBook storage order = orders[_addressToApprove];
		// Set the contribution record to indicate address has been kyc verified
		order.kycVerified = true;
	}

	/**
	 * @dev _revokeKYCAddress() provides the function to revoke previously
	 * granted KYC verification in cases of fraud or false/invalid KYC data
	 * @param _addressToRevoke is the address to remove KYC verification from
	 */
	function _revokeKYCAddress(address _addressToRevoke)
	onlyOwner
	internal
	{
		// Ensure address is not address(0)
		require(_addressToRevoke != address(0), "Invalid address specified: address(0)");
		// Obtain a copy of this addresses contribution record
		OrderBook storage order = orders[_addressToRevoke];
		// Revoke this addresses KYC verification
		order.kycVerified = false;
	}

	/**
	 * @dev _rate() provides the function of calcualting the rate based on crowdsale stage
	 * @param _weiAmount indicated the amount of ether intended to use for purchase
	 * @return number of tokens worth based on specified Wei value
	 */
	function _rate(uint _weiAmount)
	internal
	view
	returns (uint256)
	{
		require(_weiAmount > 0, "Specified wei amoount must be > 0");

		// Determine if the current operation stage of the crowdsale is preICO
		if (crowdsaleStage == CrowdsaleStage.preICO)
		{
			// Determine if the purchase is >= 21 ether
			if (_weiAmount >= 21 ether) { // 20% bonus
				return 480e8;
			}
			
			// Determine if the purchase is >= 11 ether
			if (_weiAmount >= 11 ether) { // 15% bonus
				return 460e8;
			}
			
			// Determine if the purchase is >= 5 ether
			if (_weiAmount >= 5 ether) { // 10% bonus
				return 440e8;
			}

		}
		else
		// Determine if the current operation stage of the crowdsale is bonusICO
		if (crowdsaleStage == CrowdsaleStage.bonusICO)
		{
			// Determine if the purchase is >= 21 ether
			if (_weiAmount >= 21 ether) { // 10% bonus
				return 440e8;
			}
			else if (_weiAmount >= 11 ether) { // 7% bonus
				return 428e8;
			}
			else
			if (_weiAmount >= 5 ether) { // 5% bonus
				return 420e8;
			}

		}

		// Rate is either < bounus or is main sale so return base rate only
		return rate();
	}

	/**
	 * @dev Performs token to wei converstion calculations based on crowdsale specification
	 * @param _weiAmount to spend
	 * @return number of tokens purchasable for the specified _weiAmount at crowdsale stage rates
	 */
	function _getTokenAmount(uint256 _weiAmount)
	whenNotPaused
	internal
	view
	returns (uint256)
	{
		// Get the current rate set in the constructor and calculate token units per wei
		uint256 currentRate = _rate(_weiAmount);
		// Calculate the total number of tokens buyable at based rate (before adding bonus)
		uint256 sparkleToBuy = currentRate.mul(_weiAmount).div(10e17);
		// Return proposed token amount
		return sparkleToBuy;
	}

	/**
	 * @dev _preValidatePurchase provides the functionality of pre validating a potential purchase
	 * @param _beneficiary is the address that is currently purchasing tokens
	 * @param _weiAmount is the number of tokens this address is attempting to purchase
	 */
	function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) 
	whenNotPaused
	internal
	view
	{
		// Call into the parent validation to ensure _beneficiary and _weiAmount are valid
		super._preValidatePurchase(_beneficiary, _weiAmount);
		// Calculate amount of tokens for the specified _weiAmount
		uint256 requestedTokens = getExchangeRate(_weiAmount);
		// Calculate the currently sold tokens
		uint256 tempTotalTokensSold = tokensSold;
		// Incrememt total tokens		
		tempTotalTokensSold.add(requestedTokens);
		// Ensure total max token cap is > tempTotalTokensSold
		require(tempTotalTokensSold <= tokenCap, "Requested wei amount will exceed the max token cap and was not accepted.");
		// Ensure that requested tokens will not go over the remaining token balance
		require(requestedTokens <= getRemainingTokens(), "Requested tokens would exceed tokens available and was not accepted.");
		// Obtain the order record for _beneficiary if one exists
		OrderBook storage order = orders[_beneficiary];
		// Ensure this address has been kyc validated
		require(order.kycVerified, "Address attempting to purchase is not KYC Verified.");
		// Update this addresses order to reflect the purchase and ether spent
		order.weiAmount = order.weiAmount.add(_weiAmount);
		order.pendingTokens = order.pendingTokens.add(requestedTokens);
		// increment totalTokens sold
		tokensSold = tokensSold.add(requestedTokens);
		// Emit event
		emit TokensSold(_beneficiary, requestedTokens);
	}

	/**
	 * @dev _processPurchase() is overridden and will be called by OpenZep v2.0 internally
	 * @param _beneficiary is the address that is currently purchasing tokens
	 * @param _tokenAmount is the number of tokens this address is attempting to purchase
	 */
	function _processPurchase(address _beneficiary, uint256 _tokenAmount)
	whenNotPaused
	internal
	{
		// We do not call the base class _processPurchase() functions. This is needed here or the base
		// classes function will be called.
	}

}


// File: contracts/SparkleCrowdsale.sol

contract SparkleCrowdsale is SparkleBaseCrowdsale {

  // Token contract address 
  address public initTokenAddress = 0x4b7aD3a56810032782Afce12d7d27122bDb96efF;
  // Crowdsale specification
  uint256 public initTokenRate     = 400e8;
  uint256 public initTokenCap      = 19698000e8;
  uint256 public initStartTime     = now;
  uint256 public initEndTime       = now + 12 weeks; // Set this accordingly as it cannot be changed
  address public initDepositWallet = 0x0926a84C83d7B88338588Dca2729b590D787FA34;
  bool public initKYCRequired      = true;

  constructor() 
	SparkleBaseCrowdsale(ERC20(initTokenAddress), initTokenRate, initTokenCap, initStartTime, initEndTime, initDepositWallet, initKYCRequired)
	public
	{
	}

}