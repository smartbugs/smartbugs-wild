pragma solidity ^0.4.15;

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
    require(_to != address(0));

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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

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
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
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
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
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

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract OpportyToken is StandardToken {

  string public constant name = "OpportyToken";
  string public constant symbol = "OPP";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));

  /**
   * @dev Contructor that gives msg.sender all of existing tokens.
   */
  function OpportyToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
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
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract HoldPresaleContract is Ownable {
  using SafeMath for uint256;
  // Addresses and contracts
  OpportyToken public OppToken;
  address private presaleCont;

  struct Holder {
    bool isActive;
    uint tokens;
    uint8 holdPeriod;
    uint holdPeriodTimestamp;
    bool withdrawed;
  }

  mapping(address => Holder) public holderList;
  mapping(uint => address) private holderIndexes;

  mapping (uint => address) private assetOwners;
  mapping (address => uint) private assetOwnersIndex;
  uint public assetOwnersIndexes;

  uint private holderIndex;

  event TokensTransfered(address contributor , uint amount);
  event Hold(address sender, address contributor, uint amount, uint8 holdPeriod);

  modifier onlyAssetsOwners() {
    require(assetOwnersIndex[msg.sender] > 0);
    _;
  }

  /* constructor */
  function HoldPresaleContract(address _OppToken) {
    OppToken = OpportyToken(_OppToken);
  }

  function setPresaleCont(address pres)  public onlyOwner
  {
    presaleCont = pres;
  }

  function addHolder(address holder, uint tokens, uint8 timed, uint timest) onlyAssetsOwners external {
    if (holderList[holder].isActive == false) {
      holderList[holder].isActive = true;
      holderList[holder].tokens = tokens;
      holderList[holder].holdPeriod = timed;
      holderList[holder].holdPeriodTimestamp = timest;
      holderIndexes[holderIndex] = holder;
      holderIndex++;
    } else {
      holderList[holder].tokens += tokens;
      holderList[holder].holdPeriod = timed;
      holderList[holder].holdPeriodTimestamp = timest;
    }
    Hold(msg.sender, holder, tokens, timed);
  }

  function getBalance() constant returns (uint) {
    return OppToken.balanceOf(this);
  }

  function unlockTokens() external {
    address contributor = msg.sender;

    if (holderList[contributor].isActive && !holderList[contributor].withdrawed) {
      if (now >= holderList[contributor].holdPeriodTimestamp) {
        if ( OppToken.transfer( msg.sender, holderList[contributor].tokens ) ) {
          holderList[contributor].withdrawed = true;
          TokensTransfered(contributor,  holderList[contributor].tokens);
        }
      } else {
        revert();
      }
    } else {
      revert();
    }
  }

  function addAssetsOwner(address _owner) public onlyOwner {
    assetOwnersIndexes++;
    assetOwners[assetOwnersIndexes] = _owner;
    assetOwnersIndex[_owner] = assetOwnersIndexes;
  }
  function removeAssetsOwner(address _owner) public onlyOwner {
    uint index = assetOwnersIndex[_owner];
    delete assetOwnersIndex[_owner];
    delete assetOwners[index];
    assetOwnersIndexes--;
  }
  function getAssetsOwners(uint _index) onlyOwner public constant returns (address) {
    return assetOwners[_index];
  }
}

