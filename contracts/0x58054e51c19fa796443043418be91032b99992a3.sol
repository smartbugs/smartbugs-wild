pragma solidity ^0.4.18;

contract SafeMath {
    uint256 constant public MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function safeAdd(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (x > MAX_UINT256 - y) throw;
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (x < y) throw;
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (y == 0) return 0;
        if (x > MAX_UINT256 / y) throw;
        return x * y;
    }
}

contract ERC223ReceivingContract {

    struct inr {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }

      function tokenFallback(address _from, uint _value, bytes _data){
      inr memory igniter;
      igniter.sender = _from;
      igniter.value = _value;
      igniter.data = _data;
      uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
      igniter.sig = bytes4(u);

    }
}

contract iGniter is SafeMath {

  struct serPayment {
    uint unlockedTime;
    uint256 unlockedBlockNumber;
  }

    string public name;
    bytes32 public symbol;
    uint8 public decimals;
    uint256 public rewardPerBlockPerAddress;
    uint256 public totalInitialAddresses;
    uint256 public initialBlockCount;
    uint256 private minedBlocks;
    uint256 private iGniting;
    uint256 private initialSupplyPerAddress;
    uint256 private totalMaxAvailableAmount;
    uint256 private availableAmount;
    uint256 private burnt;
    uint256 public inrSessions;
    uint256 private availableBalance;
    uint256 private balanceOfAddress;
    uint256 private initialSupply;
    uint256 private _totalSupply;
    uint256 public currentCost;
    uint256 private startBounty;
    uint256 private finishBounty;

    mapping(address => uint256) public balanceOf;
    mapping(address => uint) balances;
    mapping(address => bool) public initialAddress;
    mapping(address => bool) public bountyAddress;
    mapping (address => mapping (address => uint)) internal _allowances;
    mapping (address => serPayment) ignPayments;
    address private _owner;

    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event LogBurn(address indexed owner, uint indexed value);

    modifier isOwner() {

      require(msg.sender == _owner);
      _;
    }

    function iGniter() {

        initialSupplyPerAddress = 10000000000; //10000
        initialBlockCount = 4948670;
        rewardPerBlockPerAddress = 7;
        totalInitialAddresses = 5000;
        initialSupply = initialSupplyPerAddress * totalInitialAddresses;
       _owner = msg.sender;

    }

    function currentBlock() constant returns (uint256 blockNumber)
    {
        return block.number;
    }

    function blockDiff() constant returns (uint256 blockNumber)
    {
        return block.number - initialBlockCount;
    }

    function assignInitialAddresses(address[] _address) isOwner public returns (bool success)
    {
        if (block.number <= 7000000)
        {
          for (uint i = 0; i < _address.length; i++)
          {
            balanceOf[_address[i]] = initialSupplyPerAddress;
            initialAddress[_address[i]] = true;
          }

          return true;
        }
        return false;
    }

    function assignBountyAddresses(address[] _address) isOwner public returns (bool success)
    {
      startBounty = 2500000000;

        if (block.number <= 7000000)
        {
          for (uint i = 0; i < _address.length; i++)
          {
            balanceOf[_address[i]] = startBounty;
            initialAddress[_address[i]] = true;
          }

          return true;
        }
        return false;
    }

    function completeBountyAddresses(address[] _address) isOwner public returns (bool success)
    {
      finishBounty = 7500000000;

        if (block.number <= 7000000)
        {
          for (uint i = 0; i < _address.length; i++)
          {
            balanceOf[_address[i]] = balanceOf[_address[i]] + finishBounty;
            initialAddress[_address[i]] = true;
          }

          return true;
        }
        return false;
    }

    function balanceOf(address _address) constant returns (uint256 Balance)
    {
        if ((initialAddress[_address])) {
            minedBlocks = block.number - initialBlockCount;

            if (minedBlocks >= 105120000) return balanceOf[_address]; //app. 2058

            availableAmount = rewardPerBlockPerAddress * minedBlocks;
            availableBalance = balanceOf[_address] + availableAmount;

            return availableBalance;
        }
        else
            return balanceOf[_address];
    }

    function name() constant returns (string _name)
    {
        name = "iGniter";
        return name;
    }

    function symbol() constant returns (bytes32 _symbol)
    {
        symbol = "INR";
        return symbol;
    }

    function decimals() constant returns (uint8 _decimals)
    {
        decimals = 6;
        return decimals;
    }

    function totalSupply() constant returns (uint256 totalSupply)
    {
        minedBlocks = block.number - initialBlockCount;
        availableAmount = rewardPerBlockPerAddress * minedBlocks;
        iGniting = availableAmount * totalInitialAddresses;
        return iGniting + initialSupply - burnt;
    }

    function minedTotalSupply() constant returns (uint256 minedBlocks)
    {
        minedBlocks = block.number - initialBlockCount;
        availableAmount = rewardPerBlockPerAddress * minedBlocks;
        return availableAmount * totalInitialAddresses;
    }

    function initialiGnSupply() constant returns (uint256 maxSupply)
    {
        return initialSupplyPerAddress * totalInitialAddresses;
    }

    //burn tokens
    function burn(uint256 _value) public returns(bool success) {

        //get sum
        minedBlocks = block.number - initialBlockCount;
        availableAmount = rewardPerBlockPerAddress * minedBlocks;
        iGniting = availableAmount * totalInitialAddresses;
        _totalSupply = iGniting + initialSupply;

        //burn time
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        burnt += _value;
        Burn(msg.sender, _value);
        return true;
    }

    function transfer(address _to, uint _value) public returns (bool) {
        if (_value > 0 && _value <= balanceOf[msg.sender] && !isContract(_to)) {
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function transfer(address _to, uint _value, bytes _data) public returns (bool) {
        if (_value > 0 && _value <= balanceOf[msg.sender] && isContract(_to)) {
            balanceOf[msg.sender] -= _value;
            balanceOf[_to] += _value;
            ERC223ReceivingContract _contract = ERC223ReceivingContract(_to);
                _contract.tokenFallback(msg.sender, _value, _data);
            Transfer(msg.sender, _to, _value, _data);
            return true;
        }
        return false;
    }

    function isContract(address _addr) returns (bool) {
        uint codeSize;
        assembly {
            codeSize := extcodesize(_addr)
        }
        return codeSize > 0;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        if (_allowances[_from][msg.sender] > 0 && _value > 0 && _allowances[_from][msg.sender] >= _value &&
            balanceOf[_from] >= _value) {
            balanceOf[_from] -= _value;
            balanceOf[_to] += _value;
            _allowances[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    function approve(address _spender, uint _value) public returns (bool) {
        _allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint) {
        return _allowances[_owner][_spender];
    }

    function PaymentStatusBlockNum(address _address) constant returns (uint256 bn) {

      return ignPayments[_address].unlockedBlockNumber;
    }

    function PaymentStatusTimeStamp(address _address) constant returns (uint256 ut) {

      return ignPayments[_address].unlockedTime;
    }

    function updateCost(uint256 _currCost) isOwner public returns (uint256 currCost) {

      currentCost = _currCost;

      return currentCost;
    }

    function servicePayment(uint _value) public returns (bool, uint256, uint256) {

      require(_value >= currentCost);
      require(balanceOf[msg.sender] >= currentCost);

      //either option available
      ignPayments[msg.sender].unlockedTime = block.timestamp;
      ignPayments[msg.sender].unlockedBlockNumber = block.number;

      inrSessions++;

      //burn
      balanceOf[msg.sender] -= _value;
      burnt += _value;
      Burn(msg.sender, _value);

      return (true, ignPayments[msg.sender].unlockedTime, ignPayments[msg.sender].unlockedBlockNumber);
    }
}