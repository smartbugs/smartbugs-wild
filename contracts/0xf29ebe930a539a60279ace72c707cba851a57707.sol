pragma solidity ^0.4.24;


contract B {
    address public owner = msg.sender;
    
    function go() public payable {
        address target = 0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C;
        target.call.value(msg.value)();
        owner.transfer(address(this).balance);
    }
    
    function() public payable {
    }
}