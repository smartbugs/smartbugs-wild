pragma solidity ^0.4.17;

contract TradingHistoryStorage {
    address public contractOwner;
    address public genesisVisionAdmin;
    string public ipfsHash;

    event NewIpfsHash(string newIpfsHash);
    event NewGenesisVisionAdmin(address newGenesisVisionAdmin);
    
    modifier ownerOnly() {
        require(msg.sender == contractOwner);
        _;
    }

    modifier gvAdminAndOwnerOnly() {
        require(msg.sender == genesisVisionAdmin || msg.sender == contractOwner);
        _;
    }

    constructor() {
        contractOwner = msg.sender;
    }

    function updateIpfsHash(string newIpfsHash) public gvAdminAndOwnerOnly() {
        ipfsHash = newIpfsHash;
        emit NewIpfsHash(ipfsHash);
    }

    function setGenesisVisionAdmin(address newGenesisVisionAdmin) public ownerOnly() {
        genesisVisionAdmin = newGenesisVisionAdmin;
        emit NewGenesisVisionAdmin(genesisVisionAdmin);
    }

}