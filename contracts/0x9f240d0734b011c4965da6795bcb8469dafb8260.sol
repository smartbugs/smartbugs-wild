pragma solidity ^0.4.25;

contract ContractResolver {
    bool public locked_forever;

    function get_contract(bytes32) public view returns (address);

    function init_register_contract(bytes32, address) public returns (bool);
}

contract ResolverClient {

  /// The address of the resolver contract for this project
  address public resolver;
  bytes32 public key;

  /// Make our own address available to us as a constant
  address public CONTRACT_ADDRESS;

  /// Function modifier to check if msg.sender corresponds to the resolved address of a given key
  /// @param _contract The resolver key
  modifier if_sender_is(bytes32 _contract) {
    require(sender_is(_contract));
    _;
  }

  function sender_is(bytes32 _contract) internal view returns (bool _isFrom) {
    _isFrom = msg.sender == ContractResolver(resolver).get_contract(_contract);
  }

  modifier if_sender_is_from(bytes32[3] _contracts) {
    require(sender_is_from(_contracts));
    _;
  }

  function sender_is_from(bytes32[3] _contracts) internal view returns (bool _isFrom) {
    uint256 _n = _contracts.length;
    for (uint256 i = 0; i < _n; i++) {
      if (_contracts[i] == bytes32(0x0)) continue;
      if (msg.sender == ContractResolver(resolver).get_contract(_contracts[i])) {
        _isFrom = true;
        break;
      }
    }
  }

  /// Function modifier to check resolver's locking status.
  modifier unless_resolver_is_locked() {
    require(is_locked() == false);
    _;
  }

  /// @dev Initialize new contract
  /// @param _key the resolver key for this contract
  /// @return _success if the initialization is successful
  function init(bytes32 _key, address _resolver)
           internal
           returns (bool _success)
  {
    bool _is_locked = ContractResolver(_resolver).locked_forever();
    if (_is_locked == false) {
      CONTRACT_ADDRESS = address(this);
      resolver = _resolver;
      key = _key;
      require(ContractResolver(resolver).init_register_contract(key, CONTRACT_ADDRESS));
      _success = true;
    }  else {
      _success = false;
    }
  }

  /// @dev Check if resolver is locked
  /// @return _locked if the resolver is currently locked
  function is_locked()
           private
           view
           returns (bool _locked)
  {
    _locked = ContractResolver(resolver).locked_forever();
  }

  /// @dev Get the address of a contract
  /// @param _key the resolver key to look up
  /// @return _contract the address of the contract
  function get_contract(bytes32 _key)
           public
           view
           returns (address _contract)
  {
    _contract = ContractResolver(resolver).get_contract(_key);
  }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract DaoConstants {
    using SafeMath for uint256;
    bytes32 EMPTY_BYTES = bytes32(0x0);
    address EMPTY_ADDRESS = address(0x0);


    bytes32 PROPOSAL_STATE_PREPROPOSAL = "proposal_state_preproposal";
    bytes32 PROPOSAL_STATE_DRAFT = "proposal_state_draft";
    bytes32 PROPOSAL_STATE_MODERATED = "proposal_state_moderated";
    bytes32 PROPOSAL_STATE_ONGOING = "proposal_state_ongoing";
    bytes32 PROPOSAL_STATE_CLOSED = "proposal_state_closed";
    bytes32 PROPOSAL_STATE_ARCHIVED = "proposal_state_archived";

    uint256 PRL_ACTION_STOP = 1;
    uint256 PRL_ACTION_PAUSE = 2;
    uint256 PRL_ACTION_UNPAUSE = 3;

    uint256 COLLATERAL_STATUS_UNLOCKED = 1;
    uint256 COLLATERAL_STATUS_LOCKED = 2;
    uint256 COLLATERAL_STATUS_CLAIMED = 3;

    bytes32 INTERMEDIATE_DGD_IDENTIFIER = "inter_dgd_id";
    bytes32 INTERMEDIATE_MODERATOR_DGD_IDENTIFIER = "inter_mod_dgd_id";
    bytes32 INTERMEDIATE_BONUS_CALCULATION_IDENTIFIER = "inter_bonus_calculation_id";

    // interactive contracts
    bytes32 CONTRACT_DAO = "dao";
    bytes32 CONTRACT_DAO_SPECIAL_PROPOSAL = "dao:special:proposal";
    bytes32 CONTRACT_DAO_STAKE_LOCKING = "dao:stake-locking";
    bytes32 CONTRACT_DAO_VOTING = "dao:voting";
    bytes32 CONTRACT_DAO_VOTING_CLAIMS = "dao:voting:claims";
    bytes32 CONTRACT_DAO_SPECIAL_VOTING_CLAIMS = "dao:svoting:claims";
    bytes32 CONTRACT_DAO_IDENTITY = "dao:identity";
    bytes32 CONTRACT_DAO_REWARDS_MANAGER = "dao:rewards-manager";
    bytes32 CONTRACT_DAO_REWARDS_MANAGER_EXTRAS = "dao:rewards-extras";
    bytes32 CONTRACT_DAO_ROLES = "dao:roles";
    bytes32 CONTRACT_DAO_FUNDING_MANAGER = "dao:funding-manager";
    bytes32 CONTRACT_DAO_WHITELISTING = "dao:whitelisting";
    bytes32 CONTRACT_DAO_INFORMATION = "dao:information";

    // service contracts
    bytes32 CONTRACT_SERVICE_ROLE = "service:role";
    bytes32 CONTRACT_SERVICE_DAO_INFO = "service:dao:info";
    bytes32 CONTRACT_SERVICE_DAO_LISTING = "service:dao:listing";
    bytes32 CONTRACT_SERVICE_DAO_CALCULATOR = "service:dao:calculator";

    // storage contracts
    bytes32 CONTRACT_STORAGE_DAO = "storage:dao";
    bytes32 CONTRACT_STORAGE_DAO_COUNTER = "storage:dao:counter";
    bytes32 CONTRACT_STORAGE_DAO_UPGRADE = "storage:dao:upgrade";
    bytes32 CONTRACT_STORAGE_DAO_IDENTITY = "storage:dao:identity";
    bytes32 CONTRACT_STORAGE_DAO_POINTS = "storage:dao:points";
    bytes32 CONTRACT_STORAGE_DAO_SPECIAL = "storage:dao:special";
    bytes32 CONTRACT_STORAGE_DAO_CONFIG = "storage:dao:config";
    bytes32 CONTRACT_STORAGE_DAO_STAKE = "storage:dao:stake";
    bytes32 CONTRACT_STORAGE_DAO_REWARDS = "storage:dao:rewards";
    bytes32 CONTRACT_STORAGE_DAO_WHITELISTING = "storage:dao:whitelisting";
    bytes32 CONTRACT_STORAGE_INTERMEDIATE_RESULTS = "storage:intermediate:results";

    bytes32 CONTRACT_DGD_TOKEN = "t:dgd";
    bytes32 CONTRACT_DGX_TOKEN = "t:dgx";
    bytes32 CONTRACT_BADGE_TOKEN = "t:badge";

    uint8 ROLES_ROOT = 1;
    uint8 ROLES_FOUNDERS = 2;
    uint8 ROLES_PRLS = 3;
    uint8 ROLES_KYC_ADMINS = 4;

    uint256 QUARTER_DURATION = 90 days;

    bytes32 CONFIG_MINIMUM_LOCKED_DGD = "min_dgd_participant";
    bytes32 CONFIG_MINIMUM_DGD_FOR_MODERATOR = "min_dgd_moderator";
    bytes32 CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR = "min_reputation_moderator";

    bytes32 CONFIG_LOCKING_PHASE_DURATION = "locking_phase_duration";
    bytes32 CONFIG_QUARTER_DURATION = "quarter_duration";
    bytes32 CONFIG_VOTING_COMMIT_PHASE = "voting_commit_phase";
    bytes32 CONFIG_VOTING_PHASE_TOTAL = "voting_phase_total";
    bytes32 CONFIG_INTERIM_COMMIT_PHASE = "interim_voting_commit_phase";
    bytes32 CONFIG_INTERIM_PHASE_TOTAL = "interim_voting_phase_total";

    bytes32 CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR = "draft_quorum_fixed_numerator";
    bytes32 CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR = "draft_quorum_fixed_denominator";
    bytes32 CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR = "draft_quorum_sfactor_numerator";
    bytes32 CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR = "draft_quorum_sfactor_denominator";
    bytes32 CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR = "vote_quorum_fixed_numerator";
    bytes32 CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR = "vote_quorum_fixed_denominator";
    bytes32 CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR = "vote_quorum_sfactor_numerator";
    bytes32 CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR = "vote_quorum_sfactor_denominator";
    bytes32 CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR = "final_reward_sfactor_numerator";
    bytes32 CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR = "final_reward_sfactor_denominator";

    bytes32 CONFIG_DRAFT_QUOTA_NUMERATOR = "draft_quota_numerator";
    bytes32 CONFIG_DRAFT_QUOTA_DENOMINATOR = "draft_quota_denominator";
    bytes32 CONFIG_VOTING_QUOTA_NUMERATOR = "voting_quota_numerator";
    bytes32 CONFIG_VOTING_QUOTA_DENOMINATOR = "voting_quota_denominator";

    bytes32 CONFIG_MINIMAL_QUARTER_POINT = "minimal_qp";
    bytes32 CONFIG_QUARTER_POINT_SCALING_FACTOR = "quarter_point_scaling_factor";
    bytes32 CONFIG_REPUTATION_POINT_SCALING_FACTOR = "rep_point_scaling_factor";

    bytes32 CONFIG_MODERATOR_MINIMAL_QUARTER_POINT = "minimal_mod_qp";
    bytes32 CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR = "mod_qp_scaling_factor";
    bytes32 CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR = "mod_rep_point_scaling_factor";

    bytes32 CONFIG_QUARTER_POINT_DRAFT_VOTE = "quarter_point_draft_vote";
    bytes32 CONFIG_QUARTER_POINT_VOTE = "quarter_point_vote";
    bytes32 CONFIG_QUARTER_POINT_INTERIM_VOTE = "quarter_point_interim_vote";

    /// this is per 10000 ETHs
    bytes32 CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH = "q_p_milestone_completion";

    bytes32 CONFIG_BONUS_REPUTATION_NUMERATOR = "bonus_reputation_numerator";
    bytes32 CONFIG_BONUS_REPUTATION_DENOMINATOR = "bonus_reputation_denominator";

    bytes32 CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE = "special_proposal_commit_phase";
    bytes32 CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL = "special_proposal_phase_total";

    bytes32 CONFIG_SPECIAL_QUOTA_NUMERATOR = "config_special_quota_numerator";
    bytes32 CONFIG_SPECIAL_QUOTA_DENOMINATOR = "config_special_quota_denominator";

    bytes32 CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR = "special_quorum_numerator";
    bytes32 CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR = "special_quorum_denominator";

    bytes32 CONFIG_MAXIMUM_REPUTATION_DEDUCTION = "config_max_reputation_deduction";
    bytes32 CONFIG_PUNISHMENT_FOR_NOT_LOCKING = "config_punishment_not_locking";

    bytes32 CONFIG_REPUTATION_PER_EXTRA_QP_NUM = "config_rep_per_extra_qp_num";
    bytes32 CONFIG_REPUTATION_PER_EXTRA_QP_DEN = "config_rep_per_extra_qp_den";

    bytes32 CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION = "config_max_m_rp_deduction";
    bytes32 CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM = "config_rep_per_extra_m_qp_num";
    bytes32 CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN = "config_rep_per_extra_m_qp_den";

    bytes32 CONFIG_PORTION_TO_MODERATORS_NUM = "config_mod_portion_num";
    bytes32 CONFIG_PORTION_TO_MODERATORS_DEN = "config_mod_portion_den";

    bytes32 CONFIG_DRAFT_VOTING_PHASE = "config_draft_voting_phase";

    bytes32 CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE = "config_rp_boost_per_badge";

    bytes32 CONFIG_VOTE_CLAIMING_DEADLINE = "config_claiming_deadline";

    bytes32 CONFIG_PREPROPOSAL_COLLATERAL = "config_preproposal_collateral";

    bytes32 CONFIG_MAX_FUNDING_FOR_NON_DIGIX = "config_max_funding_nonDigix";
    bytes32 CONFIG_MAX_MILESTONES_FOR_NON_DIGIX = "config_max_milestones_nonDigix";
    bytes32 CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER = "config_nonDigix_proposal_cap";

    bytes32 CONFIG_PROPOSAL_DEAD_DURATION = "config_dead_duration";
    bytes32 CONFIG_CARBON_VOTE_REPUTATION_BONUS = "config_cv_reputation";
}

contract DaoWhitelistingStorage is ResolverClient, DaoConstants {
    mapping (address => bool) public whitelist;
}

contract DaoWhitelistingCommon is ResolverClient, DaoConstants {

    function daoWhitelistingStorage()
        internal
        view
        returns (DaoWhitelistingStorage _contract)
    {
        _contract = DaoWhitelistingStorage(get_contract(CONTRACT_STORAGE_DAO_WHITELISTING));
    }

    /**
    @notice Check if a certain address is whitelisted to read sensitive information in the storage layer
    @dev if the address is an account, it is allowed to read. If the address is a contract, it has to be in the whitelist
    */
    function senderIsAllowedToRead()
        internal
        view
        returns (bool _senderIsAllowedToRead)
    {
        // msg.sender is allowed to read only if its an EOA or a whitelisted contract
        _senderIsAllowedToRead = (msg.sender == tx.origin) || daoWhitelistingStorage().whitelist(msg.sender);
    }
}

contract DaoIdentityStorage {
    function read_user_role_id(address) constant public returns (uint256);

    function is_kyc_approved(address) public view returns (bool);
}

contract IdentityCommon is DaoWhitelistingCommon {

    modifier if_root() {
        require(identity_storage().read_user_role_id(msg.sender) == ROLES_ROOT);
        _;
    }

    modifier if_founder() {
        require(is_founder());
        _;
    }

    function is_founder()
        internal
        view
        returns (bool _isFounder)
    {
        _isFounder = identity_storage().read_user_role_id(msg.sender) == ROLES_FOUNDERS;
    }

    modifier if_prl() {
        require(identity_storage().read_user_role_id(msg.sender) == ROLES_PRLS);
        _;
    }

    modifier if_kyc_admin() {
        require(identity_storage().read_user_role_id(msg.sender) == ROLES_KYC_ADMINS);
        _;
    }

    function identity_storage()
        internal
        view
        returns (DaoIdentityStorage _contract)
    {
        _contract = DaoIdentityStorage(get_contract(CONTRACT_STORAGE_DAO_IDENTITY));
    }
}

library MathHelper {

  using SafeMath for uint256;

  function max(uint256 a, uint256 b) internal pure returns (uint256 _max){
      _max = b;
      if (a > b) {
          _max = a;
      }
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256 _min){
      _min = b;
      if (a < b) {
          _min = a;
      }
  }

  function sumNumbers(uint256[] _numbers) internal pure returns (uint256 _sum) {
      for (uint256 i=0;i<_numbers.length;i++) {
          _sum = _sum.add(_numbers[i]);
      }
  }
}

contract DaoListingService {
    function listParticipants(uint256, bool) public view returns (address[]);

    function listParticipantsFrom(address, uint256, bool) public view returns (address[]);

    function listModerators(uint256, bool) public view returns (address[]);

    function listModeratorsFrom(address, uint256, bool) public view returns (address[]);
}

contract DaoConfigsStorage {
    mapping (bytes32 => uint256) public uintConfigs;
    mapping (bytes32 => address) public addressConfigs;
    mapping (bytes32 => bytes32) public bytesConfigs;

    function updateUintConfigs(uint256[]) external;

    function readUintConfigs() public view returns (uint256[]);
}

contract DaoStakeStorage {
    mapping (address => uint256) public lockedDGDStake;

    function readLastModerator() public view returns (address);

    function readLastParticipant() public view returns (address);
}

contract DaoProposalCounterStorage {
    mapping (uint256 => uint256) public proposalCountByQuarter;

    function addNonDigixProposalCountInQuarter(uint256) public;
}

contract DaoStorage {
    function readProposal(bytes32) public view returns (bytes32, address, address, bytes32, uint256, uint256, bytes32, bytes32, bool, bool);

    function readProposalProposer(bytes32) public view returns (address);

    function readProposalDraftVotingResult(bytes32) public view returns (bool);

    function readProposalVotingResult(bytes32, uint256) public view returns (bool);

    function readProposalDraftVotingTime(bytes32) public view returns (uint256);

    function readProposalVotingTime(bytes32, uint256) public view returns (uint256);

    function readVote(bytes32, uint256, address) public view returns (bool, uint256);

    function readVotingCount(bytes32, uint256, address[]) external view returns (uint256, uint256);

    function isDraftClaimed(bytes32) public view returns (bool);

    function isClaimed(bytes32, uint256) public view returns (bool);

    function setProposalDraftPass(bytes32, bool) public;

    function setDraftVotingClaim(bytes32, bool) public;

    function readDraftVotingCount(bytes32, address[]) external view returns (uint256, uint256);

    function setProposalVotingTime(bytes32, uint256, uint256) public;

    function setProposalCollateralStatus(bytes32, uint256) public;

    function setVotingClaim(bytes32, uint256, bool) public;

    function setProposalPass(bytes32, uint256, bool) public;

    function readProposalFunding(bytes32) public view returns (uint256[] memory, uint256);

    function archiveProposal(bytes32) public;

    function readProposalMilestone(bytes32, uint256) public view returns (uint256);

    function readVotingRoundVotes(bytes32, uint256, address[], bool) external view returns (address[] memory, uint256);

    function addProposal(bytes32, address, uint256[], uint256, bool) external;

    function setProposalCollateralAmount(bytes32, uint256) public;

    function editProposal(bytes32, bytes32, uint256[], uint256) external;

    function changeFundings(bytes32, uint256[], uint256) external;

    function finalizeProposal(bytes32) public;

    function setProposalDraftVotingTime(bytes32, uint256) public;

    function addProposalDoc(bytes32, bytes32) public;

    function updateProposalEndorse(bytes32, address) public;

    function updateProposalPRL(bytes32, uint256, bytes32, uint256) public;

    function readProposalCollateralStatus(bytes32) public view returns (uint256);

    function closeProposal(bytes32) public;
}

contract DaoUpgradeStorage {
    address public newDaoContract;
    address public newDaoFundingManager;
    address public newDaoRewardsManager;
    uint256 public startOfFirstQuarter;
    bool public isReplacedByNewDao;

    function setStartOfFirstQuarter(uint256) public;

    function setNewContractAddresses(address, address, address) public;

    function updateForDaoMigration() public;
}

contract DaoSpecialStorage {
    function readProposalProposer(bytes32) public view returns (address);

    function readConfigs(bytes32) public view returns (uint256[] memory, address[] memory, bytes32[] memory);

    function readVotingCount(bytes32, address[]) external view returns (uint256, uint256);

    function readVotingTime(bytes32) public view returns (uint256);

    function setPass(bytes32, bool) public;

    function setVotingClaim(bytes32, bool) public;

    function isClaimed(bytes32) public view returns (bool);

    function readVote(bytes32, address) public view returns (bool, uint256);
}

contract DaoPointsStorage {
  function getReputation(address) public view returns (uint256);

  function addQuarterPoint(address, uint256, uint256) public returns (uint256, uint256);

  function increaseReputation(address, uint256) public returns (uint256, uint256);
}

contract DaoRewardsStorage {
    mapping (address => uint256) public lastParticipatedQuarter;

    function readDgxDistributionDay(uint256) public view returns (uint256);
}

contract IntermediateResultsStorage {
    function getIntermediateResults(bytes32) public view returns (address, uint256, uint256, uint256);

    function setIntermediateResults(bytes32, address, uint256, uint256, uint256) public;

    function resetIntermediateResults(bytes32) public;
}

contract DaoCommonMini is IdentityCommon {

    using MathHelper for MathHelper;

    /**
    @notice Check if the DAO contracts have been replaced by a new set of contracts
    @return _isNotReplaced true if it is not replaced, false if it has already been replaced
    */
    function isDaoNotReplaced()
        public
        view
        returns (bool _isNotReplaced)
    {
        _isNotReplaced = !daoUpgradeStorage().isReplacedByNewDao();
    }

    /**
    @notice Check if it is currently in the locking phase
    @dev No governance activities can happen in the locking phase. The locking phase is from t=0 to t=CONFIG_LOCKING_PHASE_DURATION-1
    @return _isLockingPhase true if it is in the locking phase
    */
    function isLockingPhase()
        public
        view
        returns (bool _isLockingPhase)
    {
        _isLockingPhase = currentTimeInQuarter() < getUintConfig(CONFIG_LOCKING_PHASE_DURATION);
    }

    /**
    @notice Check if it is currently in a main phase.
    @dev The main phase is where all the governance activities could take plase. If the DAO is replaced, there can never be any more main phase.
    @return _isMainPhase true if it is in a main phase
    */
    function isMainPhase()
        public
        view
        returns (bool _isMainPhase)
    {
        _isMainPhase =
            isDaoNotReplaced() &&
            currentTimeInQuarter() >= getUintConfig(CONFIG_LOCKING_PHASE_DURATION);
    }

    /**
    @notice Check if the calculateGlobalRewardsBeforeNewQuarter function has been done for a certain quarter
    @dev However, there is no need to run calculateGlobalRewardsBeforeNewQuarter for the first quarter
    */
    modifier ifGlobalRewardsSet(uint256 _quarterNumber) {
        if (_quarterNumber > 1) {
            require(daoRewardsStorage().readDgxDistributionDay(_quarterNumber) > 0);
        }
        _;
    }

    /**
    @notice require that it is currently during a phase, which is within _relativePhaseStart and _relativePhaseEnd seconds, after the _startingPoint
    */
    function requireInPhase(uint256 _startingPoint, uint256 _relativePhaseStart, uint256 _relativePhaseEnd)
        internal
        view
    {
        require(_startingPoint > 0);
        require(now < _startingPoint.add(_relativePhaseEnd));
        require(now >= _startingPoint.add(_relativePhaseStart));
    }

    /**
    @notice Get the current quarter index
    @dev Quarter indexes starts from 1
    @return _quarterNumber the current quarter index
    */
    function currentQuarterNumber()
        public
        view
        returns(uint256 _quarterNumber)
    {
        _quarterNumber = getQuarterNumber(now);
    }

    /**
    @notice Get the quarter index of a timestamp
    @dev Quarter indexes starts from 1
    @return _index the quarter index
    */
    function getQuarterNumber(uint256 _time)
        internal
        view
        returns (uint256 _index)
    {
        require(startOfFirstQuarterIsSet());
        _index =
            _time.sub(daoUpgradeStorage().startOfFirstQuarter())
            .div(getUintConfig(CONFIG_QUARTER_DURATION))
            .add(1);
    }

    /**
    @notice Get the relative time in quarter of a timestamp
    @dev For example, the timeInQuarter of the first second of any quarter n-th is always 1
    */
    function timeInQuarter(uint256 _time)
        internal
        view
        returns (uint256 _timeInQuarter)
    {
        require(startOfFirstQuarterIsSet()); // must be already set
        _timeInQuarter =
            _time.sub(daoUpgradeStorage().startOfFirstQuarter())
            % getUintConfig(CONFIG_QUARTER_DURATION);
    }

    /**
    @notice Check if the start of first quarter is already set
    @return _isSet true if start of first quarter is already set
    */
    function startOfFirstQuarterIsSet()
        internal
        view
        returns (bool _isSet)
    {
        _isSet = daoUpgradeStorage().startOfFirstQuarter() != 0;
    }

    /**
    @notice Get the current relative time in the quarter
    @dev For example: the currentTimeInQuarter of the first second of any quarter is 1
    @return _currentT the current relative time in the quarter
    */
    function currentTimeInQuarter()
        public
        view
        returns (uint256 _currentT)
    {
        _currentT = timeInQuarter(now);
    }

    /**
    @notice Get the time remaining in the quarter
    */
    function getTimeLeftInQuarter(uint256 _time)
        internal
        view
        returns (uint256 _timeLeftInQuarter)
    {
        _timeLeftInQuarter = getUintConfig(CONFIG_QUARTER_DURATION).sub(timeInQuarter(_time));
    }

    function daoListingService()
        internal
        view
        returns (DaoListingService _contract)
    {
        _contract = DaoListingService(get_contract(CONTRACT_SERVICE_DAO_LISTING));
    }

    function daoConfigsStorage()
        internal
        view
        returns (DaoConfigsStorage _contract)
    {
        _contract = DaoConfigsStorage(get_contract(CONTRACT_STORAGE_DAO_CONFIG));
    }

    function daoStakeStorage()
        internal
        view
        returns (DaoStakeStorage _contract)
    {
        _contract = DaoStakeStorage(get_contract(CONTRACT_STORAGE_DAO_STAKE));
    }

    function daoStorage()
        internal
        view
        returns (DaoStorage _contract)
    {
        _contract = DaoStorage(get_contract(CONTRACT_STORAGE_DAO));
    }

    function daoProposalCounterStorage()
        internal
        view
        returns (DaoProposalCounterStorage _contract)
    {
        _contract = DaoProposalCounterStorage(get_contract(CONTRACT_STORAGE_DAO_COUNTER));
    }

    function daoUpgradeStorage()
        internal
        view
        returns (DaoUpgradeStorage _contract)
    {
        _contract = DaoUpgradeStorage(get_contract(CONTRACT_STORAGE_DAO_UPGRADE));
    }

    function daoSpecialStorage()
        internal
        view
        returns (DaoSpecialStorage _contract)
    {
        _contract = DaoSpecialStorage(get_contract(CONTRACT_STORAGE_DAO_SPECIAL));
    }

    function daoPointsStorage()
        internal
        view
        returns (DaoPointsStorage _contract)
    {
        _contract = DaoPointsStorage(get_contract(CONTRACT_STORAGE_DAO_POINTS));
    }

    function daoRewardsStorage()
        internal
        view
        returns (DaoRewardsStorage _contract)
    {
        _contract = DaoRewardsStorage(get_contract(CONTRACT_STORAGE_DAO_REWARDS));
    }

    function intermediateResultsStorage()
        internal
        view
        returns (IntermediateResultsStorage _contract)
    {
        _contract = IntermediateResultsStorage(get_contract(CONTRACT_STORAGE_INTERMEDIATE_RESULTS));
    }

    function getUintConfig(bytes32 _configKey)
        public
        view
        returns (uint256 _configValue)
    {
        _configValue = daoConfigsStorage().uintConfigs(_configKey);
    }
}

contract DaoCommon is DaoCommonMini {

    using MathHelper for MathHelper;

    /**
    @notice Check if the transaction is called by the proposer of a proposal
    @return _isFromProposer true if the caller is the proposer
    */
    function isFromProposer(bytes32 _proposalId)
        internal
        view
        returns (bool _isFromProposer)
    {
        _isFromProposer = msg.sender == daoStorage().readProposalProposer(_proposalId);
    }

    /**
    @notice Check if the proposal can still be "editted", or in other words, added more versions
    @dev Once the proposal is finalized, it can no longer be editted. The proposer will still be able to add docs and change fundings though.
    @return _isEditable true if the proposal is editable
    */
    function isEditable(bytes32 _proposalId)
        internal
        view
        returns (bool _isEditable)
    {
        bytes32 _finalVersion;
        (,,,,,,,_finalVersion,,) = daoStorage().readProposal(_proposalId);
        _isEditable = _finalVersion == EMPTY_BYTES;
    }

    /**
    @notice returns the balance of DaoFundingManager, which is the wei in DigixDAO
    */
    function weiInDao()
        internal
        view
        returns (uint256 _wei)
    {
        _wei = get_contract(CONTRACT_DAO_FUNDING_MANAGER).balance;
    }

    /**
    @notice Check if it is after the draft voting phase of the proposal
    */
    modifier ifAfterDraftVotingPhase(bytes32 _proposalId) {
        uint256 _start = daoStorage().readProposalDraftVotingTime(_proposalId);
        require(_start > 0); // Draft voting must have started. In other words, proposer must have finalized the proposal
        require(now >= _start.add(getUintConfig(CONFIG_DRAFT_VOTING_PHASE)));
        _;
    }

    modifier ifCommitPhase(bytes32 _proposalId, uint8 _index) {
        requireInPhase(
            daoStorage().readProposalVotingTime(_proposalId, _index),
            0,
            getUintConfig(_index == 0 ? CONFIG_VOTING_COMMIT_PHASE : CONFIG_INTERIM_COMMIT_PHASE)
        );
        _;
    }

    modifier ifRevealPhase(bytes32 _proposalId, uint256 _index) {
      requireInPhase(
          daoStorage().readProposalVotingTime(_proposalId, _index),
          getUintConfig(_index == 0 ? CONFIG_VOTING_COMMIT_PHASE : CONFIG_INTERIM_COMMIT_PHASE),
          getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL)
      );
      _;
    }

    modifier ifAfterProposalRevealPhase(bytes32 _proposalId, uint256 _index) {
      uint256 _start = daoStorage().readProposalVotingTime(_proposalId, _index);
      require(_start > 0);
      require(now >= _start.add(getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL)));
      _;
    }

    modifier ifDraftVotingPhase(bytes32 _proposalId) {
        requireInPhase(
            daoStorage().readProposalDraftVotingTime(_proposalId),
            0,
            getUintConfig(CONFIG_DRAFT_VOTING_PHASE)
        );
        _;
    }

    modifier isProposalState(bytes32 _proposalId, bytes32 _STATE) {
        bytes32 _currentState;
        (,,,_currentState,,,,,,) = daoStorage().readProposal(_proposalId);
        require(_currentState == _STATE);
        _;
    }

    /**
    @notice Check if the DAO has enough ETHs for a particular funding request
    */
    modifier ifFundingPossible(uint256[] _fundings, uint256 _finalReward) {
        require(MathHelper.sumNumbers(_fundings).add(_finalReward) <= weiInDao());
        _;
    }

    modifier ifDraftNotClaimed(bytes32 _proposalId) {
        require(daoStorage().isDraftClaimed(_proposalId) == false);
        _;
    }

    modifier ifNotClaimed(bytes32 _proposalId, uint256 _index) {
        require(daoStorage().isClaimed(_proposalId, _index) == false);
        _;
    }

    modifier ifNotClaimedSpecial(bytes32 _proposalId) {
        require(daoSpecialStorage().isClaimed(_proposalId) == false);
        _;
    }

    modifier hasNotRevealed(bytes32 _proposalId, uint256 _index) {
        uint256 _voteWeight;
        (, _voteWeight) = daoStorage().readVote(_proposalId, _index, msg.sender);
        require(_voteWeight == uint(0));
        _;
    }

    modifier hasNotRevealedSpecial(bytes32 _proposalId) {
        uint256 _weight;
        (,_weight) = daoSpecialStorage().readVote(_proposalId, msg.sender);
        require(_weight == uint256(0));
        _;
    }

    modifier ifAfterRevealPhaseSpecial(bytes32 _proposalId) {
      uint256 _start = daoSpecialStorage().readVotingTime(_proposalId);
      require(_start > 0);
      require(now.sub(_start) >= getUintConfig(CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL));
      _;
    }

    modifier ifCommitPhaseSpecial(bytes32 _proposalId) {
        requireInPhase(
            daoSpecialStorage().readVotingTime(_proposalId),
            0,
            getUintConfig(CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE)
        );
        _;
    }

    modifier ifRevealPhaseSpecial(bytes32 _proposalId) {
        requireInPhase(
            daoSpecialStorage().readVotingTime(_proposalId),
            getUintConfig(CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE),
            getUintConfig(CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL)
        );
        _;
    }

    function daoWhitelistingStorage()
        internal
        view
        returns (DaoWhitelistingStorage _contract)
    {
        _contract = DaoWhitelistingStorage(get_contract(CONTRACT_STORAGE_DAO_WHITELISTING));
    }

    function getAddressConfig(bytes32 _configKey)
        public
        view
        returns (address _configValue)
    {
        _configValue = daoConfigsStorage().addressConfigs(_configKey);
    }

    function getBytesConfig(bytes32 _configKey)
        public
        view
        returns (bytes32 _configValue)
    {
        _configValue = daoConfigsStorage().bytesConfigs(_configKey);
    }

    /**
    @notice Check if a user is a participant in the current quarter
    */
    function isParticipant(address _user)
        public
        view
        returns (bool _is)
    {
        _is =
            (daoRewardsStorage().lastParticipatedQuarter(_user) == currentQuarterNumber())
            && (daoStakeStorage().lockedDGDStake(_user) >= getUintConfig(CONFIG_MINIMUM_LOCKED_DGD));
    }

    /**
    @notice Check if a user is a moderator in the current quarter
    */
    function isModerator(address _user)
        public
        view
        returns (bool _is)
    {
        _is =
            (daoRewardsStorage().lastParticipatedQuarter(_user) == currentQuarterNumber())
            && (daoStakeStorage().lockedDGDStake(_user) >= getUintConfig(CONFIG_MINIMUM_DGD_FOR_MODERATOR))
            && (daoPointsStorage().getReputation(_user) >= getUintConfig(CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR));
    }

    /**
    @notice Calculate the start of a specific milestone of a specific proposal.
    @dev This is calculated from the voting start of the voting round preceding the milestone
         This would throw if the voting start is 0 (the voting round has not started yet)
         Note that if the milestoneIndex is exactly the same as the number of milestones,
         This will just return the end of the last voting round.
    */
    function startOfMilestone(bytes32 _proposalId, uint256 _milestoneIndex)
        internal
        view
        returns (uint256 _milestoneStart)
    {
        uint256 _startOfPrecedingVotingRound = daoStorage().readProposalVotingTime(_proposalId, _milestoneIndex);
        require(_startOfPrecedingVotingRound > 0);
        // the preceding voting round must have started

        if (_milestoneIndex == 0) { // This is the 1st milestone, which starts after voting round 0
            _milestoneStart =
                _startOfPrecedingVotingRound
                .add(getUintConfig(CONFIG_VOTING_PHASE_TOTAL));
        } else { // if its the n-th milestone, it starts after voting round n-th
            _milestoneStart =
                _startOfPrecedingVotingRound
                .add(getUintConfig(CONFIG_INTERIM_PHASE_TOTAL));
        }
    }

    /**
    @notice Calculate the actual voting start for a voting round, given the tentative start
    @dev The tentative start is the ideal start. For example, when a proposer finish a milestone, it should be now
         However, sometimes the tentative start is too close to the end of the quarter, hence, the actual voting start should be pushed to the next quarter
    */
    function getTimelineForNextVote(
        uint256 _index,
        uint256 _tentativeVotingStart
    )
        internal
        view
        returns (uint256 _actualVotingStart)
    {
        uint256 _timeLeftInQuarter = getTimeLeftInQuarter(_tentativeVotingStart);
        uint256 _votingDuration = getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL);
        _actualVotingStart = _tentativeVotingStart;
        if (timeInQuarter(_tentativeVotingStart) < getUintConfig(CONFIG_LOCKING_PHASE_DURATION)) { // if the tentative start is during a locking phase
            _actualVotingStart = _tentativeVotingStart.add(
                getUintConfig(CONFIG_LOCKING_PHASE_DURATION).sub(timeInQuarter(_tentativeVotingStart))
            );
        } else if (_timeLeftInQuarter < _votingDuration.add(getUintConfig(CONFIG_VOTE_CLAIMING_DEADLINE))) { // if the time left in quarter is not enough to vote and claim voting
            _actualVotingStart = _tentativeVotingStart.add(
                _timeLeftInQuarter.add(getUintConfig(CONFIG_LOCKING_PHASE_DURATION)).add(1)
            );
        }
    }

    /**
    @notice Check if we can add another non-Digix proposal in this quarter
    @dev There is a max cap to the number of non-Digix proposals CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER
    */
    function checkNonDigixProposalLimit(bytes32 _proposalId)
        internal
        view
    {
        require(isNonDigixProposalsWithinLimit(_proposalId));
    }

    function isNonDigixProposalsWithinLimit(bytes32 _proposalId)
        internal
        view
        returns (bool _withinLimit)
    {
        bool _isDigixProposal;
        (,,,,,,,,,_isDigixProposal) = daoStorage().readProposal(_proposalId);
        _withinLimit = true;
        if (!_isDigixProposal) {
            _withinLimit = daoProposalCounterStorage().proposalCountByQuarter(currentQuarterNumber()) < getUintConfig(CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER);
        }
    }

    /**
    @notice If its a non-Digix proposal, check if the fundings are within limit
    @dev There is a max cap to the fundings and number of milestones for non-Digix proposals
    */
    function checkNonDigixFundings(uint256[] _milestonesFundings, uint256 _finalReward)
        internal
        view
    {
        if (!is_founder()) {
            require(_milestonesFundings.length <= getUintConfig(CONFIG_MAX_MILESTONES_FOR_NON_DIGIX));
            require(MathHelper.sumNumbers(_milestonesFundings).add(_finalReward) <= getUintConfig(CONFIG_MAX_FUNDING_FOR_NON_DIGIX));
        }
    }

    /**
    @notice Check if msg.sender can do operations as a proposer
    @dev Note that this function does not check if he is the proposer of the proposal
    */
    function senderCanDoProposerOperations()
        internal
        view
    {
        require(isMainPhase());
        require(isParticipant(msg.sender));
        require(identity_storage().is_kyc_approved(msg.sender));
    }
}

