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


contract Ownership is Owned {

    event Engraved(address indexed _from, bytes32 _hash);

    struct Entry {
        uint256 timestamp;
        bool isValid;
        string author;
        string text;
        bytes32 license;
    }

    mapping(bytes32 => Entry) public registry;
    bytes32[] public works;

    struct License {
        string title;
        string text;
        bool isValid;
    }

    mapping(bytes32 => License) public licenses;
    bytes32[] public licenseIds;

    uint256 public fee;

    // Constructor
    function Ownership(uint256 _fee) public {
        owner = msg.sender;
        beneficiary = Beneficiary(msg.sender);

        fee = _fee;

        License memory license = License({
            text: "All rights reserved. Predominance of the custom 'text' field in case of conflict.",
            title: "All rights reserved",
            isValid: true
        });

        bytes32 licenseId = keccak256(license.text);
        licenses[licenseId] = license;
        licenseIds.push(licenseId);
    }

    function updateFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function engrave(bytes32 _hash,
                     string _author,
                     string _freeText,
                     bytes32 _license) public payable {
        require(!registry[_hash].isValid);
        require(licenses[_license].isValid);

        require(msg.value >= fee);

        Entry memory entry = Entry({
            author: _author,
            isValid: true,
            timestamp: block.timestamp,
            text: _freeText,
            license: _license
        });

        registry[_hash] = entry;
        works.push(_hash);

        beneficiary.payFee.value(msg.value)();

        Engraved(msg.sender, _hash);
    }

    function engraveDefault(bytes32 _hash,
                            string _author,
                            string _freeText) public payable {
        require(!registry[_hash].isValid);
        require(licenses[licenseIds[0]].isValid);

        require(msg.value >= fee);

        Entry memory entry = Entry({
            author: _author,
            isValid: true,
            timestamp: block.timestamp,
            text: _freeText,
            license: licenseIds[0]
        });

        registry[_hash] = entry;
        works.push(_hash);

        beneficiary.payFee.value(msg.value)();

        Engraved(msg.sender, _hash);
    }

    function registerLicense(string _title, string _text)
    public returns (bytes32 hash) {
        bytes32 textHash = keccak256(_text);

        require(!licenses[textHash].isValid);

        License memory license = License({
            text: _text,
            title: _title,
            isValid: true
        });

        licenses[textHash] = license;
        licenseIds.push(textHash);

        return textHash;
    }

    function getHash(string _input) public pure returns (bytes32 hash) {
        return keccak256(_input);
    }

}