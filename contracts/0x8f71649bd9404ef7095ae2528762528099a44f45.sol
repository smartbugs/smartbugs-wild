pragma solidity ^0.4.24;

/*
*　　　　　　　　　　　　　　　　　　　　 　 　 ＿＿＿
*　　　　　　　　　　　　　　　　　　　　　　　|三三三i
*　　　　　　　　　　　　　　　　　　　　　　　|三三三|  
*　　神さま　かなえて　happy-end　　　　　　ノ三三三.廴        
*　　　　　　　　　　　　　　　　　　　　　　从ﾉ_八ﾑ_}ﾉ
*　　　＿＿}ヽ__　　　　　　　　　　 　 　 　 ヽ‐个‐ｱ.     © Team EC Present. 
*　　 　｀ﾋｙ　　ﾉ三ﾆ==ｪ- ＿＿＿ ｨｪ=ｧ='ﾌ)ヽ-''Lヽ         
*　　　　 ｀‐⌒L三ﾆ=ﾆ三三三三三三三〈oi 人 ）o〉三ﾆ、　　　 
*　　　　　　　　　　 　 ｀￣￣￣￣｀弌三三}. !　ｒ三三三iｊ　　　　　　
*　　　　　　　　　　 　 　 　 　 　 　,': ::三三|. ! ,'三三三刈、
*　　　　　　　　　 　 　 　 　 　 　 ,': : :::｀i三|人|三三ﾊ三j: ;　　　　　
*　                  　　　　　　 ,': : : : : 比|　 |三三i |三|: ',
*　　　　　　　　　　　　　　　　　,': : : : : : :Vi|　 |三三i |三|: : ',
*　　　　　　　　　　　　　　　　, ': : : : : : : ﾉ }乂{三三| |三|: : :;
*    BigOne Game v1.0　　  ,': : : : : : : : ::ｊ三三三三|: |三i: : ::,
*　　　　　　　　　　　 　 　 ,': : : : : : : : :/三三三三〈: :!三!: : ::;
*　　　　　　　　　 　 　 　 ,': : : : : : : : /三三三三三!, |三!: : : ,
*　　　　　　　 　 　 　 　 ,': : : : : : : : ::ｊ三三八三三Y {⌒i: : : :,
*　　　　　　　　 　 　 　 ,': : : : : : : : : /三//: }三三ｊ: : ー': : : : ,
*　　　　　　 　 　 　 　 ,': : : : : : : : :.//三/: : |三三|: : : : : : : : :;
*　　　　 　 　 　 　 　 ,': : : : : : : : ://三/: : : |三三|: : : : : : : : ;
*　　 　 　 　 　 　 　 ,': : : : : : : : :/三ii/ : : : :|三三|: : : : : : : : :;
*　　　 　 　 　 　 　 ,': : : : : : : : /三//: : : : ::!三三!: : : : : : : : ;
*　　　　 　 　 　 　 ,': : : : : : : : :ｊ三// : : : : ::|三三!: : : : : : : : :;
*　　 　 　 　 　 　 ,': : : : : : : : : |三ij: : : : : : ::ｌ三ﾆ:ｊ: : : : : : : : : ;
*　　　 　 　 　 　 ,': : : : : : : : ::::|三ij: : : : : : : !三刈: : : : : : : : : ;
*　 　 　 　 　 　 ,': : : : : : : : : : :|三ij: : : : : : ::ｊ三iiﾃ: : : : : : : : : :;
*　　 　 　 　 　 ,': : : : : : : : : : : |三ij: : : : : : ::|三iiﾘ: : : : : : : : : : ;
*　　　 　 　 　 ,':: : : : : : : : : : : :|三ij::: : :: :: :::|三リ: : : : : : : : : : :;
*　　　　　　　 ,': : : : : : : : : : : : :|三ij : : : : : ::ｌ三iﾘ: : : : : : : : : : : ',
*           　　　　　　　　　　　　　　   ｒ'三三jiY, : : : : : ::|三ij : : : : : : : : : : : ',
*　 　 　 　 　 　      　　                |三 j´　　　　　　　　｀',    signature:
*　　　　　　　　　　　　 　 　 　 　 　 　 　  |三三k、
*                            　　　　　　　　｀ー≠='.  93511761c3aa73c0a197c55537328f7f797c4429 
*/


