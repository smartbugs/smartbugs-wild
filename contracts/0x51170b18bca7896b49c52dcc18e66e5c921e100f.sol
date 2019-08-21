//====================CRYSTAL DOUBLER
//
// Double your Ether in a short period of time!
//
// Minimum Deposit: 0.5 Ether (500 Finney)
//
// NO FEES!!
//
// Earn ETH Now!
//
//====================START
contract CrystalDoubler {

  struct InvestorArray 
	{
      	address EtherAddress;
      	uint Amount;
  	}

  InvestorArray[] public depositors;

//====================VARIABLES

  uint public Total_Players=0;
  uint public Balance = 0;
  uint public Total_Deposited=0;
  uint public Total_Paid_Out=0;
string public Message="Welcome Player! Double your ETH Now!";
	
  address public owner;

//====================INIT

  function CrystalDoubler() {
    owner = msg.sender;
  }

//====================TRIGGER

  function() {
    enter();
  }
  
//====================ENTER

  function enter() {
    if (msg.value > 500 finney) {

    uint Amount=msg.value;

    // add a new participant to the system and calculate total players
    Total_Players=depositors.length+1;
    depositors.length += 1;
    depositors[depositors.length-1].EtherAddress = msg.sender;
    depositors[depositors.length-1].Amount = Amount;
    Balance += Amount;               		// Balance update
    Total_Deposited+=Amount;       		//update deposited Amount
    uint payout;
    uint nr=0;

    while (Balance > depositors[nr].Amount * 200/100 && nr<Total_Players)
     {
      payout = depositors[nr].Amount *200/100;                           //calculate pay out
      depositors[nr].EtherAddress.send(payout);                        //send pay out to participant
      Balance -= depositors[nr].Amount *200/100;                         //balance update
      Total_Paid_Out += depositors[nr].Amount *200/100;                 //update paid out amount   
      }
      
  }
}
}