pragma solidity ^0.4.24;
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor() public {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner,"Have no legal powerd");
    _;
  }
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
contract ERC20Interface {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}
contract VoterFactory is Ownable{
    using SafeMath for uint256; //uint256 library
    mapping(address=>uint) total; //player total Voter
    mapping(address=>mapping(uint=>uint)) totalForVoter;
    mapping(address=>uint) balances;//player gamcoin 
    mapping(address=>uint) playerP;//player PID
    mapping(uint=>address) playerA;//PID to player address
    mapping(address=>mapping(uint=>uint)) playerV;//player=>voterID=>voters
    mapping(address=>uint) playerEth;//player=>ETHER
    mapping(address=>address) referees;//player=>referees
    mapping(address=>address[]) totalReferees;//referees=>totalplayer
    mapping(address=>uint) isCreated;
    
    
    event NewVoter(uint _id,uint256 _name,uint _value,uint _vectoryvalue);// new model event
    event GiveVoter(address indexed _fromaddress,uint _toid,uint _number);// voter event
    event gameover(bool isReady);//gameover
    event NewPlayer(uint _id,address indexed _address);//createPlayer
    event restart(bool isReady,uint _RID);//reboot
    event EgiveToVoterOnlyowner(uint _toid,uint _number);
    event EgetPlayerCoin(address indexed _address,uint256 _number,bool _bool);
    event Ewithdraw(uint _ether);
    event EsetFee(uint _time,uint _fee);
    event Ebuygamecoin(uint _time,uint _number,address indexed _address);
    event EgetEveryDayEarnings(uint _time,uint _number,uint _totalplayers,address _address);
    
    struct Voter{
        uint id;
        uint256 name;
        uint value;
        address[] pa;
        uint totalplayer;
    }
    struct Winner{
        uint256 name;
        uint value;
    }
    Winner[] public winners;
    Voter[] public voters;
    Voter[] voterss;
    uint public RID=0;
    uint public totalRef;
    uint public totalplayers;//total player
    uint public ids=0;//total model
    uint public fee = 340000000000000;//gamcoin fee
    uint public createTime = now;//create Time
    uint public shutTime = 0 minutes;//shutdown time
    uint public decimals = 18; 
    bool public started = false;
    uint public EthOther = 100000000000000000000;
    uint public EthOtherfee = 10000;
    address public winnerOfplayer;
    address[]  public _addrs;
    ERC20Interface CDS;
}
contract VoterServiceImpl is VoterFactory{
    function _createPlayer(address _address) internal {
        playerA[totalplayers] = _address;
        playerP[_address] = totalplayers;
        totalplayers=totalplayers.add(1);
        _addrs.push(_address);
        emit NewPlayer(totalplayers-1,_address);
    }
    function _getEarnings(address _address,uint _playerTotal,uint _value,uint _oldvalue) internal {
        uint proportion = _playerTotal.div(_oldvalue);
        uint surplus = (_value.div(2)).add(_value.div(5));
        balances[_address] = balances[_address].add(proportion.mul(_value.sub(surplus)));
        totalRef = totalRef.add(proportion.mul(_value.sub(surplus)));
    }
    function _shutDown() internal{
        require(now>=(createTime+shutTime),"Not over yet");
        if(balances[owner]!=0){
            uint256  vectoryId=0;
            if(ids!=0){
                for(uint256 i=0;i<ids;i=i.add(1)){
                    if(voters[i].value>voters[vectoryId].value){
                        vectoryId=i;
                    }
                }
                winners.push(Winner(voters[vectoryId].name,voters[vectoryId].value));
                uint vectoryValue = balances[owner];
                uint oldvalue = voters[vectoryId].value;
                for(uint256 k=0;k<voters[vectoryId].totalplayer;k=k.add(1)){
                    address add = voters[vectoryId].pa[k];
                    uint playerTotal = playerV[add][vectoryId];
                    _getEarnings(add,playerTotal,vectoryValue,oldvalue);
                }
                for(uint256 j=0;j<ids;j=j.add(1)){
                voters[j].value=0;
                }
            }
            if(totalplayers!=0){
                for(uint256 s=0;s<totalplayers;s=s.add(1)){
                    total[playerA[s]]=0;
                    playerP[playerA[s]]=0;
                    for(uint256 n=0;n<ids;n=n.add(1)){
                        playerV[playerA[s]][n]=0;
                    }
                    playerEth[playerA[s]]=0;
                    referees[playerA[s]];
                    totalReferees[playerA[s]];
                    playerA[s]=0;
                }
            }
            balances[winnerOfplayer] = balances[winnerOfplayer].add(vectoryValue.div(50));
        }
        totalplayers=0;
        ids=0;
        EthOtherfee=10000;
        EthOther=100000000000000000000;
        winnerOfplayer = owner;
        voters = voterss;
        balances[owner]=0;
        started=false;
    }
    function _createVoter(uint256 _str) internal onlyOwner{
        address[] memory p;
        voters.push(Voter(ids,_str,0,p,0));
        ids=ids.add(1);
    }
}


