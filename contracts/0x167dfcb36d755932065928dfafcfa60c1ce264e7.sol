pragma solidity ^0.4.24;

// File: node_modules/openzeppelin-solidity/contracts/access/Roles.sol

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

// File: node_modules/openzeppelin-solidity/contracts/access/roles/PauserRole.sol

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

// File: node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol

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

// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: contracts/IGrowHops.sol

interface IGrowHops {

  function addPlanBase(uint256 minimumAmount, uint256 lockTime, uint32 lessToHops) external;

  function togglePlanBase(bytes32 planBaseId, bool isOpen) external;

  function growHops(bytes32 planBaseId, uint256 lessAmount) external;

  function updateHopsAddress(address _address) external;

  function updatelessAddress(address _address) external;

  function withdraw(bytes32 planId) external;

  function checkPlanBase(bytes32 planBaseId)
    external view returns (uint256, uint256, uint32, bool);
  
  function checkPlanBaseIds() external view returns(bytes32[]);

  function checkPlanIdsByPlanBase(bytes32 planBaseId) external view returns(bytes32[]);

  function checkPlanIdsByUser(address user) external view returns(bytes32[]);

  function checkPlan(bytes32 planId)
    external view returns (bytes32, address, uint256, uint256, uint256, uint256, bool);

  /* Events */

  event PlanBaseEvt (
    bytes32 planBaseId,
    uint256 minimumAmount,
    uint256 lockTime,
    uint32 lessToHops,
    bool isOpen
  );

  event TogglePlanBaseEvt (
    bytes32 planBaseId,
    bool isOpen
  );

  event PlanEvt (
    bytes32 planId,
    bytes32 planBaseId,
    address plantuser,
    uint256 lessAmount,
    uint256 hopsAmount,
    uint256 lockAt,
    uint256 releaseAt,
    bool isWithdrawn
  );

  event WithdrawPlanEvt (
    bytes32 planId,
    address plantuser,
    uint256 lessAmount,
    bool isWithdrawn,
    uint256 withdrawAt
  );

}

// File: contracts/SafeMath.sol

/**
 * @title SafeMath
 */
library SafeMath {
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
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) 
      internal 
      pure 
      returns (uint256 c) 
  {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    require(c / a == b, "SafeMath mul failed");
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b)
      internal
      pure
      returns (uint256) 
  {
    require(b <= a, "SafeMath sub failed");
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b)
      internal
      pure
      returns (uint256 c) 
  {
    c = a + b;
    require(c >= a, "SafeMath add failed");
    return c;
  }
  
  /**
    * @dev gives square root of given x.
    */
  function sqrt(uint256 x)
      internal
      pure
      returns (uint256 y) 
  {
    uint256 z = ((add(x,1)) / 2);
    y = x;
    while (z < y) 
    {
      y = z;
      z = ((add((x / z),z)) / 2);
    }
  }
  
  /**
    * @dev gives square. batchplies x by x
    */
  function sq(uint256 x)
      internal
      pure
      returns (uint256)
  {
    return (mul(x,x));
  }
  
  /**
    * @dev x to the power of y 
    */
  function pwr(uint256 x, uint256 y)
      internal 
      pure 
      returns (uint256)
  {
    if (x==0)
        return (0);
    else if (y==0)
        return (1);
    else 
    {
      uint256 z = x;
      for (uint256 i=1; i < y; i++)
        z = mul(z,x);
      return (z);
    }
  }
}

// File: contracts/GrowHops.sol

interface IERC20 {
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function allowance(address tokenOwner, address spender) external view returns (uint);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function balanceOf(address who) external view returns (uint256);
  function mint(address to, uint256 value) external returns (bool);
}

