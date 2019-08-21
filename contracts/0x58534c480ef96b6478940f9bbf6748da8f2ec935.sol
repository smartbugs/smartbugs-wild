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

 * @name        General Funding Input Contract ABI
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

*/



contract ABIFundingInputGeneral {

    bool public initialized = false;
    uint8 public typeId;
    address public FundingAssetAddress;

    event EventInputPaymentReceived(address sender, uint amount, uint8 _type);

    function setFundingAssetAddress(address _addr) public;
    function () public payable;
    function buy() public payable returns(bool);
}

/*

 * source       https://github.com/blockbitsio/

 * @name        Funding Contract
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

 Contains the Funding Contract code deployed and linked to the Application Entity

 !!! Links directly to Milestones

*/










contract Funding is ApplicationAsset {

    address public multiSigOutputAddress;
    ABIFundingInputGeneral public DirectInput;
    ABIFundingInputGeneral public MilestoneInput;

    // mapping (bytes32 => uint8) public FundingMethods;
    enum FundingMethodIds {
        __IGNORED__,
        DIRECT_ONLY, 				//
        MILESTONE_ONLY, 		    //
        DIRECT_AND_MILESTONE		//
    }

    ABITokenManager public TokenManagerEntity;
    ABIFundingManager public FundingManagerEntity;

    event FundingStageCreated( uint8 indexed index, bytes32 indexed name );

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
    uint8 public FundingStageNum = 0;
    uint8 public currentFundingStage = 1;

    // funding settings
    uint256 public AmountRaised = 0;
    uint256 public MilestoneAmountRaised = 0;

    uint256 public GlobalAmountCapSoft = 0;
    uint256 public GlobalAmountCapHard = 0;

    uint8 public TokenSellPercentage = 0;

    uint256 public Funding_Setting_funding_time_start = 0;
    uint256 public Funding_Setting_funding_time_end = 0;

    uint256 public Funding_Setting_cashback_time_start = 0;
    // end time is ignored at this stage, anyone can cashback forever if funding fails.
    uint256 public Funding_Setting_cashback_time_end = 0;

    // to be taken from application bylaws
    uint256 public Funding_Setting_cashback_before_start_wait_duration = 7 days;
    uint256 public Funding_Setting_cashback_duration = 365 days;

    event LifeCycle();
    event DebugRecordRequiredChanges( bytes32 indexed _assetName, uint8 indexed _current, uint8 indexed _required );
    event DebugCallAgain(uint8 indexed _who);

    event EventEntityProcessor(bytes32 indexed _assetName, uint8 indexed _current, uint8 indexed _required);
    event EventRecordProcessor(bytes32 indexed _assetName, uint8 indexed _current, uint8 indexed _required);

    event DebugAction(bytes32 indexed _name, bool indexed _allowed);


    event EventFundingReceivedPayment(address indexed _sender, uint8 indexed _payment_method, uint256 indexed _amount );

    function runBeforeInitialization() internal requireNotInitialised {

        // instantiate token manager, moved from runBeforeApplyingSettings
        TokenManagerEntity = ABITokenManager( getApplicationAssetAddressByName('TokenManager') );
        FundingManagerEntity = ABIFundingManager( getApplicationAssetAddressByName('FundingManager') );

        EventRunBeforeInit(assetName);
    }

    function setAssetStates() internal {
        // Asset States
        EntityStates["__IGNORED__"]     = 0;
        EntityStates["NEW"]             = 1;
        EntityStates["WAITING"]         = 2;
        EntityStates["IN_PROGRESS"]     = 3;
        EntityStates["COOLDOWN"]        = 4;
        EntityStates["FUNDING_ENDED"]   = 5;
        EntityStates["FAILED"]          = 6;
        EntityStates["FAILED_FINAL"]    = 7;
        EntityStates["SUCCESSFUL"]      = 8;
        EntityStates["SUCCESSFUL_FINAL"]= 9;

        // Funding Stage States
        RecordStates["__IGNORED__"]     = 0;
        RecordStates["NEW"]             = 1;
        RecordStates["IN_PROGRESS"]     = 2;
        RecordStates["FINAL"]           = 3;
    }

    function addSettings(address _outputAddress, uint256 soft_cap, uint256 hard_cap, uint8 sale_percentage, address _direct, address _milestone )
        public
        requireInitialised
        requireSettingsNotApplied
    {
        if(soft_cap > hard_cap) {
            revert();
        }

        multiSigOutputAddress = _outputAddress;
        GlobalAmountCapSoft = soft_cap;
        GlobalAmountCapHard = hard_cap;

        if(sale_percentage > 90) {
            revert();
        }

        TokenSellPercentage = sale_percentage;

        DirectInput = ABIFundingInputGeneral(_direct);
        MilestoneInput = ABIFundingInputGeneral(_milestone);
    }

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
        public
        onlyDeployer
        requireInitialised
        requireSettingsNotApplied
    {

        // make sure end time is later than start time
        if(_time_end <= _time_start) {
            revert();
        }

        // make sure hard cap exists!
        if(_amount_cap_hard == 0) {
            revert();
        }

        // make sure soft cap is not higher than hard cap
        if(_amount_cap_soft > _amount_cap_hard) {
            revert();
        }

        if(_token_share_percentage > 0) {
            revert();
        }

        FundingStage storage prevRecord = Collection[FundingStageNum];
        if(FundingStageNum > 0) {

            // new stage does not start before the previous one ends
            if( _time_start <= prevRecord.time_end ) {
                revert();
            }
        }

        FundingStage storage record = Collection[++FundingStageNum];
        record.name             = _name;
        record.time_start       = _time_start;
        record.time_end         = _time_end;
        record.amount_cap_soft  = _amount_cap_soft;
        record.amount_cap_hard  = _amount_cap_hard;

        // funding method settings
        record.methods          = _methods;
        record.minimum_entry    = _minimum_entry;

        // token settings
        record.fixed_tokens              = _fixed_tokens;
        record.price_addition_percentage = _price_addition_percentage;
        record.token_share_percentage    = _token_share_percentage;

        // state new
        record.state = getRecordState("NEW");
        record.index = FundingStageNum;

        FundingStageCreated( FundingStageNum, _name );

        adjustFundingSettingsBasedOnNewFundingStage();
    }

    function adjustFundingSettingsBasedOnNewFundingStage() internal {

        // set funding start
        Funding_Setting_funding_time_start = Collection[1].time_start;
        // set funding end
        Funding_Setting_funding_time_end = Collection[FundingStageNum].time_end;

        // cashback starts 1 day after funding status is failed
        Funding_Setting_cashback_time_start = Funding_Setting_funding_time_end + Funding_Setting_cashback_before_start_wait_duration;
        Funding_Setting_cashback_time_end = Funding_Setting_cashback_time_start + Funding_Setting_cashback_duration;
    }

    function getStageAmount(uint8 StageId) public view returns ( uint256 ) {
        return Collection[StageId].fixed_tokens;
    }

    function allowedPaymentMethod(uint8 _payment_method) public pure returns (bool) {
        if(
        _payment_method == uint8(FundingMethodIds.DIRECT_ONLY) ||
        _payment_method == uint8(FundingMethodIds.MILESTONE_ONLY)
        ){
            return true;
        } else {
            return false;
        }
    }

    function receivePayment(address _sender, uint8 _payment_method)
        payable
        public
        requireInitialised
        onlyInputPaymentMethod
        returns(bool)
    {
        // check that msg.value is higher than 0, don't really want to have to deal with minus in case the network breaks this somehow
        if(allowedPaymentMethod(_payment_method) && canAcceptPayment(msg.value) ) {

            uint256 contributed_value = msg.value;

            uint256 amountOverCap = getValueOverCurrentCap(contributed_value);
            if ( amountOverCap > 0 ) {
                // calculate how much we can accept

                // update contributed value
                contributed_value -= amountOverCap;
            }

            Collection[currentFundingStage].amount_raised+= contributed_value;
            AmountRaised+= contributed_value;

            if(_payment_method == uint8(FundingMethodIds.MILESTONE_ONLY)) {
                MilestoneAmountRaised+=contributed_value;
            }

            EventFundingReceivedPayment(_sender, _payment_method, contributed_value);

            if( FundingManagerEntity.receivePayment.value(contributed_value)( _sender, _payment_method, currentFundingStage ) ) {

                if(amountOverCap > 0) {
                    // last step, if we received more than we can accept, send remaining back
                    // amountOverCap sent back
                    if( _sender.send(this.balance) ) {
                        return true;
                    }
                    else {
                        revert();
                    }
                } else {
                    return true;
                }
            } else {
                revert();
            }

        } else {
            revert();
        }
    }

    modifier onlyInputPaymentMethod() {
        require(msg.sender != 0x0 && ( msg.sender == address(DirectInput) || msg.sender == address(MilestoneInput) ));
        _;
    }

    function canAcceptPayment(uint256 _amount) public view returns (bool) {
        if( _amount > 0 ) {
            // funding state should be IN_PROGRESS, no state changes should be required
            if( CurrentEntityState == getEntityState("IN_PROGRESS") && hasRequiredStateChanges() == false) {
                return true;
            }
        }
        return false;
    }

    function getValueOverCurrentCap(uint256 _amount) public view returns (uint256) {
        FundingStage memory record = Collection[currentFundingStage];
        uint256 remaining = record.amount_cap_hard - AmountRaised;
        if( _amount > remaining ) {
            return _amount - remaining;
        }
        return 0;
    }


    /*
    * Update Existing FundingStage
    *
    * @param        uint8 _record_id
    * @param        uint8 _new_state
    * @param        uint8 _duration
    *
    * @access       public
    * @type         method
    * @modifiers    onlyOwner, requireInitialised, updateAllowed
    *
    * @return       void
    */

    function updateFundingStage( uint8 _new_state )
        internal
        requireInitialised
        FundingStageUpdateAllowed(_new_state)
        returns (bool)
    {
        FundingStage storage rec = Collection[currentFundingStage];
        rec.state       = _new_state;
        return true;
    }


    /*
    * Modifier: Validate if record updates are allowed
    *
    * @type         modifier
    *
    * @param        uint8 _record_id
    * @param        uint8 _new_state
    * @param        uint256 _duration
    *
    * @return       bool
    */

    modifier FundingStageUpdateAllowed(uint8 _new_state) {
        require( isFundingStageUpdateAllowed( _new_state )  );
        _;
    }

    /*
     * Method: Validate if record can be updated to requested state
     *
     * @access       public
     * @type         method
     *
     * @param        uint8 _record_id
     * @param        uint8 _new_state
     *
     * @return       bool
     */
    function isFundingStageUpdateAllowed(uint8 _new_state ) public view returns (bool) {

        var (CurrentRecordState, RecordStateRequired, EntityStateRequired) = getRequiredStateChanges();

        CurrentRecordState = 0;
        EntityStateRequired = 0;

        if(_new_state == uint8(RecordStateRequired)) {
            return true;
        }
        return false;
    }

    /*
     * Funding Phase changes
     *
     * Method: Get FundingStage Required State Changes
     *
     * @access       public
     * @type         method
     * @modifiers    onlyOwner
     *
     * @return       uint8 RecordStateRequired
     */
    function getRecordStateRequiredChanges() public view returns (uint8) {

        FundingStage memory record = Collection[currentFundingStage];
        uint8 RecordStateRequired = getRecordState("__IGNORED__");

        if(record.state == getRecordState("FINAL")) {
            return getRecordState("__IGNORED__");
        }

        /*
            If funding stage is not started and timestamp is after start time:
            - we need to change state to IN_PROGRESS so we can start receiving funds
        */
        if( getTimestamp() >= record.time_start ) {
            RecordStateRequired = getRecordState("IN_PROGRESS");
        }

        /*
            This is where we're accepting payments unless we can change state to FINAL

            1. Check if timestamp is after record time_end
            2. Check hard caps
            All lead to state change => FINAL
        */

        // Time check
        if(getTimestamp() >= record.time_end) {
            // Funding Phase ended passed
            return getRecordState("FINAL");
        }

        // will trigger in pre-ico
        // Record Hard Cap Check
        if(AmountRaised >= record.amount_cap_hard) {
            // record hard cap reached
            return getRecordState("FINAL");
        }

        // will trigger in ico
        // Global Hard Cap Check
        if(AmountRaised >= GlobalAmountCapHard) {
            // hard cap reached
            return getRecordState("FINAL");
        }

        if( record.state == RecordStateRequired ) {
            RecordStateRequired = getRecordState("__IGNORED__");
        }

        return RecordStateRequired;
    }

    function doStateChanges() public {
        var (CurrentRecordState, RecordStateRequired, EntityStateRequired) = getRequiredStateChanges();
        bool callAgain = false;

        DebugRecordRequiredChanges( assetName, CurrentRecordState, RecordStateRequired );
        DebugEntityRequiredChanges( assetName, CurrentEntityState, EntityStateRequired );

        if( RecordStateRequired != getRecordState("__IGNORED__") ) {
            // process record changes.
            RecordProcessor(CurrentRecordState, RecordStateRequired);
            DebugCallAgain(2);
            callAgain = true;
        }

        if(EntityStateRequired != getEntityState("__IGNORED__") ) {
            // process entity changes.
            // if(CurrentEntityState != EntityStateRequired) {
            EntityProcessor(EntityStateRequired);
            DebugCallAgain(1);
            callAgain = true;
            //}
        }
    }

    function hasRequiredStateChanges() public view returns (bool) {
        bool hasChanges = false;

        var (CurrentRecordState, RecordStateRequired, EntityStateRequired) = getRequiredStateChanges();
        CurrentRecordState = 0;

        if( RecordStateRequired != getRecordState("__IGNORED__") ) {
            hasChanges = true;
        }
        if(EntityStateRequired != getEntityState("__IGNORED__") ) {
            hasChanges = true;
        }
        return hasChanges;
    }

    // view methods decide if changes are to be made
    // in case of tasks, we do them in the Processors.

    function RecordProcessor(uint8 CurrentRecordState, uint8 RecordStateRequired) internal {
        EventRecordProcessor( assetName, CurrentRecordState, RecordStateRequired );
        updateFundingStage( RecordStateRequired );
        if( RecordStateRequired == getRecordState("FINAL") ) {
            if(currentFundingStage < FundingStageNum) {
                // jump to next stage
                currentFundingStage++;
            }
        }
    }

    function EntityProcessor(uint8 EntityStateRequired) internal {
        EventEntityProcessor( assetName, CurrentEntityState, EntityStateRequired );

        // Do State Specific Updates
        // Update our Entity State
        CurrentEntityState = EntityStateRequired;

        if ( EntityStateRequired == getEntityState("FUNDING_ENDED") ) {
            /*
                STATE: FUNDING_ENDED
                @Processor hook
                Action: Check if funding is successful or not, and move state to "FAILED" or "SUCCESSFUL"
            */

            // Global Hard Cap Check
            if(AmountRaised >= GlobalAmountCapSoft) {
                // hard cap reached
                CurrentEntityState = getEntityState("SUCCESSFUL");
            } else {
                CurrentEntityState = getEntityState("FAILED");
            }
        }


    }

    /*
     * Method: Get Record and Entity State Changes
     *
     * @access       public
     * @type         method
     * @modifiers    onlyOwner
     *
     * @return       ( uint8 CurrentRecordState, uint8 RecordStateRequired, uint8 EntityStateRequired)
     */
    function getRequiredStateChanges() public view returns (uint8, uint8, uint8) {

        // get FundingStage current state
        FundingStage memory record = Collection[currentFundingStage];

        uint8 CurrentRecordState = record.state;
        uint8 RecordStateRequired = getRecordStateRequiredChanges();
        uint8 EntityStateRequired = getEntityState("__IGNORED__");


        // Funding Record State Overrides
        // if(CurrentRecordState != RecordStateRequired) {
        if(RecordStateRequired != getRecordState("__IGNORED__"))
        {
            // direct state overrides by funding stage
            if(RecordStateRequired == getRecordState("IN_PROGRESS") ) {
                // both funding stage and entity states need to move to IN_PROGRESS
                EntityStateRequired = getEntityState("IN_PROGRESS");

            } else if (RecordStateRequired == getRecordState("FINAL")) {
                // funding stage moves to FINAL

                if (currentFundingStage == FundingStageNum) {
                    // if current funding is last
                    EntityStateRequired = getEntityState("FUNDING_ENDED");
                }
                else {
                    // start cooldown between funding stages
                    EntityStateRequired = getEntityState("COOLDOWN");
                }
            }

        } else {

            // Records do not require any updates.
            // Do Entity Checks

            if( CurrentEntityState == getEntityState("NEW") ) {
                /*
                    STATE: NEW
                    Processor Action: Allocate Tokens to Funding / Owners then Update to WAITING
                */
                EntityStateRequired = getEntityState("WAITING");
            } else  if ( CurrentEntityState == getEntityState("FUNDING_ENDED") ) {
                /*
                    STATE: FUNDING_ENDED
                    Processor Action: Check if funding is successful or not, and move state to "SUCCESSFUL" or "FAILED"
                */
            } else if ( CurrentEntityState == getEntityState("SUCCESSFUL") ) {
                /*
                    STATE: SUCCESSFUL
                    Processor Action: none

                    External Action:
                    FundingManager - Run Internal Processor ( deliver tokens, deliver direct funding eth )
                */

                // check funding manager has processed the FUNDING_SUCCESSFUL Task, if true => FUNDING_SUCCESSFUL_DONE
                if(FundingManagerEntity.taskByHash( FundingManagerEntity.getHash("FUNDING_SUCCESSFUL_START", "") ) == true) {
                    EntityStateRequired = getEntityState("SUCCESSFUL_FINAL");
                }
                /*
                if( FundingManagerEntity.CurrentEntityState() == FundingManagerEntity.getEntityState("FUNDING_SUCCESSFUL_DONE") ) {
                    EntityStateRequired = getEntityState("SUCCESSFUL_FINAL");
                }
                */

            } else if ( CurrentEntityState == getEntityState("FAILED") ) {
                /*
                    STATE: FAILED
                    Processor Action: none

                    External Action:
                    FundingManager - Run Internal Processor (release tokens to owner) ( Cashback is available )
                */

                // check funding manager state, if FUNDING_NOT_PROCESSED -> getEntityState("__IGNORED__")
                // if FUNDING_FAILED_DONE

                if(FundingManagerEntity.taskByHash( FundingManagerEntity.getHash("FUNDING_FAILED_START", "") ) == true) {
                    EntityStateRequired = getEntityState("FAILED_FINAL");
                }
            } else if ( CurrentEntityState == getEntityState("SUCCESSFUL_FINAL") ) {
                /*
                    STATE: SUCCESSFUL_FINAL
                    Processor Action: none

                    External Action:
                    Application: Run Internal Processor ( Change State to IN_DEVELOPMENT )
                */
            } else if ( CurrentEntityState == getEntityState("FAILED_FINAL") ) {
                /*
                    STATE: FINAL_FAILED
                    Processor Action: none

                    External Action:
                    Application: Run Internal Processor ( Change State to FUNDING_FAILED )
                */
            }
        }

        return (CurrentRecordState, RecordStateRequired, EntityStateRequired);
    }

}