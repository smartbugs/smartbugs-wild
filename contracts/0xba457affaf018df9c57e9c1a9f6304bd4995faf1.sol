pragma solidity ^0.5.9;

contract Registry {
    struct ContractVersion {
        string name;
        address contractAddress;
    }

    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only the contract owner is allowed to use this function."
        );
        _;
    }

    address owner;

    ContractVersion[] versions;

    constructor() public {
        owner = msg.sender;
    }

    function addVersion(string calldata versionName, address contractAddress)
        external
        onlyOwner
    {
        ContractVersion memory newVersion = ContractVersion(
            versionName,
            contractAddress
        );
        versions.push(newVersion);
    }

    function getNumberOfVersions() public view returns (uint size) {
        return versions.length;
    }

    function getVersion(uint i)
        public
        view
        returns (string memory versionName, address contractAddress)
    {
        require(i >= 0 && i < versions.length, "Index is out of bounds");
        ContractVersion memory version = versions[i];
        return (version.name, version.contractAddress);
    }

}