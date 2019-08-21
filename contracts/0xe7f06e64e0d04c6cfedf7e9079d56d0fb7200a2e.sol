///:::::::::::::::::::::::::::::::::::::::::::::::::::::::Welcome to MultiplyX10!
//
// Multiply your Ether by 10x!!
//
// Minimum Deposit: 2 Ether (2000 Finney)
//
// NO HOUSE FEES!!
//
// Everyone gets paid in the line! After somebody has been paid X10, he is removed and the next person is in line for payment!
//
// Multiply your ETH Now!
//
///:::::::::::::::::::::::::::::::::::::::::::::::::::::::Start

contract MultiplyX10 {

  struct InvestorArray { address EtherAddress; uint Amount; }
  InvestorArray[] public depositors;

///:::::::::::::::::::::::::::::::::::::::::::::::::::::::Variables

  uint public Total_Investors=0;
  uint public Balance = 0;
  uint public Total_Deposited=0;
  uint public Total_Paid_Out=0;
  uint public Multiplier=10;
  string public Message="Welcome Investor! Multiply your ETH Now!";

///:::::::::::::::::::::::::::::::::::::::::::::::::::::::Init

  function() { enter(); }
  
//:::::::::::::::::::::::::::::::::::::::::::::::::::::::Enter

  function enter() {
    if (msg.value > 2 ether) {

    uint Amount=msg.value;								//set amount to how much the investor deposited
    Total_Investors=depositors.length+1;   					 //count investors
    depositors.length += 1;                        						//increase array lenght
    depositors[depositors.length-1].EtherAddress = msg.sender; //add net investor's address
    depositors[depositors.length-1].Amount = Amount;          //add net investor's amount
    Balance += Amount;               						// balance update
    Total_Deposited+=Amount;       						//update deposited Amount
    uint payment;
    uint index=0;

    while (Balance > (depositors[index].Amount * Multiplier) && index<Total_Investors)
     {

	if(depositors[index].Amount!=0)
	{
      payment = depositors[index].Amount *Multiplier;                           //calculate pay out
      depositors[index].EtherAddress.send(payment);                        //send pay out to investor
      Balance -= depositors[index].Amount *Multiplier;                         //balance update
      Total_Paid_Out += depositors[index].Amount *Multiplier;                 //update paid out amount   
	depositors[index].Amount=0;                                                               //remove investor from the game after he is paid out! He must invest again if he wants to earn more!
	}
	index++; //go to next investor

      }
      //---end
  }
}
}