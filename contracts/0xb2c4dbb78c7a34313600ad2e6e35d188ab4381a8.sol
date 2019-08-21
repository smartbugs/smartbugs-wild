pragma solidity >=0.5.0 <0.6.0;

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






/// @title Numerai Tournament logic contract version 1
contract NumeraiTournamentV1 is Initializable, Pausable {

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

    // define an event for tracking the progress of stake initalization.
    event StakeInitializationProgress(
        bool initialized, // true if stake initialization complete, else false.
        uint256 firstUnprocessedStakeItem // index of the skipped stake, if any.
    );

    using SafeMath for uint256;
    using SafeMath for uint128;

    // set the address of the NMR token as a constant (stored in runtime code)
    address private constant _TOKEN = address(
        0x1776e1F26f98b1A5dF9cD347953a26dd3Cb46671
    );

    /// @notice constructor function, used to enforce implementation address
    constructor() public {
        require(
            address(this) == address(0xb2C4DbB78c7a34313600aD2e6E35d188ab4381a8),
            "Incorrect deployment address - check submitting account & nonce."
        );
    }

    /// @notice Initializer function called at time of deployment
    /// @param _owner The address of the wallet to handle permission control
    function initialize(
        address _owner
    ) public initializer {
        // initialize the contract's ownership.
        Pausable.initialize(_owner);
    }

    /// @notice Initializer function to set data for tournaments and the active
    ///         rounds (i.e. the four most recent) on each of the tournaments.
    /// @param _startingRoundID The most recent round ID to initialize - this
    ///        assumes that each round has a higher roundID than the last and
    ///        that each active round will have the same roundID as other rounds
    ///        that are started at approximately the same time.
    function initializeTournamentsAndActiveRounds(
        uint256 _startingRoundID
    ) public onlyManagerOrOwner {
        // set up the NMR token interface.
        INMR nmr = INMR(_TOKEN);

        // initialize tournament one through seven with four most recent rounds.
        for (uint256 tournamentID = 1; tournamentID <= 7; tournamentID++) {
            // determine the creation time and the round IDs for the tournament.
            (
                uint256 tournamentCreationTime,
                uint256[] memory roundIDs
            ) = nmr.getTournament(tournamentID);

            // update the creation time of the tournament in storage.
            tournaments[tournamentID].creationTime = tournamentCreationTime;

            // skip round initialization if there are no rounds.
            if (roundIDs.length == 0) {
                continue;
            }

            // find the most recent roundID.
            uint256 mostRecentRoundID = roundIDs[roundIDs.length - 1];

            // skip round initialization if mostRecentRoundID < _startingRoundID
            if (mostRecentRoundID < _startingRoundID) {
                continue;
            }

            // track how many rounds are initialized.
            uint256 initializedRounds = 0;

            // iterate through and initialize each round.
            for (uint256 j = 0; j < roundIDs.length; j++) {               
                // get the current round ID.
                uint256 roundID = roundIDs[j];

                // skip this round initialization if roundID < _startingRoundID
                if (roundID < _startingRoundID) {
                    continue;
                }

                // add the roundID to roundIDs in storage.
                tournaments[tournamentID].roundIDs.push(roundID);

                // get more information on the round.
                (
                    uint256 creationTime,
                    uint256 endTime,
                ) = nmr.getRound(tournamentID, roundID);

                // set that information in storage.
                tournaments[tournamentID].rounds[roundID] = Round({
                    creationTime: uint128(creationTime),
                    stakeDeadline: uint128(endTime)
                });

                // increment the number of initialized rounds.
                initializedRounds++;
            }

            // delete the initialized rounds from the old tournament.
            require(
                nmr.createRound(tournamentID, initializedRounds, 0, 0),
                "Could not delete round from legacy tournament."
            );
        }
    }

    /// @notice Initializer function to set the data of the active stakes
    /// @param tournamentID The index of the tournament
    /// @param roundID The index of the tournament round
    /// @param staker The address of the user
    /// @param tag The UTF8 character string used to identify the submission
    function initializeStakes(
        uint256[] memory tournamentID,
        uint256[] memory roundID,
        address[] memory staker,
        bytes32[] memory tag
    ) public onlyManagerOrOwner {
        // set and validate the size of the dynamic array arguments.
        uint256 num = tournamentID.length;
        require(
            roundID.length == num &&
            staker.length == num &&
            tag.length == num,
            "Input data arrays must all have same length."
        );

        // start tracking the total stake amount.
        uint256 stakeAmt = 0;

        // set up the NMR token interface.
        INMR nmr = INMR(_TOKEN);

        // track completed state; this will be set to false if we exit early.
        bool completed = true;

        // track progress; set to the first skipped item if we exit early.
        uint256 progress;

        // iterate through each supplied stake.
        for (uint256 i = 0; i < num; i++) {
            // check gas and break if we're starting to run low.
            if (gasleft() < 100000) {
                completed = false;
                progress = i;
                break;
            }

            // get the amount and confidence
            (uint256 confidence, uint256 amount, , bool resolved) = nmr.getStake(
                tournamentID[i],
                roundID[i],
                staker[i],
                tag[i]
            );

            // only set it if the stake actually exists on the old tournament.
            if (amount > 0 || resolved) {
                uint256 currentTournamentID = tournamentID[i];
                uint256 currentRoundID = roundID[i];

                // destroy the stake on the token contract.
                require(
                    nmr.destroyStake(
                        staker[i], tag[i], currentTournamentID, currentRoundID
                    ),
                    "Could not destroy stake from legacy tournament."
                );

                // get the stake object.
                Stake storage stakeObj = tournaments[currentTournamentID]
                                           .rounds[currentRoundID]
                                           .stakes[staker[i]][tag[i]];

                // only set stake if it isn't already set on new tournament.
                if (stakeObj.amount == 0 && !stakeObj.resolved) {

                    // increase the total stake amount by the retrieved amount.
                    stakeAmt = stakeAmt.add(amount);

                    // set the amount on the stake object.
                    if (amount > 0) {
                        stakeObj.amount = uint128(amount);
                    }

                    // set the confidence on the stake object.
                    stakeObj.confidence = uint32(confidence);

                    // set returned to true if the round was resolved early.
                    if (resolved) {
                        stakeObj.resolved = true;
                    }

                }
            }
        }

        // increase the total stake by the sum of each imported stake amount.
        totalStaked = totalStaked.add(stakeAmt);

        // log the success status and the first skipped item if not completed.
        emit StakeInitializationProgress(completed, progress);
    }

    /// @notice Function to transfer tokens once intialization is completed.
    function settleStakeBalance() public onlyManagerOrOwner {
        // send the stake amount from the caller to this contract.
        require(INMR(_TOKEN).withdraw(address(0), address(0), totalStaked),
            "Stake balance was not successfully set on new tournament.");
    }

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
}