pragma solidity ^0.4.13;

 /// @title Ownable contract - base contract with an owner
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

 /// @title SafeMath contract - math operations with safety checks
contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}

/// @title Haltable contract - abstract contract that allows children to implement an emergency stop mechanism.
/// Originally envisioned in FirstBlood ICO contract.
contract Haltable is Ownable {
  bool public halted;

  modifier stopInEmergency {
    require(!halted);
    _;
  }

  modifier onlyInEmergency {
    require(halted);
    _;
  }

  /// called by the owner on emergency, triggers stopped state
  function halt() external onlyOwner {
    halted = true;
  }

  /// called by the owner on end of emergency, returns to normal state
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }
}

 /// @title ERC20 interface see https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);
  function mint(address receiver, uint amount);
  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}



/// @title PayFairToken contract - standard ERC20 token with Short Hand Attack and approve() race condition mitigation.
contract PayFairToken is SafeMath, ERC20, Ownable {
 string public name = "PayFair Token";
 string public symbol = "PFR";
 uint public constant decimals = 8;
 uint public constant FROZEN_TOKENS = 11e6;
 uint public constant FREEZE_PERIOD = 1 years;
 uint public constant MULTIPLIER = 10 ** decimals;
 uint public crowdSaleOverTimestamp;

 /// contract that is allowed to create new tokens and allows unlift the transfer limits on this token
 address public crowdsaleAgent;
 /// A crowdsale contract can release us to the wild if ICO success. If false we are are in transfer lock up period.
 bool public released = false;
 /// approve() allowances
 mapping (address => mapping (address => uint)) allowed;
 /// holder balances
 mapping(address => uint) balances;

 /// @dev Limit token transfer until the crowdsale is over.
 modifier canTransfer() {
   if(!released) {
      require(msg.sender == crowdsaleAgent);
   }
   _;
 }

 modifier checkFrozenAmount(address source, uint amount) {
   if (source == owner && now < crowdSaleOverTimestamp + FREEZE_PERIOD) {
     var frozenTokens = 10 ** decimals * FROZEN_TOKENS;
     require(safeSub(balances[owner], amount) > frozenTokens);
   }
   _;
 }

 /// @dev The function can be called only before or after the tokens have been releasesd
 /// @param _released token transfer and mint state
 modifier inReleaseState(bool _released) {
   require(_released == released);
   _;
 }

 /// @dev The function can be called only by release agent.
 modifier onlyCrowdsaleAgent() {
   require(msg.sender == crowdsaleAgent);
   _;
 }

 /// @dev Fix for the ERC20 short address attack http://vessenes.com/the-erc20-short-address-attack-explained/
 /// @param size payload size
 modifier onlyPayloadSize(uint size) {
    require(msg.data.length >= size + 4);
    _;
 }

 /// @dev Make sure we are not done yet.
 modifier canMint() {
    require(!released);
    _;
  }

 /// @dev Constructor
 function PayFairToken() {
   owner = msg.sender;
 }

 /// Fallback method will buyout tokens
 function() payable {
   revert();
 }
 /// @dev Create new tokens and allocate them to an address. Only callably by a crowdsale contract
 /// @param receiver Address of receiver
 /// @param amount  Number of tokens to issue.
 function mint(address receiver, uint amount) onlyCrowdsaleAgent canMint public {
    totalSupply = safeAdd(totalSupply, amount);
    balances[receiver] = safeAdd(balances[receiver], amount);
    Transfer(0, receiver, amount);
 }

 /// @dev Set the contract that can call release and make the token transferable.
 /// @param _crowdsaleAgent crowdsale contract address
 function setCrowdsaleAgent(address _crowdsaleAgent) onlyOwner inReleaseState(false) public {
   crowdsaleAgent = _crowdsaleAgent;
 }
 /// @dev One way function to release the tokens to the wild. Can be called only from the release agent that is the final ICO contract. It is only called if the crowdsale has been success (first milestone reached).
 function releaseTokenTransfer() public onlyCrowdsaleAgent {
   crowdSaleOverTimestamp = now;
   released = true;
 }

 /// @dev Converts token value to value with decimal places
 /// @param amount Source token value
 function convertToDecimal(uint amount) public constant returns (uint) {
   return safeMul(amount, MULTIPLIER);
 }

 /// @dev Tranfer tokens to address
 /// @param _to dest address
 /// @param _value tokens amount
 /// @return transfer result
 function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) canTransfer checkFrozenAmount(msg.sender, _value) returns (bool success) {
   balances[msg.sender] = safeSub(balances[msg.sender], _value);
   balances[_to] = safeAdd(balances[_to], _value);

   Transfer(msg.sender, _to, _value);
   return true;
 }

 /// @dev Tranfer tokens from one address to other
 /// @param _from source address
 /// @param _to dest address
 /// @param _value tokens amount
 /// @return transfer result
 function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(2 * 32) canTransfer checkFrozenAmount(_from, _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
 }
 /// @dev Tokens balance
 /// @param _owner holder address
 /// @return balance amount
 function balanceOf(address _owner) constant returns (uint balance) {
   return balances[_owner];
 }

 /// @dev Approve transfer
 /// @param _spender holder address
 /// @param _value tokens amount
 /// @return result
 function approve(address _spender, uint _value) returns (bool success) {
   // To change the approve amount you first have to reduce the addresses`
   //  allowance to zero by calling `approve(_spender, 0)` if it is not
   //  already 0 to mitigate the race condition described here:
   //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   require ((_value == 0) || (allowed[msg.sender][_spender] == 0));

   allowed[msg.sender][_spender] = _value;
   Approval(msg.sender, _spender, _value);
   return true;
 }

 /// @dev Token allowance
 /// @param _owner holder address
 /// @param _spender spender address
 /// @return remain amount
 function allowance(address _owner, address _spender) constant returns (uint remaining) {
   return allowed[_owner][_spender];
 }
}

 /// @title Killable contract - base contract that can be killed by owner. All funds in contract will be sent to the owner.
