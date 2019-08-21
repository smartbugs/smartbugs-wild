pragma solidity ^0.4.21;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}


interface IGameToken{                                             
    function mineToken(address _player, uint256 _etherAmount) external returns (uint _toPlayerToken);
    function balanceOf(address _owner) constant  external returns (uint256 _balance);
}

contract BaseGame {
    using SafeMath for uint256;
    
    string public officialGameUrl;  
    string public gameName = "GameSicBo";    
    uint public gameType = 3003;               

    mapping (address => uint256) public userEtherOf;
    
    function userRefund() public  returns(bool _result);
   
    address public currentBanker;    
    uint public bankerBeginTime;     
    uint public bankerEndTime;       
    IGameToken public GameToken;  
    
    function canSetBanker() view public returns (bool _result);
    function setBanker(address _banker, uint256 _beginTime, uint256 _endTime) public returns(bool _result);
}

contract Base is  BaseGame{
    uint public createTime = now;
    address public owner;
    bool public globalLocked = false;      
    uint public currentEventId = 1;            

    //function Base() public {
    //}

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address _newOwner)  public  onlyOwner {
        owner = _newOwner;
    }

    function lock() internal {            
        require(!globalLocked);
        globalLocked = true;
    }

    function unLock() internal {
        require(globalLocked);
        globalLocked = false;
    }

    function setLock()  public onlyOwner{
        globalLocked = false;
    }


    function getEventId() internal returns(uint _result) {  
        _result = currentEventId;
        currentEventId ++;
    }

    function setOfficialGameUrl(string _newOfficialGameUrl) public onlyOwner{
        officialGameUrl = _newOfficialGameUrl;
    }
}

