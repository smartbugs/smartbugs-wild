pragma solidity ^0.4.2;
contract Owned {
    address public owner;
    function Owned() { owner = msg.sender; }
    function delegate(address _owner) onlyOwner
    { owner = _owner; }
    modifier onlyOwner { if (msg.sender != owner) throw; _; }
}
contract Mortal is Owned {
    function kill() onlyOwner
    { suicide(owner); }
}
contract Registrar {
	event Changed(string indexed name);

	function owner(string _name) constant returns (address o_owner);
	function addr(string _name) constant returns (address o_address);
	function subRegistrar(string _name) constant returns (address o_subRegistrar);
	function content(string _name) constant returns (bytes32 o_content);
}
contract AiraRegistrarService is Registrar, Mortal {
	struct Record {
		address addr;
		address subRegistrar;
		bytes32 content;
	}
	
    function owner(string _name) constant returns (address o_owner)
    { return 0; }

	function disown(string _name) onlyOwner {
		delete m_toRecord[_name];
		Changed(_name);
	}

	function setAddr(string _name, address _a) onlyOwner {
		m_toRecord[_name].addr = _a;
		Changed(_name);
	}
	function setSubRegistrar(string _name, address _registrar) onlyOwner {
		m_toRecord[_name].subRegistrar = _registrar;
		Changed(_name);
	}
	function setContent(string _name, bytes32 _content) onlyOwner {
		m_toRecord[_name].content = _content;
		Changed(_name);
	}
	function record(string _name) constant returns (address o_addr, address o_subRegistrar, bytes32 o_content) {
		o_addr = m_toRecord[_name].addr;
		o_subRegistrar = m_toRecord[_name].subRegistrar;
		o_content = m_toRecord[_name].content;
	}
	function addr(string _name) constant returns (address) { return m_toRecord[_name].addr; }
	function subRegistrar(string _name) constant returns (address) { return m_toRecord[_name].subRegistrar; }
	function content(string _name) constant returns (bytes32) { return m_toRecord[_name].content; }

	mapping (string => Record) m_toRecord;
}