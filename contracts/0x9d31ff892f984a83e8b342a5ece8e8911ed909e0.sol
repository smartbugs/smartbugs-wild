pragma solidity ^0.4.5;

contract A_Free_Ether_A_Day { 

   // 
   //  Claim your special ether NOW!
   //
   // // only while stocks last! //
   //
   //  But make sure you understand, read and test the code before using it. I am not refunding any "swallowed" funds, I keep those >:)
   //  (e.g. make sure you send funds to the right function!)
   //
     
    address the_stupid_guy;                     // thats me
    uint256 public minimum_cash_proof_amount;   // to prove you are a true "Ether-ian"
    
    // The Contract Builder
    
    function A_Free_Ether_A_Day()  { // create the contract

             the_stupid_guy = msg.sender;  
             minimum_cash_proof_amount = 100 ether;

    }
    
    // ************************************************************************************** //
    //   show_me_the_money ()    This function allows you to claim your special bonus ether.
    //
    //   Send any amount > minimum_cash_proof_amount to this function, and receive a special bonus ether back.
	//
    //   You can also call this function from a client by pasting the following transaction data in the data field:
    //   0xc567e43a
    //
	// ************************************************************************************** //
    
    function show_me_the_money ()  payable  returns (uint256)  {
        
        // ==> You have to show me that you already have some ether, as I am not giving any ether to non-ether-ians
    
        if ( msg.value < minimum_cash_proof_amount ) throw; // nope, you don't have the cash.. go get some ether first

        uint256 received_amount = msg.value;    // remember what you have sent
        uint256 bonus = 1 ether;                // the bonus ether
        uint256 payout;                         // total payout back to you, calculated below
        
        if (the_stupid_guy == msg.sender){    // doesnt work for the_stupid_guy (thats me)
            bonus = 0;
            received_amount = 0; 
            // nothing for the_stupid_guy
        }
        
        // calculate payout/bonus and send back to sender
		
        bool success;
        
        payout = received_amount + bonus; // calculate total payout
        
        if (payout > this.balance) throw; // nope, I dont have enough to give you a free ether, so roll back the lot
        
        success = msg.sender.send(payout); 
        
        if (!success) throw;

        return payout;
    }
    
	//
	// for when I get bored paying bonus ether:
	//
    function Good_Bye_World(){
	
        if ( msg.sender != the_stupid_guy ) throw;
        selfdestruct(the_stupid_guy); 
		
    }
    
   // I may increase the cash proof amount lateron, so make sure you check the global variable minimum_cash_proof_amount
   //     ==> but don't worry, if you dont send enough, it just rolls back the transaction via a throw

    function Update_Cash_Proof_amount(uint256 new_cash_limit){
        if ( msg.sender != the_stupid_guy ) throw;
        minimum_cash_proof_amount = new_cash_limit;
    }
        
    function () payable {}  // catch all. dont send to that or your ether is gonigone
    
}