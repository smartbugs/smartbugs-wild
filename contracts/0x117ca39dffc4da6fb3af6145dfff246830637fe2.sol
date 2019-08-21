pragma solidity ^0.4.18;

library Sets {
    // address set
    struct addressSet {
        address[] members;
        mapping(address => uint) memberIndices;
    }

    function insert(addressSet storage self, address other) public {
        if (!contains(self, other)) {
            assert(length(self) < 2**256-1);
            self.members.push(other);
            self.memberIndices[other] = length(self);
        }
    }

    function remove(addressSet storage self, address other) public {
        if (contains(self, other)) {
            uint replaceIndex = self.memberIndices[other];
            address lastMember = self.members[length(self)-1];
            // overwrite other with the last member and remove last member
            self.members[replaceIndex-1] = lastMember;
            self.members.length--;
            // reflect this change in the indices
            self.memberIndices[lastMember] = replaceIndex;
            delete self.memberIndices[other];
        }
    }

    function contains(addressSet storage self, address other) public view returns (bool) {
        return self.memberIndices[other] > 0;
    }

    function length(addressSet storage self) public view returns (uint) {
        return self.members.length;
    }


    // uint set
    struct uintSet {
        uint[] members;
        mapping(uint => uint) memberIndices;
    }

    function insert(uintSet storage self, uint other) public {
        if (!contains(self, other)) {
            assert(length(self) < 2**256-1);
            self.members.push(other);
            self.memberIndices[other] = length(self);
        }
    }

    function remove(uintSet storage self, uint other) public {
        if (contains(self, other)) {
            uint replaceIndex = self.memberIndices[other];
            uint lastMember = self.members[length(self)-1];
            // overwrite other with the last member and remove last member
            self.members[replaceIndex-1] = lastMember;
            self.members.length--;
            // reflect this change in the indices
            self.memberIndices[lastMember] = replaceIndex;
            delete self.memberIndices[other];
        }
    }

    function contains(uintSet storage self, uint other) public view returns (bool) {
        return self.memberIndices[other] > 0;
    }

    function length(uintSet storage self) public view returns (uint) {
        return self.members.length;
    }


    // uint8 set
    struct uint8Set {
        uint8[] members;
        mapping(uint8 => uint) memberIndices;
    }

    function insert(uint8Set storage self, uint8 other) public {
        if (!contains(self, other)) {
            assert(length(self) < 2**256-1);
            self.members.push(other);
            self.memberIndices[other] = length(self);
        }
    }

    function remove(uint8Set storage self, uint8 other) public {
        if (contains(self, other)) {
            uint replaceIndex = self.memberIndices[other];
            uint8 lastMember = self.members[length(self)-1];
            // overwrite other with the last member and remove last member
            self.members[replaceIndex-1] = lastMember;
            self.members.length--;
            // reflect this change in the indices
            self.memberIndices[lastMember] = replaceIndex;
            delete self.memberIndices[other];
        }
    }

    function contains(uint8Set storage self, uint8 other) public view returns (bool) {
        return self.memberIndices[other] > 0;
    }

    function length(uint8Set storage self) public view returns (uint) {
        return self.members.length;
    }


    // int set
    struct intSet {
        int[] members;
        mapping(int => uint) memberIndices;
    }

    function insert(intSet storage self, int other) public {
        if (!contains(self, other)) {
            assert(length(self) < 2**256-1);
            self.members.push(other);
            self.memberIndices[other] = length(self);
        }
    }

    function remove(intSet storage self, int other) public {
        if (contains(self, other)) {
            uint replaceIndex = self.memberIndices[other];
            int lastMember = self.members[length(self)-1];
            // overwrite other with the last member and remove last member
            self.members[replaceIndex-1] = lastMember;
            self.members.length--;
            // reflect this change in the indices
            self.memberIndices[lastMember] = replaceIndex;
            delete self.memberIndices[other];
        }
    }

    function contains(intSet storage self, int other) public view returns (bool) {
        return self.memberIndices[other] > 0;
    }

    function length(intSet storage self) public view returns (uint) {
        return self.members.length;
    }


    // int8 set
    struct int8Set {
        int8[] members;
        mapping(int8 => uint) memberIndices;
    }

    function insert(int8Set storage self, int8 other) public {
        if (!contains(self, other)) {
            assert(length(self) < 2**256-1);
            self.members.push(other);
            self.memberIndices[other] = length(self);
        }
    }

    function remove(int8Set storage self, int8 other) public {
        if (contains(self, other)) {
            uint replaceIndex = self.memberIndices[other];
            int8 lastMember = self.members[length(self)-1];
            // overwrite other with the last member and remove last member
            self.members[replaceIndex-1] = lastMember;
            self.members.length--;
            // reflect this change in the indices
            self.memberIndices[lastMember] = replaceIndex;
            delete self.memberIndices[other];
        }
    }

    function contains(int8Set storage self, int8 other) public view returns (bool) {
        return self.memberIndices[other] > 0;
    }

    function length(int8Set storage self) public view returns (uint) {
        return self.members.length;
    }


    // byte set
    struct byteSet {
        byte[] members;
        mapping(byte => uint) memberIndices;
    }

    function insert(byteSet storage self, byte other) public {
        if (!contains(self, other)) {
            assert(length(self) < 2**256-1);
            self.members.push(other);
            self.memberIndices[other] = length(self);
        }
    }

    function remove(byteSet storage self, byte other) public {
        if (contains(self, other)) {
            uint replaceIndex = self.memberIndices[other];
            byte lastMember = self.members[length(self)-1];
            // overwrite other with the last member and remove last member
            self.members[replaceIndex-1] = lastMember;
            self.members.length--;
            // reflect this change in the indices
            self.memberIndices[lastMember] = replaceIndex;
            delete self.memberIndices[other];
        }
    }

    function contains(byteSet storage self, byte other) public view returns (bool) {
        return self.memberIndices[other] > 0;
    }

    function length(byteSet storage self) public view returns (uint) {
        return self.members.length;
    }


    // bytes32 set
    struct bytes32Set {
        bytes32[] members;
        mapping(bytes32 => uint) memberIndices;
    }

    function insert(bytes32Set storage self, bytes32 other) public {
        if (!contains(self, other)) {
            assert(length(self) < 2**256-1);
            self.members.push(other);
            self.memberIndices[other] = length(self);
        }
    }

    function remove(bytes32Set storage self, bytes32 other) public {
        if (contains(self, other)) {
            uint replaceIndex = self.memberIndices[other];
            bytes32 lastMember = self.members[length(self)-1];
            // overwrite other with the last member and remove last member
            self.members[replaceIndex-1] = lastMember;
            self.members.length--;
            // reflect this change in the indices
            self.memberIndices[lastMember] = replaceIndex;
            delete self.memberIndices[other];
        }
    }

    function contains(bytes32Set storage self, bytes32 other) public view returns (bool) {
        return self.memberIndices[other] > 0;
    }

    function length(bytes32Set storage self) public view returns (uint) {
        return self.members.length;
    }
}

