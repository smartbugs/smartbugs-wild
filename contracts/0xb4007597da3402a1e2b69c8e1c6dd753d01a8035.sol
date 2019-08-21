pragma solidity ^0.4.17;

/*

 * source       https://github.com/blockbitsio/

 * @name        Application Entity Generic Contract
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

    Used for the ABI interface when assets need to call Application Entity.

    This is required, otherwise we end up loading the assets themselves when we load the ApplicationEntity contract
    and end up in a loop
*/



contract ApplicationEntityABI {

    address public ProposalsEntity;
    address public FundingEntity;
    address public MilestonesEntity;
    address public MeetingsEntity;
    address public BountyManagerEntity;
    address public TokenManagerEntity;
    address public ListingContractEntity;
    address public FundingManagerEntity;
    address public NewsContractEntity;

    bool public _initialized = false;
    bool public _locked = false;
    uint8 public CurrentEntityState;
    uint8 public AssetCollectionNum;
    address public GatewayInterfaceAddress;
    address public deployerAddress;
    address testAddressAllowUpgradeFrom;
    mapping (bytes32 => uint8) public EntityStates;
    mapping (bytes32 => address) public AssetCollection;
    mapping (uint8 => bytes32) public AssetCollectionIdToName;
    mapping (bytes32 => uint256) public BylawsUint256;
    mapping (bytes32 => bytes32) public BylawsBytes32;

    function ApplicationEntity() public;
    function getEntityState(bytes32 name) public view returns (uint8);
    function linkToGateway( address _GatewayInterfaceAddress, bytes32 _sourceCodeUrl ) external;
    function setUpgradeState(uint8 state) public ;
    function addAssetProposals(address _assetAddresses) external;
    function addAssetFunding(address _assetAddresses) external;
    function addAssetMilestones(address _assetAddresses) external;
    function addAssetMeetings(address _assetAddresses) external;
    function addAssetBountyManager(address _assetAddresses) external;
    function addAssetTokenManager(address _assetAddresses) external;
    function addAssetFundingManager(address _assetAddresses) external;
    function addAssetListingContract(address _assetAddresses) external;
    function addAssetNewsContract(address _assetAddresses) external;
    function getAssetAddressByName(bytes32 _name) public view returns (address);
    function setBylawUint256(bytes32 name, uint256 value) public;
    function getBylawUint256(bytes32 name) public view returns (uint256);
    function setBylawBytes32(bytes32 name, bytes32 value) public;
    function getBylawBytes32(bytes32 name) public view returns (bytes32);
    function initialize() external returns (bool);
    function getParentAddress() external view returns(address);
    function createCodeUpgradeProposal( address _newAddress, bytes32 _sourceCodeUrl ) external returns (uint256);
    function acceptCodeUpgradeProposal(address _newAddress) external;
    function initializeAssetsToThisApplication() external returns (bool);
    function transferAssetsToNewApplication(address _newAddress) external returns (bool);
    function lock() external returns (bool);
    function canInitiateCodeUpgrade(address _sender) public view returns(bool);
    function doStateChanges() public;
    function hasRequiredStateChanges() public view returns (bool);
    function anyAssetHasChanges() public view returns (bool);
    function extendedAnyAssetHasChanges() internal view returns (bool);
    function getRequiredStateChanges() public view returns (uint8, uint8);
    function getTimestamp() view public returns (uint256);

}

/*

 * source       https://github.com/blockbitsio/

 * @name        Application Asset Contract
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

 Any contract inheriting this will be usable as an Asset in the Application Entity

*/




