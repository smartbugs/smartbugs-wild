pragma solidity 0.4.24;

// File: contracts/lib/openzeppelin-solidity/contracts/access/Roles.sol

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
    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
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

// File: contracts/lib/openzeppelin-solidity/contracts/access/roles/PauserRole.sol

contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() public {
    pausers.add(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function renouncePauser() public {
    pausers.remove(msg.sender);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}

// File: contracts/lib/openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
  event Paused();
  event Unpaused();

  bool private _paused = false;


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
    emit Paused();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused();
  }
}

// File: contracts/lib/openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: contracts/lib/openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;


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
    _owner = msg.sender;
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
    emit OwnershipRenounced(_owner);
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

// File: contracts/access/roles/ReferrerRole.sol

contract ReferrerRole is Ownable {
    using Roles for Roles.Role;

    event ReferrerAdded(address indexed account);
    event ReferrerRemoved(address indexed account);

    Roles.Role private referrers;

    constructor() public {
        referrers.add(msg.sender);
    }

    modifier onlyReferrer() {
        require(isReferrer(msg.sender));
        _;
    }
    
    function isReferrer(address account) public view returns (bool) {
        return referrers.has(account);
    }

    function addReferrer(address account) public onlyOwner() {
        referrers.add(account);
        emit ReferrerAdded(account);
    }

    function removeReferrer(address account) public onlyOwner() {
        referrers.remove(account);
        emit ReferrerRemoved(account);
    }

}

// File: contracts/shop/DailyAction.sol

contract DailyAction is Ownable, Pausable {
    using SafeMath for uint256;

    mapping(address => uint256) public latestActionTime;
    uint256 public term;

    event Action(
        address indexed user,
        address indexed referrer,
        uint256 at
    );

    event UpdateTerm(
        uint256 term
    );
    
    constructor() public {
        term = 86400;
    }

    function withdrawEther() external onlyOwner() {
        owner().transfer(address(this).balance);
    }

    function updateTerm(uint256 num) external onlyOwner() {
        term = num;

        emit UpdateTerm(
            term
        );
    }

    function requestDailyActionReward(address referrer) external whenNotPaused() {
        require(!isInTerm(msg.sender), "this sender got daily reward within term");

        emit Action(
            msg.sender,
            referrer,
            block.timestamp
        );

        latestActionTime[msg.sender] = block.timestamp;
    }

    function isInTerm(address sender) public view returns (bool) {
        if (latestActionTime[sender] == 0) {
            return false;
        } else if (block.timestamp >= latestActionTime[sender].add(term)) {
            return false;
        }
        return true;
    }
}

// File: contracts/shop/GumGateway.sol

contract GumGateway is ReferrerRole, Pausable, DailyAction {
    using SafeMath for uint256;

    uint256 internal ethBackRate;
    uint256 internal minimumAmount;

    event Sold(
        address indexed user,
        address indexed referrer,
        uint256 value,
        uint256 at
    );
    
    constructor() public {
        minimumAmount = 10000000000000000;
    }
    
    function updateEthBackRate(uint256 _newEthBackRate) external onlyOwner() {
        ethBackRate = _newEthBackRate;
    }

    function updateMinimumAmount(uint256 _newMinimumAmount) external onlyOwner() {
        minimumAmount = _newMinimumAmount;
    }

    function getEthBackRate() external onlyOwner() view returns (uint256) {
        return ethBackRate;
    }

    function withdrawEther() external onlyOwner() {
        owner().transfer(address(this).balance);
    }

    function buy(address _referrer) external payable whenNotPaused() {
        require(msg.value >= minimumAmount, "msg.value should be more than minimum ether amount");
        
        address referrer;
        if (_referrer == msg.sender){
            referrer = address(0x0);
        } else {
            referrer = _referrer;
        }
        if ((referrer != address(0x0)) && isReferrer(referrer)) {
            referrer.transfer(msg.value.mul(ethBackRate).div(100));
        }
        emit Sold(
            msg.sender,
            referrer,
            msg.value,
            block.timestamp
        );
    }

}