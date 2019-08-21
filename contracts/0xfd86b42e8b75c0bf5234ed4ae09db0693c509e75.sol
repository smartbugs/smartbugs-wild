pragma solidity 0.4.24;

contract KickvardUniversity {

    address owner;

    mapping (address => Certificate[]) certificates;

    mapping (string => address) member2address;

    struct Certificate {
        string memberId;
        string program;
        string subjects;
        string dateStart;
        string dateEnd;
    }

    constructor() public {
        owner = msg.sender;
    }

    function setCertificate(address toAddress, string memory memberId, string memory program, string memory subjects, string memory dateStart, string memory dateEnd) public {
        require(msg.sender == owner);
        certificates[toAddress].push(Certificate(memberId, program, subjects, dateStart, dateEnd));
        member2address[memberId] = toAddress;
    }

    function getCertificateByAddress(address toAddress) public view returns (string memory) {
        return renderCertificate(certificates[toAddress]);
    }

    function getCertificateByMember(string memory memberId) public view returns (string memory) {
        return renderCertificate(certificates[member2address[memberId]]);
    }

    function renderCertificate(Certificate[] memory memberCertificates) private pure returns (string memory) {
        if (memberCertificates.length < 1) {
            return "Certificate not found";
        }
        string memory result;
        string memory delimiter;
        for (uint i = 0; i < memberCertificates.length; i++) {
            result = string(abi.encodePacked(
                result,
                delimiter,
                "[ This is to certify that member ID in Sessia: ",
                memberCertificates[i].memberId,
                " between ",
                memberCertificates[i].dateStart,
                " and ",
                memberCertificates[i].dateEnd,
                " successfully finished the educational program ",
                memberCertificates[i].program,
                " that included the following subjects: ",
                memberCertificates[i].subjects,
                ". The President of the KICKVARD UNIVERSITY Narek Sirakanyan ]"
            ));
            delimiter = ", ";
        }
        return result;
    }
}