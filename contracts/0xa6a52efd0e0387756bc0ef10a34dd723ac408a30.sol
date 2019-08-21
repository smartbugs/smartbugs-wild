pragma solidity ^0.4.23;

contract Pgp {
  mapping(address => string) public addressToPublicKey;

  function addPublicKey(string publicKey) external {
    addressToPublicKey[msg.sender] = publicKey;
  }
}