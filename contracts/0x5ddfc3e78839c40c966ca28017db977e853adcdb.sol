pragma solidity ^0.4.24;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = add(x, 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = add((x / z), z) / 2;
        }
    }

    function sq(uint256 x) internal pure returns (uint256) {
        return mul(x, x);
    }

    function pwr(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x == 0) {
            return 0;
        }
        if (y == 0) {
            return 1;
        }
        uint256 z = x;
        for (uint256 i=1; i < y; i++) {
            z = mul(z,x);
        }
        return (z);
    }
}

library NameFilter {
    function nameFilter(string _input) internal pure returns(bytes32) {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
        if (_temp[0] == 0x30) {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

        bool _hasNonNumber;

        for (uint256 i = 0; i < _length; i++) {
            if (_temp[i] > 0x40 && _temp[i] < 0x5b) {
                _temp[i] = byte(uint(_temp[i]) + 32);

                if (_hasNonNumber == false) {
                    _hasNonNumber = true;
                }
            } else {
                require(_temp[i] == 0x20 || (_temp[i] > 0x60 && _temp[i] < 0x7b) || (_temp[i] > 0x2f && _temp[i] < 0x3a), "string contains invalid characters");
                if (_temp[i] == 0x20) {
                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");
                }

                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39)) {
                    _hasNonNumber = true;
                }
            }
        }

        require(_hasNonNumber == true, "string cannot be only numbers");

        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }

        return (_ret);
    }
}

library F3Ddatasets {
    // compressedData key
    // [76-33][32][31][30][29][28-18][17][16-6][5-3][2][1][0]
    // 0 - new player (bool)
    // 1 - joined round (bool)
    // 2 - new  leader (bool)
    // 3-5 - air drop tracker (uint 0-999)
    // 6-16 - round end time
    // 17 - winnerTeam
    // 18 - 28 timestamp
    // 29 - team
    // 30 - 0 = reinvest (round), 1 = buy (round), 2 = buy (ico), 3 = reinvest (ico)
    // 31 - airdrop happened bool
    // 32 - airdrop tier
    // 33 - airdrop amount won
    // compressedIDs key
    // [77-52][51-26][25-0]
    // 0-25 - pID
    // 26-51 - winPID
    // 52-77 - rID
    struct EventReturns {
        uint256 compressedData;
        uint256 compressedIDs;
        address winnerAddr;         // winner address
        bytes32 winnerName;         // winner name
        uint256 amountWon;          // amount won
        uint256 newPot;             // amount in new pot
        uint256 genAmount;          // amount distributed to gen
        uint256 potAmount;          // amount added to pot
    }

    struct Player {
        address addr;   // player address
        bytes32 name;   // player name
        uint256 win;    // winnings vault
        uint256 gen;    // general vault
        uint256 aff;    // affiliate vault
        uint256 lrnd;   // last round played
        uint256 laff;   // last affiliate id used
    }

    struct PlayerRounds {
        uint256 eth;    // eth player has added to round (used for eth limiter)
        uint256 keys;   // keys
        uint256 mask;   // player mask
        uint256 ico;    // ICO phase investment
    }

    struct Round {
        uint256 plyr;   // pID of player in lead
        uint256 team;   // tID of team in lead
        uint256 end;    // time ends/ended
        bool ended;     // has round end function been ran
        uint256 strt;   // time round started
        uint256 keys;   // keys
        uint256 eth;    // total eth in
        uint256 pot;    // eth to pot (during round) / final amount paid to winner (after round ends)
        uint256 mask;   // global mask
        uint256 ico;    // total eth sent in during ICO phase
        uint256 icoGen; // total eth for gen during ICO phase
        uint256 icoAvg; // average key price for ICO phase
    }
}

library F3DKeysCalcLong {
    using SafeMath for *;

    function keysRec(uint256 _curEth, uint256 _newEth) internal pure returns (uint256) {
        return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
    }

    function ethRec(uint256 _curKeys, uint256 _sellKeys) internal pure returns (uint256) {
        return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
    }

    function keys(uint256 _eth) internal pure returns(uint256) {
        return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
    }

    function eth(uint256 _keys) internal pure returns(uint256) {
        return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }
}