contract Killable is Ownable {
  function kill() onlyOwner {
    selfdestruct(owner);
  }
}

/// @title PayFairTokenCrowdsale contract - contract for token sales.
contract PayFairTokenCrowdsale is Haltable, Killable, SafeMath {

  /// Total count of tokens distributed via ICO
  uint public constant TOTAL_ICO_TOKENS = 56e6;

  /// Total count of tokens distributed manually on the pre-ICO stage
  uint public constant PRE_ICO_MAX_TOKENS = 33e6;

  /// Miminal tokens funding goal in Wei, if this goal isn't reached during ICO, refund will begin
  uint public constant MIN_ICO_GOAL = 1 ether;

  /// The duration of ICO
  uint public constant ICO_DURATION = 30 days;

  /// The token we are selling
  PayFairToken public token;

  /// tokens will be transfered from this address
  address public multisigWallet;

  /// the UNIX timestamp start date of the crowdsale
  uint public startsAt;

  /// How many wei of funding we have raised
  uint public weiRaised = 0;

  /// How much wei we have returned back to the contract after a failed crowdfund.
  uint public loadedRefund = 0;

  /// How much wei we have given back to investors.
  uint public weiRefunded = 0;

  /// Total count of tokens distributed via pre-ICO
  uint public preIcoTokensDistributed = 0;

  /// Has this crowdsale been finalized
  bool public finalized;

  /// How much ETH each address has invested to this crowdsale
  mapping (address => uint256) public investedAmountOf;

  /// How much tokens this crowdsale has credited for each investor address
  mapping (address => uint256) public tokenAmountOf;

  /// Define preICO pricing schedule using milestones.
  struct Milestone {
      // UNIX timestamp when this milestone kicks in
      uint start;
      // UNIX timestamp when this milestone kicks out
      uint end;
      // How many % tokens will add
      uint bonus;
  }

  /// Define a structure for one investment event occurrence
  struct Investment {
      /// Who invested
      address source;

      /// Weight coefficient of investment (early investment bonus) in %
      uint weight;

      /// Amount invested
      uint weiValue;
  }

  Milestone[] public milestones;
  Investment[] public investments;

  /// State machine
  /// Preparing: All contract initialization calls and variables have not been set yet
  /// Prefunding: We have not passed start time yet
  /// Funding: Active crowdsale
  /// Success: Minimum funding goal reached
  /// Failure: Minimum funding goal not reached before ending time
  /// Finalized: The finalized has been called and succesfully executed\
  /// Refunding: Refunds are loaded on the contract for reclaim.
  enum State {Unknown, Preparing, PreFunding, Funding, Success, Failure, Finalized, Refunding}

  /// A new investment was made
  event Invested(address investor, uint weiAmount);
  /// Refund was processed for a contributor
  event Refund(address investor, uint weiAmount);

  /// @dev Modified allowing execution only if the crowdsale is currently running
  modifier inState(State state) {
    require(getState() == state);
    _;
  }

  /// @dev Constructor
  /// @param _token Pay Fair token address
  /// @param _multisigWallet team wallet
  /// @param _start token ICO start date
  function PayFairTokenCrowdsale(address _token, address _multisigWallet, uint _start) {
    require(_multisigWallet != 0);
    require(_start != 0);

    token = PayFairToken(_token);

    multisigWallet = _multisigWallet;
    startsAt = _start;

    milestones.push(Milestone(startsAt, startsAt + 1 days, 20));
    milestones.push(Milestone(startsAt + 1 days, startsAt + 5 days, 15));
    milestones.push(Milestone(startsAt + 5 days, startsAt + 10 days, 10));
    milestones.push(Milestone(startsAt + 10 days, startsAt + 20 days, 5));
  }

  ///  Don't expect to just send in money and get tokens.
  function() payable {
    buy();
  }

  /// @dev Get the current milestone or bail out if we are not in the milestone periods.
  /// @return Milestone current bonus milestone
  function getCurrentMilestone() private constant returns (Milestone) {
    for (uint i = 0; i < milestones.length; i++) {
      if (milestones[i].start <= now && milestones[i].end > now) {
        return milestones[i];
      }
   }
 }

   /// @dev Make an investment. Crowdsale must be running for one to invest.
   /// @param receiver The Ethereum address who receives the tokens
  function investInternal(address receiver) stopInEmergency private {
    var state = getState();
    require(state == State.Funding);
    require(msg.value > 0);

    // Add investment record
    var weiAmount = msg.value;
    investments.push(Investment(receiver, weiAmount, getCurrentMilestone().bonus + 100));
    investedAmountOf[receiver] = safeAdd(investedAmountOf[receiver], weiAmount);

    // Update totals
    weiRaised = safeAdd(weiRaised, weiAmount);
    // Transfer funds to the team wallet
    multisigWallet.transfer(weiAmount);
    // Tell us invest was success
    Invested(receiver, weiAmount);
  }

  /// @dev Allow anonymous contributions to this crowdsale.
  /// @param receiver The Ethereum address who receives the tokens
  function invest(address receiver) public payable {
    investInternal(receiver);
  }

  function sendPreIcoTokens(address receiver, uint amount) public inState(State.PreFunding) onlyOwner {
    require(receiver != 0);
    require(amount > 0);
    require(safeAdd(preIcoTokensDistributed, amount) <= token.convertToDecimal(PRE_ICO_MAX_TOKENS));

    preIcoTokensDistributed = safeAdd(preIcoTokensDistributed, amount);
    assignTokens(receiver, amount);
  }

  /// @dev The basic entry point to participate the crowdsale process.
  function buy() public payable {
    invest(msg.sender);
  }

  /// @dev Finalize a succcesful crowdsale.
  function finalize() public inState(State.Success) onlyOwner stopInEmergency {
    require(!finalized);

    finalized = true;
    finalizeCrowdsale();
  }

  /// @dev Finalize a succcesful crowdsale.
  function finalizeCrowdsale() internal {
    // Calculate divisor of the total token count
    uint divisor;
    for (uint i = 0; i < investments.length; i++)
       divisor = safeAdd(divisor, safeMul(investments[i].weiValue, investments[i].weight));

    uint localMultiplier = 10 ** 12;
    // Get unit price
    uint unitPrice = safeDiv(safeMul(token.convertToDecimal(TOTAL_ICO_TOKENS), localMultiplier), divisor);

    // Distribute tokens among investors
    for (i = 0; i < investments.length; i++) {
        var tokenAmount = safeDiv(safeMul(unitPrice, safeMul(investments[i].weiValue, investments[i].weight)), localMultiplier);
        tokenAmountOf[investments[i].source] += tokenAmount;
        assignTokens(investments[i].source, tokenAmount);
    }

    token.releaseTokenTransfer();
  }

  /// @dev Allow load refunds back on the contract for the refunding.
  function loadRefund() public payable inState(State.Failure) {
    require(msg.value > 0);
    loadedRefund = safeAdd(loadedRefund, msg.value);
  }

  /// @dev Investors can claim refund.
  function refund() public inState(State.Refunding) {
    uint256 weiValue = investedAmountOf[msg.sender];
    if (weiValue == 0)
      return;
    investedAmountOf[msg.sender] = 0;
    weiRefunded = safeAdd(weiRefunded, weiValue);
    Refund(msg.sender, weiValue);
    msg.sender.transfer(weiValue);
  }

  /// @dev Minimum goal was reached
  /// @return true if the crowdsale has raised enough money to not initiate the refunding
  function isMinimumGoalReached() public constant returns (bool reached) {
    return weiRaised >= MIN_ICO_GOAL;
  }

  /// @dev Check if the ICO goal was reached.
  /// @return true if the crowdsale has raised enough money to be a success
  function isCrowdsaleFull() public constant returns (bool) {
    return isMinimumGoalReached() && now > startsAt + ICO_DURATION;
  }

  /// @dev Crowdfund state machine management.
  /// @return State current state
  function getState() public constant returns (State) {
    if (finalized)
      return State.Finalized;
    if (address(token) == 0 || address(multisigWallet) == 0)
      return State.Preparing;
    if (preIcoTokensDistributed < token.convertToDecimal(PRE_ICO_MAX_TOKENS))
        return State.PreFunding;
    if (now >= startsAt && now < startsAt + ICO_DURATION && !isCrowdsaleFull())
      return State.Funding;
    if (isMinimumGoalReached())
      return State.Success;
    if (!isMinimumGoalReached() && weiRaised > 0 && loadedRefund >= weiRaised)
      return State.Refunding;
    return State.Failure;
  }

  
   /// @dev Dynamically create tokens and assign them to the investor.
   /// @param receiver investor address
   /// @param tokenAmount The amount of tokens we try to give to the investor in the current transaction
   function assignTokens(address receiver, uint tokenAmount) private {
     token.mint(receiver, tokenAmount);
   }
}