pragma solidity ^0.4.22;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  /**
   * @dev Multiplies two numbers, throws on overflow
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0 || b == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
   * @dev Integer division of two numbers, truncating the quotient
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of ERC20 token interface
 */
contract ERC20Token {
  using SafeMath for uint256;

  uint256 public totalSupply;

  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) public allowance;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  /**
   * @dev Send tokens to a specified address
   * @param _to     address  The address to send to
   * @param _value  uint256  The amount to send
   */
  function transfer(address _to, uint256 _value) public returns (bool) {
    // Prevent sending to zero address
    require(_to != address(0));
    // Check sender has enough balance
    require(_value <= balanceOf[msg.sender]);

    // Do transfer
    balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
    balanceOf[_to] = balanceOf[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);

    return true;
  }

  /**
   * @dev Send tokens in behalf of one address to another
   * @param _from   address   The sender address
   * @param _to     address   The recipient address
   * @param _value  uint256   The amount to send
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    // Prevent sending to zero address
    require(_to != address(0));
    // Check sender has enough balance
    require(_value <= balanceOf[_from]);
    // Check caller has enough allowed balance
    require(_value <= allowance[_from][msg.sender]);

    // Make sure sending amount is subtracted from `allowance` before actual transfer
    allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

    // Do transfer
    balanceOf[_from] = balanceOf[_from].sub(_value);
    balanceOf[_to] = balanceOf[_to].add(_value);

    emit Transfer(_from, _to, _value);

    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender  address   The address which will spend the funds.
   * @param _value    uint256   The amount of tokens can be spend.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowance[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }
}

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

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

/**
 * @title ApproveAndCallFallBack
 * @dev Interface to notify contracts about approved tokens
 */
contract ApproveAndCallFallBack {
  function receiveApproval(address _from, uint256 _amount, address _token, bytes _data) public;
}

contract BCBToken is ERC20Token, Ownable {
  uint256 constant public BCB_UNIT = 10 ** 18;

  string public constant name = "BCBToken";
  string public constant symbol = "BCB";
  uint32 public constant decimals = 18;

  uint256 public totalSupply = 120000000 * BCB_UNIT;
  uint256 public lockedAllocation = 53500000 * BCB_UNIT;
  uint256 public totalAllocated = 0;
  address public allocationAddress;

  uint256 public lockEndTime;

  constructor(address _allocationAddress) public {
    // Transfer the rest of the tokens to the owner
    balanceOf[owner] = totalSupply - lockedAllocation;
    allocationAddress = _allocationAddress;

    // Lock for 12 months
    lockEndTime = now + 12 * 30 days;
  }

  /**
   * @dev Release all locked tokens
   * throws if called not by the owner or called before timelock (12 months)
   * or if tokens were already allocated
   */
  function releaseLockedTokens() public onlyOwner {
    require(now > lockEndTime);
    require(totalAllocated < lockedAllocation);

    totalAllocated = lockedAllocation;
    balanceOf[allocationAddress] = balanceOf[allocationAddress].add(lockedAllocation);

    emit Transfer(0x0, allocationAddress, lockedAllocation);
  }

  /**
   * @dev Allow other contract to spend tokens and notify the contract about it a in single transaction
   * @param _spender    address   The contract address authorized to spend
   * @param _value      uint256   The amount of tokens can be spend
   * @param _extraData  bytes     Some extra information to send to the approved contract
   */
  function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool) {
    if (approve(_spender, _value)) {
      ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _value, address(this), _extraData);
      return true;
    }
  }
}