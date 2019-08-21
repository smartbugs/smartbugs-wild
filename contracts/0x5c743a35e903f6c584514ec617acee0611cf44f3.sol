pragma solidity ^0.4.19;

contract ERC223ReceivingContract {
  function tokenFallback(address _from, uint256 _value, bytes _data) public;
}

contract ERC223Token {
  using SafeMath for uint256;

  // token constants
  string public name;
  bytes32 public symbol;
  uint8 public decimals;
  uint256 public totalSupply;

  // token balances
  mapping(address => uint256) public balanceOf;
  // token spending allowance, used by transferFrom(), for compliance with ERC20
  mapping (address => mapping(address => uint256)) internal allowances;

  // Function that is called when a user or another contract wants to transfer funds.
  function transfer(address to, uint256 value, bytes data) public returns (bool) {
    require(balanceOf[msg.sender] >= value);
    uint256 codeLength;

    assembly {
      // Retrieve the size of the code on target address, this needs assembly .
      codeLength := extcodesize(to)
    }

    balanceOf[msg.sender] -= value;  // underflow checked by require() above
    balanceOf[to] = balanceOf[to].add(value);
    if (codeLength > 0) {
      ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
      receiver.tokenFallback(msg.sender, value, data);
    }
    ERC223Transfer(msg.sender, to, value, data);
    return true;
  }

  // Standard function transfer similar to ERC20 transfer with no _data.
  // Added due to backwards compatibility reasons.
  function transfer(address to, uint256 value) public returns (bool) {
    require(balanceOf[msg.sender] >= value);
    uint256 codeLength;
    bytes memory empty;

    assembly {
      // Retrieve the size of the code on target address, this needs assembly.
      codeLength := extcodesize(to)
    }

    balanceOf[msg.sender] -= value;  // underflow checked by require() above
    balanceOf[to] = balanceOf[to].add(value);
    if (codeLength > 0) {
      ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
      receiver.tokenFallback(msg.sender, value, empty);
    }
    ERC223Transfer(msg.sender, to, value, empty);
    // ERC20 compatible event:
    Transfer(msg.sender, to, value);
    return true;
  }

  // Send _value tokens to _to from _from on the condition it is approved by _from.
  // Added for full compliance with ERC20
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(_to != address(0));
    require(_value <= balanceOf[_from]);
    require(_value <= allowances[_from][msg.sender]);
    bytes memory empty;

    balanceOf[_from] = balanceOf[_from] -= _value;
    allowances[_from][msg.sender] -= _value;
    balanceOf[_to] = balanceOf[_to].add(_value);

    // No need to call tokenFallback(), cause this is ERC20's solution to the same problem
    // tokenFallback solves in ERC223. Just fire the ERC223 event for logs consistency.
    ERC223Transfer(_from, _to, _value, empty);
    Transfer(_from, _to, _value);
    return true;
  }

  // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
  // If this function is called again it overwrites the current allowance with _value.
  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowances[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  // Returns the amount which _spender is still allowed to withdraw from _owner
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowances[_owner][_spender];
  }

  event ERC223Transfer(address indexed from, address indexed to, uint256 value, bytes indexed data);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed from, address indexed spender, uint256 value);
}

contract ERC223MintableToken is ERC223Token {
  uint256 public circulatingSupply;
  function mint(address to, uint256 value) internal returns (bool) {
    uint256 codeLength;

    assembly {
      // Retrieve the size of the code on target address, this needs assembly .
      codeLength := extcodesize(to)
    }

    circulatingSupply += value;

    balanceOf[to] += value;  // No safe math needed, won't exceed totalSupply.
    if (codeLength > 0) {
      ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
      bytes memory empty;
      receiver.tokenFallback(msg.sender, value, empty);
    }
    Mint(to, value);
    return true;
  }

  event Mint(address indexed to, uint256 value);
}

contract ERC20Token {
  function balanceOf(address owner) public view returns (uint256 balance);
  function transfer(address to, uint256 tokens) public returns (bool success);
}

contract Ownable {
  address public owner;
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

}

