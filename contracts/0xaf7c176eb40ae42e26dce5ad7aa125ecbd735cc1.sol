pragma solidity ^0.4.18;


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
   
   
    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Base {
    using SafeMath for uint256;
    uint public createTime = now;
    address public owner;
    address public ownerAdmin;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
   
    function setOwner(address _newOwner)  public {
        require(msg.sender  == ownerAdmin);
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

    mapping (address => uint256) public userEtherOf;

    function userRefund() public  returns(bool _result) {             
        return _userRefund(msg.sender);
    }

    function _userRefund(address _to) internal returns(bool _result){  
        require (_to != 0x0);
        lock();
        uint256 amount = userEtherOf[msg.sender];
        if(amount > 0){
            userEtherOf[msg.sender] = 0;
            _to.transfer(amount);
            _result = true;
        }
        else{
            _result = false;
        }
        unLock();
    }

    uint public currentEventId = 1;                             

    function getEventId() internal returns(uint _result) {      
        _result = currentEventId;
        currentEventId ++;
    }

}


interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract TokenERC20 is Base {                                               
    string public name = 'Don Quixote Token';                              
    string public symbol = 'DON';
    uint8 public decimals = 9;
         
    uint256 public totalSupply = 0;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    function _callDividend(address _user) internal returns (bool _result);      

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_from != 0x0);
        require(_to != 0x0);
        require(_from != _to);
        require(_value > 0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to].add(_value) >= balanceOf[_to]);

        _callDividend(_from);   
        _callDividend(_to);     

        uint256 previousBalances = balanceOf[_from].add(balanceOf[_to]);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from].add( balanceOf[_to]) == previousBalances);
    }

    function transfer(address _to, uint256 _value) public {
        require(_to != 0x0);
        require(_value > 0);
        _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != 0x0);
        require(_to != 0x0);
        require(_value > 0);
        require(_value <= allowance[_from][msg.sender]);    
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != 0x0);
        require(_value > 0);
               
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        require(_spender != 0x0);
        require(_value > 0);
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {           
        require(_value > 0);
        require(balanceOf[msg.sender] >= _value);

        _callDividend(msg.sender);                

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {       
        require(_from != 0x0);
        require(_value > 0);
        assert(1 >= 2);
        symbol = 'DON';
        return false;
    }
}

interface IWithholdToken{          
    function withhold(address _user,  uint256 _amount) external returns (bool _result);
    function setGameTransferFlag(address _gameAddress, bool _gameCanTransfer) external;
}

contract WithholdToken is TokenERC20, IWithholdToken{          

    mapping (address=>mapping(address=>bool)) public gameTransferFlagOf;                    

    function setGameTransferFlag(address _gameAddress, bool _gameCanTransfer) external {    
        require(_gameAddress != 0x0);
        gameTransferFlagOf[msg.sender][_gameAddress] = _gameCanTransfer;
    }

    mapping(address => bool) public gameWhiteListOf;                                       

    event OnWhiteListChange(address indexed _gameAddr, address _operator, bool _result,  uint _eventTime, uint _eventId);

    function addWhiteList(address _gameAddr) public onlyOwner {
        require (_gameAddr != 0x0);
        gameWhiteListOf[_gameAddr] = true;
        emit OnWhiteListChange(_gameAddr, msg.sender, true, now, getEventId());
    }

    function delWhiteList(address _gameAddr) public onlyOwner {
        require (_gameAddr != 0x0);
        gameWhiteListOf[_gameAddr] = false;
        emit OnWhiteListChange(_gameAddr, msg.sender, false, now, getEventId());
    }

    function isWhiteList(address _gameAddr) public view returns(bool _result) {    
        require (_gameAddr != 0x0);
        _result = gameWhiteListOf[_gameAddr];
    }
   
    function withhold(address _user,  uint256 _amount) external returns (bool _result) {
        require(_user != 0x0);
        require(_amount > 0);
        require(msg.sender != tx.origin);
       
        require(gameTransferFlagOf[_user][msg.sender]);        
        require(isWhiteList(msg.sender));
        require(balanceOf[_user] >= _amount);
        
        _transfer(_user, msg.sender, _amount);
        
        return true;
    }
   
}

