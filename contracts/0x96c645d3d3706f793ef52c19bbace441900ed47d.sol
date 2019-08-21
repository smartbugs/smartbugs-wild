/**
 * MPSToken.sol
 * MPS Token (Mt Pelerin Share)

 * More info about MPS : https://github.com/MtPelerin/MtPelerin-share-MPS

 * The unflattened code is available through this github tag:
 * https://github.com/MtPelerin/MtPelerin-protocol/tree/etherscan-verify-batch-1

 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved

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

// File: contracts/zeppelin/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts/zeppelin/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/zeppelin/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: contracts/interface/ISeizable.sol

/**
 * @title ISeizable
 * @dev ISeizable interface
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 **/
contract ISeizable {
  function seize(address _account, uint256 _value) public;
  event Seize(address account, uint256 amount);
}

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

// File: contracts/Authority.sol

/**
 * @title Authority
 * @dev The Authority contract has an authority address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * Authority means to represent a legal entity that is entitled to specific rights
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 *
 * Error messages
 * AU01: Message sender must be an authority
 */
contract Authority is Ownable {

  address authority;

  /**
   * @dev Throws if called by any account other than the authority.
   */
  modifier onlyAuthority {
    require(msg.sender == authority, "AU01");
    _;
  }

  /**
   * @dev return the address associated to the authority
   */
  function authorityAddress() public view returns (address) {
    return authority;
  }

  /**
   * @dev rdefines an authority
   * @param _name the authority name
   * @param _address the authority address.
   */
  function defineAuthority(string _name, address _address) public onlyOwner {
    emit AuthorityDefined(_name, _address);
    authority = _address;
  }

  event AuthorityDefined(
    string name,
    address _address
  );
}

// File: contracts/token/component/SeizableToken.sol

/**
 * @title SeizableToken
 * @dev BasicToken contract which allows owner to seize accounts
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 *
 * Error messages
 * ST01: Owner cannot seize itself
*/
contract SeizableToken is BasicToken, Authority, ISeizable {
  using SafeMath for uint256;

  // Although very unlikely, the value below may overflow.
  // This contract and its children should expect it to happened and consider
  // this value as only the first 256 bits of the complete value.
  uint256 public allTimeSeized = 0; // overflow may happend

  /**
   * @dev called by the owner to seize value from the account
   */
  function seize(address _account, uint256 _value)
    public onlyAuthority
  {
    require(_account != owner, "ST01");

    balances[_account] = balances[_account].sub(_value);
    balances[authority] = balances[authority].add(_value);

    allTimeSeized += _value;
    emit Seize(_account, _value);
  }
}

// File: contracts/zeppelin/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: contracts/zeppelin/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: contracts/interface/IProvableOwnership.sol

/**
 * @title IProvableOwnership
 * @dev IProvableOwnership interface which describe proof of ownership.
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 **/
contract IProvableOwnership {
  function proofLength(address _holder) public view returns (uint256);
  function proofAmount(address _holder, uint256 _proofId)
    public view returns (uint256);

  function proofDateFrom(address _holder, uint256 _proofId)
    public view returns (uint256);

  function proofDateTo(address _holder, uint256 _proofId)
    public view returns (uint256);

  function createProof(address _holder) public;
  function checkProof(address _holder, uint256 _proofId, uint256 _at)
    public view returns (uint256);

  function transferWithProofs(
    address _to,
    uint256 _value,
    bool _proofFrom,
    bool _proofTo
    ) public returns (bool);

  function transferFromWithProofs(
    address _from,
    address _to,
    uint256 _value,
    bool _proofFrom,
    bool _proofTo
    ) public returns (bool);

  event ProofOfOwnership(address indexed holder, uint256 proofId);
}

// File: contracts/interface/IAuditableToken.sol

