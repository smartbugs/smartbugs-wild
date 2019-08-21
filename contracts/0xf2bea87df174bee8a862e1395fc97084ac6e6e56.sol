/*
@author radarzhhua@gamil.com
*/
pragma solidity ^0.4.24;


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

library NameFilter {

    /**
     * @dev filters name strings
     * -converts uppercase to lower case.
     * -makes sure it does not start/end with a space
     * -makes sure it does not contain multiple spaces in a row
     * -cannot be only numbers
     * -cannot start with 0x
     * -restricts characters to A-Z, a-z, 0-9, and space.
     * @return reprocessed string in bytes32 format
     */
    function nameFilter(string _input) internal pure returns (bytes32){
        bytes memory _temp = bytes(_input);
        uint _length = _temp.length;
        //sorry limited to 32 characters
        require(_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        // make sure it doesnt start with or end with space
        require(_temp[0] != 0x20 && _temp[_length - 1] != 0x20, "string cannot start or end with space");
        // make sure first two characters are not 0x
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }
        // create a bool to track if we have a non number character
        bool _hasNonNumber;
        // convert & check
        for (uint i = 0; i < _length; i++)
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
                    require(_temp[i + 1] != 0x20, "string cannot contain consecutive spaces");

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





// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract PlayerBook is Owned {
    using SafeMath for uint;
    using NameFilter for string;
    bool public actived = false;
    uint public registrationFee_ = 1 finney;            // price to register a name
    uint public pID_;        // total number of players
    mapping(address => uint) public pIDxAddr_;          // (addr => pID) returns player id by address
    mapping(uint => Player) public plyr_;               // (pID => data) player data
    mapping(bytes32 => uint) public pIDxName_;          // (name => pID) returns player id by name
    mapping(uint => mapping(bytes32 => bool)) public plyrNames_; // (pID => name => bool) list of names a player owns.  (used so you can change your display name amoungst any name you own)
    mapping(uint => mapping(uint => bytes32)) public plyrNameList_; // (pID => nameNum => name) list of names a player owns
    struct Player {
        address addr;
        bytes32 name;
        uint laff;
        uint names;
    }
    /**
     * @dev prevents contracts from interacting with playerBook
     */
    modifier isHuman {
        address _addr = msg.sender;
        uint _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }
    modifier isActive {
        require(actived, "sorry game paused");
        _;
    }
    modifier isRegistered {
        address _addr = msg.sender;
        uint _pid = pIDxAddr_[msg.sender];
        require(_pid != 0, " you need register the address");
        _;
    }

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        // premine the admin names (sorry not sorry)
        plyr_[1].addr = 0x2ba0ECF5eC2dD51F115d8526333395beba490363;
        plyr_[1].name = "admin";
        plyr_[1].names = 1;
        pIDxAddr_[0x2ba0ECF5eC2dD51F115d8526333395beba490363] = 1;
        pIDxName_["admin"] = 1;
        plyrNames_[1]["admin"] = true;
        plyrNameList_[1][1] = "admin";
        pID_ = 1;
    }

    function checkIfNameValid(string _nameStr) public view returns (bool){
        bytes32 _name = _nameStr.nameFilter();
        if (pIDxName_[_name] == 0)
            return (true);
        else
            return (false);
    }

    function determinePID(address _addr) private returns (bool){
        if (pIDxAddr_[_addr] == 0) {
            pID_++;
            pIDxAddr_[_addr] = pID_;
            plyr_[pID_].addr = _addr;
            // set the new player bool to true
            return (true);
        } else {
            return (false);
        }
    }

    function registerNameXID(string _nameString, uint _affCode) public isActive isHuman payable {
        // make sure name fees paid
        require(msg.value >= registrationFee_, "umm.....  you have to pay the name fee");
        // filter name + condition checks
        bytes32 _name = NameFilter.nameFilter(_nameString);
        // set up address
        address _addr = msg.sender;
        // set up our tx event data and determine if player is new or not
        determinePID(_addr);
        // fetch player id
        uint _pID = pIDxAddr_[_addr];
        // manage affiliate residuals
        // if no affiliate code was given, no new affiliate code was given, or the
        // player tried to use their own pID as an affiliate code, lolz
        //_affCode must little than the pID_
        if (_affCode != 0 && _affCode != plyr_[_pID].laff && _affCode != _pID && _affCode <= pID_) {
            // update last affiliate
            plyr_[_pID].laff = _affCode;
        } else {
            if(plyr_[_pID].laff == 0)
              plyr_[_pID].laff = 1;
        }
        // register name
        plyr_[1].addr.transfer(msg.value);
        registerNameCore(_pID, _name);
    }

    function registerNameCore(uint _pID, bytes32 _name) private {
        if (pIDxName_[_name] != 0)
            require(plyrNames_[_pID][_name] == true, "sorry that names already taken");
        plyr_[_pID].name = _name;
        pIDxName_[_name] = _pID;
        if (plyrNames_[_pID][_name] == false)
        {
            plyrNames_[_pID][_name] = true;
            plyr_[_pID].names++;
            plyrNameList_[_pID][plyr_[_pID].names] = _name;
        }
    }

    function getPlayerLaffCount(address _addr) internal view returns (uint){
        uint _pid = pIDxAddr_[_addr];
        if (_pid == 0) {
            return 0;
        } else {
            uint result = 0;
            for (uint i = 1; i <= pID_; i++) {
                if (plyr_[i].laff == _pid) {
                    result ++;
                }
            }
            return result;
        }
    }

    function getPlayerID(address _addr) external view returns (uint) {
        return (pIDxAddr_[_addr]);
    }

    function getPlayerCount() external view returns (uint){
        return pID_;
    }

    function getPlayerName(uint _pID) external view returns (bytes32){
        return (plyr_[_pID].name);
    }

    function getPlayerLAff(uint _pID) external view returns (uint){
        return (plyr_[_pID].laff);
    }

    function getPlayerAddr(uint _pID) external view returns (address){
        return (plyr_[_pID].addr);
    }

    function getNameFee() external view returns (uint){
        return (registrationFee_);
    }

    function setRegistrationFee(uint _fee) public onlyOwner {
        require(_fee != 0);
        registrationFee_ = _fee;
    }

    function active() public onlyOwner {
        actived = true;
    }
}



