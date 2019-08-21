pragma solidity 0.4.26; // optimization enabled, runs: 500


/************** TPL Extended Jurisdiction - YES token integration *************
 * This digital jurisdiction supports assigning YES token, or other contracts *
 * with a similar validation mechanism, as additional attribute validators.   *
 * https://github.com/TPL-protocol/tpl-contracts/tree/yes-token-integration   *
 * Implements an Attribute Registry https://github.com/0age/AttributeRegistry *
 *                                                                            *
 * Source layout:                                    Line #                   *
 *  - library ECDSA                                    41                     *
 *  - library SafeMath                                108                     *
 *  - library Roles                                   172                     *
 *  - contract PauserRole                             212                     *
 *    - using Roles for Roles.Role                                            *
 *  - contract Pausable                               257                     *
 *    - is PauserRole                                                         *
 *  - contract Ownable                                313                     *
 *  - interface AttributeRegistryInterface            386                     *
 *  - interface BasicJurisdictionInterface            440                     *
 *  - interface ExtendedJurisdictionInterface         658                     *
 *  - interface IERC20 (partial)                      926                     *
 *  - ExtendedJurisdiction                            934                     *
 *    - is Ownable                                                            *
 *    - is Pausable                                                           *
 *    - is AttributeRegistryInterface                                         *
 *    - is BasicJurisdictionInterface                                         *
 *    - is ExtendedJurisdictionInterface                                      *
 *    - using ECDSA for bytes32                                               *
 *    - using SafeMath for uint256                                            *
 *                                                                            *
 *  https://github.com/TPL-protocol/tpl-contracts/blob/master/LICENSE.md      *
 ******************************************************************************/


/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */
library ECDSA {
  /**
   * @dev Recover signer address from a message by using their signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param signature bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes signature)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Check the signature length
    if (signature.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      r := mload(add(signature, 0x20))
      s := mload(add(signature, 0x40))
      v := byte(0, mload(add(signature, 0x60)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      // solium-disable-next-line arg-overflow
      return ecrecover(hash, v, r, s);
    }
  }

  /**
   * toEthSignedMessageHash
   * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
   * and hash the result
   */
  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
    );
  }
}


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
    require(!has(role, account));

    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

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


contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
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


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() internal {
    _paused = false;
  }

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
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }
}


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
 * @title Attribute Registry interface. EIP-165 ID: 0x5f46473f
 */
interface AttributeRegistryInterface {
  /**
   * @notice Check if an attribute of the type with ID `attributeTypeID` has
   * been assigned to the account at `account` and is currently valid.
   * @param account address The account to check for a valid attribute.
   * @param attributeTypeID uint256 The ID of the attribute type to check for.
   * @return True if the attribute is assigned and valid, false otherwise.
   * @dev This function MUST return either true or false - i.e. calling this
   * function MUST NOT cause the caller to revert.
   */
  function hasAttribute(
    address account,
    uint256 attributeTypeID
  ) external view returns (bool);

  /**
   * @notice Retrieve the value of the attribute of the type with ID
   * `attributeTypeID` on the account at `account`, assuming it is valid.
   * @param account address The account to check for the given attribute value.
   * @param attributeTypeID uint256 The ID of the attribute type to check for.
   * @return The attribute value if the attribute is valid, reverts otherwise.
   * @dev This function MUST revert if a directly preceding or subsequent
   * function call to `hasAttribute` with identical `account` and
   * `attributeTypeID` parameters would return false.
   */
  function getAttributeValue(
    address account,
    uint256 attributeTypeID
  ) external view returns (uint256);

  /**
   * @notice Count the number of attribute types defined by the registry.
   * @return The number of available attribute types.
   * @dev This function MUST return a positive integer value  - i.e. calling
   * this function MUST NOT cause the caller to revert.
   */
  function countAttributeTypes() external view returns (uint256);

  /**
   * @notice Get the ID of the attribute type at index `index`.
   * @param index uint256 The index of the attribute type in question.
   * @return The ID of the attribute type.
   * @dev This function MUST revert if the provided `index` value falls outside
   * of the range of the value returned from a directly preceding or subsequent
   * function call to `countAttributeTypes`. It MUST NOT revert if the provided
   * `index` value falls inside said range.
   */
  function getAttributeTypeID(uint256 index) external view returns (uint256);
}


/**
 * @title Basic TPL Jurisdiction Interface.
 */
interface BasicJurisdictionInterface {
  // declare events
  event AttributeTypeAdded(uint256 indexed attributeTypeID, string description);
  
  event AttributeTypeRemoved(uint256 indexed attributeTypeID);
  
  event ValidatorAdded(address indexed validator, string description);
  
  event ValidatorRemoved(address indexed validator);
  
  event ValidatorApprovalAdded(
    address validator,
    uint256 indexed attributeTypeID
  );

  event ValidatorApprovalRemoved(
    address validator,
    uint256 indexed attributeTypeID
  );

  event AttributeAdded(
    address validator,
    address indexed attributee,
    uint256 attributeTypeID,
    uint256 attributeValue
  );

  event AttributeRemoved(
    address validator,
    address indexed attributee,
    uint256 attributeTypeID
  );

  /**
  * @notice Add an attribute type with ID `ID` and description `description` to
  * the jurisdiction.
  * @param ID uint256 The ID of the attribute type to add.
  * @param description string A description of the attribute type.
  * @dev Once an attribute type is added with a given ID, the description of the
  * attribute type cannot be changed, even if the attribute type is removed and
  * added back later.
  */
  function addAttributeType(uint256 ID, string description) external;

  /**
  * @notice Remove the attribute type with ID `ID` from the jurisdiction.
  * @param ID uint256 The ID of the attribute type to remove.
  * @dev All issued attributes of the given type will become invalid upon
  * removal, but will become valid again if the attribute is reinstated.
  */
  function removeAttributeType(uint256 ID) external;

  /**
  * @notice Add account `validator` as a validator with a description
  * `description` who can be approved to set attributes of specific types.
  * @param validator address The account to assign as the validator.
  * @param description string A description of the validator.
  * @dev Note that the jurisdiction can add iteslf as a validator if desired.
  */
  function addValidator(address validator, string description) external;

  /**
  * @notice Remove the validator at address `validator` from the jurisdiction.
  * @param validator address The account of the validator to remove.
  * @dev Any attributes issued by the validator will become invalid upon their
  * removal. If the validator is reinstated, those attributes will become valid
  * again. Any approvals to issue attributes of a given type will need to be
  * set from scratch in the event a validator is reinstated.
  */
  function removeValidator(address validator) external;

  /**
  * @notice Approve the validator at address `validator` to issue attributes of
  * the type with ID `attributeTypeID`.
  * @param validator address The account of the validator to approve.
  * @param attributeTypeID uint256 The ID of the approved attribute type.
  */
  function addValidatorApproval(
    address validator,
    uint256 attributeTypeID
  ) external;

  /**
  * @notice Deny the validator at address `validator` the ability to continue to
  * issue attributes of the type with ID `attributeTypeID`.
  * @param validator address The account of the validator with removed approval.
  * @param attributeTypeID uint256 The ID of the attribute type to unapprove.
  * @dev Any attributes of the specified type issued by the validator in
  * question will become invalid once the approval is removed. If the approval
  * is reinstated, those attributes will become valid again. The approval will
  * also be removed if the approved validator is removed.
  */
  function removeValidatorApproval(
    address validator,
    uint256 attributeTypeID
  ) external;

  /**
  * @notice Issue an attribute of the type with ID `attributeTypeID` and a value
  * of `value` to `account` if `message.caller.address()` is approved validator.
  * @param account address The account to issue the attribute on.
  * @param attributeTypeID uint256 The ID of the attribute type to issue.
  * @param value uint256 An optional value for the issued attribute.
  * @dev Existing attributes of the given type on the address must be removed
  * in order to set a new attribute. Be aware that ownership of the account to
  * which the attribute is assigned may still be transferable - restricting
  * assignment to externally-owned accounts may partially alleviate this issue.
  */
  function issueAttribute(
    address account,
    uint256 attributeTypeID,
    uint256 value
  ) external payable;

  /**
  * @notice Revoke the attribute of the type with ID `attributeTypeID` from
  * `account` if `message.caller.address()` is the issuing validator.
  * @param account address The account to issue the attribute on.
  * @param attributeTypeID uint256 The ID of the attribute type to issue.
  * @dev Validators may still revoke issued attributes even after they have been
  * removed or had their approval to issue the attribute type removed - this
  * enables them to address any objectionable issuances before being reinstated.
  */
  function revokeAttribute(
    address account,
    uint256 attributeTypeID
  ) external;

  /**
   * @notice Determine if a validator at account `validator` is able to issue
   * attributes of the type with ID `attributeTypeID`.
   * @param validator address The account of the validator.
   * @param attributeTypeID uint256 The ID of the attribute type to check.
   * @return True if the validator can issue attributes of the given type, false
   * otherwise.
   */
  function canIssueAttributeType(
    address validator,
    uint256 attributeTypeID
  ) external view returns (bool);

  /**
   * @notice Get a description of the attribute type with ID `attributeTypeID`.
   * @param attributeTypeID uint256 The ID of the attribute type to check for.
   * @return A description of the attribute type.
   */
  function getAttributeTypeDescription(
    uint256 attributeTypeID
  ) external view returns (string description);
  
  /**
   * @notice Get a description of the validator at account `validator`.
   * @param validator address The account of the validator in question.
   * @return A description of the validator.
   */
  function getValidatorDescription(
    address validator
  ) external view returns (string description);

