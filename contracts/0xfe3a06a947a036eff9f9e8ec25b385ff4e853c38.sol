pragma solidity ^0.4.25;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
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
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
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

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

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
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Claimable {
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
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

/**
 * @title JZMLock
 * @author http://jzm.one
 * @dev JZMLock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract JZMLock {
  using SafeERC20 for ERC20Basic;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint256 public releaseTime;

  constructor(
    ERC20Basic _token,
    address _beneficiary,
    uint256 _releaseTime
  )
    public
  {
    // solium-disable-next-line security/no-block-members
    require(_releaseTime > block.timestamp);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  /**
   * @notice Transfers tokens held by JZMLock to beneficiary.
   */
  function release() public {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= releaseTime);
    uint256 amount = token.balanceOf(address(this));
    require(amount > 0);
    token.safeTransfer(beneficiary, amount);
  }
  
  function canRelease() public view returns (bool){
    return block.timestamp >= releaseTime;
  }
}

/**
 * @title JZMToken
 * @author http://jzm.one
 * @dev JZMToken is a token that provide lock function
 */
contract JZMToken is PausableToken {

    event TransferWithLock(address indexed from, address indexed to, address indexed locked, uint256 amount, uint256 releaseTime);
    
    mapping (address => address[] ) public balancesLocked;

    function transferWithLock(address _to, uint256 _amount, uint256 _releaseTime) public returns (bool) {
        JZMLock lock = new JZMLock(this, _to, _releaseTime);
        transfer(address(lock), _amount);
        balancesLocked[_to].push(lock);
        emit TransferWithLock(msg.sender, _to, address(lock), _amount, _releaseTime);
        return true;
    }

    /**
     * @dev Gets the locked balance of the specified address.
     * @param _owner The address to query the locked balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOfLocked(address _owner) public view returns (uint256) {
        address[] memory lockTokenAddrs = balancesLocked[_owner];

        uint256 totalLockedBalance = 0;
        for (uint i = 0; i < lockTokenAddrs.length; i++) {
            totalLockedBalance = totalLockedBalance.add(balances[lockTokenAddrs[i]]);
        }
        
        return totalLockedBalance;
    }

    function releaseToken(address _owner) public returns (bool) {
        address[] memory lockTokenAddrs = balancesLocked[_owner];
        for (uint i = 0; i < lockTokenAddrs.length; i++) {
            JZMLock lock = JZMLock(lockTokenAddrs[i]);
            if (lock.canRelease() && balanceOf(lock)>0) {
                lock.release();
            }
        }
        return true;
    }
}

/**
 * @title TUToken
 * @dev Trust Union Token Contract
 */
contract TUToken is JZMToken {
    using SafeMath for uint256;

    string public constant name = "Trust Union";
    string public constant symbol = "TUT";
    uint8 public constant decimals = 18;

    uint256 private constant TOKEN_UNIT = 10 ** uint256(decimals);
    uint256 private constant INITIAL_SUPPLY = (10 ** 9) * TOKEN_UNIT;

    //init wallet address
    address private constant ADDR_MARKET          = 0xEd3998AA7F255Ade06236776f9FD429eECc91357;
    address private constant ADDR_FOUNDTEAM       = 0x1867812567f42e2Da3C572bE597996B1309593A7;
    address private constant ADDR_ECO             = 0xF7549be7449aA2b7D708d39481fCBB618C9Fb903;
    address private constant ADDR_PRIVATE_SALE    = 0x252c4f77f1cdCCEBaEBbce393804F4c8f3D5703D;
    address private constant ADDR_SEED_INVESTOR   = 0x03a59D08980A5327a958860e346d020ec8bb33dC;
    address private constant ADDR_FOUNDATION      = 0xC138d62b3E34391964852Cf712454492DC7eFF68;

    //init supply for market = 5%
    uint256 private constant S_MARKET_TOTAL = INITIAL_SUPPLY * 5 / 100;
    uint256 private constant S_MARKET_20181030 = 5000000  * TOKEN_UNIT;
    uint256 private constant S_MARKET_20190130 = 10000000 * TOKEN_UNIT;
    uint256 private constant S_MARKET_20190430 = 15000000 * TOKEN_UNIT;
    uint256 private constant S_MARKET_20190730 = 20000000 * TOKEN_UNIT;

    //init supply for founding team = 15%
    uint256 private constant S_FOUNDTEAM_TOTAL = INITIAL_SUPPLY * 15 / 100;
    uint256 private constant S_FOUNDTEAM_20191030 = INITIAL_SUPPLY * 5 / 100;
    uint256 private constant S_FOUNDTEAM_20200430 = INITIAL_SUPPLY * 5 / 100;
    uint256 private constant S_FOUNDTEAM_20201030 = INITIAL_SUPPLY * 5 / 100;

    //init supply for ecological incentive = 40%
    uint256 private constant S_ECO_TOTAL = INITIAL_SUPPLY * 40 / 100;
    uint256 private constant S_ECO_20190401 = 45000000 * TOKEN_UNIT;
    uint256 private constant S_ECO_20191001 = 45000000 * TOKEN_UNIT;
    uint256 private constant S_ECO_20200401 = 40000000 * TOKEN_UNIT;
    uint256 private constant S_ECO_20201001 = 40000000 * TOKEN_UNIT;
    uint256 private constant S_ECO_20210401 = 35000000 * TOKEN_UNIT;
    uint256 private constant S_ECO_20211001 = 35000000 * TOKEN_UNIT;
    uint256 private constant S_ECO_20220401 = 30000000 * TOKEN_UNIT;
    uint256 private constant S_ECO_20221001 = 30000000 * TOKEN_UNIT;
    uint256 private constant S_ECO_20230401 = 25000000 * TOKEN_UNIT;
    uint256 private constant S_ECO_20231001 = 25000000 * TOKEN_UNIT;
    uint256 private constant S_ECO_20240401 = 25000000 * TOKEN_UNIT;
    uint256 private constant S_ECO_20241001 = 25000000 * TOKEN_UNIT;

    //init supply for private sale = 10%
    uint256 private constant S_PRIVATE_SALE = INITIAL_SUPPLY * 10 / 100;

    //init supply for seed investor = 10%
    uint256 private constant S_SEED_INVESTOR = INITIAL_SUPPLY * 10 / 100;

    //init supply for foundation = 20%
    uint256 private constant S_FOUNDATION = INITIAL_SUPPLY * 20 / 100;
    
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[owner] = totalSupply_;

        _initWallet();
        _invokeLockLogic();
    }

    /**
     * @dev init the wallets
     */
    function _initWallet() internal onlyOwner {
        transfer(ADDR_PRIVATE_SALE, S_PRIVATE_SALE);
        transfer(ADDR_SEED_INVESTOR, S_SEED_INVESTOR);
        transfer(ADDR_FOUNDATION, S_FOUNDATION);
    }

    /**
     * @dev invoke lock logic
     */
    function _invokeLockLogic() internal onlyOwner {
        //lock for market
        //2018/10/30 0:00:00 UTC +8
        transferWithLock(ADDR_MARKET, S_MARKET_20181030, 1540828800);
        //2019/01/30 0:00:00 UTC +8
        transferWithLock(ADDR_MARKET, S_MARKET_20190130, 1548777600); 
        //2019/04/30 0:00:00 UTC +8     
        transferWithLock(ADDR_MARKET, S_MARKET_20190430, 1556553600);
        //2019/07/30 0:00:00 UTC +8
        transferWithLock(ADDR_MARKET, S_MARKET_20190730, 1564416000);
        
        //lock for found team
        //2019/10/30 0:00:00 UTC +8
        transferWithLock(ADDR_FOUNDTEAM, S_FOUNDTEAM_20191030, 1572364800);
        //2020/04/30 0:00:00 UTC +8
        transferWithLock(ADDR_FOUNDTEAM, S_FOUNDTEAM_20200430, 1588176000);
        //2020/10/30 0:00:00 UTC +8
        transferWithLock(ADDR_FOUNDTEAM, S_FOUNDTEAM_20201030, 1603987200);
        
        //lock for eco
        //2019/04/01 0:00:00 UTC +8
        transferWithLock(ADDR_ECO, S_ECO_20190401, 1554048000);
        //2019/10/01 0:00:00 UTC +8
        transferWithLock(ADDR_ECO, S_ECO_20191001, 1569859200);
        //2020/04/01 0:00:00 UTC +8
        transferWithLock(ADDR_ECO, S_ECO_20200401, 1585670400);
        //2020/10/01 0:00:00 UTC +8
        transferWithLock(ADDR_ECO, S_ECO_20201001, 1601481600);
        //2021/04/01 0:00:00 UTC +8
        transferWithLock(ADDR_ECO, S_ECO_20210401, 1617206400);
        //2021/10/01 0:00:00 UTC +8
        transferWithLock(ADDR_ECO, S_ECO_20211001, 1633017600);
        //2022/04/01 0:00:00 UTC +8
        transferWithLock(ADDR_ECO, S_ECO_20220401, 1648742400);
        //2022/10/01 0:00:00 UTC +8
        transferWithLock(ADDR_ECO, S_ECO_20221001, 1664553600);
        //2023/04/01 0:00:00 UTC +8
        transferWithLock(ADDR_ECO, S_ECO_20230401, 1680278400);
        //2023/10/01 0:00:00 UTC +8
        transferWithLock(ADDR_ECO, S_ECO_20231001, 1696089600);
        //2024/04/01 0:00:00 UTC +8
        transferWithLock(ADDR_ECO, S_ECO_20240401, 1711900800);
        //2024/10/01 0:00:00 UTC +8
        transferWithLock(ADDR_ECO, S_ECO_20241001, 1727712000);
    }
}