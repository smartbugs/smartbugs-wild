pragma solidity ^0.4.13;

contract Owned {
	modifier only_owner {
		if (msg.sender != owner)
			return;
		_; 
	}

	event NewOwner(address indexed old, address indexed current);

	function setOwner(address _new) only_owner { NewOwner(owner, _new); owner = _new; }

	address public owner = msg.sender;
}

library Math {
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
  function transferOwnership(address newOwner) public onlyOwner {
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
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

contract LegalLazyScheduler is Ownable {
    uint64 public lastUpdate;
    uint64 public intervalDuration;
    bool schedulerEnabled = false;
    function() internal callback;

    event LogRegisteredInterval(uint64 date, uint64 duration);
    event LogProcessedInterval(uint64 date, uint64 intervals);    
    /**
    * Triggers the registered callback function for the number of periods passed since last update
    */
    modifier intervalTrigger() {
        uint64 currentTime = uint64(now);
        uint64 requiredIntervals = (currentTime - lastUpdate) / intervalDuration;
        if( schedulerEnabled && (requiredIntervals > 0)) {
            LogProcessedInterval(lastUpdate, requiredIntervals);
            while (requiredIntervals-- > 0) {
                callback();
            }
            lastUpdate = currentTime;
        }
        _;
    }
    
    function LegalLazyScheduler() {
        lastUpdate = uint64(now);
    }

    function enableScheduler() onlyOwner public {
        schedulerEnabled = true;
    }

    function registerIntervalCall(uint64 _intervalDuration, function() internal _callback) internal {
        lastUpdate = uint64(now);
        intervalDuration = _intervalDuration;
        callback = _callback;
        LogRegisteredInterval(lastUpdate, intervalDuration);        
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

  function RefundVault(address _wallet) {
    require(_wallet != 0x0);
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyOwner {
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

contract LegalTGE is Ownable, Pausable {
  /**
  * The safe math library for safety math opertations provided by Zeppelin
  */
  using SafeMath for uint256;
  /** State machine
   * - PreparePreContribution: During this phase SmartOne adjust conversionRate and start/end date
   * - PreContribution: During this phase only registered users can contribute to the TGE and therefore receive a bonus until cap or end date is reached
   * - PrepareContribution: During this phase SmartOne adjusts conversionRate by the ETHUSD depreciation during PreContribution and change start and end date in case of an unforseen event 
   * - Contribution: During this all users can contribute until cap or end date is reached
   * - Auditing: SmartOne awaits recommendation by auditor and board of foundation will then finalize contribution or enable refunding
   * - Finalized: Token are released
   * - Refunding: Refunds can be claimed
   */
  enum States{PreparePreContribution, PreContribution, PrepareContribution, Contribution, Auditing, Finalized, Refunding}

  enum VerificationLevel { None, SMSVerified, KYCVerified }

 /**
  * Whenever the state of the contract changes, this event will be fired.
  */
  event LogStateChange(States _states);


  /**
  * This event is fired when a user has been successfully verified by the external KYC verification process
  */
  event LogKYCConfirmation(address sender);

  /**
  * Whenever a legalToken is assigned to this contract, this event will be fired.
  */
  event LogTokenAssigned(address sender, address newToken);

  /**
  * Every timed transition must be loged for auditing 
  */
  event LogTimedTransition(uint _now, States _newState);
  
  /**
  * This event is fired when PreContribution data is changed during the PreparePreContribution phase
  */
  event LogPreparePreContribution(address sender, uint conversionRate, uint startDate, uint endDate);

  /**
  * A user has transfered Ether and received unreleasead tokens in return
  */
  event LogContribution(address contributor, uint256 weiAmount, uint256 tokenAmount, VerificationLevel verificationLevel, States _state);

  /**
  * This event will be fired when SmartOne finalizes the TGE 
  */
  event LogFinalized(address sender);

  /**
  * This event will be fired when the auditor confirms the confirms regularity confirmity 
  */
  event LogRegularityConfirmation(address sender, bool _regularity, bytes32 _comment);
  
  /**
  * This event will be fired when refunding is enabled by the auditor 
  */
  event LogRefundsEnabled(address sender);

  /**
  * This event is fired when PreContribution data is changed during the PreparePreContribution phase
  */
  event LogPrepareContribution(address sender, uint conversionRate, uint startDate, uint endDate);

  /**
  * This refund vault used to hold funds while TGE is running.
  * Uses the default implementation provided by the OpenZeppelin community.
  */ 
  RefundVault public vault;

  /**
  * Defines the state of the conotribution process
  */
  States public state;

  /**
  * The token we are giving the contributors in return for their contributions
  */ 
  LegalToken public token;
  
  /**
  * The contract provided by Parity Tech (Gav Woods) to verify the mobile number during user registration
  */ 
  ProofOfSMS public proofOfSMS;

  /** 
  * The contribution (wei) will be forwarded to this address after the token has been finalized by the foundation board
  */
  address public multisigWallet;

  /** 
  * Maximum amount of wei this TGE can raise.
  */
  uint256 public tokenCap;

  /** 
  * The amount of wei a contributor has contributed. 
  * Used to check whether the total of contributions per user exceeds the max limit (depending on his verification level)
  */
  mapping (address => uint) public weiPerContributor;

  /** 
  * Minimum amount of tokens a contributor is able to buy
  */
  uint256 public minWeiPerContributor;

  /** 
  * Maximum amount of tokens an SMS verified user can contribute.
  */
  uint256 public maxWeiSMSVerified;

  /** 
  * Maximum amount of tokens an none-verified user can contribute.
  */
  uint256 public maxWeiUnverified;

  /* 
  * The number of token units a contributor receives per ETHER during pre-contribtion phase
  */ 
  uint public preSaleConversionRate;

  /* 
  * The UNIX timestamp (in seconds) defining when the pre-contribution phase will start
  */
  uint public preSaleStartDate;

  /* 
  * The UNIX timestamp (in seconds) defining when the TGE will end
  */
  uint public preSaleEndDate;

  /* 
  * The number of token units a contributor receives per ETHER during contribution phase
  */ 
  uint public saleConversionRate;

  /* 
  * The UNIX timestamp (in seconds) defining when the TGE will start
  */
  uint public saleStartDate;

  /* 
  * The UNIX timestamp (in seconds) defining when the TGE would end if cap will not be reached
  */
  uint public saleEndDate;

  /* 
  * The bonus a sms verified user will receive for a contribution during pre-contribution phase in base points
  */
  uint public smsVerifiedBonusBps;

  /* 
  * The bonus a kyc verified user will receive for a contribution during pre-contribution phase in base points
  */
  uint public kycVerifiedBonusBps;

  /**
  * Total percent of tokens minted to the team at the end of the sale as base points
  * 1BP -> 0.01%
  */
  uint public maxTeamBonusBps;

  /**
  * Only the foundation board is able to finalize the TGE.
  * Two of four members have to confirm the finalization. Therefore a multisig contract is used.
  */
  address public foundationBoard;

  /**
  * Only the KYC confirmation account is allowed to confirm a successfull KYC verification
  */
  address public kycConfirmer;

  /**
  * Once the contribution has ended an auditor will verify whether all regulations have been fullfilled
  */
  address public auditor;

  /**
  * The tokens for the insitutional investors will be allocated to this wallet
  */
  address public instContWallet;

  /**
  * This flag ist set by auditor before finalizing the TGE to indicate whether all regualtions have been fulfilled
  */
  bool public regulationsFulfilled;

  /**
  * The auditor can comment the confirmation (e.g. in case of deviations)
  */
  bytes32 public auditorComment;

  /**
  * The total number of institutional and public tokens sold during pre- and contribution phase
  */
  uint256 public tokensSold = 0;

  /*
  * The number of tokens pre allocated to insitutional contributors
  */
  uint public instContAllocatedTokens;

  /**
  * The amount of wei totally raised by the public TGE
  */
  uint256 public weiRaised = 0;

  /* 
  * The amount of wei raised during the preContribution phase 
  */
  uint256 public preSaleWeiRaised = 0;

  /*
  * How much wei we have given back to contributors.
  */
  uint256 public weiRefunded = 0;

  /*
  * The number of tokens allocated to the team when the TGE was finalized.
  * The calculation is based on the predefined maxTeamBonusBps
  */
  uint public teamBonusAllocatedTokens;

  /**
  * The number of contributors which have contributed to the TGE
  */
  uint public numberOfContributors = 0;

  /**
  * dictionary that maps addresses to contributors which have sucessfully been verified by the external KYC process 
  */
  mapping (address => bool) public kycRegisteredContributors;

  struct TeamBonus {
    address toAddress;
    uint64 tokenBps;
    uint64 cliffDate;
    uint64 vestingDate;
  }

  /*
  * Defines the percentage (base points) distribution of the team-allocated bonus rewards among members which will be vested ..
  * 1 Bp -> 0.01%
  */
  TeamBonus[] public teamBonuses;

  /**
   * @dev Check whether the TGE is currently in the state provided
   */

 function LegalTGE (address _foundationBoard, address _multisigWallet, address _instContWallet, uint256 _instContAllocatedTokens, uint256 _tokenCap, uint256 _smsVerifiedBonusBps, uint256 _kycVerifiedBonusBps, uint256 _maxTeamBonusBps, address _auditor, address _kycConfirmer, ProofOfSMS _proofOfSMS, RefundVault _vault) {
     // --------------------------------------------------------------------------------
    // -- Validate all variables which are not passed to the constructor first
    // --------------------------------------------------------------------------------
    // the address of the account used for auditing
    require(_foundationBoard != 0x0);
    
    // the address of the multisig must not be 'undefined'
    require(_multisigWallet != 0x0);

    // the address of the wallet for constitutional contributors must not be 'undefined'
    require(_instContWallet != 0x0);

    // the address of the account used for auditing
    require(_auditor != 0x0);
    
    // the address of the cap for this TGE must not be 'undefined'
    require(_tokenCap > 0); 

    // pre-contribution and contribution phases must not overlap
    // require(_preSaleStartDate <= _preSaleEndDate);

    multisigWallet = _multisigWallet;
    instContWallet = _instContWallet;
    instContAllocatedTokens = _instContAllocatedTokens;
    tokenCap = _tokenCap;
    smsVerifiedBonusBps = _smsVerifiedBonusBps;
    kycVerifiedBonusBps = _kycVerifiedBonusBps;
    maxTeamBonusBps = _maxTeamBonusBps;
    auditor = _auditor;
    foundationBoard = _foundationBoard;
    kycConfirmer = _kycConfirmer;
    proofOfSMS = _proofOfSMS;

    // --------------------------------------------------------------------------------
    // -- Initialize all variables which are not passed to the constructor first
    // --------------------------------------------------------------------------------
    state = States.PreparePreContribution;
    vault = _vault;
  }

  /** =============================================================================================================================
  * All logic related to the TGE contribution is currently placed below.
  * ============================================================================================================================= */

  function setMaxWeiForVerificationLevels(uint _minWeiPerContributor, uint _maxWeiUnverified, uint  _maxWeiSMSVerified) public onlyOwner inState(States.PreparePreContribution) {
    require(_minWeiPerContributor >= 0);
    require(_maxWeiUnverified > _minWeiPerContributor);
    require(_maxWeiSMSVerified > _minWeiPerContributor);

    // the minimum number of wei an unverified user can contribute
    minWeiPerContributor = _minWeiPerContributor;

    // the maximum number of wei an unverified user can contribute
    maxWeiUnverified = _maxWeiUnverified;

    // the maximum number of wei an SMS verified user can contribute    
    maxWeiSMSVerified = _maxWeiSMSVerified;
  }

  function setLegalToken(LegalToken _legalToken) public onlyOwner inState(States.PreparePreContribution) {
    token = _legalToken;
    if ( instContAllocatedTokens > 0 ) {
      // mint the pre allocated tokens for the institutional investors
      token.mint(instContWallet, instContAllocatedTokens);
      tokensSold += instContAllocatedTokens;
    }    
    LogTokenAssigned(msg.sender, _legalToken);
  }

  function validatePreContribution(uint _preSaleConversionRate, uint _preSaleStartDate, uint _preSaleEndDate) constant internal {
    // the pre-contribution conversion rate must not be 'undefined'
    require(_preSaleConversionRate >= 0);

    // the pre-contribution start date must not be in the past
    require(_preSaleStartDate >= now);

    // the pre-contribution start date must not be in the past
    require(_preSaleEndDate >= _preSaleStartDate);
  }

  function validateContribution(uint _saleConversionRate, uint _saleStartDate, uint _saleEndDate) constant internal {
    // the contribution conversion rate must not be 'undefined'
    require(_saleConversionRate >= 0);

    // the contribution start date must not be in the past
    require(_saleStartDate >= now);

    // the contribution end date must not be before start date 
    require(_saleEndDate >= _saleStartDate);
  }

  function isNowBefore(uint _date) constant internal returns (bool) {
    return ( now < _date );
  }

  function evalTransitionState() public returns (States) {
    // once the TGE is in state finalized or refunding, there is now way to transit to another state!
    if ( hasState(States.Finalized))
      return States.Finalized;
    if ( hasState(States.Refunding))
      return States.Refunding;
    if ( isCapReached()) 
      return States.Auditing;
    if ( isNowBefore(preSaleStartDate))
      return States.PreparePreContribution; 
    if ( isNowBefore(preSaleEndDate))
      return States.PreContribution;
    if ( isNowBefore(saleStartDate))  
      return States.PrepareContribution;
    if ( isNowBefore(saleEndDate))    
      return States.Contribution;
    return States.Auditing;
  }

  modifier stateTransitions() {
    States evaluatedState = evalTransitionState();
    setState(evaluatedState);
    _;
  }

  function hasState(States _state) constant private returns (bool) {
    return (state == _state);
  }

  function setState(States _state) private {
  	if ( _state != state ) {
      state = _state;
	  LogStateChange(state);
	  }
  }

  modifier inState(States  _state) {
    require(hasState(_state));
    _;
  }

  function updateState() public stateTransitions {
  }  
  
  /**
   * @dev Checks whether contract is in a state in which contributions will be accepted
   */
  modifier inPreOrContributionState() {
    require(hasState(States.PreContribution) || (hasState(States.Contribution)));
    _;
  }
  modifier inPrePrepareOrPreContributionState() {
    require(hasState(States.PreparePreContribution) || (hasState(States.PreContribution)));
    _;
  }

  modifier inPrepareState() {
    // we can relay on state since modifer since already evaluated by stateTransitions modifier
    require(hasState(States.PreparePreContribution) || (hasState(States.PrepareContribution)));
    _;
  }
  /** 
  * This modifier makes sure that not more tokens as specified can be allocated
  */
  modifier teamBonusLimit(uint64 _tokenBps) {
    uint teamBonusBps = 0; 
    for ( uint i = 0; i < teamBonuses.length; i++ ) {
      teamBonusBps = teamBonusBps.add(teamBonuses[i].tokenBps);
    }
    require(maxTeamBonusBps >= teamBonusBps);
    _;
  }

  /**
  * Allocates the team bonus with a specific vesting rule
  */
  function allocateTeamBonus(address _toAddress, uint64 _tokenBps, uint64 _cliffDate, uint64 _vestingDate) public onlyOwner teamBonusLimit(_tokenBps) inState(States.PreparePreContribution) {
    teamBonuses.push(TeamBonus(_toAddress, _tokenBps, _cliffDate, _vestingDate));
  }

  /**
  * This method can optional be called by the owner to adjust the conversionRate, startDate and endDate before contribution phase starts.
  * Pre-conditions:
  * - Caller is owner (deployer)
  * - TGE is in state PreContribution
  * Post-conditions:
  */
  function preparePreContribution(uint _preSaleConversionRate, uint _preSaleStartDate, uint _preSaleEndDate) public onlyOwner inState(States.PreparePreContribution) {
    validatePreContribution(_preSaleConversionRate, _preSaleStartDate, _preSaleEndDate);    
    preSaleConversionRate = _preSaleConversionRate;
    preSaleStartDate = _preSaleStartDate;
    preSaleEndDate = _preSaleEndDate;
    LogPreparePreContribution(msg.sender, preSaleConversionRate, preSaleStartDate, preSaleEndDate);
  }

  /**
  * This method can optional be called by the owner to adjust the conversionRate, startDate and endDate before pre contribution phase starts.
  * Pre-conditions:
  * - Caller is owner (deployer)
  * - Crowdsale is in state PreparePreContribution
  * Post-conditions:
  */
  function prepareContribution(uint _saleConversionRate, uint _saleStartDate, uint _saleEndDate) public onlyOwner inPrepareState {
    validateContribution(_saleConversionRate, _saleStartDate, _saleEndDate);
    saleConversionRate = _saleConversionRate;
    saleStartDate = _saleStartDate;
    saleEndDate = _saleEndDate;

    LogPrepareContribution(msg.sender, saleConversionRate, saleStartDate, saleEndDate);
  }

  // fallback function can be used to buy tokens
  function () payable public {
    contribute();  
  }
  function getWeiPerContributor(address _contributor) public constant returns (uint) {
  	return weiPerContributor[_contributor];
  }

  function contribute() whenNotPaused stateTransitions inPreOrContributionState public payable {
    require(msg.sender != 0x0);
    require(msg.value >= minWeiPerContributor);

    VerificationLevel verificationLevel = getVerificationLevel();
    
    // we only allow verified users to participate during pre-contribution phase
    require(hasState(States.Contribution) || verificationLevel > VerificationLevel.None);

    // we need to keep track of all contributions per user to limit total contributions
    weiPerContributor[msg.sender] = weiPerContributor[msg.sender].add(msg.value);

    // the total amount of ETH a KYC verified user can contribute is unlimited, so we do not need to check

    if ( verificationLevel == VerificationLevel.SMSVerified ) {
      // the total amount of ETH a non-KYC user can contribute is limited to maxWeiPerContributor
      require(weiPerContributor[msg.sender] <= maxWeiSMSVerified);
    }

    if ( verificationLevel == VerificationLevel.None ) {
      // the total amount of ETH a non-verified user can contribute is limited to maxWeiUnverified
      require(weiPerContributor[msg.sender] <= maxWeiUnverified);
    }

    if (hasState(States.PreContribution)) {
      preSaleWeiRaised = preSaleWeiRaised.add(msg.value);
    }

    weiRaised = weiRaised.add(msg.value);

    // calculate the token amount to be created
    uint256 tokenAmount = calculateTokenAmount(msg.value, verificationLevel);

    tokensSold = tokensSold.add(tokenAmount);

    if ( token.balanceOf(msg.sender) == 0 ) {
       numberOfContributors++;
    }

    if ( isCapReached()) {
      updateState();
    }

    token.mint(msg.sender, tokenAmount);

    forwardFunds();

    LogContribution(msg.sender, msg.value, tokenAmount, verificationLevel, state);    
  }

 
  function calculateTokenAmount(uint256 _weiAmount, VerificationLevel _verificationLevel) public constant returns (uint256) {
    uint256 conversionRate = saleConversionRate;
    if ( state == States.PreContribution) {
      conversionRate = preSaleConversionRate;
    }
    uint256 tokenAmount = _weiAmount.mul(conversionRate);
    
    // an anonymous user (Level-0) gets no bonus
    uint256 bonusTokenAmount = 0;

    if ( _verificationLevel == VerificationLevel.SMSVerified ) {
      // a SMS verified user (Level-1) gets a bonus
      bonusTokenAmount = tokenAmount.mul(smsVerifiedBonusBps).div(10000);
    } else if ( _verificationLevel == VerificationLevel.KYCVerified ) {
      // a KYC verified user (Level-2) gets the highest bonus
      bonusTokenAmount = tokenAmount.mul(kycVerifiedBonusBps).div(10000);
    }
    return tokenAmount.add(bonusTokenAmount);
  }

  function getVerificationLevel() constant public returns (VerificationLevel) {
    if (kycRegisteredContributors[msg.sender]) {
      return VerificationLevel.KYCVerified;
    } else if (proofOfSMS.certified(msg.sender)) {
      return VerificationLevel.SMSVerified;
    }
    return VerificationLevel.None;
  }

  modifier onlyKycConfirmer() {
    require(msg.sender == kycConfirmer);
    _;
  }

  function confirmKYC(address addressId) onlyKycConfirmer inPrePrepareOrPreContributionState() public returns (bool) {
    LogKYCConfirmation(msg.sender);
    return kycRegisteredContributors[addressId] = true;
  }

// =============================================================================================================================
// All functions related to the TGE cap come here
// =============================================================================================================================
  function isCapReached() constant internal returns (bool) {
    if (tokensSold >= tokenCap) {
      return true;
    }
    return false;
  }

// =============================================================================================================================
// Everything which is related tof the auditing process comes here.
// =============================================================================================================================
  /**
   * @dev Throws if called by any account other than the foundation board
   */
  modifier onlyFoundationBoard() {
    require(msg.sender == foundationBoard);
    _;
  }

  /**
   * @dev Throws if called by any account other than the auditor.
   */
  modifier onlyAuditor() {
    require(msg.sender == auditor);
    _;
  }
  
  /**
   * @dev Throws if auditor has not yet confirmed TGE
   */
  modifier auditorConfirmed() {
    require(auditorComment != 0x0);
    _;
  }

 /*
 * After the TGE reaches state 'auditing', the auditor will verify the legal and regulatory obligations 
 */
 function confirmLawfulness(bool _regulationsFulfilled, bytes32 _auditorComment) public onlyAuditor stateTransitions inState ( States.Auditing ) {
    regulationsFulfilled = _regulationsFulfilled;
    auditorComment = _auditorComment;
    LogRegularityConfirmation(msg.sender, _regulationsFulfilled, _auditorComment);
  }

  /**
   * After the auditor has verified the the legal and regulatory obligations of the TGE, the foundation board is able to finalize the TGE.
   * The finalization consists of the following steps:
   * - Transit state
   * - close the RefundVault and transfer funds to the foundation wallet
   * - release tokens (make transferable)
   * - enable scheduler for the inflation compensation
   * - Min the defined amount of token per team and make them vestable
   */
  function finalize() public onlyFoundationBoard stateTransitions inState ( States.Auditing ) auditorConfirmed {
    setState(States.Finalized);
    // Make token transferable otherwise the transfer call used when granting vesting to teams will be rejected.
    token.releaseTokenTransfer();
    
    // mint bonusus for 
    allocateTeamBonusTokens();

    // the funds can now be transfered to the multisig wallet of the foundation
    vault.close();

    // disable minting for the TGE (though tokens will still be minted to compensate an inflation period) 
    token.finishMinting();

    // now we can safely enable the shceduler for inflation compensation
    token.enableScheduler();

    // pass ownership from contract to SmartOne
    token.transferOwnership(owner);

    LogFinalized(msg.sender);
  }

  function enableRefunds() public onlyFoundationBoard stateTransitions inState ( States.Auditing ) auditorConfirmed {
    setState(States.Refunding);

    LogRefundsEnabled(msg.sender);

    // no need to trigger event here since this allready done in RefundVault (see event RefundsEnabled) 
    vault.enableRefunds(); 
  }
  

// =============================================================================================================================
// Postallocation Reward Tokens
// =============================================================================================================================
  
  /** 
  * Called once by TGE finalize() if the sale was success.
  */
  function allocateTeamBonusTokens() private {

    for (uint i = 0; i < teamBonuses.length; i++) {
      // How many % of tokens the team member receive as rewards
      uint _teamBonusTokens = (tokensSold.mul(teamBonuses[i].tokenBps)).div(10000);

      // mint new tokens for contributors
      token.mint(this, _teamBonusTokens);
      token.grantVestedTokens(teamBonuses[i].toAddress, _teamBonusTokens, uint64(now), teamBonuses[i].cliffDate, teamBonuses[i].vestingDate, false, false);
      teamBonusAllocatedTokens = teamBonusAllocatedTokens.add(_teamBonusTokens);
    }
  }

  // =============================================================================================================================
  // All functions related to Refunding can be found here. 
  // Uses some slightly modifed logic from https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/crowdsale/RefundableTGE.sol
  // =============================================================================================================================

  /** We're overriding the fund forwarding from TGE.
  * In addition to sending the funds, we want to call
  * the RefundVault deposit function
  */
  function forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }

  /**
  * If TGE was not successfull refunding process will be released by SmartOne
  */
  function claimRefund() public stateTransitions inState ( States.Refunding ) {
    // workaround since vault refund does not return refund value
    weiRefunded = weiRefunded.add(vault.deposited(msg.sender));
    vault.refund(msg.sender);
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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

contract LimitedTransferToken is ERC20 {

  /**
   * @dev Checks whether it can transfer or otherwise throws.
   */
  modifier canTransfer(address _sender, uint256 _value) {
    require(_value <= transferableTokens(_sender, uint64(now)));
   _;
  }

  /**
   * @dev Checks modifier and allows transfer if tokens are not locked.
   * @param _to The address that will receive the tokens.
   * @param _value The amount of tokens to be transferred.
   */
  function transfer(address _to, uint256 _value) canTransfer(msg.sender, _value) public returns (bool) {
    return super.transfer(_to, _value);
  }

  /**
  * @dev Checks modifier and allows transfer if tokens are not locked.
  * @param _from The address that will send the tokens.
  * @param _to The address that will receive the tokens.
  * @param _value The amount of tokens to be transferred.
  */
  function transferFrom(address _from, address _to, uint256 _value) canTransfer(_from, _value) public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Default transferable tokens function returns all tokens for a holder (no limit).
   * @dev Overwriting transferableTokens(address holder, uint64 time) is the way to provide the
   * specific logic for limiting token transferability for a holder over time.
   */
  function transferableTokens(address holder, uint64 time) public constant returns (uint256) {
    return balanceOf(holder);
  }
}

contract VestedToken is StandardToken, LimitedTransferToken, Ownable {

  uint256 MAX_GRANTS_PER_ADDRESS = 20;

  struct TokenGrant {
    address granter;     // 20 bytes
    uint256 value;       // 32 bytes
    uint64 cliff;
    uint64 vesting;
    uint64 start;        // 3 * 8 = 24 bytes
    bool revokable;
    bool burnsOnRevoke;  // 2 * 1 = 2 bits? or 2 bytes?
  } // total 78 bytes = 3 sstore per operation (32 per sstore)

  mapping (address => TokenGrant[]) public grants;

  event NewTokenGrant(address indexed from, address indexed to, uint256 value, uint256 grantId);

  /**
   * @dev Grant tokens to a specified address
   * @param _to address The address which the tokens will be granted to.
   * @param _value uint256 The amount of tokens to be granted.
   * @param _start uint64 Time of the beginning of the grant.
   * @param _cliff uint64 Time of the cliff period.
   * @param _vesting uint64 The vesting period.
   */
  function grantVestedTokens(
    address _to,
    uint256 _value,
    uint64 _start,
    uint64 _cliff,
    uint64 _vesting,
    bool _revokable,
    bool _burnsOnRevoke
  ) onlyOwner public {

    // Check for date inconsistencies that may cause unexpected behavior
    require(_cliff >= _start && _vesting >= _cliff);

    require(tokenGrantsCount(_to) < MAX_GRANTS_PER_ADDRESS);   // To prevent a user being spammed and have his balance locked (out of gas attack when calculating vesting).

    uint256 count = grants[_to].push(
                TokenGrant(
                  _revokable ? msg.sender : 0, // avoid storing an extra 20 bytes when it is non-revokable
                  _value,
                  _cliff,
                  _vesting,
                  _start,
                  _revokable,
                  _burnsOnRevoke
                )
              );

    transfer(_to, _value);

    NewTokenGrant(msg.sender, _to, _value, count - 1);
  }

  /**
   * @dev Revoke the grant of tokens of a specifed address.
   * @param _holder The address which will have its tokens revoked.
   * @param _grantId The id of the token grant.
   */
  function revokeTokenGrant(address _holder, uint256 _grantId) public {
    TokenGrant storage grant = grants[_holder][_grantId];

    require(grant.revokable);
    require(grant.granter == msg.sender); // Only granter can revoke it

    address receiver = grant.burnsOnRevoke ? 0xdead : msg.sender;

    uint256 nonVested = nonVestedTokens(grant, uint64(now));

    // remove grant from array
    delete grants[_holder][_grantId];
    grants[_holder][_grantId] = grants[_holder][grants[_holder].length.sub(1)];
    grants[_holder].length -= 1;

    balances[receiver] = balances[receiver].add(nonVested);
    balances[_holder] = balances[_holder].sub(nonVested);

    Transfer(_holder, receiver, nonVested);
  }


  /**
   * @dev Calculate the total amount of transferable tokens of a holder at a given time
   * @param holder address The address of the holder
   * @param time uint64 The specific time.
   * @return An uint256 representing a holder's total amount of transferable tokens.
   */
  function transferableTokens(address holder, uint64 time) public constant returns (uint256) {
    uint256 grantIndex = tokenGrantsCount(holder);

    if (grantIndex == 0) 
      return super.transferableTokens(holder, time); // shortcut for holder without grants

    // Iterate through all the grants the holder has, and add all non-vested tokens
    uint256 nonVested = 0;
    for (uint256 i = 0; i < grantIndex; i++) {
      nonVested = SafeMath.add(nonVested, nonVestedTokens(grants[holder][i], time));
    }

    // Balance - totalNonVested is the amount of tokens a holder can transfer at any given time
    uint256 vestedTransferable = SafeMath.sub(balanceOf(holder), nonVested);

    // Return the minimum of how many vested can transfer and other value
    // in case there are other limiting transferability factors (default is balanceOf)
    return Math.min256(vestedTransferable, super.transferableTokens(holder, time));
  }

  /**
   * @dev Check the amount of grants that an address has.
   * @param _holder The holder of the grants.
   * @return A uint256 representing the total amount of grants.
   */
  function tokenGrantsCount(address _holder) public constant returns (uint256 index) {
    return grants[_holder].length;
  }

  /**
   * @dev Calculate amount of vested tokens at a specific time
   * @param tokens uint256 The amount of tokens granted
   * @param time uint64 The time to be checked
   * @param start uint64 The time representing the beginning of the grant
   * @param cliff uint64  The cliff period, the period before nothing can be paid out
   * @param vesting uint64 The vesting period
   * @return An uint256 representing the amount of vested tokens of a specific grant
   *  transferableTokens
   *   |                         _/--------   vestedTokens rect
   *   |                       _/
   *   |                     _/
   *   |                   _/
   *   |                 _/
   *   |                /
   *   |              .|
   *   |            .  |
   *   |          .    |
   *   |        .      |
   *   |      .        |
   *   |    .          |
   *   +===+===========+---------+----------> time
   *      Start       Cliff    Vesting
   */
  function calculateVestedTokens(
    uint256 tokens,
    uint256 time,
    uint256 start,
    uint256 cliff,
    uint256 vesting) public constant returns (uint256)
    {
      // Shortcuts for before cliff and after vesting cases.
      if (time < cliff) return 0;
      if (time >= vesting) return tokens;

      // Interpolate all vested tokens.
      // As before cliff the shortcut returns 0, we can use just calculate a value
      // in the vesting rect (as shown in above's figure)

      // vestedTokens = (tokens * (time - start)) / (vesting - start)
      uint256 vestedTokens = SafeMath.div(
                                    SafeMath.mul(
                                      tokens,
                                      SafeMath.sub(time, start)
                                      ),
                                    SafeMath.sub(vesting, start)
                                    );

      return vestedTokens;
  }

  /**
   * @dev Get all information about a specific grant.
   * @param _holder The address which will have its tokens revoked.
   * @param _grantId The id of the token grant.
   * @return Returns all the values that represent a TokenGrant(address, value, start, cliff,
   * revokability, burnsOnRevoke, and vesting) plus the vested value at the current time.
   */
  function tokenGrant(address _holder, uint256 _grantId) public constant returns (address granter, uint256 value, uint256 vested, uint64 start, uint64 cliff, uint64 vesting, bool revokable, bool burnsOnRevoke) {
    TokenGrant storage grant = grants[_holder][_grantId];

    granter = grant.granter;
    value = grant.value;
    start = grant.start;
    cliff = grant.cliff;
    vesting = grant.vesting;
    revokable = grant.revokable;
    burnsOnRevoke = grant.burnsOnRevoke;

    vested = vestedTokens(grant, uint64(now));
  }

  /**
   * @dev Get the amount of vested tokens at a specific time.
   * @param grant TokenGrant The grant to be checked.
   * @param time The time to be checked
   * @return An uint256 representing the amount of vested tokens of a specific grant at a specific time.
   */
  function vestedTokens(TokenGrant grant, uint64 time) private constant returns (uint256) {
    return calculateVestedTokens(
      grant.value,
      uint256(time),
      uint256(grant.start),
      uint256(grant.cliff),
      uint256(grant.vesting)
    );
  }

  /**
   * @dev Calculate the amount of non vested tokens at a specific time.
   * @param grant TokenGrant The grant to be checked.
   * @param time uint64 The time to be checked
   * @return An uint256 representing the amount of non vested tokens of a specific grant on the
   * passed time frame.
   */
  function nonVestedTokens(TokenGrant grant, uint64 time) private constant returns (uint256) {
    return grant.value.sub(vestedTokens(grant, time));
  }

  /**
   * @dev Calculate the date when the holder can transfer all its tokens
   * @param holder address The address of the holder
   * @return An uint256 representing the date of the last transferable tokens.
   */
  function lastTokenIsTransferableDate(address holder) public constant returns (uint64 date) {
    date = uint64(now);
    uint256 grantIndex = grants[holder].length;
    for (uint256 i = 0; i < grantIndex; i++) {
      date = Math.max64(grants[holder][i].vesting, date);
    }
  }
}

contract Certifier {
	event Confirmed(address indexed who);
	event Revoked(address indexed who);
	function certified(address _who) constant returns (bool);
	// function get(address _who, string _field) constant returns (bytes32) {}
	// function getAddress(address _who, string _field) constant returns (address) {}
	// function getUint(address _who, string _field) constant returns (uint) {}
}

contract SimpleCertifier is Owned, Certifier {

	modifier only_delegate {
		assert(msg.sender == delegate);
		_; 
	}
	modifier only_certified(address _who) {
		if (!certs[_who].active)
			return;
		_; 
	}

	struct Certification {
		bool active;
		mapping (string => bytes32) meta;
	}

	function certify(address _who) only_delegate {
		certs[_who].active = true;
		Confirmed(_who);
	}
	function revoke(address _who) only_delegate only_certified(_who) {
		certs[_who].active = false;
		Revoked(_who);
	}
	function certified(address _who) constant returns (bool) { return certs[_who].active; }
	// function get(address _who, string _field) constant returns (bytes32) { return certs[_who].meta[_field]; }
	// function getAddress(address _who, string _field) constant returns (address) { return address(certs[_who].meta[_field]); }
	// function getUint(address _who, string _field) constant returns (uint) { return uint(certs[_who].meta[_field]); }
	function setDelegate(address _new) only_owner { delegate = _new; }

	mapping (address => Certification) certs;
	// So that the server posting puzzles doesn't have access to the ETH.
	address public delegate = msg.sender;
}

contract ProofOfSMS is SimpleCertifier {

	modifier when_fee_paid {
		if (msg.value < fee)  {
		RequiredFeeNotMet(fee, msg.value);
			return;
		}
		_; 
	}
	event RequiredFeeNotMet(uint required, uint provided);
	event Requested(address indexed who);
	event Puzzled(address who, bytes32 puzzle);

	event LogAddress(address test);

	function request() payable when_fee_paid {
		if (certs[msg.sender].active) {
			return;
		}
		Requested(msg.sender);
	}

	function puzzle (address _who, bytes32 _puzzle) only_delegate {
		puzzles[_who] = _puzzle;
		Puzzled(_who, _puzzle);
	}

	function confirm(bytes32 _code) returns (bool) {
		LogAddress(msg.sender);
		if (puzzles[msg.sender] != sha3(_code))
			return;

		delete puzzles[msg.sender];
		certs[msg.sender].active = true;
		Confirmed(msg.sender);
		return true;
	}

	function setFee(uint _new) only_owner {
		fee = _new;
	}

	function drain() only_owner {
		require(msg.sender.send(this.balance));
	}

	function certified(address _who) constant returns (bool) {
		return certs[_who].active;
	}

	mapping (address => bytes32) puzzles;

	uint public fee = 30 finney;
}

contract LegalToken is LegalLazyScheduler, MintableToken, VestedToken {
    /**
    * The name of the token
    */
    bytes32 public name;

    /**
    * The symbol used for exchange
    */
    bytes32 public symbol;

    /**
    * Use to convert to number of tokens.
    */
    uint public decimals = 18;

    /**
    * The yearly expected inflation rate in base points.
    */
    uint32 public inflationCompBPS;

    /**
    * The tokens are locked until the end of the TGE.
    * The contract can release the tokens if TGE successful. If false we are in transfer lock up period.
    */
    bool public released = false;

    /**
    * Annually new minted tokens will be transferred to this wallet.
    * Publications will be rewarded with funds (incentives).  
    */
    address public rewardWallet;

    /**
    * Name and symbol were updated. 
    */
    event UpdatedTokenInformation(bytes32 newName, bytes32 newSymbol);

    /**
    * @dev Constructor that gives msg.sender all of existing tokens. 
    */
    function LegalToken(address _rewardWallet, uint32 _inflationCompBPS, uint32 _inflationCompInterval) onlyOwner public {
        setTokenInformation("Legal Token", "LGL");
        totalSupply = 0;        
        rewardWallet = _rewardWallet;
        inflationCompBPS = _inflationCompBPS;
        registerIntervalCall(_inflationCompInterval, mintInflationPeriod);
    }    

    /**
    * This function allows the token owner to rename the token after the operations
    * have been completed and then point the audience to use the token contract.
    */
    function setTokenInformation(bytes32 _name, bytes32 _symbol) onlyOwner public {
        name = _name;
        symbol = _symbol;
        UpdatedTokenInformation(name, symbol);
    }

    /**
    * Mint new tokens for the predefined inflation period and assign them to the reward wallet. 
    */
    function mintInflationPeriod() private {
        uint256 tokensToMint = totalSupply.mul(inflationCompBPS).div(10000);
        totalSupply = totalSupply.add(tokensToMint);
        balances[rewardWallet] = balances[rewardWallet].add(tokensToMint);
        Mint(rewardWallet, tokensToMint);
        Transfer(0x0, rewardWallet, tokensToMint);
    }     
    
    function setRewardWallet(address _rewardWallet) public onlyOwner {
        rewardWallet = _rewardWallet;
    }

    /**
    * Limit token transfer until the TGE is over.
    */
    modifier tokenReleased(address _sender) {
        require(released);
        _;
    }

    /**
    * This will make the tokens transferable
    */
    function releaseTokenTransfer() public onlyOwner {
        released = true;
    }

    // error: canTransfer(msg.sender, _value)
    function transfer(address _to, uint _value) public tokenReleased(msg.sender) intervalTrigger returns (bool success) {
        // Calls StandardToken.transfer()
        // error: super.transfer(_to, _value);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public tokenReleased(_from) intervalTrigger returns (bool success) {
        // Calls StandardToken.transferForm()
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public tokenReleased(msg.sender) intervalTrigger returns (bool) {
        // calls StandardToken.approve(..)
        return super.approve(_spender, _value);
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        // calls StandardToken.allowance(..)
        return super.allowance(_owner, _spender);
    }

    function increaseApproval (address _spender, uint _addedValue) public tokenReleased(msg.sender) intervalTrigger returns (bool success) {
        // calls StandardToken.increaseApproval(..)
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval (address _spender, uint _subtractedValue) public tokenReleased(msg.sender) intervalTrigger returns (bool success) {
        // calls StandardToken.decreaseApproval(..)
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}