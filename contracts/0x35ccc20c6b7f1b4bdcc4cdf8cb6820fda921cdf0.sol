// MarketPay-System-1.2.sol

/*
MarketPay Solidity Libraries
developed by:
	MarketPay.io , 2018
	https://marketpay.io/
	https://goo.gl/kdECQu

v1.2 
	+ Haltable by SC owner
	+ Constructors upgraded to new syntax
	
v1.1 
	+ Upgraded to Solidity 0.4.22
	
v1.0
	+ System functions

*/

pragma solidity ^0.4.22;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

/**
 * @title System
 * @dev Abstract contract that includes some useful generic functions.
 */
contract System {
	using SafeMath for uint256;
	
	address owner;
	
	// **** MODIFIERS

	// @notice To limit functions usage to contract owner
	modifier onlyOwner() {
		if (msg.sender != owner) {
			error('System: onlyOwner function called by user that is not owner');
		} else {
			_;
		}
	}

	// @notice To limit functions usage to contract owner, directly or indirectly (through another contract call)
	modifier onlyOwnerOrigin() {
		if (msg.sender != owner && tx.origin != owner) {
			error('System: onlyOwnerOrigin function called by user that is not owner nor a contract called by owner at origin');
		} else {
			_;
		}
	}
	
	
	// **** FUNCTIONS
	
	// @notice Calls whenever an error occurs, logs it or reverts transaction
	function error(string _error) internal {
		// revert(_error);
		// in case revert with error msg is not yet fully supported
			emit Error(_error);
			// throw;
	}

	// @notice For debugging purposes when using solidity online browser, remix and sandboxes
	function whoAmI() public constant returns (address) {
		return msg.sender;
	}
	
	// @notice Get the current timestamp from last mined block
	function timestamp() public constant returns (uint256) {
		return block.timestamp;
	}
	
	// @notice Get the balance in weis of this contract
	function contractBalance() public constant returns (uint256) {
		return address(this).balance;
	}
	
	// @notice System constructor, defines owner
	constructor() public {
		// This is the constructor, so owner should be equal to msg.sender, and this method should be called just once
		owner = msg.sender;
		
		// make sure owner address is configured
		if(owner == 0x0) error('System constructor: Owner address is 0x0'); // Never should happen, but just in case...
	}
	
	// **** EVENTS

	// @notice A generic error log
	event Error(string _error);

	// @notice For debug purposes
	event DebugUint256(uint256 _data);

}

/**
 * @title Haltable
 * @dev Abstract contract that allows children to implement an emergency stop mechanism.
 */
contract Haltable is System {
	bool public halted;
	
	// **** MODIFIERS

	modifier stopInEmergency {
		if (halted) {
			error('Haltable: stopInEmergency function called and contract is halted');
		} else {
			_;
		}
	}

	modifier onlyInEmergency {
		if (!halted) {
			error('Haltable: onlyInEmergency function called and contract is not halted');
		} {
			_;
		}
	}

	// **** FUNCTIONS
	
	// called by the owner on emergency, triggers stopped state
	function halt() external onlyOwner {
		halted = true;
		emit Halt(true, msg.sender, timestamp()); // Event log
	}

	// called by the owner on end of emergency, returns to normal state
	function unhalt() external onlyOwner onlyInEmergency {
		halted = false;
		emit Halt(false, msg.sender, timestamp()); // Event log
	}
	
	// **** EVENTS
	// @notice Triggered when owner halts contract
	event Halt(bool _switch, address _halter, uint256 _timestamp);
}
 // Voting-1.4.sol

