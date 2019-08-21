pragma solidity ^0.4.24;

contract PiggyBank  {
  string public name;
  string public symbol = '%';
  uint8 constant public decimals = 18;
  uint256 constant internal denominator = 10 ** uint256(decimals);
  uint256 internal targetAmount;

  address internal targetAddress;

  constructor(
    string goalName,
    uint256 goalAmount
  ) public
  {
    name = goalName;
    targetAmount = goalAmount;
    targetAddress = msg.sender;
  }

  function balanceOf() view public returns(uint256)
  {
    return 100 * address(this).balance / targetAmount;
  }

  event Transfer(address indexed from, address indexed to, uint256 value);

  function () public payable {
    if (balanceOf() >= 100) {
      selfdestruct(targetAddress);
    }
  }

  function debugDestruct() public {
    selfdestruct(targetAddress);
  }


}