/**
 * @title IAuditableToken
 * @dev IAuditableToken interface describing the audited data
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 **/
contract IAuditableToken {
  function lastTransactionAt(address _address) public view returns (uint256);
  function lastReceivedAt(address _address) public view returns (uint256);
  function lastSentAt(address _address) public view returns (uint256);
  function transactionCount(address _address) public view returns (uint256);
  function receivedCount(address _address) public view returns (uint256);
  function sentCount(address _address) public view returns (uint256);
  function totalReceivedAmount(address _address) public view returns (uint256);
  function totalSentAmount(address _address) public view returns (uint256);
}

// File: contracts/token/component/AuditableToken.sol

/**
 * @title AuditableToken
 * @dev AuditableToken contract
 * AuditableToken provides transaction data which can be used
 * in other smart contracts
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 **/
contract AuditableToken is IAuditableToken, StandardToken {

   // Although very unlikely, the following values below may overflow:
   //   receivedCount, sentCount, totalReceivedAmount, totalSentAmount
   // This contract and its children should expect it to happen and consider
   // these values as only the first 256 bits of the complete value.
  struct Audit {
    uint256 createdAt;
    uint256 lastReceivedAt;
    uint256 lastSentAt;
    uint256 receivedCount; // potential overflow
    uint256 sentCount; // poential overflow
    uint256 totalReceivedAmount; // potential overflow
    uint256 totalSentAmount; // potential overflow
  }
  mapping(address => Audit) internal audits;

  /**
   * @dev Time of the creation of the audit struct
   */
  function auditCreatedAt(address _address) public view returns (uint256) {
    return audits[_address].createdAt;
  }

  /**
   * @dev Time of the last transaction
   */
  function lastTransactionAt(address _address) public view returns (uint256) {
    return ( audits[_address].lastReceivedAt > audits[_address].lastSentAt ) ?
      audits[_address].lastReceivedAt : audits[_address].lastSentAt;
  }

  /**
   * @dev Time of the last received transaction
   */
  function lastReceivedAt(address _address) public view returns (uint256) {
    return audits[_address].lastReceivedAt;
  }

  /**
   * @dev Time of the last sent transaction
   */
  function lastSentAt(address _address) public view returns (uint256) {
    return audits[_address].lastSentAt;
  }

  /**
   * @dev Count of transactions
   */
  function transactionCount(address _address) public view returns (uint256) {
    return audits[_address].receivedCount + audits[_address].sentCount;
  }

  /**
   * @dev Count of received transactions
   */
  function receivedCount(address _address) public view returns (uint256) {
    return audits[_address].receivedCount;
  }

  /**
   * @dev Count of sent transactions
   */
  function sentCount(address _address) public view returns (uint256) {
    return audits[_address].sentCount;
  }

  /**
   * @dev All time received
   */
  function totalReceivedAmount(address _address)
    public view returns (uint256)
  {
    return audits[_address].totalReceivedAmount;
  }

  /**
   * @dev All time sent
   */
  function totalSentAmount(address _address) public view returns (uint256) {
    return audits[_address].totalSentAmount;
  }

  /**
   * @dev Overriden transfer function
   */
  function transfer(address _to, uint256 _value) public returns (bool) {
    if (!super.transfer(_to, _value)) {
      return false;
    }
    updateAudit(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Overriden transferFrom function
   */
  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool)
  {
    if (!super.transferFrom(_from, _to, _value)) {
      return false;
    }

    updateAudit(_from, _to, _value);
    return true;
  }

 /**
   * @dev currentTime()
   */
  function currentTime() internal view returns (uint256) {
    // solium-disable-next-line security/no-block-members
    return now;
  }

  /**
   * @dev Update audit data
   */
  function updateAudit(address _sender, address _receiver, uint256 _value)
    private returns (uint256)
  {
    Audit storage senderAudit = audits[_sender];
    senderAudit.lastSentAt = currentTime();
    senderAudit.sentCount++;
    senderAudit.totalSentAmount += _value;
    if (senderAudit.createdAt == 0) {
      senderAudit.createdAt = currentTime();
    }

    Audit storage receiverAudit = audits[_receiver];
    receiverAudit.lastReceivedAt = currentTime();
    receiverAudit.receivedCount++;
    receiverAudit.totalReceivedAmount += _value;
    if (receiverAudit.createdAt == 0) {
      receiverAudit.createdAt = currentTime();
    }
  }
}

// File: contracts/token/component/ProvableOwnershipToken.sol

/**
 * @title ProvableOwnershipToken
 * @dev ProvableOwnershipToken is a StandardToken
 * with ability to record a proof of ownership
 *
 * When desired a proof of ownership can be generated.
 * The proof is stored within the contract.
 * A proofId is then returned.
 * The proof can later be used to retrieve the amount needed.
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 **/
contract ProvableOwnershipToken is IProvableOwnership, AuditableToken, Ownable {
  struct Proof {
    uint256 amount;
    uint256 dateFrom;
    uint256 dateTo;
  }
  mapping(address => mapping(uint256 => Proof)) internal proofs;
  mapping(address => uint256) internal proofLengths;

  /**
   * @dev number of proof stored in the contract
   */
  function proofLength(address _holder) public view returns (uint256) {
    return proofLengths[_holder];
  }

  /**
   * @dev amount contains for the proofId reccord
   */
  function proofAmount(address _holder, uint256 _proofId)
    public view returns (uint256)
  {
    return proofs[_holder][_proofId].amount;
  }

  /**
   * @dev date from which the proof is valid
   */
  function proofDateFrom(address _holder, uint256 _proofId)
    public view returns (uint256)
  {
    return proofs[_holder][_proofId].dateFrom;
  }

  /**
   * @dev date until the proof is valid
   */
  function proofDateTo(address _holder, uint256 _proofId)
    public view returns (uint256)
  {
    return proofs[_holder][_proofId].dateTo;
  }

  /**
   * @dev called to challenge a proof at a point in the past
   * Return the amount tokens owned by the proof owner at that time
   */
  function checkProof(address _holder, uint256 _proofId, uint256 _at)
    public view returns (uint256)
  {
    if (_proofId < proofLengths[_holder]) {
      Proof storage proof = proofs[_holder][_proofId];

      if (proof.dateFrom <= _at && _at <= proof.dateTo) {
        return proof.amount;
      }
    }
    return 0;
  }

  /**
   * @dev called to create a proof of token ownership
   */
  function createProof(address _holder) public {
    createProofInternal(
      _holder,
      balanceOf(_holder),
      lastTransactionAt(_holder)
    );
  }

  /**
   * @dev transfer function with also create a proof of ownership to any of the participants
   * @param _proofSender if true a proof will be created for the sender
   * @param _proofReceiver if true a proof will be created for the receiver
   */
  function transferWithProofs(
    address _to,
    uint256 _value,
    bool _proofSender,
    bool _proofReceiver
  ) public returns (bool)
  {
    uint256 balanceBeforeFrom = balanceOf(msg.sender);
    uint256 beforeFrom = lastTransactionAt(msg.sender);
    uint256 balanceBeforeTo = balanceOf(_to);
    uint256 beforeTo = lastTransactionAt(_to);

    if (!super.transfer(_to, _value)) {
      return false;
    }

    transferPostProcessing(
      msg.sender,
      balanceBeforeFrom,
      beforeFrom,
      _proofSender
    );
    transferPostProcessing(
      _to,
      balanceBeforeTo,
      beforeTo,
      _proofReceiver
    );
    return true;
  }

  /**
   * @dev transfer function with also create a proof of ownership to any of the participants
   * @param _proofSender if true a proof will be created for the sender
   * @param _proofReceiver if true a proof will be created for the receiver
   */
  function transferFromWithProofs(
    address _from,
    address _to, 
    uint256 _value,
    bool _proofSender, bool _proofReceiver)
    public returns (bool)
  {
    uint256 balanceBeforeFrom = balanceOf(_from);
    uint256 beforeFrom = lastTransactionAt(_from);
    uint256 balanceBeforeTo = balanceOf(_to);
    uint256 beforeTo = lastTransactionAt(_to);

    if (!super.transferFrom(_from, _to, _value)) {
      return false;
    }

    transferPostProcessing(
      _from,
      balanceBeforeFrom,
      beforeFrom,
      _proofSender
    );
    transferPostProcessing(
      _to,
      balanceBeforeTo,
      beforeTo,
      _proofReceiver
    );
    return true;
  }

  /**
   * @dev can be used to force create a proof (with a fake amount potentially !)
   * Only usable by child contract internaly
   */
  function createProofInternal(
    address _holder, uint256 _amount, uint256 _from) internal
  {
    uint proofId = proofLengths[_holder];
    // solium-disable-next-line security/no-block-members
    proofs[_holder][proofId] = Proof(_amount, _from, currentTime());
    proofLengths[_holder] = proofId+1;
    emit ProofOfOwnership(_holder, proofId);
  }

  /**
   * @dev private function updating contract state after a transfer operation
   */
  function transferPostProcessing(
    address _holder,
    uint256 _balanceBefore,
    uint256 _before,
    bool _proof) private
  {
    if (_proof) {
      createProofInternal(_holder, _balanceBefore, _before);
    }
  }

  event ProofOfOwnership(address indexed holder, uint256 proofId);
}

// File: contracts/interface/IClaimable.sol

/**
 * @title IClaimable
 * @dev IClaimable interface
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 **/
interface IClaimable {
  function hasClaimsSince(address _address, uint256 at)
    external view returns (bool);
}

// File: contracts/interface/IWithClaims.sol

/**
 * @title IWithClaims
 * @dev IWithClaims interface
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 **/
contract IWithClaims {
  function claimableLength() public view returns (uint256);
  function claimable(uint256 _claimableId) public view returns (IClaimable);
  function hasClaims(address _holder) public view returns (bool);
  function defineClaimables(IClaimable[] _claimables) public;

  event ClaimablesDefined(uint256 count);
}

// File: contracts/token/component/TokenWithClaims.sol

/**
 * @title TokenWithClaims
 * @dev TokenWithClaims contract
 * TokenWithClaims is a token that will create a
 * proofOfOwnership during transfers if a claim can be made.
 * Holder may ask for the claim later using the proofOfOwnership
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 *
 * Error messages
 * E01: Claimable address must be defined
 * E02: Claimables parameter must not be empty
 * E03: Claimable does not exist
**/
contract TokenWithClaims is IWithClaims, ProvableOwnershipToken {

  IClaimable[] claimables;

  /**
   * @dev Constructor
   */
  constructor(IClaimable[] _claimables) public {
    claimables = _claimables;
  }

  /**
   * @dev Returns the number of claimables
   */
  function claimableLength() public view returns (uint256) {
    return claimables.length;
  }

  /**
   * @dev Returns the Claimable associated to the specified claimableId
   */
  function claimable(uint256 _claimableId) public view returns (IClaimable) {
    return claimables[_claimableId];
  }

  /**
   * @dev Returns true if there are any claims associated to this token
   * to be made at this time for the _holder
   */
  function hasClaims(address _holder) public view returns (bool) {
    uint256 lastTransaction = lastTransactionAt(_holder);
    for (uint256 i = 0; i < claimables.length; i++) {
      if (claimables[i].hasClaimsSince(_holder, lastTransaction)) {
        return true;
      }
    }
    return false;
  }

  /**
   * @dev Override the transfer function with transferWithProofs
   * A proof of ownership will be made if any claims can be made by the participants
   */
  function transfer(address _to, uint256 _value) public returns (bool) {
    bool proofFrom = hasClaims(msg.sender);
    bool proofTo = hasClaims(_to);

    return super.transferWithProofs(
      _to,
      _value,
      proofFrom,
      proofTo
    );
  }

  /**
   * @dev Override the transfer function with transferWithProofs
   * A proof of ownership will be made if any claims can be made by the participants
   */
  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool)
  {
    bool proofFrom = hasClaims(_from);
    bool proofTo = hasClaims(_to);

    return super.transferFromWithProofs(
      _from,
      _to,
      _value,
      proofFrom,
      proofTo
    );
  }

  /**
   * @dev transfer with proofs
   */
  function transferWithProofs(
    address _to,
    uint256 _value,
    bool _proofFrom,
    bool _proofTo
  ) public returns (bool)
  {
    bool proofFrom = _proofFrom || hasClaims(msg.sender);
    bool proofTo = _proofTo || hasClaims(_to);

    return super.transferWithProofs(
      _to,
      _value,
      proofFrom,
      proofTo
    );
  }

  /**
   * @dev transfer from with proofs
   */
  function transferFromWithProofs(
    address _from,
    address _to,
    uint256 _value,
    bool _proofFrom,
    bool _proofTo
  ) public returns (bool)
  {
    bool proofFrom = _proofFrom || hasClaims(_from);
    bool proofTo = _proofTo || hasClaims(_to);

    return super.transferFromWithProofs(
      _from,
      _to,
      _value,
      proofFrom,
      proofTo
    );
  }

  /**
   * @dev define claimables contract to this token
   */
  function defineClaimables(IClaimable[] _claimables) public onlyOwner {
    claimables = _claimables;
    emit ClaimablesDefined(claimables.length);
  }
}

