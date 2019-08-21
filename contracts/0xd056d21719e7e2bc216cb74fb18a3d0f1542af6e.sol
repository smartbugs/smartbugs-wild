pragma solidity ^0.4.19;

contract TEMPLAR {
string public constant symbol ="TXK";
  string public constant name ="TEMPLAR";
  uint8 public constant decimals = 8;
  uint256 public totalSupply = 800000000 * 10 ** uint256(decimals);
  address public owner = msg.sender;
  uint256 public RATE_ETH_TXK = 80000;
  mapping(address => uint256) balances;
  mapping(address => mapping (address => uint256)) allowed;
  modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
function TEMPLAR() public{
  owner = msg.sender;
}
function () public payable {
  create(msg.sender);
}
function create(address beneficiary)public payable{
    uint256 amount = msg.value;
    if(amount > 0){
      balances[beneficiary] += amount/RATE_ETH_TXK;
      totalSupply += amount/RATE_ETH_TXK;
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