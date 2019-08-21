pragma solidity ^0.4.13;

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private rentrancy_lock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!rentrancy_lock);
    rentrancy_lock = true;
    _;
    rentrancy_lock = false;
  }

}

contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }

}

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
  function transferOwnership(address newOwner) onlyOwner {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner {
    owner = pendingOwner;
    pendingOwner = 0x0;
  }
}

contract Operational is Claimable {
    address public operator;

    function Operational(address _operator) {
      operator = _operator;
    }

    modifier onlyOperator() {
      require(msg.sender == operator);
      _;
    }

    function transferOperator(address newOperator) onlyOwner {
      require(newOperator != address(0));
      operator = newOperator;
    }

}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract LockableToken is StandardToken, ReentrancyGuard {

    struct LockedBalance {
        address owner;
        uint256 value;
        uint256 releaseTime;
    }

    mapping (uint => LockedBalance) public lockedBalances;
    uint public lockedBalanceCount;

    event TransferLockedToken(address indexed from, address indexed to, uint256 value, uint256 releaseTime);
    event ReleaseLockedBalance(address indexed owner, uint256 value, uint256 releaseTime);

    // ç» _to è½¬ç§» _value ä¸ªéå®å° _releaseTime ç token
    function transferLockedToken(address _to, uint256 _value, uint256 _releaseTime) nonReentrant returns (bool) {
        require(_releaseTime > now);
        require(_releaseTime.sub(1 years) < now);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        lockedBalances[lockedBalanceCount] = LockedBalance({owner: _to, value: _value, releaseTime: _releaseTime});
        lockedBalanceCount++;
        TransferLockedToken(msg.sender, _to, _value, _releaseTime);
        return true;
    }

    // æ¥ address çéå®ä½é¢
    function lockedBalanceOf(address _owner) constant returns (uint256 value) {
        for (uint i = 0; i < lockedBalanceCount; i++) {
            LockedBalance lockedBalance = lockedBalances[i];
            if (_owner == lockedBalance.owner) {
                value = value.add(lockedBalance.value);
            }
        }
        return value;
    }

    // è§£éææå·²å°éå®æ¶é´ç token
    function releaseLockedBalance () returns (uint256 releaseAmount) {
        uint index = 0;
        while (index < lockedBalanceCount) {
            if (now >= lockedBalances[index].releaseTime) {
                releaseAmount += lockedBalances[index].value;
                unlockBalanceByIndex(index);
            } else {
                index++;
            }
        }
        return releaseAmount;
    }

    function unlockBalanceByIndex (uint index) internal {
        LockedBalance lockedBalance = lockedBalances[index];
        balances[lockedBalance.owner] = balances[lockedBalance.owner].add(lockedBalance.value);
        ReleaseLockedBalance(lockedBalance.owner, lockedBalance.value, lockedBalance.releaseTime);
        lockedBalances[index] = lockedBalances[lockedBalanceCount - 1];
        delete lockedBalances[lockedBalanceCount - 1];
        lockedBalanceCount--;
    }

}