contract ApplicationAsset {

    event EventAppAssetOwnerSet(bytes32 indexed _name, address indexed _owner);
    event EventRunBeforeInit(bytes32 indexed _name);
    event EventRunBeforeApplyingSettings(bytes32 indexed _name);


    mapping (bytes32 => uint8) public EntityStates;
    mapping (bytes32 => uint8) public RecordStates;
    uint8 public CurrentEntityState;

    event EventEntityProcessor(bytes32 indexed _assetName, uint8 indexed _current, uint8 indexed _required);
    event DebugEntityRequiredChanges( bytes32 _assetName, uint8 indexed _current, uint8 indexed _required );

    bytes32 public assetName;

    /* Asset records */
    uint8 public RecordNum = 0;

    /* Asset initialised or not */
    bool public _initialized = false;

    /* Asset settings present or not */
    bool public _settingsApplied = false;

    /* Asset owner ( ApplicationEntity address ) */
    address public owner = address(0x0) ;
    address public deployerAddress;

    function ApplicationAsset() public {
        deployerAddress = msg.sender;
    }

    function setInitialApplicationAddress(address _ownerAddress) public onlyDeployer requireNotInitialised {
        owner = _ownerAddress;
    }

    function setInitialOwnerAndName(bytes32 _name) external
        requireNotInitialised
        onlyOwner
        returns (bool)
    {
        // init states
        setAssetStates();
        assetName = _name;
        // set initial state
        CurrentEntityState = getEntityState("NEW");
        runBeforeInitialization();
        _initialized = true;
        EventAppAssetOwnerSet(_name, owner);
        return true;
    }

    function setAssetStates() internal {
        // Asset States
        EntityStates["__IGNORED__"]     = 0;
        EntityStates["NEW"]             = 1;
        // Funding Stage States
        RecordStates["__IGNORED__"]     = 0;
    }

    function getRecordState(bytes32 name) public view returns (uint8) {
        return RecordStates[name];
    }

    function getEntityState(bytes32 name) public view returns (uint8) {
        return EntityStates[name];
    }

    function runBeforeInitialization() internal requireNotInitialised  {
        EventRunBeforeInit(assetName);
    }

    function applyAndLockSettings()
        public
        onlyDeployer
        requireInitialised
        requireSettingsNotApplied
        returns(bool)
    {
        runBeforeApplyingSettings();
        _settingsApplied = true;
        return true;
    }

    function runBeforeApplyingSettings() internal requireInitialised requireSettingsNotApplied  {
        EventRunBeforeApplyingSettings(assetName);
    }

    function transferToNewOwner(address _newOwner) public requireInitialised onlyOwner returns (bool) {
        require(owner != address(0x0) && _newOwner != address(0x0));
        owner = _newOwner;
        EventAppAssetOwnerSet(assetName, owner);
        return true;
    }

    function getApplicationAssetAddressByName(bytes32 _name)
        public
        view
        returns(address)
    {
        address asset = ApplicationEntityABI(owner).getAssetAddressByName(_name);
        if( asset != address(0x0) ) {
            return asset;
        } else {
            revert();
        }
    }

    function getApplicationState() public view returns (uint8) {
        return ApplicationEntityABI(owner).CurrentEntityState();
    }

    function getApplicationEntityState(bytes32 name) public view returns (uint8) {
        return ApplicationEntityABI(owner).getEntityState(name);
    }

    function getAppBylawUint256(bytes32 name) public view requireInitialised returns (uint256) {
        ApplicationEntityABI CurrentApp = ApplicationEntityABI(owner);
        return CurrentApp.getBylawUint256(name);
    }

    function getAppBylawBytes32(bytes32 name) public view requireInitialised returns (bytes32) {
        ApplicationEntityABI CurrentApp = ApplicationEntityABI(owner);
        return CurrentApp.getBylawBytes32(name);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyApplicationEntity() {
        require(msg.sender == owner);
        _;
    }

    modifier requireInitialised() {
        require(_initialized == true);
        _;
    }

    modifier requireNotInitialised() {
        require(_initialized == false);
        _;
    }

    modifier requireSettingsApplied() {
        require(_settingsApplied == true);
        _;
    }

    modifier requireSettingsNotApplied() {
        require(_settingsApplied == false);
        _;
    }

    modifier onlyDeployer() {
        require(msg.sender == deployerAddress);
        _;
    }

    modifier onlyAsset(bytes32 _name) {
        address AssetAddress = getApplicationAssetAddressByName(_name);
        require( msg.sender == AssetAddress);
        _;
    }

    function getTimestamp() view public returns (uint256) {
        return now;
    }


}

/*

 * source       https://github.com/blockbitsio/

 * @name        Application Asset Contract ABI
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

 Any contract inheriting this will be usable as an Asset in the Application Entity

*/



contract ABIApplicationAsset {

    bytes32 public assetName;
    uint8 public CurrentEntityState;
    uint8 public RecordNum;
    bool public _initialized;
    bool public _settingsApplied;
    address public owner;
    address public deployerAddress;
    mapping (bytes32 => uint8) public EntityStates;
    mapping (bytes32 => uint8) public RecordStates;

    function setInitialApplicationAddress(address _ownerAddress) public;
    function setInitialOwnerAndName(bytes32 _name) external returns (bool);
    function getRecordState(bytes32 name) public view returns (uint8);
    function getEntityState(bytes32 name) public view returns (uint8);
    function applyAndLockSettings() public returns(bool);
    function transferToNewOwner(address _newOwner) public returns (bool);
    function getApplicationAssetAddressByName(bytes32 _name) public returns(address);
    function getApplicationState() public view returns (uint8);
    function getApplicationEntityState(bytes32 name) public view returns (uint8);
    function getAppBylawUint256(bytes32 name) public view returns (uint256);
    function getAppBylawBytes32(bytes32 name) public view returns (bytes32);
    function getTimestamp() view public returns (uint256);


}

/*

 * source       https://github.com/blockbitsio/

 * @name        Token Manager Contract
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

*/





contract ABITokenManager is ABIApplicationAsset {

    address public TokenSCADAEntity;
    address public TokenEntity;
    address public MarketingMethodAddress;
    bool OwnerTokenBalancesReleased = false;

    function addSettings(address _scadaAddress, address _tokenAddress, address _marketing ) public;
    function getTokenSCADARequiresHardCap() public view returns (bool);
    function mint(address _to, uint256 _amount) public returns (bool);
    function finishMinting() public returns (bool);
    function mintForMarketingPool(address _to, uint256 _amount) external returns (bool);
    function ReleaseOwnersLockedTokens(address _multiSigOutputAddress) public returns (bool);

}

/*

 * source       https://github.com/blockbitsio/

 * @name        Proposals Contract
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

 Contains the Proposals Contract code deployed and linked to the Application Entity

*/





contract ABIProposals is ABIApplicationAsset {

    address public Application;
    address public ListingContractEntity;
    address public FundingEntity;
    address public FundingManagerEntity;
    address public TokenManagerEntity;
    address public TokenEntity;
    address public MilestonesEntity;

    struct ProposalRecord {
        address creator;
        bytes32 name;
        uint8 actionType;
        uint8 state;
        bytes32 hash;                       // action name + args hash
        address addr;
        bytes32 sourceCodeUrl;
        uint256 extra;
        uint256 time_start;
        uint256 time_end;
        uint256 index;
    }

    struct VoteStruct {
        address voter;
        uint256 time;
        bool    vote;
        uint256 power;
        bool    annulled;
        uint256 index;
    }

    struct ResultRecord {
        uint256 totalAvailable;
        uint256 requiredForResult;
        uint256 totalSoFar;
        uint256 yes;
        uint256 no;
        bool    requiresCounting;
    }

    uint8 public ActiveProposalNum;
    uint256 public VoteCountPerProcess;
    bool public EmergencyFundingReleaseApproved;

    mapping (bytes32 => uint8) public ActionTypes;
    mapping (uint8 => uint256) public ActiveProposalIds;
    mapping (uint256 => bool) public ExpiredProposalIds;
    mapping (uint256 => ProposalRecord) public ProposalsById;
    mapping (bytes32 => uint256) public ProposalIdByHash;
    mapping (uint256 => mapping (uint256 => VoteStruct) ) public VotesByProposalId;
    mapping (uint256 => mapping (address => VoteStruct) ) public VotesByCaster;
    mapping (uint256 => uint256) public VotesNumByProposalId;
    mapping (uint256 => ResultRecord ) public ResultsByProposalId;
    mapping (uint256 => uint256) public lastProcessedVoteIdByProposal;
    mapping (uint256 => uint256) public ProcessedVotesByProposal;
    mapping (uint256 => uint256) public VoteCountAtProcessingStartByProposal;

    function getRecordState(bytes32 name) public view returns (uint8);
    function getActionType(bytes32 name) public view returns (uint8);
    function getProposalState(uint256 _proposalId) public view returns (uint8);
    function getBylawsProposalVotingDuration() public view returns (uint256);
    function getBylawsMilestoneMinPostponing() public view returns (uint256);
    function getBylawsMilestoneMaxPostponing() public view returns (uint256);
    function getHash(uint8 actionType, bytes32 arg1, bytes32 arg2) public pure returns ( bytes32 );
    function process() public;
    function hasRequiredStateChanges() public view returns (bool);
    function getRequiredStateChanges() public view returns (uint8);
    function addCodeUpgradeProposal(address _addr, bytes32 _sourceCodeUrl) external returns (uint256);
    function createMilestoneAcceptanceProposal() external returns (uint256);
    function createMilestonePostponingProposal(uint256 _duration) external returns (uint256);
    function getCurrentMilestonePostponingProposalDuration() public view returns (uint256);
    function getCurrentMilestoneProposalStatusForType(uint8 _actionType ) public view returns (uint8);
    function createEmergencyFundReleaseProposal() external returns (uint256);
    function createDelistingProposal(uint256 _projectId) external returns (uint256);
    function RegisterVote(uint256 _proposalId, bool _myVote) public;
    function hasPreviousVote(uint256 _proposalId, address _voter) public view returns (bool);
    function getTotalTokenVotingPower(address _voter) public view returns ( uint256 );
    function getVotingPower(uint256 _proposalId, address _voter) public view returns ( uint256 );
    function setVoteCountPerProcess(uint256 _perProcess) external;
    function ProcessVoteTotals(uint256 _proposalId, uint256 length) public;
    function canEndVoting(uint256 _proposalId) public view returns (bool);
    function getProposalType(uint256 _proposalId) public view returns (uint8);
    function expiryChangesState(uint256 _proposalId) public view returns (bool);
    function needsProcessing(uint256 _proposalId) public view returns (bool);
    function getMyVoteForCurrentMilestoneRelease(address _voter) public view returns (bool);
    function getHasVoteForCurrentMilestoneRelease(address _voter) public view returns (bool);
    function getMyVote(uint256 _proposalId, address _voter) public view returns (bool);

}

/*

 * source       https://github.com/blockbitsio/

 * @name        Milestones Contract
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

 Contains the Milestones Contract code deployed and linked to the Application Entity

*/





contract ABIMilestones is ABIApplicationAsset {

    struct Record {
        bytes32 name;
        string description;                     // will change to hash pointer ( external storage )
        uint8 state;
        uint256 duration;
        uint256 time_start;                     // start at unixtimestamp
        uint256 last_state_change_time;         // time of last state change
        uint256 time_end;                       // estimated end time >> can be increased by proposal
        uint256 time_ended;                     // actual end time
        uint256 meeting_time;
        uint8 funding_percentage;
        uint8 index;
    }

    uint8 public currentRecord;
    uint256 public MilestoneCashBackTime = 0;
    mapping (uint8 => Record) public Collection;
    mapping (bytes32 => bool) public MilestonePostponingHash;
    mapping (bytes32 => uint256) public ProposalIdByHash;

    function getBylawsProjectDevelopmentStart() public view returns (uint256);
    function getBylawsMinTimeInTheFutureForMeetingCreation() public view returns (uint256);
    function getBylawsCashBackVoteRejectedDuration() public view returns (uint256);
    function addRecord( bytes32 _name, string _description, uint256 _duration, uint8 _perc ) public;
    function getMilestoneFundingPercentage(uint8 recordId) public view returns (uint8);
    function doStateChanges() public;
    function getRecordStateRequiredChanges() public view returns (uint8);
    function hasRequiredStateChanges() public view returns (bool);
    function afterVoteNoCashBackTime() public view returns ( bool );
    function getHash(uint8 actionType, bytes32 arg1, bytes32 arg2) public pure returns ( bytes32 );
    function getCurrentHash() public view returns ( bytes32 );
    function getCurrentProposalId() internal view returns ( uint256 );
    function setCurrentMilestoneMeetingTime(uint256 _meeting_time) public;
    function isRecordUpdateAllowed(uint8 _new_state ) public view returns (bool);
    function getRequiredStateChanges() public view returns (uint8, uint8, uint8);
    function ApplicationIsInDevelopment() public view returns(bool);
    function MeetingTimeSetFailure() public view returns (bool);

}

/*

 * source       https://github.com/blockbitsio/

 * @name        Funding Contract ABI
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

 Contains the Funding Contract code deployed and linked to the Application Entity


    !!! Links directly to Milestones

*/





contract ABIFunding is ABIApplicationAsset {

    address public multiSigOutputAddress;
    address public DirectInput;
    address public MilestoneInput;
    address public TokenManagerEntity;
    address public FundingManagerEntity;

    struct FundingStage {
        bytes32 name;
        uint8   state;
        uint256 time_start;
        uint256 time_end;
        uint256 amount_cap_soft;            // 0 = not enforced
        uint256 amount_cap_hard;            // 0 = not enforced
        uint256 amount_raised;              // 0 = not enforced
        // funding method settings
        uint256 minimum_entry;
        uint8   methods;                    // FundingMethodIds
        // token settings
        uint256 fixed_tokens;
        uint8   price_addition_percentage;  //
        uint8   token_share_percentage;
        uint8   index;
    }

    mapping (uint8 => FundingStage) public Collection;
    uint8 public FundingStageNum;
    uint8 public currentFundingStage;
    uint256 public AmountRaised;
    uint256 public MilestoneAmountRaised;
    uint256 public GlobalAmountCapSoft;
    uint256 public GlobalAmountCapHard;
    uint8 public TokenSellPercentage;
    uint256 public Funding_Setting_funding_time_start;
    uint256 public Funding_Setting_funding_time_end;
    uint256 public Funding_Setting_cashback_time_start;
    uint256 public Funding_Setting_cashback_time_end;
    uint256 public Funding_Setting_cashback_before_start_wait_duration;
    uint256 public Funding_Setting_cashback_duration;


    function addFundingStage(
        bytes32 _name,
        uint256 _time_start,
        uint256 _time_end,
        uint256 _amount_cap_soft,
        uint256 _amount_cap_hard,   // required > 0
        uint8   _methods,
        uint256 _minimum_entry,
        uint256 _fixed_tokens,
        uint8   _price_addition_percentage,
        uint8   _token_share_percentage
    )
    public;

    function addSettings(address _outputAddress, uint256 soft_cap, uint256 hard_cap, uint8 sale_percentage, address _direct, address _milestone ) public;
    function getStageAmount(uint8 StageId) public view returns ( uint256 );
    function allowedPaymentMethod(uint8 _payment_method) public pure returns (bool);
    function receivePayment(address _sender, uint8 _payment_method) payable public returns(bool);
    function canAcceptPayment(uint256 _amount) public view returns (bool);
    function getValueOverCurrentCap(uint256 _amount) public view returns (uint256);
    function isFundingStageUpdateAllowed(uint8 _new_state ) public view returns (bool);
    function getRecordStateRequiredChanges() public view returns (uint8);
    function doStateChanges() public;
    function hasRequiredStateChanges() public view returns (bool);
    function getRequiredStateChanges() public view returns (uint8, uint8, uint8);

}

/*

 * source       https://github.com/blockbitsio/

 * @name        Token Contract
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

 Zeppelin ERC20 Standard Token

*/



contract ABIToken {

    string public  symbol;
    string public  name;
    uint8 public   decimals;
    uint256 public totalSupply;
    string public  version;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) allowed;
    address public manager;
    address public deployer;
    bool public mintingFinished = false;
    bool public initialized = false;

    function transfer(address _to, uint256 _value) public returns (bool);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function increaseApproval(address _spender, uint _addedValue) public returns (bool success);
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success);
    function mint(address _to, uint256 _amount) public returns (bool);
    function finishMinting() public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 indexed value);
    event Approval(address indexed owner, address indexed spender, uint256 indexed value);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
}

