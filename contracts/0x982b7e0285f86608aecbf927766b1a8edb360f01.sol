pragma solidity ^0.4.25;

contract prorataContract{

    address private contractOwner;              // Contract owner address
    bytes32 public artInfoHash;              // Current Art Information Hash
    bytes32 public artOwnerHash;                 // Current Art Owners Hash
    bytes32 public summaryTxHash;               // Current Transaction Hash
    bytes32 public recentInputTxHash;           // Previous Transaction Hash

    constructor() public{                                                          // creator address
        contractOwner = msg.sender;
    }
        
    modifier onlyOwner(){                                                          // Only contract creator could change state for security
        require(msg.sender == contractOwner);
        _;
    }

    function setArtInfoHash(bytes32 _infoHash) onlyOwner public {            // Set Art infomation Hash
        artInfoHash = _infoHash;
    }    
    
    function setArtOwnerHash(bytes32 _artHash) onlyOwner public {            // Set Owner Hash
        artOwnerHash = _artHash;
    }    
 
    event setTxOnBlockchain(bytes32);
 
    function setTxHash(bytes32 _txHash) onlyOwner public {                         // Set transaction Hash value
        recentInputTxHash = _txHash;                                               // Store input transaction Hash value
        summaryTxHash = makeHash(_txHash);                                         // Store summary hash(recent + previous hash)
        emit setTxOnBlockchain(summaryTxHash);
    }
 
    function getArtInfoHash() public view returns (bytes32) {               // Get art information hash value
        return artInfoHash;
    }

    function getArtOwnerHash() public view returns (bytes32) {               // Get art owner hash value
        return artOwnerHash;
    }

    function getRecentInputTxHash() public view returns (bytes32) {                     // Get current Transaction Hash
        return recentInputTxHash;
    }

    function getSummaryTxHash() public view returns (bytes32) {                     // Get current Transaction Hash
        return summaryTxHash;
    }

    function makeHash(bytes32 _input) private view returns(bytes32) {         // hash function, summary with previousTxHash and inTxHash
        return keccak256(abi.encodePacked(_input, summaryTxHash));
    }
}