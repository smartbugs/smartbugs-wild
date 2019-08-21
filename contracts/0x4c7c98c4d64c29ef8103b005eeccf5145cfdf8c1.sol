//
// Licensed under the Apache License, version 2.0.
//
pragma solidity ^0.4.17;

contract Ownable {
    address public Owner;
    
    function Ownable() { Owner = msg.sender; }
    function isOwner() internal constant returns (bool) { return(Owner == msg.sender); }
}

contract Savings is Ownable {
    address public Owner;
    mapping (address => uint) public deposits;
    uint public openDate;
    
    event Initialized(address indexed Owner, uint OpenDate);
    event Deposit(address indexed Depositor, uint Amount);
    event Withdrawal(address indexed Withdrawer, uint Amount);
    
    function init(uint open) payable {
        Owner = msg.sender;
        openDate = open;
        Initialized(Owner, open);
    }

    function() payable { deposit(); }
    
    function deposit() payable {
        if (msg.value >= 1 ether) {
            deposits[msg.sender] += msg.value;
            Deposit(msg.sender, msg.value);
        }
    }
    
    function withdraw(uint amount) payable {
        if (isOwner() && now >= openDate) {
            uint max = deposits[msg.sender];
            if (amount <= max && max > 0) {
                msg.sender.transfer(amount);
            }
        }
    }

    function kill() payable {
        if (isOwner() && this.balance == 0) {
            selfdestruct(msg.sender);
        }
	}
}