contract BountyTokenAllocation is Ownable {

  // This contract describes how the bounty tokens are allocated.
  // After a bounty allocation was proposed by a signatory, another
  // signatory must accept this allocation.

  // Total amount of remaining tokens to be distributed
  uint256 public remainingBountyTokens;

  // Addresses which have a bounty allocation, in order of proposals
  address[] public allocationAddressList;

  // Possible split states: Proposed, Approved, Rejected
  // Proposed is the initial state.
  // Both Approved and Rejected are final states.
  // The only possible transitions are:
  // Proposed => Approved
  // Proposed => Rejected

  // keep map here of bounty proposals
  mapping (address => Types.StructBountyAllocation) public bountyOf;

  /**
   * Bounty token allocation constructor.
   *
   * @param _remainingBountyTokens Total number of bounty tokens that will be
   *                               allocated.
   */
  function BountyTokenAllocation(uint256 _remainingBountyTokens) Ownable() public {
    remainingBountyTokens = _remainingBountyTokens;
  }

  /**
   * Propose a bounty transfer
   *
   * @param _dest Address of bounty reciepent
   * @param _amount Amount of tokens he will receive
   */
  function proposeBountyTransfer(address _dest, uint256 _amount) public onlyOwner {
    require(_amount > 0);
    require(_amount <= remainingBountyTokens);
     // we can't overwrite existing proposal
     // but we can overwrite rejected proposal with new values
    require(bountyOf[_dest].proposalAddress == 0x0 || bountyOf[_dest].bountyState == Types.BountyState.Rejected);

    if (bountyOf[_dest].bountyState != Types.BountyState.Rejected) {
      allocationAddressList.push(_dest);
    }

    remainingBountyTokens = SafeMath.sub(remainingBountyTokens, _amount);
    bountyOf[_dest] = Types.StructBountyAllocation({
      amount: _amount,
      proposalAddress: msg.sender,
      bountyState: Types.BountyState.Proposed
    });
  }

  /**
   * Approves a bounty transfer
   *
   * @param _dest Address of bounty reciepent
   * @return amount of tokens which we approved
   */
  function approveBountyTransfer(address _approverAddress, address _dest) public onlyOwner returns (uint256) {
    require(bountyOf[_dest].bountyState == Types.BountyState.Proposed);
    require(bountyOf[_dest].proposalAddress != _approverAddress);

    bountyOf[_dest].bountyState = Types.BountyState.Approved;
    return bountyOf[_dest].amount;
  }

  /**
   * Rejects a bounty transfer
   *
   * @param _dest Address of bounty reciepent for whom we are rejecting bounty transfer
   */
  function rejectBountyTransfer(address _dest) public onlyOwner {
    var tmp = bountyOf[_dest];
    require(tmp.bountyState == Types.BountyState.Proposed);

    bountyOf[_dest].bountyState = Types.BountyState.Rejected;
    remainingBountyTokens = remainingBountyTokens + bountyOf[_dest].amount;
  }

}

library SafeMath {
  function sub(uint256 a, uint256 b) pure internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) pure internal returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  function min(uint256 a, uint256 b) pure internal returns (uint256) {
    if(a > b)
      return b;
    else
      return a;
  }
}

contract SignatoryOwnable {
  mapping (address => bool) public IS_SIGNATORY;

  function SignatoryOwnable(address signatory0, address signatory1, address signatory2) internal {
    IS_SIGNATORY[signatory0] = true;
    IS_SIGNATORY[signatory1] = true;
    IS_SIGNATORY[signatory2] = true;
  }

  modifier onlySignatory() {
    require(IS_SIGNATORY[msg.sender]);
    _;
  }
}

contract SignatoryPausable is SignatoryOwnable {
  bool public paused;  // == false by default
  address public pauseProposer;  // == 0x0 (no proposal) by default

  function SignatoryPausable(address signatory0, address signatory1, address signatory2)
      SignatoryOwnable(signatory0, signatory1, signatory2)
      internal {}

  modifier whenPaused(bool status) {
    require(paused == status);
    _;
  }

  /**
   * @dev First signatory consent for contract pause state change.
   */
  function proposePauseChange(bool status) onlySignatory whenPaused(!status) public {
    require(pauseProposer == 0x0);  // require there's no pending proposal already
    pauseProposer = msg.sender;
  }

  /**
   * @dev Second signatory consent for contract pause state change, triggers the change.
   */
  function approvePauseChange(bool status) onlySignatory whenPaused(!status) public {
    require(pauseProposer != 0x0);  // require that a change was already proposed
    require(pauseProposer != msg.sender);  // approver must be different than proposer
    pauseProposer = 0x0;
    paused = status;
    LogPause(paused);
  }

  /**
   * @dev Reject pause status change proposal.
   * Can also be called by the proposer, to cancel his proposal.
   */
  function rejectPauseChange(bool status) onlySignatory whenPaused(!status) public {
    pauseProposer = 0x0;
  }

  event LogPause(bool status);
}

