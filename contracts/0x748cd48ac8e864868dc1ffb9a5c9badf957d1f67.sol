pragma solidity ^0.4.0;
contract BlockmaticsGraduationCertificate_011218 {
    address public owner = msg.sender;
    string certificate;
    bool certIssued = false;

    function publishGraduatingClass (string cert) public {
        assert (msg.sender == owner && !certIssued);

        certIssued = true;
        certificate = cert;
    }

    function showBlockmaticsCertificate() public constant returns (string) {
        return certificate;
    }
}