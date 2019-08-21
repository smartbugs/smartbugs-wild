pragma solidity 0.4.23;

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * @notice Checks if the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   *      as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address addr) internal view returns (bool) {
    // a variable to load `extcodesize` to
    uint256 size = 0;

    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603 for more details about how this works.
    // TODO: Check this again before the Serenity release, because all addresses will be contracts.
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      // retrieve the size of the code at address `addr`
      size := extcodesize(addr)
    }

    // positive size indicates a smart contract address
    return size > 0;
  }

}


/**
 * Library for working with strings, primarily converting
 * between strings and integer types
 */
library StringUtils {
  /**
   * @dev Converts a string to unsigned integer using the specified `base`
   * @dev Throws on invalid input
   *      (wrong characters for a given `base`)
   * @dev Throws if given `base` is not supported
   * @param a string to convert
   * @param base number base, one of 2, 8, 10, 16
   * @return a number representing given string
   */
  function atoi(string a, uint8 base) internal pure returns (uint256 i) {
    // check if the base is valid
    require(base == 2 || base == 8 || base == 10 || base == 16);

    // convert string into bytes for convenient iteration
    bytes memory buf = bytes(a);

    // iterate over the string (bytes buffer)
    for(uint256 p = 0; p < buf.length; p++) {
      // extract the digit
      uint8 digit = uint8(buf[p]) - 0x30;

      // if digit is greater then 10 – mind the gap
      // see `itoa` function for more details
      if(digit > 10) {
        // remove the gap
        digit -= 7;
      }

      // check if digit meets the base
      require(digit < base);

      // move to the next digit slot
      i *= base;

      // add digit to the result
      i += digit;
    }

    // return the result
    return i;
  }

  /**
   * @dev Converts a integer to a string using the specified `base`
   * @dev Throws if given `base` is not supported
   * @param i integer to convert
   * @param base number base, one of 2, 8, 10, 16
   * @return a string representing given integer
   */
  function itoa(uint256 i, uint8 base) internal pure returns (string a) {
    // check if the base is valid
    require(base == 2 || base == 8 || base == 10 || base == 16);

    // for zero input the result is "0" string for any base
    if (i == 0) {
      return "0";
    }

    // bytes buffer to put ASCII characters into
    bytes memory buf = new bytes(256);

    // position within a buffer to be used in cycle
    uint256 p = 0;

    // extract digits one by one in a cycle
    while (i > 0) {
      // extract current digit
      uint8 digit = uint8(i % base);

      // convert it to an ASCII code
      // 0x20 is " "
      // 0x30-0x39 is "0"-"9"
      // 0x41-0x5A is "A"-"Z"
      // 0x61-0x7A is "a"-"z" ("A"-"Z" XOR " ")
      uint8 ascii = digit + 0x30;

      // if digit is greater then 10,
      // fix the 0x3A-0x40 gap of punctuation marks
      // (7 characters in ASCII table)
      if(digit > 10) {
        // jump through the gap
        ascii += 7;
      }

      // write character into the buffer
      buf[p++] = byte(ascii);

      // move to the next digit
      i /= base;
    }

    // `p` contains real length of the buffer now, save it
    uint256 length = p;

    // reverse the buffer
    for(p = 0; p < length / 2; p++) {
      // swap elements at position `p` from the beginning and end using XOR:
      // https://en.wikipedia.org/wiki/XOR_swap_algorithm
      buf[p] ^= buf[length - 1 - p];
      buf[length - 1 - p] ^= buf[p];
      buf[p] ^= buf[length - 1 - p];
    }

    // construct string and return
    return string(buf);
  }

  /**
   * @dev Concatenates two strings `s1` and `s2`, for example, if
   *      `s1` == `foo` and `s2` == `bar`, the result `s` == `foobar`
   * @param s1 first string
   * @param s2 second string
   * @return concatenation result s1 + s2
   */
  function concat(string s1, string s2) internal pure returns (string s) {
    // convert s1 into buffer 1
    bytes memory buf1 = bytes(s1);
    // convert s2 into buffer 2
    bytes memory buf2 = bytes(s2);
    // create a buffer for concatenation result
    bytes memory buf = new bytes(buf1.length + buf2.length);

    // copy buffer 1 into buffer
    for(uint256 i = 0; i < buf1.length; i++) {
      buf[i] = buf1[i];
    }

    // copy buffer 2 into buffer
    for(uint256 j = buf1.length; j < buf2.length; j++) {
      buf[j] = buf2[j - buf1.length];
    }

    // construct string and return
    return string(buf);
  }
}


/**
 * @dev Access control module provides an API to check
 *      if specific operation is permitted globally and
 *      if particular user's has a permission to execute it
 */
