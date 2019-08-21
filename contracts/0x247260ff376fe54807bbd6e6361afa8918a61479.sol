pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
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
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
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

/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 * See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage _role, address _addr)
    internal
    view
  {
    require(has(_role, _addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage _role, address _addr)
    internal
    view
    returns (bool)
  {
    return _role.bearer[_addr];
  }
}

/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 * Supports unlimited numbers of roles and addresses.
 * See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 * for you to write your own implementation of this interface using Enums or similar.
 */
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);

  /**
   * @dev reverts if addr does not have role
   * @param _operator address
   * @param _role the name of the role
   * // reverts
   */
  function checkRole(address _operator, string _role)
    public
    view
  {
    roles[_role].check(_operator);
  }

  /**
   * @dev determine if addr has role
   * @param _operator address
   * @param _role the name of the role
   * @return bool
   */
  function hasRole(address _operator, string _role)
    public
    view
    returns (bool)
  {
    return roles[_role].has(_operator);
  }

  /**
   * @dev add a role to an address
   * @param _operator address
   * @param _role the name of the role
   */
  function addRole(address _operator, string _role)
    internal
  {
    roles[_role].add(_operator);
    emit RoleAdded(_operator, _role);
  }

  /**
   * @dev remove a role from an address
   * @param _operator address
   * @param _role the name of the role
   */
  function removeRole(address _operator, string _role)
    internal
  {
    roles[_role].remove(_operator);
    emit RoleRemoved(_operator, _role);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param _role the name of the role
   * // reverts
   */
  modifier onlyRole(string _role)
  {
    checkRole(msg.sender, _role);
    _;
  }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param _roles the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] _roles) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < _roles.length; i++) {
  //         if (hasRole(msg.sender, _roles[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
}
contract RBACOperator is Ownable, RBAC{

  /**
   * A constant role name for indicating operator.
   */
  string public constant ROLE_OPERATOR = "operator";

  /**
   * @dev the modifier to operate
   */
  modifier hasOperationPermission() {
    checkRole(msg.sender, ROLE_OPERATOR);
    _;
  }

  /**
   * @dev add a operator role to an address
   * @param _operator address
   */
  function addOperater(address _operator) public onlyOwner {
    addRole(_operator, ROLE_OPERATOR);
  }

  /**
   * @dev remove a operator role from an address
   * @param _operator address
   */
  function removeOperater(address _operator) public onlyOwner {
    removeRole(_operator, ROLE_OPERATOR);
  }
}


contract IncentivePoolContract is Ownable, RBACOperator{
  using SafeMath for uint256;
  uint256 public openingTime;


  /**
   * @dev Overridden seOpeningTimed, takes pool opening  times.
   * @param _newOpeningTime opening time
   */
  function setOpeningTime(uint32 _newOpeningTime) public hasOperationPermission {
     require(_newOpeningTime > 0);
     openingTime = _newOpeningTime;
  }


  /*
   * @dev get the incentive number
   * @return yearSum The total amount of tokens released in the current year
   * @return daySum The total number of tokens released on the day
   * @return currentYear Current year number
   */
  function getIncentiveNum() public view returns(uint256 yearSum, uint256 daySum, uint256 currentYear) {
    require(openingTime > 0 && openingTime < now);
    (yearSum, daySum, currentYear) = getIncentiveNumByTime(now);
  }



  /*
   * @dev get the incentive number
   * @param _time The time to get incentives for
   * @return yearSum The total amount of tokens released in the current year
   * @return daySum The total number of tokens released on the day
   * @return currentYear Current year number
   */
  function getIncentiveNumByTime(uint256 _time) public view returns(uint256 yearSum, uint256 daySum, uint256 currentYear) {
    require(openingTime > 0 && _time > openingTime);
    uint256 timeSpend = _time - openingTime;
    uint256 tempYear = timeSpend / 31536000;
    if (tempYear == 0) {
      yearSum = 2400000000000000000000000000;
      daySum = 6575342000000000000000000;
      currentYear = 1;
    } else if (tempYear == 1) {
      yearSum = 1080000000000000000000000000;
      daySum = 2958904000000000000000000;
      currentYear = 2;
    } else if (tempYear == 2) {
      yearSum = 504000000000000000000000000;
      daySum = 1380821000000000000000000;
      currentYear = 3;
    } else {
      uint256 year = tempYear - 3;
      uint256 d = 9 ** year;
      uint256 e = uint256(201600000000000000000000000).mul(d);
      uint256 f = 10 ** year;
      uint256 y2 = e.div(f);

      yearSum = y2;
      daySum = y2 / 365;
      currentYear = tempYear+1;
    }
  }
}