contract OpportyPresale is Pausable {
  using SafeMath for uint256;

  OpportyToken public token;

  HoldPresaleContract public holdContract;

  enum SaleState  { NEW, SALE, ENDED }
  SaleState public state;

  uint public endDate;
  uint public endSaleDate;

  // address where funds are collected
  address private wallet;

  // total ETH collected
  uint public ethRaised;

  uint private price;

  uint public tokenRaised;
  bool public tokensTransferredToHold;

  /* Events */
  event SaleStarted(uint blockNumber);
  event SaleEnded(uint blockNumber);
  event FundTransfered(address contrib, uint amount);
  event WithdrawedEthToWallet(uint amount);
  event ManualChangeEndDate(uint beforeDate, uint afterDate);
  event TokensTransferedToHold(address hold, uint amount);
  event AddedToWhiteList(address inv, uint amount, uint8 holdPeriod, uint8 bonus);
  event AddedToHolder( address sender, uint tokenAmount, uint8 holdPeriod, uint holdTimestamp);

  struct WhitelistContributor {
    bool isActive;
    uint invAmount;
    uint8 holdPeriod;
    uint holdTimestamp;
    uint8 bonus;
    bool payed;
  }

  mapping(address => WhitelistContributor) public whiteList;
  mapping(uint => address) private whitelistIndexes;
  uint private whitelistIndex;

  /* constructor */
  function OpportyPresale(
    address tokenAddress,
    address walletAddress,
    uint end,
    uint endSale,
    address holdCont )
  {
    token = OpportyToken(tokenAddress);
    state = SaleState.NEW;

    endDate     = end;
    endSaleDate = endSale;
    price       = 0.0002 * 1 ether;
    wallet      = walletAddress;

    holdContract = HoldPresaleContract(holdCont);
  }

  function startPresale() public onlyOwner {
    require(state == SaleState.NEW);
    state = SaleState.SALE;
    SaleStarted(block.number);
  }

  function endPresale() public onlyOwner {
    require(state == SaleState.SALE);
    state = SaleState.ENDED;
    SaleEnded(block.number);
  }

  function addToWhitelist(address inv, uint amount, uint8 holdPeriod, uint8 bonus) public onlyOwner {
    require(state == SaleState.NEW || state == SaleState.SALE);
    require(holdPeriod == 1 || holdPeriod == 3 || holdPeriod == 6 || holdPeriod == 12);

    amount = amount * (10 ** 18);

    if (whiteList[inv].isActive == false) {
      whiteList[inv].isActive = true;
      whiteList[inv].payed    = false;
      whitelistIndexes[whitelistIndex] = inv;
      whitelistIndex++;
    }

    whiteList[inv].invAmount  = amount;
    whiteList[inv].holdPeriod = holdPeriod;
    whiteList[inv].bonus = bonus;

    if (whiteList[inv].holdPeriod==1)  whiteList[inv].holdTimestamp = endSaleDate.add(30 days); else
    if (whiteList[inv].holdPeriod==3)  whiteList[inv].holdTimestamp = endSaleDate.add(92 days); else
    if (whiteList[inv].holdPeriod==6)  whiteList[inv].holdTimestamp = endSaleDate.add(182 days); else
    if (whiteList[inv].holdPeriod==12) whiteList[inv].holdTimestamp = endSaleDate.add(1 years);

    AddedToWhiteList(inv, whiteList[inv].invAmount, whiteList[inv].holdPeriod,  whiteList[inv].bonus);
  }

  function() whenNotPaused public payable {
    require(state == SaleState.SALE);
    require(msg.value >= 0.3 ether);
    require(whiteList[msg.sender].isActive);

    if (now > endDate) {
      state = SaleState.ENDED;
      msg.sender.transfer(msg.value);
      return ;
    }

    WhitelistContributor memory contrib = whiteList[msg.sender];
    require(contrib.invAmount <= msg.value || contrib.payed);

    if(whiteList[msg.sender].payed == false) {
      whiteList[msg.sender].payed = true;
    }

    ethRaised += msg.value;

    uint tokenAmount  = msg.value.div(price);
    tokenAmount += tokenAmount.mul(contrib.bonus).div(100);
    tokenAmount *= 10 ** 18;

    tokenRaised += tokenAmount;

    holdContract.addHolder(msg.sender, tokenAmount, contrib.holdPeriod, contrib.holdTimestamp);
    AddedToHolder(msg.sender, tokenAmount, contrib.holdPeriod, contrib.holdTimestamp);
    FundTransfered(msg.sender, msg.value);
  }

  function getBalanceContract() internal returns (uint) {
    return token.balanceOf(this);
  }

  function sendTokensToHold() public onlyOwner {
    require(state == SaleState.ENDED);

    require(getBalanceContract() >= tokenRaised);

    if (token.transfer(holdContract, tokenRaised )) {
      tokensTransferredToHold = true;
      TokensTransferedToHold(holdContract, tokenRaised );
    }
  }

  function getTokensBack() public onlyOwner {
    require(state == SaleState.ENDED);
    require(tokensTransferredToHold == true);
    uint balance;
    balance = getBalanceContract() ;
    token.transfer(msg.sender, balance);
  }

  function withdrawEth() {
    require(this.balance != 0);
    require(state == SaleState.ENDED);
    require(msg.sender == wallet);
    require(tokensTransferredToHold == true);
    uint bal = this.balance;
    wallet.transfer(bal);
    WithdrawedEthToWallet(bal);
  }

  function setEndSaleDate(uint date) public onlyOwner {
    require(state == SaleState.NEW);
    require(date > now);
    uint oldEndDate = endSaleDate;
    endSaleDate = date;
    ManualChangeEndDate(oldEndDate, date);
  }

  function setEndDate(uint date) public onlyOwner {
    require(state == SaleState.NEW || state == SaleState.SALE);
    require(date > now);
    uint oldEndDate = endDate;
    endDate = date;
    ManualChangeEndDate(oldEndDate, date);
  }

  function getTokenBalance() constant returns (uint) {
    return token.balanceOf(this);
  }

  function getEthRaised() constant external returns (uint) {
    return ethRaised;
  }
}