contract BigOneEvents {
    event onNewPlayer
    (
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

    event onEndTx
    (
        uint256 indexed playerID,
        address indexed playerAddress,
        uint256 roundID,
        uint256 ethIn,
        uint256 pot
    );

    event onWithdraw
    (
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 timeStamp
    );

    event onAffiliatePayout
    (
        uint256 indexed affiliateID,
        address affiliateAddress,
        // bytes32 affiliateName,
        uint256 indexed roundID,
        uint256 indexed buyerID,
        uint256 amount,
        uint256 timeStamp
    );

    event onEndRound
    (
        uint256 roundID,
        uint256 roundTypeID,
        address winnerAddr,
        uint256 winnerNum,
        uint256 amountWon
    );
}

contract BigOne is BigOneEvents {
    using SafeMath for *;
    using NameFilter for string;

    UserDataManagerInterface constant private UserDataManager = UserDataManagerInterface(0x5576250692275701eFdE5EEb51596e2D9460790b);

    //****************
    // constant
    //****************
    address private admin = msg.sender;
    address private shareCom1 = 0xdcd90eA01E441654C9e8e8fcfBF407781d196287;
    address private shareCom2 = 0xaF63842fb4A9B3769E0e1b7DAb9C5068dB78d3d3;

    string constant public name = "bigOne";
    string constant public symbol = "bigOne";   

    //****************
    // var
    //****************
    uint256 public rID_;    
    uint256 public rTypeID_;

    //****************
    // PLAYER DATA
    //****************
    mapping (address => uint256) public pIDxAddr_;          // (addr => pID) returns player id by address
    mapping (bytes32 => uint256) public pIDxName_;          // (name => pID) returns player id by name
    mapping (uint256 => BigOneData.Player) public plyr_;   // (pID => data) player data
    mapping (uint256 => mapping (uint256 => BigOneData.PlayerRoundData)) public plyrRnds_;   // (pID => rID => data) 
    mapping (uint256 => uint256) private playerSecret_;

    //****************
    // ROUND DATA
    //****************
    mapping (uint256 => BigOneData.RoundSetting) public rSettingXTypeID_;   //(rType => setting)
    mapping (uint256 => BigOneData.Round) public round_;   // (rID => data) round data
    mapping (uint256 => uint256) public currentRoundxType_;
    mapping (uint256 => uint256) private roundCommonSecret_;

    //==============================================================================
    // init
    //==============================================================================
    constructor() public {
        rID_ = 0;
        rTypeID_ = 0;
    }

    //==============================================================================
    // checks
    //==============================================================================
    modifier isActivated() {
        require(activated_ == true, "its not ready yet.  check ?eta in discord");
        _;
    }

    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    modifier onlyDevs() {
        require(admin == msg.sender, "msg sender is not a dev");
        _;
    }

    modifier isWithinLimits(uint256 _eth,uint256 _typeID) {
        require(rSettingXTypeID_[_typeID].isValue, "invaild mode id");
        require(_eth >= rSettingXTypeID_[_typeID].perShare, "less than min allow");
        require(_eth <= rSettingXTypeID_[_typeID].limit, "more than max allow");
        _;
    }

    modifier modeCheck(uint256 _typeID) {
        require(rSettingXTypeID_[_typeID].isValue, "invaild mode id");
        _;
    }

    //==============================================================================
    // admin
    //==============================================================================
    bool public activated_ = false;
    function activate(uint256 _initSecret)
        onlyDevs()
        public
    {
        require(activated_ == false, "BigOne already activated");
        require(rTypeID_ > 0, "No round mode setup");
        activated_ = true;

        for(uint256 i = 0; i < rTypeID_; i++) {
            rID_++;
            round_[rID_].start = now;
            round_[rID_].typeID = i + 1;
            round_[rID_].count = 1;
            round_[rID_].pot = 0;
            generateRndSecret(rID_,_initSecret);
            currentRoundxType_[i + 1] = rID_;
        }
    }

    function addRoundMode(uint256 _limit, uint256 _perShare, uint256 _shareMax)
        onlyDevs()
        public
    {
        require(activated_ == false, "BigOne already started");

        rTypeID_++;
        rSettingXTypeID_[rTypeID_].id = rTypeID_;
        rSettingXTypeID_[rTypeID_].limit = _limit;
        rSettingXTypeID_[rTypeID_].perShare = _perShare;
        rSettingXTypeID_[rTypeID_].shareMax = _shareMax;
        rSettingXTypeID_[rTypeID_].isValue = true;
    }

    //==============================================================================
    // public
    //==============================================================================

    function()
        isActivated()
        isHuman()
        isWithinLimits(msg.value,1)
        public
        payable
    {
        determinePID();

        uint256 _pID = pIDxAddr_[msg.sender];

        buyCore(_pID, plyr_[_pID].laff,1);
    }

    function buyXid(uint256 _affCode, uint256 _mode)
        isActivated()
        isHuman()
        isWithinLimits(msg.value,_mode)
        public
        payable
    {
        determinePID();

        uint256 _pID = pIDxAddr_[msg.sender];

        if (_affCode == 0 || _affCode == _pID)
        {
            _affCode = plyr_[_pID].laff;

        } else if (_affCode != plyr_[_pID].laff) {
            plyr_[_pID].laff = _affCode;
        }

        buyCore(_pID, _affCode, _mode);
    }

    function buyXaddr(address _affCode, uint256 _mode)
        isActivated()
        isHuman()
        isWithinLimits(msg.value,_mode)
        public
        payable
    {
        determinePID();

        uint256 _pID = pIDxAddr_[msg.sender];

        uint256 _affID;
        if (_affCode == address(0) || _affCode == msg.sender)
        {
            _affID = plyr_[_pID].laff;

        } else {
            _affID = pIDxAddr_[_affCode];

            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }

        buyCore(_pID, _affID, _mode);
    }

    function buyXname(bytes32 _affCode, uint256 _mode)
        isActivated()
        isHuman()
        isWithinLimits(msg.value,_mode)
        public
        payable
    {
        determinePID();

        uint256 _pID = pIDxAddr_[msg.sender];

        uint256 _affID;
        if (_affCode == '' || _affCode == plyr_[_pID].name)
        {
            _affID = plyr_[_pID].laff;

        } else {
            _affID = pIDxName_[_affCode];

            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }

        buyCore(_pID, _affID, _mode);
    }

    function reLoadXid(uint256 _affCode, uint256 _eth, uint256 _mode)
        isActivated()
        isHuman()
        isWithinLimits(_eth,_mode)
        public
    {
        uint256 _pID = pIDxAddr_[msg.sender];

        if (_affCode == 0 || _affCode == _pID)
        {
            _affCode = plyr_[_pID].laff;

        } else if (_affCode != plyr_[_pID].laff) {
            plyr_[_pID].laff = _affCode;
        }

        reLoadCore(_pID, _affCode, _eth, _mode);
    }

    function reLoadXaddr(address _affCode, uint256 _eth, uint256 _mode)
        isActivated()
        isHuman()
        isWithinLimits(_eth,_mode)
        public
    {
        uint256 _pID = pIDxAddr_[msg.sender];

        uint256 _affID;
        if (_affCode == address(0) || _affCode == msg.sender)
        {
            _affID = plyr_[_pID].laff;
        } else {
            _affID = pIDxAddr_[_affCode];

            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }

        reLoadCore(_pID, _affID, _eth, _mode);
    }

    function reLoadXname(bytes32 _affCode, uint256 _eth, uint256 _mode)
        isActivated()
        isHuman()
        isWithinLimits(_eth,_mode)
        public
    {
        uint256 _pID = pIDxAddr_[msg.sender];

        uint256 _affID;
        if (_affCode == '' || _affCode == plyr_[_pID].name)
        {
            _affID = plyr_[_pID].laff;
        } else {
            _affID = pIDxName_[_affCode];

            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }
        reLoadCore(_pID, _affID, _eth,_mode);
    }

    function withdraw()
        isActivated()
        isHuman()
        public
    {
        // grab time
        uint256 _now = now;

        // fetch player ID
        uint256 _pID = pIDxAddr_[msg.sender];

        // setup temp var for player eth
        uint256 _eth;
        uint256 _withdrawFee;
    
        // get their earnings
        _eth = withdrawEarnings(_pID);

        // gib moni
        if (_eth > 0)
        {
            //5% trade tax
            _withdrawFee = _eth.div(5);

            shareCom1.transfer((_withdrawFee.div(2)));
            shareCom2.transfer((_withdrawFee.div(10)));
            admin.transfer((_withdrawFee.div(10).mul(4)));

            plyr_[_pID].addr.transfer(_eth.sub(_withdrawFee));
        }

        // fire withdraw event
        emit BigOneEvents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
    }

    function registerNameXID(string _nameString, uint256 _affCode, bool _all)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = UserDataManager.registerNameXIDFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);

        uint256 _pID = pIDxAddr_[_addr];
        if(_isNewPlayer) generatePlayerSecret(_pID);
        emit BigOneEvents.onNewPlayer(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }

    function registerNameXaddr(string _nameString, address _affCode, bool _all)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = UserDataManager.registerNameXaddrFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);

        uint256 _pID = pIDxAddr_[_addr];
        if(_isNewPlayer) generatePlayerSecret(_pID);
        emit BigOneEvents.onNewPlayer(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }

    function registerNameXname(string _nameString, bytes32 _affCode, bool _all)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = UserDataManager.registerNameXnameFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);

        uint256 _pID = pIDxAddr_[_addr];
        if(_isNewPlayer) generatePlayerSecret(_pID);
        emit BigOneEvents.onNewPlayer(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }

//==============================================================================
// query
//==============================================================================

    function iWantXKeys(uint256 _keys,uint256 _mode)
        modeCheck(_mode)
        public
        view
        returns(uint256)
    {
        return _keys.mul(rSettingXTypeID_[_mode].perShare);
    }

    function getPlayerVaults(uint256 _pID)
        public
        view
        //win,gen,aff
        returns(uint256[])
    {
        uint256[] memory _vaults = new uint256[](3);
        _vaults[0] = plyr_[_pID].win;
        _vaults[1] = plyr_[_pID].gen;
        _vaults[2] = plyr_[_pID].aff;

        return _vaults;
    }

    function getCurrentRoundInfo(uint256 _mode)
        modeCheck(_mode)
        public
        view
        returns(uint256[])
    {
        uint256 _rID = currentRoundxType_[_mode];

        uint256[] memory _roundInfos = new uint256[](6);
        _roundInfos[0] = _mode;
        _roundInfos[1] = _rID;
        _roundInfos[2] = round_[_rID].count;
        _roundInfos[3] = round_[_rID].keyCount;
        _roundInfos[4] = round_[_rID].eth;
        _roundInfos[5] = round_[_rID].pot;

        return _roundInfos;
    }

    function getPlayerInfoByAddress(address _addr,uint256 _mode)
        modeCheck(_mode)
        public
        view
        returns(uint256, uint256, bytes32)
    {
        uint256 _rID = currentRoundxType_[_mode];

        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];

        return
        (
            _pID,                               //0
            plyrRnds_[_pID][_rID].eth,          //1
            plyr_[_pID].name                   //2
        );
    }

    function getPlayerKeys(address _addr,uint256 _mode)
        public
        view
        returns(uint256[]) 
    {
        uint256 _rID = currentRoundxType_[_mode];

        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];

        uint256[] memory _keys = new uint256[](plyrRnds_[_pID][_rID].keyCount);
        uint256 _keyIndex = 0;
        for(uint256 i = 0;i < plyrRnds_[_pID][_rID].purchaseIDs.length;i++) {
            uint256 _pIndex = plyrRnds_[_pID][_rID].purchaseIDs[i];
            BigOneData.PurchaseRecord memory _pr = round_[_rID].purchases[_pIndex];
            if(_pr.plyr == _pID) {
                for(uint256 j = _pr.start; j <= _pr.end; j++) {
                    _keys[_keyIndex] = j;
                    _keyIndex++;
                }
            }
        }
        return _keys;
    }

    function getPlayerAff(uint256 _pID)
        public
        view
        returns (uint256[])
    {
        uint256[] memory _affs = new uint256[](3);

        _affs[0] = plyr_[_pID].laffID;
        if (_affs[0] != 0)
        {
            //second level aff
            _affs[1] = plyr_[_affs[0]].laffID;

            if(_affs[1] != 0)
            {
                //third level aff
                _affs[2] = plyr_[_affs[1]].laffID;
            }
        }
        return _affs;
    }