  /**
   * @notice Find the validator that issued the attribute of the type with ID
   * `attributeTypeID` on the account at `account` and determine if the
   * validator is still valid.
   * @param account address The account that contains the attribute be checked.
   * @param attributeTypeID uint256 The ID of the attribute type in question.
   * @return The validator and the current status of the validator as it
   * pertains to the attribute type in question.
   * @dev if no attribute of the given attribute type exists on the account, the
   * function will return (address(0), false).
   */
  function getAttributeValidator(
    address account,
    uint256 attributeTypeID
  ) external view returns (address validator, bool isStillValid);

  /**
   * @notice Count the number of attribute types defined by the jurisdiction.
   * @return The number of available attribute types.
   */
  function countAttributeTypes() external view returns (uint256);

  /**
   * @notice Get the ID of the attribute type at index `index`.
   * @param index uint256 The index of the attribute type in question.
   * @return The ID of the attribute type.
   */
  function getAttributeTypeID(uint256 index) external view returns (uint256);

  /**
   * @notice Get the IDs of all available attribute types on the jurisdiction.
   * @return A dynamic array containing all available attribute type IDs.
   */
  function getAttributeTypeIDs() external view returns (uint256[]);

  /**
   * @notice Count the number of validators defined by the jurisdiction.
   * @return The number of defined validators.
   */
  function countValidators() external view returns (uint256);

  /**
   * @notice Get the account of the validator at index `index`.
   * @param index uint256 The index of the validator in question.
   * @return The account of the validator.
   */
  function getValidator(uint256 index) external view returns (address);

  /**
   * @notice Get the accounts of all available validators on the jurisdiction.
   * @return A dynamic array containing all available validator accounts.
   */
  function getValidators() external view returns (address[]);
}

/**
 * @title Extended TPL Jurisdiction Interface.
 * @dev this extends BasicJurisdictionInterface for additional functionality.
 */
interface ExtendedJurisdictionInterface {
  // declare events (NOTE: consider which fields should be indexed)
  event ValidatorSigningKeyModified(
    address indexed validator,
    address newSigningKey
  );

  event StakeAllocated(
    address indexed staker,
    uint256 indexed attribute,
    uint256 amount
  );

  event StakeRefunded(
    address indexed staker,
    uint256 indexed attribute,
    uint256 amount
  );

  event FeePaid(
    address indexed recipient,
    address indexed payee,
    uint256 indexed attribute,
    uint256 amount
  );
  
  event TransactionRebatePaid(
    address indexed submitter,
    address indexed payee,
    uint256 indexed attribute,
    uint256 amount
  );

  /**
  * @notice Add a restricted attribute type with ID `ID` and description
  * `description` to the jurisdiction. Restricted attribute types can only be
  * removed by the issuing validator or the jurisdiction.
  * @param ID uint256 The ID of the restricted attribute type to add.
  * @param description string A description of the restricted attribute type.
  * @dev Once an attribute type is added with a given ID, the description or the
  * restricted status of the attribute type cannot be changed, even if the
  * attribute type is removed and added back later.
  */
  function addRestrictedAttributeType(uint256 ID, string description) external;

  /**
  * @notice Enable or disable a restriction for a given attribute type ID `ID`
  * that prevents attributes of the given type from being set by operators based
  * on the provided value for `onlyPersonal`.
  * @param ID uint256 The attribute type ID in question.
  * @param onlyPersonal bool Whether the address may only be set personally.
  */
  function setAttributeTypeOnlyPersonal(uint256 ID, bool onlyPersonal) external;

  /**
  * @notice Set a secondary source for a given attribute type ID `ID`, with an
  * address `registry` of the secondary source in question and a given
  * `sourceAttributeTypeID` for attribute type ID to check on the secondary
  * source. The secondary source will only be checked for the given attribute in
  * cases where no attribute of the given attribute type ID is assigned locally.
  * @param ID uint256 The attribute type ID to set the secondary source for.
  * @param attributeRegistry address The secondary attribute registry account.
  * @param sourceAttributeTypeID uint256 The attribute type ID on the secondary
  * source to check.
  * @dev To remove a secondary source on an attribute type, the registry address
  * should be set to the null address.
  */
  function setAttributeTypeSecondarySource(
    uint256 ID,
    address attributeRegistry,
    uint256 sourceAttributeTypeID
  ) external;

  /**
  * @notice Set a minimum required stake for a given attribute type ID `ID` and
  * an amount of `stake`, to be locked in the jurisdiction upon assignment of
  * attributes of the given type. The stake will be applied toward a transaction
  * rebate in the event the attribute is revoked, with the remainder returned to
  * the staker.
  * @param ID uint256 The attribute type ID to set a minimum required stake for.
  * @param minimumRequiredStake uint256 The minimum required funds to lock up.
  * @dev To remove a stake requirement from an attribute type, the stake amount
  * should be set to 0.
  */
  function setAttributeTypeMinimumRequiredStake(
    uint256 ID,
    uint256 minimumRequiredStake
  ) external;

  /**
  * @notice Set a required fee for a given attribute type ID `ID` and an amount
  * of `fee`, to be paid to the owner of the jurisdiction upon assignment of
  * attributes of the given type.
  * @param ID uint256 The attribute type ID to set the required fee for.
  * @param fee uint256 The required fee amount to be paid upon assignment.
  * @dev To remove a fee requirement from an attribute type, the fee amount
  * should be set to 0.
  */
  function setAttributeTypeJurisdictionFee(uint256 ID, uint256 fee) external;

  /**
  * @notice Set the public address associated with a validator signing key, used
  * to sign off-chain attribute approvals, as `newSigningKey`.
  * @param newSigningKey address The address associated with signing key to set.
  */
  function setValidatorSigningKey(address newSigningKey) external;

  /**
  * @notice Add an attribute of the type with ID `attributeTypeID`, an attribute
  * value of `value`, and an associated validator fee of `validatorFee` to
  * account of `msg.sender` by passing in a signed attribute approval with
  * signature `signature`.
  * @param attributeTypeID uint256 The ID of the attribute type to add.
  * @param value uint256 The value for the attribute to add.
  * @param validatorFee uint256 The fee to be paid to the issuing validator.
  * @param signature bytes The signature from the validator attribute approval.
  */
  function addAttribute(
    uint256 attributeTypeID,
    uint256 value,
    uint256 validatorFee,
    bytes signature
  ) external payable;

  /**
  * @notice Remove an attribute of the type with ID `attributeTypeID` from
  * account of `msg.sender`.
  * @param attributeTypeID uint256 The ID of the attribute type to remove.
  */
  function removeAttribute(uint256 attributeTypeID) external;

  /**
  * @notice Add an attribute of the type with ID `attributeTypeID`, an attribute
  * value of `value`, and an associated validator fee of `validatorFee` to
  * account `account` by passing in a signed attribute approval with signature
  * `signature`.
  * @param account address The account to add the attribute to.
  * @param attributeTypeID uint256 The ID of the attribute type to add.
  * @param value uint256 The value for the attribute to add.
  * @param validatorFee uint256 The fee to be paid to the issuing validator.
  * @param signature bytes The signature from the validator attribute approval.
  * @dev Restricted attribute types can only be removed by issuing validators or
  * the jurisdiction itself.
  */
  function addAttributeFor(
    address account,
    uint256 attributeTypeID,
    uint256 value,
    uint256 validatorFee,
    bytes signature
  ) external payable;

  /**
  * @notice Remove an attribute of the type with ID `attributeTypeID` from
  * account of `account`.
  * @param account address The account to remove the attribute from.
  * @param attributeTypeID uint256 The ID of the attribute type to remove.
  * @dev Restricted attribute types can only be removed by issuing validators or
  * the jurisdiction itself.
  */
  function removeAttributeFor(address account, uint256 attributeTypeID) external;

  /**
   * @notice Invalidate a signed attribute approval before it has been set by
   * supplying the hash of the approval `hash` and the signature `signature`.
   * @param hash bytes32 The hash of the attribute approval.
   * @param signature bytes The hash's signature, resolving to the signing key.
   * @dev Attribute approvals can only be removed by issuing validators or the
   * jurisdiction itself.
   */
  function invalidateAttributeApproval(
    bytes32 hash,
    bytes signature
  ) external;

  /**
   * @notice Get the hash of a given attribute approval.
   * @param account address The account specified by the attribute approval.
   * @param operator address An optional account permitted to submit approval.
   * @param attributeTypeID uint256 The ID of the attribute type in question.
   * @param value uint256 The value of the attribute in the approval.
   * @param fundsRequired uint256 The amount to be included with the approval.
   * @param validatorFee uint256 The required fee to be paid to the validator.
   * @return The hash of the attribute approval.
   */
  function getAttributeApprovalHash(
    address account,
    address operator,
    uint256 attributeTypeID,
    uint256 value,
    uint256 fundsRequired,
    uint256 validatorFee
  ) external view returns (bytes32 hash);

  /**
   * @notice Check if a given signed attribute approval is currently valid when
   * submitted directly by `msg.sender`.
   * @param attributeTypeID uint256 The ID of the attribute type in question.
   * @param value uint256 The value of the attribute in the approval.
   * @param fundsRequired uint256 The amount to be included with the approval.
   * @param validatorFee uint256 The required fee to be paid to the validator.
   * @param signature bytes The attribute approval signature, based on a hash of
   * the other parameters and the submitting account.
   * @return True if the approval is currently valid, false otherwise.
   */
  function canAddAttribute(
    uint256 attributeTypeID,
    uint256 value,
    uint256 fundsRequired,
    uint256 validatorFee,
    bytes signature
  ) external view returns (bool);

