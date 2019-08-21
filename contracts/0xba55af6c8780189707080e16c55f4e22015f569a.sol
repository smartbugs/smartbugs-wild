pragma solidity ^0.4.18;

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


contract EIP820ImplementerInterface {
    /// @notice Contracts that implement an interferce in behalf of another contract must return true
    /// @param addr Address that the contract woll implement the interface in behalf of
    /// @param interfaceHash keccak256 of the name of the interface
    /// @return true if the contract can implement the interface represented by
    ///  `ìnterfaceHash` in behalf of `addr`
    function canImplementInterfaceForAddress(address addr, bytes32 interfaceHash) view public returns(bool);
}

contract EIP820Registry {

    mapping (address => mapping(bytes32 => address)) interfaces;
    mapping (address => address) managers;

    modifier canManage(address addr) {
        require(getManager(addr) == msg.sender);
        _;
    }

    /// @notice Query the hash of an interface given a name
    /// @param interfaceName Name of the interfce
    function interfaceHash(string interfaceName) public pure returns(bytes32) {
        return keccak256(interfaceName);
    }

    /// @notice GetManager
    function getManager(address addr) public view returns(address) {
        // By default the manager of an address is the same address
        if (managers[addr] == 0) {
            return addr;
        } else {
            return managers[addr];
        }
    }

    /// @notice Sets an external `manager` that will be able to call `setInterfaceImplementer()`
    ///  on behalf of the address.
    /// @param addr Address that you are defining the manager for.
    /// @param newManager The address of the manager for the `addr` that will replace
    ///  the old one.  Set to 0x0 if you want to remove the manager.
    function setManager(address addr, address newManager) public canManage(addr) {
        managers[addr] = newManager == addr ? 0 : newManager;
        ManagerChanged(addr, newManager);
    }

    /// @notice Query if an address implements an interface and thru which contract
    /// @param addr Address that is being queried for the implementation of an interface
    /// @param iHash SHA3 of the name of the interface as a string
    ///  Example `web3.utils.sha3('Ierc777`')`
    /// @return The address of the contract that implements a speficic interface
    ///  or 0x0 if `addr` does not implement this interface
    function getInterfaceImplementer(address addr, bytes32 iHash) public constant returns (address) {
        return interfaces[addr][iHash];
    }

    /// @notice Sets the contract that will handle a specific interface; only
    ///  the address itself or a `manager` defined for that address can set it
    /// @param addr Address that you want to define the interface for
    /// @param iHash SHA3 of the name of the interface as a string
    ///  For example `web3.utils.sha3('Ierc777')` for the Ierc777
    function setInterfaceImplementer(address addr, bytes32 iHash, address implementer) public canManage(addr)  {
        if ((implementer != 0) && (implementer!=msg.sender)) {
            require(EIP820ImplementerInterface(implementer).canImplementInterfaceForAddress(addr, iHash));
        }
        interfaces[addr][iHash] = implementer;
        InterfaceImplementerSet(addr, iHash, implementer);
    }

    event InterfaceImplementerSet(address indexed addr, bytes32 indexed interfaceHash, address indexed implementer);
    event ManagerChanged(address indexed addr, address indexed newManager);
}

contract EIP820Implementer {
    EIP820Registry eip820Registry = EIP820Registry(0x9aA513f1294c8f1B254bA1188991B4cc2EFE1D3B);

    function setInterfaceImplementation(string ifaceLabel, address impl) internal {
        bytes32 ifaceHash = keccak256(ifaceLabel);
        eip820Registry.setInterfaceImplementer(this, ifaceHash, impl);
    }

    function interfaceAddr(address addr, string ifaceLabel) internal constant returns(address) {
        bytes32 ifaceHash = keccak256(ifaceLabel);
        return eip820Registry.getInterfaceImplementer(addr, ifaceHash);
    }

    function delegateManagement(address newManager) internal {
        eip820Registry.setManager(this, newManager);
    }

}



