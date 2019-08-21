pragma solidity ^0.4.11;
//"0x64C222d300d5f978D9867fA20C5C59b6B2c849aF","9F86D081884C7D659A2FEAA0C55AD015A3BF4F1B2B0B822CD15D6C15B0F00A08","1","0"
contract CertiMe {
    // Defines a new type with two fields.
    struct Certificate {
        string certHash;
        address issuer_addr;
        address recepient_addr;
        string version;
        string content;
    }

    uint numCerts;
    mapping (uint => Certificate) public certificates;
    mapping (string => Certificate) certHashKey;

    function newCertificate(address beneficiary, string certHash, string version, string content ) public returns (uint certID) {
        certID = ++numCerts; // campaignID is return variable
        // Creates new struct and saves in storage. We leave out the mapping type.
        certificates[certID] = Certificate(certHash,msg.sender,beneficiary, version,content);
        certHashKey[certHash]=certificates[certID];
    }
/*
    function contribute(uint campaignID) public payable {
        Campaign storage c = campaigns[campaignID];
        // Creates a new temporary memory struct, initialised with the given values
        // and copies it over to storage.
        // Note that you can also use Funder(msg.sender, msg.value) to initialise.
        c.funders[c.numFunders++] = CertIssuer({addr: msg.sender, amount: msg.value});
        c.amount += msg.value;
    }
*/
  /*  
    function certHashExist(string value) constant returns (uint) {
        for (uint i=1; i<numCerts+1; i++) {
              if(stringsEqual(certificates[i].certHash,value)){
                return i;
              }
        }
        
        return 0;
    }*/
    function getMatchCountAddress(uint addr_type,address value) public constant returns (uint){
        uint counter = 0;
        for (uint i=1; i<numCerts+1; i++) {
              if((addr_type==0&&certificates[i].issuer_addr==value)||(addr_type==1&&certificates[i].recepient_addr==value)){
                counter++;
              }
        }        
        return counter;
    }
    function getCertsByIssuer(address value) public constant returns (uint[]) {
        uint256[] memory matches=new uint[](getMatchCountAddress(0,value));
        uint matchCount=0;
        for (uint i=1; i<numCerts+1; i++) {
              if(certificates[i].issuer_addr==value){
                matches[matchCount++]=i;
              }
        }
        
        return matches;
    }
    function getCertsByRecepient(address value) public constant returns (uint[]) {
        uint256[] memory matches=new uint[](getMatchCountAddress(1,value));
        uint matchCount=0;
        for (uint i=1; i<numCerts+1; i++) {
              if(certificates[i].recepient_addr==value){
                matches[matchCount++]=i;
              }
        }
        
        return matches;
    }   

    function getMatchCountString(uint string_type,string value) public constant returns (uint){
        uint counter = 0;
        for (uint i=1; i<numCerts+1; i++) {
              if(string_type==0){
                if(stringsEqual(certificates[i].certHash,value)){
                    counter++;
                }
              }
              if(string_type==1){
                if(stringsEqual(certificates[i].version,value)){
                    counter++;
                }
              }
              if(string_type==2){
                if(stringsEqual(certificates[i].content,value)){
                    counter++;
                }
              }
        }        
        return counter;
    }
    
    function getCertsByProof(string value) public constant returns (uint[]) {
        uint256[] memory matches=new uint[](getMatchCountString(0,value));
        uint matchCount=0;
        for (uint i=1; i<numCerts+1; i++) {
              if(stringsEqual(certificates[i].certHash,value)){
                matches[matchCount++]=i;
              }
        }
        
        return matches;
    }    
    function getCertsByVersion(string value) public constant returns (uint[]) {
        uint256[] memory matches=new uint[](getMatchCountString(1,value));
        uint matchCount=0;
        for (uint i=1; i<numCerts+1; i++) {
              if(stringsEqual(certificates[i].version,value)){
                matches[matchCount++]=i;
              }
        }
        
        return matches;
    }
    function getCertsByContent(string value) public constant returns (uint[]) {
        uint256[] memory matches=new uint[](getMatchCountString(2,value));
        uint matchCount=0;
        for (uint i=1; i<numCerts+1; i++) {
              if(stringsEqual(certificates[i].content,value)){
                matches[matchCount++]=i;
              }
        }
        
        return matches;
    }
    
/*    function getCertIssuer(string key) constant returns (address,address,string,string) {
         return (certHashKey[key].issuer_addr,certHashKey[key].recepient_addr,certHashKey[key].version,certHashKey[key].content);
    }
*/
    
	function stringsEqual(string storage _a, string memory _b) internal constant returns (bool) {
		bytes storage a = bytes(_a);
		bytes memory b = bytes(_b);
		if (a.length != b.length)
			return false;
		// @todo unroll this loop
		for (uint i = 0; i < a.length; i ++)
			if (a[i] != b[i])
				return false;
		return true;
	}    
    
}