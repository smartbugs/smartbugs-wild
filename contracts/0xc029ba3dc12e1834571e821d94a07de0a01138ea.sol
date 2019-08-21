pragma solidity ^0.4.15;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    
  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
    
  event Mint(address indexed to, uint256 amount);
  
  event MintFinished();

  bool public mintingFinished = false;

  address public saleAgent;

  function setSaleAgent(address newSaleAgnet) {
    require(msg.sender == saleAgent || msg.sender == owner);
    saleAgent = newSaleAgnet;
  }

  function mint(address _to, uint256 _amount) returns (bool) {
    require(msg.sender == saleAgent && !mintingFinished);
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() returns (bool) {
    require((msg.sender == saleAgent || msg.sender == owner) && !mintingFinished);
    mintingFinished = true;
    MintFinished();
    return true;
  }

  
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    
  event Pause();
  
  event Unpause();

  bool public paused = false;

  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused {
    paused = false;
    Unpause();
  }
  
}

contract QBEToken is MintableToken {	
    
  string public constant name = "Qubicle";
   
  string public constant symbol = "QBE";
    
  uint32 public constant decimals = 18;

  mapping (address => uint) public locked;

  function transfer(address _to, uint256 _value) returns (bool) {
    require(locked[msg.sender] < now);
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(locked[_from] < now);
    return super.transferFrom(_from, _to, _value);
  }
  
  function lock(address addr, uint periodInDays) {
    require(locked[addr] < now && (msg.sender == saleAgent || msg.sender == addr));
    locked[addr] = now + periodInDays * 1 days;
  }

  function () payable {
    revert();
  }

}

contract StagedCrowdsale is Pausable {

  using SafeMath for uint;

  struct Stage {
    uint hardcap;
    uint price;
    uint invested;
    uint closed;
  }

  uint public start;

  uint public period;

  uint public totalHardcap;
 
  uint public totalInvested;

  Stage[] public stages;

  function stagesCount() public constant returns(uint) {
    return stages.length;
  }

  function setStart(uint newStart) public onlyOwner {
    start = newStart;
  }

  function setPeriod(uint newPeriod) public onlyOwner {
    period = newPeriod;
  }

  function addStage(uint hardcap, uint price) public onlyOwner {
    require(hardcap > 0 && price > 0);
    Stage memory stage = Stage(hardcap.mul(1 ether), price, 0, 0);
    stages.push(stage);
    totalHardcap = totalHardcap.add(stage.hardcap);
  }

  function removeStage(uint8 number) public onlyOwner {
    require(number >= 0 && number < stages.length);
    Stage storage stage = stages[number];
    totalHardcap = totalHardcap.sub(stage.hardcap);    
    delete stages[number];
    for (uint i = number; i < stages.length - 1; i++) {
      stages[i] = stages[i+1];
    }
    stages.length--;
  }
 
  function changeStage(uint8 number, uint hardcap, uint price) public onlyOwner {
    require(number >= 0 && number < stages.length);
    Stage storage stage = stages[number];
    totalHardcap = totalHardcap.sub(stage.hardcap);    
    stage.hardcap = hardcap.mul(1 ether);
    stage.price = price;
    totalHardcap = totalHardcap.add(stage.hardcap);    
  }

  function insertStage(uint8 numberAfter, uint hardcap, uint price) public onlyOwner {
    require(numberAfter < stages.length);
    Stage memory stage = Stage(hardcap.mul(1 ether), price, 0, 0);
    totalHardcap = totalHardcap.add(stage.hardcap);
    stages.length++;
    for (uint i = stages.length - 2; i > numberAfter; i--) {
      stages[i + 1] = stages[i];
    }
    stages[numberAfter + 1] = stage;
  }

  function clearStages() public onlyOwner {
    for (uint i = 0; i < stages.length; i++) {
      delete stages[i];
    }
    stages.length -= stages.length;
    totalHardcap = 0;
  }

  function lastSaleDate() public constant returns(uint) {
    return start + period * 1 days;
  }

  modifier saleIsOn() {
    require(stages.length > 0 && now >= start && now < lastSaleDate());
    _;
  }
  
  modifier isUnderHardcap() {
    require(totalInvested <= totalHardcap);
    _;
  }

  function currentStage() public saleIsOn isUnderHardcap constant returns(uint) {
    for (uint i = 0; i < stages.length; i++) {
      if (stages[i].closed == 0) {
        return i;
      }
    }
    revert();
  }

}