interface IProfitOrg {                                                   
    function userRefund() external returns(bool _result);               
    function shareholder() constant external returns (address);        
                          
}

interface IDividendToken{                           
    function profitOrgPay() payable external;       
}

contract DividendToken is WithholdToken, IDividendToken{             

    address public iniOwner;

    struct DividendPeriod                          
    {
        uint StartTime;
        uint EndTime;
        uint256 TotalEtherAmount;
        uint256 ShareEtherAmount;
    }

    mapping (uint => DividendPeriod) public dividendPeriodOf;   
    uint256 public currentDividendPeriodNo = 0;                 

    uint256 public shareAddEtherValue = 0;      
    uint256 public addTotalEtherValue = 0;      

    uint public lastDividendTime = now;         

    mapping (address => uint) public balanceTimeOf;     

    uint256 public minDividendEtherAmount = 1 ether;    
    function setMinDividendEtherAmount(uint256 _newMinDividendEtherAmount) public onlyOwner{
        minDividendEtherAmount = _newMinDividendEtherAmount;
    }

    function callDividend() public returns (uint256 _etherAmount) {             
        _callDividend(msg.sender);
        _etherAmount = userEtherOf[msg.sender];
        return;
    }

    event OnCallDividend(address indexed _user, uint256 _tokenAmount, uint _lastCalTime, uint _etherAmount, uint _eventTime, uint _eventId);

    function _callDividend(address _user) internal returns (bool _result) {    
        uint _amount = 0;
        uint lastTime = balanceTimeOf[_user];
        uint256 tokenNumber = balanceOf[_user];                                 
        if(tokenNumber <= 0)
        {
            balanceTimeOf[_user] = now;
            _result = false;
            return;
        }
        if(currentDividendPeriodNo == 0){ 
        	_result = false;
            return;
        }
        for(uint256 i = currentDividendPeriodNo-1; i >= 0; i--){
            DividendPeriod memory dp = dividendPeriodOf[i];
            if(lastTime < dp.EndTime){
                _amount = _amount.add(dp.ShareEtherAmount.mul(tokenNumber));
            }else if (lastTime >= dp.EndTime){
                break;
            }
        }
        balanceTimeOf[_user] = now;
        if(_amount > 0){
            userEtherOf[_user] = userEtherOf[_user].add(_amount);          
            
        }

        emit OnCallDividend(_user, tokenNumber, lastTime, _amount, now, getEventId());
        _result = true;
        return;
    }

    function saveDividendPeriod(uint256 _ShareEtherAmount, uint256 _TotalEtherAmount) internal {    
        DividendPeriod storage dp = dividendPeriodOf[currentDividendPeriodNo];
        dp.ShareEtherAmount = _ShareEtherAmount;
        dp.TotalEtherAmount = _TotalEtherAmount;
        dp.EndTime = now;
        dividendPeriodOf[currentDividendPeriodNo] = dp;
    }

    function newDividendPeriod(uint _StartTime) internal {
        DividendPeriod memory newdp = DividendPeriod({
                StartTime :  _StartTime,
                EndTime : 0,
                TotalEtherAmount : 0,
                ShareEtherAmount : 0
        });

        currentDividendPeriodNo++;
        dividendPeriodOf[currentDividendPeriodNo] = newdp;
    }

    function callDividendAndUserRefund() public {   
        callDividend();
        userRefund();
    }
    
    function getProfit(address _profitOrg) public {     
        lock();
        IProfitOrg pt = IProfitOrg(_profitOrg);
        address sh = pt.shareholder();
        if(sh == address(this))     
        {
            pt.userRefund();       
        }
        unLock();
    }

    event OnProfitOrgPay(address _profitOrg, uint256 _sendAmount, uint256 _divAmount, uint256 _shareAmount, uint _eventTime, uint _eventId);

    uint public divIntervalDays = 1 days; 

    function  setDivIntervalDays(uint _days) public onlyOwner {
        require(_days >= 1 && _days <= 30);
        divIntervalDays = _days * (1 days);
    }

    function profitOrgPay() payable external {        
             
        if (msg.value > 0){
            userEtherOf[this] += msg.value;         
            addTotalEtherValue += msg.value;
            shareAddEtherValue += msg.value /  totalSupply;

            uint256 canValue = userEtherOf[this];
            if(canValue < minDividendEtherAmount || now - lastDividendTime < divIntervalDays)   
            {
                emit OnProfitOrgPay(msg.sender, msg.value, 0, 0, now, getEventId());
                return;
            }

            uint256 sa = canValue .div(totalSupply);        
            if(sa <= 0){
                emit OnProfitOrgPay(msg.sender, msg.value, 0, 0, now, getEventId());
                return;                                     
            }

            uint256 totalEtherAmount = sa.mul(totalSupply);        
            saveDividendPeriod(sa, totalEtherAmount);
            newDividendPeriod(now);
            userEtherOf[this] = userEtherOf[this].sub(totalEtherAmount);
            emit OnProfitOrgPay(msg.sender, msg.value, totalEtherAmount, sa, now, getEventId());
            lastDividendTime = now;
            return;
        }
    }

    event OnFreeLostToken(address _lostUser, uint256 _tokenNum, uint256 _etherNum, address _to, uint _eventTime, uint _eventId);

    function freeLostToken(address _user) public onlyOwner {          
        require(_user != 0x0);
        uint addTime = 10 * 365 days;   
            
        require(balanceOf[_user] > 0 && createTime.add(addTime) < now  && balanceTimeOf[_user].add(addTime) < now);     
	    require(_user != msg.sender && _user != iniOwner);

        uint256 ba = balanceOf[_user];                
        require(ba > 0);
        _callDividend(_user);                          
        _callDividend(msg.sender);                    
        _callDividend(iniOwner);                        

        balanceOf[_user] -= ba;
        balanceOf[msg.sender] = balanceOf[msg.sender].add( ba / 2);
        balanceOf[iniOwner] = balanceOf[iniOwner].add(ba - (ba / 2));

        uint256 amount = userEtherOf[_user];       
        if (amount > 0){
            userEtherOf[_user] = userEtherOf[_user].sub(amount);
            userEtherOf[msg.sender] = userEtherOf[msg.sender].add(amount / 2);
            userEtherOf[iniOwner] = userEtherOf[iniOwner].add(amount - (amount / 2));
        }

        emit OnFreeLostToken(_user, ba, amount, msg.sender, now, getEventId());
    }

}

