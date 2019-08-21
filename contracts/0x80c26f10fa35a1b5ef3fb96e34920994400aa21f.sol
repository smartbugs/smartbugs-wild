/**
 * LockRule.sol
 * Rule to lock all tokens on a schedule and define a whitelist of exceptions.

 * More info about MPS : https://github.com/MtPelerin/MtPelerin-share-MPS

 * The unflattened code is available through this github tag:
 * https://github.com/MtPelerin/MtPelerin-protocol/tree/etherscan-verify-batch-2

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
   * @dev Returns the address associated to the authority
   */
  function authorityAddress() public view returns (address) {
    return authority;
  }

  /** Define an address as authority, with an arbitrary name included in the event
   * @dev returns the authority of the
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

// File: contracts/rule/LockRule.sol

/**
 * @title LockRule
 * @dev LockRule contract
 * This rule allow to lock assets for a period of time
 * for event such as investment vesting
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 *
 * Error messages
 * LOR01: definePass() call have failed
 * LOR02: startAt must be before or equal to endAt
 */
contract LockRule is IRule, Authority {

  enum Direction {
    NONE,
    RECEIVE,
    SEND,
    BOTH
  }

  struct ScheduledLock {
    Direction restriction;
    uint256 startAt;
    uint256 endAt;
    bool scheduleInverted;
  }

  mapping(address => Direction) individualPasses;
  ScheduledLock lock = ScheduledLock(
    Direction.NONE,
    0,
    0,
    false
  );

  /**
   * @dev hasSendDirection
   */
  function hasSendDirection(Direction _direction) public pure returns (bool) {
    return _direction == Direction.SEND || _direction == Direction.BOTH;
  }

  /**
   * @dev hasReceiveDirection
   */
  function hasReceiveDirection(Direction _direction)
    public pure returns (bool)
  {
    return _direction == Direction.RECEIVE || _direction == Direction.BOTH;
  }

  /**
   * @dev restriction
   */
  function restriction() public view returns (Direction) {
    return lock.restriction;
  }

  /**
   * @dev scheduledStartAt
   */
  function scheduledStartAt() public view returns (uint256) {
    return lock.startAt;
  }

  /**
   * @dev scheduledEndAt
   */
  function scheduledEndAt() public view returns (uint256) {
    return lock.endAt;
  }

  /**
   * @dev lock inverted
   */
  function isScheduleInverted() public view returns (bool) {
    return lock.scheduleInverted;
  }

  /**
   * @dev isLocked
   */
  function isLocked() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return (lock.startAt <= now && lock.endAt > now)
      ? !lock.scheduleInverted : lock.scheduleInverted;
  }

  /**
   * @dev individualPass
   */
  function individualPass(address _address)
    public view returns (Direction)
  {
    return individualPasses[_address];
  }

  /**
   * @dev can the address send
   */
  function canSend(address _address) public view returns (bool) {
    if (isLocked() && hasSendDirection(lock.restriction)) {
      return hasSendDirection(individualPasses[_address]);
    }
    return true;
  }

  /**
   * @dev can the address receive
   */
  function canReceive(address _address) public view returns (bool) {
    if (isLocked() && hasReceiveDirection(lock.restriction)) {
      return hasReceiveDirection(individualPasses[_address]);
    }
    return true;
  }

  /**
   * @dev allow authority to provide a pass to an address
   */
  function definePass(address _address, uint256 _lock)
    public onlyAuthority returns (bool)
  {
    individualPasses[_address] = Direction(_lock);
    emit PassDefinition(_address, Direction(_lock));
    return true;
  }

  /**
   * @dev allow authority to provide addresses with lock passes
   */
  function defineManyPasses(address[] _addresses, uint256 _lock)
    public onlyAuthority returns (bool)
  {
    for (uint256 i = 0; i < _addresses.length; i++) {
      require(definePass(_addresses[i], _lock), "LOR01");
    }
    return true;
  }

  /**
   * @dev schedule lock
   */
  function scheduleLock(
    Direction _restriction,
    uint256 _startAt, uint256 _endAt, bool _scheduleInverted)
    public onlyAuthority returns (bool)
  {
    require(_startAt <= _endAt, "LOR02");
    lock = ScheduledLock(
      _restriction,
      _startAt,
      _endAt,
      _scheduleInverted
    );
    emit LockDefinition(
      lock.restriction, lock.startAt, lock.endAt, lock.scheduleInverted);
  }

  /**
   * @dev validates an address
   */
  function isAddressValid(address /*_address*/) public view returns (bool) {
    return true;
  }

  /**
   * @dev validates a transfer of ownership
   */
  function isTransferValid(address _from, address _to, uint256 /* _amount */)
    public view returns (bool)
  {
    return (canSend(_from) && canReceive(_to));
  }

  event LockDefinition(
    Direction restriction,
    uint256 startAt,
    uint256 endAt,
    bool scheduleInverted
  );
  event PassDefinition(address _address, Direction pass);
}