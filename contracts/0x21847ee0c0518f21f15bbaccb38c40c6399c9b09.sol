pragma solidity 0.4.20;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract GoldMineCoin is StandardToken, Ownable {	
    
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  uint public constant INITIAL_SUPPLY = 2500000000000;

  uint public constant BOUNTY_TOKENS_LIMIT = 125000000000;

  string public constant name = "GoldMineCoin";
   
  string public constant symbol = "GMC";
    
  uint32 public constant decimals = 6;

  uint public bountyTokensTransferred;

  address public saleAgent;
  
  bool public isCrowdsaleFinished;

  uint public remainingLockDate;
  
  mapping(address => uint) public locks;

  modifier notLocked(address from) {
    require(isCrowdsaleFinished || (locks[from] !=0 && now >= locks[from]));
    _;
  }

  function GoldMineCoin() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[this] = totalSupply_;
  }
  
  function addRestricedAccount(address restricedAccount, uint unlockedDate) public {
    require(!isCrowdsaleFinished);    
    require(msg.sender == saleAgent || msg.sender == owner);
    locks[restricedAccount] = unlockedDate;
  }

  function transferFrom(address _from, address _to, uint256 _value) public notLocked(_from) returns (bool) {
    super.transferFrom(_from, _to, _value);
  }

  function transfer(address _to, uint256 _value) public notLocked(msg.sender) returns (bool) {
    super.transfer(_to, _value);
  }

  function crowdsaleTransfer(address to, uint amount) public {
    require(msg.sender == saleAgent || msg.sender == owner);
    require(!isCrowdsaleFinished || now >= remainingLockDate);
    require(amount <= balances[this]);
    balances[this] = balances[this].sub(amount);
    balances[to] = balances[to].add(amount);
    Transfer(this, to, amount);
  }

  function addBountyTransferredTokens(uint amount) public {
    require(!isCrowdsaleFinished);
    require(msg.sender == saleAgent);
    bountyTokensTransferred = bountyTokensTransferred.add(amount);
  }

  function setSaleAgent(address newSaleAgent) public {
    require(!isCrowdsaleFinished);
    require(msg.sender == owner|| msg.sender == saleAgent);
    require(newSaleAgent != address(0));
    saleAgent = newSaleAgent;
  }
  
  function setRemainingLockDate(uint newRemainingLockDate) public {
    require(!isCrowdsaleFinished && msg.sender == saleAgent); 
    remainingLockDate = newRemainingLockDate;
  }

  function finishCrowdsale() public {
    require(msg.sender == saleAgent || msg.sender == owner);
    isCrowdsaleFinished = true;
  }

}

