contract EIP20Interface {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract EIP20 is EIP20Interface {

    uint256 constant MAX_UINT256 = 2**256 - 1;

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

     function EIP20(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) public {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = _decimalUnits;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
    view public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

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
    require(_prev == NULL_NODE_ID || contains(self, _prev));

    remove(self, _curr);

    require(getNext(self, _prev) == _next);

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

contract PLCRVoting {

    // ============
    // EVENTS:
    // ============

    event VoteCommitted(address voter, uint pollID, uint numTokens);
    event VoteRevealed(address voter, uint pollID, uint numTokens, uint choice);
    event PollCreated(uint voteQuorum, uint commitDuration, uint revealDuration, uint pollID);
    event VotingRightsGranted(address voter, uint numTokens);
    event VotingRightsWithdrawn(address voter, uint numTokens);

    // ============
    // DATA STRUCTURES:
    // ============

    using AttributeStore for AttributeStore.Data;
    using DLL for DLL.Data;

    struct Poll {
        uint commitEndDate;     /// expiration date of commit period for poll
        uint revealEndDate;     /// expiration date of reveal period for poll
        uint voteQuorum;	    /// number of votes required for a proposal to pass
        uint votesFor;		    /// tally of votes supporting proposal
        uint votesAgainst;      /// tally of votes countering proposal
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

    EIP20 public token;

    // ============
    // CONSTRUCTOR:
    // ============

    /**
    @dev Initializes voteQuorum, commitDuration, revealDuration, and pollNonce in addition to token contract and trusted mapping
    @param _tokenAddr The address where the ERC20 token contract is deployed
    */
    function PLCRVoting(address _tokenAddr) public {
        token = EIP20(_tokenAddr);
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
    function requestVotingRights(uint _numTokens) external {
        require(token.balanceOf(msg.sender) >= _numTokens);
        require(token.transferFrom(msg.sender, this, _numTokens));
        voteTokenBalance[msg.sender] += _numTokens;
        VotingRightsGranted(msg.sender, _numTokens);
    }

    /**
    @notice Withdraw _numTokens ERC20 tokens from the voting contract, revoking these voting rights
    @param _numTokens The number of ERC20 tokens desired in exchange for voting rights
    */
    function withdrawVotingRights(uint _numTokens) external {
        uint availableTokens = voteTokenBalance[msg.sender] - getLockedTokens(msg.sender);
        require(availableTokens >= _numTokens);
        require(token.transfer(msg.sender, _numTokens));
        voteTokenBalance[msg.sender] -= _numTokens;
        VotingRightsWithdrawn(msg.sender, _numTokens);
    }

    /**
    @dev Unlocks tokens locked in unrevealed vote where poll has ended
    @param _pollID Integer identifier associated with the target poll
    */
    function rescueTokens(uint _pollID) external {
        require(pollEnded(_pollID));
        require(!hasBeenRevealed(msg.sender, _pollID));

        dllMap[msg.sender].remove(_pollID);
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
    function commitVote(uint _pollID, bytes32 _secretHash, uint _numTokens, uint _prevPollID) external {
        require(commitPeriodActive(_pollID));
        require(voteTokenBalance[msg.sender] >= _numTokens); // prevent user from overspending
        require(_pollID != 0);                // prevent user from committing to zero node placeholder

        // TODO: Move all insert validation into the DLL lib
        // Check if _prevPollID exists
        require(_prevPollID == 0 || getCommitHash(msg.sender, _prevPollID) != 0);

        uint nextPollID = dllMap[msg.sender].getNext(_prevPollID);

        // if nextPollID is equal to _pollID, _pollID is being updated,
        nextPollID = (nextPollID == _pollID) ? dllMap[msg.sender].getNext(_pollID) : nextPollID;

        require(validPosition(_prevPollID, nextPollID, msg.sender, _numTokens));
        dllMap[msg.sender].insert(_prevPollID, _pollID, nextPollID);

        bytes32 UUID = attrUUID(msg.sender, _pollID);

        store.setAttribute(UUID, "numTokens", _numTokens);
        store.setAttribute(UUID, "commitHash", uint(_secretHash));

        VoteCommitted(msg.sender, _pollID, _numTokens);
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
    function revealVote(uint _pollID, uint _voteOption, uint _salt) external {
        // Make sure the reveal period is active
        require(revealPeriodActive(_pollID));
        require(!hasBeenRevealed(msg.sender, _pollID));                        // prevent user from revealing multiple times
        require(keccak256(_voteOption, _salt) == getCommitHash(msg.sender, _pollID)); // compare resultant hash from inputs to original commitHash

        uint numTokens = getNumTokens(msg.sender, _pollID); 

        if (_voteOption == 1) // apply numTokens to appropriate poll choice
            pollMap[_pollID].votesFor += numTokens;
        else
            pollMap[_pollID].votesAgainst += numTokens;
        
        dllMap[msg.sender].remove(_pollID); // remove the node referring to this vote upon reveal

        VoteRevealed(msg.sender, _pollID, numTokens, _voteOption);
    }

    /**
    @param _pollID Integer identifier associated with target poll
    @param _salt Arbitrarily chosen integer used to generate secretHash
    @return correctVotes Number of tokens voted for winning option
    */
    function getNumPassingTokens(address _voter, uint _pollID, uint _salt) public constant returns (uint correctVotes) {
        require(pollEnded(_pollID));
        require(hasBeenRevealed(_voter, _pollID));

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

        pollMap[pollNonce] = Poll({
            voteQuorum: _voteQuorum,
            commitEndDate: block.timestamp + _commitDuration,
            revealEndDate: block.timestamp + _commitDuration + _revealDuration,
            votesFor: 0,
            votesAgainst: 0
        });

        PollCreated(_voteQuorum, _commitDuration, _revealDuration, pollNonce);
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
    @dev Checks if user has already revealed for specified poll
    @param _voter Address of user to check against
    @param _pollID Integer identifier associated with target poll
    @return Boolean indication of whether user has already revealed
    */
    function hasBeenRevealed(address _voter, uint _pollID) constant public returns (bool revealed) {
        require(pollExists(_pollID));

        return !dllMap[_voter].contains(_pollID);
    }

    /**
    @dev Checks if a poll exists, throws if the provided poll is in an impossible state
    @param _pollID The pollID whose existance is to be evaluated.
    @return Boolean Indicates whether a poll exists for the provided pollID
    */
    function pollExists(uint _pollID) constant public returns (bool exists) {
        uint commitEndDate = pollMap[_pollID].commitEndDate;
        uint revealEndDate = pollMap[_pollID].revealEndDate;

        assert(!(commitEndDate == 0 && revealEndDate != 0));
        assert(!(commitEndDate != 0 && revealEndDate == 0));

        if(commitEndDate == 0 || revealEndDate == 0) { return false; }
        return true;
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

    /**
    @dev Gets the prevNode a new node should be inserted after given the sort factor
    @param _voter The voter whose DLL will be searched
    @param _numTokens The value for the numTokens attribute in the node to be inserted
    @return the node which the propoded node should be inserted after
    */
    function getInsertPointForNumTokens(address _voter, uint _numTokens)
    constant public returns (uint prevNode) {
      uint nodeID = getLastNode(_voter);
      uint tokensInNode = getNumTokens(_voter, nodeID);

      while(tokensInNode != 0) {
        tokensInNode = getNumTokens(_voter, nodeID);
        if(tokensInNode < _numTokens) {
          return nodeID;
        }
        nodeID = dllMap[_voter].getPrev(nodeID);
      }

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

contract Parameterizer {

  // ------
  // EVENTS
  // ------

  event _ReparameterizationProposal(address proposer, string name, uint value, bytes32 propID);
  event _NewChallenge(address challenger, bytes32 propID, uint pollID);


  // ------
  // DATA STRUCTURES
  // ------

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
  EIP20 public token;
  PLCRVoting public voting;
  uint public PROCESSBY = 604800; // 7 days

  // ------------
  // CONSTRUCTOR
  // ------------

  /**
  @dev constructor
  @param _tokenAddr        address of the token which parameterizes this system
  @param _plcrAddr         address of a PLCR voting contract for the provided token
  @param _minDeposit       minimum deposit for listing to be whitelisted  
  @param _pMinDeposit      minimum deposit to propose a reparameterization
  @param _applyStageLen    period over which applicants wait to be whitelisted
  @param _pApplyStageLen   period over which reparmeterization proposals wait to be processed 
  @param _dispensationPct  percentage of losing party's deposit distributed to winning party
  @param _pDispensationPct percentage of losing party's deposit distributed to winning party in parameterizer
  @param _commitStageLen  length of commit period for voting
  @param _pCommitStageLen length of commit period for voting in parameterizer
  @param _revealStageLen  length of reveal period for voting
  @param _pRevealStageLen length of reveal period for voting in parameterizer
  @param _voteQuorum       type of majority out of 100 necessary for vote success
  @param _pVoteQuorum      type of majority out of 100 necessary for vote success in parameterizer
  */
  function Parameterizer( 
    address _tokenAddr,
    address _plcrAddr,
    uint _minDeposit,
    uint _pMinDeposit,
    uint _applyStageLen,
    uint _pApplyStageLen,
    uint _commitStageLen,
    uint _pCommitStageLen,
    uint _revealStageLen,
    uint _pRevealStageLen,
    uint _dispensationPct,
    uint _pDispensationPct,
    uint _voteQuorum,
    uint _pVoteQuorum
    ) public {
      token = EIP20(_tokenAddr);
      voting = PLCRVoting(_plcrAddr);

      set("minDeposit", _minDeposit);
      set("pMinDeposit", _pMinDeposit);
      set("applyStageLen", _applyStageLen);
      set("pApplyStageLen", _pApplyStageLen);
      set("commitStageLen", _commitStageLen);
      set("pCommitStageLen", _pCommitStageLen);
      set("revealStageLen", _revealStageLen);
      set("pRevealStageLen", _pRevealStageLen);
      set("dispensationPct", _dispensationPct);
      set("pDispensationPct", _pDispensationPct);
      set("voteQuorum", _voteQuorum);
      set("pVoteQuorum", _pVoteQuorum);
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

    require(!propExists(propID)); // Forbid duplicate proposals
    require(get(_name) != _value); // Forbid NOOP reparameterizations
    require(token.transferFrom(msg.sender, this, deposit)); // escrow tokens (deposit amt)

    // attach name and value to pollID    
    proposals[propID] = ParamProposal({
      appExpiry: now + get("pApplyStageLen"),
      challengeID: 0,
      deposit: deposit,
      name: _name,
      owner: msg.sender,
      processBy: now + get("pApplyStageLen") + get("pCommitStageLen") +
        get("pRevealStageLen") + PROCESSBY,
      value: _value
    });

    _ReparameterizationProposal(msg.sender, _name, _value, propID);
    return propID;
  }

  /**
  @notice challenge the provided proposal ID, and put tokens at stake to do so.
  @param _propID the proposal ID to challenge
  */
  function challengeReparameterization(bytes32 _propID) public returns (uint challengeID) {
    ParamProposal memory prop = proposals[_propID];
    uint deposit = get("pMinDeposit");

    require(propExists(_propID) && prop.challengeID == 0); 

    //take tokens from challenger
    require(token.transferFrom(msg.sender, this, deposit));
    //start poll
    uint pollID = voting.startPoll(
      get("pVoteQuorum"),
      get("pCommitStageLen"),
      get("pRevealStageLen")
    );

    challenges[pollID] = Challenge({
      challenger: msg.sender,
      rewardPool: ((100 - get("pDispensationPct")) * deposit) / 100, 
      stake: deposit,
      resolved: false,
      winningTokens: 0
    });

    proposals[_propID].challengeID = pollID;       // update listing to store most recent challenge

    _NewChallenge(msg.sender, _propID, pollID);
    return pollID;
  }

  /**
  @notice for the provided proposal ID, set it, resolve its challenge, or delete it depending on whether it can be set, has a challenge which can be resolved, or if its "process by" date has passed
  @param _propID the proposal ID to make a determination and state transition for
  */
  function processProposal(bytes32 _propID) public {
    ParamProposal storage prop = proposals[_propID];

    if (canBeSet(_propID)) {
      set(prop.name, prop.value);
    } else if (challengeCanBeResolved(_propID)) {
      resolveChallenge(_propID);
    } else if (now > prop.processBy) {
      require(token.transfer(prop.owner, prop.deposit));
    } else {
      revert();
    }

    delete proposals[_propID];
  }

  /**
  @notice claim the tokens owed for the msg.sender in the provided challenge
  @param _challengeID the challenge ID to claim tokens for
  @param _salt the salt used to vote in the challenge being withdrawn for
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

    require(token.transfer(msg.sender, reward));
    
    // ensures a voter cannot claim tokens again
    challenges[_challengeID].tokenClaims[msg.sender] = true;
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

    return (prop.challengeID > 0 && challenge.resolved == false &&
            voting.pollEnded(prop.challengeID));
  }

  /**
  @notice Determines the number of tokens to awarded to the winning party in a challenge
  @param _challengeID The challengeID to determine a reward for
  */
  function challengeWinnerReward(uint _challengeID) public view returns (uint) {
    if(voting.getTotalNumberOfTokensForWinningOption(_challengeID) == 0) {
      // Edge case, nobody voted, give all tokens to the winner.
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

    if (voting.isPassed(prop.challengeID)) { // The challenge failed
      if(prop.processBy > now) {
        set(prop.name, prop.value);
      }
      require(token.transfer(prop.owner, reward));
    } 
    else { // The challenge succeeded
      require(token.transfer(challenges[prop.challengeID].challenger, reward));
    }

    challenge.winningTokens =
      voting.getTotalNumberOfTokensForWinningOption(prop.challengeID);
    challenge.resolved = true;
  }

  /**
  @dev sets the param keted by the provided name to the provided value
  @param _name the name of the param to be set
  @param _value the value to set the param to be set
  */
  function set(string _name, uint _value) private {
    params[keccak256(_name)] = _value;
  }
}
contract Registry {

    // ------
    // EVENTS
    // ------

    event _Application(bytes32 listingHash, uint deposit, string data);
    event _Challenge(bytes32 listingHash, uint deposit, uint pollID, string data);
    event _Deposit(bytes32 listingHash, uint added, uint newTotal);
    event _Withdrawal(bytes32 listingHash, uint withdrew, uint newTotal);
    event _NewListingWhitelisted(bytes32 listingHash);
    event _ApplicationRemoved(bytes32 listingHash);
    event _ListingRemoved(bytes32 listingHash);
    event _ChallengeFailed(uint challengeID);
    event _ChallengeSucceeded(uint challengeID);
    event _RewardClaimed(address voter, uint challengeID, uint reward);

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
    mapping(bytes32 => Listing) public listings;

    // Global Variables
    EIP20 public token;
    PLCRVoting public voting;
    Parameterizer public parameterizer;
    string public version = '1';

    // ------------
    // CONSTRUCTOR:
    // ------------

    /**
    @dev Contructor         Sets the addresses for token, voting, and parameterizer
    @param _tokenAddr       Address of the TCR's intrinsic ERC20 token
    @param _plcrAddr        Address of a PLCR voting contract for the provided token
    @param _paramsAddr      Address of a Parameterizer contract 
    */
    function Registry(
        address _tokenAddr,
        address _plcrAddr,
        address _paramsAddr
    ) public {
        token = EIP20(_tokenAddr);
        voting = PLCRVoting(_plcrAddr);
        parameterizer = Parameterizer(_paramsAddr);
    }

    // --------------------
    // PUBLISHER INTERFACE:
    // --------------------

    /**
    @dev                Allows a user to start an application. Takes tokens from user and sets
                        apply stage end time.
    @param _listingHash The hash of a potential listing a user is applying to add to the registry
    @param _amount      The number of ERC20 tokens a user is willing to potentially stake
    @param _data        Extra data relevant to the application. Think IPFS hashes.
    */
    function apply(bytes32 _listingHash, uint _amount, string _data) external {
        require(!isWhitelisted(_listingHash));
        require(!appWasMade(_listingHash));
        require(_amount >= parameterizer.get("minDeposit"));

        // Sets owner
        Listing storage listingHash = listings[_listingHash];
        listingHash.owner = msg.sender;

        // Transfers tokens from user to Registry contract
        require(token.transferFrom(listingHash.owner, this, _amount));

        // Sets apply stage end time
        listingHash.applicationExpiry = block.timestamp + parameterizer.get("applyStageLen");
        listingHash.unstakedDeposit = _amount;

        _Application(_listingHash, _amount, _data);
    }

    /**
    @dev                Allows the owner of a listingHash to increase their unstaked deposit.
    @param _listingHash A listingHash msg.sender is the owner of
    @param _amount      The number of ERC20 tokens to increase a user's unstaked deposit
    */
    function deposit(bytes32 _listingHash, uint _amount) external {
        Listing storage listingHash = listings[_listingHash];

        require(listingHash.owner == msg.sender);
        require(token.transferFrom(msg.sender, this, _amount));

        listingHash.unstakedDeposit += _amount;

        _Deposit(_listingHash, _amount, listingHash.unstakedDeposit);
    }

    /**
    @dev                Allows the owner of a listingHash to decrease their unstaked deposit.
    @param _listingHash A listingHash msg.sender is the owner of.
    @param _amount      The number of ERC20 tokens to withdraw from the unstaked deposit.
    */
    function withdraw(bytes32 _listingHash, uint _amount) external {
        Listing storage listingHash = listings[_listingHash];

        require(listingHash.owner == msg.sender);
        require(_amount <= listingHash.unstakedDeposit);
        require(listingHash.unstakedDeposit - _amount >= parameterizer.get("minDeposit"));

        require(token.transfer(msg.sender, _amount));

        listingHash.unstakedDeposit -= _amount;

        _Withdrawal(_listingHash, _amount, listingHash.unstakedDeposit);
    }

    /**
    @dev                Allows the owner of a listingHash to remove the listingHash from the whitelist
                        Returns all tokens to the owner of the listingHash
    @param _listingHash A listingHash msg.sender is the owner of.
    */
    function exit(bytes32 _listingHash) external {
        Listing storage listingHash = listings[_listingHash];

        require(msg.sender == listingHash.owner);
        require(isWhitelisted(_listingHash));

        // Cannot exit during ongoing challenge
        require(listingHash.challengeID == 0 || challenges[listingHash.challengeID].resolved);

        // Remove listingHash & return tokens
        resetListing(_listingHash);
    }

    // -----------------------
    // TOKEN HOLDER INTERFACE:
    // -----------------------

    /**
    @dev                Starts a poll for a listingHash which is either in the apply stage or
                        already in the whitelist. Tokens are taken from the challenger and the
                        applicant's deposits are locked.
    @param _listingHash The listingHash being challenged, whether listed or in application
    @param _data        Extra data relevant to the challenge. Think IPFS hashes.
    */
    function challenge(bytes32 _listingHash, string _data) external returns (uint challengeID) {
        bytes32 listingHashHash = _listingHash;
        Listing storage listingHash = listings[listingHashHash];
        uint deposit = parameterizer.get("minDeposit");

        // Listing must be in apply stage or already on the whitelist
        require(appWasMade(_listingHash) || listingHash.whitelisted);
        // Prevent multiple challenges
        require(listingHash.challengeID == 0 || challenges[listingHash.challengeID].resolved);

        if (listingHash.unstakedDeposit < deposit) {
            // Not enough tokens, listingHash auto-delisted
            resetListing(_listingHash);
            return 0;
        }

        // Takes tokens from challenger
        require(token.transferFrom(msg.sender, this, deposit));

        // Starts poll
        uint pollID = voting.startPoll(
            parameterizer.get("voteQuorum"),
            parameterizer.get("commitStageLen"),
            parameterizer.get("revealStageLen")
        );

        challenges[pollID] = Challenge({
            challenger: msg.sender,
            rewardPool: ((100 - parameterizer.get("dispensationPct")) * deposit) / 100,
            stake: deposit,
            resolved: false,
            totalTokens: 0
        });

        // Updates listingHash to store most recent challenge
        listings[listingHashHash].challengeID = pollID;

        // Locks tokens for listingHash during challenge
        listings[listingHashHash].unstakedDeposit -= deposit;

        _Challenge(_listingHash, deposit, pollID, _data);
        return pollID;
    }

    /**
    @dev                Updates a listingHash's status from 'application' to 'listing' or resolves
                        a challenge if one exists.
    @param _listingHash The listingHash whose status is being updated
    */
    function updateStatus(bytes32 _listingHash) public {
        if (canBeWhitelisted(_listingHash)) {
          whitelistApplication(_listingHash);
          _NewListingWhitelisted(_listingHash);
        } else if (challengeCanBeResolved(_listingHash)) {
          resolveChallenge(_listingHash);
        } else {
          revert();
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
        require(challenges[_challengeID].tokenClaims[msg.sender] == false);
        require(challenges[_challengeID].resolved == true);

        uint voterTokens = voting.getNumPassingTokens(msg.sender, _challengeID, _salt);
        uint reward = voterReward(msg.sender, _challengeID, _salt);

        // Subtracts the voter's information to preserve the participation ratios
        // of other voters compared to the remaining pool of rewards
        challenges[_challengeID].totalTokens -= voterTokens;
        challenges[_challengeID].rewardPool -= reward;

        require(token.transfer(msg.sender, reward));

        // Ensures a voter cannot claim tokens again
        challenges[_challengeID].tokenClaims[msg.sender] = true;

        _RewardClaimed(msg.sender, _challengeID, reward);
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
    @param _listingHash The listingHash whose status is to be examined
    */
    function canBeWhitelisted(bytes32 _listingHash) view public returns (bool) {
        bytes32 listingHashHash = _listingHash;
        uint challengeID = listings[listingHashHash].challengeID;

        // Ensures that the application was made,
        // the application period has ended,
        // the listingHash can be whitelisted,
        // and either: the challengeID == 0, or the challenge has been resolved.
        if (
            appWasMade(_listingHash) &&
            listings[listingHashHash].applicationExpiry < now &&
            !isWhitelisted(_listingHash) &&
            (challengeID == 0 || challenges[challengeID].resolved == true)
        ) { return true; }

        return false;
    }

    /**
    @dev                Returns true if the provided listingHash is whitelisted
    @param _listingHash The listingHash whose status is to be examined
    */
    function isWhitelisted(bytes32 _listingHash) view public returns (bool whitelisted) {
        return listings[_listingHash].whitelisted;
    }

    /**
    @dev                Returns true if apply was called for this listingHash
    @param _listingHash The listingHash whose status is to be examined
    */
    function appWasMade(bytes32 _listingHash) view public returns (bool exists) {
        return listings[_listingHash].applicationExpiry > 0;
    }

    /**
    @dev                Returns true if the application/listingHash has an unresolved challenge
    @param _listingHash The listingHash whose status is to be examined
    */
    function challengeExists(bytes32 _listingHash) view public returns (bool) {
        bytes32 listingHashHash = _listingHash;
        uint challengeID = listings[listingHashHash].challengeID;

        return (listings[listingHashHash].challengeID > 0 && !challenges[challengeID].resolved);
    }

    /**
    @dev                Determines whether voting has concluded in a challenge for a given
                        listingHash. Throws if no challenge exists.
    @param _listingHash A listingHash with an unresolved challenge
    */
    function challengeCanBeResolved(bytes32 _listingHash) view public returns (bool) {
        bytes32 listingHashHash = _listingHash;
        uint challengeID = listings[listingHashHash].challengeID;

        require(challengeExists(_listingHash));

        return voting.pollEnded(challengeID);
    }

    /**
    @dev                Determines the number of tokens awarded to the winning party in a challenge.
    @param _challengeID The challengeID to determine a reward for
    */
    function determineReward(uint _challengeID) public view returns (uint) {
        require(!challenges[_challengeID].resolved && voting.pollEnded(_challengeID));

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
    @param _listingHash A listingHash with a challenge that is to be resolved
    */
    function resolveChallenge(bytes32 _listingHash) private {
        bytes32 listingHashHash = _listingHash;
        uint challengeID = listings[listingHashHash].challengeID;

        // Calculates the winner's reward,
        // which is: (winner's full stake) + (dispensationPct * loser's stake)
        uint reward = determineReward(challengeID);

        // Records whether the listingHash is a listingHash or an application
        bool wasWhitelisted = isWhitelisted(_listingHash);

        // Case: challenge failed
        if (voting.isPassed(challengeID)) {
            whitelistApplication(_listingHash);
            // Unlock stake so that it can be retrieved by the applicant
            listings[listingHashHash].unstakedDeposit += reward;

            _ChallengeFailed(challengeID);
            if (!wasWhitelisted) { _NewListingWhitelisted(_listingHash); }
        }
        // Case: challenge succeeded
        else {
            resetListing(_listingHash);
            // Transfer the reward to the challenger
            require(token.transfer(challenges[challengeID].challenger, reward));

            _ChallengeSucceeded(challengeID);
            if (wasWhitelisted) { _ListingRemoved(_listingHash); }
            else { _ApplicationRemoved(_listingHash); }
        }

        // Sets flag on challenge being processed
        challenges[challengeID].resolved = true;

        // Stores the total tokens used for voting by the winning side for reward purposes
        challenges[challengeID].totalTokens =
            voting.getTotalNumberOfTokensForWinningOption(challengeID);
    }

    /**
    @dev                Called by updateStatus() if the applicationExpiry date passed without a
                        challenge being made. Called by resolveChallenge() if an
                        application/listing beat a challenge.
    @param _listingHash The listingHash of an application/listingHash to be whitelisted
    */
    function whitelistApplication(bytes32 _listingHash) private {
        listings[_listingHash].whitelisted = true;
    }

    /**
    @dev                Deletes a listingHash from the whitelist and transfers tokens back to owner
    @param _listingHash The listing hash to delete
    */
    function resetListing(bytes32 _listingHash) private {
        bytes32 listingHashHash = _listingHash;
        Listing storage listingHash = listings[listingHashHash];

        // Transfers any remaining balance back to the owner
        if (listingHash.unstakedDeposit > 0)
            require(token.transfer(listingHash.owner, listingHash.unstakedDeposit));

        delete listings[listingHashHash];
    }
}