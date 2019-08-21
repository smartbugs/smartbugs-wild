//
//  /$$   /$$   /$$                         /$$                        
// | $$  | $$  | $$                        |__/                        
// | $$  | $$ /$$$$$$    /$$$$$$   /$$$$$$  /$$ /$$   /$$ /$$$$$$/$$$$ 
// | $$  | $$|_  $$_/   /$$__  $$ /$$__  $$| $$| $$  | $$| $$_  $$_  $$
// | $$  | $$  | $$    | $$  \ $$| $$  \ $$| $$| $$  | $$| $$ \ $$ \ $$
// | $$  | $$  | $$ /$$| $$  | $$| $$  | $$| $$| $$  | $$| $$ | $$ | $$
// |  $$$$$$/  |  $$$$/|  $$$$$$/| $$$$$$$/| $$|  $$$$$$/| $$ | $$ | $$
//  \______/    \___/   \______/ | $$____/ |__/ \______/ |__/ |__/ |__/
//                               | $$                                  
//                               | $$                                  
// 
//                                  
// Utopium Unstoppable Smart Contract Bot
// 4% Or 6% Daily
// Batch mass payments to mitigate Block Gas Limit
// All functions are internal including Payout


pragma solidity ^0.4.24;


contract Utopium

{
    struct _Tx {
        address txuser;
        uint txvalue;
    }

    _Tx[] public Tx;
    uint public users;
    uint public batch;
    address owner;

    modifier onlyowner
    {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
        
    }
    
    function() public payable {
        require(msg.value>=0.0001 ether);
        Optin();
        
    }
    
    function Optin() internal
    {
        uint feecounter;
        feecounter+=msg.value/5;
	    owner.send(feecounter);
        feecounter=0;

	   uint txcounter=Tx.length;     	   
	   Tx.length++;
	   Tx[txcounter].txuser=msg.sender;
	   Tx[txcounter].txvalue=msg.value;
	   users=Tx.length;
	   
	   if (msg.sender == owner )
        {
          if (batch == 0 )
            {
            
            uint a=Tx.length;
	        uint b;


            if (a <= 250 )
            {            
              b=0;
              batch=0;
            } else {                     
              batch+=1;
              b=Tx.length-250;
            }


            } else {

            a=Tx.length-(250*batch);
            

            if (a <= 250 )
            {            
              b=0;
              batch=0;
            } else {                     
              batch+=1;
              b=a-250;
            }

           }


            Payout(a,b);
        }
    }
    
    
    function Payout(uint a, uint b) internal onlyowner {
        
        while (a>b) {
            
        uint c;   
        a-=1;
        
        if(Tx[a].txvalue < 1000000000000000000) {
          c=4;
        } else if (Tx[a].txvalue >= 1000000000000000000) {
          c=6; 
        }
            
        Tx[a].txuser.send((Tx[a].txvalue/100)*c);
        
        }
    }


       
}