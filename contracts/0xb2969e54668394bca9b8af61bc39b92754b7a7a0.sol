pragma solidity 0.4.26;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
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
  function isOwner() public view returns(bool) {
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


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

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




interface IOrbsRewardsDistribution {
    event RewardDistributed(string distributionEvent, address indexed recipient, uint256 amount);

    event RewardsDistributionAnnounced(string distributionEvent, bytes32[] batchHash, uint256 batchCount);
    event RewardsBatchExecuted(string distributionEvent, bytes32 batchHash, uint256 batchIndex);
    event RewardsDistributionAborted(string distributionEvent, bytes32[] abortedBatchHashes, uint256[] abortedBatchIndices);
    event RewardsDistributionCompleted(string distributionEvent);

    event RewardsDistributorReassigned(address indexed previousRewardsDistributor, address indexed newRewardsDistributor);

    function announceDistributionEvent(string distributionEvent, bytes32[] batchHashes) external;
    function abortDistributionEvent(string distributionEvent) external;

    function executeCommittedBatch(string distributionEvent, address[] recipients, uint256[] amounts, uint256 batchIndex) external;

    function distributeRewards(string distributionEvent, address[] recipients, uint256[] amounts) external;

    function getPendingBatches(string distributionEvent) external view returns (bytes32[] pendingBatchHashes, uint256[] pendingBatchIndices);
    function reassignRewardsDistributor(address _newRewardsDistributor) external;
    function isRewardsDistributor() external returns (bool);
}

/// @title Orbs rewards distribution smart contract.
contract OrbsRewardsDistribution is Ownable, IOrbsRewardsDistribution {

    struct Distribution {
        uint256 pendingBatchCount;
        bool hasPendingBatches;
        bytes32[] batchHashes;
    }

    /// The Orbs token smart contract address.
    IERC20 public orbs;

    /// Mapping of all ongoing distribution events.
    /// Distribution events are identified by a unique string
    /// for the duration of their execution.
    /// After completion or abortion the same name may be used again.
    mapping(string => Distribution) distributions;

    /// Address of an optional rewards-distributor account/contract.
    /// Meant to be used in the future, should an alternate implementation of
    /// batch commitment mechanism will be needed. Alternately, manual
    /// transfers without batch commitment may be executed by rewardsDistributor.
    /// Only the address of rewardsDistributor may call distributeRewards()
    address public rewardsDistributor;

    /// Constructor to set Orbs token contract address.
    /// @param _orbs IERC20 The address of the Orbs token contract.
    constructor(IERC20 _orbs) public {
        require(address(_orbs) != address(0), "Address must not be 0!");

        rewardsDistributor = address(0);
        orbs = _orbs;
    }

    /// Announce a new distribution event, and commits to a list of transfer batch
    /// hashes. Only the contract owner may call this method. The method verifies
    /// a distributionEvent with the same name is not currently ongoing.
    /// It then records commitments for all reward payments in the form of batch
    /// hashes array to state.
    /// @param _distributionEvent string Name of a new distribution event
    /// @param _batchHashes bytes32[] The address of the OrbsValidators contract.
    function announceDistributionEvent(string _distributionEvent, bytes32[] _batchHashes) external onlyOwner {
        require(!distributions[_distributionEvent].hasPendingBatches, "distribution event is currently ongoing");
        require(_batchHashes.length > 0, "at least one batch must be announced");

        for (uint256 i = 0; i < _batchHashes.length; i++) {
            require(_batchHashes[i] != bytes32(0), "batch hash may not be 0x0");
        }

        // store distribution event record
        Distribution storage distribution = distributions[_distributionEvent];
        distribution.pendingBatchCount = _batchHashes.length;
        distribution.hasPendingBatches = true;
        distribution.batchHashes = _batchHashes;

        emit RewardsDistributionAnnounced(_distributionEvent, _batchHashes, _batchHashes.length);
    }

    /// Aborts an ongoing distributionEvent and revokes all batch commitments.
    /// Only the contract owner may call this method.
    /// @param _distributionEvent string Name of a new distribution event
    function abortDistributionEvent(string _distributionEvent) external onlyOwner {
        require(distributions[_distributionEvent].hasPendingBatches, "distribution event is not currently ongoing");

        (bytes32[] memory abortedBatchHashes, uint256[] memory abortedBatchIndices) = this.getPendingBatches(_distributionEvent);

        delete distributions[_distributionEvent];

        emit RewardsDistributionAborted(_distributionEvent, abortedBatchHashes, abortedBatchIndices);
    }

    /// Carry out and log transfers in batch. receives two arrays of same length
    /// representing rewards payments for a list of reward recipients.
    /// distributionEvent is only provided for logging purposes.
    /// @param _distributionEvent string Name of a new distribution event
    /// @param _recipients address[] a list of recipients addresses
    /// @param _amounts uint256[] a list of amounts to transfer each recipient at the corresponding array index
    function _distributeRewards(string _distributionEvent, address[] _recipients, uint256[] _amounts) private {
        uint256 batchSize = _recipients.length;
        require(batchSize == _amounts.length, "array length mismatch");

        for (uint256 i = 0; i < batchSize; i++) {
            require(_recipients[i] != address(0), "recipient must be a valid address");
            require(orbs.transfer(_recipients[i], _amounts[i]), "transfer failed");
            emit RewardDistributed(_distributionEvent, _recipients[i], _amounts[i]);
        }
    }

    /// Perform a single batch transfer, bypassing announcement/commitment flow.
    /// Only the assigned rewardsDistributor account may call this method.
    /// Provided to allow another contract or user to implement an alternative
    /// batch commitment mechanism, should on be needed in the future.
    /// @param _distributionEvent string Name of a new distribution event
    /// @param _recipients address[] a list of recipients addresses
    /// @param _amounts uint256[] a list of amounts to transfer each recipient at the corresponding array index
    function distributeRewards(string _distributionEvent, address[] _recipients, uint256[] _amounts) external onlyRewardsDistributor {
        _distributeRewards(_distributionEvent, _recipients, _amounts);
    }

    /// Accepts a batch of payments associated with a distributionEvent.
    /// The batch will be executed only if it matches the commitment hash
    /// published by this contract's owner in a previous
    /// announceDistributionEvent() call. Once validated against an existing
    /// batch hash commitment, the commitment is cleared to ensure the batch
    /// cannot be executed twice.
    /// If this was the last batch in distributionEvent, the event record is
    /// cleared logged as completed.
    /// @param _distributionEvent string Name of a new distribution event
    /// @param _recipients address[] a list of recipients addresses
    /// @param _amounts uint256[] a list of amounts to transfer each recipient at the corresponding array index
    /// @param _batchIndex uint256 index of the specified batch in commitments array
    function executeCommittedBatch(string _distributionEvent, address[] _recipients, uint256[] _amounts, uint256 _batchIndex) external {
        Distribution storage distribution = distributions[_distributionEvent];
        bytes32[] storage batchHashes = distribution.batchHashes;

        require(_recipients.length == _amounts.length, "array length mismatch");
        require(_recipients.length > 0, "at least one reward must be included in a batch");
        require(distribution.hasPendingBatches, "distribution event is not currently ongoing");
        require(batchHashes.length > _batchIndex, "batch number out of range");
        require(batchHashes[_batchIndex] != bytes32(0), "specified batch number already executed");

        bytes32 calculatedHash = calcBatchHash(_recipients, _amounts, _batchIndex);
        require(batchHashes[_batchIndex] == calculatedHash, "batch hash does not match");

        distribution.pendingBatchCount--;
        batchHashes[_batchIndex] = bytes32(0); // delete

        if (distribution.pendingBatchCount == 0) {
            delete distributions[_distributionEvent];
            emit RewardsDistributionCompleted(_distributionEvent);
        }
        emit RewardsBatchExecuted(_distributionEvent, calculatedHash, _batchIndex);

        _distributeRewards(_distributionEvent, _recipients, _amounts);
    }

    /// Returns all pending (not yet executed) batch hashes and indices
    /// associated with a distributionEvent.
    /// @param _distributionEvent string Name of a new distribution event
    /// @return pendingBatchHashes bytes32[]
    /// @return pendingBatchIndices uint256[]
    function getPendingBatches(string _distributionEvent) external view returns (bytes32[] pendingBatchHashes, uint256[] pendingBatchIndices) {
        Distribution storage distribution = distributions[_distributionEvent];
        bytes32[] storage batchHashes = distribution.batchHashes;
        uint256 pendingBatchCount = distribution.pendingBatchCount;
        uint256 batchHashesLength = distribution.batchHashes.length;

        pendingBatchHashes = new bytes32[](pendingBatchCount);
        pendingBatchIndices = new uint256[](pendingBatchCount);

        uint256 addNextAt = 0;
        for (uint256 i = 0; i < batchHashesLength; i++) {
            bytes32 hash = batchHashes[i];
            if (hash != bytes32(0)) {
                pendingBatchIndices[addNextAt] = i;
                pendingBatchHashes[addNextAt] = hash;
                addNextAt++;
            }
        }
    }

    /// For disaster recovery purposes. transfers all orbs from this contract to owner.
    /// Only the contract owner may call this method.
    /// Transfers away any Orbs balance from this contract to the owners address
    function drainOrbs() external onlyOwner {
        uint256 balance = orbs.balanceOf(address(this));
        orbs.transfer(owner(), balance);
    }

    /// Assigns a new rewards-distributor account.
    /// To revoke the current rewards-distributor's rights call this method with 0x0.
    /// Only the contract owner may call this method.
    /// @param _newRewardsDistributor The address to set as the new rewards-distributor.
    function reassignRewardsDistributor(address _newRewardsDistributor) external onlyOwner {
        emit RewardsDistributorReassigned(rewardsDistributor, _newRewardsDistributor);
        rewardsDistributor = _newRewardsDistributor;
    }

    /// Return true if `msg.sender` is the assigned rewards-distributor.
    function isRewardsDistributor() public view returns(bool) {
        return msg.sender == rewardsDistributor;
    }

    /// Throws if called by any account other than the rewards-distributor.
    modifier onlyRewardsDistributor() {
        require(isRewardsDistributor(), "only the assigned rewards-distributor may call this method");
        _;
    }

    /// Computes a hash code form a batch payment specification.
    /// @param _recipients address[] a list of recipients addresses
    /// @param _amounts uint256[] a list of amounts to transfer each recipient at the corresponding array index
    /// @param _batchIndex uint256 index of the specified batch in commitments array
    function calcBatchHash(address[] _recipients, uint256[] _amounts, uint256 _batchIndex) private pure returns (bytes32) {
        bytes memory batchData = abi.encodePacked(_batchIndex, _recipients.length, _recipients, _amounts);

        uint256 expectedLength = 32 * (2 + _recipients.length + _amounts.length);
        require(batchData.length == expectedLength, "unexpected data length");

        return keccak256(batchData);
    }
}