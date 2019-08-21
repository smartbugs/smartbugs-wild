pragma solidity ^0.5.2;

contract DataNode {
  constructor() public {}

  uint private index = 1;

  event DataAdded(
    string metaData,
    uint dataByteLength,
    uint usedIndex,
    uint indexed index,
    address indexed from
  );

  function postDataTransaction(bytes calldata data, string calldata metaData) external payable {
    emit DataAdded(metaData, data.length, index, index, msg.sender);
    index++;
  }

  function getNextIndex() public view returns (uint){
    return index;
  }

}