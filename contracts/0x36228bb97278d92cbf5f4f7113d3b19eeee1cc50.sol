pragma solidity ^0.4.24;

library Attribute {
  enum AttributeType {
    ROLE_MANAGER,                   // 0
    ROLE_OPERATOR,                  // 1
    IS_BLACKLISTED,                 // 2
    HAS_PASSED_KYC_AML,             // 3
    NO_FEES,                        // 4
    /* Additional user-defined later */
    USER_DEFINED
  }

  function toUint256(AttributeType _type) internal pure returns (uint256) {
    return uint256(_type);
  }
}


library BitManipulation {
  uint256 constant internal ONE = uint256(1);

  function setBit(uint256 _num, uint256 _pos) internal pure returns (uint256) {
    return _num | (ONE << _pos);
  }

  function clearBit(uint256 _num, uint256 _pos) internal pure returns (uint256) {
    return _num & ~(ONE << _pos);
  }

  function toggleBit(uint256 _num, uint256 _pos) internal pure returns (uint256) {
    return _num ^ (ONE << _pos);
  }

  function checkBit(uint256 _num, uint256 _pos) internal pure returns (bool) {
    return (_num >> _pos & ONE == ONE);
  }
}



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
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
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






// Interface for logic governing write access to a Registry.
contract RegistryAccessManager {
  // Called when _admin attempts to write _value for _who's _attribute.
  // Returns true if the write is allowed to proceed.
  function confirmWrite(
    address _who,
    Attribute.AttributeType _attribute,
    address _admin
  )
    public returns (bool);
}










/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}



/**
 * @title Claimable Ex
 * @dev Extension for the Claimable contract, where the ownership transfer can be canceled.
 */
contract ClaimableEx is Claimable {
  /*
   * @dev Cancels the ownership transfer.
   */
  function cancelOwnershipTransfer() onlyOwner public {
    pendingOwner = owner;
  }
}








/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}











contract Registry is ClaimableEx {
  using BitManipulation for uint256;

  struct AttributeData {
    uint256 value;
  }

  // Stores arbitrary attributes for users. An example use case is an ERC20
  // token that requires its users to go through a KYC/AML check - in this case
  // a validator can set an account's "hasPassedKYC/AML" attribute to 1 to indicate
  // that account can use the token. This mapping stores that value (1, in the
  // example) as well as which validator last set the value and at what time,
  // so that e.g. the check can be renewed at appropriate intervals.
  mapping(address => AttributeData) private attributes;

  // The logic governing who is allowed to set what attributes is abstracted as
  // this accessManager, so that it may be replaced by the owner as needed.
  RegistryAccessManager public accessManager;

  event SetAttribute(
    address indexed who,
    Attribute.AttributeType attribute,
    bool enable,
    string notes,
    address indexed adminAddr
  );

  event SetManager(
    address indexed oldManager,
    address indexed newManager
  );

  constructor() public {
    accessManager = new DefaultRegistryAccessManager();
  }

  // Writes are allowed only if the accessManager approves
  function setAttribute(
    address _who,
    Attribute.AttributeType _attribute,
    string _notes
  )
    public
  {
    bool _canWrite = accessManager.confirmWrite(
      _who,
      _attribute,
      msg.sender
    );
    require(_canWrite);

    // Get value of previous attribute before setting new attribute
    uint256 _tempVal = attributes[_who].value;

    attributes[_who] = AttributeData(
      _tempVal.setBit(Attribute.toUint256(_attribute))
    );

    emit SetAttribute(_who, _attribute, true, _notes, msg.sender);
  }

  function clearAttribute(
    address _who,
    Attribute.AttributeType _attribute,
    string _notes
  )
    public
  {
    bool _canWrite = accessManager.confirmWrite(
      _who,
      _attribute,
      msg.sender
    );
    require(_canWrite);

    // Get value of previous attribute before setting new attribute
    uint256 _tempVal = attributes[_who].value;

    attributes[_who] = AttributeData(
      _tempVal.clearBit(Attribute.toUint256(_attribute))
    );

    emit SetAttribute(_who, _attribute, false, _notes, msg.sender);
  }

  // Returns true if the uint256 value stored for this attribute is non-zero
  function hasAttribute(
    address _who,
    Attribute.AttributeType _attribute
  )
    public
    view
    returns (bool)
  {
    return attributes[_who].value.checkBit(Attribute.toUint256(_attribute));
  }

  // Returns the exact value of the attribute, as well as its metadata
  function getAttributes(
    address _who
  )
    public
    view
    returns (uint256)
  {
    AttributeData memory _data = attributes[_who];
    return _data.value;
  }

  function setManager(RegistryAccessManager _accessManager) public onlyOwner {
    emit SetManager(accessManager, _accessManager);
    accessManager = _accessManager;
  }
}




contract DefaultRegistryAccessManager is RegistryAccessManager {
  function confirmWrite(
    address /*_who*/,
    Attribute.AttributeType _attribute,
    address _operator
  )
    public
    returns (bool)
  {
    Registry _client = Registry(msg.sender);
    if (_operator == _client.owner()) {
      return true;
    } else if (_client.hasAttribute(_operator, Attribute.AttributeType.ROLE_MANAGER)) {
      return (_attribute == Attribute.AttributeType.ROLE_OPERATOR);
    } else if (_client.hasAttribute(_operator, Attribute.AttributeType.ROLE_OPERATOR)) {
      return (_attribute != Attribute.AttributeType.ROLE_OPERATOR &&
              _attribute != Attribute.AttributeType.ROLE_MANAGER);
    }
  }
}