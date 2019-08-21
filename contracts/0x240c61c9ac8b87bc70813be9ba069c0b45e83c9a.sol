pragma solidity 0.4.24;

// File: contracts/IAccounting.sol

interface IAccounting {
  function contribute(
    address contributor,
    uint128 amount,
    uint128 feeNumerator
  ) external returns(uint128 deposited, uint128 depositedFees);

  function withdrawContribution(address contributor) external returns(
    uint128 withdrawn,
    uint128 withdrawnFees
  );

  function finalize(uint128 amountDisputed) external;

  function getTotalContribution() external view returns(uint256);

  function getTotalFeesOffered() external view returns(uint256);

  function getProjectedFee(uint128 amountDisputed) external view returns(
    uint128 feeNumerator,
    uint128 fundsUsedFromBoundaryBucket
  );

  function getOwner() external view returns(address);

  function isFinalized() external view returns(bool);

  /**
   * Return value is how much REP and dispute tokens the contributor is entitled to.
   *
   * Does not change the state, as accounting is finalized at that moment.
   *
   * In case of partial fill, we round down, leaving some dust in the contract.
   */
  function calculateProceeds(address contributor) external view returns(
    uint128 rep,
    uint128 disputeTokens
  );

  /**
   * Calculate fee that will be split between contract admin and
   * account that triggered dispute transaction.
   *
   * In case of partial fill, we round down, leaving some dust in the contract.
   */
  function calculateFees() external view returns(uint128);

  function addFeesOnTop(
    uint128 amount,
    uint128 feeNumerator
  ) external pure returns(uint128);
}

// File: contracts/IAccountingFactory.sol

interface IAccountingFactory {
  function create(address owner) external returns(IAccounting);
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

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

// File: contracts/IDisputer.sol

/**
 * Interface of what the disputer contract should do.
 *
 * Its main responsibility to interact with Augur. Only minimal glue methods
 * are added apart from that in order for crowdsourcer to be able to interact
 * with it.
 *
 * This contract holds the actual crowdsourced REP for dispute, so it doesn't
 * need to transfer it from elsewhere at the moment of dispute. It doesn't care
 * at all who this REP belongs to, it just spends it for dispute. Accounting
 * is done in other contracts.
 */
interface IDisputer {
  /**
   * This function should use as little gas as possible, as it will be called
   * during rush time. Unnecessary operations are postponed for later.
   *
   * Can by called by anyone, but only once.
   */
  function dispute(address feeReceiver) external;

  // intentionally can be called by anyone, as no user input is used
  function approveManagerToSpendDisputeTokens() external;

  function getOwner() external view returns(address);

  function hasDisputed() external view returns(bool);

  function feeReceiver() external view returns(address);

  function getREP() external view returns(IERC20);

  function getDisputeTokenAddress() external view returns(IERC20);
}

// File: contracts/augur/feeWindow.sol

interface FeeWindow {
  function getStartTime() external view returns(uint256);
  function isOver() external view returns(bool);
}

// File: contracts/augur/universe.sol

interface Universe {
  function getDisputeRoundDurationInSeconds() external view returns(uint256);

  function isForking() external view returns(bool);

  function isContainerForMarket(address _shadyMarket) external view returns(
    bool
  );
}

// File: contracts/augur/reportingParticipant.sol

/**
 * This should've been an interface, but interfaces cannot inherit interfaces
 */
contract ReportingParticipant is IERC20 {
  function redeem(address _redeemer) external returns(bool);
  function getStake() external view returns(uint256);
  function getPayoutDistributionHash() external view returns(bytes32);
  function getFeeWindow() external view returns(FeeWindow);
}

// File: contracts/augur/market.sol

interface Market {
  function contribute(
    uint256[] _payoutNumerators,
    bool _invalid,
    uint256 _amount
  ) external returns(bool);

  function getReputationToken() external view returns(IERC20);

  function getUniverse() external view returns(Universe);

