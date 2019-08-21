pragma solidity ^0.4.15;

/*
author : dungeon_master
*/

contract Bounty {
    // Track if the bounty has been already paid.
    bool public bounty_paid = false;
    // Track the total number of donors.
    uint256 public count_donors = 0;
    // Stores the amount given by every donor.
    mapping (address => uint256) public balances;
    // Stores the donor status.
    mapping (address => bool) public has_donated;
    // Stores the voting state.
    mapping (address => bool) public has_voted;

    address public proposed_beneficiary = 0x0;
    uint256 public votes_for = 0;
    uint256 public votes_against = 0;

    bytes32 hash_pwd = 0x1a78e83f94c1bc28c54cfed1fe337e04c31732614ec822978d804283ef6a60c3;

    modifier onlyDonor {
        require(!bounty_paid);
        require(has_donated[msg.sender]);
        // The rest of the function is inserted where the _; is.
        _;
    }


    // Paying the tipper.
    function payout(string _password) {
        require(keccak256(_password) == hash_pwd);
        require(!bounty_paid);
        require(proposed_beneficiary != 0x0);
        // To change, maybe. Find a way to use a ratio.
        require(votes_for > votes_against);
        // Minimum of 80% of the donors must have voted.
        require(votes_for+votes_against > count_donors*8/10);
        bounty_paid = true;
        proposed_beneficiary.transfer(this.balance);

    }

    function propose_beneficiary(address _proposed) onlyDonor {
        // Updates the proposed_beneficiary variable.
        proposed_beneficiary = _proposed;
        // Resets the voting counts.
        votes_for = 0;
        votes_against = 0;

    }

    // Allow to vote for the proposed_beneficiary by passing "yes" or "no" in the function.
    // Any other string won't be counted.
    function vote_beneficiary(string _vote) onlyDonor {
        require(!has_voted[msg.sender]);
        require(proposed_beneficiary != 0x0);
        if (keccak256(_vote) == keccak256("yes")) {
            votes_for += 1;
            has_voted[msg.sender] = true;
        }
        if (keccak256(_vote) == keccak256("no")) {
            votes_against += 1;
            has_voted[msg.sender] = true;
        }
    }

    // Allow donors to withdraw their donations.
    function refund() onlyDonor {
        // Calling a refund withdraws you from the voters
        has_donated[msg.sender] = false;
        count_donors -= 1;

        // Store the user's balance prior to withdrawal in a temporary variable.
        uint256 eth_to_withdraw = balances[msg.sender];
        
        // Update the user's balance prior to sending ETH to prevent recursive call.
        balances[msg.sender] = 0;
        
        // Return the user's funds.  Throws on failure to prevent loss of funds.
        msg.sender.transfer(eth_to_withdraw);
    }

    // Default function. Called whenever someone sent ETH to the contract.
    function () payable {
        // Disallow sending if the bounty is already paid.
        require(!bounty_paid);
        // Maximum 50 donors are allowed.
        require(count_donors < 51);
        // Minimum donation to avoid trolls.
        require(msg.value >= 0.1 ether);
        //If you haven't donated before, you are added and counted as a new donor.
        if (!has_donated[msg.sender]) {
            has_donated[msg.sender] = true;
            count_donors += 1;
        } 
        balances[msg.sender] += msg.value;
    }
}