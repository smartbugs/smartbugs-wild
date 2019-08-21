pragma solidity ^0.4.18;

// File: contracts/zeppelin-solidity-1.4/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/zeppelin-solidity-1.4/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
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

// File: contracts/BRDLockup.sol

/**
 * Contract BRDLockup keeps track of a vesting schedule for pre-sold tokens.
 * Pre-sold tokens are rewarded up to `numIntervals` times separated by an
 * `interval` of time. An equal amount of tokens (`allocation` divided by `numIntervals`)
 * is marked for reward each `interval`.
 *
 * The owner of the contract will call processInterval() which will
 * update the allocation state. The owner of the contract should then
 * read the allocation data and reward the beneficiaries.
 */
contract BRDLockup is Ownable {
  using SafeMath for uint256;

  // Allocation stores info about how many tokens to reward a beneficiary account
  struct Allocation {
    address beneficiary;      // account to receive rewards
    uint256 allocation;       // total allocated tokens
    uint256 remainingBalance; // remaining balance after the current interval
    uint256 currentInterval;  // the current interval for the given reward
    uint256 currentReward;    // amount to be rewarded during the current interval
  }

  // the allocation state
  Allocation[] public allocations;

  // the date at which allocations begin unlocking
  uint256 public unlockDate;

  // the current unlock interval
  uint256 public currentInterval;

  // the interval at which allocations will be rewarded
  uint256 public intervalDuration;

  // the number of total reward intervals, zero indexed
  uint256 public numIntervals;

  event Lock(address indexed _to, uint256 _amount);

  event Unlock(address indexed _to, uint256 _amount);

  // constructor
  // @param _crowdsaleEndDate - the date the crowdsale ends
  function BRDLockup(uint256 _crowdsaleEndDate, uint256 _numIntervals, uint256 _intervalDuration)  public {
    unlockDate = _crowdsaleEndDate;
    numIntervals = _numIntervals;
    intervalDuration = _intervalDuration;
    currentInterval = 0;
  }

  // update the allocation storage remaining balances
  function processInterval() onlyOwner public returns (bool _shouldProcessRewards) {
    // ensure the time interval is correct
    bool _correctInterval = now >= unlockDate && now.sub(unlockDate) > currentInterval.mul(intervalDuration);
    bool _validInterval = currentInterval < numIntervals;
    if (!_correctInterval || !_validInterval)
      return false;

    // advance the current interval
    currentInterval = currentInterval.add(1);

    // number of iterations to read all allocations
    uint _allocationsIndex = allocations.length;

    // loop through every allocation
    for (uint _i = 0; _i < _allocationsIndex; _i++) {
      // the current reward for the allocation at index `i`
      uint256 _amountToReward;

      // if we are at the last interval, the reward amount is the entire remaining balance
      if (currentInterval == numIntervals) {
        _amountToReward = allocations[_i].remainingBalance;
      } else {
        // otherwise the reward amount is the total allocation divided by the number of intervals
        _amountToReward = allocations[_i].allocation.div(numIntervals);
      }
      // update the allocation storage
      allocations[_i].currentReward = _amountToReward;
    }

    return true;
  }

  // the total number of allocations
  function numAllocations() constant public returns (uint) {
    return allocations.length;
  }

  // the amount allocated for beneficiary at `_index`
  function allocationAmount(uint _index) constant public returns (uint256) {
    return allocations[_index].allocation;
  }

  // reward the beneficiary at `_index`
  function unlock(uint _index) onlyOwner public returns (bool _shouldReward, address _beneficiary, uint256 _rewardAmount) {
    // ensure the beneficiary is not rewarded twice during the same interval
    if (allocations[_index].currentInterval < currentInterval) {
      // record the currentInterval so the above check is useful
      allocations[_index].currentInterval = currentInterval;
      // subtract the reward from their remaining balance
      allocations[_index].remainingBalance = allocations[_index].remainingBalance.sub(allocations[_index].currentReward);
      // emit event
      Unlock(allocations[_index].beneficiary, allocations[_index].currentReward);
      // return value
      _shouldReward = true;
    } else {
      // return value
      _shouldReward = false;
    }

    // return values
    _rewardAmount = allocations[_index].currentReward;
    _beneficiary = allocations[_index].beneficiary;
  }

  // add a new allocation to the lockup
  function pushAllocation(address _beneficiary, uint256 _numTokens) onlyOwner public {
    require(now < unlockDate);
    allocations.push(
      Allocation(
        _beneficiary,
        _numTokens,
        _numTokens,
        0,
        0
      )
    );
    Lock(_beneficiary, _numTokens);
  }
}