pragma solidity ^0.4.13;

contract NameTracker {
  address creator;
  string public name;

  function NameTracker(string initialName) {
    creator = msg.sender;
    name = initialName;
  }
  
  function update(string newName) {
    if (msg.sender == creator) {
      name = newName;
    }
  }

  function getBlockNumber() constant returns (uint)
  {
    return block.number;
  }

  function kill() {
    if (msg.sender == creator) suicide(creator);
  }
}