library DaoIntermediateStructs {
    struct VotingCount {
        // weight of votes "FOR" the voting round
        uint256 forCount;
        // weight of votes "AGAINST" the voting round
        uint256 againstCount;
    }

    // Struct used in large functions to cut down on variables
    struct Users {
        // Length of the above list
        uint256 usersLength;
        // List of addresses, participants of DigixDAO
        address[] users;
    }
}

library DaoStructs {
    struct IntermediateResults {
        // weight of "FOR" votes counted up until the current calculation step
        uint256 currentForCount;

        // weight of "AGAINST" votes counted up until the current calculation step
        uint256 currentAgainstCount;

        // summation of effectiveDGDs up until the iteration of calculation
        uint256 currentSumOfEffectiveBalance;

        // Address of user until which the calculation has been done
        address countedUntil;
    }
}

contract DaoCalculatorService {
    function minimumVotingQuorumForSpecial() public view returns (uint256);

    function votingQuotaForSpecialPass(uint256, uint256) public view returns (bool);

    function minimumDraftQuorum(bytes32) public view returns (uint256);

    function draftQuotaPass(uint256, uint256) public view returns (bool);

    function minimumVotingQuorum(bytes32, uint256) public view returns (uint256);

    function votingQuotaPass(uint256, uint256) public view returns (bool);
}

