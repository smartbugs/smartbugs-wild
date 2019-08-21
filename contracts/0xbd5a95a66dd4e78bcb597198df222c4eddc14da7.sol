// File: contracts/zeppelin-solidity/ownership/Ownable.sol

pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/installed_contracts/DLL.sol

pragma solidity^0.4.11;

library DLL {

  uint constant NULL_NODE_ID = 0;

  struct Node {
    uint next;
    uint prev;
  }

  struct Data {
    mapping(uint => Node) dll;
  }

  function isEmpty(Data storage self) public view returns (bool) {
    return getStart(self) == NULL_NODE_ID;
  }

  function contains(Data storage self, uint _curr) public view returns (bool) {
    if (isEmpty(self) || _curr == NULL_NODE_ID) {
      return false;
    }

    bool isSingleNode = (getStart(self) == _curr) && (getEnd(self) == _curr);
    bool isNullNode = (getNext(self, _curr) == NULL_NODE_ID) && (getPrev(self, _curr) == NULL_NODE_ID);
    return isSingleNode || !isNullNode;
  }

  function getNext(Data storage self, uint _curr) public view returns (uint) {
    return self.dll[_curr].next;
  }

  function getPrev(Data storage self, uint _curr) public view returns (uint) {
    return self.dll[_curr].prev;
  }

  function getStart(Data storage self) public view returns (uint) {
    return getNext(self, NULL_NODE_ID);
  }

  function getEnd(Data storage self) public view returns (uint) {
    return getPrev(self, NULL_NODE_ID);
  }

  /**
  @dev Inserts a new node between _prev and _next. When inserting a node already existing in
  the list it will be automatically removed from the old position.
  @param _prev the node which _new will be inserted after
  @param _curr the id of the new node being inserted
  @param _next the node which _new will be inserted before
  */
  function insert(Data storage self, uint _prev, uint _curr, uint _next) public {
    require(_curr != NULL_NODE_ID);

    remove(self, _curr);

    require(_prev == NULL_NODE_ID || contains(self, _prev));
    require(_next == NULL_NODE_ID || contains(self, _next));

    require(getNext(self, _prev) == _next);
    require(getPrev(self, _next) == _prev);

    self.dll[_curr].prev = _prev;
    self.dll[_curr].next = _next;

    self.dll[_prev].next = _curr;
    self.dll[_next].prev = _curr;
  }

  function remove(Data storage self, uint _curr) public {
    if (!contains(self, _curr)) {
      return;
    }

    uint next = getNext(self, _curr);
    uint prev = getPrev(self, _curr);

    self.dll[next].prev = prev;
    self.dll[prev].next = next;

    delete self.dll[_curr];
  }
}

// File: contracts/installed_contracts/AttributeStore.sol

/* solium-disable */
pragma solidity^0.4.11;

library AttributeStore {
    struct Data {
        mapping(bytes32 => uint) store;
    }

    function getAttribute(Data storage self, bytes32 _UUID, string _attrName)
    public view returns (uint) {
        bytes32 key = keccak256(_UUID, _attrName);
        return self.store[key];
    }

    function setAttribute(Data storage self, bytes32 _UUID, string _attrName, uint _attrVal)
    public {
        bytes32 key = keccak256(_UUID, _attrName);
        self.store[key] = _attrVal;
    }
}

// File: contracts/zeppelin-solidity/token/ERC20/IERC20.sol

pragma solidity ^0.4.24;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/zeppelin-solidity/math/SafeMath.sol

pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: contracts/installed_contracts/PLCRVoting.sol

pragma solidity ^0.4.8;