contract CommonCrowdsale is Ownable {

  using SafeMath for uint256;

  uint public price = 75000000;

  uint public constant MIN_INVESTED_ETH = 100000000000000000;

  uint public constant PERCENT_RATE = 100000000;
                                     
  uint public constant BOUNTY_PERCENT = 1666667;

  uint public constant REFERER_PERCENT = 500000;

  address public bountyWallet;

  address public wallet;

  uint public start;

  uint public period;

  uint public tokensSold;
  
  bool isBountyRestriced;

  GoldMineCoin public token;

  modifier saleIsOn() {
    require(now >= start && now < end() && msg.value >= MIN_INVESTED_ETH);
    require(tokensSold < tokensSoldLimit());
    _;
  }
  
  function tokensSoldLimit() public constant returns(uint);

  function end() public constant returns(uint) {
    return start + period * 1 days;
  }

  function setBountyWallet(address newBountyWallet) public onlyOwner {
    bountyWallet = newBountyWallet;
  }

  function setPrice(uint newPrice) public onlyOwner {
    price = newPrice;
  }

  function setToken(address newToken) public onlyOwner {
    token = GoldMineCoin(newToken);
  }

  function setStart(uint newStart) public onlyOwner {
    start = newStart;
  }

  function setPeriod(uint newPeriod) public onlyOwner {
    require(bountyWallet != address(0));
    period = newPeriod;
    if(isBountyRestriced) {
      token.addRestricedAccount(bountyWallet, end());
    }
  }

  function setWallet(address newWallet) public onlyOwner {
    wallet = newWallet;
  }

  function priceWithBonus() public constant returns(uint);
  
  function buyTokens() public payable saleIsOn {

    wallet.transfer(msg.value);

    uint tokens = msg.value.mul(priceWithBonus()).div(1 ether);
    
    token.crowdsaleTransfer(msg.sender, tokens);
    tokensSold = tokensSold.add(tokens);

    // referer tokens
    if(msg.data.length == 20) {
      address referer = bytesToAddres(bytes(msg.data));
      require(referer != address(token) && referer != msg.sender);
      uint refererTokens = tokens.mul(REFERER_PERCENT).div(PERCENT_RATE);
      token.crowdsaleTransfer(referer, refererTokens);
      tokens.add(refererTokens);
      tokensSold = tokensSold.add(refererTokens);
    }

    // bounty tokens
    if(token.bountyTokensTransferred() < token.BOUNTY_TOKENS_LIMIT()) {
      uint bountyTokens = tokens.mul(BOUNTY_PERCENT).div(PERCENT_RATE);
      uint diff = token.BOUNTY_TOKENS_LIMIT().sub(token.bountyTokensTransferred());
      if(bountyTokens > diff) {
        bountyTokens = diff;
      }      
      if(!isBountyRestriced) {
        token.addRestricedAccount(bountyWallet, end());  
        isBountyRestriced = true;
      }
      token.crowdsaleTransfer(bountyWallet, bountyTokens);
    }
  }

  function bytesToAddres(bytes source) internal pure returns(address) {
    uint result;
    uint mul = 1;
    for(uint i = 20; i > 0; i--) {
      result += uint8(source[i-1])*mul;
      mul = mul*256;
    }
    return address(result);
  }

  function retrieveTokens(address anotherToken) public onlyOwner {
    ERC20 alienToken = ERC20(anotherToken);
    alienToken.transfer(wallet, token.balanceOf(this));
  }

  function() external payable {
    buyTokens();
  }

}

contract StaggedCrowdale is CommonCrowdsale {

  uint public constant SALE_STEP = 5000000;

  uint public timeStep = 5 * 1 days;

  function setTimeStep(uint newTimeStep) public onlyOwner {
    timeStep = newTimeStep * 1 days;
  }

  function priceWithBonus() public constant returns(uint) {
    uint saleStage = now.sub(start).div(timeStep);
    uint saleSub = saleStage.mul(SALE_STEP);
    uint minSale = getMinPriceSale();
    uint maxSale = getMaxPriceSale();
    uint priceSale = maxSale;
    if(saleSub >= maxSale.sub(minSale)) {
      priceSale = minSale;
    } else {
      priceSale = maxSale.sub(saleSub);
    }
    return price.mul(PERCENT_RATE).div(PERCENT_RATE.sub(priceSale));
  }
  
  function getMinPriceSale() public constant returns(uint);
  
  function getMaxPriceSale() public constant returns(uint);

}

contract CrowdsaleWithNextSaleAgent is CommonCrowdsale {

  address public nextSaleAgent;

  function setNextSaleAgent(address newNextSaleAgent) public onlyOwner {
    nextSaleAgent = newNextSaleAgent;
  }

  function finishCrowdsale() public onlyOwner { 
    token.setSaleAgent(nextSaleAgent);
  }

}

contract Presale is CrowdsaleWithNextSaleAgent {

  uint public constant PRICE_SALE = 60000000;

  uint public constant TOKENS_SOLD_LIMIT = 125000000000;

  function tokensSoldLimit() public constant returns(uint) {
    return TOKENS_SOLD_LIMIT;
  }
  
  function priceWithBonus() public constant returns(uint) {
    return price.mul(PERCENT_RATE).div(PERCENT_RATE.sub(PRICE_SALE));
  }

}

contract PreICO is StaggedCrowdale, CrowdsaleWithNextSaleAgent {

  uint public constant MAX_PRICE_SALE = 55000000;

  uint public constant MIN_PRICE_SALE = 40000000;

  uint public constant TOKENS_SOLD_LIMIT = 625000000000;

  function tokensSoldLimit() public constant returns(uint) {
    return TOKENS_SOLD_LIMIT;
  }
  
  function getMinPriceSale() public constant returns(uint) {
    return MIN_PRICE_SALE;
  }
  
  function getMaxPriceSale() public constant returns(uint) {
    return MAX_PRICE_SALE;
  }

}

