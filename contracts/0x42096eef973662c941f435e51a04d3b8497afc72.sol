pragma solidity ^0.4.24;

contract SimpleStorage {
    
    address public owner;
    uint256 public storageValue;
    
    constructor()  public {
        owner = msg.sender;
    }
    
    function setStorage(uint256 _value) {
        storageValue = _value;
    }
}