library DateTime {
        /*
         *  Date and Time utilities for ethereum contracts
         *
         */
        struct DateTime {
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

        function isLeapYear(uint16 year) constant returns (bool) {
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

        function leapYearsBefore(uint year) constant returns (uint) {
                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint8 month, uint16 year) constant returns (uint8) {
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

        function parseTimestamp(uint timestamp) internal returns (DateTime dt) {
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
                dt.hour = 0;//getHour(timestamp);

                // Minute
                dt.minute = 0;//getMinute(timestamp);

                // Second
                dt.second = 0;//getSecond(timestamp);

                // Day of week.
                dt.weekday = 0;//getWeekday(timestamp);

        }

        function getYear(uint timestamp) constant returns (uint16) {
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

        function getMonth(uint timestamp) constant returns (uint8) {
                return parseTimestamp(timestamp).month;
        }

        function getDay(uint timestamp) constant returns (uint8) {
                return parseTimestamp(timestamp).day;
        }

        function getHour(uint timestamp) constant returns (uint8) {
                return uint8((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) constant returns (uint8) {
                return uint8((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) constant returns (uint8) {
                return uint8(timestamp % 60);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day) constant returns (uint timestamp) {
                return toTimestamp(year, month, day, 0, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) constant returns (uint timestamp) {
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

contract ReleaseableToken is Operational, LockableToken {
    using SafeMath for uint;
    using DateTime for uint256;
    bool secondYearUpdate = false; // Limit æ´æ°å°ç¬¬äºå¹´
    uint256 public releasedSupply; // å·²éæ¾çæ°é
    uint256 public createTime; // åçº¦åå»ºæ¶é´
    uint256 standardDecimals = 100000000; // ç±äºæ8ä½å°æ°ï¼ä¼ è¿æ¥çåæ°é½æ¯ä¸å¸¦åé¢çå°æ°ï¼è¦æä¹100000000çæä½æè½ä¿è¯æ°éçº§ä¸è´
    uint256 public totalSupply = standardDecimals.mul(1000000000); // æ»é10äº¿
    uint256 public limitSupplyPerYear = standardDecimals.mul(60000000); // æ¯å¹´éæ¾çLLTçéé¢ï¼ç¬¬ä¸å¹´6000ä¸
    uint256 public dailyLimit = standardDecimals.mul(1000000); // æ¯å¤©éæ¾çéé¢

    event ReleaseSupply(address receiver, uint256 value, uint256 releaseTime);
    event UnfreezeAmount(address receiver, uint256 amount, uint256 unfreezeTime);

    struct FrozenRecord {
        uint256 amount; // å»ç»çæ°é
        uint256 unfreezeTime; // è§£å»çæ¶é´
    }

    mapping (uint => FrozenRecord) public frozenRecords;
    uint public frozenRecordsCount = 0;

    function ReleaseableToken(
                    uint256 initialSupply,
                    uint256 initReleasedSupply,
                    address operator
                ) Operational(operator) {
        totalSupply = initialSupply;
        releasedSupply = initReleasedSupply;
        createTime = now;
        balances[msg.sender] = initReleasedSupply;
    }

    // å¨ timestamp æ¶é´ç¹éæ¾ releaseAmount ç token
    function releaseSupply(uint256 releaseAmount, uint256 timestamp) onlyOperator returns(uint256 _actualRelease) {
        require(timestamp >= createTime && timestamp <= now);
        require(!judgeReleaseRecordExist(timestamp));
        require(releaseAmount <= dailyLimit);
        updateLimit();
        require(limitSupplyPerYear > 0);
        if (releaseAmount > limitSupplyPerYear) {
            if (releasedSupply.add(limitSupplyPerYear) > totalSupply) {
                releasedSupply = totalSupply;
                releaseAmount = totalSupply.sub(releasedSupply);
            } else {
                releasedSupply = releasedSupply.add(limitSupplyPerYear);
                releaseAmount = limitSupplyPerYear;
            }
            limitSupplyPerYear = 0;
        } else {
            if (releasedSupply.add(releaseAmount) > totalSupply) {
                releasedSupply = totalSupply;
                releaseAmount = totalSupply.sub(releasedSupply);
            } else {
                releasedSupply = releasedSupply.add(releaseAmount);
            }
            limitSupplyPerYear = limitSupplyPerYear.sub(releaseAmount);
        }
        frozenRecords[frozenRecordsCount] = FrozenRecord(releaseAmount, timestamp.add(26 * 1 weeks));
        frozenRecordsCount++;
        ReleaseSupply(msg.sender, releaseAmount, timestamp);
        return releaseAmount;
    }

    // å¤æ­ timestamp è¿ä¸å¤©ææ²¡æå·²ç»éæ¾çè®°å½
    function judgeReleaseRecordExist(uint256 timestamp) internal returns(bool _exist) {
        bool exist = false;
        if (frozenRecordsCount > 0) {
            for (uint index = 0; index < frozenRecordsCount; index++) {
                if ((frozenRecords[index].unfreezeTime.parseTimestamp().year == (timestamp.add(26 * 1 weeks)).parseTimestamp().year)
                    && (frozenRecords[index].unfreezeTime.parseTimestamp().month == (timestamp.add(26 * 1 weeks)).parseTimestamp().month)
                    && (frozenRecords[index].unfreezeTime.parseTimestamp().day == (timestamp.add(26 * 1 weeks)).parseTimestamp().day)) {
                    exist = true;
                }
            }
        }
        return exist;
    }

    // æ´æ°æ¯å¹´éæ¾tokençéå¶æ°é
    function updateLimit() internal {
        if (createTime.add(1 years) < now && !secondYearUpdate) {
            limitSupplyPerYear = standardDecimals.mul(120000000);
            secondYearUpdate = true;
        }
        if (createTime.add(2 * 1 years) < now) {
            if (releasedSupply < totalSupply) {
                limitSupplyPerYear = totalSupply.sub(releasedSupply);
            }
        }
    }

    // è§£å» releaseSupply ä¸­éæ¾ç token
    function unfreeze() onlyOperator returns(uint256 _unfreezeAmount) {
        uint256 unfreezeAmount = 0;
        uint index = 0;
        while (index < frozenRecordsCount) {
            if (frozenRecords[index].unfreezeTime < now) {
                unfreezeAmount += frozenRecords[index].amount;
                unfreezeByIndex(index);
            } else {
                index++;
            }
        }
        return unfreezeAmount;
    }

    function unfreezeByIndex (uint index) internal {
        FrozenRecord unfreezeRecord = frozenRecords[index];
        balances[owner] = balances[owner].add(unfreezeRecord.amount);
        UnfreezeAmount(owner, unfreezeRecord.amount, unfreezeRecord.unfreezeTime);
        frozenRecords[index] = frozenRecords[frozenRecordsCount - 1];
        delete frozenRecords[frozenRecordsCount - 1];
        frozenRecordsCount--;
    }

    // è®¾ç½®æ¯å¤©éæ¾ token çéé¢
    function setDailyLimit(uint256 _dailyLimit) onlyOwner {
        dailyLimit = _dailyLimit;
    }
}

contract LLToken is ReleaseableToken {
    string public standard = '2017082602';
    string public name = 'LLToken';
    string public symbol = 'LLT';
    uint8 public decimals = 8;

    function LLToken(
                     uint256 initialSupply,
                     uint256 initReleasedSupply,
                     address operator
                     ) ReleaseableToken(initialSupply, initReleasedSupply, operator) {}
}