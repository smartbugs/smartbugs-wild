pragma solidity ^0.4.15;

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

contract GJCICO is Pausable{
  using SafeMath for uint256;

  //Gas/GWei
  uint constant public minContribAmount = 0.01 ether;

  // The token being sold
  GJCToken public token;
  uint256 constant public tokenDecimals = 18;

  // The vesting contract
  TokenVesting public vesting;
  uint256 constant public VESTING_TIMES = 4;
  uint256 constant public DURATION_PER_VESTING = 52 weeks;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // need to be enabled to allow investor to participate in the ico
  bool public icoEnabled;

  // address where funds are collected
  address public multisignWallet;

  // amount of raised money in wei
  uint256 public weiRaised;

  // totalSupply
  uint256 constant public totalSupply = 100000000 * (10 ** tokenDecimals);
  //pre sale cap
  uint256 constant public preSaleCap = 10000000 * (10 ** tokenDecimals);
  //sale cap
  uint256 constant public initialICOCap = 60000000 * (10 ** tokenDecimals);
  //founder share
  uint256 constant public tokensForFounder = 10000000 * (10 ** tokenDecimals);
  //dev team share
  uint256 constant public tokensForDevteam = 10000000 * (10 ** tokenDecimals);
  //Partners share
  uint256 constant public tokensForPartners = 5000000 * (10 ** tokenDecimals);
  //Charity share
  uint256 constant public tokensForCharity = 3000000 * (10 ** tokenDecimals);
  //Bounty share
  uint256 constant public tokensForBounty = 2000000 * (10 ** tokenDecimals);
    
  //Sold presale tokens
  uint256 public soldPreSaleTokens; 
  uint256 public sentPreSaleTokens;

  //ICO tokens
  //Is calcluated as: initialICOCap + preSaleCap - soldPreSaleTokens
  uint256 public icoCap; 
  uint256 public icoSoldTokens; 
  bool public icoEnded = false;

  //Sale rates
  uint256 constant public RATE_FOR_WEEK1 = 525;
  uint256 constant public RATE_FOR_WEEK2 = 455;
  uint256 constant public RATE_FOR_WEEK3 = 420;
  uint256 constant public RATE_NO_DISCOUNT = 350;


  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */ 
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function GJCICO(address _multisignWallet) {
    require(_multisignWallet != address(0));
    token = createTokenContract();
    //send all dao tokens to multiwallet
    uint256 tokensToDao = tokensForDevteam.add(tokensForPartners).add(tokensForBounty).add(tokensForCharity);
    multisignWallet = _multisignWallet;
    token.transfer(multisignWallet, tokensToDao);
  }

  function createVestingForFounder(address founderAddress) external onlyOwner(){
    require(founderAddress != address(0));
    //create only once
    require(address(vesting) == address(0));
    vesting = createTokenVestingContract(address(token));
    // create vesting schema for founders from now, total token amount is divided in 4 periods of 12 months each
    vesting.createVestingByDurationAndSplits(founderAddress, tokensForFounder, now, DURATION_PER_VESTING, VESTING_TIMES);
    //send tokens to vesting contracts
    token.transfer(address(vesting), tokensForFounder);
  }

  //
  // Token related operations
  //

  // creates the token to be sold. 
  
  function createTokenContract() internal returns (GJCToken) {
    return new GJCToken();
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenVestingContract(address tokenAddress) internal returns (TokenVesting) {
    require(address(token) != address(0));
    return new TokenVesting(tokenAddress);
  }


  // enable token tranferability
  function enableTokenTransferability() external onlyOwner {
    require(token != address(0));
    token.unpause(); 
  }

  // disable token tranferability
  function disableTokenTransferability() external onlyOwner {
    require(token != address(0));
    token.pause(); 
  }


  //
  // Presale related operations
  //

  // set total pre sale sold token
  // can not be changed once the ico is enabled
  // Ico cap is determined by SaleCap + PreSaleCap - soldPreSaleTokens 
  function setSoldPreSaleTokens(uint256 _soldPreSaleTokens) external onlyOwner{
    require(!icoEnabled);
    require(_soldPreSaleTokens <= preSaleCap);
    soldPreSaleTokens = _soldPreSaleTokens;
  }

  // transfer pre sale tokend to investors
  // soldPreSaleTokens need to be set beforehand, and bigger than 0
  // the total amount to tranfered need to be less or equal to soldPreSaleTokens 
  function transferPreSaleTokens(uint256 tokens, address beneficiary) external onlyOwner {
    require(beneficiary != address(0));
    require(soldPreSaleTokens > 0);
    uint256 newSentPreSaleTokens = sentPreSaleTokens.add(tokens);
    require(newSentPreSaleTokens <= soldPreSaleTokens);
    sentPreSaleTokens = newSentPreSaleTokens;
    token.transfer(beneficiary, tokens);
  }


  //
  // ICO related operations
  //

  // set multisign wallet
  function setMultisignWallet(address _multisignWallet) external onlyOwner{
    // need to be set before the ico start
    require(!icoEnabled || now < startTime);
    require(_multisignWallet != address(0));
    multisignWallet = _multisignWallet;
  }

  // delegate vesting contract owner
  function delegateVestingContractOwner(address newOwner) external onlyOwner{
    vesting.transferOwnership(newOwner);
  }

  // set contribution dates
  function setContributionDates(uint256 _startTime, uint256 _endTime) external onlyOwner{
    require(!icoEnabled);
    require(_startTime >= now);
    require(_endTime >= _startTime);
    startTime = _startTime;
    endTime = _endTime;
  }

  // enable ICO, need to be true to actually start ico
  // multisign wallet need to be set, because once ico started, invested funds is transfered to this address
  // once ico is enabled, following parameters can not be changed anymore:
  // startTime, endTime, soldPreSaleTokens
  function enableICO() external onlyOwner{
    require(startTime >= now);

    require(multisignWallet != address(0));
    icoEnabled = true;
    icoCap = initialICOCap.add(preSaleCap).sub(soldPreSaleTokens);
  }


  // fallback function can be used to buy tokens
  function () payable whenNotPaused {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable whenNotPaused {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;
    uint256 returnWeiAmount;

    // calculate token amount to be created
    uint rate = getRate();
    assert(rate > 0);
    uint256 tokens = weiAmount.mul(rate);

    uint256 newIcoSoldTokens = icoSoldTokens.add(tokens);

    if (newIcoSoldTokens > icoCap) {
        newIcoSoldTokens = icoCap;
        tokens = icoCap.sub(icoSoldTokens);
        uint256 newWeiAmount = tokens.div(rate);
        returnWeiAmount = weiAmount.sub(newWeiAmount);
        weiAmount = newWeiAmount;
    }

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.transfer(beneficiary, tokens);
    icoSoldTokens = newIcoSoldTokens;
    if (returnWeiAmount > 0){
        msg.sender.transfer(returnWeiAmount);
    }

    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  
  function forwardFunds() internal {
    multisignWallet.transfer(this.balance);
  }

  // unsold ico tokens transfer automatically in endIco
  // function transferUnsoldIcoTokens() onlyOwner {
  // require(hasEnded());
  // require(icoSoldTokens < icoCap);
  // uint256 unsoldTokens = icoCap.sub(icoSoldTokens);
  // token.transfer(multisignWallet, unsoldTokens);
  //}

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonMinimumPurchase = msg.value >= minContribAmount;
    bool icoTokensAvailable = icoSoldTokens < icoCap;
    return !icoEnded && icoEnabled && withinPeriod && nonMinimumPurchase && icoTokensAvailable;
  }

  // end ico by owner, not really needed in normal situation
  function endIco() external onlyOwner {
    require(!icoEnded);
    icoEnded = true;
    // send unsold tokens to multi-sign wallet
    uint256 unsoldTokens = icoCap.sub(icoSoldTokens);
    token.transfer(multisignWallet, unsoldTokens);
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return (icoEnded || icoSoldTokens >= icoCap || now > endTime);
  }


  function getRate() public constant returns(uint){
    require(now >= startTime);
    if (now < startTime.add(1 weeks)){
      // week 1
      return RATE_FOR_WEEK1;
    }else if (now < startTime.add(2 weeks)){
      // week 2
      return RATE_FOR_WEEK2;
    }else if (now < startTime.add(3 weeks)){
      // week 3
      return RATE_FOR_WEEK3;
    }else if (now < endTime){
      // no discount
      return RATE_NO_DISCOUNT;
    }
    return 0;
  }

  // drain all eth for owner in an emergency situation
  function drain() external onlyOwner {
    owner.transfer(this.balance);
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

contract TokenVesting is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for ERC20Basic;

    ERC20Basic token;
    // vesting
    mapping (address => uint256) totalVestedAmount;

    struct Vesting {
        uint256 amount;
        uint256 vestingDate;
    }

    address[] accountKeys;
    mapping (address => Vesting[]) public vestingAccounts;

    // events
    event Vest(address indexed beneficiary, uint256 amount);
    event VestingCreated(address indexed beneficiary, uint256 amount, uint256 vestingDate);

    // modifiers here
    modifier tokenSet() {
        require(address(token) != address(0));
        _;
    }

    // vesting constructor
    function TokenVesting(address token_address){
       require(token_address != address(0));
       token = ERC20Basic(token_address);
    }

    // set vesting token address
    function setVestingToken(address token_address) external onlyOwner {
        require(token_address != address(0));
        token = ERC20Basic(token_address);
    }

    // create vesting by introducing beneficiary addres, total token amount, start date, duration for each vest period and number of periods
    function createVestingByDurationAndSplits(address user, uint256 total_amount, uint256 startDate, uint256 durationPerVesting, uint256 times) public onlyOwner tokenSet {
        require(user != address(0));
        require(startDate >= now);
        require(times > 0);
        require(durationPerVesting > 0);
        uint256 vestingDate = startDate;
        uint256 i;
        uint256 amount = total_amount.div(times);
        for (i = 0; i < times; i++) {
            vestingDate = vestingDate.add(durationPerVesting);
            if (vestingAccounts[user].length == 0){
                accountKeys.push(user);
            }
            vestingAccounts[user].push(Vesting(amount, vestingDate));
            VestingCreated(user, amount, vestingDate);
        }
    }

    // get current user total granted token amount
    function getVestingAmountByNow(address user) constant returns (uint256){
        uint256 amount;
        uint256 i;
        for (i = 0; i < vestingAccounts[user].length; i++) {
            if (vestingAccounts[user][i].vestingDate < now) {
                amount = amount.add(vestingAccounts[user][i].amount);
            }
        }

    }

    // get user available vesting amount, total amount - received amount
    function getAvailableVestingAmount(address user) constant returns (uint256){
        uint256 amount;
        amount = getVestingAmountByNow(user);
        amount = amount.sub(totalVestedAmount[user]);
        return amount;
    }

    // get list of vesting users address
    function getAccountKeys(uint256 page) external constant returns (address[10]){
        address[10] memory accountList;
        uint256 i;
        for (i=0 + page * 10; i<10; i++){
            if (i < accountKeys.length){
                accountList[i - page * 10] = accountKeys[i];
            }
        }
        return accountList;
    }

    // vest
    function vest() external tokenSet {
        uint256 availableAmount = getAvailableVestingAmount(msg.sender);
        require(availableAmount > 0);
        totalVestedAmount[msg.sender] = totalVestedAmount[msg.sender].add(availableAmount);
        token.transfer(msg.sender, availableAmount);
        Vest(msg.sender, availableAmount);
    }

    // drain all eth and tokens to owner in an emergency situation
    function drain() external onlyOwner {
        owner.transfer(this.balance);
        token.transfer(owner, this.balance);
    }
}

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

}

contract PausableToken is StandardToken, Pausable {
  /**
   * @dev modifier to allow actions only when the contract is not paused or
   * the sender is the owner of the contract
   */
  modifier whenNotPausedOrOwner() {
    require(msg.sender == owner || !paused);
    _;
  }

  function transfer(address _to, uint256 _value) public whenNotPausedOrOwner returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPausedOrOwner returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPausedOrOwner returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPausedOrOwner returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPausedOrOwner returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract GJCToken is PausableToken {
  string constant public name = "GJC";
  string constant public symbol = "GJC";
  uint256 constant public decimals = 18;
  uint256 constant TOKEN_UNIT = 10 ** uint256(decimals);
  uint256 constant INITIAL_SUPPLY = 100000000 * TOKEN_UNIT;

  function GJCToken() {
    // Set untransferable by default to the token
    paused = true;
    // asign all tokens to the contract creator
    totalSupply = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}