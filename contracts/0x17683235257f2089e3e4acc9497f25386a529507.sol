//
//  Custom Wallet Contract that forces me to save, until i have reached my goal
//  and prevents me from withdrawing my funds before I have reached my personal goal
//
//  Motivation is to stop my bad trading habbits to sell ether everytime the price drops...
//  :D :D
//
//  This contract is Public Domain, please feel free to copy / modify
//  Questions/Comments/Feedback welcome: drether00@gmail.com
//
pragma solidity ^0.4.5;

contract HelpMeSave { 
   
   address public me;    // me, only I can interact with this contract
   uint256 public savings_goal; // how much I want to save
   
   // Constructor / Initialize (only runs at contract creation)
   function MyTestWallet7(){
       me = msg.sender;   // store owner, so only I can withdraw
       set_savings_goal(1000 ether);
   }
   
   // set new savings goal if I want to, once I have reached my goal
   function set_savings_goal(uint256 new_goal) noone_else { 
       if (this.balance >= savings_goal) savings_goal = new_goal;
   }
   
   // these functions I can use to deposit money into this account
    function deposit() public payable {} //
    function() payable {deposit();} //
    
    // Only I can use this once I have reached my goal   
    function withdraw () public noone_else { 

         uint256 withdraw_amt = this.balance;
         
         if (msg.sender != me || withdraw_amt < savings_goal ){ // someone else tries to withdraw, NONONO!!!
             withdraw_amt = 0;                     // or target savings not reached
         }

         if (!msg.sender.send(withdraw_amt)) throw; // everything ok, send it back to me

   }

    // This modifier stops anyone else from using this contract
    modifier noone_else() { // most functions can only be used by original creator
        if (msg.sender == me) 
            _;
    }

    // Killing of contract only possible with password (--> large number, give to nextofkin/solicitor)
    function recovery (uint256 _password) noone_else {
       //calculate a hash from the password, and if it matches, return to contract owner
       if ( uint256(sha3(_password)) % 10000000000000000000 == 49409376313952921 ){
                selfdestruct (me);
       } else throw;
    }
}