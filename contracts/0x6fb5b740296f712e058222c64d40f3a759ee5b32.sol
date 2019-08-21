pragma solidity ^0.4.18;

// File: src/Token/FallbackToken.sol

/**
 * @title FallbackToken token
 *
 * @dev add ERC223 standard ability
 **/
contract FallbackToken {

  function isContract(address _addr) internal constant returns (bool) {
    uint length;
    _addr = _addr;
    assembly {length := extcodesize(_addr)}
    return (length > 0);
  }
}


contract Receiver {
  function tokenFallback(address from, uint value) public;
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: zeppelin-solidity/contracts/token/ERC20Basic.sol

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

// File: zeppelin-solidity/contracts/token/BasicToken.sol

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

// File: zeppelin-solidity/contracts/token/ERC20.sol

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

// File: zeppelin-solidity/contracts/token/StandardToken.sol

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

// File: zeppelin-solidity/contracts/token/MintableToken.sol

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

// File: src/Token/TrustaBitToken.sol

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract TrustaBitToken is MintableToken, FallbackToken {

  string public constant name = "TrustaBits";

  string public constant symbol = "TAB";

  uint256 public constant decimals = 18;

  bool public released = false;

  event Release();

  modifier isReleased () {
    require(mintingFinished);
    require(released);
    _;
  }

  /**
    * Fix for the ERC20 short address attack
    * http://vessenes.com/the-erc20-short-address-attack-explained/
    */
  modifier onlyPayloadSize(uint size) {
    if (msg.data.length != size + 4) {
      revert();
    }
    _;
  }

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.K
   */
  /// function TrustaBitsToken() public {}

  /**
   * @dev Fallback method will buyout tokens
   */
  function() public payable {
    revert();
  }

  function release() onlyOwner public returns (bool) {
    require(mintingFinished);
    require(!released);
    released = true;
    Release();

    return true;
  }

  function transfer(address _to, uint256 _value) public isReleased onlyPayloadSize(2 * 32) returns (bool) {
    require(super.transfer(_to, _value));

    if (isContract(_to)) {
      Receiver(_to).tokenFallback(msg.sender, _value);
    }

    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public isReleased returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public isReleased returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public isReleased onlyPayloadSize(2 * 32) returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public isReleased returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }

}

// File: src/Crowdsale/MilestoneCrowdsale.sol

contract MilestoneCrowdsale {

  using SafeMath for uint256;

  /* Number of available tokens */
  uint256 public constant AVAILABLE_TOKENS = 1e9; //1 billion

  /* Total Tokens available in PreSale */
  uint256 public constant AVAILABLE_IN_PRE_SALE = 40e6; // 40,000,000

  /* Total Tokens available in Main ICO */
  uint256 public constant AVAILABLE_IN_MAIN = 610e6; // 610,000,000;

  /* Early Investors token available */
  uint256 public constant AVAILABLE_FOR_EARLY_INVESTORS = 100e6; // 100,000,000;

  /* Pre-Sale Start Date */
  uint public preSaleStartDate;

  /* Pre-Sale End Date */
  uint public preSaleEndDate;

  /* Main Token Sale Date */
  uint public mainSaleStartDate;

  /* Main Token Sale End */
  uint public mainSaleEndDate;

  struct Milestone {
    uint start; // UNIX timestamp
    uint end; // UNIX timestamp
    uint256 bonus;
    uint256 price;
  }

  Milestone[] public milestones;

  uint256 public rateUSD; // (cents)

  uint256 public earlyInvestorTokenRaised;
  uint256 public preSaleTokenRaised;
  uint256 public mainSaleTokenRaised;


  function initMilestones(uint _rate, uint _preSaleStartDate, uint _preSaleEndDate, uint _mainSaleStartDate, uint _mainSaleEndDate) internal {
    rateUSD = _rate;
    preSaleStartDate = _preSaleStartDate;
    preSaleEndDate = _preSaleEndDate;
    mainSaleStartDate = _mainSaleStartDate;
    mainSaleEndDate = _mainSaleEndDate;

    /**
     * Early investor Milestone
     * Prise: $0.025 USD (2.5 cent)
     * No bonuses
     */
    uint256 earlyInvestorPrice = ((25 * 1 ether) / (rateUSD * 10));
    milestones.push(Milestone(now, preSaleStartDate, 0, earlyInvestorPrice));

    /**
     * Pre-Sale Milestone
     * Prise: $0.05 USD (5 cent)
     * Bonus: 20%
     */
    uint256 preSalePrice = usdToEther(5);
    milestones.push(Milestone(preSaleStartDate, preSaleEndDate, 20, preSalePrice));

    /**
     * Main Milestones
     * Prise: $0.10 USD (10 cent)
     * Week 1 Bonus: 15%
     * Week 2 Main Token Sale Bonus: 10%
     * Week 3 Main Token Sale Bonus: 5%
     */
    uint256 mainSalePrice = usdToEther(10);
    uint mainSaleStartDateWeek1 = mainSaleStartDate + 1 weeks;
    uint mainSaleStartDateWeek3 = mainSaleStartDate + 3 * 1 weeks;
    uint mainSaleStartDateWeek2 = mainSaleStartDate + 2 * 1 weeks;

    milestones.push(Milestone(mainSaleStartDate, mainSaleStartDateWeek1, 15, mainSalePrice));
    milestones.push(Milestone(mainSaleStartDateWeek1, mainSaleStartDateWeek2, 10, mainSalePrice));
    milestones.push(Milestone(mainSaleStartDateWeek2, mainSaleStartDateWeek3, 5, mainSalePrice));
    milestones.push(Milestone(mainSaleStartDateWeek3, _mainSaleEndDate, 0, mainSalePrice));
  }

  function usdToEther(uint256 usdValue) public view returns (uint256) {
    // (usdValue * 1 ether / rateUSD)
    return usdValue.mul(1 ether).div(rateUSD);
  }

  function getCurrentMilestone() internal view returns (uint256, uint256) {
    for (uint i = 0; i < milestones.length; i++) {
      if (now >= milestones[i].start && now < milestones[i].end) {
        var milestone = milestones[i];
        return (milestone.bonus, milestone.price);
      }
    }

    return (0, 0);
  }

  function getCurrentPrice() public view returns (uint256) {
    var (, price) = getCurrentMilestone();

    return price;
  }

  function getTokenRaised() public view returns (uint256) {
    return mainSaleTokenRaised.add(preSaleTokenRaised.add(earlyInvestorTokenRaised));
  }

  function isEarlyInvestors() public view returns (bool) {
    return now < preSaleStartDate;
  }

  function isPreSale() public view returns (bool) {
    return now >= preSaleStartDate && now < preSaleEndDate;
  }

  function isMainSale() public view returns (bool) {
    return now >= mainSaleStartDate && now < mainSaleEndDate;
  }

  function isEnded() public view returns (bool) {
    return now >= mainSaleEndDate;
  }

}

// File: zeppelin-solidity/contracts/crowdsale/RefundVault.sol

/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function RefundVault(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}

// File: src/Crowdsale/TrustaBitCrowdsale.sol

contract TrustaBitCrowdsale is MilestoneCrowdsale, Ownable {

  using SafeMath for uint256;

  /* Minimum contribution */
  uint public constant MINIMUM_CONTRIBUTION = 3 ether;

  /* Soft cap */
  uint public constant softCapUSD = 3e6; //$3 Million USD
  uint public softCap; //$3 Million USD in ETH

  /* Hard Cap */
  uint public constant hardCapUSD = 49e6; //$49 Million USD
  uint public hardCap; //$49 Million USD in ETH

  /* Advisory Bounty Team */
  address public addressAdvisoryBountyTeam;
  uint256 public constant tokenAdvisoryBountyTeam = 250e6;

  address[] public investors;

  TrustaBitToken public token;

  address public wallet;

  uint256 public weiRaised;

  RefundVault public vault;

  bool public isFinalized = false;

  event Finalized();

  /**
   * event for token purchase logging
   * @param investor who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed investor, uint256 value, uint256 amount);

  modifier hasMinimumContribution() {
    require(msg.value >= MINIMUM_CONTRIBUTION);
    _;
  }

  function TrustaBitCrowdsale(address _wallet, address _token, uint _rate, uint _preSaleStartDate, uint _preSaleEndDate, uint _mainSaleStartDate, uint _mainSaleEndDate, address _AdvisoryBountyTeam) public {
    require(_token != address(0));
    require(_AdvisoryBountyTeam != address(0));
    require(_rate > 0);
    require(_preSaleStartDate > 0);
    require(_preSaleEndDate > 0);
    require(_preSaleEndDate > _preSaleStartDate);
    require(_mainSaleStartDate > 0);
    require(_mainSaleStartDate >= _preSaleEndDate);
    require(_mainSaleEndDate > 0);
    require(_mainSaleEndDate > _mainSaleStartDate);

    wallet = _wallet;
    token = TrustaBitToken(_token);
    addressAdvisoryBountyTeam = _AdvisoryBountyTeam;

    initMilestones(_rate, _preSaleStartDate, _preSaleEndDate, _mainSaleStartDate, _mainSaleEndDate);

    softCap = usdToEther(softCapUSD.mul(100));
    hardCap = usdToEther(hardCapUSD.mul(100));

    vault = new RefundVault(wallet);
  }

  function investorsCount() public constant returns (uint) {
    return investors.length;
  }

  // fallback function can be used to buy tokens
  function() external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address investor) public hasMinimumContribution payable {
    require(investor != address(0));
    require(!isEnded());

    uint256 weiAmount = msg.value;

    require(getCurrentPrice() > 0);

    uint256 tokensAmount = calculateTokens(weiAmount);
    require(tokensAmount > 0);

    mintTokens(investor, weiAmount, tokensAmount);
    increaseRaised(weiAmount, tokensAmount);

    if (vault.deposited(investor) == 0) {
      investors.push(investor);
    }
    // send ether to the fund collection wallet
    vault.deposit.value(weiAmount)(investor);
  }

  function calculateTokens(uint256 weiAmount) internal view returns (uint256) {
    if ((weiRaised.add(weiAmount)) > hardCap) return 0;

    var (bonus, price) = getCurrentMilestone();

    uint256 tokensAmount = weiAmount.div(price).mul(10 ** token.decimals());
    tokensAmount = tokensAmount.add(tokensAmount.mul(bonus).div(100));

    if (isEarlyInvestorsTokenRaised(tokensAmount)) return 0;
    if (isPreSaleTokenRaised(tokensAmount)) return 0;
    if (isMainSaleTokenRaised(tokensAmount)) return 0;
    if (isTokenAvailable(tokensAmount)) return 0;

    return tokensAmount;
  }

  function isEarlyInvestorsTokenRaised(uint256 tokensAmount) public view returns (bool) {
    return isEarlyInvestors() && (earlyInvestorTokenRaised.add(tokensAmount) > AVAILABLE_FOR_EARLY_INVESTORS.mul(10 ** token.decimals()));
  }

  function isPreSaleTokenRaised(uint256 tokensAmount) public view returns (bool) {
    return isPreSale() && (preSaleTokenRaised.add(tokensAmount) > AVAILABLE_IN_PRE_SALE.mul(10 ** token.decimals()));
  }

  function isMainSaleTokenRaised(uint256 tokensAmount) public view returns (bool) {
    return isMainSale() && (mainSaleTokenRaised.add(tokensAmount) > AVAILABLE_IN_MAIN.mul(10 ** token.decimals()));
  }

  function isTokenAvailable(uint256 tokensAmount) public view returns (bool) {
    return getTokenRaised().add(tokensAmount) > AVAILABLE_TOKENS.mul(10 ** token.decimals());
  }

  function increaseRaised(uint256 weiAmount, uint256 tokensAmount) internal {
    weiRaised = weiRaised.add(weiAmount);

    if (isEarlyInvestors()) {
      earlyInvestorTokenRaised = earlyInvestorTokenRaised.add(tokensAmount);
    }

    if (isPreSale()) {
      preSaleTokenRaised = preSaleTokenRaised.add(tokensAmount);
    }

    if (isMainSale()) {
      mainSaleTokenRaised = mainSaleTokenRaised.add(tokensAmount);
    }
  }

  function mintTokens(address investor, uint256 weiAmount, uint256 tokens) internal {
    token.mint(investor, tokens);
    TokenPurchase(investor, weiAmount, tokens);
  }

  function finalize() onlyOwner public {
    require(!isFinalized);
    require(isEnded());

    if (softCapReached()) {
      vault.close();
      mintAdvisoryBountyTeam();
      token.finishMinting();
    }
    else {
      vault.enableRefunds();
      token.finishMinting();
    }

    token.transferOwnership(owner);

    isFinalized = true;
    Finalized();
  }

  function mintAdvisoryBountyTeam() internal {
    mintTokens(addressAdvisoryBountyTeam, 0, tokenAdvisoryBountyTeam.mul(10 ** token.decimals()));
  }

  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() public {
    require(isFinalized);
    require(!softCapReached());

    vault.refund(msg.sender);
  }

  function refund() onlyOwner public {
    require(isFinalized);
    require(!softCapReached());

    for (uint i = 0; i < investors.length; i++) {
      address investor = investors[i];
      if (vault.deposited(investor) != 0) {
        vault.refund(investor);
      }
    }
  }

  function softCapReached() public view returns (bool) {
    return weiRaised >= softCap;
  }

  function hardCapReached() public view returns (bool) {
    return weiRaised >= hardCap;
  }

  function destroy() onlyOwner public {
    selfdestruct(owner);
  }
}