contract ICO is StaggedCrowdale {

  uint public constant MAX_PRICE_SALE = 40000000;

  uint public constant MIN_PRICE_SALE = 20000000;

  uint public constant ESCROW_TOKENS_PERCENT = 5000000;

  uint public constant FOUNDERS_TOKENS_PERCENT = 10000000;

  uint public lockPeriod = 250;

  address public foundersTokensWallet;

  address public escrowTokensWallet;

  uint public constant TOKENS_SOLD_LIMIT = 1250000000000;

  function tokensSoldLimit() public constant returns(uint) {
    return TOKENS_SOLD_LIMIT;
  }

  function setLockPeriod(uint newLockPeriod) public onlyOwner {
    lockPeriod = newLockPeriod;
  }

  function setFoundersTokensWallet(address newFoundersTokensWallet) public onlyOwner {
    foundersTokensWallet = newFoundersTokensWallet;
  }

  function setEscrowTokensWallet(address newEscrowTokensWallet) public onlyOwner {
    escrowTokensWallet = newEscrowTokensWallet;
  }

  function finishCrowdsale() public onlyOwner { 
    uint totalSupply = token.totalSupply();
    uint commonPercent = FOUNDERS_TOKENS_PERCENT + ESCROW_TOKENS_PERCENT;
    uint commonExtraTokens = totalSupply.mul(commonPercent).div(PERCENT_RATE.sub(commonPercent));
    if(commonExtraTokens > token.balanceOf(token)) {
      commonExtraTokens = token.balanceOf(token);
    }
    uint escrowTokens = commonExtraTokens.mul(FOUNDERS_TOKENS_PERCENT).div(PERCENT_RATE);
    token.crowdsaleTransfer(foundersTokensWallet, foundersTokens);

    uint foundersTokens = commonExtraTokens - escrowTokens;
    token.crowdsaleTransfer(escrowTokensWallet, escrowTokens);

    token.setRemainingLockDate(now + lockPeriod * 1 days);
    token.finishCrowdsale();
  }
  
  function getMinPriceSale() public constant returns(uint) {
    return MIN_PRICE_SALE;
  }
  
  function getMaxPriceSale() public constant returns(uint) {
    return MAX_PRICE_SALE;
  }

}

contract Configurator is Ownable {

  GoldMineCoin public token;

  Presale public presale;
  
  PreICO public preICO;
  
  ICO public ico;

  function deploy() public onlyOwner {
    token = new GoldMineCoin();

    presale = new Presale();
    presale.setToken(token);
    token.setSaleAgent(presale);
    
    presale.setBountyWallet(0x6FB77f2878A33ef21aadde868E84Ba66105a3E9c);
    presale.setWallet(0x2d664D31f3AF6aD256A62fdb72E704ab0De42619);
    presale.setStart(1519862400);
    presale.setPeriod(20);

    preICO = new PreICO();
    preICO.setToken(token);
    presale.setNextSaleAgent(preICO);
    
    preICO.setTimeStep(5);
    preICO.setBountyWallet(0x4ca3a7788A61590722A7AAb3b79E8b4DfDDf9559);
    preICO.setWallet(0x2d664D31f3AF6aD256A62fdb72E704ab0De42619);
    preICO.setStart(1521504000);
    preICO.setPeriod(40);
    
    ico = new ICO();
    ico.setToken(token);
    preICO.setNextSaleAgent(ico);
    
    ico.setTimeStep(5);
    ico.setLockPeriod(250);
    ico.setBountyWallet(0x7cfe25bdd334cdB46Ae0c4996E7D34F95DFFfdD1);
    ico.setEscrowTokensWallet(0x24D225818a19c75694FCB35297cA2f23E0bd8F82);
    ico.setFoundersTokensWallet(0x54540fC0e7cCc29d1c93AD7501761d6b232d5b03);
    ico.setWallet(0x2d664D31f3AF6aD256A62fdb72E704ab0De42619);
    ico.setStart(1525132800);
    ico.setPeriod(60);

    token.transferOwnership(0xE8910a2C39Ef0405A9960eC4bD8CBA3211e3C796);
    presale.transferOwnership(0xE8910a2C39Ef0405A9960eC4bD8CBA3211e3C796);
    preICO.transferOwnership(0xE8910a2C39Ef0405A9960eC4bD8CBA3211e3C796);
    ico.transferOwnership(0xE8910a2C39Ef0405A9960eC4bD8CBA3211e3C796);
  }

}