contract OpportySaleBonus is Ownable {
  using SafeMath for uint256;

  uint private startDate;

  /* bonus from time */
  uint private firstBonusPhase;
  uint private firstExtraBonus;
  uint private secondBonusPhase;
  uint private secondExtraBonus;
  uint private thirdBonusPhase;
  uint private thirdExtraBonus;
  uint private fourBonusPhase;
  uint private fourExtraBonus;
  uint private fifthBonusPhase;
  uint private fifthExtraBonus;
  uint private sixthBonusPhase;
  uint private sixthExtraBonus;

  /**
  * @dev constructor
  * 20% '1st 24 hours'
  * 15% '2-4 days'
  * 12% '5-9 days'
  * 10% '10-14 days'
  * 8%  '15-19 days'
  * 5%  '20-24 days'
  * 0%  '25-28 days'
  */
  function OpportySaleBonus(uint _startDate) {
    startDate = _startDate;

    firstBonusPhase   = startDate.add(1 days);
    firstExtraBonus   = 20;
    secondBonusPhase  = startDate.add(4 days);
    secondExtraBonus  = 15;
    thirdBonusPhase   = startDate.add(9 days);
    thirdExtraBonus   = 12;
    fourBonusPhase    = startDate.add(14 days);
    fourExtraBonus    = 10;
    fifthBonusPhase   = startDate.add(19 days);
    fifthExtraBonus   = 8;
    sixthBonusPhase   = startDate.add(24 days);
    sixthExtraBonus   = 5;
  }

  /**
 * @dev Calculate bonus for hours
 * @return token bonus
 */
  function calculateBonusForHours(uint256 _tokens) returns(uint256) {
    if (now >= startDate && now <= firstBonusPhase ) {
      return _tokens.mul(firstExtraBonus).div(100);
    } else
    if (now <= secondBonusPhase ) {
      return _tokens.mul(secondExtraBonus).div(100);
    } else
    if (now <= thirdBonusPhase ) {
      return _tokens.mul(thirdExtraBonus).div(100);
    } else
    if (now <= fourBonusPhase ) {
      return _tokens.mul(fourExtraBonus).div(100);
    } else
    if (now <= fifthBonusPhase ) {
      return _tokens.mul(fifthExtraBonus).div(100);
    } else
    if (now <= sixthBonusPhase ) {
      return _tokens.mul(sixthExtraBonus).div(100);
    } else
    return 0;
  }

  function changeStartDate(uint _date) onlyOwner {
    startDate = _date;
    firstBonusPhase   = startDate.add(1 days);
    secondBonusPhase  = startDate.add(4 days);
    thirdBonusPhase   = startDate.add(9 days);
    fourBonusPhase    = startDate.add(14 days);
    fifthBonusPhase   = startDate.add(19 days);
    sixthBonusPhase   = startDate.add(24 days);
  }

  /**
 * @dev return current bonus percent
 */
  function getBonus() public constant returns (uint) {
    if (now >= startDate && now <= firstBonusPhase ) {
      return firstExtraBonus;
    } else
    if ( now <= secondBonusPhase ) {
      return secondExtraBonus;
    } else
    if ( now <= thirdBonusPhase ) {
      return thirdExtraBonus;
    } else
    if ( now <= fourBonusPhase ) {
      return fourExtraBonus;
    } else
    if ( now <= fifthBonusPhase ) {
      return fifthExtraBonus;
    } else
    if ( now <= sixthBonusPhase ) {
      return sixthExtraBonus;
    } else
    return 0;
  }

}

