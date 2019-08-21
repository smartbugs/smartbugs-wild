pragma solidity 0.4.24;
// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: contracts/IHuddlToken.sol

contract IHuddlToken is IERC20{

    function mint(address to, uint256 value)external returns (bool);
    
    function decimals() public view returns(uint8);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: contracts/HuddlDistribution.sol

contract HuddlDistribution is Ownable {
    
    using SafeMath for uint256;

    IHuddlToken token;
    
    uint256 lastReleasedQuarter;

    address public usersPool;
    address public contributorsPool;
    address public reservePool;

    uint256 public inflationRate;
    //4% == 400 (supports upto 2 decimal places) for 4.5% enter 450
    uint16 public constant INFLATION_RATE_OF_CHANGE = 400;

    uint256 public contributorDistPercent;
    uint256 public reserveDistPercent;

    uint16 public contributorROC;
    uint16 public reserveROC;

    uint8 public lastQuarter;//last quarter for which tokens were released
    
    bool public launched;
    
    //1000,000,000 (considering 18 decimal places)
    uint256 public constant MAX_SUPPLY = 1000000000000000000000000000;

    uint256[] public quarterSchedule;

    event DistributionLaunched();

    event TokensReleased(
        uint256 indexed userShare, 
        uint256 indexed reserveShare, 
        uint256 indexed contributorShare
    );

    event ReserveDistributionPercentChanged(uint256 indexed newPercent);

    event ContributorDistributionPercentChanged(uint256 indexed newPercent);

    event ReserveROCChanged(uint256 indexed newROC);

    event ContributorROCChanged(uint256 indexed newROC);

    modifier distributionLaunched() {
        require(launched, "Distribution not launched");
        _;
    }

    modifier quarterRunning() {
        require(
            lastQuarter < 72 && now >= quarterSchedule[lastQuarter],
            "Quarter not started"
        );
        _;
    }

    constructor(
        address huddlTokenAddress, 
        address _usersPool, 
        address _contributorsPool, 
        address _reservePool
    )
        public 
    {

        require(
            huddlTokenAddress != address(0), 
            "Please provide valid huddl token address"
        );
        require(
            _usersPool != address(0), 
            "Please provide valid user pool address"
        );
        require(
            _contributorsPool != address(0), 
            "Please provide valid contributors pool address"
        );
        require(
            _reservePool != address(0), 
            "Please provide valid reserve pool address"
        );
        
        usersPool = _usersPool;
        contributorsPool = _contributorsPool;
        reservePool = _reservePool;

        //considering 18 decimal places (10 * (10**18) / 100) 10%
        inflationRate = 100000000000000000;

        //considering 18 decimal places (33.333 * (10**18) /100)
        contributorDistPercent = 333330000000000000; 
        reserveDistPercent = 333330000000000000;
        
        //Supports upto 2 decimal places, for 1% enter 100, for 1.5% enter 150
        contributorROC = 100;//1%
        reserveROC = 100;//1%

        token = IHuddlToken(huddlTokenAddress);

        //Initialize 72 quarterly token release schedule for distribution. Hard-coding token release time for each quarter for precision as required
        quarterSchedule.push(1554076800); // 04/01/2019 (MM/DD/YYYY)
        quarterSchedule.push(1561939200); // 07/01/2019 (MM/DD/YYYY)
        quarterSchedule.push(1569888000); // 10/01/2019 (MM/DD/YYYY)
        quarterSchedule.push(1577836800); // 01/01/2020 (MM/DD/YYYY)
        quarterSchedule.push(1585699200); // 04/01/2020 (MM/DD/YYYY)
        quarterSchedule.push(1593561600); // 07/01/2020 (MM/DD/YYYY)
        quarterSchedule.push(1601510400); // 10/01/2020 (MM/DD/YYYY)
        quarterSchedule.push(1609459200); // 01/01/2021 (MM/DD/YYYY)
        quarterSchedule.push(1617235200); // 04/01/2021 (MM/DD/YYYY)
        quarterSchedule.push(1625097600); // 07/01/2021 (MM/DD/YYYY)
        quarterSchedule.push(1633046400); // 10/01/2021 (MM/DD/YYYY)
        quarterSchedule.push(1640995200); // 01/01/2022 (MM/DD/YYYY)
        quarterSchedule.push(1648771200); // 04/01/2022 (MM/DD/YYYY)
        quarterSchedule.push(1656633600); // 07/01/2022 (MM/DD/YYYY)
        quarterSchedule.push(1664582400); // 10/01/2022 (MM/DD/YYYY)
        quarterSchedule.push(1672531200); // 01/01/2023 (MM/DD/YYYY)
        quarterSchedule.push(1680307200); // 04/01/2023 (MM/DD/YYYY)
        quarterSchedule.push(1688169600); // 07/01/2023 (MM/DD/YYYY)
        quarterSchedule.push(1696118400); // 10/01/2023 (MM/DD/YYYY)
        quarterSchedule.push(1704067200); // 01/01/2024 (MM/DD/YYYY)
        quarterSchedule.push(1711929600); // 04/01/2024 (MM/DD/YYYY)
        quarterSchedule.push(1719792000); // 07/01/2024 (MM/DD/YYYY)
        quarterSchedule.push(1727740800); // 10/01/2024 (MM/DD/YYYY)
        quarterSchedule.push(1735689600); // 01/01/2025 (MM/DD/YYYY)
        quarterSchedule.push(1743465600); // 04/01/2025 (MM/DD/YYYY)
        quarterSchedule.push(1751328000); // 07/01/2025 (MM/DD/YYYY)
        quarterSchedule.push(1759276800); // 10/01/2025 (MM/DD/YYYY)
        quarterSchedule.push(1767225600); // 01/01/2026 (MM/DD/YYYY)
        quarterSchedule.push(1775001600); // 04/01/2026 (MM/DD/YYYY)
        quarterSchedule.push(1782864000); // 07/01/2026 (MM/DD/YYYY)
        quarterSchedule.push(1790812800); // 10/01/2026 (MM/DD/YYYY)
        quarterSchedule.push(1798761600); // 01/01/2027 (MM/DD/YYYY)
        quarterSchedule.push(1806537600); // 04/01/2027 (MM/DD/YYYY)
        quarterSchedule.push(1814400000); // 07/01/2027 (MM/DD/YYYY)
        quarterSchedule.push(1822348800); // 10/01/2027 (MM/DD/YYYY)
        quarterSchedule.push(1830297600); // 01/01/2028 (MM/DD/YYYY)
        quarterSchedule.push(1838160000); // 04/01/2028 (MM/DD/YYYY)
        quarterSchedule.push(1846022400); // 07/01/2028 (MM/DD/YYYY)
        quarterSchedule.push(1853971200); // 10/01/2028 (MM/DD/YYYY)
        quarterSchedule.push(1861920000); // 01/01/2029 (MM/DD/YYYY)
        quarterSchedule.push(1869696000); // 04/01/2029 (MM/DD/YYYY)
        quarterSchedule.push(1877558400); // 07/01/2029 (MM/DD/YYYY)
        quarterSchedule.push(1885507200); // 10/01/2029 (MM/DD/YYYY)
        quarterSchedule.push(1893456000); // 01/01/2030 (MM/DD/YYYY)
        quarterSchedule.push(1901232000); // 04/01/2030 (MM/DD/YYYY)
        quarterSchedule.push(1909094400); // 07/01/2030 (MM/DD/YYYY)
        quarterSchedule.push(1917043200); // 10/01/2030 (MM/DD/YYYY)
        quarterSchedule.push(1924992000); // 01/01/2031 (MM/DD/YYYY)
        quarterSchedule.push(1932768000); // 04/01/2031 (MM/DD/YYYY)
        quarterSchedule.push(1940630400); // 07/01/2031 (MM/DD/YYYY)
        quarterSchedule.push(1948579200); // 10/01/2031 (MM/DD/YYYY)
        quarterSchedule.push(1956528000); // 01/01/2032 (MM/DD/YYYY)
        quarterSchedule.push(1964390400); // 04/01/2032 (MM/DD/YYYY)
        quarterSchedule.push(1972252800); // 07/01/2032 (MM/DD/YYYY)
        quarterSchedule.push(1980201600); // 10/01/2032 (MM/DD/YYYY)
        quarterSchedule.push(1988150400); // 01/01/2033 (MM/DD/YYYY)
        quarterSchedule.push(1995926400); // 04/01/2033 (MM/DD/YYYY)
        quarterSchedule.push(2003788800); // 07/01/2033 (MM/DD/YYYY)
        quarterSchedule.push(2011737600); // 10/01/2033 (MM/DD/YYYY)
        quarterSchedule.push(2019686400); // 01/01/2034 (MM/DD/YYYY)
        quarterSchedule.push(2027462400); // 04/01/2034 (MM/DD/YYYY)
        quarterSchedule.push(2035324800); // 07/01/2034 (MM/DD/YYYY)
        quarterSchedule.push(2043273600); // 10/01/2034 (MM/DD/YYYY)
        quarterSchedule.push(2051222400); // 01/01/2035 (MM/DD/YYYY)
        quarterSchedule.push(2058998400); // 04/01/2035 (MM/DD/YYYY)
        quarterSchedule.push(2066860800); // 07/01/2035 (MM/DD/YYYY)
        quarterSchedule.push(2074809600); // 10/01/2035 (MM/DD/YYYY)
        quarterSchedule.push(2082758400); // 01/01/2036 (MM/DD/YYYY)
        quarterSchedule.push(2090620800); // 04/01/2036 (MM/DD/YYYY)
        quarterSchedule.push(2098483200); // 07/01/2036 (MM/DD/YYYY)
        quarterSchedule.push(2106432000); // 10/01/2036 (MM/DD/YYYY)
        quarterSchedule.push(2114380800); // 01/01/2037 (MM/DD/YYYY)

    }

    /** 
    * @dev When the distribution will start the initial set of tokens will be distributed amongst users, reserve and contributors as per specs
    * Before calling this method the owner must transfer all the initial supply tokens to this distribution contract
    */
    function launchDistribution() external onlyOwner {

        require(!launched, "Distribution already launched");

        launched = true;

        (
            uint256 userShare, 
            uint256 reserveShare, 
            uint256 contributorShare
        ) = getDistributionShares(token.totalSupply());

        token.transfer(usersPool, userShare);
        token.transfer(contributorsPool, contributorShare);
        token.transfer(reservePool, reserveShare);
        adjustDistributionPercentage();
        emit DistributionLaunched();
    } 

    /** 
    * @dev This method allows owner of the contract to release tokens for the quarter.
    * So suppose current quarter is 5 and previously released quarter is 3 then owner will have to send 2 transaction to release all tokens upto this quarter.
    * First transaction will release tokens for quarter 4 and Second transaction will release tokens for quarter 5. This is done to reduce complexity.
    */
    function releaseTokens()
        external 
        onlyOwner 
        distributionLaunched
        quarterRunning//1. Check if quarter date has been reached
        returns(bool)
    {   
        
        //2. Increment quarter. Overflow will never happen as maximum quarters can be 72
        lastQuarter = lastQuarter + 1;

        //3. Calculate amount of tokens to be released
        uint256 amount = getTokensToMint();

        //4. Check if amount is greater than 0
        require(amount>0, "No tokens to be released");

        //5. Calculate share of user, reserve and contributor
        (
            uint256 userShare, 
            uint256 reserveShare, 
            uint256 contributorShare
        ) = getDistributionShares(amount);

        //6. Change inflation rate, for next release/quarter
        adjustInflationRate();

        //7. Change distribution percentage for next quarter
        adjustDistributionPercentage();

        //8. Mint and transfer tokens to respective pools
        token.mint(usersPool, userShare);
        token.mint(contributorsPool, contributorShare);
        token.mint(reservePool, reserveShare);

        //9. Emit event
        emit TokensReleased(
            userShare, 
            reserveShare, 
            contributorShare
        );
    }
   
    /** 
    * @dev This method will return the release time for upcoming quarter
    */
    function nextReleaseTime() external view returns(uint256 time) {
        time = quarterSchedule[lastQuarter];
    }

    /** 
    * @dev This method will returns whether the next quarter's token can be released now or not
    */
    function canRelease() external view returns(bool release) {
        release = now >= quarterSchedule[lastQuarter];
    }

    /** 
    * @dev Returns current distribution percentage for user pool
    */
    function userDistributionPercent() external view returns(uint256) {
        uint256 totalPercent = 1000000000000000000;
        return(
            totalPercent.sub(contributorDistPercent.add(reserveDistPercent))
        );
    }

    /** 
    * @dev Allows owner to change reserve distribution percentage for next quarter
    * Consequent calculations will be done on this basis
    * @param newPercent New percentage. Ex for 45.33% pass (45.33 * (10**18) /100) = 453330000000000000
    */
    function changeReserveDistributionPercent(
        uint256 newPercent
    )
        external 
        onlyOwner
    {
        reserveDistPercent = newPercent;
        emit ReserveDistributionPercentChanged(newPercent);
    }

    /** 
    * @dev Allows owner to change contributor distribution percentage for next quarter
    * Consequent calculations will be done on this basis
    * @param newPercent New percentage. Ex for 45.33% pass (45.33 * (10**18) /100) = 453330000000000000
    */
    function changeContributorDistributionPercent(
        uint256 newPercent
    )
        external 
        onlyOwner
    {
        contributorDistPercent = newPercent;
        emit ContributorDistributionPercentChanged(newPercent);
    }

    /** 
    * @dev Allows owner to change ROC for reserve pool
    * @dev newROC New ROC. Ex- for 1% enter 100, for 1.5% enter 150
    */
    function changeReserveROC(uint16 newROC) external onlyOwner {
        reserveROC = newROC;
        emit ReserveROCChanged(newROC);
    }

    /** 
    * @dev Allows owner to change ROC for contributor pool
    * @dev newROC New ROC. Ex- for 1% enter 100, for 1.5% enter 150
    */
    function changeContributorROC(uint16 newROC) external onlyOwner {
        contributorROC = newROC;
        emit ContributorROCChanged(newROC);
    }

    /** 
    * @dev This method returns the share of user, reserve and contributors for given token amount as per current distribution
    * @param amount The amount of tokens for which the shares have to be calculated
    */
    function getDistributionShares(
        uint256 amount
    )
        public 
        view 
        returns(
            uint256 userShare, 
            uint256 reserveShare, 
            uint256 contributorShare
        )
    {
        contributorShare = contributorDistPercent.mul(
            amount.div(10**uint256(token.decimals()))
        );

        reserveShare = reserveDistPercent.mul(
            amount.div(10**uint256(token.decimals()))
        );

        userShare = amount.sub(
            contributorShare.add(reserveShare)
        );

        assert(
            contributorShare.add(reserveShare).add(userShare) == amount
        );
    }

    
    /** 
    * @dev Returns amount of tokens to be minted in next release(quarter)
    */    
    function getTokensToMint() public view returns(uint256 amount) {
        
        if (MAX_SUPPLY == token.totalSupply()){
            return 0;
        }

        //dividing by decimal places(18) since that is already multiplied in inflation rate
        amount = token.totalSupply().div(
            10 ** uint256(token.decimals())
        ).mul(inflationRate);

        if (amount.add(token.totalSupply()) > MAX_SUPPLY){
            amount = MAX_SUPPLY.sub(token.totalSupply());
        }
    }

    function adjustDistributionPercentage() private {
        contributorDistPercent = contributorDistPercent.sub(
            contributorDistPercent.mul(contributorROC).div(10000)
        );

        reserveDistPercent = reserveDistPercent.sub(
            reserveDistPercent.mul(reserveROC).div(10000)
        );
    }

    function adjustInflationRate() private {
        inflationRate = inflationRate.sub(
            inflationRate.mul(INFLATION_RATE_OF_CHANGE).div(10000)
        );
    }

    
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

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

// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol

contract MinterRole {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private minters;

  constructor() internal {
    _addMinter(msg.sender);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender));
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyMinter {
    _addMinter(account);
  }

  function renounceMinter() public {
    _removeMinter(msg.sender);
  }

  function _addMinter(address account) internal {
    minters.add(account);
    emit MinterAdded(account);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol

/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20, MinterRole {
  /**
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address to,
    uint256 value
  )
    public
    onlyMinter
    returns (bool)
  {
    _mint(to, value);
    return true;
  }
}

// File: contracts/HuddlToken.sol

/** 
* @dev Mintable Huddl Token
* Initially deployer of the contract is only valid minter. Later on when distribution contract is deployed following steps needs to be followed-:
* 1. Make distribution contract a valid minter
* 2. Renounce miniter role for the token deployer address
* 3. Transfer initial supply tokens to distribution contract address
* 4. At launch of distribution contract transfer tokens to users, contributors and reserve as per monetary policy
*/
contract HuddlToken is ERC20Mintable{

    using SafeMath for uint256;

    string private _name;
    string private _symbol ;
    uint8 private _decimals;

    constructor(
        string name, 
        string symbol, 
        uint8 decimals, 
        uint256 totalSupply
    )
        public 
    {
    
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        
        //The initial supply of tokens will be given to the deployer. Deployer will later transfer it to distribution contract
        //At launch distribution contract will give those tokens as per policy to the users, contributors and reserve
        _mint(msg.sender, totalSupply.mul(10 ** uint256(decimals)));
    }

    
    /**
    * @return the name of the token.
    */
    function name() public view returns(string) {
        return _name;
    }

    /**
    * @return the symbol of the token.
    */
    function symbol() public view returns(string) {
        return _symbol;
    }

    /**
    * @return the number of decimals of the token.
    */
    function decimals() public view returns(uint8) {
        return _decimals;
    }

}

// File: contracts/Migrations.sol

contract Migrations {
    address public owner;
    uint public last_completed_migration;

    constructor() public {
        owner = msg.sender;
    }

    modifier restricted() {
        if (msg.sender == owner) 
            _;
    }

    function setCompleted(uint completed) public restricted {
        last_completed_migration = completed;
    }

    function upgrade(address new_address) public restricted {
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}