contract AssetRegistryStorage {

  string internal _name;
  string internal _symbol;
  string internal _description;

  /**
   * Stores the total count of assets managed by this registry
   */
  uint256 internal _count;

  /**
   * Stores an array of assets owned by a given account
   */
  mapping(address => uint256[]) internal _assetsOf;

  /**
   * Stores the current holder of an asset
   */
  mapping(uint256 => address) internal _holderOf;

  /**
   * Stores the index of an asset in the `_assetsOf` array of its holder
   */
  mapping(uint256 => uint256) internal _indexOfAsset;

  /**
   * Stores the data associated with an asset
   */
  mapping(uint256 => string) internal _assetData;

  /**
   * For a given account, for a given operator, store whether that operator is
   * allowed to transfer and modify assets on behalf of them.
   */
  mapping(address => mapping(address => bool)) internal _operators;

  /**
   * Simple reentrancy lock
   */
  bool internal _reentrancy;

  /**
   * Complex reentrancy lock
   */
  uint256 internal _reentrancyCount;

  /**
   * Approval array
   */
  mapping(uint256 => address) internal _approval;
}


interface IAssetHolder {
  function onAssetReceived(
    /* address _assetRegistry == msg.sender */
    uint256 _assetId,
    address _previousHolder,
    address _currentHolder,
    bytes   _userData,
    address _operator,
    bytes   _operatorData
  ) public;
}


interface IAssetRegistry {

  /**
   * Global Registry getter functions
   */
  function name() public view returns (string);
  function symbol() public view returns (string);
  function description() public view returns (string);
  function totalSupply() public view returns (uint256);
  function decimals() public view returns (uint256);

  function isERC821() public view returns (bool);

  /**
   * Asset-centric getter functions
   */
  function exists(uint256 assetId) public view returns (bool);

  function holderOf(uint256 assetId) public view returns (address);
  function ownerOf(uint256 assetId) public view returns (address);

  function safeHolderOf(uint256 assetId) public view returns (address);
  function safeOwnerOf(uint256 assetId) public view returns (address);

  function assetData(uint256 assetId) public view returns (string);
  function safeAssetData(uint256 assetId) public view returns (string);

  /**
   * Holder-centric getter functions
   */
  function assetCount(address holder) public view returns (uint256);
  function balanceOf(address holder) public view returns (uint256);

  function assetByIndex(address holder, uint256 index) public view returns (uint256);
  function assetsOf(address holder) external view returns (uint256[]);

  /**
   * Transfer Operations
   */
  function transfer(address to, uint256 assetId) public;
  function transfer(address to, uint256 assetId, bytes userData) public;
  function transfer(address to, uint256 assetId, bytes userData, bytes operatorData) public;

  /**
   * Authorization operations
   */
  function authorizeOperator(address operator, bool authorized) public;
  function approve(address operator, uint256 assetId) public;

  /**
   * Authorization getters
   */
  function isOperatorAuthorizedBy(address operator, address assetHolder)
    public view returns (bool);

  function approvedFor(uint256 assetId)
    public view returns (address);

  function isApprovedFor(address operator, uint256 assetId)
    public view returns (bool);

  /**
   * Events
   */
  event Transfer(
    address indexed from,
    address indexed to,
    uint256 indexed assetId,
    address operator,
    bytes userData,
    bytes operatorData
  );
  event Update(
    uint256 indexed assetId,
    address indexed holder,
    address indexed operator,
    string data
  );
  event AuthorizeOperator(
    address indexed operator,
    address indexed holder,
    bool authorized
  );
  event Approve(
    address indexed owner,
    address indexed operator,
    uint256 indexed assetId
  );
}


