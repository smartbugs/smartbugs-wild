pragma solidity ^0.4.15;

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
  function Ownable() public {
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
      OwnershipTransferred(owner, newOwner);
      owner = newOwner;
    }
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {

  function sub(uint256 x, uint256 y) internal constant returns (uint256) {
    uint256 z = x - y;
    assert(z <= x);
	  return z;
  }

  function add(uint256 x, uint256 y) internal constant returns (uint256) {
    uint256 z = x + y;
	  assert(z >= x);
	  return z;
  }
	
  function div(uint256 x, uint256 y) internal constant returns (uint256) {
    uint256 z = x / y;
    return z;
  }
	
  function mul(uint256 x, uint256 y) internal constant returns (uint256) {
    uint256 z = x * y;
    assert(x == 0 || z / x == y);
    return z;
  }

  function min(uint256 x, uint256 y) internal constant returns (uint256) {
    uint256 z = x <= y ? x : y;
    return z;
  }

  function max(uint256 x, uint256 y) internal constant returns (uint256) {
    uint256 z = x >= y ? x : y;
    return z;
  }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
	function totalSupply() public constant returns (uint);
	function balanceOf(address owner) public constant returns (uint);
	function allowance(address owner, address spender) public constant returns (uint);
	function transfer(address to, uint value) public returns (bool success);
	function transferFrom(address from, address to, uint value) public returns (bool success);
	function approve(address spender, uint value) public returns (bool success);
	function mint(address to, uint value) public returns (bool success);
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
}


/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, SafeMath, Ownable{
	
  uint256 _totalSupply;
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) approvals;
  address public crowdsaleAgent;
  bool public released = false;  
  
  /**
   * @dev Fix for the ERC20 short address attack http://vessenes.com/the-erc20-short-address-attack-explained/
   * @param numwords payload size  
   */
  modifier onlyPayloadSize(uint numwords) {
    assert(msg.data.length == numwords * 32 + 4);
    _;
  }
  
  /**
   * @dev The function can be called only by crowdsale agent.
   */
  modifier onlyCrowdsaleAgent() {
    assert(msg.sender == crowdsaleAgent);
    _;
  }

  /** Limit token mint after finishing crowdsale
   * @dev Make sure we are not done yet.
   */
  modifier canMint() {
    assert(!released);
    _;
  }
  
  /**
   * @dev Limit token transfer until the crowdsale is over.
   */
  modifier canTransfer() {
    assert(released);
    _;
  } 
  
  /** 
   * @dev Total Supply
   * @return _totalSupply 
   */  
  function totalSupply() public constant returns (uint256) {
    return _totalSupply;
  }
  
  /** 
   * @dev Tokens balance
   * @param _owner holder address
   * @return balance amount 
   */
  function balanceOf(address _owner) public constant returns (uint256) {
    return balances[_owner];
  }
  
  /** 
   * @dev Token allowance
   * @param _owner holder address
   * @param _spender spender address
   * @return remain amount
   */   
  function allowance(address _owner, address _spender) public constant returns (uint256) {
    return approvals[_owner][_spender];
  }

  /** 
   * @dev Tranfer tokens to address
   * @param _to dest address
   * @param _value tokens amount
   * @return transfer result
   */   
  function transfer(address _to, uint _value) public canTransfer onlyPayloadSize(2) returns (bool success) {
    assert(balances[msg.sender] >= _value);
    balances[msg.sender] = sub(balances[msg.sender], _value);
    balances[_to] = add(balances[_to], _value);
    
    Transfer(msg.sender, _to, _value);
    return true;
  }
  
  /**    
   * @dev Tranfer tokens from one address to other
   * @param _from source address
   * @param _to dest address
   * @param _value tokens amount
   * @return transfer result
   */    
  function transferFrom(address _from, address _to, uint _value) public canTransfer onlyPayloadSize(3) returns (bool success) {
    assert(balances[_from] >= _value);
    assert(approvals[_from][msg.sender] >= _value);
    approvals[_from][msg.sender] = sub(approvals[_from][msg.sender], _value);
    balances[_from] = sub(balances[_from], _value);
    balances[_to] = add(balances[_to], _value);
    
    Transfer(_from, _to, _value);
    return true;
  }
  
  /** 
   * @dev Approve transfer
   * @param _spender holder address
   * @param _value tokens amount
   * @return result  
   */
  function approve(address _spender, uint _value) public onlyPayloadSize(2) returns (bool success) {
    // To change the approve amount you first have to reduce the addresses`
    //  approvals to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    assert((_value == 0) || (approvals[msg.sender][_spender] == 0));
    approvals[msg.sender][_spender] = _value;
    
    Approval(msg.sender, _spender, _value);
    return true;
  }
  
  /** 
   * @dev Create new tokens and allocate them to an address. Only callably by a crowdsale contract
   * @param _to dest address
   * @param _value tokens amount
   * @return mint result
   */ 
  function mint(address _to, uint _value) public onlyCrowdsaleAgent canMint onlyPayloadSize(2) returns (bool success) {
    _totalSupply = add(_totalSupply, _value);
    balances[_to] = add(balances[_to], _value);
    
    Transfer(0, _to, _value);
    return true;
	
  }
  
  /**
   * @dev Set the contract that can call release and make the token transferable.
   * @param _crowdsaleAgent crowdsale contract address
   */
  function setCrowdsaleAgent(address _crowdsaleAgent) public onlyOwner {
    assert(!released);
    crowdsaleAgent = _crowdsaleAgent;
  }
  
  /**
   * @dev One way function to release the tokens to the wild. Can be called only from the release agent that is the final ICO contract. 
   */
  function releaseTokenTransfer() public onlyCrowdsaleAgent {
    released = true;
  }

}