contract CommonSale is StagedCrowdsale {

  address public multisigWallet;

  uint public minPrice;

  uint public totalTokensMinted;

  QBEToken public token;
  
  function setMinPrice(uint newMinPrice) public onlyOwner {
    minPrice = newMinPrice;
  }

  function setMultisigWallet(address newMultisigWallet) public onlyOwner {
    multisigWallet = newMultisigWallet;
  }
  
  function setToken(address newToken) public onlyOwner {
    token = QBEToken(newToken);
  }

  function createTokens() public whenNotPaused payable {
    require(msg.value >= minPrice);
    uint stageIndex = currentStage(); // should check if current stage returned a valid stage
    multisigWallet.transfer(msg.value);
    Stage storage stage = stages[stageIndex];
    uint tokens = msg.value.mul(stage.price);
    token.mint(this, tokens);
    token.transfer(msg.sender, tokens);
    totalTokensMinted = totalTokensMinted.add(tokens);
    totalInvested = totalInvested.add(msg.value);
    stage.invested = stage.invested.add(msg.value);
    if (stage.invested >= stage.hardcap) {
      stage.closed = now;
    }
  }

  function() external payable {
    createTokens();
  }

  function retrieveTokens(address anotherToken) public onlyOwner {
    ERC20 alienToken = ERC20(anotherToken);
    alienToken.transfer(multisigWallet, token.balanceOf(this));
  }

}

contract Presale is CommonSale {

  Mainsale public mainsale;

  function setMainsale(address newMainsale) public onlyOwner {
    mainsale = Mainsale(newMainsale);
  }

  function setMultisigWallet(address newMultisigWallet) public onlyOwner {
    multisigWallet = newMultisigWallet;
  }

  function finishMinting() public whenNotPaused onlyOwner {
    token.setSaleAgent(mainsale);
  }

  function() external payable {
    createTokens();
  }

  function retrieveTokens(address anotherToken) public onlyOwner {
    ERC20 alienToken = ERC20(anotherToken);
    alienToken.transfer(multisigWallet, token.balanceOf(this));
  }

}


contract Mainsale is CommonSale {

  address public foundersTokensWallet;
  
  address public bountyTokensWallet;

  address public unsoldTokensWallet;
  
  uint public foundersTokensReserve;
  
  uint public bountyTokensReserve;

  uint public maxTokenSupply;
  
  uint public lockPeriod;

  function setLockPeriod(uint newLockPeriod) public onlyOwner {
    lockPeriod = newLockPeriod;
  }

  function setFoundersTokensReserve(uint newFoundersTokensReserve) public onlyOwner {
    foundersTokensReserve = newFoundersTokensReserve;
  }

  function setBountyTokensReserve(uint newBountyTokensReserve) public onlyOwner {
    bountyTokensReserve = newBountyTokensReserve;
  }

  function setMaxTokenSupply(uint newMaxTokenSupply) public onlyOwner {
    maxTokenSupply = newMaxTokenSupply;
  }

  function setFoundersTokensWallet(address newFoundersTokensWallet) public onlyOwner {
    foundersTokensWallet = newFoundersTokensWallet;
  }

  function setBountyTokensWallet(address newBountyTokensWallet) public onlyOwner {
    bountyTokensWallet = newBountyTokensWallet;
  }

  function setUnsoldTokensWallet(address newUnsoldTokensWallet) public onlyOwner {
    unsoldTokensWallet = newUnsoldTokensWallet;
  }
  
  function finishMinting() public whenNotPaused onlyOwner {
    token.mint(this, foundersTokensReserve);
    token.lock(foundersTokensWallet, lockPeriod * 1 days);
    token.transfer(foundersTokensWallet, foundersTokensReserve);
    token.mint(this, bountyTokensReserve);
    token.transfer(bountyTokensWallet, bountyTokensReserve);
    totalTokensMinted = totalTokensMinted.add(foundersTokensReserve).add(bountyTokensReserve);

    uint totalUnsoldTokens = maxTokenSupply.sub(totalTokensMinted);
    if (totalUnsoldTokens > 0){
      token.mint(this, totalUnsoldTokens);
      token.transfer(unsoldTokensWallet, totalUnsoldTokens);
    }
    
    token.finishMinting();
  }

}