contract StandardAssetRegistry is AssetRegistryStorage, IAssetRegistry, EIP820Implementer {
  using SafeMath for uint256;

  //
  // Global Getters
  //

  function name() public view returns (string) {
    return _name;
  }

  function symbol() public view returns (string) {
    return _symbol;
  }

  function description() public view returns (string) {
    return _description;
  }

  function totalSupply() public view returns (uint256) {
    return _count;
  }

  function decimals() public view returns (uint256) {
    return 0;
  }

  function isERC821() public view returns (bool) {
    return true;
  }

  //
  // Asset-centric getter functions
  //

  function exists(uint256 assetId) public view returns (bool) {
    return _holderOf[assetId] != 0;
  }

  function holderOf(uint256 assetId) public view returns (address) {
    return _holderOf[assetId];
  }

  function ownerOf(uint256 assetId) public view returns (address) {
    // It's OK to be inefficient here, as this method is for compatibility.
    // Users should call `holderOf`
    return holderOf(assetId);
  }

  function safeHolderOf(uint256 assetId) public view returns (address) {
    address holder = _holderOf[assetId];
    require(holder != 0);
    return holder;
  }

  function safeOwnerOf(uint256 assetId) public view returns (address) {
    return safeHolderOf(assetId);
  }

  function assetData(uint256 assetId) public view returns (string) {
    return _assetData[assetId];
  }

  function safeAssetData(uint256 assetId) public view returns (string) {
    require(_holderOf[assetId] != 0);
    return _assetData[assetId];
  }

  //
  // Holder-centric getter functions
  //

  function assetCount(address holder) public view returns (uint256) {
    return _assetsOf[holder].length;
  }

  function balanceOf(address holder) public view returns (uint256) {
    return assetCount(holder);
  }

  function assetByIndex(address holder, uint256 index) public view returns (uint256) {
    require(index < _assetsOf[holder].length);
    require(index < (1<<127));
    return _assetsOf[holder][index];
  }

  function assetsOf(address holder) external view returns (uint256[]) {
    return _assetsOf[holder];
  }

  //
  // Authorization getters
  //

  function isOperatorAuthorizedBy(address operator, address assetHolder)
    public view returns (bool)
  {
    return _operators[assetHolder][operator];
  }

  function approvedFor(uint256 assetId) public view returns (address) {
    return _approval[assetId];
  }

  function isApprovedFor(address operator, uint256 assetId)
    public view returns (bool)
  {
    require(operator != 0);
    if (operator == holderOf(assetId)) {
      return true;
    }
    return _approval[assetId] == operator;
  }

  //
  // Authorization
  //

  function authorizeOperator(address operator, bool authorized) public {
    if (authorized) {
      require(!isOperatorAuthorizedBy(operator, msg.sender));
      _addAuthorization(operator, msg.sender);
    } else {
      require(isOperatorAuthorizedBy(operator, msg.sender));
      _clearAuthorization(operator, msg.sender);
    }
    AuthorizeOperator(operator, msg.sender, authorized);
  }

  function approve(address operator, uint256 assetId) public {
    address holder = holderOf(assetId);
    require(operator != holder);
    if (approvedFor(assetId) != operator) {
      _approval[assetId] = operator;
      Approve(holder, operator, assetId);
    }
  }

  function _addAuthorization(address operator, address holder) private {
    _operators[holder][operator] = true;
  }

  function _clearAuthorization(address operator, address holder) private {
    _operators[holder][operator] = false;
  }

  //
  // Internal Operations
  //

  function _addAssetTo(address to, uint256 assetId) internal {
    _holderOf[assetId] = to;

    uint256 length = assetCount(to);

    _assetsOf[to].push(assetId);

    _indexOfAsset[assetId] = length;

    _count = _count.add(1);
  }

  function _addAssetTo(address to, uint256 assetId, string data) internal {
    _addAssetTo(to, assetId);

    _assetData[assetId] = data;
  }

  function _removeAssetFrom(address from, uint256 assetId) internal {
    uint256 assetIndex = _indexOfAsset[assetId];
    uint256 lastAssetIndex = assetCount(from).sub(1);
    uint256 lastAssetId = _assetsOf[from][lastAssetIndex];

    _holderOf[assetId] = 0;

    // Insert the last asset into the position previously occupied by the asset to be removed
    _assetsOf[from][assetIndex] = lastAssetId;

    // Resize the array
    _assetsOf[from][lastAssetIndex] = 0;
    _assetsOf[from].length--;

    // Remove the array if no more assets are owned to prevent pollution
    if (_assetsOf[from].length == 0) {
      delete _assetsOf[from];
    }

    // Update the index of positions for the asset
    _indexOfAsset[assetId] = 0;
    _indexOfAsset[lastAssetId] = assetIndex;

    _count = _count.sub(1);
  }

  function _clearApproval(address holder, uint256 assetId) internal {
    if (holderOf(assetId) == holder && _approval[assetId] != 0) {
      _approval[assetId] = 0;
      Approve(holder, 0, assetId);
    }
  }

  function _removeAssetData(uint256 assetId) internal {
    _assetData[assetId] = '';
  }

  //
  // Supply-altering functions
  //

  function _generate(uint256 assetId, address beneficiary, string data) internal {
    require(_holderOf[assetId] == 0);

    _addAssetTo(beneficiary, assetId, data);

    Transfer(0, beneficiary, assetId, msg.sender, bytes(data), '');
  }

  function _destroy(uint256 assetId) internal {
    address holder = _holderOf[assetId];
    require(holder != 0);

    _removeAssetFrom(holder, assetId);
    _removeAssetData(assetId);

    Transfer(holder, 0, assetId, msg.sender, '', '');
  }

  //
  // Transaction related operations
  //

  modifier onlyHolder(uint256 assetId) {
    require(_holderOf[assetId] == msg.sender);
    _;
  }

  modifier onlyOperatorOrHolder(uint256 assetId) {
    require(
      _holderOf[assetId] == msg.sender
      || isOperatorAuthorizedBy(msg.sender, _holderOf[assetId])
      || isApprovedFor(msg.sender, assetId)
    );
    _;
  }

  modifier isDestinataryDefined(address destinatary) {
    require(destinatary != 0);
    _;
  }

  modifier destinataryIsNotHolder(uint256 assetId, address to) {
    require(_holderOf[assetId] != to);
    _;
  }

  function transfer(address to, uint256 assetId) public {
    return _doTransfer(to, assetId, '', 0, '');
  }

  function transfer(address to, uint256 assetId, bytes userData) public {
    return _doTransfer(to, assetId, userData, 0, '');
  }

  function transfer(address to, uint256 assetId, bytes userData, bytes operatorData) public {
    return _doTransfer(to, assetId, userData, msg.sender, operatorData);
  }

  function _doTransfer(
    address to, uint256 assetId, bytes userData, address operator, bytes operatorData
  )
    isDestinataryDefined(to)
    destinataryIsNotHolder(assetId, to)
    onlyOperatorOrHolder(assetId)
    internal
  {
    return _doSend(to, assetId, userData, operator, operatorData);
  }


  function _doSend(
    address to, uint256 assetId, bytes userData, address operator, bytes operatorData
  )
    internal
  {
    address holder = _holderOf[assetId];
    _removeAssetFrom(holder, assetId);
    _clearApproval(holder, assetId);
    _addAssetTo(to, assetId);

    if (_isContract(to)) {
      require(!_reentrancy);
      _reentrancy = true;

      address recipient = interfaceAddr(to, 'IAssetHolder');
      require(recipient != 0);

      IAssetHolder(recipient).onAssetReceived(assetId, holder, to, userData, operator, operatorData);

      _reentrancy = false;
    }

    Transfer(holder, to, assetId, operator, userData, operatorData);
  }

  //
  // Update related functions
  //

  function _update(uint256 assetId, string data) internal {
    require(exists(assetId));
    _assetData[assetId] = data;
    Update(assetId, _holderOf[assetId], msg.sender, data);
  }

  //
  // Utilities
  //

  function _isContract(address addr) internal view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }
}


