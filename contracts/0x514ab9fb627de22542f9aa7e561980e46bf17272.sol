pragma solidity ^0.4.8;

contract wallet {
    address owner;
    function wallet() {
        owner = msg.sender;
    }
    function transfer(address target) payable {
        target.send(msg.value);
    }
    function kill() {
        if (msg.sender == owner) {
            suicide(owner);
        } else {
            throw;
        }
    }
}