// ----------------------------------------------------------------------------
contract Treasure is PlayerBook {
    uint private seed = 18;                    //random seed
    /* bool private canSet = true; */
    //module 0,1,2
    uint[3] public gameRound = [1, 1, 1];                         //rounds index by module
    uint[3] public maxKeys = [1200, 12000, 60000];              //index by module
    uint[3] public keyLimits = [100, 1000, 5000];               //index by module
    uint public keyPrice = 10 finney;
    uint public devFee = 10;
    uint public laffFee1 = 10;
    uint public laffFee2 = 1;
    address public devWallet = 0xB4D4709C2D537047683294c4040aBB9d616e23B5;
    mapping(uint => mapping(uint => RoundInfo)) public gameInfo;   //module => round => info
    mapping(uint => mapping(uint => mapping(uint => uint))) public userAff;     //module => round => pid => affCount
    struct RoundInfo {
        uint module;            //module 0,1,2
        uint rd;                // rounds
        uint count;             // player number and id
        uint keys;              // purchased keys
        uint maxKeys;           // end keys
        uint keyLimits;
        uint award;             //award of the round
        address winner;         //winner
        bool isEnd;
        mapping(uint => uint) userKeys;        // pid => keys
        mapping(uint => uint) userId;      // count => pid
    }

    modifier validModule(uint _module){
        require(_module >= 0 && _module <= 2, " error module");
        _;
    }

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        initRoundInfo(0, 1);
        initRoundInfo(1, 1);
        initRoundInfo(2, 1);
    }
    //only be called once
    /* function setSeed(uint _seed) public onlyOwner {
      require(canSet);
      canSet = false;
      seed = _seed;
    } */

    /**
   random int
    */
    function randInt(uint256 _start, uint256 _end, uint256 _nonce)
    private
    view
    returns (uint256)
    {
        uint256 _range = _end.sub(_start);
        uint256 value = uint256(keccak256(abi.encodePacked(
                (block.timestamp).add
                (block.difficulty).add
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
                (block.gaslimit).add
                ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
                (block.number),
                _nonce
            )));
        return (_start + value - ((value / _range) * _range));
    }

    function initRoundInfo(uint _mode, uint _rd) private validModule(_mode) {
        uint _maxKeys = maxKeys[_mode];
        uint _keyLimits = keyLimits[_mode];
        RoundInfo memory rf = RoundInfo({
            module : _mode,
            rd : _rd,
            count : 0,
            keys : 0,
            maxKeys : _maxKeys,
            keyLimits : _keyLimits,
            award : 0,
            winner : address(0),
            isEnd : false
            });
        gameInfo[_mode][_rd] = rf;
    }
    //user detail of one round
    function getUserDetail(uint _mode, uint _rd) public validModule(_mode) view returns (uint _eth, uint _award, uint _affEth){
        address _addr = msg.sender;
        uint _pid = pIDxAddr_[_addr];
        require(_pid != 0, " you need register the address");
        uint _userKeys = gameInfo[_mode][_rd].userKeys[_pid];
        _eth = _userKeys * keyPrice;
        if (gameInfo[_mode][_rd].winner == _addr)
            _award = gameInfo[_mode][_rd].award;
        else
            _award = 0;
        _affEth = userAff[_mode][_rd][_pid];
    }

    function getAllLaffAwards(address _addr) private view returns (uint){
        uint _pid = pIDxAddr_[_addr];
        require(_pid != 0, " you need register the address");
        uint sum = 0;
        for (uint i = 0; i < 3; i++) {
            for (uint j = 1; j <= gameRound[i]; j++) {
                uint value = userAff[i][j][_pid];
                if (value > 0)
                    sum = sum.add(value);
            }
        }
        return sum;
    }

    function getPlayerAllDetail() external view returns (uint[] modes, uint[] rounds, uint[] eths, uint[] awards, uint _laffAwards, uint _laffCount){
        address _addr = msg.sender;
        uint _pid = pIDxAddr_[_addr];
        require(_pid != 0, " you need register the address");
        uint i = gameRound[0] + gameRound[1] + gameRound[2];
        uint counter = 0;
        RoundInfo[] memory allInfo = new RoundInfo[](i);
        for (i = 0; i < 3; i++) {
            for (uint j = 1; j <= gameRound[i]; j++) {
                if (gameInfo[i][j].userKeys[_pid] > 0) {
                    allInfo[counter] = gameInfo[i][j];
                    counter ++;
                }
            }
        }
        modes = new uint[](counter);
        rounds = new uint[](counter);
        eths = new uint[](counter);
        awards = new uint[](counter);
        for (i = 0; i < counter; i++) {
            modes[i] = allInfo[i].module;
            rounds[i] = allInfo[i].rd;
            eths[i] = gameInfo[modes[i]][rounds[i]].userKeys[_pid].mul(keyPrice);
            if (_addr == allInfo[i].winner) {
                awards[i] = allInfo[i].award;
            } else {
                awards[i] = 0;
            }
        }
        _laffAwards = getAllLaffAwards(_addr);
        _laffCount = getPlayerLaffCount(_addr);
    }

    function buyKeys(uint _mode, uint _rd) public isHuman isActive validModule(_mode) payable {
        address _addr = msg.sender;
        uint _pid = pIDxAddr_[_addr];
        require(_pid != 0, " you need register the address");
        uint _eth = msg.value;
        require(_eth >= keyPrice, "you need buy one or more keys");
        require(_rd == gameRound[_mode], "error round");
        RoundInfo storage ri = gameInfo[_mode][_rd];
        require(!ri.isEnd, "the round is end");
        require(ri.keys < ri.maxKeys, "the round maxKeys");
        uint _keys = _eth.div(keyPrice);
        require(ri.userKeys[_pid] < ri.keyLimits);
        if (ri.userKeys[_pid] == 0) {
            ri.count ++;
            ri.userId[ri.count] = _pid;
        }
        if (_keys.add(ri.keys) > ri.maxKeys) {
            _keys = ri.maxKeys.sub(ri.keys);
        }
        if (_keys.add(ri.userKeys[_pid]) > ri.keyLimits) {
            _keys = ri.keyLimits - ri.userKeys[_pid];
        }
        require(_keys > 0);
        uint rand = randInt(0, 100, seed+_keys);
        seed = seed.add(rand);
        _eth = _keys.mul(keyPrice);
        ri.userKeys[_pid] = ri.userKeys[_pid].add(_keys);
        ri.keys = ri.keys.add(_keys);
        //back
        if(msg.value - _eth > 10 szabo )
          msg.sender.transfer(msg.value - _eth);
        checkAff(_mode, _rd, _pid, _eth);
        if (ri.keys >= ri.maxKeys) {
            endRound(_mode, _rd);
        }
    }

    function getUserInfo(address _addr) public view returns (uint _pID, bytes32 _name, uint _laff, uint[] _keys){
        _pID = pIDxAddr_[_addr];
        _name = plyr_[_pID].name;
        _laff = plyr_[_pID].laff;
        _keys = new uint[](3);
        for (uint i = 0; i < 3; i++) {
            _keys[i] = gameInfo[i][gameRound[i]].userKeys[_pID];
        }
    }


    function endRound(uint _mode, uint _rd) private {
        RoundInfo storage ri = gameInfo[_mode][_rd];
        require(!ri.isEnd, "the rounds has end");
        ri.isEnd = true;
        uint _eth = ri.award.mul(devFee) / 100;
        uint _win = calWinner(_mode, _rd);
        ri.winner = plyr_[_win].addr;
        gameRound[_mode] = _rd + 1;
        initRoundInfo(_mode, _rd + 1);
        devWallet.transfer(_eth);
        plyr_[_win].addr.transfer(ri.award.sub(_eth));
    }

    function calWinner(uint _mode, uint _rd) private returns (uint){
        RoundInfo storage ri = gameInfo[_mode][_rd];
        uint rand = randInt(0, ri.maxKeys, seed);
        seed = seed.add(rand);
        uint keySum = 0;
        uint _win = 0;
        for (uint i = 1; i <= ri.count; i++) {
            uint _key = ri.userKeys[ri.userId[i]];
            keySum += _key;
            if (rand < keySum) {
                _win = i;
                break;
            }
        }
        require(_win > 0);
        return ri.userId[_win];
    }

    function checkAff(uint _mode, uint _rd, uint _pid, uint _eth) private {
        uint fee1 = _eth.mul(laffFee1).div(100);
        uint fee2 = _eth.mul(laffFee2).div(100);
        uint res = _eth.sub(fee1).sub(fee2);
        gameInfo[_mode][_rd].award += res;
        uint laff1 = plyr_[_pid].laff;
        if (laff1 == 0) {
            plyr_[1].addr.transfer(fee1.add(fee2));
        } else {
            plyr_[laff1].addr.transfer(fee1);
            userAff[_mode][_rd][laff1] += fee1;
            uint laff2 = plyr_[laff1].laff;
            if (laff2 == 0) {
                plyr_[1].addr.transfer(fee2);
            } else {
                plyr_[laff2].addr.transfer(fee2);
                userAff[_mode][_rd][laff2] += fee2;
            }
        }
    }

    function getRoundInfo(uint _mode) external validModule(_mode) view returns (uint _cr, uint _ck, uint _mk, uint _award){
        _cr = gameRound[_mode];
        _ck = gameInfo[_mode][_cr].keys;
        _mk = gameInfo[_mode][_cr].maxKeys;
        _award = gameInfo[_mode][_cr].award;
    }

    function getRoundIsEnd(uint _mode, uint _rd) external validModule(_mode) view returns (bool){
        require(_rd > 0 && _rd <= gameRound[_mode]);
        return gameInfo[_mode][_rd].isEnd;
    }

    function getAwardHistorhy(uint _mode) external validModule(_mode) view returns (address[] dh, uint[] ah){
        uint hr = gameRound[_mode] - 1;
        dh = new address[](hr);
        ah = new uint[](hr);
        if (hr != 0) {
            for (uint i = 1; i <= hr; i++) {
                RoundInfo memory rf = gameInfo[_mode][i];
                dh[i - 1] = rf.winner;
                ah[i - 1] = rf.award;
            }
        }
    }
        /* ****************************************************
              *********                            *********
                *********                        *********
                  *********    thanks a lot    *********
                    *********                *********
                      *********            *********
                        *********        *********
                          *********    *********
                            ******************
                              **************
                                **********
                                  *****
                                    *
         *********************************************************/
}