//==============================================================================
// private
//==============================================================================

    function buyCore(uint256 _pID, uint256 _affID, uint256 _mode)
        private
    {
        uint256 _rID = currentRoundxType_[_mode];

        if (round_[_rID].keyCount < rSettingXTypeID_[_mode].shareMax && round_[_rID].plyr == 0)
        {
            core(_rID, _pID, msg.value, _affID,_mode);
        } else {
            if (round_[_rID].keyCount >= rSettingXTypeID_[_mode].shareMax && round_[_rID].plyr == 0 && round_[_rID].ended == false)
            {
                round_[_rID].ended = true;
                endRound(_mode); 
            }
            //directly refund player
            plyr_[_pID].addr.transfer(msg.value);
        }
    }

    function reLoadCore(uint256 _pID, uint256 _affID, uint256 _eth, uint _mode)
        private
    {
        uint256 _rID = currentRoundxType_[_mode];

        if (round_[_rID].keyCount < rSettingXTypeID_[_mode].shareMax && round_[_rID].plyr == 0)
        {
            plyr_[_pID].gen = withdrawEarnings(_pID).sub(_eth);
            core(_rID, _pID, _eth, _affID,_mode);
        } else {
            if (round_[_rID].keyCount >= rSettingXTypeID_[_mode].shareMax && round_[_rID].plyr == 0 && round_[_rID].ended == false) 
            {
                round_[_rID].ended = true;
                endRound(_mode);      
            }
        }
    }

    function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _mode)
        private
    {
        if (plyrRnds_[_pID][_rID].keyCount == 0) 
        {
            managePlayer(_pID,_rID);
        }

        if (round_[_rID].keyCount < rSettingXTypeID_[_mode].shareMax)
        {
            uint256 _ethAdd = ((rSettingXTypeID_[_mode].shareMax).sub(round_[_rID].keyCount)).mul(rSettingXTypeID_[_mode].perShare);
            if(_eth > _ethAdd) {
                plyr_[_pID].gen = plyr_[_pID].gen.add(_eth.sub(_ethAdd)); 
            } else {
                _ethAdd = _eth;
            }

            uint256 _keyAdd = _ethAdd.div(rSettingXTypeID_[_mode].perShare);
            uint256 _keyEnd = (round_[_rID].keyCount).add(_keyAdd);
            
            BigOneData.PurchaseRecord memory _pr;
            _pr.plyr = _pID;
            _pr.start = round_[_rID].keyCount;
            _pr.end = _keyEnd - 1;
            round_[_rID].purchases.push(_pr);
            plyrRnds_[_pID][_rID].purchaseIDs.push(round_[_rID].purchases.length - 1);
            plyrRnds_[_pID][_rID].keyCount += _keyAdd;

            plyrRnds_[_pID][_rID].eth = _ethAdd.add(plyrRnds_[_pID][_rID].eth);
            round_[_rID].keyCount = _keyEnd;
            round_[_rID].eth = _ethAdd.add(round_[_rID].eth);
            round_[_rID].pot = (round_[_rID].pot).add(_ethAdd.mul(95).div(100));

            distributeExternal(_rID, _pID, _ethAdd, _affID);

            if (round_[_rID].keyCount >= rSettingXTypeID_[_mode].shareMax && round_[_rID].plyr == 0 && round_[_rID].ended == false) 
            {
                round_[_rID].ended = true;
                endRound(_mode); 
            }

            emit BigOneEvents.onEndTx
            (
               _pID,
                msg.sender,
                _rID,
                _ethAdd,
                round_[_rID].pot
            );

        } else {
            // put back eth in players vault
            plyr_[_pID].gen = plyr_[_pID].gen.add(_eth);    
        }

    }