contract AccessControl {
  /// @notice Role manager is responsible for assigning the roles
  /// @dev Role ROLE_ROLE_MANAGER allows executing addOperator/removeOperator
  uint256 private constant ROLE_ROLE_MANAGER = 0x10000000;

  /// @notice Feature manager is responsible for enabling/disabling
  ///      global features of the smart contract
  /// @dev Role ROLE_FEATURE_MANAGER allows enabling/disabling global features
  uint256 private constant ROLE_FEATURE_MANAGER = 0x20000000;

  /// @dev Bitmask representing all the possible permissions (super admin role)
  uint256 private constant FULL_PRIVILEGES_MASK = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  /// @dev A bitmask of globally enabled features
  uint256 public features;

  /// @notice Privileged addresses with defined roles/permissions
  /// @notice In the context of ERC20/ERC721 tokens these can be permissions to
  ///      allow minting tokens, transferring on behalf and so on
  /// @dev Maps an address to the permissions bitmask (role), where each bit
  ///      represents a permission
  /// @dev Bitmask 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
  ///      represents all possible permissions
  mapping(address => uint256) public userRoles;

  /// @dev Fired in updateFeatures()
  event FeaturesUpdated(address indexed _by, uint256 _requested, uint256 _actual);

  /// @dev Fired in addOperator(), removeOperator(), addRole(), removeRole()
  event RoleUpdated(address indexed _by, address indexed _to, uint256 _role);

  /**
   * @dev Creates an access controlled instance
   */
  constructor() public {
    // contract creator has full privileges
    userRoles[msg.sender] = FULL_PRIVILEGES_MASK;
  }

  /**
   * @dev Updates set of the globally enabled features (`f`),
   *      taking into account sender's permissions.
   * @dev Requires sender to have `ROLE_FEATURE_MANAGER` permission.
   * @param mask bitmask representing a set of features to enable/disable
   */
  function updateFeatures(uint256 mask) public {
    // call sender nicely - caller
    address caller = msg.sender;
    // read caller's permissions
    uint256 p = userRoles[caller];

    // caller should have a permission to update global features
    require(__hasRole(p, ROLE_FEATURE_MANAGER));

    // taking into account caller's permissions,
    // 1) enable features requested
    features |= p & mask;
    // 2) disable features requested
    features &= FULL_PRIVILEGES_MASK ^ (p & (FULL_PRIVILEGES_MASK ^ mask));

    // fire an event
    emit FeaturesUpdated(caller, mask, features);
  }

  /**
   * @dev Adds a new `operator` - an address which has
   *      some extended privileges over the smart contract,
   *      for example token minting, transferring on behalf, etc.
   * @dev Newly added `operator` cannot have any permissions which
   *      transaction sender doesn't have.
   * @dev Requires transaction sender to have `ROLE_ROLE_MANAGER` permission.
   * @dev Cannot update existing operator. Throws if `operator` already exists.
   * @param operator address of the operator to add
   * @param role bitmask representing a set of permissions which
   *      newly created operator will have
   */
  function addOperator(address operator, uint256 role) public {
    // call sender gracefully - `manager`
    address manager = msg.sender;

    // read manager's permissions (role)
    uint256 permissions = userRoles[manager];

    // check that `operator` doesn't exist
    require(userRoles[operator] == 0);

    // manager must have a ROLE_ROLE_MANAGER role
    require(__hasRole(permissions, ROLE_ROLE_MANAGER));

    // recalculate permissions (role) to set:
    // we cannot create an operator more powerful then calling `manager`
    uint256 r = role & permissions;

    // check if we still have some permissions (role) to set
    require(r != 0);

    // create an operator by persisting his permissions (roles) to storage
    userRoles[operator] = r;

    // fire an event
    emit RoleUpdated(manager, operator, userRoles[operator]);
  }

  /**
   * @dev Deletes an existing `operator`.
   * @dev Requires sender to have `ROLE_ROLE_MANAGER` permission.
   * @param operator address of the operator to delete
   */
  function removeOperator(address operator) public {
    // call sender gracefully - `manager`
    address manager = msg.sender;

    // check if an `operator` exists
    require(userRoles[operator] != 0);

    // do not allow transaction sender to remove himself
    // protects from an accidental removal of all the operators
    require(operator != manager);

    // manager must have a ROLE_ROLE_MANAGER role
    // and he must have all the permissions operator has
    require(__hasRole(userRoles[manager], ROLE_ROLE_MANAGER | userRoles[operator]));

    // perform operator deletion
    delete userRoles[operator];

    // fire an event
    emit RoleUpdated(manager, operator, 0);
  }

  /**
   * @dev Updates an existing `operator`, adding a specified role to it.
   * @dev Note that `operator` cannot receive permission which
   *      transaction sender doesn't have.
   * @dev Requires transaction sender to have `ROLE_ROLE_MANAGER` permission.
   * @dev Cannot create a new operator. Throws if `operator` doesn't exist.
   * @dev Existing permissions of the `operator` are preserved
   * @param operator address of the operator to update
   * @param role bitmask representing a set of permissions which
   *      `operator` will have
   */
  function addRole(address operator, uint256 role) public {
    // call sender gracefully - `manager`
    address manager = msg.sender;

    // read manager's permissions (role)
    uint256 permissions = userRoles[manager];

    // check that `operator` exists
    require(userRoles[operator] != 0);

    // manager must have a ROLE_ROLE_MANAGER role
    require(__hasRole(permissions, ROLE_ROLE_MANAGER));

    // recalculate permissions (role) to add:
    // we cannot make an operator more powerful then calling `manager`
    uint256 r = role & permissions;

    // check if we still have some permissions (role) to add
    require(r != 0);

    // update operator's permissions (roles) in the storage
    userRoles[operator] |= r;

    // fire an event
    emit RoleUpdated(manager, operator, userRoles[operator]);
  }

  /**
   * @dev Updates an existing `operator`, removing a specified role from it.
   * @dev Note that  permissions which transaction sender doesn't have
   *      cannot be removed.
   * @dev Requires transaction sender to have `ROLE_ROLE_MANAGER` permission.
   * @dev Cannot remove all permissions. Throws on such an attempt.
   * @param operator address of the operator to update
   * @param role bitmask representing a set of permissions which
   *      will be removed from the `operator`
   */
  function removeRole(address operator, uint256 role) public {
    // call sender gracefully - `manager`
    address manager = msg.sender;

    // read manager's permissions (role)
    uint256 permissions = userRoles[manager];

    // check that we're not removing all the `operator`s permissions
    // this is not really required and just causes inconveniences is function use
    //require(userRoles[operator] ^ role != 0);

    // manager must have a ROLE_ROLE_MANAGER role
    require(__hasRole(permissions, ROLE_ROLE_MANAGER));

    // recalculate permissions (role) to remove:
    // we cannot revoke permissions which calling `manager` doesn't have
    uint256 r = role & permissions;

    // check if we still have some permissions (role) to revoke
    require(r != 0);

    // update operator's permissions (roles) in the storage
    userRoles[operator] &= FULL_PRIVILEGES_MASK ^ r;

    // fire an event
    emit RoleUpdated(manager, operator, userRoles[operator]);
  }

  /// @dev Checks if requested feature is enabled globally on the contract
  function __isFeatureEnabled(uint256 featureRequired) internal constant returns(bool) {
    // delegate call to `__hasRole`
    return __hasRole(features, featureRequired);
  }

  /// @dev Checks if transaction sender `msg.sender` has all the required permissions `roleRequired`
  function __isSenderInRole(uint256 roleRequired) internal constant returns(bool) {
    // read sender's permissions (role)
    uint256 userRole = userRoles[msg.sender];

    // delegate call to `__hasRole`
    return __hasRole(userRole, roleRequired);
  }

  /// @dev Checks if user role `userRole` contain all the permissions required `roleRequired`
  function __hasRole(uint256 userRole, uint256 roleRequired) internal pure returns(bool) {
    // check the bitmask for the role required and return the result
    return userRole & roleRequired == roleRequired;
  }
}


