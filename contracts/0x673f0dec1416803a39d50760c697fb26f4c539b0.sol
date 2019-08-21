//! E-mail verification contract
//! By Gav Wood, 2016.

pragma solidity ^0.4.0;

contract Owned {
	modifier only_owner { if (msg.sender != owner) return; _; }

	event NewOwner(address indexed old, address indexed current);

	function setOwner(address _new) only_owner { NewOwner(owner, _new); owner = _new; }

	address public owner = msg.sender;
}

contract Certifier {
	event Confirmed(address indexed who);
	event Revoked(address indexed who);
	function certified(address _who) constant returns (bool);
	function get(address _who, string _field) constant returns (bytes32) {}
	function getAddress(address _who, string _field) constant returns (address) {}
	function getUint(address _who, string _field) constant returns (uint) {}
}

contract ProofOfEmail is Owned, Certifier {
	modifier when_fee_paid { if (msg.value < fee) return; _; }

	event Requested(address indexed who, bytes32 indexed emailHash);
	event Puzzled(address indexed who, bytes32 indexed emailHash, bytes32 puzzle);

	function request(bytes32 _emailHash) payable when_fee_paid {
		Requested(msg.sender, _emailHash);
	}

	function puzzle(address _who, bytes32 _puzzle, bytes32 _emailHash) only_owner {
		puzzles[_puzzle] = _emailHash;
		Puzzled(_who, _emailHash, _puzzle);
	}

	function confirm(bytes32 _code) returns (bool) {
		var emailHash = puzzles[sha3(_code)];
		if (emailHash == 0)
			return;
		delete puzzles[sha3(_code)];
		if (reverse[emailHash] != 0)
			return;
		entries[msg.sender] = emailHash;
		reverse[emailHash] = msg.sender;
		Confirmed(msg.sender);
		return true;
	}

	function setFee(uint _new) only_owner {
		fee = _new;
	}

	function drain() only_owner {
		if (!msg.sender.send(this.balance))
			throw;
	}

	function certified(address _who) constant returns (bool) {
		return entries[_who] != 0;
	}

	function get(address _who, string _field) constant returns (bytes32) {
		entries[_who];
	}

	mapping (address => bytes32) entries;
	mapping (bytes32 => address) public reverse;
	mapping (bytes32 => bytes32) puzzles;

	uint public fee = 0 finney;
}