  function derivePayoutDistributionHash(
    uint256[] _payoutNumerators,
    bool _invalid
  ) external view returns(bytes32);

  function getCrowdsourcer(
    bytes32 _payoutDistributionHash
  ) external view returns(ReportingParticipant);

  function getNumParticipants() external view returns(uint256);

  function getReportingParticipant(uint256 _index) external view returns(
    ReportingParticipant
  );

  function isFinalized() external view returns(bool);

  function getFeeWindow() external view returns(FeeWindow);

  function getWinningReportingParticipant() external view returns(
    ReportingParticipant
  );

  function isContainerForReportingParticipant(
    ReportingParticipant _shadyReportingParticipant
  ) external view returns(bool);
}

// File: contracts/IDisputerFactory.sol

interface IDisputerFactory {
  event DisputerCreated(
    address _owner,
    IDisputer _address,
    Market market,
    uint256 feeWindowId,
    uint256[] payoutNumerators,
    bool invalid
  );

  function create(
    address owner,
    Market market,
    uint256 feeWindowId,
    uint256[] payoutNumerators,
    bool invalid
  ) external returns(IDisputer);
}

// File: contracts/ICrowdsourcerParent.sol

/**
 * Parent of a crowdsourcer that is passed into it on construction. Used
 * to determine destination for fees.
 */
interface ICrowdsourcerParent {
  function getContractFeeReceiver() external view returns(address);
}

// File: contracts/ICrowdsourcer.sol

/**
 * Crowdsourcer for specific market/outcome/round.
 */
interface ICrowdsourcer {
  event ContributionAccepted(
    address contributor,
    uint128 amount,
    uint128 feeNumerator
  );

  event ContributionWithdrawn(address contributor, uint128 amount);

  event CrowdsourcerFinalized(uint128 amountDisputeTokensAcquired);

  event ProceedsWithdrawn(
    address contributor,
    uint128 disputeTokensAmount,
    uint128 repAmount
  );

  event FeesWithdrawn(
    address contractAuthor,
    address executor,
    uint128 contractAuthorAmount,
    uint128 executorAmount
  );

  event Initialized();

  // initialization stage
  function initialize() external;

  // pre-dispute stage
  function contribute(uint128 amount, uint128 feeNumerator) external;

  function withdrawContribution() external;

  // finalization (after dispute happened)
  function finalize() external;

  // after finalization

  // intentionally anyone can call it, since they won't harm contributor
  // by helping them withdraw their proceeds
  function withdrawProceeds(address contributor) external;

  function withdrawFees() external;

  function hasDisputed() external view returns(bool);

  function isInitialized() external view returns(bool);

  function getParent() external view returns(ICrowdsourcerParent);

  function getDisputerParams() external view returns(
    Market market,
    uint256 feeWindowId,
    uint256[] payoutNumerators,
    bool invalid
  );

  function getDisputer() external view returns(IDisputer);

  function getAccounting() external view returns(IAccounting);

  function getREP() external view returns(IERC20);

  function getDisputeToken() external view returns(IERC20);

