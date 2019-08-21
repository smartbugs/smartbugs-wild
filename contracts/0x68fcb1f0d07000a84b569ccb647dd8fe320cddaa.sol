pragma solidity ^0.4.17;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract CoinMarketCapApi {
    function requestPrice(string _ticker) public payable;
    function _cost() public returns (uint _price);
}

contract ERC20 {
    function transfer(address to, uint tokens) public returns (bool success);
}

contract DateTime {
    using SafeMath for uint;
    
    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    int constant OFFSET19700101 = 2440588;
    
    function _timestampToDate(uint256 _timestamp) internal pure returns (uint year, uint month, uint day) {
        uint _days = _timestamp / SECONDS_PER_DAY;
        int __days = int(_days);
        
        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;
        
        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }
    
    function isLeapYear(uint year) internal pure returns (bool) {
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
    
    function getDaysInMonth(uint month, uint year, uint _addMonths) internal pure returns (uint) {
        if(_addMonths > 0){
            (month, year) = addMonth(month, year, _addMonths);
        }
        
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
    
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {
        require(fromTimestamp <= toTimestamp);
        uint fromYear;
        uint fromMonth;
        uint fromDay;
        uint toYear;
        uint toMonth;
        uint toDay;
        (fromYear, fromMonth, fromDay) = _timestampToDate(fromTimestamp);
        (toYear, toMonth, toDay) = _timestampToDate(toTimestamp);
        
        _months = (((toYear.mul(12)).add(toMonth)).sub(fromYear.mul(12))).sub(fromMonth);
    }
    
    function addMonth(uint _month, uint _year, uint _add) internal pure returns (uint _nwMonth, uint _nwYear) {
        require(_add < 12);
        
        if(_month + _add > 12){
            _nwYear = _year + 1;
            _nwMonth = 1;
        } else {
            _nwMonth = _month + _add;
            _nwYear = _year;
        }
    }
}

contract initLib is DateTime {
    using SafeMath for uint;
    
    string  public symbol = "OWT";
    uint256 public decimals = 18;
    address public tokenAddress;
    uint256 public tokenPrice = 150000;
    
    uint256 public domainCost = 500; 
    uint256 public publishCost = 200; 
    uint256 public hostRegistryCost = 1000; 
    uint256 public userSurfingCost = 10; 
    uint256 public registryDuration = 365 * 1 days;
    uint256 public stakeLockTime = 31 * 1 days;
    
    uint public websiteSizeLimit = 512;
    uint public websiteFilesLimit = 20;
    
    address public ow_owner;
    address public cmcAddress;
    uint public lastPriceUpdate;
    
    mapping ( address => uint256 ) public balanceOf;
    mapping ( address => uint256 ) public stakeBalance;
    mapping ( uint => mapping ( uint => uint256 )) public poolBalance;
    mapping ( uint => mapping ( uint => uint256 )) public poolBalanceClaimed;
    mapping ( uint => mapping ( uint => uint256 )) public totalStakes;
    
    uint256 public totalSubscriber;
    uint256 public totalHosts;
    uint256 public totalDomains;
    
    mapping ( address => UserMeta ) public users;
    mapping ( bytes32 => DomainMeta ) public domains;
    mapping ( bytes32 => DomainSaleMeta ) public domain_sale;
    mapping ( address => HostMeta ) public hosts;
    mapping ( uint => address ) public hostAddress;
    mapping ( uint => bytes32 ) public hostConnection;
    mapping ( bytes32 => bool ) public hostConnectionDB;
    
    mapping ( uint => mapping ( uint => mapping ( address => uint256 ) )) public hostStakes;
    mapping ( uint => mapping ( uint => mapping ( address => uint256 ) )) public stakeTmpBalance;
    mapping ( address => uint256 ) public stakesLockups;
    
    mapping ( uint => uint ) public hostUpdates;
    uint public hostUpdatesCounter;
    
    mapping ( uint => string ) public websiteUpdates;
    uint public websiteUpdatesCounter;
    
    struct DomainMeta {
        string name;
        uint admin_index;
        uint total_admins;
        mapping(uint => mapping(address => bool)) admins;
        string git;
        bytes32 domain_bytes;
        bytes32 hash;
        uint total_files;
        uint version;
        mapping(uint => mapping(bytes32 => bytes32)) files_hash;
        uint ttl;
        uint time;
        uint expity_time;
    }
    
    struct DomainSaleMeta {
        address owner;
        address to;
        uint amount;
        uint time;
        uint expity_time;
    }
    
    struct HostMeta {
        uint id;
        address hostAddress;
        bytes32 connection;
        bool active;
        uint start_time;
        uint time;
    }
    
    struct UserMeta {
        bool active;
        uint start_time;
        uint expiry_time;
        uint time;
    }
    
    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function setOwOwner(address _address) public {
        require(msg.sender == ow_owner);
        ow_owner = _address;
    }
    
    function _currentPrice(uint256 _price) public view returns (uint256 _getprice) {
        _getprice = (_price * 10**uint(24)) / tokenPrice;
    }
    
    function __response(uint _price) public {
        require(msg.sender == cmcAddress);
        tokenPrice = _price;
    }
    
    function fetchTokenPrice() public payable {
        require(
            lastPriceUpdate + 1 * 1 days <  now
        );
        
        lastPriceUpdate = now;
        uint _getprice = CoinMarketCapApi(cmcAddress)._cost();
        CoinMarketCapApi(cmcAddress).requestPrice.value(_getprice)(symbol);
    }
    
    function _priceFetchingCost() public view returns (uint _getprice) {
        _getprice = CoinMarketCapApi(cmcAddress)._cost();
    }
    
    function debitToken(uint256 _amount) internal {
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        balanceOf[ow_owner] = balanceOf[ow_owner].add(_amount);
    }
    
    function creditUserPool(uint _duration, uint256 _price) internal {
        uint _monthDays; uint _remainingDays; 
        uint _year; uint _month; uint _day; 
        (_year, _month, _day) = _timestampToDate(now);
        
        _day--;
        uint monthDiff = diffMonths(now, now + ( _duration * 1 days )) + 1;
        
        for(uint i = 0; i < monthDiff; i++) {
            _monthDays = getDaysInMonth(_month, _year, 0); 
            
            if(_day.add(_duration) > _monthDays){ 
                _remainingDays = _monthDays.sub(_day);
                balanceOf[address(0x0)] = balanceOf[address(0x0)].add((_remainingDays * _price * 10) / 100);
                poolBalance[_year][_month] = poolBalance[_year][_month].add((_remainingDays * _price * 90) / 100);
                
                (_month, _year) = addMonth(_month, _year, 1);
                
                _duration = _duration.sub(_remainingDays);
                _day = 0;
                
            } else {
                balanceOf[address(0x0)] = balanceOf[address(0x0)].add((_duration * _price * 10) / 100);
                poolBalance[_year][_month] = poolBalance[_year][_month].add((_duration * _price * 90) / 100);
            }
            
        }
    }
}

contract owContract is initLib {
    
    function owContract(address _token, address _cmc) public {
        tokenAddress = _token;
        ow_owner = msg.sender;
        cmcAddress = _cmc;
    }
    
    function _validateDomain(string _domain) internal pure returns (bool){
        bytes memory b = bytes(_domain);
        if(b.length > 32) return false;
        
        uint counter = 0;
        for(uint i; i<b.length; i++){
            bytes1 char = b[i];
            
            if(
                !(char >= 0x30 && char <= 0x39)   //9-0
                && !(char >= 0x61 && char <= 0x7A)  //a-z
                && !(char == 0x2D) // - 
                && !(char == 0x2E && counter == 0) // . 
            ){
                    return false;
            }
            
            if(char == 0x2E) counter++; 
        }
    
        return true;
    }
    
    function registerDomain(string _domain, uint _ttl) public returns (bool _status) {
        bytes32 _domainBytes = stringToBytes32(_domain);
        DomainMeta storage d = domains[_domainBytes];
        uint256 _cPrice = _currentPrice(domainCost);
        
        require(
            d.expity_time < now 
            && _ttl >= 1 hours 
            && balanceOf[msg.sender] >= _cPrice 
            && _validateDomain(_domain)
        );
        
        debitToken(_cPrice);
        uint _adminIndex = d.admin_index + 1;
        
        if(d.expity_time == 0){
            totalDomains++;
        }
        
        d.name = _domain;
        d.domain_bytes = _domainBytes;
        d.admin_index = _adminIndex;
        d.total_admins = 1;
        d.admins[_adminIndex][msg.sender] = true;
        d.ttl = _ttl;
        d.expity_time = now + registryDuration;
        d.time = now;
        
        _status = true;
    }
    
    function updateDomainTTL(string _domain, uint _ttl) public returns (bool _status) {
        bytes32 _domainBytes = stringToBytes32(_domain);
        DomainMeta storage d = domains[_domainBytes];
        require(
            d.admins[d.admin_index][msg.sender] 
            && _ttl >= 1 hours 
            && d.expity_time > now
        );
        
        d.ttl = _ttl;
        _status = true;
    }
    
    function renewDomain(string _domain) public returns (bool _status) {
        bytes32 _domainBytes = stringToBytes32(_domain);
        DomainMeta storage d = domains[_domainBytes];
        uint256 _cPrice = _currentPrice(domainCost);
        
        require(
            d.expity_time > now 
            && balanceOf[msg.sender] >= _cPrice
        );
        
        debitToken(_cPrice);
        d.expity_time = d.expity_time.add(registryDuration);
        
        _status = true;
    }
    
    function addDomainAdmin(string _domain, address _admin) public returns (bool _status) {
        bytes32 _domainBytes = stringToBytes32(_domain);
        DomainMeta storage d = domains[_domainBytes];
        require(
            d.admins[d.admin_index][msg.sender] 
            && !d.admins[d.admin_index][_admin]
            && d.expity_time > now
        );
        
        d.total_admins = d.total_admins.add(1);
        d.admins[d.admin_index][_admin] = true;
        
        _status = true;
    }
    
    function removeDomainAdmin(string _domain, address _admin) public returns (bool _status) {
        bytes32 _domainBytes = stringToBytes32(_domain);
        DomainMeta storage d = domains[_domainBytes];
        require(
            d.admins[d.admin_index][msg.sender] 
            && d.admins[d.admin_index][_admin] 
            && d.expity_time > now
        );
        
        d.total_admins = d.total_admins.sub(1);
        d.admins[d.admin_index][_admin] = false;
        
        _status = true;
    }
    
    function sellDomain(
        string _domain, 
        address _owner, 
        address _to, 
        uint256 _amount, 
        uint _expiry
    ) public returns (bool _status) {
        bytes32 _domainBytes = stringToBytes32(_domain);
        uint _sExpiry = now + ( _expiry * 1 days );
        
        DomainMeta storage d = domains[_domainBytes];
        DomainSaleMeta storage ds = domain_sale[_domainBytes];
        
        require(
            _amount > 0
            && d.admins[d.admin_index][msg.sender] 
            && d.expity_time > _sExpiry 
            && ds.expity_time < now
        );
        
        ds.owner = _owner;
        ds.to = _to;
        ds.amount = _amount;
        ds.time = now;
        ds.expity_time = _sExpiry;
        
        _status = true;
    }
    
    function cancelSellDomain(string _domain) public returns (bool _status) {
        bytes32 _domainBytes = stringToBytes32(_domain);
        DomainMeta storage d = domains[_domainBytes];
        DomainSaleMeta storage ds = domain_sale[_domainBytes];
        
        require(
            d.admins[d.admin_index][msg.sender] 
            && d.expity_time > now 
            && ds.expity_time > now
        );
        
        ds.owner = address(0x0);
        ds.to = address(0x0);
        ds.amount = 0;
        ds.time = 0;
        ds.expity_time = 0;
        
        _status = true;
    }
    
    function buyDomain(string _domain) public returns (bool _status) {
        bytes32 _domainBytes = stringToBytes32(_domain);
        DomainMeta storage d = domains[_domainBytes];
        DomainSaleMeta storage ds = domain_sale[_domainBytes];
        
        if(ds.to != address(0x0)){
            require( ds.to == msg.sender );
        }
        
        require(
            balanceOf[msg.sender] >= ds.amount 
            && d.expity_time > now 
            && ds.expity_time > now
        );
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(ds.amount);
        balanceOf[ds.owner] = balanceOf[ds.owner].add(ds.amount);
        
        uint _adminIndex = d.admin_index + 1;
        
        d.total_admins = 1;
        d.admin_index = _adminIndex;
        d.admins[_adminIndex][msg.sender] = true;
        ds.expity_time = 0;
        
        _status = true;
    }
    
    function publishWebsite(
        string _domain, 
        string _git, 
        bytes32 _filesHash,
        bytes32[] _file_name, 
        bytes32[] _file_hash
    ) public returns (bool _status) {
        bytes32 _domainBytes = stringToBytes32(_domain);
        DomainMeta storage d = domains[_domainBytes];
        uint256 _cPrice = _currentPrice(publishCost);
        
        require(
            d.admins[d.admin_index][msg.sender] 
            && balanceOf[msg.sender] >= _cPrice 
            && _file_name.length <= websiteFilesLimit 
            && _file_name.length == _file_hash.length
            && d.expity_time > now
        );
        
        debitToken(_cPrice);
        d.version++;
        
        for(uint i = 0; i < _file_name.length; i++) {
            d.files_hash[d.version][_file_name[i]] = _file_hash[i];
        }
        
        d.git = _git;
        d.total_files = _file_name.length;
        d.hash = _filesHash;
        
        websiteUpdates[websiteUpdatesCounter] = _domain;
        websiteUpdatesCounter++;
        
        _status = true;
    }
    
    function getDomainMeta(string _domain) public view 
        returns (
            string _name,  
            string _git, 
            bytes32 _domain_bytes, 
            bytes32 _hash, 
            uint _total_admins,
            uint _adminIndex, 
            uint _total_files, 
            uint _version, 
            uint _ttl, 
            uint _time, 
            uint _expity_time
        )
    {
        bytes32 _domainBytes = stringToBytes32(_domain);
        DomainMeta storage d = domains[_domainBytes];
        
        _name = d.name;
        _git = d.git;
        _domain_bytes = d.domain_bytes;
        _hash = d.hash;
        _total_admins = d.total_admins;
        _adminIndex = d.admin_index;
        _total_files = d.total_files;
        _version = d.version;
        _ttl = d.ttl;
        _time = d.time;
        _expity_time = d.expity_time;
    }
    
    function getDomainFileHash(string _domain, bytes32 _file_name) public view 
        returns ( 
            bytes32 _hash
        )
    {
        bytes32 _domainBytes = stringToBytes32(_domain);
        DomainMeta storage d = domains[_domainBytes];
        
        _hash = d.files_hash[d.version][_file_name];
    }
    
    function verifyDomainFileHash(string _domain, bytes32 _file_name, bytes32 _file_hash) public view 
        returns ( 
            bool _status
        )
    {
        bytes32 _domainBytes = stringToBytes32(_domain);
        DomainMeta storage d = domains[_domainBytes];
        
        _status = ( d.files_hash[d.version][_file_name] == _file_hash );
    }
    
    function registerHost(string _connection) public returns (bool _status) {
        bytes32 hostConn = stringToBytes32(_connection);
        HostMeta storage h = hosts[msg.sender];
        uint256 _cPrice = _currentPrice(hostRegistryCost);
        
        require(
            !h.active 
            && balanceOf[msg.sender] >= _cPrice 
            && !hostConnectionDB[hostConn]
        );
        
        debitToken(_cPrice);
        
        h.id = totalHosts;
        h.connection = hostConn;
        h.active = true;
        h.time = now;
        
        hostAddress[totalHosts] = msg.sender;
        hostConnection[totalHosts] = h.connection;
        hostConnectionDB[hostConn] = true;
        totalHosts++;
        
        _status = true;
    }
    
    function updateHost(string _connection) public returns (bool _status) {
        bytes32 hostConn = stringToBytes32(_connection);
        HostMeta storage h = hosts[msg.sender];
        
        require(
            h.active 
            && h.connection != hostConn 
            && !hostConnectionDB[hostConn]
        );
        
        hostConnectionDB[h.connection] = false;
        h.connection = hostConn;
        
        hostConnectionDB[hostConn] = true;
        hostUpdates[hostUpdatesCounter] = h.id;
        hostConnection[h.id] = hostConn;
        hostUpdatesCounter++;
        
        _status = true;
    }
    
    function userSubscribe(uint _duration) public {
        uint256 _cPrice = _currentPrice(userSurfingCost);
        uint256 _cost = _duration * _cPrice;
        
        require(
            _duration < 400 
            && _duration > 0
            && balanceOf[msg.sender] >= _cost
        );
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_cost);
        creditUserPool(_duration, _cPrice);
        
        UserMeta storage u = users[msg.sender];
        if(!u.active){
            u.active = true;
            u.time = now;
            
            totalSubscriber++;
        }
        
        if(u.expiry_time < now){
            u.start_time = now;
            u.expiry_time = now + (_duration * 1 days);
        } else {
            u.expiry_time = u.expiry_time.add(_duration * 1 days);
        }
    }
    
    function stakeTokens(address _hostAddress, uint256 _amount) public {
        require( balanceOf[msg.sender] >= _amount );
        
        uint _year; uint _month; uint _day; 
        (_year, _month, _day) = _timestampToDate(now);
        
        HostMeta storage h = hosts[_hostAddress];
        require( h.active );
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        stakeBalance[msg.sender] = stakeBalance[msg.sender].add(_amount);
        stakeTmpBalance[_year][_month][msg.sender] = stakeTmpBalance[_year][_month][msg.sender].add(_amount);
        
        stakesLockups[msg.sender] = now + stakeLockTime;
        
        hostStakes[_year][_month][_hostAddress] = hostStakes[_year][_month][_hostAddress].add(_amount);
        totalStakes[_year][_month] = totalStakes[_year][_month].add(_amount);
    }
    
    function validateMonth(uint _year, uint _month) internal view {
        uint __year; uint __month; uint __day; 
        (__year, __month, __day) = _timestampToDate(now);
        if(__month == 1){ __year--; __month = 12; } else { __month--; }
        
        require( (((__year.mul(12)).add(__month)).sub(_year.mul(12))).sub(_month) >= 0 );
    }
    
    function claimHostTokens(uint _year, uint _month) public {
        validateMonth(_year, _month);
        
        HostMeta storage h = hosts[msg.sender];
        require( h.active );
        
        if(totalStakes[_year][_month] > 0){
            uint256 _tmpHostStake = hostStakes[_year][_month][msg.sender];
            
            if(_tmpHostStake > 0){
                uint256 _totalStakes = totalStakes[_year][_month];
                uint256 _poolAmount = poolBalance[_year][_month];
                
                hostStakes[_year][_month][msg.sender] = 0;
                uint256 _amount = ((_tmpHostStake.mul(_poolAmount)).mul(50)).div(_totalStakes.mul(100));
                if(_amount > 0){
                    balanceOf[msg.sender] = balanceOf[msg.sender].add(_amount);
                    poolBalanceClaimed[_year][_month] = poolBalanceClaimed[_year][_month].add(_amount);
                }
            }
        }
    }
    
    function claimStakeTokens(uint _year, uint _month) public {
        validateMonth(_year, _month);
        require(stakesLockups[msg.sender] < now);
        
        if(totalStakes[_year][_month] > 0){
            uint256 _tmpStake = stakeTmpBalance[_year][_month][msg.sender];
            
            if(_tmpStake > 0){
                uint256 _totalStakesBal = stakeBalance[msg.sender];
                
                uint256 _totalStakes = totalStakes[_year][_month];
                uint256 _poolAmount = poolBalance[_year][_month];
                
                uint256 _amount = ((_tmpStake.mul(_poolAmount)).mul(50)).div(_totalStakes.mul(100));
                
                stakeTmpBalance[_year][_month][msg.sender] = 0;
                stakeBalance[msg.sender] = 0;
                uint256 _totamount = _amount.add(_totalStakesBal);
                
                if(_totamount > 0){
                    balanceOf[msg.sender] = balanceOf[msg.sender].add(_totamount);
                    poolBalanceClaimed[_year][_month] = poolBalanceClaimed[_year][_month].add(_amount);
                }
            }
        }
    }
    
    function getHostTokens(address _address, uint _year, uint _month) public view returns (uint256 _amount) {
        validateMonth(_year, _month);
        
        HostMeta storage h = hosts[_address];
        require( h.active );
        
        _amount = 0;
        if(h.active && totalStakes[_year][_month] > 0){
            uint256 _tmpHostStake = hostStakes[_year][_month][_address];
            
            if(_tmpHostStake > 0){
                uint256 _totalStakes = totalStakes[_year][_month];
                uint256 _poolAmount = poolBalance[_year][_month];
                
                _amount = ((_tmpHostStake.mul(_poolAmount)).mul(50)).div(_totalStakes.mul(100));
            }
        }
    }
    
    function getStakeTokens(address _address, uint _year, uint _month) public view returns (uint256 _amount) {
        validateMonth(_year, _month);
        require(stakesLockups[_address] < now);
        
        _amount = 0;
        if(stakesLockups[_address] < now && totalStakes[_year][_month] > 0){
            uint256 _tmpStake = stakeTmpBalance[_year][_month][_address];
            
            if(_tmpStake > 0){
                uint256 _totalStakesBal = stakeBalance[_address];
                
                uint256 _totalStakes = totalStakes[_year][_month];
                uint256 _poolAmount = poolBalance[_year][_month];
                
                _amount = ((_tmpStake.mul(_poolAmount)).mul(50)).div(_totalStakes.mul(100));
                _amount = _amount.add(_totalStakesBal);
            }
        }
    }
    
    function burnPoolTokens(uint _year, uint _month) public {
        validateMonth(_year, _month);
        
        if(totalStakes[_year][_month] == 0){
            uint256 _poolAmount = poolBalance[_year][_month];
            
            if(_poolAmount > 0){
                poolBalance[_year][_month] = 0;
                balanceOf[address(0x0)] = balanceOf[address(0x0)].add(_poolAmount);
            }
        }
    }
    
    function poolDonate(uint _year, uint _month, uint256 _amount) public {
        require(
            _amount > 0
            && balanceOf[msg.sender] >= _amount
        );
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        
        balanceOf[address(0x0)] = balanceOf[address(0x0)].add((_amount * 10) / 100);
        poolBalance[_year][_month] = poolBalance[_year][_month].add((_amount * 90) / 100);
    }
    
    function internalTransfer(address _to, uint256 _value) public returns (bool success) {
        require(
            _value > 0
            && balanceOf[msg.sender] >= _value
        );
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        
        return true;
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(
            _value > 0
            && balanceOf[msg.sender] >= _value
        );
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        ERC20(tokenAddress).transfer(_to, _value);
        
        return true;
    }
    
    function burn() public {
        uint256 _amount = balanceOf[address(0x0)];
        require( _amount > 0 );
        
        balanceOf[address(0x0)] = 0;
        ERC20(tokenAddress).transfer(address(0x0), _amount);
    }
    
    function notifyBalance(address sender, uint tokens) public {
        require(
            msg.sender == tokenAddress
        );
        
        balanceOf[sender] = balanceOf[sender].add(tokens);
    }
    
    function () public payable {} 
}