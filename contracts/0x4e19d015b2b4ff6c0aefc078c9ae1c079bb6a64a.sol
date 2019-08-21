/**
 * UserRegistry.sol
 * Mt Pelerin user registry.

 * The unflattened code is available through this github tag:
 * https://github.com/MtPelerin/MtPelerin-protocol/tree/etherscan-verify-batch-1

 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved

 * @notice All matters regarding the intellectual property of this code 
 * @notice or software are subject to Swiss Law without reference to its 
 * @notice conflicts of law rules.

 * @notice License for each contract is available in the respective file
 * @notice or in the LICENSE.md file.
 * @notice https://github.com/MtPelerin/

 * @notice Code by OpenZeppelin is copyrighted and licensed on their repository:
 * @notice https://github.com/OpenZeppelin/openzeppelin-solidity
 */

pragma solidity ^0.4.24;

// File: contracts/zeppelin/ownership/Ownable.sol

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

// File: contracts/Authority.sol

/**
 * @title Authority
 * @dev The Authority contract has an authority address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * Authority means to represent a legal entity that is entitled to specific rights
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 *
 * Error messages
 * AU01: Message sender must be an authority
 */
contract Authority is Ownable {

  address authority;

  /**
   * @dev Throws if called by any account other than the authority.
   */
  modifier onlyAuthority {
    require(msg.sender == authority, "AU01");
    _;
  }

  /**
   * @dev return the address associated to the authority
   */
  function authorityAddress() public view returns (address) {
    return authority;
  }

  /**
   * @dev rdefines an authority
   * @param _name the authority name
   * @param _address the authority address.
   */
  function defineAuthority(string _name, address _address) public onlyOwner {
    emit AuthorityDefined(_name, _address);
    authority = _address;
  }

  event AuthorityDefined(
    string name,
    address _address
  );
}

// File: contracts/interface/IRule.sol

/**
 * @title IRule
 * @dev IRule interface
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 **/
interface IRule {
  function isAddressValid(address _address) external view returns (bool);
  function isTransferValid(address _from, address _to, uint256 _amount)
    external view returns (bool);
}

// File: contracts/interface/IUserRegistry.sol

/**
 * @title IUserRegistry
 * @dev IUserRegistry interface
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 **/
contract IUserRegistry {

  function registerManyUsers(address[] _addresses, uint256 _validUntilTime)
    public;

  function attachManyAddresses(uint256[] _userIds, address[] _addresses)
    public;

  function detachManyAddresses(address[] _addresses)
    public;

  function userCount() public view returns (uint256);
  function userId(address _address) public view returns (uint256);
  function addressConfirmed(address _address) public view returns (bool);
  function validUntilTime(uint256 _userId) public view returns (uint256);
  function suspended(uint256 _userId) public view returns (bool);
  function extended(uint256 _userId, uint256 _key)
    public view returns (uint256);

  function isAddressValid(address _address) public view returns (bool);
  function isValid(uint256 _userId) public view returns (bool);

  function registerUser(address _address, uint256 _validUntilTime) public;
  function attachAddress(uint256 _userId, address _address) public;
  function confirmSelf() public;
  function detachAddress(address _address) public;
  function detachSelf() public;
  function detachSelfAddress(address _address) public;
  function suspendUser(uint256 _userId) public;
  function unsuspendUser(uint256 _userId) public;
  function suspendManyUsers(uint256[] _userIds) public;
  function unsuspendManyUsers(uint256[] _userIds) public;
  function updateUser(uint256 _userId, uint256 _validUntil, bool _suspended)
    public;

  function updateManyUsers(
    uint256[] _userIds,
    uint256 _validUntil,
    bool _suspended) public;

  function updateUserExtended(uint256 _userId, uint256 _key, uint256 _value)
    public;

  function updateManyUsersExtended(
    uint256[] _userIds,
    uint256 _key,
    uint256 _value) public;
}

// File: contracts/UserRegistry.sol

