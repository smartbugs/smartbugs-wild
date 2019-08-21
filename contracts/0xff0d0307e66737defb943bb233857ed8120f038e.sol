pragma solidity ^0.4.18;

contract RateOracle {

  address public owner;
  uint public rate;
  uint256 public lastUpdateTime;

  function RateOracle() public {
    owner = msg.sender;
  }

  function setRate(uint _rateCents) public {
    require(msg.sender == owner);
    require(_rateCents > 100);
    rate = _rateCents;
    lastUpdateTime = now;
  }

}