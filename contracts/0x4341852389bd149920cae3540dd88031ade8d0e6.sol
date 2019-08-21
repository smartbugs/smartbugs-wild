pragma solidity ^0.4.18;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function () public payable {
    revert();
  }

}

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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
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


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract MilkCoinToken is MintableToken {	
 
  event Burn(address indexed burner, uint256 value);

  uint public constant PERCENT_RATE = 100;

  uint public constant BUY_BACK_BONUS = 20;
   
  string public constant name = "Milkcoin";
   
  string public constant symbol = "MLCN";
    
  uint8 public constant decimals = 2;

  uint public invested;

  uint public tokensAfterCrowdsale;

  uint public startBuyBackDate;

  uint public endBuyBackDate;

  uint public toBuyBack;

  bool public dividendsCalculated;

  uint public dividendsIndex;

  uint public dividendsPayedIndex;
      
  bool public dividendsPayed;

  uint public ethToDividendsNeeds;

  uint public buyBackInvestedValue;

  address[] public addresses;

  mapping(address => bool) public savedAddresses;

  mapping(address => uint) public dividends;

  mapping(address => bool) public lockAddresses;

  function addAddress(address addr) internal {
    if(!savedAddresses[addr]) {
       savedAddresses[addr] = true;
       addresses.push(addr); 
    }
  }

  function countOfAddresses() public constant returns(uint) {
    return addresses.length;
  }

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    bool result = super.mint(_to, _amount);
    if(result) {
      addAddress(_to);
    }
    return result;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    return postProcessTransfer(super.transfer(_to, _value), msg.sender, _to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    return postProcessTransfer(super.transferFrom(_from, _to, _value), _from, _to, _value);
  }

  function postProcessTransfer(bool result, address _from, address _to, uint256 _value) internal returns (bool) {
    if(result) {
      if(_to == address(this)) {
        buyBack(_from, _value);
      } else { 
        addAddress(_to);
      }
    }
    return result;
  }

  function buyBack(address from, uint amount) internal {
    if(now > endBuyBackDate) {
      startBuyBackDate = endBuyBackDate;
      endBuyBackDate = startBuyBackDate + 1 years;      
      toBuyBack = tokensAfterCrowdsale.div(10);
    }
    require(now > startBuyBackDate && now < endBuyBackDate && amount <= toBuyBack); 
    balances[this] = balances[this].sub(amount);
    totalSupply = totalSupply.sub(amount);
    Burn(this, amount);
    toBuyBack = toBuyBack.sub(amount);
    uint valueInWei = amount.mul(buyBackInvestedValue).mul(PERCENT_RATE.add(BUY_BACK_BONUS)).div(PERCENT_RATE).div(totalSupply);
    buyBackInvestedValue = buyBackInvestedValue.sub(amount.mul(buyBackInvestedValue).div(totalSupply));
    from.transfer(valueInWei);
  }

  function retrieveTokens(address anotherToken) public onlyOwner {
    require(anotherToken != address(this));
    ERC20 alienToken = ERC20(anotherToken);
    alienToken.transfer(owner, alienToken.balanceOf(this));
  }

  function finishMinting(uint newInvested) onlyOwner public returns (bool) {
    invested = newInvested;
    buyBackInvestedValue = newInvested;
    tokensAfterCrowdsale = totalSupply;    
    startBuyBackDate = 1609459200;
    endBuyBackDate = startBuyBackDate + 365 * 1 days;      
    toBuyBack = tokensAfterCrowdsale.div(10);
    return super.finishMinting();
  }

  function lockAddress(address toLock) public onlyOwner {
    lockAddresses[toLock] = true;
  }

  function unlockAddress(address toLock) public onlyOwner {
    lockAddresses[toLock] = false;
  }

  // should use when payDividends is under re-entrance freeze
  function payDividendsManually() public {
    require(dividends[msg.sender] > 0);
    uint dividendsValue = dividends[msg.sender];
    dividends[msg.sender] = 0;
    ethToDividendsNeeds = ethToDividendsNeeds.sub(dividendsValue);
    msg.sender.transfer(dividendsValue);
  }

  // should use when payDividends is under re-entrance freeze
  function resetDividendsCalculation() public onlyOwner {
    dividendsCalculated = false;
    dividendsPayed = false;
  }

  // re-entrance attack can freeze all dividends calculation
  function payDividends(uint count) public onlyOwner {
    require(!dividendsPayed && dividendsCalculated);
    for(uint i = 0; dividendsPayedIndex < addresses.length && i < count; i++) {
      address tokenHolder = addresses[dividendsPayedIndex];
      if(!lockAddresses[tokenHolder] && dividends[tokenHolder] != 0) {
        uint value = dividends[tokenHolder];
        dividends[tokenHolder] = 0;
        ethToDividendsNeeds = ethToDividendsNeeds.sub(value);
        tokenHolder.transfer(value);
      }
      dividendsPayedIndex++;
    }
    if(dividendsPayedIndex == addresses.length) {  
      dividendsPayedIndex = 0;
      dividendsPayed = true;
      dividendsCalculated = false;
    }
  }
  

  // re-entrance attack can freeze all dividends calculation
  function calculateDividends(uint percent, uint count) public onlyOwner {
    require(!dividendsCalculated);
    for(uint i = 0; dividendsIndex < addresses.length && i < count; i++) {
      address tokenHolder = addresses[dividendsIndex];
      if(balances[tokenHolder] != 0) {
        uint valueInWei = balances[tokenHolder].mul(invested).mul(percent).div(PERCENT_RATE).div(totalSupply);
        ethToDividendsNeeds = ethToDividendsNeeds.add(valueInWei);
        dividends[tokenHolder] = dividends[tokenHolder].add(valueInWei);
      }
      dividendsIndex++;
    }
    if(dividendsIndex == addresses.length) {  
      dividendsIndex = 0;
      dividendsCalculated = true;
      dividendsPayed = false;
    }
  }

  function withdraw() public onlyOwner {
    owner.transfer(this.balance);
  }

  function deposit() public payable {
  }

  function () public payable {
    deposit();
  }

}

