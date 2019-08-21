pragma solidity ^0.4.24;


/**
 * Libraries
**/

library ExtendedMath {
    function limitLessThan(uint a, uint b) internal pure returns(uint c) {
        if (a > b) return b;
        return a;
    }
}

library SafeMath {

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 _a, uint256 _b) internal pure returns(uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 _a, uint256 _b) internal pure returns(uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 _a, uint256 _b) internal pure returns(uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b != 0);
        return a % b;
    }
}

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

contract ERC20Basic {
    function totalSupply() public view returns(uint256);

    function balanceOf(address _who) public view returns(uint256);

    function transfer(address _to, uint256 _value) public returns(bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address _owner, address _spender) public view returns(uint256);

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool);

    function approve(address _spender, uint256 _value) public returns(bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract BasicToken is ERC20Basic {
    using SafeMath
    for uint256;

    mapping(address => uint256) internal balances;

    uint256 internal totalSupply_;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns(uint256) {
        return totalSupply_;
    }

    /**
     * @dev Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns(bool) {
        //require(_value <= balances[msg.sender]);
        require(_to != address(0));

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns(uint256) {
        return balances[_owner];
    }

}

contract StandardToken is ERC20, BasicToken {

    mapping(address => mapping(address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
    public
    returns(bool) {
        //require(_value <= balances[_from]);
        //require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns(bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(
        address _owner,
        address _spender
    )
    public
    view
    returns(uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
    public
    returns(bool) {
        allowed[msg.sender][_spender] = (
            allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
    public
    returns(bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

interface IRemoteFunctions {
  function _externalAddMasternode(address) external;
  function _externalStopMasternode(address) external;
}

interface IcaelumVoting {
    function getTokenProposalDetails() external view returns(address, uint, uint, uint);
    function getExpiry() external view returns (uint);
    function getContractType () external view returns (uint);
}

interface EIP918Interface  {

    /*
     * Externally facing mint function that is called by miners to validate challenge digests, calculate reward,
     * populate statistics, mutate epoch variables and adjust the solution difficulty as required. Once complete,
     * a Mint event is emitted before returning a success indicator.
     **/
  	function mint(uint256 nonce, bytes32 challenge_digest) external returns (bool success);


	/*
     * Returns the challenge number
     **/
    function getChallengeNumber() external constant returns (bytes32);

    /*
     * Returns the mining difficulty. The number of digits that the digest of the PoW solution requires which
     * typically auto adjusts during reward generation.
     **/
    function getMiningDifficulty() external constant returns (uint);

    /*
     * Returns the mining target
     **/
    function getMiningTarget() external constant returns (uint);

    /*
     * Return the current reward amount. Depending on the algorithm, typically rewards are divided every reward era
     * as tokens are mined to provide scarcity
     **/
    function getMiningReward() external constant returns (uint);

    /*
     * Upon successful verification and reward the mint method dispatches a Mint Event indicating the reward address,
     * the reward amount, the epoch count and newest challenge number.
     **/
    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

}

contract NewMinerProposal is IcaelumVoting {

    enum VOTE_TYPE {MINER, MASTER, TOKEN}

    VOTE_TYPE public contractType = VOTE_TYPE.TOKEN;
    address contractAddress;
    uint validUntil;
    uint votingDurationInDays;

    /**
     * @dev Create a new vote proposal for an ERC20 token.
     * @param _contract ERC20 contract
     * @param _valid How long do we accept these tokens on the contract (UNIX timestamp)
     * @param _voteDuration How many days is this vote available
     */
    constructor(address _contract, uint _valid, uint _voteDuration) public {
        require(_voteDuration >= 14 && _voteDuration <= 50, "Proposed voting duration does not meet requirements");

        contractAddress = _contract;
        validUntil = _valid;
        votingDurationInDays = _voteDuration;
    }

    /**
     * @dev Returns all details about this proposal
     */
    function getTokenProposalDetails() public view returns(address, uint, uint, uint) {
        return (contractAddress, 0, validUntil, uint(contractType));
    }

    /**
     * @dev Displays the expiry date of contract
     * @return uint Days valid
     */
    function getExpiry() external view returns (uint) {
        return votingDurationInDays;
    }

    /**
     * @dev Displays the type of contract
     * @return uint Enum value {TOKEN, TEAM}
     */
    function getContractType () external view returns (uint){
        return uint(contractType);
    }
}

contract CaelumVotings is Ownable {
    using SafeMath for uint;

    enum VOTE_TYPE {MINER, MASTER, TOKEN}

    struct Proposals {
        address tokenContract;
        uint totalVotes;
        uint proposedOn;
        uint acceptedOn;
        VOTE_TYPE proposalType;
    }

    struct Voters {
        bool isVoter;
        address owner;
        uint[] votedFor;
    }

    uint MAJORITY_PERCENTAGE_NEEDED = 60;
    uint MINIMUM_VOTERS_NEEDED = 1;
    bool public proposalPending;

    mapping(uint => Proposals) public proposalList;
    mapping (address => Voters) public voterMap;
    mapping(uint => address) public voterProposals;
    uint public proposalCounter;
    uint public votersCount;
    uint public votersCountTeam;


    function setMasternodeContractFromVote(address _t) internal ;
    function setTokenContractFromVote(address _t) internal;
    function setMiningContractFromVote (address _t) internal;

    event NewProposal(uint ProposalID);
    event ProposalAccepted(uint ProposalID);

    address _CaelumMasternodeContract;
    CaelumMasternode public MasternodeContract;

    function setMasternodeContractForData(address _t) onlyOwner public {
        MasternodeContract = CaelumMasternode(_t);
        _CaelumMasternodeContract = (_t);
    }

    function setVotingMinority(uint _total) onlyOwner public {
        require(_total > MINIMUM_VOTERS_NEEDED);
        MINIMUM_VOTERS_NEEDED = _total;
    }


    /**
     * @dev Create a new proposal.
     * @param _contract Proposal contract address
     * @return uint ProposalID
     */
    function pushProposal(address _contract) onlyOwner public returns (uint) {
        if(proposalCounter != 0)
        require (pastProposalTimeRules (), "You need to wait 90 days before submitting a new proposal.");
        require (!proposalPending, "Another proposal is pending.");

        uint _contractType = IcaelumVoting(_contract).getContractType();
        proposalList[proposalCounter] = Proposals(_contract, 0, now, 0, VOTE_TYPE(_contractType));

        emit NewProposal(proposalCounter);

        proposalCounter++;
        proposalPending = true;

        return proposalCounter.sub(1);
    }

    /**
     * @dev Internal function that handles the proposal after it got accepted.
     * This function determines if the proposal is a token or team member proposal and executes the corresponding functions.
     * @return uint Returns the proposal ID.
     */
    function handleLastProposal () internal returns (uint) {
        uint _ID = proposalCounter.sub(1);

        proposalList[_ID].acceptedOn = now;
        proposalPending = false;

        address _address;
        uint _required;
        uint _valid;
        uint _type;
        (_address, _required, _valid, _type) = getTokenProposalDetails(_ID);

        if(_type == uint(VOTE_TYPE.MINER)) {
            setMiningContractFromVote(_address);
        }

        if(_type == uint(VOTE_TYPE.MASTER)) {
            setMasternodeContractFromVote(_address);
        }

        if(_type == uint(VOTE_TYPE.TOKEN)) {
            setTokenContractFromVote(_address);
        }

        emit ProposalAccepted(_ID);

        return _ID;
    }

    /**
     * @dev Rejects the last proposal after the allowed voting time has expired and it's not accepted.
     */
    function discardRejectedProposal() onlyOwner public returns (bool) {
        require(proposalPending);
        require (LastProposalCanDiscard());
        proposalPending = false;
        return (true);
    }

    /**
     * @dev Checks if the last proposal allowed voting time has expired and it's not accepted.
     * @return bool
     */
    function LastProposalCanDiscard () public view returns (bool) {

        uint daysBeforeDiscard = IcaelumVoting(proposalList[proposalCounter - 1].tokenContract).getExpiry();
        uint entryDate = proposalList[proposalCounter - 1].proposedOn;
        uint expiryDate = entryDate + (daysBeforeDiscard * 1 days);

        if (now >= expiryDate)
        return true;
    }

    /**
     * @dev Returns all details about a proposal
     */
    function getTokenProposalDetails(uint proposalID) public view returns(address, uint, uint, uint) {
        return IcaelumVoting(proposalList[proposalID].tokenContract).getTokenProposalDetails();
    }

    /**
     * @dev Returns if our 90 day cooldown has passed
     * @return bool
     */
    function pastProposalTimeRules() public view returns (bool) {
        uint lastProposal = proposalList[proposalCounter - 1].proposedOn;
        if (now >= lastProposal + 90 days)
        return true;
    }


    /**
     * @dev Allow any masternode user to become a voter.
     */
    function becomeVoter() public  {
        require (MasternodeContract.isMasternodeOwner(msg.sender), "User has no masternodes");
        require (!voterMap[msg.sender].isVoter, "User Already voted for this proposal");

        voterMap[msg.sender].owner = msg.sender;
        voterMap[msg.sender].isVoter = true;
        votersCount = votersCount + 1;

        if (MasternodeContract.isTeamMember(msg.sender))
        votersCountTeam = votersCountTeam + 1;
    }

    /**
     * @dev Allow voters to submit their vote on a proposal. Voters can only cast 1 vote per proposal.
     * If the proposed vote is about adding Team members, only Team members are able to vote.
     * A proposal can only be published if the total of votes is greater then MINIMUM_VOTERS_NEEDED.
     * @param proposalID proposalID
     */
    function voteProposal(uint proposalID) public returns (bool success) {
        require(voterMap[msg.sender].isVoter, "Sender not listed as voter");
        require(proposalID >= 0, "No proposal was selected.");
        require(proposalID <= proposalCounter, "Proposal out of limits.");
        require(voterProposals[proposalID] != msg.sender, "Already voted.");


        require(votersCount >= MINIMUM_VOTERS_NEEDED, "Not enough voters in existence to push a proposal");
        voterProposals[proposalID] = msg.sender;
        proposalList[proposalID].totalVotes++;

        if(reachedMajority(proposalID)) {
            // This is the prefered way of handling vote results. It costs more gas but prevents tampering.
            // If gas is an issue, you can comment handleLastProposal out and call it manually as onlyOwner.
            handleLastProposal();
            return true;

        }

    }

    /**
     * @dev Check if a proposal has reached the majority vote
     * @param proposalID Token ID
     * @return bool
     */
    function reachedMajority (uint proposalID) public view returns (bool) {
        uint getProposalVotes = proposalList[proposalID].totalVotes;
        if (getProposalVotes >= majority())
        return true;
    }

    /**
     * @dev Internal function that calculates the majority
     * @return uint Total of votes needed for majority
     */
    function majority () internal view returns (uint) {
        uint a = (votersCount * MAJORITY_PERCENTAGE_NEEDED );
        return a / 100;
    }

    /**
     * @dev Check if a proposal has reached the majority vote for a team member
     * @param proposalID Token ID
     * @return bool
     */
    function reachedMajorityForTeam (uint proposalID) public view returns (bool) {
        uint getProposalVotes = proposalList[proposalID].totalVotes;
        if (getProposalVotes >= majorityForTeam())
        return true;
    }

    /**
     * @dev Internal function that calculates the majority
     * @return uint Total of votes needed for majority
     */
    function majorityForTeam () internal view returns (uint) {
        uint a = (votersCountTeam * MAJORITY_PERCENTAGE_NEEDED );
        return a / 100;
    }

}

contract CaelumAcceptERC20 is Ownable  {
    using SafeMath for uint;

    IRemoteFunctions public DataVault;

    address[] public tokensList;
    bool setOwnContract = true;

    struct _whitelistTokens {
        address tokenAddress;
        bool active;
        uint requiredAmount;
        uint validUntil;
        uint timestamp;
    }

    mapping(address => mapping(address => uint)) public tokens;
    mapping(address => _whitelistTokens) acceptedTokens;

    event Deposit(address token, address user, uint amount, uint balance);
    event Withdraw(address token, address user, uint amount, uint balance);

    


    /**
     * @notice Allow the dev to set it's own token as accepted payment.
     * @dev Can be hardcoded in the constructor. Given the contract size, we decided to separate it.
     * @return bool
     */
    function addOwnToken() onlyOwner public returns (bool) {
        require(setOwnContract);
        addToWhitelist(this, 5000 * 1e8, 36500);
        setOwnContract = false;
        return true;
    }


    /**
     * @notice Add a new token as accepted payment method.
     * @param _token Token contract address.
     * @param _amount Required amount of this Token as collateral
     * @param daysAllowed How many days will we accept this token?
     */
    function addToWhitelist(address _token, uint _amount, uint daysAllowed) internal {
        _whitelistTokens storage newToken = acceptedTokens[_token];
        newToken.tokenAddress = _token;
        newToken.requiredAmount = _amount;
        newToken.timestamp = now;
        newToken.validUntil = now + (daysAllowed * 1 days);
        newToken.active = true;

        tokensList.push(_token);
    }

    /**
     * @dev internal function to determine if we accept this token.
     * @param _ad Token contract address
     * @return bool
     */
    function isAcceptedToken(address _ad) internal view returns(bool) {
        return acceptedTokens[_ad].active;
    }

    /**
     * @dev internal function to determine the requiredAmount for a specific token.
     * @param _ad Token contract address
     * @return bool
     */
    function getAcceptedTokenAmount(address _ad) internal view returns(uint) {
        return acceptedTokens[_ad].requiredAmount;
    }

    /**
     * @dev internal function to determine if the token is still accepted timewise.
     * @param _ad Token contract address
     * @return bool
     */
    function isValid(address _ad) internal view returns(bool) {
        uint endTime = acceptedTokens[_ad].validUntil;
        if (block.timestamp < endTime) return true;
        return false;
    }

    /**
     * @notice Returns an array of all accepted token. You can get more details by calling getTokenDetails function with this address.
     * @return array Address
     */
    function listAcceptedTokens() public view returns(address[]) {
        return tokensList;
    }

    /**
     * @notice Returns a full list of the token details
     * @param token Token contract address
     */
    function getTokenDetails(address token) public view returns(address ad,uint required, bool active, uint valid) {
        return (acceptedTokens[token].tokenAddress, acceptedTokens[token].requiredAmount,acceptedTokens[token].active, acceptedTokens[token].validUntil);
    }

    /**
     * @notice Public function that allows any user to deposit accepted tokens as collateral to become a masternode.
     * @param token Token contract address
     * @param amount Amount to deposit
     */
    function depositCollateral(address token, uint amount) public {
        require(isAcceptedToken(token), "ERC20 not authorised");  // Should be a token from our list
        require(amount == getAcceptedTokenAmount(token));         // The amount needs to match our set amount
        require(isValid(token));                                  // It should be called within the setup timeframe

        tokens[token][msg.sender] = tokens[token][msg.sender].add(amount);

        require(StandardToken(token).transferFrom(msg.sender, this, amount), "error with token");
        emit Deposit(token, msg.sender, amount, tokens[token][msg.sender]);

        DataVault._externalAddMasternode(msg.sender);
    }


    /**
     * @notice Public function that allows any user to withdraw deposited tokens and stop as masternode
     * @param token Token contract address
     * @param amount Amount to withdraw
     */
    function withdrawCollateral(address token, uint amount) public {
        require(token != 0);                                        // token should be an actual address
        require(isAcceptedToken(token), "ERC20 not authorised");    // Should be a token from our list
        require(amount == getAcceptedTokenAmount(token));           // The amount needs to match our set amount, allow only one withdrawal at a time.
        require(tokens[token][msg.sender] >= amount);               // The owner must own at least this amount of tokens.

        uint amountToWithdraw = tokens[token][msg.sender];
        tokens[token][msg.sender] = 0;

        DataVault._externalStopMasternode(msg.sender);

        if (!StandardToken(token).transfer(msg.sender, amountToWithdraw)) revert();
        emit Withdraw(token, msg.sender, amountToWithdraw, amountToWithdraw);
    }

    function setDataStorage (address _masternodeContract) onlyOwner public {
        DataVault = IRemoteFunctions(_masternodeContract);
    }
}

contract CaelumAbstractMasternode is Ownable{
    using SafeMath for uint;

    bool onTestnet = false;
    bool genesisAdded = false;

    uint public masternodeRound;
    uint public masternodeCandidate;
    uint public masternodeCounter;
    uint public masternodeEpoch;
    uint public miningEpoch;

    uint public rewardsProofOfWork;
    uint public rewardsMasternode;
    uint rewardsGlobal = 50 * 1e8;

    uint public MINING_PHASE_DURATION_BLOCKS = 4500;

    struct MasterNode {
        address accountOwner;
        bool isActive;
        bool isTeamMember;
        uint storedIndex;
        uint startingRound;
        uint[] indexcounter;
    }

    uint[] userArray;
    address[] userAddressArray;

    mapping(uint => MasterNode) userByIndex; // UINT masterMapping
    mapping(address => MasterNode) userByAddress; //masterMapping
    mapping(address => uint) userAddressIndex;

    event Deposit(address token, address user, uint amount, uint balance);
    event Withdraw(address token, address user, uint amount, uint balance);

    event NewMasternode(address candidateAddress, uint timeStamp);
    event RemovedMasternode(address candidateAddress, uint timeStamp);

    /**
     * @dev Add the genesis accounts
     */
    function addGenesis(address _genesis, bool _team) onlyOwner public {
        require(!genesisAdded);

        addMasternode(_genesis);

        if (_team) {
            updateMasternodeAsTeamMember(msg.sender);
        }

    }

    /**
     * @dev Close the genesis accounts
     */
    function closeGenesis() onlyOwner public {
        genesisAdded = true; // Forever lock this.
    }

    /**
     * @dev Add a user as masternode. Called as internal since we only add masternodes by depositing collateral or by voting.
     * @param _candidate Candidate address
     * @return uint Masternode index
     */
    function addMasternode(address _candidate) internal returns(uint) {
        userByIndex[masternodeCounter].accountOwner = _candidate;
        userByIndex[masternodeCounter].isActive = true;
        userByIndex[masternodeCounter].startingRound = masternodeRound + 1;
        userByIndex[masternodeCounter].storedIndex = masternodeCounter;

        userByAddress[_candidate].accountOwner = _candidate;
        userByAddress[_candidate].indexcounter.push(masternodeCounter);

        userArray.push(userArray.length);
        masternodeCounter++;

        emit NewMasternode(_candidate, now);
        return masternodeCounter - 1; //
    }

    /**
     * @dev Allow us to update a masternode's round to keep progress
     * @param _candidate ID of masternode
     */
    function updateMasternode(uint _candidate) internal returns(bool) {
        userByIndex[_candidate].startingRound++;
        return true;
    }

    /**
     * @dev Allow us to update a masternode to team member status
     * @param _member address
     */
    function updateMasternodeAsTeamMember(address _member) internal returns (bool) {
        userByAddress[_member].isTeamMember = true;
        return (true);
    }

    /**
     * @dev Let us know if an address is part of the team.
     * @param _member address
     */
    function isTeamMember (address _member) public view returns (bool) {
        if (userByAddress[_member].isTeamMember)
        return true;
    }

    /**
     * @dev Remove a specific masternode
     * @param _masternodeID ID of the masternode to remove
     */
    function deleteMasternode(uint _masternodeID) internal returns(bool success) {

        uint rowToDelete = userByIndex[_masternodeID].storedIndex;
        uint keyToMove = userArray[userArray.length - 1];

        userByIndex[_masternodeID].isActive = userByIndex[_masternodeID].isActive = (false);
        userArray[rowToDelete] = keyToMove;
        userByIndex[keyToMove].storedIndex = rowToDelete;
        userArray.length = userArray.length - 1;

        removeFromUserCounter(_masternodeID);

        emit RemovedMasternode(userByIndex[_masternodeID].accountOwner, now);

        return true;
    }

    /**
     * @dev returns what account belongs to a masternode
     */
    function isPartOf(uint mnid) public view returns (address) {
        return userByIndex[mnid].accountOwner;
    }

    /**
     * @dev Internal function to remove a masternode from a user address if this address holds multpile masternodes
     * @param index MasternodeID
     */
    function removeFromUserCounter(uint index)  internal returns(uint[]) {
        address belong = isPartOf(index);

        if (index >= userByAddress[belong].indexcounter.length) return;

        for (uint i = index; i<userByAddress[belong].indexcounter.length-1; i++){
            userByAddress[belong].indexcounter[i] = userByAddress[belong].indexcounter[i+1];
        }

        delete userByAddress[belong].indexcounter[userByAddress[belong].indexcounter.length-1];
        userByAddress[belong].indexcounter.length--;
        return userByAddress[belong].indexcounter;
    }

    /**
     * @dev Primary contract function to update the current user and prepare the next one.
     * A number of steps have been token to ensure the contract can never run out of gas when looping over our masternodes.
     */
    function setMasternodeCandidate() internal returns(address) {

        uint hardlimitCounter = 0;

        while (getFollowingCandidate() == 0x0) {
            // We must return a value not to break the contract. Require is a secondary killswitch now.
            require(hardlimitCounter < 6, "Failsafe switched on");
            // Choose if loop over revert/require to terminate the loop and return a 0 address.
            if (hardlimitCounter == 5) return (0);
            masternodeRound = masternodeRound + 1;
            masternodeCandidate = 0;
            hardlimitCounter++;
        }

        if (masternodeCandidate == masternodeCounter - 1) {
            masternodeRound = masternodeRound + 1;
            masternodeCandidate = 0;
        }

        for (uint i = masternodeCandidate; i < masternodeCounter; i++) {
            if (userByIndex[i].isActive) {
                if (userByIndex[i].startingRound == masternodeRound) {
                    updateMasternode(i);
                    masternodeCandidate = i;
                    return (userByIndex[i].accountOwner);
                }
            }
        }

        masternodeRound = masternodeRound + 1;
        return (0);

    }

    /**
     * @dev Helper function to loop through our masternodes at start and return the correct round
     */
    function getFollowingCandidate() internal view returns(address _address) {
        uint tmpRound = masternodeRound;
        uint tmpCandidate = masternodeCandidate;

        if (tmpCandidate == masternodeCounter - 1) {
            tmpRound = tmpRound + 1;
            tmpCandidate = 0;
        }

        for (uint i = masternodeCandidate; i < masternodeCounter; i++) {
            if (userByIndex[i].isActive) {
                if (userByIndex[i].startingRound == tmpRound) {
                    tmpCandidate = i;
                    return (userByIndex[i].accountOwner);
                }
            }
        }

        tmpRound = tmpRound + 1;
        return (0);
    }

    /**
     * @dev Displays all masternodes belonging to a user address.
     */
    function belongsToUser(address userAddress) public view returns(uint[]) {
        return (userByAddress[userAddress].indexcounter);
    }

    /**
     * @dev Helper function to know if an address owns masternodes
     */
    function isMasternodeOwner(address _candidate) public view returns(bool) {
        if(userByAddress[_candidate].indexcounter.length <= 0) return false;
        if (userByAddress[_candidate].accountOwner == _candidate)
        return true;
    }

    /**
     * @dev Helper function to get the last masternode belonging to a user
     */
    function getLastPerUser(address _candidate) public view returns (uint) {
        return userByAddress[_candidate].indexcounter[userByAddress[_candidate].indexcounter.length - 1];
    }

    /**
     * @dev Return the base rewards. This should be overrided by the miner contract.
     * Return a base value for standalone usage ONLY.
     */
    function getMiningReward() public view returns(uint) {
        return 50 * 1e8;
    }

    /**
     * @dev Calculate and set the reward schema for Caelum.
     * Each mining phase is decided by multiplying the MINING_PHASE_DURATION_BLOCKS with factor 10.
     * Depending on the outcome (solidity always rounds), we can detect the current stage of mining.
     * First stage we cut the rewards to 5% to prevent instamining.
     * Last stage we leave 2% for miners to incentivize keeping miners running.
     */
    function calculateRewardStructures() internal {
        //ToDo: Set
        uint _global_reward_amount = getMiningReward();
        uint getStageOfMining = miningEpoch / MINING_PHASE_DURATION_BLOCKS * 10;

        if (getStageOfMining < 10) {
            rewardsProofOfWork = _global_reward_amount / 100 * 5;
            rewardsMasternode = 0;
            return;
        }

        if (getStageOfMining > 90) {
            rewardsProofOfWork = _global_reward_amount / 100 * 2;
            rewardsMasternode = _global_reward_amount / 100 * 98;
            return;
        }

        uint _mnreward = (_global_reward_amount / 100) * getStageOfMining;
        uint _powreward = (_global_reward_amount - _mnreward);

        setBaseRewards(_powreward, _mnreward);
    }

    function setBaseRewards(uint _pow, uint _mn) internal {
        rewardsMasternode = _mn;
        rewardsProofOfWork = _pow;
    }

    /**
     * @dev Executes the masternode flow. Should be called after mining a block.
     */
    function _arrangeMasternodeFlow() internal {
        calculateRewardStructures();
        setMasternodeCandidate();
        miningEpoch++;
    }

    /**
     * @dev Executes the masternode flow. Should be called after mining a block.
     * This is an emergency manual loop method.
     */
    function _emergencyLoop() onlyOwner public {
        calculateRewardStructures();
        setMasternodeCandidate();
        miningEpoch++;
    }

    function masternodeInfo(uint index) public view returns
    (
        address,
        bool,
        uint,
        uint
    )
    {
        return (
            userByIndex[index].accountOwner,
            userByIndex[index].isActive,
            userByIndex[index].storedIndex,
            userByIndex[index].startingRound
        );
    }

    function contractProgress() public view returns
    (
        uint epoch,
        uint candidate,
        uint round,
        uint miningepoch,
        uint globalreward,
        uint powreward,
        uint masternodereward,
        uint usercounter
    )
    {
        return (
            masternodeEpoch,
            masternodeCandidate,
            masternodeRound,
            miningEpoch,
            getMiningReward(),
            rewardsProofOfWork,
            rewardsMasternode,
            masternodeCounter
        );
    }

}

contract CaelumMasternode is CaelumVotings, CaelumAbstractMasternode {

    /**
     * @dev Hardcoded token mining address. For trust and safety we do not allow changing this.
     * Should anything change, a new instance needs to be redeployed.
     */
    address public miningContract;
    address public tokenContract;
    
    bool minerSet = false;
    bool tokenSet = false;

    function setMiningContract(address _t) onlyOwner public {
        require(!minerSet);
        miningContract = _t;
        minerSet = true;
    }

    function setTokenContract(address _t) onlyOwner public {
        require(!tokenSet);
        tokenContract = _t;
        tokenSet = true;
    }

    function setMasternodeContractFromVote(address _t) internal {
    }

    function setTokenContractFromVote(address _t) internal{
        tokenContract = _t;
    }

    function setMiningContractFromVote (address _t) internal {
        miningContract = _t;
    }

    /**
     * @dev Only allow the token mining contract to call this function when used remotely.
     * Use the internal function when working within the same contract.
     */
    modifier onlyMiningContract() {
        require(msg.sender == miningContract);
        _;
    }

    /**
     * @dev Only allow the token contract to call this function when used remotely.
     * Use the internal function when working within the same contract.
     */
    modifier onlyTokenContract() {
        require(msg.sender == tokenContract);
        _;
    }

    /**
     * @dev Only allow the token contract to call this function when used remotely.
     * Use the internal function when working within the same contract.
     */
    modifier bothRemoteContracts() {
        require(msg.sender == tokenContract || msg.sender == miningContract);
        _;
    }

    /**
     * @dev Use this to externaly call the _arrangeMasternodeFlow function. ALWAYS set a modifier !
     */
    function _externalArrangeFlow() onlyMiningContract external {
        _arrangeMasternodeFlow();
    }

    /**
     * @dev Use this to externaly call the addMasternode function. ALWAYS set a modifier !
     */
    function _externalAddMasternode(address _received) onlyMiningContract external {
        addMasternode(_received);
    }

    /**
     * @dev Use this to externaly call the deleteMasternode function. ALWAYS set a modifier !
     */
    function _externalStopMasternode(address _received) onlyMiningContract external {
        deleteMasternode(getLastPerUser(_received));
    }

    function getMiningReward() public view returns(uint) {
        return CaelumMiner(miningContract).getMiningReward();
    }
    
    address cloneDataFrom = 0x7600bF5112945F9F006c216d5d6db0df2806eDc6;
    
    function getDataFromContract () onlyOwner public returns(uint) {
        
        CaelumMasternode prev = CaelumMasternode(cloneDataFrom);
        (uint epoch,
        uint candidate,
        uint round,
        uint miningepoch,
        uint globalreward,
        uint powreward,
        uint masternodereward,
        uint usercounter) = prev.contractProgress();
        
        masternodeEpoch = epoch;
        masternodeRound = round;
        miningEpoch = miningepoch;
        rewardsProofOfWork = powreward;
        rewardsMasternode = masternodereward;

    }

}

contract CaelumToken is Ownable, StandardToken, CaelumVotings, CaelumAcceptERC20 {
    using SafeMath for uint;

    ERC20 previousContract;
    
    bool contractSet = false;
    bool public swapClosed = false;
    uint public swapCounter;

    string public symbol = "CLM";
    string public name = "Caelum Token";
    uint8 public decimals = 8;
    uint256 public totalSupply = 2100000000000000;
    
    address public miningContract = 0x0;

    /**
     * @dev Only allow the token mining contract to call this function when used remotely.
     * Use the internal function when working within the same contract.
     */
    modifier onlyMiningContract() {
        require(msg.sender == miningContract);
        _;
    }

    constructor(address _previousContract) public {
        previousContract = ERC20(_previousContract);
        swapClosed = false;
        swapCounter = 0;
    }

    function setMiningContract (address _t) onlyOwner public {
        require(!contractSet);
        miningContract = _t;
        contractSet = true;
    }

    function setMasternodeContractFromVote(address _t) internal {
        return;
    }

    function setTokenContractFromVote(address _t) internal{
        return;
    }

    function setMiningContractFromVote (address _t) internal {
        miningContract = _t;
    }
    
    function changeSwapState (bool _state) onlyOwner public {
        require(swapCounter <= 9);
        swapClosed = _state;
        swapCounter++;
    }

    function rewardExternal(address _receiver, uint _amount) onlyMiningContract external {
        balances[_receiver] = balances[_receiver].add(_amount);
        emit Transfer(this, _receiver, _amount);
    }


    function upgradeTokens() public{
        require(!swapClosed);
        uint amountToUpgrade = previousContract.balanceOf(msg.sender);
        require(amountToUpgrade <= previousContract.allowance(msg.sender, this));
        
        if(previousContract.transferFrom(msg.sender, this, amountToUpgrade)){
            balances[msg.sender] = balances[msg.sender].add(amountToUpgrade); // 2% Premine as determined by the community meeting.
            emit Transfer(this, msg.sender, amountToUpgrade);
        }
        
        require(previousContract.balanceOf(msg.sender) == 0);
    }
}



contract AbstractERC918 is EIP918Interface {

    // generate a new challenge number after a new reward is minted
    bytes32 public challengeNumber;

    // the current mining difficulty
    uint public difficulty;

    // cumulative counter of the total minted tokens
    uint public tokensMinted;

    // track read only minting statistics
    struct Statistics {
        address lastRewardTo;
        uint lastRewardAmount;
        uint lastRewardEthBlockNumber;
        uint lastRewardTimestamp;
    }

    Statistics public statistics;

    /*
     * Externally facing mint function that is called by miners to validate challenge digests, calculate reward,
     * populate statistics, mutate epoch variables and adjust the solution difficulty as required. Once complete,
     * a Mint event is emitted before returning a success indicator.
     **/
    function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success);


    /*
     * Internal interface function _hash. Overide in implementation to define hashing algorithm and
     * validation
     **/
    function _hash(uint256 nonce, bytes32 challenge_digest) internal returns (bytes32 digest);

    /*
     * Internal interface function _reward. Overide in implementation to calculate and return reward
     * amount
     **/
    function _reward() internal returns (uint);

    /*
     * Internal interface function _newEpoch. Overide in implementation to define a cutpoint for mutating
     * mining variables in preparation for the next epoch
     **/
    function _newEpoch(uint256 nonce) internal returns (uint);

    /*
     * Internal interface function _adjustDifficulty. Overide in implementation to adjust the difficulty
     * of the mining as required
     **/
    function _adjustDifficulty() internal returns (uint);

}

