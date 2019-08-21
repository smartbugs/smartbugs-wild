pragma solidity ^0.4.0;

contract Eventer {
  event Record(
    address _from,
    string _message
  );

  function record(string message) {
    Record(msg.sender, message);
  }
}