pragma solidity ^0.4.15;

contract Directory {
    struct Entry {
        string name;
        string company;
        string description;
        string category;
        string contact;
        address ethAddress;
        uint256 timestamp;
        bool deprecated;
    }

    mapping(address => Entry) public directory;
    Entry[] public entries;

    address public owner;

    function Directory() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier indexMatches(uint256 index, address ethAddress) {
        require(entries[index].ethAddress == ethAddress);
        _;
    }

    function transferOwner(address _owner) onlyOwner public returns (bool) {
        owner = _owner;
        return true;
    }

    function addEntry(string name, string company, string description, string category, string contact, address ethAddress) onlyOwner public returns (bool) {
        require(directory[ethAddress].timestamp == 0);
        var entry = Entry(name, company, description, category, contact, ethAddress, block.timestamp, false);
        directory[ethAddress] = entry;
        entries.push(entry);
        return true;
    }

    function findCurrentIndex(address ethAddress) public constant returns (uint256) {
        for (uint i = 0; i < entries.length; i++) {
            if (entries[i].ethAddress == ethAddress) {
                return i;
            }
        }
        revert();
    }

    function removeEntry(address ethAddress) public returns (bool) {
        return removeEntryManual(findCurrentIndex(ethAddress), ethAddress);
    }

    function removeEntryManual(uint256 index, address ethAddress) onlyOwner indexMatches(index, ethAddress) public returns (bool) {
        uint256 lastIndex = entries.length - 1;
        entries[index] = entries[lastIndex];
        delete entries[lastIndex];
        delete directory[ethAddress];
        return true;
    }

    function modifyDescription(address ethAddress, string description) public returns (bool) {
        return modifyDescriptionManual(findCurrentIndex(ethAddress), ethAddress, description);
    }

    function modifyDescriptionManual(uint256 index, address ethAddress, string description) onlyOwner indexMatches(index, ethAddress) public returns (bool) {
        entries[index].description = description;
        directory[ethAddress].description = description;
        return true;
    }

    function modifyContact(address ethAddress, string contact) public returns (bool) {
        return modifyDescriptionManual(findCurrentIndex(ethAddress), ethAddress, contact);
    }

    function modifyContactManual(uint256 index, address ethAddress, string contact) onlyOwner indexMatches(index, ethAddress) public returns (bool) {
        entries[index].contact = contact;
        directory[ethAddress].contact = contact;
        return true;
    }

    function setDeprecated(address ethAddress, bool deprecated) public returns (bool) {
        return setDeprecatedManual(findCurrentIndex(ethAddress), ethAddress, deprecated);
    }

    function setDeprecatedManual(uint256 index, address ethAddress, bool deprecated) onlyOwner indexMatches(index, ethAddress) public returns (bool) {
        entries[index].deprecated = deprecated;
        directory[ethAddress].deprecated = deprecated;
        return true;
    }

    function getName(address _address) public constant returns (string) { return directory[_address].name; }
    function getCompany(address _address) public constant returns (string) { return directory[_address].company; }
    function getDescription(address _address) public constant returns (string) { return directory[_address].description; }
    function getCategory(address _address) public constant returns (string) { return directory[_address].category; }
    function getTimestamp(address _address) public constant returns (uint256) { return directory[_address].timestamp; }
    function isDeprecated(address _address) public constant returns (bool) { return directory[_address].deprecated; }

    function getNameHash(address _address) public constant returns (bytes32) { return keccak256(directory[_address].name); }
    function getCompanyHash(address _address) public constant returns (bytes32) { return keccak256(directory[_address].company); }
    function getDescriptionHash(address _address) public constant returns (bytes32) { return keccak256(directory[_address].description);}
    function getCategoryHash(address _address) public constant returns (bytes32) { return keccak256(directory[_address].category); }
}