interface PartnershipInterface {
    function deposit() external payable returns(bool);
}

interface PlayerBookInterface {
    function getPlayerID(address _addr) external returns (uint256);
    function getPlayerName(uint256 _pID) external view returns (bytes32);
    function getPlayerLAff(uint256 _pID) external view returns (uint256);
    function getPlayerAddr(uint256 _pID) external view returns (address);
    function getNameFee() external view returns (uint256);
    function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all) external payable returns(bool, uint256);
    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all) external payable returns(bool, uint256);
    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all) external payable returns(bool, uint256);
}

interface ExternalSettingsInterface {
    function getLongGap() external returns(uint256);
    function getLongExtra() external returns(uint256);
    function updateLongExtra(uint256 _pID) external;
}

contract F3Devents {
    event onNewName(
        uint256 indexed playerID,
        address indexed playerAddress,
        bytes32 indexed playerName,
        bool isNewPlayer,
        uint256 affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 amountPaid,
        uint256 timeStamp
    );

    event onEndTx(
        uint256 compressedData,
        uint256 compressedIDs,
        bytes32 playerName,
        address playerAddress,
        uint256 ethIn,
        uint256 keysBought,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount,
        uint256 potAmount,
        uint256 airDropPot
    );

    event onWithdraw(
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 timeStamp
    );

    event onWithdrawAndDistribute(
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );

    event onBuyAndDistribute(
        address playerAddress,
        bytes32 playerName,
        uint256 ethIn,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );

    event onReLoadAndDistribute(
        address playerAddress,
        bytes32 playerName,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );

    event onAffiliatePayout(
        uint256 indexed affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 indexed roundID,
        uint256 indexed buyerID,
        uint256 amount,
        uint256 timeStamp
    );

    event onPotSwapDeposit(
        uint256 roundID,
        uint256 amountAddedToPot
    );
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not owner.");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address.");

        owner = _newOwner;

        emit OwnershipTransferred(owner, _newOwner);
    }
}

