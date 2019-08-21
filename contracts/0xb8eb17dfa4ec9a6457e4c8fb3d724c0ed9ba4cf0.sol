pragma solidity ^0.4.13;

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

contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

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


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


  // fallback function can be used to buy tokens
  function () public payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

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
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }


}

contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

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

contract WhiteListCrowdsale is
  CappedCrowdsale,
  Ownable
{

  /**
   * @dev Rate of bonus tokens received by investors during the whitelist period of the crowdsale.
   */
  uint8 public constant WHITELIST_BONUS_RATE = 10;

  /**
   * @dev Rate of bonus tokens received by a referring investor,
   * expressed as % of total bonus tokens issued for the purchase.
   */
  uint8 public constant REFERRAL_SHARE_RATE = 50;

  /**
   * @dev Timestamp until which it is possible to add an investor to the whitelist.
   */
  uint256 public whiteListRegistrationEndTime;

  /**
   * @dev Timestamp after which anyone can participate in the crowdsale.
   */
  uint256 public whiteListEndTime;

  /**
   * @dev Whitelisted addresses.
   */
  mapping(address => bool) public isWhiteListed;

  /**
   * @dev Referral codes associated to their referring addresses.
   */
  mapping(bytes32 => address) internal referralCodes;

  /**
   * @dev Maps referred investors to their referrers (referred => referring).
   */
  mapping(address => address) internal referrals;

  /**
   * @dev Event fired when an address is added to the whitelist.
   * @param investor whitelisted investor
   * @param referralCode referral code of the whitelisted investor
   */
  event WhiteListedInvestorAdded(
    address indexed investor,
    string referralCode
  );

  /**
   * event for bonus token emmited
   * @param referralCode referral code of the whitelisted investor
   * @param referredInvestor address of the referred investor
   */
  event ReferredInvestorAdded(
    string referralCode,
    address referredInvestor
  );

  /**
   * @dev Event fired when bonus tokens are emitted for referred purchases.
   * @param beneficiary who got the tokens
   * @param amount bonus tokens issued
   */
  event ReferredBonusTokensEmitted(
    address indexed beneficiary,
    uint256 amount
  );

  /**
   * @dev Event fired when bonus tokens are emitted for whitelist or referred purchases.
   * @param beneficiary who got the tokens
   * @param amount bonus tokens issued
   */
  event WhiteListBonusTokensEmitted(
    address indexed beneficiary,
    uint256 amount
  );

  /**
   * @dev WhiteListCrowdsale construction.
   * @param _whiteListRegistrationEndTime time until which white list registration is still possible
   * @param _whiteListEndTime time until which only white list purchases are accepted
   */
  function WhiteListCrowdsale(uint256 _whiteListRegistrationEndTime, uint256 _whiteListEndTime) public {
    require(_whiteListEndTime > startTime);

    whiteListEndTime = _whiteListEndTime;
    whiteListRegistrationEndTime = _whiteListRegistrationEndTime;
  }

  /**
   * @dev Overriding Crowdsale#buyTokens to add extra whitelist and referral logic.
   * @param _beneficiary address that is buying tokens.
   */
  function buyTokens(address _beneficiary) public payable
  {
    require(validWhiteListedPurchase(_beneficiary));

    // Buys tokens and transfers them to _beneficiary.
    super.buyTokens(_beneficiary);
    
    uint256 bonusTokens = computeBonusTokens(_beneficiary, msg.value);
    if (isReferred(_beneficiary))
    {
      uint256 bonusTokensForReferral = bonusTokens.mul(REFERRAL_SHARE_RATE).div(100);
      uint256 bonusTokensForReferred = bonusTokens.sub(bonusTokensForReferral);
      token.mint(_beneficiary, bonusTokensForReferred);
      token.mint(referrals[_beneficiary], bonusTokensForReferral);
      ReferredBonusTokensEmitted(_beneficiary, bonusTokensForReferred);
      WhiteListBonusTokensEmitted(referrals[_beneficiary], bonusTokensForReferral);
    }
    else if (isWhiteListed[_beneficiary])
    {
      token.mint(_beneficiary, bonusTokens);
      WhiteListBonusTokensEmitted(_beneficiary, bonusTokens);
    }
  }

  /**
   * @dev Adds an investor to the whitelist if registration is open. Fails otherwise.
   * @param _investor whitelisted investor
   * @param _referralCode investor's referral code
   */
  function addWhiteListedInvestor(address _investor, string _referralCode) public
  {
    require(block.timestamp <= whiteListRegistrationEndTime);
    require(_investor != 0);
    require(!isWhiteListed[_investor]);
    bytes32 referralCodeHash = keccak256(_referralCode);
    require(referralCodes[referralCodeHash] == 0x0);
    
    isWhiteListed[_investor] = true;
    referralCodes[referralCodeHash] = _investor;
    WhiteListedInvestorAdded(_investor, _referralCode);
  }

  /**
   * @dev Adds up to 30 whitelisted investors. To be called one or more times
   * for initial whitelist loading.
   * @param _investors whitelisted investors.
   * @param _referralCodes keccak-256 hashes of corresponding investor referral codes.
   */
  function loadWhiteList(address[] _investors, bytes32[] _referralCodes) public onlyOwner
  {
    require(_investors.length <= 30);
    require(_investors.length == _referralCodes.length);

    for (uint i = 0; i < _investors.length; i++)
    {
      isWhiteListed[_investors[i]] = true;
      referralCodes[_referralCodes[i]] = _investors[i];
    }
  }

  /**
   * @dev Adds a referred investor to the second-level whitelist.
   * @param _referredInvestor whitelisted investor.
   * @param _referralCode investor's referral code.
   */
  function addReferredInvestor(string _referralCode, address _referredInvestor) public
  {
    require(!hasEnded());
    require(!isWhiteListed[_referredInvestor]);
    require(_referredInvestor != 0);
    require(referrals[_referredInvestor] == 0x0);
    bytes32 referralCodeHash = keccak256(_referralCode);
    require(referralCodes[referralCodeHash] != 0);

    referrals[_referredInvestor] = referralCodes[referralCodeHash];
    ReferredInvestorAdded(_referralCode, _referredInvestor);
  }

  /**
   * @dev Adds up to 30 referred investors. To be called one or more times
   * for initial referred list loading.
   * @param _referralCodes keccak-256 hashes of referral codes.
   * @param _investors corresponding referred investors.
   */
  function loadReferredInvestors(bytes32[] _referralCodes, address[] _investors) public onlyOwner
  {
    require(_investors.length <= 30);
    require(_investors.length == _referralCodes.length);

    for (uint i = 0; i < _investors.length; i++)
    {
      referrals[_investors[i]] = referralCodes[_referralCodes[i]];
    }
  }

  /**
   * @dev Returns true if _investor is a referred investor.
   * @param _investor address to check against the list of referred investors.
   */
  function isReferred(address _investor) public constant returns (bool)
  {
    return referrals[_investor] != 0x0;
  }

  /**
   * @dev Returns true if _investor is a whitelisted or referred investor,
   * or the whitelist period has ended (and the crowdsale hasn't) and everyone can buy.
   * @param _investor investor who is making the purchase.
   */
  function validWhiteListedPurchase(address _investor) internal constant returns (bool)
  {
    return isWhiteListed[_investor] || isReferred(_investor) || block.timestamp > whiteListEndTime;
  }

  /**
   * @dev Returns the number of bonus tokens for a whitelisted or referred purchase.
   * Returns zero if the purchase is not from a whitelisted or referred investor.
   * @param _weiAmount purchase amount.
   */
  function computeBonusTokens(address _beneficiary, uint256 _weiAmount) internal constant returns (uint256)
  {
    if (isReferred(_beneficiary) || isWhiteListed[_beneficiary]) {
      uint256 bonusTokens = _weiAmount.mul(rate).mul(WHITELIST_BONUS_RATE).div(100);
      if (block.timestamp > whiteListEndTime) {
        bonusTokens = bonusTokens.div(2);
      }
      return bonusTokens;
    }
    else
    {
      return 0;
    }
  }

}

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
  }
}

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
    require(_wallet != 0x0);
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

