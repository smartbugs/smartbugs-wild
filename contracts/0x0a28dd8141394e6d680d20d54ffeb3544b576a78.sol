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


contract BaseGame {
    using SafeMath for uint256;
    
    string public officialGameUrl;  
    string public gameName = "SelectOne";    
    uint public gameType = 3002;               

    mapping (address => uint256) public userEtherOf;
    
    function userRefund() public  returns(bool _result);
}

contract Base is  BaseGame{
    uint public createTime = now;
    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address _newOwner)  public  onlyOwner {
        owner = _newOwner;
    }

    bool public globalLocked = false;     

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


    uint public currentEventId = 1;

    function getEventId() internal returns(uint _result) { 
        _result = currentEventId;
        currentEventId ++;
    }

    function setOfficialGameUrl(string _newOfficialGameUrl) public onlyOwner{
        officialGameUrl = _newOfficialGameUrl;
    }
}



interface IDividendToken{                           
    function profitOrgPay() payable external ;    
}

interface IGameToken{                                             
    function mineToken(address _player, uint256 _etherAmount) external returns (uint _toPlayerToken);
    function balanceOf(address _owner) constant  external returns (uint256 _balance);
}

contract Loan is Base{     

    address public shareholder;               

    bool public shareholderIsToken = false;
    bool public isStopPlay = false;
    uint public stopTime = 0;
    
    function setStopPlay(bool _isStopPlay) public onlyOwner
    {
        isStopPlay = _isStopPlay;
        stopTime = now;
    }

    function userRefund() public  returns(bool _result) {
        return _userRefund(msg.sender);
    }

    function _userRefund(address _to) internal  returns(bool _result){    
        require (_to != 0x0);
        _result = false;
        lock();
        uint256 amount = userEtherOf[msg.sender];
        if(amount > 0){
            if(msg.sender == shareholder){       
		checkPayShareholder();
            }
            else{       
                userEtherOf[msg.sender] = 0;
                _to.transfer(amount);
            }
            _result = true;
        }
        else{   
            _result = false;
        }
        unLock();
    }

    uint256 maxShareholderEther = 20 ether;                                

    function setMaxShareholderEther(uint256 _value) public onlyOwner {     
        require(_value >= minBankerEther * 2);
        require(_value <= minBankerEther * 20);
        maxShareholderEther = _value;
    }

    function autoCheckPayShareholder() internal {                             
        if (userEtherOf[shareholder] > maxShareholderEther){
            checkPayShareholder();
         }
    }

    function checkPayShareholder() internal {               
        uint256 amount = userEtherOf[shareholder];
        if(currentLoanPerson == 0x0 || checkPayLoan()){       
            uint256 me = minBankerEther;                    
            if(isStopPlay){
                me = 0;
            }
            if(amount >= me){     
                uint256 toShareHolder = amount - me;
                if(shareholderIsToken){     
                    IDividendToken token = IDividendToken(shareholder);
                    token.profitOrgPay.value(toShareHolder)();  
                }else{
                    shareholder.transfer(toShareHolder);
                }
                userEtherOf[shareholder] = me;
            }
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////

    uint256 public gameMaxBetAmount = 0.4 ether;        
    uint256 public gameMinBetAmount = 0.04 ether;      
    uint256 public minBankerEther = gameMaxBetAmount * 20;

    function setMinBankerEther(uint256 _value) public onlyOwner {          
        require(_value >= gameMinBetAmount *  18 * 1);
        require(_value <= gameMaxBetAmount *  18 * 10);
        minBankerEther = _value;
    }

    uint256 public currentDayRate10000 = 0;
    address public currentLoanPerson;       
    uint256 public currentLoanAmount;       
    uint public currentLoanDayTime;      

    function depositEther() public payable
    {  
        if (msg.value > 0){
            userEtherOf[msg.sender] = userEtherOf[msg.sender].add(msg.value);
        }
    }

    event OnBidLoan(bool indexed _success, address indexed _user, uint256 indexed _dayRate10000,  uint256 _etherAmount);
    event OnPayLoan(address _sender,uint _eventTime,uint256 _toLoan);

    function bidLoan(uint256 _dayRate10000) public payable returns(bool _result) {      
        _result = false;
        require(!isStopPlay);
        require(msg.sender != shareholder);

        require(_dayRate10000 < 1000);
        depositEther();
        
        if(checkPayLoan()){
            emit OnBidLoan(false, msg.sender, _dayRate10000,  0);
            return;
        }
        
        uint256 toLoan = calLoanAmount();
        uint256 toGame = 0;
        if (userEtherOf[shareholder] < minBankerEther){       
            toGame = minBankerEther.sub(userEtherOf[shareholder]);
        }

        if(toLoan > 0 && toGame == 0 && currentLoanPerson != 0x0){                   
            require(_dayRate10000 < currentDayRate10000);
        }

        require(toLoan + toGame > 0);
        require(userEtherOf[msg.sender] >= toLoan + toGame);

        userEtherOf[msg.sender] = userEtherOf[msg.sender].sub(toLoan + toGame);
        userEtherOf[currentLoanPerson] = userEtherOf[currentLoanPerson].add(toLoan);
        userEtherOf[shareholder] = userEtherOf[shareholder].add(toGame);

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
        if (userEtherOf[shareholder] <= minBankerEther){
            toGame = minBankerEther - userEtherOf[shareholder];
            _result =  toLoan + toGame;
            return;
        }
        else if (userEtherOf[shareholder] > minBankerEther){
            uint256 c = userEtherOf[shareholder] - minBankerEther;
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
          uint d = now.sub(currentLoanDayTime).div(1 days);
          for(uint i = 0; i < d; i++){
              _result = _result.mul(currentDayRate10000.add(10000)).div(10000);
          }
        }
    }


    function checkPayLoan() public returns (bool _result) {                        
        _result = false;
        uint256 toLoan = calLoanAmount();
        if(toLoan > 0){
            if(isStopPlay && now  > stopTime.add(1 days)){         
                if(toLoan > userEtherOf[shareholder]){
                    toLoan = userEtherOf[shareholder];
                    userEtherOf[currentLoanPerson] = userEtherOf[currentLoanPerson].add(toLoan);
                    userEtherOf[shareholder] = userEtherOf[shareholder].sub(toLoan);
                }
                else{
                    userEtherOf[currentLoanPerson] = userEtherOf[currentLoanPerson].add(toLoan);
                    userEtherOf[shareholder] = userEtherOf[shareholder].sub(toLoan);
                }

                currentLoanPerson = 0x0;
                currentDayRate10000 = 0;
                currentLoanAmount = 0;
                currentLoanDayTime = now;
                _result = true;
                emit OnPayLoan(msg.sender, now, toLoan);
                return;
            }                             
            if (userEtherOf[shareholder] >= minBankerEther.add(toLoan)){            
                userEtherOf[currentLoanPerson] = userEtherOf[currentLoanPerson].add(toLoan);
                userEtherOf[shareholder] = userEtherOf[shareholder].sub(toLoan);
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
}


contract SelectOne is Loan
{
  uint public playNo = 1;      
  uint public constant minNum = 1; 
  uint public constant maxNum = 22;         
  uint public constant winMultiplePer = 1800;

  struct betInfo              
  {
    address Player;         
    uint[] BetNums;
    uint AwardNum;
    uint256[] BetAmounts;      
    uint256 BlockNumber;    
    uint EventId;           
    bool IsReturnAward;     
  }
  mapping (uint => betInfo) public playerBetInfoOf;               
  IGameToken public GameToken;


  //function SelectOne(uint _maxNum, uint256 _gameMinBetAmount,uint256 _gameMaxBetAmount,uint _winMultiplePer,string _gameName,address _gameToken,bool _isToken) public{
  function SelectOne(uint256 _gameMinBetAmount,uint256 _gameMaxBetAmount, string _gameName,address _gameToken) public{
    //require(1 < _maxNum);
    //require(_maxNum < 100);
    require(_gameMinBetAmount > 0); 
    require(_gameMaxBetAmount >= _gameMinBetAmount);
    //require(_winMultiplePer < _maxNum.mul(100));
    owner = msg.sender;             
    //maxNum = _maxNum;
    gameMinBetAmount = _gameMinBetAmount;
    gameMaxBetAmount = _gameMaxBetAmount;
    minBankerEther = gameMaxBetAmount * 20;
    //winMultiplePer = _winMultiplePer;
    gameName = _gameName;   
    GameToken = IGameToken(_gameToken);
    shareholder = _gameToken;
    shareholderIsToken = true;
    officialGameUrl='http://select.donquixote.games/';
  }
  

  function tokenOf(address _user) view public returns(uint _result){
    _result = GameToken.balanceOf(_user);
  }

  event OnPlay(address indexed _player, uint[] _betNums,uint256[] _betAmounts,uint256 _giftToken, uint _blockNumber,uint _playNo, uint _eventTime, uint eventId);
  event OnGetAward(address indexed _player, uint256 _playNo, uint[] _betNums,uint _blockNumber,uint256[] _betAmounts ,uint _eventId,uint _awardNum,uint256 _awardAmount);


  function play(uint[] _betNums,uint256[] _betAmounts) public  payable returns(bool _result){       
    _result = false;
    require(_betNums.length > 0);
    require(_betNums.length == _betAmounts.length);
    depositEther();
    _result = _play(_betNums,_betAmounts);
  }

  function _play(uint[] _betNums, uint256[] _betAmounts) private  returns(bool _result){            
    _result = false;
    require (!isStopPlay);

    uint maxBetAmount = 0;
    uint totalBetAmount = 0;
    uint8[22] memory betNumOf;                      

    for(uint i=0;i < _betNums.length;i++){
      require(_betNums[i] > 0 && _betNums[i] <= maxNum );
      require(betNumOf[_betNums[i] - 1] == 0);       
	  betNumOf[_betNums[i] - 1] = 1;      
      if(_betAmounts[i] > gameMaxBetAmount){
        _betAmounts[i] = gameMaxBetAmount;
      }
      if(_betAmounts[i] > maxBetAmount){
        maxBetAmount = _betAmounts[i];
      }
      totalBetAmount = totalBetAmount.add(_betAmounts[i]);
    }

    uint256 needAmount = maxBetAmount.mul(winMultiplePer).div(100);
    if(totalBetAmount > needAmount){
      needAmount = 0;
    }else{
      needAmount = needAmount.sub(totalBetAmount);
    }
    require(userEtherOf[shareholder] >= needAmount);
    require(userEtherOf[msg.sender] >= totalBetAmount);
    lock();
    betInfo memory bi = betInfo({
      Player :  msg.sender,              
      BetNums : _betNums,                       
      AwardNum : 0,
      BetAmounts : _betAmounts,                     
      BlockNumber : block.number,         
      EventId : currentEventId,           
      IsReturnAward: false               
    });
    playerBetInfoOf[playNo] = bi;
    userEtherOf[msg.sender] = userEtherOf[msg.sender].sub(totalBetAmount);                  
    userEtherOf[shareholder] = userEtherOf[shareholder].sub(needAmount);             
    userEtherOf[this] = userEtherOf[this].add(needAmount).add(totalBetAmount);
    
    uint256 _giftToken = GameToken.mineToken(msg.sender,totalBetAmount);
    emit OnPlay(msg.sender,_betNums,_betAmounts,_giftToken,block.number,playNo,now, getEventId());      
    playNo++;       
    _result = true;
    unLock();
	  autoCheckPayShareholder();             
  }

  function getAward(uint[] _playNos) public returns(bool _result){
    require(_playNos.length > 0);
    _result = false;
    for(uint i = 0;i < _playNos.length;i++){
      _result = _getAward(_playNos[i]);
    }
  }

  function _getAward(uint _playNo) private  returns(bool _result){
    require(_playNo < playNo);       
    _result = false;        
    betInfo storage bi = playerBetInfoOf[_playNo];        
    require(block.number > bi.BlockNumber);
    require(!bi.IsReturnAward);      

    lock();
    uint awardNum = 0;
    uint256 awardAmount = 0;
    uint256 totalBetAmount = 0;
    uint256 maxBetAmount = 0;
    uint256 totalAmount = 0;
    for(uint i=0;i <bi.BetNums.length;i++){
      if(bi.BetAmounts[i] > maxBetAmount){
        maxBetAmount = bi.BetAmounts[i];
      }
      totalBetAmount = totalBetAmount.add(bi.BetAmounts[i]);
    }
    totalAmount = maxBetAmount.mul(winMultiplePer).div(100);
    if(totalBetAmount >= totalAmount){
      totalAmount = totalBetAmount;
    }
    if(bi.BlockNumber.add(256) >= block.number){
      uint256 randomNum = bi.EventId%1000000;
      bytes32 encrptyHash = keccak256(bi.Player,block.blockhash(bi.BlockNumber),uintToString(randomNum));
      awardNum = uint(encrptyHash)%22;
      awardNum = awardNum.add(1);
      bi.AwardNum = awardNum;
      for(uint n=0;n <bi.BetNums.length;n++){
        if(bi.BetNums[n] == awardNum){
          awardAmount = bi.BetAmounts[n].mul(winMultiplePer).div(100);
          bi.IsReturnAward = true;  
          userEtherOf[this] = userEtherOf[this].sub(totalAmount);
          userEtherOf[bi.Player] = userEtherOf[bi.Player].add(awardAmount);
          userEtherOf[shareholder] = userEtherOf[shareholder].add(totalAmount.sub(awardAmount));
          break;
        }
      }
    }
    if(!bi.IsReturnAward){
      bi.IsReturnAward = true;
      userEtherOf[this] = userEtherOf[this].sub(totalAmount);
      userEtherOf[shareholder] = userEtherOf[shareholder].add(totalAmount);
    }
    emit OnGetAward(bi.Player,_playNo,bi.BetNums,bi.BlockNumber,bi.BetAmounts,getEventId(),awardNum,awardAmount);  
    _result = true; 
    unLock();
  }
  function getAwardNum(uint _playNo) view public returns(uint _awardNum){
    betInfo memory bi = playerBetInfoOf[_playNo];
    if(bi.BlockNumber.add(256) >= block.number){
      uint256 randomNum = bi.EventId%1000000;
      bytes32 encrptyHash = keccak256(bi.Player,block.blockhash(bi.BlockNumber),uintToString(randomNum));
      _awardNum = uint(encrptyHash)%22;
      _awardNum = _awardNum.add(1);
    }
  }

  function uintToString(uint v) private pure returns (string)    
  {
    uint maxlength = 10;                     
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

  function () public payable {        
    if(msg.value > 0){
      userEtherOf[msg.sender] = userEtherOf[msg.sender].add(msg.value);
    }
  }

}