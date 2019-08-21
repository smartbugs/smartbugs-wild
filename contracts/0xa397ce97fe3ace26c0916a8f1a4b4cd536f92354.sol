pragma solidity 0.5.1;

// File: contracts/lib/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
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
        require(isOwner(), "Only the owner can call this function.");
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
}

// File: contracts/lib/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */

interface IERC20 {

  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  // solhint-disable-next-line func-order
  function transfer(address to, uint256 value) external returns (bool);

  // solhint-disable-next-line func-order
  function approve(address spender, uint256 value)
    external returns (bool);

  // solhint-disable-next-line func-order
  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  // solhint-disable-next-line no-simple-event-func-name
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

// File: contracts/lib/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */

library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
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
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: contracts/lib/Roles.sol

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

// File: contracts/lib/PauserRole.sol

contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() public {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender), "Can only be called by pauser.");
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}

// File: contracts/lib/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
  event Paused();
  event Unpaused();

  bool private _paused = false;

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused, "Cannot call when paused.");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused, "Can only call this when paused.");
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused();
  }
}

// File: contracts/lib/ValidatorRole.sol

contract ValidatorRole {
  using Roles for Roles.Role;

  event ValidatorAdded(address indexed account);
  event ValidatorRemoved(address indexed account);

  Roles.Role private validators;

  constructor(address validator) public {
    _addValidator(validator);
  }

  modifier onlyValidator() {
    require(
      isValidator(msg.sender),
      "This function can only be called by a validator."
    );
    _;
  }

  function isValidator(address account) public view returns (bool) {
    return validators.has(account);
  }

  function addValidator(address account) public onlyValidator {
    _addValidator(account);
  }

  function renounceValidator() public {
    _removeValidator(msg.sender);
  }

  function _addValidator(address account) internal {
    validators.add(account);
    emit ValidatorAdded(account);
  }

  function _removeValidator(address account) internal {
    validators.remove(account);
    emit ValidatorRemoved(account);
  }
}

// File: contracts/IxtProtect.sol

/// @title IxtEvents
/// @notice Holds all events used by the IXTProtect contract
contract IxtEvents {

  event MemberAdded(
    address indexed memberAddress,
    bytes32 indexed membershipNumber,
    bytes32 indexed invitationCode
  );

  event StakeDeposited(
    address indexed memberAddress,
    bytes32 indexed membershipNumber,
    uint256 stakeAmount
  );

  event StakeWithdrawn(
    address indexed memberAddress,
    uint256 stakeAmount
  );

  event RewardClaimed(
    address indexed memberAddress,
    uint256 rewardAmount
  );

  event InvitationRewardGiven(
    address indexed memberReceivingReward,
    address indexed memberGivingReward,
    uint256 rewardAmount
  );

  event PoolDeposit(
    address indexed depositer,
    uint256 amount
  );

  event PoolWithdraw(
    address indexed withdrawer,
    uint256 amount
  );

  event AdminRemovedMember(
    address indexed admin,
    address indexed userAddress,
    uint256 refundIssued
  );

  event MemberDrained(
    address indexed memberAddress,
    uint256 amountRefunded
  );

  event PoolDrained(
    address indexed refundRecipient,
    uint256 amountRefunded
  );

  event ContractDrained(
    address indexed drainInitiator
  );

  event InvitationRewardChanged(
    uint256 newInvitationReward
  );

  event LoyaltyRewardChanged(
    uint256 newLoyaltyRewardAmount
  );
}

/// @title RoleManager which inherits the Role-based functionality used
/// by the IXTProtect contract
contract RoleManager is Ownable, Pausable, ValidatorRole {

  constructor(address validator)
    public
    ValidatorRole(validator)
  {}
}

