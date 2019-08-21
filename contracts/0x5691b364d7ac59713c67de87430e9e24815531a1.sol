pragma solidity 0.4.18;

// File: contracts/ownership/Ownable.sol

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

// File: contracts/NextSaleAgentFeature.sol

contract NextSaleAgentFeature is Ownable {

  address public nextSaleAgent;

  function setNextSaleAgent(address newNextSaleAgent) public onlyOwner {
    nextSaleAgent = newNextSaleAgent;
  }

}

// File: contracts/DevWallet.sol

contract DevWallet {

  uint public date = 1525255200;
  uint public limit = 4500000000000000000;
  address public wallet = 0xEA15Adb66DC92a4BbCcC8Bf32fd25E2e86a2A770;

  function withdraw() public {
    require(now >= date);
    wallet.transfer(this.balance);
  }

  function () public payable {}

}

// File: contracts/PercentRateProvider.sol

contract PercentRateProvider is Ownable {

  uint public percentRate = 100;

  function setPercentRate(uint newPercentRate) public onlyOwner {
    percentRate = newPercentRate;
  }

}

// File: contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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

// File: contracts/token/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/token/BasicToken.sol

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
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: contracts/token/ERC20.sol

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

// File: contracts/token/StandardToken.sol

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

// File: contracts/MintableToken.sol

contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);

  event MintFinished();

  bool public mintingFinished = false;

  address public saleAgent;

  function setSaleAgent(address newSaleAgnet) public {
    require(msg.sender == saleAgent || msg.sender == owner);
    saleAgent = newSaleAgnet;
  }

  function mint(address _to, uint256 _amount) public returns (bool) {
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
  function finishMinting() public returns (bool) {
    require((msg.sender == saleAgent || msg.sender == owner) && !mintingFinished);
    mintingFinished = true;
    MintFinished();
    return true;
  }

}

// File: contracts/REPUToken.sol

contract REPUToken is MintableToken {

  string public constant name = 'REPU';

  string public constant symbol = 'REPU';

  uint32 public constant decimals = 18;

}

// File: contracts/CommonSale.sol

contract CommonSale is PercentRateProvider {

  using SafeMath for uint;

  address public wallet;

  address public directMintAgent;

  uint public price;

  uint public start;

  uint public minInvestedLimit;

  REPUToken public token;

  DevWallet public devWallet;

  bool public devWalletLocked;

  uint public hardcap;

  uint public invested;

  modifier isUnderHardcap() {
    require(invested < hardcap);
    _;
  }

  function setHardcap(uint newHardcap) public onlyOwner {
    hardcap = newHardcap;
  }

  modifier onlyDirectMintAgentOrOwner() {
    require(directMintAgent == msg.sender || owner == msg.sender);
    _;
  }

  modifier minInvestLimited(uint value) {
    require(value >= minInvestedLimit);
    _;
  }

  function setStart(uint newStart) public onlyOwner {
    start = newStart;
  }

  function setMinInvestedLimit(uint newMinInvestedLimit) public onlyOwner {
    minInvestedLimit = newMinInvestedLimit;
  }

  function setDirectMintAgent(address newDirectMintAgent) public onlyOwner {
    directMintAgent = newDirectMintAgent;
  }

  function setWallet(address newWallet) public onlyOwner {
    wallet = newWallet;
  }

  function setPrice(uint newPrice) public onlyOwner {
    price = newPrice;
  }

  function setToken(address newToken) public onlyOwner {
    token = REPUToken(newToken);
  }

  function setDevWallet(address newDevWallet) public onlyOwner {
    require(!devWalletLocked);
    devWallet = DevWallet(newDevWallet);
    devWalletLocked = true;
  }

  function calculateTokens(uint _invested) internal returns(uint);

  function mintTokensExternal(address to, uint tokens) public onlyDirectMintAgentOrOwner {
    mintTokens(to, tokens);
  }

  function mintTokens(address to, uint tokens) internal {
    token.mint(this, tokens);
    token.transfer(to, tokens);
  }

  function endSaleDate() public view returns(uint);

  function mintTokensByETHExternal(address to, uint _invested) public onlyDirectMintAgentOrOwner returns(uint) {
    return mintTokensByETH(to, _invested);
  }

  function mintTokensByETH(address to, uint _invested) internal isUnderHardcap returns(uint) {
    invested = invested.add(_invested);
    uint tokens = calculateTokens(_invested);
    mintTokens(to, tokens);
    return tokens;
  }

  function devWithdraw() internal {
    uint received = devWallet.balance;
    uint limit = devWallet.limit();
    if (received < limit) {
      uint shouldSend = limit.sub(received);
      uint value;
      if (msg.value < shouldSend) {
        value = msg.value;
      } else {
        value = shouldSend;
      }
      devWallet.transfer(value);
    }
  }

  function fallback() internal minInvestLimited(msg.value) returns(uint) {
    require(now >= start && now < endSaleDate());
    if (devWallet != address(0)) {
      devWithdraw();
    }
    wallet.transfer(this.balance);
    return mintTokensByETH(msg.sender, msg.value);
  }

  function () public payable {
    fallback();
  }

}

