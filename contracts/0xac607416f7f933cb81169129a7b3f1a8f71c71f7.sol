pragma solidity ^0.4.24;

// SafeMath library
library SafeMath {
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        assert(c >= _a);
        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_a >= _b);
        return _a - _b;
    }

    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a == 0) {
            return 0;
        }
        uint256 c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a / _b;
    }
}

// Contract must have an owner
contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "sender must be owner");
        _;
    }

    function setOwner(address _owner) onlyOwner public {
        owner = _owner;
    }
}

// SaleBook Contract
contract SaleBook is Ownable {
    using SafeMath for uint256;

    // admins info
    mapping (uint256 => address) public admins;
    mapping (address => uint256) public adminId;
    uint256 public adminCount = 0;

    // investor data
    struct InvestorData {
        uint256 id;
        address addr;
        uint256 ref;
        address ref1;
        address ref2;
        uint256 reffed;
        uint256 topref;
        uint256 topreffed;
    }

    mapping (uint256 => InvestorData) public investors;
    mapping (address => uint256) public investorId;
    uint256 public investorCount = 0;

    event AdminAdded(address indexed _addr, uint256 _id, address indexed _adder);
    event AdminRemoved(address indexed _addr, uint256 _id, address indexed _remover);
    event InvestorAdded(address indexed _addr, uint256 _id, address _ref1, address _ref2, address indexed _adder);

    // check the address is human or contract
    function isHuman(address _addr) public view returns (bool) {
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        return (_codeLength == 0);
    }

    modifier validAddress(address _addr) {
        require(_addr != 0x0);
        _;
    }

    modifier onlyAdmin() {
        require(adminId[msg.sender] != 0);
        _;
    }

    constructor() public {
        adminId[address(0x0)] = 0;
        admins[0] = address(0x0);

        investorId[address(0x0)] = 0;
        investors[0] = InvestorData({id: 0, addr: address(0x0), ref: 0, ref1: address(0x0), ref2: address(0x0), reffed: 0, topref: 0, topreffed: 0});


        // first admin is owner
        addAdmin(owner);
    }

    // owner may add or remove admins
    function addAdmin(address _admin) onlyOwner validAddress(_admin) public {
        require(isHuman(_admin));

        uint256 id = adminId[_admin];
        if (id == 0) {
            id = adminCount.add(1);
            adminId[_admin] = id;
            admins[id] = _admin;
            adminCount = id;
            emit AdminAdded(_admin, id, msg.sender);
        }
    }

    function removeAdmin(address _admin) onlyOwner validAddress(_admin) public {
        require(adminId[_admin] != 0);

        uint256 aid = adminId[_admin];
        adminId[_admin] = 0;
        for (uint256 i = aid; i < adminCount; i++){
            admins[i] = admins[i + 1];
            adminId[admins[i]] = i;
        }
        delete admins[adminCount];
        adminCount--;
        emit AdminRemoved(_admin, aid, msg.sender);
    }

    // admins may batch add investors, and investors cannot be removed
    function addInvestor(address _addr, address _ref1, address _ref2) validAddress(_addr) internal returns (uint256) {
        require(investorId[_addr] == 0 && isHuman(_addr));
        if (investorId[_ref1] == 0) _ref1 = address(0x0);
        if (investorId[_ref2] == 0) _ref2 = address(0x0);

        investorCount++;
        investorId[_addr] = investorCount;

        investors[investorCount] = InvestorData({id: investorCount, addr: _addr, ref: 0, ref1: _ref1, ref2: _ref2, reffed: 0, topref: 0, topreffed: 0});

        emit InvestorAdded(_addr, investorCount, _ref1, _ref2, msg.sender);
        return investorCount;
    }

}

interface ERC20Token {
    function transfer(address _to, uint256 _value) external returns (bool);
    function balanceOf(address _addr) external view returns (uint256);
    function decimals() external view returns (uint8);
}