contract RefundableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;

  // minimum amount of funds to be raised in weis
  uint256 public goal;

  // refund vault used to hold funds while crowdsale is running
  RefundVault public vault;

  function RefundableCrowdsale(uint256 _goal) public {
    require(_goal > 0);
    vault = new RefundVault(wallet);
    goal = _goal;
  }

  // We're overriding the fund forwarding from Crowdsale.
  // In addition to sending the funds, we want to call
  // the RefundVault deposit function
  function forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }

  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());

    vault.refund(msg.sender);
  }

  // vault finalization task, called when owner calls finalize()
  function finalization() internal {
    if (goalReached()) {
      vault.close();
    } else {
      vault.enableRefunds();
    }

    super.finalization();
  }

  function goalReached() public constant returns (bool) {
    return weiRaised >= goal;
  }

}

contract Destructible is Ownable {

  function Destructible() public payable { }

  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
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

contract DemeterCrowdsale is
  RefundableCrowdsale,
  WhiteListCrowdsale,
  Pausable,
  Destructible
{

  /**
   * @dev Each time an investor purchases, he gets this % of the minted tokens
   * (plus bonus if applicable), while the company gets 70% (minus bonus).
   */
  uint8 constant public PERC_TOKENS_TO_INVESTOR = 30;

  /**
   * @dev Portion of total tokens reserved for future token releases.
   * Documentation-only. Unused in code, as the release part is calculated by subtraction.
   */
  uint8 constant public PERC_TOKENS_TO_RELEASE = 25;

  /**
   * @dev Address to which the release tokens are credited.
   */
  address constant public RELEASE_WALLET = 0x867D85437d27cA97e1EB574250efbba487aca637;

  /**
   * Portion of total tokens reserved for dev. team.
   */
  uint8 constant public PERC_TOKENS_TO_DEV = 20;

  /**
   * @dev Address to which the dev. tokens are credited.
   */
  address constant public DEV_WALLET = 0x70323222694584c68BD5a29194bb72c248e715F7;

  /**
   * Portion of total tokens reserved for business dev.
   */
  uint8 constant public PERC_TOKENS_TO_BIZDEV = 25;

  /**
   * @dev Address to which the business dev. tokens are credited.
   */
  address constant public BIZDEV_WALLET = 0xE43053e265F04f690021735E02BBA559Cea681D6;

  /**
   * @dev Event fired whenever company tokens are issued for a purchase.
   * @param investor who made the purchase
   * @param value weis paid for purchase
   * @param amount amount of tokens minted for the company
   */
  event CompanyTokensIssued(
    address indexed investor,
    uint256 value,
    uint256 amount
  );

  /**
   * @dev DemeterCrowdsale construction.
   * @param _startTime beginning of crowdsale.
   * @param _endTime end of crowdsale.
   * @param _whiteListRegistrationEndTime time until which whitelist registration is still possible.
   * @param _whiteListEndTime time until which only whitelist purchases are accepted.
   * @param _rate how many tokens per ether in case of no whitelist or referral bonuses.
   * @param _cap crowdsale hard cap in wei.
   * @param _goal minimum crowdsale goal in wei; if not reached, causes refunds to be available.
   * @param _wallet where the raised ethers are transferred in case of successful crowdsale.
   */
  function DemeterCrowdsale(
    uint256 _startTime,
    uint256 _endTime,
    uint256 _whiteListRegistrationEndTime,
    uint256 _whiteListEndTime,
    uint256 _rate,
    uint256 _cap,
    uint256 _goal,
    address _wallet
  ) public
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    CappedCrowdsale(_cap)
    RefundableCrowdsale(_goal)
    WhiteListCrowdsale(_whiteListRegistrationEndTime, _whiteListEndTime)
  {
    DemeterToken(token).setUnlockTime(_endTime);
  }

  /**
   * @dev Called when a purchase is made. Override to issue company tokens
   * in addition to bought and bonus tokens.
   * @param _beneficiary the investor that buys the tokens.
   */
  function buyTokens(address _beneficiary) public payable whenNotPaused {
    require(msg.value >= 0.1 ether);
    // buys tokens (including referral or whitelist tokens) and
    // transfers them to _beneficiary.
    super.buyTokens(_beneficiary);
    
    // mints additional tokens for the company and distributes them to the company wallets.
    issueCompanyTokens(_beneficiary, msg.value);
  }

  /**
   * @dev Closes the vault, terminates the contract and the token contract as well.
   * Only allowed while the vault is open (not when refunds are enabled or the vault
   * is already closed). Balance would be transferred to the owner, but it is
   * always zero anyway.
   */
  function destroy() public onlyOwner {
    vault.close();
    super.destroy();
    DemeterToken(token).destroyAndSend(this);
  }

  /**
   * @dev Closes the vault, terminates the contract and the token contract as well.
   * Only allowed while the vault is open (not when refunds are enabled or the vault
   * is already closed). Balance would be transferred to _recipient, but it is
   * always zero anyway.
   */
  function destroyAndSend(address _recipient) public onlyOwner {
    vault.close();
    super.destroyAndSend(_recipient);
    DemeterToken(token).destroyAndSend(_recipient);
  }

  /**
   * @dev Allows the owner to change the minimum goal during the sale.
   * @param _goal new goal in wei.
   */
  function updateGoal(uint256 _goal) public onlyOwner {
    require(_goal >= 0 && _goal <= cap);
    require(!hasEnded());

    goal = _goal;
  }

  /**
   * @dev Mints additional tokens for the company and distributes them to the company wallets.
   * @param _investor the investor that bought tokens.
   * @param _weiAmount the amount paid in weis.
   */
  function issueCompanyTokens(address _investor, uint256 _weiAmount) internal {
    uint256 investorTokens = _weiAmount.mul(rate);
    uint256 bonusTokens = computeBonusTokens(_investor, _weiAmount);
    uint256 companyTokens = investorTokens.mul(100 - PERC_TOKENS_TO_INVESTOR).div(PERC_TOKENS_TO_INVESTOR);
    uint256 totalTokens = investorTokens.add(companyTokens);
    // distribute total tokens among the three wallets.
    uint256 devTokens = totalTokens.mul(PERC_TOKENS_TO_DEV).div(100);
    token.mint(DEV_WALLET, devTokens);
    // We take out bonus tokens from bizDev amount.
    uint256 bizDevTokens = (totalTokens.mul(PERC_TOKENS_TO_BIZDEV).div(100)).sub(bonusTokens);
    token.mint(BIZDEV_WALLET, bizDevTokens);
    uint256 actualCompanyTokens = companyTokens.sub(bonusTokens);
    uint256 releaseTokens = actualCompanyTokens.sub(bizDevTokens).sub(devTokens);
    token.mint(RELEASE_WALLET, releaseTokens);

    CompanyTokensIssued(_investor, _weiAmount, actualCompanyTokens);
  }

  /**
   * @dev Override to create our specific token contract.
   */
  function createTokenContract() internal returns (MintableToken) {
    return new DemeterToken();
  }

  /**
   * Immediately unlocks tokens. To be used in case of early close of the sale.
   */
  function unlockTokens() internal {
    if (DemeterToken(token).unlockTime() > block.timestamp) {
      DemeterToken(token).setUnlockTime(block.timestamp);
    }
  }

  /**
   * @dev Unlock the tokens immediately if the sale closes prematurely.
   */
  function finalization() internal {
    super.finalization();
    unlockTokens();
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

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

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
  function increaseApproval (address _spender, uint _addedValue) public
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public
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
    Transfer(0x0, _to, _amount);
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

contract TimeLockedToken is MintableToken
{

  /**
   * @dev Timestamp after which tokens can be transferred.
   */
  uint256 public unlockTime = 0;

  /**
   * @dev Checks whether it can transfer or otherwise throws.
   */
  modifier canTransfer() {
    require(unlockTime == 0 || block.timestamp > unlockTime);
    _;
  }

  /**
   * @dev Sets the date and time since which tokens can be transfered.
   * It can only be moved back, and not in the past.
   * @param _unlockTime New unlock timestamp.
   */
  function setUnlockTime(uint256 _unlockTime) public onlyOwner {
    require(unlockTime == 0 || _unlockTime < unlockTime);
    require(_unlockTime >= block.timestamp);

    unlockTime = _unlockTime;
  }

  /**
   * @dev Checks modifier and allows transfer if tokens are not locked.
   * @param _to The address that will recieve the tokens.
   * @param _value The amount of tokens to be transferred.
   */
  function transfer(address _to, uint256 _value) public canTransfer returns (bool) {
    return super.transfer(_to, _value);
  }

  /**
  * @dev Checks modifier and allows transfer if tokens are not locked.
  * @param _from The address that will send the tokens.
  * @param _to The address that will recieve the tokens.
  * @param _value The amount of tokens to be transferred.
  */
  function transferFrom(address _from, address _to, uint256 _value) public canTransfer returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

}

contract DemeterToken is TimeLockedToken, Destructible
{
  string public name = "Demeter";
  string public symbol = "DMT";
  uint256 public decimals = 18;
}