/*

 * source       https://github.com/blockbitsio/

 * @name        Token Stake Calculation And Distribution Algorithm - Type 3 - Sell a variable amount of tokens for a fixed price
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>


    Inputs:

    Defined number of tokens per wei ( X Tokens = 1 wei )
    Received amount of ETH
    Generates:

    Total Supply of tokens available in Funding Phase respectively Project
    Observations:

    Will sell the whole supply of Tokens available to Current Funding Phase
    Use cases:

    Any Funding Phase where you want the first Funding Phase to determine the token supply of the whole Project

*/




contract ABITokenSCADAVariable {
    bool public SCADA_requires_hard_cap = true;
    bool public initialized;
    address public deployerAddress;
    function addSettings(address _fundingContract) public;
    function requiresHardCap() public view returns (bool);
    function getTokensForValueInCurrentStage(uint256 _value) public view returns (uint256);
    function getTokensForValueInStage(uint8 _stage, uint256 _value) public view returns (uint256);
    function getBoughtTokens( address _vaultAddress, bool _direct ) public view returns (uint256);
}

/*

 * source       https://github.com/blockbitsio/

 * @name        Funding Contract ABI
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

 Contains the Funding Contract code deployed and linked to the Application Entity

*/





contract ABIFundingManager is ABIApplicationAsset {

    bool public fundingProcessed;
    bool FundingPoolBalancesAllocated;
    uint8 public VaultCountPerProcess;
    uint256 public lastProcessedVaultId;
    uint256 public vaultNum;
    uint256 public LockedVotingTokens;
    bytes32 public currentTask;
    mapping (bytes32 => bool) public taskByHash;
    mapping  (address => address) public vaultList;
    mapping  (uint256 => address) public vaultById;

    function receivePayment(address _sender, uint8 _payment_method, uint8 _funding_stage) payable public returns(bool);
    function getMyVaultAddress(address _sender) public view returns (address);
    function setVaultCountPerProcess(uint8 _perProcess) external;
    function getHash(bytes32 actionType, bytes32 arg1) public pure returns ( bytes32 );
    function getCurrentMilestoneProcessed() public view returns (bool);
    function processFundingFailedFinished() public view returns (bool);
    function processFundingSuccessfulFinished() public view returns (bool);
    function getCurrentMilestoneIdHash() internal view returns (bytes32);
    function processMilestoneFinished() public view returns (bool);
    function processEmergencyFundReleaseFinished() public view returns (bool);
    function getAfterTransferLockedTokenBalances(address vaultAddress, bool excludeCurrent) public view returns (uint256);
    function VaultRequestedUpdateForLockedVotingTokens(address owner) public;
    function doStateChanges() public;
    function hasRequiredStateChanges() public view returns (bool);
    function getRequiredStateChanges() public view returns (uint8, uint8);
    function ApplicationInFundingOrDevelopment() public view returns(bool);

}