// File: contracts/RetrieveTokensFeature.sol

contract RetrieveTokensFeature is Ownable {

  function retrieveTokens(address to, address anotherToken) public onlyOwner {
    ERC20 alienToken = ERC20(anotherToken);
    alienToken.transfer(to, alienToken.balanceOf(this));
  }

}

// File: contracts/ValueBonusFeature.sol

contract ValueBonusFeature is PercentRateProvider {

  using SafeMath for uint;

  struct ValueBonus {
    uint from;
    uint bonus;
  }

  ValueBonus[] public valueBonuses;

  function addValueBonus(uint from, uint bonus) public onlyOwner {
    valueBonuses.push(ValueBonus(from, bonus));
  }

  function getValueBonusTokens(uint tokens, uint _invested) public view returns(uint) {
    uint valueBonus = getValueBonus(_invested);
    if (valueBonus == 0) {
      return 0;
    }
    return tokens.mul(valueBonus).div(percentRate);
  }

  function getValueBonus(uint value) public view returns(uint) {
    uint bonus = 0;
    for (uint i = 0; i < valueBonuses.length; i++) {
      if (value >= valueBonuses[i].from) {
        bonus = valueBonuses[i].bonus;
      } else {
        return bonus;
      }
    }
    return bonus;
  }

}

// File: contracts/REPUCommonSale.sol

contract REPUCommonSale is ValueBonusFeature, RetrieveTokensFeature, CommonSale {


}

// File: contracts/StagedCrowdsale.sol

contract StagedCrowdsale is Ownable {

  using SafeMath for uint;

  struct Milestone {
    uint period;
    uint bonus;
  }

  uint public totalPeriod;

  Milestone[] public milestones;

  function milestonesCount() public view returns(uint) {
    return milestones.length;
  }

  function addMilestone(uint period, uint bonus) public onlyOwner {
    require(period > 0);
    milestones.push(Milestone(period, bonus));
    totalPeriod = totalPeriod.add(period);
  }

  function removeMilestone(uint8 number) public onlyOwner {
    require(number < milestones.length);
    Milestone storage milestone = milestones[number];
    totalPeriod = totalPeriod.sub(milestone.period);

    delete milestones[number];

    for (uint i = number; i < milestones.length - 1; i++) {
      milestones[i] = milestones[i+1];
    }

    milestones.length--;
  }

  function changeMilestone(uint8 number, uint period, uint bonus) public onlyOwner {
    require(number < milestones.length);
    Milestone storage milestone = milestones[number];

    totalPeriod = totalPeriod.sub(milestone.period);

    milestone.period = period;
    milestone.bonus = bonus;

    totalPeriod = totalPeriod.add(period);
  }

  function insertMilestone(uint8 numberAfter, uint period, uint bonus) public onlyOwner {
    require(numberAfter < milestones.length);

    totalPeriod = totalPeriod.add(period);

    milestones.length++;

    for (uint i = milestones.length - 2; i > numberAfter; i--) {
      milestones[i + 1] = milestones[i];
    }

    milestones[numberAfter + 1] = Milestone(period, bonus);
  }

  function clearMilestones() public onlyOwner {
    require(milestones.length > 0);
    for (uint i = 0; i < milestones.length; i++) {
      delete milestones[i];
    }
    milestones.length -= milestones.length;
    totalPeriod = 0;
  }

  function lastSaleDate(uint start) public view returns(uint) {
    return start + totalPeriod * 1 days;
  }

  function currentMilestone(uint start) public view returns(uint) {
    uint previousDate = start;
    for (uint i = 0; i < milestones.length; i++) {
      if (now >= previousDate && now < previousDate + milestones[i].period * 1 days) {
        return i;
      }
      previousDate = previousDate.add(milestones[i].period * 1 days);
    }
    revert();
  }

}

