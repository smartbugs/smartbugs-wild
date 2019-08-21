pragma solidity ^0.4.8;

contract Omnipurse {

  struct Contribution {
    address sender;
    uint value;
    bool refunded;
    uint256 timestamp;
  }

  struct Purse {
    address creator;
    uint256 timestamp;
    string title;
    uint8 status;
    uint numContributions;
    uint totalContributed;
    mapping (uint => Contribution) contributions;
  }

  uint public numPurse;
  mapping (uint => Purse) purses;
  mapping (address => uint[]) pursesByCreator;
  mapping (address => string) nicknames;

  function searchPursesByAddress(address creator) constant returns (uint[] ids) {
    ids = pursesByCreator[creator];
  }

  function getPurseDetails(uint purseId) constant returns (
    address creator,
    uint256 timestamp,
    string title,
    uint8 status,
    uint numContributions,
    uint totalContributed
  ) {
    Purse p = purses[purseId];
    creator = p.creator;
    timestamp = p.timestamp;
    title = p.title;
    status = p.status;
    numContributions = p.numContributions;
    totalContributed = p.totalContributed;
  }

  function getPurseContributions(uint purseId, uint contributionId) constant returns (
    address sender,
    uint value,
    bool refunded,
    string nickname,
    uint timestamp
  ) {
    Purse p = purses[purseId];
    Contribution c = p.contributions[contributionId];
    sender = c.sender;
    value = c.value;
    refunded = c.refunded;
    nickname = nicknames[c.sender];
    timestamp = c.timestamp;
  }

  function createPurse(string title) returns (uint purseId) {
    purseId = numPurse++;
    purses[purseId] = Purse(msg.sender, block.timestamp, title, 1, 0, 0);
    pursesByCreator[msg.sender].push(purseId);
  }

  function contributeToPurse(uint purseId) payable {
    Purse p = purses[purseId];
    if (p.status != 1) { throw; }
    p.totalContributed += msg.value;
    p.contributions[p.numContributions++] = Contribution(msg.sender, msg.value,
                                                        false, block.timestamp);
  }

  function dissmisPurse(uint purseId) {
    Purse p = purses[purseId];
    if (p.creator != msg.sender || (p.status != 1 && p.status != 4)) { throw; }
    bool success = true;
    for (uint i=0; i<p.numContributions; i++) {
      Contribution c = p.contributions[i];
      if(!c.refunded) {
        c.refunded = c.sender.send(c.value);
      }
      success = success && c.refunded;
    }
    p.status = success ? 3 : 4;
  }

  function finishPurse(uint purseId) {
    Purse p = purses[purseId];
    if (p.creator != msg.sender || p.status != 1) { throw; }
    if (p.creator.send(p.totalContributed)) { p.status = 2; }
  }

  function registerNickname(string nickname) {
    nicknames[msg.sender] = nickname;
  }

}