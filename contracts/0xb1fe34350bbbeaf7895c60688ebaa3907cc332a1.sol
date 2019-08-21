pragma solidity 0.4.23;

contract CareerCertificate {

    struct Certificate {

    bytes32 id;
    bool isCertificate;
    bytes32 date;
    string completeName;
    string RUT;
    string institution;
    bytes32 RutInstitution;
    string title;
    string Totalhash;
    bytes32 FechaTitulacion;
    bytes32 NroRegistro;
    bytes32 CodigoVerificacion;
    
    bool active;

  }

    address public ceoAddress;
    mapping(address=>bool) employee;

    mapping (bytes32 => Certificate) certificates;

    event CertificateCreated(address creator, string id, string RUT);
    event SetActive(address responsable, string id, bool active, string description);

    constructor() public {
    ceoAddress = msg.sender;
}
    //funcion que crea un certificado recibe los campos y lo convierte en la variable bytes32
    function createCertificate(string _id, string _date, string _completeName, string _RUT, string _institution, string _RutInstition, string _title, string _Totalhash, string _FechaTitulacion, 
                                string _NroRegistro, string _CodigoVerificacion) public onlyEmployees {
 
         bytes32 realId = convert(_id);
         
         certificates[realId].id = realId;
         certificates[realId].isCertificate = true;
         certificates[realId].date = convert(_date);
         
         certificates[realId].completeName = _completeName;
         certificates[realId].RUT =_RUT;
         certificates[realId].institution =_institution ;
         certificates[realId].RutInstitution = convert(_RutInstition);//CAMBIOS
         certificates[realId].title = _title;
         certificates[realId].Totalhash= _Totalhash;//CAMBIOS
         certificates[realId].FechaTitulacion = convert(_FechaTitulacion);//CAMBIOS
         certificates[realId].NroRegistro = convert(_NroRegistro) ;//CAMBIOS
         certificates[realId].CodigoVerificacion = convert(_CodigoVerificacion);//CAMBIOS
         
         certificates[realId].active = true;
        
         emit CertificateCreated(msg.sender, _id, _RUT);
}
    function convert(string key) internal returns (bytes32 ret) {
     if (bytes(key).length > 32) {
        throw;
     }

     assembly {
        ret := mload(add(key, 32))
     }
   }
   function setActive(string _id, bool _active, string description) onlyEmployees {
         bytes32 realId = convert(_id);
         certificates[realId].active = _active;

        emit SetActive(msg.sender, _id, _active, description);
}

function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }
    function setEmployee (address user) external  onlyCEO {
        employee[user]=true;
    }
    function removeEmployee (address user) external onlyCEO{
        employee[0];
        employee[user] = employee[0];
    }
    //Ver si employee esta agregado
    function getEmployee(address user) public view returns (bool) {
    return employee[user];
    }
    modifier onlyCEO() {
        require(msg.sender == ceoAddress );
        _;
    }
    modifier onlyEmployees() {
        require(employee[msg.sender] == true || msg.sender == ceoAddress);
        _;
    }

}