// File: contracts/Mainsale.sol

contract Mainsale is StagedCrowdsale, REPUCommonSale {

  address public foundersTokensWallet;

  address public advisorsTokensWallet;

  address public bountyTokensWallet;

  address public lotteryTokensWallet;

  uint public foundersTokensPercent;

  uint public advisorsTokensPercent;

  uint public bountyTokensPercent;

  uint public lotteryTokensPercent;

  function setFoundersTokensPercent(uint newFoundersTokensPercent) public onlyOwner {
    foundersTokensPercent = newFoundersTokensPercent;
  }

  function setAdvisorsTokensPercent(uint newAdvisorsTokensPercent) public onlyOwner {
    advisorsTokensPercent = newAdvisorsTokensPercent;
  }

  function setBountyTokensPercent(uint newBountyTokensPercent) public onlyOwner {
    bountyTokensPercent = newBountyTokensPercent;
  }

  function setLotteryTokensPercent(uint newLotteryTokensPercent) public onlyOwner {
    lotteryTokensPercent = newLotteryTokensPercent;
  }

  function setFoundersTokensWallet(address newFoundersTokensWallet) public onlyOwner {
    foundersTokensWallet = newFoundersTokensWallet;
  }

  function setAdvisorsTokensWallet(address newAdvisorsTokensWallet) public onlyOwner {
    advisorsTokensWallet = newAdvisorsTokensWallet;
  }

  function setBountyTokensWallet(address newBountyTokensWallet) public onlyOwner {
    bountyTokensWallet = newBountyTokensWallet;
  }

  function setLotteryTokensWallet(address newLotteryTokensWallet) public onlyOwner {
    lotteryTokensWallet = newLotteryTokensWallet;
  }

  function calculateTokens(uint _invested) internal returns(uint) {
    uint milestoneIndex = currentMilestone(start);
    Milestone storage milestone = milestones[milestoneIndex];
    uint tokens = _invested.mul(price).div(1 ether);
    uint valueBonusTokens = getValueBonusTokens(tokens, _invested);
    if (milestone.bonus > 0) {
      tokens = tokens.add(tokens.mul(milestone.bonus).div(percentRate));
    }
    return tokens.add(valueBonusTokens);
  }

  function finish() public onlyOwner {
    uint summaryTokensPercent = bountyTokensPercent.add(foundersTokensPercent).add(advisorsTokensPercent).add(lotteryTokensPercent);
    uint mintedTokens = token.totalSupply();
    uint allTokens = mintedTokens.mul(percentRate).div(percentRate.sub(summaryTokensPercent));
    uint foundersTokens = allTokens.mul(foundersTokensPercent).div(percentRate);
    uint advisorsTokens = allTokens.mul(advisorsTokensPercent).div(percentRate);
    uint bountyTokens = allTokens.mul(bountyTokensPercent).div(percentRate);
    uint lotteryTokens = allTokens.mul(lotteryTokensPercent).div(percentRate);
    mintTokens(foundersTokensWallet, foundersTokens);
    mintTokens(advisorsTokensWallet, advisorsTokens);
    mintTokens(bountyTokensWallet, bountyTokens);
    mintTokens(lotteryTokensWallet, lotteryTokens);
    token.finishMinting();
  }

  function endSaleDate() public view returns(uint) {
    return lastSaleDate(start);
  }

}

