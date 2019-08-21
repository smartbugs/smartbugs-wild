pragma solidity ^0.4.19;

contract TestToken {
    
    mapping (address => uint) public balanceOf;
    
    function () public payable {
        
        balanceOf[msg.sender] = msg.value;
        
    }
    
}