/** 
 * @title DAOPlayMarket2.0 contract - standard ERC20 token with Short Hand Attack and approve() race condition mitigation.
 */
contract DAOPlayMarketToken is StandardToken {
  
  string public name;
  string public symbol;
  uint public decimals;
  
  /** Name and symbol were updated. */
  event UpdatedTokenInformation(string newName, string newSymbol);

  /**
   * Construct the token.
   *
   * This token must be created through a team multisig wallet, so that it is owned by that wallet.
   *
   * @param _name Token name
   * @param _symbol Token symbol - should be all caps
   * @param _initialSupply How many tokens we start with
   * @param _decimals Number of decimal places
   * @param _addr Address for team's tokens
   */
   
  function DAOPlayMarketToken(string _name, string _symbol, uint _initialSupply, uint _decimals, address _addr) public {
    require(_addr != 0x0);
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
	
    _totalSupply = _initialSupply*10**_decimals;

    // Creating initial tokens
    balances[_addr] = _totalSupply;
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

    UpdatedTokenInformation(name, symbol);
  }

}


/**
 * @title Haltable
 * @dev Abstract contract that allows children to implement an
 * emergency stop mechanism. Differs from Pausable by causing a throw when in halt mode.
 */
contract Haltable is Ownable {
  bool public halted;

  modifier stopInEmergency {
    assert(!halted);
    _;
  }

  modifier onlyInEmergency {
    assert(halted);
    _;
  }

  /**
   *@dev Called by the owner on emergency, triggers stopped state
   */
  function halt() external onlyOwner {
    halted = true;
  }

  /**
   * @dev Called by the owner on end of emergency, returns to normal state
   */
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }
}


/** 
 * @title Killable DAOPlayMarketTokenCrowdsale contract
 */
contract Killable is Ownable {
  function kill() onlyOwner {
    selfdestruct(owner);
  }
}

/** 
 * @title DAOPlayMarketTokenCrowdsale contract - contract for token sales.
 */
