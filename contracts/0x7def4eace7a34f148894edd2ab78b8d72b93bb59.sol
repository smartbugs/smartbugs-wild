pragma solidity 0.4.24;

contract SimpleVoting {

    string public constant description = "abc";

    string public name = "asd";

    mapping (string => string) certificates;

    address owner;

    constructor() public {
        owner = msg.sender;
    }

    function getCertificate(string memory id) public view returns (string memory) {
        return certificates[id];
    }

    function setCertificate(string memory id, string memory cert) public {
        require(msg.sender == owner);
        certificates[id] = cert;
    }
}