pragma solidity ^0.4.24;

/*
*__/\\\\____________/\\\\________________/\\\\____________/\\\\________/\\\\\\_____/\\\\\\___________________________________________________
* _\/\\\\\\________/\\\\\\_______________\/\\\\\\________/\\\\\\_______\////\\\____\////\\\___________________________________________________
*  _\/\\\//\\\____/\\\//\\\____/\\\__/\\\_\/\\\//\\\____/\\\//\\\__/\\\____\/\\\_______\/\\\_____/\\\__________________________________________
*   _\/\\\\///\\\/\\\/_\/\\\___\//\\\/\\\__\/\\\\///\\\/\\\/_\/\\\_\///_____\/\\\_______\/\\\____\///______/\\\\\_____/\\/\\\\\\____/\\\\\\\\\\_
*    _\/\\\__\///\\\/___\/\\\____\//\\\\\___\/\\\__\///\\\/___\/\\\__/\\\____\/\\\_______\/\\\_____/\\\___/\\\///\\\__\/\\\////\\\__\/\\\//////__
*     _\/\\\____\///_____\/\\\_____\//\\\____\/\\\____\///_____\/\\\_\/\\\____\/\\\_______\/\\\____\/\\\__/\\\__\//\\\_\/\\\__\//\\\_\/\\\\\\\\\\_
*      _\/\\\_____________\/\\\__/\\_/\\\_____\/\\\_____________\/\\\_\/\\\____\/\\\_______\/\\\____\/\\\_\//\\\__/\\\__\/\\\___\/\\\_\////////\\\_
*       _\/\\\_____________\/\\\_\//\\\\/______\/\\\_____________\/\\\_\/\\\__/\\\\\\\\\__/\\\\\\\\\_\/\\\__\///\\\\\/___\/\\\___\/\\\__/\\\\\\\\\\_
*        _\///______________\///___\////________\///______________\///__\///__\/////////__\/////////__\///_____\/////_____\///____\///__\//////////__
*/

