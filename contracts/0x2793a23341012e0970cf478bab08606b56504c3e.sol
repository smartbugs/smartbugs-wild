pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
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


contract Administratable is Ownable {
  using SafeMath for uint256;

  address[] public adminsForIndex;
  address[] public superAdminsForIndex;
  mapping (address => bool) public admins;
  mapping (address => bool) public superAdmins;
  mapping (address => bool) private processedAdmin;
  mapping (address => bool) private processedSuperAdmin;

  event AddAdmin(address indexed admin);
  event RemoveAdmin(address indexed admin);
  event AddSuperAdmin(address indexed admin);
  event RemoveSuperAdmin(address indexed admin);

  modifier onlyAdmins {
    require (msg.sender == owner || superAdmins[msg.sender] || admins[msg.sender]);
    _;
  }

  modifier onlySuperAdmins {
    require (msg.sender == owner || superAdmins[msg.sender]);
    _;
  }

  function totalSuperAdminsMapping() public view returns (uint256) {
    return superAdminsForIndex.length;
  }

  function addSuperAdmin(address admin) public onlySuperAdmins {
    require(admin != address(0));
    superAdmins[admin] = true;
    if (!processedSuperAdmin[admin]) {
      superAdminsForIndex.push(admin);
      processedSuperAdmin[admin] = true;
    }

    emit AddSuperAdmin(admin);
  }

  function removeSuperAdmin(address admin) public onlySuperAdmins {
    require(admin != address(0));
    superAdmins[admin] = false;

    emit RemoveSuperAdmin(admin);
  }

  function totalAdminsMapping() public view returns (uint256) {
    return adminsForIndex.length;
  }

  function addAdmin(address admin) public onlySuperAdmins {
    require(admin != address(0));
    admins[admin] = true;
    if (!processedAdmin[admin]) {
      adminsForIndex.push(admin);
      processedAdmin[admin] = true;
    }

    emit AddAdmin(admin);
  }

  function removeAdmin(address admin) public onlySuperAdmins {
    require(admin != address(0));
    admins[admin] = false;

    emit RemoveAdmin(admin);
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
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}


/**
 * @title EternalStorage
 * @dev An Administratable contract that can be used as a storage where the variables
 * are stored in a set of mappings indexed by hash names.
 */
contract EternalStorage is Administratable {

  struct Storage {
    mapping(bytes32 => bool) _bool;
    mapping(bytes32 => int) _int;
    mapping(bytes32 => uint256) _uint;
    mapping(bytes32 => string) _string;
    mapping(bytes32 => address) _address;
    mapping(bytes32 => bytes) _bytes;
  }

  Storage internal s;

  /**
   * @dev Allows admins to set a value for a boolean variable.
   * @param h The keccak256 hash of the variable name
   * @param v The value to be stored
   */
  function setBoolean(bytes32 h, bool v) public onlyAdmins {
    s._bool[h] = v;
  }

  /**
   * @dev Allows admins to set a value for a int variable.
   * @param h The keccak256 hash of the variable name
   * @param v The value to be stored
   */
  function setInt(bytes32 h, int v) public onlyAdmins {
    s._int[h] = v;
  }

  /**
   * @dev Allows admins to set a value for a boolean variable.
   * @param h The keccak256 hash of the variable name
   * @param v The value to be stored
   */
  function setUint(bytes32 h, uint256 v) public onlyAdmins {
    s._uint[h] = v;
  }

  /**
   * @dev Allows admins to set a value for a address variable.
   * @param h The keccak256 hash of the variable name
   * @param v The value to be stored
   */
  function setAddress(bytes32 h, address v) public onlyAdmins {
    s._address[h] = v;
  }

  /**
   * @dev Allows admins to set a value for a string variable.
   * @param h The keccak256 hash of the variable name
   * @param v The value to be stored
   */
  function setString(bytes32 h, string v) public onlyAdmins {
    s._string[h] = v;
  }

  /**
   * @dev Allows the owner to set a value for a bytes variable.
   * @param h The keccak256 hash of the variable name
   * @param v The value to be stored
   */
  function setBytes(bytes32 h, bytes v) public onlyAdmins {
    s._bytes[h] = v;
  }

  /**
   * @dev Get the value stored of a boolean variable by the hash name
   * @param h The keccak256 hash of the variable name
   */
  function getBoolean(bytes32 h) public view returns (bool){
    return s._bool[h];
  }

  /**
   * @dev Get the value stored of a int variable by the hash name
   * @param h The keccak256 hash of the variable name
   */
  function getInt(bytes32 h) public view returns (int){
    return s._int[h];
  }

  /**
   * @dev Get the value stored of a uint variable by the hash name
   * @param h The keccak256 hash of the variable name
   */
  function getUint(bytes32 h) public view returns (uint256){
    return s._uint[h];
  }

  /**
   * @dev Get the value stored of a address variable by the hash name
   * @param h The keccak256 hash of the variable name
   */
  function getAddress(bytes32 h) public view returns (address){
    return s._address[h];
  }

  /**
   * @dev Get the value stored of a string variable by the hash name
   * @param h The keccak256 hash of the variable name
   */
  function getString(bytes32 h) public view returns (string){
    return s._string[h];
  }

  /**
   * @dev Get the value stored of a bytes variable by the hash name
   * @param h The keccak256 hash of the variable name
   */
  function getBytes(bytes32 h) public view returns (bytes){
    return s._bytes[h];
  }
}


library TokenLib {
  using SafeMath for uint256;

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  /* struct TokenStorage { address storage} */

  function transfer(address _storage, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    uint256 senderBalance = EternalStorage(_storage).getUint(keccak256(abi.encodePacked('balance', msg.sender)));
    require(_value <= senderBalance);

    uint256 receiverBalance = balanceOf(_storage, _to);
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('balance', msg.sender)), senderBalance.sub(_value));
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('balance', _to)), receiverBalance.add(_value));
    emit Transfer(msg.sender, _to, _value);

    return true;
  }

  function mint(address _storage, address _to, uint256 _value) public {
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('balance', _to)), _value);
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('totalSupply')), _value);
  }

  function setTotalSupply(address _storage, uint256 _totalSupply) public {
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('totalSupply')), _totalSupply);
  }

  function totalSupply(address _storage) public view returns (uint256) {
    return EternalStorage(_storage).getUint(keccak256(abi.encodePacked('totalSupply')));
  }


  function balanceOf(address _storage, address _owner) public view returns (uint256 balance) {
    return EternalStorage(_storage).getUint(keccak256(abi.encodePacked('balance', _owner)));
  }

  function getAllowance(address _storage, address _owner, address _spender) public view returns (uint256) {
    return EternalStorage(_storage).getUint(keccak256(abi.encodePacked('allowance', _owner, _spender)));
  }

  function setAllowance(address _storage, address _owner, address _spender, uint256 _allowance) public {
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('allowance', _owner, _spender)), _allowance);
  }

  function allowance(address _storage, address _owner, address _spender) public view  returns (uint256) {
    return getAllowance(_storage, _owner, _spender);
  }

  function transferFrom(address _storage, address _from, address _to, uint256 _value) public  returns (bool) {
    require(_to != address(0));
    require(_from != msg.sender);
    require(_value > 0);
    uint256 senderBalance = balanceOf(_storage, _from);
    require(senderBalance >= _value);

    uint256 allowanceValue = allowance(_storage, _from, msg.sender);
    require(allowanceValue >= _value);

    uint256 receiverBalance = balanceOf(_storage, _to);
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('balance', _from)), senderBalance.sub(_value));
    EternalStorage(_storage).setUint(keccak256(abi.encodePacked('balance', _to)), receiverBalance.add(_value));

    setAllowance(_storage, _from, msg.sender, allowanceValue.sub(_value));
    emit Transfer(_from, _to, _value);

    return true;
  }

  function approve(address _storage, address _spender, uint256 _value) public returns (bool) {
    require(_spender != address(0));
    require(msg.sender != _spender);

    setAllowance(_storage, msg.sender, _spender, _value);

    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function increaseApproval(address _storage, address _spender, uint256 _addedValue) public returns (bool) {
    return approve(_storage, _spender, getAllowance(_storage, msg.sender, _spender).add(_addedValue));
  }

  function decreaseApproval(address _storage, address _spender, uint256 _subtractedValue) public returns (bool) {
    uint256 oldValue = getAllowance(_storage, msg.sender, _spender);

    if (_subtractedValue > oldValue) {
      return approve(_storage, _spender, 0);
    } else {
      return approve(_storage, _spender, oldValue.sub(_subtractedValue));
    }
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
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract UpgradableToken is ERC20, Ownable {
  address public predecessor;
  address public successor;
  string public version;

  event UpgradedTo(address indexed successor);
  event UpgradedFrom(address indexed predecessor);

  modifier unlessUpgraded() {
    require (msg.sender == successor || successor == address(0));
    _;
  }

  modifier isUpgraded() {
    require (successor != address(0));
    _;
  }

  modifier hasPredecessor() {
    require (predecessor != address(0));
    _;
  }

  function isDeprecated() public view returns (bool) {
    return successor != address(0);
  }

  constructor(string _version) public {
      version = _version;
  }

  function upgradeTo(address _successor) public onlyOwner unlessUpgraded returns (bool){
    require(_successor != address(0));

    uint remainingContractBalance = balanceOf(this);

    if (remainingContractBalance > 0) {
      this.transfer(_successor, remainingContractBalance);
    }
    successor = _successor;
    emit UpgradedTo(_successor);
    return true;
  }

  function upgradedFrom(address _predecessor) public onlyOwner returns (bool) {
    require(_predecessor != address(0));

    predecessor = _predecessor;

    emit UpgradedFrom(_predecessor);

    return true;
  }
}



contract Token is Ownable {
  event UpgradedTo(address indexed implementation);

  address internal _implementation;

  function implementation() public view returns (address) {
    return _implementation;
  }

  function upgradeTo(address impl) public onlyOwner {
    require(_implementation != impl);
    _implementation = impl;
    emit UpgradedTo(impl);
  }

  function () payable public {
    address _impl = implementation();
    require(_impl != address(0));
    bytes memory data = msg.data;

    assembly {
      let result := delegatecall(gas, _impl, add(data, 0x20), mload(data), 0, 0)
      let size := returndatasize
      let ptr := mload(0x40)
      returndatacopy(ptr, 0, size)
      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}


/**
 * @title DetailedERC20 token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}



contract TokenDelegate is UpgradableToken, DetailedERC20, Pausable {
    using TokenLib for address;

    address tokenStorage;

    constructor(string _name, string _symbol, uint8 _decimals, address _storage, string _version)
        DetailedERC20(_name, _symbol, _decimals) UpgradableToken(_version) public {
        setStorage(_storage);
    }

    function setTotalSupply(uint256 _totalSupply) public onlyOwner {
        tokenStorage.setTotalSupply(_totalSupply);
    }

    function setStorage(address _storage) public onlyOwner unlessUpgraded whenNotPaused {
        tokenStorage = _storage;
    }

    function totalSupply() public view returns (uint){
        return tokenStorage.totalSupply();
    }

    function mint(address _to, uint _value) public onlyOwner unlessUpgraded whenNotPaused {
        tokenStorage.mint(_to, _value);
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return tokenStorage.balanceOf(_owner);
    }

    function transfer(address _to, uint _value) public unlessUpgraded whenNotPaused returns(bool) {
        return tokenStorage.transfer(_to, _value);
    }

    function approve(address _to, uint _value) public unlessUpgraded whenNotPaused returns(bool) {
        return tokenStorage.approve(_to, _value);
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return tokenStorage.allowance(_owner, _spender);
    }

    function transferFrom(address _from, address _to, uint256 _value) public unlessUpgraded whenNotPaused returns (bool) {
        return tokenStorage.transferFrom(_from, _to, _value);
    }

    function increaseApproval(address _spender, uint256 _addedValue) public unlessUpgraded whenNotPaused returns (bool) {
        return tokenStorage.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public unlessUpgraded whenNotPaused returns (bool) {
        return tokenStorage.decreaseApproval(_spender, _subtractedValue);
    }
}