// File: contracts/interface/IRule.sol

/**
 * @title IRule
 * @dev IRule interface
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 **/
interface IRule {
  function isAddressValid(address _address) external view returns (bool);
  function isTransferValid(address _from, address _to, uint256 _amount)
    external view returns (bool);
}

// File: contracts/interface/IWithRules.sol

/**
 * @title IWithRules
 * @dev IWithRules interface
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 **/
contract IWithRules {
  function ruleLength() public view returns (uint256);
  function rule(uint256 _ruleId) public view returns (IRule);
  function validateAddress(address _address) public view returns (bool);
  function validateTransfer(address _from, address _to, uint256 _amount)
    public view returns (bool);

  function defineRules(IRule[] _rules) public;

  event RulesDefined(uint256 count);
}

// File: contracts/rule/WithRules.sol

/**
 * @title WithRules
 * @dev WithRules contract allows inheriting contract to use a set of validation rules
 * @dev contract owner may add or remove rules
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 *
 * Error messages
 * WR01: The rules rejected this address
 * WR02: The rules rejected the transfer
 **/
contract WithRules is IWithRules, Ownable {

  IRule[] internal rules;

  /**
   * @dev Constructor
   */
  constructor(IRule[] _rules) public {
    rules = _rules;
  }

  /**
   * @dev Returns the number of rules
   */
  function ruleLength() public view returns (uint256) {
    return rules.length;
  }

  /**
   * @dev Returns the Rule associated to the specified ruleId
   */
  function rule(uint256 _ruleId) public view returns (IRule) {
    return rules[_ruleId];
  }

  /**
   * @dev Check if the rules are valid for an address
   */
  function validateAddress(address _address) public view returns (bool) {
    for (uint256 i = 0; i < rules.length; i++) {
      if (!rules[i].isAddressValid(_address)) {
        return false;
      }
    }
    return true;
  }

  /**
   * @dev Check if the rules are valid
   */
  function validateTransfer(address _from, address _to, uint256 _amount)
    public view returns (bool)
  {
    for (uint256 i = 0; i < rules.length; i++) {
      if (!rules[i].isTransferValid(_from, _to, _amount)) {
        return false;
      }
    }
    return true;
  }

  /**
   * @dev Modifier to make functions callable
   * only when participants follow rules
   */
  modifier whenAddressRulesAreValid(address _address) {
    require(validateAddress(_address), "WR01");
    _;
  }

  /**
   * @dev Modifier to make transfer functions callable
   * only when participants follow rules
   */
  modifier whenTransferRulesAreValid(
    address _from,
    address _to,
    uint256 _amount)
  {
    require(validateTransfer(_from, _to, _amount), "WR02");
    _;
  }

  /**
   * @dev Define rules to the token
   */
  function defineRules(IRule[] _rules) public onlyOwner {
    rules = _rules;
    emit RulesDefined(rules.length);
  }
}

