pragma solidity ^0.4.18;

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
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

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
  function OpportyToken() public {
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
  function HoldPresaleContract(address _OppToken) public {
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

  function getBalance() public constant returns (uint) {
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
    address holdCont ) public
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

  function getBalanceContract() view internal returns (uint) {
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

  function withdrawEth() public {
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

  function getTokenBalance() public constant returns (uint) {
    return token.balanceOf(this);
  }

  function getEthRaised() constant external returns (uint) {
    return ethRaised;
  }
}

contract OpportyPresale2 is Pausable {
  using SafeMath for uint256;

  OpportyToken public token;

  HoldPresaleContract public holdContract;
  OpportyPresale      public preSaleContract;

  enum SaleState  { NEW, SALE, ENDED }
  SaleState public state;

  uint public endDate;
  uint public endSaleDate;
  uint public minimalContribution;

  // address where funds are collected
  address private wallet;

  address private preSaleOld;

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
  event AddedToHolder(address sender, uint tokenAmount, uint8 holdPeriod, uint holdTimestamp);
  event ChangeMinAmount(uint oldMinAmount, uint minAmount);

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

  mapping (uint => address) private assetOwners;
  mapping (address => uint) private assetOwnersIndex;
  uint public assetOwnersIndexes;

  modifier onlyAssetsOwners() {
    require(assetOwnersIndex[msg.sender] > 0);
    _;
  }

  /* constructor */
  function OpportyPresale2(
    address tokenAddress,
    address walletAddress,
    uint end,
    uint endSale,
    address holdCont,
    address oldPreSale) public
  {
    token = OpportyToken(tokenAddress);
    state = SaleState.NEW;

    endDate     = end;
    endSaleDate = endSale;
    price       = 0.0002 * 1 ether;
    wallet      = walletAddress;
    minimalContribution = 0.3 * 1 ether;

    preSaleContract = OpportyPresale(oldPreSale);
    holdContract = HoldPresaleContract(holdCont);
    addAssetsOwner(msg.sender);
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

  function addToWhitelist(address inv, uint amount, uint8 holdPeriod, uint8 bonus) public onlyAssetsOwners {
    require(state == SaleState.NEW || state == SaleState.SALE);
    require(holdPeriod == 1 || holdPeriod == 3 || holdPeriod == 6 || holdPeriod == 12);
    require(amount >= minimalContribution);

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
    require(msg.value >= minimalContribution);
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

    // forward the funds to the wallet
    forwardFunds();
  }

  /**
     * send ether to the fund collection wallet
     * override to create custom fund forwarding mechanisms
     */
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }


  function getBalanceContract() view internal returns (uint) {
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

  function withdrawEth() public {
    require(this.balance != 0);
    require(state == SaleState.ENDED);
    require(msg.sender == wallet);
    require(tokensTransferredToHold == true);
    uint bal = this.balance;
    wallet.transfer(bal);
    WithdrawedEthToWallet(bal);
  }

  function setEndSaleDate(uint date) public onlyOwner {
    require(state == SaleState.NEW || state == SaleState.SALE);
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

  function setMinimalContribution(uint minimumAmount) public onlyOwner {
    uint oldMinAmount = minimalContribution;
    minimalContribution = minimumAmount;
    ChangeMinAmount(oldMinAmount, minimalContribution);
  }

  function getTokenBalance() public constant returns (uint) {
    return token.balanceOf(this);
  }

  function getEthRaised() constant external returns (uint) {
    uint pre = preSaleContract.getEthRaised();
    return pre + ethRaised;
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