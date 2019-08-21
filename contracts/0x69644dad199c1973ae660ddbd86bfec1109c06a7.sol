pragma solidity ^0.4.8;
contract Switch 
{
    uint256 public blink_block;
    uint256 public on_block;
    address public owner;

    function Switch(){
        owner=msg.sender;
        on_block=block.number;
        blink_block=block.number;
    }
    function blink() payable {
        if(msg.value>0)blink_block=block.number;
    }
    function () payable {
        if(msg.value>0)on_block=block.number;
    }
    function kill() {
    if (msg.sender==owner) selfdestruct(owner);
    }
}