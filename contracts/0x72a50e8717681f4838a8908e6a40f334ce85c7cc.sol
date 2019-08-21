pragma solidity 0.4.25;

contract HighwayAcademyCertificates {
    
    event NewCertificate(uint256 indexed certificate_number, string info, string course_name, string student_name, string linkedin, string released_project, string mentor_name, string graduation_date_place);
    
    struct Certificate {
        
        string info;
        string course_name;
        string student_name;
        string student_linkedin;
        string released_project;
        string mentor_name;
        string graduation_date_place;
    }
    
    address public owner;
    uint256 public count = 0;
    mapping(uint256 => Certificate) public certificates;
    
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can use this function");
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
    
    function addCertificate(uint256 certificate_number, string info, string course_name, string student_name, string student_linkedin, string released_project, string mentor_name, string graduation_date_place) public onlyOwner {
        count++;
        require(count == certificate_number, "Wrong certificate number");
        certificates[count] = Certificate(info, course_name, student_name, student_linkedin, released_project, mentor_name, graduation_date_place);
        emit NewCertificate(certificate_number, info, course_name, student_name, student_linkedin, released_project, mentor_name, graduation_date_place);
    }
}