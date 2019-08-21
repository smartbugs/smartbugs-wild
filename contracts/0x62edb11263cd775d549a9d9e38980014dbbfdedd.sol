pragma solidity ^0.4.17;

/**
   @title SafeMath
   @notice Implements SafeMath
*/
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity automatically throws when dividing by 0
        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);

        return a - b;
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;

        assert(c >= a);

        return c;
    }
}

contract Hasher {

    /*
     *  Public pure functions
     */
    function hashUuid(
        string _symbol,
        string _name,
        uint256 _chainIdValue,
        uint256 _chainIdUtility,
        address _openSTUtility,
        uint256 _conversionRate,
        uint8 _conversionRateDecimals)
        public
        pure
        returns (bytes32)
    {
        return keccak256(
            _symbol,
            _name,
            _chainIdValue,
            _chainIdUtility,
            _openSTUtility,
            _conversionRate,
            _conversionRateDecimals);
    }

    function hashStakingIntent(
        bytes32 _uuid,
        address _account,
        uint256 _accountNonce,
        address _beneficiary,
        uint256 _amountST,
        uint256 _amountUT,
        uint256 _escrowUnlockHeight)
        public
        pure
        returns (bytes32)
    {
        return keccak256(
            _uuid,
            _account,
            _accountNonce,
            _beneficiary,
            _amountST,
            _amountUT,
            _escrowUnlockHeight);
    }

    function hashRedemptionIntent(
        bytes32 _uuid,
        address _account,
        uint256 _accountNonce,
        address _beneficiary,
        uint256 _amountUT,
        uint256 _escrowUnlockHeight)
        public
        pure
        returns (bytes32)
    {
        return keccak256(
            _uuid,
            _account,
            _accountNonce,
            _beneficiary,
            _amountUT,
            _escrowUnlockHeight);
    }
}

/**
   @title Owned
   @notice Implements basic ownership with 2-step transfers
*/
contract Owned {

    address public owner;
    address public proposedOwner;

    event OwnershipTransferInitiated(address indexed _proposedOwner);
    event OwnershipTransferCompleted(address indexed _newOwner);


    function Owned() public {
        owner = msg.sender;
    }


    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }


    function isOwner(address _address) internal view returns (bool) {
        return (_address == owner);
    }


    function initiateOwnershipTransfer(address _proposedOwner) public onlyOwner returns (bool) {
        proposedOwner = _proposedOwner;

        OwnershipTransferInitiated(_proposedOwner);

        return true;
    }


    function completeOwnershipTransfer() public returns (bool) {
        require(msg.sender == proposedOwner);

        owner = proposedOwner;
        proposedOwner = address(0);

        OwnershipTransferCompleted(owner);

        return true;
    }
}

/**
   @title OpsManaged
   @notice Implements OpenST ownership and permission model
*/
contract OpsManaged is Owned {

    address public opsAddress;
    address public adminAddress;

    event AdminAddressChanged(address indexed _newAddress);
    event OpsAddressChanged(address indexed _newAddress);


    function OpsManaged() public
        Owned()
    {
    }


    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
        _;
    }


    modifier onlyAdminOrOps() {
        require(isAdmin(msg.sender) || isOps(msg.sender));
        _;
    }


    modifier onlyOwnerOrAdmin() {
        require(isOwner(msg.sender) || isAdmin(msg.sender));
        _;
    }


    modifier onlyOps() {
        require(isOps(msg.sender));
        _;
    }


    function isAdmin(address _address) internal view returns (bool) {
        return (adminAddress != address(0) && _address == adminAddress);
    }


    function isOps(address _address) internal view returns (bool) {
        return (opsAddress != address(0) && _address == opsAddress);
    }


    function isOwnerOrOps(address _address) internal view returns (bool) {
        return (isOwner(_address) || isOps(_address));
    }


    // Owner and Admin can change the admin address. Address can also be set to 0 to 'disable' it.
    function setAdminAddress(address _adminAddress) external onlyOwnerOrAdmin returns (bool) {
        require(_adminAddress != owner);
        require(_adminAddress != address(this));
        require(!isOps(_adminAddress));

        adminAddress = _adminAddress;

        AdminAddressChanged(_adminAddress);

        return true;
    }


    // Owner and Admin can change the operations address. Address can also be set to 0 to 'disable' it.
    function setOpsAddress(address _opsAddress) external onlyOwnerOrAdmin returns (bool) {
        require(_opsAddress != owner);
        require(_opsAddress != address(this));
        require(!isAdmin(_opsAddress));

        opsAddress = _opsAddress;

        OpsAddressChanged(_opsAddress);

        return true;
    }
}