/**
@title Partial-Lock-Commit-Reveal Voting scheme with ERC20 tokens
@author Team: Aspyn Palatnick, Cem Ozer, Yorke Rhodes
*/
contract PLCRVoting {

    // ============
    // EVENTS:
    // ============

    event _VoteCommitted(uint indexed pollID, uint numTokens, address indexed voter);
    event _VoteRevealed(uint indexed pollID, uint numTokens, uint votesFor, uint votesAgainst, uint indexed choice, address indexed voter, uint salt);
    event _PollCreated(uint voteQuorum, uint commitEndDate, uint revealEndDate, uint indexed pollID, address indexed creator);
    event _VotingRightsGranted(uint numTokens, address indexed voter);
    event _VotingRightsWithdrawn(uint numTokens, address indexed voter);
    event _TokensRescued(uint indexed pollID, address indexed voter);

    // ============
    // DATA STRUCTURES:
    // ============

    using AttributeStore for AttributeStore.Data;
    using DLL for DLL.Data;
    using SafeMath for uint;

    struct Poll {
        uint commitEndDate;     /// expiration date of commit period for poll
        uint revealEndDate;     /// expiration date of reveal period for poll
        uint voteQuorum;	    /// number of votes required for a proposal to pass
        uint votesFor;		    /// tally of votes supporting proposal
        uint votesAgainst;      /// tally of votes countering proposal
        mapping(address => bool) didCommit;  /// indicates whether an address committed a vote for this poll
        mapping(address => bool) didReveal;   /// indicates whether an address revealed a vote for this poll
    }

    // ============
    // STATE VARIABLES:
    // ============

    uint constant public INITIAL_POLL_NONCE = 0;
    uint public pollNonce;

    mapping(uint => Poll) public pollMap; // maps pollID to Poll struct
    mapping(address => uint) public voteTokenBalance; // maps user's address to voteToken balance

    mapping(address => DLL.Data) dllMap;
    AttributeStore.Data store;

    IERC20 public token;

    /**
    @param _token The address where the ERC20 token contract is deployed
    */
    constructor(address _token) public {
        require(_token != 0);

        token = IERC20(_token);
        pollNonce = INITIAL_POLL_NONCE;
    }

    // ================
    // TOKEN INTERFACE:
    // ================

    /**
    @notice Loads _numTokens ERC20 tokens into the voting contract for one-to-one voting rights
    @dev Assumes that msg.sender has approved voting contract to spend on their behalf
    @param _numTokens The number of votingTokens desired in exchange for ERC20 tokens
    */
    function requestVotingRights(uint _numTokens) public {
        require(token.balanceOf(msg.sender) >= _numTokens);
        voteTokenBalance[msg.sender] += _numTokens;
        require(token.transferFrom(msg.sender, this, _numTokens));
        emit _VotingRightsGranted(_numTokens, msg.sender);
    }

    /**
    @notice Withdraw _numTokens ERC20 tokens from the voting contract, revoking these voting rights
    @param _numTokens The number of ERC20 tokens desired in exchange for voting rights
    */
    function withdrawVotingRights(uint _numTokens) external {
        uint availableTokens = voteTokenBalance[msg.sender].sub(getLockedTokens(msg.sender));
        require(availableTokens >= _numTokens);
        voteTokenBalance[msg.sender] -= _numTokens;
        require(token.transfer(msg.sender, _numTokens));
        emit _VotingRightsWithdrawn(_numTokens, msg.sender);
    }

    /**
    @dev Unlocks tokens locked in unrevealed vote where poll has ended
    @param _pollID Integer identifier associated with the target poll
    */
    function rescueTokens(uint _pollID) public {
        require(isExpired(pollMap[_pollID].revealEndDate));
        require(dllMap[msg.sender].contains(_pollID));

        dllMap[msg.sender].remove(_pollID);
        emit _TokensRescued(_pollID, msg.sender);
    }

    /**
    @dev Unlocks tokens locked in unrevealed votes where polls have ended
    @param _pollIDs Array of integer identifiers associated with the target polls
    */
    function rescueTokensInMultiplePolls(uint[] _pollIDs) public {
        // loop through arrays, rescuing tokens from all
        for (uint i = 0; i < _pollIDs.length; i++) {
            rescueTokens(_pollIDs[i]);
        }
    }

    // =================
    // VOTING INTERFACE:
    // =================

    /**
    @notice Commits vote using hash of choice and secret salt to conceal vote until reveal
    @param _pollID Integer identifier associated with target poll
    @param _secretHash Commit keccak256 hash of voter's choice and salt (tightly packed in this order)
    @param _numTokens The number of tokens to be committed towards the target poll
    @param _prevPollID The ID of the poll that the user has voted the maximum number of tokens in which is still less than or equal to numTokens
    */
    function commitVote(uint _pollID, bytes32 _secretHash, uint _numTokens, uint _prevPollID) public {
        require(commitPeriodActive(_pollID));

        // if msg.sender doesn't have enough voting rights,
        // request for enough voting rights
        if (voteTokenBalance[msg.sender] < _numTokens) {
            uint remainder = _numTokens.sub(voteTokenBalance[msg.sender]);
            requestVotingRights(remainder);
        }

        // make sure msg.sender has enough voting rights
        require(voteTokenBalance[msg.sender] >= _numTokens);
        // prevent user from committing to zero node placeholder
        require(_pollID != 0);
        // prevent user from committing a secretHash of 0
        require(_secretHash != 0);

        // Check if _prevPollID exists in the user's DLL or if _prevPollID is 0
        require(_prevPollID == 0 || dllMap[msg.sender].contains(_prevPollID));

        uint nextPollID = dllMap[msg.sender].getNext(_prevPollID);

        // edge case: in-place update
        if (nextPollID == _pollID) {
            nextPollID = dllMap[msg.sender].getNext(_pollID);
        }

        require(validPosition(_prevPollID, nextPollID, msg.sender, _numTokens));
        dllMap[msg.sender].insert(_prevPollID, _pollID, nextPollID);

        bytes32 UUID = attrUUID(msg.sender, _pollID);

        store.setAttribute(UUID, "numTokens", _numTokens);
        store.setAttribute(UUID, "commitHash", uint(_secretHash));

        pollMap[_pollID].didCommit[msg.sender] = true;
        emit _VoteCommitted(_pollID, _numTokens, msg.sender);
    }

    /**
    @notice                 Commits votes using hashes of choices and secret salts to conceal votes until reveal
    @param _pollIDs         Array of integer identifiers associated with target polls
    @param _secretHashes    Array of commit keccak256 hashes of voter's choices and salts (tightly packed in this order)
    @param _numsTokens      Array of numbers of tokens to be committed towards the target polls
    @param _prevPollIDs     Array of IDs of the polls that the user has voted the maximum number of tokens in which is still less than or equal to numTokens
    */
    function commitVotes(uint[] _pollIDs, bytes32[] _secretHashes, uint[] _numsTokens, uint[] _prevPollIDs) external {
        // make sure the array lengths are all the same
        require(_pollIDs.length == _secretHashes.length);
        require(_pollIDs.length == _numsTokens.length);
        require(_pollIDs.length == _prevPollIDs.length);

        // loop through arrays, committing each individual vote values
        for (uint i = 0; i < _pollIDs.length; i++) {
            commitVote(_pollIDs[i], _secretHashes[i], _numsTokens[i], _prevPollIDs[i]);
        }
    }

    /**
    @dev Compares previous and next poll's committed tokens for sorting purposes
    @param _prevID Integer identifier associated with previous poll in sorted order
    @param _nextID Integer identifier associated with next poll in sorted order
    @param _voter Address of user to check DLL position for
    @param _numTokens The number of tokens to be committed towards the poll (used for sorting)
    @return valid Boolean indication of if the specified position maintains the sort
    */
    function validPosition(uint _prevID, uint _nextID, address _voter, uint _numTokens) public constant returns (bool valid) {
        bool prevValid = (_numTokens >= getNumTokens(_voter, _prevID));
        // if next is zero node, _numTokens does not need to be greater
        bool nextValid = (_numTokens <= getNumTokens(_voter, _nextID) || _nextID == 0);
        return prevValid && nextValid;
    }

    /**
    @notice Reveals vote with choice and secret salt used in generating commitHash to attribute committed tokens
    @param _pollID Integer identifier associated with target poll
    @param _voteOption Vote choice used to generate commitHash for associated poll
    @param _salt Secret number used to generate commitHash for associated poll
    */
    function revealVote(uint _pollID, uint _voteOption, uint _salt) public {
        // Make sure the reveal period is active
        require(revealPeriodActive(_pollID));
        require(pollMap[_pollID].didCommit[msg.sender]);                         // make sure user has committed a vote for this poll
        require(!pollMap[_pollID].didReveal[msg.sender]);                        // prevent user from revealing multiple times
        require(keccak256(_voteOption, _salt) == getCommitHash(msg.sender, _pollID)); // compare resultant hash from inputs to original commitHash

        uint numTokens = getNumTokens(msg.sender, _pollID);

        if (_voteOption == 1) {// apply numTokens to appropriate poll choice
            pollMap[_pollID].votesFor += numTokens;
        } else {
            pollMap[_pollID].votesAgainst += numTokens;
        }

        dllMap[msg.sender].remove(_pollID); // remove the node referring to this vote upon reveal
        pollMap[_pollID].didReveal[msg.sender] = true;

        emit _VoteRevealed(_pollID, numTokens, pollMap[_pollID].votesFor, pollMap[_pollID].votesAgainst, _voteOption, msg.sender, _salt);
    }

    /**
    @notice             Reveals multiple votes with choices and secret salts used in generating commitHashes to attribute committed tokens
    @param _pollIDs     Array of integer identifiers associated with target polls
    @param _voteOptions Array of vote choices used to generate commitHashes for associated polls
    @param _salts       Array of secret numbers used to generate commitHashes for associated polls
    */
    function revealVotes(uint[] _pollIDs, uint[] _voteOptions, uint[] _salts) external {
        // make sure the array lengths are all the same
        require(_pollIDs.length == _voteOptions.length);
        require(_pollIDs.length == _salts.length);

        // loop through arrays, revealing each individual vote values
        for (uint i = 0; i < _pollIDs.length; i++) {
            revealVote(_pollIDs[i], _voteOptions[i], _salts[i]);
        }
    }

    /**
    @param _pollID Integer identifier associated with target poll
    @param _salt Arbitrarily chosen integer used to generate secretHash
    @return correctVotes Number of tokens voted for winning option
    */
    function getNumPassingTokens(address _voter, uint _pollID, uint _salt) public constant returns (uint correctVotes) {
        require(pollEnded(_pollID));
        require(pollMap[_pollID].didReveal[_voter]);

        uint winningChoice = isPassed(_pollID) ? 1 : 0;
        bytes32 winnerHash = keccak256(winningChoice, _salt);
        bytes32 commitHash = getCommitHash(_voter, _pollID);

        require(winnerHash == commitHash);

        return getNumTokens(_voter, _pollID);
    }

    // ==================
    // POLLING INTERFACE:
    // ==================

    /**
    @dev Initiates a poll with canonical configured parameters at pollID emitted by PollCreated event
    @param _voteQuorum Type of majority (out of 100) that is necessary for poll to be successful
    @param _commitDuration Length of desired commit period in seconds
    @param _revealDuration Length of desired reveal period in seconds
    */
    function startPoll(uint _voteQuorum, uint _commitDuration, uint _revealDuration) public returns (uint pollID) {
        pollNonce = pollNonce + 1;

        uint commitEndDate = block.timestamp.add(_commitDuration);
        uint revealEndDate = commitEndDate.add(_revealDuration);

        pollMap[pollNonce] = Poll({
            voteQuorum: _voteQuorum,
            commitEndDate: commitEndDate,
            revealEndDate: revealEndDate,
            votesFor: 0,
            votesAgainst: 0
        });

        emit _PollCreated(_voteQuorum, commitEndDate, revealEndDate, pollNonce, msg.sender);
        return pollNonce;
    }

    /**
    @notice Determines if proposal has passed
    @dev Check if votesFor out of totalVotes exceeds votesQuorum (requires pollEnded)
    @param _pollID Integer identifier associated with target poll
    */
    function isPassed(uint _pollID) constant public returns (bool passed) {
        require(pollEnded(_pollID));

        Poll memory poll = pollMap[_pollID];
        return (100 * poll.votesFor) > (poll.voteQuorum * (poll.votesFor + poll.votesAgainst));
    }

    // ----------------
    // POLLING HELPERS:
    // ----------------

    /**
    @dev Gets the total winning votes for reward distribution purposes
    @param _pollID Integer identifier associated with target poll
    @return Total number of votes committed to the winning option for specified poll
    */
    function getTotalNumberOfTokensForWinningOption(uint _pollID) constant public returns (uint numTokens) {
        require(pollEnded(_pollID));

        if (isPassed(_pollID))
            return pollMap[_pollID].votesFor;
        else
            return pollMap[_pollID].votesAgainst;
    }

    /**
    @notice Determines if poll is over
    @dev Checks isExpired for specified poll's revealEndDate
    @return Boolean indication of whether polling period is over
    */
    function pollEnded(uint _pollID) constant public returns (bool ended) {
        require(pollExists(_pollID));

        return isExpired(pollMap[_pollID].revealEndDate);
    }

    /**
    @notice Checks if the commit period is still active for the specified poll
    @dev Checks isExpired for the specified poll's commitEndDate
    @param _pollID Integer identifier associated with target poll
    @return Boolean indication of isCommitPeriodActive for target poll
    */
    function commitPeriodActive(uint _pollID) constant public returns (bool active) {
        require(pollExists(_pollID));

        return !isExpired(pollMap[_pollID].commitEndDate);
    }

    /**
    @notice Checks if the reveal period is still active for the specified poll
    @dev Checks isExpired for the specified poll's revealEndDate
    @param _pollID Integer identifier associated with target poll
    */
    function revealPeriodActive(uint _pollID) constant public returns (bool active) {
        require(pollExists(_pollID));

        return !isExpired(pollMap[_pollID].revealEndDate) && !commitPeriodActive(_pollID);
    }

    /**
    @dev Checks if user has committed for specified poll
    @param _voter Address of user to check against
    @param _pollID Integer identifier associated with target poll
    @return Boolean indication of whether user has committed
    */
    function didCommit(address _voter, uint _pollID) constant public returns (bool committed) {
        require(pollExists(_pollID));

        return pollMap[_pollID].didCommit[_voter];
    }

    /**
    @dev Checks if user has revealed for specified poll
    @param _voter Address of user to check against
    @param _pollID Integer identifier associated with target poll
    @return Boolean indication of whether user has revealed
    */
    function didReveal(address _voter, uint _pollID) constant public returns (bool revealed) {
        require(pollExists(_pollID));

        return pollMap[_pollID].didReveal[_voter];
    }

    /**
    @dev Checks if a poll exists
    @param _pollID The pollID whose existance is to be evaluated.
    @return Boolean Indicates whether a poll exists for the provided pollID
    */
    function pollExists(uint _pollID) constant public returns (bool exists) {
        return (_pollID != 0 && _pollID <= pollNonce);
    }

    // ---------------------------
    // DOUBLE-LINKED-LIST HELPERS:
    // ---------------------------

    /**
    @dev Gets the bytes32 commitHash property of target poll
    @param _voter Address of user to check against
    @param _pollID Integer identifier associated with target poll
    @return Bytes32 hash property attached to target poll
    */
    function getCommitHash(address _voter, uint _pollID) constant public returns (bytes32 commitHash) {
        return bytes32(store.getAttribute(attrUUID(_voter, _pollID), "commitHash"));
    }

    /**
    @dev Wrapper for getAttribute with attrName="numTokens"
    @param _voter Address of user to check against
    @param _pollID Integer identifier associated with target poll
    @return Number of tokens committed to poll in sorted poll-linked-list
    */
    function getNumTokens(address _voter, uint _pollID) constant public returns (uint numTokens) {
        return store.getAttribute(attrUUID(_voter, _pollID), "numTokens");
    }

    /**
    @dev Gets top element of sorted poll-linked-list
    @param _voter Address of user to check against
    @return Integer identifier to poll with maximum number of tokens committed to it
    */
    function getLastNode(address _voter) constant public returns (uint pollID) {
        return dllMap[_voter].getPrev(0);
    }

    /**
    @dev Gets the numTokens property of getLastNode
    @param _voter Address of user to check against
    @return Maximum number of tokens committed in poll specified
    */
    function getLockedTokens(address _voter) constant public returns (uint numTokens) {
        return getNumTokens(_voter, getLastNode(_voter));
    }

    /*
    @dev Takes the last node in the user's DLL and iterates backwards through the list searching
    for a node with a value less than or equal to the provided _numTokens value. When such a node
    is found, if the provided _pollID matches the found nodeID, this operation is an in-place
    update. In that case, return the previous node of the node being updated. Otherwise return the
    first node that was found with a value less than or equal to the provided _numTokens.
    @param _voter The voter whose DLL will be searched
    @param _numTokens The value for the numTokens attribute in the node to be inserted
    @return the node which the propoded node should be inserted after
    */
    function getInsertPointForNumTokens(address _voter, uint _numTokens, uint _pollID)
    constant public returns (uint prevNode) {
      // Get the last node in the list and the number of tokens in that node
      uint nodeID = getLastNode(_voter);
      uint tokensInNode = getNumTokens(_voter, nodeID);

      // Iterate backwards through the list until reaching the root node
      while(nodeID != 0) {
        // Get the number of tokens in the current node
        tokensInNode = getNumTokens(_voter, nodeID);
        if(tokensInNode <= _numTokens) { // We found the insert point!
          if(nodeID == _pollID) {
            // This is an in-place update. Return the prev node of the node being updated
            nodeID = dllMap[_voter].getPrev(nodeID);
          }
          // Return the insert point
          return nodeID;
        }
        // We did not find the insert point. Continue iterating backwards through the list
        nodeID = dllMap[_voter].getPrev(nodeID);
      }

      // The list is empty, or a smaller value than anything else in the list is being inserted
      return nodeID;
    }

    // ----------------
    // GENERAL HELPERS:
    // ----------------

    /**
    @dev Checks if an expiration date has been reached
    @param _terminationDate Integer timestamp of date to compare current timestamp with
    @return expired Boolean indication of whether the terminationDate has passed
    */
    function isExpired(uint _terminationDate) constant public returns (bool expired) {
        return (block.timestamp > _terminationDate);
    }

    /**
    @dev Generates an identifier which associates a user and a poll together
    @param _pollID Integer identifier associated with target poll
    @return UUID Hash which is deterministic from _user and _pollID
    */
    function attrUUID(address _user, uint _pollID) public pure returns (bytes32 UUID) {
        return keccak256(_user, _pollID);
    }
}

