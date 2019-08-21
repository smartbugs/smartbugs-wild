/*

Etherandom v1.0 [API]

Copyright (c) 2016, Etherandom [etherandom.com]
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the <organization> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL ETHERANDOM BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

*/

contract EtherandomI {
  address public addr;
  function seed() returns (bytes32 _id);
  function seedWithGasLimit(uint _gasLimit) returns (bytes32 _id);
  function exec(bytes32 _serverSeedHash, bytes32 _clientSeed, uint _cardinality) returns (bytes32 _id);
  function execWithGasLimit(bytes32 _serverSeedHash, bytes32 _clientSeed, uint _cardinality, uint _gasLimit) returns (bytes32 _id);
  function getSeedCost(uint _gasLimit) constant returns (uint _cost);
  function getExecCost(uint _gasLimit) constant returns (uint _cost);
  function getMinimumGasLimit() constant returns (uint _minimumGasLimit);
}

contract EtherandomProxyI {
  function getContractAddress() constant returns (address _addr); 
  function getCallbackAddress() constant returns (address _addr); 
}

contract EtherandomizedI {
  function onEtherandomSeed(bytes32 _id, bytes32 serverSeedHash);
  function onEtherandomExec(bytes32 _id, bytes32 serverSeed, uint randomNumber);
}

contract etherandomized {
  EtherandomProxyI EAR;
  EtherandomI etherandom;

  modifier etherandomAPI {
    address addr = EAR.getContractAddress();
    if (addr == 0) {
      etherandomSetNetwork();
      addr = EAR.getContractAddress();
    }
    etherandom = EtherandomI(addr);
    _
  }

  function etherandomSetNetwork() internal returns (bool) {
    if (getCodeSize(0x5be0372559e0275c0c415ab48eb0e211bc2f52a8)>0){
      EAR = EtherandomProxyI(0x5be0372559e0275c0c415ab48eb0e211bc2f52a8);
      return true;
    }
    if (getCodeSize(0xf6d9979499491c1c0c9ef518860f4476c1cd551a)>0){
      EAR = EtherandomProxyI(0xf6d9979499491c1c0c9ef518860f4476c1cd551a);
      return true;
    }
    return false;
  }

  function getCodeSize(address _addr) constant internal returns (uint _size) {
    assembly { _size := extcodesize(_addr) }
  }

  function etherandomSeed() etherandomAPI internal returns (bytes32 _id) {
    uint cost = etherandom.getSeedCost(etherandom.getMinimumGasLimit());
    return etherandom.seed.value(cost)();
  }

  function etherandomSeedWithGasLimit(uint gasLimit) etherandomAPI internal returns (bytes32 _id) {
    uint cost = etherandom.getSeedCost(gasLimit);
    return etherandom.seedWithGasLimit.value(cost)(gasLimit);
  }

  function etherandomExec(bytes32 serverSeedHash, bytes32 clientSeed, uint cardinality) etherandomAPI internal returns (bytes32 _id) {
    uint cost = etherandom.getExecCost(etherandom.getMinimumGasLimit());
    return etherandom.exec.value(cost)(serverSeedHash, clientSeed, cardinality);
  }

  function etherandomExecWithGasLimit(bytes32 serverSeedHash, bytes32 clientSeed, uint cardinality, uint gasLimit) etherandomAPI internal returns (bytes32 _id) {
    uint cost = etherandom.getExecCost(gasLimit);
    return etherandom.execWithGasLimit.value(cost)(serverSeedHash, clientSeed, cardinality, gasLimit);
  }
  
  function etherandomCallbackAddress() internal returns (address _addr) {
    return EAR.getCallbackAddress();
  }

  function etherandomVerify(bytes32 serverSeedHash, bytes32 serverSeed, bytes32 clientSeed, uint cardinality, uint randomNumber) internal returns (bool _verified) {
    if (sha3(serverSeed) != serverSeedHash) return false;
    uint num = addmod(uint(serverSeed), uint(clientSeed), cardinality);
    return num == randomNumber;
  }

  function() {
    throw;
  }
}


contract Dice is etherandomized {
  struct Roll {
    address bettor;
    bytes32 clientSeed;
  }

  address owner;
  uint pendingAmount;
  mapping (bytes32 => Roll) pendingSeed;
  mapping (bytes32 => Roll) pendingExec;
  mapping (bytes32 => bytes32) serverSeedHashes;

  function Dice() {
    owner = msg.sender;
  }

  function getAvailable() returns (uint _available) {
    return this.balance - pendingAmount;
  }

  function roll() {
    rollWithSeed("");
  }

  function rollWithSeed(bytes32 clientSeed) {
    if ( (msg.value != 1) || (getAvailable() < 2)) throw;
    bytes32 _id = etherandomSeed();
    pendingSeed[_id] = Roll({bettor: msg.sender, clientSeed: clientSeed});
    pendingAmount = pendingAmount + 2;
  }

  function onEtherandomSeed(bytes32 _id, bytes32 serverSeedHash) {
    if (msg.sender != etherandomCallbackAddress()) throw;
    Roll roll = pendingSeed[_id];
    bytes32 _execID = etherandomExec(serverSeedHash, roll.clientSeed, 100);
    pendingExec[_execID] = roll;
    serverSeedHashes[_execID] = serverSeedHash;
    delete pendingSeed[_id];
  }

  function onEtherandomExec(bytes32 _id, bytes32 serverSeed, uint randomNumber) {
    if (msg.sender != etherandomCallbackAddress()) throw;
    Roll roll = pendingExec[_id];
    bytes32 serverSeedHash = serverSeedHashes[_id];

    pendingAmount = pendingAmount - 2;

    if (etherandomVerify(serverSeedHash, serverSeed, roll.clientSeed, 100, randomNumber)) {
      if (randomNumber < 50) roll.bettor.send(2);
    } else {
      roll.bettor.send(1);
    }
    
    delete serverSeedHashes[_id];
    delete pendingExec[_id];
  }
}