/*

 * source       https://github.com/blockbitsio/

 * @name        Funding Vault
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

    each purchase creates a separate funding vault contract
*/













contract FundingVault {

    /* Asset initialised or not */
    bool public _initialized = false;

    /*
        Addresses:
        vaultOwner - the address of the wallet that stores purchases in this vault ( investor address )
        outputAddress - address where funds go upon successful funding or successful milestone release
        managerAddress - address of the "FundingManager"
    */
    address public vaultOwner ;
    address public outputAddress;
    address public managerAddress;

    /*
        Lock and BlackHole settings
    */

    bool public allFundingProcessed = false;
    bool public DirectFundingProcessed = false;

    /*
        Assets
    */
    // ApplicationEntityABI public ApplicationEntity;
    ABIFunding FundingEntity;
    ABIFundingManager FundingManagerEntity;
    ABIMilestones MilestonesEntity;
    ABIProposals ProposalsEntity;
    ABITokenSCADAVariable TokenSCADAEntity;
    ABIToken TokenEntity ;

    /*
        Globals
    */
    uint256 public amount_direct = 0;
    uint256 public amount_milestone = 0;

    // bylaws
    bool public emergencyFundReleased = false;
    uint8 emergencyFundPercentage = 0;
    uint256 BylawsCashBackOwnerMiaDuration;
    uint256 BylawsCashBackVoteRejectedDuration;
    uint256 BylawsProposalVotingDuration;

    struct PurchaseStruct {
        uint256 unix_time;
        uint8 payment_method;
        uint256 amount;
        uint8 funding_stage;
        uint16 index;
    }

    mapping(uint16 => PurchaseStruct) public purchaseRecords;
    uint16 public purchaseRecordsNum;

    event EventPaymentReceived(uint8 indexed _payment_method, uint256 indexed _amount, uint16 indexed _index );
    event VaultInitialized(address indexed _owner);

    function initialize(
        address _owner,
        address _output,
        address _fundingAddress,
        address _milestoneAddress,
        address _proposalsAddress
    )
        public
        requireNotInitialised
        returns(bool)
    {
        VaultInitialized(_owner);

        outputAddress = _output;
        vaultOwner = _owner;

        // whomever creates this contract is the manager.
        managerAddress = msg.sender;

        // assets
        FundingEntity = ABIFunding(_fundingAddress);
        FundingManagerEntity = ABIFundingManager(managerAddress);
        MilestonesEntity = ABIMilestones(_milestoneAddress);
        ProposalsEntity = ABIProposals(_proposalsAddress);

        address TokenManagerAddress = FundingEntity.getApplicationAssetAddressByName("TokenManager");
        ABITokenManager TokenManagerEntity = ABITokenManager(TokenManagerAddress);

        address TokenAddress = TokenManagerEntity.TokenEntity();
        TokenEntity = ABIToken(TokenAddress);

        address TokenSCADAAddress = TokenManagerEntity.TokenSCADAEntity();
        TokenSCADAEntity = ABITokenSCADAVariable(TokenSCADAAddress);

        // set Emergency Fund Percentage if available.
        address ApplicationEntityAddress = TokenManagerEntity.owner();
        ApplicationEntityABI ApplicationEntity = ApplicationEntityABI(ApplicationEntityAddress);

        // get Application Bylaws
        emergencyFundPercentage             = uint8( ApplicationEntity.getBylawUint256("emergency_fund_percentage") );
        BylawsCashBackOwnerMiaDuration      = ApplicationEntity.getBylawUint256("cashback_owner_mia_dur") ;
        BylawsCashBackVoteRejectedDuration  = ApplicationEntity.getBylawUint256("cashback_investor_no") ;
        BylawsProposalVotingDuration        = ApplicationEntity.getBylawUint256("proposal_voting_duration") ;

        // init
        _initialized = true;
        return true;
    }



    /*
        The funding contract decides if a vault should receive payments or not, since it's the one that creates them,
        no point in creating one if you can't accept payments.
    */

    mapping (uint8 => uint256) public stageAmounts;
    mapping (uint8 => uint256) public stageAmountsDirect;

    function addPayment(
        uint8 _payment_method,
        uint8 _funding_stage
    )
        public
        payable
        requireInitialised
        onlyManager
        returns (bool)
    {
        if(msg.value > 0 && FundingEntity.allowedPaymentMethod(_payment_method)) {

            // store payment
            PurchaseStruct storage purchase = purchaseRecords[++purchaseRecordsNum];
                purchase.unix_time = now;
                purchase.payment_method = _payment_method;
                purchase.amount = msg.value;
                purchase.funding_stage = _funding_stage;
                purchase.index = purchaseRecordsNum;

            // assign payment to direct or milestone
            if(_payment_method == 1) {
                amount_direct+= purchase.amount;
                stageAmountsDirect[_funding_stage]+=purchase.amount;
            }

            if(_payment_method == 2) {
                amount_milestone+= purchase.amount;
            }

            // in order to not iterate through purchase records, we just increase funding stage amount.
            // issue with iterating over them, while processing vaults, would be that someone could create a large
            // number of payments, which would result in an "out of gas" / stack overflow issue, that would lock
            // our contract, so we don't really want to do that.
            // doing it this way also saves some gas
            stageAmounts[_funding_stage]+=purchase.amount;

            EventPaymentReceived( purchase.payment_method, purchase.amount, purchase.index );
            return true;
        } else {
            revert();
        }
    }

    function getBoughtTokens() public view returns (uint256) {
        return TokenSCADAEntity.getBoughtTokens( address(this), false );
    }

    function getDirectBoughtTokens() public view returns (uint256) {
        return TokenSCADAEntity.getBoughtTokens( address(this), true );
    }


    mapping (uint8 => uint256) public etherBalances;
    mapping (uint8 => uint256) public tokenBalances;
    uint8 public BalanceNum = 0;

    bool public BalancesInitialised = false;
    function initMilestoneTokenAndEtherBalances() internal
    {
        if(BalancesInitialised == false) {

            uint256 milestoneTokenBalance = TokenEntity.balanceOf(address(this));
            uint256 milestoneEtherBalance = this.balance;

            // no need to worry about fractions because at the last milestone, we send everything that's left.

            // emergency fund takes it's percentage from initial balances.
            if(emergencyFundPercentage > 0) {
                tokenBalances[0] = milestoneTokenBalance / 100 * emergencyFundPercentage;
                etherBalances[0] = milestoneEtherBalance / 100 * emergencyFundPercentage;

                milestoneTokenBalance-=tokenBalances[0];
                milestoneEtherBalance-=etherBalances[0];
            }

            // milestones percentages are then taken from what's left.
            for(uint8 i = 1; i <= MilestonesEntity.RecordNum(); i++) {

                uint8 perc = MilestonesEntity.getMilestoneFundingPercentage(i);
                tokenBalances[i] = milestoneTokenBalance / 100 * perc;
                etherBalances[i] = milestoneEtherBalance / 100 * perc;
            }

            BalanceNum = i;
            BalancesInitialised = true;
        }
    }

    function ReleaseFundsAndTokens()
        public
        requireInitialised
        onlyManager
        returns (bool)
    {
        // first make sure cashback is not possible, and that we've not processed everything in this vault
        if(!canCashBack() && allFundingProcessed == false) {

            if(FundingManagerEntity.CurrentEntityState() == FundingManagerEntity.getEntityState("FUNDING_SUCCESSFUL_PROGRESS")) {

                // case 1, direct funding only
                if(amount_direct > 0 && amount_milestone == 0) {

                    // if we have direct funding and no milestone balance, transfer everything and lock vault
                    // to save gas in future processing runs.

                    // transfer tokens to the investor
                    TokenEntity.transfer(vaultOwner, TokenEntity.balanceOf( address(this) ) );

                    // transfer ether to the owner's wallet
                    outputAddress.transfer(this.balance);

                    // lock vault.. and enable black hole methods
                    allFundingProcessed = true;

                } else {
                // case 2 and 3, direct funding only

                    if(amount_direct > 0 && DirectFundingProcessed == false ) {
                        TokenEntity.transfer(vaultOwner, getDirectBoughtTokens() );
                        // transfer "direct funding" ether to the owner's wallet
                        outputAddress.transfer(amount_direct);
                        DirectFundingProcessed = true;
                    }

                    // process and initialize milestone balances, emergency fund, etc, once
                    initMilestoneTokenAndEtherBalances();
                }
                return true;

            } else if(FundingManagerEntity.CurrentEntityState() == FundingManagerEntity.getEntityState("MILESTONE_PROCESS_PROGRESS")) {

                // get current milestone so we know which one we need to release funds for.
                uint8 milestoneId = MilestonesEntity.currentRecord();

                uint256 transferTokens = tokenBalances[milestoneId];
                uint256 transferEther = etherBalances[milestoneId];

                if(milestoneId == BalanceNum - 1) {
                    // we're processing the last milestone and balance, this means we're transferring everything left.
                    // this is done to make sure we've transferred everything, even "ether that got mistakenly sent to this address"
                    // as well as the emergency fund if it has not been used.
                    transferTokens = TokenEntity.balanceOf(address(this));
                    transferEther = this.balance;
                }

                // set balances to 0 so we can't transfer multiple times.
                // tokenBalances[milestoneId] = 0;
                // etherBalances[milestoneId] = 0;

                // transfer tokens to the investor
                TokenEntity.transfer(vaultOwner, transferTokens );

                // transfer ether to the owner's wallet
                outputAddress.transfer(transferEther);

                if(milestoneId == BalanceNum - 1) {
                    // lock vault.. and enable black hole methods
                    allFundingProcessed = true;
                }

                return true;
            }
        }

        return false;
    }


    function releaseTokensAndEtherForEmergencyFund()
        public
        requireInitialised
        onlyManager
        returns (bool)
    {
        if( emergencyFundReleased == false && emergencyFundPercentage > 0) {

            // transfer tokens to the investor
            TokenEntity.transfer(vaultOwner, tokenBalances[0] );

            // transfer ether to the owner's wallet
            outputAddress.transfer(etherBalances[0]);

            emergencyFundReleased = true;
            return true;
        }
        return false;
    }

    function ReleaseFundsToInvestor()
        public
        requireInitialised
        isOwner
    {
        if(canCashBack()) {

            // IF we're doing a cashback
            // transfer vault tokens back to owner address
            // send all ether to wallet owner

            // get token balance
            uint256 myBalance = TokenEntity.balanceOf(address(this));
            // transfer all vault tokens to owner
            if(myBalance > 0) {
                TokenEntity.transfer(outputAddress, myBalance );
            }

            // now transfer all remaining ether back to investor address
            vaultOwner.transfer(this.balance);

            // update FundingManager Locked Token Amount, so we don't break voting
            FundingManagerEntity.VaultRequestedUpdateForLockedVotingTokens( vaultOwner );

            // disallow further processing, so we don't break Funding Manager.
            // this method can still be called to collect future black hole ether to this vault.
            allFundingProcessed = true;
        }
    }

    /*
        1 - if the funding of the project Failed, allows investors to claim their locked ether back.
        2 - if the Investor votes NO to a Development Milestone Completion Proposal, where the majority
            also votes NO allows investors to claim their locked ether back.
        3 - project owner misses to set the time for a Development Milestone Completion Meeting allows investors
        to claim their locked ether back.
    */
    function canCashBack() public view requireInitialised returns (bool) {

        // case 1
        if(checkFundingStateFailed()) {
            return true;
        }
        // case 2
        if(checkMilestoneStateInvestorVotedNoVotingEndedNo()) {
            return true;
        }
        // case 3
        if(checkOwnerFailedToSetTimeOnMeeting()) {
            return true;
        }

        return false;
    }

    function checkFundingStateFailed() public view returns (bool) {
        if(FundingEntity.CurrentEntityState() == FundingEntity.getEntityState("FAILED_FINAL") ) {
            return true;
        }

        // also check if funding period ended, and 7 days have passed and no processing was done.
        if( FundingEntity.getTimestamp() >= FundingEntity.Funding_Setting_cashback_time_start() ) {

            // should only be possible if funding entity has been stuck in processing for more than 7 days.
            if( FundingEntity.CurrentEntityState() != FundingEntity.getEntityState("SUCCESSFUL_FINAL") ) {
                return true;
            }
        }

        return false;
    }

    function checkMilestoneStateInvestorVotedNoVotingEndedNo() public view returns (bool) {
        if(MilestonesEntity.CurrentEntityState() == MilestonesEntity.getEntityState("VOTING_ENDED_NO") ) {
            // first we need to make sure we actually voted.
            if( ProposalsEntity.getHasVoteForCurrentMilestoneRelease(vaultOwner) == true) {
                // now make sure we voted NO, and if so return true
                if( ProposalsEntity.getMyVoteForCurrentMilestoneRelease( vaultOwner ) == false) {
                    return true;
                }
            }
        }
        return false;
    }

    function checkOwnerFailedToSetTimeOnMeeting() public view returns (bool) {
        // Looks like the project owner is missing in action
        // they only have to do 1 thing, which is set the meeting time 7 days before the end of the milestone so that
        // investors know when they need to show up for a progress report meeting

        // as they did not, we consider them missing in action and allow investors to retrieve their locked ether back
        if( MilestonesEntity.CurrentEntityState() == MilestonesEntity.getEntityState("DEADLINE_MEETING_TIME_FAILED") ) {
            return true;
        }
        return false;
    }


    modifier isOwner() {
        require(msg.sender == vaultOwner);
        _;
    }

    modifier onlyManager() {
        require(msg.sender == managerAddress);
        _;
    }

    modifier requireInitialised() {
        require(_initialized == true);
        _;
    }

    modifier requireNotInitialised() {
        require(_initialized == false);
        _;
    }
}