/// @title StakeManager which contains some of the stake-based state
/// used by the IXTProtect contract
contract StakeManager {

  /*      Function modifiers      */

  modifier isValidStakeLevel(StakeLevel level) {
    require(
      uint8(level) >= 0 && uint8(level) <= 2,
      "Is not valid a staking level."
    );
    _;
  }

  /*      Data types      */

  /// @dev The three levels of stake used within the IXTProtect platform
  /// @dev Solidity enums are 0 based
  enum StakeLevel { LOW, MEDIUM, HIGH }

  /*      Variable declarations      */

  /// @dev the defined staking amount for each level
  uint256[3] public ixtStakingLevels;

  /*      Constructor      */

  /// @param _ixtStakingLevels the amount of stake used for each of the staking levels
  /// used within the IXTProtect platform
  constructor(
    uint256[3] memory _ixtStakingLevels
  ) public {
    ixtStakingLevels = _ixtStakingLevels;
  }

}

/// @title RewardManager which contains some of the reward-based state
/// used by the IXTProtect contract
contract RewardManager {

  /*      Variable declarations      */

  /// @dev the reward received when inviting someone
  uint256 public invitationReward;
  /// @dev the period after which a member gets a loyalty reward
  uint256 public loyaltyPeriodDays;
  /// @dev the rate used for calculation of the loyalty reward
  uint256 public loyaltyRewardAmount;

  /*      Constructor      */

  /// @param _invitationReward the amount of reward used when a member uses an invitation code
  /// @param _loyaltyPeriodDays the amount of days that will be used for the loyalty period
  /// @param _loyaltyRewardAmount the rate used as a loyalty reward after every loyalty period
  constructor(
    uint256 _invitationReward,
    uint256 _loyaltyPeriodDays,
    uint256 _loyaltyRewardAmount
  ) public {
    require(
      _loyaltyRewardAmount >= 0 &&
      _loyaltyRewardAmount <= 100,
      "Loyalty reward amount must be between 0 and 100."
    );
    invitationReward = _invitationReward;
    loyaltyPeriodDays = _loyaltyPeriodDays;
    loyaltyRewardAmount = _loyaltyRewardAmount;
  }

}