// File: contracts/Presale.sol

contract Presale is NextSaleAgentFeature, StagedCrowdsale, REPUCommonSale {

  function calculateTokens(uint _invested) internal returns(uint) {
    uint milestoneIndex = currentMilestone(start);
    Milestone storage milestone = milestones[milestoneIndex];
    uint tokens = _invested.mul(price).div(1 ether);
    uint valueBonusTokens = getValueBonusTokens(tokens, _invested);
    if (milestone.bonus > 0) {
      tokens = tokens.add(tokens.mul(milestone.bonus).div(percentRate));
    }
    return tokens.add(valueBonusTokens);
  }

  function finish() public onlyOwner {
    token.setSaleAgent(nextSaleAgent);
  }

  function endSaleDate() public view returns(uint) {
    return lastSaleDate(start);
  }

}

// File: contracts/ClosedRound.sol

contract ClosedRound is NextSaleAgentFeature, REPUCommonSale {

  uint public maxLimit; 

  uint public end;

  function calculateTokens(uint _invested) internal returns(uint) {
    uint tokens = _invested.mul(price).div(1 ether);
    return tokens.add(getValueBonusTokens(tokens, _invested));
  }

  function setMaxLimit(uint newMaxLimit) public onlyOwner {
    maxLimit = newMaxLimit;
  }

  function setEnd(uint newEnd) public onlyOwner {
    end = newEnd;
  }

  function finish() public onlyOwner {
    token.setSaleAgent(nextSaleAgent);
  }

  function fallback() internal returns(uint) {
    require(msg.value <= maxLimit);
    return super.fallback();
  }

  function endSaleDate() public view returns(uint) {
    return end;
  }

}

// File: contracts/Configurator.sol