  function isFinalized() external view returns(bool);
}

// File: contracts/DisputerParams.sol

library DisputerParams {
  struct Params {
    Market market;
    uint256 feeWindowId;
    uint256[] payoutNumerators;
    bool invalid;
  }
}

// File: contracts/Crowdsourcer.sol

contract Crowdsourcer is ICrowdsourcer {
  bool public m_isInitialized = false;
  DisputerParams.Params public m_disputerParams;
  IAccountingFactory public m_accountingFactory;
  IDisputerFactory public m_disputerFactory;

  IAccounting public m_accounting;
  ICrowdsourcerParent public m_parent;
  IDisputer public m_disputer;

  mapping(address => bool) public m_proceedsCollected;
  bool public m_feesCollected = false;

  constructor(
    ICrowdsourcerParent parent,
    IAccountingFactory accountingFactory,
    IDisputerFactory disputerFactory,
    Market market,
    uint256 feeWindowId,
    uint256[] payoutNumerators,
    bool invalid
  ) public {
    m_parent = parent;
    m_accountingFactory = accountingFactory;
    m_disputerFactory = disputerFactory;
    m_disputerParams = DisputerParams.Params(
      market,
      feeWindowId,
      payoutNumerators,
      invalid
    );
  }

  modifier beforeDisputeOnly() {
    require(!hasDisputed(), "Method only allowed before dispute");
    _;
  }

  modifier requiresInitialization() {
    require(isInitialized(), "Must call initialize() first");
    _;
  }

  modifier requiresFinalization() {
    if (!isFinalized()) {
      finalize();
      assert(isFinalized());
    }
    _;
  }

  function initialize() external {
    require(!m_isInitialized, "Already initialized");
    m_isInitialized = true;
    m_accounting = m_accountingFactory.create(this);
    m_disputer = m_disputerFactory.create(
      this,
      m_disputerParams.market,
      m_disputerParams.feeWindowId,
      m_disputerParams.payoutNumerators,
      m_disputerParams.invalid
    );
    emit Initialized();
  }

  function contribute(
    uint128 amount,
    uint128 feeNumerator
  ) external requiresInitialization beforeDisputeOnly {
    uint128 amountWithFees = m_accounting.addFeesOnTop(amount, feeNumerator);

    IERC20 rep = getREP();
    require(rep.balanceOf(msg.sender) >= amountWithFees, "Not enough funds");
    require(
      rep.allowance(msg.sender, this) >= amountWithFees,
      "Now enough allowance"
    );

    // record contribution in accounting (will perform validations)
    uint128 deposited;
    uint128 depositedFees;
    (deposited, depositedFees) = m_accounting.contribute(
      msg.sender,
      amount,
      feeNumerator
    );

    assert(deposited == amount);
    assert(deposited + depositedFees == amountWithFees);

    // actually transfer tokens and revert tx if any problem
    assert(rep.transferFrom(msg.sender, m_disputer, deposited));
    assert(rep.transferFrom(msg.sender, this, depositedFees));

    assertBalancesBeforeDispute();

    emit ContributionAccepted(msg.sender, amount, feeNumerator);
  }

  function withdrawContribution(

  ) external requiresInitialization beforeDisputeOnly {
    IERC20 rep = getREP();

    // record withdrawal in accounting (will perform validations)
    uint128 withdrawn;
    uint128 withdrawnFees;
    (withdrawn, withdrawnFees) = m_accounting.withdrawContribution(msg.sender);

    // actually transfer tokens and revert tx if any problem
    assert(rep.transferFrom(m_disputer, msg.sender, withdrawn));
    assert(rep.transfer(msg.sender, withdrawnFees));

    assertBalancesBeforeDispute();

    emit ContributionWithdrawn(msg.sender, withdrawn);
  }

  function withdrawProceeds(address contributor) external requiresFinalization {
    require(
      !m_proceedsCollected[contributor],
      "Can only collect proceeds once"
    );

    // record proceeds have been collected
    m_proceedsCollected[contributor] = true;

    uint128 refund;
    uint128 proceeds;

    // calculate how much this contributor is entitled to
    (refund, proceeds) = m_accounting.calculateProceeds(contributor);

    IERC20 rep = getREP();
    IERC20 disputeTokenAddress = getDisputeToken();

    // actually deliver the proceeds/refund
    assert(rep.transfer(contributor, refund));
    assert(disputeTokenAddress.transfer(contributor, proceeds));

    emit ProceedsWithdrawn(contributor, proceeds, refund);
  }

  function withdrawFees() external requiresFinalization {
    require(!m_feesCollected, "Can only collect fees once");

    m_feesCollected = true;

    uint128 feesTotal = m_accounting.calculateFees();
    // 10% of fees go to contract author
    uint128 feesForContractAuthor = feesTotal / 10;
    uint128 feesForExecutor = feesTotal - feesForContractAuthor;

    assert(feesForContractAuthor + feesForExecutor == feesTotal);

    address contractFeesRecipient = m_parent.getContractFeeReceiver();
    address executorFeesRecipient = m_disputer.feeReceiver();

    IERC20 rep = getREP();

    assert(rep.transfer(contractFeesRecipient, feesForContractAuthor));
    assert(rep.transfer(executorFeesRecipient, feesForExecutor));

    emit FeesWithdrawn(
      contractFeesRecipient,
      executorFeesRecipient,
      feesForContractAuthor,
      feesForExecutor
    );
  }

  function getParent() external view returns(ICrowdsourcerParent) {
    return m_parent;
  }

  function getDisputerParams() external view returns(
    Market market,
    uint256 feeWindowId,
    uint256[] payoutNumerators,
    bool invalid
  ) {
    return (m_disputerParams.market, m_disputerParams.feeWindowId, m_disputerParams.payoutNumerators, m_disputerParams.invalid);
  }

  function getDisputer() external view requiresInitialization returns(
    IDisputer
  ) {
    return m_disputer;
  }

  function getAccounting() external view requiresInitialization returns(
    IAccounting
  ) {
    return m_accounting;
  }

  function finalize() public requiresInitialization {
    require(hasDisputed(), "Can only finalize after dispute");
    require(!isFinalized(), "Can only finalize once");

    // now that we've disputed we must know dispute token address
    IERC20 disputeTokenAddress = getDisputeToken();
    IERC20 rep = getREP();

    m_disputer.approveManagerToSpendDisputeTokens();

    // retrieve all tokens from disputer for proceeds distribution
    // This wouldn't work extremely well if it is called from disputer's
    // dispute() method, but it should only call Augur which we trust.
    assert(rep.transferFrom(m_disputer, this, rep.balanceOf(m_disputer)));
    assert(
      disputeTokenAddress.transferFrom(
        m_disputer,
        this,
        disputeTokenAddress.balanceOf(m_disputer)
      )
    );

    uint256 amountDisputed = disputeTokenAddress.balanceOf(this);
    uint128 amountDisputed128 = uint128(amountDisputed);

    // REP has only so many tokens
    assert(amountDisputed128 == amountDisputed);

    m_accounting.finalize(amountDisputed128);

    assert(isFinalized());

    emit CrowdsourcerFinalized(amountDisputed128);
  }

  function isInitialized() public view returns(bool) {
    return m_isInitialized;
  }

  function getREP() public view requiresInitialization returns(IERC20) {
    return m_disputer.getREP();
  }

  function getDisputeToken() public view requiresInitialization returns(
    IERC20
  ) {
    return m_disputer.getDisputeTokenAddress();
  }

  function hasDisputed() public view requiresInitialization returns(bool) {
    return m_disputer.hasDisputed();
  }

  function isFinalized() public view requiresInitialization returns(bool) {
    return m_accounting.isFinalized();
  }

  function assertBalancesBeforeDispute() internal view {
    IERC20 rep = getREP();
    assert(rep.balanceOf(m_disputer) >= m_accounting.getTotalContribution());
    assert(rep.balanceOf(this) >= m_accounting.getTotalFeesOffered());
  }
}

// File: contracts/CrowdsourcerFactory.sol

/**
 * NOTE: the created crowdsourcers trust the market that was passed in constructor.
 * If a malicious market is passed in, all bets are off.
 *
 * Individual crowdsourcers have no trust relationships with each other.
 */
contract CrowdsourcerFactory is ICrowdsourcerParent {
  event CrowdsourcerCreated(
    ICrowdsourcer crowdsourcer,
    Market market,
    uint256 feeWindowId,
    uint256[] payoutNumerators,
    bool invalid
  );

  IAccountingFactory public m_accountingFactory;
  IDisputerFactory public m_disputerFactory;

  address public m_feeCollector;
  mapping(bytes32 => ICrowdsourcer) public m_crowdsourcers;
  mapping(uint256 => ICrowdsourcer[]) private m_crowdsourcersPerFeeWindow;

  constructor(
    IAccountingFactory accountingFactory,
    IDisputerFactory disputerFactory,
    address feeCollector
  ) public {
    m_accountingFactory = accountingFactory;
    m_disputerFactory = disputerFactory;
    m_feeCollector = feeCollector;
  }

  function transferFeeCollection(address recipient) external {
    require(msg.sender == m_feeCollector, "Not authorized");
    m_feeCollector = recipient;
  }

  function getInitializedCrowdsourcer(
    Market market,
    uint256 feeWindowId,
    uint256[] payoutNumerators,
    bool invalid
  ) external returns(ICrowdsourcer) {
    ICrowdsourcer crowdsourcer = getCrowdsourcer(
      market,
      feeWindowId,
      payoutNumerators,
      invalid
    );
    if (!crowdsourcer.isInitialized()) {
      crowdsourcer.initialize();
      assert(crowdsourcer.isInitialized());
    }
    return crowdsourcer;
  }

  function getContractFeeReceiver() external view returns(address) {
    return m_feeCollector;
  }

  function maybeGetCrowdsourcer(
    Market market,
    uint256 feeWindowId,
    uint256[] payoutNumerators,
    bool invalid
  ) external view returns(ICrowdsourcer) {
    bytes32 paramsHash = hashParams(
      market,
      feeWindowId,
      payoutNumerators,
      invalid
    );
    return m_crowdsourcers[paramsHash];
  }

  function getCrowdsourcer(
    Market market,
    uint256 feeWindowId,
    uint256[] payoutNumerators,
    bool invalid
  ) public returns(ICrowdsourcer) {
    bytes32 paramsHash = hashParams(
      market,
      feeWindowId,
      payoutNumerators,
      invalid
    );
    ICrowdsourcer existing = m_crowdsourcers[paramsHash];
    if (address(existing) != 0) {
      return existing;
    }
    ICrowdsourcer created = new Crowdsourcer(
      this,
      m_accountingFactory,
      m_disputerFactory,
      market,
      feeWindowId,
      payoutNumerators,
      invalid
    );
    emit CrowdsourcerCreated(
      created,
      market,
      feeWindowId,
      payoutNumerators,
      invalid
    );
    m_crowdsourcersPerFeeWindow[feeWindowId].push(created);
    m_crowdsourcers[paramsHash] = created;
    return created;
  }

  function findCrowdsourcer(
    uint256 feeWindowId,
    uint256 startFrom,
    uint256 minFeesOffered,
    ICrowdsourcer[] exclude
  ) public view returns(uint256, ICrowdsourcer) {
    ICrowdsourcer[] storage crowdsourcers = m_crowdsourcersPerFeeWindow[feeWindowId];
    uint256 n = crowdsourcers.length;
    uint256 i;

    for (i = startFrom; i < n; ++i) {
      ICrowdsourcer candidate = crowdsourcers[i];

      if (!candidate.isInitialized() || candidate.getAccounting(

      ).getTotalFeesOffered() < minFeesOffered) {
        continue;
      }

      bool isGood = true;
      for (uint256 j = 0; j < exclude.length; ++j) {
        if (candidate == exclude[j]) {
          isGood = false;
          break;
        }
      }

      if (isGood) {
        return (i, candidate);
      }
    }

    return (i, ICrowdsourcer(0));
  }

  function getNumCrowdsourcers(uint256 feeWindowId) public view returns(
    uint256
  ) {
    return m_crowdsourcersPerFeeWindow[feeWindowId].length;
  }

  function hashParams(
    Market market,
    uint256 feeWindowId,
    uint256[] payoutNumerators,
    bool invalid
  ) public pure returns(bytes32) {
    return keccak256(
      abi.encodePacked(market, feeWindowId, payoutNumerators, invalid)
    );
  }
}