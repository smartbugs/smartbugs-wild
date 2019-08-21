pragma solidity ^0.4.11;

contract Owned {
    address public owner;

    modifier onlyOwner() { if (isOwner(msg.sender)) _; }
    modifier ifOwner(address sender) { if (isOwner(sender)) _; }

    function Owned() {
        owner = msg.sender;
    }

    function isOwner(address addr) public returns(bool) {
        return addr == owner;
    }
}

contract DataDump is Owned {
	event DataDumped(address indexed _recipient, string indexed _topic, bytes32 _dataHash);

	function DataDump() {}
	function postData(address recipient, string topic, bytes32 data) onlyOwner() {
		DataDumped(recipient, topic, data);
	}
}