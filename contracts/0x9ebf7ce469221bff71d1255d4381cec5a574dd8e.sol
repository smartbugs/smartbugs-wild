pragma solidity ^0.4.3;
contract Game{

  address founder;

  uint8 betPhase=6;

  uint8 commitPhase=6;

  uint8 openPhase=6;

  uint minValue=0.1 ether;



  uint refund=90;

  bool finished=true;

  uint startBlock;

  uint id=0;

  struct Participant{
    bytes32 hash;
    bytes32 origin;
    uint value;
    bool committed;
    bool returned;
  }




  struct Bet{
    uint8 betPhase;
    uint8 commitPhase;
    uint8 openPhase;
    uint minValue;

    mapping(address=>Participant) participants;
    address[] keys;
    uint totalValue;
    uint valiadValue;
    uint validUsers;
    bytes32 luckNumber;
    address lucky;
    bool prized;
    uint refund;
  }

  mapping(uint=>Bet) games;


  modifier checkGameFinish(){
    if(finished){
      throw;
    }
    _;
  }

  modifier checkFounder(){
    if(msg.sender!=founder){
      throw;
    }
    _;
  }

  modifier checkPrized(uint id){
    if(games[id].prized){
      throw;
    }
    _;
  }

  modifier checkFihished(){
    if(!finished){
      throw;
    }
    _;
  }

  modifier checkId(uint i){
    if(id!=i){
      throw;
    }
    _;
  }

  modifier checkValue(uint value){
    if(value<minValue){
      throw;
    }
    _;
  }

  modifier checkBetPhase(){
    if(block.number>startBlock+betPhase){
      throw;
    }
    _;
  }

  modifier checkCommitPhase(){
    if(block.number>startBlock+betPhase+commitPhase){
      throw;
    }
    _;
  }

  modifier checkOpen(){
    if(block.number<startBlock+betPhase+commitPhase){
      throw;
    }
    _;
  }

  modifier checkUser(address user,uint id){
    if(games[id].participants[user].hash==""){
      throw;
    }
    _;
  }

  modifier checkRegister(uint id,address user){
    if(games[id].participants[user].hash!=""){
      throw;
    }
    _;
  }

  function Game() public{
    founder=msg.sender;
  }

  event StartGame(uint indexed id,uint8 betPhase,uint8 commitPhase,uint8 openPhase,uint betValue,uint refund,uint startBlock);



  function startGame(uint8 iBetPhase,uint8 iCommitPhase,uint8 iOpenPhase,uint betvalue,uint iRefund)
  checkFounder
  checkFihished
  {
    id+=1;
    betPhase=iBetPhase;
    commitPhase=iCommitPhase;
    openPhase=iOpenPhase;
    minValue=(betvalue*1 ether)/100;
    finished=false;
    startBlock=block.number;
    refund=iRefund;
    StartGame(id,betPhase,commitPhase,openPhase,minValue,refund,startBlock);
  }

  // current total value,hash,id,sid
  event Play(uint indexed value,bytes32 hash,uint id,bytes32 sid,address player);

  function play(uint id,bytes32 hash,bytes32 sid) public payable
  checkValue(msg.value)
  checkBetPhase
  checkId(id)
  checkRegister(id,msg.sender)
  {
    address user=msg.sender;
    Bet memory tmp=games[id];
    Participant memory participant=Participant({hash:hash,origin:"",value:msg.value,committed:false,returned:false});
    uint value;
    if(tmp.keys.length==0){
      Bet storage bet=games[id];
      bet.betPhase=betPhase;
      bet.commitPhase=commitPhase;
      bet.openPhase=openPhase;
      bet.minValue=minValue;

      bet.keys.push(user);
      bet.participants[user]=participant;
      bet.refund=refund;
      bet.totalValue=msg.value;
      value=msg.value;
    }else{
      games[id].keys.push(user);
      games[id].participants[user]=participant;
      games[id].totalValue+=msg.value;
      value=msg.value;
    }
    var num=games[id].keys.length;
    Play(value,hash,id,sid,msg.sender);
  }
  // origin,valid users
  event CommitOrigin(address indexed user,bytes32 origin,uint num,bytes32 sid,uint id);

  function commitOrigin(uint id,bytes32 origin,bytes32 sid)
  checkCommitPhase
  checkId(id)
  checkUser(msg.sender,id)
  {
    bytes32 hash=games[id].participants[msg.sender].hash;
    if(sha3(origin)==hash){
      if(games[id].participants[msg.sender].committed!=true){
        games[id].participants[msg.sender].committed=true;
        games[id].participants[msg.sender].origin=origin;
        games[id].valiadValue+=games[id].participants[msg.sender].value;
        games[id].validUsers++;
        CommitOrigin(msg.sender,origin,games[id].validUsers,sid,id);
      }

    }else{
      throw;
    }
  }

  function getLuckNumber(Bet storage bet) internal
  returns(bytes32)
  {
    address[] memory users=bet.keys;
    bytes32 random;
    for(uint i=0;i<users.length;i++){
      address key=users[i];
      Participant memory p=bet.participants[key];

      if(p.committed==true){
        random ^=p.origin;
      }
    }
    return sha3(random);
  }

  // lucky user,lucky number,random number,prize
  event Open(address indexed user,bytes32 random,uint prize,uint id);

  function open(uint id)
  checkPrized(id)
  checkFounder
  checkOpen
  checkGameFinish
  {
    bytes32 max=0;
    Bet storage bet=games[id];
    bytes32 random=getLuckNumber(bet);
    address tmp;
    address[] memory users=bet.keys;
    for(uint i=0;i<users.length;i++){

      address key=users[i];
      Participant storage p=bet.participants[key];
      if(p.committed==true){
        bytes32 distance=random^p.origin;
        if(distance>max){
          max=distance;
          tmp=key;
        }
      }else{
        if(p.returned==false){
          if(key.send(p.value*8/10)){
            p.returned=true;
          }

        }
      }

    }
    bet.lucky=tmp;
    bet.luckNumber=random;
    uint prize=bet.valiadValue*refund/100;

    founder.send((bet.valiadValue-prize));
    if(tmp.send(prize)){
      bet.prized=true;
      Open(tmp,random,prize,id);
    }

    finished=true;
  }

  function getContractBalance() constant returns(uint){
    return this.balance;
  }

  function withdraw(address user,uint value)
  checkFounder
  {
    user.send(value);
  }

  function getPlayerCommitted(uint period,address player) constant returns(bool){
    Participant memory p=games[period].participants[player];
    return p.committed;
  }

  function getPlayerReturned(uint period,address player) constant returns(bool){
    Participant memory p=games[period].participants[player];
    return p.returned;
  }

  function getPlayerNum(uint period) constant
  returns(uint){
    Bet bet=games[period];
    return bet.keys.length;
  }

  function getPlayerAddress(uint period,uint offset) constant
  returns(address){
    Bet bet=games[period];
    return bet.keys[offset];
  }

  function getPlayerOrigin(uint period,uint offset) constant
  returns(bytes32){
    Bet bet=games[period];
    address user=bet.keys[offset];
    return bet.participants[user].origin;
  }

  function getPlayerHash(uint period,uint offset) constant
  returns(bytes32){
    Bet bet=games[period];
    address user=bet.keys[offset];
    return bet.participants[user].hash;
  }

  function getPlayerValue(uint period,uint offset) constant
  returns(uint){
    Bet bet=games[period];
    address user=bet.keys[offset];
    return bet.participants[user].value;
  }

  // public getRandom(uint id) constant{

  // }
  function getId() constant returns(uint){
    return id;
  }

  function getRandom(uint id) constant
  checkId(id)
  returns(bytes32){
    return games[id].luckNumber;
  }

  function getLuckUser(uint id) constant
  checkId(id)
  returns(address){
    return games[id].lucky;
  }

  function getPrizeAmount(uint id) constant
  checkId(id)
  returns(uint){
    return games[id].totalValue;
  }

  function getMinAmount(uint id) constant
  checkId(id)
  returns(uint)
  {
    return minValue;
  }

  function getsha3(bytes32 x) constant
  returns(bytes32){
    return sha3(x);
  }

  function getGamePeriod() constant
  returns(uint){
    return id;
  }


  function getStartBlock() constant
  returns(uint){
    return startBlock;
  }

  function getBetPhase() constant
  returns(uint){
    return betPhase;
  }

  function getCommitPhase() constant
  returns(uint){
    return commitPhase;
  }

  function getFinished() constant
  returns(bool){
    return finished;
  }

}