contract test {

  struct Person {
      address etherAddress;
      uint amount;
  }

  Person[] public persons;

  uint public payoutIdx = 0;
  uint public collectedFees;
  uint public balance = 0;

  address public owner;


  modifier onlyowner { if (msg.sender == owner) _ }


  function test() {
    owner = msg.sender;
  }

  function() {
    enter();
  }
  
  function enter() {
  //only pair amount
    if (msg.value % 2 != 0 ) {
        msg.sender.send(msg.value);
        return;
    }
	
	uint amount;

	amount = msg.value;


    uint idx = persons.length;
    persons.length += 1;
    persons[idx].etherAddress = msg.sender;
    persons[idx].amount = amount;
 
    

      balance += amount;
  


    while (balance > persons[payoutIdx].amount * 2) {
      uint transactionAmount = persons[payoutIdx].amount * 2;
      persons[payoutIdx].etherAddress.send(transactionAmount);

      balance -= transactionAmount;
      payoutIdx += 1;
    }
  }

function kill(){
  if(msg.sender == owner) {
  suicide(owner);
  }
  }

  function setOwner(address _owner) onlyowner {
      owner = _owner;
  }
}