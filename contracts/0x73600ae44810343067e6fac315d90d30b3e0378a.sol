pragma solidity 0.4.17;

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

 * @name        Funding Vault ABI
 * @package     BlockBitsIO
 * @author      Micky Socaci <micky@nowlive.ro>

 each purchase creates a separate funding vault contract

*/


contract ABIFundingVault {

    bool public _initialized;
    address public vaultOwner;
    address public outputAddress;
    address public managerAddress;
    bool public allFundingProcessed;
    bool public DirectFundingProcessed;
    uint256 public amount_direct;
    uint256 public amount_milestone;
    bool public emergencyFundReleased;

    struct PurchaseStruct {
        uint256 unix_time;
        uint8 payment_method;
        uint256 amount;
        uint8 funding_stage;
        uint16 index;
    }

    bool public BalancesInitialised;
    uint8 public BalanceNum;
    uint16 public purchaseRecordsNum;
    mapping(uint16 => PurchaseStruct) public purchaseRecords;
    mapping (uint8 => uint256) public stageAmounts;
    mapping (uint8 => uint256) public stageAmountsDirect;
    mapping (uint8 => uint256) public etherBalances;
    mapping (uint8 => uint256) public tokenBalances;

    function initialize( address _owner, address _output, address _fundingAddress, address _milestoneAddress, address _proposalsAddress ) public returns(bool);
    function addPayment(uint8 _payment_method, uint8 _funding_stage ) public payable returns (bool);
    function getBoughtTokens() public view returns (uint256);
    function getDirectBoughtTokens() public view returns (uint256);
    function ReleaseFundsAndTokens() public returns (bool);
    function releaseTokensAndEtherForEmergencyFund() public returns (bool);
    function ReleaseFundsToInvestor() public;
    function canCashBack() public view returns (bool);
    function checkFundingStateFailed() public view returns (bool);
    function checkMilestoneStateInvestorVotedNoVotingEndedNo() public view returns (bool);
    function checkOwnerFailedToSetTimeOnMeeting() public view returns (bool);
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







contract TokenSCADAVariable {

    ABIFunding FundingEntity;

    bool public SCADA_requires_hard_cap = true;
    bool public initialized = false;
    address public deployerAddress;

    function TokenSCADAVariable() public {
        deployerAddress = msg.sender;
    }

    function addSettings(address _fundingContract) onlyDeployer public {
        require(initialized == false);
        FundingEntity = ABIFunding(_fundingContract);
        initialized = true;
    }

    function requiresHardCap() public view returns (bool) {
        return SCADA_requires_hard_cap;
    }

    function getTokensForValueInCurrentStage(uint256 _value) public view returns (uint256) {
        return getTokensForValueInStage(FundingEntity.currentFundingStage(), _value);
    }

    function getTokensForValueInStage(uint8 _stage, uint256 _value) public view returns (uint256) {
        uint256 amount = FundingEntity.getStageAmount(_stage);
        return _value * amount;
    }

    function getBoughtTokens( address _vaultAddress, bool _direct ) public view returns (uint256) {
        ABIFundingVault vault = ABIFundingVault(_vaultAddress);

        if(_direct) {
            uint256 DirectTokens = getTokensForValueInStage(1, vault.stageAmountsDirect(1));
            DirectTokens+= getTokensForValueInStage(2, vault.stageAmountsDirect(2));
            return DirectTokens;
        } else {
            uint256 TotalTokens = getTokensForValueInStage(1, vault.stageAmounts(1));
            TotalTokens+= getTokensForValueInStage(2, vault.stageAmounts(2));
            return TotalTokens;
        }
    }

    modifier onlyDeployer() {
        require(msg.sender == deployerAddress);
        _;
    }
}