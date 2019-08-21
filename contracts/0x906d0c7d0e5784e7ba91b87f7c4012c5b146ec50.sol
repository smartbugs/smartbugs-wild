pragma solidity ^0.4.18;
contract TimeStampingAuthority {
    
    struct Entry {
        address sender;
        uint timestamp;
        string note;
    }

    mapping(bytes => Entry) entries;
    
    function submitEntry(bytes _hash, string note) public {
        require(entries[_hash].timestamp == 0);
        entries[_hash] = Entry(msg.sender, now, note);
    }
    
    function getEntry(bytes _hash) public constant returns (address, uint, string) {
        return (entries[_hash].sender, entries[_hash].timestamp, entries[_hash].note);
    }
}