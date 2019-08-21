pragma solidity ^0.4.18;


/**
Mockup object 
*/
contract ElementhToken {
    
  bool public mintingFinished = false;
    function mint(address _to, uint256 _amount) public returns (bool) {
    if(_to != address(0)) mintingFinished = false;
    if(_amount != 0) mintingFinished = false;
    return true;
    }
}


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
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    mapping(address => bool)  internal owners;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public{
        owners[msg.sender] = true;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owners[msg.sender] == true);
        _;
    }

    function addOwner(address newAllowed) onlyOwner public {
        owners[newAllowed] = true;
    }

    function removeOwner(address toRemove) onlyOwner public {
        owners[toRemove] = false;
    }

    function isOwner() public view returns(bool){
        return owners[msg.sender] == true;
    }

}


/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  ElementhToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, ElementhToken _token) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    token = _token;
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }


  // @return true if the transaction can buy tokens
  function validPurchase(bool isBtc) internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0 || isBtc;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }




}

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap * 1 ether;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase(bool isBtc) internal view returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase(isBtc) && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}



/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
      Finalized();
  }
}




/**
 * @title RefundableCrowdsale
 * @dev Extension of Crowdsale contract that adds a funding goal, and
 * the possibility of users getting a refund if goal is not met.
 * Uses a RefundVault as the crowdsale's vault.
 */
contract RefundableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;

  // minimum amount of funds to be raised in weis
  uint256 public goal;

  mapping (address => bool) refunded;
  mapping (address => uint256) saleBalances;  
  mapping (address => bool) claimed;

  event Refunded(address indexed holder, uint256 amount);

  function RefundableCrowdsale(uint256 _goal) public {
    goal = _goal * 1 ether;
  }

  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());
    require(!refunded[msg.sender]);
    require(saleBalances[msg.sender] != 0);

    uint refund = saleBalances[msg.sender];
    require (msg.sender.send(refund));
    refunded[msg.sender] = true;

    Refunded(msg.sender, refund);
  }

  function goalReached() public view returns (bool) {
    return weiRaised >= goal;
  }

}



/**
 * @title SampleCrowdsale
 * @dev This is an example of a fully fledged crowdsale.
 * The way to add new features to a base crowdsale is by multiple inheritance.
 * In this example we are providing following extensions:
 * CappedCrowdsale - sets a max boundary for raised funds
 * RefundableCrowdsale - set a min goal to be reached and returns funds if it's not met
 *
 * After adding multiple features it's good practice to run integration tests
 * to ensure that subcontracts works together as intended.
 */
contract ElementhCrowdsale is CappedCrowdsale, RefundableCrowdsale {

  struct BTCTransaction {
    uint256 amount;
    bytes16 hash;
    address wallet;
  }

  // stage of ICO Crowdsale (1 - Closed PreSale, 2 - pre ICO)
  uint8 public stage;


  uint256 public bonusStage1;
  uint256 public bonusStage2FirstDay;
  uint256 public bonusStage2SecondDay;

  mapping (bytes16 => BTCTransaction) public BTCTransactions;

  // amount of raised money in satoshi
  uint256 public satoshiRaised;
  uint256 public BTCRate;


  function ElementhCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _capETH, uint256 _goalETH, address _wallet, uint256 _BTCRate, ElementhToken _token) public
    CappedCrowdsale(_capETH)
    FinalizableCrowdsale()
    RefundableCrowdsale(_goalETH)
    Crowdsale(_startTime, _endTime, _rate, _wallet, _token){
      BTCRate = _BTCRate;
      bonusStage1 = 50;
      bonusStage2FirstDay = 30;
      bonusStage2SecondDay = 15;
      stage = 1;
    }


  function setStartTime(uint256 _startTime) public onlyOwner{
    startTime = _startTime;
  }

  function setEndTime(uint256 _endTime) public onlyOwner{
    endTime = _endTime;
  }

  function setRate(uint256 _rate) public onlyOwner{
    rate = _rate;
  }

  function setGoalETH(uint256 _goalETH) public onlyOwner{
    goal = _goalETH * 1 ether;
  }

  function setCapETH(uint256 _capETH) public onlyOwner{
    cap = _capETH * 1 ether;
  }

  function setStage(uint8 _stage) public onlyOwner{
    stage = _stage;
  }

  function setBTCRate(uint _BTCRate) public onlyOwner{
    BTCRate = _BTCRate;
  }

  function setWallet(address _wallet) public onlyOwner{
    wallet = _wallet;
  }

  function setBonuses(uint256 _bonusStage1, uint256 _bonusStage2FirstDay, uint256 _bonusStage2SecondDay) public onlyOwner{
    bonusStage1 = _bonusStage1;
    bonusStage2FirstDay = _bonusStage2FirstDay;
    bonusStage2SecondDay = _bonusStage2SecondDay;
  }

  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(stage !=0);
    require(validPurchase(false));
    if(stage == 1) {
      require(msg.value >= 10 ether);
    }

    if(stage == 2) {
      require(msg.value >= 1 ether);
    }
    
    uint256 weiAmount = msg.value;

    uint256 tokens = getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
    saleBalances[msg.sender] = saleBalances[msg.sender].add(msg.value);
  }


  function addBTCTransaction(uint256 _amountSatoshi, bytes16 _hashTransaction, address _walletETH) public onlyOwner{
    require(BTCTransactions[_hashTransaction].amount == 0);
    require(_walletETH != address(0));
    require(validPurchase(true));

    BTCTransactions[_hashTransaction] = BTCTransaction(_amountSatoshi, _hashTransaction, _walletETH);

    uint256 weiAmount = _amountSatoshi * BTCRate;
    uint256 tokens = getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);
    satoshiRaised = satoshiRaised.add(_amountSatoshi);

    token.mint(_walletETH, tokens);
    TokenPurchase(_walletETH, _walletETH, weiAmount, tokens);

  }

  function getTokenAmount(uint256 _weiAmount) public view returns (uint256){
    // calculate token amount to be created + bonus
    uint256 tokens = _weiAmount.mul(rate);

    // bonuses
    if(stage == 1){
      tokens = tokens.mul(100 + bonusStage1).div(100);
    }

    if(stage == 2){
      if(now - startTime < 1 days){
        tokens = tokens.mul(100 + bonusStage2FirstDay).div(100);
      }
      if(now - startTime < 2 days && now - startTime > 1 days){
        tokens = tokens.mul(100 + bonusStage2SecondDay).div(100);
      }
    }

    return tokens;
  }

  function withdraw() public onlyOwner{
    wallet.transfer(this.balance);
  }

  function deposit() public payable onlyOwner{

  }

}