/**
   @title EIP20Interface
   @notice Provides EIP20 token interface
*/
contract EIP20Interface {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256);

    function balanceOf(address _owner) public view returns (uint256 balance);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

contract CoreInterface {
    
    function registrar() public view returns (address /* registrar */);

    function chainIdRemote() public view returns (uint256 /* chainIdRemote */);
    function openSTRemote() public view returns (address /* OpenSTRemote */);
}

contract ProtocolVersioned {

    /*
     *  Events
     */
    event ProtocolTransferInitiated(address indexed _existingProtocol, address indexed _proposedProtocol, uint256 _activationHeight);
    event ProtocolTransferRevoked(address indexed _existingProtocol, address indexed _revokedProtocol);
    event ProtocolTransferCompleted(address indexed _newProtocol);

    /*
     *  Constants
     */
    /// Blocks to wait before the protocol transfer can be completed
    /// This allows anyone with a stake to unstake under the existing
    /// protocol if they disagree with the new proposed protocol
    /// @dev from OpenST ^v1.0 this constant will be set to a significant value
    /// ~ 1 week at 15 seconds per block
    uint256 constant private PROTOCOL_TRANSFER_BLOCKS_TO_WAIT = 40320;
    
    /*
     *  Storage
     */
    /// OpenST protocol contract
    address public openSTProtocol;
    /// proposed OpenST protocol
    address public proposedProtocol;
    /// earliest protocol transfer height
    uint256 public earliestTransferHeight;

    /*
     * Modifiers
     */
    modifier onlyProtocol() {
        require(msg.sender == openSTProtocol);
        _;
    }

    modifier onlyProposedProtocol() {
        require(msg.sender == proposedProtocol);
        _;
    }

    modifier afterWait() {
        require(earliestTransferHeight <= block.number);
        _;
    }

    modifier notNull(address _address) {
        require(_address != 0);
        _;
    }
    
    // TODO: [ben] add hasCode modifier so that for 
    //       a significant wait time the code at the proposed new
    //       protocol can be reviewed

    /*
     *  Public functions
     */
    /// @dev Constructor set the OpenST Protocol
    function ProtocolVersioned(address _protocol) 
        public
        notNull(_protocol)
    {
        openSTProtocol = _protocol;
    }

    /// @dev initiate protocol transfer
    function initiateProtocolTransfer(
        address _proposedProtocol)
        public 
        onlyProtocol
        notNull(_proposedProtocol)
        returns (bool)
    {
        require(_proposedProtocol != openSTProtocol);
        require(proposedProtocol == address(0));

        earliestTransferHeight = block.number + blocksToWaitForProtocolTransfer();
        proposedProtocol = _proposedProtocol;

        ProtocolTransferInitiated(openSTProtocol, _proposedProtocol, earliestTransferHeight);

        return true;
    }

    /// @dev only after the waiting period, can
    ///      proposed protocol complete the transfer
    function completeProtocolTransfer()
        public
        onlyProposedProtocol
        afterWait
        returns (bool) 
    {
        openSTProtocol = proposedProtocol;
        proposedProtocol = address(0);
        earliestTransferHeight = 0;

        ProtocolTransferCompleted(openSTProtocol);

        return true;
    }

    /// @dev protocol can revoke initiated protocol
    ///      transfer
    function revokeProtocolTransfer()
        public
        onlyProtocol
        returns (bool)
    {
        require(proposedProtocol != address(0));

        address revokedProtocol = proposedProtocol;
        proposedProtocol = address(0);
        earliestTransferHeight = 0;

        ProtocolTransferRevoked(openSTProtocol, revokedProtocol);

        return true;
    }

    function blocksToWaitForProtocolTransfer() public pure returns (uint256) {
        return PROTOCOL_TRANSFER_BLOCKS_TO_WAIT;
    }
}