/*
Voting Smart Contracts v1.4
developed by:
	MarketPay.io , 2017-2018
	https://marketpay.io/
	https://goo.gl/kdECQu

v1.5 https://gitlab.com/lemonandmarket/third.io.marketpay.alcobendas/blob/master/contracts/Voting.sol
	+ new eVotingStatus
	+ Teller can endTesting() and reset all test votes
	+ Added full scan of tellers endpoint

v1.4 https://gist.github.com/computerphysicslab/7a92baf53a66e6b6f104b9daf19ab33a
	+ grantTeller should call grantOracle
	+ remove constrain on voter being registered to vote (teller should check that a posteriori)
	+ store voter pubkey when registered and endpoint to query it, getVoterPubKey()
	+ System library
	+ function isACitizen() to public
	
v1.3 https://gist.github.com/computerphysicslab/106a25a062cb611685b5f36abf1a3eea
	+ Tellers contract records public key of tellers, in order to voters send their votes ciphered for the tellers

v1.2 https://gist.github.com/computerphysicslab/057c10515b38f0dcacdbd5d3cb6e9d61
	+ Tellers contract is actually another instance of Oracle contract
	+ Tellers only can close the poll
	+ SC Owner defines tellers

v1.1 https://gist.github.com/computerphysicslab/c592bbe6d4ad56a11b39bae31852f17c
	+ Oracles contract
	+ Oracles only are allowed to grantVote
	+ SC Owner defines oracles

v1.0 https://gist.github.com/computerphysicslab/39a7a8bc2c364d4a17c5ef0362904aeb
	+ Storage of votes
	+ Poll closes on deadline
	+ Forbid double vote
	+ Oracle grants whitelist of addresses to vote
	+ Full scan query of votes
*/


/**
 * @title Oracles
 * @dev This contract is used to validate Oracles
 */
contract Oracles is Haltable {
	// **** DATA
	struct oracle {
		uint256 oracleId;
		bool oracleAuth;
		address oracleAddress;
	}
	mapping (address => oracle) oracleData;
	mapping (uint256 => address) oracleAddressById; // indexed oracles so as to be fully scannable
	uint256 lastId;


	// **** METHODS

	// Checks whether a given user is an authorized oracle
	function isOracle(address _oracle) public constant returns (bool) {
		return (oracleData[_oracle].oracleAuth);
	}

	function newOracle(address _oracle) internal onlyOwner returns (uint256 id) {
		// Update Index
		id = ++lastId;
		oracleData[_oracle].oracleId = id;
		oracleData[_oracle].oracleAuth = false;
		oracleData[_oracle].oracleAddress = _oracle;
		oracleAddressById[id] = _oracle;

		emit NewOracle(_oracle, id, timestamp()); // Event log
	}

	function grantOracle(address _oracle) public onlyOwner {
		// Checks whether this user has been previously added as an oracle
		uint256 id;
		if (oracleData[_oracle].oracleId > 0) {
			id = oracleData[_oracle].oracleId;
		} else {
			id = newOracle(_oracle);
		}

		oracleData[_oracle].oracleAuth = true;

		emit GrantOracle(_oracle, id, timestamp()); // Event log
	}

	function revokeOracle(address _oracle) external onlyOwner {
		oracleData[_oracle].oracleAuth = false;

		emit RevokeOracle(_oracle, timestamp()); // Event log
	}

	// Queries the oracle, knowing the address
	function getOracleByAddress(address _oracle) public constant returns (uint256 _oracleId, bool _oracleAuth, address _oracleAddress) {
		return (oracleData[_oracle].oracleId, oracleData[_oracle].oracleAuth, oracleData[_oracle].oracleAddress);
	}

	// Queries the oracle, knowing the id
	function getOracleById(uint256 id) public constant returns (uint256 _oracleId, bool _oracleAuth, address _oracleAddress) {
		return (getOracleByAddress(oracleAddressById[id]));
	}


	// **** EVENTS

	// Triggered when a new oracle is created
	event NewOracle(address indexed _who, uint256 indexed _id, uint256 _timestamp);

	// Triggered when a user is granted to become an oracle
	event GrantOracle(address indexed _who, uint256 indexed _id, uint256 _timestamp);

	// Triggered when a user is revoked for being an oracle
	event RevokeOracle(address indexed _who, uint256 _timestamp);
}

  // Voting-1.4.sol

