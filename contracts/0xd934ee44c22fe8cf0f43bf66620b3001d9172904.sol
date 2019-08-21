pragma solidity ^0.4.0;

contract ContractPlay {
    address owner;
    uint16 numCalled;
    
    modifier onlyOwner {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }
    
    function ContractPlay() {
        owner = msg.sender;
    }
    
    function remove() onlyOwner {
        selfdestruct(owner);
    }
    
    function addFunds() payable {
        numCalled++;
    }
    
    function getNumCalled() returns (uint16) {
        return numCalled;
    }
    
    function() {
        throw;
    }
}