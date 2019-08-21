pragma solidity >=0.5.0 <0.6.0;

interface IRelay {

    /// @notice Transfer NMR on behalf of a Numerai user
    ///         Can only be called by Manager or Owner
    /// @dev Can only be used on the first 1 million ethereum addresses
    /// @param _from The user address
    /// @param _to The recipient address
    /// @param _value The amount of NMR in wei
    function withdraw(address _from, address _to, uint256 _value) external returns (bool ok);

    /// @notice Burn the NMR sent to address 0 and burn address
    function burnZeroAddress() external;

    /// @notice Permanantly disable the relay contract
    ///         Can only be called by Owner
    function disable() external;

    /// @notice Permanantly disable token upgradability
    ///         Can only be called by Owner
    function disableTokenUpgradability() external;

    /// @notice Upgrade the token delegate logic.
    ///         Can only be called by Owner
    /// @param _newDelegate Address of the new delegate contract
    function changeTokenDelegate(address _newDelegate) external;

    /// @notice Upgrade the token delegate logic using the UpgradeDelegate
    ///         Can only be called by Owner
    /// @dev must be called after UpgradeDelegate is set as the token delegate
    /// @param _multisig Address of the multisig wallet address to receive NMR and ETH
    /// @param _delegateV3 Address of NumeraireDelegateV3
    function executeUpgradeDelegate(address _multisig, address _delegateV3) external;

    /// @notice Burn stakes during initialization phase
    ///         Can only be called by Manager or Owner
    /// @dev must be called after UpgradeDelegate is set as the token delegate
    /// @param tournamentID The index of the tournament
    /// @param roundID The index of the tournament round
    /// @param staker The address of the user
    /// @param tag The UTF8 character string used to identify the submission
    function destroyStake(uint256 tournamentID, uint256 roundID, address staker, bytes32 tag) external;

}


interface INMR {

    /* ERC20 Interface */

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    /* NMR Special Interface */

    // used for user balance management
    function withdraw(address _from, address _to, uint256 _value) external returns(bool ok);

    // used for migrating active stakes
    function destroyStake(address _staker, bytes32 _tag, uint256 _tournamentID, uint256 _roundID) external returns (bool ok);

    // used for disabling token upgradability
    function createRound(uint256, uint256, uint256, uint256) external returns (bool ok);

    // used for upgrading the token delegate logic
    function createTournament(uint256 _newDelegate) external returns (bool ok);

    // used like burn(uint256)
    function mint(uint256 _value) external returns (bool ok);

    // used like burnFrom(address, uint256)
    function numeraiTransfer(address _to, uint256 _value) external returns (bool ok);

    // used to check if upgrade completed
    function contractUpgradable() external view returns (bool);

    function getTournament(uint256 _tournamentID) external view returns (uint256, uint256[] memory);

    function getRound(uint256 _tournamentID, uint256 _roundID) external view returns (uint256, uint256, uint256);

    function getStake(uint256 _tournamentID, uint256 _roundID, address _staker, bytes32 _tag) external view returns (uint256, uint256, bool, bool);

}


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}



/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable is Initializable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function initialize(address sender) public initializer {
        _owner = sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    uint256[50] private ______gap;
}



