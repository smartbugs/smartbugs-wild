pragma solidity ^0.4.7;
contract DXContracts {

  struct Contract {
    string contractName;
    string contractDescription;
    uint index;
    bytes32 sha256sum;
    address[] signers;
    uint timeStamp;
    mapping (address=>bool) hasSigned;
    mapping (address=>string) signerName;
    bool sealed;
    uint numberAlreadySigned;
  }
  Contract[] public contracts;
    
    
  function getContractSigners(bytes32 _shasum) constant returns(address[], string, string, uint)
    {
        return (contracts[contractIndex[_shasum]].signers, contracts[contractIndex[_shasum]].contractName, contracts[contractIndex[_shasum]].contractDescription, contracts[contractIndex[_shasum]].numberAlreadySigned);
    }
    
  function checkIfSignedBy(bytes32 _shasum, address _signer) constant returns(bool)
    {
        uint index=contractIndex[_shasum];
        return (contracts[index].hasSigned[_signer]);
    }
    
  mapping (bytes32=>uint) public contractIndex;
 
  mapping (address=>bool) isAdmin;
     
  function DXContracts()
  {
    isAdmin[msg.sender]=true;
    contracts.length++;
  }
     
  function addAdmin(address _new_admin) onlyAdmin
  {
    isAdmin[_new_admin]=true;
  }
     
  function removeAdmin(address _old_admin) onlyAdmin
  {
    isAdmin[_old_admin]=false;
  }
 
  modifier onlyAdmin
  {
    if (!isAdmin[msg.sender]) throw;
    _;
  }
 
    event newContract(string name, address[] signers, string description, bytes32 sha256sum, uint index);
  function submitNewContract(string _name, address[] _signers, string _description, bytes32 _sha256sum) onlyAdmin
  {
    
    if (contractIndex[_sha256sum]!=0) throw;
    if (_signers.length==0) throw;
    contractIndex[_sha256sum]=contracts.length;
    contracts.push(Contract(_name, _description, contractIndex[_sha256sum], _sha256sum, _signers, now, false, 0));
    newContract(_name, _signers, _description, _sha256sum, contractIndex[_sha256sum]);
  }
    
    
    event signature(string name, address signer, bytes32 sha256sum);
    event sealed(uint index, bytes32 sha256sum);

  function signContract(bytes32 _sha256sum, string _my_name, bool _I_accept) returns (bool)
  {
    uint index=contractIndex[_sha256sum];
    if (contracts[index].sealed) throw;
    bool isSigner;
    for (uint k=0; k<contracts[index].signers.length; k++)
    {
        if (contracts[index].signers[k]==msg.sender) isSigner=true;
    }
    if (isSigner==false) throw;
    if (!_I_accept) throw;
    if (index==0) throw;
    else
      {
	if (!contracts[index].hasSigned[msg.sender])
	  {
	    contracts[index].numberAlreadySigned++;
	  }
	contracts[index].hasSigned[msg.sender]=true;
	contracts[index].signerName[msg.sender]=_my_name;
	signature(_my_name, msg.sender, _sha256sum);
	if (contracts[index].numberAlreadySigned==contracts[index].signers.length)
	  {
	    contracts[index].sealed=true;
	    sealed(index, _sha256sum);
	  }
	return true;
      }

  }
 
 
}