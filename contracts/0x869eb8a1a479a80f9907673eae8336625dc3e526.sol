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

    uint public fee = 100;            //  1% from bet
    uint public refGroupFee = 5000;   // 50% from profit
    uint public refLevel1Fee = 1000;  // 10% from profit
    uint public refLevel2Fee = 500;   //  5% from profit
    uint public min = 1000000000000000;       // 0.001 ETH
    uint public max = 1000000000000000000000;  // 1000 ETH

    uint256 public start = 0;         // Must be equal to the date of issue tokens
    uint256 public period = 30 days;  // By default, the dividend accrual period is 30 days

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
        int refID;
        State state;
    }

    _duel[] public Duels;
    mapping(int => address) public RefGroup;                 // RefGroup[id group] = address referrer
    mapping(address => address) public RefAddr;              // RefAddr[address referal] = address referrer

    mapping(uint => uint) public reward;                     // reward[period] = amount
    mapping(address => uint) public rewardGroup;             // rewardGroup[address] = amount
    mapping(address => uint) public rewardAddr;              // rewardAddr[address] = amount

    mapping(uint => bool) public AlreadyReward;              // AlreadyReward[period] = true/false

    event newDuel(uint duel, address indexed creator, address indexed responder, uint bet, int refID);
    event deleteDuel(uint duel);
    event respondDuel(uint duel, address indexed responder);

    event refundDuel(uint duel);
    event resultDuel(uint duel, address indexed winner, uint sum);

    event changeMin(uint min);
    event changeMax(uint max);
    
    event changeRefGroup(int ID, address referrer);
    event changeRefAddr(address referal, address referrer);

    event changeFee(uint fee);
    event changeRefGroupFee(uint refGroupFee);
    event changeRefLevel1Fee(uint refLevel1Fee);
    event changeRefLevel2Fee(uint refLevel2Fee);    
    
    event withdrawProfit(uint fee, address RefGroup);

    event UpdatedPeriod(uint _period);

    constructor() public {
        RefGroup[0] = msg.sender;
        emit changeRefGroup(0, msg.sender);
    }

    function CreateDuel(address _responder) payable external {

        require(msg.value >= min && msg.value <= max);        

        Duels.push(_duel({
            creator : msg.sender,
            responder : _responder,
            bet : msg.value,
            blocknumber : 0,
            state : State.New,
            refID : 0
            }));

        emit newDuel(Duels.length - 1, msg.sender, _responder, msg.value, 0);
    }

    function CreateDuel(address _responder, int _refID) payable external {

        require(msg.value >= min && msg.value <= max);
        require(RefGroup[_refID] != address(0));

        Duels.push(_duel({
            creator : msg.sender,
            responder : _responder,
            bet : msg.value,
            blocknumber : 0,
            state : State.New,
            refID : _refID
            }));

        emit newDuel(Duels.length - 1, msg.sender, _responder, msg.value, _refID);
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

        uint256 N = 1;
        if (block.timestamp > start) {
            N = (block.timestamp - start) / period + 1;
        }

        reward[N] = safeAdd(reward[N], duel_fee);

        duel.creator.transfer(safeSub(duel.bet, duel_fee));

        emit deleteDuel(_duelID);
    }


    function GetWin(uint _duelID) external {

        _duel storage duel = Duels[_duelID];

        require(duel.state == State.OnGoing);
        require(duel.creator == msg.sender || duel.responder == msg.sender);
        require(block.number > duel.blocknumber + 1);

        duel.state = State.Closed;
        uint duel_fee = 0;

        uint256 N = 1;
        if (block.timestamp > start) {
            N = (block.timestamp - start) / period + 1;
        }

        if (blockhash(duel.blocknumber) == 0 || (block.number - duel.blocknumber) > 256) {

            duel_fee = safePerc(duel.bet, fee);

            duel.creator.transfer(safeSub(duel.bet, duel_fee));
            duel.responder.transfer(safeSub(duel.bet, duel_fee));

            reward[N] = safeAdd(reward[N], safeMul(2, duel_fee));

            emit refundDuel(_duelID);

        } else {

            uint hash = uint(keccak256(abi.encodePacked(blockhash(duel.blocknumber + 1), duel.creator, duel.responder, duel.bet)));

            uint duel_bet_common = safeMul(2, duel.bet);
            duel_fee = safePerc(duel_bet_common, fee);

            uint refFee = 0;
            uint sum = safeSub(duel_bet_common, duel_fee);

            address winner;

            if (hash % 2 == 0) {
                duel.creator.transfer(sum);
                winner = duel.creator;
                emit resultDuel(_duelID, duel.creator, sum);

            } else {                
                duel.responder.transfer(sum);
                winner = duel.responder;
                emit resultDuel(_duelID, duel.responder, sum);
            }

            // ref level 1
            if (RefAddr[winner] != address(0)) {                
                refFee = refLevel1Fee;
                rewardAddr[RefAddr[winner]] = safeAdd(rewardAddr[RefAddr[winner]], safePerc(duel_fee, refLevel1Fee));

                // ref level 2
                if (RefAddr[RefAddr[winner]] != address(0)) {
                    refFee = safeAdd(refFee, refLevel2Fee);
                    rewardAddr[RefAddr[RefAddr[winner]]] = safeAdd(rewardAddr[RefAddr[RefAddr[winner]]], safePerc(duel_fee, refLevel2Fee));
                }
            }
            
            // ref group
            if (duel.refID != 0) {
                refFee = safeSub(refGroupFee, refFee);
                rewardGroup[RefGroup[duel.refID]] = safeAdd(rewardGroup[RefGroup[duel.refID]], safePerc(duel_fee, refFee));
                reward[N] = safeAdd(reward[N], safeSub(duel_fee, safePerc(duel_fee, refGroupFee)));
            } else {
                reward[N] = safeAdd(reward[N], safeSub(duel_fee, safePerc(duel_fee, refFee)));
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

    function setRefGroupFee(uint _refGroupFee) external onlyOwner {
        refGroupFee = _refGroupFee;        
        emit changeRefGroupFee(_refGroupFee);
    }
    
    function setRefLevel1Fee(uint _refLevel1Fee) external onlyOwner {
        refLevel1Fee = _refLevel1Fee;
        emit changeRefLevel1Fee(_refLevel1Fee);
    }

    function setRefLevel2Fee(uint _refLevel2Fee) external onlyOwner {
        refLevel2Fee = _refLevel2Fee;
        emit changeRefLevel2Fee(_refLevel2Fee);
    }
    
    function setRefGroup(int _ID, address _referrer) external onlyAgent {
        RefGroup[_ID] = _referrer;
        emit changeRefGroup(_ID, _referrer);
    }
    
    function setRefAddr(address _referral, address _referrer) external onlyAgent {
        RefAddr[_referral] = _referrer;
        emit changeRefAddr(_referral, _referrer);
    }

    function withdraw() external onlyOwner returns (bool success) {        
        uint256 N = 1;
        if (block.timestamp > start) {
            N = (block.timestamp - start) / period;
        }

        if (!AlreadyReward[N]) {
            uint amount = reward[N];
            AlreadyReward[N] = true;
            msg.sender.transfer(amount);
            emit withdrawProfit(amount, msg.sender);
            return true;
        } else {
            return false;
        }
    }
    
    function withdrawRefGroup() external returns (bool success) {
        require(rewardGroup[msg.sender] > 0);
        uint amount = rewardGroup[msg.sender];
        rewardGroup[msg.sender] = 0;
        msg.sender.transfer(amount);
        emit withdrawProfit(amount, msg.sender);
        return true;
    }

    function withdrawRefAddr() external returns (bool success) {
        require(rewardAddr[msg.sender] > 0);
        uint amount = rewardAddr[msg.sender];
        rewardAddr[msg.sender] = 0;
        msg.sender.transfer(amount);
        emit withdrawProfit(amount, msg.sender);
        return true;
    }

    function withdrawRefBoth() external returns (bool success) {
        require(rewardAddr[msg.sender] > 0 || rewardGroup[msg.sender] > 0);
        uint amount = safeAdd(rewardAddr[msg.sender], rewardGroup[msg.sender]);
        rewardAddr[msg.sender] = 0;
        rewardGroup[msg.sender] = 0;
        msg.sender.transfer(amount);
        emit withdrawProfit(amount, msg.sender);
        return true;
    }

    /**
    * Owner can change period
    */
    function setPeriod(uint _period) external onlyOwner {
        period = _period;
        emit UpdatedPeriod(_period);
    }

    /**
    * Owner can change start
    */
    function setStart(uint _start) external onlyOwner {        
        start = _start;
    }
}