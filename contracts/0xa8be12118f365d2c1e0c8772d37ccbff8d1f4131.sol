pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

//"1","Francisco","18028348","SC001","Smart Contract","Asistencia"

contract lccCertificados {

    address constant public myAddressLcc = 0xdc32EFF737bd1B94a7814eC269Ef4808C887850D;
    event LogsCourse(string name);
    
    struct Course {
      string nameStudent;
      string idStudent;
      string idCourse;
      string nameCourse;
      string note;
      uint timestamp;
    }
    
    mapping (uint => Course) Courses;
    
    
    // SET EXPEDIENTE
    function setCourse(uint id, string memory nameStudent, string memory idStudent, string memory idCourse, string memory nameCourse, string memory note) public payable returns  (uint success)  {

       //uint id = now;
       
       if(msg.sender == myAddressLcc) {

         Courses[id].nameStudent = nameStudent;
         Courses[id].idStudent = idStudent;        
         Courses[id].idCourse = idCourse;
         Courses[id].nameCourse = nameCourse;
         Courses[id].note = note;
         Courses[id].timestamp = now;
         return id;
        
       }
   
    }
    

    // GET
    function getCourse(uint id) public view returns  (Course memory success)  {
        return Courses[id];
        
    }
    function getSender() public view returns  (address success)  {
        return msg.sender;
        
    }
    function getNameCourse(uint id) public view returns  (string memory success)  {
        return Courses[id].nameCourse;
    }


    
}