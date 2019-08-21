pragma solidity ^0.5.1;
contract Operations {
    function copyBytesNToBytes(bytes32 source, bytes memory destination, uint[1] memory pointer) internal pure {
        for (uint i=0; i < 32; i++) {
            if (source[i] == 0)
                break;
            else {
                destination[pointer[0]]=source[i];
                pointer[0]++;
            }
        }
    }
    function copyBytesToBytes(bytes memory source, bytes memory destination, uint[1] memory pointer) internal pure {
        for (uint i=0; i < source.length; i++) {
            destination[pointer[0]]=source[i];
            pointer[0]++;
        }
    }
    function uintToBytesN(uint v) internal pure returns (bytes32 ret) {
        if (v == 0) {
            ret = '0';
        }
        else {
            while (v > 0) {
//                ret = bytes32(uint(ret) / (2 ** 8));
//                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                ret = bytes32(uint(ret) >> 8);
                ret |= bytes32(((v % 10) + 48) << (8 * 31));
                v /= 10;
            }
        }
        return ret;
    }
    function stringToBytes32(string memory str) internal pure returns(bytes32) {
        bytes32 bStrN;
        assembly {
            bStrN := mload(add(str, 32))
        }
        return(bStrN);
    }
}
contract DataRegister is Operations {
    bytes32 Institute; 
    address owner;
    mapping(bytes10 => bytes) Instructor;
    mapping(uint => bytes10) InstructorUIds;
    uint InstructorCount = 0;
    struct course {
//        bytes10 CourseNumber;
        bytes CourseName;
        bytes10 StartDate;
        bytes10 EndDate;
        uint Hours;
        uint InstructorId;
    }
    mapping(bytes10 => course) Course;
    mapping(uint => bytes10) CourseUIds;
    uint CourseCount = 0;
    struct student {
        bytes Name;
        bytes10 NationalId;
    }
    mapping(bytes10 => student) Student;
    mapping(uint => bytes10) StudentUIds;
    uint StudentCount = 0;
    struct certificate {
        uint CourseId;
        uint StudentId;
        uint CertificateType;
        bytes10 Result;
        bool Enabled;
    }
    mapping(bytes10 => certificate) Certificate;
    uint CertificateCount = 0;
    mapping(uint => bytes10) CertificateUIds;
    modifier onlyOwner() {
        require(msg.sender==owner);
        _;
    }
    modifier notEmpty(string memory str) {
        bytes memory bStr = bytes(str);
        require(bStr.length > 0);
        _;
    }
    modifier isPositive(uint number) {
        require(number > 0);
        _;
    }
    modifier haveInstructor(uint InstructorId) {
        require(Instructor[InstructorUIds[InstructorId]].length > 0);
        _;
    }
    modifier haveCourse(uint CourseId) {
        require(CourseUIds[CourseId].length > 0);
        _;
    }
    modifier haveStudent(uint StudentId) {
        require(Student[StudentUIds[StudentId]].Name.length > 0);
        _;
    }
    modifier uniqueCertificateUId(string memory certificateUId) {
        require(Certificate[bytes10(stringToBytes32(certificateUId))].CourseId == 0);
        _;
    }
    modifier uniqueInstructorUId(string memory _instructorUId) {
        require(Instructor[bytes10(stringToBytes32(_instructorUId))].length == 0);
        _;
    }
    modifier uniqueCourseUId(string memory _courseUId) {
        require(Course[bytes10(stringToBytes32(_courseUId))].CourseName.length == 0);
        _;
    }
    modifier uniqueStudentUId(string memory _studentUId) {
        require(Student[bytes10(stringToBytes32(_studentUId))].Name.length == 0);
        _;
    }
    function RegisterInstructor(
        string memory instructorUId, 
        string memory instructor
        ) public onlyOwner notEmpty(instructorUId) notEmpty(instructor) uniqueInstructorUId(instructorUId) returns(bool) {
            bytes10 _instructorUId = bytes10(stringToBytes32(instructorUId));
            InstructorCount++;
            Instructor[_instructorUId] = bytes(instructor);
            InstructorUIds[InstructorCount]=_instructorUId;
            return(true);
    }
    function RegisterCourse(
        string memory CourseUId,
        string memory CourseName,
        string memory StartDate,
        string memory EndDate,
        uint Hours,
        uint InstructorId
        ) public onlyOwner notEmpty(CourseUId) notEmpty(CourseName) 
            isPositive(Hours) haveInstructor(InstructorId) uniqueCourseUId(CourseUId) {
            course memory _course = setCourseElements(CourseName, StartDate, EndDate, Hours, InstructorId);
            CourseCount++;
            bytes10 _courseUId = bytes10(stringToBytes32(CourseUId));
            CourseUIds[CourseCount] = _courseUId;
            Course[_courseUId] = _course;
    }
    function setCourseElements(
        string memory CourseName, 
        string memory StartDate, 
        string memory EndDate,
        uint Hours,
        uint InstructorId
        ) internal pure returns(course memory) {
        course memory _course;
        _course.CourseName = bytes(CourseName);
        _course.StartDate = bytes10(stringToBytes32(StartDate));
        _course.EndDate = bytes10(stringToBytes32(EndDate));
        _course.Hours = Hours;
        _course.InstructorId = InstructorId;
        return(_course);
    }
    function RegisterStudent(
        string memory StudentUId,
        string memory Name,
        string memory NationalId
        ) public onlyOwner notEmpty(Name) notEmpty(NationalId) notEmpty(StudentUId) uniqueStudentUId(StudentUId) returns(bool) {
            StudentCount++;
            StudentUIds[StudentCount] = bytes10(stringToBytes32(StudentUId));
            student memory _student;
            _student.Name = bytes(Name);
            _student.NationalId = bytes10(stringToBytes32(NationalId));
            Student[StudentUIds[StudentCount]]=_student;
        return(true);
    }
    function RegisterCertificate(
        string memory CertificateUId,
        uint CourseId,
        uint StudentId,
        uint CertificateType,
        string memory Result
        ) public onlyOwner haveStudent(StudentId) haveCourse(CourseId) 
        uniqueCertificateUId(CertificateUId) isPositive(CertificateType) returns(bool) {
            certificate memory _certificate;
            _certificate.CourseId = CourseId;
            _certificate.StudentId = StudentId;
            _certificate.CertificateType = CertificateType;
            _certificate.Result = bytes10(stringToBytes32(Result));
            _certificate.Enabled = true;
            bytes10 cert_uid = bytes10(stringToBytes32(CertificateUId));
            CertificateCount++;
            Certificate[cert_uid] = _certificate;
            CertificateUIds[CertificateCount] = cert_uid;
            return(true);
    }
    function EnableCertificate(string memory CertificateId) public onlyOwner notEmpty(CertificateId) returns(bool) {
        bytes10 _certificateId = bytes10(stringToBytes32(CertificateId));
        certificate memory _certificate = Certificate[_certificateId];
        require(_certificate.Result != '');
        require(! _certificate.Enabled);
        Certificate[_certificateId].Enabled = true;
        return(true);
    }
    function DisableCertificate(string memory CertificateId) public onlyOwner notEmpty(CertificateId) returns(bool) {
        bytes10 _certificateId = bytes10(stringToBytes32(CertificateId));
        certificate memory _certificate = Certificate[_certificateId];
        require(_certificate.Result != '');
        require(_certificate.Enabled);
        Certificate[_certificateId].Enabled = false;
        return(true);
    }
}
contract CryptoClassCertificate is DataRegister {
    constructor(string memory _Institute) public notEmpty(_Institute) {
        owner = msg.sender;
        Institute = stringToBytes32(_Institute);
    }
    function GetInstitute() public view returns(string  memory) {
        uint[1] memory pointer;
        pointer[0]=0;
        bytes memory institute=new bytes(48);
        copyBytesToBytes('{"Institute":"', institute, pointer);
        copyBytesNToBytes(Institute, institute, pointer);
        copyBytesToBytes('"}', institute, pointer);
        return(string(institute));
    }
    function GetInstructors() public view onlyOwner returns(string memory) {
        uint len = 30;
        uint i;
        for (i=1 ; i <= InstructorCount ; i++) 
            len += 30 + Instructor[InstructorUIds[i]].length;
        bytes memory instructors = new bytes(len);
        uint[1] memory pointer;
        pointer[0]=0;
        copyBytesNToBytes('{ "Instructors":[', instructors, pointer);
        for (i=1 ; i <= InstructorCount ; i++) {
            if (i > 1) 
                copyBytesNToBytes(',', instructors, pointer);
            copyBytesNToBytes('{"Id":"', instructors, pointer);
            copyBytesNToBytes(InstructorUIds[i], instructors, pointer);
            copyBytesNToBytes('","Name":"', instructors, pointer);
            copyBytesToBytes(Instructor[InstructorUIds[i]], instructors, pointer);
            copyBytesNToBytes('"}', instructors, pointer);
        }
        copyBytesNToBytes(']}', instructors, pointer);
        return(string(instructors));
    }
    function GetInstructor(string memory InstructorUId) public view notEmpty(InstructorUId) returns(string memory) {
        bytes10 _instructorId = bytes10(stringToBytes32(InstructorUId));
        require(Instructor[_instructorId].length > 0);
        uint len = 30;
        len += Instructor[_instructorId].length;
        bytes memory _instructor = new bytes(len);
        uint[1] memory pointer;
        pointer[0]=0;
        copyBytesNToBytes('{ "Instructor":"', _instructor, pointer);
        copyBytesToBytes(Instructor[_instructorId], _instructor, pointer);
        copyBytesNToBytes('"}', _instructor, pointer);
        return(string(_instructor));
    }
    function GetInstructorCourses(string memory InstructorUId) public view notEmpty(InstructorUId) returns(string memory) {
        bytes10 _instructorUId = bytes10(stringToBytes32(InstructorUId));
        require(Instructor[_instructorUId].length > 0);
        uint _instructorId = 0;
        for (uint i = 1; i <= InstructorCount; i++)
            if (InstructorUIds[i] == _instructorUId) {
                _instructorId = i;
                break;
            }
        uint len = 30;
        course memory _course;
        uint i;
        for (i=1; i<=CourseCount; i++) {
            if (Course[CourseUIds[i]].InstructorId == _instructorId) { 
                _course = Course[CourseUIds[i]];
                len += 180 + Institute.length + _course.CourseName.length + Instructor[InstructorUIds[_course.InstructorId]].length;
            }
        }
        bytes memory courseInfo = new bytes(len);
        uint[1] memory pointer;
        pointer[0]=0;
        copyBytesNToBytes('{"Courses":[', courseInfo, pointer);
        bool first = true;
        for (i=1; i<=CourseCount; i++) {
            _course = Course[CourseUIds[i]];
            if (_course.InstructorId == _instructorId) {
                if (first)
                    first = false;
                else
                    copyBytesNToBytes(',', courseInfo, pointer);
                copyBytesNToBytes('{"CourseId":"', courseInfo, pointer);
                copyBytesNToBytes(CourseUIds[i], courseInfo, pointer);
                copyBytesNToBytes('","CourseName":"', courseInfo, pointer);
                copyBytesToBytes(_course.CourseName, courseInfo, pointer);
                copyBytesNToBytes('","StartDate":"', courseInfo, pointer);
                copyBytesNToBytes(_course.StartDate, courseInfo, pointer);
                copyBytesNToBytes('","EndDate":"', courseInfo, pointer);
                copyBytesNToBytes(_course.EndDate, courseInfo, pointer);
                copyBytesNToBytes('","DurationHours":"', courseInfo, pointer);
                copyBytesNToBytes( uintToBytesN(_course.Hours), courseInfo, pointer);
                copyBytesNToBytes('"}', courseInfo, pointer);
            }
        }
        copyBytesNToBytes(']}', courseInfo, pointer);
        return(string(courseInfo));
    }
    function GetCourseInfo(string memory CourseUId) public view notEmpty(CourseUId) returns(string memory) {
        bytes10 _courseUId=bytes10(stringToBytes32(CourseUId));
        course memory _course;
        _course = Course[_courseUId];
        require(_course.CourseName.length > 0);
        uint len = 110;
        len += Institute.length + 10 + _course.CourseName.length + 10 + 10 + Instructor[InstructorUIds[_course.InstructorId]].length;
        bytes memory courseInfo = new bytes(len);
        uint[1] memory pointer;
        pointer[0]=0;
        copyBytesNToBytes('{"Course":', courseInfo, pointer);
        copyBytesNToBytes('{"Issuer":"', courseInfo, pointer);
        copyBytesNToBytes(Institute, courseInfo, pointer);
        copyBytesNToBytes('","CourseUId":"', courseInfo, pointer);
        copyBytesNToBytes(_courseUId, courseInfo, pointer);
        copyBytesNToBytes('","CourseName":"', courseInfo, pointer);
        copyBytesToBytes(_course.CourseName, courseInfo, pointer);
        copyBytesNToBytes('","StartDate":"', courseInfo, pointer);
        copyBytesNToBytes(_course.StartDate, courseInfo, pointer);
        copyBytesNToBytes('","EndDate":"', courseInfo, pointer);
        copyBytesNToBytes(_course.EndDate, courseInfo, pointer);
        copyBytesNToBytes('","DurationHours":"', courseInfo, pointer);
        copyBytesNToBytes( uintToBytesN(_course.Hours), courseInfo, pointer);
        copyBytesNToBytes('"}}', courseInfo, pointer);
        return(string(courseInfo));
    }
    function GetCourses() public view onlyOwner returns(string memory) {
        uint len = 30;
        uint i;
        course memory _course;
        for (i=1 ; i <= CourseCount ; i++) {
            _course = Course[CourseUIds[i]];
            len += 90 + 10 + _course.CourseName.length + 10 + 12 + 12 + 6 + Instructor[InstructorUIds[_course.InstructorId]].length;
        }
        bytes memory courses = new bytes(len);
        uint[1] memory pointer;
        pointer[0]=0;
        bytes32 hrs;
        copyBytesNToBytes('{"Courses":[', courses, pointer);
        for (i=1 ; i <= CourseCount ; i++) {
            if (i > 1)
                copyBytesNToBytes(',', courses, pointer);
            _course = Course[CourseUIds[i]];
            copyBytesNToBytes('{"UId":"', courses, pointer);
            copyBytesNToBytes(CourseUIds[i], courses, pointer);
            copyBytesNToBytes('","Name":"', courses, pointer);
            copyBytesToBytes(_course.CourseName, courses, pointer);
            copyBytesNToBytes('","InstructorId":"', courses, pointer);
            copyBytesToBytes(Instructor[InstructorUIds[_course.InstructorId]], courses, pointer);
            copyBytesNToBytes('","StartDate":"', courses, pointer);
            copyBytesNToBytes(_course.StartDate, courses, pointer);
            copyBytesNToBytes('","EndDate":"', courses, pointer);
            copyBytesNToBytes(_course.EndDate, courses, pointer);
            copyBytesNToBytes('","Duration":"', courses, pointer);
            hrs = uintToBytesN(_course.Hours);
            copyBytesNToBytes(hrs, courses, pointer);
            copyBytesNToBytes(' Hours"}', courses, pointer);
        }
        copyBytesNToBytes(']}', courses, pointer);
        return(string(courses));
    }
    function GetStudentInfo(string memory StudentUId) public view notEmpty(StudentUId) returns(string memory) {
        bytes10 _studentUId=bytes10(stringToBytes32(StudentUId));
        student memory _student;
        _student = Student[_studentUId];
        require(_student.Name.length > 0);
        uint len = 110;
        len += Institute.length + 10 + _student.Name.length + 10 ;
        bytes memory studentInfo = new bytes(len);
        uint[1] memory pointer;
        pointer[0]=0;
        copyBytesNToBytes('{"Student":', studentInfo, pointer);
        copyBytesNToBytes('{"Issuer":"', studentInfo, pointer);
        copyBytesNToBytes(Institute, studentInfo, pointer);
        copyBytesNToBytes('","StudentUId":"', studentInfo, pointer);
        copyBytesNToBytes(_studentUId, studentInfo, pointer);
        copyBytesNToBytes('","Name":"', studentInfo, pointer);
        copyBytesToBytes(_student.Name, studentInfo, pointer);
        copyBytesNToBytes('","NationalId":"', studentInfo, pointer);
        copyBytesNToBytes(_student.NationalId, studentInfo, pointer);
        copyBytesNToBytes('"}}', studentInfo, pointer);
        return(string(studentInfo));
    }
    function GetStudents() public view onlyOwner returns(string memory) {
        uint len = 30;
        uint i;
        for (i=1 ; i <= StudentCount ; i++) 
            len += 50 + 3 + Student[StudentUIds[i]].Name.length;
        bytes memory students = new bytes(len);
        uint[1] memory pointer;
        pointer[0]=0;
        copyBytesNToBytes('{"Students":[', students, pointer);
        for (i=1 ; i <= StudentCount ; i++) {
            if (i > 1)
                copyBytesNToBytes(',', students, pointer);
            student memory _student = Student[StudentUIds[i]];
            copyBytesNToBytes('{"UId":"', students, pointer);
            copyBytesNToBytes(StudentUIds[i], students, pointer);
            copyBytesNToBytes('","NationalId":"', students, pointer);
            copyBytesNToBytes(_student.NationalId, students, pointer);
            copyBytesNToBytes('","Name":"', students, pointer);
            copyBytesToBytes(_student.Name, students, pointer);
            copyBytesNToBytes('"}', students, pointer);
        }
        copyBytesNToBytes(']}', students, pointer);
        return(string(students));
    }
    function GetCertificates() public view onlyOwner returns(string memory) {
        uint len = 30;
        uint i;
        len += CertificateCount * 40;
        bytes memory certificates = new bytes(len);
        uint[1] memory pointer;
        pointer[0]=0;
        copyBytesNToBytes('{"Certificates":[', certificates, pointer);
        for (i = 1 ; i <= CertificateCount ; i++) {
            if (i > 1)
                copyBytesNToBytes(',', certificates, pointer);
            copyBytesNToBytes('{"CertificateId":"', certificates, pointer);
            copyBytesNToBytes(CertificateUIds[i], certificates, pointer);
            copyBytesNToBytes('"}', certificates, pointer);
        }
        copyBytesNToBytes(']}', certificates, pointer);
        return(string(certificates));
    }
    function GetCertificate(string memory CertificateId) public view notEmpty(CertificateId) returns(string memory) {
        bytes memory certSpec;
        uint len;
        uint[1] memory pointer;
        pointer[0] = 0;
        bytes10 _certificateId = bytes10(stringToBytes32(CertificateId));
        certificate memory _certificate = Certificate[_certificateId];
        course memory _course = Course[CourseUIds[_certificate.CourseId]];
        student memory _student = Student[StudentUIds[_certificate.StudentId]];
        bytes memory _instructor = Instructor[InstructorUIds[_course.InstructorId]];
        len = 500;
        len += _course.CourseName.length + _instructor.length;
        certSpec = new bytes(len);
        require(_certificate.StudentId > 0);
        require(_certificate.Enabled);
        copyBytesNToBytes('{"Certificate":{"Issuer":"', certSpec, pointer);
        copyBytesNToBytes(Institute, certSpec, pointer);
        copyBytesNToBytes('","CertificateId":"', certSpec, pointer);
        copyBytesNToBytes(_certificateId, certSpec, pointer);
        copyBytesNToBytes('","Name":"', certSpec, pointer);
        copyBytesToBytes(_student.Name, certSpec, pointer);
        copyBytesNToBytes('","NationalId":"', certSpec, pointer);
        copyBytesNToBytes( _student.NationalId, certSpec, pointer);
        copyBytesNToBytes('","CourseId":"', certSpec, pointer);
        copyBytesNToBytes(CourseUIds[_certificate.CourseId], certSpec, pointer);
        copyBytesNToBytes('","CourseName":"', certSpec, pointer);
        copyBytesToBytes(_course.CourseName, certSpec, pointer);
        copyBytesNToBytes('","StartDate":"', certSpec, pointer);
        copyBytesNToBytes(_course.StartDate, certSpec, pointer);
        copyBytesNToBytes('","EndDate":"', certSpec, pointer);
        copyBytesNToBytes(_course.EndDate, certSpec, pointer);
        copyBytesNToBytes('","DurationHours":"', certSpec, pointer);
        copyBytesNToBytes(uintToBytesN(_course.Hours), certSpec, pointer);
        copyBytesNToBytes('","Instructor":"', certSpec, pointer);
        copyBytesToBytes(_instructor, certSpec, pointer);
        bytes10 _certType = GetCertificateTypeDescription(_certificate.CertificateType);
        copyBytesNToBytes('","CourseType":"', certSpec, pointer);
        copyBytesNToBytes(_certType, certSpec, pointer);
        copyBytesNToBytes('","Result":"', certSpec, pointer);
        copyBytesNToBytes(_certificate.Result, certSpec, pointer);
        copyBytesNToBytes('"}}', certSpec, pointer);
        return(string(certSpec));
    }
    function GetCertificateTypeDescription(uint Type) pure internal returns(bytes10) {
        if (Type == 1) 
            return('Attendance');
        else if (Type == 2)
            return('Online');
        else if (Type == 3)
            return('Video');
        else if (Type == 4)
            return('ELearning');
        else
            return(bytes10(uintToBytesN(Type)));
    } 
}