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
*  UserDataManager v0.1　　,': : : : : : : : ::ｊ三三三三|: |三i: : ::,
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


interface UserDataManagerReceiverInterface {
    function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff) external;
    function receivePlayerNameList(uint256 _pID, bytes32 _name) external;
}

contract UserDataManager {
    using NameFilter for string;
    using SafeMath for uint256;

    address private admin = msg.sender;
    uint256 public registrationFee_ = 0;                   
    mapping(uint256 => UserDataManagerReceiverInterface) public games_;  
    mapping(address => bytes32) public gameNames_;         
    mapping(address => uint256) public gameIDs_;           
    uint256 public gID_;        
    uint256 public pID_;       
    mapping (address => uint256) public pIDxAddr_;          
    mapping (bytes32 => uint256) public pIDxName_;          
    mapping (uint256 => Player) public plyr_;              
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; 
    mapping (uint256 => mapping (uint256 => bytes32)) public plyrNameList_; 
    struct Player {
        address addr;
        bytes32 name;
        uint256 laff;
        uint256 names;
    }

    constructor()
        public
    {
        // premine the dev names 
        plyr_[1].addr = 0xe27c188521248a49adfc61090d3c8ab7c3754e0a;
        plyr_[1].name = "matt";
        plyr_[1].names = 1;
        pIDxAddr_[0xe27c188521248a49adfc61090d3c8ab7c3754e0a] = 1;
        pIDxName_["matt"] = 1;
        plyrNames_[1]["matt"] = true;
        plyrNameList_[1][1] = "matt";

        pID_ = 1;
    }

    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    modifier onlyDevs()
    {
        require(admin == msg.sender, "msg sender is not a dev");
        _;
    }

    modifier isRegisteredGame()
    {
        require(gameIDs_[msg.sender] != 0);
        _;
    }

    event onNewName
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

    function checkIfNameValid(string _nameStr)
        public
        view
        returns(bool)
    {
        bytes32 _name = _nameStr.nameFilter();
        if (pIDxName_[_name] == 0)
            return (true);
        else
            return (false);
    }

    function registerNameXID(string _nameString, uint256 _affCode, bool _all)
        isHuman()
        public
        payable
    {
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        bytes32 _name = NameFilter.nameFilter(_nameString);

        address _addr = msg.sender;

        bool _isNewPlayer = determinePID(_addr);

        uint256 _pID = pIDxAddr_[_addr];

        if (_affCode != 0 && _affCode != plyr_[_pID].laff && _affCode != _pID)
        {
            plyr_[_pID].laff = _affCode;
        } else if (_affCode == _pID) {
            _affCode = 0;
        }

        registerNameCore(_pID, _addr, _affCode, _name, _isNewPlayer, _all);
    }

    function registerNameXaddr(string _nameString, address _affCode, bool _all)
        isHuman()
        public
        payable
    {
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        bytes32 _name = NameFilter.nameFilter(_nameString);

        address _addr = msg.sender;

        bool _isNewPlayer = determinePID(_addr);

        uint256 _pID = pIDxAddr_[_addr];

        uint256 _affID;
        if (_affCode != address(0) && _affCode != _addr)
        {
            _affID = pIDxAddr_[_affCode];

            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }

        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
    }

    function registerNameXname(string _nameString, bytes32 _affCode, bool _all)
        isHuman()
        public
        payable
    {
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        bytes32 _name = NameFilter.nameFilter(_nameString);

        address _addr = msg.sender;

        bool _isNewPlayer = determinePID(_addr);

        uint256 _pID = pIDxAddr_[_addr];

        uint256 _affID;
        if (_affCode != "" && _affCode != _name)
        {
            _affID = pIDxName_[_affCode];

            if (_affID != plyr_[_pID].laff)
            {
                plyr_[_pID].laff = _affID;
            }
        }

        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);
    }

    function addMeToGame(uint256 _gameID)
        isHuman()
        public
    {
        require(_gameID <= gID_, "that game doesn't exist yet");
        address _addr = msg.sender;
        uint256 _pID = pIDxAddr_[_addr];
        require(_pID != 0, "player dont even have an account");
        uint256 _totalNames = plyr_[_pID].names;

        games_[_gameID].receivePlayerInfo(_pID, _addr, plyr_[_pID].name, plyr_[_pID].laff);

        // add list of all names
        if (_totalNames > 1)
            for (uint256 ii = 1; ii <= _totalNames; ii++)
                games_[_gameID].receivePlayerNameList(_pID, plyrNameList_[_pID][ii]);
    }

    function addMeToAllGames()
        isHuman()
        public
    {
        address _addr = msg.sender;
        uint256 _pID = pIDxAddr_[_addr];
        require(_pID != 0, "player dont even have an account");
        uint256 _laff = plyr_[_pID].laff;
        uint256 _totalNames = plyr_[_pID].names;
        bytes32 _name = plyr_[_pID].name;

        for (uint256 i = 1; i <= gID_; i++)
        {
            games_[i].receivePlayerInfo(_pID, _addr, _name, _laff);
            if (_totalNames > 1)
                for (uint256 ii = 1; ii <= _totalNames; ii++)
                    games_[i].receivePlayerNameList(_pID, plyrNameList_[_pID][ii]);
        }

    }

    function useMyOldName(string _nameString)
        isHuman()
        public
    {
        bytes32 _name = _nameString.nameFilter();
        uint256 _pID = pIDxAddr_[msg.sender];

        require(plyrNames_[_pID][_name] == true, "thats not a name you own");

        plyr_[_pID].name = _name;
    }

    function registerNameCore(uint256 _pID, address _addr, uint256 _affID, bytes32 _name, bool _isNewPlayer, bool _all)
        private
    {
        // if names already has been used, require that current msg sender owns the name
        if (pIDxName_[_name] != 0)
            require(plyrNames_[_pID][_name] == true, "sorry that names already taken");

        // add name to player profile, registry, and name book
        plyr_[_pID].name = _name;
        pIDxName_[_name] = _pID;
        if (plyrNames_[_pID][_name] == false)
        {
            plyrNames_[_pID][_name] = true;
            plyr_[_pID].names++;
            plyrNameList_[_pID][plyr_[_pID].names] = _name;
        }

        // registration fee goes directly to community rewards
        admin.transfer(address(this).balance);

        // push player info to games
        if (_all == true)
            for (uint256 i = 1; i <= gID_; i++)
                games_[i].receivePlayerInfo(_pID, _addr, _name, _affID);

        // fire event
        emit onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, msg.value, now);
    }

    function determinePID(address _addr)
        private
        returns (bool)
    {
        if (pIDxAddr_[_addr] == 0)
        {
            pID_++;
            pIDxAddr_[_addr] = pID_;
            plyr_[pID_].addr = _addr;

            // set the new player bool to true
            return (true);
        } else {
            return (false);
        }
    }

    function getPlayerID(address _addr)
        isRegisteredGame()
        external
        returns (uint256)
    {
        determinePID(_addr);
        return (pIDxAddr_[_addr]);
    }
    function getPlayerName(uint256 _pID)
        external
        view
        returns (bytes32)
    {
        return (plyr_[_pID].name);
    }
    function getPlayerLAff(uint256 _pID)
        external
        view
        returns (uint256)
    {
        return (plyr_[_pID].laff);
    }
    function getPlayerAddr(uint256 _pID)
        external
        view
        returns (address)
    {
        return (plyr_[_pID].addr);
    }
    function getNameFee()
        external
        view
        returns (uint256)
    {
        return(registrationFee_);
    }
    function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all)
        isRegisteredGame()
        external
        payable
        returns(bool, uint256)
    {
        // make sure name fees paid
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        // set up our tx event data and determine if player is new or not
        bool _isNewPlayer = determinePID(_addr);

        // fetch player id
        uint256 _pID = pIDxAddr_[_addr];

        uint256 _affID = _affCode;
        if (_affID != 0 && _affID != plyr_[_pID].laff && _affID != _pID)
        {
            // update last affiliate
            plyr_[_pID].laff = _affID;
        } else if (_affID == _pID) {
            _affID = 0;
        }

        // register name
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);

        return(_isNewPlayer, _affID);
    }
    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all)
        isRegisteredGame()
        external
        payable
        returns(bool, uint256)
    {
        // make sure name fees paid
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        // set up our tx event data and determine if player is new or not
        bool _isNewPlayer = determinePID(_addr);

        // fetch player id
        uint256 _pID = pIDxAddr_[_addr];

        // manage affiliate residuals
        // if no affiliate code was given or player tried to use their own, lolz
        uint256 _affID;
        if (_affCode != address(0) && _affCode != _addr)
        {
            // get affiliate ID from aff Code
            _affID = pIDxAddr_[_affCode];

            // if affID is not the same as previously stored
            if (_affID != plyr_[_pID].laff)
            {
                // update last affiliate
                plyr_[_pID].laff = _affID;
            }
        }

        // register name
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);

        return(_isNewPlayer, _affID);
    }
    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all)
        isRegisteredGame()
        external
        payable
        returns(bool, uint256)
    {
        // make sure name fees paid
        require (msg.value >= registrationFee_, "umm.....  you have to pay the name fee");

        // set up our tx event data and determine if player is new or not
        bool _isNewPlayer = determinePID(_addr);

        // fetch player id
        uint256 _pID = pIDxAddr_[_addr];

        // manage affiliate residuals
        // if no affiliate code was given or player tried to use their own, lolz
        uint256 _affID;
        if (_affCode != "" && _affCode != _name)
        {
            // get affiliate ID from aff Code
            _affID = pIDxName_[_affCode];

            // if affID is not the same as previously stored
            if (_affID != plyr_[_pID].laff)
            {
                // update last affiliate
                plyr_[_pID].laff = _affID;
            }
        }

        // register name
        registerNameCore(_pID, _addr, _affID, _name, _isNewPlayer, _all);

        return(_isNewPlayer, _affID);
    }

    function addGame(address _gameAddress, string _gameNameStr)
        onlyDevs()
        public
    {
        require(gameIDs_[_gameAddress] == 0, "derp, that games already been registered");
        gID_++;
        bytes32 _name = _gameNameStr.nameFilter();
        gameIDs_[_gameAddress] = gID_;
        gameNames_[_gameAddress] = _name;
        games_[gID_] = UserDataManagerReceiverInterface(_gameAddress);

        games_[gID_].receivePlayerInfo(1, plyr_[1].addr, plyr_[1].name, 0);
        games_[gID_].receivePlayerInfo(2, plyr_[2].addr, plyr_[2].name, 0);
        games_[gID_].receivePlayerInfo(3, plyr_[3].addr, plyr_[3].name, 0);
        games_[gID_].receivePlayerInfo(4, plyr_[4].addr, plyr_[4].name, 0);
    }

    function setRegistrationFee(uint256 _fee)
        onlyDevs()
        public
    {
        registrationFee_ = _fee;
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

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y)
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

    /**
     * @dev x to the power of y
     */
    function pwr(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}