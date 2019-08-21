pragma solidity ^0.4.8;

contract testingToken {
	mapping (address => uint256) public balanceOf;
	address public owner;
	function testingToken() {
		owner = msg.sender;
		balanceOf[msg.sender] = 1000;
	}
	function send(address _to, uint256 _value) {
		if (balanceOf[msg.sender]<_value) throw;
		if (balanceOf[_to]+_value<balanceOf[_to]) throw;
		if (_value<0) throw;
		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;
	}
}