// File: contracts/token/component/TokenWithRules.sol

/**
 * @title TokenWithRules
 * @dev TokenWithRules contract
 * TokenWithRules is a token that will apply
 * rules restricting transferability
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 *
 **/
contract TokenWithRules is StandardToken, WithRules {

  /**
   * @dev Constructor
   */
  constructor(IRule[] _rules) public WithRules(_rules) { }

  /**
   * @dev Overriden transfer function
   */
  function transfer(address _to, uint256 _value)
    public whenTransferRulesAreValid(msg.sender, _to, _value)
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  /**
   * @dev Overriden transferFrom function
   */
  function transferFrom(address _from, address _to, uint256 _value)
    public whenTransferRulesAreValid(_from, _to, _value)
    whenAddressRulesAreValid(msg.sender)
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }
}

// File: contracts/token/BridgeToken.sol

/**
 * @title BridgeToken
 * @dev BridgeToken contract
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 */
contract BridgeToken is TokenWithRules, TokenWithClaims, SeizableToken {
  string public name;
  string public symbol;

  /**
   * @dev constructor
   */
  constructor(string _name, string _symbol) 
    TokenWithRules(new IRule[](0))
    TokenWithClaims(new IClaimable[](0)) public
  {
    name = _name;
    symbol = _symbol;
  }
}

