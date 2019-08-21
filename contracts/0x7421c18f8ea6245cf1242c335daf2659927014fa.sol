pragma solidity ^0.4.10;

contract PingContract {
	function ping() returns (uint) {
		return pingTimestamp();
	}
	
	function pingTimestamp() returns (uint) {
		return block.timestamp;
	}
	
	function pingBlock() returns (uint) {
		return block.number;
	}
}