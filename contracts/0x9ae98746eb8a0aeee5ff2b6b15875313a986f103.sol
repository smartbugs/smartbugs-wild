//! SMS verification contract
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

contract SimpleCertifier is Owned, Certifier {
	modifier only_delegate { if (msg.sender != delegate) return; _; }
	modifier only_certified(address _who) { if (!certs[_who].active) return; _; }

	struct Certification {
		bool active;
		mapping (string => bytes32) meta;
	}

	function certify(address _who) only_delegate {
		certs[_who].active = true;
		Confirmed(_who);
	}
	function revoke(address _who) only_delegate only_certified(_who) {
		certs[_who].active = false;
		Revoked(_who);
	}
	function certified(address _who) constant returns (bool) { return certs[_who].active; }
	function get(address _who, string _field) constant returns (bytes32) { return certs[_who].meta[_field]; }
	function getAddress(address _who, string _field) constant returns (address) { return address(certs[_who].meta[_field]); }
	function getUint(address _who, string _field) constant returns (uint) { return uint(certs[_who].meta[_field]); }
	function setDelegate(address _new) only_owner { delegate = _new; }

	mapping (address => Certification) certs;
	// So that the server posting puzzles doesn't have access to the ETH.
	address public delegate = msg.sender;
}



contract ProofOfSMS is SimpleCertifier {

	modifier when_fee_paid { if (msg.value < fee) return; _; }

	event Requested(address indexed who);
	event Puzzled(address indexed who, bytes32 puzzle);

	function request() payable when_fee_paid {
		if (certs[msg.sender].active)
			return;
		Requested(msg.sender);
	}

	function puzzle(address _who, bytes32 _puzzle) only_delegate {
		puzzles[_who] = _puzzle;
		Puzzled(_who, _puzzle);
	}

	function confirm(bytes32 _code) returns (bool) {
		if (puzzles[msg.sender] != sha3(_code))
			return;
		delete puzzles[msg.sender];
		certs[msg.sender].active = true;
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
		return certs[_who].active;
	}

	mapping (address => bytes32) puzzles;

	uint public fee = 30 finney;
}