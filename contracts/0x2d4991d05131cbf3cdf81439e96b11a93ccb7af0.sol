pragma solidity ^0.4.4;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract GoFreakingDoIt is Ownable {
    struct Goal {
    	bytes32 hash;
        address owner; // goal owner addr
        string description; // set goal description
        uint amount; // set goal amount
        string supervisorEmail; // email of friend
        string creatorEmail; // email of friend
        string deadline;
        bool emailSent;
        bool completed;
    }

    // address owner;
	mapping (bytes32 => Goal) public goals;
	Goal[] public activeGoals;

	// Events
    event setGoalEvent (
    	address _owner,
        string _description,
        uint _amount,
        string _supervisorEmail,
        string _creatorEmail,
        string _deadline,
        bool _emailSent,
        bool _completed
    );

    event setGoalSucceededEvent(bytes32 hash, bool _completed);
    event setGoalFailedEvent(bytes32 hash, bool _completed);

	// app.setGoal("Finish cleaning", "hello@karolisram.com", "hello@karolisram.com", "2017-12-12", {value: web3.toWei(11.111, 'ether')})
	// app.setGoal("Finish cleaning", "hello@karolisram.com", "hello@karolisram.com", "2017-12-12", {value: web3.toWei(11.111, 'ether'), from: web3.eth.accounts[1]})
	function setGoal(string _description, string _supervisorEmail, string _creatorEmail, string _deadline) payable returns (bytes32, address, string, uint, string, string, string) {
		require(msg.value > 0);
		require(keccak256(_description) != keccak256(''));
		require(keccak256(_creatorEmail) != keccak256(''));
		require(keccak256(_deadline) != keccak256(''));

		bytes32 hash = keccak256(msg.sender, _description, msg.value, _deadline);

		Goal memory goal = Goal({
			hash: hash,
			owner: msg.sender,
			description: _description,
			amount: msg.value,
			supervisorEmail: _supervisorEmail,
			creatorEmail: _creatorEmail,
			deadline: _deadline,
			emailSent: false,
			completed: false
		});

		goals[hash] = goal;
		activeGoals.push(goal);

		setGoalEvent(goal.owner, goal.description, goal.amount, goal.supervisorEmail, goal.creatorEmail, goal.deadline, goal.emailSent, goal.completed);

		return (hash, goal.owner, goal.description, goal.amount, goal.supervisorEmail, goal.creatorEmail, goal.deadline);
	}

	function getGoalsCount() constant returns (uint count) {
	    return activeGoals.length;
	}

	// app.setEmailSent("0x00f2484d16ad04b395c6261b978fb21f0c59210d98e9ac361afc4772ab811393", {from: web3.eth.accounts[1]})
	function setEmailSent(uint _index, bytes32 _hash) onlyOwner {
		assert(goals[_hash].amount > 0);

		goals[_hash].emailSent = true;
		activeGoals[_index].emailSent = true;
	}

	function setGoalSucceeded(uint _index, bytes32 _hash) onlyOwner {
		assert(goals[_hash].amount > 0);

		goals[_hash].completed = true;
		activeGoals[_index].completed = true;

		goals[_hash].owner.transfer(goals[_hash].amount); // send ether back to person who set the goal

		setGoalSucceededEvent(_hash, true);
	}

	// app.setGoalFailed(0, '0xf7a1a8aa52aeaaaa353ab49ab5cd735f3fd02598b4ff861b314907a414121ba4')
	function setGoalFailed(uint _index, bytes32 _hash) {
		assert(goals[_hash].amount > 0);
		// assert(goals[_hash].emailSent == true);

		goals[_hash].completed = false;
		activeGoals[_index].completed = false;

		owner.transfer(goals[_hash].amount); // send ether to contract owner

		setGoalFailedEvent(_hash, false);
	}

	// Fallback function in case someone sends ether to the contract so it doesn't get lost
	function() payable {}

    function kill() onlyOwner { 
    	selfdestruct(owner);
    }
}