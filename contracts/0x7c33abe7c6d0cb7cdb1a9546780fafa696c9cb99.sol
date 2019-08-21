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

// ----------------------------------------------------------------------------
// Administratable contract
// ----------------------------------------------------------------------------
/**
 * @title Administratable
 * @dev The Admin contract has the list of admin addresses.
 */
contract Administratable is Claimable {
  struct MintStruct {
    uint256 mintedTotal;
    uint256 lastMintTimestamp;
  }

  struct BurnStruct {
    uint256 burntTotal;
    uint256 lastBurnTimestamp;
  }

  mapping(address => bool) public admins;
  mapping(address => MintStruct) public mintLimiter;
  mapping(address => BurnStruct) public burnLimiter;

  event AdminAddressAdded(address indexed addr);
  event AdminAddressRemoved(address indexed addr);


  /**
   * @dev Throws if called by any account that's not admin or owner.
   */
  modifier onlyAdmin() {
    require(admins[msg.sender] || msg.sender == owner);
    _;
  }

  /**
   * @dev add an address to the admin list
   * @param addr address
   * @return true if the address was added to the admin list, false if the address was already in the admin list
   */
  function addAddressToAdmin(address addr) onlyOwner public returns(bool success) {
    if (!admins[addr]) {
      admins[addr] = true;
      mintLimiter[addr] = MintStruct(0, 0);
      burnLimiter[addr] = BurnStruct(0, 0);
      emit AdminAddressAdded(addr);
      success = true;
    }
  }

  /**
   * @dev remove an address from the admin list
   * @param addr address
   * @return true if the address was removed from the admin list,
   * false if the address wasn't in the admin list in the first place
   */
  function removeAddressFromAdmin(address addr) onlyOwner public returns(bool success) {
    if (admins[addr]) {
      admins[addr] = false;
      delete mintLimiter[addr];
      delete burnLimiter[addr];
      emit AdminAddressRemoved(addr);
      success = true;
    }
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

/**
 * @title ControllerContract
 * @dev A contract for managing the blacklist and verified list and burning and minting of the tokens.
 */
contract ControllerContract is Pausable, Administratable, UserContract {
  using SafeMath for uint256;
  Balance internal _balances;

  uint256 constant decimals = 18;
  uint256 constant maxBLBatch = 100;
  uint256 public dailyMintLimit = 10000 * 10 ** decimals;
  uint256 public dailyBurnLimit = 10000 * 10 ** decimals;
  uint256 constant dayInSeconds = 86400;

  constructor(
    Balance _balanceContract, Blacklist _blacklistContract, Verified _verifiedListContract
  ) UserContract(_blacklistContract, _verifiedListContract) public {
    _balances = _balanceContract;
  }

  // This notifies clients about the amount burnt
  event Burn(address indexed from, uint256 value);
  // This notifies clients about the amount mint
  event Mint(address indexed to, uint256 value);
  // This notifies clients about the amount of limit mint by some admin
  event LimitMint(address indexed admin, address indexed to, uint256 value);
  // This notifies clients about the amount of limit burn by some admin
  event LimitBurn(address indexed admin, address indexed from, uint256 value);

  event VerifiedAddressAdded(address indexed addr);
  event VerifiedAddressRemoved(address indexed addr);

  event BlacklistedAddressAdded(address indexed addr);
  event BlacklistedAddressRemoved(address indexed addr);

  // blacklist operations
  function _addToBlacklist(address addr) internal returns (bool success) {
    success = _blacklist.addAddressToBlacklist(addr);
    if (success) {
      emit BlacklistedAddressAdded(addr);
    }
  }

  function _removeFromBlacklist(address addr) internal returns (bool success) {
    success = _blacklist.removeAddressFromBlacklist(addr);
    if (success) {
      emit BlacklistedAddressRemoved(addr);
    }
  }

  /**
   * @dev add an address to the blacklist
   * @param addr address
   * @return true if the address was added to the blacklist, false if the address was already in the blacklist
   */
  function addAddressToBlacklist(address addr) onlyAdmin whenNotPaused public returns (bool) {
    return _addToBlacklist(addr);
  }

  /**
   * @dev add addresses to the blacklist
   * @param addrs addresses
   * @return true if at least one address was added to the blacklist,
   * false if all addresses were already in the blacklist
   */
  function addAddressesToBlacklist(address[] addrs) onlyAdmin whenNotPaused public returns (bool success) {
    uint256 cnt = uint256(addrs.length);
    require(cnt <= maxBLBatch);
    success = true;
    for (uint256 i = 0; i < addrs.length; i++) {
      if (!_addToBlacklist(addrs[i])) {
        success = false;
      }
    }
  }

  /**
   * @dev remove an address from the blacklist
   * @param addr address
   * @return true if the address was removed from the blacklist,
   * false if the address wasn't in the blacklist in the first place
   */
  function removeAddressFromBlacklist(address addr) onlyAdmin whenNotPaused public returns (bool) {
    return _removeFromBlacklist(addr);
  }

  /**
   * @dev remove addresses from the blacklist
   * @param addrs addresses
   * @return true if at least one address was removed from the blacklist,
   * false if all addresses weren't in the blacklist in the first place
   */
  function removeAddressesFromBlacklist(address[] addrs) onlyAdmin whenNotPaused public returns (bool success) {
    success = true;
    for (uint256 i = 0; i < addrs.length; i++) {
      if (!_removeFromBlacklist(addrs[i])) {
        success = false;
      }
    }
  }

  // verified list operations
  function _verifyAddress(address addr) internal returns (bool success) {
    success = _verifiedList.verifyAddress(addr);
    if (success) {
      emit VerifiedAddressAdded(addr);
    }
  }

  function _unverifyAddress(address addr) internal returns (bool success) {
    success = _verifiedList.unverifyAddress(addr);
    if (success) {
      emit VerifiedAddressRemoved(addr);
    }
  }

  /**
   * @dev add an address to the verifiedlist
   * @param addr address
   * @return true if the address was added to the verifiedlist, false if the address was already in the verifiedlist or if the address is in the blacklist
   */
  function verifyAddress(address addr) onlyAdmin onlyNotBlacklistedAddr(addr) whenNotPaused public returns (bool) {
    return _verifyAddress(addr);
  }

  /**
   * @dev add addresses to the verifiedlist
   * @param addrs addresses
   * @return true if at least one address was added to the verifiedlist,
   * false if all addresses were already in the verifiedlist
   */
  function verifyAddresses(address[] addrs) onlyAdmin onlyNotBlacklistedAddrs(addrs) whenNotPaused public returns (bool success) {
    success = true;
    for (uint256 i = 0; i < addrs.length; i++) {
      if (!_verifyAddress(addrs[i])) {
        success = false;
      }
    }
  }


  /**
   * @dev remove an address from the verifiedlist
   * @param addr address
   * @return true if the address was removed from the verifiedlist,
   * false if the address wasn't in the verifiedlist in the first place
   */
  function unverifyAddress(address addr) onlyAdmin whenNotPaused public returns (bool) {
    return _unverifyAddress(addr);
  }


  /**
   * @dev remove addresses from the verifiedlist
   * @param addrs addresses
   * @return true if at least one address was removed from the verifiedlist,
   * false if all addresses weren't in the verifiedlist in the first place
   */
  function unverifyAddresses(address[] addrs) onlyAdmin whenNotPaused public returns (bool success) {
    success = true;
    for (uint256 i = 0; i < addrs.length; i++) {
      if (!_unverifyAddress(addrs[i])) {
        success = false;
      }
    }
  }

  /**
   * @dev set if to use the verified list
   * @param value true if should verify address, false if should skip address verification
   */
   function shouldVerify(bool value) onlyOwner public returns (bool success) {
     _verifiedList.setShouldVerify(value);
     return true;
   }

  /**
   * Destroy tokens from other account
   *
   * Remove `_amount` tokens from the system irreversibly on behalf of `_from`.
   *
   * @param _from the address of the sender
   * @param _amount the amount of money to burn
   */
  function burnFrom(address _from, uint256 _amount) onlyOwner whenNotPaused
  public returns (bool success) {
    require(_balances.balanceOf(_from) >= _amount);    // Check if the targeted balance is enough
    _balances.subBalance(_from, _amount);              // Subtract from the targeted balance
    _balances.subTotalSupply(_amount);
    emit Burn(_from, _amount);
    return true;
  }

  /**
   * Destroy tokens from other account
   * If the burn total amount exceeds the daily threshold, this operation will fail
   *
   * Remove `_amount` tokens from the system irreversibly on behalf of `_from`.
   *
   * @param _from the address of the sender
   * @param _amount the amount of money to burn
   */
  function limitBurnFrom(address _from, uint256 _amount) onlyAdmin whenNotPaused
  public returns (bool success) {
    require(_balances.balanceOf(_from) >= _amount && _amount <= dailyBurnLimit);
    if (burnLimiter[msg.sender].lastBurnTimestamp.div(dayInSeconds) != now.div(dayInSeconds)) {
      burnLimiter[msg.sender].burntTotal = 0;
    }
    require(burnLimiter[msg.sender].burntTotal.add(_amount) <= dailyBurnLimit);
    _balances.subBalance(_from, _amount);              // Subtract from the targeted balance
    _balances.subTotalSupply(_amount);
    burnLimiter[msg.sender].lastBurnTimestamp = now;
    burnLimiter[msg.sender].burntTotal = burnLimiter[msg.sender].burntTotal.add(_amount);
    emit LimitBurn(msg.sender, _from, _amount);
    emit Burn(_from, _amount);
    return true;
  }

  /**
    * Add `_amount` tokens to the pool and to the `_to` address' balance.
    * If the mint total amount exceeds the daily threshold, this operation will fail
    *
    * @param _to the address that will receive the given amount of tokens
    * @param _amount the amount of tokens it will receive
    */
  function limitMint(address _to, uint256 _amount)
  onlyAdmin whenNotPaused onlyNotBlacklistedAddr(_to) onlyVerifiedAddr(_to)
  public returns (bool success) {
    require(_to != msg.sender);
    require(_amount <= dailyMintLimit);
    if (mintLimiter[msg.sender].lastMintTimestamp.div(dayInSeconds) != now.div(dayInSeconds)) {
      mintLimiter[msg.sender].mintedTotal = 0;
    }
    require(mintLimiter[msg.sender].mintedTotal.add(_amount) <= dailyMintLimit);
    _balances.addBalance(_to, _amount);
    _balances.addTotalSupply(_amount);
    mintLimiter[msg.sender].lastMintTimestamp = now;
    mintLimiter[msg.sender].mintedTotal = mintLimiter[msg.sender].mintedTotal.add(_amount);
    emit LimitMint(msg.sender, _to, _amount);
    emit Mint(_to, _amount);
    return true;
  }

  function setDailyMintLimit(uint256 _limit) onlyOwner public returns (bool) {
    dailyMintLimit = _limit;
    return true;
  }

  function setDailyBurnLimit(uint256 _limit) onlyOwner public returns (bool) {
    dailyBurnLimit = _limit;
    return true;
  }

  /**
    * Add `_amount` tokens to the pool and to the `_to` address' balance
    *
    * @param _to the address that will receive the given amount of tokens
    * @param _amount the amount of tokens it will receive
    */
  function mint(address _to, uint256 _amount)
  onlyOwner whenNotPaused onlyNotBlacklistedAddr(_to) onlyVerifiedAddr(_to)
  public returns (bool success) {
    _balances.addBalance(_to, _amount);
    _balances.addTotalSupply(_amount);
    emit Mint(_to, _amount);
    return true;
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