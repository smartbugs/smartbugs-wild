pragma solidity ^0.5.1;
contract BlockmaticsGraduationCertificate_120918 {
    address public owner = msg.sender;
    string public certificate;
    bool public certIssued = false;

    function publishGraduatingClass (string memory cert) public  {
        assert (msg.sender == owner && !certIssued);

        certIssued = true;
        certificate = cert;
    }
}