// File: contracts/installed_contracts/Parameterizer.sol

pragma solidity^0.4.11;




contract Parameterizer {

    // ------
    // EVENTS
    // ------

    event _ReparameterizationProposal(string name, uint value, bytes32 propID, uint deposit, uint appEndDate, address indexed proposer);
    event _NewChallenge(bytes32 indexed propID, uint challengeID, uint commitEndDate, uint revealEndDate, address indexed challenger);
    event _ProposalAccepted(bytes32 indexed propID, string name, uint value);
    event _ProposalExpired(bytes32 indexed propID);
    event _ChallengeSucceeded(bytes32 indexed propID, uint indexed challengeID, uint rewardPool, uint totalTokens);
    event _ChallengeFailed(bytes32 indexed propID, uint indexed challengeID, uint rewardPool, uint totalTokens);
    event _RewardClaimed(uint indexed challengeID, uint reward, address indexed voter);


    // ------
    // DATA STRUCTURES
    // ------

    using SafeMath for uint;

    struct ParamProposal {
        uint appExpiry;
        uint challengeID;
        uint deposit;
        string name;
        address owner;
        uint processBy;
        uint value;
    }

    struct Challenge {
        uint rewardPool;        // (remaining) pool of tokens distributed amongst winning voters
        address challenger;     // owner of Challenge
        bool resolved;          // indication of if challenge is resolved
        uint stake;             // number of tokens at risk for either party during challenge
        uint winningTokens;     // (remaining) amount of tokens used for voting by the winning side
        mapping(address => bool) tokenClaims;
    }

    // ------
    // STATE
    // ------

    mapping(bytes32 => uint) public params;

    // maps challengeIDs to associated challenge data
    mapping(uint => Challenge) public challenges;

    // maps pollIDs to intended data change if poll passes
    mapping(bytes32 => ParamProposal) public proposals;

    // Global Variables
    IERC20 public token;
    PLCRVoting public voting;
    uint public PROCESSBY = 604800; // 7 days

    /**
    @param _token           The address where the ERC20 token contract is deployed
    @param _plcr            address of a PLCR voting contract for the provided token
    @notice _parameters     array of canonical parameters
    */
    constructor(
        address _token,
        address _plcr,
        uint[] _parameters
    ) public {
        token = IERC20(_token);
        voting = PLCRVoting(_plcr);

        // minimum deposit for listing to be whitelisted
        set("minDeposit", _parameters[0]);

        // minimum deposit to propose a reparameterization
        set("pMinDeposit", _parameters[1]);

        // period over which applicants wait to be whitelisted
        set("applyStageLen", _parameters[2]);

        // period over which reparmeterization proposals wait to be processed
        set("pApplyStageLen", _parameters[3]);

        // length of commit period for voting
        set("commitStageLen", _parameters[4]);

        // length of commit period for voting in parameterizer
        set("pCommitStageLen", _parameters[5]);

        // length of reveal period for voting
        set("revealStageLen", _parameters[6]);

        // length of reveal period for voting in parameterizer
        set("pRevealStageLen", _parameters[7]);

        // percentage of losing party's deposit distributed to winning party
        set("dispensationPct", _parameters[8]);

        // percentage of losing party's deposit distributed to winning party in parameterizer
        set("pDispensationPct", _parameters[9]);

        // type of majority out of 100 necessary for candidate success
        set("voteQuorum", _parameters[10]);

        // type of majority out of 100 necessary for proposal success in parameterizer
        set("pVoteQuorum", _parameters[11]);
    }

    // -----------------------
    // TOKEN HOLDER INTERFACE
    // -----------------------

    /**
    @notice propose a reparamaterization of the key _name's value to _value.
    @param _name the name of the proposed param to be set
    @param _value the proposed value to set the param to be set
    */
    function proposeReparameterization(string _name, uint _value) public returns (bytes32) {
        uint deposit = get("pMinDeposit");
        bytes32 propID = keccak256(_name, _value);

        if (keccak256(_name) == keccak256("dispensationPct") ||
            keccak256(_name) == keccak256("pDispensationPct")) {
            require(_value <= 100);
        }

        require(!propExists(propID)); // Forbid duplicate proposals
        require(get(_name) != _value); // Forbid NOOP reparameterizations

        // attach name and value to pollID
        proposals[propID] = ParamProposal({
            appExpiry: now.add(get("pApplyStageLen")),
            challengeID: 0,
            deposit: deposit,
            name: _name,
            owner: msg.sender,
            processBy: now.add(get("pApplyStageLen"))
                .add(get("pCommitStageLen"))
                .add(get("pRevealStageLen"))
                .add(PROCESSBY),
            value: _value
        });

        require(token.transferFrom(msg.sender, this, deposit)); // escrow tokens (deposit amt)

        emit _ReparameterizationProposal(_name, _value, propID, deposit, proposals[propID].appExpiry, msg.sender);
        return propID;
    }

    /**
    @notice challenge the provided proposal ID, and put tokens at stake to do so.
    @param _propID the proposal ID to challenge
    */
    function challengeReparameterization(bytes32 _propID) public returns (uint challengeID) {
        ParamProposal memory prop = proposals[_propID];
        uint deposit = prop.deposit;

        require(propExists(_propID) && prop.challengeID == 0);

        //start poll
        uint pollID = voting.startPoll(
            get("pVoteQuorum"),
            get("pCommitStageLen"),
            get("pRevealStageLen")
        );

        challenges[pollID] = Challenge({
            challenger: msg.sender,
            rewardPool: SafeMath.sub(100, get("pDispensationPct")).mul(deposit).div(100),
            stake: deposit,
            resolved: false,
            winningTokens: 0
        });

        proposals[_propID].challengeID = pollID;       // update listing to store most recent challenge

        //take tokens from challenger
        require(token.transferFrom(msg.sender, this, deposit));

        var (commitEndDate, revealEndDate,) = voting.pollMap(pollID);

        emit _NewChallenge(_propID, pollID, commitEndDate, revealEndDate, msg.sender);
        return pollID;
    }

    /**
    @notice             for the provided proposal ID, set it, resolve its challenge, or delete it depending on whether it can be set, has a challenge which can be resolved, or if its "process by" date has passed
    @param _propID      the proposal ID to make a determination and state transition for
    */
    function processProposal(bytes32 _propID) public {
        ParamProposal storage prop = proposals[_propID];
        address propOwner = prop.owner;
        uint propDeposit = prop.deposit;


        // Before any token transfers, deleting the proposal will ensure that if reentrancy occurs the
        // prop.owner and prop.deposit will be 0, thereby preventing theft
        if (canBeSet(_propID)) {
            // There is no challenge against the proposal. The processBy date for the proposal has not
            // passed, but the proposal's appExpirty date has passed.
            set(prop.name, prop.value);
            emit _ProposalAccepted(_propID, prop.name, prop.value);
            delete proposals[_propID];
            require(token.transfer(propOwner, propDeposit));
        } else if (challengeCanBeResolved(_propID)) {
            // There is a challenge against the proposal.
            resolveChallenge(_propID);
        } else if (now > prop.processBy) {
            // There is no challenge against the proposal, but the processBy date has passed.
            emit _ProposalExpired(_propID);
            delete proposals[_propID];
            require(token.transfer(propOwner, propDeposit));
        } else {
            // There is no challenge against the proposal, and neither the appExpiry date nor the
            // processBy date has passed.
            revert();
        }

        assert(get("dispensationPct") <= 100);
        assert(get("pDispensationPct") <= 100);

        // verify that future proposal appExpiry and processBy times will not overflow
        now.add(get("pApplyStageLen"))
            .add(get("pCommitStageLen"))
            .add(get("pRevealStageLen"))
            .add(PROCESSBY);

        delete proposals[_propID];
    }

    /**
    @notice                 Claim the tokens owed for the msg.sender in the provided challenge
    @param _challengeID     the challenge ID to claim tokens for
    @param _salt            the salt used to vote in the challenge being withdrawn for
    */
    function claimReward(uint _challengeID, uint _salt) public {
        // ensure voter has not already claimed tokens and challenge results have been processed
        require(challenges[_challengeID].tokenClaims[msg.sender] == false);
        require(challenges[_challengeID].resolved == true);

        uint voterTokens = voting.getNumPassingTokens(msg.sender, _challengeID, _salt);
        uint reward = voterReward(msg.sender, _challengeID, _salt);

        // subtract voter's information to preserve the participation ratios of other voters
        // compared to the remaining pool of rewards
        challenges[_challengeID].winningTokens -= voterTokens;
        challenges[_challengeID].rewardPool -= reward;

        // ensures a voter cannot claim tokens again
        challenges[_challengeID].tokenClaims[msg.sender] = true;

        emit _RewardClaimed(_challengeID, reward, msg.sender);
        require(token.transfer(msg.sender, reward));
    }

    /**
    @dev                    Called by a voter to claim their rewards for each completed vote.
                            Someone must call updateStatus() before this can be called.
    @param _challengeIDs    The PLCR pollIDs of the challenges rewards are being claimed for
    @param _salts           The salts of a voter's commit hashes in the given polls
    */
    function claimRewards(uint[] _challengeIDs, uint[] _salts) public {
        // make sure the array lengths are the same
        require(_challengeIDs.length == _salts.length);

        // loop through arrays, claiming each individual vote reward
        for (uint i = 0; i < _challengeIDs.length; i++) {
            claimReward(_challengeIDs[i], _salts[i]);
        }
    }

    // --------
    // GETTERS
    // --------

    /**
    @dev                Calculates the provided voter's token reward for the given poll.
    @param _voter       The address of the voter whose reward balance is to be returned
    @param _challengeID The ID of the challenge the voter's reward is being calculated for
    @param _salt        The salt of the voter's commit hash in the given poll
    @return             The uint indicating the voter's reward
    */
    function voterReward(address _voter, uint _challengeID, uint _salt)
    public view returns (uint) {
        uint winningTokens = challenges[_challengeID].winningTokens;
        uint rewardPool = challenges[_challengeID].rewardPool;
        uint voterTokens = voting.getNumPassingTokens(_voter, _challengeID, _salt);
        return (voterTokens * rewardPool) / winningTokens;
    }

    /**
    @notice Determines whether a proposal passed its application stage without a challenge
    @param _propID The proposal ID for which to determine whether its application stage passed without a challenge
    */
    function canBeSet(bytes32 _propID) view public returns (bool) {
        ParamProposal memory prop = proposals[_propID];

        return (now > prop.appExpiry && now < prop.processBy && prop.challengeID == 0);
    }

    /**
    @notice Determines whether a proposal exists for the provided proposal ID
    @param _propID The proposal ID whose existance is to be determined
    */
    function propExists(bytes32 _propID) view public returns (bool) {
        return proposals[_propID].processBy > 0;
    }

    /**
    @notice Determines whether the provided proposal ID has a challenge which can be resolved
    @param _propID The proposal ID whose challenge to inspect
    */
    function challengeCanBeResolved(bytes32 _propID) view public returns (bool) {
        ParamProposal memory prop = proposals[_propID];
        Challenge memory challenge = challenges[prop.challengeID];

        return (prop.challengeID > 0 && challenge.resolved == false && voting.pollEnded(prop.challengeID));
    }

    /**
    @notice Determines the number of tokens to awarded to the winning party in a challenge
    @param _challengeID The challengeID to determine a reward for
    */
    function challengeWinnerReward(uint _challengeID) public view returns (uint) {
        if(voting.getTotalNumberOfTokensForWinningOption(_challengeID) == 0) {
            // Edge case, nobody voted, give all tokens to the challenger.
            return 2 * challenges[_challengeID].stake;
        }

        return (2 * challenges[_challengeID].stake) - challenges[_challengeID].rewardPool;
    }

    /**
    @notice gets the parameter keyed by the provided name value from the params mapping
    @param _name the key whose value is to be determined
    */
    function get(string _name) public view returns (uint value) {
        return params[keccak256(_name)];
    }

    /**
    @dev                Getter for Challenge tokenClaims mappings
    @param _challengeID The challengeID to query
    @param _voter       The voter whose claim status to query for the provided challengeID
    */
    function tokenClaims(uint _challengeID, address _voter) public view returns (bool) {
        return challenges[_challengeID].tokenClaims[_voter];
    }

    // ----------------
    // PRIVATE FUNCTIONS
    // ----------------

    /**
    @dev resolves a challenge for the provided _propID. It must be checked in advance whether the _propID has a challenge on it
    @param _propID the proposal ID whose challenge is to be resolved.
    */
    function resolveChallenge(bytes32 _propID) private {
        ParamProposal memory prop = proposals[_propID];
        Challenge storage challenge = challenges[prop.challengeID];

        // winner gets back their full staked deposit, and dispensationPct*loser's stake
        uint reward = challengeWinnerReward(prop.challengeID);

        challenge.winningTokens = voting.getTotalNumberOfTokensForWinningOption(prop.challengeID);
        challenge.resolved = true;

        if (voting.isPassed(prop.challengeID)) { // The challenge failed
            if(prop.processBy > now) {
                set(prop.name, prop.value);
            }
            emit _ChallengeFailed(_propID, prop.challengeID, challenge.rewardPool, challenge.winningTokens);
            require(token.transfer(prop.owner, reward));
        }
        else { // The challenge succeeded or nobody voted
            emit _ChallengeSucceeded(_propID, prop.challengeID, challenge.rewardPool, challenge.winningTokens);
            require(token.transfer(challenges[prop.challengeID].challenger, reward));
        }
    }

    /**
    @dev sets the param keted by the provided name to the provided value
    @param _name the name of the param to be set
    @param _value the value to set the param to be set
    */
    function set(string _name, uint _value) internal {
        params[keccak256(_name)] = _value;
    }
}

