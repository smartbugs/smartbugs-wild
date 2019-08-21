pragma solidity 0.4.19;


contract Beneficiary {
    function payFee() public payable;
}


contract Owned {
    address public owner;
    Beneficiary public beneficiary;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
        beneficiary = Beneficiary(_newOwner);
    }
}


contract Integrity is Owned {
    uint256 public fee;

    event Engraved(address indexed _from, string _namespace, string _name, bytes32 _hash);

    struct FileInfo {
        string name;
        bool isValid;
    }

    struct Namespace {
        mapping(bytes32 => FileInfo) files;
        mapping(address => bool) permissions;
        address owner;
        bool isValid;
    }

    mapping(string => Namespace) registry;

    modifier onlyNamespaceOwner(string _namespace) {
        require(msg.sender == registry[_namespace].owner);
        _;
    }

    modifier onlyNamespaceMember(string _namespace) {
        require(registry[_namespace].permissions[msg.sender]);
        _;
    }

    // Constructor
    function Integrity(uint256 _fee) public {
        owner = msg.sender;
        beneficiary = Beneficiary(msg.sender);

        fee = _fee;

        Namespace memory namespace = Namespace({
            owner: 0x0,
            isValid: true
        });

        registry["default"] = namespace;
    }

    function updateFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function createNamespace(string _namespace) public payable {
        require(!registry[_namespace].isValid);
        require(msg.value >= fee * 10);

        Namespace memory namespace = Namespace({
            owner: msg.sender,
            isValid: true
        });

        registry[_namespace] = namespace;
        registry[_namespace].permissions[msg.sender] = true;

        beneficiary.payFee.value(msg.value)();
    }

    function changeNamespaceOwner(string _namespace, address _newOwner)
    public onlyNamespaceOwner(_namespace) {
        require(registry[_namespace].isValid);

        registry[_namespace].owner = _newOwner;
    }

    function addNamespaceMember(string _namespace, address _newMember)
    public onlyNamespaceOwner(_namespace) {
        require(registry[_namespace].isValid);

        registry[_namespace].permissions[_newMember] = true;
    }

    function removeNamespaceMember(string _namespace, address _member)
    public onlyNamespaceOwner(_namespace) {
        require(registry[_namespace].isValid);
        require(registry[_namespace].permissions[_member]);

        registry[_namespace].permissions[_member] = false;
    }

    function engraveNamespace(string _namespace, string _name, bytes32 _hash)
    public onlyNamespaceMember(_namespace) payable {
        require(registry[_namespace].isValid);
        require(!registry[_namespace].files[_hash].isValid);
        require(msg.value >= fee);

        FileInfo memory info = FileInfo({
            name: _name,
            isValid: true
        });

        registry[_namespace].files[_hash] = info;

        beneficiary.payFee.value(msg.value)();

        Engraved(msg.sender, _namespace, _name, _hash);
    }

    function engrave(string _name, bytes32 _hash) public payable {
        require(registry["default"].isValid);
        require(!registry["default"].files[_hash].isValid);
        require(msg.value >= fee);

        FileInfo memory info = FileInfo({
            name: _name,
            isValid: true
        });

        registry["default"].files[_hash] = info;

        beneficiary.payFee.value(msg.value)();

        Engraved(msg.sender, "default", _name, _hash);
    }

    function checkFileNamespace(string _namespace, bytes32 _hash)
    public constant returns (string name) {
        return registry[_namespace].files[_hash].name;
    }

    function checkFile(bytes32 _hash)
    public constant returns (string name) {
        return registry["default"].files[_hash].name;
    }

    function getHash(string _input) public pure returns (bytes32 hash) {
        return keccak256(_input);
    }

}