pragma solidity ^0.4.8;
contract Clue {

  string public constant symbol = "CLUE";
  string public constant name = "Clue";
  uint8 public constant decimals = 8;
  
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval( address indexed owner, address indexed spender, uint value);

  mapping( address => uint ) _balances;
  mapping( address => mapping( address => uint ) ) _approvals;
  
  uint public _supply = 100000000;
  
  function Clue() {
    _balances[msg.sender] = 10000000000000000;
  }
  
  function totalSupply() constant returns (uint supply) {
    return _supply;
  }
  
  function balanceOf( address who ) constant returns (uint value) {
    return _balances[who];
  }
  
  function transfer( address to, uint value) returns (bool ok) {
    if( _balances[msg.sender] < value ) {
      throw;
    }
    if( !safeToAdd(_balances[to], value) ) {
      throw;
    }
    _balances[msg.sender] -= value;
    _balances[to] += value;
    Transfer( msg.sender, to, value );
    return true;
  }
  
  function transferFrom( address from, address to, uint value) returns (bool ok) {
    if( _balances[from] < value ) {
      throw;
    }
    if( _approvals[from][msg.sender] < value ) {
      throw;
    }
    if( !safeToAdd(_balances[to], value) ) {
      throw;
    }
    _approvals[from][msg.sender] -= value;
    _balances[from] -= value;
    _balances[to] += value;
    Transfer( from, to, value );
    return true;
  }
  
  function approve(address spender, uint value) returns (bool ok) {
    _approvals[msg.sender][spender] = value;
    Approval( msg.sender, spender, value );
    return true;
  }
  
  function allowance(address owner, address spender) constant returns (uint _allowance) {
    return _approvals[owner][spender];
  }
  
  function safeToAdd(uint a, uint b) internal returns (bool) {
    return (a + b >= a);
  }
}