contract Configurator is Ownable {

  REPUToken public token;

  ClosedRound public closedRound;

  Presale public presale;

  Mainsale public mainsale;

  DevWallet public devWallet;

  function deploy() public onlyOwner {

    token = new REPUToken();
    closedRound = new ClosedRound();
    presale = new Presale();
    mainsale = new Mainsale();
    devWallet = new DevWallet();

    token.setSaleAgent(closedRound);

    closedRound.setWallet(0x425dE1C67928834AE72FB7E6Fc17d88d1Db4484b);
    closedRound.setStart(1517652000);
    closedRound.setEnd(1519293600);
    closedRound.setPrice(12500000000000000000000);        // 1 REPU = 0.00008 ETH
    closedRound.setHardcap(1000000000000000000000);       // 1000 ETH
    closedRound.setMinInvestedLimit(1000000000000000000); // 1 ETH
    closedRound.setMaxLimit(250000000000000000000);       // 250 ETH
    closedRound.addValueBonus(2000000000000000000, 2);    // > 2 ETH => 2%
    closedRound.addValueBonus(11000000000000000000, 5);   // > 11 ETH => 5%
    closedRound.addValueBonus(51000000000000000000, 7);   // > 51 ETH => 7%
    closedRound.addValueBonus(101000000000000000000, 10); // > 101 ETH => 10%
    closedRound.setToken(token);
    closedRound.setNextSaleAgent(presale);
    closedRound.setDevWallet(devWallet);


    presale.setWallet(0x425dE1C67928834AE72FB7E6Fc17d88d1Db4484b);
    presale.setStart(1519380000);
    presale.setPrice(6854009595613434000000);             // 1 REPU = 0.0001459 ETH
    presale.setPercentRate(10000);
    presale.addMilestone(1, 2159);                        // 8333.7902 REPU / ETH
    presale.addMilestone(1, 1580);                        // 7936.9431 REPU / ETH
    presale.addMilestone(1, 1028);                        // 7558.6017 REPU / ETH
    presale.addMilestone(1, 504);                         // 7199.4516 REPU / ETH
    presale.addMilestone(3, 0);                           // 6854.0095 REPU / ETH

    closedRound.transferOwnership(owner);
    token.transferOwnership(owner);
    presale.transferOwnership(owner);
    mainsale.transferOwnership(owner);    

/*    presale.setHardcap(1800000000000000000000);           // 1800 ETH
    presale.setMinInvestedLimit(100000000000000000);      // 0.1 ETH
    presale.addValueBonus(2000000000000000000, 200);      // > 2 ETH => 2%
    presale.addValueBonus(11000000000000000000, 500);     // > 11 ETH => 5%
    presale.addValueBonus(51000000000000000000, 700);     // > 51 ETH => 7%
    presale.addValueBonus(101000000000000000000, 1000);   // > 101 ETH => 10%
    presale.addValueBonus(301000000000000000000, 1500);   // > 301 ETH => 15%

    presale.setToken(token);
    presale.setNextSaleAgent(mainsale);
    presale.setDevWallet(devWallet);

    mainsale.setWallet(0x29b637Ca54Fc1A9d8d92475f8a64C199c91B82E4);
    mainsale.setStart(1522663200);
    mainsale.setPrice(3937007874015748300000);                // 1 REPU = 0.0002540 ETH
    mainsale.setPercentRate(100000);
    mainsale.addMilestone(7, 48200);                          // 5834.6456 REPU / ETH
    mainsale.addMilestone(7, 29990);                          // 5117.7165 REPU / ETH
    mainsale.addMilestone(7, 14010);                          // 4488.5826 REPU / ETH
    mainsale.addMilestone(9, 0);                              // 3937.0078 REPU / ETH
    mainsale.setHardcap(30000000000000000000000);             // 30 000 ETH
    mainsale.setMinInvestedLimit(30000000000000000);          // 0.03 ETH
    mainsale.addValueBonus(2000000000000000000, 2000);        // > 2 ETH => 2%
    mainsale.addValueBonus(11000000000000000000, 3000);       // > 11 ETH => 3%
    mainsale.addValueBonus(51000000000000000000, 5000);       // > 51 ETH => 5%
    mainsale.addValueBonus(101000000000000000000, 7000);      // > 101 ETH => 7%
    mainsale.addValueBonus(301000000000000000000, 10000);     // > 301 ETH => 10%
    mainsale.addValueBonus(501000000000000000000, 15000);     // > 501 ETH => 15%
    mainsale.addValueBonus(1000000000000000000000, 20000);    // > 1000 ETH => 20%
    mainsale.setFoundersTokensWallet(0x650F7fcBd397AB0C722D9EfBBd6Cd885d02e8f8F);
    mainsale.setFoundersTokensPercent(12500);
    mainsale.setAdvisorsTokensWallet(0x93b103Ecc79f6ef79038E041704a1083E9C4e1A6);
    mainsale.setAdvisorsTokensPercent(3330);
    mainsale.setBountyTokensWallet(0xaAF9430b8B68146665acB4F05396d63a71d54C4d);
    mainsale.setBountyTokensPercent(6250);
    mainsale.setLotteryTokensWallet(0xDA7b920F54e14F0Cc5658f0635B45a0839Dbf18C);
    mainsale.setLotteryTokensPercent(625);
    mainsale.setDevWallet(devWallet);

    address manager = 0x8c782FAF936ce57Dca60791a47E680e7A34A6315;
    
    closedRound.transferOwnership(manager);
    token.transferOwnership(manager);
    presale.transferOwnership(manager);
    mainsale.transferOwnership(manager);*/
  }

}