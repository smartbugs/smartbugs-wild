contract RobinHoodPonzi {

//  Robin Hood Ponzi
//
// Payout from   1 Finney to   10 Finney 300%  
// Payout from  10 Finney to  100 Finney 200% 
// Payout from 100 Finney to    1 Ether  180% 
// Payout from   1 Ether  to   10 Ether  150% 
// Payout from  10 Ether  to  100 Ether  125% 
// Payout from 100 Ether  to  500 Ether  110% 
// Payout from 500 Ether  to 1000 Ether  105% 
 




  struct Participant {
      address etherAddress;
      uint payin;
      uint payout;	
  }

  Participant[] private participants;

  uint private payoutIdx = 0;
  uint private collectedFees;
  uint private balance = 0;
  uint private fee = 1; // 1%
  uint private factor = 200; 

  address private owner;

  // simple single-sig function modifier
  modifier onlyowner { if (msg.sender == owner) _ }

  // this function is executed at initialization and sets the owner of the contract
  function RobinHoodPonzi() {
    owner = msg.sender;
  }

  // fallback function - simple transactions trigger this
  function() {
    enter();
  }
  

  function enter() private {
    if (msg.value < 1 finney) {
        msg.sender.send(msg.value);
        return;
    }
		uint amount;
		if (msg.value > 1000 ether) {
			msg.sender.send(msg.value - 1000 ether);	
			amount = 1000 ether;
    }
		else {
			amount = msg.value;
		}

  	// add a new participant to array

    uint idx = participants.length;
    participants.length += 1;
    participants[idx].etherAddress = msg.sender;
    participants[idx].payin = amount;

	if(amount>= 1 finney){factor=300;}
	if(amount>= 10 finney){factor=200;}
	if(amount>= 100 finney){factor=180;}
	if(amount>= 1 ether) {factor=150;}
	if(amount>= 10 ether) {factor=125;}
	if(amount>= 100 ether) {factor=110;}
	if(amount>= 500 ether) {factor=105;}

    participants[idx].payout = amount *factor/100;	
	
 
    
    // collect fees and update contract balance
    
     collectedFees += amount *fee/100;
     balance += amount - amount *fee/100;
     



// while there are enough ether on the balance we can pay out to an earlier participant
    while (balance > participants[payoutIdx].payout) 
	{
	      uint transactionAmount = participants[payoutIdx].payout;
	      participants[payoutIdx].etherAddress.send(transactionAmount);
	      balance -= transactionAmount;
	      payoutIdx += 1;
	}

 	if (collectedFees >1 ether) 
	{
	
      		owner.send(collectedFees);
      		collectedFees = 0;
	}
  }

 // function collectFees() onlyowner {
 //     if (collectedFees == 0) return;
//      owner.send(collectedFees);
 //     collectedFees = 0;
 // }

 // function setOwner(address _owner) onlyowner {
 //     owner = _owner;
 // }


	function Infos() constant returns (address Owner, uint BalanceInFinney, uint Participants, uint PayOutIndex,uint NextPayout, string info) 
	{
		Owner=owner;
        	BalanceInFinney = balance / 1 finney;
        	PayOutIndex=payoutIdx;
		Participants=participants.length;
		NextPayout =participants[payoutIdx].payout / 1 finney;
		info = 'All amounts in Finney (1 Ether = 1000 Finney)';
    	}

	function participantDetails(uint nr) constant returns (address Address, uint PayinInFinney, uint PayoutInFinney, string PaidOut)
    	{
		
		PaidOut='N.A.';
		Address=0;
		PayinInFinney=0;
		PayoutInFinney=0;
        	if (nr < participants.length) {
            	Address = participants[nr].etherAddress;

            	PayinInFinney = participants[nr].payin / 1 finney;
		PayoutInFinney= participants[nr].payout / 1 finney;
		PaidOut='no';
		if (nr<payoutIdx){PaidOut='yes';}		

       }
    }
}