/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 *      See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
  }
}



/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 *      Supports unlimited numbers of roles and addresses.
 *      See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 *  for you to write your own implementation of this interface using Enums or similar.
 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,
 *  to avoid typos.
 */
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address addr, string roleName);
  event RoleRemoved(address addr, string roleName);

  /**
   * A constant role name for indicating admins.
   */
  string public constant ROLE_ADMIN = "admin";

  /**
   * @dev constructor. Sets msg.sender as admin by default
   */
  function RBAC()
    public
  {
    addRole(msg.sender, ROLE_ADMIN);
  }

  /**
   * @dev reverts if addr does not have role
   * @param addr address
   * @param roleName the name of the role
   * // reverts
   */
  function checkRole(address addr, string roleName)
    view
    public
  {
    roles[roleName].check(addr);
  }

  /**
   * @dev determine if addr has role
   * @param addr address
   * @param roleName the name of the role
   * @return bool
   */
  function hasRole(address addr, string roleName)
    view
    public
    returns (bool)
  {
    return roles[roleName].has(addr);
  }

  /**
   * @dev add a role to an address
   * @param addr address
   * @param roleName the name of the role
   */
  function adminAddRole(address addr, string roleName)
    onlyAdmin
    public
  {
    addRole(addr, roleName);
  }

  /**
   * @dev remove a role from an address
   * @param addr address
   * @param roleName the name of the role
   */
  function adminRemoveRole(address addr, string roleName)
    onlyAdmin
    public
  {
    removeRole(addr, roleName);
  }

  /**
   * @dev add a role to an address
   * @param addr address
   * @param roleName the name of the role
   */
  function addRole(address addr, string roleName)
    internal
  {
    roles[roleName].add(addr);
    RoleAdded(addr, roleName);
  }

  /**
   * @dev remove a role from an address
   * @param addr address
   * @param roleName the name of the role
   */
  function removeRole(address addr, string roleName)
    internal
  {
    roles[roleName].remove(addr);
    RoleRemoved(addr, roleName);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param roleName the name of the role
   * // reverts
   */
  modifier onlyRole(string roleName)
  {
    checkRole(msg.sender, roleName);
    _;
  }

  /**
   * @dev modifier to scope access to admins
   * // reverts
   */
  modifier onlyAdmin()
  {
    checkRole(msg.sender, ROLE_ADMIN);
    _;
  }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param roleNames the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] roleNames) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < roleNames.length; i++) {
  //         if (hasRole(msg.sender, roleNames[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
}


