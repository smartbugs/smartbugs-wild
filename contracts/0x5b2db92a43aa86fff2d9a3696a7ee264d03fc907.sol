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

 * @name        Listing Contract ABI
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

*/





contract ABIListingContract is ABIApplicationAsset {

    address public managerAddress;
    // child items
    struct item {
        bytes32 name;
        address itemAddress;
        bool    status;
        uint256 index;
    }

    mapping ( uint256 => item ) public items;
    uint256 public itemNum;

    function setManagerAddress(address _manager) public;
    function addItem(bytes32 _name, address _address) public;
    function getNewsContractAddress(uint256 _childId) external view returns (address);
    function canBeDelisted(uint256 _childId) public view returns (bool);
    function getChildStatus( uint256 _childId ) public view returns (bool);
    function delistChild( uint256 _childId ) public;

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

 * @name        Proposals Contract
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

 Contains the Proposals Contract code deployed and linked to the Application Entity

*/














contract Proposals is ApplicationAsset {

    ApplicationEntityABI public Application;
    ABIListingContract public ListingContractEntity;
    ABIFunding public FundingEntity;
    ABIFundingManager public FundingManagerEntity;
    ABITokenManager public TokenManagerEntity;
    ABIToken public TokenEntity;
    ABIMilestones public MilestonesEntity;

    function getRecordState(bytes32 name) public view returns (uint8) {
        return RecordStates[name];
    }

    function getActionType(bytes32 name) public view returns (uint8) {
        return ActionTypes[name];
    }

    function getProposalState(uint256 _proposalId) public view returns (uint8) {
        return ProposalsById[_proposalId].state;
    }

    mapping (bytes32 => uint8) public ActionTypes;

    function setActionTypes() internal {
        // owner initiated
        ActionTypes["MILESTONE_DEADLINE"] = 1;
        ActionTypes["MILESTONE_POSTPONING"] = 2;
        ActionTypes["EMERGENCY_FUND_RELEASE"] = 60;
        ActionTypes["IN_DEVELOPMENT_CODE_UPGRADE"] = 50;

        // shareholder initiated
        ActionTypes["AFTER_COMPLETE_CODE_UPGRADE"] = 51;
        ActionTypes["PROJECT_DELISTING"] = 75;
    }


    function setAssetStates() internal {

        setActionTypes();

        RecordStates["NEW"]                 = 1;
        RecordStates["ACCEPTING_VOTES"]     = 2;
        RecordStates["VOTING_ENDED"]        = 3;
        RecordStates["VOTING_RESULT_YES"]   = 10;
        RecordStates["VOTING_RESULT_NO"]    = 20;
    }

    event EventNewProposalCreated ( bytes32 indexed _hash, uint256 indexed _proposalId );

    function runBeforeApplyingSettings()
        internal
        requireInitialised
        requireSettingsNotApplied
    {
        address FundingAddress = getApplicationAssetAddressByName('Funding');
        FundingEntity = ABIFunding(FundingAddress);

        address FundingManagerAddress = getApplicationAssetAddressByName('FundingManager');
        FundingManagerEntity = ABIFundingManager(FundingManagerAddress);

        address TokenManagerAddress = getApplicationAssetAddressByName('TokenManager');
        TokenManagerEntity = ABITokenManager(TokenManagerAddress);
        TokenEntity = ABIToken(TokenManagerEntity.TokenEntity());

        address ListingContractAddress = getApplicationAssetAddressByName('ListingContract');
        ListingContractEntity = ABIListingContract(ListingContractAddress);

        address MilestonesContractAddress = getApplicationAssetAddressByName('Milestones');
        MilestonesEntity = ABIMilestones(MilestonesContractAddress);

        EventRunBeforeApplyingSettings(assetName);
    }

    function getBylawsProposalVotingDuration() public view returns (uint256) {
        return getAppBylawUint256("proposal_voting_duration");
    }

    function getBylawsMilestoneMinPostponing() public view returns (uint256) {
        return getAppBylawUint256("min_postponing");
    }

    function getBylawsMilestoneMaxPostponing() public view returns (uint256) {
        return getAppBylawUint256("max_postponing");
    }

    function getHash(uint8 actionType, bytes32 arg1, bytes32 arg2) public pure returns ( bytes32 ) {
        return keccak256(actionType, arg1, arg2);
    }


    // need to implement a way to just iterate through active proposals, and remove the ones we already processed
    // otherwise someone with malicious intent could add a ton of proposals, just to make our contract cost a ton of gas.

    // to that end, we allow individual proposal processing. so that we don't get affected by people with too much
    // money and time on their hands.

    // whenever the system created a proposal, it will store the id, and process it when required.

    // not that much of an issue at this stage because:
    // NOW:
    // - only the system can create - MILESTONE_DEADLINE
    // - only the deployer can create - MILESTONE_POSTPONING / EMERGENCY_FUND_RELEASE / IN_DEVELOPMENT_CODE_UPGRADE

    // FUTURE:
    // - PROJECT_DELISTING is tied into an existing "listing id" which will be created by the system ( if requested by
    // someone, but at quite a significant cost )
    // - AFTER_COMPLETE_CODE_UPGRADE

    mapping (uint8 => uint256) public ActiveProposalIds;
    uint8 public ActiveProposalNum = 0;

    mapping (uint256 => bool) public ExpiredProposalIds;

    function process() public onlyApplicationEntity {
        for(uint8 i = 0; i < ActiveProposalNum; i++) {

            if(
                getProposalType(ActiveProposalIds[i]) == getActionType("PROJECT_DELISTING") ||
                getProposalType(ActiveProposalIds[i]) == getActionType("AFTER_COMPLETE_CODE_UPGRADE")
            ) {
                ProcessVoteTotals( ActiveProposalIds[i], VoteCountPerProcess );
            } else {
                // try expiry ending
                tryEndVoting(ActiveProposalIds[i]);
            }

        }
    }

    function hasRequiredStateChanges() public view returns (bool) {
        for(uint8 i = 0; i < ActiveProposalNum; i++) {
            if( needsProcessing( ActiveProposalIds[i] ) ) {
                return true;
            }
        }
        return false;
    }

    function getRequiredStateChanges() public view returns (uint8) {
        if(hasRequiredStateChanges()) {
            return ActiveProposalNum;
        }
        return 0;
    }

    function addCodeUpgradeProposal(address _addr, bytes32 _sourceCodeUrl)
        external
        onlyApplicationEntity   // shareholder check is done directly in Gateway by calling applicationEntity to confirm
        returns (uint256)
    {

        // hash enforces only 1 possible voting of this type per record.
        // basically if a vote failed, you need to deploy it with changes to a new address. that simple.

        // depending on the application overall state, we have 2 different voting implementations.

        uint8 thisAction;

        if(getApplicationState() == getApplicationEntityState("IN_DEVELOPMENT") ) {
            thisAction = getActionType("IN_DEVELOPMENT_CODE_UPGRADE");

        } else if(getApplicationState() == getApplicationEntityState("DEVELOPMENT_COMPLETE") ) {
            thisAction = getActionType("AFTER_COMPLETE_CODE_UPGRADE");
        }

        return createProposal(
            msg.sender,
            "CODE_UPGRADE",
            getHash( thisAction, bytes32(_addr), 0 ),
            thisAction,
            _addr,
            _sourceCodeUrl,
            0
        );
    }


    function createMilestoneAcceptanceProposal()
        external
        onlyAsset("Milestones")
        returns (uint256)
    {

        uint8 recordId = MilestonesEntity.currentRecord();
        return createProposal(
            msg.sender,
            "MILESTONE_DEADLINE",
            getHash( getActionType("MILESTONE_DEADLINE"), bytes32( recordId ), 0 ),
            getActionType("MILESTONE_DEADLINE"),
            0,
            0,
            uint256(recordId)
        );
    }

    function createMilestonePostponingProposal(uint256 _duration)
        external
        onlyDeployer
        returns (uint256)
    {
        if(_duration >= getBylawsMilestoneMinPostponing() && _duration <= getBylawsMilestoneMaxPostponing() ) {

            uint8 recordId = MilestonesEntity.currentRecord();
            return createProposal(
                msg.sender,
                "MILESTONE_POSTPONING",
                getHash( getActionType("MILESTONE_POSTPONING"), bytes32( recordId ), 0 ),
                getActionType("MILESTONE_POSTPONING"),
                0,
                0,
                _duration
            );
        } else {
            revert();
        }
    }

    function getCurrentMilestonePostponingProposalDuration() public view returns (uint256) {
        uint8 recordId = MilestonesEntity.currentRecord();
        bytes32 hash = getHash( getActionType("MILESTONE_POSTPONING"), bytes32( recordId ), 0 );
        ProposalRecord memory proposal = ProposalsById[ ProposalIdByHash[hash] ];
        return proposal.extra;
    }

    function getCurrentMilestoneProposalStatusForType(uint8 _actionType ) public view returns (uint8) {

        if(_actionType == getActionType("MILESTONE_DEADLINE") || _actionType == getActionType("MILESTONE_POSTPONING")) {
            uint8 recordId = MilestonesEntity.currentRecord();
            bytes32 hash = getHash( _actionType, bytes32( recordId ), 0 );
            uint256 ProposalId = ProposalIdByHash[hash];
            ProposalRecord memory proposal = ProposalsById[ProposalId];
            return proposal.state;
        }
        return 0;
    }

    function createEmergencyFundReleaseProposal()
        external
        onlyDeployer
        returns (uint256)
    {
        return createProposal(
            msg.sender,
            "EMERGENCY_FUND_RELEASE",
            getHash( getActionType("EMERGENCY_FUND_RELEASE"), 0, 0 ),
            getActionType("EMERGENCY_FUND_RELEASE"),
            0,
            0,
            0
        );
    }

    function createDelistingProposal(uint256 _projectId)
        external
        onlyTokenHolder
        returns (uint256)
    {
        // let's validate the project is actually listed first in order to remove any spamming ability.
        if( ListingContractEntity.canBeDelisted(_projectId) == true) {

            return createProposal(
                msg.sender,
                "PROJECT_DELISTING",
                getHash( getActionType("PROJECT_DELISTING"), bytes32(_projectId), 0 ),
                getActionType("PROJECT_DELISTING"),
                0,
                0,
                _projectId
            );
        } else {
            revert();
        }
    }

    modifier onlyTokenHolder() {
        require( getTotalTokenVotingPower(msg.sender) > 0 );
        _;
    }

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

    mapping (uint256 => ProposalRecord) public ProposalsById;
    mapping (bytes32 => uint256) public ProposalIdByHash;

    function createProposal(
        address _creator,
        bytes32 _name,
        bytes32 _hash,
        uint8   _action,
        address _addr,
        bytes32 _sourceCodeUrl,
        uint256 _extra
    )
        internal
        returns (uint256)
    {

        // if(_action > 0) {

        if(ProposalIdByHash[_hash] == 0) {

            ProposalRecord storage proposal = ProposalsById[++RecordNum];
            proposal.creator        = _creator;
            proposal.name           = _name;
            proposal.actionType     = _action;
            proposal.addr           = _addr;
            proposal.sourceCodeUrl  = _sourceCodeUrl;
            proposal.extra          = _extra;
            proposal.hash           = _hash;
            proposal.state          = getRecordState("NEW");
            proposal.time_start     = getTimestamp();
            proposal.time_end       = getTimestamp() + getBylawsProposalVotingDuration();
            proposal.index          = RecordNum;

            ProposalIdByHash[_hash] = RecordNum;

        } else {
            // already exists!
            revert();
        }

        initProposalVoting(RecordNum);
        EventNewProposalCreated ( _hash, RecordNum );
        return RecordNum;

        /*
        } else {
            // no action?!
            revert();
        }
        */
    }

    function acceptCodeUpgrade(uint256 _proposalId) internal {
        ProposalRecord storage proposal = ProposalsById[_proposalId];
        // reinitialize this each time, because we rely on "owner" as the address, and it will change
        Application = ApplicationEntityABI(owner);
        Application.acceptCodeUpgradeProposal(proposal.addr);
    }


    function initProposalVoting(uint256 _proposalId) internal {

        ResultRecord storage result = ResultsByProposalId[_proposalId];
        ProposalRecord storage proposal = ProposalsById[_proposalId];

        if(getApplicationState() == getApplicationEntityState("IN_DEVELOPMENT") ) {

            if(proposal.actionType == getActionType("PROJECT_DELISTING") ) {
                // while in development project delisting can be voted by all available tokens, except owner
                uint256 ownerLockedTokens = TokenEntity.balanceOf(TokenManagerEntity);
                result.totalAvailable = TokenEntity.totalSupply() - ownerLockedTokens;

                // since we're counting unlocked tokens, we need to recount votes each time we want to end the voting period
                result.requiresCounting = true;

            } else {
                // any other proposal is only voted by "locked ether", thus we use locked tokens
                result.totalAvailable = FundingManagerEntity.LockedVotingTokens();

                // locked tokens do not require recounting.
                result.requiresCounting = false;
            }

        } else if(getApplicationState() == getApplicationEntityState("DEVELOPMENT_COMPLETE") ) {
            // remove residual token balance from TokenManagerEntity.
            uint256 residualLockedTokens = TokenEntity.balanceOf(TokenManagerEntity);
            result.totalAvailable = TokenEntity.totalSupply() - residualLockedTokens;

            // since we're counting unlocked tokens, we need to recount votes each time we want to end the voting period
            result.requiresCounting = true;
        }
        result.requiredForResult = result.totalAvailable / 2;   // 50%

        proposal.state = getRecordState("ACCEPTING_VOTES");
        addActiveProposal(_proposalId);

        tryFinaliseNonLockedTokensProposal(_proposalId);
    }



    /*

    Voting

    */

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


    mapping (uint256 => mapping (uint256 => VoteStruct) ) public VotesByProposalId;
    mapping (uint256 => mapping (address => VoteStruct) ) public VotesByCaster;
    mapping (uint256 => uint256 ) public VotesNumByProposalId;
    mapping (uint256 => ResultRecord ) public ResultsByProposalId;

    function RegisterVote(uint256 _proposalId, bool _myVote) public {
        address Voter = msg.sender;

        // get voting power
        uint256 VoterPower = getVotingPower(_proposalId, Voter);

        // get proposal for state
        ProposalRecord storage proposal = ProposalsById[_proposalId];

        // make sure voting power is greater than 0
        // make sure proposal.state allows receiving votes
        // make sure proposal.time_end has not passed.

        if(VoterPower > 0 && proposal.state == getRecordState("ACCEPTING_VOTES")) {

            // first check if this Voter has a record registered,
            // and if they did, annul initial vote, update results, and add new one
            if( hasPreviousVote(_proposalId, Voter) ) {
                undoPreviousVote(_proposalId, Voter);
            }

            registerNewVote(_proposalId, Voter, _myVote, VoterPower);

            // this is where we can end voting before time if result.yes or result.no > totalSoFar
            tryEndVoting(_proposalId);

        } else {
            revert();
        }
    }

    function hasPreviousVote(uint256 _proposalId, address _voter) public view returns (bool) {
        VoteStruct storage previousVoteByCaster = VotesByCaster[_proposalId][_voter];
        if( previousVoteByCaster.power > 0 ) {
            return true;
        }
        return false;
    }

    function undoPreviousVote(uint256 _proposalId, address _voter) internal {

        VoteStruct storage previousVoteByCaster = VotesByCaster[_proposalId][_voter];

        // if( previousVoteByCaster.power > 0 ) {
            previousVoteByCaster.annulled = true;

            VoteStruct storage previousVoteByProposalId = VotesByProposalId[_proposalId][previousVoteByCaster.index];
            previousVoteByProposalId.annulled = true;

            ResultRecord storage result = ResultsByProposalId[_proposalId];

            // update total so far as well
            result.totalSoFar-= previousVoteByProposalId.power;

            if(previousVoteByProposalId.vote == true) {
                result.yes-= previousVoteByProposalId.power;
            // } else if(previousVoteByProposalId.vote == false) {
            } else {
                result.no-= previousVoteByProposalId.power;
            }
        // }

    }

    function registerNewVote(uint256 _proposalId, address _voter, bool _myVote, uint256 _power) internal {

        // handle new vote
        uint256 currentVoteId = VotesNumByProposalId[_proposalId]++;
        VoteStruct storage vote = VotesByProposalId[_proposalId][currentVoteId];
            vote.voter = _voter;
            vote.time = getTimestamp();
            vote.vote = _myVote;
            vote.power = _power;
            vote.index = currentVoteId;

        VotesByCaster[_proposalId][_voter] = VotesByProposalId[_proposalId][currentVoteId];

        addVoteIntoResult(_proposalId, _myVote, _power );
    }

    event EventAddVoteIntoResult ( uint256 indexed _proposalId, bool indexed _type, uint256 indexed _power );

    function addVoteIntoResult(uint256 _proposalId, bool _type, uint256 _power ) internal {

        EventAddVoteIntoResult(_proposalId, _type, _power );

        ResultRecord storage newResult = ResultsByProposalId[_proposalId];
        newResult.totalSoFar+= _power;
        if(_type == true) {
            newResult.yes+= _power;
        } else {
            newResult.no+= _power;
        }
    }

    function getTotalTokenVotingPower(address _voter) public view returns ( uint256 ) {
        address VaultAddress = FundingManagerEntity.getMyVaultAddress(_voter);
        uint256 VotingPower = TokenEntity.balanceOf(VaultAddress);
        VotingPower+= TokenEntity.balanceOf(_voter);
        return VotingPower;
    }

    function getVotingPower(uint256 _proposalId, address _voter) public view returns ( uint256 ) {
        uint256 VotingPower = 0;
        ProposalRecord storage proposal = ProposalsById[_proposalId];

        if(proposal.actionType == getActionType("AFTER_COMPLETE_CODE_UPGRADE")) {

            return TokenEntity.balanceOf(_voter);

        } else {

            address VaultAddress = FundingManagerEntity.getMyVaultAddress(_voter);
            if(VaultAddress != address(0x0)) {
                VotingPower = TokenEntity.balanceOf(VaultAddress);

                if( proposal.actionType == getActionType("PROJECT_DELISTING") ) {
                    // for project delisting, we want to also include tokens in the voter's wallet.
                    VotingPower+= TokenEntity.balanceOf(_voter);
                }
            }
        }
        return VotingPower;
    }


    mapping( uint256 => uint256 ) public lastProcessedVoteIdByProposal;
    mapping( uint256 => uint256 ) public ProcessedVotesByProposal;
    mapping( uint256 => uint256 ) public VoteCountAtProcessingStartByProposal;
    uint256 public VoteCountPerProcess = 10;

    function setVoteCountPerProcess(uint256 _perProcess) external onlyDeployer {
        if(_perProcess > 0) {
            VoteCountPerProcess = _perProcess;
        } else {
            revert();
        }
    }

    event EventProcessVoteTotals ( uint256 indexed _proposalId, uint256 indexed start, uint256 indexed end );

    function ProcessVoteTotals(uint256 _proposalId, uint256 length) public onlyApplicationEntity {

        uint256 start = lastProcessedVoteIdByProposal[_proposalId] + 1;
        uint256 end = start + length - 1;
        if(end > VotesNumByProposalId[_proposalId]) {
            end = VotesNumByProposalId[_proposalId];
        }

        EventProcessVoteTotals(_proposalId, start, end);

        // first run
        if(start == 1) {
            // save vote count at start, so we can reset if it changes
            VoteCountAtProcessingStartByProposal[_proposalId] = VotesNumByProposalId[_proposalId];

            // reset vote totals to 0
            ResultRecord storage result = ResultsByProposalId[_proposalId];
            result.yes = 0;
            result.no = 0;
            result.totalSoFar = 0;
        }

        // reset to start if vote count has changed in the middle of processing run
        if(VoteCountAtProcessingStartByProposal[_proposalId] != VotesNumByProposalId[_proposalId]) {
            // we received votes while counting
            // reset from start
            lastProcessedVoteIdByProposal[_proposalId] = 0;
            // exit
            return;
        }

        for(uint256 i = start; i <= end; i++) {

            VoteStruct storage vote = VotesByProposalId[_proposalId][i - 1];
            // process vote into totals.
            if(vote.annulled != true) {
                addVoteIntoResult(_proposalId, vote.vote, vote.power );
            }

            lastProcessedVoteIdByProposal[_proposalId]++;
        }

        // reset iterator so we can call it again.
        if(lastProcessedVoteIdByProposal[_proposalId] >= VotesNumByProposalId[_proposalId] ) {

            ProcessedVotesByProposal[_proposalId] = lastProcessedVoteIdByProposal[_proposalId];
            lastProcessedVoteIdByProposal[_proposalId] = 0;
            tryEndVoting(_proposalId);
        }
    }

    function canEndVoting(uint256 _proposalId) public view returns (bool) {

        ResultRecord memory result = ResultsByProposalId[_proposalId];
        if(result.requiresCounting == false) {
            if(result.yes > result.requiredForResult || result.no > result.requiredForResult) {
                return true;
            }
        }
        else {

            if(ProcessedVotesByProposal[_proposalId] == VotesNumByProposalId[_proposalId]) {
                if(result.yes > result.requiredForResult || result.no > result.requiredForResult) {
                    return true;
                }
            }

        }
        return false;
    }

    function getProposalType(uint256 _proposalId) public view returns (uint8) {
        return ProposalsById[_proposalId].actionType;
    }

    function expiryChangesState(uint256 _proposalId) public view returns (bool) {
        ProposalRecord memory proposal = ProposalsById[_proposalId];
        if( proposal.state == getRecordState("ACCEPTING_VOTES") && proposal.time_end < getTimestamp() ) {
            return true;
        }
        return false;
    }

    function needsProcessing(uint256 _proposalId) public view returns (bool) {
        if( expiryChangesState(_proposalId) ) {
            return true;
        }

        ResultRecord memory result = ResultsByProposalId[_proposalId];
        if(result.requiresCounting == true) {
            if( lastProcessedVoteIdByProposal[_proposalId] < VotesNumByProposalId[_proposalId] ) {
                if(ProcessedVotesByProposal[_proposalId] == VotesNumByProposalId[_proposalId]) {
                    return false;
                }
            }

        } else {
            return false;
        }

        return true;
    }

    function tryEndVoting(uint256 _proposalId) internal {
        if(canEndVoting(_proposalId)) {
            finaliseProposal(_proposalId);
        }

        if(expiryChangesState(_proposalId) ) {
            finaliseExpiredProposal(_proposalId);
        }
    }

    function finaliseProposal(uint256 _proposalId) internal {

        ResultRecord storage result = ResultsByProposalId[_proposalId];
        ProposalRecord storage proposal = ProposalsById[_proposalId];

        // Milestone Deadline proposals cannot be ended "by majority vote", we rely on finaliseExpiredProposal here
        // because we want to allow everyone to be able to vote "NO" if they choose to cashback.

        if( proposal.actionType != getActionType("MILESTONE_DEADLINE")) {
            // read results,
            if(result.yes > result.requiredForResult) {
                // voting resulted in YES
                proposal.state = getRecordState("VOTING_RESULT_YES");
            } else if (result.no >= result.requiredForResult) {
                // voting resulted in NO
                proposal.state = getRecordState("VOTING_RESULT_NO");
            }
        }

        runActionAfterResult(_proposalId);
    }

    function finaliseExpiredProposal(uint256 _proposalId) internal {

        ResultRecord storage result = ResultsByProposalId[_proposalId];
        ProposalRecord storage proposal = ProposalsById[_proposalId];

        // an expired proposal with no votes will end as YES
        if(result.yes == 0 && result.no == 0) {
            proposal.state = getRecordState("VOTING_RESULT_YES");
        } else {
            // read results,
            if(result.yes > result.no) {
                // voting resulted in YES
                proposal.state = getRecordState("VOTING_RESULT_YES");
            } else if (result.no >= result.yes) {
                // tie equals no
                // voting resulted in NO
                proposal.state = getRecordState("VOTING_RESULT_NO");
            }
        }
        runActionAfterResult(_proposalId);
    }

    function tryFinaliseNonLockedTokensProposal(uint256 _proposalId) internal {

        ResultRecord storage result = ResultsByProposalId[_proposalId];
        ProposalRecord storage proposal = ProposalsById[_proposalId];

        if(result.requiredForResult == 0) {
            proposal.state = getRecordState("VOTING_RESULT_YES");
            runActionAfterResult(_proposalId);
        }
    }

    function addActiveProposal(uint256 _proposalId) internal {
        ActiveProposalIds[ActiveProposalNum++]= _proposalId;
    }

    function removeAndReindexActive(uint256 _proposalId) internal {

        bool found = false;
        for (uint8 i = 0; i < ActiveProposalNum; i++) {
            if(ActiveProposalIds[i] == _proposalId) {
                found = true;
            }
            if(found) {
                ActiveProposalIds[i] = ActiveProposalIds[i+1];
            }
        }

        ActiveProposalNum--;
    }


    bool public EmergencyFundingReleaseApproved = false;

    function runActionAfterResult(uint256 _proposalId) internal {

        ProposalRecord storage proposal = ProposalsById[_proposalId];

        if(proposal.state == getRecordState("VOTING_RESULT_YES")) {

            if(proposal.actionType == getActionType("MILESTONE_DEADLINE")) {

            } else if (proposal.actionType == getActionType("MILESTONE_POSTPONING")) {

            } else if (proposal.actionType == getActionType("EMERGENCY_FUND_RELEASE")) {
                EmergencyFundingReleaseApproved = true;

            } else if (proposal.actionType == getActionType("PROJECT_DELISTING")) {

                ListingContractEntity.delistChild( proposal.extra );

            } else if (
                proposal.actionType == getActionType("IN_DEVELOPMENT_CODE_UPGRADE") ||
                proposal.actionType == getActionType("AFTER_COMPLETE_CODE_UPGRADE")
            ) {

                // initiate code upgrade
                acceptCodeUpgrade(_proposalId);
            }

            removeAndReindexActive(_proposalId);

        } else if(proposal.state == getRecordState("VOTING_RESULT_NO")) {

            //
            if(proposal.actionType == getActionType("MILESTONE_DEADLINE")) {

            } else {
                removeAndReindexActive(_proposalId);
            }
        }
    }

    // used by vault cash back
    function getMyVoteForCurrentMilestoneRelease(address _voter) public view returns (bool) {
        // find proposal id for current milestone
        uint8 recordId = MilestonesEntity.currentRecord();
        bytes32 hash = getHash( getActionType("MILESTONE_DEADLINE"), bytes32( recordId ), 0 );
        uint256 proposalId = ProposalIdByHash[hash];
        // based on that proposal id, find my vote
        VoteStruct memory vote = VotesByCaster[proposalId][_voter];
        return vote.vote;
    }

    function getHasVoteForCurrentMilestoneRelease(address _voter) public view returns (bool) {
        // find proposal id for current milestone
        uint8 recordId = MilestonesEntity.currentRecord();
        bytes32 hash = getHash( getActionType("MILESTONE_DEADLINE"), bytes32( recordId ), 0 );
        uint256 proposalId = ProposalIdByHash[hash];
        return hasPreviousVote(proposalId, _voter);
    }

    function getMyVote(uint256 _proposalId, address _voter) public view returns (bool) {
        VoteStruct memory vote = VotesByCaster[_proposalId][_voter];
        return vote.vote;
    }

}