pragma solidity 0.4.24;


contract AddressrResolver {

    address public addr;
    
    address owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
    
    function changeOwner(address newowner) external onlyOwner {
        owner = newowner;
    }
    
    function setAddr(address newaddr) external onlyOwner {
        addr = newaddr;
    }
    
}