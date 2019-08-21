pragma solidity ^0.4.0;

contract Templar {
string public constant symbol = "Templar";
  string public constant name = "KXT";
  uint8 public constant decimals = 18;
  uint256 public totalSupply = 100000000 * (uint256(10)**decimals);
  address public owner;
  uint256 public rate =  5000000000000;
  mapping(address => uint256) balances;
  mapping(address => mapping (address => uint256)) allowed;
  modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
function Mint() public{
  owner = msg.sender;
}
function () public payable {
  create(msg.sender);
}
function create(address beneficiary)public payable{
    uint256 amount = msg.value;
    if(amount > 0){
      balances[beneficiary] += amount/rate;
      totalSupply += amount/rate;
    }
  }
function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
}
function collect(uint256 amount) onlyOwner public{
  msg.sender.transfer(amount);
}
function transfer(address _to, uint256 _amount) public returns (bool success) {
    if (balances[msg.sender] >= _amount
        && _amount > 0
        && balances[_to] + _amount > balances[_to]) {
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        Transfer(msg.sender, _to, _amount);
        return true;
    } else {
        return false;
    }
}
function transferFrom(
    address _from,
    address _to,
    uint256 _amount
) public returns (bool success) {
    if (balances[_from] >= _amount
        && allowed[_from][msg.sender] >= _amount
        && _amount > 0
        && balances[_to] + _amount > balances[_to]) {
        balances[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;
        balances[_to] += _amount;
        Transfer(_from, _to, _amount);
        return true;
    } else {
        return false;
    }
}
function approve(address _spender, uint256 _amount) public returns (bool success) {
    allowed[msg.sender][_spender] = _amount;
    Approval(msg.sender, _spender, _amount);
    return true;
}
function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
}
}