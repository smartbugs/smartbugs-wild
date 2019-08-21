pragma solidity 0.4.4;

contract AddressNames{

	mapping(address => string) addressNames;
	address[] namedAddresses;

	function setName(string name){
		_setNameToAddress(msg.sender,name);
	}

	function hasName(address who) constant returns (bool hasAName){
		hasAName = _hasName(who);
	}

	function getName(address who) constant returns (string name){
		name = addressNames[who];
	}
	
	function getNamedAddresses() constant returns (address[] addresses){
		addresses = namedAddresses;
	}

	function _setNameToAddress(address who, string name) internal returns (bool valid){
		if (bytes(name).length < 3){
		valid = false;
		}

		if (!_hasName(who)){
			namedAddresses.push(who);
		}
		addressNames[msg.sender] = name;
		
		valid = true;
	}

	function _hasName(address who) internal returns (bool hasAName){
		hasAName = bytes(addressNames[who]).length != 0;
	}

}