//==============================================================================
// util
//==============================================================================

    function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff)
        external
    {
        require (msg.sender == address(UserDataManager), "your not userManager contract");
        if (pIDxAddr_[_addr] != _pID)
            pIDxAddr_[_addr] = _pID;
        if (pIDxName_[_name] != _pID)
            pIDxName_[_name] = _pID;
        if (plyr_[_pID].addr != _addr)
            plyr_[_pID].addr = _addr;
        if (plyr_[_pID].name != _name)
            plyr_[_pID].name = _name;
        if (plyr_[_pID].laff != _laff)
            plyr_[_pID].laff = _laff;
    }

    function determinePID()
        private
    {
        uint256 _pID = pIDxAddr_[msg.sender];
        if (_pID == 0)
        {
            _pID = UserDataManager.getPlayerID(msg.sender);
            bytes32 _name = UserDataManager.getPlayerName(_pID);
            uint256 _laff = UserDataManager.getPlayerLaff(_pID);

            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;

            if (_name != "")
            {
                pIDxName_[_name] = _pID;
                plyr_[_pID].name = _name;
            }

            if (_laff != 0 && _laff != _pID) 
            {
                plyr_[_pID].laff = _laff;
            }
            generatePlayerSecret(_pID);
        }
    }

    function withdrawEarnings(uint256 _pID)
        private
        returns(uint256)
    {
        uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
        if (_earnings > 0)
        {
            plyr_[_pID].win = 0;
            plyr_[_pID].gen = 0;
            plyr_[_pID].aff = 0;
        }

        return(_earnings);
    }

    function managePlayer(uint256 _pID,uint256 _rID)
        private
    {
        plyr_[_pID].lrnd = _rID;
    }

    function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID)
        private
    {
         // pay community rewards
        // uint256 _com = _eth / 50;
        

        // if (address(admin).call.value((_com / 2))() == false)
        // {
        //     _p3d = _com / 2;
        //     _com = _com / 2;
        // }

        // if (address(shareCom).call.value((_com / 2))() == false)
        // {
        //     _p3d = _p3d.add(_com / 2);
        //     _com = _com.sub(_com / 2);
        // }

        uint256 _p3d = distributeAff(_rID,_pID,_eth,_affID);

        if (_p3d > 0)
        {
            shareCom1.transfer((_p3d.div(2)));
            shareCom2.transfer((_p3d.div(10)));
            admin.transfer((_p3d.div(10).mul(4)));
        }
    }

    function distributeAff(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID)
        private
        returns(uint256)
    {
        uint256 _addP3d = 0;

        // distribute share to affiliate
        uint256 _aff1 = _eth.div(20);
        // uint256 _aff2 = _eth.div(20);
        // uint256 _aff3 = _eth.div(100).mul(3);


        // decide what to do with affiliate share of fees
        // affiliate must not be self
        if ((_affID != 0) && (_affID != _pID) && (plyr_[_affID].addr != address(0)))
        {
            plyr_[_pID].laffID = _affID;
            plyr_[_affID].aff = _aff1.add(plyr_[_affID].aff);

            emit BigOneEvents.onAffiliatePayout(_affID, plyr_[_affID].addr, _rID, _pID, _aff1, now);

            //second level aff
            // uint256 _secLaff = plyr_[_affID].laffID;
            // if((_secLaff != 0) && (_secLaff != _pID))
            // {
            //     plyr_[_secLaff].aff = _aff3.add(plyr_[_secLaff].aff);
            //     emit BigOneEvents.onAffiliatePayout(_secLaff, plyr_[_secLaff].addr, _rID, _pID, _aff3, now);
            // } else {
            //     _addP3d = _addP3d.add(_aff3);
            // }
        } else {
            _addP3d = _addP3d.add(_aff1);
        }
        return(_addP3d);
    }

    function distributeWinning(uint256 _mode, uint256 _amount, uint256 _affID)
        private
    {
        if ((_affID != 0) && (plyr_[_affID].addr != address(0)))
        {
            uint256 _affReward = (rSettingXTypeID_[_mode].limit).div(20);
            if(_affReward > _amount)
            {
                _affReward = _amount;
            } else {
                uint256 _rest = _amount.sub(_affReward);
                if(_rest > 0)
                {
                    shareCom1.transfer((_rest.div(2)));
                    shareCom2.transfer((_rest.div(10)));
                    admin.transfer((_rest.div(10).mul(4)));
                }
            }
            plyr_[_affID].aff = _affReward.add(plyr_[_affID].aff);
        } else {
            shareCom1.transfer((_amount.div(2)));
            shareCom2.transfer((_amount.div(10)));
            admin.transfer((_amount.div(10).mul(4)));
        }
    }

    function generateRndSecret(uint256 _rID, uint256 _lastSecret)
        private
    {
        roundCommonSecret_[_rID] = uint256(keccak256(abi.encodePacked(_lastSecret, _rID, block.difficulty, now)));
    }

    function generatePlayerSecret(uint256 _pID)
        private
    {
        playerSecret_[_pID] = uint256(keccak256(abi.encodePacked(block.blockhash(block.number-1), msg.sender, block.difficulty, now)));
    }

    function endRound(uint256 _mode)
        private
    {
        uint256 _rID = currentRoundxType_[_mode];

        uint256 _winKey = uint256(keccak256(abi.encodePacked(roundCommonSecret_[_rID], playerSecret_[pIDxAddr_[msg.sender]-1], block.difficulty, now))).mod(round_[_rID].keyCount);
        uint256 _winPID;
        for(uint256 i = 0;i < round_[_rID].purchases.length; i++) {
            if(round_[_rID].purchases[i].start <= _winKey && round_[_rID].purchases[i].end >= _winKey) {
                _winPID = round_[_rID].purchases[i].plyr;
                break;
            }
        }

        if(_winPID != 0) {
            uint256 _winAmount = (rSettingXTypeID_[_mode].limit).mul(90).div(100);

            // pay our winner
            plyr_[_winPID].win = (_winAmount).add(plyr_[_winPID].win);

            distributeWinning(_mode, (round_[_rID].pot).sub(_winAmount), plyr_[_winPID].laffID);
        }

        round_[_rID].plyr = _winPID;
        round_[_rID].end = now;

        emit BigOneEvents.onEndRound
        (
            _rID,
            _mode,
            plyr_[_winPID].addr,
            _winKey,
            _winAmount
        );

        // start next round
        rID_++;
        round_[rID_].start = now;
        round_[rID_].typeID = _mode;
        round_[rID_].count = round_[_rID].count + 1;
        round_[rID_].pot = 0;
        generateRndSecret(rID_,roundCommonSecret_[_rID]);
        currentRoundxType_[_mode] = rID_;
    }
}

