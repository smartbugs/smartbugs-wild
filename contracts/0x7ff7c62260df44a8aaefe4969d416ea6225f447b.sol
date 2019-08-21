pragma solidity >=0.4.22 <0.6.0;


interface CitizenInterface {
    function addWinIncome(address _citizen, uint256 _value) external;
    function getRef(address _address) external view returns(address);
    function isCitizen(address _address) external view returns(bool);
    
    function addGameEthSpendWin(address _citizen, uint256 _value)  external;
    function addGameEthSpendLose(address _citizen, uint256 _value) external;
    function addGameTokenSpend(address _citizen, uint256 _value) external;
}

interface DAAInterface {
    function pushDividend() external payable;
    function payOut(address _winner, uint256 _unit, uint256 _value, uint256 _valuewin) external;
    function pushGameRefIncome(address _sender,uint256 _unit, uint256 _value) external payable;
    function citizenUseDeposit(address _citizen, uint _value) external;
}

library SafeMath {
    int256 constant private INT256_MIN = -2**255;

    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

library Helper {
    using SafeMath for uint256;
    
        
    function bytes32ToUint(bytes32 n) 
        public
        pure
        returns (uint256) 
    {
        return uint256(n);
    }
    
    function stringToBytes32(string memory source) 
        public
        pure
        returns (bytes32 result) 
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function stringToUint(string memory source) 
        public
        pure
        returns (uint256)
    {
        return bytes32ToUint(stringToBytes32(source));
    }
    
    function validUsername(string _username)
        public
        pure
        returns(bool)
    {
        uint256 len = bytes(_username).length;
        // Im Raum [4, 18]
        if ((len < 4) || (len > 18)) return false;
        // Letzte Char != ' '
        if (bytes(_username)[len-1] == 32) return false;
        // Erste Char != '0'
        return uint256(bytes(_username)[0]) != 48;
    }   
    
    function getRandom(uint256 _seed, uint256 _range)
        public
        pure
        returns(uint256)
    {
        if (_range == 0) return _seed;
        return (_seed % _range);
    }

}

contract DiceGame {
    using SafeMath for uint256;
    
    modifier registered(){
        require(citizenContract.isCitizen(msg.sender), "must be a citizen");
        _;
    }
    
     modifier onlyAdmin() {
        require(msg.sender == devTeam1, "admin required");
        _;
    }
    
    event BetAGame(
        uint256 totalPayout,
        uint256 indexed histoyLen,
        address indexed player,
        uint8 prediction,
        bool prediction_type,
        uint8 result,
        bool isHighRoller,
        bool isRareWins,
        bool isWin,
        uint256 amount,
        uint256 payout,
        uint8 unit,
        uint256 creationDate
    );
    
    uint8 public decimals = 10;
    uint256 public unitRate;
    
    uint256 constant public MULTIPLIES = 985;
    uint256 public HIGHROLLER = 8 ether;
    uint256 public HIGHROLLERTOKEN = 8;
    uint256 public MIN=0.006 ether;
    uint256 public MAX=10 ether;
    uint256 public MIN_TOKEN=1;
    uint256 public MAX_TOKEN=10;
    address devTeam1;
    uint256 privateKey;
    
    struct History{
        address player;
        uint8 prediction; 
        bool prediction_type;
        uint8 result;
        bool isHighRoller;
        bool isRareWins;
        bool isWin;
        uint256 amount;
        uint256 payout;
        uint8 unit;
        uint256 creationDate;
    }
    
    // History[] public gameHistory;
    // mapping(address => History[]) public myHistory;
    // History[] public isHighRollerHistory;
    // History[] public isRareWinsHistory;
    uint256 public totalPayout;
    uint256 public histoyLen;
    
    mapping(address=>uint256) public citizenSpendEth;
    mapping(address=>uint256) public citizenSpendToken;
    mapping(address=>uint256) public citizenSeed;
    
    address[11] public mostTotalSpender;
    mapping (address => uint256) public mostTotalSpenderId;
    
    CitizenInterface public citizenContract;
    DAAInterface public DAAContract;
    
    constructor (address[3] _contract, string _key)
        public
    {
        unitRate = 10 ** uint256(decimals);
        HIGHROLLERTOKEN = HIGHROLLERTOKEN.mul(unitRate);
        MIN_TOKEN = MIN_TOKEN.mul(unitRate);
        MAX_TOKEN = MAX_TOKEN.mul(unitRate);
        
        citizenContract = CitizenInterface(_contract[1]);
        DAAContract = DAAInterface(_contract[0]);
        devTeam1 = _contract[2];
        privateKey = Helper.stringToUint(_key);
    }
    
    function setSeed(string _key) public registered() {
        citizenSeed[msg.sender] =  Helper.stringToUint(_key);
    }
    
    // function getMyHistoryLength(address _sender) public view returns(uint256){
    //     return myHistory[_sender].length;
    // }
    
    // function getGameHistoryLength() public view returns(uint256){
    //     return gameHistory.length;
    // }
    
    // function getIsHighRollerHistoryLength() public view returns(uint256){
    //     return isHighRollerHistory.length;
    // }
    
    // function getIsRareWinsHistoryLength() public view returns(uint256){
    //     return isRareWinsHistory.length;
    // }
    
    function sortMostSpend(address _citizen) public payable {
        uint256 citizen_spender = citizenSpendEth[_citizen];
        uint256 i=1;
        while (i<11) {
            if (mostTotalSpender[i]==0x0||(mostTotalSpender[i]!=0x0&&citizenSpendEth[mostTotalSpender[i]]<citizen_spender)){
                if (mostTotalSpenderId[_citizen]!=0&&mostTotalSpenderId[_citizen]<i){
                    break;
                }
                if (mostTotalSpenderId[_citizen]!=0){
                    mostTotalSpender[mostTotalSpenderId[_citizen]]=0x0;
                }
                address temp1 = mostTotalSpender[i];
                address temp2;
                uint256 j=i+1;
                while (j<11&&temp1!=0x0){
                    temp2 = mostTotalSpender[j];
                    mostTotalSpender[j]=temp1;
                    mostTotalSpenderId[temp1]=j;
                    temp1 = temp2;
                    j++;
                }
                mostTotalSpender[i]=_citizen;
                mostTotalSpenderId[_citizen]=i;
                break;
            }
            i++;
        }
    }
    
    function addToHistory(address _sender,uint8 _prediction,bool _prediction_type, uint8 _result,bool _isWin, uint256 _amount, uint256 _payout, uint8 _unit) private{
        History memory _history;
        _history.player = _sender;
        _history.prediction = _prediction;
        _history.prediction_type = _prediction_type;
        _history.result = _result;
        _history.isWin = _isWin;
        _history.amount = _amount;
        _history.payout = _payout;
        _history.unit = _unit;
        _history.creationDate = now;
        
        uint256 tempRareWin;
        if (_prediction_type){
            tempRareWin = _prediction;
        }else{
            tempRareWin = 99-_prediction;
        }
        if (_isWin==true&&tempRareWin<10) _history.isRareWins = true;
        if ((_unit==0&&_amount>HIGHROLLER)||(_unit==1&&_amount>HIGHROLLERTOKEN)) _history.isHighRoller = true;
        
        histoyLen = histoyLen+1;
        // gameHistory.push(_history);
        // myHistory[_sender].push(_history);
        // if (_history.isHighRoller) isHighRollerHistory.push(_history);
        // if (_history.isHighRoller) isRareWinsHistory.push(_history);
        emit BetAGame(totalPayout, histoyLen, _sender, _prediction, _prediction_type, _result, _history.isHighRoller, _history.isRareWins, _isWin, _amount, _payout, _unit, _history.creationDate);
    }
    
    function betByEth(bool _method,uint8 _prediction) public payable registered() {
        address _sender = msg.sender;
        uint256 _value = msg.value;
        require(_value>=MIN&&_value<=MAX);
        
        // _method = True is roll under
        // _method = False is roll over
        uint64 _seed = getSeed();
        uint8 _winnumber = uint8(Helper.getRandom(_seed, 100));
        uint256 _valueForRef = _value*15/1000;
        uint256 _win_value;
        if(_method){
            require(_prediction>0&&_prediction<96);
            citizenSpendEth[_sender] = _value.add(citizenSpendEth[_sender]);
            DAAContract.pushDividend.value(_value)();
            DAAContract.pushGameRefIncome(_sender,1,_valueForRef);
            if (_winnumber<_prediction){
                _win_value = _value.mul(MULTIPLIES).div(10).div(_prediction);
                // citizenContract.addGametEthSpendWin(_sender,_value);
                DAAContract.payOut(_sender,0,_win_value,_value);
                totalPayout = totalPayout.add(_win_value);
                addToHistory(_sender,_prediction,_method,_winnumber,true,_value,_win_value,0);
            } else {
                citizenContract.addGameEthSpendLose(_sender,_value);
                addToHistory(_sender,_prediction,_method,_winnumber,false,_value,0,0);
            }
            
        }else{
            require(_prediction>3&&_prediction<99);
            citizenSpendEth[_sender] = _value.add(citizenSpendEth[_sender]);
            DAAContract.pushDividend.value(_value)();
            DAAContract.pushGameRefIncome(_sender,1,_valueForRef);
            if (_winnumber>_prediction){
                _win_value = _value.mul(MULTIPLIES).div(10).div(99-_prediction);
                // citizenContract.addGametEthSpendWin(_sender,_value);
                DAAContract.payOut(_sender,0,_win_value,_value);
                totalPayout = totalPayout.add(_win_value);
                addToHistory(_sender,_prediction,_method,_winnumber,true,_value,_win_value,0);
            } else {
                citizenContract.addGameEthSpendLose(_sender,_value);
                addToHistory(_sender,_prediction,_method,_winnumber,false,_value,0,0);
            }
        }
        if (histoyLen%50==0){
            sortMostSpend(_sender);
        }
    } 
    
    function betByToken(bool _method,uint8 _prediction, uint256 _value) public registered() {
        address _sender = msg.sender;
        DAAContract.citizenUseDeposit(_sender, _value);
        require(_value>=MIN_TOKEN&&_value<=MAX_TOKEN);
        
        // _method = True is roll under
        // _method = False is roll over
        uint64 _seed = getSeed();
        uint8 _winnumber = uint8(Helper.getRandom(_seed, 100));
        uint256 _valueForRef = _value*15/1000;
        uint256 _win_value;
        if(_method){
            require(_prediction>0&&_prediction<96);
            citizenSpendToken[_sender] = _value.add(citizenSpendToken[_sender]);
            citizenContract.addGameTokenSpend(_sender,_value);
            DAAContract.pushGameRefIncome(_sender,0,_valueForRef);
            if (_winnumber<_prediction){
                _win_value = _value.mul(MULTIPLIES).div(10).div(_prediction);
                DAAContract.payOut(_sender,1,_win_value,_value);
                addToHistory(_sender,_prediction,_method,_winnumber,true,_value,_win_value,1);
            } else {
                addToHistory(_sender,_prediction,_method,_winnumber,false,_value,0,1);
            }
            
        }else{
            require(_prediction>3&&_prediction<99);
            citizenSpendToken[_sender] = _value.add(citizenSpendToken[_sender]);
            citizenContract.addGameTokenSpend(_sender,_value);
            DAAContract.pushGameRefIncome(_sender,0,_valueForRef);
            if (_winnumber>_prediction){
                _win_value = _value.mul(MULTIPLIES).div(10).div(99-_prediction);
                DAAContract.payOut(_sender,1,_win_value,_value);
                addToHistory(_sender,_prediction,_method,_winnumber,true,_value,_win_value,1);
            } else {
                addToHistory(_sender,_prediction,_method,_winnumber,false,_value,0,1);
            }
        }
    }
    
    function updateHIGHROLLER(uint256 _value) onlyAdmin() public{
        HIGHROLLER = _value;
    }
    
    function updateHIGHROLLERTOKEN(uint256 _value) onlyAdmin() public{
        HIGHROLLERTOKEN = _value;
    }
    
    function updateMinEth(uint256 _value) onlyAdmin() public{
        MIN = _value;
    }
    
    function updateMaxEth(uint256 _value) onlyAdmin() public {
        MAX = _value;
    }
    
    function updateMinToken(uint256 _value) onlyAdmin() public{
        MIN_TOKEN = _value;
    }
    
    function updateMaxToken(uint256 _value) onlyAdmin() public{
        MAX_TOKEN = _value;
    }
    
    function getSeed()
        public
        view
        returns (uint64)
    {
        if (citizenSeed[msg.sender]==0){
            return uint64(keccak256(abi.encodePacked(block.timestamp,block.difficulty, msg.sender, privateKey)));
        }
        return uint64(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, citizenSeed[msg.sender])));
    }
    
    
}