contract GameSicBo is Base
{
    uint public maxPlayableGameId = 0;      
    uint public gameTime;              
    uint256 public gameMaxBetAmount;    
    uint256 public gameMinBetAmount;    
    uint256 public minBankerEther = gameMaxBetAmount * 20;

    function setMinBankerEther(uint256 _value) public onlyBanker {          
        require(_value >= gameMinBetAmount *  150);
        minBankerEther = _value;
    }

    uint public gameExpirationTime = 5 days;  
    string public constant gameRandon2 = 'ChinasNewGovernmentBracesforTrump';    
    bool public isStopPlay = false;
    uint public playNo = 1;      
    bool public isNeedLoan = true; 
    uint256 public currentDayRate10000 = 0;      
    address public currentLoanPerson;       
    uint256 public currentLoanAmount;       
    uint public currentLoanDayTime;       

    function GameSicBo(string _gameName,uint  _gameTime, uint256 _gameMinBetAmount, uint256 _gameMaxBetAmount,address _auction,address _gameToken)  public {
        require(_gameTime > 0);
        require(_gameMinBetAmount > 0);
        require(_gameMaxBetAmount > 0);
        require(_gameMaxBetAmount >= _gameMinBetAmount);
        require(_gameToken != 0x0);

        gameMinBetAmount = _gameMinBetAmount;
        gameMaxBetAmount = _gameMaxBetAmount;
        
        minBankerEther = gameMaxBetAmount * 20;
        gameTime = _gameTime;
        GameToken = IGameToken(_gameToken);

        gameName = _gameName;
        owner = msg.sender;
        auction = _auction;
        officialGameUrl='http://sicbo.donquixote.games/';
    }

    function tokenOf(address _user) view public returns(uint _result){
       _result = GameToken.balanceOf(_user);
    }

    address public auction;     
    function setAuction(address _newAuction) public onlyOwner{
        auction = _newAuction;
    }

    modifier onlyAuction {              
        require(msg.sender == auction);
        _;
    }

    modifier onlyBanker {              
        require(msg.sender == currentBanker);
        require(bankerBeginTime <= now);
        require(now < bankerEndTime);
        _;
    }

    modifier playable(uint betAmount) {
        require (!isStopPlay); 
        require(msg.sender != currentBanker);               
        require(betAmount >= gameMinBetAmount);        
        _;
    }

   function canSetBanker() public view returns (bool _result){
        _result =  bankerEndTime <= now;
    }

    event OnSetNewBanker(address _caller, address _banker, uint _beginTime, uint _endTime, uint _code,uint _eventId,uint _eventTime);
    function setBanker(address _banker, uint _beginTime, uint _endTime) public onlyAuction returns(bool _result)        
    {
        _result = false;
        require(_banker != 0x0);
             
        if(now < bankerEndTime){
            emit OnSetNewBanker(msg.sender, _banker,  _beginTime,  _endTime, 1 ,getEventId(),now);
            return;
        }
       
        if(_beginTime > now){
            emit OnSetNewBanker(msg.sender, _banker,  _beginTime,  _endTime, 3 ,getEventId(),now);
            return;
        }
     
        if(_endTime <= now){
            emit OnSetNewBanker(msg.sender, _banker,  _beginTime,  _endTime, 4 ,getEventId(),now);
            return;
        }
       
        uint256 toLoan = calLoanAmount();
        uint256 _bankerAmount = userEtherOf[currentBanker];
        if(_bankerAmount < toLoan){
             toLoan = _bankerAmount;
        }
        userEtherOf[currentLoanPerson] = userEtherOf[currentLoanPerson].add(toLoan);
        userEtherOf[currentBanker] = userEtherOf[currentBanker].sub(toLoan);
        currentLoanPerson = 0x0;
        currentDayRate10000 = 0;
        currentLoanAmount = 0;
        currentLoanDayTime = now;
        emit OnPayLoan(currentBanker,now,toLoan);

        currentBanker = _banker;
        bankerBeginTime = _beginTime;
        bankerEndTime = _endTime;
        isStopPlay = false;
        
        emit OnSetNewBanker(msg.sender, _banker,  _beginTime,  _endTime, 0, getEventId(),now);
        _result = true;
    }
   
    struct gameInfo             
    {
        address Banker;
        bytes32 EncryptedText;  
        bytes32 GameRandon;        
        uint GameResult ; 
        mapping(uint8 => uint) TotalBetInfoOf;
    }

    function hasBetting(uint _gameId) public view returns (bool _result){       
        gameInfo storage gi = gameInfoOf[_gameId];
        require(gi.Banker != 0x0);
        _result = false;
        for(uint8 i = 1; i <= 50; i++){
            if (gi.TotalBetInfoOf[i] > 0){
                _result = true;
                return;
            }
        }
    }
    struct betInfo             
    {
        uint256 GameId;
        address Player;
        uint256 BetAmount;      
        uint8 Odds;            
        uint8 BetNum;           
        bool IsReturnAward;     
        bool IsWin ;         
        uint BetTime;
    }

    mapping (uint => betInfo) public playerBetInfoOf;             
    mapping (uint => gameInfo) public gameInfoOf;               

    function getCurrentGameId()  public  view returns (uint _result){       
        _result = now.sub(createTime).div(gameTime);
        if(now.sub(createTime) % gameTime >0 ){
           _result = _result.add(1);
        }
    }

    function getCountCanAdd() view public returns (uint _result){         
        _result = 0;
        uint currentGameId = getCurrentGameId();
        if(currentGameId < maxPlayableGameId){
          _result = (bankerEndTime.sub(gameTime.mul(maxPlayableGameId).add(createTime))).div(gameTime);
        }else{
          _result = bankerEndTime.sub(now).div(gameTime);
        }
    }

    function getGameBeginTime(uint _gameId) view public returns (uint _result){
        _result = 0;
        if(_gameId <= maxPlayableGameId && _gameId != 0){
          _result = _gameId.mul(gameTime).add(createTime).sub(gameTime);
        }
    }

    function getGameEndTime(uint _gameId) view public returns (uint _result){
        _result = 0;
        if(_gameId <= maxPlayableGameId  && _gameId != 0){
          _result = _gameId.mul(gameTime).add(createTime);
        }
    }

    function isGameExpiration(uint _gameId) view public returns(bool _result){        
        _result = false;
        if(_gameId.mul(gameTime).add(createTime).add(gameExpirationTime) < now && gameInfoOf[_gameId].GameResult ==0 ){
          _result = true;
        }
    }

    function userRefund() public  returns(bool _result) {
        return _userRefund(msg.sender);
    }
    
    function _userRefund(address _to) internal returns(bool _result) {
        require (_to != 0x0);
        lock();
        uint256 amount = userEtherOf[msg.sender];
        if(amount > 0){ 
            if(msg.sender == currentBanker){
                if(currentLoanPerson == 0x0 || checkPayLoan() ){   
                    if(amount >= minBankerEther){    
                      uint256 toBanker = amount - minBankerEther;
                      _to.transfer(toBanker);
                      userEtherOf[msg.sender] = minBankerEther;
                    }
                }
            }else{
                _to.transfer(amount);
                userEtherOf[msg.sender] = 0;    
            }
            _result = true;
        }else{
            _result = false;
        }
        unLock();
    }

    function setIsNeedLoan(bool _isNeedLoan) public onlyBanker returns(bool _result) {  
        _result = false;
        if(!isNeedLoan){
            
            require(currentLoanAmount == 0);
        }
        isNeedLoan = _isNeedLoan;
        _result = true;
    }

    event OnBidLoan(bool indexed _success, address indexed _user, uint256 indexed _dayRate10000,  uint256 _etherAmount);
    event OnPayLoan(address _sender,uint _eventTime,uint256 _toLoan);

    function bidLoan(uint256 _dayRate10000) public payable returns(bool _result) {      
        _result = false;
        require(isNeedLoan); 
        require(!isStopPlay);
        require(msg.sender != currentBanker);
        
        require(_dayRate10000 < 1000);           
        depositEther();
        
        if(checkPayLoan()){
           
            emit OnBidLoan(false, msg.sender, _dayRate10000,  0);
            return;
        }
        
        uint256 toLoan = calLoanAmount();
        uint256 toGame = 0;
        if (userEtherOf[currentBanker] < minBankerEther){      
            toGame = minBankerEther.sub(userEtherOf[currentBanker]);
        }

        if(toLoan > 0 && toGame == 0 && currentLoanPerson != 0x0){                    
            require(_dayRate10000 < currentDayRate10000);
        }

        require(toLoan + toGame > 0);                                                
        require(userEtherOf[msg.sender] >= toLoan + toGame);

        userEtherOf[msg.sender] = userEtherOf[msg.sender].sub(toLoan + toGame);
        userEtherOf[currentLoanPerson] = userEtherOf[currentLoanPerson].add(toLoan);
        userEtherOf[currentBanker] = userEtherOf[currentBanker].add(toGame);

        currentLoanPerson = msg.sender;
        currentDayRate10000 = _dayRate10000;
        currentLoanAmount = toLoan + toGame;
        currentLoanDayTime = now;

        emit OnBidLoan(false, msg.sender, _dayRate10000,  currentLoanAmount);

        _result = true;
        return;
    }

    function getCanLoanAmount() public view returns(uint256  _result){                 
        uint256 toLoan = calLoanAmount();

        uint256 toGame = 0;
        if (userEtherOf[currentBanker] <= minBankerEther){
            toGame = minBankerEther - userEtherOf[currentBanker];
            _result =  toLoan + toGame;
            return;
        }
        else if (userEtherOf[currentBanker] > minBankerEther){
            uint256 c = userEtherOf[currentBanker] - minBankerEther;
            if(toLoan > c){
                _result =  toLoan - c;
                return;
            }
            else{
                _result =  0;
                return;
            }
        }
    }

    function calLoanAmount() public view returns (uint256 _result){
      _result = 0;
      if(currentLoanPerson != 0x0 && currentLoanAmount > 0){
          _result = currentLoanAmount;
          uint d = (now - currentLoanDayTime) / (1 days);
          for(uint i = 0; i < d; i++){
              _result = _result * (10000 + currentDayRate10000) / 10000;
          }
        }
    }

    function checkPayLoan() public returns (bool _result) {                        
        _result = false;
        uint256 toLoan = calLoanAmount();
        if(toLoan > 0){      
            bool isStop =  isStopPlay && now  > getGameEndTime(maxPlayableGameId).add(1 hours);                      
            if (isStop || userEtherOf[currentBanker] >= minBankerEther.add(toLoan)){            
                userEtherOf[currentLoanPerson] = userEtherOf[currentLoanPerson].add(toLoan);
                userEtherOf[currentBanker] = userEtherOf[currentBanker].sub(toLoan);
                currentLoanPerson = 0x0;
                currentDayRate10000 = 0;
                currentLoanAmount = 0;
                currentLoanDayTime = now;
                _result = true;
                emit OnPayLoan(msg.sender,now,toLoan);
                return;
            }
        }
    }

    event OnNewGame(uint indexed _gameId, address indexed _bankerAddress, bytes32 indexed _gameEncryptedTexts, uint _gameBeginTime, uint _gameEndTime, uint _eventTime, uint _eventId);
    function newGame(bytes32[] _gameEncryptedTexts) public onlyBanker payable returns(bool _result)       
    {
        if (msg.value > 0){
            userEtherOf[msg.sender] = userEtherOf[msg.sender].add(msg.value);       
        }

        _result = _newGame( _gameEncryptedTexts);
    }

    function setStopPlay(bool _isStopPlay) public onlyBanker
    {   
        isStopPlay = _isStopPlay;
    }

    function _newGame(bytes32[] _gameEncryptedTexts)   private  returns(bool _result)       
    {   
        _result = false;

        uint countCanAdd = getCountCanAdd();   
        require(countCanAdd > 0); 
        if(countCanAdd > _gameEncryptedTexts.length){
          countCanAdd = _gameEncryptedTexts.length;
        }
        uint currentGameId = getCurrentGameId();
        if(maxPlayableGameId < currentGameId){
          maxPlayableGameId = currentGameId.sub(1);
        }

        for(uint i=0;i<countCanAdd;i++){
            if(_gameEncryptedTexts[i] == 0x0){
                continue;
            }
            maxPlayableGameId++;
            gameInfo memory info = gameInfo({
                Banker :currentBanker,
                EncryptedText:  _gameEncryptedTexts[i],
                GameRandon:  0x0,       
                GameResult:0  
            });
            gameInfoOf[maxPlayableGameId] = info;
            emit OnNewGame(maxPlayableGameId, msg.sender, _gameEncryptedTexts[i], getGameBeginTime(maxPlayableGameId), getGameEndTime(maxPlayableGameId), now, getEventId());
        }
        _result = true;
    }

    event OnPlay(address indexed _player,uint indexed _gameId, uint indexed _playNo, uint8 _betNum, uint256 _betAmount,uint _giftToken, uint _eventId,uint _eventTime);

    function depositEther() public payable
    {  
        if (msg.value > 0){
            userEtherOf[msg.sender] = userEtherOf[msg.sender].add(msg.value);
        }
    }

    function playBigOrSmall(uint8 _betNum, uint256 _betAmount) public payable playable(_betAmount) returns(bool _result){       
        lock();
        depositEther();
        require(_betNum ==1 || _betNum == 2); 
        if (_betAmount > gameMaxBetAmount){             
            _betAmount = gameMaxBetAmount;
        }
        _result = _play(_betNum, _betAmount,false);
        unLock();
    }

    function playAnyTriples(uint256 _betAmount) public payable  playable(_betAmount)  returns(bool _result){       
        lock();
        depositEther();
        if (_betAmount > gameMaxBetAmount){             
            _betAmount = gameMaxBetAmount;
        }
        _result = _play(3, _betAmount,false);
        unLock();
    }

    function playSpecificTriples(uint8 _betNum, uint256 _betAmount) public payable playable(_betAmount)  returns(bool _result){       
        lock();
        depositEther();
        require(_betNum >= 1 && _betNum <=6); 
        if (_betAmount > gameMaxBetAmount){             
            _betAmount = gameMaxBetAmount;
        }
        _result = _play(_betNum + 3, _betAmount,false);
        unLock();
    }

    function playSpecificDoubles(uint8 _betNum, uint256 _betAmount) public payable playable(_betAmount)  returns(bool _result){       
        lock();
        depositEther();
        require(_betNum >= 1 && _betNum <=6);
        if (_betAmount > gameMaxBetAmount){             
            _betAmount = gameMaxBetAmount;
        }
        _result = _play(_betNum + 9 , _betAmount,false);
        unLock();
    }

    function playThreeDiceTotal(uint8 _betNum,uint256 _betAmount) public payable  playable(_betAmount)  returns(bool _result){      
        lock();
        depositEther();
        require(_betNum >= 4 && _betNum <=17); 
        if (_betAmount > gameMaxBetAmount){             
            _betAmount = gameMaxBetAmount;
        }
        _result = _play(_betNum + 12, _betAmount,false);
        unLock();
    }

    function playDiceCombinations(uint8 _smallNum,uint8 _bigNum,uint256 _betAmount) public payable playable(_betAmount)  returns(bool _result){       
        lock();
        depositEther();
        require(_smallNum < _bigNum);
        require(_smallNum >= 1 && _smallNum <=5); 
        require(_bigNum >= 2 && _bigNum <=6);
        if (_betAmount > gameMaxBetAmount){             
            _betAmount = gameMaxBetAmount;
        }
        uint8 _betNum = 0 ;
        if(_smallNum == 1){
            _betNum = 28+_bigNum;
        }else if(_smallNum ==2){
             _betNum = 32+_bigNum;
        }else if(_smallNum == 3){
             _betNum = 35+_bigNum;
        }else if(_smallNum == 4){
             _betNum = 37+_bigNum;
        }else if(_smallNum == 5){
            _betNum = 44;
        }
        _result = _play(_betNum,_betAmount,false);
        unLock();
    }

    function playSingleDiceBet(uint8 _betNum,uint256 _betAmount) public payable playable(_betAmount)  returns(bool _result){       
        lock();
        depositEther();
        require(_betNum >= 1 && _betNum <=6);
        if (_betAmount > gameMaxBetAmount){            
            _betAmount = gameMaxBetAmount;
        }
        _result = _play(_betNum + 44,_betAmount,false);
        unLock();
    }

    function _calOdds(uint8 _betNum) internal pure returns(uint8 _odds){
        if(_betNum > 0 && _betNum <= 2){
            return 1;
        }else if(_betNum == 3){
            return 24;
        }else if(_betNum <= 9){
            return 150;
        }else if(_betNum <= 15){
            return 8;
        }else if(_betNum <= 29){
            if(_betNum == 16 || _betNum == 29){ 
                return 50;
            }else if(_betNum == 17 || _betNum == 28){ 
                return 18;
            }else if(_betNum == 18 || _betNum == 27){
               return 14;
            }else if(_betNum == 19 || _betNum == 26){  
                return 12;
            }else if(_betNum == 20 || _betNum == 25){ 
                return 8;
            }else{
                return 6;
            }
        }else if(_betNum <= 44){
            return 5;
        }else if(_betNum <= 50){
            return 3;
        }
        return 0;
    }

    function playBatch(uint8[] _betNums,uint256[] _betAmounts) public payable returns(bool _result)
    {   
        lock();
        _result = false;
      
        require(msg.sender != currentBanker);               
        
        uint currentGameId = getCurrentGameId();
        
        gameInfo  storage gi = gameInfoOf[currentGameId];
        require (gi.GameResult == 0 && gi.Banker == currentBanker);
        depositEther();
        require(_betNums.length == _betAmounts.length);
        require (_betNums.length <= 10);
        _result = true ;
        for(uint i = 0; i < _betNums.length && _result ; i++ ){
            uint8 _betNum = _betNums[i];
            uint256 _betAmount = _betAmounts[i];
            if(_betAmount < gameMinBetAmount || _betNum > 50){
               
                continue ;
            }
            if (_betAmount > gameMaxBetAmount){             
                _betAmount = gameMaxBetAmount;
            }
            _result =_play(_betNum,_betAmount,true);
        }
        unLock();
    }

    function _play(uint8 _betNum,  uint256 _betAmount,bool isBatch) private  returns(bool _result)
    {            
        _result = false;
        uint8 _odds = _calOdds(_betNum);
        uint bankerAmount = _betAmount.mul(_odds);   
        if(!isBatch){
            require(userEtherOf[msg.sender] >= _betAmount);
            require(userEtherOf[currentBanker] >= bankerAmount); 
        }else{
            if(userEtherOf[msg.sender] < _betAmount  || userEtherOf[currentBanker] < bankerAmount){
                return false;
            }
        }
        uint currentGameId = getCurrentGameId();
        gameInfo  storage gi = gameInfoOf[currentGameId];
        require (gi.GameResult == 0 && gi.Banker == currentBanker);

        betInfo memory bi = betInfo({
            GameId : currentGameId ,
            Player :  msg.sender,
            BetNum : _betNum,
            BetAmount : _betAmount,
            Odds : _odds,
            IsReturnAward: false,
            IsWin :  false,
            BetTime : now
        });
        playerBetInfoOf[playNo] = bi;
        userEtherOf[msg.sender] = userEtherOf[msg.sender].sub(_betAmount);                  
        userEtherOf[currentBanker] = userEtherOf[currentBanker].sub(bankerAmount);     
        userEtherOf[this] = userEtherOf[this].add(_betAmount.add(bankerAmount));

        gi.TotalBetInfoOf[_betNum] = gi.TotalBetInfoOf[_betNum].add(_betAmount.add(bankerAmount));

        uint _giftToken = GameToken.mineToken(msg.sender,_betAmount);

        emit OnPlay(msg.sender, currentGameId, playNo , _betNum,  _betAmount,_giftToken,getEventId(), now);

        playNo++;
        _result = true;
    }
    
    function _getPlayDiceCombinationsIndex(uint8 _smallNum,uint8 _bigNum) internal pure returns(uint8 index)
    {
        if(_smallNum == 1){
            return 28+_bigNum;
        }else if(_smallNum ==2){
             return 32+_bigNum;
        }else if(_smallNum == 3){
             return 35+_bigNum;
        }else if(_smallNum == 4){
             return 37+_bigNum;
        }else if(_smallNum == 5){
            return 44;
        }
    }

    function uintToString(uint v) private pure returns (string)
    {
        uint maxlength = 3;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i); 
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - j - 1]; 
        }
        string memory str = string(s); 
        return str; 
    }

    event OnOpenGameResult(uint indexed _gameId,  address indexed _banker,bytes32 indexed _randon1,uint _gameResult, uint _eventId,uint _eventTime);

    function openGameResult(uint _gameId,uint8 _minGameResult,uint8 _midGameResult,uint8 _maxGameResult, bytes32 _randon1) public  returns(bool _result)
    {
        _result =  _openGameResult(_gameId, _minGameResult,_midGameResult,_maxGameResult,_randon1);
    }

    function _openGameResult(uint _gameId,uint8 _minGameResult,uint8 _midGameResult, uint8 _maxGameResult, bytes32 _randon1) private  returns(bool _result)
    {            
        _result = false;
        require(_minGameResult <= _midGameResult);
        require(_midGameResult <= _maxGameResult);
        require (_minGameResult >= 1 && _maxGameResult <= 6);
        uint _gameEndTime = getGameEndTime(_gameId);
        require (_gameEndTime < now);  
        require (_gameEndTime + gameExpirationTime > now);  

        gameInfo  storage gi = gameInfoOf[_gameId];
        require(gi.Banker == msg.sender);
        require(gi.GameResult == 0);
        uint _gameResult = uint(_minGameResult)*100 + _midGameResult*10 + _maxGameResult;

      require (keccak256(uintToString(_gameResult) ,gameRandon2, _randon1) ==  gi.EncryptedText);

        gi.GameResult = _gameResult;
        gi.GameRandon = _randon1;

        emit OnOpenGameResult(_gameId, msg.sender,_randon1,  _gameResult, getEventId(),now);
        lock();
        _bankerCal(gi,_minGameResult,_midGameResult,_maxGameResult);
        unLock();
        _result = true;
    }

    function _bankerCal(gameInfo storage _gi,uint8 _minGameResult,uint8 _midGameResult, uint8 _maxGameResult) internal
    {
        uint _bankerAmount = 0;

        mapping(uint8 => uint) _totalBetInfoOf = _gi.TotalBetInfoOf;

        uint8 _threeDiceTotal = _minGameResult + _midGameResult + _maxGameResult;  
        bool _isAnyTriple = (_minGameResult == _maxGameResult);
        uint8 _doubleTriple = (_minGameResult == _midGameResult) ? _minGameResult : ((_midGameResult == _maxGameResult)? _maxGameResult: 0);

        _bankerAmount = _bankerAmount.add(_sumAmount(_gi,16,29,_threeDiceTotal + 12));
        _bankerAmount = _bankerAmount.add(_sumAmount(_gi,10,15,_doubleTriple +9));

        if(_isAnyTriple){ 
          
            _bankerAmount = _bankerAmount.add(_totalBetInfoOf[1]);
            _bankerAmount = _bankerAmount.add(_totalBetInfoOf[2]);
            _bankerAmount = _bankerAmount.add(_sumAmount(_gi,4,9,3+_minGameResult));
            _bankerAmount = _bankerAmount.add(_sumAmount(_gi,30,44,0));  
            _bankerAmount = _bankerAmount.add(_sumAmount(_gi,45,50,_minGameResult + 44));  
        }else{
            
            _bankerAmount = _bankerAmount.add(_sumAmount(_gi,3,9,0));
            if(_threeDiceTotal >= 11){ 
                _bankerAmount = _bankerAmount.add(_totalBetInfoOf[1]);
            }else{
                _bankerAmount = _bankerAmount.add(_totalBetInfoOf[2]);
            }
            _bankerAmount = _bankerAmount.add(_bankerCalOther(_gi,_minGameResult,_midGameResult,_maxGameResult,_doubleTriple));
        }
         
        userEtherOf[_gi.Banker] =userEtherOf[_gi.Banker].add(_bankerAmount);
        userEtherOf[this] =userEtherOf[this].sub(_bankerAmount);
    }

    function _bankerCalOther(gameInfo storage _gi,uint8 _minGameResult,uint8 _midGameResult, uint8 _maxGameResult,uint8 _doubleTriple) private view returns(uint _bankerAmount) {
        
        mapping(uint8 => uint) _totalBetInfoOf = _gi.TotalBetInfoOf;
        if(_doubleTriple != 0){
            
            if(_maxGameResult == _doubleTriple){
               
                uint8 _index1 = _getPlayDiceCombinationsIndex(_minGameResult,_midGameResult);
                uint8 _index2 = _minGameResult + 44; 
            }else if(_minGameResult == _doubleTriple){
                
                _index1 =_getPlayDiceCombinationsIndex(_midGameResult,_maxGameResult);
                _index2 = _maxGameResult + 44; 
            }
            _bankerAmount = _bankerAmount.add(_sumAmount(_gi,30,44,_index1));  

            uint8 _index3= _midGameResult + 44; 
            for(uint8 i=45;i<=50;i++){
                if(i == _index3){
                    
                    _betAmount = _totalBetInfoOf[i];
                    _bankerAmount = _bankerAmount.add(_betAmount.div(4));
                }else if(i == _index2){
                    
                    _betAmount = _totalBetInfoOf[i];
                    _bankerAmount = _bankerAmount.add(_betAmount.div(2));
                }else{
                    
                    _bankerAmount = _bankerAmount.add(_totalBetInfoOf[i]);
                }
            }
        }else{
              
            _index1 = _getPlayDiceCombinationsIndex(_minGameResult,_midGameResult);
            _index2 = _getPlayDiceCombinationsIndex(_minGameResult,_maxGameResult);
            _index3 = _getPlayDiceCombinationsIndex(_midGameResult,_maxGameResult);

            for(i=30;i<=44;i++){
                if(i != _index1 && i != _index2 && i != _index3){
                    _bankerAmount = _bankerAmount.add(_totalBetInfoOf[i]);
                }
            }
           
            _index1 = _minGameResult+44;
            _index2 = _midGameResult+44;
            _index3 = _maxGameResult+44;
            uint _betAmount = 0 ;
            for(i=45;i<=50;i++){
                if(i != _index1 && i != _index2 && i != _index3){
                   
                     _bankerAmount = _bankerAmount.add(_totalBetInfoOf[i]);
                }else{
                    
                    _betAmount = _totalBetInfoOf[i];
                    _bankerAmount = _bankerAmount.add(_betAmount.div(2)); 
                }
            }

        }
    }

    function _sumAmount(gameInfo storage _gi,uint8 _startIndex,uint8 _endIndex,uint8 _excludeIndex) internal view returns(uint _totalAmount)
    {   
        _totalAmount = 0 ;
        for(uint8 i=_startIndex;i<=_endIndex;i++){
            if(i != _excludeIndex){
                _totalAmount = _totalAmount.add(_gi.TotalBetInfoOf[i]);
            }
        }
        return _totalAmount;
    }

    event OnGetAward(uint indexed _playNo,uint indexed _gameId, address indexed _player, uint _betNum, uint _betAmount,uint _awardAmount, uint _gameResult,uint _eventTime, uint _eventId);
    
    function getAwards(uint[] playNos) public
    {   
        lock();

        for(uint i=0;i<playNos.length;i++){
            if(playNos[i] > playNo){
                continue; 
            }
            betInfo storage p = playerBetInfoOf[playNos[i]];
            if(p.IsReturnAward){
                continue;
            }

            gameInfo storage _gi = gameInfoOf[p.GameId];
            uint _gameEndTime = getGameEndTime(p.GameId);
            uint _awardAmount = 0; 
            if(isGameExpiration(p.GameId)){
                uint AllAmount = p.BetAmount.mul(1 + p.Odds); 
                userEtherOf[this] =userEtherOf[this].sub(AllAmount);
                p.IsReturnAward = true;
                if(now > _gameEndTime+ 30 days){
                    userEtherOf[_gi.Banker] =userEtherOf[_gi.Banker].add(AllAmount);                   
                }else{
                    p.IsWin = true ; 
                    userEtherOf[p.Player] =userEtherOf[p.Player].add(AllAmount);
                    _awardAmount = AllAmount;                
                }                   
            }else if(_gi.GameResult != 0){ 
                p.IsReturnAward = true;
                uint8 _realOdd = _playRealOdds(p.BetNum,p.Odds,_gi.GameResult);
                if(_realOdd > 0){ 
                    uint256 winAmount = p.BetAmount.mul(1 + _realOdd); 
                    p.Odds = _realOdd;
                    userEtherOf[this] = userEtherOf[this].sub(winAmount);
                    if(now > _gameEndTime + 30 days){
                        
                        userEtherOf[_gi.Banker] = userEtherOf[_gi.Banker].add(winAmount);
                    }else{
                        p.IsWin = true ;
                        userEtherOf[p.Player] =  userEtherOf[p.Player].add(winAmount);
                        _awardAmount = winAmount;
                    }
                }
               
            }
            emit OnGetAward(playNos[i], p.GameId, p.Player,  p.BetNum, p.BetAmount, _awardAmount, _gi.GameResult, now, getEventId());
        }
        unLock();
    }

    function _playRealOdds(uint8 _betNum,uint8 _odds,uint _gameResult) private  pure returns(uint8 _realOdds)
    {
        uint8 _minGameResult = uint8(_gameResult/100);
        uint8 _midGameResult = uint8(_gameResult/10%10);
        uint8 _maxGameResult = uint8(_gameResult%10);

        _realOdds = 0;
        uint8 _smallNum = 0;
        uint8 _bigNum = 0;
        if(_betNum <=2){
            
            if(_minGameResult == _maxGameResult){
                return 0;
            }
            uint8 _threeDiceTotal = _minGameResult + _midGameResult +_maxGameResult ; 
            uint _bigOrSmall = _threeDiceTotal >= 11 ? 2 : 1 ; 
            _smallNum = _betNum;
            if(_bigOrSmall == _smallNum){
                _realOdds = _odds;
            }
        }else if(_betNum == 3){
            if(_minGameResult == _maxGameResult){
                _realOdds = _odds;
            }
        }else if(_betNum <= 9){
            uint _specificTriple  = (_minGameResult == _maxGameResult) ? _minGameResult : 0 ; 
            _smallNum = _betNum - 3 ;
            if( _specificTriple == _smallNum){
                _realOdds = _odds;
            }
        }else if(_betNum <= 15){
            uint _doubleTriple = (_minGameResult == _midGameResult) ? _minGameResult : ((_midGameResult == _maxGameResult)? _maxGameResult: 0);
            _smallNum = _betNum - 9 ;
            if(_doubleTriple == _smallNum){
                _realOdds = _odds;
            }
        }else if(_betNum <= 29){
            _threeDiceTotal = _minGameResult + _midGameResult + _maxGameResult ;  
            _smallNum = _betNum - 12 ;
            if(_threeDiceTotal == _smallNum){
                _realOdds = _odds;
            }
        }else  if(_betNum <= 44){
            
            if(_betNum <= 34){
                _smallNum = 1;
                _bigNum = _betNum - 28;
            }else if(_betNum <= 38){
                _smallNum = 2;
                _bigNum = _betNum - 32;
            }else if(_betNum <=41){
                 _smallNum = 3;
                _bigNum = _betNum - 35;
            }else if(_betNum <=43){
                 _smallNum = 4;
                _bigNum = _betNum - 37;
            }else{
                _smallNum = 5;
                _bigNum = 6;
            }
            if(_smallNum == _minGameResult || _smallNum == _midGameResult){
                if(_bigNum == _midGameResult || _bigNum == _maxGameResult){
                    _realOdds = _odds;
                }
            }
        }else if(_betNum <= 50){
            
            _smallNum = _betNum - 44;
            if(_smallNum == _minGameResult){
                _realOdds++;
            }
            if(_smallNum == _midGameResult){
                _realOdds++;
            }
            if(_smallNum == _maxGameResult){
                _realOdds++;
            }
        }
        return _realOdds;
    }

    function () public payable {       
        if(msg.value > 0){              
            userEtherOf[msg.sender] = userEtherOf[msg.sender].add(msg.value);   
        }
    }
}