//==============================================================================
// interface
//==============================================================================

interface UserDataManagerInterface {
    function getPlayerID(address _addr) external returns (uint256);
    function getPlayerName(uint256 _pID) external view returns (bytes32);
    function getPlayerLaff(uint256 _pID) external view returns (uint256);
    function getPlayerAddr(uint256 _pID) external view returns (address);
    function getNameFee() external view returns (uint256);
    function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all) external payable returns(bool, uint256);
    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all) external payable returns(bool, uint256);
    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all) external payable returns(bool, uint256);
}

//==============================================================================
// struct
//==============================================================================
library BigOneData {

    struct Player {
        address addr;   // player address
        bytes32 name;   // player name
        uint256 win;    // winnings vault
        uint256 gen;    // general vault
        uint256 aff;    // affiliate vault
        uint256 lrnd;   // last round played
        uint256 laff;   // last affiliate id used
        uint256 laffID;   // last affiliate id unaffected
    }
    struct PlayerRoundData {
        uint256 eth;    // eth player has added to round 
        uint256[] purchaseIDs;   // keys
        uint256 keyCount;
    }
    struct RoundSetting {
        uint256 id;
        uint256 limit;   
        uint256 perShare; 
        uint256 shareMax;   
        bool isValue;
    }
    struct Round {
        uint256 plyr;   // pID of player in win
        uint256 end;    // time ends/ended
        bool ended;     // has round end function been ran
        uint256 start;   // time round started

        uint256 keyCount;   // keys
        BigOneData.PurchaseRecord[] purchases;  
        uint256 eth;    // total eth in
        uint256 pot;    // eth to pot (during round) / final amount paid to winner (after round ends)

        uint256 typeID;
        uint256 count;
    }
    struct PurchaseRecord {
        uint256 plyr;   
        uint256 start;
        uint256 end;
    }

}


library NameFilter {

    function nameFilter(string _input)
        internal
        pure
        returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        //sorry limited to 32 characters
        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        // make sure it doesnt start with or end with space
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
        // make sure first two characters are not 0x
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

        // create a bool to track if we have a non number character
        bool _hasNonNumber;

        // convert & check
        for (uint256 i = 0; i < _length; i++)
        {
            // if its uppercase A-Z
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                // convert to lower case a-z
                _temp[i] = byte(uint(_temp[i]) + 32);

                // we have a non number
                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                    // require character is a space
                    _temp[i] == 0x20 ||
                    // OR lowercase a-z
                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                    // or 0-9
                    (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                // make sure theres not 2x spaces in a row
                if (_temp[i] == 0x20)
                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");

                // see if we have a character other than a number
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;
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


library SafeMath 
{
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
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

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

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