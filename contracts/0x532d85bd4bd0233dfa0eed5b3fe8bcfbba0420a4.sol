pragma solidity ^0.5.1;

// Author: SilentCicero @IAmNickDodson
contract MerklIO {
    address public owner = msg.sender;
    mapping(bytes32 => uint256) public hashToTimestamp; // hash => block timestamp
    mapping(bytes32 => uint256) public hashToNumber; // hash => block number
    
    event Hashed(bytes32 indexed hash);
    
    function store(bytes32 hash) external {
         // owner is merklio
        assert(msg.sender == owner);
        
        // hash has not been set
        assert(hashToTimestamp[hash] <= 0);
    
        // set hash to timestamp and blocknumber
        hashToTimestamp[hash] = block.timestamp;
        hashToNumber[hash] = block.number;
        
        // emit log for tracking
        emit Hashed(hash);
    }
    
    function changeOwner(address ownerNew) external {
        // sender is owner
        assert(msg.sender == owner);
        
        // set new owner
        owner = ownerNew;
    }
}