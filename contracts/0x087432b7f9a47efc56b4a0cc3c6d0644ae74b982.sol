pragma solidity ^0.4.24;

/**
 * @title ERC223 interface
 * @dev see https://github.com/ethereum/EIPs/issues/223
 */
interface ERC223I {

  function balanceOf(address _owner) external view returns (uint balance);
  
  function name() external view returns (string _name);
  function symbol() external view returns (string _symbol);
  function decimals() external view returns (uint8 _decimals);
  function totalSupply() external view returns (uint256 supply);

  function transfer(address to, uint value) external returns (bool ok);
  function transfer(address to, uint value, bytes data) external returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) external returns (bool ok);

  function releaseTokenTransfer() external;
  
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);  
}

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
 * @title RateContract Interface
 * @dev 
 */
interface RateContractI {
    // returns the Currency information
    function getCurrency(bytes32 _code) external view returns (string, uint, uint, uint, uint);

    // returns Rate of coin to PMC (with the exception of rate["ETH"]) 
    function getRate(bytes32 _code) external view returns (uint);

    // returns Price of Object in the specified currency (local user currency)
    // _code - specified currency
    // _amount - price of object in PMC
    function getLocalPrice(bytes32 _code, uint _amount) external view returns (uint);

    // returns Price of Object in the crypto currency (ETH)    
    // _amount - price of object in PMC
    function getCryptoPrice(uint _amount) external view returns (uint);

    // update rates for a specific coin
    function updateRate(bytes32 _code, uint _pmc) external;
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
 * @title Standard ERC223 token
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/223
 */
contract ERC223 is ERC223I, Agent, SafeMath {

  mapping(address => uint) balances;
  
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;

  address public crowdsale = address(0);
  bool public released = false;

  /**
   * @dev Limit token transfer until the crowdsale is over.
   */
  modifier canTransfer() {
    assert(released || msg.sender == crowdsale);
    _;
  }

  modifier onlyCrowdsaleContract() {
    assert(msg.sender == crowdsale);
    _;
  }  
  
  function name() public view returns (string _name) {
    return name;
  }

  function symbol() public view returns (string _symbol) {
    return symbol;
  }

  function decimals() public view returns (uint8 _decimals) {
    return decimals;
  }

  function totalSupply() public view returns (uint256 _totalSupply) {
    return totalSupply;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }  

  // if bytecode exists then the _addr is a contract.
  function isContract(address _addr) private view returns (bool is_contract) {
    uint length;
    assembly {
      //retrieve the size of the code on target address, this needs assembly
      length := extcodesize(_addr)
    }
    return (length>0);
  }
  
  // function that is called when a user or another contract wants to transfer funds .
  function transfer(address _to, uint _value, bytes _data) external canTransfer() returns (bool success) {      
    if(isContract(_to)) {
      return transferToContract(_to, _value, _data);
    } else {
      return transferToAddress(_to, _value, _data);
    }
  }
  
  // standard function transfer similar to ERC20 transfer with no _data.
  // added due to backwards compatibility reasons.
  function transfer(address _to, uint _value) external canTransfer() returns (bool success) {      
    bytes memory empty;
    if(isContract(_to)) {
      return transferToContract(_to, _value, empty);
    } else {
      return transferToAddress(_to, _value, empty);
    }
  }

  // function that is called when transaction target is an address
  function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  
  // function that is called when transaction target is a contract
  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    assert(_to.call.value(0)(abi.encodeWithSignature("tokenFallback(address,uint256,bytes)", msg.sender, _value, _data)));
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }

  // function that is called when a user or another contract wants to transfer funds .
  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) external canTransfer() returns (bool success) {      
    if(isContract(_to)) {
      if (balanceOf(msg.sender) < _value) revert();
      balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
      balances[_to] = safeAdd(balanceOf(_to), _value);      
      assert(_to.call.value(0)(abi.encodeWithSignature(_custom_fallback), msg.sender, _value, _data));    
      emit Transfer(msg.sender, _to, _value, _data);
      return true;
    } else {
      return transferToAddress(_to, _value, _data);
    }
  }

  function setCrowdsaleContract(address _contract) external onlyOwner {
    crowdsale = _contract;
  }

  /**
   * @dev One way function to release the tokens to the wild. Can be called only from the crowdsale contract.
   */
  function releaseTokenTransfer() external onlyCrowdsaleContract {
    released = true;
  }
}