contract CNTOSale is SaleBook {
    using SafeMath for uint256;

    string constant name = "CNTO Sale";
    string constant version = "1.8";
    uint256 constant keybase = 1000000000000000000;
    uint256 constant DAY_IN_SECONDS = 86400;
    uint256 private rseed = 0;

    // various token related stuff
    struct TokenInfo {
        ERC20Token token;
        address addr;
        uint8 decimals;
        address payaddr;
        uint256 bought;
        uint256 vaulted;
        uint256 price;
        uint256 buypercent;
        uint256 lockperiod;
    }

    TokenInfo public tokenInfo;

    // Investor's time-locked vaults to store tokens
    struct InvestorTokenVault {
        mapping (uint256 => uint256) lockValue;
        mapping (uint256 => uint256) lockTime;
        uint256 totalToken;
        uint256 locks;
        uint256 withdraws;
        uint256 withdrawn;
    }

    mapping(uint256 => InvestorTokenVault) public investorVaults;


    // Round related data
    struct RoundData {
        uint256 startTime;
        uint256 endTime;
        bool ended;
        uint256 keys;
        uint256 shares;
        uint256 ethers;
        uint256 pot;
        uint256 divie;
        uint256 currentInvestor;
    }

    bool public saleActive;
    uint256 public saleEndTime;
    uint256 public roundNum = 0; // current Round number
    uint256 public endNum = 0; // end Round number
    mapping (uint256 => RoundData) public rounds; // all rounds data for the game

    // investor related info
    struct InvestorInfo {
        address addr;
        uint256 lastRound;
        uint256 invested;
        uint256 keys;
        uint256 prevEther;
        uint256 lastEther;
        uint256 potEther;
        uint256 candyEther;
        uint256 refEther;
        uint256 withdrawn;
    }

    mapping (uint256 => InvestorInfo) public investorInfo; // all investor info for the sale

    // Investor keys and shares in each round
    struct InvestorRoundData {
        uint256 keys;
        uint256 shares;
    }

    mapping (uint256 => mapping (uint256 => InvestorRoundData)) public investorAtRound; // round number => id => investor keys and shares

    // attributes of the entire Game
    uint256 public roundTimeLimit;
    uint256 public keyTime;
    uint256 public keyprice;
    uint256 public stepped;
    uint256 public potpercent;
    uint256 public diviepercent;
    uint256 public tokenpercent;
    uint256 public candypercent;
    uint256 public candyvalue;
    uint256 public candythreshold;
    uint256 public candyprob;
    uint256 public ref1percent;
    uint256 public ref2percent;
    uint256 public oppercent;
    address public opaddress;
    address public defaddress;
    uint256 public defid;

    // Round related events
    event KeyBought(uint256 _round, uint256 _id, uint256 _keys, uint256 _shares);
    event NewRoundCreated(uint256 _round, uint256 _id, uint256 _startTime, uint256 _endTime);
    event RoundExtended(uint256 _round, uint256 _id, uint256 _endTime);
    event PotWon(uint256 _round, uint256 _id, uint256 _pot);
    event CandyWon(uint256 _round, uint256 _id, uint256 _candy);
    event EtherWithdrawn(uint256 _round, uint256 _id, uint256 _value);
    event EndingSale(address indexed _ender, uint256 _round, uint256 _time);
    event SaleEnded(uint256 _round, uint256 _time);
    event EtherReturned(address indexed _sender, uint256 _value, uint256 _time);

    // Token related events
    event TokenBought(uint256 _id, uint256 _amount);
    event TokenLocked(uint256 _id, uint256 _amount, uint256 _locktime);
    event TokenFundPaid(address indexed _paddr, uint256 _value);
    event TokenWithdrawn(uint256 _id, uint256 _amount);

    // Safety measure events
    event WrongTokenEmptied(address indexed _token, address indexed _addr, uint256 _amount, address indexed _target);
    event InactiveTokenEmptied(address indexed _addr, uint256 _amount, address indexed _target);
    event InactiveEtherEmptied(address indexed _addr, uint256 _amount, address indexed _target);
    event ForgottenTokenEmptied(address indexed _addr, uint256 _amount, address indexed _target);
    event ForgottenEtherEmptied(address indexed _addr, uint256 _amount, address indexed _target);

    constructor(address _tokenAddress, address _payAddress, uint256 _price, uint256 _buypercent, uint256 _lockperiod, uint256 _candythreshold,
    uint256 _candyprob, address _defaddress) public {
        tokenInfo.token = ERC20Token(_tokenAddress);
        tokenInfo.addr = _tokenAddress;
        tokenInfo.decimals = tokenInfo.token.decimals();
        tokenInfo.payaddr = _payAddress;
        tokenInfo.bought = 0;
        tokenInfo.vaulted = 0;
        tokenInfo.price = _price;
        tokenInfo.buypercent = _buypercent;
        tokenInfo.lockperiod = _lockperiod;
        candythreshold = _candythreshold;
        candyprob = _candyprob;
        defaddress = _defaddress;

        defid = addInvestor(defaddress, address(0x0), address(0x0));
    }

    function initRound(uint256 _roundTimeLimit, uint256 _keyTime, uint256 _keyprice, uint256 _stepped, uint256 _potpercent, uint256 _diviepercent, uint256 _tokenpercent,
    uint256 _candypercent, uint256 _ref1percent, uint256 _ref2percent, uint256 _oppercent, address _opaddress) onlyAdmin public {
        require(roundNum == 0, "already initialized");
        require(!((_potpercent + _diviepercent + _tokenpercent + _candypercent + _ref1percent + _ref2percent + _oppercent) > 100), "the sum cannot be greater than 100");
        roundTimeLimit = _roundTimeLimit;
        keyTime = _keyTime;
        keyprice = _keyprice;
        stepped = _stepped;
        potpercent = _potpercent;
        diviepercent = _diviepercent;
        tokenpercent = _tokenpercent;
        candypercent = _candypercent;
        ref1percent = _ref1percent;
        ref2percent = _ref2percent;
        oppercent = _oppercent;
        opaddress = _opaddress;

        candyvalue = 0;
        saleActive = true;
        roundNum = 1;

        rounds[roundNum] = RoundData({startTime: now, endTime: now.add(roundTimeLimit), ended: false, keys: 0, shares: 0, ethers: 0, pot: 0, divie: 0, currentInvestor: 0});
        emit NewRoundCreated(roundNum, 0, rounds[roundNum].startTime, rounds[roundNum].endTime);
    }

    function saleState() public view returns (uint8 _status) {
        if (roundNum == 0) return 0;
        if (!saleActive && roundNum >= endNum) return 2;
        return 1;
    }

    function roundStatus(uint256 _round) public view returns (uint8 _status) {
        require(_round <= roundNum);
        if (rounds[_round].ended) return 0;
        return 1;
    }

    function getCurrentRoundInfo() public view returns (uint256 _divie, uint256 _startTime, uint256 _endTime,
    uint256 _ethers, uint256 _keyTime, uint256 _keys, uint256 _pot, uint256 _candy, uint256 _roundNum,
    uint8 _status, uint256 _tokenprice, uint256 _keyprice, uint8 _activityStatus, uint256 _activityStartTime) {
        if(saleState() == 2) {
            return (rounds[roundNum - 1].divie, rounds[roundNum - 1].startTime, rounds[roundNum - 1].endTime, rounds[roundNum - 1].ethers, keyTime, rounds[roundNum - 1].keys,
            rounds[roundNum - 1].pot, candyvalue, roundNum - 1, roundStatus(roundNum - 1), tokenInfo.price, keyprice, saleState(), rounds[1].startTime);
        }
        return (rounds[roundNum].divie, rounds[roundNum].startTime, rounds[roundNum].endTime, rounds[roundNum].ethers, keyTime, rounds[roundNum].keys,
        rounds[roundNum].pot, candyvalue, roundNum, roundStatus(roundNum), tokenInfo.price, keyprice, saleState(), rounds[1].startTime);
    }

    function getRoundInfo(uint256 _round) public view returns (uint256 _divie, uint256 _startTime, uint256 _endTime,
    uint256 _ethers, uint256 _keys, uint256 _pot, uint8 _status) {
        require(_round <= roundNum);
        return (rounds[_round].divie, rounds[_round].startTime, rounds[_round].endTime,
        rounds[_round].ethers, rounds[_round].keys, rounds[_round].pot, roundStatus(_round));
    }

    function getAllRoundsInfo() external view returns (uint256[] _divies, uint256[] _startTimes, uint256[] _endTimes,
    uint256[] _ethers, uint256[] _keys, uint256[] _pots, uint8[] _status) {
        uint256 i = 0;

        _divies = new uint256[](roundNum);
        _startTimes = new uint256[](roundNum);
        _endTimes = new uint256[](roundNum);
        _ethers = new uint256[](roundNum);
        _keys = new uint256[](roundNum);
        _pots = new uint256[](roundNum);
        _status = new uint8[](roundNum);

        while (i < roundNum) {
            (_divies[i], _startTimes[i], _endTimes[i], _ethers[i], _keys[i], _pots[i], _status[i]) = getRoundInfo(i + 1);
            i++;
        }
        return (_divies, _startTimes, _endTimes, _ethers, _keys, _pots, _status);
    }

    function tokenBalance() public view returns (uint256 _balance) {
        return tokenInfo.token.balanceOf(address(this)).sub(tokenInfo.vaulted);
    }

    function tokenBuyable(uint256 _eth) public view returns (bool _buyable) {
        if (!saleActive && roundNum >= endNum) return false;
        uint256 buyAmount = (_eth).mul(tokenInfo.buypercent).div(100).mul(uint256(10)**tokenInfo.decimals).div(tokenInfo.price);
        return (tokenBalance() >= buyAmount);
    }

    // Handles the buying of Tokens
    function buyToken(uint256 _id, uint256 _eth) internal {
        require(_id <= investorCount, "invalid investor id");
        require(tokenBuyable(_eth), "not enough token in reserve");

        uint256 buyAmount = (_eth).mul(tokenInfo.buypercent).div(100).mul(uint256(10)**tokenInfo.decimals).div(tokenInfo.price);
        assert(tokenBalance() >= buyAmount);

        tokenInfo.bought = tokenInfo.bought.add(buyAmount);
        tokenInfo.vaulted = tokenInfo.vaulted.add(buyAmount);

        emit TokenBought(_id, buyAmount);

        uint256 lockStartTime = rounds[roundNum].startTime;
        tokenTimeLock(_id, buyAmount, lockStartTime);

        tokenInfo.payaddr.transfer(_eth);

        emit TokenFundPaid(tokenInfo.payaddr, _eth);
    }

    // lock the Tokens allocated to investors with a timelock
    function tokenTimeLock(uint256 _id, uint256 _amount, uint256 _start) private {
        uint256 lockTime;
        uint256 lockNum;
        uint256 withdrawNum;

        for (uint256 i = 0; i < 10; i++) {
            lockTime = _start + tokenInfo.lockperiod.div(10).mul(i.add(1));
            lockNum = investorVaults[_id].locks;
            withdrawNum = investorVaults[_id].withdraws;
            if (lockNum >= 10 && lockNum >= withdrawNum.add(10)) {
                if (investorVaults[_id].lockTime[lockNum.sub(10).add(i)] == lockTime) {
                    investorVaults[_id].lockValue[lockNum.sub(10).add(i)] = investorVaults[_id].lockValue[lockNum.sub(10).add(i)].add(_amount.div(10));
                } else {
                    investorVaults[_id].lockTime[lockNum] = lockTime;
                    investorVaults[_id].lockValue[lockNum] = _amount.div(10);
                    investorVaults[_id].locks++;
                }
            } else {
                investorVaults[_id].lockTime[lockNum] = lockTime;
                investorVaults[_id].lockValue[lockNum] = _amount.div(10);
                investorVaults[_id].locks++;
            }
            emit TokenLocked(_id, _amount.div(10), lockTime);
        }

        investorVaults[_id].totalToken = investorVaults[_id].totalToken.add(_amount);
    }

    function showInvestorVaultByAddress(address _addr) public view returns (uint256 _total, uint256 _locked, uint256 _unlocked, uint256 _withdrawable, uint256 _withdrawn) {
        uint256 id = investorId[_addr];
        if (id == 0) {
            return (0, 0, 0, 0, 0);
        }
        return showInvestorVaultById(id);
    }

    function showInvestorVaultById(uint256 _id) public view returns (uint256 _total, uint256 _locked, uint256 _unlocked, uint256 _withdrawable, uint256 _withdrawn) {
        require(_id <= investorCount && _id > 0, "invalid investor id");
        uint256 locked = 0;
        uint256 unlocked = 0;
        uint256 withdrawable = 0;
        uint256 withdraws = investorVaults[_id].withdraws;
        uint256 locks = investorVaults[_id].locks;
        uint256 withdrawn = investorVaults[_id].withdrawn;
        for (uint256 i = withdraws; i < locks; i++) {
            if (investorVaults[_id].lockTime[i] < now) {
                unlocked = unlocked.add(investorVaults[_id].lockValue[i]);
                if (i - withdraws < 50) withdrawable = withdrawable.add(investorVaults[_id].lockValue[i]);
            } else {
                locked = locked.add(investorVaults[_id].lockValue[i]);
            }
        }
        return (investorVaults[_id].totalToken, locked, unlocked, withdrawable, withdrawn);
    }

    function showInvestorVaultTime(uint256 _id, uint256 _count) public view returns (uint256 _time) {
        return investorVaults[_id].lockTime[_count];
    }

    function showInvestorVaultValue(uint256 _id, uint256 _count) public view returns (uint256 _value) {
        return investorVaults[_id].lockValue[_count];
    }

    // investors may withdraw tokens after the timelock period
    function withdrawToken() public {
        uint256 id = investorId[msg.sender];
        require(id > 0, "withdraw need valid investor");
        uint256 withdrawable = 0;
        uint256 i = investorVaults[id].withdraws;
        uint256 count = 0;
        uint256 locks = investorVaults[id].locks;
        for (; (i < locks) && (count < 50); i++) {
            if (investorVaults[id].lockTime[i] < now) {
                withdrawable = withdrawable.add(investorVaults[id].lockValue[i]);
                investorVaults[id].withdraws = i + 1;
            }
            count++;
        }

        assert((tokenInfo.token.balanceOf(address(this)) >= withdrawable) && (tokenInfo.vaulted >= withdrawable));
        tokenInfo.vaulted = tokenInfo.vaulted.sub(withdrawable);
        investorVaults[id].withdrawn = investorVaults[id].withdrawn.add(withdrawable);
        require(tokenInfo.token.transfer(msg.sender, withdrawable), "token withdraw transfer failed");

        emit TokenWithdrawn(id, withdrawable);
    }

    modifier isPaid() {
        // paymnent must be greater than 1GWei and less than 100k ETH
        require((msg.value > 1000000000) && (msg.value < 100000000000000000000000), "payment invalid");
        _;
    }

    function buyKey(address _ref1, address _ref2, address _node) isPaid public payable returns (bool _success) {
        require(roundNum > 0, "uninitialized");
        require(!rounds[roundNum].ended, "cannot buy key from ended round");

        if (_ref1 == address(0x0)) {
            _ref1 = defaddress;
        }
        if (_ref2 == address(0x0)) {
            _ref2 = defaddress;
        }
        if (_node == address(0x0)) {
            _node = defaddress;
        }

        uint256 id = investorId[msg.sender];
        if (id == 0) {
            if (investorId[_node] == 0) {
                _node = defaddress;
            }
            if (investorId[_ref1] == 0) {
                _ref1 = _node;
            }
            if (investorId[_ref2] == 0) {
                _ref2 = _node;
            }
            id = addInvestor(msg.sender, _ref1, _ref2);
        }
        investorInfo[id].addr = msg.sender;
        if (rounds[roundNum].ethers == 0) {
            rounds[roundNum].startTime = now;
            rounds[roundNum].endTime = now.add(roundTimeLimit);
        }
        uint256 topot = msg.value.mul(potpercent).div(100);
        uint256 todivie = msg.value.mul(diviepercent).div(100);
        uint256 totoken = msg.value.mul(tokenpercent).div(100);
        uint256 tocandy = msg.value.mul(candypercent).div(100);
        uint256 toref1 = msg.value.mul(ref1percent).div(100);
        uint256 toref2 = msg.value.mul(ref2percent).div(100);
        uint256 toop = msg.value.mul(oppercent).div(100);


        if (now > rounds[roundNum].endTime) {
            // current round ended, pot goes to winner
            investorInfo[rounds[roundNum].currentInvestor].potEther = investorInfo[rounds[roundNum].currentInvestor].potEther.add(rounds[roundNum].pot);
            emit PotWon(roundNum, rounds[roundNum].currentInvestor, rounds[roundNum].pot);

            // start a new round
            startNewRound(id, msg.value, topot, todivie);
        } else {
            processCurrentRound(id, msg.value, topot, todivie);
        }

        if (rounds[roundNum].ended) {
            msg.sender.transfer(msg.value);
            emit EtherReturned(msg.sender, msg.value, now);
            return false;
        }

        uint256 cn = tryRandom();

        candyvalue = candyvalue.add(tocandy);
        if ((cn % candyprob == 0) && (msg.value >= candythreshold)) {
            investorInfo[id].candyEther = investorInfo[id].candyEther.add(candyvalue);
            candyvalue = 0;
        }

        toRef(id, toref1, toref2);

        investorInfo[id].invested = investorInfo[id].invested.add(msg.value);

        opaddress.transfer(toop);
        buyToken(id, totoken);
        return true;
    }

    function toRef(uint256 _id, uint256 _toref1, uint256 _toref2) private {
        uint256 ref1 = investorId[investors[_id].ref1];
        uint256 ref2 = investorId[investors[_id].ref2];
        if (ref1 == 0 || ref1 > investorCount) {
            ref1 = defid;
        }
        if (ref2 == 0 || ref2 > investorCount) {
            ref2 = defid;
        }
        investorInfo[ref1].refEther = investorInfo[ref1].refEther.add(_toref1);
        investorInfo[ref2].refEther = investorInfo[ref2].refEther.add(_toref2);
    }

    function tryRandom() private returns (uint256) {
        uint256 bn = block.number;
        rseed++;
        uint256 bm1 = uint256(blockhash(bn - 1)) % 250 + 1;
        uint256 bm2 = uint256(keccak256(abi.encodePacked(now))) % 250 + 2;
        uint256 bm3 = uint256(keccak256(abi.encodePacked(block.difficulty))) % 250 + 3;
        uint256 bm4 = uint256(keccak256(abi.encodePacked(uint256(msg.sender) + gasleft() + block.gaslimit))) % 250 + 4;
        uint256 bm5 = uint256(keccak256(abi.encodePacked(uint256(keccak256(msg.data)) + msg.value + uint256(block.coinbase)))) % 250 + 5;
        uint256 cn = uint256(keccak256(abi.encodePacked((bn + rseed) ^ uint256(blockhash(bn - bm1)) ^ uint256(blockhash(bn - bm2)) ^ uint256(blockhash(bn - bm3))
        ^ uint256(blockhash(bn - bm4)) ^ uint256(blockhash(bn - bm5)))));
        return cn;
    }

    function startNewRound(uint256 _id, uint256 _eth, uint256 _topot, uint256 _todivie) private {
        processLastEther(_id);
        investorInfo[_id].prevEther = investorInfo[_id].prevEther.add(investorInfo[_id].lastEther);
        investorInfo[_id].lastEther = 0;
        rounds[roundNum].ended = true;
        roundNum++;
        if (!saleActive) {
            rounds[roundNum].ended = true;
            saleEndTime = now;
            emit SaleEnded(roundNum.sub(1), now);
            return;
        }
        rounds[roundNum] = RoundData({startTime: now, endTime: now.add(roundTimeLimit), ended: false, keys: 0, shares: 0, ethers: _eth, pot: _topot, divie: _todivie, currentInvestor: _id});
        uint256 boughtkeys = _eth.mul(keybase).div(keyprice);
        uint256 denominator = uint256(1).add(rounds[roundNum].keys.div(stepped).div(keybase));
        rounds[roundNum].keys = boughtkeys;
        investorAtRound[roundNum][_id].keys = boughtkeys;
        investorInfo[_id].keys = investorInfo[_id].keys.add(boughtkeys);
        uint256 boughtshares = boughtkeys.div(denominator);
        rounds[roundNum].shares = boughtshares;
        investorAtRound[roundNum][_id].shares = boughtshares;
        investorInfo[_id].lastRound = roundNum;
        investorInfo[_id].lastEther = rounds[roundNum].divie.mul(investorAtRound[roundNum][_id].shares).div(rounds[roundNum].shares);

        emit NewRoundCreated(roundNum, _id, rounds[roundNum].startTime, rounds[roundNum].endTime);
        emit KeyBought(roundNum, _id, boughtkeys, boughtshares);
    }

    function processCurrentRound(uint256 _id, uint256 _eth, uint256 _topot, uint256 _todivie) private {
        processLastEther(_id);
        rounds[roundNum].ethers = rounds[roundNum].ethers.add(_eth);
        rounds[roundNum].pot = rounds[roundNum].pot.add(_topot);
        rounds[roundNum].divie = rounds[roundNum].divie.add(_todivie);
        uint256 boughtkeys = _eth.mul(keybase).div(keyprice);
        uint256 denominator = uint256(1).add(rounds[roundNum].keys.div(stepped).div(keybase));
        rounds[roundNum].keys = rounds[roundNum].keys.add(boughtkeys);
        investorAtRound[roundNum][_id].keys = investorAtRound[roundNum][_id].keys.add(boughtkeys);
        investorInfo[_id].keys = investorInfo[_id].keys.add(boughtkeys);
        uint256 boughtshares = boughtkeys.div(denominator);
        rounds[roundNum].shares = rounds[roundNum].shares.add(boughtshares);
        investorAtRound[roundNum][_id].shares = investorAtRound[roundNum][_id].shares.add(boughtshares);
        investorInfo[_id].lastRound = roundNum;
        investorInfo[_id].lastEther = rounds[roundNum].divie.mul(investorAtRound[roundNum][_id].shares).div(rounds[roundNum].shares);

        rounds[roundNum].endTime = rounds[roundNum].endTime.add(boughtkeys.div(keybase).mul(keyTime));
        if (rounds[roundNum].endTime > now.add(roundTimeLimit)) {
            rounds[roundNum].endTime = now.add(roundTimeLimit);
        }

        rounds[roundNum].currentInvestor = _id;

        emit RoundExtended(roundNum, _id, rounds[roundNum].endTime);
        emit KeyBought(roundNum, _id, boughtkeys, boughtshares);
    }

    function processLastEther(uint256 _id) private {
        uint256 pround = investorInfo[_id].lastRound;
        assert(pround <= roundNum);
        if (pround < roundNum && rounds[pround].shares > 0) {
            investorInfo[_id].prevEther = investorInfo[_id].prevEther.add(rounds[pround].divie.mul(investorAtRound[pround][_id].shares).div(rounds[pround].shares));
        }
        if (rounds[roundNum].shares > 0) {
            investorInfo[_id].lastEther = rounds[roundNum].divie.mul(investorAtRound[roundNum][_id].shares).div(rounds[roundNum].shares);
        } else {
            investorInfo[_id].lastEther = 0;
        }
        investorInfo[_id].lastRound = roundNum;
    }

    function showInvestorExtraByAddress(address _addr) public view returns (uint256 _invested, uint256 _lastRound, uint256 _keys, uint8 _activityStatus, uint256 _roundNum, uint256 _startTime) {
        uint256 id = investorId[_addr];
        if (id == 0) {
            return (0, 0, 0, 0, 0, 0);
        }
        return showInvestorExtraById(id);
    }

    function showInvestorExtraById(uint256 _id ) public view returns (uint256 _invested, uint256 _lastRound, uint256 _keys, uint8 _activityStatus, uint256 _roundNum, uint256 _startTime) {
        require(_id <= investorCount && _id > 0, "invalid investor id");
        uint256 pinvested = investorInfo[_id].invested;
        uint256 plastRound = investorInfo[_id].lastRound;
        uint256 pkeys = investorInfo[_id].keys;
        return (pinvested, plastRound, pkeys, saleState(), (saleState() == 2) ? roundNum - 1 : roundNum, rounds[1].startTime);
    }

    // show Investor's ether info
    function showInvestorEtherByAddress(address _addr) public view returns (uint256 _divie, uint256 _pot, uint256 _candy, uint256 _ref, uint256 _withdrawable, uint256 _withdrawn) {
        uint256 id = investorId[_addr];
        if (id == 0) {
            return (0, 0, 0, 0, 0, 0);
        }
        return showInvestorEtherById(id);
    }

    function showInvestorEtherById(uint256 _id) public view returns (uint256 _divie, uint256 _pot, uint256 _candy, uint256 _ref, uint256 _withdrawable, uint256 _withdrawn) {
        require(_id <= investorCount && _id > 0, "invalid investor id");
        uint256 pdivie;
        uint256 ppot;
        uint256 pcandy;
        uint256 pref;
        (pdivie, ppot, pcandy, pref) = investorInfoById(_id);
        uint256 pwithdrawn = investorInfo[_id].withdrawn;
        uint256 pwithdrawable = pdivie.add(ppot).add(pcandy).add(pref).sub(pwithdrawn);
        return (pdivie, ppot, pcandy, pref, pwithdrawable, pwithdrawn);
    }

    function investorInfoById(uint256 _id) private view returns (uint256 _divie, uint256 _pot, uint256 _candy, uint256 _ref) {
        require(_id <= investorCount && _id > 0, "invalid investor id");

        uint256 pdivie = investorInfo[_id].prevEther;
        if (investorInfo[_id].lastRound > 0) {
            uint256 pround = investorInfo[_id].lastRound;
            assert(pround <= roundNum);
            pdivie = pdivie.add(rounds[pround].divie.mul(investorAtRound[pround][_id].shares).div(rounds[pround].shares));
        }
        uint256 ppot = investorInfo[_id].potEther;
        uint256 pcandy = investorInfo[_id].candyEther;
        uint256 pref = investorInfo[_id].refEther;

        return (pdivie, ppot, pcandy, pref);
    }

    // investor withdraw ether
    function withdraw() public {
        require(roundNum > 0, "uninitialized");
        if (now > rounds[roundNum].endTime) {
            // current round ended, pot goes to winner
            investorInfo[rounds[roundNum].currentInvestor].potEther = investorInfo[rounds[roundNum].currentInvestor].potEther.add(rounds[roundNum].pot);
            emit PotWon(roundNum, rounds[roundNum].currentInvestor, rounds[roundNum].pot);

            // start a new round
            startNewRoundFromWithdrawal();
        }
        uint256 pdivie;
        uint256 ppot;
        uint256 pcandy;
        uint256 pref;
        uint256 withdrawable;
        uint256 withdrawn;
        uint256 id = investorId[msg.sender];
        (pdivie, ppot, pcandy, pref, withdrawable, withdrawn) = showInvestorEtherById(id);
        require(withdrawable > 0, "no ether to withdraw");
        require(address(this).balance >= withdrawable, "something wrong, not enough ether in reserve");
        investorInfo[id].withdrawn = investorInfo[id].withdrawn.add(withdrawable);
        msg.sender.transfer(withdrawable);

        emit EtherWithdrawn(roundNum, id, withdrawable);
    }

    function startNewRoundFromWithdrawal() private {
        rounds[roundNum].ended = true;
        roundNum++;
        if (!saleActive) {
            rounds[roundNum].ended = true;
            saleEndTime = now;
            emit SaleEnded(roundNum.sub(1), now);
            return;
        }
        rounds[roundNum] = RoundData({startTime: now, endTime: now.add(roundTimeLimit), ended: false, keys: 0, shares: 0, ethers: 0, pot: 0, divie: 0, currentInvestor: 0});

        emit NewRoundCreated(roundNum, 0, rounds[roundNum].startTime, rounds[roundNum].endTime);
    }

    // end the whole Sale after the current round
    function endSale() onlyAdmin public {
        saleActive = false;
        endNum = roundNum.add(1);
        emit EndingSale(msg.sender, roundNum, now);
    }

    // admin can empty wrongly sent Tokens
    function emptyWrongToken(address _addr, address _target) onlyAdmin public {
        require(_addr != tokenInfo.addr, "this is not a wrong token");
        ERC20Token wrongToken = ERC20Token(_addr);
        uint256 amount = wrongToken.balanceOf(address(this));
        require(amount > 0, "no wrong token sent here");
        require(wrongToken.transfer(_target, amount), "token transfer failed");

        emit WrongTokenEmptied(_addr, msg.sender, amount, _target);
    }

    // admins can empty unsold tokens after sale ended
    function emptyInactiveToken(address _target) onlyAdmin public {
        require(!saleActive && roundNum >= endNum, "sale still active");
        uint256 amount = tokenInfo.token.balanceOf(address(this)).sub(tokenInfo.vaulted);
        require(tokenInfo.token.transfer(_target, amount), "inactive token transfer failed");

        emit InactiveTokenEmptied(msg.sender, amount, _target);
    }

    // admins can empty unclaimed candy ethers after sale ended
    function emptyInactiveEther(address _target) onlyAdmin public {
        require(!saleActive && roundNum >= endNum, "sale still active");
        require(candyvalue > 0, "no inactive ether");
        uint256 amount = candyvalue;
        _target.transfer(amount);
        candyvalue = 0;

        emit InactiveEtherEmptied(msg.sender, amount, _target);
    }


    // Emoty tokens and ethers after a long time?
    function emptyForgottenToken(address _target) onlyAdmin public {
        require(!saleActive && roundNum >= endNum, "sale still active");
        require(now > saleEndTime.add(tokenInfo.lockperiod).add(180 * DAY_IN_SECONDS), "still in waiting period");
        uint256 amount = tokenInfo.token.balanceOf(address(this));
        require(tokenInfo.token.transfer(_target, amount), "forgotten token transfer failed");

        emit ForgottenTokenEmptied(msg.sender, amount, _target);
    }

    function emptyForgottenEther(address _target) onlyAdmin public {
        require(!saleActive && roundNum >= endNum, "sale still active");
        require(now > saleEndTime.add(tokenInfo.lockperiod).add(180 * DAY_IN_SECONDS), "still in waiting period");
        uint256 amount = address(this).balance;
        _target.transfer(amount);

        emit ForgottenEtherEmptied(msg.sender, amount, _target);
    }


    function () public payable {
        revert();
    }
}