pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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






/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}


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
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
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
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <remco@2π.com>
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up
 * in the contract, it will allow the owner to reclaim this Ether.
 * @notice Ether can still be sent to this contract by:
 * calling functions labeled `payable`
 * `selfdestruct(contract_address)`
 * mining directly to the contract address
 */
contract HasNoEther is Ownable {

  /**
  * @dev Constructor that rejects incoming Ether
  * The `payable` flag is added so we can access `msg.value` without compiler warning. If we
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
  * we could use assembly to access msg.value.
  */
  constructor() public payable {
    require(msg.value == 0);
  }

  /**
   * @dev Disallows direct send by setting a default function without the `payable` flag.
   */
  function() external {
  }

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
    owner.transfer(address(this).balance);
  }
}










/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param _token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic _token) external onlyOwner {
    uint256 balance = _token.balanceOf(this);
    _token.safeTransfer(owner, balance);
  }

}



/**
 * @title Contracts that should not own Tokens
 * @author Remco Bloemen <remco@2π.com>
 * @dev This blocks incoming ERC223 tokens to prevent accidental loss of tokens.
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the
 * owner to reclaim the tokens.
 */
contract HasNoTokens is CanReclaimToken {

 /**
  * @dev Reject all ERC223 compatible tokens
  * @param _from address The address that is transferring the tokens
  * @param _value uint256 the amount of the specified token
  * @param _data Bytes The data passed from the caller.
  */
  function tokenFallback(
    address _from,
    uint256 _value,
    bytes _data
  )
    external
    pure
  {
    _from;
    _value;
    _data;
    revert();
  }

}






/**
 * @title Contracts that should not own Contracts
 * @author Remco Bloemen <remco@2π.com>
 * @dev Should contracts (anything Ownable) end up being owned by this contract, it allows the owner
 * of this contract to reclaim ownership of the contracts.
 */
contract HasNoContracts is Ownable {

  /**
   * @dev Reclaim ownership of Ownable contracts
   * @param _contractAddr The address of the Ownable to be reclaimed.
   */
  function reclaimContract(address _contractAddr) external onlyOwner {
    Ownable contractInst = Ownable(_contractAddr);
    contractInst.transferOwnership(owner);
  }
}



/**
 * @title Base contract for contracts that should not own things.
 * @author Remco Bloemen <remco@2π.com>
 * @dev Solves a class of errors where a contract accidentally becomes owner of Ether, Tokens or
 * Owned contracts. See respective base contracts for details.
 */
contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {
}



/**
 * @title NoOwner Ex
 * @dev Extension for the NoOwner contract, to support a case where
 * this contract's owner can't own ether or tokens.
 * Note that we *do* inherit reclaimContract from NoOwner: This contract
 * does have to own contracts, but it also has to be able to relinquish them
 **/
contract NoOwnerEx is NoOwner {
  function reclaimEther(address _to) external onlyOwner {
    _to.transfer(address(this).balance);
  }

  function reclaimToken(ERC20Basic token, address _to) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(_to, balance);
  }
}











/**
 * @title Address Set.
 * @dev This contract allows to store addresses in a set and
 * owner can run a loop through all elements.
 **/
contract AddressSet is Ownable {
  mapping(address => bool) exist;
  address[] elements;

  /**
   * @dev Adds a new address to the set.
   * @param _addr Address to add.
   * @return True if succeed, otherwise false.
   */
  function add(address _addr) onlyOwner public returns (bool) {
    if (contains(_addr)) {
      return false;
    }

    exist[_addr] = true;
    elements.push(_addr);
    return true;
  }

  /**
   * @dev Checks whether the set contains a specified address or not.
   * @param _addr Address to check.
   * @return True if the address exists in the set, otherwise false.
   */
  function contains(address _addr) public view returns (bool) {
    return exist[_addr];
  }

  /**
   * @dev Gets an element at a specified index in the set.
   * @param _index Index.
   * @return A relevant address.
   */
  function elementAt(uint256 _index) onlyOwner public view returns (address) {
    require(_index < elements.length);

    return elements[_index];
  }

  /**
   * @dev Gets the number of elements in the set.
   * @return The number of elements.
   */
  function getTheNumberOfElements() onlyOwner public view returns (uint256) {
    return elements.length;
  }
}