// File: contracts/interface/IMintable.sol

/**
 * @title Mintable interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 */
contract IMintable {
  function mintingFinished() public view returns (bool);

  function mint(address _to, uint256 _amount) public returns (bool);
  function finishMinting() public returns (bool);
 
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
}

// File: contracts/token/component/MintableToken.sol

/**
 * @title MintableToken
 * @dev MintableToken contract
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 *
 * Error messages
 * MT01: Minting is already finished.
*/
contract MintableToken is StandardToken, Ownable, IMintable {

  bool public mintingFinished = false;

  function mintingFinished() public view returns (bool) {
    return mintingFinished;
  }

  modifier canMint() {
    require(!mintingFinished, "MT01");
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  ) public canMint onlyOwner returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public canMint onlyOwner returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }

  event Mint(address indexed to, uint256 amount);
  event MintFinished();
}

// File: contracts/token/MintableBridgeToken.sol

/**
 * @title MintableBridgeToken
 * @dev MintableBridgeToken contract
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 */
contract MintableBridgeToken is BridgeToken, MintableToken {

  string public name;
  string public symbol;

  /**
   * @dev constructor
   */
  constructor(string _name, string _symbol)
    BridgeToken(_name, _symbol) public
  {
    name = _name;
    symbol = _symbol;
  }
}

// File: contracts/token/ShareBridgeToken.sol

/**
 * @title ShareBridgeToken
 * @dev ShareBridgeToken contract
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 */
contract ShareBridgeToken is MintableBridgeToken {

  // Shares are non divisible assets
  uint256 public decimals = 0;

  /**
   * @dev constructor
   */
  constructor(string _name, string _symbol) public
    MintableBridgeToken(_name, _symbol)
  {
  }
}

// File: contracts/mps/MPSToken.sol

/**
 * @title MPSToken
 * @dev MPSToken contract
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 */
contract MPSToken is ShareBridgeToken {

  /**
   * @dev constructor
   */
  constructor() public
    ShareBridgeToken("MtPelerin Shares", "MPS")
  {
  }
}