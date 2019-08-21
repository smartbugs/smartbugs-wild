/**
 * SignatureChallenge.sol

 * The links below will provide more information about the MtPelerin's Bridge protocol:
 * https://www.mtpelerin.com
 * https://github.com/MtPelerin/MtPelerin-protocol

 * The unflattened code is available through this github tag:
 * https://github.com/MtPelerin/MtPelerin-protocol/tree/etherscan-verify-batch-3

 * @notice Copyright © 2016 - 2019 Mt Pelerin Group SA - All Rights Reserved

 * @notice All matters regarding the intellectual property of this code 
 * @notice or software are subject to Swiss Law without reference to its 
 * @notice conflicts of law rules.

 * @notice License for each contract is available in the respective file
 * @notice or in the LICENSE.md file.
 * @notice https://github.com/MtPelerin/

 * @notice Code by OpenZeppelin is copyrighted and licensed on their repository:
 * @notice https://github.com/OpenZeppelin/openzeppelin-solidity
 */

pragma solidity ^0.4.24;

// File: contracts/zeppelin/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/SignatureChallenge.sol

/**
 * @title SignatureChallenge
 * @dev SignatureChallenge accept anyone to send a transaction with a challenge in it.
 * Any Oracle which creates a challenge, may use it to assess that someone does really
 * own a given address.
 *
 * @notice Copyright © 2016 - 2019 Mt Pelerin Group SA - All Rights Reserved
 * @notice This content cannot be used, copied or reproduced in part or in whole
 * @notice without the express and written permission of Mt Pelerin Group SA.
 * @notice Written by *Mt Pelerin Group SA*, <info@mtpelerin.com>
 * @notice All matters regarding the intellectual property of this code or software
 * @notice are subjects to Swiss Law without reference to its conflicts of law rules.
 *
 * Error messages
 * SC01: No ETH must be provided for the challenge
 * SC02: Target must not be null
 * SC03: Execution call must be successful
 * SC04: Challenges are not active
 * SC05: Challenge must not be longer than challengeBytes
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 */
contract SignatureChallenge is Ownable {

  bool public active = true;
  uint8 public challengeBytes = 2;

  function () external payable {
    require(msg.value == 0, "SC01");
    acceptCode(msg.data);
  }

  /**
   * @dev Update Challenge
   */
  function updateChallenge(
    bool _active,
    uint8 _challengeBytes,
    bytes _testCode) public onlyOwner
  {
    if(!signChallengeWhenValid()) {
      active = _active;
      challengeBytes = _challengeBytes;
      emit ChallengeUpdated(_active, _challengeBytes);

      if (active) {
        acceptCode(_testCode);
      }
    }
  }

  /**
   * @dev execute
   */
  function execute(address _target, bytes _data)
    public payable
  {
    if (!signChallengeWhenValid()) {
      executeOwnerRestricted(_target, _data);
    }
  }

  /**
   * @dev Makes sure to accept the code even it matches a valid function signature.
   */
  function signChallengeWhenValid() private returns (bool)
  {
    // Prevent any loophole against the default function
    // SignatureChallenge may be set inactive to bypass this feature
    if (active && msg.data.length == challengeBytes) {
      require(msg.value == 0, "SC01");
      acceptCode(msg.data);
      return true;
    }
    return false;
  }

  /**
   * @dev execute restricted to owner
   */
  function executeOwnerRestricted(address _target, bytes _data)
    private onlyOwner
  {
    require(_target != address(0), "SC02");
    // solium-disable-next-line security/no-call-value
    require(_target.call.value(msg.value)(_data), "SC03");
  }

  /**
   * @dev accept code
   */
  function acceptCode(bytes _code) private {
    require(active, "SC04");
    require(_code.length == challengeBytes, "SC05");
    emit ChallengeSigned(msg.sender, _code);
  }

  event ChallengeUpdated(bool active, uint8 length);
  event ChallengeSigned(address indexed signer, bytes code);
}