contract TestConfigurator is Ownable {

  QBEToken public token; 

  Presale public presale;

  Mainsale public mainsale;

  function deploy() public onlyOwner {
    token = new QBEToken();

    presale = new Presale();

    presale.setToken(token);
    presale.addStage(10,3000);
    presale.setMultisigWallet(0x4c076e99d9E8cFC647E1807D89506189d4256Ee1);
    presale.setStart(1509393730);
    presale.setPeriod(1);
    presale.setMinPrice(100000000000000000);
    token.setSaleAgent(presale);	

    mainsale = new Mainsale();

    mainsale.setToken(token);
    mainsale.addStage(100,1500);
    mainsale.setMultisigWallet(0xf32737F7779cA2D20c017Da8F51b2DF99F86A221);
    mainsale.setFoundersTokensWallet(0x5b819179C8Ba84FB4a517Dd566cb09Ff4b8a277f);
    mainsale.setBountyTokensWallet(0x7D2b00C23aDab97152aaB6588A50FcEdCEbD58e4);
    mainsale.setUnsoldTokensWallet(0xAE5e64280eD777c6D2bb8EddfeF2394A21f147DD);
    mainsale.setStart(1509393800);
    mainsale.setPeriod(1);
    mainsale.setLockPeriod(1);
    mainsale.setMinPrice(100000000000000000);
    mainsale.setFoundersTokensReserve(20 * (10**6) * 10**18);
    mainsale.setBountyTokensReserve(10 * (10**6) * 10**18);
    mainsale.setMaxTokenSupply(100 * (10**6) * 10**18);

    presale.setMainsale(mainsale);

    token.transferOwnership(owner);
    presale.transferOwnership(owner);
    mainsale.transferOwnership(owner);
  }

}

contract Configurator is Ownable {

  QBEToken public token; 

  Presale public presale;

  Mainsale public mainsale;

  function deploy() public onlyOwner {
    token = new QBEToken();

    presale = new Presale();

    presale.setToken(token);
    presale.addStage(6000,3000);
    presale.setMultisigWallet(0x17FB4A3ff095F445287AA6F3Ab699a3DCaE3DC56);
    presale.setStart(1510128000);
    presale.setPeriod(31);
    presale.setMinPrice(100000000000000000);
    token.setSaleAgent(presale);	

    mainsale = new Mainsale();

    mainsale.setToken(token);
    mainsale.addStage(45000,1500);
    mainsale.setMultisigWallet(0xdfF07F415E00a338205A8E21C39eC007eb37F746);
    mainsale.setFoundersTokensWallet(0x7bfC9AdaF3D07adC4a1d3D03cde6581100845540);
    mainsale.setBountyTokensWallet(0xce8d83BA3cDD4E7447339936643861478F8037AD);
    mainsale.setUnsoldTokensWallet(0xd88a0920Dc4A044A95874f4Bd4858Fb013511290);
    mainsale.setStart(1514764800);
    mainsale.setPeriod(60);
    mainsale.setLockPeriod(90);
    mainsale.setMinPrice(100000000000000000);
    mainsale.setFoundersTokensReserve(20 * (10**6) * 10**18);
    mainsale.setBountyTokensReserve(10 * (10**6) * 10**18);
    mainsale.setMaxTokenSupply(100 * (10**6) * 10**18);

    presale.setMainsale(mainsale);

    token.transferOwnership(owner);
    presale.transferOwnership(owner);
    mainsale.transferOwnership(owner);
  }
}