pragma solidity ^0.4.24;


// Based on https://medium.com/@ChrisLundkvist/exploring-simpler-ethereum-multisig-contracts-b71020c19037
contract MonteLabsMS {
  uint public nonce;
  // MonteLabs owners
  mapping (address => bool) isOwner;

  constructor(address[] _owners) public {
    require(_owners.length == 3);
    for (uint i = 0; i < _owners.length; ++i) {
      isOwner[_owners[i]] = true;
    }
  }

  function execute(uint8 _sigV, bytes32 _sigR, bytes32 _sigS, address _destination, uint _value, bytes _data) public {
    require(isOwner[msg.sender]);
    bytes memory prefix = "\x19Ethereum Signed Message:\n32";
    bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, keccak256(abi.encodePacked(this, _destination, _value, _data, nonce))));

    address recovered = ecrecover(prefixedHash, _sigV, _sigR, _sigS);
    ++nonce;
    require(_destination.call.value(_value)(_data));
    require(recovered != msg.sender);
    require(isOwner[recovered]);
  }

  function() external payable {}
}