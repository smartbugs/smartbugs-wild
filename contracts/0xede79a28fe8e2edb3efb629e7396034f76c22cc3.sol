pragma solidity ^0.4.18;

// Free money. No bamboozle.
// By NR
contract FreeMoney {
    
    uint public remaining;
    
    function FreeMoney() public payable {
        remaining += msg.value;
    }
    
    // Feel free to give money to whomever
    function() payable {
        remaining += msg.value;
    }
    
    // You're welcome?!
    function withdraw() public {
        remaining = 0;
        msg.sender.transfer(this.balance);
    }
}