// File: contracts/tcr/AddressRegistry.sol

// solium-disable
pragma solidity ^0.4.24;





contract AddressRegistry {

    // ------
    // EVENTS
    // ------

    event _Application(address indexed listingAddress, uint deposit, uint appEndDate, string data, address indexed applicant);
    event _Challenge(address indexed listingAddress, uint indexed challengeID, string data, uint commitEndDate, uint revealEndDate, address indexed challenger);
    event _Deposit(address indexed listingAddress, uint added, uint newTotal, address indexed owner);
    event _Withdrawal(address indexed listingAddress, uint withdrew, uint newTotal, address indexed owner);
    event _ApplicationWhitelisted(address indexed listingAddress);
    event _ApplicationRemoved(address indexed listingAddress);
    event _ListingRemoved(address indexed listingAddress);
    event _ListingWithdrawn(address indexed listingAddress);
    event _TouchAndRemoved(address indexed listingAddress);
    event _ChallengeFailed(address indexed listingAddress, uint indexed challengeID, uint rewardPool, uint totalTokens);
    event _ChallengeSucceeded(address indexed listingAddress, uint indexed challengeID, uint rewardPool, uint totalTokens);
    event _RewardClaimed(uint indexed challengeID, uint reward, address indexed voter);

    using SafeMath for uint;

    struct Listing {
        uint applicationExpiry; // Expiration date of apply stage
        bool whitelisted;       // Indicates registry status
        address owner;          // Owner of Listing
        uint unstakedDeposit;   // Number of tokens in the listing not locked in a challenge
        uint challengeID;       // Corresponds to a PollID in PLCRVoting
    }

    struct Challenge {
        uint rewardPool;        // (remaining) Pool of tokens to be distributed to winning voters
        address challenger;     // Owner of Challenge
        bool resolved;          // Indication of if challenge is resolved
        uint stake;             // Number of tokens at stake for either party during challenge
        uint totalTokens;       // (remaining) Number of tokens used in voting by the winning side
        mapping(address => bool) tokenClaims; // Indicates whether a voter has claimed a reward yet
    }

    // Maps challengeIDs to associated challenge data
    mapping(uint => Challenge) public challenges;

    // Maps listingHashes to associated listingHash data
    mapping(address => Listing) public listings;

    // Global Variables
    IERC20 public token;
    PLCRVoting public voting;
    Parameterizer public parameterizer;
    string public name;

    /**
    @dev Initializer. Can only be called once.
    @param _token The address where the ERC20 token contract is deployed
    */
    constructor(address _token, address _voting, address _parameterizer, string _name) public {
        require(_token != 0, "_token address is 0");
        require(_voting != 0, "_voting address is 0");
        require(_parameterizer != 0, "_parameterizer address is 0");

        token = IERC20(_token);
        voting = PLCRVoting(_voting);
        parameterizer = Parameterizer(_parameterizer);
        name = _name;
    }

    // --------------------
    // PUBLISHER INTERFACE:
    // --------------------

    /**
    @dev                Allows a user to start an application. Takes tokens from user and sets
                        apply stage end time.
    @param listingAddress The hash of a potential listing a user is applying to add to the registry
    @param _amount      The number of ERC20 tokens a user is willing to potentially stake
    @param _data        Extra data relevant to the application. Think IPFS hashes.
    */
    function apply(address listingAddress, uint _amount, string _data) public {
        require(!isWhitelisted(listingAddress), "Listing already whitelisted");
        require(!appWasMade(listingAddress), "Application already made for this address");
        require(_amount >= parameterizer.get("minDeposit"), "Deposit amount not above minDeposit");

        // Sets owner
        Listing storage listing = listings[listingAddress];
        listing.owner = msg.sender;

        // Sets apply stage end time
        listing.applicationExpiry = block.timestamp.add(parameterizer.get("applyStageLen"));
        listing.unstakedDeposit = _amount;

        // Transfers tokens from user to Registry contract
        require(token.transferFrom(listing.owner, this, _amount), "Token transfer failed");

        emit _Application(listingAddress, _amount, listing.applicationExpiry, _data, msg.sender);
    }

    /**
    @dev                Allows the owner of a listingHash to increase their unstaked deposit.
    @param listingAddress A listingHash msg.sender is the owner of
    @param _amount      The number of ERC20 tokens to increase a user's unstaked deposit
    */
    function deposit(address listingAddress, uint _amount) external {
        Listing storage listing = listings[listingAddress];

        require(listing.owner == msg.sender, "Sender is not owner of Listing");

        listing.unstakedDeposit += _amount;
        require(token.transferFrom(msg.sender, this, _amount), "Token transfer failed");

        emit _Deposit(listingAddress, _amount, listing.unstakedDeposit, msg.sender);
    }

    /**
    @dev                Allows the owner of a listingHash to decrease their unstaked deposit.
    @param listingAddress A listingHash msg.sender is the owner of.
    @param _amount      The number of ERC20 tokens to withdraw from the unstaked deposit.
    */
    function withdraw(address listingAddress, uint _amount) external {
        Listing storage listing = listings[listingAddress];

        require(listing.owner == msg.sender, "Sender is not owner of listing");
        require(_amount <= listing.unstakedDeposit, "Cannot withdraw more than current unstaked deposit");
        if (listing.challengeID == 0 || challenges[listing.challengeID].resolved) { // ok to withdraw entire unstakedDeposit when challenge active as described here: https://github.com/skmgoldin/tcr/issues/55
          require(listing.unstakedDeposit - _amount >= parameterizer.get("minDeposit"), "Withdrawal prohibitied as it would put Listing unstaked deposit below minDeposit");
        }

        listing.unstakedDeposit -= _amount;
        require(token.transfer(msg.sender, _amount), "Token transfer failed");

        emit _Withdrawal(listingAddress, _amount, listing.unstakedDeposit, msg.sender);
    }

    /**
    @dev                Allows the owner of a listingHash to remove the listingHash from the whitelist
                        Returns all tokens to the owner of the listingHash
    @param listingAddress A listingHash msg.sender is the owner of.
    */
    function exit(address listingAddress) external {
        Listing storage listing = listings[listingAddress];

        require(msg.sender == listing.owner, "Sender is not owner of listing");
        require(isWhitelisted(listingAddress), "Listing must be whitelisted to be exited");

        // Cannot exit during ongoing challenge
        require(listing.challengeID == 0 || challenges[listing.challengeID].resolved, "Listing must not have an active challenge to be exited");

        // Remove listingHash & return tokens
        resetListing(listingAddress);
        emit _ListingWithdrawn(listingAddress);
    }

    // -----------------------
    // TOKEN HOLDER INTERFACE:
    // -----------------------

    /**
    @dev                Starts a poll for a listingHash which is either in the apply stage or
                        already in the whitelist. Tokens are taken from the challenger and the
                        applicant's deposits are locked.
    @param listingAddress The listingHash being challenged, whether listed or in application
    @param _data        Extra data relevant to the challenge. Think IPFS hashes.
    */
    function challenge(address listingAddress, string _data) public returns (uint challengeID) {
        Listing storage listing = listings[listingAddress];
        uint minDeposit = parameterizer.get("minDeposit");

        // Listing must be in apply stage or already on the whitelist
        require(appWasMade(listingAddress) || listing.whitelisted, "Listing must be in application phase or already whitelisted to be challenged");
        // Prevent multiple challenges
        require(listing.challengeID == 0 || challenges[listing.challengeID].resolved, "Listing must not have active challenge to be challenged");

        if (listing.unstakedDeposit < minDeposit) {
            // Not enough tokens, listingHash auto-delisted
            resetListing(listingAddress);
            emit _TouchAndRemoved(listingAddress);
            return 0;
        }

        // Starts poll
        uint pollID = voting.startPoll(
            parameterizer.get("voteQuorum"),
            parameterizer.get("commitStageLen"),
            parameterizer.get("revealStageLen")
        );

        uint oneHundred = 100; // Kludge that we need to use SafeMath
        challenges[pollID] = Challenge({
            challenger: msg.sender,
            rewardPool: ((oneHundred.sub(parameterizer.get("dispensationPct"))).mul(minDeposit)).div(100),
            stake: minDeposit,
            resolved: false,
            totalTokens: 0
        });

        // Updates listingHash to store most recent challenge
        listing.challengeID = pollID;

        // Locks tokens for listingHash during challenge
        listing.unstakedDeposit -= minDeposit;

        // Takes tokens from challenger
        require(token.transferFrom(msg.sender, this, minDeposit), "Token transfer failed");

        var (commitEndDate, revealEndDate,) = voting.pollMap(pollID);

        emit _Challenge(listingAddress, pollID, _data, commitEndDate, revealEndDate, msg.sender);
        return pollID;
    }

    /**
    @dev                Updates a listingHash's status from 'application' to 'listing' or resolves
                        a challenge if one exists.
    @param listingAddress The listingHash whose status is being updated
    */
    function updateStatus(address listingAddress) public {
        if (canBeWhitelisted(listingAddress)) {
            whitelistApplication(listingAddress);
        } else if (challengeCanBeResolved(listingAddress)) {
            resolveChallenge(listingAddress);
        } else {
            revert();
        }
    }

    /**
    @dev                  Updates an array of listingHashes' status from 'application' to 'listing' or resolves
                          a challenge if one exists.
    @param listingAddresses The listingHashes whose status are being updated
    */
    function updateStatuses(address[] listingAddresses) public {
        // loop through arrays, revealing each individual vote values
        for (uint i = 0; i < listingAddresses.length; i++) {
            updateStatus(listingAddresses[i]);
        }
    }

    // ----------------
    // TOKEN FUNCTIONS:
    // ----------------

    /**
    @dev                Called by a voter to claim their reward for each completed vote. Someone
                        must call updateStatus() before this can be called.
    @param _challengeID The PLCR pollID of the challenge a reward is being claimed for
    @param _salt        The salt of a voter's commit hash in the given poll
    */
    function claimReward(uint _challengeID, uint _salt) public {
        // Ensures the voter has not already claimed tokens and challenge results have been processed
        require(challenges[_challengeID].tokenClaims[msg.sender] == false, "Reward already claimed");
        require(challenges[_challengeID].resolved == true, "Challenge not yet resolved");

        uint voterTokens = voting.getNumPassingTokens(msg.sender, _challengeID, _salt);
        uint reward = voterReward(msg.sender, _challengeID, _salt);

        // Subtracts the voter's information to preserve the participation ratios
        // of other voters compared to the remaining pool of rewards
        challenges[_challengeID].totalTokens -= voterTokens;
        challenges[_challengeID].rewardPool -= reward;

        // Ensures a voter cannot claim tokens again
        challenges[_challengeID].tokenClaims[msg.sender] = true;

        require(token.transfer(msg.sender, reward), "Token transfer failed");

        emit _RewardClaimed(_challengeID, reward, msg.sender);
    }

    /**
    @dev                 Called by a voter to claim their rewards for each completed vote. Someone
                         must call updateStatus() before this can be called.
    @param _challengeIDs The PLCR pollIDs of the challenges rewards are being claimed for
    @param _salts        The salts of a voter's commit hashes in the given polls
    */
    function claimRewards(uint[] _challengeIDs, uint[] _salts) public {
        // make sure the array lengths are the same
        require(_challengeIDs.length == _salts.length, "Mismatch in length of _challengeIDs and _salts parameters");

        // loop through arrays, claiming each individual vote reward
        for (uint i = 0; i < _challengeIDs.length; i++) {
            claimReward(_challengeIDs[i], _salts[i]);
        }
    }

    // --------
    // GETTERS:
    // --------

    /**
    @dev                Calculates the provided voter's token reward for the given poll.
    @param _voter       The address of the voter whose reward balance is to be returned
    @param _challengeID The pollID of the challenge a reward balance is being queried for
    @param _salt        The salt of the voter's commit hash in the given poll
    @return             The uint indicating the voter's reward
    */
    function voterReward(address _voter, uint _challengeID, uint _salt)
    public view returns (uint) {
        uint totalTokens = challenges[_challengeID].totalTokens;
        uint rewardPool = challenges[_challengeID].rewardPool;
        uint voterTokens = voting.getNumPassingTokens(_voter, _challengeID, _salt);
        return (voterTokens * rewardPool) / totalTokens;
    }

    /**
    @dev                Determines whether the given listingHash be whitelisted.
    @param listingAddress The listingHash whose status is to be examined
    */
    function canBeWhitelisted(address listingAddress) view public returns (bool) {
        uint challengeID = listings[listingAddress].challengeID;

        // Ensures that the application was made,
        // the application period has ended,
        // the listingHash can be whitelisted,
        // and either: the challengeID == 0, or the challenge has been resolved.
        if (
            appWasMade(listingAddress) &&
            listings[listingAddress].applicationExpiry < now &&
            !isWhitelisted(listingAddress) &&
            (challengeID == 0 || challenges[challengeID].resolved == true)
        ) { return true; }

        return false;
    }

    /**
    @dev                Returns true if the provided listingHash is whitelisted
    @param listingAddress The listingHash whose status is to be examined
    */
    function isWhitelisted(address listingAddress) view public returns (bool whitelisted) {
        return listings[listingAddress].whitelisted;
    }

    /**
    @dev                Returns true if apply was called for this listingHash
    @param listingAddress The listingHash whose status is to be examined
    */
    function appWasMade(address listingAddress) view public returns (bool exists) {
        return listings[listingAddress].applicationExpiry > 0;
    }

    /**
    @dev                Returns true if the application/listingHash has an unresolved challenge
    @param listingAddress The listingHash whose status is to be examined
    */
    function challengeExists(address listingAddress) view public returns (bool) {
        uint challengeID = listings[listingAddress].challengeID;

        return (listings[listingAddress].challengeID > 0 && !challenges[challengeID].resolved);
    }

    /**
    @dev                Determines whether voting has concluded in a challenge for a given
                        listingHash. Throws if no challenge exists.
    @param listingAddress A listingHash with an unresolved challenge
    */
    function challengeCanBeResolved(address listingAddress) view public returns (bool) {
        uint challengeID = listings[listingAddress].challengeID;

        require(challengeExists(listingAddress), "Challenge does not exist for Listing");

        return voting.pollEnded(challengeID);
    }

    /**
    @dev                Determines the number of tokens awarded to the winning party in a challenge.
    @param _challengeID The challengeID to determine a reward for
    */
    function determineReward(uint _challengeID) public view returns (uint) {
        require(!challenges[_challengeID].resolved, "Challenge already resolved");
        require(voting.pollEnded(_challengeID), "Poll for challenge has not ended");

        // Edge case, nobody voted, give all tokens to the challenger.
        if (voting.getTotalNumberOfTokensForWinningOption(_challengeID) == 0) {
            return 2 * challenges[_challengeID].stake;
        }

        return (2 * challenges[_challengeID].stake) - challenges[_challengeID].rewardPool;
    }

    /**
    @dev                Getter for Challenge tokenClaims mappings
    @param _challengeID The challengeID to query
    @param _voter       The voter whose claim status to query for the provided challengeID
    */
    function tokenClaims(uint _challengeID, address _voter) public view returns (bool) {
        return challenges[_challengeID].tokenClaims[_voter];
    }

    // ----------------
    // PRIVATE FUNCTIONS:
    // ----------------

    /**
    @dev                Determines the winner in a challenge. Rewards the winner tokens and
                        either whitelists or de-whitelists the listingHash.
    @param listingAddress A listingHash with a challenge that is to be resolved
    */
    function resolveChallenge(address listingAddress) internal {
        uint challengeID = listings[listingAddress].challengeID;

        // Calculates the winner's reward,
        // which is: (winner's full stake) + (dispensationPct * loser's stake)
        uint reward = determineReward(challengeID);

        // Sets flag on challenge being processed
        challenges[challengeID].resolved = true;

        // Stores the total tokens used for voting by the winning side for reward purposes
        challenges[challengeID].totalTokens =
            voting.getTotalNumberOfTokensForWinningOption(challengeID);

        // Case: challenge failed
        if (voting.isPassed(challengeID)) {
            whitelistApplication(listingAddress);
            // Unlock stake so that it can be retrieved by the applicant
            listings[listingAddress].unstakedDeposit += reward;

            emit _ChallengeFailed(listingAddress, challengeID, challenges[challengeID].rewardPool, challenges[challengeID].totalTokens);
        }
        // Case: challenge succeeded or nobody voted
        else {
            resetListing(listingAddress);
            // Transfer the reward to the challenger
            require(token.transfer(challenges[challengeID].challenger, reward), "Token transfer failure");

            emit _ChallengeSucceeded(listingAddress, challengeID, challenges[challengeID].rewardPool, challenges[challengeID].totalTokens);
        }
    }

    /**
    @dev                Called by updateStatus() if the applicationExpiry date passed without a
                        challenge being made. Called by resolveChallenge() if an
                        application/listing beat a challenge.
    @param listingAddress The listingHash of an application/listingHash to be whitelisted
    */
    function whitelistApplication(address listingAddress) internal {
        if (!listings[listingAddress].whitelisted) { emit _ApplicationWhitelisted(listingAddress); }
        listings[listingAddress].whitelisted = true;
    }

    /**
    @dev                Deletes a listingHash from the whitelist and transfers tokens back to owner
    @param listingAddress The listing hash to delete
    */
    function resetListing(address listingAddress) internal {
        Listing storage listing = listings[listingAddress];

        // Emit events before deleting listing to check whether is whitelisted
        if (listing.whitelisted) {
            emit _ListingRemoved(listingAddress);
        } else {
            emit _ApplicationRemoved(listingAddress);
        }

        // Deleting listing to prevent reentry
        address owner = listing.owner;
        uint unstakedDeposit = listing.unstakedDeposit;
        delete listings[listingAddress];

        // Transfers any remaining balance back to the owner
        if (unstakedDeposit > 0){
            require(token.transfer(owner, unstakedDeposit), "Token transfer failure");
        }
    }
}