/*

 * source       https://github.com/blockbitsio/

 * @name        Funding Contract
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

 Contains the Funding Contract code deployed and linked to the Application Entity

*/















contract FundingManager is ApplicationAsset {

    ABIFunding FundingEntity;
    ABITokenManager TokenManagerEntity;
    ABIToken TokenEntity;
    ABITokenSCADAVariable TokenSCADAEntity;
    ABIProposals ProposalsEntity;
    ABIMilestones MilestonesEntity;

    uint256 public LockedVotingTokens = 0;

    event EventFundingManagerReceivedPayment(address indexed _vault, uint8 indexed _payment_method, uint256 indexed _amount );
    event EventFundingManagerProcessedVault(address _vault, uint256 id );

    mapping  (address => address) public vaultList;
    mapping  (uint256 => address) public vaultById;
    uint256 public vaultNum = 0;

    function setAssetStates() internal {
        // Asset States
        EntityStates["__IGNORED__"]                 = 0;
        EntityStates["NEW"]                         = 1;
        EntityStates["WAITING"]                     = 2;

        EntityStates["FUNDING_FAILED_START"]        = 10;
        EntityStates["FUNDING_FAILED_PROGRESS"]     = 11;
        EntityStates["FUNDING_FAILED_DONE"]         = 12;

        EntityStates["FUNDING_SUCCESSFUL_START"]    = 20;
        EntityStates["FUNDING_SUCCESSFUL_PROGRESS"] = 21;
        EntityStates["FUNDING_SUCCESSFUL_DONE"]     = 22;
        EntityStates["FUNDING_SUCCESSFUL_ALLOCATE"] = 25;


        EntityStates["MILESTONE_PROCESS_START"]     = 30;
        EntityStates["MILESTONE_PROCESS_PROGRESS"]  = 31;
        EntityStates["MILESTONE_PROCESS_DONE"]      = 32;

        EntityStates["EMERGENCY_PROCESS_START"]     = 40;
        EntityStates["EMERGENCY_PROCESS_PROGRESS"]  = 41;
        EntityStates["EMERGENCY_PROCESS_DONE"]      = 42;


        EntityStates["COMPLETE_PROCESS_START"]     = 100;
        EntityStates["COMPLETE_PROCESS_PROGRESS"]  = 101;
        EntityStates["COMPLETE_PROCESS_DONE"]      = 102;

        // Funding Stage States
        RecordStates["__IGNORED__"]     = 0;

    }

    function runBeforeApplyingSettings()
        internal
        requireInitialised
        requireSettingsNotApplied
    {
        address FundingAddress = getApplicationAssetAddressByName('Funding');
        FundingEntity = ABIFunding(FundingAddress);
        EventRunBeforeApplyingSettings(assetName);

        address TokenManagerAddress = getApplicationAssetAddressByName('TokenManager');
        TokenManagerEntity = ABITokenManager(TokenManagerAddress);

        TokenEntity = ABIToken(TokenManagerEntity.TokenEntity());

        address TokenSCADAAddress = TokenManagerEntity.TokenSCADAEntity();
        TokenSCADAEntity = ABITokenSCADAVariable(TokenSCADAAddress) ;

        address MilestonesAddress = getApplicationAssetAddressByName('Milestones');
        MilestonesEntity = ABIMilestones(MilestonesAddress) ;

        address ProposalsAddress = getApplicationAssetAddressByName('Proposals');
        ProposalsEntity = ABIProposals(ProposalsAddress) ;
    }



    function receivePayment(address _sender, uint8 _payment_method, uint8 _funding_stage)
        payable
        public
        requireInitialised
        onlyAsset('Funding')
        returns(bool)
    {
        // check that msg.value is higher than 0, don't really want to have to deal with minus in case the network breaks this somehow
        if(msg.value > 0) {
            FundingVault vault;

            // no vault present
            if(!hasVault(_sender)) {
                // create and initialize a new one
                vault = new FundingVault();
                if(vault.initialize(
                    _sender,
                    FundingEntity.multiSigOutputAddress(),
                    address(FundingEntity),
                    address(getApplicationAssetAddressByName('Milestones')),
                    address(getApplicationAssetAddressByName('Proposals'))
                )) {
                    // store new vault address.
                    vaultList[_sender] = vault;
                    // increase internal vault number
                    vaultNum++;
                    // assign vault to by int registry
                    vaultById[vaultNum] = vault;

                } else {
                    revert();
                }
            } else {
                // use existing vault
                vault = FundingVault(vaultList[_sender]);
            }

            EventFundingManagerReceivedPayment(vault, _payment_method, msg.value);

            if( vault.addPayment.value(msg.value)( _payment_method, _funding_stage ) ) {

                // if payment is received in the vault then mint tokens based on the received value!
                TokenManagerEntity.mint( vault, TokenSCADAEntity.getTokensForValueInCurrentStage(msg.value) );

                return true;
            } else {
                revert();
            }
        } else {
            revert();
        }
    }

    function getMyVaultAddress(address _sender) public view returns (address) {
        return vaultList[_sender];
    }

    function hasVault(address _sender) internal view returns(bool) {
        if(vaultList[_sender] != address(0x0)) {
            return true;
        } else {
            return false;
        }
    }

    bool public fundingProcessed = false;
    uint256 public lastProcessedVaultId = 0;
    uint8 public VaultCountPerProcess = 10;
    bytes32 public currentTask = "";

    mapping (bytes32 => bool) public taskByHash;

    function setVaultCountPerProcess(uint8 _perProcess) external onlyDeployer {
        if(_perProcess > 0) {
            VaultCountPerProcess = _perProcess;
        } else {
            revert();
        }
    }

    function getHash(bytes32 actionType, bytes32 arg1) public pure returns ( bytes32 ) {
        return keccak256(actionType, arg1);
    }

    function getCurrentMilestoneProcessed() public view returns (bool) {
        return taskByHash[ getHash("MILESTONE_PROCESS_START", getCurrentMilestoneIdHash() ) ];
    }



    function ProcessVaultList(uint8 length) internal {

        if(taskByHash[currentTask] == false) {
            if(
                CurrentEntityState == getEntityState("FUNDING_FAILED_PROGRESS") ||
                CurrentEntityState == getEntityState("FUNDING_SUCCESSFUL_PROGRESS") ||
                CurrentEntityState == getEntityState("MILESTONE_PROCESS_PROGRESS") ||
                CurrentEntityState == getEntityState("EMERGENCY_PROCESS_PROGRESS") ||
                CurrentEntityState == getEntityState("COMPLETE_PROCESS_PROGRESS")
            ) {

                uint256 start = lastProcessedVaultId + 1;
                uint256 end = start + length - 1;

                if(end > vaultNum) {
                    end = vaultNum;
                }

                // first run
                if(start == 1) {
                    // reset LockedVotingTokens, as we reindex them
                    LockedVotingTokens = 0;
                }

                for(uint256 i = start; i <= end; i++) {
                    address currentVault = vaultById[i];
                    EventFundingManagerProcessedVault(currentVault, i);
                    ProcessFundingVault(currentVault);
                    lastProcessedVaultId++;
                }
                if(lastProcessedVaultId >= vaultNum ) {
                    // reset iterator and set task state to true so we can't call it again.
                    lastProcessedVaultId = 0;
                    taskByHash[currentTask] = true;
                }
            } else {
                revert();
            }
        } else {
            revert();
        }
    }

    function processFundingFailedFinished() public view returns (bool) {
        bytes32 thisHash = getHash("FUNDING_FAILED_START", "");
        return taskByHash[thisHash];
    }

    function processFundingSuccessfulFinished() public view returns (bool) {
        bytes32 thisHash = getHash("FUNDING_SUCCESSFUL_START", "");
        return taskByHash[thisHash];
    }

    function getCurrentMilestoneIdHash() internal view returns (bytes32) {
        return bytes32(MilestonesEntity.currentRecord());
    }

    function processMilestoneFinished() public view returns (bool) {
        bytes32 thisHash = getHash("MILESTONE_PROCESS_START", getCurrentMilestoneIdHash());
        return taskByHash[thisHash];
    }

    function processEmergencyFundReleaseFinished() public view returns (bool) {
        bytes32 thisHash = getHash("EMERGENCY_PROCESS_START", bytes32(0));
        return taskByHash[thisHash];
    }

    function ProcessFundingVault(address vaultAddress ) internal {
        FundingVault vault = FundingVault(vaultAddress);

        if(vault.allFundingProcessed() == false) {

            if(CurrentEntityState == getEntityState("FUNDING_SUCCESSFUL_PROGRESS")) {

                // tokens are minted and allocated to this vault when it receives payments.
                // vault should now hold as many tokens as the investor bought using direct and milestone funding,
                // as well as the ether they sent
                // "direct funding" release -> funds to owner / tokens to investor
                if(!vault.ReleaseFundsAndTokens()) {
                    revert();
                }

            } else if(CurrentEntityState == getEntityState("MILESTONE_PROCESS_PROGRESS")) {
                // release funds to owner / tokens to investor
                if(!vault.ReleaseFundsAndTokens()) {
                    revert();
                }

            } else if(CurrentEntityState == getEntityState("EMERGENCY_PROCESS_PROGRESS")) {
                // release emergency funds to owner / tokens to investor
                if(!vault.releaseTokensAndEtherForEmergencyFund()) {
                    revert();
                }
            }

            // For proposal voting, we need to know how many investor locked tokens remain.
            LockedVotingTokens+= getAfterTransferLockedTokenBalances(vaultAddress, true);

        }
    }

    function getAfterTransferLockedTokenBalances(address vaultAddress, bool excludeCurrent) public view returns (uint256) {
        FundingVault vault = FundingVault(vaultAddress);
        uint8 currentMilestone = MilestonesEntity.currentRecord();

        uint256 LockedBalance = 0;
        // handle emergency funding first
        if(vault.emergencyFundReleased() == false) {
            LockedBalance+=vault.tokenBalances(0);
        }

        // get token balances starting from current
        uint8 start = currentMilestone;

        if(CurrentEntityState != getEntityState("FUNDING_SUCCESSFUL_PROGRESS")) {
            if(excludeCurrent == true) {
                start++;
            }
        }

        for(uint8 i = start; i < vault.BalanceNum() ; i++) {
            LockedBalance+=vault.tokenBalances(i);
        }
        return LockedBalance;

    }

    function VaultRequestedUpdateForLockedVotingTokens(address owner) public {
        // validate sender
        address vaultAddress = vaultList[owner];
        if(msg.sender == vaultAddress){
            // get token balances starting from current
            LockedVotingTokens-= getAfterTransferLockedTokenBalances(vaultAddress, false);
        }
    }

    bool FundingPoolBalancesAllocated = false;

    function AllocateAfterFundingBalances() internal {
        // allocate owner, advisor, bounty pools
        if(FundingPoolBalancesAllocated == false) {

            // mint em!
            uint256 mintedSupply = TokenEntity.totalSupply();
            uint256 salePercent = getAppBylawUint256("token_sale_percentage");

            // find one percent
            uint256 onePercent = (mintedSupply * 1 / salePercent * 100) / 100;

            // bounty tokens
            uint256 bountyPercent = getAppBylawUint256("token_bounty_percentage");
            uint256 bountyValue = onePercent * bountyPercent;

            address BountyManagerAddress = getApplicationAssetAddressByName("BountyManager");
            TokenManagerEntity.mint( BountyManagerAddress, bountyValue );

            // project tokens
            // should be 40
            uint256 projectPercent = 100 - salePercent - bountyPercent;
            uint256 projectValue = onePercent * projectPercent;

            // project tokens get minted to Token Manager's address, and are locked there
            TokenManagerEntity.mint( TokenManagerEntity, projectValue );
            TokenManagerEntity.finishMinting();

            FundingPoolBalancesAllocated = true;
        }
    }


    function doStateChanges() public {

        var (returnedCurrentEntityState, EntityStateRequired) = getRequiredStateChanges();
        bool callAgain = false;

        DebugEntityRequiredChanges( assetName, returnedCurrentEntityState, EntityStateRequired );

        if(EntityStateRequired != getEntityState("__IGNORED__") ) {
            EntityProcessor(EntityStateRequired);
            callAgain = true;
        }
    }

    function hasRequiredStateChanges() public view returns (bool) {
        bool hasChanges = false;
        var (returnedCurrentEntityState, EntityStateRequired) = getRequiredStateChanges();
        // suppress unused local variable warning
        returnedCurrentEntityState = 0;
        if(EntityStateRequired != getEntityState("__IGNORED__") ) {
            hasChanges = true;
        }
        return hasChanges;
    }

    function EntityProcessor(uint8 EntityStateRequired) internal {

        EventEntityProcessor( assetName, CurrentEntityState, EntityStateRequired );

        // Update our Entity State
        CurrentEntityState = EntityStateRequired;
        // Do State Specific Updates

// Funding Failed
        if ( EntityStateRequired == getEntityState("FUNDING_FAILED_START") ) {
            // set ProcessVaultList Task
            currentTask = getHash("FUNDING_FAILED_START", "");
            CurrentEntityState = getEntityState("FUNDING_FAILED_PROGRESS");
        } else if ( EntityStateRequired == getEntityState("FUNDING_FAILED_PROGRESS") ) {
            ProcessVaultList(VaultCountPerProcess);

// Funding Successful
        } else if ( EntityStateRequired == getEntityState("FUNDING_SUCCESSFUL_START") ) {

            // init SCADA variable cache.
            //if(TokenSCADAEntity.initCacheForVariables()) {

            // start processing vaults
            currentTask = getHash("FUNDING_SUCCESSFUL_START", "");
            CurrentEntityState = getEntityState("FUNDING_SUCCESSFUL_PROGRESS");

        } else if ( EntityStateRequired == getEntityState("FUNDING_SUCCESSFUL_PROGRESS") ) {
            ProcessVaultList(VaultCountPerProcess);

        } else if ( EntityStateRequired == getEntityState("FUNDING_SUCCESSFUL_ALLOCATE") ) {
            AllocateAfterFundingBalances();

// Milestones
        } else if ( EntityStateRequired == getEntityState("MILESTONE_PROCESS_START") ) {
            currentTask = getHash("MILESTONE_PROCESS_START", getCurrentMilestoneIdHash() );
            CurrentEntityState = getEntityState("MILESTONE_PROCESS_PROGRESS");

        } else if ( EntityStateRequired == getEntityState("MILESTONE_PROCESS_PROGRESS") ) {
            ProcessVaultList(VaultCountPerProcess);

// Emergency funding release
        } else if ( EntityStateRequired == getEntityState("EMERGENCY_PROCESS_START") ) {
            currentTask = getHash("EMERGENCY_PROCESS_START", bytes32(0) );
            CurrentEntityState = getEntityState("EMERGENCY_PROCESS_PROGRESS");
        } else if ( EntityStateRequired == getEntityState("EMERGENCY_PROCESS_PROGRESS") ) {
            ProcessVaultList(VaultCountPerProcess);

// Completion
        } else if ( EntityStateRequired == getEntityState("COMPLETE_PROCESS_START") ) {
            currentTask = getHash("COMPLETE_PROCESS_START", "");
            CurrentEntityState = getEntityState("COMPLETE_PROCESS_PROGRESS");

        } else if ( EntityStateRequired == getEntityState("COMPLETE_PROCESS_PROGRESS") ) {
            // release platform owner tokens from token manager
            TokenManagerEntity.ReleaseOwnersLockedTokens( FundingEntity.multiSigOutputAddress() );
            CurrentEntityState = getEntityState("COMPLETE_PROCESS_DONE");
        }

    }

    /*
     * Method: Get Entity Required State Changes
     *
     * @access       public
     * @type         method
     *
     * @return       ( uint8 CurrentEntityState, uint8 EntityStateRequired )
     */
    function getRequiredStateChanges() public view returns (uint8, uint8) {

        uint8 EntityStateRequired = getEntityState("__IGNORED__");

        if(ApplicationInFundingOrDevelopment()) {

            if ( CurrentEntityState == getEntityState("WAITING") ) {
                /*
                    This is where we decide if we should process something
                */

                // For funding
                if(FundingEntity.CurrentEntityState() == FundingEntity.getEntityState("FAILED")) {
                    EntityStateRequired = getEntityState("FUNDING_FAILED_START");
                }
                else if(FundingEntity.CurrentEntityState() == FundingEntity.getEntityState("SUCCESSFUL")) {
                    // make sure we haven't processed this yet
                    if(taskByHash[ getHash("FUNDING_SUCCESSFUL_START", "") ] == false) {
                        EntityStateRequired = getEntityState("FUNDING_SUCCESSFUL_START");
                    }
                }
                else if(FundingEntity.CurrentEntityState() == FundingEntity.getEntityState("SUCCESSFUL_FINAL")) {

                    if ( processMilestoneFinished() == false) {
                        if(
                            MilestonesEntity.CurrentEntityState() == MilestonesEntity.getEntityState("VOTING_ENDED_YES") ||
                            MilestonesEntity.CurrentEntityState() == MilestonesEntity.getEntityState("VOTING_ENDED_NO_FINAL")
                        ) {
                            EntityStateRequired = getEntityState("MILESTONE_PROCESS_START");
                        }
                    }

                    if(processEmergencyFundReleaseFinished() == false) {
                        if(ProposalsEntity.EmergencyFundingReleaseApproved() == true) {
                            EntityStateRequired = getEntityState("EMERGENCY_PROCESS_START");
                        }
                    }

                    // else, check if all milestones have been processed and try finalising development process
                    // EntityStateRequired = getEntityState("COMPLETE_PROCESS_START");


                }

            } else if ( CurrentEntityState == getEntityState("FUNDING_SUCCESSFUL_PROGRESS") ) {
                // still in progress? check if we should move to done
                if ( processFundingSuccessfulFinished() ) {
                    EntityStateRequired = getEntityState("FUNDING_SUCCESSFUL_ALLOCATE");
                } else {
                    EntityStateRequired = getEntityState("FUNDING_SUCCESSFUL_PROGRESS");
                }

            } else if ( CurrentEntityState == getEntityState("FUNDING_SUCCESSFUL_ALLOCATE") ) {

                if(FundingPoolBalancesAllocated) {
                    EntityStateRequired = getEntityState("FUNDING_SUCCESSFUL_DONE");
                }

            } else if ( CurrentEntityState == getEntityState("FUNDING_SUCCESSFUL_DONE") ) {
                EntityStateRequired = getEntityState("WAITING");

    // Funding Failed
            } else if ( CurrentEntityState == getEntityState("FUNDING_FAILED_PROGRESS") ) {
                // still in progress? check if we should move to done
                if ( processFundingFailedFinished() ) {
                    EntityStateRequired = getEntityState("FUNDING_FAILED_DONE");
                } else {
                    EntityStateRequired = getEntityState("FUNDING_FAILED_PROGRESS");
                }

    // Milestone process
            } else if ( CurrentEntityState == getEntityState("MILESTONE_PROCESS_PROGRESS") ) {
                // still in progress? check if we should move to done

                if ( processMilestoneFinished() ) {
                    EntityStateRequired = getEntityState("MILESTONE_PROCESS_DONE");
                } else {
                    EntityStateRequired = getEntityState("MILESTONE_PROCESS_PROGRESS");
                }

            } else if ( CurrentEntityState == getEntityState("MILESTONE_PROCESS_DONE") ) {

                if(processMilestoneFinished() == false) {
                    EntityStateRequired = getEntityState("WAITING");

                } else if(MilestonesEntity.currentRecord() == MilestonesEntity.RecordNum()) {
                    EntityStateRequired = getEntityState("COMPLETE_PROCESS_START");
                }

    // Emergency funding release
            } else if ( CurrentEntityState == getEntityState("EMERGENCY_PROCESS_PROGRESS") ) {
                // still in progress? check if we should move to done

                if ( processEmergencyFundReleaseFinished() ) {
                    EntityStateRequired = getEntityState("EMERGENCY_PROCESS_DONE");
                } else {
                    EntityStateRequired = getEntityState("EMERGENCY_PROCESS_PROGRESS");
                }
            } else if ( CurrentEntityState == getEntityState("EMERGENCY_PROCESS_DONE") ) {
                EntityStateRequired = getEntityState("WAITING");

    // Completion
            } else if ( CurrentEntityState == getEntityState("COMPLETE_PROCESS_PROGRESS") ) {
                EntityStateRequired = getEntityState("COMPLETE_PROCESS_PROGRESS");
            }
        } else {

            if( CurrentEntityState == getEntityState("NEW") ) {
                // general so we know we initialized
                EntityStateRequired = getEntityState("WAITING");
            }
        }

        return (CurrentEntityState, EntityStateRequired);
    }

    function ApplicationInFundingOrDevelopment() public view returns(bool) {
        uint8 AppState = getApplicationState();
        if(
            AppState == getApplicationEntityState("IN_FUNDING") ||
            AppState == getApplicationEntityState("IN_DEVELOPMENT")
        ) {
            return true;
        }
        return false;
    }



}