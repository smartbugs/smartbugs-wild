pragma solidity ^0.4.0;
contract WyoMesh {

    struct Device {
        string name;
        bool permissioned;
        // last TX hash?
        //more meta data
    }
    struct IPFS_Hash {
        string ipfs_hash;
        bool auditor_signed; //
    }

    // need a store of the last *transaction* that a device successfully submitted - so you get a list you can scan back in the contrac twith latest -> latest -1 -> ... original.

    address public auditor;
    mapping(address => Device) private devices;
    IPFS_Hash[] ipfs_hashes;
    uint hash_index;

    /// Create a new Master and auditor with $(_maxHashes) different ipfs_hashes.
    constructor(uint8 _maxHashes) public {
        auditor = msg.sender;
        ipfs_hashes.length = _maxHashes;
        devices[msg.sender].permissioned = true;
        hash_index = 0;
    }

    /// Give $(toDevice) the right to add data on this contract
    /// May only be called by $(auditor).
    function addDevice(address toDevice) public returns(bool){
        if (msg.sender != auditor) return false;
        devices[toDevice].permissioned = true;
        return true;
    }


    /// Submit an IPFS_Hash
    function submitHash(string newIPFS_Hash) public returns(bool){
        if(!devices[msg.sender].permissioned || hash_index >= ipfs_hashes.length-1) return false;
        ipfs_hashes[hash_index].ipfs_hash = newIPFS_Hash;
        hash_index++;
        return true;
    }

    /// Get a submited IPFS_Hash
    function getHash(uint8 index_) public returns(string){
        return ipfs_hashes[index_].ipfs_hash;
    }

    /// Sign-off on event as a known auditor
    function signAudit(uint8 index_) public returns(bool){
      if(msg.sender != auditor) return false;
        ipfs_hashes[index_].auditor_signed = true;
        return true;
    }
}