pragma solidity ^0.4.18;

contract test {
  uint256 public totalSupply;
  function test(uint256 _totalSupply) {
    totalSupply = _totalSupply;
  }
  function add(uint256 _add) {
    if (_add > 0) {
      totalSupply += _add;
    } else {
      totalSupply++;
    }
  }
}