contract ReferrerToken is DividendToken{                

    mapping(address => address) playerReferrerOf;       

    uint256 public refRewardL1Per100 = 30;             
   
    function setRefRewardPer100(uint256 _value1) public onlyOwner{
        require(_value1 <= 50);
        refRewardL1Per100 = _value1;
    }

    bool public referrerEnable = true;          

    function setreferrerEnable(bool _enable) public onlyOwner{
        referrerEnable = _enable;
    }

    event OnAddPlayer(address _player, address _referrer, uint _eventTime, uint _eventId);

    function addPlayer(address _player, address _referrer) public returns (bool _result){
        _result = false;
        require(_player != 0x0);
        require(_referrer != 0x0);
        require(referrerEnable);

        if(balanceOf[_player] != 0){
            return;
        }

        if(balanceOf[_referrer] == 0){
            return;
        }

        if(playerReferrerOf[_player] == 0x0){
            playerReferrerOf[_player] = _referrer;
            emit OnAddPlayer(_player, _referrer, now, getEventId());
            _result = true;
        }
    }

    function addPlayer1(address _player) public returns (bool _result){
        _result = addPlayer(_player, msg.sender);
    }

    function addPlayer2(address[] _players) public returns (uint _result){
        _result = 0;
        for(uint i = 0; i < _players.length; i++){
            if(addPlayer(_players[i], msg.sender)){
                _result++;
            }
        }
    }

    function addPlayer3(address[] _players, address _referrer) public returns (uint _result){
        _result = 0;
        for(uint i = 0; i < _players.length; i++){
            if(addPlayer(_players[i], _referrer)){
                _result++;
            }
        }
    }

    function getReferrer1(address _player) public view returns (address _result){           
        _result = playerReferrerOf[_player];
    }

}

interface IGameToken{                                                                      
   function mineToken(address _player, uint256 _etherAmount) external returns (uint _toPlayerToken);
}

