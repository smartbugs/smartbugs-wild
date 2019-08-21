pragma solidity 0.4.4;

contract AddressNames{

	mapping(address => string) addressNames;

	function setName(string name){
		if(bytes(name).length >= 3){
			addressNames[msg.sender] = name;
		}
	}

	function hasName(address who) constant returns (bool hasAName){
		hasAName = bytes(addressNames[who]).length != 0;
	}

	function getName(address who) constant returns (string name){
		name = addressNames[who];
	}
}