pragma solidity ^0.5.0;

contract Prize {
	event Commit(address sender, uint revealable);

	bytes32 private flagHash;

	mapping(address => bytes32) private commits;
	mapping(address => uint) private revealable;

	constructor(bytes32 _flagHash) public payable {
		flagHash = _flagHash;
	}

	function commit(bytes32 commitment) external {
		commits[msg.sender] = commitment;
		emit Commit(msg.sender, revealable[msg.sender] = block.number + 128);
	}
	function reveal(bytes32 flag) external {
		require(calcFlagHash(flag) == flagHash);
		require(calcCommitment(flag, msg.sender) == commits[msg.sender]);
		require(block.number >= revealable[msg.sender]);
		selfdestruct(msg.sender);
	}

	function calcFlagHash(bytes32 flag) public pure returns(bytes32) {
		return keccak256(abi.encodePacked(flag));
	}
	function calcCommitment(bytes32 flag, address sender) public pure returns(bytes32) {
		return keccak256(abi.encodePacked(flag, sender));
	}
}