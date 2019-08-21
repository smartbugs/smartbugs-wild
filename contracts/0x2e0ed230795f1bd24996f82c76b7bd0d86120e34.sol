pragma solidity ^0.4.24;

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

// File: contracts/TimestampNotary.sol

contract TimestampNotary is Operable {
  struct Time {
    uint32 declared;
    uint32 recorded;
  }
  mapping (bytes32 => Time) _hashTime;

  event Timestamp(
    bytes32 indexed hash,
    uint32 declaredTime,
    uint32 recordedTime
  );

  /**
   * @dev Allows an operator to timestamp a new hash value.
   * @param hash bytes32 The hash value to be stamped in the contract storage
   * @param declaredTime uint The timestamp associated with the given hash value
   */
  function addTimestamp(bytes32 hash, uint32 declaredTime)
    public
    onlyOperator
    whenNotPaused
    returns (bool)
  {
    _addTimestamp(hash, declaredTime);
    return true;
  }

  /**
   * @dev Registers the timestamp hash value in the contract storage, along with
   * the current and declared timestamps.
   * @param hash bytes32 The hash value to be registered
   * @param declaredTime uint32 The declared timestamp of the hash value
   */
  function _addTimestamp(bytes32 hash, uint32 declaredTime) internal {
    uint32 recordedTime = uint32(block.timestamp);
    _hashTime[hash] = Time(declaredTime, recordedTime);
    emit Timestamp(hash, declaredTime, recordedTime);
  }

  /**
   * @dev Allows anyone to verify the declared timestamp for any given hash.
   */
  function verifyDeclaredTime(bytes32 hash)
    public
    view
    returns (uint32)
  {
    return _hashTime[hash].declared;
  }

  /**
   * @dev Allows anyone to verify the recorded timestamp for any given hash.
   */
  function verifyRecordedTime(bytes32 hash)
    public
    view
    returns (uint32)
  {
    return _hashTime[hash].recorded;
  }
}

// File: contracts/LinkedToken.sol

contract LinkedTokenAbstract {
  function totalSupply() public view returns (uint256);
  function balanceOf(address account) public view returns (uint256);
}


contract LinkedToken is Pausable {
  address internal _token;
  event TokenChanged(address indexed token);
  
  /**
   * @dev Returns the address of the associated token contract.
   */
  function tokenAddress() public view returns (address) {
    return _token;
  }

  /**
   * @dev Allows the current owner to change the address of the associated token contract.
   * @param token address The address of the new token contract
   */
  function setToken(address token) 
    public
    onlyOwner
    whenPaused
    returns (bool)
  {
    _setToken(token);
    emit TokenChanged(token);
    return true;
  }

  /**
   * @dev Changes the address of the associated token contract
   * @param token address The address of the new token contract
   */
  function _setToken(address token) internal {
    require(token != address(0));
    _token = token;
  }
}

// File: contracts/AssetNotary.sol

contract AssetNotary is TimestampNotary, LinkedToken {
  using SafeMath for uint256;

  bytes8[] private _assetList;
  mapping (bytes8 => uint8) private _assetDecimals;
  mapping (bytes8 => uint256) private _assetBalances;

  event AssetBalanceUpdate(
    bytes8 indexed assetId,
    uint256 balance
  );

  function registerAsset(bytes8 assetId, uint8 decimals)
    public
    onlyOperator
    returns (bool)
  {
    require(decimals > 0);
    require(decimals <= 32);
    _assetDecimals[assetId] = decimals;
    _assetList.push(assetId);
    return true;
  }

  function assetList()
    public
    view
    returns (bytes8[])
  {
    return _assetList;
  }

  function getAssetId(string name)
    public
    pure
    returns (bytes8)
  {
    return bytes8(keccak256(abi.encodePacked(name)));
  }

  function assetDecimals(bytes8 assetId)
    public
    view
    returns (uint8)
  {
    return _assetDecimals[assetId];
  }

  function assetBalance(bytes8 assetId)
    public
    view
    returns (uint256)
  {
    return _assetBalances[assetId];
  }

  function updateAssetBalances(bytes8[] assets, uint256[] balances)
    public
    onlyOperator
    whenNotPaused
    returns (bool)
  {
    uint assetsLength = assets.length;
    require(assetsLength > 0);
    require(assetsLength == balances.length);
    
    for (uint i=0; i<assetsLength; i++) {
      require(_assetDecimals[assets[i]] > 0);
      _assetBalances[assets[i]] = balances[i];
      emit AssetBalanceUpdate(assets[i], balances[i]);
    }
    return true;
  }

  function verifyUserBalance(address user, string assetName)
    public
    view
    returns (uint256)
  {
    LinkedTokenAbstract token = LinkedTokenAbstract(_token);
    uint256 totalShares = token.totalSupply();
    require(totalShares > 0);
    uint256 userShares = token.balanceOf(user);
    bytes8 assetId = getAssetId(assetName);
    return _assetBalances[assetId].mul(userShares) / totalShares;
  }
}

// File: contracts/XFTNotary.sol

contract XFTNotary is AssetNotary {
  string public constant name = 'XFT Asset Notary';
  string public constant version = '0.1';
  
  /*
   * @dev Links the Notary contract with the Token contract.
   */
  constructor(address token) public {
    _setToken(token);
  }
}