pragma solidity ^0.4.24;

// File: contracts/Ownable.sol

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
  constructor() public {
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
    require(isOwner(msg.sender));
    _;
  }

  /**
   * @return true if the account is the owner of the contract.
   */
  function isOwner(address account) public view returns(bool) {
    return account == _owner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner)
    public
    onlyOwner
  {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner)
    internal
  {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: contracts/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Paused();
  event Unpaused();

  bool private _paused;

  constructor() public {
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
  function pause()
    public
    onlyOwner
    whenNotPaused
  {
    _paused = true;
    emit Paused();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause()
    public
    onlyOwner
    whenPaused
  {
    _paused = false;
    emit Unpaused();
  }
}

// File: contracts/Operable.sol

/**
 * @title Operable
 * @dev Base contract that allows the owner to enforce access control over certain
 * operations by adding or removing operator addresses.
 */
contract Operable is Pausable {
  event OperatorAdded(address indexed account);
  event OperatorRemoved(address indexed account);

  mapping (address => bool) private _operators;

  constructor() public {
    _addOperator(msg.sender);
  }

  modifier onlyOperator() {
    require(isOperator(msg.sender));
    _;
  }

  function isOperator(address account)
    public
    view
    returns (bool) 
  {
    require(account != address(0));
    return _operators[account];
  }

  function addOperator(address account)
    public
    onlyOwner
  {
    _addOperator(account);
  }

  function removeOperator(address account)
    public
    onlyOwner
  {
    _removeOperator(account);
  }

  function _addOperator(address account)
    internal
  {
    require(account != address(0));
    _operators[account] = true;
    emit OperatorAdded(account);
  }

  function _removeOperator(address account)
    internal
  {
    require(account != address(0));
    _operators[account] = false;
    emit OperatorRemoved(account);
  }
}

// File: contracts/SafeMath.sol

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

// File: contracts/ManagedToken.sol

contract ManagedToken is Operable {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  uint256 private _totalSupply;

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param account The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address from, address to, uint256 value)
    public
    onlyOperator
    whenNotPaused
    returns (bool)
  {
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Specifically prohibits token transfers from msg.sender's address
   * @param to address The address receiving the token transfer
   * @param value uint256 the amount of tokens to be transferred
   */
  // function transfer(address to, uint256 value)
  //   public
  //   whenNotPaused
  //   returns (bool)
  // {
  //   revert();
  // }

  /**
   * @dev Mints new tokens to the target address.
   * @param to The address that will receive the minted tokens.
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address to, uint256 value)
    public
    onlyOperator
    whenNotPaused
    returns (bool)
  {
    _mint(to, value);
    return true;
  }

  /**
   * @dev Burns a specific amount of tokens from the target address and decrements allowance
   * @param from address The address which you want to send tokens from
   * @param value uint256 The amount of token to be burned
   */
  function burn(address from, uint256 value)
    public
    onlyOperator
    whenNotPaused
    returns (bool)
  {
    _burn(from, value);
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
}

// File: contracts/XFTToken.sol

contract XFTToken is ManagedToken {
  string public constant name = 'XFT Token';
  string public constant symbol = 'XFT';
  uint8 public constant decimals = 18;
  string public constant version = '1.0';
}