contract Manageable is Initializable, Ownable {
    address private _manager;

    event ManagementTransferred(address indexed previousManager, address indexed newManager);

    /**
     * @dev The Managable constructor sets the original `manager` of the contract to the sender
     * account.
     */
    function initialize(address sender) initializer public {
        Ownable.initialize(sender);
        _manager = sender;
        emit ManagementTransferred(address(0), _manager);
    }

    /**
     * @return the address of the manager.
     */
    function manager() public view returns (address) {
        return _manager;
    }

    /**
     * @dev Throws if called by any account other than the owner or manager.
     */
    modifier onlyManagerOrOwner() {
        require(isManagerOrOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner or manager of the contract.
     */
    function isManagerOrOwner() public view returns (bool) {
        return (msg.sender == _manager || isOwner());
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newManager.
     * @param newManager The address to transfer management to.
     */
    function transferManagement(address newManager) public onlyOwner {
        require(newManager != address(0));
        emit ManagementTransferred(_manager, newManager);
        _manager = newManager;
    }

    uint256[50] private ______gap;
}



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 *      Modified from openzeppelin Pausable to simplify access control.
 */
contract Pausable is Initializable, Manageable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    /// @notice Initializer function called at time of deployment
    /// @param sender The address of the wallet to handle permission control
    function initialize(address sender) public initializer {
        Manageable.initialize(sender);
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyManagerOrOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyManagerOrOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    uint256[50] private ______gap;
}







/// @title Numerai Tournament logic contract version 2
contract NumeraiTournamentV2 is Initializable, Pausable {

    uint256 public totalStaked;

    mapping (uint256 => Tournament) public tournaments;

    struct Tournament {
        uint256 creationTime;
        uint256[] roundIDs;
        mapping (uint256 => Round) rounds;
    }

    struct Round {
        uint128 creationTime;
        uint128 stakeDeadline;
        mapping (address => mapping (bytes32 => Stake)) stakes;
    }

    struct Stake {
        uint128 amount;
        uint32 confidence;
        uint128 burnAmount;
        bool resolved;
    }

    /* /////////////////// */
    /* Do not modify above */
    /* /////////////////// */

    using SafeMath for uint256;
    using SafeMath for uint128;

    event Staked(
        uint256 indexed tournamentID,
        uint256 indexed roundID,
        address indexed staker,
        bytes32 tag,
        uint256 stakeAmount,
        uint256 confidence
    );
    event StakeResolved(
        uint256 indexed tournamentID,
        uint256 indexed roundID,
        address indexed staker,
        bytes32 tag,
        uint256 originalStake,
        uint256 burnAmount
    );
    event RoundCreated(
        uint256 indexed tournamentID,
        uint256 indexed roundID,
        uint256 stakeDeadline
    );
    event TournamentCreated(
        uint256 indexed tournamentID
    );

    // set the address of the NMR token as a constant (stored in runtime code)
    address private constant _TOKEN = address(
        0x1776e1F26f98b1A5dF9cD347953a26dd3Cb46671
    );

    // set the address of the relay as a constant (stored in runtime code)
    address private constant _RELAY = address(
        0xB17dF4a656505570aD994D023F632D48De04eDF2
    );

    /// @dev Throws if the roundID given is not greater than the latest one
    modifier onlyNewRounds(uint256 tournamentID, uint256 roundID) {
        uint256 length = tournaments[tournamentID].roundIDs.length;
        if (length > 0) {
            uint256 lastRoundID = tournaments[tournamentID].roundIDs[length - 1];
            require(roundID > lastRoundID, "roundID must be increasing");
        }
        _;
    }

    /// @dev Throws if the uint256 input is bigger than the max uint128
    modifier onlyUint128(uint256 a) {
        require(
            a < 0x100000000000000000000000000000000,
            "Input uint256 cannot be larger than uint128"
        );
        _;
    }

    /// @notice constructor function, used to enforce implementation address
    constructor() public {
        require(
            address(this) == address(0x4a0E8E6E323E45f8f63De2389407BF6670B8E716),
            "incorrect deployment address - check submitting account & nonce."
        );
    }

    /////////////////////////////
    // Fund Recovery Functions //
    /////////////////////////////

    /// @notice Recover the ETH sent to this contract address
    ///         Can only be called by Numerai
    /// @param recipient The address of the recipient
    function recoverETH(address payable recipient) public onlyOwner {
        recipient.transfer(address(this).balance);
    }

    /// @notice Recover the NMR sent to this address
    ///         Can only be called by Numerai
    /// @param recipient The address of the recipient
    function recoverNMR(address payable recipient) public onlyOwner {
        uint256 balance = INMR(_TOKEN).balanceOf(address(this));
        uint256 amount = balance.sub(totalStaked);
        require(INMR(_TOKEN).transfer(recipient, amount));
    }

    ///////////////////////
    // Batched Functions //
    ///////////////////////

    /// @notice A batched version of stakeOnBehalf()
    /// @param tournamentID The index of the tournament
    /// @param roundID The index of the tournament round
    /// @param staker The address of the user
    /// @param tag The UTF8 character string used to identify the submission
    /// @param stakeAmount The amount of NMR in wei to stake with this submission
    /// @param confidence The confidence threshold to submit with this submission
    function batchStakeOnBehalf(
        uint256[] calldata tournamentID,
        uint256[] calldata roundID,
        address[] calldata staker,
        bytes32[] calldata tag,
        uint256[] calldata stakeAmount,
        uint256[] calldata confidence
    ) external {
        uint256 len = tournamentID.length;
        require(
            roundID.length == len &&
            staker.length == len &&
            tag.length == len &&
            stakeAmount.length == len &&
            confidence.length == len,
            "Inputs must be same length"
        );
        for (uint i = 0; i < len; i++) {
            stakeOnBehalf(tournamentID[i], roundID[i], staker[i], tag[i], stakeAmount[i], confidence[i]);
        }
    }

    /// @notice A batched version of withdraw()
    /// @param from The user address
    /// @param to The recipient address
    /// @param value The amount of NMR in wei
    function batchWithdraw(
        address[] calldata from,
        address[] calldata to,
        uint256[] calldata value
    ) external {
        uint256 len = from.length;
        require(
            to.length == len &&
            value.length == len,
            "Inputs must be same length"
        );
        for (uint i = 0; i < len; i++) {
            withdraw(from[i], to[i], value[i]);
        }
    }

    /// @notice A batched version of resolveStake()
    /// @param tournamentID The index of the tournament
    /// @param roundID The index of the tournament round
    /// @param staker The address of the user
    /// @param tag The UTF8 character string used to identify the submission
    /// @param burnAmount The amount of NMR in wei to burn from the stake
    function batchResolveStake(
        uint256[] calldata tournamentID,
        uint256[] calldata roundID,
        address[] calldata staker,
        bytes32[] calldata tag,
        uint256[] calldata burnAmount
    ) external {
        uint256 len = tournamentID.length;
        require(
            roundID.length == len &&
            staker.length == len &&
            tag.length == len &&
            burnAmount.length == len,
            "Inputs must be same length"
        );
        for (uint i = 0; i < len; i++) {
            resolveStake(tournamentID[i], roundID[i], staker[i], tag[i], burnAmount[i]);
        }
    }

    //////////////////////////////
    // Special Access Functions //
    //////////////////////////////

    /// @notice Stake a round submission on behalf of a Numerai user
    ///         Can only be called by Numerai
    ///         Calling this function multiple times will increment the stake
    /// @dev Calls withdraw() on the NMR token contract through the relay contract.
    ///      Can only be used on the first 1 million ethereum addresses.
    /// @param tournamentID The index of the tournament
    /// @param roundID The index of the tournament round
    /// @param staker The address of the user
    /// @param tag The UTF8 character string used to identify the submission
    /// @param stakeAmount The amount of NMR in wei to stake with this submission
    /// @param confidence The confidence threshold to submit with this submission
    function stakeOnBehalf(
        uint256 tournamentID,
        uint256 roundID,
        address staker,
        bytes32 tag,
        uint256 stakeAmount,
        uint256 confidence
    ) public onlyManagerOrOwner whenNotPaused {
        _stake(tournamentID, roundID, staker, tag, stakeAmount, confidence);
        IRelay(_RELAY).withdraw(staker, address(this), stakeAmount);
    }

    /// @notice Transfer NMR on behalf of a Numerai user
    ///         Can only be called by Numerai
    /// @dev Calls the NMR token contract through the relay contract
    ///      Can only be used on the first 1 million ethereum addresses.
    /// @param from The user address
    /// @param to The recipient address
    /// @param value The amount of NMR in wei
    function withdraw(
        address from,
        address to,
        uint256 value
    ) public onlyManagerOrOwner whenNotPaused {
        IRelay(_RELAY).withdraw(from, to, value);
    }

    ////////////////////
    // User Functions //
    ////////////////////

    /// @notice Stake a round submission on your own behalf
    ///         Can be called by anyone
    /// @param tournamentID The index of the tournament
    /// @param roundID The index of the tournament round
    /// @param tag The UTF8 character string used to identify the submission
    /// @param stakeAmount The amount of NMR in wei to stake with this submission
    /// @param confidence The confidence threshold to submit with this submission
    function stake(
        uint256 tournamentID,
        uint256 roundID,
        bytes32 tag,
        uint256 stakeAmount,
        uint256 confidence
    ) public whenNotPaused {
        _stake(tournamentID, roundID, msg.sender, tag, stakeAmount, confidence);
        require(INMR(_TOKEN).transferFrom(msg.sender, address(this), stakeAmount),
            "Stake was not successfully transfered");
    }

    /////////////////////////////////////
    // Tournament Management Functions //
    /////////////////////////////////////

    /// @notice Resolve a staked submission after the round is completed
    ///         The portion of the stake which is not burned is returned to the user.
    ///         Can only be called by Numerai
    /// @param tournamentID The index of the tournament
    /// @param roundID The index of the tournament round
    /// @param staker The address of the user
    /// @param tag The UTF8 character string used to identify the submission
    /// @param burnAmount The amount of NMR in wei to burn from the stake
    function resolveStake(
        uint256 tournamentID,
        uint256 roundID,
        address staker,
        bytes32 tag,
        uint256 burnAmount
    )
    public
    onlyManagerOrOwner
    whenNotPaused
    onlyUint128(burnAmount)
    {
        Stake storage stakeObj = tournaments[tournamentID].rounds[roundID].stakes[staker][tag];
        uint128 originalStakeAmount = stakeObj.amount;
        if (burnAmount >= 0x100000000000000000000000000000000)
            burnAmount = originalStakeAmount;
        uint128 releaseAmount = uint128(originalStakeAmount.sub(burnAmount));

        assert(originalStakeAmount == releaseAmount + burnAmount);
        require(originalStakeAmount > 0, "The stake must exist");
        require(!stakeObj.resolved, "The stake must not already be resolved");
        require(
            uint256(
                tournaments[tournamentID].rounds[roundID].stakeDeadline
            ) < block.timestamp,
            "Cannot resolve before stake deadline"
        );

        stakeObj.amount = 0;
        stakeObj.burnAmount = uint128(burnAmount);
        stakeObj.resolved = true;

        require(
            INMR(_TOKEN).transfer(staker, releaseAmount),
            "Stake was not succesfully released"
        );
        _burn(burnAmount);

        totalStaked = totalStaked.sub(originalStakeAmount);

        emit StakeResolved(tournamentID, roundID, staker, tag, originalStakeAmount, burnAmount);
    }

    /// @notice Initialize a new tournament
    ///         Can only be called by Numerai
    /// @param tournamentID The index of the tournament
    function createTournament(uint256 tournamentID) public onlyManagerOrOwner {

        Tournament storage tournament = tournaments[tournamentID];

        require(
            tournament.creationTime == 0,
            "Tournament must not already be initialized"
        );

        uint256 oldCreationTime;
        (oldCreationTime,) = getTournamentV1(tournamentID);
        require(
            oldCreationTime == 0,
            "This tournament must not be initialized in V1"
        );

        tournament.creationTime = block.timestamp;

        emit TournamentCreated(tournamentID);
    }

    /// @notice Initialize a new round
    ///         Can only be called by Numerai
    /// @dev The new roundID must be > the last roundID used on the previous tournament version
    /// @param tournamentID The index of the tournament
    /// @param roundID The index of the tournament round
    /// @param stakeDeadline The UNIX timestamp deadline for users to stake their submissions
    function createRound(
        uint256 tournamentID,
        uint256 roundID,
        uint256 stakeDeadline
    )
    public
    onlyManagerOrOwner
    onlyNewRounds(tournamentID, roundID)
    onlyUint128(stakeDeadline)
    {
        Tournament storage tournament = tournaments[tournamentID];
        Round storage round = tournament.rounds[roundID];

        require(tournament.creationTime > 0, "This tournament must be initialized");
        require(round.creationTime == 0, "This round must not be initialized");

        tournament.roundIDs.push(roundID);
        round.creationTime = uint128(block.timestamp);
        round.stakeDeadline = uint128(stakeDeadline);

        emit RoundCreated(tournamentID, roundID, stakeDeadline);
    }

    //////////////////////
    // Getter Functions //
    //////////////////////

    /// @notice Get the state of a tournament in this version
    /// @param tournamentID The index of the tournament
    /// @return creationTime The UNIX timestamp of the tournament creation
    /// @return roundIDs The array of index of the tournament rounds
    function getTournamentV2(uint256 tournamentID) public view returns (
        uint256 creationTime,
        uint256[] memory roundIDs
    ) {
        Tournament storage tournament = tournaments[tournamentID];
        return (tournament.creationTime, tournament.roundIDs);
    }

    /// @notice Get the state of a round in this version
    /// @param tournamentID The index of the tournament
    /// @param roundID The index of the tournament round
    /// @return creationTime The UNIX timestamp of the round creation
    /// @return stakeDeadline The UNIX timestamp of the round deadline for staked submissions
    function getRoundV2(uint256 tournamentID, uint256 roundID) public view returns (
        uint256 creationTime,
        uint256 stakeDeadline
    ) {
        Round storage round = tournaments[tournamentID].rounds[roundID];
        return (uint256(round.creationTime), uint256(round.stakeDeadline));
    }

    /// @notice Get the state of a staked submission in this version
    /// @param tournamentID The index of the tournament
    /// @param roundID The index of the tournament round
    /// @param staker The address of the user
    /// @param tag The UTF8 character string used to identify the submission
    /// @return amount The amount of NMR in wei staked with this submission
    /// @return confidence The confidence threshold attached to this submission
    /// @return burnAmount The amount of NMR in wei burned by the resolution
    /// @return resolved True if the staked submission has been resolved
    function getStakeV2(uint256 tournamentID, uint256 roundID, address staker, bytes32 tag) public view returns (
        uint256 amount,
        uint256 confidence,
        uint256 burnAmount,
        bool resolved
    ) {
        Stake storage stakeObj = tournaments[tournamentID].rounds[roundID].stakes[staker][tag];
        return (stakeObj.amount, stakeObj.confidence, stakeObj.burnAmount, stakeObj.resolved);
    }

    /// @notice Get the state of a tournament in this version
    /// @param tournamentID The index of the tournament
    /// @return creationTime The UNIX timestamp of the tournament creation
    /// @return roundIDs The array of index of the tournament rounds
    function getTournamentV1(uint256 tournamentID) public view returns (
        uint256 creationTime,
        uint256[] memory roundIDs
    ) {
        return INMR(_TOKEN).getTournament(tournamentID);
    }

    /// @notice Get the state of a round in this version
    /// @param tournamentID The index of the tournament
    /// @param roundID The index of the tournament round
    /// @return creationTime The UNIX timestamp of the round creation
    /// @return endTime The UNIX timestamp of the round deadline for staked submissions
    /// @return resolutionTime The UNIX timestamp of the round start time for resolutions
    function getRoundV1(uint256 tournamentID, uint256 roundID) public view returns (
        uint256 creationTime,
        uint256 endTime,
        uint256 resolutionTime
    ) {
        return INMR(_TOKEN).getRound(tournamentID, roundID);
    }

    /// @notice Get the state of a staked submission in this version
    /// @param tournamentID The index of the tournament
    /// @param roundID The index of the tournament round
    /// @param staker The address of the user
    /// @param tag The UTF8 character string used to identify the submission
    /// @return confidence The confidence threshold attached to this submission
    /// @return amount The amount of NMR in wei staked with this submission
    /// @return successful True if the staked submission beat the threshold
    /// @return resolved True if the staked submission has been resolved
    function getStakeV1(uint256 tournamentID, uint256 roundID, address staker, bytes32 tag) public view returns (
        uint256 confidence,
        uint256 amount,
        bool successful,
        bool resolved
    ) {
        return INMR(_TOKEN).getStake(tournamentID, roundID, staker, tag);
    }

    /// @notice Get the address of the relay contract
    /// @return The address of the relay contract
    function relay() external pure returns (address) {
        return _RELAY;
    }

    /// @notice Get the address of the NMR token contract
    /// @return The address of the NMR token contract
    function token() external pure returns (address) {
        return _TOKEN;
    }

    ////////////////////////
    // Internal Functions //
    ////////////////////////

    /// @dev Internal function to handle stake logic
    ///      stakeAmount must fit in a uint128
    ///      confidence must fit in a uint32
    /// @param tournamentID The index of the tournament
    /// @param roundID The index of the tournament round
    /// @param tag The UTF8 character string used to identify the submission
    /// @param stakeAmount The amount of NMR in wei to stake with this submission
    /// @param confidence The confidence threshold to submit with this submission
    function _stake(
        uint256 tournamentID,
        uint256 roundID,
        address staker,
        bytes32 tag,
        uint256 stakeAmount,
        uint256 confidence
    ) internal onlyUint128(stakeAmount) {
        Tournament storage tournament = tournaments[tournamentID];
        Round storage round = tournament.rounds[roundID];
        Stake storage stakeObj = round.stakes[staker][tag];

        uint128 currentStake = stakeObj.amount;
        uint32 currentConfidence = stakeObj.confidence;

        require(tournament.creationTime > 0, "This tournament must be initialized");
        require(round.creationTime > 0, "This round must be initialized");
        require(
            uint256(round.stakeDeadline) > block.timestamp,
            "Cannot stake after stake deadline"
        );
        require(stakeAmount > 0 || currentStake > 0, "Cannot stake zero NMR");
        require(confidence <= 1000000000, "Confidence is capped at 9 decimal places");
        require(currentConfidence <= confidence, "Confidence can only be increased");

        stakeObj.amount = uint128(currentStake.add(stakeAmount));
        stakeObj.confidence = uint32(confidence);

        totalStaked = totalStaked.add(stakeAmount);

        emit Staked(tournamentID, roundID, staker, tag, stakeObj.amount, confidence);
    }

    /// @notice Internal helper function to burn NMR
    /// @dev If before the token upgrade, sends the tokens to address 0
    ///      If after the token upgrade, calls the repurposed mint function to burn
    /// @param _value The amount of NMR in wei
    function _burn(uint256 _value) internal {
        if (INMR(_TOKEN).contractUpgradable()) {
            require(INMR(_TOKEN).transfer(address(0), _value));
        } else {
            require(INMR(_TOKEN).mint(_value), "burn not successful");
        }
    }
}