contract CaelumAbstractMiner is AbstractERC918 {
    /**
     * CaelumMiner contract.
     *
     * We need to make sure the contract is 100% compatible when using the EIP918Interface.
     * This contract is an abstract Caelum miner contract.
     *
     * Function 'mint', and '_reward' are overriden in the CaelumMiner contract.
     * Function '_reward_masternode' is added and needs to be overriden in the CaelumMiner contract.
     */

    using SafeMath for uint;
    using ExtendedMath for uint;

    uint256 public totalSupply = 2100000000000000;

    uint public latestDifficultyPeriodStarted;
    uint public epochCount;
    uint public baseMiningReward = 50;
    uint public blocksPerReadjustment = 512;
    uint public _MINIMUM_TARGET = 2 ** 16;
    uint public _MAXIMUM_TARGET = 2 ** 234;
    uint public rewardEra = 0;

    uint public maxSupplyForEra;
    uint public MAX_REWARD_ERA = 39;
    uint public MINING_RATE_FACTOR = 60; //mint the token 60 times less often than ether

    uint public MAX_ADJUSTMENT_PERCENT = 100;
    uint public TARGET_DIVISOR = 2000;
    uint public QUOTIENT_LIMIT = TARGET_DIVISOR.div(2);
    mapping(bytes32 => bytes32) solutionForChallenge;
    mapping(address => mapping(address => uint)) allowed;

    bytes32 public challengeNumber;
    uint public difficulty;
    uint public tokensMinted;


    Statistics public statistics;

    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);
    event RewardMasternode(address candidate, uint amount);

    constructor() public {
        tokensMinted = 0;
        maxSupplyForEra = totalSupply.div(2);
        difficulty = _MAXIMUM_TARGET;
        latestDifficultyPeriodStarted = block.number;
        _newEpoch(0);
    }



    function _newEpoch(uint256 nonce) internal returns(uint) {

        if (tokensMinted.add(getMiningReward()) > maxSupplyForEra && rewardEra < MAX_REWARD_ERA) {
            rewardEra = rewardEra + 1;
        }
        maxSupplyForEra = totalSupply - totalSupply.div(2 ** (rewardEra + 1));
        epochCount = epochCount.add(1);
        challengeNumber = blockhash(block.number - 1);
        return (epochCount);
    }

    function mint(uint256 nonce, bytes32 challenge_digest) public returns(bool success);

    function _hash(uint256 nonce, bytes32 challenge_digest) internal returns(bytes32 digest) {
        digest = keccak256(challengeNumber, msg.sender, nonce);
        if (digest != challenge_digest) revert();
        if (uint256(digest) > difficulty) revert();
        bytes32 solution = solutionForChallenge[challengeNumber];
        solutionForChallenge[challengeNumber] = digest;
        if (solution != 0x0) revert(); //prevent the same answer from awarding twice
    }

    function _reward() internal returns(uint);

    function _reward_masternode() internal returns(uint);

    function _adjustDifficulty() internal returns(uint) {
        //every so often, readjust difficulty. Dont readjust when deploying
        if (epochCount % blocksPerReadjustment != 0) {
            return difficulty;
        }

        uint ethBlocksSinceLastDifficultyPeriod = block.number - latestDifficultyPeriodStarted;
        //assume 360 ethereum blocks per hour
        //we want miners to spend 10 minutes to mine each 'block', about 60 ethereum blocks = one 0xbitcoin epoch
        uint epochsMined = blocksPerReadjustment;
        uint targetEthBlocksPerDiffPeriod = epochsMined * MINING_RATE_FACTOR;
        //if there were less eth blocks passed in time than expected
        if (ethBlocksSinceLastDifficultyPeriod < targetEthBlocksPerDiffPeriod) {
            uint excess_block_pct = (targetEthBlocksPerDiffPeriod.mul(MAX_ADJUSTMENT_PERCENT)).div(ethBlocksSinceLastDifficultyPeriod);
            uint excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(QUOTIENT_LIMIT);
            // If there were 5% more blocks mined than expected then this is 5.  If there were 100% more blocks mined than expected then this is 100.
            //make it harder
            difficulty = difficulty.sub(difficulty.div(TARGET_DIVISOR).mul(excess_block_pct_extra)); //by up to 50 %
        } else {
            uint shortage_block_pct = (ethBlocksSinceLastDifficultyPeriod.mul(MAX_ADJUSTMENT_PERCENT)).div(targetEthBlocksPerDiffPeriod);
            uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(QUOTIENT_LIMIT); //always between 0 and 1000
            //make it easier
            difficulty = difficulty.add(difficulty.div(TARGET_DIVISOR).mul(shortage_block_pct_extra)); //by up to 50 %
        }
        latestDifficultyPeriodStarted = block.number;
        if (difficulty < _MINIMUM_TARGET) //very difficult
        {
            difficulty = _MINIMUM_TARGET;
        }
        if (difficulty > _MAXIMUM_TARGET) //very easy
        {
            difficulty = _MAXIMUM_TARGET;
        }
    }

    function getChallengeNumber() public view returns(bytes32) {
        return challengeNumber;
    }

    function getMiningDifficulty() public view returns(uint) {
        return _MAXIMUM_TARGET.div(difficulty);
    }

    function getMiningTarget() public view returns(uint) {
        return difficulty;
    }

    function getMiningReward() public view returns(uint) {
        return (baseMiningReward * 1e8).div(2 ** rewardEra);
    }

    function getMintDigest(
        uint256 nonce,
        bytes32 challenge_digest,
        bytes32 challenge_number
    )
    public view returns(bytes32 digesttest) {
        bytes32 digest = keccak256(challenge_number, msg.sender, nonce);
        return digest;
    }

    function checkMintSolution(
        uint256 nonce,
        bytes32 challenge_digest,
        bytes32 challenge_number,
        uint testTarget
    )
    public view returns(bool success) {
        bytes32 digest = keccak256(challenge_number, msg.sender, nonce);
        if (uint256(digest) > testTarget) revert();
        return (digest == challenge_digest);
    }
}