contract Voterplayer is VoterServiceImpl{
    function giveToVoter(uint _value,uint _id) public {
        require(started);
        require(msg.sender!=owner);
        uint time = createTime.add(shutTime);
        require(now<time);
        require(_id<=ids);
        require(msg.sender!=owner,"owner Can't vote");
        require(balances[msg.sender]>=_value,"balances too low");
        balances[msg.sender]=balances[msg.sender].sub(_value);
        totalForVoter[msg.sender][_id]=totalForVoter[msg.sender][_id].add(_value);
        if(playerV[msg.sender][_id]==0){
            voters[_id].pa.push(msg.sender);
            voters[_id].totalplayer=voters[_id].totalplayer.add(1);
        }
        if(referees[msg.sender]!=0){
            balances[referees[msg.sender]] = balances[referees[msg.sender]].add(_value.mul(1).div(10));
            totalRef = totalRef.add(_value.mul(1).div(10));
        }
        total[msg.sender]=total[msg.sender].add(_value);
        balances[owner]=balances[owner].add(_value);
        voters[_id].value=voters[_id].value.add(_value);
        playerV[msg.sender][_id] = playerV[msg.sender][_id].add(_value);
        emit GiveVoter(msg.sender,_id,_value);
        return;
    }
    function createAllVoter(uint256[] _voter) public onlyOwner{
        for(uint i=0;i<_voter.length;i=i.add(1)){
             createVoter(_voter[i]);
        }
    }
    function giveToVoterOnlyowner(uint _value,uint _id) public onlyOwner{
        require(started);
        voters[_id].value=voters[_id].value.add(_value);
        balances[owner]=balances[owner].add(_value);
        emit EgiveToVoterOnlyowner(_id,_value);
    }
    function getaddresstotal(uint _id) public view returns(uint){
        return voters[_id].totalplayer;
    }
    function getTotalForVoter(address _address,uint _id) view public returns(uint){
        return totalForVoter[_address][_id];
    } 
    function getTotalVoter(address _address) view public returns(uint totals){
        return total[_address];
    }
    function balanceOf(address _address) view public returns(uint balance){
        return balances[_address];
    }
    function refereesOf(address _address) view public returns(address[]){
        return totalReferees[_address];
    }
    function getAllPlayer() view public returns(address[]){
        return _addrs;
    }
    function buyGameCoin(uint256 _number,address _address) public payable{
        require(started);
        require(msg.sender!=owner);
        uint256  coinfee = _number.div(10).mul(fee);
        require(msg.value>=coinfee);
        if(msg.sender!=_address&&referees[msg.sender]==0){
            require(balances[_address]>0);
            balances[_address] = balances[_address].add((_number.mul(30).div(100)).mul(1).div(10));
            totalRef = totalRef.add(_number.mul(10).div(100));
            referees[msg.sender] = _address;
            totalReferees[_address].push(msg.sender);
        }else if(msg.sender==_address&&referees[msg.sender]!=0){
            balances[referees[msg.sender]] = balances[referees[msg.sender]].add((_number.mul(30).div(100)).mul(1).div(10));
            totalRef = totalRef.add((_number.mul(30).div(100)).mul(1).div(10));
        }
        total[msg.sender] = total[msg.sender].add(_number.mul(30).div(100));
        if(isCreated[msg.sender]==0){
            isCreated[msg.sender] = 1;
            _createPlayer(msg.sender);
        }
        balances[msg.sender]=balances[msg.sender].add(_number.mul(70).div(100));
        balances[owner] = balances[owner].add(_number.mul(30).div(100));
        if(playerEth[owner]>=EthOther){
            EthOtherfee=EthOtherfee.mul(2);
            EthOther = EthOther.mul(3);
        }
        fee=fee.add(fee.div(EthOtherfee.mul(1000)).mul((msg.value.sub(msg.value%1000000000000000)).div(1000000000000000)));
        playerEth[owner] = playerEth[owner].add(msg.value);
        msg.sender.transfer(msg.value.sub(coinfee));
        owner.transfer(coinfee);
        shutTime = shutTime.add(_number.div(10));
        winnerOfplayer = msg.sender;
        emit Ebuygamecoin(now,_number,_address);
    }
    function getPlayerCoin(uint256 _number) external {
        require(balances[msg.sender]>=_number);
        balances[msg.sender] = balances[msg.sender].sub(_number);
        uint256 _token = _number.div(10).mul(10**decimals);
        require(CDS.transferFrom(owner,msg.sender,_token));
        emit EgetPlayerCoin(msg.sender,_number,true);
    }
    function createVoter(uint256 _name) public onlyOwner{
        _createVoter(_name);
        emit NewVoter(ids-1,_name,0,0);
    }
    function startGame(uint _time,address _address,uint256 _decimals) public onlyOwner{
        require(!started);
        require(_address!=address(0));
        CDS=ERC20Interface(_address);
        decimals=_decimals;
        createTime=now;
        shutTime= _time;
        RID=RID.add(1);
        started=true;
        totalRef=0;
        emit restart(started,RID);
    }
    function setTime(uint _time) public onlyOwner{
        require(started);
        shutTime= _time;
    }
    function setFee(uint _fee) public onlyOwner{
        fee=_fee;
        emit EsetFee(now,_fee);
    }
    function gameOver() public onlyOwner{
        _shutDown();
        emit gameover(true);
    }
    function withdraw() external onlyOwner {
        address myAddress = address(this);
        owner.transfer(myAddress.balance);
        emit Ewithdraw(myAddress.balance);
    }
    function setCDStokenAddress(address _address,uint256 _decimals) public onlyOwner{
       require(_address!=address(0));
        decimals=_decimals;
        CDS=ERC20Interface(_address);
    }
    
    function getEveryDayEarnings(address _address,uint256 _number) public onlyOwner{
        require(balances[owner]>=_number);
        totalRef=totalRef.add(_number.mul(2));
        balances[_address]=balances[_address].add(_number);
        if(totalplayers!=0){
                for(uint256 s=0;s<totalplayers;s=s.add(1)){
                    if(total[playerA[s]]==0){
                        continue;
                    }
                    balances[playerA[s]] = balances[playerA[s]].add(_number.mul(total[playerA[s]]).div(balances[owner]));
                }
            }
        emit EgetEveryDayEarnings(now,_number,totalplayers,_address);
    }
    
}
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}