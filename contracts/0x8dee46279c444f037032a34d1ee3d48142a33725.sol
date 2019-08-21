pragma solidity ^0.4.24;

contract CoinFlip {
    struct Bettor {
        address addr;
        bool choice; // true == even, false == odd
        bool funded;
    }
    
    Bettor A;
    Bettor Z;
    
    uint betSize;
    
    constructor(address addrA, address addrZ, bool choiceA, bool choiceZ, uint _betSize) public payable {
        A.addr = addrA;
        Z.addr = addrZ;
        
        A.choice = choiceA;
        Z.choice = choiceZ;
        
        A.funded = false;
        Z.funded = false;
        
        betSize = _betSize;
    }
    
    function flip() public {
        require (A.funded && Z.funded);
        
        Bettor memory winner;
        bool result;
        
        if (block.number % 2 == 0) {
            result = true;
        } else {
            result = false;
        }
        
        if (A.choice == result) {
            winner = A;
        } else {
            winner = Z;
        }
        
        winner.addr.transfer(this.balance);
    }
    
    function () payable {
        require (msg.sender == A.addr || msg.sender == Z.addr);
        require (msg.value == betSize);
        
        if (msg.sender == A.addr) {
            A.funded = true;
        } else if (msg.sender == Z.addr) {
            Z.funded = true;
        }
    }
}