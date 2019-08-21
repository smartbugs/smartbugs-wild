pragma solidity ^0.4.8;

contract Sylence {

  struct User {
    uint16 pubKeysCount;
    mapping(uint16 => string) pubKeys;
  }
  mapping(bytes28 => User) users;

  address owner;

  function Sylence() { owner = msg.sender; }

  function getPubKeyByHash(bytes28 phoneHash) constant returns (string pubKey) {
    User u = users[phoneHash];
    pubKey = u.pubKeys[u.pubKeysCount];
  }

  function registerNewPubKeyForHash(bytes28 phoneHash, string pubKey) {
    if(msg.sender != owner) { throw; }
    User u = users[phoneHash];
    u.pubKeys[u.pubKeysCount++] = pubKey;
  }

}