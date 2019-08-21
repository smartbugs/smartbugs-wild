pragma solidity ^0.4.0;

contract CarelessWhisper {
    address owner;
    event Greeting(bytes data);
    
    constructor() public {
        owner = msg.sender;
    }

    function greeting(bytes data) public {
    }
    
    function kill() public {
        require (msg.sender == owner);
        selfdestruct(msg.sender);
    }
}