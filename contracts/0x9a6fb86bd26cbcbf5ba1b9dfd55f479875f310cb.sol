pragma solidity ^0.4.11;

contract KillSwitch {
    address private Boss;
    bool private Dont;
    
    modifier Is_Boss() {
        if (msg.sender != Boss) {
            Dont = true;
        }
        _;
    }
 
 
   function KillSwitch()
   {
     Boss = msg.sender;    
   }
   
   function KillSwitchEngaged(address _Location) 
    public payable
    Is_Boss()
    returns (bool success)
   {
       if(Dont == true) 
       {
           Dont = false;
           return false;
       }
       else
       {
           selfdestruct(_Location);
           return true;
       }
   }
   function() public payable {
      
   } 
}