contract ExyToken is ERC223MintableToken, SignatoryPausable {
  using SafeMath for uint256;

  VestingAllocation private partnerTokensAllocation;
  VestingAllocation private companyTokensAllocation;
  BountyTokenAllocation private bountyTokensAllocation;

  /*
   * ICO TOKENS
   * 33% (including SEED TOKENS)
   *
   * Ico tokens are sent to the ICO_TOKEN_ADDRESS immediately
   * after ExyToken initialization
   */
  uint256 private constant ICO_TOKENS = 14503506112248500000000000;
  address private constant ICO_TOKENS_ADDRESS = 0x97c967524d1eacAEb375d4269bE4171581a289C7;
  /*
   * SEED TOKENS
   * 33% (including ICO TOKENS)
   *
   * Seed tokens are sent to the SEED_TOKENS_ADDRESS immediately
   * after ExyToken initialization
   */
  uint256 private constant SEED_TOKENS = 11700000000000000000000000;
  address private constant SEED_TOKENS_ADDRESS = 0x7C32c7649aA1335271aF00cd4280f87166474778;

  /*
   * COMPANY TOKENS
   * 33%
   *
   * Company tokens are being distrubited in 36 months
   * Total tokens = COMPANY_TOKENS_PER_PERIOD * COMPANY_PERIODS
   */
  uint256 private constant COMPANY_TOKENS_PER_PERIOD = 727875169784680000000000;
  uint256 private constant COMPANY_PERIODS = 36;
  uint256 private constant MINUTES_IN_COMPANY_PERIOD = 60 * 24 * 365 / 12;

  /*
   * PARTNER TOKENS
   * 30%
   *
   * Partner tokens are available after 18 months
   * Total tokens = PARTNER_TOKENS_PER_PERIOD * PARTNER_PERIODS
   */
  uint256 private constant PARTNER_TOKENS_PER_PERIOD = 23821369192953200000000000;
  uint256 private constant PARTNER_PERIODS = 1;
  uint256 private constant MINUTES_IN_PARTNER_PERIOD = MINUTES_IN_COMPANY_PERIOD * 18; // MINUTES_IN_COMPANY_PERIOD equals one month (see declaration of MINUTES_IN_COMPANY_PERIOD constant)

  /*
   * BOUNTY TOKENS
   * 3%
   *
   * Bounty tokens can be sent immediately after initialization
   */
  uint256 private constant BOUNTY_TOKENS = 2382136919295320000000000;

  /*
   * MARKETING COST TOKENS
   * 1%
   *
   * Tokens are sent to the MARKETING_COST_ADDRESS immediately
   * after ExyToken initialization
   */
  uint256 private constant MARKETING_COST_TOKENS = 794045639765106000000000;
  address private constant MARKETING_COST_ADDRESS = 0xF133ef3BE68128c9Af16F5aF8F8707f7A7A51452;

  uint256 public INIT_DATE;

  string public constant name = "Experty Token";
  bytes32 public constant symbol = "EXY";
  uint8 public constant decimals = 18;
  uint256 public constant totalSupply = (
    COMPANY_TOKENS_PER_PERIOD * COMPANY_PERIODS +
    PARTNER_TOKENS_PER_PERIOD * PARTNER_PERIODS +
    BOUNTY_TOKENS + MARKETING_COST_TOKENS +
    ICO_TOKENS + SEED_TOKENS);

  /**
   * ExyToken contructor.
   *
   * Exy token contains allocations of:
   * - partnerTokensAllocation
   * - companyTokensAllocation
   * - bountyTokensAllocation
   *
   * param signatory0 Address of first signatory.
   * param signatory1 Address of second signatory.
   * param signatory2 Address of third signatory.
   *
   */
  function ExyToken(address signatory0, address signatory1, address signatory2)
      SignatoryPausable(signatory0, signatory1, signatory2)
      public {

    // NOTE: the contract is safe as long as this assignment is not changed nor updated.
    // If, in the future, INIT_DATE could have a different value, calculations using its value
    // should most likely use SafeMath.
    INIT_DATE = block.timestamp;

    companyTokensAllocation = new VestingAllocation(
      COMPANY_TOKENS_PER_PERIOD,
      COMPANY_PERIODS,
      MINUTES_IN_COMPANY_PERIOD,
      INIT_DATE);

    partnerTokensAllocation = new VestingAllocation(
      PARTNER_TOKENS_PER_PERIOD,
      PARTNER_PERIODS,
      MINUTES_IN_PARTNER_PERIOD,
      INIT_DATE);

    bountyTokensAllocation = new BountyTokenAllocation(
      BOUNTY_TOKENS
    );

    // minting marketing cost tokens
    mint(MARKETING_COST_ADDRESS, MARKETING_COST_TOKENS);

    // minting ICO tokens
    mint(ICO_TOKENS_ADDRESS, ICO_TOKENS);
    // minting SEED tokens
    mint(SEED_TOKENS_ADDRESS, SEED_TOKENS);
  }

  /**
   * Transfer ERC20 tokens out of this contract, to avoid them being stuck here forever.
   * Only one signatory decision needed, to minimize contract size since this is a rare case.
   */
  function erc20TokenTransfer(address _tokenAddr, address _dest) public onlySignatory {
    ERC20Token token = ERC20Token(_tokenAddr);
    token.transfer(_dest, token.balanceOf(address(this)));
  }

  /**
   * Adds a proposition of a company token split to companyTokensAllocation
   */
  function proposeCompanyAllocation(address _dest, uint256 _tokensPerPeriod) public onlySignatory onlyPayloadSize(2 * 32) {
    companyTokensAllocation.proposeAllocation(msg.sender, _dest, _tokensPerPeriod);
  }

  /**
   * Approves a proposition of a company token split
   */
  function approveCompanyAllocation(address _dest) public onlySignatory {
    companyTokensAllocation.approveAllocation(msg.sender, _dest);
  }

  /**
   * Rejects a proposition of a company token split.
   * it can reject only not approved method
   */
  function rejectCompanyAllocation(address _dest) public onlySignatory {
    companyTokensAllocation.rejectAllocation(_dest);
  }

  /**
   * Return number of remaining company tokens allocations
   * @return Length of company allocations per period
   */
  function getRemainingCompanyTokensAllocation() public view returns (uint256) {
    return companyTokensAllocation.remainingTokensPerPeriod();
  }

  /**
   * Given the index of the company allocation in allocationAddressList
   * we find its reciepent address and return struct with informations
   * about this allocation
   *
   * @param nr Index of allocation in allocationAddressList
   * @return Information about company alloction
   */
  function getCompanyAllocation(uint256 nr) public view returns (uint256, address, uint256, Types.AllocationState, address) {
    address recipientAddress = companyTokensAllocation.allocationAddressList(nr);
    var (tokensPerPeriod, proposalAddress, claimedPeriods, allocationState) = companyTokensAllocation.allocationOf(recipientAddress);
    return (tokensPerPeriod, proposalAddress, claimedPeriods, allocationState, recipientAddress);
  }

  /**
   * Adds a proposition of a partner token split to companyTokensAllocation
   */
  function proposePartnerAllocation(address _dest, uint256 _tokensPerPeriod) public onlySignatory onlyPayloadSize(2 * 32) {
    partnerTokensAllocation.proposeAllocation(msg.sender, _dest, _tokensPerPeriod);
  }

  /**
   * Approves a proposition of a partner token split
   */
  function approvePartnerAllocation(address _dest) public onlySignatory {
    partnerTokensAllocation.approveAllocation(msg.sender, _dest);
  }

  /**
   * Rejects a proposition of a partner token split.
   * it can reject only not approved method
   */
  function rejectPartnerAllocation(address _dest) public onlySignatory {
    partnerTokensAllocation.rejectAllocation(_dest);
  }

  /**
   * Return number of remaining partner tokens allocations
   * @return Length of partner allocations per period
   */
  function getRemainingPartnerTokensAllocation() public view returns (uint256) {
    return partnerTokensAllocation.remainingTokensPerPeriod();
  }

  /**
   * Given the index of the partner allocation in allocationAddressList
   * we find its reciepent address and return struct with informations
   * about this allocation
   *
   * @param nr Index of allocation in allocationAddressList
   * @return Information about partner alloction
   */
  function getPartnerAllocation(uint256 nr) public view returns (uint256, address, uint256, Types.AllocationState, address) {
    address recipientAddress = partnerTokensAllocation.allocationAddressList(nr);
    var (tokensPerPeriod, proposalAddress, claimedPeriods, allocationState) = partnerTokensAllocation.allocationOf(recipientAddress);
    return (tokensPerPeriod, proposalAddress, claimedPeriods, allocationState, recipientAddress);
  }

  function proposeBountyTransfer(address _dest, uint256 _amount) public onlySignatory onlyPayloadSize(2 * 32) {
    bountyTokensAllocation.proposeBountyTransfer(_dest, _amount);
  }

  /**
   * Approves a bounty transfer and mint tokens
   *
   * @param _dest Address of the bounty reciepent to whom we should mint token
   */
  function approveBountyTransfer(address _dest) public onlySignatory {
    uint256 tokensToMint = bountyTokensAllocation.approveBountyTransfer(msg.sender, _dest);
    mint(_dest, tokensToMint);
  }

  /**
   * Rejects a proposition of a bounty token.
   * it can reject only not approved method
   */
  function rejectBountyTransfer(address _dest) public onlySignatory {
    bountyTokensAllocation.rejectBountyTransfer(_dest);
  }

  function getBountyTransfers(uint256 nr) public view returns (uint256, address, Types.BountyState, address) {
    address recipientAddress = bountyTokensAllocation.allocationAddressList(nr);
    var (amount, proposalAddress, bountyState) = bountyTokensAllocation.bountyOf(recipientAddress);
    return (amount, proposalAddress, bountyState, recipientAddress);
  }

  /**
   * Return number of remaining bounty tokens allocations
   * @return Length of company allocations
   */
  function getRemainingBountyTokens() public view returns (uint256) {
    return bountyTokensAllocation.remainingBountyTokens();
  }

  function claimTokens() public {
    mint(
      msg.sender,
      partnerTokensAllocation.claimTokens(msg.sender) +
      companyTokensAllocation.claimTokens(msg.sender)
    );
  }

  /**
   * Override the transfer and mint functions to respect pause state.
   */
  function transfer(address to, uint256 value, bytes data) public whenPaused(false) returns (bool) {
    return super.transfer(to, value, data);
  }

  function transfer(address to, uint256 value) public whenPaused(false) returns (bool) {
    return super.transfer(to, value);
  }

  function mint(address to, uint256 value) internal whenPaused(false) returns (bool) {
    if (circulatingSupply.add(value) > totalSupply) {
      paused = true;  // emergency pause, this should never happen!
      return false;
    }
    return super.mint(to, value);
  }

  modifier onlyPayloadSize(uint size) {
    assert(msg.data.length == size + 4);
    _;
  }

}

