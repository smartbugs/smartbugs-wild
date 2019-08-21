contract PreICOin {
  string public constant symbol = "PreICO";
  string public constant name = "PreICOin";
  uint8 public constant decimals = 18;
  uint256 public _totalSupply = 0;
  bool private workingState = false;
  bool private transferAllowed = false;
  address public owner;
  address private cur_coin;
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  mapping (address => uint256) private etherClients;
  event FundsGot(address indexed _sender, uint256 _value);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  event ContractEnabled();
  event ContractDisabled();
  event TransferEnabled();
  event TransferDisabled();
  event CurrentCoin(address coin);

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  modifier ownerAndCoin {
    require((msg.sender == owner)||(msg.sender == cur_coin));
    _;
  }
  modifier workingFlag {
    require(workingState == true);
    _;
  }
  modifier transferFlag {
    require(transferAllowed == true);
    _;
  }

  function PreICOin() payable {
    owner = msg.sender;
    enableContract();
  }
  function kill() public onlyOwner {
    require(workingState == false);
    selfdestruct(owner);
  }
  function setCurrentCoin(address current) onlyOwner workingFlag {
    cur_coin = current;
    CurrentCoin(cur_coin);
  }

  //work controller functions
  function enableContract() onlyOwner {
    workingState = true;
    ContractEnabled();
  }
  function disableContract() onlyOwner {
    workingState = false;
    ContractDisabled();
  }
  function contractState() returns (string state) {
    if (workingState) {
      state = "Working";
    }
    else {
      state = "Stopped";
    }
  }
  //transfer controller functions
  function enableTransfer() onlyOwner {
    transferAllowed = true;
    TransferEnabled();
  }
  function disableTransfer() onlyOwner {
    transferAllowed = false;
    TransferDisabled();
  }
  function transferState() returns (string state) {
    if (transferAllowed) {
      state = "Working";
    }
    else {
      state = "Stopped";
    }
  }
  //token controller functions
  function generateTokens(address _client, uint256 _amount) ownerAndCoin workingFlag {
    _totalSupply += _amount;
    balances[_client] += _amount;
  }
  function destroyTokens(address _client, uint256 _amount) ownerAndCoin workingFlag returns (bool state) {
    if (balances[_client] >= _amount) {
      balances[_client] -= _amount;
      _totalSupply -= _amount;
      return true;
    }
    else {
      return false;
    }
  }
  //send ether function (working)
  function () workingFlag payable {
    bool ret = cur_coin.call(bytes4(keccak256("pay(address,uint256)")), msg.sender, msg.value);
    ret;
  }
  function totalSupply() constant workingFlag returns (uint256 totalsupply) {
    totalsupply = _totalSupply;
  }
  //ERC20 Interface
  function balanceOf(address _owner) constant workingFlag returns (uint256 balance) {
    return balances[_owner];
  }
  function transfer(address _to, uint256 _value) transferFlag workingFlag returns (bool success) {
    if (balances[msg.sender] >= _value
      && _value > 0
      && balances[_to] + _value > balances[_to])
      {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      }
      else {
        return false;
      }
  }
  function transferFrom(address _from, address _to, uint256 _value) transferFlag workingFlag returns (bool success) {
    if (balances[_from] >= _value
      && allowed[_from][msg.sender] >= _value
      && _value > 0
      && balances[_to] + _value > balances[_to])
      {
        balances[msg.sender] -= _value;
        allowed[_from][msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        return true;
      }
      else {
        return false;
      }
  }
  function approve(address _spender, uint256 _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}