/**
 * @title UserRegistry
 * @dev UserRegistry contract
 * Configure and manage users
 * Extended may be used externaly to store data within a user context
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 *
 * Error messages
 * UR01: Users length does not match addresses length
 * UR02: UserId is invalid
 * UR03: WalletOwner is invalid
 * UR04: WalletOwner is already confirmed
 * UR05: User is already suspended
 * UR06: User is not suspended
*/
contract UserRegistry is IUserRegistry, Authority {

  struct User {
    uint256 validUntilTime;
    bool suspended;
    mapping(uint256 => uint256) extended;
  }
  struct WalletOwner {
    uint256 userId;
    bool confirmed;
  }

  mapping(uint256 => User) internal users;
  mapping(address => WalletOwner) internal walletOwners;
  uint256 public userCount;

  /**
   * @dev contructor
   **/
  constructor(address[] _addresses, uint256 _validUntilTime) public {
    for (uint256 i = 0; i < _addresses.length; i++) {
      registerUserInternal(_addresses[i], _validUntilTime);
      walletOwners[_addresses[i]].confirmed = true;
    }
  }

  /**
   * @dev register many users
   */
  function registerManyUsers(address[] _addresses, uint256 _validUntilTime)
    public onlyAuthority
  {
    for (uint256 i = 0; i < _addresses.length; i++) {
      registerUserInternal(_addresses[i], _validUntilTime);
    }
  }

  /**
   * @dev attach many addresses to many users
   */
  function attachManyAddresses(uint256[] _userIds, address[] _addresses)
    public onlyAuthority
  {
    require(_addresses.length == _userIds.length, "UR01");
    for (uint256 i = 0; i < _addresses.length; i++) {
      attachAddress(_userIds[i], _addresses[i]);
    }
  }

  /**
   * @dev detach many addresses association between addresses and their respective users
   */
  function detachManyAddresses(address[] _addresses) public onlyAuthority {
    for (uint256 i = 0; i < _addresses.length; i++) {
      detachAddress(_addresses[i]);
    }
  }

  /**
   * @dev number of user registred
   */
  function userCount() public view returns (uint256) {
    return userCount;
  }

  /**
   * @dev the userId associated to the provided address
   */
  function userId(address _address) public view returns (uint256) {
    return walletOwners[_address].userId;
  }

  /**
   * @dev the userId associated to the provided address if the user is valid
   */
  function validUserId(address _address) public view returns (uint256) {
    if (isAddressValid(_address)) {
      return walletOwners[_address].userId;
    }
    return 0;
  }

  /**
   * @dev the userId associated to the provided address
   */
  function addressConfirmed(address _address) public view returns (bool) {
    return walletOwners[_address].confirmed;
  }

  /**
   * @dev returns the time at which user validity ends
   */
  function validUntilTime(uint256 _userId) public view returns (uint256) {
    return users[_userId].validUntilTime;
  }

  /**
   * @dev is the user suspended
   */
  function suspended(uint256 _userId) public view returns (bool) {
    return users[_userId].suspended;
  }

  /**
   * @dev access to extended user data
   */
  function extended(uint256 _userId, uint256 _key)
    public view returns (uint256)
  {
    return users[_userId].extended[_key];
  }

  /**
   * @dev validity of the current user
   */
  function isAddressValid(address _address) public view returns (bool) {
    return walletOwners[_address].confirmed &&
      isValid(walletOwners[_address].userId);
  }

  /**
   * @dev validity of the current user
   */
  function isValid(uint256 _userId) public view returns (bool) {
    return isValidInternal(users[_userId]);
  }

  /**
   * @dev register a user
   */
  function registerUser(address _address, uint256 _validUntilTime)
    public onlyAuthority
  {
    registerUserInternal(_address, _validUntilTime);
  }

  /**
   * @dev register a user
   */
  function registerUserInternal(address _address, uint256 _validUntilTime)
    public
  {
    require(walletOwners[_address].userId == 0, "UR03");
    users[++userCount] = User(_validUntilTime, false);
    walletOwners[_address] = WalletOwner(userCount, false);
  }

  /**
   * @dev attach an address with a user
   */
  function attachAddress(uint256 _userId, address _address)
    public onlyAuthority
  {
    require(_userId > 0 && _userId <= userCount, "UR02");
    require(walletOwners[_address].userId == 0, "UR03");
    walletOwners[_address] = WalletOwner(_userId, false);
  }

  /**
   * @dev confirm the address by the user to activate it
   */
  function confirmSelf() public {
    require(walletOwners[msg.sender].userId != 0, "UR03");
    require(!walletOwners[msg.sender].confirmed, "UR04");
    walletOwners[msg.sender].confirmed = true;
  }

  /**
   * @dev detach the association between an address and its user
   */
  function detachAddress(address _address) public onlyAuthority {
    require(walletOwners[_address].userId != 0, "UR03");
    delete walletOwners[_address];
  }

  /**
   * @dev detach the association between an address and its user
   */
  function detachSelf() public {
    detachSelfAddress(msg.sender);
  }

  /**
   * @dev detach the association between an address and its user
   */
  function detachSelfAddress(address _address) public {
    uint256 senderUserId = walletOwners[msg.sender].userId;
    require(senderUserId != 0, "UR03");
    require(walletOwners[_address].userId == senderUserId, "UR06");
    delete walletOwners[_address];
  }

  /**
   * @dev suspend a user
   */
  function suspendUser(uint256 _userId) public onlyAuthority {
    require(_userId > 0 && _userId <= userCount, "UR02");
    require(!users[_userId].suspended, "UR06");
    users[_userId].suspended = true;
  }

  /**
   * @dev unsuspend a user
   */
  function unsuspendUser(uint256 _userId) public onlyAuthority {
    require(_userId > 0 && _userId <= userCount, "UR02");
    require(users[_userId].suspended, "UR06");
    users[_userId].suspended = false;
  }

  /**
   * @dev suspend many users
   */
  function suspendManyUsers(uint256[] _userIds) public onlyAuthority {
    for (uint256 i = 0; i < _userIds.length; i++) {
      suspendUser(_userIds[i]);
    }
  }

  /**
   * @dev unsuspend many users
   */
  function unsuspendManyUsers(uint256[] _userIds) public onlyAuthority {
    for (uint256 i = 0; i < _userIds.length; i++) {
      unsuspendUser(_userIds[i]);
    }
  }

  /**
   * @dev update a user
   */
  function updateUser(
    uint256 _userId,
    uint256 _validUntilTime,
    bool _suspended) public onlyAuthority
  {
    require(_userId > 0 && _userId <= userCount, "UR02");
    users[_userId].validUntilTime = _validUntilTime;
    users[_userId].suspended = _suspended;
  }

  /**
   * @dev update many users
   */
  function updateManyUsers(
    uint256[] _userIds,
    uint256 _validUntilTime,
    bool _suspended) public onlyAuthority
  {
    for (uint256 i = 0; i < _userIds.length; i++) {
      updateUser(_userIds[i], _validUntilTime, _suspended);
    }
  }

  /**
   * @dev update user extended information
   */
  function updateUserExtended(uint256 _userId, uint256 _key, uint256 _value)
    public onlyAuthority
  {
    require(_userId > 0 && _userId <= userCount, "UR02");
    users[_userId].extended[_key] = _value;
  }

  /**
   * @dev update many users' extended information
   */
  function updateManyUsersExtended(
    uint256[] _userIds,
    uint256 _key,
    uint256 _value) public onlyAuthority
  {
    for (uint256 i = 0; i < _userIds.length; i++) {
      updateUserExtended(_userIds[i], _key, _value);
    }
  }

  /**
   * @dev validity of the current user
   */
  function isValidInternal(User user) internal view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return !user.suspended && user.validUntilTime > now;
  }
}