/// @title SimpleStake - stakes the value of an EIP20 token on Ethereum
///        for a utility token on the OpenST platform
/// @author OpenST Ltd.
contract SimpleStake is ProtocolVersioned {
    using SafeMath for uint256;

    /*
     *  Events
     */
    event ReleasedStake(address indexed _protocol, address indexed _to, uint256 _amount);

    /*
     *  Storage
     */
    /// EIP20 token contract that can be staked
    EIP20Interface public eip20Token;
    /// UUID for the utility token
    bytes32 public uuid;

    /*
     *  Public functions
     */
    /// @dev Contract constructor sets the protocol and the EIP20 token to stake
    /// @param _eip20Token EIP20 token that will be staked
    /// @param _openSTProtocol OpenSTProtocol contract that governs staking
    /// @param _uuid Unique Universal Identifier of the registered utility token
    function SimpleStake(
        EIP20Interface _eip20Token,
        address _openSTProtocol,
        bytes32 _uuid)
        ProtocolVersioned(_openSTProtocol)
        public
    {
        eip20Token = _eip20Token;
        uuid = _uuid;
    }

    /// @dev Allows the protocol to release the staked amount
    ///      into provided address.
    ///      The protocol MUST be a contract that sets the rules
    ///      on how the stake can be released and to who.
    ///      The protocol takes the role of an "owner" of the stake.
    /// @param _to Beneficiary of the amount of the stake
    /// @param _amount Amount of stake to release to beneficiary
    function releaseTo(address _to, uint256 _amount) 
        public 
        onlyProtocol
        returns (bool)
    {
        require(_to != address(0));
        require(eip20Token.transfer(_to, _amount));
        
        ReleasedStake(msg.sender, _to, _amount);

        return true;
    }

    /*
     * Web3 call functions
     */
    /// @dev total stake is the balance of the staking contract
    ///      accidental transfers directly to SimpleStake bypassing
    ///      the OpenST protocol will not mint new utility tokens,
    ///      but will add to the total stake.
    ///      (accidental) donations can not be prevented
    function getTotalStake()
        public
        view
        returns (uint256)
    {
        return eip20Token.balanceOf(this);
    }
}