/*
Voting Smart Contracts v1.4
developed by:
	MarketPay.io , 2017-2018
	https://marketpay.io/
	https://goo.gl/kdECQu

v1.5 https://gitlab.com/lemonandmarket/third.io.marketpay.alcobendas/blob/master/contracts/Voting.sol
	+ new eVotingStatus
	+ Teller can endTesting() and reset all test votes
	+ Added full scan of tellers endpoint

v1.4 https://gist.github.com/computerphysicslab/7a92baf53a66e6b6f104b9daf19ab33a
	+ grantTeller should call grantOracle
	+ remove constrain on voter being registered to vote (teller should check that a posteriori)
	+ store voter pubkey when registered and endpoint to query it, getVoterPubKey()
	+ System library
	+ function isACitizen() to public
	
v1.3 https://gist.github.com/computerphysicslab/106a25a062cb611685b5f36abf1a3eea
	+ Tellers contract records public key of tellers, in order to voters send their votes ciphered for the tellers

v1.2 https://gist.github.com/computerphysicslab/057c10515b38f0dcacdbd5d3cb6e9d61
	+ Tellers contract is actually another instance of Oracle contract
	+ Tellers only can close the poll
	+ SC Owner defines tellers

v1.1 https://gist.github.com/computerphysicslab/c592bbe6d4ad56a11b39bae31852f17c
	+ Oracles contract
	+ Oracles only are allowed to grantVote
	+ SC Owner defines oracles

v1.0 https://gist.github.com/computerphysicslab/39a7a8bc2c364d4a17c5ef0362904aeb
	+ Storage of votes
	+ Poll closes on deadline
	+ Forbid double vote
	+ Oracle grants whitelist of addresses to vote
	+ Full scan query of votes
*/





/**
 * @title Tellers
 * @dev This contract is used to validate Tellers that can read ciphered votes and close the voting process
 */
contract Tellers is Oracles {
	// **** DATA
	address[] public tellersArray; // full scan of tellers
	mapping (address => bytes) public pubKeys;
	bytes[] public pubKeysArray; // full scan of tellers' pubkeys

	function grantTeller(address _teller, bytes _pubKey) external onlyOwner {
		// Checks whether this user has been previously added as a teller
		if (keccak256(pubKeys[_teller]) != keccak256("")) { // A workaround to bytes comparison: if (pubKeys[_teller] != '') ...
			error('grantTeller: This teller is already granted');
		}

		tellersArray.push(_teller);
		pubKeys[_teller] = _pubKey;
		pubKeysArray.push(_pubKey);

		grantOracle(_teller); // A teller inherits oracle behaviour

		emit GrantTeller(_teller, _pubKey, timestamp()); // Event log
	}

	// Triggered when a user is granted to become a teller
	event GrantTeller(address indexed _who, bytes _pubKey, uint256 _timestamp);
}


  // Voting-1.4.sol

/*
Voting Smart Contracts v1.4
developed by:
	MarketPay.io , 2017-2018
	https://marketpay.io/
	https://goo.gl/kdECQu

v1.5 https://gitlab.com/lemonandmarket/third.io.marketpay.alcobendas/blob/master/contracts/Voting.sol
	+ new eVotingStatus
	+ Teller can endTesting() and reset all test votes
	+ Added full scan of tellers endpoint

v1.4 https://gist.github.com/computerphysicslab/7a92baf53a66e6b6f104b9daf19ab33a
	+ grantTeller should call grantOracle
	+ remove constrain on voter being registered to vote (teller should check that a posteriori)
	+ store voter pubkey when registered and endpoint to query it, getVoterPubKey()
	+ System library
	+ function isACitizen() to public
	
v1.3 https://gist.github.com/computerphysicslab/106a25a062cb611685b5f36abf1a3eea
	+ Tellers contract records public key of tellers, in order to voters send their votes ciphered for the tellers

v1.2 https://gist.github.com/computerphysicslab/057c10515b38f0dcacdbd5d3cb6e9d61
	+ Tellers contract is actually another instance of Oracle contract
	+ Tellers only can close the poll
	+ SC Owner defines tellers

v1.1 https://gist.github.com/computerphysicslab/c592bbe6d4ad56a11b39bae31852f17c
	+ Oracles contract
	+ Oracles only are allowed to grantVote
	+ SC Owner defines oracles

v1.0 https://gist.github.com/computerphysicslab/39a7a8bc2c364d4a17c5ef0362904aeb
	+ Storage of votes
	+ Poll closes on deadline
	+ Forbid double vote
	+ Oracle grants whitelist of addresses to vote
	+ Full scan query of votes
*/




/**
 * @title Voting
 * @dev This contract is used to store votes
 */
