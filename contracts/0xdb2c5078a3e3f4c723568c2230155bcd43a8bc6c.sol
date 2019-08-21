pragma solidity ^0.4.11;

contract Certificate {
  struct Subject {
    uint id;            
    address validate_hash; 
    uint birthday;      
    string fullname;   
    uint8 gender;       
    uint dt_sign;       
    uint dt_cancel;    
  }
  uint8 type_id;   
  uint dt_create; 
  address[] subjects_addr; 
  mapping (address => Subject) subjects;
  address _owner;       

  function Certificate(uint8 _type_id, uint _dt_create, address[] _subjects_addr) public {
    type_id = _type_id;
    dt_create = _dt_create;
    subjects_addr = _subjects_addr;
    _owner = msg.sender;
  }

  modifier restricted_to_subject {
      bool allowed = false;
      for(uint i = 0; i < subjects_addr.length; i++) {
        if (msg.sender == subjects_addr[i]) {
          allowed = true;
          break;
        }
      }
      if (subjects[msg.sender].dt_sign != 0 || allowed == false) {
        revert();
      }
      _;
  }

  function Sign(uint _id, address _validate_hash, uint _birthday, uint8 _gender, uint _dt_sign, string _fullname) public restricted_to_subject payable {
    subjects[msg.sender] = Subject(_id, _validate_hash, _birthday, _fullname, _gender, _dt_sign, 0);
    if(msg.value != 0)
      _owner.transfer(msg.value);
  }

  function getSubject(uint index) public constant returns (uint _id, address _validate_hash, uint _birthday, string _fullname, uint8 _gender, uint _dt_sign, uint _dt_cancel) {
    _id = subjects[subjects_addr[index]].id;
    _validate_hash = subjects[subjects_addr[index]].validate_hash;
    _birthday = subjects[subjects_addr[index]].birthday;
    _fullname = subjects[subjects_addr[index]].fullname;
    _gender = subjects[subjects_addr[index]].gender;
    _dt_sign = subjects[subjects_addr[index]].dt_sign;
    _dt_cancel = subjects[subjects_addr[index]].dt_cancel;
  }

  function getCertificate() public constant returns (uint8 _type_id, uint _dt_create, uint _subjects_count) {
    _type_id = type_id;
    _dt_create = dt_create;
    _subjects_count = subjects_addr.length;
  }
}