contract DaoFundingManager {
    function refundCollateral(address, bytes32) public returns (bool);

    function moveFundsToNewDao(address) public;
}

contract DaoRewardsManager {
    function moveDGXsToNewDao(address) public;
}

contract DaoVotingClaims {
}

/**
@title Interactive DAO contract for creating/modifying/endorsing proposals
@author Digix Holdings
*/
contract Dao is DaoCommon {

    event NewProposal(bytes32 indexed _proposalId, address _proposer);
    event ModifyProposal(bytes32 indexed _proposalId, bytes32 _newDoc);
    event ChangeProposalFunding(bytes32 indexed _proposalId);
    event FinalizeProposal(bytes32 indexed _proposalId);
    event FinishMilestone(bytes32 indexed _proposalId, uint256 indexed _milestoneIndex);
    event AddProposalDoc(bytes32 indexed _proposalId, bytes32 _newDoc);
    event PRLAction(bytes32 indexed _proposalId, uint256 _actionId, bytes32 _doc);
    event CloseProposal(bytes32 indexed _proposalId);
    event MigrateToNewDao(address _newDaoContract, address _newDaoFundingManager, address _newDaoRewardsManager);

    constructor(address _resolver) public {
        require(init(CONTRACT_DAO, _resolver));
    }

    function daoFundingManager()
        internal
        view
        returns (DaoFundingManager _contract)
    {
        _contract = DaoFundingManager(get_contract(CONTRACT_DAO_FUNDING_MANAGER));
    }

    function daoRewardsManager()
        internal
        view
        returns (DaoRewardsManager _contract)
    {
        _contract = DaoRewardsManager(get_contract(CONTRACT_DAO_REWARDS_MANAGER));
    }

    function daoVotingClaims()
        internal
        view
        returns (DaoVotingClaims _contract)
    {
        _contract = DaoVotingClaims(get_contract(CONTRACT_DAO_VOTING_CLAIMS));
    }

    /**
    @notice Set addresses for the new Dao and DaoFundingManager contracts
    @dev This is the first step of the 2-step migration
    @param _newDaoContract Address of the new Dao contract
    @param _newDaoFundingManager Address of the new DaoFundingManager contract
    @param _newDaoRewardsManager Address of the new daoRewardsManager contract
    */
    function setNewDaoContracts(
        address _newDaoContract,
        address _newDaoFundingManager,
        address _newDaoRewardsManager
    )
        public
        if_root()
    {
        require(daoUpgradeStorage().isReplacedByNewDao() == false);
        daoUpgradeStorage().setNewContractAddresses(
            _newDaoContract,
            _newDaoFundingManager,
            _newDaoRewardsManager
        );
    }

    /**
    @notice Migrate this DAO to a new DAO contract
    @dev This is the second step of the 2-step migration
         Migration can only be done during the locking phase, after the global rewards for current quarter are set.
         This is to make sure that there is no rewards calculation pending before the DAO is migrated to new contracts
         The addresses of the new Dao contracts have to be provided again, and be double checked against the addresses that were set in setNewDaoContracts()
    @param _newDaoContract Address of the new DAO contract
    @param _newDaoFundingManager Address of the new DaoFundingManager contract, which would receive the remaining ETHs in this DaoFundingManager
    @param _newDaoRewardsManager Address of the new daoRewardsManager contract, which would receive the claimableDGXs from this daoRewardsManager
    */
    function migrateToNewDao(
        address _newDaoContract,
        address _newDaoFundingManager,
        address _newDaoRewardsManager
    )
        public
        if_root()
        ifGlobalRewardsSet(currentQuarterNumber())
    {
        require(isLockingPhase());
        require(daoUpgradeStorage().isReplacedByNewDao() == false);
        require(
          (daoUpgradeStorage().newDaoContract() == _newDaoContract) &&
          (daoUpgradeStorage().newDaoFundingManager() == _newDaoFundingManager) &&
          (daoUpgradeStorage().newDaoRewardsManager() == _newDaoRewardsManager)
        );
        daoUpgradeStorage().updateForDaoMigration();
        daoFundingManager().moveFundsToNewDao(_newDaoFundingManager);
        daoRewardsManager().moveDGXsToNewDao(_newDaoRewardsManager);
        emit MigrateToNewDao(_newDaoContract, _newDaoFundingManager, _newDaoRewardsManager);
    }

    /**
    @notice Call this function to mark the start of the DAO's first quarter. This can only be done once, by a founder
    @param _start Start time of the first quarter in the DAO
    */
    function setStartOfFirstQuarter(uint256 _start) public if_founder() {
        require(daoUpgradeStorage().startOfFirstQuarter() == 0);
        require(_start > now);
        daoUpgradeStorage().setStartOfFirstQuarter(_start);
    }

    /**
    @notice Submit a new preliminary idea / Pre-proposal
    @dev The proposer has to send in a collateral == getUintConfig(CONFIG_PREPROPOSAL_COLLATERAL)
         which he could claim back in these scenarios:
          - Before the proposal is finalized, by calling closeProposal()
          - After all milestones are done and the final voting round is passed

    @param _docIpfsHash Hash of the IPFS doc containing details of proposal
    @param _milestonesFundings Array of fundings of the proposal milestones (in wei)
    @param _finalReward Final reward asked by proposer at successful completion of all milestones of proposal
    */
    function submitPreproposal(
        bytes32 _docIpfsHash,
        uint256[] _milestonesFundings,
        uint256 _finalReward
    )
        external
        payable
    {
        senderCanDoProposerOperations();
        bool _isFounder = is_founder();

        require(MathHelper.sumNumbers(_milestonesFundings).add(_finalReward) <= weiInDao());

        require(msg.value == getUintConfig(CONFIG_PREPROPOSAL_COLLATERAL));
        require(address(daoFundingManager()).call.gas(25000).value(msg.value)());

        checkNonDigixFundings(_milestonesFundings, _finalReward);

        daoStorage().addProposal(_docIpfsHash, msg.sender, _milestonesFundings, _finalReward, _isFounder);
        daoStorage().setProposalCollateralStatus(_docIpfsHash, COLLATERAL_STATUS_UNLOCKED);
        daoStorage().setProposalCollateralAmount(_docIpfsHash, msg.value);

        emit NewProposal(_docIpfsHash, msg.sender);
    }

    /**
    @notice Modify a proposal (this can be done only before setting the final version)
    @param _proposalId Proposal ID (hash of IPFS doc of the first version of the proposal)
    @param _docIpfsHash Hash of IPFS doc of the modified version of the proposal
    @param _milestonesFundings Array of fundings of the modified version of the proposal (in wei)
    @param _finalReward Final reward on successful completion of all milestones of the modified version of proposal (in wei)
    */
    function modifyProposal(
        bytes32 _proposalId,
        bytes32 _docIpfsHash,
        uint256[] _milestonesFundings,
        uint256 _finalReward
    )
        external
    {
        senderCanDoProposerOperations();
        require(isFromProposer(_proposalId));

        require(isEditable(_proposalId));
        bytes32 _currentState;
        (,,,_currentState,,,,,,) = daoStorage().readProposal(_proposalId);
        require(_currentState == PROPOSAL_STATE_PREPROPOSAL ||
          _currentState == PROPOSAL_STATE_DRAFT);

        checkNonDigixFundings(_milestonesFundings, _finalReward);

        daoStorage().editProposal(_proposalId, _docIpfsHash, _milestonesFundings, _finalReward);

        emit ModifyProposal(_proposalId, _docIpfsHash);
    }

    /**
    @notice Function to change the funding structure for a proposal
    @dev Proposers can only change fundings for the subsequent milestones,
    during the duration of an on-going milestone (so, cannot be before proposal finalization or during any voting phase)
    @param _proposalId ID of the proposal
    @param _milestonesFundings Array of fundings for milestones
    @param _finalReward Final reward needed for completion of proposal
    @param _currentMilestone the milestone number the proposal is currently in
    */
    function changeFundings(
        bytes32 _proposalId,
        uint256[] _milestonesFundings,
        uint256 _finalReward,
        uint256 _currentMilestone
    )
        external
    {
        senderCanDoProposerOperations();
        require(isFromProposer(_proposalId));

        checkNonDigixFundings(_milestonesFundings, _finalReward);

        uint256[] memory _currentFundings;
        (_currentFundings,) = daoStorage().readProposalFunding(_proposalId);

        // If there are N milestones, the milestone index must be < N. Otherwise, putting a milestone index of N will actually return a valid timestamp that is
        // right after the final voting round (voting round index N is the final voting round)
        // Which could be abused ( to add more milestones even after the final voting round)
        require(_currentMilestone < _currentFundings.length);

        uint256 _startOfCurrentMilestone = startOfMilestone(_proposalId, _currentMilestone);

        // must be after the start of the milestone, and the milestone has not been finished yet (next voting hasnt started)
        require(now > _startOfCurrentMilestone);
        require(daoStorage().readProposalVotingTime(_proposalId, _currentMilestone.add(1)) == 0);

        // can only modify the fundings after _currentMilestone
        // so, all the fundings from 0 to _currentMilestone must be the same
        for (uint256 i=0;i<=_currentMilestone;i++) {
            require(_milestonesFundings[i] == _currentFundings[i]);
        }

        daoStorage().changeFundings(_proposalId, _milestonesFundings, _finalReward);

        emit ChangeProposalFunding(_proposalId);
    }

    /**
    @notice Finalize a proposal
    @dev After finalizing a proposal, no more proposal version can be added. Proposer will only be able to change fundings and add more docs
         Right after finalizing a proposal, the draft voting round starts. The proposer would also not be able to closeProposal() anymore
         (hence, cannot claim back the collateral anymore, until the final voting round passes)
    @param _proposalId ID of the proposal
    */
    function finalizeProposal(bytes32 _proposalId)
        public
    {
        senderCanDoProposerOperations();
        require(isFromProposer(_proposalId));
        require(isEditable(_proposalId));
        checkNonDigixProposalLimit(_proposalId);

        // make sure we have reasonably enough time left in the quarter to conduct the Draft Voting.
        // Otherwise, the proposer must wait until the next quarter to finalize the proposal
        require(getTimeLeftInQuarter(now) > getUintConfig(CONFIG_DRAFT_VOTING_PHASE).add(getUintConfig(CONFIG_VOTE_CLAIMING_DEADLINE)));
        address _endorser;
        (,,_endorser,,,,,,,) = daoStorage().readProposal(_proposalId);
        require(_endorser != EMPTY_ADDRESS);
        daoStorage().finalizeProposal(_proposalId);
        daoStorage().setProposalDraftVotingTime(_proposalId, now);

        emit FinalizeProposal(_proposalId);
    }

    /**
    @notice Function to set milestone to be completed
    @dev This can only be called in the Main Phase of DigixDAO by the proposer. It sets the
         voting time for the next milestone, which is immediately, for most of the times. If there is not enough time left in the current
         quarter, then the next voting is postponed to the start of next quarter
    @param _proposalId ID of the proposal
    @param _milestoneIndex Index of the milestone. Index starts from 0 (for the first milestone)
    */
    function finishMilestone(bytes32 _proposalId, uint256 _milestoneIndex)
        public
    {
        senderCanDoProposerOperations();
        require(isFromProposer(_proposalId));

        uint256[] memory _currentFundings;
        (_currentFundings,) = daoStorage().readProposalFunding(_proposalId);

        // If there are N milestones, the milestone index must be < N. Otherwise, putting a milestone index of N will actually return a valid timestamp that is
        // right after the final voting round (voting round index N is the final voting round)
        // Which could be abused ( to "finish" a milestone even after the final voting round)
        require(_milestoneIndex < _currentFundings.length);

        // must be after the start of this milestone, and the milestone has not been finished yet (voting hasnt started)
        uint256 _startOfCurrentMilestone = startOfMilestone(_proposalId, _milestoneIndex);
        require(now > _startOfCurrentMilestone);
        require(daoStorage().readProposalVotingTime(_proposalId, _milestoneIndex.add(1)) == 0);

        daoStorage().setProposalVotingTime(
            _proposalId,
            _milestoneIndex.add(1),
            getTimelineForNextVote(_milestoneIndex.add(1), now)
        ); // set the voting time of next voting

        emit FinishMilestone(_proposalId, _milestoneIndex);
    }

    /**
    @notice Add IPFS docs to a proposal
    @dev This is allowed only after a proposal is finalized. Before finalizing
         a proposal, proposer can modifyProposal and basically create a different ProposalVersion. After the proposal is finalized,
         they can only allProposalDoc to the final version of that proposal
    @param _proposalId ID of the proposal
    @param _newDoc hash of the new IPFS doc
    */
    function addProposalDoc(bytes32 _proposalId, bytes32 _newDoc)
        public
    {
        senderCanDoProposerOperations();
        require(isFromProposer(_proposalId));
        bytes32 _finalVersion;
        (,,,,,,,_finalVersion,,) = daoStorage().readProposal(_proposalId);
        require(_finalVersion != EMPTY_BYTES);
        daoStorage().addProposalDoc(_proposalId, _newDoc);

        emit AddProposalDoc(_proposalId, _newDoc);
    }

    /**
    @notice Function to endorse a pre-proposal (can be called only by DAO Moderator)
    @param _proposalId ID of the proposal (hash of IPFS doc of the first version of the proposal)
    */
    function endorseProposal(bytes32 _proposalId)
        public
        isProposalState(_proposalId, PROPOSAL_STATE_PREPROPOSAL)
    {
        require(isMainPhase());
        require(isModerator(msg.sender));
        daoStorage().updateProposalEndorse(_proposalId, msg.sender);
    }

    /**
    @notice Function to update the PRL (regulatory status) status of a proposal
    @dev if a proposal is paused or stopped, the proposer wont be able to withdraw the funding
    @param _proposalId ID of the proposal
    @param _doc hash of IPFS uploaded document, containing details of PRL Action
    */
    function updatePRL(
        bytes32 _proposalId,
        uint256 _action,
        bytes32 _doc
    )
        public
        if_prl()
    {
        require(_action == PRL_ACTION_STOP || _action == PRL_ACTION_PAUSE || _action == PRL_ACTION_UNPAUSE);
        daoStorage().updateProposalPRL(_proposalId, _action, _doc, now);

        emit PRLAction(_proposalId, _action, _doc);
    }

    /**
    @notice Function to close proposal (also get back collateral)
    @dev Can only be closed if the proposal has not been finalized yet
    @param _proposalId ID of the proposal
    */
    function closeProposal(bytes32 _proposalId)
        public
    {
        senderCanDoProposerOperations();
        require(isFromProposer(_proposalId));
        bytes32 _finalVersion;
        bytes32 _status;
        (,,,_status,,,,_finalVersion,,) = daoStorage().readProposal(_proposalId);
        require(_finalVersion == EMPTY_BYTES);
        require(_status != PROPOSAL_STATE_CLOSED);
        require(daoStorage().readProposalCollateralStatus(_proposalId) == COLLATERAL_STATUS_UNLOCKED);

        daoStorage().closeProposal(_proposalId);
        daoStorage().setProposalCollateralStatus(_proposalId, COLLATERAL_STATUS_CLAIMED);
        emit CloseProposal(_proposalId);
        require(daoFundingManager().refundCollateral(msg.sender, _proposalId));
    }

    /**
    @notice Function for founders to close all the dead proposals
    @dev Dead proposals = all proposals who are not yet finalized, and been there for more than the threshold time
         The proposers of dead proposals will not get the collateral back
    @param _proposalIds Array of proposal IDs
    */
    function founderCloseProposals(bytes32[] _proposalIds)
        external
        if_founder()
    {
        uint256 _length = _proposalIds.length;
        uint256 _timeCreated;
        bytes32 _finalVersion;
        bytes32 _currentState;
        for (uint256 _i = 0; _i < _length; _i++) {
            (,,,_currentState,_timeCreated,,,_finalVersion,,) = daoStorage().readProposal(_proposalIds[_i]);
            require(_finalVersion == EMPTY_BYTES);
            require(
                (_currentState == PROPOSAL_STATE_PREPROPOSAL) ||
                (_currentState == PROPOSAL_STATE_DRAFT)
            );
            require(now > _timeCreated.add(getUintConfig(CONFIG_PROPOSAL_DEAD_DURATION)));
            emit CloseProposal(_proposalIds[_i]);
            daoStorage().closeProposal(_proposalIds[_i]);
        }
    }
}