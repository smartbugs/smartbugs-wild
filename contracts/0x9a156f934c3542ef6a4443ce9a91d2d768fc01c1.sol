pragma solidity ^0.4.25;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {

    /**
    * @dev Subtracts two numbers, reverts on overflow.
    */
    function safeSub(uint256 x, uint256 y) internal pure returns (uint256) {
        assert(y <= x);
        uint256 z = x - y;
        return z;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function safeAdd(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x + y;
        assert(z >= x);
        return z;
    }
	
	/**
    * @dev Integer division of two numbers, reverts on division by zero.
    */
    function safeDiv(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x / y;
        return z;
    }
    
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */	
    function safeMul(uint256 x, uint256 y) internal pure returns (uint256) {    
        if (x == 0) {
            return 0;
        }
    
        uint256 z = x * y;
        assert(z / x == y);
        return z;
    }

    /**
    * @dev Returns the integer percentage of the number.
    */
    function safePerc(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x == 0) {
            return 0;
        }
        
        uint256 z = x * y;
        assert(z / x == y);    
        z = z / 10000; // percent to hundredths
        return z;
    }

    /**
    * @dev Returns the minimum value of two numbers.
    */	
    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x <= y ? x : y;
        return z;
    }

    /**
    * @dev Returns the maximum value of two numbers.
    */
    function max(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x >= y ? x : y;
        return z;
    }
}


/**
 * @title DAppDEXI - Interface 
 */
interface DAppDEXI {

    function updateAgent(address _agent, bool _status) external;

    function setAccountType(address user_, uint256 type_) external;
    function getAccountType(address user_) external view returns(uint256);
    function setFeeType(uint256 type_ , uint256 feeMake_, uint256 feeTake_) external;
    function getFeeMake(uint256 type_ ) external view returns(uint256);
    function getFeeTake(uint256 type_ ) external view returns(uint256);
    function changeFeeAccount(address feeAccount_) external;
    
    function setWhitelistTokens(address token) external;
    function setWhitelistTokens(address token, bool active, uint256 timestamp, bytes32 typeERC) external;
    function depositToken(address token, uint amount) external;
    function tokenFallback(address owner, uint256 amount, bytes data) external returns (bool success);

    function withdraw(uint amount) external;
    function withdrawToken(address token, uint amount) external;

    function balanceOf(address token, address user) external view returns (uint);

