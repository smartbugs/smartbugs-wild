pragma solidity ^0.4.13;

contract AllocationAddressList {

  address[] public allocationAddressList;
}

contract ERC223ReceivingContract {
  // AUDIT[CHF-08] The name of the token transfer "fallback" function.
  //
  // There were suggestions to change the "stanard" fallback function name
  // to "onTokenReceived", see
  // https://github.com/ethereum/EIPs/issues/223#issuecomment-327709226
  // See also https://github.com/ethereum/EIPs/issues/777.
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

  // Function that is called when a user or another contract wants to transfer funds .
  function transfer(address to, uint256 value, bytes data) public returns (bool) {
    // Standard function transfer similar to ERC20 transfer with no _data .
    // Added due to backwards compatibility reasons .
    uint256 codeLength;

    assembly {
      // Retrieve the size of the code on target address, this needs assembly .
      codeLength := extcodesize(to)
    }

    balanceOf[msg.sender] = balanceOf[msg.sender].sub(value);
    balanceOf[to] = balanceOf[to].add(value);
    if (codeLength > 0) {
      ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
      receiver.tokenFallback(msg.sender, value, data);
    }
    Transfer(msg.sender, to, value, data);
    return true;
  }

  // Standard function transfer similar to ERC20 transfer with no _data .
  // Added due to backwards compatibility reasons .
  function transfer(address to, uint256 value) public returns (bool) {
    uint256 codeLength;
    bytes memory empty;

    assembly {
      // Retrieve the size of the code on target address, this needs assembly .
      codeLength := extcodesize(to)
    }

    balanceOf[msg.sender] = balanceOf[msg.sender].sub(value);
    balanceOf[to] = balanceOf[to].add(value);
    if (codeLength > 0) {
      ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
      receiver.tokenFallback(msg.sender, value, empty);
    }
    Transfer(msg.sender, to, value, empty);
    // ERC20 compatible event:
    Transfer(msg.sender, to, value);
    return true;
  }

  event Transfer(address indexed from, address indexed to, uint256 value, bytes indexed data);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC223MintableToken is ERC223Token {
  using SafeMath for uint256;
  uint256 public circulatingSupply;
  function mint(address to, uint256 value) internal returns (bool) {
    uint256 codeLength;

    assembly {
      // Retrieve the size of the code on target address, this needs assembly .
      codeLength := extcodesize(to)
    }

    circulatingSupply += value;

    balanceOf[to] = balanceOf[to].add(value);
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

contract TestToken is ERC223MintableToken {
  mapping (address => bool) public IS_SIGNATURER;

  VestingAllocation private partnerTokensAllocation;
  VestingAllocation private companyTokensAllocation;
  BountyTokenAllocation private bountyTokensAllocation;

  /*
   * ICO TOKENS
   * 33%
   *
   * Ico tokens are sent to the ICO_TOKEN_ADDRESS immediately
   * after TestToken initialization
   */ 
  uint256 constant ICO_TOKENS = 25346500000000000000000000;
  address constant ICO_TOKENS_ADDRESS = 0xCE1182147FD13A59E4Ca114CAa1cD58719e09F67;
  // AUDIT[CHF-02] Document "seed" tokens.
  uint256 constant SEED_TOKENS = 25346500000000000000000000;
  address constant SEED_TOKENS_ADDRESS = 0x8746177Ff2575E826f6f73A1f90351e0FD0A6649;

  /*
   * COMPANY TOKENS
   * 33%
   *
   * Company tokens are being distrubited in 36 months
   * Total tokens = COMPANY_TOKENS_PER_PERIOD * COMPANY_PERIODS
   */
  uint256 constant COMPANY_TOKENS_PER_PERIOD = 704069444444444000000000;
  uint256 constant COMPANY_PERIODS = 36;
  uint256 constant MINUTES_IN_COMPANY_PERIOD = 10; //1 years / 12 / 1 minutes;

  /*
   * PARTNER TOKENS
   * 30%
   *
   * Company tokens are avaialable after 18 months
   * Total tokens = PARTNER_TOKENS_PER_PERIOD * PARTNER_PERIODS
   */
  uint256 constant PARTNER_TOKENS_PER_PERIOD = 23042272727272700000000000;
  uint256 constant PARTNER_PERIODS = 1;
  uint256 constant MINUTES_IN_PARTNER_PERIOD = 60 * 2; //MINUTES_IN_COMPANY_PERIOD * 18;

  /*
   * BOUNTY TOKENS
   * 30%
   *
   * Bounty tokens can be sent immediately after initialization
   */
  uint256 constant BOUNTY_TOKENS = 2304227272727270000000000;

  /*
   * MARKETING COST TOKENS
   * 1%
   *
   * Tokens are sent to the MARKETING_COST_ADDRESS immediately
   * after TestToken initialization
   */
  uint256 constant MARKETING_COST_TOKENS = 768075757575758000000000;
  address constant MARKETING_COST_ADDRESS = 0x54a0AB12710fad2a24CB391406c234855C835340;

  uint256 public INIT_DATE;

  string public constant name = "Test Token";
  bytes32 public constant symbol = "TST";
  uint8 public constant decimals = 18;
  uint256 public constant totalSupply = (
    COMPANY_TOKENS_PER_PERIOD * COMPANY_PERIODS +
    PARTNER_TOKENS_PER_PERIOD * PARTNER_PERIODS +
    BOUNTY_TOKENS + MARKETING_COST_TOKENS +
    ICO_TOKENS + SEED_TOKENS);

  /**
   * TestToken contructor.
   *
   * Exy token contains allocations of:
   * - partnerTokensAllocation
   * - companyTokensAllocation
   * - bountyTokensAllocation
   *
   * param signaturer0 Address of first signaturer.
   * param signaturer1 Address of second signaturer.
   * param signaturer2 Address of third signaturer.
   *
   * Arguments in constructor are only for testing. When deploying
   * on main net, please hardcode them inside:
   * address signaturer0 = 0x0;
   * address signaturer1 = 0x1;
   * address signaturer2 = 0x2;
   */
  function TestToken() public {
    address signaturer0 = 0xe029b7b51b8c5B71E6C6f3DC66a11DF3CaB6E3B5;
    address signaturer1 = 0xBEE9b5e75383f56eb103DdC1a4343dcA6124Dfa3;
    address signaturer2 = 0xcdD1Db16E83AA757a5B3E6d03482bBC9A27e8D49;
    IS_SIGNATURER[signaturer0] = true;
    IS_SIGNATURER[signaturer1] = true;
    IS_SIGNATURER[signaturer2] = true;
    INIT_DATE = block.timestamp;

    // AUDIT[CHF-06] Inherit instead of compose.
    //
    // I don't see a point of creating "Signatures" as a separate contract.
    // Just embed it here.
    // Also, move "onlySignaturer" to Signatures contract
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
   * Adds a proposition of a company token split to companyTokensAllocation
   */
  function proposeCompanyAllocation(address _dest, uint256 _tokensPerPeriod) public onlySignaturer {
    companyTokensAllocation.proposeAllocation(msg.sender, _dest, _tokensPerPeriod);
  }

  /**
   * Approves a proposition of a company token split
   */
  function approveCompanyAllocation(address _dest) public onlySignaturer {
    companyTokensAllocation.approveAllocation(msg.sender, _dest);
  }

  /**
   * Rejects a proposition of a company token split.
   * it can reject only not approved method
   */
  function rejectCompanyAllocation(address _dest) public onlySignaturer {
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
  function proposePartnerAllocation(address _dest, uint256 _tokensPerPeriod) public onlySignaturer {
    partnerTokensAllocation.proposeAllocation(msg.sender, _dest, _tokensPerPeriod);
  }

  /**
   * Approves a proposition of a partner token split
   */
  function approvePartnerAllocation(address _dest) public onlySignaturer {
    partnerTokensAllocation.approveAllocation(msg.sender, _dest);
  }

  /**
   * Rejects a proposition of a partner token split.
   * it can reject only not approved method
   */
  function rejectPartnerAllocation(address _dest) public onlySignaturer {
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

  function proposeBountyTransfer(address _dest, uint256 _amount) public onlySignaturer {
    bountyTokensAllocation.proposeBountyTransfer(_dest, _amount);
  }

  /**
   * Approves a bounty transfer and mint tokens
   *
   * @param _dest Address of the bounty reciepent to whom we should mint token
   */
  function approveBountyTransfer(address _dest) public onlySignaturer {
    uint256 tokensToMint = bountyTokensAllocation.approveBountyTransfer(msg.sender, _dest);
    mint(_dest, tokensToMint);
  }

  /**
   * Rejects a proposition of a bounty token.
   * it can reject only not approved method
   */
  function rejectBountyTransfer(address _dest) public onlySignaturer {
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

  function claimTokens() public returns (uint256) {
    mint(msg.sender,
      partnerTokensAllocation.claimTokens(msg.sender) +
      companyTokensAllocation.claimTokens(msg.sender));
  }
  modifier onlySignaturer() {
    require(IS_SIGNATURER[msg.sender]);
    _;
  }

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

contract BountyTokenAllocation is Ownable, AllocationAddressList {

  // This contract describes how the bounty tokens are allocated.
  // After a bounty allocation was proposed by a signaturer, another
  // signaturer must accept this allocation.

  // Total amount of remaining tokens to be distributed
  uint256 public remainingBountyTokens;

  // Possible split states: Proposed, Approved, Rejected
  // Proposed is the initial state.
  // Both Approved and Rejected are final states.
  // The only possible transitions are:
  // Proposed => Approved
  // Proposed => Rejected

  // keep map here of bounty proposals
  mapping (address => Types.StructBountyAllocation) public bountyOf;

  address public owner = msg.sender;

  /**
   * Bounty token allocation constructor.
   *
   * @param _remainingBountyTokens Total number of bounty tokens that will be
   *                               allocated.
   */
  function BountyTokenAllocation(uint256 _remainingBountyTokens) onlyOwner public {
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

    bountyOf[_dest] = Types.StructBountyAllocation({
      amount: _amount,
      proposalAddress: msg.sender,
      bountyState: Types.BountyState.Proposed
    });

    remainingBountyTokens = remainingBountyTokens - _amount;
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
    // By whom was this split proposed. Another signaturer must approve too
    address proposerAddress;
    // How many times did we released tokens
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

contract VestingAllocation is Ownable, AllocationAddressList {

  // This contract describes how the tokens are being released in time

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
   */
  // Invoking parent constructor (OwnedBySignaturers) with signatures addresses
  function VestingAllocation(uint256 _tokensPerPeriod, uint256 _periods, uint256 _minutesInPeriod, uint256 _initalTimestamp)  Ownable() public {
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

    allocationOf[_dest] = Types.StructVestingAllocation({
      tokensPerPeriod: _tokensPerPeriod,
      allocationState: Types.AllocationState.Proposed,
      proposerAddress: _proposerAddress,
      claimedPeriods: 0
    });

    remainingTokensPerPeriod = remainingTokensPerPeriod - _tokensPerPeriod; // TODO safe-math
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