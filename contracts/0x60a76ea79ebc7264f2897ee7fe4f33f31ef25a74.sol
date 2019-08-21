pragma solidity ^0.4.2;
contract BlockmaticsGraduationCertificate {
    address public owner = msg.sender;
    string certificate;
    bool certIssued = false;


    function publishGraduatingClass(string cert) {
        if (msg.sender != owner || certIssued)
            throw;
        certIssued = true;
        certificate = cert;
    }


    function showBlockmaticsCertificate() constant returns (string) {
        return certificate;
    }
}