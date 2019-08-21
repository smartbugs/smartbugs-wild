pragma solidity ^0.4.17;

//
// Swarm Voting MVP
// Single use contract to manage liquidity vote shortly after Swarm TS
// Author: Max Kaye
//
//
// Architecture:
// * Ballot authority declares public key with which to encrypt ballots
// * Users submit encrypted ballots as blobs
// * These ballots are tracked by the ETH address of the sender
// * Following the conclusion of the ballot, the secret key is provided
//   by the ballot authority, and all users may transparently and
//   independently validate the results
//
// Notes:
// * Since ballots are encrypted the only validation we can do is length
//


contract SwarmVotingMVP {
    //// ** Storage Variables

    // Std owner pattern
    address public owner;

    // test mode - operations like changing start/end times
    bool public testMode = false;

    // Maps to store ballots, along with corresponding log of voters.
    // Should only be modified through `addBallotAndVoter` internal function
    mapping(uint256 => bytes32) public encryptedBallots;
    mapping(uint256 => bytes32) public associatedPubkeys;
    mapping(uint256 => address) public associatedAddresses;
    uint256 public nVotesCast = 0;

    // Use a map for voters to look up their ballot
    mapping(address => uint256) public voterToBallotID;

    // Public key with which to encrypt ballots - curve25519
    bytes32 public ballotEncryptionPubkey;

    // Private key to be set after ballot conclusion - curve25519
    bytes32 public ballotEncryptionSeckey;
    bool seckeyRevealed = false;
    bool allowSeckeyBeforeEndTime = false;

    // Timestamps for start and end of ballot (UTC)
    uint256 public startTime;
    uint256 public endTime;

    // Banned addresses - necessary to ban Swarm Fund from voting in their own ballot
    mapping(address => bool) public bannedAddresses;
    address public swarmFundAddress = 0x8Bf7b2D536D286B9c5Ad9d99F608e9E214DE63f0;

    bytes32[5] public optionHashes;

    //// ** Events
    event CreatedBallot(address creator, uint256 start, uint256 end, bytes32 encPubkey, string o1, string o2, string o3, string o4, string o5);
    event SuccessfulVote(address voter, bytes32 ballot, bytes32 pubkey);
    event SeckeyRevealed(bytes32 secretKey);
    event AllowEarlySeckey(bool allowEarlySeckey);
    event TestingEnabled();
    event Error(string error);


    //// ** Modifiers

    modifier notBanned {
        if (!bannedAddresses[msg.sender]) {  // ensure banned addresses cannot vote
            _;
        } else {
            Error("Banned address");
        }
    }

    modifier onlyOwner {
        if (msg.sender == owner) {  // fail if msg.sender is not the owner
            _;
        } else {
            Error("Not owner");
        }
    }

    modifier ballotOpen {
        if (block.timestamp >= startTime && block.timestamp < endTime) {
            _;
        } else {
            Error("Ballot not open");
        }
    }

    modifier onlyTesting {
        if (testMode) {
            _;
        } else {
            Error("Testing disabled");
        }
    }

    //// ** Functions

    // Constructor function - init core params on deploy
    function SwarmVotingMVP(uint256 _startTime, uint256 _endTime, bytes32 _encPK, bool enableTesting, bool _allowSeckeyBeforeEndTime, string opt1, string opt2, string opt3, string opt4, string opt5) public {
        owner = msg.sender;

        startTime = _startTime;
        endTime = _endTime;
        ballotEncryptionPubkey = _encPK;

        bannedAddresses[swarmFundAddress] = true;

        optionHashes = [keccak256(opt1), keccak256(opt2), keccak256(opt3), keccak256(opt4), keccak256(opt5)];

        allowSeckeyBeforeEndTime = _allowSeckeyBeforeEndTime;
        AllowEarlySeckey(_allowSeckeyBeforeEndTime);

        if (enableTesting) {
            testMode = true;
            TestingEnabled();
        }

        CreatedBallot(msg.sender, _startTime, _endTime, _encPK, opt1, opt2, opt3, opt4, opt5);
    }

    // Ballot submission
    function submitBallot(bytes32 encryptedBallot, bytes32 senderPubkey) notBanned ballotOpen public {
        addBallotAndVoter(encryptedBallot, senderPubkey);
    }

    // Internal function to ensure atomicity of voter log
    function addBallotAndVoter(bytes32 encryptedBallot, bytes32 senderPubkey) internal {
        uint256 ballotNumber = nVotesCast;
        encryptedBallots[ballotNumber] = encryptedBallot;
        associatedPubkeys[ballotNumber] = senderPubkey;
        associatedAddresses[ballotNumber] = msg.sender;
        voterToBallotID[msg.sender] = ballotNumber;
        nVotesCast += 1;
        SuccessfulVote(msg.sender, encryptedBallot, senderPubkey);
    }

    // Allow the owner to reveal the secret key after ballot conclusion
    function revealSeckey(bytes32 _secKey) onlyOwner public {
        if (allowSeckeyBeforeEndTime == false) {
            require(block.timestamp > endTime);
        }

        ballotEncryptionSeckey = _secKey;
        seckeyRevealed = true;  // this flag allows the contract to be locked
        SeckeyRevealed(_secKey);
    }

    // Helpers
    function getEncPubkey() public constant returns (bytes32) {
        return ballotEncryptionPubkey;
    }

    function getEncSeckey() public constant returns (bytes32) {
        return ballotEncryptionSeckey;
    }

    function getBallotOptions() public constant returns (bytes32[5]) {
        return optionHashes;
    }

    // ballot params - allows the frontend to do some checking
    function getBallotOptNumber() public pure returns (uint256) {
        return 5;
    }

    // Test functions
    function setEndTime(uint256 newEndTime) onlyTesting onlyOwner public {
        endTime = newEndTime;
    }

    function banAddress(address _addr) onlyTesting onlyOwner public {
        bannedAddresses[_addr] = true;
    }
}