// File: contracts/tcr/ContractAddressRegistry.sol

pragma solidity ^0.4.24;


contract ContractAddressRegistry is AddressRegistry {

  modifier onlyContract(address contractAddress) {
    uint size;
    assembly { size := extcodesize(contractAddress) }
    require(size > 0, "Address is not a contract");
    _;
  }

  constructor(address _token, address _voting, address _parameterizer, string _name) public AddressRegistry(_token, _voting, _parameterizer, _name) {
  }

  // --------------------
  // PUBLISHER INTERFACE:
  // --------------------

  /**
  @notice Allows a user to start an application. Takes tokens from user and sets apply stage end time.
  --------
  In order to apply:
  1) Listing must not currently be whitelisted
  2) Listing must not currently be in application pahse
  3) Tokens deposited must be greater than or equal to the minDeposit value from the parameterizer
  4) Listing Address must point to contract
  --------
  Emits `_Application` event if successful
  @param amount The number of ERC20 tokens a user is willing to potentially stake
  @param data Extra data relevant to the application. Think IPFS hashes.
  */
  function apply(address listingAddress, uint amount, string data) onlyContract(listingAddress) public {
    super.apply(listingAddress, amount, data);
  }
}

// File: contracts/tcr/RestrictedAddressRegistry.sol