contract DAOPlayMarketTokenCrowdsale is Haltable, SafeMath, Killable {
  
  /* The token we are selling */
  DAOPlayMarketToken public token;

  /* tokens will be transfered from this address */
  address public multisigWallet;

  /* the UNIX timestamp start date of the crowdsale */
  uint public startsAt;
  
  /* the UNIX timestamp end date of the crowdsale */
  uint public endsAt;
  
  /* the number of tokens already sold through this contract*/
  uint public tokensSold = 0;
  
  /* How many wei of funding we have raised */
  uint public weiRaised = 0;
  
  /* How many unique addresses that have invested */
  uint public investorCount = 0;
  
  /* Has this crowdsale been finalized */
  bool public finalized;
  
  /* Cap of tokens */
  uint public CAP;
  
  /* How much ETH each address has invested to this crowdsale */
  mapping (address => uint256) public investedAmountOf;
  
  /* How much tokens this crowdsale has credited for each investor address */
  mapping (address => uint256) public tokenAmountOf;
  
  /* Contract address that can call invest other crypto */
  address public cryptoAgent;
  
  /** How many tokens he charged for each investor's address in a particular period */
  mapping (uint => mapping (address => uint256)) public tokenAmountOfPeriod;
  
  struct Stage {
    // UNIX timestamp when the stage begins
    uint start;
    // UNIX timestamp when the stage is over
    uint end;
    // Number of period
    uint period;
    // Price#1 token in WEI
    uint price1;
    // Price#2 token in WEI
    uint price2;
    // Price#3 token in WEI
    uint price3;
    // Price#4 token in WEI
    uint price4;
    // Cap of period
    uint cap;
    // Token sold in period
    uint tokenSold;
  }
  
  /** Stages **/
  Stage[] public stages;
  uint public periodStage;
  uint public stage;
  
  /** State machine
   *
   * - Preparing: All contract initialization calls and variables have not been set yet
   * - Funding: Active crowdsale
   * - Success: Minimum funding goal reached
   * - Failure: Minimum funding goal not reached before ending time
   * - Finalized: The finalized has been called and succesfully executed
   */
  enum State{Unknown, Preparing, Funding, Success, Failure, Finalized}
  
  // A new investment was made
  event Invested(address investor, uint weiAmount, uint tokenAmount);
  
  // A new investment was made
  event InvestedOtherCrypto(address investor, uint weiAmount, uint tokenAmount);

  // Crowdsale end time has been changed
  event EndsAtChanged(uint _endsAt);
  
  // New distributions were made
  event DistributedTokens(address investor, uint tokenAmount);
  
  /** 
   * @dev Modified allowing execution only if the crowdsale is currently running
   */
  modifier inState(State state) {
    require(getState() == state);
    _;
  }
  
  /**
   * @dev The function can be called only by crowdsale agent.
   */
  modifier onlyCryptoAgent() {
    assert(msg.sender == cryptoAgent);
    _;
  }
  
  /**
   * @dev Constructor
   * @param _token DAOPlayMarketToken token address
   * @param _multisigWallet team wallet
   * @param _start token ICO start date
   * @param _cap token ICO 
   * @param _price array of price 
   * @param _periodStage period of stage
   * @param _capPeriod cap of period
   */
  function DAOPlayMarketTokenCrowdsale(address _token, address _multisigWallet, uint _start, uint _cap, uint[20] _price, uint _periodStage, uint _capPeriod) public {
  
    require(_multisigWallet != 0x0);
    require(_start >= block.timestamp);
    require(_cap > 0);
    require(_periodStage > 0);
    require(_capPeriod > 0);
	
    token = DAOPlayMarketToken(_token);
    multisigWallet = _multisigWallet;
    startsAt = _start;
    CAP = _cap*10**token.decimals();
	
    periodStage = _periodStage*1 days;
    uint capPeriod = _capPeriod*10**token.decimals();
    uint j = 0;
    for(uint i=0; i<_price.length; i=i+4) {
      stages.push(Stage(startsAt+j*periodStage, startsAt+(j+1)*periodStage, j, _price[i], _price[i+1], _price[i+2], _price[i+3], capPeriod, 0));
      j++;
    }
    endsAt = stages[stages.length-1].end;
    stage = 0;
  }
  
  /**
   * Buy tokens from the contract
   */
  function() public payable {
    investInternal(msg.sender);
  }

  /**
   * Make an investment.
   *
   * Crowdsale must be running for one to invest.
   * We must have not pressed the emergency brake.
   *
   * @param receiver The Ethereum address who receives the tokens
   *
   */
  function investInternal(address receiver) private stopInEmergency {
    require(msg.value > 0);
	
    assert(getState() == State.Funding);

    // Determine in what period we hit
    stage = getStage();
	
    uint weiAmount = msg.value;

    // Account presale sales separately, so that they do not count against pricing tranches
    uint tokenAmount = calculateToken(weiAmount, stage, token.decimals());

    assert(tokenAmount > 0);

	// Check that we did not bust the cap in the period
    assert(stages[stage].cap >= add(tokenAmount, stages[stage].tokenSold));
	
    tokenAmountOfPeriod[stage][receiver]=add(tokenAmountOfPeriod[stage][receiver],tokenAmount);
	
    stages[stage].tokenSold = add(stages[stage].tokenSold,tokenAmount);
	
    if (stages[stage].cap == stages[stage].tokenSold){
      updateStage(stage);
      endsAt = stages[stages.length-1].end;
    }
	
	// Check that we did not bust the cap
    //assert(!isBreakingCap(tokenAmount, tokensSold));
	
    if(investedAmountOf[receiver] == 0) {
       // A new investor
       investorCount++;
    }

    // Update investor
    investedAmountOf[receiver] = add(investedAmountOf[receiver],weiAmount);
    tokenAmountOf[receiver] = add(tokenAmountOf[receiver],tokenAmount);

    // Update totals
    weiRaised = add(weiRaised,weiAmount);
    tokensSold = add(tokensSold,tokenAmount);

    assignTokens(receiver, tokenAmount);

    // send ether to the fund collection wallet
    multisigWallet.transfer(weiAmount);

    // Tell us invest was success
    Invested(receiver, weiAmount, tokenAmount);
	
  }
  
  /**
   * Make an investment.
   *
   * Crowdsale must be running for one to invest.
   * We must have not pressed the emergency brake.
   *
   * @param receiver The Ethereum address who receives the tokens
   * @param _weiAmount amount in Eth
   *
   */
  function investOtherCrypto(address receiver, uint _weiAmount) public onlyCryptoAgent stopInEmergency {
    require(_weiAmount > 0);
	
    assert(getState() == State.Funding);

    // Determine in what period we hit
    stage = getStage();
	
    uint weiAmount = _weiAmount;

    // Account presale sales separately, so that they do not count against pricing tranches
    uint tokenAmount = calculateToken(weiAmount, stage, token.decimals());

    assert(tokenAmount > 0);

	// Check that we did not bust the cap in the period
    assert(stages[stage].cap >= add(tokenAmount, stages[stage].tokenSold));
	
    tokenAmountOfPeriod[stage][receiver]=add(tokenAmountOfPeriod[stage][receiver],tokenAmount);
	
    stages[stage].tokenSold = add(stages[stage].tokenSold,tokenAmount);
	
    if (stages[stage].cap == stages[stage].tokenSold){
      updateStage(stage);
      endsAt = stages[stages.length-1].end;
    }
	
	// Check that we did not bust the cap
    //assert(!isBreakingCap(tokenAmount, tokensSold));
	
    if(investedAmountOf[receiver] == 0) {
       // A new investor
       investorCount++;
    }

    // Update investor
    investedAmountOf[receiver] = add(investedAmountOf[receiver],weiAmount);
    tokenAmountOf[receiver] = add(tokenAmountOf[receiver],tokenAmount);

    // Update totals
    weiRaised = add(weiRaised,weiAmount);
    tokensSold = add(tokensSold,tokenAmount);

    assignTokens(receiver, tokenAmount);
	
    // Tell us invest was success
    InvestedOtherCrypto(receiver, weiAmount, tokenAmount);
  }
  
  /**
   * Create new tokens or transfer issued tokens to the investor depending on the cap model.
   */
  function assignTokens(address receiver, uint tokenAmount) private {
     token.mint(receiver, tokenAmount);
  }
   
  /**
   * Check if the current invested breaks our cap rules.
   *
   * Called from invest().
   *
   * @param tokenAmount The amount of tokens we try to give to the investor in the current transaction
   * @param tokensSoldTotal What would be our total sold tokens count after this transaction
   *
   * @return true if taking this investment would break our cap rules
   */
  function isBreakingCap(uint tokenAmount, uint tokensSoldTotal) public constant returns (bool limitBroken){
	if(add(tokenAmount,tokensSoldTotal) <= CAP){
	  return false;
	}
	return true;
  }

  /**
   * @dev Distribution of remaining tokens.
   */
  function distributionOfTokens() public stopInEmergency {
    require(block.timestamp >= endsAt);
    require(!finalized);
    uint amount;
    for(uint i=0; i<stages.length; i++) {
      if(tokenAmountOfPeriod[stages[i].period][msg.sender] != 0){
        amount = add(amount,div(mul(sub(stages[i].cap,stages[i].tokenSold),tokenAmountOfPeriod[stages[i].period][msg.sender]),stages[i].tokenSold));
        tokenAmountOfPeriod[stages[i].period][msg.sender] = 0;
      }
    }
    assert(amount > 0);
    assignTokens(msg.sender, amount);
	
    // Tell us distributed was success
    DistributedTokens(msg.sender, amount);
  }
  
  /**
   * @dev Finalize a succcesful crowdsale.
   */
  function finalize() public inState(State.Success) onlyOwner stopInEmergency {
    require(block.timestamp >= (endsAt+periodStage));
    require(!finalized);
	
    finalizeCrowdsale();
    finalized = true;
  }
  
  /**
   * @dev Finalize a succcesful crowdsale.
   */
  function finalizeCrowdsale() internal {
    token.releaseTokenTransfer();
  }
  
  /**
   * @dev Check if the ICO goal was reached.
   * @return true if the crowdsale has raised enough money to be a success
   */
  function isCrowdsaleFull() public constant returns (bool) {
    if(tokensSold >= CAP || block.timestamp >= endsAt){
      return true;  
    }
    return false;
  }
  
  /** 
   * @dev Allow crowdsale owner to close early or extend the crowdsale.
   * @param time timestamp
   */
  function setEndsAt(uint time) public onlyOwner {
    require(!finalized);
    require(time >= block.timestamp);
    endsAt = time;
    EndsAtChanged(endsAt);
  }
  
   /**
   * @dev Allow to change the team multisig address in the case of emergency.
   */
  function setMultisig(address addr) public onlyOwner {
    require(addr != 0x0);
    multisigWallet = addr;
  }
  
  /**
   * @dev Allow crowdsale owner to change the token address.
   */
  function setToken(address addr) public onlyOwner {
    require(addr != 0x0);
    token = DAOPlayMarketToken(addr);
  }
  
  /** 
   * @dev Crowdfund state machine management.
   * @return State current state
   */
  function getState() public constant returns (State) {
    if (finalized) return State.Finalized;
    else if (address(token) == 0 || address(multisigWallet) == 0 || block.timestamp < startsAt) return State.Preparing;
    else if (block.timestamp <= endsAt && block.timestamp >= startsAt && !isCrowdsaleFull()) return State.Funding;
    else if (isCrowdsaleFull()) return State.Success;
    else return State.Failure;
  }
  
  /** 
   * @dev Set base price for ICO.
   */
  function setBasePrice(uint[20] _price, uint _startDate, uint _periodStage, uint _cap, uint _decimals) public onlyOwner {
    periodStage = _periodStage*1 days;
    uint cap = _cap*10**_decimals;
    uint j = 0;
    delete stages;
    for(uint i=0; i<_price.length; i=i+4) {
      stages.push(Stage(_startDate+j*periodStage, _startDate+(j+1)*periodStage, j, _price[i], _price[i+1], _price[i+2], _price[i+3], cap, 0));
      j++;
    }
    endsAt = stages[stages.length-1].end;
    stage =0;
  }
  
  /** 
   * @dev Updates the ICO steps if the cap is reached.
   */
  function updateStage(uint number) private {
    require(number>=0);
    uint time = block.timestamp;
    uint j = 0;
    stages[number].end = time;
    for (uint i = number+1; i < stages.length; i++) {
      stages[i].start = time+periodStage*j;
      stages[i].end = time+periodStage*(j+1);
      j++;
    }
  }
  
  /** 
   * @dev Gets the current stage.
   * @return uint current stage
   */
  function getStage() private constant returns (uint){
    for (uint i = 0; i < stages.length; i++) {
      if (block.timestamp >= stages[i].start && block.timestamp < stages[i].end) {
        return stages[i].period;
      }
    }
    return stages[stages.length-1].period;
  }
  
  /** 
   * @dev Gets the cap of amount.
   * @return uint cap of amount
   */
  function getAmountCap(uint value) private constant returns (uint ) {
    if(value <= 10*10**18){
      return 0;
    }else if (value <= 50*10**18){
      return 1;
    }else if (value <= 300*10**18){
      return 2;
    }else {
      return 3;
    }
  }
  
  /**
   * When somebody tries to buy tokens for X eth, calculate how many tokens they get.
   * @param value - The value of the transaction send in as wei
   * @param _stage - The stage of ICO
   * @param decimals - How many decimal places the token has
   * @return Amount of tokens the investor receives
   */
   
  function calculateToken(uint value, uint _stage, uint decimals) private constant returns (uint){
    uint tokenAmount = 0;
    uint saleAmountCap = getAmountCap(value); 
	
    if(saleAmountCap == 0){
      tokenAmount = div(value*10**decimals,stages[_stage].price1);
    }else if(saleAmountCap == 1){
      tokenAmount = div(value*10**decimals,stages[_stage].price2);
    }else if(saleAmountCap == 2){
      tokenAmount = div(value*10**decimals,stages[_stage].price3);
    }else{
      tokenAmount = div(value*10**decimals,stages[_stage].price4);
    }
    return tokenAmount;
  }
 
  /**
   * @dev Set the contract that can call the invest other crypto function.
   * @param _cryptoAgent crowdsale contract address
   */
  function setCryptoAgent(address _cryptoAgent) public onlyOwner {
    require(!finalized);
    cryptoAgent = _cryptoAgent;
  }
}