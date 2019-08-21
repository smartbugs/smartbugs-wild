pragma solidity ^0.5.0;

/// https://eips.ethereum.org/EIPS/eip-165
interface ERC165 {
  /// @notice Query if a contract implements an interface
  /// @param interfaceID The interface identifier, as specified in ERC-165
  /// @dev Interface identification is specified in ERC-165. This function
  ///  uses less than 30,000 gas.
  /// @return `true` if the contract implements `interfaceID` and
  ///  `interfaceID` is not 0xffffffff, `false` otherwise
  function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

/// https://eips.ethereum.org/EIPS/eip-900
/// @notice Interface with external methods
interface ISimpleStaking {

  event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
  event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);

  function stake(uint256 amount, bytes calldata data) external;
  function stakeFor(address user, uint256 amount, bytes calldata data) external;
  function unstake(uint256 amount, bytes calldata data) external;
  function totalStakedFor(address addr) external view returns (uint256);
  function totalStaked() external view returns (uint256);
  function token() external view returns (address);
  function supportsHistory() external pure returns (bool);

  // optional. Commented out until we have valid reason to implement these methods
  // function lastStakedFor(address addr) public view returns (uint256);
  // function totalStakedForAt(address addr, uint256 blockNumber) public view returns (uint256);
  // function totalStakedAt(uint256 blockNumber) public view returns (uint256);
}