pragma solidity ^0.4.24;



contract RestrictedAddressRegistry is ContractAddressRegistry {

  modifier onlyContractOwner(address _contractAddress) {
    Ownable ownedContract = Ownable(_contractAddress);
    require(ownedContract.owner() == msg.sender, "Sender is not owner of contract");
    _;
  }

  constructor(address _token, address _voting, address _parameterizer, string _name) public ContractAddressRegistry(_token, _voting, _parameterizer, _name) {
  }

  // --------------------
  // PUBLISHER INTERFACE:
  // --------------------

  /**
  @notice Allows a user to start an application. Takes tokens from user and sets apply stage end time.
  --------
  In order to apply:
  1) Listing must not currently be whitelisted
  2) Listing must not currently be in application pahse
  3) Tokens deposited must be greater than or equal to the minDeposit value from the parameterizer
  4) Listing Address must point to owned contract
  5) Sender of message must be owner of contract at Listing Address
  --------
  Emits `_Application` event if successful
  @param amount The number of ERC20 tokens a user is willing to potentially stake
  @param data Extra data relevant to the application. Think IPFS hashes.
  */
  function apply(address listingAddress, uint amount, string data) onlyContractOwner(listingAddress) public {
    super.apply(listingAddress, amount, data);
  }
}

// File: contracts/interfaces/IGovernment.sol

pragma solidity ^0.4.19;

/**
@title IGovernment
@notice This is an interface that defines the functionality required by a Government
The functions herein are accessed by the CivilTCR contract as part of the appeals process.
@author Nick Reynolds - nick@joincivil.com
*/
interface IGovernment {
  function getAppellate() public view returns (address);
  function getGovernmentController() public view returns (address);
  function get(string name) public view returns (uint);
}

// File: contracts/proof-of-use/telemetry/TokenTelemetryI.sol

pragma solidity ^0.4.23;

interface TokenTelemetryI {
  function onRequestVotingRights(address user, uint tokenAmount) external;
}

// File: contracts/tcr/CivilPLCRVoting.sol

pragma solidity ^0.4.23;



/**
@title Partial-Lock-Commit-Reveal Voting scheme with ERC20 tokens
*/
contract CivilPLCRVoting is PLCRVoting {

  TokenTelemetryI public telemetry;

  /**
  @dev Initializer. Can only be called once.
  @param tokenAddr The address where the ERC20 token contract is deployed
  @param telemetryAddr The address where the TokenTelemetry contract is deployed
  */
  constructor(address tokenAddr, address telemetryAddr) public PLCRVoting(tokenAddr) {
    require(telemetryAddr != 0);
    telemetry = TokenTelemetryI(telemetryAddr);
  }

  /**
    @notice Loads _numTokens ERC20 tokens into the voting contract for one-to-one voting rights
    @dev Assumes that msg.sender has approved voting contract to spend on their behalf
    @param _numTokens The number of votingTokens desired in exchange for ERC20 tokens
    @dev Differs from base implementation in that it records use of token in mapping for "proof of use"
  */
  function requestVotingRights(uint _numTokens) public {
    super.requestVotingRights(_numTokens);
    telemetry.onRequestVotingRights(msg.sender, voteTokenBalance[msg.sender]);
  }

  /**
  @param _pollID Integer identifier associated with target poll
  @param _salt Arbitrarily chosen integer used to generate secretHash
  @return correctVotes Number of tokens voted for losing option
  */
  function getNumLosingTokens(address _voter, uint _pollID, uint _salt) public view returns (uint correctVotes) {
    require(pollEnded(_pollID));
    require(pollMap[_pollID].didReveal[_voter]);

    uint losingChoice = isPassed(_pollID) ? 0 : 1;
    bytes32 loserHash = keccak256(losingChoice, _salt);
    bytes32 commitHash = getCommitHash(_voter, _pollID);

    require(loserHash == commitHash);

    return getNumTokens(_voter, _pollID);
  }

  /**
  @dev Gets the total losing votes for reward distribution purposes
  @param _pollID Integer identifier associated with target poll
  @return Total number of votes committed to the losing option for specified poll
  */
  function getTotalNumberOfTokensForLosingOption(uint _pollID) public view returns (uint numTokens) {
    require(pollEnded(_pollID));

    if (isPassed(_pollID))
      return pollMap[_pollID].votesAgainst;
    else
      return pollMap[_pollID].votesFor;
  }

}

// File: contracts/tcr/CivilParameterizer.sol

pragma solidity ^0.4.19;


contract CivilParameterizer is Parameterizer {

  /**
  @param tokenAddr           The address where the ERC20 token contract is deployed
  @param plcrAddr            address of a PLCR voting contract for the provided token
  @notice parameters     array of canonical parameters
  */
  constructor(
    address tokenAddr,
    address plcrAddr,
    uint[] parameters
  ) public Parameterizer(tokenAddr, plcrAddr, parameters)
  {
    set("challengeAppealLen", parameters[12]);
    set("challengeAppealCommitLen", parameters[13]);
    set("challengeAppealRevealLen", parameters[14]);
  }
}

// File: contracts/tcr/CivilTCR.sol

pragma solidity ^0.4.24;






