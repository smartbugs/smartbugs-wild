pragma solidity ^0.4.24;


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
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

// ----------------------------------------------------------------------------
// Ownable contract
// ----------------------------------------------------------------------------
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
}

/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  event OwnershipTransferPending(address indexed owner, address indexed pendingOwner);

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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferPending(owner, pendingOwner);
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

// ----------------------------------------------------------------------------
// Pausable contract
// ----------------------------------------------------------------------------
/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Claimable {
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
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

/**
 * @title Callable
 * @dev Extension for the Claimable contract.
 * This allows the contract only be called by certain contract.
 */
contract Callable is Claimable {
  mapping(address => bool) public callers;

  event CallerAddressAdded(address indexed addr);
  event CallerAddressRemoved(address indexed addr);


  /**
   * @dev Modifier throws if called by any account other than the callers or owner.
   */
  modifier onlyCaller() {
    require(callers[msg.sender]);
    _;
  }

  /**
   * @dev add an address to the caller list
   * @param addr address
   * @return true if the address was added to the caller list, false if the address was already in the caller list
   */
  function addAddressToCaller(address addr) onlyOwner public returns(bool success) {
    if (!callers[addr]) {
      callers[addr] = true;
      emit CallerAddressAdded(addr);
      success = true;
    }
  }

  /**
   * @dev remove an address from the caller list
   * @param addr address
   * @return true if the address was removed from the caller list,
   * false if the address wasn't in the caller list in the first place
   */
  function removeAddressFromCaller(address addr) onlyOwner public returns(bool success) {
    if (callers[addr]) {
      callers[addr] = false;
      emit CallerAddressRemoved(addr);
      success = true;
    }
  }
}

// ----------------------------------------------------------------------------
// Blacklist
// ----------------------------------------------------------------------------
/**
 * @title Blacklist
 * @dev The Blacklist contract has a blacklist of addresses, and provides basic authorization control functions.
 */
contract Blacklist is Callable {
  mapping(address => bool) public blacklist;

  function addAddressToBlacklist(address addr) onlyCaller public returns (bool success) {
    if (!blacklist[addr]) {
      blacklist[addr] = true;
      success = true;
    }
  }

  function removeAddressFromBlacklist(address addr) onlyCaller public returns (bool success) {
    if (blacklist[addr]) {
      blacklist[addr] = false;
      success = true;
    }
  }
}

// ----------------------------------------------------------------------------
// Verified
// ----------------------------------------------------------------------------
/**
 * @title Verified
 * @dev The Verified contract has a list of verified addresses.
 */
contract Verified is Callable {
  mapping(address => bool) public verifiedList;
  bool public shouldVerify = true;

  function verifyAddress(address addr) onlyCaller public returns (bool success) {
    if (!verifiedList[addr]) {
      verifiedList[addr] = true;
      success = true;
    }
  }

  function unverifyAddress(address addr) onlyCaller public returns (bool success) {
    if (verifiedList[addr]) {
      verifiedList[addr] = false;
      success = true;
    }
  }

  function setShouldVerify(bool value) onlyCaller public returns (bool success) {
    shouldVerify = value;
    return true;
  }
}

// ----------------------------------------------------------------------------
// Allowance
// ----------------------------------------------------------------------------
/**
 * @title Allowance
 * @dev Storage for the Allowance List.
 */
contract Allowance is Callable {
  using SafeMath for uint256;

  mapping (address => mapping (address => uint256)) public allowanceOf;

  function addAllowance(address _holder, address _spender, uint256 _value) onlyCaller public {
    allowanceOf[_holder][_spender] = allowanceOf[_holder][_spender].add(_value);
  }

  function subAllowance(address _holder, address _spender, uint256 _value) onlyCaller public {
    uint256 oldValue = allowanceOf[_holder][_spender];
    if (_value > oldValue) {
      allowanceOf[_holder][_spender] = 0;
    } else {
      allowanceOf[_holder][_spender] = oldValue.sub(_value);
    }
  }

  function setAllowance(address _holder, address _spender, uint256 _value) onlyCaller public {
    allowanceOf[_holder][_spender] = _value;
  }
}

// ----------------------------------------------------------------------------
// Balance
// ----------------------------------------------------------------------------
/**
 * @title Balance
 * @dev Storage for the Balance List.
 */
contract Balance is Callable {
  using SafeMath for uint256;

  mapping (address => uint256) public balanceOf;

  uint256 public totalSupply;

  function addBalance(address _addr, uint256 _value) onlyCaller public {
    balanceOf[_addr] = balanceOf[_addr].add(_value);
  }

  function subBalance(address _addr, uint256 _value) onlyCaller public {
    balanceOf[_addr] = balanceOf[_addr].sub(_value);
  }

  function setBalance(address _addr, uint256 _value) onlyCaller public {
    balanceOf[_addr] = _value;
  }

  function addTotalSupply(uint256 _value) onlyCaller public {
    totalSupply = totalSupply.add(_value);
  }

  function subTotalSupply(uint256 _value) onlyCaller public {
    totalSupply = totalSupply.sub(_value);
  }
}

// ----------------------------------------------------------------------------
// UserContract
// ----------------------------------------------------------------------------
/**
 * @title UserContract
 * @dev A contract for the blacklist and verified list modifiers.
 */
contract UserContract {
  Blacklist internal _blacklist;
  Verified internal _verifiedList;

  constructor(
    Blacklist _blacklistContract, Verified _verifiedListContract
  ) public {
    _blacklist = _blacklistContract;
    _verifiedList = _verifiedListContract;
  }


  /**
   * @dev Throws if the given address is blacklisted.
   */
  modifier onlyNotBlacklistedAddr(address addr) {
    require(!_blacklist.blacklist(addr));
    _;
  }

  /**
   * @dev Throws if one of the given addresses is blacklisted.
   */
  modifier onlyNotBlacklistedAddrs(address[] addrs) {
    for (uint256 i = 0; i < addrs.length; i++) {
      require(!_blacklist.blacklist(addrs[i]));
    }
    _;
  }

  /**
   * @dev Throws if the given address is not verified.
   */
  modifier onlyVerifiedAddr(address addr) {
    if (_verifiedList.shouldVerify()) {
      require(_verifiedList.verifiedList(addr));
    }
    _;
  }

  /**
   * @dev Throws if one of the given addresses is not verified.
   */
  modifier onlyVerifiedAddrs(address[] addrs) {
    if (_verifiedList.shouldVerify()) {
      for (uint256 i = 0; i < addrs.length; i++) {
        require(_verifiedList.verifiedList(addrs[i]));
      }
    }
    _;
  }

  function blacklist(address addr) public view returns (bool) {
    return _blacklist.blacklist(addr);
  }

  function verifiedlist(address addr) public view returns (bool) {
    return _verifiedList.verifiedList(addr);
  }
}

// ----------------------------------------------------------------------------
// ContractInterface
// ----------------------------------------------------------------------------
contract ContractInterface {
  function totalSupply() public view returns (uint256);
  function balanceOf(address tokenOwner) public view returns (uint256);
  function allowance(address tokenOwner, address spender) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function batchTransfer(address[] to, uint256 value) public returns (bool);
  function increaseApproval(address spender, uint256 value) public returns (bool);
  function decreaseApproval(address spender, uint256 value) public returns (bool);
  function burn(uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed tokenOwner, address indexed spender, uint256 value);
  // This notifies clients about the amount burnt
  event Burn(address indexed from, uint256 value);
}

// ----------------------------------------------------------------------------
// USDO contract
// ----------------------------------------------------------------------------
contract USDO is ContractInterface, Pausable, UserContract {
  using SafeMath for uint256;

  // variables of the token
  uint8 public constant decimals = 18;
  uint256 constant maxBatch = 100;

  string public name;
  string public symbol;

  Balance internal _balances;
  Allowance internal _allowance;

  constructor(string _tokenName, string _tokenSymbol,
    Balance _balanceContract, Allowance _allowanceContract,
    Blacklist _blacklistContract, Verified _verifiedListContract
  ) UserContract(_blacklistContract, _verifiedListContract) public {
    name = _tokenName;                                        // Set the name for display purposes
    symbol = _tokenSymbol;                                    // Set the symbol for display purposes
    _balances = _balanceContract;
    _allowance = _allowanceContract;
  }

  function totalSupply() public view returns (uint256) {
    return _balances.totalSupply();
  }

  function balanceOf(address _addr) public view returns (uint256) {
    return _balances.balanceOf(_addr);
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return _allowance.allowanceOf(_owner, _spender);
  }

  /**
   *  @dev Internal transfer, only can be called by this contract
   */
  function _transfer(address _from, address _to, uint256 _value) internal {
    require(_value > 0);                                               // transfering value must be greater than 0
    require(_to != 0x0);                                               // Prevent transfer to 0x0 address. Use burn() instead
    require(_balances.balanceOf(_from) >= _value);                     // Check if the sender has enough
    uint256 previousBalances = _balances.balanceOf(_from).add(_balances.balanceOf(_to)); // Save this for an assertion in the future
    _balances.subBalance(_from, _value);                 // Subtract from the sender
    _balances.addBalance(_to, _value);                     // Add the same to the recipient
    emit Transfer(_from, _to, _value);
    // Asserts are used to use static analysis to find bugs in your code. They should never fail
    assert(_balances.balanceOf(_from) + _balances.balanceOf(_to) == previousBalances);
  }

  /**
   * @dev Transfer tokens
   * Send `_value` tokens to `_to` from your account
   *
   * @param _to The address of the recipient
   * @param _value the amount to send
   */
  function transfer(address _to, uint256 _value)
  whenNotPaused onlyNotBlacklistedAddr(msg.sender) onlyNotBlacklistedAddr(_to) onlyVerifiedAddr(msg.sender) onlyVerifiedAddr(_to)
  public returns (bool) {
    _transfer(msg.sender, _to, _value);
    return true;
  }


  /**
   * @dev Transfer tokens to multiple accounts
   * Send `_value` tokens to all addresses in `_to` from your account
   *
   * @param _to The addresses of the recipients
   * @param _value the amount to send
   */
  function batchTransfer(address[] _to, uint256 _value)
  whenNotPaused onlyNotBlacklistedAddr(msg.sender) onlyNotBlacklistedAddrs(_to) onlyVerifiedAddr(msg.sender) onlyVerifiedAddrs(_to)
  public returns (bool) {
    uint256 cnt = uint256(_to.length);
    require(cnt > 0 && cnt <= maxBatch && _value > 0);
    uint256 amount = _value.mul(cnt);
    require(_balances.balanceOf(msg.sender) >= amount);

    for (uint256 i = 0; i < cnt; i++) {
      _transfer(msg.sender, _to[i], _value);
    }
    return true;
  }

  /**
   * @dev Transfer tokens from other address
   * Send `_value` tokens to `_to` in behalf of `_from`
   *
   * @param _from The address of the sender
   * @param _to The address of the recipient
   * @param _value the amount to send
   */
  function transferFrom(address _from, address _to, uint256 _value)
  whenNotPaused onlyNotBlacklistedAddr(_from) onlyNotBlacklistedAddr(_to) onlyVerifiedAddr(_from) onlyVerifiedAddr(_to)
  public returns (bool) {
    require(_allowance.allowanceOf(_from, msg.sender) >= _value);     // Check allowance
    _allowance.subAllowance(_from, msg.sender, _value);
    _transfer(_from, _to, _value);
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
   *
   * Allows `_spender` to spend no more than `_value` tokens in your behalf
   *
   * @param _spender The address authorized to spend
   * @param _value the max amount they can spend
   */
  function approve(address _spender, uint256 _value)
  whenNotPaused onlyNotBlacklistedAddr(msg.sender) onlyNotBlacklistedAddr(_spender) onlyVerifiedAddr(msg.sender) onlyVerifiedAddr(_spender)
  public returns (bool) {
    _allowance.setAllowance(msg.sender, _spender, _value);
    emit Approval(msg.sender, _spender, _value);
    return true;
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
  function increaseApproval(address _spender, uint256 _addedValue)
  whenNotPaused onlyNotBlacklistedAddr(msg.sender) onlyNotBlacklistedAddr(_spender) onlyVerifiedAddr(msg.sender) onlyVerifiedAddr(_spender)
  public returns (bool) {
    _allowance.addAllowance(msg.sender, _spender, _addedValue);
    emit Approval(msg.sender, _spender, _allowance.allowanceOf(msg.sender, _spender));
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
  function decreaseApproval(address _spender, uint256 _subtractedValue)
  whenNotPaused onlyNotBlacklistedAddr(msg.sender) onlyNotBlacklistedAddr(_spender) onlyVerifiedAddr(msg.sender) onlyVerifiedAddr(_spender)
  public returns (bool) {
    _allowance.subAllowance(msg.sender, _spender, _subtractedValue);
    emit Approval(msg.sender, _spender, _allowance.allowanceOf(msg.sender, _spender));
    return true;
  }

  /**
   * @dev Destroy tokens
   * Remove `_value` tokens from the system irreversibly
   *
   * @param _value the amount of money to burn
   */
  function burn(uint256 _value) whenNotPaused onlyNotBlacklistedAddr(msg.sender) onlyVerifiedAddr(msg.sender)
  public returns (bool success) {
    require(_balances.balanceOf(msg.sender) >= _value);         // Check if the sender has enough
    _balances.subBalance(msg.sender, _value);                   // Subtract from the sender
    _balances.subTotalSupply(_value);                           // Updates totalSupply
    emit Burn(msg.sender, _value);
    return true;
  }

  /**
   * @dev Change name and symbol of the tokens
   *
   * @param _name the new name of the token
   * @param _symbol the new symbol of the token
   */
  function changeName(string _name, string _symbol) onlyOwner whenNotPaused public {
    name = _name;
    symbol = _symbol;
  }
}