contract EtherandomProxy {
  address owner;
  address etherandom;
  address callback;

  function EtherandomProxy() {
    owner = msg.sender;
  }

  modifier onlyAdmin {
    if (msg.sender != owner) throw;
    _
  }

  function getContractAddress() public constant returns (address _etherandom) {
    return etherandom;
  }
  
  function setContractAddress(address newEtherandom) onlyAdmin {
    etherandom = newEtherandom;
  }

  function getCallbackAddress() public constant returns (address _callback) {
    return callback;
  }
  
  function setCallbackAddress(address newCallback) onlyAdmin {
    callback = newCallback;
  }
  
  function kill() onlyAdmin {
    selfdestruct(owner);
  }
}