contract CaelumMiner is CaelumVotings, CaelumAbstractMiner {

    /**
     * CaelumMiner main contract
     *
     * Inherit from our abstract CaelumMiner contract and override some functions
     * of the AbstractERC918 contract to allow masternode rewardings.
     *
     * @dev use this contract to make all changes needed for your project.
     */

    address cloneDataFrom = 0x7600bF5112945F9F006c216d5d6db0df2806eDc6;

    bool ACTIVE_CONTRACT_STATE = true;
    bool MasternodeSet = false;
    bool TokenSet = false;

    address _CaelumMasternodeContract;
    address _CaelumTokenContract;

    CaelumMasternode public MasternodeContract;
    CaelumToken public tokenContract;

    function setMasternodeContract(address _t) onlyOwner public {
        require(!MasternodeSet);
        MasternodeContract = CaelumMasternode(_t);
        _CaelumMasternodeContract = (_t);
        MasternodeSet = true;
    }

    function setTokenContract(address _t) onlyOwner public {
        require(!TokenSet);
        tokenContract = CaelumToken(_t);
        _CaelumTokenContract = (_t);
        TokenSet = true;
    }

    function setMiningContract (address _t) onlyOwner public {
        return; 
    }

    function setMasternodeContractFromVote(address _t) internal {
        MasternodeContract = CaelumMasternode(_t);
        _CaelumMasternodeContract = (_t);
    }

    function setTokenContractFromVote(address _t) internal{
        tokenContract = CaelumToken(_t);
        _CaelumTokenContract = (_t);
    }

    function setMiningContractFromVote (address _t) internal {
        return;
    }
    
    function lockMiningContract () onlyOwner public {
        ACTIVE_CONTRACT_STATE = false;
    }

    function getDataFromContract () onlyOwner public {

        require(_CaelumTokenContract != 0);
        require(_CaelumMasternodeContract != 0);

        CaelumMiner prev = CaelumMiner(cloneDataFrom);
        difficulty = prev.difficulty();
        rewardEra = prev.rewardEra();
        MINING_RATE_FACTOR = prev.MINING_RATE_FACTOR();
        maxSupplyForEra = prev.maxSupplyForEra();
        tokensMinted = prev.tokensMinted();
        epochCount = prev.epochCount();
        latestDifficultyPeriodStarted = prev.latestDifficultyPeriodStarted();

        ACTIVE_CONTRACT_STATE = true;
    }
    

    /**
     * @dev override of the original function since we want to call the masternode contract remotely.
     */
    function mint(uint256 nonce, bytes32 challenge_digest) public returns(bool success) {
        // If contract is no longer active, stop accepting solutions.
        require(ACTIVE_CONTRACT_STATE);

        _hash(nonce, challenge_digest);

        MasternodeContract._externalArrangeFlow();

        uint rewardAmount =_reward();
        uint rewardMasternode = _reward_masternode();

        tokensMinted += rewardAmount.add(rewardMasternode);

        uint epochCounter = _newEpoch(nonce);

        _adjustDifficulty();

        statistics = Statistics(msg.sender, rewardAmount, block.number, now);

        emit Mint(msg.sender, rewardAmount, epochCounter, challengeNumber);

        return true;
    }

    /**
     * @dev override of the original function since we want to call the masternode contract remotely.
     */
    function _reward() internal returns(uint) {

        uint _pow = MasternodeContract.rewardsProofOfWork();

        tokenContract.rewardExternal(msg.sender, _pow);

        return _pow;
    }

    /**
     * @dev override of the original function since we want to call the masternode contract remotely.
     */
    function _reward_masternode() internal returns(uint) {

        uint _mnReward = MasternodeContract.rewardsMasternode();
        if (MasternodeContract.masternodeCounter() == 0) return 0;

        uint getCandidate = MasternodeContract.masternodeCandidate();
        address _mnCandidate = MasternodeContract.isPartOf(getCandidate);
        if (_mnCandidate == 0x0) return 0;

        tokenContract.rewardExternal(_mnCandidate, _mnReward);

        emit RewardMasternode(_mnCandidate, _mnReward);

        return _mnReward;
    }
    
    function getMiningReward() public view returns(uint) {
        return MasternodeContract.rewardsProofOfWork();
    }
}


/**
 * Burn some gas and create all contracts in a single call :-)
 */

contract caelumFactory { 

    CaelumMiner public MINER;
    CaelumMasternode public MASTER;
    CaelumToken public TOKEN;

    function newCookie() public {
        MINER = new CaelumMiner();
        MASTER = new CaelumMasternode();
        TOKEN = new CaelumToken(0x0);

        MASTER.setMiningContract(MINER);
        MASTER.setTokenContract(TOKEN);

        MINER.setMasternodeContract(MASTER);
        MINER.setTokenContract(TOKEN);

        TOKEN.setMiningContract(MINER);
        TOKEN.setDataStorage(MASTER);

        MASTER.transferOwnership(msg.sender);
        TOKEN.transferOwnership(msg.sender);
        MINER.transferOwnership(msg.sender);
    }

}