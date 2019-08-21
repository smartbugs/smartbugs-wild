pragma solidity 0.4.24;

contract SimpleVoting {

    string public constant description = "abc";

    struct Cert {
        string memberId;
        string program;
        string subjects;
        string dateStart;
        string dateEnd;
    }

    mapping  (string => Cert) certs;

    address owner;

    constructor() public {
        owner = msg.sender;
    }

    /// metadata
    function setCertificate(string memory memberId, string memory program, string memory subjects, string memory dateStart, string memory dateEnd) public {
        require(msg.sender == owner);
        certs[memberId] = Cert(memberId, program, subjects, dateStart, dateEnd);
    }

    /// Give certificate to memberId $(memberId).
    function getCertificate(string memory memberId) public view returns (string memory) {
        Cert memory cert = certs[memberId];
        return string(abi.encodePacked(
            "This is to certify that member ID in Sessia: ",
            cert.memberId,
            " between ",
            cert.dateStart,
            " and ",
            cert.dateEnd,
            " successfully finished the educational program ",
            cert.program,
            " that included the following subjects: ",
            cert.subjects,
            ". The President of the KICKVARD UNIVERSITY Narek Sirakanyan"
        ));
    }
}