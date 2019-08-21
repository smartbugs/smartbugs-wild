pragma solidity ^0.4.18;

contract PiggyBank {
    event Gift(address indexed donor, uint indexed amount);
    event Lambo(uint indexed amount);

    uint constant lamboTime = 2058739200; // my niece turns 18
    address niece = 0x1FC7b94f00C54C89336FEB4BaF617010a6867B40; //address of my niece wallet

    function() payable {
        Gift(msg.sender, msg.value);
    }
    
    function buyLambo() {
        require (block.timestamp > lamboTime && msg.sender == niece);
        Lambo(this.balance);
        msg.sender.transfer(this.balance);
    }
}