/**
 * @title SABIGlobal CrowdSale management contract
 */
contract CrowdSale is Agent, SafeMath {

  uint public decimals = 8;
  uint public multiplier = 10 ** decimals;
  
  RateContractI public RateContract;
  ERC223I public ERC223;

  uint public totalSupply;
  
  uint public SoftCap;
  uint public HardCap;

  /* The UNIX timestamp start/end date of the crowdsale */
  uint public startsAt;
  uint public endsIn;
  
  /* How many unique addresses that have invested */
  uint public investorCount = 0;
  
  /* How many wei of funding we have raised */
  uint public weiRaised = 0;
  
  /* How many usd of funding we have raised */
  uint public usdRaised = 0;
  
  /* The number of tokens already sold through this contract*/
  uint public tokensSold = 0;
  
  /* Has this crowdsale been finalized */
  bool public finalized;

  /** State
   *
   * - Preparing: All contract initialization calls and variables have not been set yet
   * - PrivateSale: Private sale
   * - PreSale: Pre Sale
   * - Sale: Active crowdsale
   * - Success: HardCap reached
   * - Failure: HardCap not reached before ending time
   * - Finalized: The finalized has been called and succesfully executed
   */
  enum State{Unknown, Preparing, PrivateSale, PreSale, Sale, Success, Failure, Finalized}

  /* How much ETH each address has invested to this crowdsale */
  mapping (address => uint) public investedAmountOf;
  
  /* How much tokens this crowdsale has credited for each investor address */
  mapping (address => uint) public tokenAmountOf;
  
  /* Wei will be transfered on this address */
  address public multisigWallet;
  
  /* How much wei we have given back to investors. */
  uint public weiRefunded = 0;

  /* token price in USD */
  uint public price;

  struct _Stage {
    uint startsAt;
    uint endsIn;
    uint bonus;    
    uint min;
    uint tokenAmount;
    mapping (address => uint) tokenAmountOfStage; // how much tokens this crowdsale has credited for each investor address in a particular stage
  }

  _Stage[5] public Stages;

  mapping (bytes32 => uint) public cap;
  uint[5] public duration;

  /* A new investment was made */
  event Invested(address investor, uint weiAmount, uint tokenAmount, uint bonusAmount);
  /* Receive ether on the contract */
  event ReceiveEtherOnContract(address sender, uint amount);
  
  /**
   * @dev Constructor sets default parameters
   * @param _startsAt1 = 1539993600 (20.10.2018)
   * @param _startsAt2 = 1543104000 (25.11.2018)
   * @param _startsAt3 = 1544313600 (09.12.2018)
   * @param _startsAt4 = 1545523200 (23.12.2018)
   * @param _startsAt5 = 1552176000 (10.03.2019)
   */
  constructor(address _multisigWallet, uint _priceTokenInUSDCents, uint _startsAt1, uint _startsAt2, uint _startsAt3, uint _startsAt4, uint _startsAt5) public {
    
    duration[0] = 36 days;
    duration[1] = 14 days;
    duration[2] = 14 days;
    duration[3] =  9 days;  
    duration[4] = 32 days;

    initialization(_multisigWallet, _priceTokenInUSDCents, _startsAt1, _startsAt2, _startsAt3, _startsAt4, _startsAt5);
  }

  function hash(State _data) private pure returns (bytes32 _hash) {
    return keccak256(abi.encodePacked(_data));
  }

  function initialization(address _multisigWallet, uint _priceTokenInUSDCents, uint _startsAt1, uint _startsAt2, uint _startsAt3, uint _startsAt4, uint _startsAt5) public onlyOwner {

    require(_multisigWallet != address(0) && _priceTokenInUSDCents > 0);

    require(_startsAt1 < _startsAt2 &&
            _startsAt2 >= _startsAt1 + duration[0] &&
            _startsAt3 >= _startsAt2 + duration[1] &&
            _startsAt4 >= _startsAt3 + duration[2] &&
            _startsAt5 >= _startsAt4 + duration[3]);

    multisigWallet =_multisigWallet;
    startsAt = _startsAt1;
    endsIn = _startsAt5 + duration[4];
    price = _priceTokenInUSDCents;

    SoftCap =  200 * (10**6) * multiplier;
    HardCap = 1085 * (10**6) * multiplier;

    cap[hash(State.PrivateSale)] = 150 * (10**6) * multiplier +  60 * (10**6) * multiplier;
    cap[hash(State.PreSale)]     = 500 * (10**6) * multiplier + 125 * (10**6) * multiplier;
    cap[hash(State.Sale)]        = 250 * (10**6) * multiplier;

    Stages[0] = _Stage({startsAt: _startsAt1, endsIn:_startsAt1 + duration[0] - 1, bonus: 4000, min: 1250 * 10**3 * multiplier, tokenAmount: 0});
    Stages[1] = _Stage({startsAt: _startsAt2, endsIn:_startsAt2 + duration[1] - 1, bonus: 2500, min: 2500 * multiplier, tokenAmount: 0});
    Stages[2] = _Stage({startsAt: _startsAt3, endsIn:_startsAt3 + duration[2] - 1, bonus: 2000, min: 2500 * multiplier, tokenAmount: 0});
    Stages[3] = _Stage({startsAt: _startsAt4, endsIn:_startsAt4 + duration[3],     bonus: 1500, min: 2500 * multiplier, tokenAmount: 0});
    Stages[4] = _Stage({startsAt: _startsAt5, endsIn:_startsAt5 + duration[4],     bonus:    0, min: 1000 * multiplier, tokenAmount: 0});
  }
  
  /** 
   * @dev Crowdfund state
   * @return State current state
   */
  function getState() public constant returns (State) {
    if (finalized) return State.Finalized;
    else if (ERC223 == address(0) || RateContract == address(0) || now < startsAt) return State.Preparing;
    else if (now >= Stages[0].startsAt && now <= Stages[0].endsIn) return State.PrivateSale;
    else if (now >= Stages[1].startsAt && now <= Stages[3].endsIn) return State.PreSale;
    else if (now > Stages[3].endsIn && now < Stages[4].startsAt) return State.Preparing;
    else if (now >= Stages[4].startsAt && now <= Stages[4].endsIn) return State.Sale;    
    else if (isCrowdsaleFull()) return State.Success;
    else return State.Failure;
  }

  /** 
   * @dev Gets the current stage.
   * @return uint current stage
   */
  function getStage() public constant returns (uint) {
    uint i;
    for (i = 0; i < Stages.length; i++) {
      if (now >= Stages[i].startsAt && now < Stages[i].endsIn) {
        return i;
      }
    }
    return Stages.length-1;
  }

  /**
   * Buy tokens from the contract
   */
  function() public payable {
    investInternal(msg.sender, msg.value);
  }

  /**
   * Buy tokens from personal area (ETH or BTC)
   */
  function investByAgent(address _receiver, uint _weiAmount) external onlyAgent {
    investInternal(_receiver, _weiAmount);
  }
  
  /**
   * Make an investment.
   *
   * @param _receiver The Ethereum address who receives the tokens
   * @param _weiAmount The invested amount
   *
   */
  function investInternal(address _receiver, uint _weiAmount) private {

    require(_weiAmount > 0);

    State currentState = getState();
    require(currentState == State.PrivateSale || currentState == State.PreSale || currentState == State.Sale);

    uint currentStage = getStage();
    
    // Calculating the number of tokens
    uint tokenAmount = 0;
    uint bonusAmount = 0;
    (tokenAmount, bonusAmount) = calculateTokens(_weiAmount, currentStage);

    tokenAmount = safeAdd(tokenAmount, bonusAmount);
    
    // Check cap for every State
    if (currentState == State.PrivateSale || currentState == State.Sale) {
      require(safeAdd(Stages[currentStage].tokenAmount, tokenAmount) <= cap[hash(currentState)]);
    } else {
      uint TokenSoldOnPreSale = safeAdd(safeAdd(Stages[1].tokenAmount, Stages[2].tokenAmount), Stages[3].tokenAmount);
      TokenSoldOnPreSale = safeAdd(TokenSoldOnPreSale, tokenAmount);
      require(TokenSoldOnPreSale <= cap[hash(currentState)]);
    }      

    // Check HardCap
    require(safeAdd(tokensSold, tokenAmount) <= HardCap);
    
    // Update stage counts  
    Stages[currentStage].tokenAmount  = safeAdd(Stages[currentStage].tokenAmount, tokenAmount);
    Stages[currentStage].tokenAmountOfStage[_receiver] = safeAdd(Stages[currentStage].tokenAmountOfStage[_receiver], tokenAmount);
	
    // Update investor
    if(investedAmountOf[_receiver] == 0) {       
       investorCount++; // A new investor
    }  
    investedAmountOf[_receiver] = safeAdd(investedAmountOf[_receiver], _weiAmount);
    tokenAmountOf[_receiver] = safeAdd(tokenAmountOf[_receiver], tokenAmount);

    // Update totals
    weiRaised  = safeAdd(weiRaised, _weiAmount);
    usdRaised  = safeAdd(usdRaised, weiToUsdCents(_weiAmount));
    tokensSold = safeAdd(tokensSold, tokenAmount);    

    // Send ETH to multisigWallet
    multisigWallet.transfer(msg.value);

    // Send tokens to _receiver
    ERC223.transfer(_receiver, tokenAmount);

    // Tell us invest was success
    emit Invested(_receiver, _weiAmount, tokenAmount, bonusAmount);
  }  
  
  /**
   * @dev Calculating tokens count
   * @param _weiAmount invested
   * @param _stage stage of crowdsale
   * @return tokens amount
   */
  function calculateTokens(uint _weiAmount, uint _stage) internal view returns (uint tokens, uint bonus) {
    uint usdAmount = weiToUsdCents(_weiAmount);    
    tokens = safeDiv(safeMul(multiplier, usdAmount), price);

    // Check minimal amount to buy
    require(tokens >= Stages[_stage].min);    

    bonus = safePerc(tokens, Stages[_stage].bonus);
    return (tokens, bonus);
  }
  
  /**
   * @dev Converts wei value into USD cents according to current exchange rate
   * @param weiValue wei value to convert
   * @return USD cents equivalent of the wei value
   */
  function weiToUsdCents(uint weiValue) internal view returns (uint) {
    return safeDiv(safeMul(weiValue, RateContract.getRate("ETH")), 1 ether);
  }
  
  /**
   * @dev Check if SoftCap was reached.
   * @return true if the crowdsale has raised enough money to be a success
   */
  function isCrowdsaleFull() public constant returns (bool) {
    if(tokensSold >= SoftCap){
      return true;  
    }
    return false;
  }

  /**
   * @dev burn unsold tokens and allow transfer of tokens.
   */
  function finalize() public onlyOwner {    
    require(!finalized);
    require(now > endsIn);

    if(HardCap > tokensSold){
      // burn unsold tokens 
      ERC223.transfer(address(0), safeSub(HardCap, tokensSold));
    }

    // allow transfer of tokens
    ERC223.releaseTokenTransfer();

    finalized = true;
  }

  /**
   * Receives ether on the contract
   */
  function receive() public payable {
    emit ReceiveEtherOnContract(msg.sender, msg.value);
  }

  function setTokenContract(address _contract) external onlyOwner {
    ERC223 = ERC223I(_contract);
    totalSupply = ERC223.totalSupply();
    HardCap = ERC223.balanceOf(address(this));
  }

  function setRateContract(address _contract) external onlyOwner {
    RateContract = RateContractI(_contract);
  }

  function setDurations(uint _duration1, uint _duration2, uint _duration3, uint _duration4, uint _duration5) public onlyOwner {
    duration[0] = _duration1;
    duration[1] = _duration2;
    duration[2] = _duration3;
    duration[3] = _duration4;
    duration[4] = _duration5;
  }
}