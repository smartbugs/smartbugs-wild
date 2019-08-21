pragma solidity^0.4.8;

contract BlockAppsCertificateManager {
    address owner;
    Certificate [] certificates;
    
    function BlockAppsCertificateManager() {
        owner = msg.sender;
    }
    function issueCertificate(string _classDate, string _participants, string _location) returns(bool){
        if (msg.sender != owner){
            return false;
        }
        certificates.push(new Certificate(_classDate, _participants, _location)); 
        return true;
    }
}

contract Certificate {
    string classDate; 
    string participants;
    string location;
    address certificateManager;
    
    function Certificate(string _classDate, string _participants, string _location) {
        classDate = _classDate;
        participants = _participants;
        certificateManager = msg.sender;
        location = _location;
    }
}