contract Voting is Haltable {
	// **** DATA
	mapping (address => string) votes;
	uint256 public numVotes;

	mapping (address => bool) allowed; // Only granted addresses are allowed to issue a vote in the poll
	address[] votersArray;
	uint256 public numVoters;

	uint256 public deadline;
	eVotingStatus public VotingStatus; // Tellers are allowed to close the poll
	enum eVotingStatus { Test, Voting, Closed }


	Oracles public SCOracles; // Contract that defines who is an oracle. Oracles allow wallets to vote
	Tellers public SCTellers; // Contract that defines who is a teller. Tellers are allowed to close the poll and have an associated pubKey stored on contract

	mapping (address => bytes) public pubKeys; // Voters' pubkeys


	// **** MODIFIERS
	modifier votingClosed() { if (now >= deadline || VotingStatus == eVotingStatus.Closed) _; }
	modifier votingActive() { if (now < deadline && VotingStatus != eVotingStatus.Closed) _; }

	// To limit voteGranting function just to authorized oracles
	modifier onlyOracle() {
		if (!SCOracles.isOracle(msg.sender)) {
			error('onlyOracle function called by user that is not an authorized oracle');
		} else {
			_;
		}
	}

	// To limit closeVoting function just to authorized tellers
	modifier onlyTeller() {
		if (!SCTellers.isOracle(msg.sender)) {
			error('onlyTeller function called by user that is not an authorized teller');
		} else {
			_;
		}
	}


	// **** METHODS
	constructor(address _SCOracles, address _SCTellers) public {
		SCOracles = Oracles(_SCOracles);
		SCTellers = Tellers(_SCTellers);
		deadline = now + 60 days;
		VotingStatus = eVotingStatus.Test;
	}

	function pollStatus() public constant returns (eVotingStatus) {
		if (now >= deadline) {
			return eVotingStatus.Closed;
		}
		return VotingStatus;
	}

	function isACitizen(address _voter) public constant returns (bool) {
		if (allowed[_voter]) {
			return true;
		} else {
			return false;
		}
	}

	function amIACitizen() public constant returns (bool) {
		return (isACitizen(msg.sender));
	}

	function canItVote(address _voter) internal constant returns (bool) {
		if (bytes(votes[_voter]).length == 0) {
			return true;
		} else {
			return false;
		}
	}

	function canIVote() public constant returns (bool) {
		return (canItVote(msg.sender));
	}

	function sendVote(string _vote) votingActive public returns (bool) {
		// Check whether voter has not previously casted a vote
		if (!canIVote()) {
			error('sendVote: sender cannot vote because it has previously casted another vote');
			return false;
		}

		// Check whether vote is not empty
		if (bytes(_vote).length < 1) {
			error('sendVote: vote is empty');
			return false;
		}

		// Cast the vote
		votes[msg.sender] = _vote;
		numVotes ++;

		emit SendVote(msg.sender, _vote); // Event log

		return true;
	}

	function getVoter(uint256 _idVoter) /* votingClosed */ public constant returns (address) {
		return (votersArray[_idVoter]);
	}

	function readVote(address _voter) /* votingClosed */ public constant returns (string) {
		return (votes[_voter]);
	}

	// Low level grantVoter w/o pubKey, avoid adding the same voter twice
	function _grantVoter(address _voter) onlyOracle public {
		if(!allowed[_voter]) {
			allowed[_voter] = true;
			votersArray.push(_voter);
			numVoters ++;

			emit GrantVoter(_voter); // Event log
		}
	}

	// New endpoint that sets pubKey as well
	function grantVoter(address _voter, bytes _pubKey) onlyOracle public {
		_grantVoter(_voter);

		pubKeys[_voter] = _pubKey;
	}

	function getVoterPubKey(address _voter) public constant returns (bytes) {
		return (pubKeys[_voter]);
	}

	function closeVoting() onlyTeller public {
		VotingStatus = eVotingStatus.Closed;

		emit CloseVoting(true); // Event log
	}

	function endTesting() onlyTeller public {
		numVotes = 0;
		uint256 l = votersArray.length;
		for(uint256 i = 0;i<l;i++) {
			delete votes[votersArray[i]];
		}
		VotingStatus = eVotingStatus.Voting;
	}

	// fallback function. This SC doesn't accept any Ether
	function () payable public {
		revert();
	}


	// **** EVENTS
	// Triggered when a voter issues a vote
	event SendVote(address indexed _from, string _vote);

	// Triggered when a voter is granted by the Oracle
	event GrantVoter(address indexed _voter);

	// Triggered when Contract Owner closes the voting
	event CloseVoting(bool _VotingClosed);
}