contract Ownable {
    address public owner;
    address public developers = 0x0c05aE835f26a8d4a89Ae80c7A0e5495e5361ca1;
    address public marketers = 0xE222Dd2DD012FCAC0256B1f3830cc033418B6889;
    uint256 public constant developersPercent = 1;
    uint256 public constant marketersPercent = 14;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event DevelopersChanged(address indexed previousDevelopers, address indexed newDevelopers);
    event MarketersChanged(address indexed previousMarketers, address indexed newMarketers);

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyThisOwner(address _owner) {
        require(owner == _owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function setDevelopers(address newDevelopers) public onlyOwner {
        require(newDevelopers != address(0));
        emit DevelopersChanged(developers, newDevelopers);
        developers = newDevelopers;
    }

    function setMarketers(address newMarketers) public onlyOwner {
        require(newMarketers != address(0));
        emit MarketersChanged(marketers, newMarketers);
        marketers = newMarketers;
    }

}

library SafeMath {
    function mul(uint256 _a, uint256 _b) internal pure returns(uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns(uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b != 0);
        return a % b;
    }
}

library Math {
    function max(uint a, uint b) returns (uint) {
        if (a > b) return a;
        else return b;
    }
    function min(uint a, uint b) returns (uint) {
        if (a < b) return a;
        else return b;
    }
}

contract LeaderSystem {
    using SafeMath for uint256;

    event NewLeader(uint256 _indexTable, address _addr, uint256 _index, uint256 _sum);
    event LeadersClear(uint256 _indexTable);

    uint8 public constant leadersCount = 7;
    mapping (uint8 => uint256) public leaderBonuses;

    struct LeadersTable {
        uint256 timestampEnd;              // timestamp of closing table
        uint256 duration;                   // duration compute
        uint256 minSum;                     // min sum of leaders
        address[] leaders;                  // leaders array
        mapping (address => uint256) users; // sum all users
    }

    LeadersTable[] public leaders;

    function setupLeaderSystemModule() internal {
        leaderBonuses[0] = 10;  // 10%
        leaderBonuses[1] = 7;   // 7%
        leaderBonuses[2] = 5;   // 5%
        leaderBonuses[3] = 3;   // 3%
        leaderBonuses[4] = 1;   // 1%
        leaderBonuses[5] = 0;   // 0%
        leaderBonuses[6] = 0;   // 0%

        leaders.push(LeadersTable(now + 86400, 86400, 0, new address[](0)));
        leaders.push(LeadersTable(now + 604800, 604800, 0, new address[](0)));
        leaders.push(LeadersTable(now + 77760000, 77760000, 0, new address[](0)));
        leaders.push(LeadersTable(now + 31536000, 31536000, 0, new address[](0)));
    }

    function _clearLeadersTable(uint256 _indexTable) internal {
        LeadersTable storage _leader = leaders[_indexTable];
        leaders[_indexTable] = LeadersTable(_leader.timestampEnd + _leader.duration, _leader.duration, 0, new address[](0));

        emit LeadersClear(_indexTable);
    }

    function quickSort(LeadersTable storage leader, int left, int right) internal {
        int i = left;
        int j = right;
        if (i == j) return;
        uint pivot = leader.users[leader.leaders[uint(left + (right - left) / 2)]];
        while (i <= j) {
            while (leader.users[leader.leaders[uint(i)]] > pivot) i++;
            while (pivot > leader.users[leader.leaders[uint(j)]]) j--;
            if (i <= j) {
                (leader.leaders[uint(i)], leader.leaders[uint(j)]) = (leader.leaders[uint(j)], leader.leaders[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(leader, left, j);
        if (i < right)
            quickSort(leader, i, right);
    }

    function _updateLeadersTable(uint256 i, address _addr, uint256 _value) internal {
        if (now > leaders[i].timestampEnd) _clearLeadersTable(i);

        LeadersTable storage leader = leaders[i];
        bool isExist = leader.users[_addr] >= leader.minSum;

        uint256 oldSum = leader.users[_addr];
        uint256 newSum = oldSum.add(_value);
        leader.users[_addr] = newSum;

        if (newSum < leader.minSum && leader.leaders.length == leadersCount) return;

        if (!isExist || leader.leaders.length == 0) leader.leaders.push(_addr);

        if (leader.leaders.length > 1) quickSort(leader, 0, int256(leader.leaders.length - 1));
        if (leader.leaders.length > leadersCount) {
            delete leader.leaders[leadersCount - 1];
        }

        leader.minSum = leader.users[leader.leaders[leader.leaders.length - 1]];
    }

    function _updateLeaders(address _addr, uint256 _value) internal {
        for (uint i = 0; i < leaders.length; i++) {
            _updateLeadersTable(i, _addr, _value);
        }
    }

    function getLeadersTableInfo(uint256 _indexTable) public view returns(uint256, uint256, uint256) {
        return (leaders[_indexTable].timestampEnd, leaders[_indexTable].duration, leaders[_indexTable].minSum);
    }

    function getLeaders(uint256 _indexTable) public view returns(address[], uint256[]) {
        LeadersTable storage leader = leaders[_indexTable];
        uint256[] memory balances = new uint256[](leader.leaders.length);

        for (uint i = 0; i < leader.leaders.length; i++) {
            balances[i] = leader.users[leader.leaders[i]];
        }

        return (leader.leaders, balances);
    }

}

contract Factoring {

    enum FactoryType { Wood, Metal, Oil, PreciousMetal }

    mapping (uint8 => uint256) public resourcePrices;

    function setupFactoringModule() internal {
        resourcePrices[uint8(FactoryType.Wood)]         = 0.02315 szabo;
        resourcePrices[uint8(FactoryType.Metal)]        = 0.03646 szabo;
        resourcePrices[uint8(FactoryType.Oil)]          = 0.04244 szabo;
        resourcePrices[uint8(FactoryType.PreciousMetal)]= 0.06655 szabo;
    }

    function getResourcePrice(uint8 _type) public view returns(uint256) {
        return resourcePrices[_type];
    }

}

contract Improvements is Factoring {

    mapping (uint8 => mapping (uint8 => Params)) public levelStack;
    uint8 public constant levelsCount = 7;

    struct Params {
        uint256 price;      // improvements cost
        uint256 ppm;        // products per minute
        uint256 ppmBonus;   // bonus per minute
    }

    function setupImprovementsModule() internal {
        // initial pricess
        levelStack[uint8(FactoryType.Wood)][0]          = Params(0.01 ether, 200, 0);
        levelStack[uint8(FactoryType.Metal)][0]         = Params(0.03 ether, 400, 0);
        levelStack[uint8(FactoryType.Oil)][0]           = Params(0.05 ether, 600, 0);
        levelStack[uint8(FactoryType.PreciousMetal)][0] = Params(0.10 ether, 800, 0);

        // level 1
        levelStack[uint8(FactoryType.Wood)][1]          = Params(0.05 ether, 1200, 120);
        levelStack[uint8(FactoryType.Metal)][1]         = Params(0.09 ether, 1600, 138);
        levelStack[uint8(FactoryType.Oil)][1]           = Params(0.15 ether, 2400, 164);
        levelStack[uint8(FactoryType.PreciousMetal)][1] = Params(0.50 ether, 4800, 418);

        // level 2
        levelStack[uint8(FactoryType.Wood)][2]          = Params(0.12 ether, 3600, 540);
        levelStack[uint8(FactoryType.Metal)][2]         = Params(0.27 ether, 5200, 866);
        levelStack[uint8(FactoryType.Oil)][2]           = Params(0.35 ether, 6600, 1050);
        levelStack[uint8(FactoryType.PreciousMetal)][2] = Params(1.00 ether, 12800, 1670);

        // level 3
        levelStack[uint8(FactoryType.Wood)][3]          = Params(0.30 ether, 9600, 2400);
        levelStack[uint8(FactoryType.Metal)][3]         = Params(0.75 ether, 15200, 3980);
        levelStack[uint8(FactoryType.Oil)][3]           = Params(1.15 ether, 20400, 5099);
        levelStack[uint8(FactoryType.PreciousMetal)][3] = Params(3.50 ether, 40800, 11531);

        // level 4
        levelStack[uint8(FactoryType.Wood)][4]          = Params(0.90 ether, 27600, 9660);
        levelStack[uint8(FactoryType.Metal)][4]         = Params(2.13 ether, 43600, 15568);
        levelStack[uint8(FactoryType.Oil)][4]           = Params(3.00 ether, 56400, 17943);
        levelStack[uint8(FactoryType.PreciousMetal)][4] = Params(7.00 ether, 96800, 31567);

        // level 5
        levelStack[uint8(FactoryType.Wood)][5]          = Params(1.80 ether, 63600, 25440);
        levelStack[uint8(FactoryType.Metal)][5]         = Params(5.31 ether, 114400, 49022);
        levelStack[uint8(FactoryType.Oil)][5]           = Params(7.30 ether, 144000, 55629);
        levelStack[uint8(FactoryType.PreciousMetal)][5] = Params(17.10 ether, 233600, 96492);

        // level 6
        levelStack[uint8(FactoryType.Wood)][6]          = Params(5.40 ether, 171600, 85800);
        levelStack[uint8(FactoryType.Metal)][6]         = Params(13.89 ether, 298400, 158120);
        levelStack[uint8(FactoryType.Oil)][6]           = Params(24.45 ether, 437400, 218674);
        levelStack[uint8(FactoryType.PreciousMetal)][6] = Params(55.50 ether, 677600, 353545);
    }

    function getPrice(FactoryType _type, uint8 _level) public view returns(uint256) {
        return levelStack[uint8(_type)][_level].price;
    }

    function getProductsPerMinute(FactoryType _type, uint8 _level) public view returns(uint256) {
        return levelStack[uint8(_type)][_level].ppm;
    }

    function getBonusPerMinute(FactoryType _type, uint8 _level) public view returns(uint256) {
        return levelStack[uint8(_type)][_level].ppmBonus;
    }
}

contract ReferralsSystem {

    struct ReferralGroup {
        uint256 minSum;
        uint256 maxSum;
        uint16[] percents;
    }

    uint256 public constant minSumReferral = 0.01 ether;
    uint256 public constant referralLevelsGroups = 3;
    uint256 public constant referralLevelsCount = 5;
    ReferralGroup[] public referralGroups;

    function setupReferralsSystemModule() internal {
        ReferralGroup memory refGroupFirsty = ReferralGroup(minSumReferral, 10 ether - 1 wei, new uint16[](referralLevelsCount));
        refGroupFirsty.percents[0] = 300;   // 3%
        refGroupFirsty.percents[1] = 75;    // 0.75%
        refGroupFirsty.percents[2] = 60;    // 0.6%
        refGroupFirsty.percents[3] = 40;    // 0.4%
        refGroupFirsty.percents[4] = 25;    // 0.25%
        referralGroups.push(refGroupFirsty);

        ReferralGroup memory refGroupLoyalty = ReferralGroup(10 ether, 50 ether - 1 wei, new uint16[](referralLevelsCount));
        refGroupLoyalty.percents[0] = 500;  // 5%
        refGroupLoyalty.percents[1] = 200;  // 2%
        refGroupLoyalty.percents[2] = 150;  // 1.5%
        refGroupLoyalty.percents[3] = 100;  // 1%
        refGroupLoyalty.percents[4] = 50;   // 0.5%
        referralGroups.push(refGroupLoyalty);

        ReferralGroup memory refGroupUltraPremium = ReferralGroup(50 ether, 2**256 - 1, new uint16[](referralLevelsCount));
        refGroupUltraPremium.percents[0] = 700; // 7%
        refGroupUltraPremium.percents[1] = 300; // 3%
        refGroupUltraPremium.percents[2] = 250; // 2.5%
        refGroupUltraPremium.percents[3] = 150; // 1.5%
        refGroupUltraPremium.percents[4] = 100; // 1%
        referralGroups.push(refGroupUltraPremium);
    }

    function getReferralPercents(uint256 _sum) public view returns(uint16[]) {
        for (uint i = 0; i < referralLevelsGroups; i++) {
            ReferralGroup memory group = referralGroups[i];
            if (_sum >= group.minSum && _sum <= group.maxSum) return group.percents;
        }
    }

    function getReferralPercentsByIndex(uint256 _index) public view returns(uint16[]) {
        return referralGroups[_index].percents;
    }

}

/// @title Smart-contract of MyMillions ecosystem
/// @author Shagaleev Alexey
contract MyMillions is Ownable, Improvements, ReferralsSystem, LeaderSystem {
    using SafeMath for uint256;

    event CreateUser(uint256 _index, address _address, uint256 _balance);
    event ReferralRegister(uint256 _refferalId, uint256 _userId);
    event ReferrerDistribute(uint256 _userId, uint256 _referrerId, uint256 _sum);
    event Deposit(uint256 _userId, uint256 _value);
    event PaymentProceed(uint256 _userId, uint256 _factoryId, FactoryType _factoryType, uint256 _price);
    event CollectResources(FactoryType _type, uint256 _resources);
    event LevelUp(uint256 _factoryId, uint8 _newLevel, uint256 _userId, uint256 _price);
    event Sell(uint256 _userId, uint8 _type, uint256 _sum);

    bool isSetted = false;
    uint256 public minSumDeposit = 0.01 ether;

    struct User {
        address addr;                                   // user address
        uint256 balance;                                // balance of account
        uint256 totalPay;                               // sum of all input pay
        uint256 referrersReceived;                      // total deposit from referrals
        uint256[] resources;                            // collected resources
        uint256[] referrersByLevel;                     // referrers user ids
        mapping (uint8 => uint256[]) referralsByLevel;  // all referrals user ids
    }

    User[] public users;
    mapping (address => uint256) public addressToUser;
    uint256 public totalUsers = 0;
    uint256 public totalDeposit = 0;

    struct Factory {
        FactoryType ftype;      // factory type
        uint8 level;            // factory level
        uint256 collected_at;   // timestamp updated
    }

    Factory[] public factories;
    mapping (uint256 => uint256) public factoryToUser;
    mapping (uint256 => uint256[]) public userToFactories;

    modifier onlyExistingUser() {
        require(addressToUser[msg.sender] != 0);
        _;
    }
    modifier onlyNotExistingUser() {
        require(addressToUser[msg.sender] == 0);
        _;
    }

    constructor() public payable {
        users.push(User(0x0, 0, 0, 0, new uint256[](4), new uint256[](referralLevelsCount)));  // for find by addressToUser map
    }

    function setup() public onlyOwner {
        require(isSetted == false);
        isSetted = true;

        setupFactoringModule();
        setupImprovementsModule();
        setupReferralsSystemModule();
        setupLeaderSystemModule();
    }

    // @dev register for only new users with min pay
    /// @return id of new user
    function register() public payable onlyNotExistingUser returns(uint256) {
        require(addressToUser[msg.sender] == 0);

        uint256 index = users.push(User(msg.sender, msg.value, 0, 0, new uint256[](4), new uint256[](referralLevelsCount))) - 1;
        addressToUser[msg.sender] = index;
        totalUsers++;

        emit CreateUser(index, msg.sender, msg.value);
        return index;
    }


    /// @notice just registry by referral link
    /// @param _refId the ID of the user who gets the affiliate fee
    /// @return id of new user
    function registerWithRefID(uint256 _refId) public payable onlyNotExistingUser returns(uint256) {
        require(_refId < users.length);

        uint256 index = register();
        _updateReferrals(index, _refId);

        emit ReferralRegister(_refId, index);
        return index;
    }

    /// @notice update referrersByLevel and referralsByLevel of new user
    /// @param _newUserId the ID of the new user
    /// @param _refUserId the ID of the user who gets the affiliate fee
    function _updateReferrals(uint256 _newUserId, uint256 _refUserId) private {
        if (_newUserId == _refUserId) return;
        users[_newUserId].referrersByLevel[0] = _refUserId;

        for (uint i = 1; i < referralLevelsCount; i++) {
            uint256 _refId = users[_refUserId].referrersByLevel[i - 1];
            users[_newUserId].referrersByLevel[i] = _refId;
            users[_refId].referralsByLevel[uint8(i)].push(_newUserId);
        }

        users[_refUserId].referralsByLevel[0].push(_newUserId);
    }

    /// @notice distribute value of tx to referrers of user
    /// @param _userId the ID of the user who gets the affiliate fee
    /// @param _sum value of ethereum for distribute to referrers of user
    function _distributeReferrers(uint256 _userId, uint256 _sum) private {
        uint256[] memory referrers = users[_userId].referrersByLevel;

        for (uint i = 0; i < referralLevelsCount; i++) {
            uint256 referrerId = referrers[i];

            if (referrers[i] == 0) break;
            if (users[referrerId].totalPay < minSumReferral) continue;

            uint16[] memory percents = getReferralPercents(users[referrerId].totalPay);
            uint256 value = _sum * percents[i] / 10000;
            users[referrerId].balance = users[referrerId].balance.add(value);
            users[referrerId].referrersReceived = users[referrerId].referrersReceived.add(value);

            emit ReferrerDistribute(_userId, referrerId, value);
        }
    }

    /// @notice deposit ethereum for user
    /// @return balance value of user
    function deposit() public payable onlyExistingUser returns(uint256) {
        require(msg.value > minSumDeposit, "Deposit does not enough");
        uint256 userId = addressToUser[msg.sender];
        users[userId].balance = users[userId].balance.add(msg.value);
        totalDeposit += msg.value;

        // distribute
        _distributeInvestment(msg.value);
        _updateLeaders(msg.sender, msg.value);

        emit Deposit(userId, msg.value);
        return users[userId].balance;
    }

    /// @notice getter for balance of user
    /// @return balance value of user
    function balanceOf() public view returns (uint256) {
        return users[addressToUser[msg.sender]].balance;
    }

    /// @notice getter for resources of user
    /// @return resources value of user
    function resoucesOf() public view returns (uint256[]) {
        return users[addressToUser[msg.sender]].resources;
    }

    /// @notice getter for referrers of user
    /// @return array of referrers id
    function referrersOf() public view returns (uint256[]) {
        return users[addressToUser[msg.sender]].referrersByLevel;
    }

    /// @notice getter for referrals of user by level
    /// @param _level level of referrals user needed
    /// @return array of referrals id
    function referralsOf(uint8 _level) public view returns (uint256[]) {
        return users[addressToUser[msg.sender]].referralsByLevel[uint8(_level)];
    }

    /// @notice getter for extended information of user
    /// @param _userId id of user needed
    /// @return address of user
    /// @return balance of user
    /// @return totalPay of user
    /// @return array of resources user
    /// @return array of referrers id user
    function userInfo(uint256 _userId) public view returns(address, uint256, uint256, uint256, uint256[], uint256[]) {
        User memory user = users[_userId];
        return (user.addr, user.balance, user.totalPay, user.referrersReceived, user.resources, user.referrersByLevel);
    }

    /// @notice mechanics of buying any factory
    /// @param _type type of factory needed
    /// @return id of new factory
    function buyFactory(FactoryType _type) public payable onlyExistingUser returns (uint256) {
        uint256 userId = addressToUser[msg.sender];

        // if user not registered
        if (addressToUser[msg.sender] == 0)
            userId = register();

        return _paymentProceed(userId, Factory(_type, 0, now));
    }

    /// @notice get factories of user
    /// @param _user_id id of user
    /// @return array of id factory
    function getFactories(uint256 _user_id) public view returns (uint256[]) {
        return userToFactories[_user_id];
    }

    /// @notice buy wood factory
    /// @dev wrapper over buyFactory for FactoryType.Wood
    /// @return id of new factory
    function buyWoodFactory() public payable returns (uint256) {
        return buyFactory(FactoryType.Wood);
    }

    /// @notice buy wood factory
    /// @dev wrapper over buyFactory for FactoryType.Metal
    /// @return id of new factory
    function buyMetalFactory() public payable returns (uint256) {
        return buyFactory(FactoryType.Metal);
    }

    /// @notice buy wood factory
    /// @dev wrapper over buyFactory for FactoryType.Oil
    /// @return id of new factory
    function buyOilFactory() public payable returns (uint256) {
        return buyFactory(FactoryType.Oil);
    }

    /// @notice buy wood factory
    /// @dev wrapper over buyFactory for FactoryType.PreciousMetal
    /// @return id of new factory
    function buyPreciousMetal() public payable returns (uint256) {
        return buyFactory(FactoryType.PreciousMetal);
    }

    /// @notice distribute investment when user buy anything
    /// @param _value value of investment
    function _distributeInvestment(uint256 _value) private {
        developers.transfer(msg.value * developersPercent / 100);
        marketers.transfer(msg.value * marketersPercent / 100);
    }

    /// @notice function of proceed payment
    /// @dev for only buy new factory
    /// @return id of new factory
    function _paymentProceed(uint256 _userId, Factory _factory) private returns(uint256) {
        User storage user = users[_userId];

        require(_checkPayment(user, _factory.ftype, _factory.level));

        uint256 price = getPrice(_factory.ftype, 0);
        user.balance = user.balance.add(msg.value);
        user.balance = user.balance.sub(price);
        user.totalPay = user.totalPay.add(price);
        totalDeposit += msg.value;

        uint256 index = factories.push(_factory) - 1;
        factoryToUser[index] = _userId;
        userToFactories[_userId].push(index);

        // distribute
        _distributeInvestment(msg.value);
        _distributeReferrers(_userId, price);
        _updateLeaders(msg.sender, msg.value);

        emit PaymentProceed(_userId, index, _factory.ftype, price);
        return index;
    }

    /// @notice check available investment
    /// @return true if user does enough balance for investment
    function _checkPayment(User _user, FactoryType _type, uint8 _level) private view returns(bool) {
        uint256 totalBalance = _user.balance.add(msg.value);

        if (totalBalance < getPrice(_type, _level)) return false;

        return true;
    }

    /// @notice level up for factory
    /// @param _factoryId id of factory
    function levelUp(uint256 _factoryId) public payable onlyExistingUser {
        Factory storage factory = factories[_factoryId];
        uint256 price = getPrice(factory.ftype, factory.level + 1);

        uint256 userId = addressToUser[msg.sender];
        User storage user = users[userId];

        require(_checkPayment(user, factory.ftype, factory.level + 1));

        // payment
        user.balance = user.balance.add(msg.value);
        user.balance = user.balance.sub(price);
        user.totalPay = user.totalPay.add(price);
        totalDeposit += msg.value;

        _distributeInvestment(msg.value);
        _distributeReferrers(userId, price);

        // collect
        _collectResource(factory, user);
        factory.level++;

        _updateLeaders(msg.sender, msg.value);

        emit LevelUp(_factoryId, factory.level, userId, price);
    }

    /// @notice sell resources of user with type
    /// @param _type type of resources
    /// @return sum of sell
    function sellResources(uint8 _type) public onlyExistingUser returns(uint256) {
        uint256 userId = addressToUser[msg.sender];
        uint256 sum = Math.min(users[userId].resources[_type] * getResourcePrice(_type), address(this).balance);
        users[userId].resources[_type] = 0;

        msg.sender.transfer(sum);

        emit Sell(userId, _type, sum);
        return sum;
    }

    /// @notice function for compute worktime factory
    /// @param _collected_at timestamp of start
    /// @return duration minutes
    function worktimeAtDate(uint256 _collected_at) public view returns(uint256) {
        return (now - _collected_at) / 60;
    }

    /// @notice function for compute duration work factory
    /// @param _factoryId id of factory
    /// @return timestamp of duration
    function worktime(uint256 _factoryId) public view returns(uint256) {
        return worktimeAtDate(factories[_factoryId].collected_at);
    }

    /// @notice function for compute resource factory at time
    /// @param _type type of factory
    /// @param _level level of factory
    /// @param _collected_at timestamp for collect
    /// @return count of resources
    function _resourcesAtTime(FactoryType _type, uint8 _level, uint256 _collected_at) public view returns(uint256) {
        return worktimeAtDate(_collected_at) * (getProductsPerMinute(_type, _level) + getBonusPerMinute(_type, _level)) / 100;
    }

    /// @notice function for compute resource factory at time
    /// @dev wrapper over _resourcesAtTime
    /// @param _factoryId id of factory
    /// @return count of resources
    function resourcesAtTime(uint256 _factoryId) public view returns(uint256) {
        Factory storage factory = factories[_factoryId];
        return _resourcesAtTime(factory.ftype, factory.level, factory.collected_at);
    }

    /// @notice function for collect resource
    /// @param _factory factory object
    /// @param _user user object
    /// @return count of resources
    function _collectResource(Factory storage _factory, User storage _user) internal returns(uint256) {
        uint256 resources = _resourcesAtTime(_factory.ftype, _factory.level, _factory.collected_at);
        _user.resources[uint8(_factory.ftype)] = _user.resources[uint8(_factory.ftype)].add(resources);
        _factory.collected_at = now;

        emit CollectResources(_factory.ftype, resources);
        return resources;
    }

    /// @notice function for collect all resources from all factories
    /// @dev wrapper over _collectResource
    function collectResources() public onlyExistingUser {
        uint256 index = addressToUser[msg.sender];
        User storage user = users[index];
        uint256[] storage factoriesIds = userToFactories[addressToUser[msg.sender]];

        for (uint256 i = 0; i < factoriesIds.length; i++) {
            _collectResource(factories[factoriesIds[i]], user);
        }
    }

}