// A wrapper around the balances mapping.
contract BalanceSheet is ClaimableEx {
  using SafeMath for uint256;

  mapping (address => uint256) private balances;

  AddressSet private holderSet;

  constructor() public {
    holderSet = new AddressSet();
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

  function addBalance(address _addr, uint256 _value) public onlyOwner {
    balances[_addr] = balances[_addr].add(_value);

    _checkHolderSet(_addr);
  }

  function subBalance(address _addr, uint256 _value) public onlyOwner {
    balances[_addr] = balances[_addr].sub(_value);
  }

  function setBalance(address _addr, uint256 _value) public onlyOwner {
    balances[_addr] = _value;

    _checkHolderSet(_addr);
  }

  function setBalanceBatch(
    address[] _addrs,
    uint256[] _values
  )
    public
    onlyOwner
  {
    uint256 _count = _addrs.length;
    require(_count == _values.length);

    for(uint256 _i = 0; _i < _count; _i++) {
      setBalance(_addrs[_i], _values[_i]);
    }
  }

  function getTheNumberOfHolders() public view returns (uint256) {
    return holderSet.getTheNumberOfElements();
  }

  function getHolder(uint256 _index) public view returns (address) {
    return holderSet.elementAt(_index);
  }

  function _checkHolderSet(address _addr) internal {
    if (!holderSet.contains(_addr)) {
      holderSet.add(_addr);
    }
  }
}



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * A version of OpenZeppelin's StandardToken whose balances mapping has been replaced
 * with a separate BalanceSheet contract. Most useful in combination with e.g.
 * HasNoContracts because then it can relinquish its balance sheet to a new
 * version of the token, removing the need to copy over balances.
 **/
contract StandardToken is ClaimableEx, NoOwnerEx, ERC20 {
  using SafeMath for uint256;

  uint256 totalSupply_;

  BalanceSheet private balances;
  event BalanceSheetSet(address indexed sheet);

  mapping (address => mapping (address => uint256)) private allowed;

  constructor() public {
    totalSupply_ = 0;
  }

  /**
   * @dev Total number of tokens in existence
   */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
   * @dev Gets the balance of the specified address.
   * @param _owner The address to query the the balance of.
   * @return An uint256 representing the amount owned by the passed address.
   */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances.balanceOf(_owner);
  }

  /**
   * @dev Claim ownership of the BalanceSheet contract
   * @param _sheet The address of the BalanceSheet to claim.
   */
  function setBalanceSheet(address _sheet) public onlyOwner returns (bool) {
    balances = BalanceSheet(_sheet);
    balances.claimOwnership();
    emit BalanceSheetSet(_sheet);
    return true;
  }

  function getTheNumberOfHolders() public view returns (uint256) {
    return balances.getTheNumberOfHolders();
  }

  function getHolder(uint256 _index) public view returns (address) {
    return balances.getHolder(_index);
  }

  /**
   * @dev Transfer token for a specified address
   * @param _to The address to transfer to.
   * @param _value The amount to be transferred.
   */
  function transfer(address _to, uint256 _value) public returns (bool) {
    _transfer(msg.sender, _to, _value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from The address which you want to send tokens from
   * @param _to The address which you want to transfer to
   * @param _value The amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    _transferFrom(_from, _to, _value, msg.sender);
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
    _approve(_spender, _value, msg.sender);
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
    _increaseApproval(_spender, _addedValue, msg.sender);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
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
    _decreaseApproval(_spender, _subtractedValue, msg.sender);
    return true;
  }

  function _approve(
    address _spender,
    uint256 _value,
    address _tokenHolder
  )
    internal
  {
    allowed[_tokenHolder][_spender] = _value;

    emit Approval(_tokenHolder, _spender, _value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param _burner The account whose tokens will be burnt.
   * @param _value The amount that will be burnt.
   */
  function _burn(address _burner, uint256 _value) internal {
    require(_burner != 0);
    require(_value <= balanceOf(_burner), "not enough balance to burn");

    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure
    balances.subBalance(_burner, _value);
    totalSupply_ = totalSupply_.sub(_value);

    emit Transfer(_burner, address(0), _value);
  }

  function _decreaseApproval(
    address _spender,
    uint256 _subtractedValue,
    address _tokenHolder
  )
    internal
  {
    uint256 _oldValue = allowed[_tokenHolder][_spender];
    if (_subtractedValue >= _oldValue) {
      allowed[_tokenHolder][_spender] = 0;
    } else {
      allowed[_tokenHolder][_spender] = _oldValue.sub(_subtractedValue);
    }

    emit Approval(_tokenHolder, _spender, allowed[_tokenHolder][_spender]);
  }

  function _increaseApproval(
    address _spender,
    uint256 _addedValue,
    address _tokenHolder
  )
    internal
  {
    allowed[_tokenHolder][_spender] = (
      allowed[_tokenHolder][_spender].add(_addedValue));

    emit Approval(_tokenHolder, _spender, allowed[_tokenHolder][_spender]);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param _account The account that will receive the created tokens.
   * @param _amount The amount that will be created.
   */
  function _mint(address _account, uint256 _amount) internal {
    require(_account != 0);

    totalSupply_ = totalSupply_.add(_amount);
    balances.addBalance(_account, _amount);

    emit Transfer(address(0), _account, _amount);
  }

  function _transfer(address _from, address _to, uint256 _value) internal {
    require(_to != address(0), "to address cannot be 0x0");
    require(_from != address(0),"from address cannot be 0x0");
    require(_value <= balanceOf(_from), "not enough balance to transfer");

    // SafeMath.sub will throw if there is not enough balance.
    balances.subBalance(_from, _value);
    balances.addBalance(_to, _value);

    emit Transfer(_from, _to, _value);
  }

  function _transferFrom(
    address _from,
    address _to,
    uint256 _value,
    address _spender
  )
    internal
  {
    uint256 _allowed = allowed[_from][_spender];
    require(_value <= _allowed, "not enough allowance to transfer");

    allowed[_from][_spender] = allowed[_from][_spender].sub(_value);
    _transfer(_from, _to, _value);
  }
}





/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 **/
contract BurnableToken is StandardToken {
  event Burn(address indexed burner, uint256 value, string note);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   * @param _note a note that burner can attach.
   */
  function burn(uint256 _value, string _note) public returns (bool) {
    _burn(msg.sender, _value, _note);

    return true;
  }

  /**
   * @dev Burns a specific amount of tokens of an user.
   * @param _burner Who has tokens to be burned.
   * @param _value The amount of tokens to be burned.
   * @param _note a note that the manager can attach.
   */
  function _burn(
    address _burner,
    uint256 _value,
    string _note
  )
    internal
  {
    _burn(_burner, _value);

    emit Burn(_burner, _value, _note);
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



// Superclass for contracts that have a registry that can be set by their owners
contract HasRegistry is Ownable {
  Registry public registry;

  event SetRegistry(address indexed registry);

  function setRegistry(Registry _registry) public onlyOwner {
    registry = _registry;
    emit SetRegistry(registry);
  }
}



/**
 * @title Manageable
 * @dev The Manageable contract provides basic authorization control functions
 * for managers. This simplifies the implementation of "manager permissions".
 */
contract Manageable is HasRegistry {
  /**
   * @dev Throws if called by any account that is not in the managers list.
   */
  modifier onlyManager() {
    require(
      registry.hasAttribute(
        msg.sender,
        Attribute.AttributeType.ROLE_MANAGER
      )
    );
    _;
  }

  /**
   * @dev Getter to determine if address is a manager
   */
  function isManager(address _operator) public view returns (bool) {
    return registry.hasAttribute(
      _operator,
      Attribute.AttributeType.ROLE_MANAGER
    );
  }
}



// Interface implemented by tokens that are the *target* of a BurnableToken's
// delegation. That is, if we want to replace BurnableToken X by
// Y but for convenience we'd like users of X
// to be able to keep using it and it will just forward calls to Y,
// then X should extend CanDelegate and Y should extend DelegateBurnable.
// Most ERC20 calls use the value of msg.sender to figure out e.g. whose
// balance to update; since X becomes the msg.sender of all such calls
// that it forwards to Y, we add the origSender parameter to those calls.
// Delegation is intended as a convenience for legacy users of X since
// we do not expect all regular users to learn about Y and change accordingly,
// but we do require the *owner* of X to now use Y instead so ownerOnly
// functions are not delegated and should be disabled instead.
// This delegation system is intended to work with the modified versions of
// the standard ERC20 token contracts, allowing the balances
// to be moved over to a new contract.
// NOTE: To maintain backwards compatibility, these function signatures
// cannot be changed
contract DelegateBurnable {
  function delegateTotalSupply() public view returns (uint256);

  function delegateBalanceOf(address _who) public view returns (uint256);

  function delegateTransfer(address _to, uint256 _value, address _origSender)
    public returns (bool);

  function delegateAllowance(address _owner, address _spender)
    public view returns (uint256);

  function delegateTransferFrom(
    address _from,
    address _to,
    uint256 _value,
    address _origSender
  )
    public returns (bool);

  function delegateApprove(
    address _spender,
    uint256 _value,
    address _origSender
  )
    public returns (bool);

  function delegateIncreaseApproval(
    address _spender,
    uint256 _addedValue,
    address _origSender
  )
    public returns (bool);

  function delegateDecreaseApproval(
    address _spender,
    uint256 _subtractedValue,
    address _origSender
  )
    public returns (bool);

  function delegateBurn(
    address _origSender,
    uint256 _value,
    string _note
  )
    public;

  function delegateGetTheNumberOfHolders() public view returns (uint256);

  function delegateGetHolder(uint256 _index) public view returns (address);
}







/**
 * @title Contactable token
 * @dev Basic version of a contactable contract, allowing the owner to provide a string with their
 * contact information.
 */
contract Contactable is Ownable {

  string public contactInformation;

  /**
    * @dev Allows the owner to set a string with their contact information.
    * @param _info The contact information to attach to the contract.
    */
  function setContactInformation(string _info) public onlyOwner {
    contactInformation = _info;
  }
}










/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}





/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function _transfer(
    address _from,
    address _to,
    uint256 _value
  )
    internal
    whenNotPaused
  {
    super._transfer(_from, _to, _value);
  }

  function _transferFrom(
    address _from,
    address _to,
    uint256 _value,
    address _spender
  )
    internal
    whenNotPaused
  {
    super._transferFrom(_from, _to, _value, _spender);
  }

  function _approve(
    address _spender,
    uint256 _value,
    address _tokenHolder
  )
    internal
    whenNotPaused
  {
    super._approve(_spender, _value, _tokenHolder);
  }

  function _increaseApproval(
    address _spender,
    uint256 _addedValue,
    address _tokenHolder
  )
    internal
    whenNotPaused
  {
    super._increaseApproval(_spender, _addedValue, _tokenHolder);
  }

  function _decreaseApproval(
    address _spender,
    uint256 _subtractedValue,
    address _tokenHolder
  )
    internal
    whenNotPaused
  {
    super._decreaseApproval(_spender, _subtractedValue, _tokenHolder);
  }

  function _burn(
    address _burner,
    uint256 _value
  )
    internal
    whenNotPaused
  {
    super._burn(_burner, _value);
  }
}







// See DelegateBurnable.sol for more on the delegation system.
contract CanDelegateToken is BurnableToken {
  // If this contract needs to be upgraded, the new contract will be stored
  // in 'delegate' and any BurnableToken calls to this contract will be delegated to that one.
  DelegateBurnable public delegate;

  event DelegateToNewContract(address indexed newContract);

  // Can undelegate by passing in _newContract = address(0)
  function delegateToNewContract(
    DelegateBurnable _newContract
  )
    public
    onlyOwner
  {
    delegate = _newContract;
    emit DelegateToNewContract(delegate);
  }

  // If a delegate has been designated, all ERC20 calls are forwarded to it
  function _transfer(address _from, address _to, uint256 _value) internal {
    if (!_hasDelegate()) {
      super._transfer(_from, _to, _value);
    } else {
      require(delegate.delegateTransfer(_to, _value, _from));
    }
  }

  function _transferFrom(
    address _from,
    address _to,
    uint256 _value,
    address _spender
  )
    internal
  {
    if (!_hasDelegate()) {
      super._transferFrom(_from, _to, _value, _spender);
    } else {
      require(delegate.delegateTransferFrom(_from, _to, _value, _spender));
    }
  }

  function totalSupply() public view returns (uint256) {
    if (!_hasDelegate()) {
      return super.totalSupply();
    } else {
      return delegate.delegateTotalSupply();
    }
  }

  function balanceOf(address _who) public view returns (uint256) {
    if (!_hasDelegate()) {
      return super.balanceOf(_who);
    } else {
      return delegate.delegateBalanceOf(_who);
    }
  }

  function getTheNumberOfHolders() public view returns (uint256) {
    if (!_hasDelegate()) {
      return super.getTheNumberOfHolders();
    } else {
      return delegate.delegateGetTheNumberOfHolders();
    }
  }

  function getHolder(uint256 _index) public view returns (address) {
    if (!_hasDelegate()) {
      return super.getHolder(_index);
    } else {
      return delegate.delegateGetHolder(_index);
    }
  }

  function _approve(
    address _spender,
    uint256 _value,
    address _tokenHolder
  )
    internal
  {
    if (!_hasDelegate()) {
      super._approve(_spender, _value, _tokenHolder);
    } else {
      require(delegate.delegateApprove(_spender, _value, _tokenHolder));
    }
  }

  function allowance(
    address _owner,
    address _spender
  )
    public
    view
    returns (uint256)
  {
    if (!_hasDelegate()) {
      return super.allowance(_owner, _spender);
    } else {
      return delegate.delegateAllowance(_owner, _spender);
    }
  }

  function _increaseApproval(
    address _spender,
    uint256 _addedValue,
    address _tokenHolder
  )
    internal
  {
    if (!_hasDelegate()) {
      super._increaseApproval(_spender, _addedValue, _tokenHolder);
    } else {
      require(
        delegate.delegateIncreaseApproval(_spender, _addedValue, _tokenHolder)
      );
    }
  }

  function _decreaseApproval(
    address _spender,
    uint256 _subtractedValue,
    address _tokenHolder
  )
    internal
  {
    if (!_hasDelegate()) {
      super._decreaseApproval(_spender, _subtractedValue, _tokenHolder);
    } else {
      require(
        delegate.delegateDecreaseApproval(
          _spender,
          _subtractedValue,
          _tokenHolder)
      );
    }
  }

  function _burn(address _burner, uint256 _value, string _note) internal {
    if (!_hasDelegate()) {
      super._burn(_burner, _value, _note);
    } else {
      delegate.delegateBurn(_burner, _value , _note);
    }
  }

  function _hasDelegate() internal view returns (bool) {
    return !(delegate == address(0));
  }
}







// Treats all delegate functions exactly like the corresponding normal functions,
// e.g. delegateTransfer is just like transfer. See DelegateBurnable.sol for more on
// the delegation system.
contract DelegateToken is DelegateBurnable, BurnableToken {
  address public delegatedFrom;

  event DelegatedFromSet(address addr);

  // Only calls from appointed address will be processed
  modifier onlyMandator() {
    require(msg.sender == delegatedFrom);
    _;
  }

  function setDelegatedFrom(address _addr) public onlyOwner {
    delegatedFrom = _addr;
    emit DelegatedFromSet(_addr);
  }

  // each function delegateX is simply forwarded to function X
  function delegateTotalSupply(
  )
    public
    onlyMandator
    view
    returns (uint256)
  {
    return totalSupply();
  }

  function delegateBalanceOf(
    address _who
  )
    public
    onlyMandator
    view
    returns (uint256)
  {
    return balanceOf(_who);
  }

  function delegateTransfer(
    address _to,
    uint256 _value,
    address _origSender
  )
    public
    onlyMandator
    returns (bool)
  {
    _transfer(_origSender, _to, _value);
    return true;
  }

  function delegateAllowance(
    address _owner,
    address _spender
  )
    public
    onlyMandator
    view
    returns (uint256)
  {
    return allowance(_owner, _spender);
  }

  function delegateTransferFrom(
    address _from,
    address _to,
    uint256 _value,
    address _origSender
  )
    public
    onlyMandator
    returns (bool)
  {
    _transferFrom(_from, _to, _value, _origSender);
    return true;
  }

  function delegateApprove(
    address _spender,
    uint256 _value,
    address _origSender
  )
    public
    onlyMandator
    returns (bool)
  {
    _approve(_spender, _value, _origSender);
    return true;
  }

  function delegateIncreaseApproval(
    address _spender,
    uint256 _addedValue,
    address _origSender
  )
    public
    onlyMandator
    returns (bool)
  {
    _increaseApproval(_spender, _addedValue, _origSender);
    return true;
  }

  function delegateDecreaseApproval(
    address _spender,
    uint256 _subtractedValue,
    address _origSender
  )
    public
    onlyMandator
    returns (bool)
  {
    _decreaseApproval(_spender, _subtractedValue, _origSender);
    return true;
  }

  function delegateBurn(
    address _origSender,
    uint256 _value,
    string _note
  )
    public
    onlyMandator
  {
    _burn(_origSender, _value , _note);
  }

  function delegateGetTheNumberOfHolders() public view returns (uint256) {
    return getTheNumberOfHolders();
  }

  function delegateGetHolder(uint256 _index) public view returns (address) {
    return getHolder(_index);
  }
}






/**
 * @title Asset information.
 * @dev Stores information about a specified real asset.
 */
contract AssetInfo is Manageable {
  string public publicDocument;

  /**
   * Event for updated running documents logging.
   * @param newLink New link.
   */
  event UpdateDocument(
    string newLink
  );

  /**
   * @param _publicDocument A link to a zip file containing running documents of the asset.
   */
  constructor(string _publicDocument) public {
    publicDocument = _publicDocument;
  }

  /**
   * @dev Updates information about where to find new running documents of this asset.
   * @param _link A link to a zip file containing running documents of the asset.
   */
  function setPublicDocument(string _link) public onlyManager {
    publicDocument = _link;

    emit UpdateDocument(publicDocument);
  }
}







/**
 * @title BurnableExToken.
 * @dev Extension for the BurnableToken contract, to support
 * some manager to enforce burning all tokens of all holders.
 **/
contract BurnableExToken is Manageable, BurnableToken {

  /**
   * @dev Burns all remaining tokens of all holders.
   * @param _note a note that the manager can attach.
   */
  function burnAll(string _note) external onlyManager {
    uint256 _holdersCount = getTheNumberOfHolders();
    for (uint256 _i = 0; _i < _holdersCount; ++_i) {
      address _holder = getHolder(_i);
      uint256 _balance = balanceOf(_holder);
      if (_balance == 0) continue;

      _burn(_holder, _balance, _note);
    }
  }
}








/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 **/
contract MintableToken is StandardToken {
  event Mint(address indexed to, uint256 value);
  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _value
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    _mint(_to, _value);

    emit Mint(_to, _value);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}




contract CompliantToken is HasRegistry, MintableToken {
  // Addresses can also be blacklisted, preventing them from sending or receiving
  // PAT tokens. This can be used to prevent the use of PAT by bad actors in
  // accordance with law enforcement.

  modifier onlyIfNotBlacklisted(address _addr) {
    require(
      !registry.hasAttribute(
        _addr,
        Attribute.AttributeType.IS_BLACKLISTED
      )
    );
    _;
  }

  modifier onlyIfBlacklisted(address _addr) {
    require(
      registry.hasAttribute(
        _addr,
        Attribute.AttributeType.IS_BLACKLISTED
      )
    );
    _;
  }

  modifier onlyIfPassedKYC_AML(address _addr) {
    require(
      registry.hasAttribute(
        _addr,
        Attribute.AttributeType.HAS_PASSED_KYC_AML
      )
    );
    _;
  }

  function _mint(
    address _to,
    uint256 _value
  )
    internal
    onlyIfPassedKYC_AML(_to)
    onlyIfNotBlacklisted(_to)
  {
    super._mint(_to, _value);
  }

  // transfer and transferFrom both call this function, so check blacklist here.
  function _transfer(
    address _from,
    address _to,
    uint256 _value
  )
    internal
    onlyIfNotBlacklisted(_from)
    onlyIfNotBlacklisted(_to)
    onlyIfPassedKYC_AML(_to)
  {
    super._transfer(_from, _to, _value);
  }
}







/**
 * @title TokenWithFees.
 * @dev This contract allows for transaction fees to be assessed on transfer.
 **/
contract TokenWithFees is Manageable, StandardToken {
  uint8 public transferFeeNumerator = 0;
  uint8 public transferFeeDenominator = 100;
  // All transaction fees are paid to this address.
  address public beneficiary;

  event ChangeWallet(address indexed addr);
  event ChangeFees(uint8 transferFeeNumerator,
                   uint8 transferFeeDenominator);

  constructor(address _wallet) public {
    beneficiary = _wallet;
  }

  // transfer and transferFrom both call this function, so pay fee here.
  // E.g. if A transfers 1000 tokens to B, B will receive 999 tokens,
  // and the system wallet will receive 1 token.
  function _transfer(address _from, address _to, uint256 _value) internal {
    uint256 _fee = _payFee(_from, _value, _to);
    uint256 _remaining = _value.sub(_fee);
    super._transfer(_from, _to, _remaining);
  }

  function _payFee(
    address _payer,
    uint256 _value,
    address _otherParticipant
  )
    internal
    returns (uint256)
  {
    // This check allows accounts to be whitelisted and not have to pay transaction fees.
    bool _shouldBeFree = (
      registry.hasAttribute(_payer, Attribute.AttributeType.NO_FEES) ||
      registry.hasAttribute(_otherParticipant, Attribute.AttributeType.NO_FEES)
    );
    if (_shouldBeFree) {
      return 0;
    }

    uint256 _fee = _value.mul(transferFeeNumerator).div(transferFeeDenominator);
    if (_fee > 0) {
      super._transfer(_payer, beneficiary, _fee);
    }
    return _fee;
  }

  function checkTransferFee(uint256 _value) public view returns (uint256) {
    return _value.mul(transferFeeNumerator).div(transferFeeDenominator);
  }

  function changeFees(
    uint8 _transferFeeNumerator,
    uint8 _transferFeeDenominator
  )
    public
    onlyManager
  {
    require(_transferFeeNumerator < _transferFeeDenominator);
    transferFeeNumerator = _transferFeeNumerator;
    transferFeeDenominator = _transferFeeDenominator;

    emit ChangeFees(transferFeeNumerator, transferFeeDenominator);
  }

  /**
   * @dev Change address of the wallet where the fees will be sent to.
   * @param _beneficiary The new wallet address.
   */
  function changeWallet(address _beneficiary) public onlyManager {
    require(_beneficiary != address(0), "new wallet cannot be 0x0");
    beneficiary = _beneficiary;

    emit ChangeWallet(_beneficiary);
  }
}






// This allows a token to treat transfer(redeemAddress, value) as burn(value).
// This is useful for users of standard wallet programs which have transfer
// functionality built in but not the ability to burn.
contract WithdrawalToken is BurnableToken {
  address public constant redeemAddress = 0xfacecafe01facecafe02facecafe03facecafe04;

  function _transfer(address _from, address _to, uint256 _value) internal {
    if (_to == redeemAddress) {
      burn(_value, '');
    } else {
      super._transfer(_from, _to, _value);
    }
  }

  // StandardToken's transferFrom doesn't have to check for _to != redeemAddress,
  // but we do because we redirect redeemAddress transfers to burns, but
  // we do not redirect transferFrom
  function _transferFrom(
    address _from,
    address _to,
    uint256 _value,
    address _spender
  ) internal {
    require(_to != redeemAddress, "_to is redeem address");

    super._transferFrom(_from, _to, _value, _spender);
  }
}



/**
 * @title PAT token.
 * @dev PAT is a ERC20 token that:
 *  - has no tokens limit.
 *  - mints new tokens for each new property (real asset).
 *  - can pause and unpause token transfer (and authorization) actions.
 *  - token holders can be distributed profit from asset manager.
 *  - contains real asset information.
 *  - can delegate to a new contract.
 *  - can enforce burning all tokens.
 *  - transferring tokens to 0x0 address is treated as burning.
 *  - transferring tokens with fees are sent to the system wallet.
 *  - attempts to check KYC/AML and Blacklist using Registry.
 *  - attempts to reject ERC20 token transfers to itself and allows token transfer out.
 *  - attempts to reject ether sent and allows any ether held to be transferred out.
 *  - allows the new owner to accept the ownership transfer, the owner can cancel the transfer if needed.
 **/
contract PATToken is Contactable, AssetInfo, BurnableExToken, CanDelegateToken, DelegateToken, TokenWithFees, CompliantToken, WithdrawalToken, PausableToken {
  string public name = "RAX Mt.Fuji";
  string public symbol = "FUJI";
  uint8 public constant decimals = 18;

  event ChangeTokenName(string newName, string newSymbol);

  /**
   * @param _name Name of this token.
   * @param _symbol Symbol of this token.
   */
  constructor(
    string _name,
    string _symbol,
    string _publicDocument,
    address _wallet
  )
    public
    AssetInfo(_publicDocument)
    TokenWithFees(_wallet)
  {
    name = _name;
    symbol = _symbol;
    contactInformation = 'https://rax.exchange/';
  }

  function changeTokenName(string _name, string _symbol) public onlyOwner {
    name = _name;
    symbol = _symbol;
    emit ChangeTokenName(_name, _symbol);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a new owner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) onlyOwner public {
    // do not allow self ownership
    require(_newOwner != address(this));
    super.transferOwnership(_newOwner);
  }
}