contract OpportySale is Pausable {

  using SafeMath for uint256;

  OpportyToken public token;

  // minimum goal ETH
  uint private SOFTCAP;
  // maximum goal ETH
  uint private HARDCAP;

  // start and end timestamps where investments are allowed
  uint private startDate;
  uint private endDate;

  uint private price;

  // total ETH collected
  uint private ethRaised;
  // total token sales
  uint private totalTokens;
  // how many tokens sent to investors
  uint private withdrawedTokens;
  // minimum ETH investment amount
  uint private minimalContribution;

  bool releasedTokens;

  // address where funds are collected
  address public wallet;
  // address where funds will be frozen
  HoldPresaleContract public holdContract;
  OpportyPresale private presale;
  OpportySaleBonus private bonus;

  //minimum of tokens that must be on the contract for the start
  uint private minimumTokensToStart = 150000000 * (10 ** 18);

  struct ContributorData {
    bool isActive;
    uint contributionAmount;// total ETH
    uint tokensIssued;// total token
    uint bonusAmount;// total bonus token
  }

  enum SaleState  { NEW, SALE, ENDED }
  SaleState private state;

  mapping(address => ContributorData) public contributorList;
  uint private nextContributorIndex;
  uint private nextContributorToClaim;
  uint private nextContributorToTransferTokens;

  mapping(uint => address) private contributorIndexes;
  mapping(address => bool) private hasClaimedEthWhenFail; //address who got a refund
  mapping(address => bool) private hasWithdrawedTokens; //address who got a tokens

  /* Events */
  event CrowdsaleStarted(uint blockNumber);
  event CrowdsaleEnded(uint blockNumber);
  event SoftCapReached(uint blockNumber);
  event HardCapReached(uint blockNumber);
  event FundTransfered(address contrib, uint amount);
  event TokensTransfered(address contributor , uint amount);
  event Refunded(address ref, uint amount);
  event ErrorSendingETH(address to, uint amount);
  event WithdrawedEthToWallet(uint amount);
  event ManualChangeStartDate(uint beforeDate, uint afterDate);
  event ManualChangeEndDate(uint beforeDate, uint afterDate);
  event TokensTransferedToHold(address hold, uint amount);
  event TokensTransferedToOwner(address hold, uint amount);

  function OpportySale(
    address tokenAddress,
    address walletAddress,
    uint start,
    uint end,
    address holdCont,
    address presaleCont )
  {
    token = OpportyToken(tokenAddress);
    state = SaleState.NEW;
    SOFTCAP   = 1000 * 1 ether;
    HARDCAP   = 50000 * 1 ether;
    price     = 0.0002 * 1 ether;
    startDate = start;
    endDate   = end;
    minimalContribution = 0.3 * 1 ether;
    releasedTokens = false;

    wallet = walletAddress;
    holdContract = HoldPresaleContract(holdCont);
    presale = OpportyPresale(presaleCont);
    bonus   = new OpportySaleBonus(start);
  }

  /* Setters */

  function setStartDate(uint date) onlyOwner {
    require(state == SaleState.NEW);
    require(date < endDate);
    uint oldStartDate = startDate;
    startDate = date;
    bonus.changeStartDate(date);
    ManualChangeStartDate(oldStartDate, date);
  }
  function setEndDate(uint date) onlyOwner {
    require(state == SaleState.NEW || state == SaleState.SALE);
    require(date > now && date > startDate);
    uint oldEndDate = endDate;
    endDate = date;
    ManualChangeEndDate(oldEndDate, date);
  }
  function setSoftCap(uint softCap) onlyOwner {
    require(state == SaleState.NEW);
    SOFTCAP = softCap;
  }
  function setHardCap(uint hardCap) onlyOwner {
    require(state == SaleState.NEW);
    HARDCAP = hardCap;
  }

  /* The function without name is the default function that is called whenever anyone sends funds to a contract */
  function() whenNotPaused public payable {
    require(msg.value != 0);

    if (state == SaleState.ENDED) {
      revert();
    }

    bool chstate = checkCrowdsaleState();

    if (state == SaleState.SALE) {
      processTransaction(msg.sender, msg.value);
    }
    else {
      refundTransaction(chstate);
    }
  }

  /**
   * @dev Checks if the goal or time limit has been reached and ends the campaign
   * @return false when contract does not accept tokens
   */
  function checkCrowdsaleState() internal returns (bool){
    if (getEthRaised() >= HARDCAP && state != SaleState.ENDED) {
      state = SaleState.ENDED;
      HardCapReached(block.number); // Close the crowdsale
      CrowdsaleEnded(block.number);
      return true;
    }

    if(now > startDate && now <= endDate) {
      if (state == SaleState.SALE && checkBalanceContract() >= minimumTokensToStart ) {
        return true;
      }
    } else {
      if (state != SaleState.ENDED && now > endDate) {
        state = SaleState.ENDED;
        CrowdsaleEnded(block.number);
        return true;
      }
    }
    return false;
  }

  /**
   * @dev Token purchase
   */
  function processTransaction(address _contributor, uint _amount) internal {

    require(msg.value >= minimalContribution);

    uint maxContribution = calculateMaxContribution();
    uint contributionAmount = _amount;
    uint returnAmount = 0;

    if (maxContribution < _amount) {
      contributionAmount = maxContribution;
      returnAmount = _amount - maxContribution;
    }
    uint ethrai = getEthRaised() ;
    if (ethrai + contributionAmount >= SOFTCAP && SOFTCAP > ethrai) {
      SoftCapReached(block.number);
    }

    if (contributorList[_contributor].isActive == false) {
      contributorList[_contributor].isActive = true;
      contributorList[_contributor].contributionAmount = contributionAmount;
      contributorIndexes[nextContributorIndex] = _contributor;
      nextContributorIndex++;
    } else {
      contributorList[_contributor].contributionAmount += contributionAmount;
    }

    ethRaised += contributionAmount;

    FundTransfered(_contributor, contributionAmount);

    uint tokenAmount  = contributionAmount.div(price);
    uint timeBonus    = bonus.calculateBonusForHours(tokenAmount);

    if (tokenAmount > 0) {
      contributorList[_contributor].tokensIssued += tokenAmount.add(timeBonus);
      contributorList[_contributor].bonusAmount += timeBonus;
      totalTokens += tokenAmount.add(timeBonus);
    }

    if (returnAmount != 0) {
      _contributor.transfer(returnAmount);
    }
  }

  /**
   * @dev It is necessary for a correct change of status in the event of completion of the campaign.
   * @param _stateChanged if true transfer ETH back
   */
  function refundTransaction(bool _stateChanged) internal {
    if (_stateChanged) {
      msg.sender.transfer(msg.value);
    } else{
      revert();
    }
  }

  /**
   * @dev transfer remains tokens after the completion of crowdsale
   */
  function releaseTokens() onlyOwner {
    require (state == SaleState.ENDED);

    uint cbalance = checkBalanceContract();

    require (cbalance != 0);
    require (withdrawedTokens >= totalTokens || getEthRaised() < SOFTCAP);

    if (getEthRaised() >= SOFTCAP) {
      if (releasedTokens == true) {
        if (token.transfer(msg.sender, cbalance ) ) {
          TokensTransferedToOwner(msg.sender , cbalance );
        }
      } else {
        if (token.transfer(holdContract, cbalance ) ) {
          holdContract.addHolder(msg.sender, cbalance, 1, endDate.add(182 days) );
          releasedTokens = true;
          TokensTransferedToHold(holdContract , cbalance );
        }
      }
    } else {
      if (token.transfer(msg.sender, cbalance) ) {
        TokensTransferedToOwner(msg.sender , cbalance );
      }
    }
  }

  function checkBalanceContract() internal returns (uint) {
    return token.balanceOf(this);
  }

  /**
   * @dev if crowdsale is successful, investors can claim token here
   */
  function getTokens() whenNotPaused {
    uint er =  getEthRaised();
    require((now > endDate && er >= SOFTCAP )  || ( er >= HARDCAP)  );
    require(state == SaleState.ENDED);
    require(contributorList[msg.sender].tokensIssued > 0);
    require(!hasWithdrawedTokens[msg.sender]);

    uint tokenCount = contributorList[msg.sender].tokensIssued;

    if (token.transfer(msg.sender, tokenCount * (10 ** 18) )) {
      TokensTransfered(msg.sender , tokenCount * (10 ** 18) );
      withdrawedTokens += tokenCount;
      hasWithdrawedTokens[msg.sender] = true;
    }

  }
  function batchReturnTokens(uint _numberOfReturns) onlyOwner whenNotPaused {
    uint er = getEthRaised();
    require((now > endDate && er >= SOFTCAP )  || (er >= HARDCAP)  );
    require(state == SaleState.ENDED);

    address currentParticipantAddress;
    uint tokensCount;

    for (uint cnt = 0; cnt < _numberOfReturns; cnt++) {
      currentParticipantAddress = contributorIndexes[nextContributorToTransferTokens];
      if (currentParticipantAddress == 0x0) return;
      if (!hasWithdrawedTokens[currentParticipantAddress]) {
        tokensCount = contributorList[currentParticipantAddress].tokensIssued;
        hasWithdrawedTokens[currentParticipantAddress] = true;
        if (token.transfer(currentParticipantAddress, tokensCount * (10 ** 18))) {
          TokensTransfered(currentParticipantAddress, tokensCount * (10 ** 18));
          withdrawedTokens += tokensCount;
          hasWithdrawedTokens[msg.sender] = true;
        }
      }
      nextContributorToTransferTokens += 1;
    }

  }

  /**
   * @dev if crowdsale is unsuccessful, investors can claim refunds here
   */
  function refund() whenNotPaused {
    require(now > endDate && getEthRaised() < SOFTCAP);
    require(contributorList[msg.sender].contributionAmount > 0);
    require(!hasClaimedEthWhenFail[msg.sender]);

    uint ethContributed = contributorList[msg.sender].contributionAmount;
    hasClaimedEthWhenFail[msg.sender] = true;
    if (!msg.sender.send(ethContributed)) {
      ErrorSendingETH(msg.sender, ethContributed);
    } else {
      Refunded(msg.sender, ethContributed);
    }
  }
  function batchReturnEthIfFailed(uint _numberOfReturns) onlyOwner whenNotPaused {
    require(now > endDate && getEthRaised() < SOFTCAP);
    address currentParticipantAddress;
    uint contribution;
    for (uint cnt = 0; cnt < _numberOfReturns; cnt++) {
      currentParticipantAddress = contributorIndexes[nextContributorToClaim];
      if (currentParticipantAddress == 0x0) return;
      if (!hasClaimedEthWhenFail[currentParticipantAddress]) {
        contribution = contributorList[currentParticipantAddress].contributionAmount;
        hasClaimedEthWhenFail[currentParticipantAddress] = true;

        if (!currentParticipantAddress.send(contribution)){
          ErrorSendingETH(currentParticipantAddress, contribution);
        } else {
          Refunded(currentParticipantAddress, contribution);
        }
      }
      nextContributorToClaim += 1;
    }
  }

  /**
   * @dev transfer funds ETH to multisig wallet if reached minimum goal
   */
  function withdrawEth() {
    require(this.balance != 0);
    require(getEthRaised() >= SOFTCAP);
    require(msg.sender == wallet);
    uint bal = this.balance;
    wallet.transfer(bal);
    WithdrawedEthToWallet(bal);
  }

  function withdrawRemainingBalanceForManualRecovery() onlyOwner {
    require(this.balance != 0);
    require(now > endDate);
    require(contributorIndexes[nextContributorToClaim] == 0x0);
    msg.sender.transfer(this.balance);
  }

  /**
   * @dev Manual start crowdsale.
   */
  function startCrowdsale() onlyOwner  {
    require(now > startDate && now <= endDate);
    require(state == SaleState.NEW);
    require(checkBalanceContract() >= minimumTokensToStart);

    state = SaleState.SALE;
    CrowdsaleStarted(block.number);
  }

  /* Getters */

  function getAccountsNumber() constant returns (uint) {
    return nextContributorIndex;
  }

  function getEthRaised() constant returns (uint) {
    uint pre = presale.getEthRaised();
    return pre + ethRaised;
  }

  function getTokensTotal() constant returns (uint) {
    return totalTokens;
  }

  function getWithdrawedToken() constant returns (uint) {
    return withdrawedTokens;
  }

  function calculateMaxContribution() constant returns (uint) {
    return HARDCAP - getEthRaised();
  }

  function getSoftCap() constant returns(uint) {
    return SOFTCAP;
  }

  function getHardCap() constant returns(uint) {
    return HARDCAP;
  }

  function getSaleStatus() constant returns (uint) {
    return uint(state);
  }

  function getStartDate() constant returns (uint) {
    return startDate;
  }

  function getEndDate() constant returns (uint) {
    return endDate;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endDate || state == SaleState.ENDED;
  }

  function getTokenBalance() constant returns (uint) {
    return token.balanceOf(this);
  }

  /**
   * @dev return current bonus percent
   */
  function getCurrentBonus() public constant returns (uint) {
    if(now > endDate || state == SaleState.ENDED) {
      return 0;
    }
    return bonus.getBonus();
  }
}