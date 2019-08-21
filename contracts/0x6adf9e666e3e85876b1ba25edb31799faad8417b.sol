pragma solidity ^0.4.6;
//
// Social Experiment - Finished (or is it... ;)
//
// This contract returns ether (plus bonus) to the "participant" who had contributed 100 ether to "my evil plan"
//
// Status FreeEtherADay:  SUCCESS
// Status HelpMeSave: FAILURE
// Status Free_Ether_A_Day_Funds_Return: TBD......
//
// But is this the end... we'll see. ;)
//
// Watch out for my blog report, will post link via PM to ppl involved
// and here https://www.reddit.com/r/ethtrader/comments/5foa5p/daily_discussion_30nov2016/dalsir4/
// And thanks to everyone who participated. Special mention goes out to /u/WhySoS3rious 
// and to 0xb7b8f253f9Df281EFE9E34F07F598f9817D6eb83
//
// Questions: drether00@gmail.com
//

contract Free_Ether_A_Day_Funds_Return {
   address owner;
   address poorguy = 0xb7b8f253f9Df281EFE9E34F07F598f9817D6eb83;
   
   function Free_Ether_A_Day_Funds_Return() {
        owner = msg.sender;
   }
  
  // send 100 ether, I'll send back 210 ether ;)
  // thats an additional 10 on top of your 100 for the inconvenience.
  //   truuuuuuuust me....... no bugs this time ;---)
  
   function return_funds() payable {

       if (msg.sender != poorguy) throw;
       
       if (msg.value == 100 ether){
             bool success = poorguy.send(210 ether);
             if (!success) throw;
       }
       else throw;
   }
   
   function() payable {}
   
   function kill(){
       if (msg.sender == owner)
           selfdestruct(owner);
   }
}