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

contract ERC20 {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
  function allowance(address _owner, address _spender) public view returns (uint256);
  function approve(address _spender, uint256 _value) public returns (bool);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Ownable {
  address public owner;

  function Ownable() public {
    owner = msg.sender;
  }

  modifier isOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address _newOwner) public isOwner {
    require(_newOwner != address(0));
    OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);
}

contract Pausable is Ownable {
  bool public stopped = false;

  modifier isRunning() {
    require(!stopped);
    _;
  }

  modifier isStopped() {
    require(stopped);
    _;
  }

  function stop() isOwner isRunning public {
    stopped = true;
    Pause();
  }

  function start() isOwner isStopped public {
    stopped = false;
    Unpause();
  }

  event Pause();
  event Unpause();
}

contract CPTXToken is ERC20, Pausable {
  using SafeMath for uint256;

  string public constant name = "Crypterra Token";
  string public constant symbol = "CPTX";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 600000000 * (10 ** uint256(decimals));

  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;

  uint256 totalSupply_;

  function CPTXToken() public {
    totalSupply_ = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
    Transfer(0x0, msg.sender, INITIAL_SUPPLY);
  }

  modifier validAddress {
    assert(0x0 != msg.sender);
    _;
  }

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) isRunning validAddress public returns (bool) {
    require(_to != address(0));
    require(balances[msg.sender] >= _value);
    require(balances[_to] + _value >= balances[_to]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  function transferFrom(address _from, address _to, uint256 _value) isRunning validAddress public returns (bool) {
    require(_to != address(0));
    require(balances[_from] >= _value);
    require(allowed[_from][msg.sender] >= _value);
    require(balances[_to] + _value >= balances[_to]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) isRunning public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function burn(uint256 _value) public {
    require(_value > 0);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(msg.sender, _value);
  }
 
  event Burn(address indexed _burner, uint256 indexed _value);
}