contract GrowHops is IGrowHops, Ownable, Pausable {

  using SafeMath for *;

  address public hopsAddress;
  address public lessAddress;

  struct PlanBase {
    uint256 minimumAmount;
    uint256 lockTime;
    uint32 lessToHops;
    bool isOpen;
  }

  struct Plan {
    bytes32 planBaseId;
    address plantuser;
    uint256 lessAmount;
    uint256 hopsAmount;
    uint256 lockAt;
    uint256 releaseAt;
    bool isWithdrawn;
  }
  bytes32[] public planBaseIds;

  mapping (bytes32 => bytes32[]) planIdsByPlanBase;
  mapping (bytes32 => PlanBase) planBaseIdToPlanBase;
  
  mapping (bytes32 => Plan) planIdToPlan;
  mapping (address => bytes32[]) userToPlanIds;

  constructor (address _hopsAddress, address _lessAddress) public {
    hopsAddress = _hopsAddress;
    lessAddress = _lessAddress;
  }

  function addPlanBase(uint256 minimumAmount, uint256 lockTime, uint32 lessToHops)
    onlyOwner external {
    bytes32 planBaseId = keccak256(
      abi.encodePacked(block.timestamp, minimumAmount, lockTime, lessToHops)
    );

    PlanBase memory planBase = PlanBase(
      minimumAmount,
      lockTime,
      lessToHops,
      true
    );

    planBaseIdToPlanBase[planBaseId] = planBase;
    planBaseIds.push(planBaseId);
    emit PlanBaseEvt(planBaseId, minimumAmount, lockTime, lessToHops, true);
  }

  function togglePlanBase(bytes32 planBaseId, bool isOpen) onlyOwner external {

    planBaseIdToPlanBase[planBaseId].isOpen = isOpen;
    emit TogglePlanBaseEvt(planBaseId, isOpen);
  }
  
  function growHops(bytes32 planBaseId, uint256 lessAmount) whenNotPaused external {
    address sender = msg.sender;
    require(IERC20(lessAddress).allowance(sender, address(this)) >= lessAmount);

    PlanBase storage planBase = planBaseIdToPlanBase[planBaseId];
    require(planBase.isOpen);
    require(lessAmount >= planBase.minimumAmount);
    bytes32 planId = keccak256(
      abi.encodePacked(block.timestamp, sender, planBaseId, lessAmount)
    );
    uint256 hopsAmount = lessAmount.mul(planBase.lessToHops);

    Plan memory plan = Plan(
      planBaseId,
      sender,
      lessAmount,
      hopsAmount,
      block.timestamp,
      block.timestamp.add(planBase.lockTime),
      false
    );
    
    require(IERC20(lessAddress).transferFrom(sender, address(this), lessAmount));
    require(IERC20(hopsAddress).mint(sender, hopsAmount));

    planIdToPlan[planId] = plan;
    userToPlanIds[sender].push(planId);
    planIdsByPlanBase[planBaseId].push(planId);
    emit PlanEvt(planId, planBaseId, sender, lessAmount, hopsAmount, block.timestamp, block.timestamp.add(planBase.lockTime), false);
  }

  function updateHopsAddress(address _address) external onlyOwner {
    hopsAddress = _address;
  }

  function updatelessAddress(address _address) external onlyOwner {
    lessAddress = _address;
  }

  function withdraw(bytes32 planId) whenNotPaused external {
    address sender = msg.sender;
    Plan storage plan = planIdToPlan[planId];
    require(!plan.isWithdrawn);
    require(plan.plantuser == sender);
    require(block.timestamp >= plan.releaseAt);
    require(IERC20(lessAddress).transfer(sender, plan.lessAmount));

    planIdToPlan[planId].isWithdrawn = true;
    emit WithdrawPlanEvt(planId, sender, plan.lessAmount, true, block.timestamp);
  }

  function checkPlanBase(bytes32 planBaseId)
    external view returns (uint256, uint256, uint32, bool){
    PlanBase storage planBase = planBaseIdToPlanBase[planBaseId];
    return (
      planBase.minimumAmount,
      planBase.lockTime,
      planBase.lessToHops,
      planBase.isOpen
    );
  }

  function checkPlanBaseIds() external view returns(bytes32[]) {
    return planBaseIds;
  }

  function checkPlanIdsByPlanBase(bytes32 planBaseId) external view returns(bytes32[]) {
    return planIdsByPlanBase[planBaseId];
  }

  function checkPlanIdsByUser(address user) external view returns(bytes32[]) {
    return userToPlanIds[user];
  }

  function checkPlan(bytes32 planId)
    external view returns (bytes32, address, uint256, uint256, uint256, uint256, bool) {
    Plan storage plan = planIdToPlan[planId];
    return (
      plan.planBaseId,
      plan.plantuser,
      plan.lessAmount,
      plan.hopsAmount,
      plan.lockAt,
      plan.releaseAt,
      plan.isWithdrawn
    );
  }
}