/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safe transfers
 *      from ERC721 asset contracts.
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
interface ERC721Receiver {
  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient after a `transfer`.
   *      This function MAY throw to revert and reject the transfer.
   *      Return of other than the magic value MUST result in the transaction being reverted.
   * @notice The contract address is always the message sender.
   *      A wallet/broker/auction application MUST implement the wallet interface
   *      if it will accept safe transfers.
   * @param _operator The address which called `safeTransferFrom` function
   * @param _from The address which previously owned the token
   * @param _tokenId The NFT identifier which is being transferred
   * @param _data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))` unless throwing
   */
  function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
}


/**
 * @title ERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
contract ERC165 {
  /**
   * 0x01ffc9a7 == bytes4(keccak256('supportsInterface(bytes4)'))
   */
  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;

  /**
   * @dev a mapping of interface id to whether or not it's supported
   */
  mapping(bytes4 => bool) internal supportedInterfaces;

  /**
   * @dev A contract implementing SupportsInterfaceWithLookup
   * implement ERC165 itself
   */
  constructor() public {
    // register itself in a lookup table
    _registerInterface(InterfaceId_ERC165);
  }



  /**
   * @notice Query if a contract implements an interface
   * @param _interfaceId The interface identifier, as specified in ERC-165
   * @dev Interface identification is specified in ERC-165.
   * @dev This function uses less than 30,000 gas.
   */
  function supportsInterface(bytes4 _interfaceId) public constant returns (bool) {
    // find if interface is supported using a lookup table
    return supportedInterfaces[_interfaceId];
  }

  /**
   * @dev private method for registering an interface
   */
  function _registerInterface(bytes4 _interfaceId) internal {
    require(_interfaceId != 0xffffffff);
    supportedInterfaces[_interfaceId] = true;
  }
}


/**
 * @notice Gem is unique tradable entity. Non-fungible.
 * @dev A gem is an ERC721 non-fungible token, which maps Token ID,
 *      a 32 bit number to a set of gem properties -
 *      attributes (mostly immutable by their nature) and state variables (mutable)
 * @dev A gem token supports only minting, it can be only created
 */
contract GemERC721 is AccessControl, ERC165 {
  /// @dev Smart contract version
  /// @dev Should be incremented manually in this source code
  ///      each time smart contact source code is changed
  uint32 public constant TOKEN_VERSION = 0x3;

  /// @dev ERC20 compliant token symbol
  string public constant symbol = "GEM";
  /// @dev ERC20 compliant token name
  string public constant name = "GEM – CryptoMiner World";
  /// @dev ERC20 compliant token decimals
  /// @dev this can be only zero, since ERC721 token is non-fungible
  uint8 public constant decimals = 0;

  /// @dev A gem data structure
  /// @dev Occupies 64 bytes of storage (512 bits)
  struct Gem {
    /// High 256 bits
    /// @dev Where gem was found: land plot ID,
    ///      land block within a plot,
    ///      gem number (id) within a block of land, immutable
    uint64 coordinates;

    /// @dev Gem color, one of 12 values, immutable
    uint8 color;

    /// @dev Level modified time
    /// @dev Stored as Ethereum Block Number of the transaction
    ///      when the gem was created
    uint32 levelModified;

    /// @dev Level value (mutable), one of 1, 2, 3, 4, 5
    uint8 level;

    /// @dev Grade modified time
    /// @dev Stored as Ethereum Block Number of the transaction
    ///      when the gem was created
    uint32 gradeModified;

    /// @dev High 8 bits store grade type and low 24 bits grade value
    /// @dev Grade type is one of D (1), C (2), B (3), A (4), AA (5) and AAA (6)
    uint32 grade;

    /// @dev Store state modified time
    /// @dev Stored as Ethereum Block Number of the transaction
    ///      when the gem was created
    uint32 stateModified;

    /// @dev State value, mutable
    uint48 state;


    /// Low 256 bits
    /// @dev Gem creation time, immutable, cannot be zero
    /// @dev Stored as Ethereum Block Number of the transaction
    ///      when the gem was created
    uint32 creationTime;

    /// @dev Gem index within an owner's collection of gems, mutable
    uint32 index;

    /// @dev Initially zero, changes when ownership is transferred
    /// @dev Stored as Ethereum Block Number of the transaction
    ///      when the gem's ownership was changed, mutable
    uint32 ownershipModified;

    /// @dev Gem's owner, initialized upon gem creation, mutable
    address owner;
  }

  /// @notice All the emitted gems
  /// @dev Core of the Gem as ERC721 token
  /// @dev Maps Gem ID => Gem Data Structure
  mapping(uint256 => Gem) public gems;

  /// @dev Mapping from a gem ID to an address approved to
  ///      transfer ownership rights for this gem
  mapping(uint256 => address) public approvals;

  /// @dev Mapping from owner to operator approvals
  ///      token owner => approved token operator => is approved
  mapping(address => mapping(address => bool)) public approvedOperators;

  /// @notice Storage for a collections of tokens
  /// @notice A collection of tokens is an ordered list of token IDs,
  ///      owned by a particular address (owner)
  /// @dev A mapping from owner to a collection of his tokens (IDs)
  /// @dev ERC20 compliant structure for balances can be derived
  ///      as a length of each collection in the mapping
  /// @dev ERC20 balances[owner] is equal to collections[owner].length
  mapping(address => uint32[]) public collections;

  /// @dev Array with all token ids, used for enumeration
  /// @dev ERC20 compliant structure for totalSupply can be derived
  ///      as a length of this collection
  /// @dev ERC20 totalSupply() is equal to allTokens.length
  uint32[] public allTokens;

  /// @dev The data in token's state may contain lock(s)
  ///      (ex.: is gem currently mining or not)
  /// @dev A locked token cannot be transferred or upgraded
  /// @dev The token is locked if it contains any bits
  ///      from the `lockedBitmask` in its `state` set
  uint64 public lockedBitmask = DEFAULT_MINING_BIT;

  /// @dev Enables ERC721 transfers of the tokens
  uint32 public constant FEATURE_TRANSFERS = 0x00000001;

  /// @dev Enables ERC721 transfers on behalf
  uint32 public constant FEATURE_TRANSFERS_ON_BEHALF = 0x00000002;

  /// @dev Enables partial support of ERC20 transfers of the tokens,
  ///      allowing to transfer only all owned tokens at once
  //uint32 public constant ERC20_TRANSFERS = 0x00000004;

  /// @dev Enables partial support of ERC20 transfers on behalf
  ///      allowing to transfer only all owned tokens at once
  //uint32 public constant ERC20_TRANSFERS_ON_BEHALF = 0x00000008;

  /// @dev Enables full support of ERC20 transfers of the tokens,
  ///      allowing to transfer arbitrary amount of the tokens at once
  //uint32 public constant ERC20_INSECURE_TRANSFERS = 0x00000010;

  /// @dev Default bitmask indicating that the gem is `mining`
  /// @dev Consists of a single bit at position 1 – binary 1
  /// @dev This bit is cleared by `miningComplete`
  /// @dev The bit meaning in gem's `state` is as follows:
  ///      0: not mining
  ///      1: mining
  uint64 public constant DEFAULT_MINING_BIT = 0x1; // bit number 1

  /// @notice Exchange is responsible for trading tokens on behalf of token holders
  /// @dev Role ROLE_EXCHANGE allows executing transfer on behalf of token holders
  /// @dev Not used
  //uint32 public constant ROLE_EXCHANGE = 0x00010000;

  /// @notice Level provider is responsible for enabling the workshop
  /// @dev Role ROLE_LEVEL_PROVIDER allows leveling up the gem
  uint32 public constant ROLE_LEVEL_PROVIDER = 0x00100000;

  /// @notice Grade provider is responsible for enabling the workshop
  /// @dev Role ROLE_GRADE_PROVIDER allows modifying gem's grade
  uint32 public constant ROLE_GRADE_PROVIDER = 0x00200000;

  /// @notice Token state provider is responsible for enabling the mining protocol
  /// @dev Role ROLE_STATE_PROVIDER allows modifying token's state
  uint32 public constant ROLE_STATE_PROVIDER = 0x00400000;

  /// @notice Token state provider is responsible for enabling the mining protocol
  /// @dev Role ROLE_STATE_LOCK_PROVIDER allows modifying token's locked bitmask
  uint32 public constant ROLE_STATE_LOCK_PROVIDER = 0x00800000;

  /// @notice Token creator is responsible for creating tokens
  /// @dev Role ROLE_TOKEN_CREATOR allows minting tokens
  uint32 public constant ROLE_TOKEN_CREATOR = 0x00040000;

  /// @notice Token destroyer is responsible for destroying tokens
  /// @dev Role ROLE_TOKEN_DESTROYER allows burning tokens
  //uint32 public constant ROLE_TOKEN_DESTROYER = 0x00080000;

  /// @dev Magic value to be returned upon successful reception of an NFT
  /// @dev Equal to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`,
  ///      which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
  bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

  /**
   * Supported interfaces section
   */

  /**
   * ERC721 interface definition in terms of ERC165
   *
   * 0x80ac58cd ==
   *   bytes4(keccak256('balanceOf(address)')) ^
   *   bytes4(keccak256('ownerOf(uint256)')) ^
   *   bytes4(keccak256('approve(address,uint256)')) ^
   *   bytes4(keccak256('getApproved(uint256)')) ^
   *   bytes4(keccak256('setApprovalForAll(address,bool)')) ^
   *   bytes4(keccak256('isApprovedForAll(address,address)')) ^
   *   bytes4(keccak256('transferFrom(address,address,uint256)')) ^
   *   bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
   *   bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
   */
  bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;

  /**
   * ERC721 interface extension – exists(uint256)
   *
   * 0x4f558e79 == bytes4(keccak256('exists(uint256)'))
   */
  bytes4 private constant InterfaceId_ERC721Exists = 0x4f558e79;

  /**
   * ERC721 interface extension - ERC721Enumerable
   *
   * 0x780e9d63 ==
   *   bytes4(keccak256('totalSupply()')) ^
   *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
   *   bytes4(keccak256('tokenByIndex(uint256)'))
   */
  bytes4 private constant InterfaceId_ERC721Enumerable = 0x780e9d63;

  /**
   * ERC721 interface extension - ERC721Metadata
   *
   * 0x5b5e139f ==
   *   bytes4(keccak256('name()')) ^
   *   bytes4(keccak256('symbol()')) ^
   *   bytes4(keccak256('tokenURI(uint256)'))
   */
  bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;

  /// @dev Event names are self-explanatory:
  /// @dev Fired in mint()
  /// @dev Address `_by` allows to track who created a token
  event Minted(address indexed _by, address indexed _to, uint32 indexed _tokenId);

  /// @dev Fired in burn()
  /// @dev Address `_by` allows to track who destroyed a token
  //event Burnt(address indexed _from, address _by, uint32 indexed _tokenId);

  /// @dev Fired in transfer(), transferFor(), mint()
  /// @dev When minting a token, address `_from` is zero
  /// @dev ERC20/ERC721 compliant event
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId, uint256 _value);

  /// @dev Fired in approve()
  /// @dev ERC721 compliant event
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

  /// @dev Fired in setApprovalForAll()
  /// @dev ERC721 compliant event
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _value);

  /// @dev Fired in levelUp()
  event LevelUp(address indexed _by, address indexed _owner, uint256 indexed _tokenId, uint8 _levelReached);

  /// @dev Fired in upgradeGrade()
  event UpgradeComplete(address indexed _by, address indexed _owner, uint256 indexed _tokenId, uint32 _gradeFrom, uint32 _gradeTo);

  /// @dev Fired in setState()
  event StateModified(address indexed _by, address indexed _owner, uint256 indexed _tokenId, uint48 _stateFrom, uint48 _stateTo);

  /// @dev Creates a Gem ERC721 instance,
  /// @dev Registers a ERC721 interface using ERC165
  constructor() public {
    // register the supported interfaces to conform to ERC721 via ERC165
    _registerInterface(InterfaceId_ERC721);
    _registerInterface(InterfaceId_ERC721Exists);
    _registerInterface(InterfaceId_ERC721Enumerable);
    _registerInterface(InterfaceId_ERC721Metadata);
  }

  /**
   * @dev Gets a gem by ID, representing it as two integers.
   *      The two integers are tightly packed with a gem data:
   *      First integer (high bits) contains (from higher to lower bits order):
   *          coordinates:
   *            plotId,
   *            depth (block ID),
   *            gemNum (gem ID within a block)
   *          color,
   *          levelModified,
   *          level,
   *          gradeModified,
   *          grade,
   *          stateModified,
   *          state,
   *      Second integer (low bits) contains (from higher to lower bits order):
   *          creationTime,
   *          index,
   *          ownershipModified,
   *          owner
   * @dev Throws if gem doesn't exist
   * @param _tokenId ID of the gem to fetch
   */
  function getPacked(uint256 _tokenId) public constant returns(uint256, uint256) {
    // validate gem existence
    require(exists(_tokenId));

    // load the gem from storage
    Gem memory gem = gems[_tokenId];

    // pack high 256 bits of the result
    uint256 high = uint256(gem.coordinates) << 192
                 | uint192(gem.color) << 184
                 | uint184(gem.levelModified) << 152
                 | uint152(gem.level) << 144
                 | uint144(gem.gradeModified) << 112
                 | uint112(gem.grade) << 80
                 | uint80(gem.stateModified) << 48
                 | uint48(gem.state);

    // pack low 256 bits of the result
    uint256 low  = uint256(gem.creationTime) << 224
                 | uint224(gem.index) << 192
                 | uint192(gem.ownershipModified) << 160
                 | uint160(gem.owner);

    // return the whole 512 bits of result
    return (high, low);
  }

  /**
   * @dev Allows to fetch collection of tokens, including internal token data
   *       in a single function, useful when connecting to external node like INFURA
   * @param owner an address to query a collection for
   */
  function getPackedCollection(address owner) public constant returns (uint80[]) {
    // get an array of Gem IDs owned by an `owner` address
    uint32[] memory tokenIds = getCollection(owner);

    // how many gems are there in a collection
    uint32 balance = uint32(tokenIds.length);

    // data container to store the result
    uint80[] memory result = new uint80[](balance);

    // fetch token info one by one and pack into structure
    for(uint32 i = 0; i < balance; i++) {
      // token ID to work with
      uint32 tokenId = tokenIds[i];
      // get the token properties and pack them together with tokenId
      uint48 properties = getProperties(tokenId);

      // pack the data
      result[i] = uint80(tokenId) << 48 | properties;
    }

    // return the packed data structure
    return result;
  }

  /**
   * @notice Retrieves a collection of tokens owned by a particular address
   * @notice An order of token IDs is not guaranteed and may change
   *      when a token from the list is transferred
   * @param owner an address to query a collection for
   * @return an ordered list of tokens
   */
  function getCollection(address owner) public constant returns(uint32[]) {
    // read a collection from mapping and return
    return collections[owner];
  }

  /**
   * @dev Allows setting the `lockedBitmask` parameter of the contract,
   *      which is used to determine if a particular token is locked or not
   * @dev A locked token cannot be transferred, upgraded or burnt
   * @dev The token is locked if it contains any bits
   *      from the `lockedBitmask` in its `state` set
   * @dev Requires sender to have `ROLE_STATE_PROVIDER` permission.
   * @param bitmask a value to set `lockedBitmask` to
   */
  function setLockedBitmask(uint64 bitmask) public {
    // check that the call is made by a state lock provider
    require(__isSenderInRole(ROLE_STATE_LOCK_PROVIDER));

    // update the locked bitmask
    lockedBitmask = bitmask;
  }

  /**
   * @dev Gets the coordinates of a token
   * @param _tokenId ID of the token to get coordinates for
   * @return a token coordinates
   */
  function getCoordinates(uint256 _tokenId) public constant returns(uint64) {
    // validate token existence
    require(exists(_tokenId));

    // obtain token's coordinates from storage and return
    return gems[_tokenId].coordinates;
  }

  /**
   * @dev Gets the land plot ID of a gem
   * @param _tokenId ID of the gem to get land plot ID value for
   * @return a token land plot ID
   */
  function getPlotId(uint256 _tokenId) public constant returns(uint32) {
    // extract high 32 bits of the coordinates and return
    return uint32(getCoordinates(_tokenId) >> 32);
  }

  /**
   * @dev Gets the depth (block ID) within plot of land of a gem
   * @param _tokenId ID of the gem to get depth value for
   * @return a token depth
   */
  function getDepth(uint256 _tokenId) public constant returns(uint16) {
    // extract middle 16 bits of the coordinates and return
    return uint16(getCoordinates(_tokenId) >> 16);
  }

  /**
   * @dev Gets the gem's number within land block
   * @param _tokenId ID of the gem to get depth value for
   * @return a gem number within a land block
   */
  function getGemNum(uint256 _tokenId) public constant returns(uint16) {
    // extract low 16 bits of the coordinates and return
    return uint16(getCoordinates(_tokenId));
  }

  /**
   * @dev Gets the gem's properties – color, level and
   *      grade - as packed uint32 number
   * @param _tokenId ID of the gem to get properties for
   * @return gem's properties - color, level, grade as packed uint32
   */
  function getProperties(uint256 _tokenId) public constant returns(uint48) {
    // validate token existence
    require(exists(_tokenId));

    // read gem from storage
    Gem memory gem = gems[_tokenId];

    // pack data structure and return
    return uint48(gem.color) << 40 | uint40(gem.level) << 32 | gem.grade;
  }

  /**
   * @dev Gets the color of a token
   * @param _tokenId ID of the token to get color for
   * @return a token color
   */
  function getColor(uint256 _tokenId) public constant returns(uint8) {
    // validate token existence
    require(exists(_tokenId));

    // obtain token's color from storage and return
    return gems[_tokenId].color;
  }

  /**
   * @dev Gets the level modified date of a token
   * @param _tokenId ID of the token to get level modification date for
   * @return a token level modification date
   */
  function getLevelModified(uint256 _tokenId) public constant returns(uint32) {
    // validate token existence
    require(exists(_tokenId));

    // obtain token's level modified date from storage and return
    return gems[_tokenId].levelModified;
  }

  /**
   * @dev Gets the level of a token
   * @param _tokenId ID of the token to get level for
   * @return a token level
   */
  function getLevel(uint256 _tokenId) public constant returns(uint8) {
    // validate token existence
    require(exists(_tokenId));

    // obtain token's level from storage and return
    return gems[_tokenId].level;
  }

  /**
   * @dev Levels up a gem
   * @dev Requires sender to have `ROLE_STATE_PROVIDER` permission
   * @param _tokenId ID of the gem to level up
   */
  function levelUp(uint256 _tokenId) public {
    // check that the call is made by a level provider
    require(__isSenderInRole(ROLE_LEVEL_PROVIDER));

    // check that token to set state for exists
    require(exists(_tokenId));

    // update the level modified date
    gems[_tokenId].levelModified = uint32(block.number);

    // increment the level required
    gems[_tokenId].level++;

    // emit an event
    emit LevelUp(msg.sender, ownerOf(_tokenId), _tokenId, gems[_tokenId].level);
  }

  /**
   * @dev Gets the grade modified date of a gem
   * @param _tokenId ID of the gem to get grade modified date for
   * @return a token grade modified date
   */
  function getGradeModified(uint256 _tokenId) public constant returns(uint32) {
    // validate token existence
    require(exists(_tokenId));

    // obtain token's grade modified date from storage and return
    return gems[_tokenId].gradeModified;
  }

  /**
   * @dev Gets the grade of a gem
   * @param _tokenId ID of the gem to get grade for
   * @return a token grade
   */
  function getGrade(uint256 _tokenId) public constant returns(uint32) {
    // validate token existence
    require(exists(_tokenId));

    // obtain token's grade from storage and return
    return gems[_tokenId].grade;
  }

  /**
   * @dev Gets the grade type of a gem
   * @param _tokenId ID of the gem to get grade type for
   * @return a token grade type
   */
  function getGradeType(uint256 _tokenId) public constant returns(uint8) {
    // extract high 8 bits of the grade and return
    return uint8(getGrade(_tokenId) >> 24);
  }

  /**
   * @dev Gets the grade value of a gem
   * @param _tokenId ID of the gem to get grade value for
   * @return a token grade value
   */
  function getGradeValue(uint256 _tokenId) public constant returns(uint24) {
    // extract low 24 bits of the grade and return
    return uint24(getGrade(_tokenId));
  }

  /**
   * @dev Upgrades the grade of the gem
   * @dev Requires new grade to be higher than an old one
   * @dev Requires sender to have `ROLE_GRADE_PROVIDER` permission
   * @param _tokenId ID of the gem to modify the grade for
   * @param grade new grade to set for the token, should be higher then current state
   */
  function upgradeGrade(uint256 _tokenId, uint32 grade) public {
    // check that the call is made by a grade provider
    require(__isSenderInRole(ROLE_GRADE_PROVIDER));

    // check that token to set grade for exists
    require(exists(_tokenId));

    // check if we're not downgrading the gem
    require(gems[_tokenId].grade < grade);

    // emit an event
    emit UpgradeComplete(msg.sender, ownerOf(_tokenId), _tokenId, gems[_tokenId].grade, grade);

    // set the grade required
    gems[_tokenId].grade = grade;

    // update the grade modified date
    gems[_tokenId].gradeModified = uint32(block.number);
  }

  /**
   * @dev Gets the state modified date of a token
   * @param _tokenId ID of the token to get state modified date for
   * @return a token state modification date
   */
  function getStateModified(uint256 _tokenId) public constant returns(uint32) {
    // validate token existence
    require(exists(_tokenId));

    // obtain token's state modified date from storage and return
    return gems[_tokenId].stateModified;
  }

  /**
   * @dev Gets the state of a token
   * @param _tokenId ID of the token to get state for
   * @return a token state
   */
  function getState(uint256 _tokenId) public constant returns(uint48) {
    // validate token existence
    require(exists(_tokenId));

    // obtain token's state from storage and return
    return gems[_tokenId].state;
  }

  /**
   * @dev Sets the state of a token
   * @dev Requires sender to have `ROLE_STATE_PROVIDER` permission
   * @param _tokenId ID of the token to set state for
   * @param state new state to set for the token
   */
  function setState(uint256 _tokenId, uint48 state) public {
    // check that the call is made by a state provider
    require(__isSenderInRole(ROLE_STATE_PROVIDER));

    // check that token to set state for exists
    require(exists(_tokenId));

    // emit an event
    emit StateModified(msg.sender, ownerOf(_tokenId), _tokenId, gems[_tokenId].state, state);

    // set the state required
    gems[_tokenId].state = state;

    // update the state modified date
    gems[_tokenId].stateModified = uint32(block.number);
  }

  /**
   * @dev Gets the creation time of a token
   * @param _tokenId ID of the token to get creation time for
   * @return a token creation time
   */
  function getCreationTime(uint256 _tokenId) public constant returns(uint32) {
    // validate token existence
    require(exists(_tokenId));

    // obtain token's creation time from storage and return
    return gems[_tokenId].creationTime;
  }

  /**
   * @dev Gets the ownership modified time of a token
   * @param _tokenId ID of the token to get ownership modified time for
   * @return a token ownership modified time
   */
  function getOwnershipModified(uint256 _tokenId) public constant returns(uint32) {
    // validate token existence
    require(exists(_tokenId));

    // obtain token's ownership modified time from storage and return
    return gems[_tokenId].ownershipModified;
  }

  /**
   * @notice Total number of existing tokens (tracked by this contract)
   * @return A count of valid tokens tracked by this contract,
   *    where each one of them has an assigned and
   *    queryable owner not equal to the zero address
   */
  function totalSupply() public constant returns (uint256) {
    // read the length of the `allTokens` collection
    return allTokens.length;
  }

  /**
   * @notice Enumerate valid tokens
   * @dev Throws if `_index` >= `totalSupply()`.
   * @param _index a counter less than `totalSupply()`
   * @return The token ID for the `_index`th token, unsorted
   */
  function tokenByIndex(uint256 _index) public constant returns (uint256) {
    // out of bounds check
    require(_index < allTokens.length);

    // get the token ID and return
    return allTokens[_index];
  }

  /**
   * @notice Enumerate tokens assigned to an owner
   * @dev Throws if `_index` >= `balanceOf(_owner)`.
   * @param _owner an address of the owner to query token from
   * @param _index a counter less than `balanceOf(_owner)`
   * @return the token ID for the `_index`th token assigned to `_owner`, unsorted
   */
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public constant returns (uint256) {
    // out of bounds check
    require(_index < collections[_owner].length);

    // get the token ID from owner collection and return
    return collections[_owner][_index];
  }

  /**
   * @notice Gets an amount of token owned by the given address
   * @dev Gets the balance of the specified address
   * @param _owner address to query the balance for
   * @return an amount owned by the address passed as an input parameter
   */
  function balanceOf(address _owner) public constant returns (uint256) {
    // read the length of the `who`s collection of tokens
    return collections[_owner].length;
  }

  /**
   * @notice Checks if specified token exists
   * @dev Returns whether the specified token ID exists
   * @param _tokenId ID of the token to query the existence for
   * @return whether the token exists (true - exists)
   */
  function exists(uint256 _tokenId) public constant returns (bool) {
    // check if this token exists (owner is not zero)
    return gems[_tokenId].owner != address(0);
  }

  /**
   * @notice Finds an owner address for a token specified
   * @dev Gets the owner of the specified token from the `gems` mapping
   * @dev Throws if a token with the ID specified doesn't exist
   * @param _tokenId ID of the token to query the owner for
   * @return owner address currently marked as the owner of the given token
   */
  function ownerOf(uint256 _tokenId) public constant returns (address) {
    // check if this token exists
    require(exists(_tokenId));

    // return owner's address
    return gems[_tokenId].owner;
  }

  /**
   * @dev Creates new token with `tokenId` ID specified and
   *      assigns an ownership `to` for that token
   * @dev Allows setting initial token's properties
   * @param to an address to assign created token ownership to
   * @param tokenId ID of the token to create
   */
  function mint(
    address to,
    uint32 tokenId,
    uint32 plotId,
    uint16 depth,
    uint16 gemNum,
    uint8 color,
    uint8 level,
    uint8 gradeType,
    uint24 gradeValue
  ) public {
    // validate destination address
    require(to != address(0));
    require(to != address(this));

    // check if caller has sufficient permissions to mint a token
    // and if feature is enabled globally
    require(__isSenderInRole(ROLE_TOKEN_CREATOR));

    // delegate call to `__mint`
    __mint(to, tokenId, plotId, depth, gemNum, color, level, gradeType, gradeValue);

    // fire ERC20 transfer event
    emit Transfer(address(0), to, tokenId, 1);
  }

  /**
   * @notice Transfers ownership rights of a token defined
   *      by the `tokenId` to a new owner specified by address `to`
   * @dev Requires the sender of the transaction to be an owner
   *      of the token specified (`tokenId`)
   * @param to new owner address
   * @param _tokenId ID of the token to transfer ownership rights for
   */
  function transfer(address to, uint256 _tokenId) public {
    // check if token transfers feature is enabled
    require(__isFeatureEnabled(FEATURE_TRANSFERS));

    // call sender gracefully - `from`
    address from = msg.sender;

    // delegate call to unsafe `__transfer`
    __transfer(from, to, _tokenId);
  }

  /**
   * @notice A.k.a "transfer a token on behalf"
   * @notice Transfers ownership rights of a token defined
   *      by the `tokenId` to a new owner specified by address `to`
   * @notice Allows transferring ownership rights by a trading operator
   *      on behalf of token owner. Allows building an exchange of tokens.
   * @dev Transfers the ownership of a given token ID to another address
   * @dev Requires the transaction sender to be one of:
   *      owner of a gem - then its just a usual `transfer`
   *      approved – an address explicitly approved earlier by
   *        the owner of a token to transfer this particular token `tokenId`
   *      operator - an address explicitly approved earlier by
   *        the owner to transfer all his tokens on behalf
   * @param from current owner of the token
   * @param to address to receive the ownership of the token
   * @param _tokenId ID of the token to be transferred
   */
  function transferFrom(address from, address to, uint256 _tokenId) public {
    // check if transfers on behalf feature is enabled
    require(__isFeatureEnabled(FEATURE_TRANSFERS_ON_BEHALF));

    // call sender gracefully - `operator`
    address operator = msg.sender;

    // find if an approved address exists for this token
    address approved = approvals[_tokenId];

    // we assume `from` is an owner of the token,
    // this will be explicitly checked in `__transfer`

    // fetch how much approvals left for an operator
    bool approvedOperator = approvedOperators[from][operator];

    // operator must have an approval to transfer this particular token
    // or operator must be approved to transfer all the tokens
    // or, if nothing satisfies, this is equal to regular transfer,
    // where `from` is basically a transaction sender and owner of the token
    if(operator != approved && !approvedOperator) {
      // transaction sender doesn't have any special permissions
      // we will treat him as a token owner and sender and try to perform
      // a regular transfer:
      // check `from` to be `operator` (transaction sender):
      require(from == operator);

      // additionally check if token transfers feature is enabled
      require(__isFeatureEnabled(FEATURE_TRANSFERS));
    }

    // delegate call to unsafe `__transfer`
    __transfer(from, to, _tokenId);
  }

  /**
   * @notice A.k.a "safe transfer a token on behalf"
   * @notice Transfers ownership rights of a token defined
   *      by the `tokenId` to a new owner specified by address `to`
   * @notice Allows transferring ownership rights by a trading operator
   *      on behalf of token owner. Allows building an exchange of tokens.
   * @dev Safely transfers the ownership of a given token ID to another address
   * @dev Requires the transaction sender to be the owner, approved, or operator
   * @dev When transfer is complete, this function
   *      checks if `_to` is a smart contract (code size > 0). If so, it calls
   *      `onERC721Received` on `_to` and throws if the return value is not
   *      `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the token
   * @param _tokenId ID of the token to be transferred
   * @param _data Additional data with no specified format, sent in call to `_to`
   */
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public {
    // delegate call to usual (unsafe) `transferFrom`
    transferFrom(_from, _to, _tokenId);

    // check if receiver `_to` supports ERC721 interface
    if (AddressUtils.isContract(_to)) {
      // if `_to` is a contract – execute onERC721Received
      bytes4 response = ERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);

      // expected response is ERC721_RECEIVED
      require(response == ERC721_RECEIVED);
    }
  }

  /**
   * @notice A.k.a "safe transfer a token on behalf"
   * @notice Transfers ownership rights of a token defined
   *      by the `tokenId` to a new owner specified by address `to`
   * @notice Allows transferring ownership rights by a trading operator
   *      on behalf of token owner. Allows building an exchange of tokens.
   * @dev Safely transfers the ownership of a given token ID to another address
   * @dev Requires the transaction sender to be the owner, approved, or operator
   * @dev Requires from to be an owner of the token
   * @dev If the target address is a contract, it must implement `onERC721Received`,
   *      which is called upon a safe transfer, and return the magic value
   *      `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`;
   *      otherwise the transfer is reverted.
   * @dev This works identically to the other function with an extra data parameter,
   *      except this function just sets data to "".
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the token
   * @param _tokenId ID of the token to be transferred
   */
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {
    // delegate call to overloaded `safeTransferFrom`, set data to ""
    safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
   * @notice Approves an address to transfer the given token on behalf of its owner
   *      Can also be used to revoke an approval by setting `to` address to zero
   * @dev The zero `to` address revokes an approval for a given token
   * @dev There can only be one approved address per token at a given time
   * @dev This function can only be called by the token owner
   * @param _approved address to be approved to transfer the token on behalf of its owner
   * @param _tokenId ID of the token to be approved for transfer on behalf
   */
  function approve(address _approved, uint256 _tokenId) public {
    // call sender nicely - `from`
    address from = msg.sender;

    // get token owner address (also ensures that token exists)
    address owner = ownerOf(_tokenId);

    // caller must own this token
    require(from == owner);
    // approval for owner himself is pointless, do not allow
    require(_approved != owner);
    // either we're removing approval, or setting it
    require(approvals[_tokenId] != address(0) || _approved != address(0));

    // set an approval (deletes an approval if to == 0)
    approvals[_tokenId] = _approved;

    // emit an ERC721 event
    emit Approval(from, _approved, _tokenId);
  }

  /**
   * @notice Removes an approved address, which was previously added by `approve`
   *      for the given token. Equivalent to calling approve(0, tokenId)
   * @dev Same as calling approve(0, tokenId)
   * @param _tokenId ID of the token to remove approved address for
   */
  function revokeApproval(uint256 _tokenId) public {
    // delegate call to `approve`
    approve(address(0), _tokenId);
  }

  /**
   * @dev Sets or unsets the approval of a given operator
   * @dev An operator is allowed to transfer *all* tokens of the sender on their behalf
   * @param to operator address to set the approval for
   * @param approved representing the status of the approval to be set
   */
  function setApprovalForAll(address to, bool approved) public {
    // call sender nicely - `from`
    address from = msg.sender;

    // validate destination address
    require(to != address(0));

    // approval for owner himself is pointless, do not allow
    require(to != from);

    // set an approval
    approvedOperators[from][to] = approved;

    // emit an ERC721 compliant event
    emit ApprovalForAll(from, to, approved);
  }

  /**
   * @notice Get the approved address for a single token
   * @dev Throws if `_tokenId` is not a valid token ID.
   * @param _tokenId ID of the token to find the approved address for
   * @return the approved address for this token, or the zero address if there is none
   */
  function getApproved(uint256 _tokenId) public constant returns (address) {
    // validate token existence
    require(exists(_tokenId));

    // find approved address and return
    return approvals[_tokenId];
  }

  /**
   * @notice Query if an address is an authorized operator for another address
   * @param _owner the address that owns at least one token
   * @param _operator the address that acts on behalf of the owner
   * @return true if `_operator` is an approved operator for `_owner`, false otherwise
   */
  function isApprovedForAll(address _owner, address _operator) public constant returns (bool) {
    // is there a positive amount of approvals left
    return approvedOperators[_owner][_operator];
  }

  /**
   * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
   * @dev Throws if `_tokenId` is not a valid token ID.
   *      URIs are defined in RFC 3986.
   * @param _tokenId uint256 ID of the token to query
   * @return token URI
   */
  function tokenURI(uint256 _tokenId) public constant returns (string) {
    // validate token existence
    require(exists(_tokenId));

    // token URL consists of base URL part (domain) and token ID
    return StringUtils.concat("http://cryptominerworld.com/gem/", StringUtils.itoa(_tokenId, 16));
  }

  /// @dev Creates new token with `tokenId` ID specified and
  ///      assigns an ownership `to` for this token
  /// @dev Unsafe: doesn't check if caller has enough permissions to execute the call
  ///      checks only that the token doesn't exist yet
  /// @dev Must be kept private at all times
  function __mint(
    address to,
    uint32 tokenId,
    uint32 plotId,
    uint16 depth,
    uint16 gemNum,
    uint8 color,
    uint8 level,
    uint8 gradeType,
    uint24 gradeValue
  ) private {
    // check that `tokenId` is inside valid bounds
    require(tokenId > 0);

    // ensure that token with such ID doesn't exist
    require(!exists(tokenId));

    // create new gem in memory
    Gem memory gem = Gem({
      coordinates: uint64(plotId) << 32 | uint32(depth) << 16 | gemNum,
      color: color,
      levelModified: 0,
      level: level,
      gradeModified: 0,
      grade: uint32(gradeType) << 24 | gradeValue,
      stateModified: 0,
      state: 0,

      creationTime: uint32(block.number),
      // token index within the owner's collection of token
      // points to the place where the token will be placed to
      index: uint32(collections[to].length),
      ownershipModified: 0,
      owner: to
    });

    // push newly created `tokenId` to the owner's collection of tokens
    collections[to].push(tokenId);

    // persist gem to the storage
    gems[tokenId] = gem;

    // add token ID to the `allTokens` collection,
    // automatically updates total supply
    allTokens.push(tokenId);

    // fire Minted event
    emit Minted(msg.sender, to, tokenId);
    // fire ERC20/ERC721 transfer event
    emit Transfer(address(0), to, tokenId, 1);
  }

  /// @dev Performs a transfer of a token `tokenId` from address `from` to address `to`
  /// @dev Unsafe: doesn't check if caller has enough permissions to execute the call;
  ///      checks only for token existence and that ownership belongs to `from`
  /// @dev Is save to call from `transfer(to, tokenId)` since it doesn't need any additional checks
  /// @dev Must be kept private at all times
  function __transfer(address from, address to, uint256 _tokenId) private {
    // validate source and destination address
    require(to != address(0));
    require(to != from);
    // impossible by design of transfer(), transferFrom(),
    // approveToken() and approve()
    assert(from != address(0));

    // validate token existence
    require(exists(_tokenId));

    // validate token ownership
    require(ownerOf(_tokenId) == from);

    // transfer is not allowed for a locked gem
    // (ex.: if ge is currently mining)
    require(getState(_tokenId) & lockedBitmask == 0);

    // clear approved address for this particular token + emit event
    __clearApprovalFor(_tokenId);

    // move gem ownership,
    // update old and new owner's gem collections accordingly
    __move(from, to, _tokenId);

    // fire ERC20/ERC721 transfer event
    emit Transfer(from, to, _tokenId, 1);
  }

  /// @dev Clears approved address for a particular token
  function __clearApprovalFor(uint256 _tokenId) private {
    // check if approval exists - we don't want to fire an event in vain
    if(approvals[_tokenId] != address(0)) {
      // clear approval
      delete approvals[_tokenId];

      // emit an ERC721 event
      emit Approval(msg.sender, address(0), _tokenId);
    }
  }

  /// @dev Move a `gem` from owner `from` to a new owner `to`
  /// @dev Unsafe, doesn't check for consistence
  /// @dev Must be kept private at all times
  function __move(address from, address to, uint256 _tokenId) private {
    // cast token ID to uint32 space
    uint32 tokenId = uint32(_tokenId);

    // overflow check, failure impossible by design of mint()
    assert(tokenId == _tokenId);

    // get the gem pointer to the storage
    Gem storage gem = gems[_tokenId];

    // get a reference to the collection where gem is now
    uint32[] storage source = collections[from];

    // get a reference to the collection where gem goes to
    uint32[] storage destination = collections[to];

    // collection `source` cannot be empty, if it is - it's a bug
    assert(source.length != 0);

    // index of the gem within collection `source`
    uint32 i = gem.index;

    // we put the last gem in the collection `source` to the position released
    // get an ID of the last gem in `source`
    uint32 sourceId = source[source.length - 1];

    // update gem index to point to proper place in the collection `source`
    gems[sourceId].index = i;

    // put it into the position i within `source`
    source[i] = sourceId;

    // trim the collection `source` by removing last element
    source.length--;

    // update gem index according to position in new collection `destination`
    gem.index = uint32(destination.length);

    // update gem owner
    gem.owner = to;

    // update ownership transfer date
    gem.ownershipModified = uint32(block.number);

    // push gem into collection
    destination.push(tokenId);
  }

}