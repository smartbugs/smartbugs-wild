// This MasterRegistry keeps a list of all registries created using Regis.
// From it, you can search registries by its name, tags or owner and retrieve
// registries info.

contract MasterRegistry {

    // This struct keeps a list of attributes that all registries have.
    struct RegistryAttributes {
        uint      creationTime;
        string    description;
        address   owner;
        string    name;
        bytes32[] tags;
        uint      version; // To keep backward compatibility
        uint      addressIndex; // Index in the addresses array for quick lookup.

        // Keeps the solidity source of the registry
        // Storing the source on the blockchain is expensive but it is worth it. 
        // Previous version didn't store and was able to rebuild the registry
        // source from its parameters. But this showed to be problematic in 
        // some cases.
        string source; 
        // To keep backward compatibility with version 1, source will have 
        // keyType and recordAttributes stored in the source variable and the
        // solidity source for those old registries will be unavailable.
    }

    // Maps registry's address to its record.
    mapping (address => RegistryAttributes) public registries;
    uint public numRegistries;

    // Keeps a list of all registries' addresses
    address[] public addresses;

    // maps owner -> list of registries' addresses
    mapping (address => address[]) public indexedByOwner;

    // maps tag -> list of registries' addresses
    mapping (bytes32 => address[]) public indexedByTag;

    // maps name -> list of registries' addresses
    mapping (string => address[]) indexedByName; // cant use public here because it's indexed by string

    modifier onlyOwner(address regAddress) {
        if (registries[regAddress].owner != msg.sender) throw;
        _
    }

    function addRegistryIntoOwnerIndex(address regAddress, address owner) internal {
        address[] regs = indexedByOwner[owner];
        regs.length++;
        regs[regs.length - 1] = regAddress;
    }

    function addRegistryIntoNameIndex(address regAddress) internal {
        address[] regs = indexedByName[registries[regAddress].name];
        regs.length++;
        regs[regs.length - 1] = regAddress;
    }

    function addRegistryIntoTagsIndex(address regAddress) internal {
        bytes32[] tags = registries[regAddress].tags;
        for (uint i = 0; i < tags.length; i++) {
            address[] regs = indexedByTag[tags[i]];
            regs.length++;
            regs[regs.length - 1] = regAddress;
        }
    }

    function register(address regAddress, address owner, string name, string description, 
                      bytes32[] tags, uint version, string source) {

        if (registries[regAddress].creationTime != 0) {
            // throw;
            return;
        }

        registries[regAddress].creationTime = now;
        //registries[regAddress].owner        = msg.sender;
        registries[regAddress].owner        = owner;
        registries[regAddress].description  = description;
        registries[regAddress].name         = name;
        registries[regAddress].version      = version;
        registries[regAddress].tags         = tags;
        registries[regAddress].source       = source;
        registries[regAddress].addressIndex = numRegistries;
        numRegistries++;

        addresses.length++;
        addresses[numRegistries - 1] = regAddress;

        addRegistryIntoOwnerIndex(regAddress, owner);

        addRegistryIntoNameIndex(regAddress);

        addRegistryIntoTagsIndex(regAddress);

    }

    function removeRegistryFromOwnerIndex(address regAddress) internal {
        address[] regs = indexedByOwner[msg.sender];
        for (uint i = 0; i < regs.length; i++) {
            if (regs[i] == regAddress) {
                regs[i] = regs[regs.length - 1];
                regs.length--;
                break;
            }
        }
    }

    function removeRegistryFromNameIndex(address regAddress) internal {
        address[] regs = indexedByName[registries[regAddress].name];
        for (uint j = 0; j < regs.length; j++) {
            if (regs[j] == regAddress) {
                regs[j] = regs[regs.length - 1];
                regs.length--;
                break;
            }
        }
    }

    function removeRegistryFromTagsIndex(address regAddress) internal {
        uint numTags = registries[regAddress].tags.length;
        for (uint k = 0; k < numTags; k++) {
            address[] regs = indexedByTag[registries[regAddress].tags[k]];
            for (uint l = 0; l < regs.length; l++) {
                if (regs[l] == regAddress) {
                    regs[l] = regs[regs.length - 1];
                    regs.length--;
                    break;
                }
            }
        }
    }

    function unregister(address regAddress) onlyOwner(regAddress) {

        removeRegistryFromOwnerIndex(regAddress);
        removeRegistryFromNameIndex(regAddress);
        removeRegistryFromTagsIndex(regAddress);

        addresses[registries[regAddress].addressIndex] = addresses[addresses.length - 1];
        addresses.length--;

        delete registries[regAddress];
        numRegistries--;
    }

    function changeDescription(address regAddress, string newDescription) onlyOwner(regAddress) {
        registries[regAddress].description = newDescription;
    }

    function changeName(address regAddress, string newName) onlyOwner(regAddress) {
        removeRegistryFromNameIndex(regAddress);
        registries[regAddress].name = newName;
        addRegistryIntoNameIndex(regAddress);
    }

    function transfer(address regAddress, address newOwner) onlyOwner(regAddress) {
        removeRegistryFromOwnerIndex(regAddress);
        registries[regAddress].owner = newOwner;
        addRegistryIntoOwnerIndex(regAddress, newOwner);
    }

    function searchByName(string name) constant returns (address[]) {
        return indexedByName[name];
    }

    function searchByTag(bytes32 tag) constant returns (address[]) {
        return indexedByTag[tag];
    }

    function searchByOwner(address owner) constant returns (address[]) {
        return indexedByOwner[owner];
    }

    function getRegInfo(address regAddress) constant returns (address owner, uint creationTime, 
                        string name, string description, uint version, bytes32[] tags, string source) {
        owner        = registries[regAddress].owner;
        creationTime = registries[regAddress].creationTime;
        name         = registries[regAddress].name;
        description  = registries[regAddress].description;
        version      = registries[regAddress].version;
        tags         = registries[regAddress].tags;
        source       = registries[regAddress].source;
    }

    // This function is only valid for a very small amount of time
    // after which it will become useless!
    // It was used to migrate registries from old MasterRegistry
    // into this new one and fix old registries creation_time (which
    // are now inside the registry itself).
    function setTime(address regAddress, uint time) {
        if (now < 1469830946) { // Valid up to 29-Jul-2016 19:22:26
            registries[regAddress].creationTime = time;
        }
    }

}