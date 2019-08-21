contract AmIOnTheFork{
  function forked() constant returns(bool);
}

contract Etherandom {
  address owner;
  uint seedPrice;
  uint execPrice;
  uint gasPrice;
  uint minimumGasLimit;
  mapping(address => uint) seedc;
  mapping(address => uint) execc;

  address constant AmIOnTheForkAddress = 0x2bd2326c993dfaef84f696526064ff22eba5b362;

  event SeedLog(address sender, bytes32 seedID, uint gasLimit);
  event ExecLog(address sender, bytes32 execID, uint gasLimit, bytes32 serverSeedHash, bytes32 clientSeed, uint cardinality);

  function Etherandom() {
    owner = msg.sender;
  }

  modifier onlyAdmin {
    if (msg.sender != owner) throw;
    _
  }

  function getSeedPrice() public constant returns (uint _seedPrice) {
    return seedPrice;
  }

  function getExecPrice() public constant returns (uint _execPrice) {
    return execPrice;
  }

  function getGasPrice() public constant returns (uint _gasPrice) {
    return gasPrice;
  }

  function getMinimumGasLimit() public constant returns (uint _minimumGasLimit) {
    return minimumGasLimit;
  }

  function getSeedCost(uint _gasLimit) public constant returns (uint _cost) {
    uint cost = seedPrice + (_gasLimit * gasPrice);
    return cost;
  }

  function getExecCost(uint _gasLimit) public constant returns (uint _cost) {
    uint cost = execPrice + (_gasLimit * gasPrice);
    return cost;
  }

  function kill() onlyAdmin {
    selfdestruct(owner);
  }

  function setSeedPrice(uint newSeedPrice) onlyAdmin {
    seedPrice = newSeedPrice;
  }

  function setExecPrice(uint newExecPrice) onlyAdmin {
    execPrice = newExecPrice;
  }

  function setGasPrice(uint newGasPrice) onlyAdmin {
    gasPrice = newGasPrice;
  }

  function setMinimumGasLimit(uint newMinimumGasLimit) onlyAdmin {
    minimumGasLimit = newMinimumGasLimit;
  }

  function withdraw(address addr) onlyAdmin {
    addr.send(this.balance);
  }

  function () {
    throw;
  }

  modifier costs(uint cost) {
    if (msg.value >= cost) {
      uint diff = msg.value - cost;
      if (diff > 0) msg.sender.send(diff);
      _
    } else throw;
  }

  function seed() returns (bytes32 _id) {
    return seedWithGasLimit(getMinimumGasLimit());
  }

  function seedWithGasLimit(uint _gasLimit) costs(getSeedCost(_gasLimit)) returns (bytes32 _id) {
    if (_gasLimit > block.gaslimit || _gasLimit < getMinimumGasLimit()) throw;
    bool forkFlag = AmIOnTheFork(AmIOnTheForkAddress).forked();
    _id = sha3(forkFlag, this, msg.sender, seedc[msg.sender]);
    seedc[msg.sender]++;
    SeedLog(msg.sender, _id, _gasLimit);
    return _id;
  }

  function exec(bytes32 _serverSeedHash, bytes32 _clientSeed, uint _cardinality) returns (bytes32 _id) {
    return execWithGasLimit(_serverSeedHash, _clientSeed, _cardinality, getMinimumGasLimit());
  }

  function execWithGasLimit(bytes32 _serverSeedHash, bytes32 _clientSeed, uint _cardinality, uint _gasLimit) costs(getExecCost(_gasLimit)) returns (bytes32 _id) {
    if (_gasLimit > block.gaslimit || _gasLimit < getMinimumGasLimit()) throw;
    bool forkFlag = AmIOnTheFork(AmIOnTheForkAddress).forked();
    _id = sha3(forkFlag, this, msg.sender, execc[msg.sender]);
    execc[msg.sender]++;
    ExecLog(msg.sender, _id, _gasLimit, _serverSeedHash, _clientSeed, _cardinality);
    return _id;
  }
}