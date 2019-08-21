pragma solidity >= 0.4.24;

contract against_NS_for_IPFS {
    mapping(bytes32 => string) public nsname;
	
    string public name = "AGAINST NS";
    string public symbol = "AGAINST";
    string public comment = "AGAINST NS for IPFS";
    address internal owner;
	
	constructor() public {
       owner = address(msg.sender); 
    }
	
	function setNS(bytes32 _nsname,string _hash) public {
	   if (msg.sender == owner) {
	     nsname[_nsname] = _hash;
	   }
	}
}