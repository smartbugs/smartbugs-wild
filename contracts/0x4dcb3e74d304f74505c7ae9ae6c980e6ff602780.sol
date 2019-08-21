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
 * @title Agent contract - base contract with an agent
 */
contract Agent is Ownable {

  address public defAgent;

  mapping(address => bool) public Agents;  

  event UpdatedAgent(address _agent, bool _status);

  constructor() public {
    defAgent = msg.sender;
    Agents[msg.sender] = true;
  }
  
  modifier onlyAgent() {
    assert(Agents[msg.sender]);
    _;
  }
  
  function updateAgent(address _agent, bool _status) public onlyOwner {
    assert(_agent != address(0));
    Agents[_agent] = _status;

    emit UpdatedAgent(_agent, _status);
  }  
}


/**
 * @title CryptoDuel game
 */
contract CryptoDuel is Agent, SafeMath {

  uint public fee = 100; // 1%
  uint public referrerFee = 5000; // 50 %
  uint public min = 10000000000000000;       // 0.01 ETH
  uint public max = 1000000000000000000000;  // 1000 ETH

  /** State
   *
   * - New: 0 
   * - Deleted: 1
   * - OnGoing: 2
   * - Closed: 3
   */
  enum State{New, Deleted, OnGoing, Closed}

  struct _duel {
    address creator;
    address responder;
    uint bet;
    uint blocknumber;
    int referrerID;
    State state;
  }

  _duel[] public Duels;
  mapping (int => address) public Referrer; 
  mapping (address => uint) public reward; 

  event newDuel(uint duel, address indexed creator, address indexed responder, uint bet, int referrerID);
  event deleteDuel(uint duel);
  event respondDuel(uint duel, address indexed responder);

  event refundDuel(uint duel);
  event resultDuel(uint duel, address indexed winner, uint sum);

  event changeMin(uint min);
  event changeMax(uint max);

  event changeReferrerFee(uint referrerFee);
  event changeReferrer(int referrerID, address referrerAddress);
  
  event changeFee(uint fee);
  event withdrawFee(uint fee, address referrer);

  constructor() public {
    Referrer[0] = msg.sender;
    emit changeReferrer(0, msg.sender);
  }


  function CreateDuel(address _responder, int _referrerID) payable external {
    
    require(msg.value >= min && msg.value <= max);
    require(Referrer[_referrerID] != address(0));
    
    Duels.push(_duel({
      creator: msg.sender,
      responder: _responder,
      bet: msg.value,
      blocknumber: 0,
      state: State.New,
      referrerID: _referrerID
    }));

    emit newDuel(Duels.length-1, msg.sender, _responder, msg.value, _referrerID);
  } 


  function RespondDuel(uint _duelID) payable external {

    _duel storage duel = Duels[_duelID];

    require(duel.state == State.New);
    require(duel.bet == msg.value);
    require(duel.responder == msg.sender || duel.responder == address(0));

    duel.state = State.OnGoing;
    duel.responder = msg.sender;
    duel.blocknumber = block.number;    

    emit respondDuel(_duelID, msg.sender);
  }

    
  function DeleteDuel(uint _duelID) external {

    _duel storage duel = Duels[_duelID];

    require(duel.creator == msg.sender);
    require(duel.state == State.New);

    duel.state = State.Deleted;

    uint duel_fee = safePerc(duel.bet, fee);
    uint duel_fee_referrer = safePerc(duel_fee, referrerFee);
    
    reward[Referrer[0]] = safeAdd(reward[Referrer[0]], safeSub(duel_fee, duel_fee_referrer));
    reward[Referrer[duel.referrerID]] = safeAdd(reward[Referrer[duel.referrerID]], duel_fee_referrer);
    
    duel.creator.transfer(safeSub(duel.bet, duel_fee));

    emit deleteDuel(_duelID);
  }


  function GetWin(uint _duelID) external {

    _duel storage duel = Duels[_duelID];

    require(duel.state == State.OnGoing);    
    require(duel.creator == msg.sender || duel.responder == msg.sender);
    require(block.number > duel.blocknumber+1);

    duel.state = State.Closed;
    uint duel_fee = 0;
    uint duel_fee_referrer = 0;
    if (blockhash(duel.blocknumber) == 0 || (block.number - duel.blocknumber) > 256) {
    
      duel_fee = safePerc(duel.bet, fee);
      
      duel.creator.transfer(safeSub(duel.bet, duel_fee));
      duel.responder.transfer(safeSub(duel.bet, duel_fee));
      
      duel_fee_referrer = safePerc(duel_fee, referrerFee);
      
      reward[Referrer[0]] = safeAdd(reward[Referrer[0]], safeMul(2, safeSub(duel_fee, duel_fee_referrer)));
      reward[Referrer[duel.referrerID]] = safeAdd(reward[Referrer[duel.referrerID]], safeMul(2, duel_fee_referrer));

      emit refundDuel(_duelID);

    } else {

      uint hash = uint(keccak256(abi.encodePacked(blockhash(duel.blocknumber+1), duel.creator, duel.responder, duel.bet)));

      uint duel_bet_common = safeMul(2, duel.bet);
      duel_fee = safePerc(duel_bet_common, fee);
      duel_fee_referrer = safePerc(duel_fee, referrerFee);
      
      reward[Referrer[0]] = safeAdd(reward[Referrer[0]], safeSub(duel_fee, duel_fee_referrer));
      reward[Referrer[duel.referrerID]] = safeAdd(reward[Referrer[duel.referrerID]], duel_fee_referrer);

      uint sum = safeSub(duel_bet_common, duel_fee);

      if (hash % 2 == 0) {        
        duel.creator.transfer(sum);
        emit resultDuel(_duelID, duel.creator, sum);
      } else {
        duel.responder.transfer(sum);
        emit resultDuel(_duelID, duel.responder, sum);
      }     

    }
  }

  function setMin(uint _min) external onlyOwner {
    min = _min;
    emit changeMin(_min);
  }

  function setMax(uint _max) external onlyOwner {
    max = _max;
    emit changeMax(_max);
  }

  function setFee(uint _fee) external onlyOwner {
    fee = _fee;
    emit changeFee(_fee);
  }

  function setReferrerFee(uint _referrerFee) external onlyOwner {
    referrerFee = _referrerFee;
    emit changeReferrerFee(_referrerFee);
  }
  
  function setReferrer(int _referrerID, address _referrerAddress) external onlyOwner {
    Referrer[_referrerID] = _referrerAddress;
    emit changeReferrer(_referrerID, _referrerAddress);
  }
  
  function withdraw(int _referrerID) external {
    require(msg.sender == Referrer[_referrerID]);
    uint sum = reward[msg.sender];
    reward[msg.sender] = 0;
    msg.sender.transfer(sum);
    emit withdrawFee(sum, msg.sender);
  }
}