/**
@title CivilTCR - Token Curated Registry with Appeallate Functionality and Restrictions on Application
@author Nick Reynolds - nick@civil.co / engineering@civil.co
@notice The CivilTCR is a TCR with restrictions (address applied for must be a contract with Owned
implementated, and only the owner of a contract can apply on behalf of that contract), an appeallate entity that can
overturn challenges if someone requests an appeal, and a process by which granted appeals can be vetoed by a supermajority vote.
A Granted Appeal reverses the result of the challenge vote (including which parties are considered the winners & receive rewards).
A successful Appeal Challenge reverses the result of the Granted Appeal (again, including the winners).
*/
contract CivilTCR is RestrictedAddressRegistry {

  event _AppealRequested(address indexed listingAddress, uint indexed challengeID, uint appealFeePaid, address requester, string data);
  event _AppealGranted(address indexed listingAddress, uint indexed challengeID, string data);
  event _FailedChallengeOverturned(address indexed listingAddress, uint indexed challengeID, uint rewardPool, uint totalTokens);
  event _SuccessfulChallengeOverturned(address indexed listingAddress, uint indexed challengeID, uint rewardPool, uint totalTokens);
  event _GrantedAppealChallenged(address indexed listingAddress, uint indexed challengeID, uint indexed appealChallengeID, string data);
  event _GrantedAppealOverturned(address indexed listingAddress, uint indexed challengeID, uint indexed appealChallengeID, uint rewardPool, uint totalTokens);
  event _GrantedAppealConfirmed(address indexed listingAddress, uint indexed challengeID, uint indexed appealChallengeID, uint rewardPool, uint totalTokens);
  event _GovernmentTransfered(address newGovernment);

  modifier onlyGovernmentController {
    require(msg.sender == government.getGovernmentController(), "sender was not the Government Controller");
    _;
  }

  /**
  @notice modifier that checks that the sender of a message is the Appellate entity set by the Government
  */
  modifier onlyAppellate {
    require(msg.sender == government.getAppellate(), "sender was not the Appellate");
    _;
  }

  CivilPLCRVoting public civilVoting;
  IGovernment public government;

  /*
  @notice this struct handles the state of an appeal. It is first initialized
  when an appeal is requested
  */
  struct Appeal {
    address requester;
    uint appealFeePaid;
    uint appealPhaseExpiry;
    bool appealGranted;
    uint appealOpenToChallengeExpiry;
    uint appealChallengeID;
    bool overturned;
  }

  mapping(uint => uint) public challengeRequestAppealExpiries;
  mapping(uint => Appeal) public appeals; // map challengeID to appeal

  /**
  @notice Init function calls AddressRegistry init then sets IGovernment
  @dev passes tokenAddr, plcrAddr, paramsAddr up to RestrictedAddressRegistry constructor
  @param token TCR's intrinsic ERC20 token
  @param plcr CivilPLCR voting contract for the provided token
  @param param CivilParameterizer contract
  @param govt IGovernment contract
  */
  constructor(
    IERC20 token,
    CivilPLCRVoting plcr,
    CivilParameterizer param,
    IGovernment govt
  ) public RestrictedAddressRegistry(token, address(plcr), address(param), "CivilTCR")
  {
    require(address(govt) != 0, "govt address was zero");
    require(govt.getGovernmentController() != 0, "govt.getGovernmentController address was 0");
    civilVoting = plcr;
    government = govt;
  }

  // --------------------
  // LISTING OWNER INTERFACE:
  // --------------------

  /**
  @dev Allows a user to start an application. Takes tokens from user and sets apply stage end time.
  @param listingAddress The hash of a potential listing a user is applying to add to the registry
  @param amount The number of ERC20 tokens a user is willing to potentially stake
  @param data Extra data relevant to the application. Think IPFS hashes.
  */
  function apply(address listingAddress, uint amount, string data) public {
    super.apply(listingAddress, amount, data);
  }

  /**
  @notice Requests an appeal for a listing that has been challenged and completed its voting
  phase, but has not passed its challengeRequestAppealExpiries time.
  --------
  In order to request appeal, the following conditions must be met:
  1) voting for challenge has ended
  2) request appeal expiry has not passed
  3) appeal not already requested
  4) appeal requester transfers appealFee to TCR
  --------
  Initializes `Appeal` struct in `appeals` mapping for active challenge on listing at given address.
  --------
  Emits `_AppealRequested` if successful
  @param listingAddress address of listing that has challenged result that the user wants to appeal
  @param data Extra data relevant to the spprsl. Think IPFS hashes.
  */
  function requestAppeal(address listingAddress, string data) external {
    Listing storage listing = listings[listingAddress];
    require(voting.pollEnded(listing.challengeID), "Poll for listing challenge has not ended");
    require(challengeRequestAppealExpiries[listing.challengeID] > now, "Request Appeal phase is over"); // "Request Appeal Phase" active
    require(appeals[listing.challengeID].requester == address(0), "Appeal for this challenge has already been made");

    uint appealFee = government.get("appealFee");
    Appeal storage appeal = appeals[listing.challengeID];
    appeal.requester = msg.sender;
    appeal.appealFeePaid = appealFee;
    appeal.appealPhaseExpiry = now.add(government.get("judgeAppealLen"));
    require(token.transferFrom(msg.sender, this, appealFee), "Token transfer failed");
    emit _AppealRequested(listingAddress, listing.challengeID, appealFee, msg.sender, data);
  }

  // --------
  // APPELLATE INTERFACE:
  // --------

  /**
  @notice Grants a requested appeal.
  --------
  In order to grant an appeal:
  1) Message sender must be appellate entity as set by IGovernment contract
  2) An appeal has been requested
  3) The appeal phase expiry has not passed
  4) An appeal has not yet been granted
  --------
  Updates `Appeal` struct for appeal of active challenge for listing at given address by setting `appealGranted` to true and
  setting the `appealOpenToChallengeExpiry` value to a future time based on current value of `challengeAppealLen` in the Parameterizer.
  --------
  Emits `_AppealGranted` if successful
  @param listingAddress The address of the listing associated with the appeal
  @param data Extra data relevant to the appeal. Think IPFS hashes.
  */
  function grantAppeal(address listingAddress, string data) external onlyAppellate {
    Listing storage listing = listings[listingAddress];
    Appeal storage appeal = appeals[listing.challengeID];
    require(appeal.appealPhaseExpiry > now, "Judge Appeal phase not active"); // "Judge Appeal Phase" active
    require(!appeal.appealGranted, "Appeal has already been granted"); // don't grant twice

    appeal.appealGranted = true;
    appeal.appealOpenToChallengeExpiry = now.add(parameterizer.get("challengeAppealLen"));
    emit _AppealGranted(listingAddress, listing.challengeID, data);
  }

  /**
  @notice Updates IGovernment instance.
  --------
  Can only be called by Government Controller.
  --------
  Emits `_GovernmentTransfered` if successful.
  */
  function transferGovernment(IGovernment newGovernment) external onlyGovernmentController {
    require(address(newGovernment) != address(0), "New Government address is 0");
    government = newGovernment;
    emit _GovernmentTransfered(newGovernment);
  }

  // --------
  // ANY USER INTERFACE
  // ANYONE CAN CALL THESE FUNCTIONS FOR A LISTING
  // --------

  /**
  @notice Updates a listing's status from 'application' to 'listing', or resolves a challenge or appeal
  or appeal challenge if one exists. Reverts if none of `canBeWhitelisted`, `challengeCanBeResolved`, or
  `appealCanBeResolved` is true for given `listingAddress`.
  @param listingAddress Address of the listing of which the status is being updated
  */
  function updateStatus(address listingAddress) public {
    if (canBeWhitelisted(listingAddress)) {
      whitelistApplication(listingAddress);
    } else if (challengeCanBeResolved(listingAddress)) {
      resolveChallenge(listingAddress);
    } else if (appealCanBeResolved(listingAddress)) {
      resolveAppeal(listingAddress);
    } else if (appealChallengeCanBeResolved(listingAddress)) {
      resolveAppealChallenge(listingAddress);
    } else {
      revert();
    }
  }

  /**
  @notice Update state of listing after "Judge Appeal Phase" has ended. Reverts if cannot be processed yet.
  @param listingAddress Address of listing associated with appeal
  */
  function resolveAppeal(address listingAddress) internal {
    Listing listing = listings[listingAddress];
    Appeal appeal = appeals[listing.challengeID];
    if (appeal.appealGranted) {
      // appeal granted. override decision of voters.
      resolveOverturnedChallenge(listingAddress);
      // return appeal fee to appeal requester
      require(token.transfer(appeal.requester, appeal.appealFeePaid), "Token transfer failed");
    } else {
      // appeal fee is split between original winning voters and challenger
      Challenge storage challenge = challenges[listing.challengeID];
      uint extraReward = appeal.appealFeePaid.div(2);
      challenge.rewardPool = challenge.rewardPool.add(extraReward);
      challenge.stake = challenge.stake.add(appeal.appealFeePaid.sub(extraReward));
      // appeal not granted, confirm original decision of voters.
      super.resolveChallenge(listingAddress);
    }
  }

  // --------------------
  // TOKEN OWNER INTERFACE:
  // --------------------

  /**
  @notice Starts a poll for a listingAddress which is either in the apply stage or already in the whitelist.
  Tokens are taken from the challenger and the applicant's deposits are locked.
  Delists listing and returns 0 if listing's unstakedDeposit is less than current minDeposit
  @dev  Differs from base implementation in that it stores a timestamp in a mapping
  corresponding to the end of the request appeal phase, at which point a challenge
  can be resolved, if no appeal was requested
  @param listingAddress The listingAddress being challenged, whether listed or in application
  @param data Extra data relevant to the challenge. Think IPFS hashes.
  */
  function challenge(address listingAddress, string data) public returns (uint challengeID) {
    uint id = super.challenge(listingAddress, data);
    if (id > 0) {
      uint challengeLength = parameterizer.get("commitStageLen").add(parameterizer.get("revealStageLen")).add(government.get("requestAppealLen"));
      challengeRequestAppealExpiries[id] = now.add(challengeLength);
    }
    return id;
  }

  /**
  @notice Starts a poll for a listingAddress which has recently been granted an appeal. If
  the poll passes, the granted appeal will be overturned.
  --------
  In order to start a challenge:
  1) There is an active appeal on the listing
  2) This appeal was granted
  3) This appeal has not yet been challenged
  4) The expiry time of the appeal challenge is greater than the current time
  5) The challenger transfers tokens to the TCR equal to appeal fee paid by appeal requester
  --------
  Initializes `Challenge` struct in `challenges` mapping
  --------
  Emits `_GrantedAppealChallenged` if successful, and sets value of `appealChallengeID` on appeal being challenged.
  @return challengeID associated with the appeal challenge
  @dev challengeID is a nonce created by the PLCRVoting contract, regular challenges and appeal challenges share the same nonce variable
  @param listingAddress The listingAddress associated with the appeal
  @param data Extra data relevant to the appeal challenge. Think URLs.
  */
  function challengeGrantedAppeal(address listingAddress, string data) public returns (uint challengeID) {
    Listing storage listing = listings[listingAddress];
    Appeal storage appeal = appeals[listing.challengeID];
    require(appeal.appealGranted, "Appeal not granted");
    require(appeal.appealChallengeID == 0, "Appeal already challenged");
    require(appeal.appealOpenToChallengeExpiry > now, "Appeal no longer open to challenge");

    uint pollID = voting.startPoll(
      government.get("appealVotePercentage"),
      parameterizer.get("challengeAppealCommitLen"),
      parameterizer.get("challengeAppealRevealLen")
    );

    uint oneHundred = 100;
    uint reward = (oneHundred.sub(government.get("appealChallengeVoteDispensationPct"))).mul(appeal.appealFeePaid).div(oneHundred);
    challenges[pollID] = Challenge({
      challenger: msg.sender,
      rewardPool: reward,
      stake: appeal.appealFeePaid,
      resolved: false,
      totalTokens: 0
    });

    appeal.appealChallengeID = pollID;

    require(token.transferFrom(msg.sender, this, appeal.appealFeePaid), "Token transfer failed");
    emit _GrantedAppealChallenged(listingAddress, listing.challengeID, pollID, data);
    return pollID;
  }


  /**
  @notice Determines the winner in an appeal challenge. Rewards the winner tokens and
  either whitelists or delists the listing at the given address. Also resolves the underlying
  challenge that was originally appealed.
  Emits `_GrantedAppealConfirmed` if appeal challenge unsuccessful (vote not passed).
  Emits `_GrantedAppealOverturned` if appeal challenge successful (vote passed).
  @param listingAddress The address of a listing with an appeal challenge that is to be resolved
  */
  function resolveAppealChallenge(address listingAddress) internal {
    Listing storage listing = listings[listingAddress];
    uint challengeID = listings[listingAddress].challengeID;
    Appeal storage appeal = appeals[listing.challengeID];
    uint appealChallengeID = appeal.appealChallengeID;
    Challenge storage appealChallenge = challenges[appeal.appealChallengeID];

    // Calculates the winner's reward,
    // which is: (winner's full stake) + (dispensationPct * loser's stake)
    uint reward = determineReward(appealChallengeID);

    // Sets flag on challenge being processed
    appealChallenge.resolved = true;

    // Stores the total tokens used for voting by the winning side for reward purposes
    appealChallenge.totalTokens = voting.getTotalNumberOfTokensForWinningOption(appealChallengeID);

    if (voting.isPassed(appealChallengeID)) { // Case: vote passed, appeal challenge succeeded, overturn appeal
      appeal.overturned = true;
      super.resolveChallenge(listingAddress);
      require(token.transfer(appealChallenge.challenger, reward), "Token transfer failed");
      emit _GrantedAppealOverturned(listingAddress, challengeID, appealChallengeID, appealChallenge.rewardPool, appealChallenge.totalTokens);
    } else { // Case: vote not passed, appeal challenge failed, confirm appeal
      resolveOverturnedChallenge(listingAddress);
      require(token.transfer(appeal.requester, reward), "Token transfer failed");
      emit _GrantedAppealConfirmed(listingAddress, challengeID, appealChallengeID, appealChallenge.rewardPool, appealChallenge.totalTokens);
    }
  }

  /**
  @dev Called by a voter to claim their reward for each completed vote. Someone must call
  updateStatus() before this can be called.
  @param _challengeID The PLCR pollID of the challenge a reward is being claimed for
  @param _salt        The salt of a voter's commit hash in the given poll
  */
  function claimReward(uint _challengeID, uint _salt) public {
    // Ensures the voter has not already claimed tokens and challenge results have been processed
    require(challenges[_challengeID].tokenClaims[msg.sender] == false, "Reward already claimed");
    require(challenges[_challengeID].resolved == true, "Challenge not yet resolved");

    uint voterTokens = getNumChallengeTokens(msg.sender, _challengeID, _salt);
    uint reward = voterReward(msg.sender, _challengeID, _salt);

    // Subtracts the voter's information to preserve the participation ratios
    // of other voters compared to the remaining pool of rewards
    challenges[_challengeID].totalTokens = challenges[_challengeID].totalTokens.sub(voterTokens);
    challenges[_challengeID].rewardPool = challenges[_challengeID].rewardPool.sub(reward);

    // Ensures a voter cannot claim tokens again
    challenges[_challengeID].tokenClaims[msg.sender] = true;

    require(token.transfer(msg.sender, reward), "Token transfer failed");

    emit _RewardClaimed(_challengeID, reward, msg.sender);
  }

  /**
  @notice gets the number of tokens the voter staked on the winning side of the challenge,
  or the losing side if the challenge has been overturned
  @param voter The Voter to check
  @param challengeID The PLCR pollID of the challenge to check
  @param salt The salt of a voter's commit hash in the given poll
  */
  function getNumChallengeTokens(address voter, uint challengeID, uint salt) internal view returns (uint) {
    // a challenge is overturned if an appeal for it was granted, but the appeal itself was not overturned
    bool challengeOverturned = appeals[challengeID].appealGranted && !appeals[challengeID].overturned;
    if (challengeOverturned) {
      return civilVoting.getNumLosingTokens(voter, challengeID, salt);
    } else {
      return voting.getNumPassingTokens(voter, challengeID, salt);
    }
  }

  /**
  @dev Determines the number of tokens awarded to the winning party in a challenge.
  @param challengeID The challengeID to determine a reward for
  */
  function determineReward(uint challengeID) public view returns (uint) {
    // a challenge is overturned if an appeal for it was granted, but the appeal itself was not overturned
    require(!challenges[challengeID].resolved, "Challenge already resolved");
    require(voting.pollEnded(challengeID), "Poll for challenge has not ended");
    bool challengeOverturned = appeals[challengeID].appealGranted && !appeals[challengeID].overturned;
    // Edge case, nobody voted, give all tokens to the challenger.
    if (challengeOverturned) {
      if (civilVoting.getTotalNumberOfTokensForLosingOption(challengeID) == 0) {
        return 2 * challenges[challengeID].stake;
      }
    } else {
      if (voting.getTotalNumberOfTokensForWinningOption(challengeID) == 0) {
        return 2 * challenges[challengeID].stake;
      }
    }

    return (2 * challenges[challengeID].stake) - challenges[challengeID].rewardPool;
  }

  /**
  @notice Calculates the provided voter's token reward for the given poll.
  @dev differs from implementation in `AddressRegistry` in that it takes into consideration whether an
  appeal was granted and possible overturned via appeal challenge.
  @param voter The address of the voter whose reward balance is to be returned
  @param challengeID The pollID of the challenge a reward balance is being queried for
  @param salt The salt of the voter's commit hash in the given poll
  @return The uint indicating the voter's reward
  */
  function voterReward(
    address voter,
    uint challengeID,
    uint salt
  ) public view returns (uint)
  {
    Challenge challenge = challenges[challengeID];
    uint totalTokens = challenge.totalTokens;
    uint rewardPool = challenge.rewardPool;
    uint voterTokens = getNumChallengeTokens(voter, challengeID, salt);
    return (voterTokens.mul(rewardPool)).div(totalTokens);
  }

  /**
  @dev Called by updateStatus() if the applicationExpiry date passed without a challenge being made.
  Called by resolveChallenge() if an application/listing beat a challenge. Differs from base
  implementation in thatit also clears out challengeID
  @param listingAddress The listingHash of an application/listingHash to be whitelisted
  */
  function whitelistApplication(address listingAddress) internal {
    super.whitelistApplication(listingAddress);
    listings[listingAddress].challengeID = 0;
  }

  /**
  @notice Updates the state of a listing after a challenge was overtuned via appeal (and no appeal
  challenge was initiated). If challenge previously failed, transfer reward to original challenger.
  Otherwise, add reward to listing's unstaked deposit
  --------
  Emits `_FailedChallengeOverturned` if original challenge failed.
  Emits `_SuccessfulChallengeOverturned` if original challenge succeeded.
  Emits `_ListingRemoved` if original challenge failed and listing was previous whitelisted.
  Emits `_ApplicationRemoved` if original challenge failed and listing was not previously whitelisted.
  Emits `_ApplicationWhitelisted` if original challenge succeeded and listing was not previously whitelisted.
  @param listingAddress Address of listing with a challenge that is to be resolved
  */
  function resolveOverturnedChallenge(address listingAddress) private {
    Listing storage listing = listings[listingAddress];
    uint challengeID = listing.challengeID;
    Challenge storage challenge = challenges[challengeID];
    // Calculates the winner's reward,
    uint reward = determineReward(challengeID);

    challenge.resolved = true;
    // Stores the total tokens used for voting by the losing side for reward purposes
    challenge.totalTokens = civilVoting.getTotalNumberOfTokensForLosingOption(challengeID);

    // challenge is overturned, behavior here is opposite resolveChallenge
    if (!voting.isPassed(challengeID)) { // original vote failed (challenge succeded), this should whitelist listing
      whitelistApplication(listingAddress);
      // Unlock stake so that it can be retrieved by the applicant
      listing.unstakedDeposit = listing.unstakedDeposit.add(reward);

      emit _SuccessfulChallengeOverturned(listingAddress, challengeID, challenge.rewardPool, challenge.totalTokens);
    } else { // original vote succeded (challenge failed), this should de-list listing
      resetListing(listingAddress);
      // Transfer the reward to the challenger
      require(token.transfer(challenge.challenger, reward), "Token transfer failed");

      emit _FailedChallengeOverturned(listingAddress, challengeID, challenge.rewardPool, challenge.totalTokens);
    }
  }

  /**
  @notice Determines whether a challenge can be resolved for a listing at given address. Throws if no challenge exists.
  @param listingAddress An address for a listing to check
  @return True if challenge exists, has not already been resolved, has not had appeal requested, and has passed the request
  appeal expiry time. False otherwise.
  */
  function challengeCanBeResolved(address listingAddress) view public returns (bool canBeResolved) {
    uint challengeID = listings[listingAddress].challengeID;
    require(challengeExists(listingAddress), "Challenge does not exist for listing");
    if (challengeRequestAppealExpiries[challengeID] > now) {
      return false;
    }
    return (appeals[challengeID].appealPhaseExpiry == 0);
  }

  /**
  @notice Determines whether an appeal can be resolved for a listing at given address. Throws if no challenge exists.
  @param listingAddress An address for a listing to check
  @return True if challenge exists, has not already been resolved, has had appeal requested, and has either
  (1) had an appeal granted and passed the appeal opten to challenge expiry OR (2) has not had an appeal granted and
  has passed the appeal phase expiry. False otherwise.
  */
  function appealCanBeResolved(address listingAddress) view public returns (bool canBeResolved) {
    uint challengeID = listings[listingAddress].challengeID;
    Appeal appeal = appeals[challengeID];
    require(challengeExists(listingAddress), "Challenge does not exist for listing");
    if (appeal.appealPhaseExpiry == 0) {
      return false;
    }
    if (!appeal.appealGranted) {
      return appeal.appealPhaseExpiry < now;
    } else {
      return appeal.appealOpenToChallengeExpiry < now && appeal.appealChallengeID == 0;
    }
  }

  /**
  @notice Determines whether an appeal challenge can be resolved for a listing at given address. Throws if no challenge exists.
  @param listingAddress An address for a listing to check
  @return True if appeal challenge exists, has not already been resolved, and the voting phase for the appeal challenge is ended. False otherwise.
  */
  function appealChallengeCanBeResolved(address listingAddress) view public returns (bool canBeResolved) {
    uint challengeID = listings[listingAddress].challengeID;
    Appeal appeal = appeals[challengeID];
    require(challengeExists(listingAddress), "Challenge does not exist for listing");
    if (appeal.appealChallengeID == 0) {
      return false;
    }
    return voting.pollEnded(appeal.appealChallengeID);
  }
}