/// @title IxtProtect
/// @notice Holds state and contains key logic which controls the IXTProtect platform
contract IxtProtect is IxtEvents, RoleManager, StakeManager, RewardManager {

  /*      Function modifiers      */

  modifier isNotMember(address memberAddress) {
    require(
      members[memberAddress].addedTimestamp == 0,
      "Already a member."
    );
    _;
  }

  modifier isMember(address memberAddress) {
    require(
      members[memberAddress].addedTimestamp != 0,
      "User is not a member."
    );
    _;
  }

  modifier notStaking(address memberAddress) {
    require(
      members[memberAddress].stakeTimestamp == 0,
      "Member is staking already."
    );
    _;
  }

  modifier staking(address memberAddress) {
    require(
      members[memberAddress].stakeTimestamp != 0,
      "Member is not staking."
    );
    _;
  }

  /*      Data types      */

  /// @dev data structure used to track state on each member using the platform
  struct Member {
    uint256 addedTimestamp;
    uint256 stakeTimestamp;
    uint256 startOfLoyaltyRewardEligibility;
    bytes32 membershipNumber;
    bytes32 invitationCode;
    uint256 stakeBalance;
    uint256 invitationRewards;
    uint256 previouslyAppliedLoyaltyBalance;
  }

  /*      Variable declarations      */

  /// @dev the IXT ERC20 Token contract
  IERC20 public ixtToken;
  /// @dev a mapping from member wallet addresses to Member struct
  mapping(address => Member) public members;
  /// @dev the same data as `members`, but iterable
  address[] public membersArray;
  /// @dev the total balance of all members
  uint256 public totalMemberBalance;
  /// @dev the total pool balance
  uint256 public totalPoolBalance;
  /// @notice a mapping from invitationCode => memberAddress, so invitation rewards can be applied.
  mapping(bytes32 => address) public registeredInvitationCodes;
 

  /*      Constants      */

  /// @dev the amount of decimals used by the IXT ERC20 token
  uint256 public constant IXT_DECIMALS = 8;

  /*      Constructor      */

  /// @param _validator the address to use as the validator
  /// @param _loyaltyPeriodDays the amount of days that will be used for the loyalty period
  /// @param _ixtToken the address of the IXT ERC20 token to be used as stake and for rewards
  /// @param _invitationReward the amount of reward used when a member uses an invitation code
  /// @param _loyaltyRewardAmount the rate used as a loyalty reward after every loyalty period
  /// @param _ixtStakingLevels three ascending amounts of IXT token to be used as staking levels
  constructor(
    address _validator,
    uint256 _loyaltyPeriodDays,
    address _ixtToken,
    uint256 _invitationReward,
    uint256 _loyaltyRewardAmount,
    uint256[3] memory _ixtStakingLevels
  )
    public
    RoleManager(_validator)
    StakeManager(_ixtStakingLevels)
    RewardManager(_invitationReward, _loyaltyPeriodDays, _loyaltyRewardAmount)
  {
    require(_ixtToken != address(0x0), "ixtToken address was set to 0.");
    ixtToken = IERC20(_ixtToken);
  }

  /*                            */
  /*      PUBLIC FUNCTIONS      */
  /*                            */

  /*      (member control)      */

  /// @notice Registers a new user as a member after the KYC process
  /// @notice This function should not add the invitationCode
  /// to the mapping yet, this should only happen after join
  /// @notice This function can only be called by a "validator" which is set inside the
  /// constructor
  /// @param _membershipNumber the membership number of the member to authorise
  /// @param _memberAddress the EOA address of the member to authorise
  /// @param _invitationCode should be associated with *this* member in order to apply invitation rewards
  /// @param _referralInvitationCode the invitation code of another member which is used to give the

  function addMember(
    bytes32 _membershipNumber,
    address _memberAddress,
    bytes32 _invitationCode,
    bytes32 _referralInvitationCode
  ) 
    public
    onlyValidator
    isNotMember(_memberAddress)
    notStaking(_memberAddress)
  {
    require(
      _memberAddress != address(0x0),
      "Member address was set to 0."
    );
    Member memory member = Member({
      addedTimestamp: block.timestamp,
      stakeTimestamp: 0,
      startOfLoyaltyRewardEligibility: 0,
      membershipNumber: _membershipNumber,
      invitationCode: _invitationCode,
      stakeBalance: 0,
      invitationRewards: 0,
      previouslyAppliedLoyaltyBalance: 0
    });
    members[_memberAddress] = member;
    membersArray.push(_memberAddress);

    /// @dev add this members invitation code to the mapping
    registeredInvitationCodes[member.invitationCode] = _memberAddress;
    /// @dev if the _referralInvitationCode is already registered, add on reward
    address rewardMemberAddress = registeredInvitationCodes[_referralInvitationCode];
    if (
      rewardMemberAddress != address(0x0)
    ) {
      Member storage rewardee = members[rewardMemberAddress];
      rewardee.invitationRewards = SafeMath.add(rewardee.invitationRewards, invitationReward);
      emit InvitationRewardGiven(rewardMemberAddress, _memberAddress, invitationReward);
    }

    emit MemberAdded(_memberAddress, _membershipNumber, _invitationCode);
  }

  /// @notice Called by a member once they have been approved to join the scheme
  /// @notice Before calling the prospective member *must* have approved the appropriate amount of
  /// IXT token to be transferred by this contract
  /// @param _stakeLevel the staking level used by this member. Note this is not the staking *amount*.
  /// other member a reward upon *this* user joining.
  function depositStake(
    StakeLevel _stakeLevel
  )
    public
    whenNotPaused()
    isMember(msg.sender)
    notStaking(msg.sender)
    isValidStakeLevel(_stakeLevel)
  {
    uint256 amountDeposited = depositInternal(msg.sender, ixtStakingLevels[uint256(_stakeLevel)], false);
    Member storage member = members[msg.sender];
    member.stakeTimestamp = block.timestamp;
    member.startOfLoyaltyRewardEligibility = block.timestamp;
    /// @dev add this members invitation code to the mapping
    registeredInvitationCodes[member.invitationCode] = msg.sender;
    emit StakeDeposited(msg.sender, member.membershipNumber, amountDeposited);
  }

  /// @notice Called by the member if they wish to withdraw the stake
  /// @notice This function will return all stake and eligible reward balance back to the user
  function withdrawStake()
    public
    whenNotPaused()
    staking(msg.sender)
  {

    uint256 stakeAmount = refundUserBalance(msg.sender);
    delete registeredInvitationCodes[members[msg.sender].invitationCode];
    Member storage member = members[msg.sender];
    member.stakeTimestamp = 0;
    member.startOfLoyaltyRewardEligibility = 0;
    emit StakeWithdrawn(msg.sender, stakeAmount);
  }

  /// @notice Called by the member if they wish to claim the rewards they are eligible
  /// @notice This function will return all eligible reward balance back to the user
  function claimRewards()
    public
    whenNotPaused()
    staking(msg.sender)
  {
    uint256 rewardClaimed = claimRewardsInternal(msg.sender);
    emit RewardClaimed(msg.sender, rewardClaimed);
  }

  /*      (getter functions)      */

  /// @notice Called in order to get the number of members on the platform
  /// @return length of the members array
  function getMembersArrayLength() public view returns (uint256) {
    return membersArray.length;
  }

  /// @notice Called to obtain the account balance of any given member
  /// @param memberAddress the address of the member to get the account balance for
  /// @return the account balance of the member in question
  function getAccountBalance(address memberAddress)
    public
    view
    staking(memberAddress)
    returns (uint256)
  {
    return getStakeBalance(memberAddress) +
      getRewardBalance(memberAddress);
  }

  /// @notice Called to obtain the stake balance of any given member
  /// @param memberAddress the address of the member to get the stake balance for
  /// @return the stake balance of the member in question
  function getStakeBalance(address memberAddress)
    public
    view
    staking(memberAddress)
    returns (uint256)
  {
    return members[memberAddress].stakeBalance;
  }

  /// @notice Called to obtain the reward balance of any given member
  /// @param memberAddress the address of the member to get the total reward balance for
  /// @return the total reward balance of the member in question
  function getRewardBalance(address memberAddress)
    public
    view
    staking(memberAddress)
    returns (uint256)
  {
    return getInvitationRewardBalance(memberAddress) +
      getLoyaltyRewardBalance(memberAddress);
  }

  /// @notice Called to obtain the invitation reward balance of any given member
  /// @param memberAddress the address of the member to get the invitation reward balance for
  /// @return the invitation reward balance of the member in question
  function getInvitationRewardBalance(address memberAddress)
    public
    view
    staking(memberAddress)
    returns (uint256)
  {
    return members[memberAddress].invitationRewards;
  }

  /// @notice Called to obtain the loyalty reward balance of any given member
  /// @param memberAddress the address of the member to get the loyalty reward balance for
  /// @return the loyalty reward balance of the member in question
  function getLoyaltyRewardBalance(address memberAddress)
    public
    view
    staking(memberAddress)
    returns (uint256 loyaltyReward)
  {
    uint256 loyaltyPeriodSeconds = loyaltyPeriodDays * 1 days;
    Member storage thisMember = members[memberAddress];
    uint256 elapsedTimeSinceEligible = block.timestamp - thisMember.startOfLoyaltyRewardEligibility;
    loyaltyReward = thisMember.previouslyAppliedLoyaltyBalance;
    if (elapsedTimeSinceEligible >= loyaltyPeriodSeconds) {
      uint256 numWholePeriods = SafeMath.div(elapsedTimeSinceEligible, loyaltyPeriodSeconds);
      uint256 rewardForEachPeriod = thisMember.stakeBalance * loyaltyRewardAmount / 100;
      loyaltyReward += rewardForEachPeriod * numWholePeriods;
    }
  }

  /*      (admin functions)      */

  /// @notice Called by the admin to deposit extra IXT into the contract to be used as rewards
  /// @notice This function can only be called by the contract owner
  /// @param amountToDeposit the amount of IXT ERC20 token to deposit into the pool
  function depositPool(uint256 amountToDeposit)
    public
    onlyOwner
  {
    uint256 amountDeposited = depositInternal(msg.sender, amountToDeposit, true);
    emit PoolDeposit(msg.sender, amountDeposited);
  }

  /// @notice Called by the admin to withdraw IXT from the pool balance
  /// @notice This function can only be called by the contract owner
  /// @param amountToWithdraw the amount of IXT ERC20 token to withdraw from the pool
  function withdrawPool(uint256 amountToWithdraw)
    public
    onlyOwner
  {
    if (amountToWithdraw > 0) {
      require(
        totalPoolBalance >= amountToWithdraw &&
        ixtToken.transfer(msg.sender, amountToWithdraw),
        "Unable to withdraw this value of IXT."  
      );
      totalPoolBalance = SafeMath.sub(totalPoolBalance, amountToWithdraw);
    }
    emit PoolWithdraw(msg.sender, amountToWithdraw);
  }

  /// @notice Called by an admin to remove a member from the platform
  /// @notice This function can only be called by the contract owner
  /// @notice The member will be automatically refunded their stake balance and any
  /// unclaimed rewards as a result of being removed by the admin
  /// @notice Can be called if user is authorised *or* joined
  /// @param userAddress the address of the member that the admin wishes to remove
  function removeMember(address userAddress)
    public
    isMember(userAddress)
    onlyOwner
  {
    uint256 refund = cancelMembershipInternal(userAddress);
    emit AdminRemovedMember(msg.sender, userAddress, refund);
  }

  /// @notice Called by an admin in emergency situations only, will returns *ALL* stake balance
  /// and reward balances back to the users. Any left over pool balance will be returned to the
  /// contract owner.
  /// @notice This function can only be called by the contract owner
  function drain() public onlyOwner {
    /// @dev Refund and delete all members
    for (uint256 index = 0; index < membersArray.length; index++) {
      address memberAddress = membersArray[index];
      bool memberJoined = members[memberAddress].stakeTimestamp != 0;
      uint256 amountRefunded = memberJoined ? refundUserBalance(memberAddress) : 0;

      delete registeredInvitationCodes[members[memberAddress].invitationCode];
      delete members[memberAddress];

      emit MemberDrained(memberAddress, amountRefunded);
    }
    delete membersArray;

    /// @dev Refund the pool balance
    require(
      ixtToken.transfer(msg.sender, totalPoolBalance),
      "Unable to withdraw this value of IXT."
    );
    totalPoolBalance = 0;
    emit PoolDrained(msg.sender, totalPoolBalance);
    
    emit ContractDrained(msg.sender);
  }

  /// @notice Called by the contract owner to set the invitation reward to be given to future members
  /// @notice This function does not affect previously awarded invitation rewards
  /// @param _invitationReward the amount that the invitation reward should be set to
  function setInvitationReward(uint256 _invitationReward)
    public
    onlyOwner
  {
    invitationReward = _invitationReward;
    emit InvitationRewardChanged(_invitationReward);
  }

  /// @notice Called by the contract owner to set the loyalty reward rate to be given to future members
  /// @notice This function does not affect previously awarded loyalty rewards
  /// @notice The loyalty reward amount is actually a rate from 0 to 100 that is used to
  /// calculate the proportion of stake balance that should be rewarded.
  /// @param newLoyaltyRewardAmount the amount that the loyalty reward should be set to
  function setLoyaltyRewardAmount(uint256 newLoyaltyRewardAmount)
    public
    onlyOwner
  {
    require(
      newLoyaltyRewardAmount >= 0 &&
      newLoyaltyRewardAmount <= 100,
      "Loyalty reward amount must be between 0 and 100."
    );
    uint256 loyaltyPeriodSeconds = loyaltyPeriodDays * 1 days;
    /// @dev Loop through all the current members and apply previous reward amounts
    for (uint256 i = 0; i < membersArray.length; i++) {
      Member storage thisMember = members[membersArray[i]];
      uint256 elapsedTimeSinceEligible = block.timestamp - thisMember.startOfLoyaltyRewardEligibility;
      if (elapsedTimeSinceEligible >= loyaltyPeriodSeconds) {
        uint256 numWholePeriods = SafeMath.div(elapsedTimeSinceEligible, loyaltyPeriodSeconds);
        uint256 rewardForEachPeriod = thisMember.stakeBalance * loyaltyRewardAmount / 100;
        thisMember.previouslyAppliedLoyaltyBalance += rewardForEachPeriod * numWholePeriods;
        thisMember.startOfLoyaltyRewardEligibility += numWholePeriods * loyaltyPeriodSeconds;
      }
    }
    loyaltyRewardAmount = newLoyaltyRewardAmount;
    emit LoyaltyRewardChanged(newLoyaltyRewardAmount);
  }

  /*                              */
  /*      INTERNAL FUNCTIONS      */
  /*                              */

  function cancelMembershipInternal(address memberAddress)
    internal
    returns
    (uint256 amountRefunded)
  {
    if(members[memberAddress].stakeTimestamp != 0) {
      amountRefunded = refundUserBalance(memberAddress);
    }

    delete registeredInvitationCodes[members[memberAddress].invitationCode];

    delete members[memberAddress];

    removeMemberFromArray(memberAddress);
  }

  function refundUserBalance(
    address memberAddress
  ) 
    internal
    returns (uint256)
  {
    Member storage member = members[memberAddress];

    /// @dev Pool balance will be reduced inside this function
    uint256 claimsRefunded = claimRewardsInternal(memberAddress);
    uint256 stakeToRefund = member.stakeBalance;

    bool userStaking = member.stakeTimestamp != 0;
    if (stakeToRefund > 0 && userStaking) {
      require(
        ixtToken.transfer(memberAddress, stakeToRefund),
        "Unable to withdraw this value of IXT."  
      );
      totalMemberBalance = SafeMath.sub(totalMemberBalance, stakeToRefund);
    }
    member.stakeBalance = 0;
    return claimsRefunded + stakeToRefund;
  }

  function removeMemberFromArray(address memberAddress) internal {
    /// @dev removing the member address from the membersArray
    for (uint256 index; index < membersArray.length; index++) {
      if (membersArray[index] == memberAddress) {
        membersArray[index] = membersArray[membersArray.length - 1];
        membersArray[membersArray.length - 1] = address(0);
        membersArray.length -= 1;
        break;
      }
    }
  }

  function claimRewardsInternal(address memberAddress)
    internal
    returns (uint256 rewardAmount)
  {
    rewardAmount = getRewardBalance(memberAddress);

    if (rewardAmount == 0) {
      return rewardAmount;
    }

    require(
      totalPoolBalance >= rewardAmount,
      "Pool balance not sufficient to withdraw rewards."
    );
    require(
      ixtToken.transfer(memberAddress, rewardAmount),
      "Unable to withdraw this value of IXT."  
    );
    /// @dev we know this is safe as totalPoolBalance >= rewardAmount
    totalPoolBalance -= rewardAmount;

    Member storage thisMember = members[memberAddress];
    thisMember.previouslyAppliedLoyaltyBalance = 0;
    thisMember.invitationRewards = 0;

    uint256 loyaltyPeriodSeconds = loyaltyPeriodDays * 1 days;
    uint256 elapsedTimeSinceEligible = block.timestamp - thisMember.startOfLoyaltyRewardEligibility;
    if (elapsedTimeSinceEligible >= loyaltyPeriodSeconds) {
      uint256 numWholePeriods = SafeMath.div(elapsedTimeSinceEligible, loyaltyPeriodSeconds);
      thisMember.startOfLoyaltyRewardEligibility += numWholePeriods * loyaltyPeriodSeconds;
    }
  }

  function depositInternal(
    address depositer,
    uint256 amount,
    bool isPoolDeposit
  ) 
    internal
    returns (uint256)
  {
    /// @dev Explicitly checking allowance & balance before transferFrom
    /// so we get the revert message.
    require(amount > 0, "Cannot deposit 0 IXT.");
    require(
      ixtToken.allowance(depositer, address(this)) >= amount &&
      ixtToken.balanceOf(depositer) >= amount &&
      ixtToken.transferFrom(depositer, address(this), amount),
      "Unable to deposit IXT - check allowance and balance."  
    );
    if (isPoolDeposit) {
      totalPoolBalance = SafeMath.add(totalPoolBalance, amount);
    } else {
      Member storage member = members[depositer];
      member.stakeBalance = SafeMath.add(member.stakeBalance, amount);
      totalMemberBalance = SafeMath.add(totalMemberBalance, amount);
    }
    return amount;
  }
}