pragma solidity ^0.4.18;

contract DateTime {
        /*
         *  Date and Time utilities for ethereum contracts
         *
         */
        struct _DateTime {
                uint16 year;
                uint8 month;
                uint8 day;
                uint8 hour;
                uint8 minute;
                uint8 second;
                uint8 weekday;
        }

        uint constant DAY_IN_SECONDS = 86400;
        uint constant YEAR_IN_SECONDS = 31536000;
        uint constant LEAP_YEAR_IN_SECONDS = 31622400;

        uint constant HOUR_IN_SECONDS = 3600;
        uint constant MINUTE_IN_SECONDS = 60;

        uint16 constant ORIGIN_YEAR = 1970;

        function isLeapYear(uint16 year) public pure returns (bool) {
                if (year % 4 != 0) {
                        return false;
                }
                if (year % 100 != 0) {
                        return true;
                }
                if (year % 400 != 0) {
                        return false;
                }
                return true;
        }

        function leapYearsBefore(uint year) public pure returns (uint) {
                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
        }

        function parseTimestamp(uint timestamp) internal pure returns (_DateTime dt) {
                uint secondsAccountedFor = 0;
                uint buf;
                uint8 i;

                // Year
                dt.year = getYear(timestamp);
                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

                // Month
                uint secondsInMonth;
                for (i = 1; i <= 12; i++) {
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                        if (secondsInMonth + secondsAccountedFor > timestamp) {
                                dt.month = i;
                                break;
                        }
                        secondsAccountedFor += secondsInMonth;
                }

                // Day
                for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                                dt.day = i;
                                break;
                        }
                        secondsAccountedFor += DAY_IN_SECONDS;
                }

                // Hour
                dt.hour = getHour(timestamp);

                // Minute
                dt.minute = getMinute(timestamp);

                // Second
                dt.second = getSecond(timestamp);

                // Day of week.
                dt.weekday = getWeekday(timestamp);
        }

        function getYear(uint timestamp) public pure returns (uint16) {
                uint secondsAccountedFor = 0;
                uint16 year;
                uint numLeapYears;

                // Year
                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

                while (secondsAccountedFor > timestamp) {
                        if (isLeapYear(uint16(year - 1))) {
                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                secondsAccountedFor -= YEAR_IN_SECONDS;
                        }
                        year -= 1;
                }
                return year;
        }

        function getMonth(uint timestamp) public pure returns (uint8) {
                return parseTimestamp(timestamp).month;
        }

        function getDay(uint timestamp) public pure returns (uint8) {
                return parseTimestamp(timestamp).day;
        }

        function getHour(uint timestamp) public pure returns (uint8) {
                return uint8((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) public pure returns (uint8) {
                return uint8((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) public pure returns (uint8) {
                return uint8(timestamp % 60);
        }

        function getWeekday(uint timestamp) public pure returns (uint8) {
                return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp) {
                return toTimestamp(year, month, day, 0, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, minute, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp) {
                uint16 i;

                // Year
                for (i = ORIGIN_YEAR; i < year; i++) {
                        if (isLeapYear(i)) {
                                timestamp += LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                timestamp += YEAR_IN_SECONDS;
                        }
                }

                // Month
                uint8[12] memory monthDayCounts;
                monthDayCounts[0] = 31;
                if (isLeapYear(year)) {
                        monthDayCounts[1] = 29;
                }
                else {
                        monthDayCounts[1] = 28;
                }
                monthDayCounts[2] = 31;
                monthDayCounts[3] = 30;
                monthDayCounts[4] = 31;
                monthDayCounts[5] = 30;
                monthDayCounts[6] = 31;
                monthDayCounts[7] = 31;
                monthDayCounts[8] = 30;
                monthDayCounts[9] = 31;
                monthDayCounts[10] = 30;
                monthDayCounts[11] = 31;

                for (i = 1; i < month; i++) {
                        timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
                }

                // Day
                timestamp += DAY_IN_SECONDS * (day - 1);

                // Hour
                timestamp += HOUR_IN_SECONDS * (hour);

                // Minute
                timestamp += MINUTE_IN_SECONDS * (minute);

                // Second
                timestamp += second;

                return timestamp;
        }
}
pragma solidity ^0.4.18;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}
pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}
pragma solidity ^0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {

    function Destructible() public payable { }

    /**
     * @dev Transfers the current balance to the owner and terminates the contract.
     */
    function destroy() onlyOwner public {
        selfdestruct(owner);
    }

    function destroyAndSend(address _recipient) onlyOwner public {
        selfdestruct(_recipient);
    }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
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
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}


/// @title ABAToken - Token code for the ABA Project
/// @author David Chen, Jacky Lin
contract ABAToken is StandardToken, Ownable, Pausable, Destructible {

    using SafeMath for uint;
    string public constant name = "EcosBall";
    string public constant symbol = "ABA";
    uint public constant decimals = 18;

    DateTime public dateTime;

    uint constant million=1000000e18;
    //total token supply: 2.1 billion
    uint constant totalToken = 2100*million;
    //miner reward: 1.47 billion, 70% in 30 years, locked in the first year, 3.45% per year started from second year
    uint constant minerTotalSupply = 1470*million;
    //fund:105 million,5%, locked at least 1 year
    uint constant fundTotalSupply = 105*million;
    //IEO supply 105 million,5%
    uint constant ieoTotalSupply = 105*million;
    //Project team 105 million,5%, 12.5% of them are released in every 6 months
    uint constant projectTotalSupply = 105*million;
    //presale supply 105 million,5%
    uint constant presaleTotalSupply = 105*million;
    //market and community: 210 million, 10%, 50% of them are locked for 1 year
    uint constant market_communityTotalSupply = 210*million;

    uint projectUsedTokens = 0;
    uint market_communityUsedTokens = 0;

    bool bAllocFund = false;
    bool bAllocMarket_community = false;
    bool bAllocProject1 = false;
    bool bAllocProject2 = false;
    bool bAllocProject3 = false;
    bool bAllocProject4 = false;
    bool bAllocProject5 = false;
    bool bAllocProject6 = false;
    bool bAllocProject7 = false;
    bool bAllocProject8 = false;
    uint constant perProjectAlloc = 13125000e18;

    address public fundStorageVault;
    address public ieoStorageVault;
    address public projectStorageVault;
    address public presaleStorageVault;
    address public market_communityStorageVault;

    //@notice  Constructor of ABAToken
    function ABAToken() {
      totalSupply = totalToken;
      fundStorageVault = 0xa5b2F189552d3200fF393a38cCD90D63F3a99D08;
      ieoStorageVault = 0x07D150A514EB394efe4879d530C4c6C710509Da7;
      projectStorageVault = 0xd275eD1359F89251FbDeCdCbC196B57Ad71B851c;
      presaleStorageVault = 0xeA426B782D7526d5236Ff39515696cB096F5Af0A;
      market_communityStorageVault = 0xA408529eb7a233808F4c37308ed52e02046e7B09;

      balances[fundStorageVault] = 0;
      balances[ieoStorageVault] = ieoTotalSupply;
      balances[projectStorageVault] = 0;
      balances[presaleStorageVault] = presaleTotalSupply;
      market_communityUsedTokens = market_communityTotalSupply.div(2);
      balances[market_communityStorageVault] = market_communityUsedTokens;

      dateTime = new DateTime();
      balances[msg.sender] = minerTotalSupply;
    }

    function allocateFundToken() onlyOwner whenNotPaused external {
      if (now < dateTime.toTimestamp(2019,4,15)) throw;
      if (bAllocFund) throw;
      bAllocFund = true;
      balances[fundStorageVault] = balances[fundStorageVault].add(fundTotalSupply);
    }

    function getProjectUsedTokens() constant returns (uint256) {
      return projectUsedTokens;
    }

    function getProjectUnusedTokens() constant returns (uint256) {
      if(projectUsedTokens > projectTotalSupply) throw;
      uint projectUnusedTokens = projectTotalSupply.sub(projectUsedTokens);
      return projectUnusedTokens;
    }

    function allocate1ProjectToken() onlyOwner whenNotPaused external {
      if (now < dateTime.toTimestamp(2018,6,30)) throw;
      if (bAllocProject1) throw;
      bAllocProject1 = true;
      projectUsedTokens = projectUsedTokens.add(perProjectAlloc);
      balances[projectStorageVault] = balances[projectStorageVault].add(perProjectAlloc);
    }

    function allocate2ProjectToken() onlyOwner whenNotPaused external {
      if (now < dateTime.toTimestamp(2018,12,31)) throw;
      if (bAllocProject2) throw;
      bAllocProject2 = true;
      projectUsedTokens = projectUsedTokens.add(perProjectAlloc);
      balances[projectStorageVault] = balances[projectStorageVault].add(perProjectAlloc);
    }

    function allocate3ProjectToken() onlyOwner whenNotPaused external {
      if (now < dateTime.toTimestamp(2019,6,30)) throw;
      if (bAllocProject3) throw;
      bAllocProject3 = true;
      projectUsedTokens = projectUsedTokens.add(perProjectAlloc);
      balances[projectStorageVault] = balances[projectStorageVault].add(perProjectAlloc);
    }

    function allocate4ProjectToken() onlyOwner whenNotPaused external {
      if (now < dateTime.toTimestamp(2019,12,31)) throw;
      if (bAllocProject4) throw;
      bAllocProject4 = true;
      projectUsedTokens = projectUsedTokens.add(perProjectAlloc);
      balances[projectStorageVault] = balances[projectStorageVault].add(perProjectAlloc);
    }

    function allocate5ProjectToken() onlyOwner whenNotPaused external {
      if (now < dateTime.toTimestamp(2020,6,30)) throw;
      if (bAllocProject5) throw;
      bAllocProject5 = true;
      projectUsedTokens = projectUsedTokens.add(perProjectAlloc);
      balances[projectStorageVault] = balances[projectStorageVault].add(perProjectAlloc);
    }

    function allocate6ProjectToken() onlyOwner whenNotPaused external {
      if (now < dateTime.toTimestamp(2020,12,31)) throw;
      if (bAllocProject6) throw;
      bAllocProject6 = true;
      projectUsedTokens = projectUsedTokens.add(perProjectAlloc);
      balances[projectStorageVault] = balances[projectStorageVault].add(perProjectAlloc);
    }

    function allocate7ProjectToken() onlyOwner whenNotPaused external {
      if (now < dateTime.toTimestamp(2021,6,30)) throw;
      if (bAllocProject7) throw;
      bAllocProject7 = true;
      projectUsedTokens = projectUsedTokens.add(perProjectAlloc);
      balances[projectStorageVault] = balances[projectStorageVault].add(perProjectAlloc);
    }

    function allocate8ProjectToken() onlyOwner whenNotPaused external {
      if (now < dateTime.toTimestamp(2021,12,31)) throw;
      if (bAllocProject8) throw;
      bAllocProject8 = true;
      projectUsedTokens = projectUsedTokens.add(perProjectAlloc);
      balances[projectStorageVault] = balances[projectStorageVault].add(perProjectAlloc);
    }

    function allocateMarket_CommunitTokens() onlyOwner whenNotPaused external {
      if (now < dateTime.toTimestamp(2019,4,15)) throw;
      if (bAllocMarket_community) throw;
      bAllocMarket_community = true;
      uint nowAllocateTokens = market_communityTotalSupply.div(2);
      market_communityUsedTokens = market_communityUsedTokens.add(market_communityUsedTokens);
      balances[market_communityStorageVault] = balances[market_communityStorageVault].add(nowAllocateTokens);
    }

    function getMarket_CommunitUsedTokens() constant returns (uint256) {
      return market_communityUsedTokens;
    }

    function getMarket_CommunitUnusedTokens() constant returns (uint256) {
      if(market_communityUsedTokens > market_communityTotalSupply) throw;
      uint market_communityUnusedTokens = market_communityTotalSupply.sub(market_communityUsedTokens);
      return market_communityUnusedTokens;
    }
}