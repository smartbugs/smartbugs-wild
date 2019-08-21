contract TossMyCoin {

  uint fee;
  uint public balance = 0;
  uint  balanceLimit = 0;
  address public owner;
  uint public active = 1;
  uint FirstRun = 1;

  modifier onlyowner { if (msg.sender == owner) _ }


  function TossMyCoin() {
    owner = msg.sender;
  }

  function() {
    enter();
  }
  
  function enter() {
  
  if(active ==0){
  msg.sender.send(msg.value);
  return;
  }
  
  if(FirstRun == 1){
  balance = msg.value;
  FirstRun = 0;
  }
  
    if(msg.value < 10 finney){
        msg.sender.send(msg.value);
        return;
    }

    uint amount;
	uint reward;
    fee = msg.value / 10;
    owner.send(fee);
    fee = 0;
    amount = msg.value * 9 / 10;
	
    balanceLimit = balance * 8 / 10;
    if (amount > balanceLimit){
        msg.sender.send(amount - balanceLimit);
        amount = balanceLimit;
    }

    var toss = uint(sha3(msg.gas)) + uint(sha3(block.timestamp));
        
    if (toss % 2 == 0){
    balance = balance + amount ;  
    } 
    else{
	reward = amount * 2;
    msg.sender.send(reward);	
    }


  }

  function kill(){
  if(msg.sender == owner) {
  active = 0;
  suicide(owner);
  
  }
  }
  function setOwner(address _owner) onlyowner {
      owner = _owner;
  }
}