pragma solidity ^0.5.8;

contract Registry {
    struct Entry {
        uint64 lenData;
        mapping (uint32=>address) data;
        address owner;
        bool uploaded;
    }
    mapping(uint256=>Entry) public entries;
    uint256 public numEntries = 0;

    function addEntry(uint64 lenData) public returns(uint256) {
        entries[numEntries] = Entry(lenData, msg.sender, false);
        numEntries += 1;
        return numEntries - 1;
    }

    function finalize(uint256 entryId) public {
        require(entries[entryId].owner == msg.sender);
        entries[entryId].uploaded = true;
    }
    
    function storeDataAsContract(bytes memory data) internal returns (address) {
        address result;
        assembly {
            let length := mload(data)
            mstore(data, 0x58600c8038038082843982f3)
            result := create(0, add(data, 20), add(12, length))
        }
        require(result != address(0x0));
        return result;
    }
    
    function addChunk(uint256 entryId, uint32 chunkIndex, bytes memory chunkData) public {
        require(entries[entryId].owner == msg.sender);
        entries[entryId].data[chunkIndex] = storeDataAsContract(chunkData);
    }

    function get(uint256 entryId, uint32 chunkIndex) public view returns(bytes memory result) {
        require(entries[entryId].uploaded);
        address _addr = entries[entryId].data[chunkIndex];
        assembly {
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(_addr)
            // allocate output byte array - this could also be done without assembly
            // by using o_code = new bytes(size)
            result := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(result, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(result, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(_addr, add(result, 0x20), 0, size)            
        }
    }

    function getLen(uint256 entry) public view returns(uint64 length) {
        return entries[entry].lenData;
    }
}