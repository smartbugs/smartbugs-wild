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
    uint256 c = a / b;
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

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
}

// built upon OpenZeppelin

contract Oryza is BasicToken, Ownable {

  string public constant name = "Oryza";
  string public constant symbol = "米";
  uint256 public constant decimals = 0;

  event Mint(address indexed to, uint256 amount);

  function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }
}

contract OryzaOffering is Ownable {
  using SafeMath for uint256;

  Oryza public oryza = new Oryza();
  uint256 public price = 3906250000000000;

  event Purchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function () external payable {
    purchase(msg.sender);
  }

  function purchase(address beneficiary) public payable {
    require(beneficiary != address(0) && msg.value != 0);

    uint256 value = msg.value;
    uint256 amount = value.div(price);

    oryza.mint(beneficiary, amount);
    Purchase(msg.sender, beneficiary, value, amount);
    owner.transfer(msg.value);
  }

  function issue(address beneficiary, uint256 amount) onlyOwner public {
    require(beneficiary != address(0));

    oryza.mint(beneficiary, amount);
  }
}