contract Types {

  // Possible split states: Proposed, Approved, Rejected
  // Proposed is the initial state.
  // Both Approved and Rejected are final states.
  // The only possible transitions are:
  // Proposed => Approved
  // Proposed => Rejected
  enum AllocationState {
    Proposed,
    Approved,
    Rejected
  }

  // Structure used for storing company and partner allocations
  struct StructVestingAllocation {
    // How many tokens per period we want to pass
    uint256 tokensPerPeriod;
    // By whom was this split proposed. Another signatory must approve too
    address proposerAddress;
    // How many times did we release tokens
    uint256 claimedPeriods;
    // State of actual split.
    AllocationState allocationState;
  }

  enum BountyState {
    Proposed, // 0
    Approved, // 1
    Rejected  // 2
  }

  struct StructBountyAllocation {
    // How many tokens send him or her
    uint256 amount;
    // By whom was this allocation proposed
    address proposalAddress;
    // State of actual split.
    BountyState bountyState;
  }
}

contract VestingAllocation is Ownable {

  // This contract describes how the tokens are being released in time

  // Addresses which have a vesting allocation, in order of proposals
  address[] public allocationAddressList;

  // How many distributions periods there are
  uint256 public periods;
  // How long is one interval
  uint256 public minutesInPeriod;
  // Total amount of remaining tokens to be distributed
  uint256 public remainingTokensPerPeriod;
  // Total amount of all tokens
  uint256 public totalSupply;
  // Inital timestamp
  uint256 public initTimestamp;

  // For each address we can add exactly one possible split.
  // If we try to add another proposal on existing address it will be rejected
  mapping (address => Types.StructVestingAllocation) public allocationOf;

  /**
   * VestingAllocation contructor.
   * RemainingTokensPerPeriod variable which represents
   * the remaining amount of tokens to be distributed
   *
   */
  function VestingAllocation(uint256 _tokensPerPeriod, uint256 _periods, uint256 _minutesInPeriod, uint256 _initalTimestamp) Ownable() public {
    totalSupply = _tokensPerPeriod * _periods;
    periods = _periods;
    minutesInPeriod = _minutesInPeriod;
    remainingTokensPerPeriod = _tokensPerPeriod;
    initTimestamp = _initalTimestamp;
  }

  /**
   * Propose split method adds proposal to the splits Array.
   *
   * @param _dest              - address of the new receiver
   * @param _tokensPerPeriod   - how many tokens we are giving to dest
   */
  function proposeAllocation(address _proposerAddress, address _dest, uint256 _tokensPerPeriod) public onlyOwner {
    require(_tokensPerPeriod > 0);
    require(_tokensPerPeriod <= remainingTokensPerPeriod);
    // In solidity there is no "exist" method on a map key.
    // We can't overwrite existing proposal, so we are checking if it is the default value (0x0)
    // Add `allocationOf[_dest].allocationState == Types.AllocationState.Rejected` for possibility to overwrite rejected allocation
    require(allocationOf[_dest].proposerAddress == 0x0 || allocationOf[_dest].allocationState == Types.AllocationState.Rejected);

    if (allocationOf[_dest].allocationState != Types.AllocationState.Rejected) {
      allocationAddressList.push(_dest);
    }

    remainingTokensPerPeriod = remainingTokensPerPeriod - _tokensPerPeriod;
    allocationOf[_dest] = Types.StructVestingAllocation({
      tokensPerPeriod: _tokensPerPeriod,
      allocationState: Types.AllocationState.Proposed,
      proposerAddress: _proposerAddress,
      claimedPeriods: 0
    });
  }

  /**
   * Approves the split allocation, so it can be claimed after periods
   *
   * @param _address - address for the split
   */
  function approveAllocation(address _approverAddress, address _address) public onlyOwner {
    require(allocationOf[_address].allocationState == Types.AllocationState.Proposed);
    require(allocationOf[_address].proposerAddress != _approverAddress);
    allocationOf[_address].allocationState = Types.AllocationState.Approved;
  }

 /**
   * Rejects the split allocation
   *
   * @param _address - address for the split to be rejected
   */
  function rejectAllocation(address _address) public onlyOwner {
    var tmp = allocationOf[_address];
    require(tmp.allocationState == Types.AllocationState.Proposed);
    allocationOf[_address].allocationState = Types.AllocationState.Rejected;
    remainingTokensPerPeriod = remainingTokensPerPeriod + tmp.tokensPerPeriod;
  }

  function claimTokens(address _address) public returns (uint256) {
    Types.StructVestingAllocation storage alloc = allocationOf[_address];
    if (alloc.allocationState == Types.AllocationState.Approved) {
      uint256 periodsElapsed = SafeMath.min((block.timestamp - initTimestamp) / (minutesInPeriod * 1 minutes), periods);
      uint256 tokens = (periodsElapsed - alloc.claimedPeriods) * alloc.tokensPerPeriod;
      alloc.claimedPeriods = periodsElapsed;
      return tokens;
    }
    return 0;
  }

}