contract GameToken is ReferrerToken, IGameToken{        

    address public boss;
    address public bossAdmin;
    function setBoss(address _newBoss) public{
        require(msg.sender == bossAdmin);
        boss = _newBoss;
    }

    function GameToken(address _ownerAdmin, address _boss, address _bossAdmin)  public {
        require(_ownerAdmin != 0x0);
        require(_boss != 0x0);
        require(_bossAdmin != 0x0);

        owner = msg.sender;
        iniOwner = msg.sender;
        ownerAdmin = _ownerAdmin;

        boss = _boss;
        bossAdmin = _bossAdmin;

        totalSupply = 0;                             
        balanceOf[msg.sender] = totalSupply;           
    }

    event OnAddYearToken(uint256 _lastTotalSupply, uint256 _currentTotalSupply, uint _years, uint _eventTime, uint _eventId);

    mapping(uint => uint256) yearTotalSupplyOf;

    function addYearToken() public returns(bool _result) {                      
        _result = false;
        uint y = (now - createTime) / (365 days);
        if (y > 0 && yearTotalSupplyOf[y] == 0){
            _callDividend(iniOwner);    

            uint256 _lastTotalSupply = totalSupply;
            totalSupply = totalSupply.mul(102).div(100);                                 
            uint256 _add = totalSupply.sub(_lastTotalSupply);
            balanceOf[iniOwner] = balanceOf[iniOwner].add(_add);
            yearTotalSupplyOf[y] = totalSupply;

            emit OnAddYearToken(_lastTotalSupply, totalSupply, y, now, getEventId());
        }
    }

    uint256 public baseMineTokenAmount = 1000 * (10 ** uint256(decimals));   

    uint256 public currentMineTokenAmount   = baseMineTokenAmount;
    uint    public currentMideTokenTime     = now;

    function getMineTokenAmount() public returns (uint256 _result){            
        _result = 0;

        if (currentMineTokenAmount == 0){
            _result = currentMineTokenAmount;
            return;
        }

        if(now <= 1 days + currentMideTokenTime){
            _result = currentMineTokenAmount;
            return;
        }

        currentMineTokenAmount = currentMineTokenAmount * 996 / 1000;
        if(currentMineTokenAmount <= 10 ** uint256(decimals)){
            currentMineTokenAmount = 0;
        }
        currentMideTokenTime = now;

        _result = currentMineTokenAmount;
        return;
    }
    
    event OnMineToken(address indexed _game, address indexed _player, uint256 _toUser, uint256 _toOwner, uint256 _toBosss, uint256 _toSupper, uint _eventTime, uint _eventId);

    function mineToken(address _player, uint256 _etherAmount) external returns (uint _toPlayerToken) {
        _toPlayerToken = _mineToken(_player, _etherAmount);
    }

    function _mineToken(address _player, uint256 _etherAmount) private returns (uint _toPlayerToken) {
        require(_player != 0x0);
        require(isWhiteList(msg.sender));   
        require(msg.sender != tx.origin);   
        require(_etherAmount > 0);

        uint256 te = getMineTokenAmount();
        if (te == 0){
            return;
        }

        uint256 ToUser = te .mul(_etherAmount).div(1 ether);
        if (ToUser > 0){
            _callDividend(_player);
            _callDividend(owner);
            _callDividend(boss);

            balanceOf[_player] = balanceOf[_player].add(ToUser);

            uint256 ToSupper = 0;
            if(referrerEnable){
                address supper = getReferrer1(_player);
                if (supper != 0x0){
                    _callDividend(supper);
                    ToSupper = ToUser * refRewardL1Per100 / 100;
                    balanceOf[supper] = balanceOf[supper].add(ToSupper);
                }
            }

            uint256 ToUS = ToUser.add(ToSupper);
            uint256 ToOwner = ToUS.div(8);
            balanceOf[owner] = balanceOf[owner].add(ToOwner);
            uint256 ToBoss = ToUS.div(8);
            balanceOf[boss] = balanceOf[boss].add(ToBoss);

            totalSupply = totalSupply.add(ToUS.add(ToOwner.add(ToBoss)));

            emit OnMineToken(msg.sender,  _player, ToUser, ToOwner, ToBoss, ToSupper, now, getEventId());
        }
        _toPlayerToken = ToUser;
    }

    function () public payable {                            
        if (msg.value > 0){
            userEtherOf[msg.sender] += msg.value;
        }
    }

}