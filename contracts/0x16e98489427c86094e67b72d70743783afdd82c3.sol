pragma solidity ^0.4.18;
//Copyright 2018 MiningRigRentals.com
contract ClientReceipt {
    event Deposit(address indexed _to, bytes32 indexed _id, uint _value);
    address public owner;
    function ClientReceipt() {
        owner = msg.sender;
    }
    function deposit(bytes32 _id) public payable {
        Deposit(this, _id, msg.value);
        if(msg.value > 0) {
            owner.transfer(msg.value);
        }
    }
    function () public payable { 
        Deposit(this, 0, msg.value);
        if(msg.value > 0) {
            owner.transfer(msg.value);
        }
    }
}