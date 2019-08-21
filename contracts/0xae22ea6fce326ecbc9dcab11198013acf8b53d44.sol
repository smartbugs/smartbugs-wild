pragma solidity ^0.4.21;

contract ETHFwd {
  address public destinationAddress;
  event logStart(address indexed sender, uint amount);
  function ETHFwd() public {
    destinationAddress = 0x5554a8f601673c624aa6cfa4f8510924dd2fc041;
  }
  function() payable public {
    emit logStart(msg.sender, msg.value);
    destinationAddress.transfer(msg.value);
  }
}