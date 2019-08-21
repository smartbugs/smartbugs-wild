pragma solidity ^0.5.2;

contract Counter {
  event Incremented(uint256 value);

  uint256 public value;

  constructor() public payable
  {
    value = 0;
  }

  function increment() public payable {
    value += 1;
    emit Incremented(value);
  }
}