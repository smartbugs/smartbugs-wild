pragma solidity ^0.4.11;
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
/**
 * The QuantstampSale smart contract is used for selling QuantstampToken
 * tokens (QSP). It does so by converting ETH received into a quantity of
 * tokens that are transferred to the contributor via the ERC20-compatible
 * transferFrom() function.
 */
contract QuantstampSale is Pausable {
    using SafeMath for uint256;
    // The beneficiary is the future recipient of the funds
    address public beneficiary;
    // The crowdsale has a funding goal, cap, deadline, and minimum contribution
    uint public fundingCap;
    uint public minContribution;
    bool public fundingCapReached = false;
    bool public saleClosed = false;
    // Whitelist data
    mapping(address => bool) public registry;
    // For each user, specifies the cap (in wei) that can be contributed for each tier
    // Tiers are filled in the order 3, 2, 1, 4
    mapping(address => uint256) public cap1;        // 100% bonus
    mapping(address => uint256) public cap2;        // 40% bonus
    mapping(address => uint256) public cap3;        // 20% bonus
    mapping(address => uint256) public cap4;        // 0% bonus
    // Stores the amount contributed for each tier for a given address
    mapping(address => uint256) public contributed1;
    mapping(address => uint256) public contributed2;
    mapping(address => uint256) public contributed3;
    mapping(address => uint256) public contributed4;
    // Conversion rate by tier (QSP : ETHER)
    uint public rate1 = 10000;
    uint public rate2 = 7000;
    uint public rate3 = 6000;
    uint public rate4 = 5000;
    // Time period of sale (UNIX timestamps)
    uint public startTime;
    uint public endTime;
    // Keeps track of the amount of wei raised
    uint public amountRaised;
    // prevent certain functions from being recursively called
    bool private rentrancy_lock = false;
    // The token being sold
    // QuantstampToken public tokenReward;
    // A map that tracks the amount of wei contributed by address
    mapping(address => uint256) public balanceOf;
    // A map that tracks the amount of QSP tokens that should be allocated to each address
    mapping(address => uint256) public tokenBalanceOf;
    // Events
    event CapReached(address _beneficiary, uint _amountRaised);
    event FundTransfer(address _backer, uint _amount, bool _isContribution);
    event RegistrationStatusChanged(address target, bool isRegistered, uint c1, uint c2, uint c3, uint c4);
    // Modifiers
    modifier beforeDeadline()   { require (currentTime() < endTime); _; }
    // modifier afterDeadline()    { require (currentTime() >= endTime); _; } no longer used without fundingGoal
    modifier afterStartTime()    { require (currentTime() >= startTime); _; }
    modifier saleNotClosed()    { require (!saleClosed); _; }
    modifier nonReentrant() {
        require(!rentrancy_lock);
        rentrancy_lock = true;
        _;
        rentrancy_lock = false;
    }
    /**
     * Constructor for a crowdsale of QuantstampToken tokens.
     *
     * @param ifSuccessfulSendTo            the beneficiary of the fund
     * @param fundingCapInEthers            the cap (maximum) size of the fund
     * @param minimumContributionInWei      minimum contribution (in wei)
     * @param start                         the start time (UNIX timestamp)
     * @param durationInMinutes             the duration of the crowdsale in minutes
     */
    function QuantstampSale(
        address ifSuccessfulSendTo,
        uint fundingCapInEthers,
        uint minimumContributionInWei,
        uint start,
        uint durationInMinutes
        // address addressOfTokenUsedAsReward
    ) {
        require(ifSuccessfulSendTo != address(0) && ifSuccessfulSendTo != address(this));
        //require(addressOfTokenUsedAsReward != address(0) && addressOfTokenUsedAsReward != address(this));
        require(durationInMinutes > 0);
        beneficiary = ifSuccessfulSendTo;
        fundingCap = fundingCapInEthers * 1 ether;
        minContribution = minimumContributionInWei;
        startTime = start;
        endTime = start + (durationInMinutes * 1 minutes);
        // tokenReward = QuantstampToken(addressOfTokenUsedAsReward);
    }
    /**
     * This function is called whenever Ether is sent to the
     * smart contract. It can only be executed when the crowdsale is
     * not paused, not closed, and before the deadline has been reached.
     *
     * This function will update state variables for whether or not the
     * funding goal or cap have been reached. It also ensures that the
     * tokens are transferred to the sender, and that the correct
     * number of tokens are sent according to the current rate.
     */
    function () payable {
        buy();
    }
    function buy ()
        payable public
        whenNotPaused
        beforeDeadline
        afterStartTime
        saleNotClosed
        nonReentrant
    {
        require(msg.value >= minContribution);
        uint amount = msg.value;
        // ensure that the user adheres to whitelist restrictions
        require(registry[msg.sender]);
        uint numTokens = computeTokenAmount(msg.sender, amount);
        assert(numTokens > 0);
        // update the total amount raised
        amountRaised = amountRaised.add(amount);
        require(amountRaised <= fundingCap);
        // update the sender's balance of wei contributed
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        // add to the token balance of the sender
        tokenBalanceOf[msg.sender] = tokenBalanceOf[msg.sender].add(numTokens);
        FundTransfer(msg.sender, amount, true);
        updateFundingCap();
    }
    /**
    * Computes the amount of QSP that should be issued for the given transaction.
    * Contribution tiers are filled up in the order 3, 2, 1, 4.
    * @param addr      The wallet address of the contributor
    * @param amount    Amount of wei for payment
    */
    function computeTokenAmount(address addr, uint amount) internal
        returns (uint){
        require(amount > 0);
        uint r3 = cap3[addr].sub(contributed3[addr]);
        uint r2 = cap2[addr].sub(contributed2[addr]);
        uint r1 = cap1[addr].sub(contributed1[addr]);
        uint r4 = cap4[addr].sub(contributed4[addr]);
        uint numTokens = 0;
        // cannot contribute more than the remaining sum
        assert(amount <= r3.add(r2).add(r1).add(r4));
        // Compute tokens for tier 3
        if(r3 > 0){
            if(amount <= r3){
                contributed3[addr] = contributed3[addr].add(amount);
                return rate3.mul(amount);
            }
            else{
                numTokens = rate3.mul(r3);
                amount = amount.sub(r3);
                contributed3[addr] = cap3[addr];
            }
        }
        // Compute tokens for tier 2
        if(r2 > 0){
            if(amount <= r2){
                contributed2[addr] = contributed2[addr].add(amount);
                return numTokens.add(rate2.mul(amount));
            }
            else{
                numTokens = numTokens.add(rate2.mul(r2));
                amount = amount.sub(r2);
                contributed2[addr] = cap2[addr];
            }
        }
        // Compute tokens for tier 1
        if(r1 > 0){
            if(amount <= r1){
                contributed1[addr] = contributed1[addr].add(amount);
                return numTokens.add(rate1.mul(amount));
            }
            else{
                numTokens = numTokens.add(rate1.mul(r1));
                amount = amount.sub(r1);
                contributed1[addr] = cap1[addr];
            }
        }
        // Compute tokens for tier 4 (overflow)
        contributed4[addr] = contributed4[addr].add(amount);
        return numTokens.add(rate4.mul(amount));
    }
    /**
     * @dev Check if a contributor was at any point registered.
     *
     * @param contributor Address that will be checked.
     */
    function hasPreviouslyRegistered(address contributor)
        internal
        constant
        onlyOwner returns (bool)
    {
        // if caps for this customer exist, then the customer has previously been registered
        return (cap1[contributor].add(cap2[contributor]).add(cap3[contributor]).add(cap4[contributor])) > 0;
    }
    /*
    * If the user was already registered, ensure that the new caps do not conflict previous contributions
    *
    * NOTE: cannot use SafeMath here, because it exceeds the local variable stack limit.
    * Should be ok since it is onlyOwner, and conditionals should guard the subtractions from underflow.
    */
    function validateUpdatedRegistration(address addr, uint c1, uint c2, uint c3, uint c4)
        internal
        constant
        onlyOwner returns(bool)
    {
        return (contributed3[addr] <= c3) && (contributed2[addr] <= c2)
            && (contributed1[addr] <= c1) && (contributed4[addr] <= c4);
    }
    /**
     * @dev Sets registration status of an address for participation.
     *
     * @param contributor Address that will be registered/deregistered.
     * @param c1 The maximum amount of wei that the user can contribute in tier 1.
     * @param c2 The maximum amount of wei that the user can contribute in tier 2.
     * @param c3 The maximum amount of wei that the user can contribute in tier 3.
     * @param c4 The maximum amount of wei that the user can contribute in tier 4.
     */
    function registerUser(address contributor, uint c1, uint c2, uint c3, uint c4)
        public
        onlyOwner
    {
        require(contributor != address(0));
        // if the user was already registered ensure that the new caps do not contradict their current contributions
        if(hasPreviouslyRegistered(contributor)){
            require(validateUpdatedRegistration(contributor, c1, c2, c3, c4));
        }
        require(c1.add(c2).add(c3).add(c4) >= minContribution);
        registry[contributor] = true;
        cap1[contributor] = c1;
        cap2[contributor] = c2;
        cap3[contributor] = c3;
        cap4[contributor] = c4;
        RegistrationStatusChanged(contributor, true, c1, c2, c3, c4);
    }
     /**
     * @dev Remove registration status of an address for participation.
     *
     * NOTE: if the user made initial contributions to the crowdsale,
     *       this will not return the previously allotted tokens.
     *
     * @param contributor Address to be unregistered.
     */
    function deactivate(address contributor)
        public
        onlyOwner
    {
        require(registry[contributor]);
        registry[contributor] = false;
        RegistrationStatusChanged(contributor, false, cap1[contributor], cap2[contributor], cap3[contributor], cap4[contributor]);
    }
    /**
     * @dev Re-registers an already existing contributor
     *
     * @param contributor Address to be unregistered.
     */
    function reactivate(address contributor)
        public
        onlyOwner
    {
        require(hasPreviouslyRegistered(contributor));
        registry[contributor] = true;
        RegistrationStatusChanged(contributor, true, cap1[contributor], cap2[contributor], cap3[contributor], cap4[contributor]);
    }
    /**
     * @dev Sets registration statuses of addresses for participation.
     * @param contributors Addresses that will be registered/deregistered.
     * @param caps1 The maximum amount of wei that each user can contribute to cap1, in the same order as the addresses.
     * @param caps2 The maximum amount of wei that each user can contribute to cap2, in the same order as the addresses.
     * @param caps3 The maximum amount of wei that each user can contribute to cap3, in the same order as the addresses.
     * @param caps4 The maximum amount of wei that each user can contribute to cap4, in the same order as the addresses.
     */
    function registerUsers(address[] contributors,
                           uint[] caps1,
                           uint[] caps2,
                           uint[] caps3,
                           uint[] caps4)
        external
        onlyOwner
    {
        // check that all arrays have the same length
        require(contributors.length == caps1.length);
        require(contributors.length == caps2.length);
        require(contributors.length == caps3.length);
        require(contributors.length == caps4.length);
        for (uint i = 0; i < contributors.length; i++) {
            registerUser(contributors[i], caps1[i], caps2[i], caps3[i], caps4[i]);
        }
    }
    /**
     * The owner can terminate the crowdsale at any time.
     */
    function terminate() external onlyOwner {
        saleClosed = true;
    }
    /**
     * The owner can allocate the specified amount of tokens from the
     * crowdsale allowance to the recipient addresses.
     *
     * NOTE: be extremely careful to get the amounts correct, which
     * are in units of wei and mini-QSP. Every digit counts.
     *
     * @param addrs          the recipient addresses
     * @param weiAmounts     the amounts contributed in wei
     * @param miniQspAmounts the amounts of tokens transferred in mini-QSP
     */
    function ownerAllocateTokensForList(address[] addrs, uint[] weiAmounts, uint[] miniQspAmounts)
            external onlyOwner
    {
        require(addrs.length == weiAmounts.length);
        require(addrs.length == miniQspAmounts.length);
        for(uint i = 0; i < addrs.length; i++){
            ownerAllocateTokens(addrs[i], weiAmounts[i], miniQspAmounts[i]);
        }
    }
    /**
     *
     * The owner can allocate the specified amount of tokens from the
     * crowdsale allowance to the recipient (_to).
     *
     *
     *
     * NOTE: be extremely careful to get the amounts correct, which
     * are in units of wei and mini-QSP. Every digit counts.
     *
     * @param _to            the recipient of the tokens
     * @param amountWei     the amount contributed in wei
     * @param amountMiniQsp the amount of tokens transferred in mini-QSP
     */
    function ownerAllocateTokens(address _to, uint amountWei, uint amountMiniQsp)
            onlyOwner nonReentrant
    {
        // don't allocate tokens for the admin
        // require(tokenReward.adminAddr() != _to);
        amountRaised = amountRaised.add(amountWei);
        require(amountRaised <= fundingCap);
        tokenBalanceOf[_to] = tokenBalanceOf[_to].add(amountMiniQsp);
        balanceOf[_to] = balanceOf[_to].add(amountWei);
        FundTransfer(_to, amountWei, true);
        updateFundingCap();
    }
    /**
     * The owner can call this function to withdraw the funds that
     * have been sent to this contract for the crowdsale subject to
     * the funding goal having been reached. The funds will be sent
     * to the beneficiary specified when the crowdsale was created.
     */
    function ownerSafeWithdrawal() external onlyOwner nonReentrant {
        uint balanceToSend = this.balance;
        beneficiary.transfer(balanceToSend);
        FundTransfer(beneficiary, balanceToSend, false);
    }
    /**
     * Checks if the funding cap has been reached. If it has, then
     * the CapReached event is triggered.
     */
    function updateFundingCap() internal {
        assert (amountRaised <= fundingCap);
        if (amountRaised == fundingCap) {
            // Check if the funding cap has been reached
            fundingCapReached = true;
            saleClosed = true;
            CapReached(beneficiary, amountRaised);
        }
    }
    /**
     * Returns the current time.
     * Useful to abstract calls to "now" for tests.
    */
    function currentTime() constant returns (uint _currentTime) {
        return now;
    }
}