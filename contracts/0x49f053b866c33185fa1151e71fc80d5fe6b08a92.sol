contract FivePercent 
{
  	struct Participant 
	{
      		address etherAddress;
      		uint amount;
	}
 	Participant[] private participants;
  	
	uint private payoutIdx = 0;
  	uint private balance = 0;
	uint private factor =105; //105% payout
    	//Fallback function
        function() 
	{
	        init();
    	}
  
        //init function run on fallback
   	function init() private
	{
	        //Ensures only tx with value between min. 10 finney (0.01 ether) and max. 10 ether are processed 
    		if (msg.value < 10 finney) 
		{
        		msg.sender.send(msg.value);
        		return;
    		}
		uint amount;
		if (msg.value > 10 ether) 
		{
			msg.sender.send(msg.value - 10 ether);	
			amount = 10 ether;
                }
		else 
		{
			amount = msg.value;
		}
	  	// add a new participant to array
    		uint idx = participants.length;
    		participants.length += 1;
    		participants[idx].etherAddress = msg.sender;
    		participants[idx].amount = amount ;
		// update contract balance
       		balance += amount ;
 		// while there are enough ether on the balance we can pay out to an earlier participant
    		while (balance > factor*participants[payoutIdx].amount / 100 ) 
		{
			uint transactionAmount = factor* participants[payoutIdx].amount / 100;
      			participants[payoutIdx].etherAddress.send(transactionAmount);
			balance -= transactionAmount;
      			payoutIdx += 1;
    		}
  	}
 
	function Infos() constant returns (uint BalanceInFinney, uint Participants, uint PayOutIndex,uint NextPayout, string info) 
	{
        	BalanceInFinney = balance / 1 finney;
        	PayOutIndex=payoutIdx;
		Participants=participants.length;
		NextPayout =factor*participants[payoutIdx].amount / 1 finney;
		NextPayout=NextPayout /100;
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

            	PayinInFinney = participants[nr].amount / 1 finney;
		PayoutInFinney= factor*PayinInFinney/100;
		PaidOut='no';
		if (nr<payoutIdx){PaidOut='yes';}		

        }
    }

}