contract Mintable821 is StandardAssetRegistry, RBAC {
  event Mint(uint256 assetId, address indexed beneficiary, string data);
  event MintFinished();

  uint256 public nextAssetId = 0;

  string constant ROLE_MINTER = "minter";
  bool public minting;

  modifier onlyMinter() {
    require(
      hasRole(msg.sender, ROLE_MINTER)
    );
    _;
  }

  modifier canMint() {
    require(minting);
    _;
  }

  function Mintable821(address minter) public {
    _name = "Mintable821";
    _symbol = "MINT";
    _description = "ERC 821 minting contract";

    removeRole(msg.sender, ROLE_ADMIN);
    addRole(minter, ROLE_MINTER);

    minting = true;
  }

  function isContractProxy(address addr) public view returns (bool) {
    return _isContract(addr);
  }

  function generate(address beneficiary, string data)
    onlyMinter
    canMint
    public
  {
    uint256 assetId = nextAssetId;
    _generate(assetId, beneficiary, data);
    Mint(assetId, beneficiary, data);
    nextAssetId = nextAssetId + 1;
  }

  // function update(uint256 assetId, string data)
  //   onlyMinter
  //   public
  // {
  //   _update(assetId, data);
  // }

  function transferTo(
    address to, uint256 assetId, bytes userData, bytes operatorData
  )
    public
  {
    return transfer(to, assetId, userData, operatorData);
  }

  function endMinting()
    onlyMinter
    canMint
    public
  {
    minting = false;
    MintFinished();
  }
}


contract OZWorkshop is Mintable821 {
  function OZWorkshop ()
    Mintable821(msg.sender)
    public
  {
    _name = "OZ Workshop";
    _symbol = "OZWS";
    _description = "Awarded for completing the OpenZeppelin Workshop at ETHDenver 2018";
  }
}