contract Prover {
    // attach library
    using Sets for Sets.addressSet;
    using Sets for Sets.bytes32Set;

    // storage vars
    address owner;
    Sets.addressSet users;
    mapping(address => Account) internal accounts;

    // structs
    struct Account {
        Sets.bytes32Set entries;
        mapping(bytes32 => Entry) values;
    }

    struct Entry {
        uint time;
        uint staked;
    }

    // constructor
    function Prover() public {
        owner = msg.sender;
    }

    // fallback
    function() internal {
        revert();
    }


    // modifier to check if a target address has a particular entry
    modifier entryExists(address target, bytes32 dataHash, bool exists) {
        assert(accounts[target].entries.contains(dataHash) == exists);
        _;
    }

    // external functions
    // allow access to our structs via functions with convenient return values
    function registeredUsers()
        external
        view
        returns (address[] unique_addresses) {
        return users.members;
    }
    function userEntries(address target)
        external
        view
        returns (bytes32[] entries) {
        return accounts[target].entries.members;
    }
    function entryInformation(address target, bytes32 dataHash)
        external
        view
        returns (bool proved, uint time, uint staked) {
        return (accounts[target].entries.contains(dataHash),
                accounts[target].values[dataHash].time,
                accounts[target].values[dataHash].staked);
    }

    // public functions
    // adding entries
    function addEntry(bytes32 dataHash)
        public
        payable
        entryExists(msg.sender, dataHash, false){
        users.insert(msg.sender);
        accounts[msg.sender].entries.insert(dataHash);
        accounts[msg.sender].values[dataHash] = Entry(now, msg.value);
    }

    // deleting entries
    function deleteEntry(bytes32 dataHash)
        public
        entryExists(msg.sender, dataHash, true) {
        uint rebate = accounts[msg.sender].values[dataHash].staked;
        // update user account
        delete accounts[msg.sender].values[dataHash];
        accounts[msg.sender].entries.remove(dataHash);
        // delete from users if this was the user's last entry
        if (accounts[msg.sender].entries.length() == 0) {
            users.remove(msg.sender);
        }
        // send the rebate
        if (rebate > 0) msg.sender.transfer(rebate);
    }

    // allow owner to delete contract if no accounts exist
    function selfDestruct() public {
        if ((msg.sender == owner) && (users.length() == 0)) {
            selfdestruct(owner);
        }
    }
}