contract CommonCrowdsale is Ownable {

  using SafeMath for uint256;
 
  uint public constant DIVIDER = 10000000000000000;

  uint public constant PERCENT_RATE = 100;

  uint public price = 1500;

  uint public minInvestedLimit = 100000000000000000;

  uint public hardcap = 250000000000000000000000;

  uint public start = 1510758000;

  uint public invested;

  address public wallet;

  struct Milestone {
    uint periodInDays;
    uint bonus;
  }

  Milestone[] public milestones;

  MilkCoinToken public token = new MilkCoinToken();

  function setHardcap(uint newHardcap) public onlyOwner { 
    hardcap = newHardcap;
  }
 
  function setStart(uint newStart) public onlyOwner { 
    start = newStart;
  }

  function setWallet(address newWallet) public onlyOwner { 
    wallet = newWallet;
  }

  function setPrice(uint newPrice) public onlyOwner {
    price = newPrice;
  }

  function setMinInvestedLimit(uint newMinInvestedLimit) public onlyOwner {
    minInvestedLimit = newMinInvestedLimit;
  }
 
  function milestonesCount() public constant returns(uint) {
    return milestones.length;
  }

  function addMilestone(uint limit, uint bonus) public onlyOwner {
    milestones.push(Milestone(limit, bonus));
  }

  function end() public constant returns(uint) {
    uint last = start;
    for (uint i = 0; i < milestones.length; i++) {
      Milestone storage milestone = milestones[i];
      last += milestone.periodInDays * 1 days;
    }
    return last;
  }

  function getMilestoneBonus() public constant returns(uint) {
    uint prevTimeLimit = start;
    for (uint i = 0; i < milestones.length; i++) {
      Milestone storage milestone = milestones[i];
      prevTimeLimit += milestone.periodInDays * 1 days;
      if (now < prevTimeLimit)
        return milestone.bonus;
    }
    revert();
  }

  function createTokensManually(address to, uint amount) public onlyOwner {
    require(now >= start && now < end());
    token.mint(to, amount);
  }

  function createTokens() public payable {
    require(now >= start && now < end() && invested < hardcap);
    wallet.transfer(msg.value);
    invested = invested.add(msg.value);
    uint tokens = price.mul(msg.value).div(DIVIDER);
    uint bonusPercent = getMilestoneBonus();    
    if(bonusPercent > 0) {
      tokens = tokens.add(tokens.mul(bonusPercent).div(PERCENT_RATE));
    }
    token.mint(msg.sender, tokens);
  }

  function finishMinting() public onlyOwner {
    token.finishMinting(invested);
    token.transferOwnership(owner);
  }

  function() external payable {
    createTokens();
  }

  function retrieveTokens(address anotherToken) public onlyOwner {
    ERC20 alienToken = ERC20(anotherToken);
    alienToken.transfer(wallet, alienToken.balanceOf(this));
  }

}

contract MilkCoinTokenCrowdsale is CommonCrowdsale {

  function MilkCoinTokenCrowdsale() public {
    setHardcap(250000000000000000000000);
    setStart(1510758000);
    setPrice(1500);
    setWallet(0x87127Cb2a73eA9ba842b208455fa076cab03E844);
    addMilestone(3, 100);
    addMilestone(5, 67);
    addMilestone(5, 43);
    addMilestone(5, 25);
    addMilestone(12, 0);
    transferOwnership(0xb794B6c611bFC09ABD206184417082d3CA570FB7);
  }

}