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

contract ERC20xVariables {
    address public creator;
    address public lib;

    uint256 constant public MAX_UINT256 = 2**256 - 1;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowed;

    uint8 public constant decimals = 18;
    string public name;
    string public symbol;
    uint public totalSupply;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Created(address creator, uint supply);

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract ERC20x is ERC20xVariables {

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transferBalance(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(allowance >= _value);
        _transferBalance(_from, _to, _value);
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferToContract(address _to, uint256 _value, bytes data) public returns (bool) {
        _transferBalance(msg.sender, _to, _value);
        bytes4 sig = bytes4(keccak256("receiveTokens(address,uint256,bytes)"));
        require(_to.call(sig, msg.sender, _value, data));
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function _transferBalance(address _from, address _to, uint _value) internal {
        require(balances[_from] >= _value);
        balances[_from] -= _value;
        balances[_to] += _value;
    }
}

contract VariableSupplyToken is ERC20x {
    function grant(address to, uint256 amount) public {
        require(msg.sender == creator);
        require(balances[to] + amount >= amount);
        balances[to] += amount;
        totalSupply += amount;
    }

    function burn(address from, uint amount) public {
        require(msg.sender == creator);
        require(balances[from] >= amount);
        balances[from] -= amount;
        totalSupply -= amount;
    }
}

contract OptionToken is ERC20xVariables {

    constructor(string _name, string _symbol, address _lib) public {
        creator = msg.sender;
        lib = _lib;
        name = _name;
        symbol = _symbol;
    }

    function() public {
        require(
            lib.delegatecall(msg.data)
        );
    }
}

// we don't store much state here either
contract Token is VariableSupplyToken {
    constructor() public {
        creator = msg.sender;
        name = "Decentralized Settlement Facility Token";
        symbol = "DSF";

        // this needs to be here to avoid zero initialization of token rights.
        totalSupply = 1;
        balances[0x0] = 1;
    }
}

contract Protocol is DateTime {
    
    address public lib;
    ERC20x public usdERC20;
    Token public protocolToken;

    // We use "flavor" because type is a reserved word in many programming languages
    enum Flavor {
        Call,
        Put
    }

    struct OptionSeries {
        uint expiration;
        Flavor flavor;
        uint strike;
    }

    uint public constant DURATION = 12 hours;
    uint public constant HALF_DURATION = DURATION / 2;

    mapping(bytes32 => address) public seriesToken;
    mapping(address => uint) public openInterest;
    mapping(address => uint) public earlyExercised;
    mapping(address => uint) public totalInterest;
    mapping(address => mapping(address => uint)) public writers;
    mapping(address => OptionSeries) public seriesInfo;
    mapping(address => uint) public holdersSettlement;

    bytes4 public constant GRANT = bytes4(keccak256("grant(address,uint256)"));
    bytes4 public constant BURN = bytes4(keccak256("burn(address,uint256)"));

    bytes4 public constant RECEIVE_ETH = bytes4(keccak256("receiveETH(address,uint256)"));
    bytes4 public constant RECEIVE_USD = bytes4(keccak256("receiveUSD(address,uint256)"));

    uint public deployed;

    mapping(address => uint) public expectValue;
    bool isAuction;

    uint public constant ONE_MILLION = 1000000;

    // maximum token holder rights capped at 3.7% of total supply?
    // Why 3.7%?
    // I could make up some fancy explanation
    // and use the phrase "byzantine fault tolerance" somehow
    // Or I could just say that 3.7% allows for a total of 27 independent actors
    // that are all receiving the maximum benefit, and it solves all the other
    // issues of disincentivizing centralization and "rich get richer" mechanics, so I chose 27 'cause it just has a nice "decentralized" feel to it.
    // 21 would have been fine, as few as ten probably would have been ok 'cause people can just pool anyways
    // up to a thousand or so probably wouldn't have hurt either.
    // In the end it really doesn't matter as long as the game ends up being played fairly.

    // I'm sure someone will take my system and parameterize it differently at some point and bill it as a totally new product.
    uint public constant PREFERENCE_MAX = 0.037 ether;

    constructor(address _usd) public {
        lib = new VariableSupplyToken();
        protocolToken = new Token();
        usdERC20 = ERC20x(_usd);
        deployed = now;
    }

    function() public payable {
        revert();
    }

    event SeriesIssued(address series);

    function issue(uint expiration, Flavor flavor, uint strike) public returns (address) {
        require(strike >= 20 ether);
        require(strike % 20 ether == 0);
        require(strike <= 10000 ether);

        // require expiration to be at noon UTC
        require(expiration % 86400 == 43200);

        // valid expirations: 7n + 1 where n = (unix timestamp / 86400)
        require(((expiration / 86400) + 2) % 7 == 0);
        require(expiration > now + 12 hours);
        require(expiration < now + 365 days);

        // compute the symbol based on datetime library
        _DateTime memory exp = parseTimestamp(expiration);

        uint strikeCode = strike / 1 ether;

        string memory name = _name(exp, flavor, strikeCode);

        string memory symbol = _symbol(exp, flavor, strikeCode);

        bytes32 id = _seriesHash(expiration, flavor, strike);
        require(seriesToken[id] == address(0));
        address series = new OptionToken(name, symbol, lib);
        seriesToken[id] = series;
        seriesInfo[series] = OptionSeries(expiration, flavor, strike);
        emit SeriesIssued(series);
        return series;
    }

    function _name(_DateTime exp, Flavor flavor, uint strikeCode) private pure returns (string) {
        return string(
            abi.encodePacked(
                _monthName(exp.month),
                " ",
                uint2str(exp.day),
                " ",
                uint2str(strikeCode),
                "-",
                flavor == Flavor.Put ? "PUT" : "CALL"
            )
        );
    }

    function _symbol(_DateTime exp, Flavor flavor, uint strikeCode) private pure returns (string) {
        uint monthChar = 64 + exp.month;
        if (flavor == Flavor.Put) {
            monthChar += 12;
        }

        uint dayChar = 65 + (exp.day - 1) / 7;

        return string(
            abi.encodePacked(
                "∆",
                byte(monthChar),
                byte(dayChar),
                uint2str(strikeCode)
            )
        );
    }

    function open(address _series, uint amount) public payable returns (bool) {
        OptionSeries memory series = seriesInfo[_series];

        bytes32 id = _seriesHash(series.expiration, series.flavor, series.strike);
        require(seriesToken[id] == _series);
        require(_series.call(GRANT, msg.sender, amount));

        require(now < series.expiration);

        if (series.flavor == Flavor.Call) {
            require(msg.value == amount);
        } else {
            require(msg.value == 0);
            uint escrow = amount * series.strike;
            require(escrow / amount == series.strike);
            escrow /= 1 ether;
            require(usdERC20.transferFrom(msg.sender, this, escrow));
        }
        
        openInterest[_series] += amount;
        totalInterest[_series] += amount;
        writers[_series][msg.sender] += amount;

        return true;
    }

    function close(address _series, uint amount) public {
        OptionSeries memory series = seriesInfo[_series];

        require(now < series.expiration);
        require(openInterest[_series] >= amount);
        require(_series.call(BURN, msg.sender, amount));

        require(writers[_series][msg.sender] >= amount);
        writers[_series][msg.sender] -= amount;
        openInterest[_series] -= amount;
        totalInterest[_series] -= amount;
        
        if (series.flavor == Flavor.Call) {
            msg.sender.transfer(amount);
        } else {
            require(
                usdERC20.transfer(msg.sender, amount * series.strike / 1 ether));
        }
    }
    
    function exercise(address _series, uint amount) public payable {
        OptionSeries memory series = seriesInfo[_series];

        require(now < series.expiration);
        require(openInterest[_series] >= amount);
        require(_series.call(BURN, msg.sender, amount));

        uint usd = amount * series.strike;
        require(usd / amount == series.strike);
        usd /= 1 ether;

        openInterest[_series] -= amount;
        earlyExercised[_series] += amount;

        if (series.flavor == Flavor.Call) {
            msg.sender.transfer(amount);
            require(msg.value == 0);
            require(usdERC20.transferFrom(msg.sender, this, usd));
        } else {
            require(msg.value == amount);
            require(usdERC20.transfer(msg.sender, usd));
        }
    }
    
    function receive() public payable {
        require(expectValue[msg.sender] == msg.value);
        expectValue[msg.sender] = 0;
    }

    function bid(address _series, uint amount) public payable {

        require(isAuction == false);
        isAuction = true;

        OptionSeries memory series = seriesInfo[_series];

        uint start = series.expiration;
        uint time = now + _timePreference(msg.sender);

        require(time > start);
        require(time < start + DURATION);

        uint elapsed = time - start;

        amount = _min(amount, openInterest[_series]);

        if ((now - deployed) / 1 weeks < 8) {
            _grantReward(msg.sender, amount);
        }

        openInterest[_series] -= amount;

        uint offer;
        uint givGet;
        bool result;

        if (series.flavor == Flavor.Call) {
            require(msg.value == 0);

            offer = (series.strike * DURATION) / elapsed;
            givGet = offer * amount / 1 ether;
            holdersSettlement[_series] += givGet - amount * series.strike / 1 ether;

            bool hasFunds = usdERC20.balanceOf(msg.sender) >= givGet && usdERC20.allowance(msg.sender, this) >= givGet;

            if (hasFunds) {
                msg.sender.transfer(amount);
            } else {
                result = msg.sender.call.value(amount)(RECEIVE_ETH, _series, amount);
                require(result);
            }

            require(usdERC20.transferFrom(msg.sender, this, givGet));
        } else {
            offer = (DURATION * 1 ether * 1 ether) / (series.strike * elapsed);
            givGet = (amount * 1 ether) / offer;

            holdersSettlement[_series] += amount * series.strike / 1 ether - givGet;
            require(usdERC20.transfer(msg.sender, givGet));

            if (msg.value == 0) {
                require(expectValue[msg.sender] == 0);
                expectValue[msg.sender] = amount;

                result = msg.sender.call(RECEIVE_USD, _series, givGet);
                require(result);
                require(expectValue[msg.sender] == 0);
            } else {
                require(msg.value >= amount);
                msg.sender.transfer(msg.value - amount);
            }
        }

        isAuction = false;
    }

    function redeem(address _series) public {
        OptionSeries memory series = seriesInfo[_series];

        require(now > series.expiration + DURATION);

        uint unsettledPercent = openInterest[_series] * 1 ether / totalInterest[_series];
        uint exercisedPercent = (totalInterest[_series] - openInterest[_series]) * 1 ether / totalInterest[_series];
        uint owed;

        if (series.flavor == Flavor.Call) {
            owed = writers[_series][msg.sender] * unsettledPercent / 1 ether;
            if (owed > 0) {
                msg.sender.transfer(owed);
            }

            owed = writers[_series][msg.sender] * exercisedPercent / 1 ether;
            owed = owed * series.strike / 1 ether;
            if (owed > 0) {
                require(usdERC20.transfer(msg.sender, owed));
            }
        } else {
            owed = writers[_series][msg.sender] * unsettledPercent / 1 ether;
            owed = owed * series.strike / 1 ether;
            if (owed > 0) {
                require(usdERC20.transfer(msg.sender, owed));
            }

            owed = writers[_series][msg.sender] * exercisedPercent / 1 ether;
            if (owed > 0) {
                msg.sender.transfer(owed);
            }
        }

        writers[_series][msg.sender] = 0;
    }

    function settle(address _series) public {
        OptionSeries memory series = seriesInfo[_series];
        require(now > series.expiration + DURATION);

        uint bal = ERC20x(_series).balanceOf(msg.sender);
        require(_series.call(BURN, msg.sender, bal));

        uint percent = bal * 1 ether / (totalInterest[_series] - earlyExercised[_series]);
        uint owed = holdersSettlement[_series] * percent / 1 ether;
        require(usdERC20.transfer(msg.sender, owed));
    }

    function _timePreference(address from) public view returns (uint) {
        return (_unsLn(_preference(from) * 1000000 + 1 ether) * 171) / 1 ether;
    }

    function _grantReward(address to, uint amount) private {
        uint percentOfMax = _preference(to) * 1 ether / PREFERENCE_MAX;
        require(percentOfMax <= 1 ether);
        uint percentGrant = 1 ether - percentOfMax;


        uint elapsed = (now - deployed) / 1 weeks;
        elapsed = _min(elapsed, 7);
        uint div = 10**elapsed;
        uint reward = percentGrant * (amount * (ONE_MILLION / div)) / 1 ether;

        require(address(protocolToken).call(GRANT, to, reward));
    }

    function _preference(address from) public view returns (uint) {
        return _min(
            protocolToken.balanceOf(from) * 1 ether / protocolToken.totalSupply(),
            PREFERENCE_MAX
        );
    }

    function _min(uint a, uint b) pure public returns (uint) {
        if (a > b)
            return b;
        return a;
    }

    function _max(uint a, uint b) pure public returns (uint) {
        if (a > b)
            return a;
        return b;
    }
    
    function _seriesHash(uint expiration, Flavor flavor, uint strike) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(expiration, flavor, strike));
    }

    function _monthName(uint month) public pure returns (string) {
        string[12] memory names = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        return names[month-1];
    }

    function _unsLn(uint x) pure public returns (uint log) {
        log = 0;
        
        // not a true ln function, we can't represent the negatives
        if (x < 1 ether)
            return 0;

        while (x >= 1.5 ether) {
            log += 0.405465 ether;
            x = x * 2 / 3;
        }
        
        x = x - 1 ether;
        uint y = x;
        uint i = 1;

        while (i < 10) {
            log += (y / i);
            i = i + 1;
            y = y * x / 1 ether;
            log -= (y / i);
            i = i + 1;
            y = y * x / 1 ether;
        }
         
        return(log);
    }

    function uint2str(uint i) internal pure returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
}