/**
 * @title SafeMath
 * Courtesy of https://github.com/OpenZeppelin/openzeppelin-solidity/blob/9be0f100c48e4726bee73829fbb10f7d85b6ef54/contracts/math/SafeMath.sol
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

contract ERC20 {

  /// @return The total amount of tokens
  function totalSupply() public view returns (uint256 supply);

  /// @param _owner The address from which the balance will be retrieved
  /// @return The balance
  function balanceOf(address _owner) public view returns (uint256 balance);

  /// @notice send `_value` token to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _value) public returns (bool success);

  /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

  /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @param _value The amount of tokens to be approved for transfer
  /// @return Whether the approval was successful or not
  function approve(address _spender, uint256 _value) public returns (bool success);

  /// @param _owner The address of the account owning tokens
  /// @param _spender The address of the account able to transfer the tokens
  /// @return Amount of remaining tokens allowed to spent
  function allowance(address _owner, address _spender) public view returns (uint256 remaining);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
* Smart contract to stake ERC20 and optionally lock it in for a period of time.
* Users can add stake any time as long as the emergency status is false
* Maximum locked-in time is 365 days from now.
*
* It also keeps track of the effective start time which is recorded on the very
* first stake. Think of it as the "member since" attribute.
* If user unstakes (full or partial) at any point, the effective start time is reset.
*
*/
contract TimeLockedStaking is ERC165, ISimpleStaking {
  using SafeMath for uint256;

  struct StakeRecord {
    uint256 amount;
    uint256 unlockedAt;
  }

  struct StakeInfo {
    /// total tokens this user stakes.
    uint256 totalAmount;
    /// "member since" in unix timestamp. Reset when user unstakes.
    uint256 effectiveAt;
    /// storing staking data for unstaking later.
    /// recordId i.e. key of mapping is the keccak256 of the 'data' parameter in the stake method.
    mapping (bytes32 => StakeRecord) stakeRecords;
  }

  /// @dev When emergency is true,
  /// block staking action and
  /// allow to unstake without verifying the record.unlockedAt
  bool public emergency;

  /// @dev Owner of this contract, who can activate the emergency.
  address public owner;

  /// @dev Address of the ERC20 token contract used for staking.
  ERC20 internal erc20Token;

  /// @dev https://solidity.readthedocs.io/en/v0.4.25/style-guide.html#avoiding-naming-collisions
  uint256 internal totalStaked_ = 0;

  /// Keep track of all stakers
  mapping (address => StakeInfo) public stakers;

  modifier greaterThanZero(uint256 num) {
    require(num > 0, "Must be greater than 0.");
    _;
  }

  /// @dev Better to manually validate these params after deployment.
  /// @param token_ ERC0 token's address. Required.
  /// @param owner_ Who can set emergency status. Default: msg.sender.
  constructor(address token_, address owner_) public {
    erc20Token = ERC20(token_);
    owner = owner_;
    emergency = false;
  }

  /// @dev Implement ERC165
  /// With three or more supported interfaces (including ERC165 itself as a required supported interface),
  /// the mapping approach (in every case) costs less gas than the pure approach (at worst case).
  function supportsInterface(bytes4 interfaceID) external view returns (bool) {
    return
      interfaceID == this.supportsInterface.selector ||
      interfaceID == this.stake.selector ^ this.stakeFor.selector ^ this.unstake.selector ^ this.totalStakedFor.selector ^ this.totalStaked.selector ^ this.token.selector ^ this.supportsHistory.selector;
  }

  /// @dev msg.sender stakes for him/her self.
  /// @param amount Number of ERC20 to be staked. Amount must be > 0.
  /// @param data Used for signaling the unlocked time.
  function stake(uint256 amount, bytes calldata data) external {
    registerStake(msg.sender, amount, data);
  }

  /// @dev msg.sender stakes for someone else.
  /// @param amount Number of ERC20 to be staked. Must be > 0.
  /// @param data Used for signaling the unlocked time.
  function stakeFor(address user, uint256 amount, bytes calldata data) external {
    registerStake(user, amount, data);
  }

  /// @dev msg.sender can unstake full amount or partial if unlockedAt =< now
  /// @notice as a result, the "member since" attribute is reset.
  /// @param amount Number of ERC20 to be unstaked. Must be > 0 and =< staked amount.
  /// @param data The payload that was used when staking.
  function unstake(uint256 amount, bytes calldata data)
    external
    greaterThanZero(stakers[msg.sender].effectiveAt) // must be a member
    greaterThanZero(amount)
  {
    address user = msg.sender;

    bytes32 recordId = keccak256(data);

    StakeRecord storage record = stakers[user].stakeRecords[recordId];

    require(amount <= record.amount, "Amount must be equal or smaller than the record.");

    // Validate unlockedAt if there's no emergency.
    // Otherwise, ignore the lockdown period.
    if (!emergency) {
      require(block.timestamp >= record.unlockedAt, "This stake is still locked.");
    }

    record.amount = record.amount.sub(amount);

    stakers[user].totalAmount = stakers[user].totalAmount.sub(amount);
    stakers[user].effectiveAt = block.timestamp;

    totalStaked_ = totalStaked_.sub(amount);

    require(erc20Token.transfer(user, amount), "Transfer failed.");
    emit Unstaked(user, amount, stakers[user].totalAmount, data);
  }

  /// @return The staked amount of an address.
  function totalStakedFor(address addr) external view returns (uint256) {
    return stakers[addr].totalAmount;
  }

  /// @return Total number of tokens this smart contract hold.
  function totalStaked() external view returns (uint256) {
    return totalStaked_;
  }

  /// @return Address of the ERC20 used for staking.
  function token() external view returns (address) {
    return address(erc20Token);
  }

  /// @dev This smart contract does not store staking activities on chain.
  /// @return false History is processed off-chain via event logs.
  function supportsHistory() external pure returns (bool) {
    return false;
  }


  /// Escape hatch
  function setEmergency(bool status) external {
    require(msg.sender == owner, "msg.sender must be owner.");
    emergency = status;
  }

  /// Helpers
  ///

  function max(uint256 a, uint256 b) public pure returns (uint256) {
    return a > b ? a : b;
  }

  function min(uint256 a, uint256 b) public pure returns (uint256) {
    return a > b ? b : a;
  }

  function getStakeRecordUnlockedAt(address user, bytes memory data) public view returns (uint256) {
    return stakers[user].stakeRecords[keccak256(data)].unlockedAt;
  }

  function getStakeRecordAmount(address user, bytes memory data) public view returns (uint256) {
    return stakers[user].stakeRecords[keccak256(data)].amount;
  }

  /// @dev Get the unlockedAt in the data field.
  /// Maximum of 365 days from now.
  /// Minimum of 1. Default value if data.length < 32.
  /// @param data The left-most 256 bits are unix timestamp in seconds.
  /// @return The unlockedAt in the data. Range [1, 365 days from now].
  function getUnlockedAtSignal(bytes memory data) public view returns (uint256) {
    uint256 unlockedAt;

    if (data.length >= 32) {
      assembly {
        let d := add(data, 32) // first 32 bytes are the padded length of data
        unlockedAt := mload(d)
      }
    }

    // Maximum 365 days from now
    uint256 oneYearFromNow = block.timestamp + 365 days;
    uint256 capped = min(unlockedAt, oneYearFromNow);

    return max(1, capped);
  }

  /// @dev Register a stake by updating the StakeInfo struct
  function registerStake(address user, uint256 amount, bytes memory data) private greaterThanZero(amount) {
    require(!emergency, "Cannot stake due to emergency.");
    require(erc20Token.transferFrom(msg.sender, address(this), amount), "Transfer failed.");

    StakeInfo storage info = stakers[user];

    // Update effective at
    info.effectiveAt = info.effectiveAt == 0 ? block.timestamp : info.effectiveAt;

    // Update stake record
    bytes32 recordId = keccak256(data);
    StakeRecord storage record = info.stakeRecords[recordId];
    record.amount = amount.add(record.amount);
    record.unlockedAt = record.unlockedAt == 0 ? getUnlockedAtSignal(data) : record.unlockedAt;

    // Update total amounts
    info.totalAmount = amount.add(info.totalAmount);
    totalStaked_ = totalStaked_.add(amount);

    emit Staked(user, amount, stakers[user].totalAmount, data);
  }
}