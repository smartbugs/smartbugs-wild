pragma solidity ^0.4.18;

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

// File: contracts/RetrieveTokenFeature.sol

contract RetrieveTokenFeature is Ownable {

  function retrieveTokens(address to, address anotherToken) public onlyOwner {
    ERC20 alienToken = ERC20(anotherToken);
    alienToken.transfer(to, alienToken.balanceOf(this));
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

// File: contracts/StagedCrowdsale.sol

contract StagedCrowdsale is RetrieveTokenFeature {

  using SafeMath for uint;

  struct Milestone {
    uint period;
    uint bonus;
  }

  uint public start;

  uint public totalPeriod;

  uint public invested;

  uint public hardCap;

  Milestone[] public milestones;

  function milestonesCount() public constant returns(uint) {
    return milestones.length;
  }

  function setStart(uint newStart) public onlyOwner {
    start = newStart;
  }

  function setHardcap(uint newHardcap) public onlyOwner {
    hardCap = newHardcap;
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

  modifier saleIsOn() {
    require(milestones.length > 0 && now >= start && now < lastSaleDate());
    _;
  }

  modifier isUnderHardCap() {
    require(invested <= hardCap);
    _;
  }

  function lastSaleDate() public constant returns(uint) {
    require(milestones.length > 0);
    return start + totalPeriod * 1 days;
  }

  function currentMilestone() public saleIsOn constant returns(uint) {
    uint previousDate = start;
    for(uint i=0; i < milestones.length; i++) {
      if(now >= previousDate && now < previousDate + milestones[i].period * 1 days) {
        return i;
      }
      previousDate = previousDate.add(milestones[i].period * 1 days);
    }
    revert();
  }

}

// File: contracts/WalletProvider.sol

contract WalletProvider is Ownable {

  address public wallet;

  function setWallet(address newWallet) public onlyOwner {
    wallet = newWallet;
  }

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

// File: contracts/token/MintableToken.sol

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
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

// File: contracts/YayProtoToken.sol

contract YayProtoToken is MintableToken {

  string public constant name = "YayProto";

  string public constant symbol = "YFN";

  uint32 public constant decimals = 18;

  address public saleAgent;

  modifier notLocked() {
    require(mintingFinished || msg.sender == owner || msg.sender == saleAgent);
    _;
  }

  modifier onlyOwnerOrSaleAgent() {
    require(msg.sender == owner || msg.sender == saleAgent);
    _;
  }

  function setSaleAgent(address newSaleAgent) public {
    require(msg.sender == owner || msg.sender == saleAgent);
    saleAgent = newSaleAgent;
  }

  function mint(address _to, uint256 _amount) onlyOwnerOrSaleAgent canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  function finishMinting() onlyOwnerOrSaleAgent canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

  function transfer(address _to, uint256 _value) public notLocked returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public notLocked returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

}

// File: contracts/CommonSale.sol

contract CommonSale is StagedCrowdsale, WalletProvider {

  address public directMintAgent;

  uint public percentRate = 100;

  uint public minPrice;

  uint public price;

  YayProtoToken public token;

  modifier onlyDirectMintAgentOrOwner() {
    require(directMintAgent == msg.sender || owner == msg.sender);
    _;
  }

  modifier minPriceLimit() {
    require(msg.value >= minPrice);
    _;
  }

  function setDirectMintAgent(address newDirectMintAgent) public onlyOwner {
    directMintAgent = newDirectMintAgent;
  }

  function setMinPrice(uint newMinPrice) public onlyOwner {
    minPrice = newMinPrice;
  }

  function setPrice(uint newPrice) public onlyOwner {
    price = newPrice;
  }

  function setToken(address newToken) public onlyOwner {
    token = YayProtoToken(newToken);
  }

  function directMint(address to, uint investedWei) public onlyDirectMintAgentOrOwner saleIsOn {
    mintTokens(to, investedWei);
  }

  function mintTokens(address to, uint weiInvested) internal {
    uint milestoneIndex = currentMilestone();
    Milestone storage milestone = milestones[milestoneIndex];
    invested = invested.add(msg.value);
    uint tokens = weiInvested.mul(price).div(1 ether);
    uint bonusTokens = tokens.mul(milestone.bonus).div(percentRate);
    uint tokensWithBonus = tokens.add(bonusTokens);
    createAndTransferTokens(to, tokensWithBonus);
  }

  function createAndTransferTokens(address to, uint tokens) internal isUnderHardCap {
    token.mint(this, tokens);
    token.transfer(to, tokens);
  }

}

// File: contracts/Mainsale.sol

contract Mainsale is CommonSale {

  address public marketingTokensWallet;

  address public developersTokensWallet;

  address public advisorsTokensWallet;

  address public teamTokensWallet;

  uint public marketingTokensPercent;

  uint public developersTokensPercent;

  uint public advisorsTokensPercent;

  uint public teamTokensPercent;

  function setMarketingTokensPercent(uint newMarketingTokensPercent) public onlyOwner {
    marketingTokensPercent = newMarketingTokensPercent;
  }

  function setDevelopersTokensPercent(uint newDevelopersTokensPercent) public onlyOwner {
    developersTokensPercent = newDevelopersTokensPercent;
  }

  function setAdvisorsTokensPercent(uint newAdvisorsTokensPercent) public onlyOwner {
    advisorsTokensPercent = newAdvisorsTokensPercent;
  }

  function setTeamTokensPercent(uint newTeamTokensPercent) public onlyOwner {
    teamTokensPercent = newTeamTokensPercent;
  }

  function setMarketingTokensWallet(address newMarketingTokensWallet) public onlyOwner {
    marketingTokensWallet = newMarketingTokensWallet;
  }

  function setDevelopersTokensWallet(address newDevelopersTokensWallet) public onlyOwner {
    developersTokensWallet = newDevelopersTokensWallet;
  }

  function setAdvisorsTokensWallet(address newAdvisorsTokensWallet) public onlyOwner {
    advisorsTokensWallet = newAdvisorsTokensWallet;
  }

  function setTeamTokensWallet(address newTeamTokensWallet) public onlyOwner {
    teamTokensWallet = newTeamTokensWallet;
  }

  function finish() public onlyOwner {
    uint extendedTokensPercent = marketingTokensPercent.add(teamTokensPercent).add(developersTokensPercent).add(advisorsTokensPercent);
    uint allTokens = token.totalSupply().mul(percentRate).div(percentRate.sub(extendedTokensPercent));
    createAndTransferTokens(marketingTokensWallet,allTokens.mul(marketingTokensPercent).div(percentRate));
    createAndTransferTokens(teamTokensWallet,allTokens.mul(teamTokensPercent).div(percentRate));
    createAndTransferTokens(developersTokensWallet,allTokens.mul(developersTokensPercent).div(percentRate));
    createAndTransferTokens(advisorsTokensWallet,allTokens.mul(advisorsTokensPercent).div(percentRate));
    token.finishMinting();
  }

  function () external payable minPriceLimit {
    wallet.transfer(msg.value);
    mintTokens(msg.sender, msg.value);
  }

}

// File: contracts/SoftcapFeature.sol

contract SoftcapFeature is WalletProvider {

  using SafeMath for uint;

  mapping(address => uint) balances;

  bool public softcapAchieved;

  bool public refundOn;

  uint public softcap;

  uint public invested;

  function setSoftcap(uint newSoftcap) public onlyOwner {
    softcap = newSoftcap;
  }

  function withdraw() public onlyOwner {
    require(softcapAchieved);
    wallet.transfer(this.balance);
  }

  function updateBalance(address to, uint amount) internal {
    balances[to] = balances[to].add(amount);
    invested = invested.add(amount);
    if (!softcapAchieved && invested >= softcap) {
      softcapAchieved = true;
    }
  }

  function updateRefundState() internal returns(bool) {
    if (!softcapAchieved) {
      refundOn = true;
    }
    return refundOn;
  }

}

// File: contracts/Presale.sol

contract Presale is SoftcapFeature, CommonSale {

  Mainsale public mainsale;

  function setMainsale(address newMainsale) public onlyOwner {
    mainsale = Mainsale(newMainsale);
  }

  function finish() public onlyOwner {
    token.setSaleAgent(mainsale);
  }

  function mintTokens(address to, uint weiInvested) internal {
    super.mintTokens(to, weiInvested);
    updateBalance(msg.sender, msg.value);
  }

  function () external payable minPriceLimit {
    mintTokens(msg.sender, msg.value);
  }

  function refund() public {
    require(refundOn && balances[msg.sender] > 0);
    uint value = balances[msg.sender];
    balances[msg.sender] = 0;
    msg.sender.transfer(value);
  }

  function finishMinting() public onlyOwner {
    if (updateRefundState()) {
      token.finishMinting();
    } else {
      withdraw();
      token.setSaleAgent(mainsale);
    }
  }

}

// File: contracts/Configurator.sol

contract Configurator is Ownable {

  YayProtoToken public token;

  Presale public presale;

  Mainsale public mainsale;

  function deploy() public onlyOwner {

    token = new YayProtoToken();
    presale = new Presale();
    mainsale = new Mainsale();

    presale.setToken(token);
    presale.setWallet(0x00c286bFbEfa2e7D060259822EDceA2E922a2B7C);
    presale.setStart(1517356800);
    presale.setMinPrice(100000000000000000);
    presale.setPrice(7500000000000000000000);
    presale.setSoftcap(3000000000000000000000);
    presale.setHardcap(11250000000000000000000);
    presale.addMilestone(7,60);
    presale.addMilestone(7,50);
    presale.addMilestone(7,40);
    presale.addMilestone(7,30);
    presale.addMilestone(7,25);
    presale.addMilestone(7,20);
    presale.setMainsale(mainsale);

    mainsale.setToken(token);
    mainsale.setPrice(7500000000000000000000);
    mainsale.setWallet(0x009693f53723315219f681529fE6e05a91a28C41);
    mainsale.setDevelopersTokensWallet(0x0097895f899559D067016a3d61e3742c0da533ED);
    mainsale.setTeamTokensWallet(0x00137668FEda9d278A242C69aB520466A348C954);
    mainsale.setMarketingTokensWallet(0x00A8a63f43ce630dbd3b96F1e040A730341bAa4D);
    mainsale.setAdvisorsTokensWallet(0x00764817d154237115DdA4FAA76C7aaB5dE3cb25);
    mainsale.setStart(1523750400);
    mainsale.setMinPrice(100000000000000000);
    mainsale.setHardcap(95000000000000000000000);
    mainsale.setDevelopersTokensPercent(10);
    mainsale.setTeamTokensPercent(10);
    mainsale.setMarketingTokensPercent(5);
    mainsale.setAdvisorsTokensPercent(10);
    mainsale.addMilestone(7,15);
    mainsale.addMilestone(7,10);
    mainsale.addMilestone(7,7);
    mainsale.addMilestone(7,4);
    mainsale.addMilestone(7,0);

    token.setSaleAgent(presale);

    token.transferOwnership(owner);
    presale.transferOwnership(owner);
    mainsale.transferOwnership(owner);
  }

}