pragma solidity ^0.4.23;

contract BatchTransfer {
  address public owner;
  uint256 public totalTransfer;
  uint256 public totalAddresses;
  uint256 public totalTransactions;

  event Transfers(address indexed from, uint256 indexed value, uint256 indexed count);
  
  constructor() public {
    owner = msg.sender;
  }

  modifier restricted() {
    if (msg.sender == owner) _;
  }

  function batchTransfer(address[] _addresses) public payable {
    require (msg.value > 0 && _addresses.length > 0);
    totalTransfer += msg.value;
    totalAddresses += _addresses.length;
    totalTransactions++;
    uint256 value = msg.value / _addresses.length;
    for (uint i = 0; i < _addresses.length; i++) {
      _addresses[i].transfer(value);
    }
    emit Transfers(msg.sender,msg.value,_addresses.length);
  }

  function withdraw() public restricted {
    address contractAddress = this;
    owner.transfer(contractAddress.balance);
  }

  function () payable public {
    msg.sender.transfer(msg.value);
  }  
}