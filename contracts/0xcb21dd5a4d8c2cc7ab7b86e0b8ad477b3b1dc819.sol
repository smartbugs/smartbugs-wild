pragma solidity ^0.5.0;


contract SafeCreativeAudit {

    address public owner;

    struct Record {
        uint mineTime;
        uint blockNumber;
    }
    
    mapping (bytes32 => Record) private docHashes;
    
    modifier ownerOnly {
        require(owner == msg.sender, "Unauthorized: only owner");
        _;   // <--- note the '_', which represents the modified function's body
    }

    constructor() public {
        owner = msg.sender;
    }

    function addDocHash(bytes32 hash) public ownerOnly {
        Record memory newRecord = Record(block.timestamp, block.number);
        docHashes[hash] = newRecord;
    }

    function findDocHash(bytes32 hash) public view returns(uint, uint) {
        return (docHashes[hash].mineTime, docHashes[hash].blockNumber);
    }

    function changeOwner(address newOwner) public ownerOnly{
        owner = newOwner;
    }


}