/// @title AM1OpenSTValue - value staking contract for OpenST
contract AM1OpenSTValue is OpsManaged, Hasher {
    using SafeMath for uint256;
    
    /*
     *  Events
     */
    event UtilityTokenRegistered(bytes32 indexed _uuid, address indexed stake,
        string _symbol, string _name, uint8 _decimals, uint256 _conversionRate, uint8 _conversionRateDecimals,
        uint256 _chainIdUtility, address indexed _stakingAccount);

    event StakingIntentDeclared(bytes32 indexed _uuid, address indexed _staker,
        uint256 _stakerNonce, address _beneficiary, uint256 _amountST,
        uint256 _amountUT, uint256 _unlockHeight, bytes32 _stakingIntentHash,
        uint256 _chainIdUtility);

    event ProcessedStake(bytes32 indexed _uuid, bytes32 indexed _stakingIntentHash,
        address _stake, address _staker, uint256 _amountST, uint256 _amountUT);

    event RevertedStake(bytes32 indexed _uuid, bytes32 indexed _stakingIntentHash,
        address _staker, uint256 _amountST, uint256 _amountUT);

    event RedemptionIntentConfirmed(bytes32 indexed _uuid, bytes32 _redemptionIntentHash,
        address _redeemer, address _beneficiary, uint256 _amountST, uint256 _amountUT, uint256 _expirationHeight);

    event ProcessedUnstake(bytes32 indexed _uuid, bytes32 indexed _redemptionIntentHash,
        address stake, address _redeemer, address _beneficiary, uint256 _amountST);

    event RevertedUnstake(bytes32 indexed _uuid, bytes32 indexed _redemptionIntentHash,
        address _redeemer, address _beneficiary, uint256 _amountST);

    /*
     *  Constants
     */
    uint8 public constant TOKEN_DECIMALS = 18;
    uint256 public constant DECIMALSFACTOR = 10**uint256(TOKEN_DECIMALS);
    // ~3 weeks, assuming ~15s per block
    uint256 private constant BLOCKS_TO_WAIT_LONG = 120960;
    // ~3 days, assuming ~15s per block
    uint256 private constant BLOCKS_TO_WAIT_SHORT = 17280;

    /*
     *  Structures
     */
    struct UtilityToken {
        string  symbol;
        string  name;
        uint256 conversionRate;
        uint8 conversionRateDecimals;
        uint8   decimals;
        uint256 chainIdUtility;
        SimpleStake simpleStake;
        address stakingAccount;
    }

    struct Stake {
        bytes32 uuid;
        address staker;
        address beneficiary;
        uint256 nonce;
        uint256 amountST;
        uint256 amountUT;
        uint256 unlockHeight;
    }

    struct Unstake {
        bytes32 uuid;
        address redeemer;
        address beneficiary;
        uint256 amountST;
        // @dev consider removal of amountUT
        uint256 amountUT;
        uint256 expirationHeight;
    }

    /*
     *  Storage
     */
    uint256 public chainIdValue;
    EIP20Interface public valueToken;
    address public registrar;
    bytes32[] public uuids;
    bool public deactivated;
    mapping(uint256 /* chainIdUtility */ => CoreInterface) internal cores;
    mapping(bytes32 /* uuid */ => UtilityToken) public utilityTokens;
    /// nonce makes the staking process atomic across the two-phased process
    /// and protects against replay attack on (un)staking proofs during the process.
    /// On the value chain nonces need to strictly increase by one; on the utility
    /// chain the nonce need to strictly increase (as one value chain can have multiple
    /// utility chains)
    mapping(address /* (un)staker */ => uint256) internal nonces;
    /// register the active stakes and unstakes
    mapping(bytes32 /* hashStakingIntent */ => Stake) public stakes;
    mapping(bytes32 /* hashRedemptionIntent */ => Unstake) public unstakes;

    /*
     *  Modifiers
     */
    modifier onlyRegistrar() {
        // for now keep unique registrar
        require(msg.sender == registrar);
        _;
    }

    function AM1OpenSTValue(
        uint256 _chainIdValue,
        EIP20Interface _eip20token,
        address _registrar)
        public
        OpsManaged()
    {
        require(_chainIdValue != 0);
        require(_eip20token != address(0));
        require(_registrar != address(0));

        chainIdValue = _chainIdValue;
        valueToken = _eip20token;
        // registrar cannot be reset
        // TODO: require it to be a contract
        registrar = _registrar;
        deactivated = false;
    }

    /*
     *  External functions
     */
    /// @dev In order to stake the tx.origin needs to set an allowance
    ///      for the OpenSTValue contract to transfer to itself to hold
    ///      during the staking process.
    function stake(
        bytes32 _uuid,
        uint256 _amountST,
        address _beneficiary)
        external
        returns (
        uint256 amountUT,
        uint256 nonce,
        uint256 unlockHeight,
        bytes32 stakingIntentHash)
        /* solhint-disable-next-line function-max-lines */
    {
        require(!deactivated);
        /* solhint-disable avoid-tx-origin */
        // check the staking contract has been approved to spend the amount to stake
        // OpenSTValue needs to be able to transfer the stake into its balance for
        // keeping until the two-phase process is completed on both chains.
        require(_amountST > 0);
        // Consider the security risk of using tx.origin; at the same time an allowance
        // needs to be set before calling stake over a potentially malicious contract at stakingAccount.
        // The second protection is that the staker needs to check the intent hash before
        // signing off on completing the two-phased process.
        require(valueToken.allowance(tx.origin, address(this)) >= _amountST);

        require(utilityTokens[_uuid].simpleStake != address(0));
        require(_beneficiary != address(0));

        UtilityToken storage utilityToken = utilityTokens[_uuid];

        // if the staking account is set to a non-zero address,
        // then all transactions have come (from/over) the staking account,
        // whether this is an EOA or a contract; tx.origin is putting forward the funds
        if (utilityToken.stakingAccount != address(0)) require(msg.sender == utilityToken.stakingAccount);
        require(valueToken.transferFrom(tx.origin, address(this), _amountST));

        amountUT = (_amountST.mul(utilityToken.conversionRate))
            .div(10**uint256(utilityToken.conversionRateDecimals));
        unlockHeight = block.number + blocksToWaitLong();

        nonces[tx.origin]++;
        nonce = nonces[tx.origin];

        stakingIntentHash = hashStakingIntent(
            _uuid,
            tx.origin,
            nonce,
            _beneficiary,
            _amountST,
            amountUT,
            unlockHeight
        );

        stakes[stakingIntentHash] = Stake({
            uuid:         _uuid,
            staker:       tx.origin,
            beneficiary:  _beneficiary,
            nonce:        nonce,
            amountST:     _amountST,
            amountUT:     amountUT,
            unlockHeight: unlockHeight
        });

        StakingIntentDeclared(_uuid, tx.origin, nonce, _beneficiary,
            _amountST, amountUT, unlockHeight, stakingIntentHash, utilityToken.chainIdUtility);

        return (amountUT, nonce, unlockHeight, stakingIntentHash);
        /* solhint-enable avoid-tx-origin */
    }

    function processStaking(
        bytes32 _stakingIntentHash)
        external
        returns (address stakeAddress)
    {
        require(_stakingIntentHash != "");

        Stake storage stake = stakes[_stakingIntentHash];

        // note: as processStaking incurs a cost for the staker, we provide a fallback
        // in v0.9 for registrar to process the staking on behalf of the staker,
        // as the staker could fail to process the stake and avoid the cost of staking;
        // this will be replaced with a signature carry-over implementation instead, where
        // the signature of the intent hash suffices on value and utility chain, decoupling
        // it from the transaction to processStaking and processMinting
        require(stake.staker == msg.sender || registrar == msg.sender);
        // as this bears the cost, there is no need to require
        // that the stake.unlockHeight is not yet surpassed
        // as is required on processMinting

        UtilityToken storage utilityToken = utilityTokens[stake.uuid];
        stakeAddress = address(utilityToken.simpleStake);
        require(stakeAddress != address(0));

        assert(valueToken.balanceOf(address(this)) >= stake.amountST);
        require(valueToken.transfer(stakeAddress, stake.amountST));

        ProcessedStake(stake.uuid, _stakingIntentHash, stakeAddress, stake.staker,
            stake.amountST, stake.amountUT);

        delete stakes[_stakingIntentHash];

        return stakeAddress;
    }

    function revertStaking(
        bytes32 _stakingIntentHash)
        external
        returns (
        bytes32 uuid,
        uint256 amountST,
        address staker)
    {
        require(_stakingIntentHash != "");

        Stake storage stake = stakes[_stakingIntentHash];

        // require that the stake is unlocked and exists
        require(stake.unlockHeight > 0);
        require(stake.unlockHeight <= block.number);

        assert(valueToken.balanceOf(address(this)) >= stake.amountST);
        // revert the amount that was intended to be staked back to staker
        require(valueToken.transfer(stake.staker, stake.amountST));

        uuid = stake.uuid;
        amountST = stake.amountST;
        staker = stake.staker;

        RevertedStake(stake.uuid, _stakingIntentHash, stake.staker,
            stake.amountST, stake.amountUT);

        delete stakes[_stakingIntentHash];

        return (uuid, amountST, staker);
    }

    function confirmRedemptionIntent(
        bytes32 _uuid,
        address _redeemer,
        uint256 _redeemerNonce,
        address _beneficiary,
        uint256 _amountUT,
        uint256 _redemptionUnlockHeight,
        bytes32 _redemptionIntentHash)
        external
        onlyRegistrar
        returns (
        uint256 amountST,
        uint256 expirationHeight)
    {
        require(utilityTokens[_uuid].simpleStake != address(0));
        require(_amountUT > 0);
        require(_beneficiary != address(0));
        // later core will provide a view on the block height of the
        // utility chain
        require(_redemptionUnlockHeight > 0);
        require(_redemptionIntentHash != "");

        require(nonces[_redeemer] + 1 == _redeemerNonce);
        nonces[_redeemer]++;

        bytes32 redemptionIntentHash = hashRedemptionIntent(
            _uuid,
            _redeemer,
            nonces[_redeemer],
            _beneficiary,
            _amountUT,
            _redemptionUnlockHeight
        );

        require(_redemptionIntentHash == redemptionIntentHash);

        expirationHeight = block.number + blocksToWaitShort();

        UtilityToken storage utilityToken = utilityTokens[_uuid];
        // minimal precision to unstake 1 STWei
        require(_amountUT >= (utilityToken.conversionRate.div(10**uint256(utilityToken.conversionRateDecimals))));
        amountST = (_amountUT
            .mul(10**uint256(utilityToken.conversionRateDecimals))).div(utilityToken.conversionRate);

        require(valueToken.balanceOf(address(utilityToken.simpleStake)) >= amountST);

        unstakes[redemptionIntentHash] = Unstake({
            uuid:         _uuid,
            redeemer:     _redeemer,
            beneficiary:  _beneficiary,
            amountUT:     _amountUT,
            amountST:     amountST,
            expirationHeight: expirationHeight
        });

        RedemptionIntentConfirmed(_uuid, redemptionIntentHash, _redeemer,
            _beneficiary, amountST, _amountUT, expirationHeight);

        return (amountST, expirationHeight);
    }

    function processUnstaking(
        bytes32 _redemptionIntentHash)
        external
        returns (
        address stakeAddress)
    {
        require(_redemptionIntentHash != "");

        Unstake storage unstake = unstakes[_redemptionIntentHash];
        require(unstake.redeemer == msg.sender);

        // as the process unstake results in a gain for the caller
        // it needs to expire well before the process redemption can
        // be reverted in OpenSTUtility
        require(unstake.expirationHeight > block.number);

        UtilityToken storage utilityToken = utilityTokens[unstake.uuid];
        stakeAddress = address(utilityToken.simpleStake);
        require(stakeAddress != address(0));

        require(utilityToken.simpleStake.releaseTo(unstake.beneficiary, unstake.amountST));

        ProcessedUnstake(unstake.uuid, _redemptionIntentHash, stakeAddress,
            unstake.redeemer, unstake.beneficiary, unstake.amountST);

        delete unstakes[_redemptionIntentHash];

        return stakeAddress;
    }

    function revertUnstaking(
        bytes32 _redemptionIntentHash)
        external
        returns (
        bytes32 uuid,
        address redeemer,
        address beneficiary,
        uint256 amountST)
    {
        require(_redemptionIntentHash != "");

        Unstake storage unstake = unstakes[_redemptionIntentHash];

        // require that the unstake has expired and that the redeemer has not
        // processed the unstaking, ie unstake has not been deleted
        require(unstake.expirationHeight > 0);
        require(unstake.expirationHeight <= block.number);

        uuid = unstake.uuid;
        redeemer = unstake.redeemer;
        beneficiary = unstake.beneficiary;
        amountST = unstake.amountST;

        delete unstakes[_redemptionIntentHash];

        RevertedUnstake(uuid, _redemptionIntentHash, redeemer, beneficiary, amountST);

        return (uuid, redeemer, beneficiary, amountST);
    }

    function core(
        uint256 _chainIdUtility)
        external
        view
        returns (address /* core address */ )
    {
        return address(cores[_chainIdUtility]);
    }

    /*
     *  Public view functions
     */
    function getNextNonce(
        address _account)
        public
        view
        returns (uint256 /* nextNonce */)
    {
        return (nonces[_account] + 1);
    }

    function blocksToWaitLong() public pure returns (uint256) {
        return BLOCKS_TO_WAIT_LONG;
    }

    function blocksToWaitShort() public pure returns (uint256) {
        return BLOCKS_TO_WAIT_SHORT;
    }

    /// @dev Returns size of uuids
    /// @return size
    function getUuidsSize() public view returns (uint256) {
        return uuids.length;
    }

    /*
     *  Registrar functions
     */
    function addCore(
        CoreInterface _core)
        public
        onlyRegistrar
        returns (bool /* success */)
    {
        require(address(_core) != address(0));
        // core constructed with same registrar
        require(registrar == _core.registrar());
        // on value chain core only tracks a remote utility chain
        uint256 chainIdUtility = _core.chainIdRemote();
        require(chainIdUtility != 0);
        // cannot overwrite core for given chainId
        require(cores[chainIdUtility] == address(0));

        cores[chainIdUtility] = _core;

        return true;
    }

    function registerUtilityToken(
        string _symbol,
        string _name,
        uint256 _conversionRate,
        uint8 _conversionRateDecimals,
        uint256 _chainIdUtility,
        address _stakingAccount,
        bytes32 _checkUuid)
        public
        onlyRegistrar
        returns (bytes32 uuid)
    {
        require(bytes(_name).length > 0);
        require(bytes(_symbol).length > 0);
        require(_conversionRate > 0);
        require(_conversionRateDecimals <= 5);

        address openSTRemote = cores[_chainIdUtility].openSTRemote();
        require(openSTRemote != address(0));

        uuid = hashUuid(
            _symbol,
            _name,
            chainIdValue,
            _chainIdUtility,
            openSTRemote,
            _conversionRate,
            _conversionRateDecimals);

        require(uuid == _checkUuid);

        require(address(utilityTokens[uuid].simpleStake) == address(0));

        SimpleStake simpleStake = new SimpleStake(
            valueToken, address(this), uuid);

        utilityTokens[uuid] = UtilityToken({
            symbol:         _symbol,
            name:           _name,
            conversionRate: _conversionRate,
            conversionRateDecimals: _conversionRateDecimals,
            decimals:       TOKEN_DECIMALS,
            chainIdUtility: _chainIdUtility,
            simpleStake:    simpleStake,
            stakingAccount: _stakingAccount
        });
        uuids.push(uuid);

        UtilityTokenRegistered(uuid, address(simpleStake), _symbol, _name,
            TOKEN_DECIMALS, _conversionRate, _conversionRateDecimals, _chainIdUtility, _stakingAccount);

        return uuid;
    }

    /*
     *  Administrative functions
     */
    function initiateProtocolTransfer(
        ProtocolVersioned _simpleStake,
        address _proposedProtocol)
        public
        onlyAdmin
        returns (bool)
    {
        _simpleStake.initiateProtocolTransfer(_proposedProtocol);

        return true;
    }

    // on the very first released version v0.9.1 there is no need
    // to completeProtocolTransfer from a previous version

    /* solhint-disable-next-line separate-by-one-line-in-contract */
    function revokeProtocolTransfer(
        ProtocolVersioned _simpleStake)
        public
        onlyAdmin
        returns (bool)
    {
        _simpleStake.revokeProtocolTransfer();

        return true;
    }

    function deactivate()
        public
        onlyAdmin
        returns (
        bool result)
    {
        deactivated = true;
        return deactivated;
    }
}