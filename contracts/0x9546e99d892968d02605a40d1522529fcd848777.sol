pragma solidity ^0.4.24;

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
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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

contract CardioCoin is ERC20Basic, Ownable, RBAC {
    string public constant ROLE_NEED_LOCK_UP = "need_lock_up";

    using SafeMath for uint256;

    uint public constant RESELLING_LOCKUP_PERIOD = 210 days;
    uint public constant PRE_PUBLIC_LOCKUP_PERIOD = 180 days;
    uint public constant UNLOCK_TEN_PERCENT_PERIOD = 30 days;

    string public name = "CardioCoin";
    string public symbol = "CRDC";

    uint8 public decimals = 18;
    uint256 internal totalSupply_ = 50000000000 * (10 ** uint256(decimals));

    mapping (address => uint256) internal reselling;
    uint256 internal resellingAmount = 0;

    event ResellingAdded(address seller, uint256 amount);
    event ResellingSubtracted(address seller, uint256 amount);
    event Reselled(address seller, address buyer, uint256 amount);

    event TokenLocked(address owner, uint256 amount);
    event TokenUnlocked(address owner, uint256 amount);

    constructor() public Ownable() {
        balance memory b;

        b.available = totalSupply_;
        balances[msg.sender] = b;
    }

    function addLockedUpTokens(address _owner, uint256 amount, uint lockupPeriod)
    internal {
        balance storage b = balances[_owner];
        lockup memory l;

        l.amount = amount;
        l.unlockTimestamp = now + lockupPeriod;
        b.lockedUp += amount;
        b.lockUpData[b.lockUpCount] = l;
        b.lockUpCount += 1;
        emit TokenLocked(_owner, amount);
    }

    // 리셀링 등록

    function addResellingAmount(address seller, uint256 amount)
    public
    onlyOwner
    {
        require(seller != address(0));
        require(amount > 0);
        require(balances[seller].available >= amount);

        reselling[seller] = reselling[seller].add(amount);
        balances[seller].available = balances[seller].available.sub(amount);
        resellingAmount = resellingAmount.add(amount);
        emit ResellingAdded(seller, amount);
    }

    function subtractResellingAmount(address seller, uint256 _amount)
    public
    onlyOwner
    {
        uint256 amount = reselling[seller];

        require(seller != address(0));
        require(_amount > 0);
        require(amount >= _amount);

        reselling[seller] = reselling[seller].sub(_amount);
        resellingAmount = resellingAmount.sub(_amount);
        balances[seller].available = balances[seller].available.add(_amount);
        emit ResellingSubtracted(seller, _amount);
    }

    function cancelReselling(address seller)
    public
    onlyOwner {
        uint256 amount = reselling[seller];

        require(seller != address(0));
        require(amount > 0);

        subtractResellingAmount(seller, amount);
    }

    function resell(address seller, address buyer, uint256 amount)
    public
    onlyOwner
    returns (bool)
    {
        require(seller != address(0));
        require(buyer != address(0));
        require(amount > 0);
        require(reselling[seller] >= amount);
        require(balances[owner].available >= amount);

        reselling[seller] = reselling[seller].sub(amount);
        resellingAmount = resellingAmount.sub(amount);

        addLockedUpTokens(buyer, amount, RESELLING_LOCKUP_PERIOD);
        emit Reselled(seller, buyer, amount);

        return true;
    }

    // BasicToken

    struct lockup {
        uint256 amount;
        uint unlockTimestamp;
        uint unlockCount;
    }

    struct balance {
        uint256 available;
        uint256 lockedUp;
        mapping (uint => lockup) lockUpData;
        uint lockUpCount;
        uint unlockIndex;
    }

    mapping(address => balance) internal balances;

    function unlockBalance(address _owner) internal {
        balance storage b = balances[_owner];

        if (b.lockUpCount > 0 && b.unlockIndex < b.lockUpCount) {
            for (uint i = b.unlockIndex; i < b.lockUpCount; i++) {
                lockup storage l = b.lockUpData[i];

                if (l.unlockTimestamp <= now) {
                    uint count = unlockCount(l.unlockTimestamp, l.unlockCount);
                    uint256 unlockedAmount = l.amount.mul(count).div(10);

                    if (unlockedAmount > b.lockedUp) {
                        unlockedAmount = b.lockedUp;
                        l.unlockCount = 10;
                    } else {
                        b.available = b.available.add(unlockedAmount);
                        b.lockedUp = b.lockedUp.sub(unlockedAmount);
                        l.unlockCount += count;
                    }
                    emit TokenUnlocked(_owner, unlockedAmount);
                    if (l.unlockCount == 10) {
                        lockup memory tempA = b.lockUpData[i];
                        lockup memory tempB = b.lockUpData[b.unlockIndex];

                        b.lockUpData[i] = tempB;
                        b.lockUpData[b.unlockIndex] = tempA;
                        b.unlockIndex += 1;
                    } else {
                        l.unlockTimestamp += UNLOCK_TEN_PERCENT_PERIOD * count;
                    }
                }
            }
        }
    }

    function unlockCount(uint timestamp, uint _unlockCount) view internal returns (uint) {
        uint count = 0;
        uint nowFixed = now;

        while (timestamp < nowFixed && _unlockCount + count < 10) {
            count++;
            timestamp += UNLOCK_TEN_PERCENT_PERIOD;
        }

        return count;
    }

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value)
    public
    returns (bool) {
        unlockBalance(msg.sender);
        if (hasRole(msg.sender, ROLE_NEED_LOCK_UP)) {
            require(_value <= balances[msg.sender].available);
            require(_to != address(0));

            balances[msg.sender].available = balances[msg.sender].available.sub(_value);
            addLockedUpTokens(_to, _value, RESELLING_LOCKUP_PERIOD);
        } else {
            require(_value <= balances[msg.sender].available);
            require(_to != address(0));

            balances[msg.sender].available = balances[msg.sender].available.sub(_value);
            balances[_to].available = balances[_to].available.add(_value);
        }
        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner].available.add(balances[_owner].lockedUp);
    }

    function lockedUpBalanceOf(address _owner) public view returns (uint256) {
        return balances[_owner].lockedUp;
    }

    function resellingBalanceOf(address _owner) public view returns (uint256) {
        return reselling[_owner];
    }

    function refreshLockUpStatus()
    public
    {
        unlockBalance(msg.sender);
    }

    function transferWithLockUp(address _to, uint256 _value)
    public
    onlyOwner
    returns (bool) {
        require(_value <= balances[owner].available);
        require(_to != address(0));

        balances[owner].available = balances[owner].available.sub(_value);
        addLockedUpTokens(_to, _value, PRE_PUBLIC_LOCKUP_PERIOD);
        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    // Burnable

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who].available);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[_who].available = balances[_who].available.sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
    }

    // 리셀러 락업

    function addAddressToNeedLockUpList(address _operator)
    public
    onlyOwner {
        addRole(_operator, ROLE_NEED_LOCK_UP);
    }

    function removeAddressToNeedLockUpList(address _operator)
    public
    onlyOwner {
        removeRole(_operator, ROLE_NEED_LOCK_UP);
    }
}