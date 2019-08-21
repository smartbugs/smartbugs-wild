pragma solidity ^0.4.24;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Transfer {
  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate
 * behavior.
 */
contract Crowdsale is Ownable {
  using SafeMath for uint256;
  using SafeERC20Transfer for IERC20;

  // The token being sold
  IERC20 private _token;

  // Address where funds are collected
  address private _wallet;

  // How many token units a buyer gets per 1 ETH.
  uint256 private _rate = 5000;

  // Amount of wei raised
  uint256 private _weiRaised;

  // Accrued tokens amount
  uint256 private _accruedTokensAmount;

  // freezing periods in seconds
  uint256 private _threeMonths = 5256000;
  uint256 private _sixMonths = 15768000;
  uint256 private _nineMonths = 21024000;
  uint256 private _twelveMonths = 31536000;

  // ICO configuration
  uint256 private _foundersTokens = 4e7;
  uint256 private _distributedTokens = 1e9;
  uint256 public softCap = 1000 ether;
  uint256 public hardCap = 35000 ether;
  uint256 public preICO_1_Start = 1541030400; // 01/11/2018 00:00:00
  uint256 public preICO_2_Start = 1541980800; // 12/11/2018 00:00:00
  uint256 public preICO_3_Start = 1542844800; // 22/11/2018 00:00:00
  uint256 public ICO_Start = 1543622400; // 01/12/2018 00:00:00
  uint256 public ICO_End = 1548979199; // 31/01/2019 23:59:59
  uint32 public bonus1 = 30; // pre ICO phase 1
  uint32 public bonus2 = 20; // pre ICO phase 2
  uint32 public bonus3 = 10; // pre ICO phase 3
  uint32 public whitelistedBonus = 10;

  mapping (address => bool) private _whitelist;

  // tokens accrual
  mapping (address => uint256) public threeMonthsFreezingAccrual;
  mapping (address => uint256) public sixMonthsFreezingAccrual;
  mapping (address => uint256) public nineMonthsFreezingAccrual;
  mapping (address => uint256) public twelveMonthsFreezingAccrual;

  // investors ledger
  mapping (address => uint256) public ledger;

  /**
   * Event for tokens accrual logging
   * @param to who tokens where accrued to
   * @param accruedAmount amount of tokens accrued
   * @param freezingTime period for freezing in seconds
   * @param purchasedAmount amount of tokens purchased
   * @param weiValue amount of ether contributed
   */
  event Accrual(
    address to,
    uint256 accruedAmount,
    uint256 freezingTime,
    uint256 purchasedAmount,
    uint256 weiValue
  );

  /**
   * Event for accrued tokens releasing logging
   * @param to who tokens where release to
   * @param amount amount of tokens released
   */
  event Released(
    address to,
    uint256 amount
  );

  /**
   * Event for refund logging
   * @param to who have got refund
   * @param value ether refunded
   */
  event Refunded(
    address to,
    uint256 value
  );

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokensPurchased(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @dev The rate is the conversion between wei and the smallest and indivisible
   * token unit. So, if you are using a rate of 1 with a ERC20Detailed token
   * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.
   * @param wallet Address where collected funds will be forwarded to
   * @param founders Address for founders tokens accrual
   * @param token Address of the token being sold
   */
  constructor(address newOwner, address wallet, address founders, IERC20 token) public {
    require(wallet != address(0));
    require(founders != address(0));
    require(token != address(0));
    require(newOwner != address(0));
    transferOwnership(newOwner);

    _wallet = wallet;
    _token = token;

    twelveMonthsFreezingAccrual[founders] = _foundersTokens;
    _accruedTokensAmount = _foundersTokens;
    emit Accrual(founders, _foundersTokens, _twelveMonths, 0, 0);
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @return the token being sold.
   */
  function token() public view returns(IERC20) {
    return _token;
  }

  /**
   * @return the address where funds are collected.
   */
  function wallet() public view returns(address) {
    return _wallet;
  }

  /**
   * @return the number of token units a buyer gets per wei.
   */
  function rate() public view returns(uint256) {
    return _rate;
  }

  /**
   * @return the amount of wei raised.
   */
  function weiRaised() public view returns (uint256) {
    return _weiRaised;
  }

  /**
   * @return if who is whitelisted.
   * @param who investors address
   */
  function whitelist(address who) public view returns (bool) {
    return _whitelist[who];
  }

  /**
   * add investor to whitelist
   * @param who investors address
   */
  function addToWhitelist(address who) public onlyOwner {
    _whitelist[who] = true;
  }

  /**
   * remove investor from whitelist
   * @param who investors address
   */
  function removeFromWhitelist(address who) public onlyOwner {
    _whitelist[who] = false;
  }

  /**
   * Accrue bonuses to advisors
   * @param to address for accrual
   * @param amount tokem amount
   */
  function accrueAdvisorsTokens(address to, uint256 amount) public onlyOwner {
    require(now > ICO_End);
    uint256 tokenBalance = _token.balanceOf(address(this));
    require(tokenBalance >= _accruedTokensAmount.add(amount));

    _accruedTokensAmount = _accruedTokensAmount.add(amount);
    
    sixMonthsFreezingAccrual[to] = sixMonthsFreezingAccrual[to].add(amount);

    emit Accrual(to, amount, _sixMonths, 0, 0);    
  }

  /**
   * Accrue bonuses to partners
   * @param to address for accrual
   * @param amount tokem amount
   */
  function accruePartnersTokens(address to, uint256 amount) public onlyOwner {
    require(now > ICO_End);
    uint256 tokenBalance = _token.balanceOf(address(this));
    require(tokenBalance >= _accruedTokensAmount.add(amount));

    _accruedTokensAmount = _accruedTokensAmount.add(amount);
    
    nineMonthsFreezingAccrual[to] = nineMonthsFreezingAccrual[to].add(amount);

    emit Accrual(to, amount, _nineMonths, 0, 0);    
  }

  /**
   * Accrue bounty and airdrop bonuses
   * @param to address for accrual
   * @param amount tokem amount
   */
  function accrueBountyTokens(address to, uint256 amount) public onlyOwner {
    require(now > ICO_End);
    uint256 tokenBalance = _token.balanceOf(address(this));
    require(tokenBalance >= _accruedTokensAmount.add(amount));

    _accruedTokensAmount = _accruedTokensAmount.add(amount);
    
    twelveMonthsFreezingAccrual[to] = twelveMonthsFreezingAccrual[to].add(amount);

    emit Accrual(to, amount, _twelveMonths, 0, 0);    
  }

  /**
   * release accrued tokens
   */
  function release() public {
    address who = msg.sender;
    uint256 amount;
    if (now > ICO_End.add(_twelveMonths) && twelveMonthsFreezingAccrual[who] > 0) {
      amount = amount.add(twelveMonthsFreezingAccrual[who]);
      _accruedTokensAmount = _accruedTokensAmount.sub(twelveMonthsFreezingAccrual[who]);
      twelveMonthsFreezingAccrual[who] = 0;
    }
    if (now > ICO_End.add(_nineMonths) && nineMonthsFreezingAccrual[who] > 0) {
      amount = amount.add(nineMonthsFreezingAccrual[who]);
      _accruedTokensAmount = _accruedTokensAmount.sub(nineMonthsFreezingAccrual[who]);
      nineMonthsFreezingAccrual[who] = 0;
    }
    if (now > ICO_End.add(_sixMonths) && sixMonthsFreezingAccrual[who] > 0) {
      amount = amount.add(sixMonthsFreezingAccrual[who]);
      _accruedTokensAmount = _accruedTokensAmount.sub(sixMonthsFreezingAccrual[who]);
      sixMonthsFreezingAccrual[who] = 0;
    }
    if (now > ICO_End.add(_threeMonths) && threeMonthsFreezingAccrual[who] > 0) {
      amount = amount.add(threeMonthsFreezingAccrual[who]);
      _accruedTokensAmount = _accruedTokensAmount.sub(threeMonthsFreezingAccrual[who]);
      threeMonthsFreezingAccrual[who] = 0;
    }
    if (amount > 0) {
      _deliverTokens(who, amount);
      emit Released(who, amount);
    }
  }

  /**
   * refund ether
   */
  function refund() public {
    address investor = msg.sender;
    require(now > ICO_End);
    require(_weiRaised < softCap);
    require(ledger[investor] > 0);
    uint256 value = ledger[investor];
    ledger[investor] = 0;
    investor.transfer(value);
    emit Refunded(investor, value);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param beneficiary Address performing the token purchase
   */
  function buyTokens(address beneficiary) public payable {
    uint256 weiAmount = msg.value;
    _preValidatePurchase(beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // bonus tokens accrual and ensure token balance is enough for accrued tokens release
    _accrueBonusTokens(beneficiary, tokens, weiAmount);

    // update state
    _weiRaised = _weiRaised.add(weiAmount);

    _processPurchase(beneficiary, tokens);
    emit TokensPurchased(
      msg.sender,
      beneficiary,
      weiAmount,
      tokens
    );

    if (_weiRaised >= softCap) _forwardFunds();

    ledger[msg.sender] = ledger[msg.sender].add(msg.value);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

    /**
   * @dev Accrue bonus tokens.
   * @param beneficiary Address for tokens accrual
   * @param tokenAmount amount of tokens that beneficiary get
   */
  function _accrueBonusTokens(address beneficiary, uint256 tokenAmount, uint256 weiAmount) internal {
    uint32 bonus = 0;
    uint256 bonusTokens = 0;
    uint256 tokenBalance = _token.balanceOf(address(this));
    if (_whitelist[beneficiary] && now < ICO_Start) bonus = bonus + whitelistedBonus;
    if (now < preICO_2_Start) {
      bonus = bonus + bonus1;
      bonusTokens = tokenAmount.mul(bonus).div(100);

      require(tokenBalance >= _accruedTokensAmount.add(bonusTokens).add(tokenAmount));

      _accruedTokensAmount = _accruedTokensAmount.add(bonusTokens);

      nineMonthsFreezingAccrual[beneficiary] = nineMonthsFreezingAccrual[beneficiary].add(bonusTokens);

      emit Accrual(beneficiary, bonusTokens, _nineMonths, tokenAmount, weiAmount);
    } else if (now < preICO_3_Start) {
      bonus = bonus + bonus2;
      bonusTokens = tokenAmount.mul(bonus).div(100);

      require(tokenBalance >= _accruedTokensAmount.add(bonusTokens).add(tokenAmount));

      _accruedTokensAmount = _accruedTokensAmount.add(bonusTokens);
      
      sixMonthsFreezingAccrual[beneficiary] = sixMonthsFreezingAccrual[beneficiary].add(bonusTokens);

      emit Accrual(beneficiary, bonusTokens, _sixMonths, tokenAmount, weiAmount);
    } else if (now < ICO_Start) {
      bonus = bonus + bonus3;
      bonusTokens = tokenAmount.mul(bonus).div(100);

      require(tokenBalance >= _accruedTokensAmount.add(bonusTokens).add(tokenAmount));

      _accruedTokensAmount = _accruedTokensAmount.add(bonusTokens);
      
      threeMonthsFreezingAccrual[beneficiary] = threeMonthsFreezingAccrual[beneficiary].add(bonusTokens);

      emit Accrual(beneficiary, bonusTokens, _threeMonths, tokenAmount, weiAmount);
    } else {
      require(tokenBalance >= _accruedTokensAmount.add(tokenAmount));

      emit Accrual(beneficiary, 0, 0, tokenAmount, weiAmount);
    }
  }

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
   * Example from CappedCrowdsale.sol's _preValidatePurchase method:
   *   super._preValidatePurchase(beneficiary, weiAmount);
   *   require(weiRaised().add(weiAmount) <= cap);
   * @param beneficiary Address performing the token purchase
   * @param weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal view
  {
    require(beneficiary != address(0));
    require(weiAmount != 0);
    require(_weiRaised.add(weiAmount) <= hardCap);
    require(now >= preICO_1_Start);
    require(now <= ICO_End);
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param beneficiary Address performing the token purchase
   * @param tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address beneficiary,
    uint256 tokenAmount
  )
    internal
  {
    _token.safeTransfer(beneficiary, tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param beneficiary Address receiving the tokens
   * @param tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address beneficiary,
    uint256 tokenAmount
  )
    internal
  {
    _deliverTokens(beneficiary, tokenAmount);
  }

  /**
   * @dev The way in which ether is converted to tokens.
   * @param weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(
    uint256 weiAmount
  )
    internal view returns (uint256)
  {
    return weiAmount.mul(_rate).div(1e18);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    uint256 balance = address(this).balance;
    _wallet.transfer(balance);
  }
}