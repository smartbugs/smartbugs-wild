pragma solidity ^0.4.24;

contract PiggyBank  {
  string public name;
  string public symbol = '%';
  uint8 constant public decimals = 18;
  uint256 constant internal denominator = 10 ** uint256(decimals);
  uint256 public targetAmount;

  bool public complete = false;

  address internal targetAddress;

  constructor(
    string goalName,
    uint256 goalAmount,
    address target
  ) public
  {
    name = goalName;
    targetAmount = goalAmount;
    targetAddress = target;
  }

  function balanceOf(address target) view public returns(uint256)
  {
    if (target != targetAddress)
      return 0;

    if (complete)
      return denominator * 100;

    return denominator * 100 * address(this).balance / targetAmount;
  }

  event Transfer(address indexed from, address indexed to, uint256 value);

  function () public payable {
    emit Transfer(address(this), targetAddress, denominator * msg.value / targetAmount * 100);
    if (balanceOf(targetAddress) >= 100 * denominator) {
      complete = true;
      selfdestruct(targetAddress);
    }
  }

}