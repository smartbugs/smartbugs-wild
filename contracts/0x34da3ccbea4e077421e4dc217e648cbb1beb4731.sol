pragma solidity ^0.4.18;

contract Voting {
  address creator; // The address of the account that created this ballot.

  mapping (bytes32 => uint8) public votesReceived;
  mapping (address => bytes32) public votes;

  bytes32[] public candidateList;
  uint16 public totalVotes;
  bool public votingFinished;

  function Voting(bytes32[] candidateNames) public {
    creator = msg.sender;
    candidateList = candidateNames;
  }

  function totalVotesFor(bytes32 candidate) view public returns (uint8) {
    require(validCandidate(candidate));
    require(votingFinished);  // Don't reveal votes until voting is finished
    return votesReceived[candidate];
  }

  function numCandidates() public constant returns(uint count) {
    return candidateList.length;
  }

  function getMyVote() public returns(bytes32 candidate) {
    return votes[msg.sender];
  }

  function voteForCandidate(bytes32 candidate) public {
    require(!votingFinished);
    require(validCandidate(candidate));
    votes[msg.sender] = candidate;
    votesReceived[candidate] += 1;
    totalVotes += 1;
  }

  function validCandidate(bytes32 candidate) view public returns (bool) {
    for(uint i = 0; i < candidateList.length; i++) {
      if (candidateList[i] == candidate) {
        return true;
      }
    }
    return false;
  }
  
  function endVote() public returns (bool) {
    require(msg.sender == creator);  // Only contract creator can end the vote.
    votingFinished = true;
  }
  
}