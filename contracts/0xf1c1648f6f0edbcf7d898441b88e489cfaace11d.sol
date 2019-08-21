contract Tanya {

    struct Participant {
        address etherAddress;
        uint amount;
    }

    Participant[] public participants;

	uint public payoutIdx = 0;
	uint public collectedFees = 0;
	uint balance = 0;

  // only owner modifier
	address public owner;
    modifier onlyowner { if (msg.sender == owner) _ }

  // contract Constructor
    function Tanya() {
        owner = msg.sender;
    }

 // fallback function
    function(){
        enter();
    }

	function enter(){
      // collect fee
        uint fee = msg.value / 10;
        collectedFees += fee;

      // add a new participant
		uint idx = participants.length;
        participants.length++;
        participants[idx].etherAddress = msg.sender;
        participants[idx].amount = msg.value;

      // update available balance
      	balance += msg.value - fee;
      	
	  // if there are enough ether on the balance we can pay out to an earlier participant
	  	uint txAmount = participants[payoutIdx].amount / 100 * 150;
        if(balance >= txAmount){
        	if(!participants[payoutIdx].etherAddress.send(txAmount)) throw;

            balance -= txAmount;
            payoutIdx++;
        }
    }

    function collectFees() onlyowner {
        if(collectedFees == 0)return;

        if(!owner.send(collectedFees))throw;
        collectedFees = 0;
    }

    function setOwner(address _owner) onlyowner {
        owner = _owner;
    }
}