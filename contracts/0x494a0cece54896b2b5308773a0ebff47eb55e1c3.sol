pragma solidity 0.4.24;

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

contract owned {
    address public owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


contract ERC20 {
    function totalSupply() public view returns (uint256);

    function balanceOf(address _who) public view returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );
}


contract StandardToken is ERC20 {
    using SafeMath for uint256;

    mapping(address => uint256) internal balances;

    uint256 internal totalSupply_;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /**
     * @dev Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_value <= balances[msg.sender]);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}


contract ioeXTokenERC20 is StandardToken, owned {
    using SafeMath for uint256;

    // Public variables of the token
    bytes internal name_ = "Internet of Everything X";

    bytes internal symbol_ = "IOEX";

    uint256 public decimals = 8;

    uint256 private constant LOCK_TYPE_MAX = 3;
    uint256 private constant LOCK_STAGE_MAX = 4;

    mapping (address => bool) public frozenAccount;

    //Save lock type and amount of init tokens
    struct StructLockAccountInfo {
        uint256 lockType;
        uint256 initBalance;
        uint256 startTime;
    }

    mapping (address => StructLockAccountInfo) public lockAccountInfo;
 
    //Save 4 set of time and percent of unlocked tokens
    struct StructLockType {
        uint256[LOCK_STAGE_MAX] time;
        uint256[LOCK_STAGE_MAX] freePercent;
    }

    StructLockType[LOCK_TYPE_MAX] private lockType;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    // This generates a public event that record info about locked account,
    // including amount of init tokens and lock type
    event SetLockData(address indexed account, uint256 initBalance, uint256 lockType, uint256 startDate);

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        totalSupply_ = 20000000000000000;
        balances[msg.sender] = totalSupply_;  // Give the creator all initial tokens

        //init all lock data
        //Lock type 1
        lockType[0].time[0] = 30;
        lockType[0].freePercent[0] = 40;     //40%
        lockType[0].time[1] = 60;
        lockType[0].freePercent[1] = 20;     //20%
        lockType[0].time[2] = 120;
        lockType[0].freePercent[2] = 20;     //20%
        lockType[0].time[3] = 180;
        lockType[0].freePercent[3] = 20;     //20%

        //Lock type 2
        lockType[1].time[0] = 30;
        lockType[1].freePercent[0] = 25;     //25%
        lockType[1].time[1] = 60;
        lockType[1].freePercent[1] = 25;     //25%
        lockType[1].time[2] = 120;
        lockType[1].freePercent[2] = 25;     //25%
        lockType[1].time[3] = 180;
        lockType[1].freePercent[3] = 25;     //25%

        //Lock type 3
        lockType[2].time[0] = 180;
        lockType[2].freePercent[0] = 25;     //25%
        lockType[2].time[1] = 360;
        lockType[2].freePercent[1] = 25;     //25%
        lockType[2].time[2] = 540;
        lockType[2].freePercent[2] = 25;     //25%
        lockType[2].time[3] = 720;
        lockType[2].freePercent[3] = 25;     //25%

        //init all lock data
    }

    /**
    * @dev Gets the token name
    * @return string representing the token name
    */
    function name() external view returns (string) {
        return string(name_);
    }

    /**
    * @dev Gets the token symbol
    * @return string representing the token symbol
    */
    function symbol() external view returns (string) {
        return string(symbol_);
    }

    /**
     * Calculate how much tokens must be locked
     * return the amount of locked tokens
     */
    function getLockBalance(address account) internal returns (uint256) {
        uint256 lockTypeIndex;
        uint256 amountLockedTokens = 0;
        uint256 resultFreePercent = 0;
        uint256 duration = 0;
        uint256 i;

        lockTypeIndex = lockAccountInfo[account].lockType;

        if (lockTypeIndex >= 1) {
            if (lockTypeIndex <= LOCK_TYPE_MAX) {
                lockTypeIndex = lockTypeIndex.sub(1);
                for (i = 0; i < LOCK_STAGE_MAX; i++) {
                    duration = (lockType[lockTypeIndex].time[i]).mul(1 days);
                    if (lockAccountInfo[account].startTime.add(duration) >= now) {
                        resultFreePercent = resultFreePercent.add(lockType[lockTypeIndex].freePercent[i]);
                    }
                }
            }

            amountLockedTokens = (lockAccountInfo[account].initBalance.mul(resultFreePercent)).div(100);

            if (amountLockedTokens == 0){
                lockAccountInfo[account].lockType = 0;
            }
        }

        return amountLockedTokens;
    }

    /**
     * Internal transfer, only can be called by this contract
     * Transfer toekns, and lock time and balance by selectType
     */
    function _transferForLock(address _to, uint256 _value, uint256 selectType) internal {
        require(selectType >= 1);
        require(selectType <= LOCK_TYPE_MAX);

        if ((lockAccountInfo[_to].lockType == 0) && 
            (lockAccountInfo[_to].initBalance == 0)) {
            require(_value <= balances[msg.sender]);
            require(_to != address(0));

            //write data
            lockAccountInfo[_to].lockType = selectType;
            lockAccountInfo[_to].initBalance = _value;
            lockAccountInfo[_to].startTime = now;
            emit SetLockData(_to,_value, lockAccountInfo[_to].lockType, lockAccountInfo[_to].startTime);
            //write data

            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            emit Transfer(msg.sender, _to, _value);
        } else {
            revert();
        }
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        //check
        uint256 freeBalance;

        if (lockAccountInfo[msg.sender].lockType > 0) {
            freeBalance = balances[msg.sender].sub(getLockBalance(msg.sender));
            require(freeBalance >=_value);
        }
        //check

        require(_value <= balances[msg.sender]);
        require(_to != address(0));
        require(!frozenAccount[msg.sender]);        // Check if sender is frozen
        require(!frozenAccount[_to]);               // Check if recipient is frozen

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) public onlyOwner {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    /**
     * Transfer tokens
     * Lock time and token by lock_type 1
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferLockBalance_1(address _to, uint256 _value) public onlyOwner {
        _transferForLock(_to, _value, 1);
    }

    /**
     * Transfer tokens
     * Lock time and token by lock_type 2
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferLockBalance_2(address _to, uint256 _value) public onlyOwner {
        _transferForLock(_to, _value, 2);
    }

    /**
     * Transfer tokens
     * Lock time and token by lock_type 3
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferLockBalance_3(address _to, uint256 _value) public onlyOwner {
        _transferForLock(_to, _value, 3);
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public onlyOwner {
        _burn(msg.sender, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= balances[_who]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[_who] = balances[_who].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(_who, _value);
    }
}