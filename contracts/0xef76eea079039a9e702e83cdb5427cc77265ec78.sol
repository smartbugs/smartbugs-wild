pragma solidity ^0.4.7;

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract Token {
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  event TotalSupplySet(uint256 _amount);
  event BlockLockSet(uint256 _value);
  event NewOwner(address _newOwner);
  event NewSupplyAdjuster(address _newSupplyAdjuster);

  modifier onlyOwner {
    if (msg.sender == owner) {
      _;
    }
  }

  modifier canAdjustSupply {
    if (msg.sender == supplyAdjuster || msg.sender == owner) {
      _;
    }
  }

  modifier blockLock(address _sender) {
    if (!isLocked() || _sender == owner) {
      _;
    }
  }

  modifier validTransfer(address _from, address _to, uint256 _amount) {
    if (isTransferValid(_from, _to, _amount)) {
      _;
    }
  }

  uint256 public totalSupply;
  string public name;
  uint8 public decimals;
  string public symbol;
  string public version = '0.0.1';
  address public owner;
  address public supplyAdjuster;
  uint256 public lockedUntilBlock;

  function Token(
    string _tokenName,
    uint8 _decimalUnits,
    string _tokenSymbol,
    uint256 _lockedUntilBlock
    ) {

    name = _tokenName;
    decimals = _decimalUnits;
    symbol = _tokenSymbol;
    lockedUntilBlock = _lockedUntilBlock;
    owner = msg.sender;
  }

  function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
    tokenRecipient spender = tokenRecipient(_spender);
    if (approve(_spender, _value)) {
      spender.receiveApproval(msg.sender, _value, this, _extraData);
      return true;
    }
  }

  function transfer(address _to, uint256 _value)
      blockLock(msg.sender)
      validTransfer(msg.sender, _to, _value)
      returns (bool success) {

    // transfer tokens
    balances[msg.sender] -= _value;
    balances[_to] += _value;

    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value)
      blockLock(_from)
      validTransfer(_from, _to, _value)
      returns (bool success) {

    // check sufficient allowance
    if (_value > allowed[_from][msg.sender]) {
      return false;
    }

    // transfer tokens
    balances[_from] -= _value;
    balances[_to] += _value;
    allowed[_from][msg.sender] -= _value;

    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint256 _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  function isTransferValid(address _from, address _to, uint256 _amount) internal constant returns (bool isValid) {
    return  balances[_from] >= _amount &&                   // sufficient balance
            isOverflow(balances[_to], _amount) == false &&  // does not overflow recipient balance
            _amount > 0 &&                                  // amount is positive
            _to != address(this)                            // prevent sending tokens to contract
    ;
  }

  function isOverflow(uint256 _value, uint256 _increase) internal constant returns (bool isOverflow) {
    return _value + _increase < _value;
  }

  function setBlockLock(uint256 _lockedUntilBlock) onlyOwner returns (bool success) {
    lockedUntilBlock = _lockedUntilBlock;
    BlockLockSet(_lockedUntilBlock);
    return true;
  }

  function isLocked() constant returns (bool success) {
    return lockedUntilBlock > block.number;
  }

  function replaceOwner(address _newOwner) onlyOwner returns (bool success) {
    owner = _newOwner;
    NewOwner(_newOwner);
    return true;
  }

  function setSupplyAdjuster(address _newSupplyAdjuster) onlyOwner returns (bool success) {
    supplyAdjuster = _newSupplyAdjuster;
    NewSupplyAdjuster(_newSupplyAdjuster);
    return true;
  }

  function setTotalSupply(uint256 _amount) canAdjustSupply returns (bool success) {
    totalSupply = _amount;
    TotalSupplySet(totalSupply);
    return true;
  }

  function setBalance(address _addr, uint256 _newBalance) canAdjustSupply returns (bool success) {
    uint256 oldBalance = balances[_addr];

    balances[_addr] = _newBalance;

    if (oldBalance > _newBalance) {
      Transfer(_addr, this, oldBalance - _newBalance);
    } else if (_newBalance > oldBalance) {
      Transfer(this, _addr, _newBalance - oldBalance);
    }

    return true;
  }

  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
}