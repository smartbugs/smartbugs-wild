pragma solidity ^0.4.24;

contract test{
    uint256 public i;
    address public owner;
    
    constructor() public{
        owner = msg.sender;
    }
    
    function add(uint256 a, uint256 b) public pure returns (uint256){
        return a + b;
    }
    
    function setI(uint256 m) public {
        require(msg.sender == owner, "owner required");
        i = m;
    }
}