  /**
   * @notice Check if a given signed attribute approval is currently valid for a
   * given account when submitted by the operator at `msg.sender`.
   * @param account address The account specified by the attribute approval.
   * @param attributeTypeID uint256 The ID of the attribute type in question.
   * @param value uint256 The value of the attribute in the approval.
   * @param fundsRequired uint256 The amount to be included with the approval.
   * @param validatorFee uint256 The required fee to be paid to the validator.
   * @param signature bytes The attribute approval signature, based on a hash of
   * the other parameters and the submitting account.
   * @return True if the approval is currently valid, false otherwise.
   */
  function canAddAttributeFor(
    address account,
    uint256 attributeTypeID,
    uint256 value,
    uint256 fundsRequired,
    uint256 validatorFee,
    bytes signature
  ) external view returns (bool);

  /**
   * @notice Get comprehensive information on an attribute type with ID
   * `attributeTypeID`.
   * @param attributeTypeID uint256 The attribute type ID in question.
   * @return Information on the attribute type in question.
   */
  function getAttributeTypeInformation(
    uint256 attributeTypeID
  ) external view returns (
    string description,
    bool isRestricted,
    bool isOnlyPersonal,
    address secondarySource,
    uint256 secondaryId,
    uint256 minimumRequiredStake,
    uint256 jurisdictionFee
  );
  
  /**
   * @notice Get a validator's signing key.
   * @param validator address The account of the validator.
   * @return The account referencing the public component of the signing key.
   */
  function getValidatorSigningKey(
    address validator
  ) external view returns (
    address signingKey
  );
}

/**
 * @title Interface for checking attribute assignment on YES token and for token
 * recovery.
 */
interface IERC20 {
  function balanceOf(address) external view returns (uint256);
  function transfer(address, uint256) external returns (bool);
}

/**
 * @title An extended TPL jurisdiction for assigning attributes to addresses.
 */
