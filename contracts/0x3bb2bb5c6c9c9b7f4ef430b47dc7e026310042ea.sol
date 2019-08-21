//! Registry contract.
//! By Gav Wood (Ethcore), 2016.
//! Released under the Apache Licence 2.

// From Owned.sol
contract Owned {
    modifier only_owner { if (msg.sender != owner) return; _ }
    
    event NewOwner(address indexed old, address indexed current);
    
    function setOwner(address _new) only_owner { NewOwner(owner, _new); owner = _new; }
    
    address public owner = msg.sender;
}

contract Registry is Owned {
    struct Entry {
        address owner;
        address reverse;
        mapping (string => bytes32) data;
    }
    
    event Drained(uint amount);
    event FeeChanged(uint amount);
    event Reserved(bytes32 indexed name, address indexed owner);
    event Transferred(bytes32 indexed name, address indexed oldOwner, address indexed newOwner);
    event Dropped(bytes32 indexed name, address indexed owner);
    event DataChanged(bytes32 indexed name, address indexed owner, string indexed key, string plainKey);
    event ReverseProposed(string indexed name, address indexed reverse);
    event ReverseConfirmed(string indexed name, address indexed reverse);
    event ReverseRemoved(string indexed name, address indexed reverse);

    modifier when_unreserved(bytes32 _name) { if (entries[_name].owner != 0) return; _ }
    modifier only_owner_of(bytes32 _name) { if (entries[_name].owner != msg.sender) return; _ }
    modifier when_proposed(string _name) { if (entries[sha3(_name)].reverse != msg.sender) return; _ }
    modifier when_fee_paid { if (msg.value < fee) return; _ }

    function reserve(bytes32 _name) when_unreserved(_name) when_fee_paid returns (bool success) {
        entries[_name].owner = msg.sender;
        Reserved(_name, msg.sender);
        return true;
    }
    function transfer(bytes32 _name, address _to) only_owner_of(_name) returns (bool success) {
        entries[_name].owner = _to;
        Transferred(_name, msg.sender, _to);
        return true;
    }
    function drop(bytes32 _name) only_owner_of(_name) returns (bool success) {
        delete entries[_name];
        Dropped(_name, msg.sender);
        return true;
    }
    
    function set(bytes32 _name, string _key, bytes32 _value) only_owner_of(_name) returns (bool success) {
        entries[_name].data[_key] = _value;
        DataChanged(_name, msg.sender, _key, _key);
        return true;
    }
    function setAddress(bytes32 _name, string _key, address _value) only_owner_of(_name) returns (bool success) {
        entries[_name].data[_key] = bytes32(_value);
        DataChanged(_name, msg.sender, _key, _key);
        return true;
    }
    function setUint(bytes32 _name, string _key, uint _value) only_owner_of(_name) returns (bool success) {
        entries[_name].data[_key] = bytes32(_value);
        DataChanged(_name, msg.sender, _key, _key);
        return true;
    }
    
    function reserved(bytes32 _name) constant returns (bool reserved) {
        return entries[_name].owner != 0;
    } 
    function get
    (bytes32 _name, string _key) constant returns (bytes32) {
        return entries[_name].data[_key];
    }
    function getAddress(bytes32 _name, string _key) constant returns (address) {
        return address(entries[_name].data[_key]);
    }
    function getUint(bytes32 _name, string _key) constant returns (uint) {
        return uint(entries[_name].data[_key]);
    }
    
    function proposeReverse(string _name, address _who) only_owner_of(sha3(_name)) returns (bool success) {
        var sha3Name = sha3(_name);
        if (entries[sha3Name].reverse != 0 && sha3(reverse[entries[sha3Name].reverse]) == sha3Name) {
            delete reverse[entries[sha3Name].reverse];
            ReverseRemoved(_name, entries[sha3Name].reverse);
        }
        entries[sha3Name].reverse = _who;
        ReverseProposed(_name, _who);
        return true;
    }
    
    function confirmReverse(string _name) when_proposed(_name) returns (bool success) {
        reverse[msg.sender] = _name;
        ReverseConfirmed(_name, msg.sender);
        return true;
    }
    
    function removeReverse() {
        ReverseRemoved(reverse[msg.sender], msg.sender);
        delete entries[sha3(reverse[msg.sender])].reverse;
        delete reverse[msg.sender];
    }
    
    function setFee(uint _amount) only_owner {
        fee = _amount;
        FeeChanged(_amount);
    }
    
    function drain() only_owner {
        Drained(this.balance);
        if (!msg.sender.send(this.balance)) throw;
    }
    
    mapping (bytes32 => Entry) entries;
    mapping (address => string) public reverse;
    
    uint public fee = 1 ether;
}