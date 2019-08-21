pragma solidity ^0.4.10;
contract NVTNetworkToken { 
// set contract name
   
string public name; 
string public symbol; 
uint8 public decimals;
uint256 public totalSupply;
 
// Balances for each account
mapping(address => uint256) balances;
address devAddress;
// Events
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event Transfer(address indexed from, address indexed to, uint256 value);
 
// Owner of the account approves the transfer of an amount to another account
mapping(address => mapping (address => uint256)) allowed;
// Constructor function
function NVTNetworkToken() { 
    name = "NVTNetworkToken";
    symbol = "NVT";
    decimals = 18; // sets the number of decimals
    devAddress=0x529F1b18b28D73461602d7143f6d3758628D383f; // address that will distribute the tokens
    uint initialBalance=1000000000000000000*1000000000; // 1 billion tokens
    balances[devAddress]=initialBalance;
    totalSupply+=initialBalance; // sets the total supply
}
function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
}
// Transfer the balance from owner's account to another account
function transfer(address _to, uint256 _amount) returns (bool success) {
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
) returns (bool success) {
    if (balances[_from] >= _amount
        && allowed[_from][msg.sender] >= _amount
        && _amount > 0
        && balances[_to] + _amount > balances[_to]) {
        balances[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;
        balances[_to] += _amount;
        return true;
    } else {
        return false;
    }
}
//If this function is called again it overwrites the current allowance with _value.
function approve(address _spender, uint256 _amount) returns (bool success) {
    allowed[msg.sender][_spender] = _amount;
    Approval(msg.sender, _spender, _amount);
    return true;
}
}