contract ExtendedJurisdiction is Ownable, Pausable, AttributeRegistryInterface, BasicJurisdictionInterface, ExtendedJurisdictionInterface {
  using ECDSA for bytes32;
  using SafeMath for uint256;

  // validators are entities who can add or authorize addition of new attributes
  struct Validator {
    bool exists;
    uint256 index; // NOTE: consider use of uint88 to pack struct
    address signingKey;
    string description;
  }

  // attributes are properties that validators associate with specific addresses
  struct IssuedAttribute {
    bool exists;
    bool setPersonally;
    address operator;
    address validator;
    uint256 value;
    uint256 stake;
  }

  // attributes also have associated type - metadata common to each attribute
  struct AttributeType {
    bool exists;
    bool restricted;
    bool onlyPersonal;
    uint256 index; // NOTE: consider use of uint72 to pack struct
    address secondarySource;
    uint256 secondaryAttributeTypeID;
    uint256 minimumStake;
    uint256 jurisdictionFee;
    string description;
    mapping(address => bool) approvedValidators;
  }

  // top-level information about attribute types is held in a mapping of structs
  mapping(uint256 => AttributeType) private _attributeTypes;

  // the jurisdiction retains a mapping of addresses with assigned attributes
  mapping(address => mapping(uint256 => IssuedAttribute)) private _issuedAttributes;

  // there is also a mapping to identify all approved validators and their keys
  mapping(address => Validator) private _validators;

  // each registered signing key maps back to a specific validator
  mapping(address => address) private _signingKeys;

  // once attribute types are assigned to an ID, they cannot be modified
  mapping(uint256 => bytes32) private _attributeTypeHashes;

  // submitted attribute approvals are retained to prevent reuse after removal 
  mapping(bytes32 => bool) private _invalidAttributeApprovalHashes;

  // attribute approvals by validator are held in a mapping
  mapping(address => uint256[]) private _validatorApprovals;

   // attribute approval index by validator is tracked as well
  mapping(address => mapping(uint256 => uint256)) private _validatorApprovalsIndex;

  // IDs for all supplied attributes are held in an array (enables enumeration)
  uint256[] private _attributeIDs;

  // addresses for all designated validators are also held in an array
  address[] private _validatorAccounts;

  // track any recoverable funds locked in the contract 
  uint256 private _recoverableFunds;

  /**
  * @notice Add an attribute type with ID `ID` and description `description` to
  * the jurisdiction.
  * @param ID uint256 The ID of the attribute type to add.
  * @param description string A description of the attribute type.
  * @dev Once an attribute type is added with a given ID, the description of the
  * attribute type cannot be changed, even if the attribute type is removed and
  * added back later.
  */
  function addAttributeType(
    uint256 ID,
    string description
  ) external onlyOwner whenNotPaused {
    // prevent existing attributes with the same id from being overwritten
    require(
      !isAttributeType(ID),
      "an attribute type with the provided ID already exists"
    );

    // calculate a hash of the attribute type based on the type's properties
    bytes32 hash = keccak256(
      abi.encodePacked(
        ID, false, description
      )
    );

    // store hash if attribute type is the first one registered with provided ID
    if (_attributeTypeHashes[ID] == bytes32(0)) {
      _attributeTypeHashes[ID] = hash;
    }

    // prevent addition if different attribute type with the same ID has existed
    require(
      hash == _attributeTypeHashes[ID],
      "attribute type properties must match initial properties assigned to ID"
    );

    // set the attribute mapping, assigning the index as the end of attributeID
    _attributeTypes[ID] = AttributeType({
      exists: true,
      restricted: false, // when true: users can't remove attribute
      onlyPersonal: false, // when true: operators can't add attribute
      index: _attributeIDs.length,
      secondarySource: address(0), // the address of a remote registry
      secondaryAttributeTypeID: uint256(0), // the attribute type id to query
      minimumStake: uint256(0), // when > 0: users must stake ether to set
      jurisdictionFee: uint256(0),
      description: description
      // NOTE: no approvedValidators variable declaration - must be added later
    });
    
    // add the attribute type id to the end of the attributeID array
    _attributeIDs.push(ID);

    // log the addition of the attribute type
    emit AttributeTypeAdded(ID, description);
  }

  /**
  * @notice Add a restricted attribute type with ID `ID` and description
  * `description` to the jurisdiction. Restricted attribute types can only be
  * removed by the issuing validator or the jurisdiction.
  * @param ID uint256 The ID of the restricted attribute type to add.
  * @param description string A description of the restricted attribute type.
  * @dev Once an attribute type is added with a given ID, the description or the
  * restricted status of the attribute type cannot be changed, even if the
  * attribute type is removed and added back later.
  */
  function addRestrictedAttributeType(
    uint256 ID,
    string description
  ) external onlyOwner whenNotPaused {
    // prevent existing attributes with the same id from being overwritten
    require(
      !isAttributeType(ID),
      "an attribute type with the provided ID already exists"
    );

    // calculate a hash of the attribute type based on the type's properties
    bytes32 hash = keccak256(
      abi.encodePacked(
        ID, true, description
      )
    );

    // store hash if attribute type is the first one registered with provided ID
    if (_attributeTypeHashes[ID] == bytes32(0)) {
      _attributeTypeHashes[ID] = hash;
    }

    // prevent addition if different attribute type with the same ID has existed
    require(
      hash == _attributeTypeHashes[ID],
      "attribute type properties must match initial properties assigned to ID"
    );

    // set the attribute mapping, assigning the index as the end of attributeID
    _attributeTypes[ID] = AttributeType({
      exists: true,
      restricted: true, // when true: users can't remove attribute
      onlyPersonal: false, // when true: operators can't add attribute
      index: _attributeIDs.length,
      secondarySource: address(0), // the address of a remote registry
      secondaryAttributeTypeID: uint256(0), // the attribute type id to query
      minimumStake: uint256(0), // when > 0: users must stake ether to set
      jurisdictionFee: uint256(0),
      description: description
      // NOTE: no approvedValidators variable declaration - must be added later
    });
    
    // add the attribute type id to the end of the attributeID array
    _attributeIDs.push(ID);

    // log the addition of the attribute type
    emit AttributeTypeAdded(ID, description);
  }

  /**
  * @notice Enable or disable a restriction for a given attribute type ID `ID`
  * that prevents attributes of the given type from being set by operators based
  * on the provided value for `onlyPersonal`.
  * @param ID uint256 The attribute type ID in question.
  * @param onlyPersonal bool Whether the address may only be set personally.
  */
  function setAttributeTypeOnlyPersonal(uint256 ID, bool onlyPersonal) external {
    // if the attribute type ID does not exist, there is nothing to remove
    require(
      isAttributeType(ID),
      "unable to set to only personal, no attribute type with the provided ID"
    );

    // modify the attribute type in the mapping
    _attributeTypes[ID].onlyPersonal = onlyPersonal;
  }

  /**
  * @notice Set a secondary source for a given attribute type ID `ID`, with an
  * address `registry` of the secondary source in question and a given
  * `sourceAttributeTypeID` for attribute type ID to check on the secondary
  * source. The secondary source will only be checked for the given attribute in
  * cases where no attribute of the given attribute type ID is assigned locally.
  * @param ID uint256 The attribute type ID to set the secondary source for.
  * @param attributeRegistry address The secondary attribute registry account.
  * @param sourceAttributeTypeID uint256 The attribute type ID on the secondary
  * source to check.
  * @dev To remove a secondary source on an attribute type, the registry address
  * should be set to the null address.
  */
  function setAttributeTypeSecondarySource(
    uint256 ID,
    address attributeRegistry,
    uint256 sourceAttributeTypeID
  ) external {
    // if the attribute type ID does not exist, there is nothing to remove
    require(
      isAttributeType(ID),
      "unable to set secondary source, no attribute type with the provided ID"
    );

    // modify the attribute type in the mapping
    _attributeTypes[ID].secondarySource = attributeRegistry;
    _attributeTypes[ID].secondaryAttributeTypeID = sourceAttributeTypeID;
  }

  /**
  * @notice Set a minimum required stake for a given attribute type ID `ID` and
  * an amount of `stake`, to be locked in the jurisdiction upon assignment of
  * attributes of the given type. The stake will be applied toward a transaction
  * rebate in the event the attribute is revoked, with the remainder returned to
  * the staker.
  * @param ID uint256 The attribute type ID to set a minimum required stake for.
  * @param minimumRequiredStake uint256 The minimum required funds to lock up.
  * @dev To remove a stake requirement from an attribute type, the stake amount
  * should be set to 0.
  */
  function setAttributeTypeMinimumRequiredStake(
    uint256 ID,
    uint256 minimumRequiredStake
  ) external {
    // if the attribute type ID does not exist, there is nothing to remove
    require(
      isAttributeType(ID),
      "unable to set minimum stake, no attribute type with the provided ID"
    );

    // modify the attribute type in the mapping
    _attributeTypes[ID].minimumStake = minimumRequiredStake;
  }

  /**
  * @notice Set a required fee for a given attribute type ID `ID` and an amount
  * of `fee`, to be paid to the owner of the jurisdiction upon assignment of
  * attributes of the given type.
  * @param ID uint256 The attribute type ID to set the required fee for.
  * @param fee uint256 The required fee amount to be paid upon assignment.
  * @dev To remove a fee requirement from an attribute type, the fee amount
  * should be set to 0.
  */
  function setAttributeTypeJurisdictionFee(uint256 ID, uint256 fee) external {
    // if the attribute type ID does not exist, there is nothing to remove
    require(
      isAttributeType(ID),
      "unable to set fee, no attribute type with the provided ID"
    );

    // modify the attribute type in the mapping
    _attributeTypes[ID].jurisdictionFee = fee;
  }

  /**
  * @notice Remove the attribute type with ID `ID` from the jurisdiction.
  * @param ID uint256 The ID of the attribute type to remove.
  * @dev All issued attributes of the given type will become invalid upon
  * removal, but will become valid again if the attribute is reinstated.
  */
  function removeAttributeType(uint256 ID) external onlyOwner whenNotPaused {
    // if the attribute type ID does not exist, there is nothing to remove
    require(
      isAttributeType(ID),
      "unable to remove, no attribute type with the provided ID"
    );

    // get the attribute ID at the last index of the array
    uint256 lastAttributeID = _attributeIDs[_attributeIDs.length.sub(1)];

    // set the attributeID at attribute-to-delete.index to the last attribute ID
    _attributeIDs[_attributeTypes[ID].index] = lastAttributeID;

    // update the index of the attribute type that was moved
    _attributeTypes[lastAttributeID].index = _attributeTypes[ID].index;
    
    // remove the (now duplicate) attribute ID at the end by trimming the array
    _attributeIDs.length--;

    // delete the attribute type's record from the mapping
    delete _attributeTypes[ID];

    // log the removal of the attribute type
    emit AttributeTypeRemoved(ID);
  }

  /**
  * @notice Add account `validator` as a validator with a description
  * `description` who can be approved to set attributes of specific types.
  * @param validator address The account to assign as the validator.
  * @param description string A description of the validator.
  * @dev Note that the jurisdiction can add iteslf as a validator if desired.
  */
  function addValidator(
    address validator,
    string description
  ) external onlyOwner whenNotPaused {
    // check that an empty address was not provided by mistake
    require(validator != address(0), "must supply a valid address");

    // prevent existing validators from being overwritten
    require(
      !isValidator(validator),
      "a validator with the provided address already exists"
    );

    // prevent duplicate signing keys from being created
    require(
      _signingKeys[validator] == address(0),
      "a signing key matching the provided address already exists"
    );
    
    // create a record for the validator
    _validators[validator] = Validator({
      exists: true,
      index: _validatorAccounts.length,
      signingKey: validator, // NOTE: this will be initially set to same address
      description: description
    });

    // set the initial signing key (the validator's address) resolving to itself
    _signingKeys[validator] = validator;

    // add the validator to the end of the _validatorAccounts array
    _validatorAccounts.push(validator);
    
    // log the addition of the new validator
    emit ValidatorAdded(validator, description);
  }

  /**
  * @notice Remove the validator at address `validator` from the jurisdiction.
  * @param validator address The account of the validator to remove.
  * @dev Any attributes issued by the validator will become invalid upon their
  * removal. If the validator is reinstated, those attributes will become valid
  * again. Any approvals to issue attributes of a given type will need to be
  * set from scratch in the event a validator is reinstated.
  */
  function removeValidator(address validator) external onlyOwner whenNotPaused {
    // check that a validator exists at the provided address
    require(
      isValidator(validator),
      "unable to remove, no validator located at the provided address"
    );

    // first, start removing validator approvals until gas is exhausted
    while (_validatorApprovals[validator].length > 0 && gasleft() > 25000) {
      // locate the index of last attribute ID in the validator approval group
      uint256 lastIndex = _validatorApprovals[validator].length.sub(1);

      // locate the validator approval to be removed
      uint256 targetApproval = _validatorApprovals[validator][lastIndex];

      // remove the record of the approval from the associated attribute type
      delete _attributeTypes[targetApproval].approvedValidators[validator];

      // remove the record of the index of the approval
      delete _validatorApprovalsIndex[validator][targetApproval];

      // drop the last attribute ID from the validator approval group
      _validatorApprovals[validator].length--;
    }

    // require that all approvals were successfully removed
    require(
      _validatorApprovals[validator].length == 0,
      "Cannot remove validator - first remove any existing validator approvals"
    );

    // get the validator address at the last index of the array
    address lastAccount = _validatorAccounts[_validatorAccounts.length.sub(1)];

    // set the address at validator-to-delete.index to last validator address
    _validatorAccounts[_validators[validator].index] = lastAccount;

    // update the index of the attribute type that was moved
    _validators[lastAccount].index = _validators[validator].index;
    
    // remove (duplicate) validator address at the end by trimming the array
    _validatorAccounts.length--;

    // remove the validator's signing key from its mapping
    delete _signingKeys[_validators[validator].signingKey];

    // remove the validator record
    delete _validators[validator];

    // log the removal of the validator
    emit ValidatorRemoved(validator);
  }

  /**
  * @notice Approve the validator at address `validator` to issue attributes of
  * the type with ID `attributeTypeID`.
  * @param validator address The account of the validator to approve.
  * @param attributeTypeID uint256 The ID of the approved attribute type.
  */
  function addValidatorApproval(
    address validator,
    uint256 attributeTypeID
  ) external onlyOwner whenNotPaused {
    // check that the attribute is predefined and that the validator exists
    require(
      isValidator(validator) && isAttributeType(attributeTypeID),
      "must specify both a valid attribute and an available validator"
    );

    // check that the validator is not already approved
    require(
      !_attributeTypes[attributeTypeID].approvedValidators[validator],
      "validator is already approved on the provided attribute"
    );

    // set the validator approval status on the attribute
    _attributeTypes[attributeTypeID].approvedValidators[validator] = true;

    // add the record of the index of the validator approval to be added
    uint256 index = _validatorApprovals[validator].length;
    _validatorApprovalsIndex[validator][attributeTypeID] = index;

    // include the attribute type in the validator approval mapping
    _validatorApprovals[validator].push(attributeTypeID);

    // log the addition of the validator's attribute type approval
    emit ValidatorApprovalAdded(validator, attributeTypeID);
  }

  /**
  * @notice Deny the validator at address `validator` the ability to continue to
  * issue attributes of the type with ID `attributeTypeID`.
  * @param validator address The account of the validator with removed approval.
  * @param attributeTypeID uint256 The ID of the attribute type to unapprove.
  * @dev Any attributes of the specified type issued by the validator in
  * question will become invalid once the approval is removed. If the approval
  * is reinstated, those attributes will become valid again. The approval will
  * also be removed if the approved validator is removed.
  */
  function removeValidatorApproval(
    address validator,
    uint256 attributeTypeID
  ) external onlyOwner whenNotPaused {
    // check that the attribute is predefined and that the validator exists
    require(
      canValidate(validator, attributeTypeID),
      "unable to remove validator approval, attribute is already unapproved"
    );

    // remove the validator approval status from the attribute
    delete _attributeTypes[attributeTypeID].approvedValidators[validator];

    // locate the index of the last validator approval
    uint256 lastIndex = _validatorApprovals[validator].length.sub(1);

    // locate the last attribute ID in the validator approval group
    uint256 lastAttributeID = _validatorApprovals[validator][lastIndex];

    // locate the index of the validator approval to be removed
    uint256 index = _validatorApprovalsIndex[validator][attributeTypeID];

    // replace the validator approval with the last approval in the array
    _validatorApprovals[validator][index] = lastAttributeID;

    // drop the last attribute ID from the validator approval group
    _validatorApprovals[validator].length--;

    // update the record of the index of the swapped-in approval
    _validatorApprovalsIndex[validator][lastAttributeID] = index;

    // remove the record of the index of the removed approval
    delete _validatorApprovalsIndex[validator][attributeTypeID];
    
    // log the removal of the validator's attribute type approval
    emit ValidatorApprovalRemoved(validator, attributeTypeID);
  }

  /**
  * @notice Set the public address associated with a validator signing key, used
  * to sign off-chain attribute approvals, as `newSigningKey`.
  * @param newSigningKey address The address associated with signing key to set.
  * @dev Consider having the validator submit a signed proof demonstrating that
  * the provided signing key is indeed a signing key in their control - this
  * helps mitigate the fringe attack vector where a validator could set the
  * address of another validator candidate (especially in the case of a deployed
  * smart contract) as their "signing key" in order to block them from being
  * added to the jurisdiction (due to the required property of signing keys
  * being unique, coupled with the fact that new validators are set up with
  * their address as the default initial signing key).
  */
  function setValidatorSigningKey(address newSigningKey) external {
    require(
      isValidator(msg.sender),
      "only validators may modify validator signing keys");
 
    // prevent duplicate signing keys from being created
    require(
      _signingKeys[newSigningKey] == address(0),
      "a signing key matching the provided address already exists"
    );

    // remove validator address as the resolved value for the old key
    delete _signingKeys[_validators[msg.sender].signingKey];

    // set the signing key to the new value
    _validators[msg.sender].signingKey = newSigningKey;

    // add validator address as the resolved value for the new key
    _signingKeys[newSigningKey] = msg.sender;

    // log the modification of the signing key
    emit ValidatorSigningKeyModified(msg.sender, newSigningKey);
  }

  /**
  * @notice Issue an attribute of the type with ID `attributeTypeID` and a value
  * of `value` to `account` if `message.caller.address()` is approved validator.
  * @param account address The account to issue the attribute on.
  * @param attributeTypeID uint256 The ID of the attribute type to issue.
  * @param value uint256 An optional value for the issued attribute.
  * @dev Existing attributes of the given type on the address must be removed
  * in order to set a new attribute. Be aware that ownership of the account to
  * which the attribute is assigned may still be transferable - restricting
  * assignment to externally-owned accounts may partially alleviate this issue.
  */
  function issueAttribute(
    address account,
    uint256 attributeTypeID,
    uint256 value
  ) external payable whenNotPaused {
    require(
      canValidate(msg.sender, attributeTypeID),
      "only approved validators may assign attributes of this type"
    );

    require(
      !_issuedAttributes[account][attributeTypeID].exists,
      "duplicate attributes are not supported, remove existing attribute first"
    );

    // retrieve required minimum stake and jurisdiction fees on attribute type
    uint256 minimumStake = _attributeTypes[attributeTypeID].minimumStake;
    uint256 jurisdictionFee = _attributeTypes[attributeTypeID].jurisdictionFee;
    uint256 stake = msg.value.sub(jurisdictionFee);

    require(
      stake >= minimumStake,
      "attribute requires a greater value than is currently provided"
    );

    // store attribute value and amount of ether staked in correct scope
    _issuedAttributes[account][attributeTypeID] = IssuedAttribute({
      exists: true,
      setPersonally: false,
      operator: address(0),
      validator: msg.sender,
      value: value,
      stake: stake
    });

    // log the addition of the attribute
    emit AttributeAdded(msg.sender, account, attributeTypeID, value);

    // log allocation of staked funds to the attribute if applicable
    if (stake > 0) {
      emit StakeAllocated(msg.sender, attributeTypeID, stake);
    }

    // pay jurisdiction fee to the owner of the jurisdiction if applicable
    if (jurisdictionFee > 0) {
      // NOTE: send is chosen over transfer to prevent cases where a improperly
      // configured fallback function could block addition of an attribute
      if (owner().send(jurisdictionFee)) {
        emit FeePaid(owner(), msg.sender, attributeTypeID, jurisdictionFee);
      } else {
        _recoverableFunds = _recoverableFunds.add(jurisdictionFee);
      }
    }
  }

  /**
  * @notice Revoke the attribute of the type with ID `attributeTypeID` from
  * `account` if `message.caller.address()` is the issuing validator.
  * @param account address The account to issue the attribute on.
  * @param attributeTypeID uint256 The ID of the attribute type to issue.
  * @dev Validators may still revoke issued attributes even after they have been
  * removed or had their approval to issue the attribute type removed - this
  * enables them to address any objectionable issuances before being reinstated.
  */
  function revokeAttribute(
    address account,
    uint256 attributeTypeID
  ) external whenNotPaused {
    // ensure that an attribute with the given account and attribute exists
    require(
      _issuedAttributes[account][attributeTypeID].exists,
      "only existing attributes may be removed"
    );

    // determine the assigned validator on the user attribute
    address validator = _issuedAttributes[account][attributeTypeID].validator;
    
    // caller must be either the jurisdiction owner or the assigning validator
    require(
      msg.sender == validator || msg.sender == owner(),
      "only jurisdiction or issuing validators may revoke arbitrary attributes"
    );

    // determine if attribute has any stake in order to refund transaction fee
    uint256 stake = _issuedAttributes[account][attributeTypeID].stake;

    // determine the correct address to refund the staked amount to
    address refundAddress;
    if (_issuedAttributes[account][attributeTypeID].setPersonally) {
      refundAddress = account;
    } else {
      address operator = _issuedAttributes[account][attributeTypeID].operator;
      if (operator == address(0)) {
        refundAddress = validator;
      } else {
        refundAddress = operator;
      }
    }

    // remove the attribute from the designated user account
    delete _issuedAttributes[account][attributeTypeID];

    // log the removal of the attribute
    emit AttributeRemoved(validator, account, attributeTypeID);

    // pay out any refunds and return the excess stake to the user
    if (stake > 0 && address(this).balance >= stake) {
      // NOTE: send is chosen over transfer to prevent cases where a malicious
      // fallback function could forcibly block an attribute's removal. Another
      // option is to allow a user to pull the staked amount after the removal.
      // NOTE: refine transaction rebate gas calculation! Setting this value too
      // high gives validators the incentive to revoke valid attributes. Simply
      // checking against gasLeft() & adding the final gas usage won't give the
      // correct transaction cost, as freeing space refunds gas upon completion.
      uint256 transactionGas = 37700; // <--- WARNING: THIS IS APPROXIMATE
      uint256 transactionCost = transactionGas.mul(tx.gasprice);

      // if stake exceeds allocated transaction cost, refund user the difference
      if (stake > transactionCost) {
        // refund the excess stake to the address that contributed the funds
        if (refundAddress.send(stake.sub(transactionCost))) {
          emit StakeRefunded(
            refundAddress,
            attributeTypeID,
            stake.sub(transactionCost)
          );
        } else {
          _recoverableFunds = _recoverableFunds.add(stake.sub(transactionCost));
        }

        // emit an event for the payment of the transaction rebate
        emit TransactionRebatePaid(
          tx.origin,
          refundAddress,
          attributeTypeID,
          transactionCost
        );

        // refund the cost of the transaction to the trasaction submitter
        tx.origin.transfer(transactionCost);

      // otherwise, allocate entire stake to partially refunding the transaction
      } else {
        // emit an event for the payment of the partial transaction rebate
        emit TransactionRebatePaid(
          tx.origin,
          refundAddress,
          attributeTypeID,
          stake
        );

        // refund the partial cost of the transaction to trasaction submitter
        tx.origin.transfer(stake);
      }
    }
  }

  /**
  * @notice Add an attribute of the type with ID `attributeTypeID`, an attribute
  * value of `value`, and an associated validator fee of `validatorFee` to
  * account of `msg.sender` by passing in a signed attribute approval with
  * signature `signature`.
  * @param attributeTypeID uint256 The ID of the attribute type to add.
  * @param value uint256 The value for the attribute to add.
  * @param validatorFee uint256 The fee to be paid to the issuing validator.
  * @param signature bytes The signature from the validator attribute approval.
  */
  function addAttribute(
    uint256 attributeTypeID,
    uint256 value,
    uint256 validatorFee,
    bytes signature
  ) external payable {
    // NOTE: determine best course of action when the attribute already exists
    // NOTE: consider utilizing bytes32 type for attributes and values
    // NOTE: does not currently support an extraData parameter, consider adding
    // NOTE: if msg.sender is a proxy contract, its ownership may be transferred
    // at will, circumventing any token transfer restrictions. Restricting usage
    // to only externally owned accounts may partially alleviate this concern.
    // NOTE: cosider including a salt (or better, nonce) parameter so that when
    // a user adds an attribute, then it gets revoked, the user can get a new
    // signature from the validator and renew the attribute using that. The main
    // downside is that everyone will have to keep track of the extra parameter.
    // Another solution is to just modifiy the required stake or fee amount.

    require(
      !_issuedAttributes[msg.sender][attributeTypeID].exists,
      "duplicate attributes are not supported, remove existing attribute first"
    );

    // retrieve required minimum stake and jurisdiction fees on attribute type
    uint256 minimumStake = _attributeTypes[attributeTypeID].minimumStake;
    uint256 jurisdictionFee = _attributeTypes[attributeTypeID].jurisdictionFee;
    uint256 stake = msg.value.sub(validatorFee).sub(jurisdictionFee);

    require(
      stake >= minimumStake,
      "attribute requires a greater value than is currently provided"
    );

    // signed data hash constructed according to EIP-191-0x45 to prevent replays
    bytes32 hash = keccak256(
      abi.encodePacked(
        address(this),
        msg.sender,
        address(0),
        msg.value,
        validatorFee,
        attributeTypeID,
        value
      )
    );

    require(
      !_invalidAttributeApprovalHashes[hash],
      "signed attribute approvals from validators may not be reused"
    );

    // extract the key used to sign the message hash
    address signingKey = hash.toEthSignedMessageHash().recover(signature);

    // retrieve the validator who controls the extracted key
    address validator = _signingKeys[signingKey];

    require(
      canValidate(validator, attributeTypeID),
      "signature does not match an approved validator for given attribute type"
    );

    // store attribute value and amount of ether staked in correct scope
    _issuedAttributes[msg.sender][attributeTypeID] = IssuedAttribute({
      exists: true,
      setPersonally: true,
      operator: address(0),
      validator: validator,
      value: value,
      stake: stake
      // NOTE: no extraData included
    });

    // flag the signed approval as invalid once it's been used to set attribute
    _invalidAttributeApprovalHashes[hash] = true;

    // log the addition of the attribute
    emit AttributeAdded(validator, msg.sender, attributeTypeID, value);

    // log allocation of staked funds to the attribute if applicable
    if (stake > 0) {
      emit StakeAllocated(msg.sender, attributeTypeID, stake);
    }

    // pay jurisdiction fee to the owner of the jurisdiction if applicable
    if (jurisdictionFee > 0) {
      // NOTE: send is chosen over transfer to prevent cases where a improperly
      // configured fallback function could block addition of an attribute
      if (owner().send(jurisdictionFee)) {
        emit FeePaid(owner(), msg.sender, attributeTypeID, jurisdictionFee);
      } else {
        _recoverableFunds = _recoverableFunds.add(jurisdictionFee);
      }
    }

    // pay validator fee to the issuing validator's address if applicable
    if (validatorFee > 0) {
      // NOTE: send is chosen over transfer to prevent cases where a improperly
      // configured fallback function could block addition of an attribute
      if (validator.send(validatorFee)) {
        emit FeePaid(validator, msg.sender, attributeTypeID, validatorFee);
      } else {
        _recoverableFunds = _recoverableFunds.add(validatorFee);
      }
    }
  }

  /**
  * @notice Remove an attribute of the type with ID `attributeTypeID` from
  * account of `msg.sender`.
  * @param attributeTypeID uint256 The ID of the attribute type to remove.
  */
  function removeAttribute(uint256 attributeTypeID) external {
    // attributes may only be removed by the user if they are not restricted
    require(
      !_attributeTypes[attributeTypeID].restricted,
      "only jurisdiction or issuing validator may remove a restricted attribute"
    );

    require(
      _issuedAttributes[msg.sender][attributeTypeID].exists,
      "only existing attributes may be removed"
    );

    // determine the assigned validator on the user attribute
    address validator = _issuedAttributes[msg.sender][attributeTypeID].validator;

    // determine if the attribute has a staked value
    uint256 stake = _issuedAttributes[msg.sender][attributeTypeID].stake;

    // determine the correct address to refund the staked amount to
    address refundAddress;
    if (_issuedAttributes[msg.sender][attributeTypeID].setPersonally) {
      refundAddress = msg.sender;
    } else {
      address operator = _issuedAttributes[msg.sender][attributeTypeID].operator;
      if (operator == address(0)) {
        refundAddress = validator;
      } else {
        refundAddress = operator;
      }
    }    

    // remove the attribute from the user address
    delete _issuedAttributes[msg.sender][attributeTypeID];

    // log the removal of the attribute
    emit AttributeRemoved(validator, msg.sender, attributeTypeID);

    // if the attribute has any staked balance, refund it to the user
    if (stake > 0 && address(this).balance >= stake) {
      // NOTE: send is chosen over transfer to prevent cases where a malicious
      // fallback function could forcibly block an attribute's removal
      if (refundAddress.send(stake)) {
        emit StakeRefunded(refundAddress, attributeTypeID, stake);
      } else {
        _recoverableFunds = _recoverableFunds.add(stake);
      }
    }
  }

  /**
  * @notice Add an attribute of the type with ID `attributeTypeID`, an attribute
  * value of `value`, and an associated validator fee of `validatorFee` to
  * account `account` by passing in a signed attribute approval with signature
  * `signature`.
  * @param account address The account to add the attribute to.
  * @param attributeTypeID uint256 The ID of the attribute type to add.
  * @param value uint256 The value for the attribute to add.
  * @param validatorFee uint256 The fee to be paid to the issuing validator.
  * @param signature bytes The signature from the validator attribute approval.
  * @dev Restricted attribute types can only be removed by issuing validators or
  * the jurisdiction itself.
  */
  function addAttributeFor(
    address account,
    uint256 attributeTypeID,
    uint256 value,
    uint256 validatorFee,
    bytes signature
  ) external payable {
    // NOTE: determine best course of action when the attribute already exists
    // NOTE: consider utilizing bytes32 type for attributes and values
    // NOTE: does not currently support an extraData parameter, consider adding
    // NOTE: if msg.sender is a proxy contract, its ownership may be transferred
    // at will, circumventing any token transfer restrictions. Restricting usage
    // to only externally owned accounts may partially alleviate this concern.
    // NOTE: consider including a salt (or better, nonce) parameter so that when
    // a user adds an attribute, then it gets revoked, the user can get a new
    // signature from the validator and renew the attribute using that. The main
    // downside is that everyone will have to keep track of the extra parameter.
    // Another solution is to just modifiy the required stake or fee amount.

    // attributes may only be added by a third party if onlyPersonal is false
    require(
      !_attributeTypes[attributeTypeID].onlyPersonal,
      "only operatable attributes may be added on behalf of another address"
    );

    require(
      !_issuedAttributes[account][attributeTypeID].exists,
      "duplicate attributes are not supported, remove existing attribute first"
    );

    // retrieve required minimum stake and jurisdiction fees on attribute type
    uint256 minimumStake = _attributeTypes[attributeTypeID].minimumStake;
    uint256 jurisdictionFee = _attributeTypes[attributeTypeID].jurisdictionFee;
    uint256 stake = msg.value.sub(validatorFee).sub(jurisdictionFee);

    require(
      stake >= minimumStake,
      "attribute requires a greater value than is currently provided"
    );

    // signed data hash constructed according to EIP-191-0x45 to prevent replays
    bytes32 hash = keccak256(
      abi.encodePacked(
        address(this),
        account,
        msg.sender,
        msg.value,
        validatorFee,
        attributeTypeID,
        value
      )
    );

    require(
      !_invalidAttributeApprovalHashes[hash],
      "signed attribute approvals from validators may not be reused"
    );

    // extract the key used to sign the message hash
    address signingKey = hash.toEthSignedMessageHash().recover(signature);

    // retrieve the validator who controls the extracted key
    address validator = _signingKeys[signingKey];

    require(
      canValidate(validator, attributeTypeID),
      "signature does not match an approved validator for provided attribute"
    );

    // store attribute value and amount of ether staked in correct scope
    _issuedAttributes[account][attributeTypeID] = IssuedAttribute({
      exists: true,
      setPersonally: false,
      operator: msg.sender,
      validator: validator,
      value: value,
      stake: stake
      // NOTE: no extraData included
    });

    // flag the signed approval as invalid once it's been used to set attribute
    _invalidAttributeApprovalHashes[hash] = true;

    // log the addition of the attribute
    emit AttributeAdded(validator, account, attributeTypeID, value);

    // log allocation of staked funds to the attribute if applicable
    // NOTE: the staker is the entity that pays the fee here!
    if (stake > 0) {
      emit StakeAllocated(msg.sender, attributeTypeID, stake);
    }

    // pay jurisdiction fee to the owner of the jurisdiction if applicable
    if (jurisdictionFee > 0) {
      // NOTE: send is chosen over transfer to prevent cases where a improperly
      // configured fallback function could block addition of an attribute
      if (owner().send(jurisdictionFee)) {
        emit FeePaid(owner(), msg.sender, attributeTypeID, jurisdictionFee);
      } else {
        _recoverableFunds = _recoverableFunds.add(jurisdictionFee);
      }
    }

    // pay validator fee to the issuing validator's address if applicable
    if (validatorFee > 0) {
      // NOTE: send is chosen over transfer to prevent cases where a improperly
      // configured fallback function could block addition of an attribute
      if (validator.send(validatorFee)) {
        emit FeePaid(validator, msg.sender, attributeTypeID, validatorFee);
      } else {
        _recoverableFunds = _recoverableFunds.add(validatorFee);
      }
    }
  }

  /**
  * @notice Remove an attribute of the type with ID `attributeTypeID` from
  * account of `account`.
  * @param account address The account to remove the attribute from.
  * @param attributeTypeID uint256 The ID of the attribute type to remove.
  * @dev Restricted attribute types can only be removed by issuing validators or
  * the jurisdiction itself.
  */
  function removeAttributeFor(address account, uint256 attributeTypeID) external {
    // attributes may only be removed by the user if they are not restricted
    require(
      !_attributeTypes[attributeTypeID].restricted,
      "only jurisdiction or issuing validator may remove a restricted attribute"
    );

    require(
      _issuedAttributes[account][attributeTypeID].exists,
      "only existing attributes may be removed"
    );

    require(
      _issuedAttributes[account][attributeTypeID].operator == msg.sender,
      "only an assigning operator may remove attribute on behalf of an address"
    );

    // determine the assigned validator on the user attribute
    address validator = _issuedAttributes[account][attributeTypeID].validator;

    // determine if the attribute has a staked value
    uint256 stake = _issuedAttributes[account][attributeTypeID].stake;

    // remove the attribute from the user address
    delete _issuedAttributes[account][attributeTypeID];

    // log the removal of the attribute
    emit AttributeRemoved(validator, account, attributeTypeID);

    // if the attribute has any staked balance, refund it to the user
    if (stake > 0 && address(this).balance >= stake) {
      // NOTE: send is chosen over transfer to prevent cases where a malicious
      // fallback function could forcibly block an attribute's removal
      if (msg.sender.send(stake)) {
        emit StakeRefunded(msg.sender, attributeTypeID, stake);
      } else {
        _recoverableFunds = _recoverableFunds.add(stake);
      }
    }
  }

  /**
   * @notice Invalidate a signed attribute approval before it has been set by
   * supplying the hash of the approval `hash` and the signature `signature`.
   * @param hash bytes32 The hash of the attribute approval.
   * @param signature bytes The hash's signature, resolving to the signing key.
   * @dev Attribute approvals can only be removed by issuing validators or the
   * jurisdiction itself.
   */
  function invalidateAttributeApproval(
    bytes32 hash,
    bytes signature
  ) external {
    // determine the assigned validator on the signed attribute approval
    address validator = _signingKeys[
      hash.toEthSignedMessageHash().recover(signature) // signingKey
    ];
    
    // caller must be either the jurisdiction owner or the assigning validator
    require(
      msg.sender == validator || msg.sender == owner(),
      "only jurisdiction or issuing validator may invalidate attribute approval"
    );

    // add the hash to the set of invalid attribute approval hashes
    _invalidAttributeApprovalHashes[hash] = true;
  }

  /**
   * @notice Check if an attribute of the type with ID `attributeTypeID` has
   * been assigned to the account at `account` and is currently valid.
   * @param account address The account to check for a valid attribute.
   * @param attributeTypeID uint256 The ID of the attribute type to check for.
   * @return True if the attribute is assigned and valid, false otherwise.
   * @dev This function MUST return either true or false - i.e. calling this
   * function MUST NOT cause the caller to revert.
   */
  function hasAttribute(
    address account, 
    uint256 attributeTypeID
  ) external view returns (bool) {
    address validator = _issuedAttributes[account][attributeTypeID].validator;
    return (
      (
        _validators[validator].exists &&   // isValidator(validator)
        _attributeTypes[attributeTypeID].approvedValidators[validator] &&
        _attributeTypes[attributeTypeID].exists //isAttributeType(attributeTypeID)
      ) || (
        _attributeTypes[attributeTypeID].secondarySource != address(0) &&
        secondaryHasAttribute(
          _attributeTypes[attributeTypeID].secondarySource,
          account,
          _attributeTypes[attributeTypeID].secondaryAttributeTypeID
        )
      )
    );
  }

  /**
   * @notice Retrieve the value of the attribute of the type with ID
   * `attributeTypeID` on the account at `account`, assuming it is valid.
   * @param account address The account to check for the given attribute value.
   * @param attributeTypeID uint256 The ID of the attribute type to check for.
   * @return The attribute value if the attribute is valid, reverts otherwise.
   * @dev This function MUST revert if a directly preceding or subsequent
   * function call to `hasAttribute` with identical `account` and
   * `attributeTypeID` parameters would return false.
   */
  function getAttributeValue(
    address account,
    uint256 attributeTypeID
  ) external view returns (uint256 value) {
    // gas optimization: get validator & call canValidate function body directly
    address validator = _issuedAttributes[account][attributeTypeID].validator;
    if (
      _validators[validator].exists &&   // isValidator(validator)
      _attributeTypes[attributeTypeID].approvedValidators[validator] &&
      _attributeTypes[attributeTypeID].exists //isAttributeType(attributeTypeID)
    ) {
      return _issuedAttributes[account][attributeTypeID].value;
    } else if (
      _attributeTypes[attributeTypeID].secondarySource != address(0)
    ) {
      // if attributeTypeID = uint256 of 'wyre-yes-token', use special handling
      if (_attributeTypes[attributeTypeID].secondaryAttributeTypeID == 2423228754106148037712574142965102) {
        require(
          IERC20(
            _attributeTypes[attributeTypeID].secondarySource
          ).balanceOf(account) >= 1,
          "no Yes Token has been issued to the provided account"
        );
        return 1; // this could also return a specific yes token's country code?
      }

      // first ensure hasAttribute on the secondary source returns true
      require(
        AttributeRegistryInterface(
          _attributeTypes[attributeTypeID].secondarySource
        ).hasAttribute(
          account, _attributeTypes[attributeTypeID].secondaryAttributeTypeID
        ),
        "attribute of the provided type is not assigned to the provided account"
      );

      return (
        AttributeRegistryInterface(
          _attributeTypes[attributeTypeID].secondarySource
        ).getAttributeValue(
          account, _attributeTypes[attributeTypeID].secondaryAttributeTypeID
        )
      );
    }

    // NOTE: checking for values of invalid attributes will revert
    revert("could not find an attribute value at the provided account and ID");
  }

  /**
   * @notice Determine if a validator at account `validator` is able to issue
   * attributes of the type with ID `attributeTypeID`.
   * @param validator address The account of the validator.
   * @param attributeTypeID uint256 The ID of the attribute type to check.
   * @return True if the validator can issue attributes of the given type, false
   * otherwise.
   */
  function canIssueAttributeType(
    address validator,
    uint256 attributeTypeID
  ) external view returns (bool) {
    return canValidate(validator, attributeTypeID);
  }

  /**
   * @notice Get a description of the attribute type with ID `attributeTypeID`.
   * @param attributeTypeID uint256 The ID of the attribute type to check for.
   * @return A description of the attribute type.
   */
  function getAttributeTypeDescription(
    uint256 attributeTypeID
  ) external view returns (
    string description
  ) {
    return _attributeTypes[attributeTypeID].description;
  }

  /**
   * @notice Get comprehensive information on an attribute type with ID
   * `attributeTypeID`.
   * @param attributeTypeID uint256 The attribute type ID in question.
   * @return Information on the attribute type in question.
   */
  function getAttributeTypeInformation(
    uint256 attributeTypeID
  ) external view returns (
    string description,
    bool isRestricted,
    bool isOnlyPersonal,
    address secondarySource,
    uint256 secondaryAttributeTypeID,
    uint256 minimumRequiredStake,
    uint256 jurisdictionFee
  ) {
    return (
      _attributeTypes[attributeTypeID].description,
      _attributeTypes[attributeTypeID].restricted,
      _attributeTypes[attributeTypeID].onlyPersonal,
      _attributeTypes[attributeTypeID].secondarySource,
      _attributeTypes[attributeTypeID].secondaryAttributeTypeID,
      _attributeTypes[attributeTypeID].minimumStake,
      _attributeTypes[attributeTypeID].jurisdictionFee
    );
  }

  /**
   * @notice Get a description of the validator at account `validator`.
   * @param validator address The account of the validator in question.
   * @return A description of the validator.
   */
  function getValidatorDescription(
    address validator
  ) external view returns (
    string description
  ) {
    return _validators[validator].description;
  }

  /**
   * @notice Get the signing key of the validator at account `validator`.
   * @param validator address The account of the validator in question.
   * @return The signing key of the validator.
   */
  function getValidatorSigningKey(
    address validator
  ) external view returns (
    address signingKey
  ) {
    return _validators[validator].signingKey;
  }

  /**
   * @notice Find the validator that issued the attribute of the type with ID
   * `attributeTypeID` on the account at `account` and determine if the
   * validator is still valid.
   * @param account address The account that contains the attribute be checked.
   * @param attributeTypeID uint256 The ID of the attribute type in question.
   * @return The validator and the current status of the validator as it
   * pertains to the attribute type in question.
   * @dev if no attribute of the given attribute type exists on the account, the
   * function will return (address(0), false).
   */
  function getAttributeValidator(
    address account,
    uint256 attributeTypeID
  ) external view returns (
    address validator,
    bool isStillValid
  ) {
    address issuer = _issuedAttributes[account][attributeTypeID].validator;
    return (issuer, canValidate(issuer, attributeTypeID));
  }

  /**
   * @notice Count the number of attribute types defined by the registry.
   * @return The number of available attribute types.
   * @dev This function MUST return a positive integer value  - i.e. calling
   * this function MUST NOT cause the caller to revert.
   */
  function countAttributeTypes() external view returns (uint256) {
    return _attributeIDs.length;
  }

  /**
   * @notice Get the ID of the attribute type at index `index`.
   * @param index uint256 The index of the attribute type in question.
   * @return The ID of the attribute type.
   * @dev This function MUST revert if the provided `index` value falls outside
   * of the range of the value returned from a directly preceding or subsequent
   * function call to `countAttributeTypes`. It MUST NOT revert if the provided
   * `index` value falls inside said range.
   */
  function getAttributeTypeID(uint256 index) external view returns (uint256) {
    require(
      index < _attributeIDs.length,
      "provided index is outside of the range of defined attribute type IDs"
    );

    return _attributeIDs[index];
  }

  /**
   * @notice Get the IDs of all available attribute types on the jurisdiction.
   * @return A dynamic array containing all available attribute type IDs.
   */
  function getAttributeTypeIDs() external view returns (uint256[]) {
    return _attributeIDs;
  }

  /**
   * @notice Count the number of validators defined by the jurisdiction.
   * @return The number of defined validators.
   */
  function countValidators() external view returns (uint256) {
    return _validatorAccounts.length;
  }

  /**
   * @notice Get the account of the validator at index `index`.
   * @param index uint256 The index of the validator in question.
   * @return The account of the validator.
   */
  function getValidator(
    uint256 index
  ) external view returns (address) {
    return _validatorAccounts[index];
  }

  /**
   * @notice Get the accounts of all available validators on the jurisdiction.
   * @return A dynamic array containing all available validator accounts.
   */
  function getValidators() external view returns (address[]) {
    return _validatorAccounts;
  }

  /**
   * @notice Determine if the interface ID `interfaceID` is supported (ERC-165)
   * @param interfaceID bytes4 The interface ID in question.
   * @return True if the interface is supported, false otherwise.
   * @dev this function will produce a compiler warning recommending that the
   * visibility be set to pure, but the interface expects a view function.
   * Supported interfaces include ERC-165 (0x01ffc9a7) and the attribute
   * registry interface (0x5f46473f).
   */
  function supportsInterface(bytes4 interfaceID) external view returns (bool) {
    return (
      interfaceID == this.supportsInterface.selector || // ERC165
      interfaceID == (
        this.hasAttribute.selector 
        ^ this.getAttributeValue.selector
        ^ this.countAttributeTypes.selector
        ^ this.getAttributeTypeID.selector
      ) // AttributeRegistryInterface
    ); // 0x01ffc9a7 || 0x5f46473f
  }

  /**
   * @notice Get the hash of a given attribute approval.
   * @param account address The account specified by the attribute approval.
   * @param operator address An optional account permitted to submit approval.
   * @param attributeTypeID uint256 The ID of the attribute type in question.
   * @param value uint256 The value of the attribute in the approval.
   * @param fundsRequired uint256 The amount to be included with the approval.
   * @param validatorFee uint256 The required fee to be paid to the validator.
   * @return The hash of the attribute approval.
   */
  function getAttributeApprovalHash(
    address account,
    address operator,
    uint256 attributeTypeID,
    uint256 value,
    uint256 fundsRequired,
    uint256 validatorFee
  ) external view returns (
    bytes32 hash
  ) {
    return calculateAttributeApprovalHash(
      account,
      operator,
      attributeTypeID,
      value,
      fundsRequired,
      validatorFee
    );
  }

  /**
   * @notice Check if a given signed attribute approval is currently valid when
   * submitted directly by `msg.sender`.
   * @param attributeTypeID uint256 The ID of the attribute type in question.
   * @param value uint256 The value of the attribute in the approval.
   * @param fundsRequired uint256 The amount to be included with the approval.
   * @param validatorFee uint256 The required fee to be paid to the validator.
   * @param signature bytes The attribute approval signature, based on a hash of
   * the other parameters and the submitting account.
   * @return True if the approval is currently valid, false otherwise.
   */
  function canAddAttribute(
    uint256 attributeTypeID,
    uint256 value,
    uint256 fundsRequired,
    uint256 validatorFee,
    bytes signature
  ) external view returns (bool) {
    // signed data hash constructed according to EIP-191-0x45 to prevent replays
    bytes32 hash = calculateAttributeApprovalHash(
      msg.sender,
      address(0),
      attributeTypeID,
      value,
      fundsRequired,
      validatorFee
    );

    // recover the address associated with the signature of the message hash
    address signingKey = hash.toEthSignedMessageHash().recover(signature);
    
    // retrieve variables necessary to perform checks
    address validator = _signingKeys[signingKey];
    uint256 minimumStake = _attributeTypes[attributeTypeID].minimumStake;
    uint256 jurisdictionFee = _attributeTypes[attributeTypeID].jurisdictionFee;

    // determine if the attribute can currently be added.
    // NOTE: consider returning an error code along with the boolean.
    return (
      fundsRequired >= minimumStake.add(jurisdictionFee).add(validatorFee) &&
      !_invalidAttributeApprovalHashes[hash] &&
      canValidate(validator, attributeTypeID) &&
      !_issuedAttributes[msg.sender][attributeTypeID].exists
    );
  }

  /**
   * @notice Check if a given signed attribute approval is currently valid for a
   * given account when submitted by the operator at `msg.sender`.
   * @param account address The account specified by the attribute approval.
   * @param attributeTypeID uint256 The ID of the attribute type in question.
   * @param value uint256 The value of the attribute in the approval.
   * @param fundsRequired uint256 The amount to be included with the approval.
   * @param validatorFee uint256 The required fee to be paid to the validator.
   * @param signature bytes The attribute approval signature, based on a hash of
   * the other parameters and the submitting account.
   * @return True if the approval is currently valid, false otherwise.
   */
  function canAddAttributeFor(
    address account,
    uint256 attributeTypeID,
    uint256 value,
    uint256 fundsRequired,
    uint256 validatorFee,
    bytes signature
  ) external view returns (bool) {
    // signed data hash constructed according to EIP-191-0x45 to prevent replays
    bytes32 hash = calculateAttributeApprovalHash(
      account,
      msg.sender,
      attributeTypeID,
      value,
      fundsRequired,
      validatorFee
    );

    // recover the address associated with the signature of the message hash
    address signingKey = hash.toEthSignedMessageHash().recover(signature);
    
    // retrieve variables necessary to perform checks
    address validator = _signingKeys[signingKey];
    uint256 minimumStake = _attributeTypes[attributeTypeID].minimumStake;
    uint256 jurisdictionFee = _attributeTypes[attributeTypeID].jurisdictionFee;

    // determine if the attribute can currently be added.
    // NOTE: consider returning an error code along with the boolean.
    return (
      fundsRequired >= minimumStake.add(jurisdictionFee).add(validatorFee) &&
      !_invalidAttributeApprovalHashes[hash] &&
      canValidate(validator, attributeTypeID) &&
      !_issuedAttributes[account][attributeTypeID].exists
    );
  }

  /**
   * @notice Determine if an attribute type with ID `attributeTypeID` is
   * currently defined on the jurisdiction.
   * @param attributeTypeID uint256 The attribute type ID in question.
   * @return True if the attribute type is defined, false otherwise.
   */
  function isAttributeType(uint256 attributeTypeID) public view returns (bool) {
    return _attributeTypes[attributeTypeID].exists;
  }

  /**
   * @notice Determine if the account `account` is currently assigned as a
   * validator on the jurisdiction.
   * @param account address The account to check for validator status.
   * @return True if the account is assigned as a validator, false otherwise.
   */
  function isValidator(address account) public view returns (bool) {
    return _validators[account].exists;
  }

  /**
   * @notice Check for recoverable funds that have become locked in the
   * jurisdiction as a result of improperly configured receivers for payments of
   * fees or remaining stake. Note that funds sent into the jurisdiction as a 
   * result of coinbase assignment or as the recipient of a selfdestruct will
   * not be recoverable.
   * @return The total tracked recoverable funds.
   */
  function recoverableFunds() public view returns (uint256) {
    // return the total tracked recoverable funds.
    return _recoverableFunds;
  }

  /**
   * @notice Check for recoverable tokens that are owned by the jurisdiction at
   * the token contract address of `token`.
   * @param token address The account where token contract is located.
   * @return The total recoverable tokens.
   */
  function recoverableTokens(address token) public view returns (uint256) {
    // return the total tracked recoverable tokens.
    return IERC20(token).balanceOf(address(this));
  }

  /**
   * @notice Recover funds that have become locked in the jurisdiction as a
   * result of improperly configured receivers for payments of fees or remaining
   * stake by transferring an amount of `value` to the address at `account`.
   * Note that funds sent into the jurisdiction as a result of coinbase
   * assignment or as the recipient of a selfdestruct will not be recoverable.
   * @param account address The account to send recovered tokens.
   * @param value uint256 The amount of tokens to be sent.
   */
  function recoverFunds(address account, uint256 value) public onlyOwner {    
    // safely deduct the value from the total tracked recoverable funds.
    _recoverableFunds = _recoverableFunds.sub(value);
    
    // transfer the value to the specified account & revert if any error occurs.
    account.transfer(value);
  }

  /**
   * @notice Recover tokens that are owned by the jurisdiction at the token
   * contract address of `token`, transferring an amount of `value` to the
   * address at `account`.
   * @param token address The account where token contract is located.
   * @param account address The account to send recovered funds.
   * @param value uint256 The amount of ether to be sent.
   */
  function recoverTokens(
    address token,
    address account,
    uint256 value
  ) public onlyOwner {
    // transfer the value to the specified account & revert if any error occurs.
    require(IERC20(token).transfer(account, value));
  }

  /**
   * @notice Internal function to determine if a validator at account
   * `validator` can issue attributes of the type with ID `attributeTypeID`.
   * @param validator address The account of the validator.
   * @param attributeTypeID uint256 The ID of the attribute type to check.
   * @return True if the validator can issue attributes of the given type, false
   * otherwise.
   */
  function canValidate(
    address validator,
    uint256 attributeTypeID
  ) internal view returns (bool) {
    return (
      _validators[validator].exists &&   // isValidator(validator)
      _attributeTypes[attributeTypeID].approvedValidators[validator] &&
      _attributeTypes[attributeTypeID].exists // isAttributeType(attributeTypeID)
    );
  }

  // internal helper function for getting the hash of an attribute approval
  function calculateAttributeApprovalHash(
    address account,
    address operator,
    uint256 attributeTypeID,
    uint256 value,
    uint256 fundsRequired,
    uint256 validatorFee
  ) internal view returns (bytes32 hash) {
    return keccak256(
      abi.encodePacked(
        address(this),
        account,
        operator,
        fundsRequired,
        validatorFee,
        attributeTypeID,
        value
      )
    );
  }

  // helper function, won't revert calling hasAttribute on secondary registries
  function secondaryHasAttribute(
    address source,
    address account,
    uint256 attributeTypeID
  ) internal view returns (bool result) {
    // if attributeTypeID = uint256 of 'wyre-yes-token', use special handling
    if (attributeTypeID == 2423228754106148037712574142965102) {
      return (IERC20(source).balanceOf(account) >= 1);
    }

    uint256 maxGas = gasleft() > 20000 ? 20000 : gasleft();
    bytes memory encodedParams = abi.encodeWithSelector(
      this.hasAttribute.selector,
      account,
      attributeTypeID
    );

    assembly {
      let encodedParams_data := add(0x20, encodedParams)
      let encodedParams_size := mload(encodedParams)
      
      let output := mload(0x40) // get storage start from free memory pointer
      mstore(output, 0x0)       // set up the location for output of staticcall

      let success := staticcall(
        maxGas,                 // maximum of 20k gas can be forwarded
        source,                 // address of attribute registry to call
        encodedParams_data,     // inputs are stored at pointer location
        encodedParams_size,     // inputs are 68 bytes (4 + 32 * 2)
        output,                 // return to designated free space
        0x20                    // output is one word, or 32 bytes
      )

      switch success            // instrumentation bug: use switch instead of if
      case 1 {                  // only recognize successful staticcall output 
        result := mload(output) // set the output to the return value
      }
    }
  }
}