contract Fomo3DQuick is F3Devents, Ownable {
    using SafeMath for *;
    using NameFilter for string;
    using F3DKeysCalcLong for uint256;

    ExternalSettingsInterface constant private externalSettings = ExternalSettingsInterface(0xC77c0EF6B077D2F251C19B2DBA3ad8e0DF26aF31);
    PartnershipInterface constant private partnership = PartnershipInterface(0x59Ff25C4E2550bc9E2115dbcD28b949d7670d134);
	PlayerBookInterface constant private playerBook = PlayerBookInterface(0x38926C81Bf68130fFfc6972F7b5DBc550272EB4e);

    string constant public name = "Fomo3D Quick (Released)";
    string constant public symbol = "F3DQ";

    uint256 private rndGap_ = externalSettings.getLongGap();
	uint256 private rndExtra_ = externalSettings.getLongExtra();
    uint256 constant private rndInit_ = 1 minutes;
    uint256 constant private rndInc_ = 30 seconds;
    uint256 constant private rndMax_ = 24 minutes;

	uint256 public airDropPot_;
    uint256 public airDropTracker_ = 0;

    uint256 public rID_;

    bool public activated_ = false;

    mapping (address => uint256) public pIDxAddr_;
    mapping (bytes32 => uint256) public pIDxName_;
    mapping (uint256 => F3Ddatasets.Player) public plyr_;
    mapping (uint256 => mapping (uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_;
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_;

    mapping (uint256 => F3Ddatasets.Round) public round_;
    mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;

    mapping (uint256 => uint256) public fees_;
    mapping (uint256 => uint256) public potSplit_;

    constructor() public {
		// 团队分配比例（0 = 鲸队; 1 = 熊队; 2 = 蛇队; 3 = 牛队）

        fees_[0] = 30;   //50% 奖池, 15% 推荐人, 4% 社区基金, 1% 空投奖池
        fees_[1] = 35;   //45% 奖池, 15% 推荐人, 4% 社区基金, 1% 空投奖池
        fees_[2] = 50;   //30% 奖池, 15% 推荐人, 4% 社区基金, 1% 空投奖池
        fees_[3] = 45;   //35% 奖池, 15% 推荐人, 4% 社区基金, 1% 空投奖池

        potSplit_[0] = 30;  //58% 中奖者, 10% 下一轮奖池, 2% 社区基金
        potSplit_[1] = 25;  //58% 中奖者, 15% 下一轮奖池, 2% 社区基金
        potSplit_[2] = 10;  //58% 中奖者, 30% 下一轮奖池, 2% 社区基金
        potSplit_[3] = 15;  //58% 中奖者, 25% 下一轮奖池, 2% 社区基金
	}

    modifier isActivated() {
        require(activated_ == true, "its not ready yet. check ?eta in discord");
        _;
    }

    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {
            _codeLength := extcodesize(_addr)
        }

        require(_codeLength == 0, "sorry humans only");
        _;
    }

    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        require(_eth <= 100000000000000000000000, "no vitalik, no");
        _;
    }

    function() public payable isActivated isHuman isWithinLimits(msg.value) {
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        uint256 _pID = pIDxAddr_[msg.sender];

        buyCore(_pID, plyr_[_pID].laff, 2, _eventData_);
    }

    function buyXid(uint256 _affCode, uint256 _team) public payable isActivated isHuman isWithinLimits(msg.value) {
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        uint256 _pID = pIDxAddr_[msg.sender];
        if (_affCode == 0 || _affCode == _pID) {
            _affCode = plyr_[_pID].laff;
        } else if (_affCode != plyr_[_pID].laff) {
            plyr_[_pID].laff = _affCode;
        }

        _team = verifyTeam(_team);

        buyCore(_pID, _affCode, _team, _eventData_);
    }

    function buyXaddr(address _affCode, uint256 _team) public payable isActivated isHuman isWithinLimits(msg.value) {
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        uint256 _pID = pIDxAddr_[msg.sender];

        uint256 _affID;
        if (_affCode == address(0) || _affCode == msg.sender) {
            _affID = plyr_[_pID].laff;
        } else {
            _affID = pIDxAddr_[_affCode];
            if (_affID != plyr_[_pID].laff) {
                plyr_[_pID].laff = _affID;
            }
        }

        _team = verifyTeam(_team);

        buyCore(_pID, _affID, _team, _eventData_);
    }

    function buyXname(bytes32 _affCode, uint256 _team) public payable isActivated isHuman isWithinLimits(msg.value) {
        F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        uint256 _pID = pIDxAddr_[msg.sender];

        uint256 _affID;
        if (_affCode == "" || _affCode == plyr_[_pID].name) {
            _affID = plyr_[_pID].laff;
        } else {
            _affID = pIDxName_[_affCode];
            if (_affID != plyr_[_pID].laff) {
                plyr_[_pID].laff = _affID;
            }
        }

        _team = verifyTeam(_team);

        buyCore(_pID, _affID, _team, _eventData_);
    }

    function reLoadXid(uint256 _affCode, uint256 _team, uint256 _eth) public isActivated isHuman isWithinLimits(_eth) {
        F3Ddatasets.EventReturns memory _eventData_;

        uint256 _pID = pIDxAddr_[msg.sender];
        if (_affCode == 0 || _affCode == _pID) {
            _affCode = plyr_[_pID].laff;
        } else if (_affCode != plyr_[_pID].laff) {
            plyr_[_pID].laff = _affCode;
        }

        _team = verifyTeam(_team);

        reLoadCore(_pID, _affCode, _team, _eth, _eventData_);
    }

    function reLoadXaddr(address _affCode, uint256 _team, uint256 _eth) public isActivated isHuman isWithinLimits(_eth) {
        F3Ddatasets.EventReturns memory _eventData_;

        uint256 _pID = pIDxAddr_[msg.sender];

        uint256 _affID;
        if (_affCode == address(0) || _affCode == msg.sender) {
            _affID = plyr_[_pID].laff;
        } else {
            _affID = pIDxAddr_[_affCode];
            if (_affID != plyr_[_pID].laff) {
                plyr_[_pID].laff = _affID;
            }
        }

        _team = verifyTeam(_team);

        reLoadCore(_pID, _affID, _team, _eth, _eventData_);
    }

    function reLoadXname(bytes32 _affCode, uint256 _team, uint256 _eth) public isActivated isHuman isWithinLimits(_eth) {
        F3Ddatasets.EventReturns memory _eventData_;

        uint256 _pID = pIDxAddr_[msg.sender];

        uint256 _affID;
        if (_affCode == "" || _affCode == plyr_[_pID].name) {
            _affID = plyr_[_pID].laff;
        } else {
            _affID = pIDxName_[_affCode];
            if (_affID != plyr_[_pID].laff) {
                plyr_[_pID].laff = _affID;
            }
        }

        _team = verifyTeam(_team);

        reLoadCore(_pID, _affID, _team, _eth, _eventData_);
    }

    function withdraw() public isActivated isHuman {
        uint256 _now = block.timestamp;
        uint256 _eth;
        uint256 _pID = pIDxAddr_[msg.sender];
        uint256 _rID = rID_;
        if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0) {
            F3Ddatasets.EventReturns memory _eventData_;

			round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);

            _eth = withdrawEarnings(_pID);
            if (_eth > 0) {
                plyr_[_pID].addr.transfer(_eth);
            }

            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

            emit F3Devents.onWithdrawAndDistribute(
                msg.sender,
                plyr_[_pID].name,
                _eth,
                _eventData_.compressedData,
                _eventData_.compressedIDs,
                _eventData_.winnerAddr,
                _eventData_.winnerName,
                _eventData_.amountWon,
                _eventData_.newPot,
                _eventData_.genAmount
            );
        } else {
            _eth = withdrawEarnings(_pID);
            if (_eth > 0) {
                plyr_[_pID].addr.transfer(_eth);
            }

            emit F3Devents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
        }
    }

    function registerNameXID(string _nameString, uint256 _affCode, bool _all) public payable isHuman {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = playerBook.registerNameXIDFromDapp.value(_paid)(_addr, _name, _affCode, _all);

        uint256 _pID = pIDxAddr_[_addr];

        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, block.timestamp);
    }

    function registerNameXaddr(string _nameString, address _affCode, bool _all) public payable isHuman {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = playerBook.registerNameXaddrFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);

        uint256 _pID = pIDxAddr_[_addr];

        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, block.timestamp);
    }

    function registerNameXname(string _nameString, bytes32 _affCode, bool _all) public payable isHuman {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = playerBook.registerNameXnameFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);

        uint256 _pID = pIDxAddr_[_addr];

        emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, block.timestamp);
    }

    function getBuyPrice() public view returns(uint256) {
        uint256 _now = block.timestamp;
        uint256 _rID = rID_;
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) {
            return (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000);
        }
        return 75000000000000;
    }

    function getTimeLeft() public view returns(uint256) {
        uint256 _now = block.timestamp;
        uint256 _rID = rID_;
        if (_now < round_[_rID].end) {
            if (_now > round_[_rID].strt + rndGap_) {
                return (round_[_rID].end).sub(_now);
            }
            return (round_[_rID].strt + rndGap_).sub(_now);
        }
        return 0;
    }

    function getPlayerVaults(uint256 _pID) public view returns(uint256 ,uint256, uint256) {
        uint256 _rID = rID_;
        if (block.timestamp > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0) {
            if (round_[_rID].plyr == _pID) {
                return (
                    (plyr_[_pID].win).add(((round_[_rID].pot).mul(48)) / 100),
                    (plyr_[_pID].gen).add(getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)),
                    plyr_[_pID].aff
                );
            }
            return (
                plyr_[_pID].win,
                (plyr_[_pID].gen).add(getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)),
                plyr_[_pID].aff
            );
        }
        return (
            plyr_[_pID].win,
            (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
            plyr_[_pID].aff
        );
    }

    function getPlayerVaultsHelper(uint256 _pID, uint256 _rID) private view returns(uint256) {
        return (((((round_[_rID].mask).add(((((round_[_rID].pot).mul(potSplit_[round_[_rID].team])) / 100).mul(1000000000000000000)) / (round_[_rID].keys))).mul(plyrRnds_[_pID][_rID].keys)) / 1000000000000000000));
    }

    function getCurrentRoundInfo() public view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256) {
        uint256 _rID = rID_;

        return (
            round_[_rID].ico,                               // 0
            _rID,                                           // 1
            round_[_rID].keys,                              // 2
            round_[_rID].end,                               // 3
            round_[_rID].strt,                              // 4
            round_[_rID].pot,                               // 5
            (round_[_rID].team + (round_[_rID].plyr * 10)), // 6
            plyr_[round_[_rID].plyr].addr,                  // 7
            plyr_[round_[_rID].plyr].name,                  // 8
            rndTmEth_[_rID][0],                             // 9
            rndTmEth_[_rID][1],                             // 10
            rndTmEth_[_rID][2],                             // 11
            rndTmEth_[_rID][3],                             // 12
            airDropTracker_ + (airDropPot_ * 1000)          // 13
        );
    }

    function getPlayerInfoByAddress(address _addr) public view returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256) {
        if (_addr == address(0)) {
            _addr == msg.sender;
        }

        uint256 _rID = rID_;
        uint256 _pID = pIDxAddr_[_addr];

        return (
            _pID,                                                                // 0
            plyr_[_pID].name,                                                    // 1
            plyrRnds_[_pID][_rID].keys,                                          // 2
            plyr_[_pID].win,                                                     // 3
            (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)), // 4
            plyr_[_pID].aff,                                                     // 5
            plyrRnds_[_pID][_rID].eth                                            // 6
        );
    }

    function buyCore(uint256 _pID, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_) private {
        uint256 _now = block.timestamp;
        uint256 _rID = rID_;
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) {
            core(_rID, _pID, msg.value, _affID, _team, _eventData_);
        } else {
            if (_now > round_[_rID].end && round_[_rID].ended == false) {
			    round_[_rID].ended = true;
                _eventData_ = endRound(_eventData_);

                _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
                _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

                emit F3Devents.onBuyAndDistribute (
                    msg.sender,
                    plyr_[_pID].name,
                    msg.value,
                    _eventData_.compressedData,
                    _eventData_.compressedIDs,
                    _eventData_.winnerAddr,
                    _eventData_.winnerName,
                    _eventData_.amountWon,
                    _eventData_.newPot,
                    _eventData_.genAmount
                );
            }

            plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
        }
    }

    function reLoadCore(uint256 _pID, uint256 _affID, uint256 _team, uint256 _eth, F3Ddatasets.EventReturns memory _eventData_) private {
        uint256 _now = block.timestamp;
        uint256 _rID = rID_;
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) {
            plyr_[_pID].gen = withdrawEarnings(_pID).sub(_eth);

            core(_rID, _pID, _eth, _affID, _team, _eventData_);
        } else if (_now > round_[_rID].end && round_[_rID].ended == false) {
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);

            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

            emit F3Devents.onReLoadAndDistribute (
                msg.sender,
                plyr_[_pID].name,
                _eventData_.compressedData,
                _eventData_.compressedIDs,
                _eventData_.winnerAddr,
                _eventData_.winnerName,
                _eventData_.amountWon,
                _eventData_.newPot,
                _eventData_.genAmount
            );
        }
    }

    function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_) private {
        externalSettings.updateLongExtra(_pID);

        if (plyrRnds_[_pID][_rID].keys == 0) {
            _eventData_ = managePlayer(_pID, _eventData_);
        }

        if (round_[_rID].eth < 100000000000000000000 && plyrRnds_[_pID][_rID].eth.add(_eth) > 1000000000000000000) {
            uint256 _availableLimit = (1000000000000000000).sub(plyrRnds_[_pID][_rID].eth);
            uint256 _refund = _eth.sub(_availableLimit);
            plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
            _eth = _availableLimit;
        }

        if (_eth > 1000000000) {
            uint256 _keys = (round_[_rID].eth).keysRec(_eth);
            if (_keys >= 1000000000000000000) {
                updateTimer(_keys, _rID);

                if (round_[_rID].plyr != _pID) {
                    round_[_rID].plyr = _pID;
                }
                if (round_[_rID].team != _team) {
                    round_[_rID].team = _team;
                }

                _eventData_.compressedData = _eventData_.compressedData + 100;
            }

            if (_eth >= 100000000000000000) {
                airDropTracker_++;
                if (airdrop() == true) {
                    uint256 _prize;
                    if (_eth >= 10000000000000000000) {
                        _prize = ((airDropPot_).mul(75)) / 100;
                        plyr_[_pID].win = (plyr_[_pID].win).add(_prize);

                        airDropPot_ = (airDropPot_).sub(_prize);

                        _eventData_.compressedData += 300000000000000000000000000000000;
                    } else if (_eth >= 1000000000000000000 && _eth < 10000000000000000000) {
                        _prize = ((airDropPot_).mul(50)) / 100;
                        plyr_[_pID].win = (plyr_[_pID].win).add(_prize);

                        airDropPot_ = (airDropPot_).sub(_prize);

                        _eventData_.compressedData += 200000000000000000000000000000000;
                    } else if (_eth >= 100000000000000000 && _eth < 1000000000000000000) {
                        _prize = ((airDropPot_).mul(25)) / 100;
                        plyr_[_pID].win = (plyr_[_pID].win).add(_prize);

                        airDropPot_ = (airDropPot_).sub(_prize);

                        _eventData_.compressedData += 300000000000000000000000000000000;
                    }

                    _eventData_.compressedData += 10000000000000000000000000000000;
                    _eventData_.compressedData += _prize * 1000000000000000000000000000000000;

                    airDropTracker_ = 0;
                }
            }

            _eventData_.compressedData = _eventData_.compressedData + (airDropTracker_ * 1000);

            plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
            plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);

            round_[_rID].keys = _keys.add(round_[_rID].keys);
            round_[_rID].eth = _eth.add(round_[_rID].eth);
            rndTmEth_[_rID][_team] = _eth.add(rndTmEth_[_rID][_team]);

            _eventData_ = distributeExternal(_rID, _pID, _eth, _affID, _eventData_);
            _eventData_ = distributeInternal(_rID, _pID, _eth, _team, _keys, _eventData_);

		    endTx(_pID, _team, _eth, _keys, _eventData_);
        }
    }

    function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast) private view returns(uint256) {
        return ((((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask));
    }

    function calcKeysReceived(uint256 _rID, uint256 _eth) public view returns(uint256) {
        uint256 _now = block.timestamp;
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) {
            return (round_[_rID].eth).keysRec(_eth);
        }
        return (_eth).keys();
    }

    function iWantXKeys(uint256 _keys) public view returns(uint256) {
        uint256 _now = block.timestamp;
        uint256 _rID = rID_;
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) {
            return ( (round_[_rID].keys.add(_keys)).ethRec(_keys) );
        }
        return ( (_keys).eth() );
    }

    function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff) external {
        require (msg.sender == address(playerBook), "your not playerNames contract... hmmm..");
        if (pIDxAddr_[_addr] != _pID) {
            pIDxAddr_[_addr] = _pID;
        }
        if (pIDxName_[_name] != _pID) {
            pIDxName_[_name] = _pID;
        }
        if (plyr_[_pID].addr != _addr) {
            plyr_[_pID].addr = _addr;
        }
        if (plyr_[_pID].name != _name) {
            plyr_[_pID].name = _name;
        }
        if (plyr_[_pID].laff != _laff) {
            plyr_[_pID].laff = _laff;
        }
        if (plyrNames_[_pID][_name] == false) {
            plyrNames_[_pID][_name] = true;
        }
    }

    function receivePlayerNameList(uint256 _pID, bytes32 _name) external {
        require (msg.sender == address(playerBook), "your not playerNames contract... hmmm..");
        if(plyrNames_[_pID][_name] == false) {
            plyrNames_[_pID][_name] = true;
        }
    }

    function determinePID(F3Ddatasets.EventReturns memory _eventData_) private returns (F3Ddatasets.EventReturns) {
        uint256 _pID = pIDxAddr_[msg.sender];
        if (_pID == 0) {
            _pID = playerBook.getPlayerID(msg.sender);
            bytes32 _name = playerBook.getPlayerName(_pID);
            uint256 _laff = playerBook.getPlayerLAff(_pID);

            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;

            if (_name != "") {
                pIDxName_[_name] = _pID;
                plyr_[_pID].name = _name;
                plyrNames_[_pID][_name] = true;
            }

            if (_laff != 0 && _laff != _pID) {
                plyr_[_pID].laff = _laff;
            }

            _eventData_.compressedData = _eventData_.compressedData + 1;
        }

        return (_eventData_);
    }

    function verifyTeam(uint256 _team) private pure returns (uint256) {
        if (_team < 0 || _team > 3) {
            return 2;
        }
        return _team;
    }

    function managePlayer(uint256 _pID, F3Ddatasets.EventReturns memory _eventData_) private returns (F3Ddatasets.EventReturns) {
        if (plyr_[_pID].lrnd != 0) {
            updateGenVault(_pID, plyr_[_pID].lrnd);
        }
        plyr_[_pID].lrnd = rID_;

        _eventData_.compressedData = _eventData_.compressedData + 10;

        return _eventData_;
    }

    function endRound(F3Ddatasets.EventReturns memory _eventData_) private returns (F3Ddatasets.EventReturns) {
        uint256 _rID = rID_;

        uint256 _winPID = round_[_rID].plyr;
        uint256 _winTID = round_[_rID].team;

        uint256 _pot = round_[_rID].pot;

        // 中奖者拿走 58%
        uint256 _win = (_pot.mul(58)) / 100;

        // 提取社区基金 2%
        uint256 _com = (_pot / 50);

        // 所在团队分红
        uint256 _gen = (_pot.mul(potSplit_[_winTID])) / 100;

        // 进入下一轮奖池
        uint256 _res = _pot.sub(_win).sub(_com).sub(_gen);

        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
        if (_dust > 0) {
            _gen = _gen.sub(_dust);
            _res = _res.add(_dust);
        }

        plyr_[_winPID].win = _win.add(plyr_[_winPID].win);

        partnership.deposit.value(_com)();

        round_[_rID].mask = _ppt.add(round_[_rID].mask);

        _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000) + (_winTID * 100000000000000000);
        _eventData_.winnerAddr = plyr_[_winPID].addr;
        _eventData_.winnerName = plyr_[_winPID].name;
        _eventData_.amountWon = _win;
        _eventData_.genAmount = _gen;
        _eventData_.newPot = _res;

        rID_++;
        _rID++;
        round_[_rID].strt = block.timestamp;
        round_[_rID].end = block.timestamp.add(rndInit_).add(rndGap_);
        round_[_rID].pot = _res;

        return(_eventData_);
    }

    function updateGenVault(uint256 _pID, uint256 _rIDlast) private {
        uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
        if (_earnings > 0) {
            plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
            plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);
        }
    }

    function updateTimer(uint256 _keys, uint256 _rID) private {
        uint256 _now = block.timestamp;

        uint256 _newTime;
        if (_now > round_[_rID].end && round_[_rID].plyr == 0) {
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
        } else {
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);
        }

        if (_newTime < (rndMax_).add(_now)) {
            round_[_rID].end = _newTime;
        } else {
            round_[_rID].end = rndMax_.add(_now);
        }
    }

    function airdrop() private view returns(bool) {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            (block.timestamp).add(
                block.difficulty
            ).add(
                uint256(keccak256(abi.encodePacked(block.coinbase))) / block.timestamp
            ).add(
                block.gaslimit
            ).add(
                (uint256(keccak256(abi.encodePacked(msg.sender)))) / block.timestamp
            ).add(
                block.number
            )
        )));

        if ((seed - ((seed / 1000) * 1000)) < airDropTracker_) {
            return true;
        }

        return false;
    }

    function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, F3Ddatasets.EventReturns memory _eventData_) private returns(F3Ddatasets.EventReturns) {
        // 社区基金 4%
        uint256 _com = _eth / 25;
        partnership.deposit.value(_com)();

        // 直接推荐人 5%
        uint256 _firstAff = _eth / 20;

        if (_affID == _pID || plyr_[_affID].name == "") {
            _affID = 1;
        }
        plyr_[_affID].aff = _firstAff.add(plyr_[_affID].aff);
        emit F3Devents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _firstAff, block.timestamp);

        // 二级推荐人 10%
        uint256 _secondAff = _eth / 10;

        uint256 _secondAffID = plyr_[_affID].laff;
        if (_secondAffID == plyr_[_secondAffID].laff && plyr_[_secondAffID].name == "") {
            _secondAffID = 1;
        }
        plyr_[_secondAffID].aff = _secondAff.add(plyr_[_secondAffID].aff);
        emit F3Devents.onAffiliatePayout(_secondAffID, plyr_[_secondAffID].addr, plyr_[_secondAffID].name, _rID, _affID, _secondAff, block.timestamp);

        return _eventData_;
    }

    function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _team, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_) private returns(F3Ddatasets.EventReturns) {
        // 团队分红
        uint256 _gen = (_eth.mul(fees_[_team])) / 100;

        // 空投奖池 1%
        uint256 _air = _eth / 100;
        airDropPot_ = airDropPot_.add(_air);

        // 奖池
        uint256 _pot = _eth.sub(_gen.add(_eth / 5));

        uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
        if (_dust > 0) {
            _gen = _gen.sub(_dust);
        }

        round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);

        _eventData_.genAmount = _gen.add(_eventData_.genAmount);
        _eventData_.potAmount = _pot;

        return(_eventData_);
    }

    function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys) private returns(uint256) {
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        round_[_rID].mask = _ppt.add(round_[_rID].mask);

        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
        plyrRnds_[_pID][_rID].mask = (((round_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);

        return (_gen.sub((_ppt.mul(round_[_rID].keys)) / (1000000000000000000)));
    }

    function withdrawEarnings(uint256 _pID) private returns(uint256) {
        updateGenVault(_pID, plyr_[_pID].lrnd);

        uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
        if (_earnings > 0) {
            plyr_[_pID].win = 0;
            plyr_[_pID].gen = 0;
            plyr_[_pID].aff = 0;
        }

        return(_earnings);
    }

    function endTx(uint256 _pID, uint256 _team, uint256 _eth, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_) private {
        _eventData_.compressedData = _eventData_.compressedData + (block.timestamp * 1000000000000000000) + (_team * 100000000000000000000000000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + _pID + (rID_ * 10000000000000000000000000000000000000000000000000000);

        emit F3Devents.onEndTx(
            _eventData_.compressedData,
            _eventData_.compressedIDs,
            plyr_[_pID].name,
            msg.sender,
            _eth,
            _keys,
            _eventData_.winnerAddr,
            _eventData_.winnerName,
            _eventData_.amountWon,
            _eventData_.newPot,
            _eventData_.genAmount,
            _eventData_.potAmount,
            airDropPot_
        );
    }

    function activate() public onlyOwner {
        require(activated_ == false, "fomo3d already activated");

        activated_ = true;

		rID_ = 1;
        round_[1].strt = block.timestamp + rndExtra_ - rndGap_;
        round_[1].end = block.timestamp + rndInit_ + rndExtra_;
    }
}