contract ValidetherOracle {

  //  Name of the institution to Ethereum address of the institution
  mapping (string => address) nameToAddress;
    //  Ethereum address of the institution to Name of the institution
  mapping (address => string) addressToName;

  address admin;

  modifier onlyAdmin {
     if (msg.sender != admin) throw;
     _
  }

  /*
    Constructor Function
  */
  function ValidetherOracle() {
    admin = msg.sender;
  }

  /*
    Function which adds an institution
    */
  function addInstitution(address institutionAddress, string institutionName) onlyAdmin {
    nameToAddress[institutionName] = institutionAddress;
    addressToName[institutionAddress] = institutionName;
  }

  /*
    Function which validates an institution address and returns its name
    @param institutionAddress Ethereum Address of the institution
    @return "" if the address is not valid and the institution name if the address is valid.
    */
  function getInstitutionByAddress(address institutionAddress) constant returns(string) {
    return addressToName[institutionAddress];
  }

  /*
    Function which validates an institution name and returns its address
    @param institutionName Name of the institution
    @return 0x0000000000000000000000000000000000000000 if the name is not valid and the institution Ethereum Address if the name is valid.
  */
  function getInstitutionByName(string institutionName) constant returns(address) {
    return nameToAddress[institutionName];
  }

  /*
    Function which changes the admin address of the contract
    @param newAdmin Ethereum address of the new admin
  */
  function setNewAdmin(address newAdmin) onlyAdmin {
    admin = newAdmin;
  }

}