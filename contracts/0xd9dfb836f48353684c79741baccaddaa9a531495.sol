pragma solidity ^0.4.8;

/// @title Oracle contract where m of n predetermined voters determine a value
contract FederatedOracleBytes8 {
    struct Voter {
        bool isVoter;
        bool hasVoted;
    }

    event VoterAdded(address account);
    event VoteSubmitted(address account, bytes8 value);
    event ValueFinalized(bytes8 value);

    mapping(address => Voter) public voters;
    mapping(bytes8 => uint8) public votes;

    uint8 public m;
    uint8 public n;
    bytes8 public finalValue;

    uint8 private voterCount;
    address private creator;

    function FederatedOracleBytes8(uint8 m_, uint8 n_) {
        creator = msg.sender;
        m = m_;
        n = n_;
    }

    function addVoter(address account) {
        if (msg.sender != creator) {
            throw;
        }
        if (voterCount == n) {
            throw;
        }

        var voter = voters[account];
        if (voter.isVoter) {
            throw;
        }

        voter.isVoter = true;
        voterCount++;
        VoterAdded(account);
    }

    function submitValue(bytes8 value) {
        var voter = voters[msg.sender];
        if (!voter.isVoter) {
            throw;
        }
        if (voter.hasVoted) {
            throw;
        }

        voter.hasVoted = true;
        votes[value]++;
        VoteSubmitted(msg.sender, value);

        if (votes[value] == m) {
            finalValue = value;
            ValueFinalized(value);
        }
    }
}