    function order(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce) external;
    function trade(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) external;    
    function cancelOrder(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) external;
    function testTrade(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount, address sender) external view returns(bool);
    function availableVolume(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) external view returns(uint);
    function amountFilled(address tokenBuy, uint amountBuy, address tokenSell, uint amountSell, uint expires, uint nonce, address user) external view returns(uint);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface ERC20I {

  function balanceOf(address _owner) external view returns (uint256);

  function totalSupply() external view returns (uint256);
  function transfer(address _to, uint256 _value) external returns (bool success);
  
  function allowance(address _owner, address _spender) external view returns (uint256);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
  function approve(address _spender, uint256 _value) external returns (bool success);
  
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Ownable contract - base contract with an owner
 */
contract Ownable {
  
  address public owner;
  address public newOwner;

  event OwnershipTransferred(address indexed _from, address indexed _to);
  
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
    assert(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    assert(_newOwner != address(0));      
    newOwner = _newOwner;
  }

  /**
   * @dev Accept transferOwnership.
   */
  function acceptOwnership() public {
    if (msg.sender == newOwner) {
      emit OwnershipTransferred(owner, newOwner);
      owner = newOwner;
    }
  }
}


/**
 * @title SDADI - Interface
 */
interface SDADI  {	
  function AddToken(address token) external;
  function DelToken(address token) external;
}


/**
 * @title Standard ERC20 token + balance on date
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20 
 */
contract ERC20Base is ERC20I, SafeMath {
	
  uint256 totalSupply_;
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;

  uint256 public start = 0;               // Must be equal to the date of issue tokens
  uint256 public period = 30 days;        // By default, the dividend accrual period is 30 days
  mapping (address => mapping (uint256 => int256)) public ChangeOverPeriod;

  address[] public owners;
  mapping (address => bool) public ownersIndex;

  struct _Prop {
    uint propID;          // proposal ID in DAO    
    uint endTime;         // end time of voting
  }
  
  _Prop[] public ActiveProposals;  // contains active proposals

  // contains voted Tokens on proposals
  mapping (uint => mapping (address => uint)) public voted;

  /** 
   * @dev Total Supply
   * @return totalSupply_ 
   */  
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
  
  /** 
   * @dev Tokens balance
   * @param _owner holder address
   * @return balance amount 
   */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  /** 
   * @dev Balance of tokens on date
   * @param _owner holder address
   * @return balance amount 
   */
  function balanceOf(address _owner, uint _date) public view returns (uint256) {
    require(_date >= start);
    uint256 N1 = (_date - start) / period + 1;    

    uint256 N2 = 1;
    if (block.timestamp > start) {
      N2 = (block.timestamp - start) / period + 1;
    }

    require(N2 >= N1);

    int256 B = int256(balances[_owner]);

    while (N2 > N1) {
      B = B - ChangeOverPeriod[_owner][N2];
      N2--;
    }

    require(B >= 0);
    return uint256(B);
  }

  /** 
   * @dev Tranfer tokens to address
   * @param _to dest address
   * @param _value tokens amount
   * @return transfer result
   */
  function transfer(address _to, uint256 _value) public returns (bool success) {
    require(_to != address(0));

    uint lock = 0;
    for (uint k = 0; k < ActiveProposals.length; k++) {
      if (ActiveProposals[k].endTime > now) {
        if (lock < voted[ActiveProposals[k].propID][msg.sender]) {
          lock = voted[ActiveProposals[k].propID][msg.sender];
        }
      }
    }

    require(safeSub(balances[msg.sender], lock) >= _value);

    if (ownersIndex[_to] == false && _value > 0) {
      ownersIndex[_to] = true;
      owners.push(_to);
    }
    
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);

    uint256 N = 1;
    if (block.timestamp > start) {
      N = (block.timestamp - start) / period + 1;
    }

    ChangeOverPeriod[msg.sender][N] = ChangeOverPeriod[msg.sender][N] - int256(_value);
    ChangeOverPeriod[_to][N] = ChangeOverPeriod[_to][N] + int256(_value);
   
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /** 
   * @dev Token allowance
   * @param _owner holder address
   * @param _spender spender address
   * @return remain amount
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**    
   * @dev Transfer tokens from one address to another
   * @param _from source address
   * @param _to dest address
   * @param _value tokens amount
   * @return transfer result
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(_to != address(0));

    uint lock = 0;
    for (uint k = 0; k < ActiveProposals.length; k++) {
      if (ActiveProposals[k].endTime > now) {
        if (lock < voted[ActiveProposals[k].propID][_from]) {
          lock = voted[ActiveProposals[k].propID][_from];
        }
      }
    }
    
    require(safeSub(balances[_from], lock) >= _value);
    
    require(allowed[_from][msg.sender] >= _value);

    if (ownersIndex[_to] == false && _value > 0) {
      ownersIndex[_to] = true;
      owners.push(_to);
    }
    
    balances[_from] = safeSub(balances[_from], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
    
    uint256 N = 1;
    if (block.timestamp > start) {
      N = (block.timestamp - start) / period + 1;
    }

    ChangeOverPeriod[_from][N] = ChangeOverPeriod[_from][N] - int256(_value);
    ChangeOverPeriod[_to][N] = ChangeOverPeriod[_to][N] + int256(_value);

    emit Transfer(_from, _to, _value);
    return true;
  }
  
  /** 
   * @dev Approve transfer
   * @param _spender holder address
   * @param _value tokens amount
   * @return result  
   */
  function approve(address _spender, uint256 _value) public returns (bool success) {
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    allowed[msg.sender][_spender] = _value;
    
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /** 
   * @dev Trim owners with zero balance
   */
  function trim(uint offset, uint limit) external returns (bool) { 
    uint k = offset;
    uint ln = limit;
    while (k < ln) {
      if (balances[owners[k]] == 0) {
        ownersIndex[owners[k]] =  false;
        owners[k] = owners[owners.length-1];
        owners.length = owners.length-1;
        ln--;
      } else {
        k++;
      }
    }
    return true;
  }

  // current number of shareholders (owners)
  function getOwnersCount() external view returns (uint256 count) {
    return owners.length;
  }

  // current period
  function getCurrentPeriod() external view returns (uint256 N) {
    if (block.timestamp > start) {
      return (block.timestamp - start) / period;
    } else {
      return 0;
    }
  }

  function addProposal(uint _propID, uint _endTime) internal {
    ActiveProposals.push(_Prop({
      propID: _propID,
      endTime: _endTime
    }));
  }

  function delProposal(uint _propID) internal {
    uint k = 0;
    while (k < ActiveProposals.length){
      if (ActiveProposals[k].propID == _propID) {
        require(ActiveProposals[k].endTime < now);
        ActiveProposals[k] = ActiveProposals[ActiveProposals.length-1];
        ActiveProposals.length = ActiveProposals.length-1;   
      } else {
        k++;
      }
    }    
  }

  function getVoted(uint _propID, address _voter) external view returns (uint) {
    return voted[_propID][_voter];
  }
}


/**
 * @title Dividend Distribution Contract for DAO
 */
contract Dividends is ERC20Base, Ownable {

  DAppDEXI public DEX;

  address[] public tokens;
  mapping (address => uint) public tokensIndex;
  
  mapping (uint => mapping (address => uint)) public dividends;
  mapping (address => mapping (address => uint)) public ownersbal;  
  mapping (uint => mapping (address => mapping (address => bool))) public AlreadyReceived;

  uint public multiplier = 100000; // precision to ten thousandth percent (0.001%)

  event Payment(address indexed sender, uint amount);
  event setDEXContractEvent(address dex);
   
  function AddToken(address token) public {
    require(msg.sender == address(DEX));
    tokens.push(token);
    tokensIndex[token] = tokens.length-1;
  }

  function DelToken(address token) public {
    require(msg.sender == address(DEX));
    require(tokens[tokensIndex[token]] != 0);    
    tokens[tokensIndex[token]] = tokens[tokens.length-1];
    tokens.length = tokens.length-1;
  }

  // Take profit for dividends from DEX contract
  function TakeProfit(uint offset, uint limit) external {
    require (limit <= tokens.length);
    require (offset < limit);

    uint N = (block.timestamp - start) / period;
    
    require (N > 0);
    
    for (uint k = offset; k < limit; k++) {
      if(dividends[N][tokens[k]] == 0 ) {
          uint amount = DEX.balanceOf(tokens[k], address(this));
          if (k == 0) {
            DEX.withdraw(amount);
            dividends[N][tokens[k]] = amount;
          } else {
            DEX.withdrawToken(tokens[k], amount);
            dividends[N][tokens[k]] = amount;
          }
      }
    }
  }

  function () public payable {
      emit Payment(msg.sender, msg.value);
  }
  
  // PayDividends to owners
  function PayDividends(address token, uint offset, uint limit) external {
    //require (address(this).balance > 0);
    require (limit <= owners.length);
    require (offset < limit);

    uint N = (block.timestamp - start) / period; // current - 1
    uint date = start + N * period - 1;
    
    require(dividends[N][token] > 0);

    uint share = 0;
    uint k = 0;
    for (k = offset; k < limit; k++) {
      if (!AlreadyReceived[N][token][owners[k]]) {
        share = safeMul(balanceOf(owners[k], date), multiplier);
        share = safeDiv(safeMul(share, 100), totalSupply_); // calc the percentage of the totalSupply_ (from 100%)

        share = safePerc(dividends[N][token], share);
        share = safeDiv(share, safeDiv(multiplier, 100));  // safeDiv(multiplier, 100) - convert to hundredths
        
        ownersbal[owners[k]][token] = safeAdd(ownersbal[owners[k]][token], share);
        AlreadyReceived[N][token][owners[k]] = true;
      }
    }
  }

  // PayDividends individuals to msg.sender
  function PayDividends(address token) external {
    //require (address(this).balance > 0);

    uint N = (block.timestamp - start) / period; // current - 1
    uint date = start + N * period - 1;

    require(dividends[N][token] > 0);
    
    if (!AlreadyReceived[N][token][msg.sender]) {      
      uint share = safeMul(balanceOf(msg.sender, date), multiplier);
      share = safeDiv(safeMul(share, 100), totalSupply_); // calc the percentage of the totalSupply_ (from 100%)

      share = safePerc(dividends[N][token], share);
      share = safeDiv(share, safeDiv(multiplier, 100));  // safeDiv(multiplier, 100) - convert to hundredths
        
      ownersbal[msg.sender][token] = safeAdd(ownersbal[msg.sender][token], share);
      AlreadyReceived[N][token][msg.sender] = true;
    }
  }

  // withdraw dividends
  function withdraw(address token, uint _value) external {    
    require(ownersbal[msg.sender][token] >= _value);
    ownersbal[msg.sender][token] = safeSub(ownersbal[msg.sender][token], _value);
    if (token == address(0)) {
      msg.sender.transfer(_value);
    } else {
      ERC20I(token).transfer(msg.sender, _value);
    }
  }
  
  // withdraw dividends to address
  function withdraw(address token, uint _value, address _receiver) external {    
    require(ownersbal[msg.sender][token] >= _value);
    ownersbal[msg.sender][token] = safeSub(ownersbal[msg.sender][token], _value);
    if (token == address(0)) {
      _receiver.transfer(_value);
    } else {
      ERC20I(token).transfer(_receiver, _value);
    }    
  }

  function setMultiplier(uint _value) external onlyOwner {
    require(_value > 0);
    multiplier = _value;
  }
  
  function getMultiplier() external view returns (uint ) {
    return multiplier;
  }  

  // link to DEX contract
  function setDEXContract(address _contract) external onlyOwner {
    DEX = DAppDEXI(_contract);
    emit setDEXContractEvent(_contract);
  }
}


/**
 * @title External interface for DAO
 */
interface CommonI {
    function transferOwnership(address _newOwner) external;
    function acceptOwnership() external;
    function updateAgent(address _agent, bool _state) external;    
}


/**
 * @title Decentralized Autonomous Organization
 */
contract DAO is Dividends {

    //minimum balance for adding proposal - default 10000 tokens
    uint minBalance = 1000000000000; 
    // minimum quorum - number of votes must be more than minimum quorum
    uint public minimumQuorum;
    // debating period duration
    uint public debatingPeriodDuration;
    // requisite majority of votes (by the system a simple majority)
    uint public requisiteMajority;

    struct _Proposal {
        // proposal may execute only after voting ended
        uint endTimeOfVoting;
        // if executed = true
        bool executed;
        // if passed = true
        bool proposalPassed;
        // number of votes already voted
        uint numberOfVotes;
        // in support of votes
        uint votesSupport;
        // against votes
        uint votesAgainst;
        
        // the address where the `amount` will go to if the proposal is accepted
        address recipient;
        // the amount to transfer to `recipient` if the proposal is accepted.
        uint amount;
        // keccak256(abi.encodePacked(recipient, amount, transactionByteCode));
        bytes32 transactionHash;

        // a plain text description of the proposal
        string desc;
        // a hash of full description data of the proposal (optional)
        string fullDescHash;
    }

    _Proposal[] public Proposals;

    event ProposalAdded(uint proposalID, address recipient, uint amount, string description, string fullDescHash);
    event Voted(uint proposalID, bool position, address voter, string justification);
    event ProposalTallied(uint proposalID, uint votesSupport, uint votesAgainst, uint quorum, bool active);    
    event ChangeOfRules(uint newMinimumQuorum, uint newdebatingPeriodDuration, uint newRequisiteMajority);
    event Payment(address indexed sender, uint amount);

    // Modifier that allows only owners of tokens to vote and create new proposals
    modifier onlyMembers {
        require(balances[msg.sender] > 0);
        _;
    }

    /**
     * Change voting rules
     *
     * Make so that Proposals need to be discussed for at least `_debatingPeriodDuration/60` hours,
     * have at least `_minimumQuorum` votes, and have 50% + `_requisiteMajority` votes to be executed
     *
     * @param _minimumQuorum how many members must vote on a proposal for it to be executed
     * @param _debatingPeriodDuration the minimum amount of delay between when a proposal is made and when it can be executed
     * @param _requisiteMajority the proposal needs to have 50% plus this number
     */
    function changeVotingRules(
        uint _minimumQuorum,
        uint _debatingPeriodDuration,
        uint _requisiteMajority
    ) onlyOwner public {
        minimumQuorum = _minimumQuorum;
        debatingPeriodDuration = _debatingPeriodDuration;
        requisiteMajority = _requisiteMajority;

        emit ChangeOfRules(minimumQuorum, debatingPeriodDuration, requisiteMajority);
    }

    /**
     * Add Proposal
     *
     * Propose to send `_amount / 1e18` ether to `_recipient` for `_desc`. `_transactionByteCode ? Contains : Does not contain` code.
     *
     * @param _recipient who to send the ether to
     * @param _amount amount of ether to send, in wei
     * @param _desc Description of job
     * @param _fullDescHash Hash of full description of job
     * @param _transactionByteCode bytecode of transaction
     */
    function addProposal(address _recipient, uint _amount, string _desc, string _fullDescHash, bytes _transactionByteCode, uint _debatingPeriodDuration) onlyMembers public returns (uint) {
        require(balances[msg.sender] > minBalance);

        if (_debatingPeriodDuration == 0) {
            _debatingPeriodDuration = debatingPeriodDuration;
        }

        Proposals.push(_Proposal({      
            endTimeOfVoting: now + _debatingPeriodDuration * 1 minutes,
            executed: false,
            proposalPassed: false,
            numberOfVotes: 0,
            votesSupport: 0,
            votesAgainst: 0,
            recipient: _recipient,
            amount: _amount,
            transactionHash: keccak256(abi.encodePacked(_recipient, _amount, _transactionByteCode)),
            desc: _desc,
            fullDescHash: _fullDescHash
        }));
        
        // add proposal in ERC20 base contract for block transfer
        super.addProposal(Proposals.length-1, Proposals[Proposals.length-1].endTimeOfVoting);

        emit ProposalAdded(Proposals.length-1, _recipient, _amount, _desc, _fullDescHash);

        return Proposals.length-1;
    }

    /**
     * Check if a proposal code matches
     *
     * @param _proposalID number of the proposal to query
     * @param _recipient who to send the ether to
     * @param _amount amount of ether to send
     * @param _transactionByteCode bytecode of transaction
     */
    function checkProposalCode(uint _proposalID, address _recipient, uint _amount, bytes _transactionByteCode) view public returns (bool) {
        require(Proposals[_proposalID].recipient == _recipient);
        require(Proposals[_proposalID].amount == _amount);
        // compare ByteCode        
        return Proposals[_proposalID].transactionHash == keccak256(abi.encodePacked(_recipient, _amount, _transactionByteCode));
    }

    /**
     * Log a vote for a proposal
     *
     * Vote `supportsProposal? in support of : against` proposal #`proposalID`
     *
     * @param _proposalID number of proposal
     * @param _supportsProposal either in favor or against it
     * @param _justificationText optional justification text
     */
    function vote(uint _proposalID, bool _supportsProposal, string _justificationText) onlyMembers public returns (uint) {
        // Get the proposal
        _Proposal storage p = Proposals[_proposalID]; 
        require(now <= p.endTimeOfVoting);

        // get numbers of votes for msg.sender
        uint votes = safeSub(balances[msg.sender], voted[_proposalID][msg.sender]);
        require(votes > 0);

        voted[_proposalID][msg.sender] = safeAdd(voted[_proposalID][msg.sender], votes);

        // Increase the number of votes
        p.numberOfVotes = p.numberOfVotes + votes;
        
        if (_supportsProposal) {
            p.votesSupport = p.votesSupport + votes;
        } else {
            p.votesAgainst = p.votesAgainst + votes;
        }
        
        emit Voted(_proposalID, _supportsProposal, msg.sender, _justificationText);
        return p.numberOfVotes;
    }

    /**
     * Finish vote
     *
     * Count the votes proposal #`_proposalID` and execute it if approved
     *
     * @param _proposalID proposal number
     * @param _transactionByteCode optional: if the transaction contained a bytecode, you need to send it
     */
    function executeProposal(uint _proposalID, bytes _transactionByteCode) public {
        // Get the proposal
        _Proposal storage p = Proposals[_proposalID];

        require(now > p.endTimeOfVoting                                                                       // If it is past the voting deadline
            && !p.executed                                                                                    // and it has not already been executed
            && p.transactionHash == keccak256(abi.encodePacked(p.recipient, p.amount, _transactionByteCode))  // and the supplied code matches the proposal
            && p.numberOfVotes >= minimumQuorum);                                                             // and a minimum quorum has been reached
        // then execute result
        if (p.votesSupport > requisiteMajority) {
            // Proposal passed; execute the transaction
            require(p.recipient.call.value(p.amount)(_transactionByteCode));
            p.proposalPassed = true;
        } else {
            // Proposal failed
            p.proposalPassed = false;
        }
        p.executed = true;

        // delete proposal from active list
        super.delProposal(_proposalID);
       
        // Fire Events
        emit ProposalTallied(_proposalID, p.votesSupport, p.votesAgainst, p.numberOfVotes, p.proposalPassed);
    }

    // function is needed if execution transactionByteCode in Proposal failed
    function delActiveProposal(uint _proposalID) public onlyOwner {
        // delete proposal from active list
        super.delProposal(_proposalID);   
    }

    /**
    * @dev Allows the DAO to transfer control of the _contract to a _newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _contract, address _newOwner) public onlyOwner {
        CommonI(_contract).transferOwnership(_newOwner);
    }

    /**
     * @dev Accept transferOwnership on a this (DAO) contract
     */
    function acceptOwnership(address _contract) public onlyOwner {
        CommonI(_contract).acceptOwnership();        
    }

    function updateAgent(address _contract, address _agent, bool _state) public onlyOwner {
        CommonI(_contract).updateAgent(_agent, _state);        
    }

    /**
     * Set minimum balance for adding proposal
     */
    function setMinBalance(uint _minBalance) public onlyOwner {
        assert(_minBalance > 0);
        minBalance = _minBalance;
    }
}


/**
 * @title Agent contract - base contract with an agent
 */
contract Agent is Ownable {

  address public defAgent;

  mapping(address => bool) public Agents;
  
  constructor() public {    
    Agents[msg.sender] = true;
  }
  
  modifier onlyAgent() {
    assert(Agents[msg.sender]);
    _;
  }
  
  function updateAgent(address _agent, bool _status) public onlyOwner {
    assert(_agent != address(0));
    Agents[_agent] = _status;
  }  
}


/**
 * @title SDAD - ERC20 Token based on ERC20Base, DAO, Dividends smart contracts
 */
contract SDAD is SDADI, DAO {
	
  uint public initialSupply = 10 * 10**6; // 10 million tokens
  uint public decimals = 8;

  string public name;
  string public symbol;

  /** Name and symbol were updated. */
  event UpdatedTokenInformation(string _name, string _symbol);

  /** Period were updated. */
  event UpdatedPeriod(uint _period);

  constructor(string _name, string _symbol, uint _start, uint _period, address _dexowner) public {
    name = _name;
    symbol = _symbol;
    start = _start;
    period = _period;

    totalSupply_ = initialSupply*10**decimals;

    // creating initial tokens
    balances[_dexowner] = totalSupply_;    
    emit Transfer(0x0, _dexowner, balances[_dexowner]);

    ownersIndex[_dexowner] = true;
    owners.push(_dexowner);

    ChangeOverPeriod[_dexowner][1] = int256(balances[_dexowner]);

    // set voting rules
    // _minimumQuorum = 50%
    // _requisiteMajority = 25%
    // _debatingPeriodDuration = 1 day
    changeVotingRules(safePerc(totalSupply_, 5000), 1440, safePerc(totalSupply_, 2500));

    // add ETH
    tokens.push(address(0));
    tokensIndex[address(0)] = tokens.length-1;
  } 

  /**
  * Owner can update token information here.
  *
  * It is often useful to conceal the actual token association, until
  * the token operations, like central issuance or reissuance have been completed.
  *
  * This function allows the token owner to rename the token after the operations
  * have been completed and then point the audience to use the token contract.
  */
  function setTokenInformation(string _name, string _symbol) public onlyOwner {
    name = _name;
    symbol = _symbol;
    emit UpdatedTokenInformation(_name, _symbol);
  }

  /**
  * Owner can change period
  *
  */
  function setPeriod(uint _period) public onlyOwner {
    period = _period;
    emit UpdatedPeriod(_period);    
  }

  /**
  * set owner to self
  *
  */
  function setOwnerToSelf() public onlyOwner {
    owner = address(this);
    emit OwnershipTransferred(msg.sender, address(this));
  }
}