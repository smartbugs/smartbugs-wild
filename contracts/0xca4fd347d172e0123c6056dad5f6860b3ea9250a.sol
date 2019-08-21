pragma solidity ^0.4.18;

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
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
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

contract OpportyYearHold is Pausable {
  using SafeMath for uint256;
  OpportyToken public token;

  uint public holdPeriod;
  address public multisig;

  // start and end timestamps where investments are allowed
  uint public startDate;
  uint public endDate;
  uint public endSaleDate;

  uint private price;

  uint public minimalContribution;

  // total ETH collected
  uint public ethRaised;

  enum SaleState { NEW, SALE, ENDED }
  SaleState public state;

  mapping (uint => address) private assetOwners;
  mapping (address => uint) private assetOwnersIndex;
  uint public assetOwnersIndexes;

  struct Bonus {
    uint minAmount;
    uint maxAmount;
    uint8 bonus;
  }

  Bonus[]  bonuses;

  struct Holder {
    bool isActive;
    uint tokens;
    uint holdPeriodTimestamp;
    bool withdrawed;
  }

  mapping(address => Holder) public holderList;
  mapping(uint => address) private holderIndexes;
  uint private holderIndex;


  event TokensTransfered(address contributor , uint amount);
  event Hold(address sender, address contributor, uint amount, uint8 holdPeriod);
  event ManualChangeStartDate(uint beforeDate, uint afterDate);
  event ManualChangeEndDate(uint beforeDate, uint afterDate);
  event ChangeMinAmount(uint oldMinAmount, uint minAmount);
  event BonusChanged(uint minAmount, uint maxAmount, uint8 newBonus);
  event HolderAdded(address addr, uint contribution, uint tokens, uint holdPeriodTimestamp);
  event FundsTransferredToMultisig(address multisig, uint value);
  event SaleNew();
  event SaleStarted();
  event SaleEnded();
  event ManualPriceChange(uint beforePrice, uint afterPrice);
  event HoldChanged(address holder, uint tokens, uint timest);
  event TokenChanged(address newAddress);

  modifier onlyAssetsOwners() {
    require(assetOwnersIndex[msg.sender] > 0 || msg.sender == owner);
    _;
  }

  function OpportyYearHold(address walletAddress, uint start, uint end, uint endSale) public {
    holdPeriod = 1 years;
    state = SaleState.NEW;

    startDate = start;
    endDate   = end;
    endSaleDate = endSale;
    price = 0.0002 * 1 ether;
    multisig = walletAddress;
    minimalContribution = 0.3 * 1 ether;

    bonuses.push(Bonus({minAmount: 0, maxAmount: 50, bonus: 35 }));
    bonuses.push(Bonus({minAmount: 50, maxAmount: 100, bonus: 40 }));
    bonuses.push(Bonus({minAmount: 100, maxAmount: 250, bonus: 45 }));
    bonuses.push(Bonus({minAmount: 250, maxAmount: 500, bonus: 50 }));
    bonuses.push(Bonus({minAmount: 500, maxAmount: 1000, bonus: 70 }));
    bonuses.push(Bonus({minAmount: 1000, maxAmount: 5000, bonus: 80 }));
    bonuses.push(Bonus({minAmount: 5000, maxAmount: 99999999, bonus: 90 }));
  }

  function changeBonus(uint minAmount, uint maxAmount, uint8 newBonus) public {
    bool find = false;
    for (uint i = 0; i < bonuses.length; ++i) {
      if (bonuses[i].minAmount == minAmount && bonuses[i].maxAmount == maxAmount ) {
        bonuses[i].bonus = newBonus;
        find = true;
        break;
      }
    }
    if (!find) {
      bonuses.push(Bonus({minAmount:minAmount, maxAmount: maxAmount, bonus:newBonus}));
    }
    BonusChanged(minAmount, maxAmount, newBonus);
  }

  function getBonus(uint am) public view returns(uint8) {
    uint8 bon = 0;
    am /= 10 ** 18;

    for (uint i = 0; i < bonuses.length; ++i) {
      if (am >= bonuses[i].minAmount && am<bonuses[i].maxAmount)
        bon = bonuses[i].bonus;
    }

    return bon;
  }

  function() public payable {
    require(state == SaleState.SALE);
    require(msg.value >= minimalContribution);
    require(now >= startDate);

    if (now > endDate) {
      state = SaleState.ENDED;
      msg.sender.transfer(msg.value);
      SaleEnded();
      return ;
    }

    uint tokenAmount = msg.value.div(price);
    tokenAmount += tokenAmount.mul(getBonus(msg.value)).div(100);
    tokenAmount *= 10 ** 18;

    uint holdTimestamp = endSaleDate.add(holdPeriod);
    addHolder(msg.sender, tokenAmount, holdTimestamp);
    HolderAdded(msg.sender, msg.value, tokenAmount, holdTimestamp);

    forwardFunds();

  }

  function addHolder(address holder, uint tokens, uint timest) internal {
    if (holderList[holder].isActive == false) {
      holderList[holder].isActive = true;
      holderList[holder].tokens = tokens;
      holderList[holder].holdPeriodTimestamp = timest;
      holderIndexes[holderIndex] = holder;
      holderIndex++;
    } else {
      holderList[holder].tokens += tokens;
      holderList[holder].holdPeriodTimestamp = timest;
    }
  }

  function changeHold(address holder, uint tokens, uint timest) onlyAssetsOwners public {
    if (holderList[holder].isActive == true) {
      holderList[holder].tokens = tokens;
      holderList[holder].holdPeriodTimestamp = timest;
      HoldChanged(holder, tokens, timest);
    }
  }

  function forwardFunds() internal {
    ethRaised += msg.value;
    multisig.transfer(msg.value);
    FundsTransferredToMultisig(multisig, msg.value);
  }

  function newPresale() public onlyOwner {
    state = SaleState.NEW;
    SaleNew();
  }

  function startPresale() public onlyOwner {
    state = SaleState.SALE;
    SaleStarted();
  }

  function endPresale() public onlyOwner {
    state = SaleState.ENDED;
    SaleEnded();
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

  function getBalance() public constant returns (uint) {
    return token.balanceOf(this);
  }

  function returnTokens(uint nTokens) public onlyOwner returns (bool) {
    require(nTokens <= getBalance());
    token.transfer(msg.sender, nTokens);
    TokensTransfered(msg.sender, nTokens);
    return true;
  }

  function unlockTokens() public returns (bool) {
    require(holderList[msg.sender].isActive);
    require(!holderList[msg.sender].withdrawed);
    require(now >= holderList[msg.sender].holdPeriodTimestamp);

    token.transfer(msg.sender, holderList[msg.sender].tokens);
    holderList[msg.sender].withdrawed = true;
    TokensTransfered(msg.sender, holderList[msg.sender].tokens);
    return true;
  }

  function setStartDate(uint date) public onlyOwner {
    uint oldStartDate = startDate;
    startDate = date;
    ManualChangeStartDate(oldStartDate, date);
  }

  function setEndSaleDate(uint date) public onlyOwner {
    uint oldEndDate = endSaleDate;
    endSaleDate = date;
    ManualChangeEndDate(oldEndDate, date);
  }

  function setEndDate(uint date) public onlyOwner {
    uint oldEndDate = endDate;
    endDate = date;
    ManualChangeEndDate(oldEndDate, date);
  }

  function setPrice(uint newPrice) public onlyOwner {
    uint oldPrice = price;
    price = newPrice;
    ManualPriceChange(oldPrice, newPrice);
  }

  function setMinimalContribution(uint minimumAmount) public onlyOwner {
    uint oldMinAmount = minimalContribution;
    minimalContribution = minimumAmount;
    ChangeMinAmount(oldMinAmount, minimalContribution);
  }

  function batchChangeHoldPeriod(uint holdedPeriod) public onlyAssetsOwners {
    for (uint i = 0; i < holderIndex; ++i) {
      holderList[holderIndexes[i]].holdPeriodTimestamp = holdedPeriod;
      HoldChanged(holderIndexes[i], holderList[holderIndexes[i]].tokens, holdedPeriod);
    }
  }

  function setToken(address newToken) public onlyOwner {
    token = OpportyToken(newToken);
    TokenChanged(token);
  }

  function getTokenAmount() public view returns (uint) {
    uint tokens = 0;
    for (uint i = 0; i < holderIndex; ++i) {
      if (!holderList[holderIndexes[i]].withdrawed) {
        tokens += holderList[holderIndexes[i]].tokens;
      }
    }
    return tokens;
  }

  function getEthRaised() constant external returns (uint) {
    return ethRaised;
  }

}