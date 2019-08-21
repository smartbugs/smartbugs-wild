pragma solidity ^0.4.11;

library DateTimeLib {
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

library SafeMathLib {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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

interface IERC20 {
    //function totalSupply() public constant returns (uint256 totalSupply);
    function balanceOf(address _owner) public constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address _spender, uint256 _value);
}

contract StandardToken is IERC20 {

    using SafeMathLib for uint256;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowed;

    function StandardToken() public payable {

    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        return transferInternal(msg.sender, _to, _value);
    }

    function transferInternal(address _from, address _to, uint256 _value) internal returns (bool success) {
        require(_value > 0 && balances[_from] >= _value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value > 0 && allowed[_from][msg.sender] >= _value && balances[_from] >= _value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address _spender, uint256 _value);
}

contract LockableToken is StandardToken {

    mapping(address => uint256) internal lockedBalance;

    mapping(address => uint) internal timeRelease;

    address internal teamReservedHolder;

    uint256 internal teamReservedBalance;

    uint [8] internal teamReservedFrozenDates;

    uint256 [8] internal teamReservedFrozenLimits;

    function LockableToken() public payable {

    }

    function lockInfo(address _address) public constant returns (uint timeLimit, uint256 balanceLimit) {
        return (timeRelease[_address], lockedBalance[_address]);
    }

    function teamReservedLimit() internal returns (uint256 balanceLimit) {
        uint time = now;
        for (uint index = 0; index < teamReservedFrozenDates.length; index++) {
            if (teamReservedFrozenDates[index] == 0x0) {
                continue;
            }
            if (time > teamReservedFrozenDates[index]) {
                teamReservedFrozenDates[index] = 0x0;
            } else {
                return teamReservedFrozenLimits[index];
            }
        }
        return 0;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        return transferInternal(msg.sender, _to, _value);
    }

    function transferInternal(address _from, address _to, uint256 _value) internal returns (bool success) {
        require(_to != 0x0 && _value > 0x0);
        if (_from == teamReservedHolder) {
            uint256 reservedLimit = teamReservedLimit();
            require(balances[_from].sub(reservedLimit) >= _value);
        }
        var (timeLimit, lockLimit) = lockInfo(_from);
        if (timeLimit <= now && timeLimit != 0x0) {
            timeLimit = 0x0;
            timeRelease[_from] = 0x0;
            lockedBalance[_from] = 0x0;
            UnLock(_from, lockLimit);
            lockLimit = 0x0;
        }
        if (timeLimit != 0x0 && lockLimit > 0x0) {
            require(balances[_from].sub(lockLimit) >= _value);
        }
        return super.transferInternal(_from, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        return transferFromInternal(_from, _to, _value);
    }

    function transferFromInternal(address _from, address _to, uint256 _value) internal returns (bool success) {
        require(_to != 0x0 && _value > 0x0);
        if (_from == teamReservedHolder) {
            uint256 reservedLimit = teamReservedLimit();
            require(balances[_from].sub(reservedLimit) >= _value);
        }
        var (timeLimit, lockLimit) = lockInfo(_from);
        if (timeLimit <= now && timeLimit != 0x0) {
            timeLimit = 0x0;
            timeRelease[_from] = 0x0;
            lockedBalance[_from] = 0x0;
            UnLock(_from, lockLimit);
            lockLimit = 0x0;
        }
        if (timeLimit != 0x0 && lockLimit > 0x0) {
            require(balances[_from].sub(lockLimit) >= _value);
        }
        return super.transferFrom(_from, _to, _value);
    }

    event Lock(address indexed owner, uint256 value, uint releaseTime);
    event UnLock(address indexed owner, uint256 value);
}

contract TradeableToken is LockableToken {

    address public publicOfferingHolder;

    uint256 internal baseExchangeRate;

    uint256 internal earlyExchangeRate;

    uint internal earlyEndTime;

    function TradeableToken() public payable {

    }

    function buy(address _beneficiary, uint256 _weiAmount) internal {
        require(_beneficiary != 0x0);
        require(publicOfferingHolder != 0x0);
        require(earlyEndTime != 0x0 && baseExchangeRate != 0x0 && earlyExchangeRate != 0x0);
        require(_weiAmount != 0x0);

        uint256 rate = baseExchangeRate;
        if (now <= earlyEndTime) {
            rate = earlyExchangeRate;
        }
        uint256 exchangeToken = _weiAmount.mul(rate);
        exchangeToken = exchangeToken.div(1 * 10 ** 10);

        publicOfferingHolder.transfer(_weiAmount);
        super.transferInternal(publicOfferingHolder, _beneficiary, exchangeToken);
    }
}

contract OwnableToken is TradeableToken {

    address internal owner;

    uint internal _totalSupply = 1500000000 * 10 ** 8;

    function OwnableToken() public payable {

    }

    /*
     *  Modifiers
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) onlyOwner public {
        require(_newOwner != address(0));
        owner = _newOwner;
        OwnershipTransferred(owner, _newOwner);
    }

    function lock(address _owner, uint256 _value, uint _releaseTime) public payable onlyOwner returns (uint releaseTime, uint256 limit) {
        require(_owner != 0x0 && _value > 0x0 && _releaseTime >= now);
        _value = lockedBalance[_owner].add(_value);
        _releaseTime = _releaseTime >= timeRelease[_owner] ? _releaseTime : timeRelease[_owner];
        lockedBalance[_owner] = _value;
        timeRelease[_owner] = _releaseTime;
        Lock(_owner, _value, _releaseTime);
        return (_releaseTime, _value);
    }

    function unlock(address _owner) public payable onlyOwner returns (bool) {
        require(_owner != 0x0);
        uint256 _value = lockedBalance[_owner];
        lockedBalance[_owner] = 0x0;
        timeRelease[_owner] = 0x0;
        UnLock(_owner, _value);
        return true;
    }

    function transferAndLock(address _to, uint256 _value, uint _releaseTime) public payable onlyOwner returns (bool success) {
        require(_to != 0x0);
        require(_value > 0);
        require(_releaseTime >= now);
        require(_value <= balances[msg.sender]);

        super.transfer(_to, _value);
        lock(_to, _value, _releaseTime);
        return true;
    }

    function setBaseExchangeRate(uint256 _baseExchangeRate) public payable onlyOwner returns (bool success) {
        require(_baseExchangeRate > 0x0);
        baseExchangeRate = _baseExchangeRate;
        BaseExchangeRateChanged(baseExchangeRate);
        return true;
    }

    function setEarlyExchangeRate(uint256 _earlyExchangeRate) public payable onlyOwner returns (bool success) {
        require(_earlyExchangeRate > 0x0);
        earlyExchangeRate = _earlyExchangeRate;
        EarlyExchangeRateChanged(earlyExchangeRate);
        return true;
    }

    function setEarlyEndTime(uint256 _earlyEndTime) public payable onlyOwner returns (bool success) {
        require(_earlyEndTime > 0x0);
        earlyEndTime = _earlyEndTime;
        EarlyEndTimeChanged(earlyEndTime);
        return true;
    }

    function burn(uint256 _value) public payable onlyOwner returns (bool success) {
        require(_value > 0x0);
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        Burned(_value);
        return true;
    }

    function setPublicOfferingHolder(address _publicOfferingHolder) public payable onlyOwner returns (bool success) {
        require(_publicOfferingHolder != 0x0);
        publicOfferingHolder = _publicOfferingHolder;
        return true;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event BaseExchangeRateChanged(uint256 baseExchangeRate);
    event EarlyExchangeRateChanged(uint256 earlyExchangeRate);
    event EarlyEndTimeChanged(uint256 earlyEndTime);
    event Burned(uint256 value);
}

contract TenYunToken is OwnableToken {

    string public constant symbol = "TYC";

    string public constant name = "TenYun Coin";

    uint8 public constant decimals = 8;

    function TenYunToken() public payable {
        owner = 0x593841e27b7122ef48F7854c7E7E1d5A374f8BB3;
        balances[owner] = 1500000000 * 10 ** 8;

        publicOfferingHolder = 0x0B83ED7C57c335dCA9C978f78819A739AC67fD5D;
        balances[publicOfferingHolder] = 0x0;
        baseExchangeRate = 8500;
        earlyExchangeRate = 9445;
        earlyEndTime = 1516291200;

        teamReservedHolder = 0x6e4890764AA2Bba346459e2D6b811e26C9691704;
        teamReservedBalance = 300000000 * 10 ** 8;
        balances[teamReservedHolder] = 0x0;
        teamReservedFrozenDates =
        [
        DateTimeLib.toTimestamp(2018, 4, 25),
        DateTimeLib.toTimestamp(2018, 7, 25),
        DateTimeLib.toTimestamp(2018, 10, 25),
        DateTimeLib.toTimestamp(2019, 1, 25),
        DateTimeLib.toTimestamp(2019, 4, 25),
        DateTimeLib.toTimestamp(2019, 7, 25),
        DateTimeLib.toTimestamp(2019, 10, 25),
        DateTimeLib.toTimestamp(2020, 1, 25)
        ];
        teamReservedFrozenLimits =
        [
        teamReservedBalance,
        teamReservedBalance - (teamReservedBalance / 8) * 1,
        teamReservedBalance - (teamReservedBalance / 8) * 2,
        teamReservedBalance - (teamReservedBalance / 8) * 3,
        teamReservedBalance - (teamReservedBalance / 8) * 4,
        teamReservedBalance - (teamReservedBalance / 8) * 5,
        teamReservedBalance - (teamReservedBalance / 8) * 6,
        teamReservedBalance - (teamReservedBalance / 8) * 7
        ];
    }

    // fallback function can be used to buy tokens
    function() public payable {
        buy(msg.sender, msg.value);
    }

    function ethBalanceOf(address _owner) public constant returns (uint256){
        return _owner.balance;
    }

    function totalSupply() public constant returns (uint256 totalSupply) {
        return _totalSupply;
    }
}