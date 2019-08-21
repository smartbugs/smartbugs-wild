pragma solidity ^0.4.11;

contract ERC20 {
  uint256 public totalSupply;

  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  
  function approve(address spender, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract PortCoin is ERC20 {

  address mayor;

  string public name = "Portland Maine Token";
  string public symbol = "PORT";
  uint public decimals = 0;

  mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) approvals;

  event NewMayor(address indexed oldMayor, address indexed newMayor);

  function PortCoin() {
    mayor = msg.sender;
  }

  modifier onlyMayor() {
    require(msg.sender == mayor);
    _;
  }

  function electNewMayor(address newMayor) onlyMayor public {
    address oldMayor = mayor;
    mayor = newMayor;
    NewMayor(oldMayor, newMayor);
  }

  function issue(address to, uint256 amount) onlyMayor public returns (bool){
    totalSupply += amount;
    balances[to] += amount;
    Transfer(0x0, to, amount);
    return true;
  }

  function balanceOf(address who) public constant returns (uint256) {
    return balances[who];
  }

  function transfer(address to, uint256 value) public returns (bool) {
    require(balances[msg.sender] >= value);
    balances[to] += value;
    balances[msg.sender] -= value;
    Transfer(msg.sender, to, value);
    return true;
  }

  function approve(address spender, uint256 value) public returns (bool) {
    approvals[msg.sender][spender] = value;
    Approval(msg.sender, spender, value);
    return true;
  }

  function allowance(address owner, address spender) public constant returns (uint256) {
    return approvals[owner][spender];
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(approvals[from][msg.sender] >= value);
    require(balances[from] >= value);

    balances[to] += value;
    balances[from] -= value;
    approvals[from][msg.sender] -= value;
    Transfer(from, to, value);
    return true;
  }
}