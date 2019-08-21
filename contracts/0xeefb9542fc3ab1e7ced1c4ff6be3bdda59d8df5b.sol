pragma solidity ^0.4.8;

contract Token {
  function balanceOf(address owner) returns (uint256 balance);
}
contract SaleBalanceTracker {
  uint256 public snapshotTimestamp = 0;
  uint256 public balanceAtSnapshot = 0;
  address public saleAddress = 0x0d845706DdC11f181303a80828219c714ceb3687;
  address public owner = 0x000000ba8f84d23de76508547f809d75733ba170;
  address public dvipAddress = 0xadc46ff5434910bd17b24ffb429e585223287d7f;
  bool public locked = false;
  function endSale() {
    require(owner == msg.sender);
    require(!locked);
    snapshotTimestamp = block.timestamp;
    balanceAtSnapshot = Token(dvipAddress).balanceOf(saleAddress);
    locked = true;
  }
}