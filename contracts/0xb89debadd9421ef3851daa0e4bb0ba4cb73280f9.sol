pragma solidity ^0.4.6;

contract Blockmatics_Certificate_12142017 {
    address public owner = msg.sender;
    string certificate;
    bool certIssued = false;

    function publishGraduatingClass(string cert) public {
        if (msg.sender != owner || certIssued)
            revert();
        certIssued = true;
        certificate = cert;
    }

    function showCertificate() constant public returns (string)  {
        return certificate;
    }
}