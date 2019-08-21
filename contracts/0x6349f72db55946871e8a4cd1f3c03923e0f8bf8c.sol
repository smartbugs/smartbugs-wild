pragma solidity ^0.4.24;


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