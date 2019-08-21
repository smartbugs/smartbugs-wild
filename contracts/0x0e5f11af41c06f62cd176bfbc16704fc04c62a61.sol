pragma solidity ^0.4.18;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
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
  function Ownable() public {
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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Token is ERC20, Ownable {
  using SafeMath for uint;

  // Token 信息

  string public constant name = "Truedeal Token";
  string public constant symbol = "TDT";

  uint8 public decimals = 18;

  mapping (address => uint256) accounts; // User Accounts
  mapping (address => mapping (address => uint256)) allowed; // User's allowances table

  // Modifier
  modifier nonZeroAddress(address _to) {                 // Ensures an address is provided
      require(_to != 0x0);
      _;
  }

  modifier nonZeroAmount(uint _amount) {                 // Ensures a non-zero amount
      require(_amount > 0);
      _;
  }

  modifier nonZeroValue() {                              // Ensures a non-zero value is passed
      require(msg.value > 0);
      _;
  }

  // ERC20 API

  // -------------------------------------------------
  // Transfers to another address
  // -------------------------------------------------
  function transfer(address _to, uint256 _amount) public returns (bool success) {
      require(accounts[msg.sender] >= _amount);         // check amount of balance can be tranfetdt
      addToBalance(_to, _amount);
      decrementBalance(msg.sender, _amount);
      Transfer(msg.sender, _to, _amount);
      return true;
  }

  // -------------------------------------------------
  // Transfers from one address to another (need allowance to be called first)
  // -------------------------------------------------
  function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
      require(allowance(_from, msg.sender) >= _amount);
      decrementBalance(_from, _amount);
      addToBalance(_to, _amount);
      allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
      Transfer(_from, _to, _amount);
      return true;
  }

  // -------------------------------------------------
  // Approves another address a certain amount of TDT
  // -------------------------------------------------
  function approve(address _spender, uint256 _value) public returns (bool success) {
      require((_value == 0) || (allowance(msg.sender, _spender) == 0));
      allowed[msg.sender][_spender] = _value;
      Approval(msg.sender, _spender, _value);
      return true;
  }

  // -------------------------------------------------
  // Gets an address's TDT allowance
  // -------------------------------------------------
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
  }

  // -------------------------------------------------
  // Gets the TDT balance of any address
  // -------------------------------------------------
  function balanceOf(address _owner) public constant returns (uint256 balance) {
      return accounts[_owner];
  }

  function Token(address _address) public {
    totalSupply = 8000000000 * 1e18;
    addToBalance(_address, totalSupply);
    Transfer(0x0, _address, totalSupply);
  }

  // -------------------------------------------------
  // Add balance
  // -------------------------------------------------
  function addToBalance(address _address, uint _amount) internal {
    accounts[_address] = accounts[_address].add(_amount);
  }

  // -------------------------------------------------
  // Sub balance
  // -------------------------------------------------
  function decrementBalance(address _address, uint _amount) internal {
    accounts[_address] = accounts[_address].sub(_amount);
  }
}