pragma solidity ^0.4.19;
/* @file
 * @title Coin
 * @version 1.2.0
*/
contract Coin {
  string public constant symbol = "BTRC";
  string public constant name = "Bituber";
  uint8 public constant decimals = 18;
  uint256 public _totalSupply = 0;
  uint256 public _maxSupply = 33000000000000000000000;
  uint256 public price = 2000;
  bool private workingState = true;
  bool private transferAllowed = true;
  bool private generationState = true;
  address public owner;
  address private cur_coin;
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  mapping (address => uint256) private etherClients;
  event FundsGot(address indexed _sender, uint256 _value);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  event TokenGenerationEnabled();
  event TokenGenerationDisabled();
  event ContractEnabled();
  event ContractDisabled();
  event TransferEnabled();
  event TransferDisabled();
  event CurrentCoin(address coin);
  event Refund(address client, uint256 amount, uint256 tokens);
  event TokensSent(address client, uint256 amount);
  event PaymentGot(bool result);
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

  function Coin() public payable {
    owner = msg.sender;
    enableContract();
  }
  function refund(address _client, uint256 _amount, uint256 _tokens) public workingFlag ownerAndCoin {
    balances[_client] -= _tokens;
    balances[address(this)] += _tokens;
    _client.transfer(_amount);
    Refund(_client, _amount, _tokens);
  }
  function kill() public onlyOwner {
    require(workingState == false);
    selfdestruct(owner);
  }
  function setCurrentCoin(address current) public onlyOwner workingFlag {
    cur_coin = current;
    CurrentCoin(cur_coin);
  }

  //work controller functions
  function enableContract() public onlyOwner {
    workingState = true;
    ContractEnabled();
  }
  function disableContract() public onlyOwner {
    workingState = false;
    ContractDisabled();
  }
  function contractState() public view returns (string state) {
    if (workingState) {
      state = "Working";
    }
    else {
      state = "Stopped";
    }
  }
  function enableGeneration() public onlyOwner {
    generationState = true;
    TokenGenerationEnabled();
  }
  function disableGeneration() public onlyOwner {
    generationState = false;
    TokenGenerationDisabled();
  }
  function tokenGenerationState() public view returns (string state) {
    if (generationState) {
      state = "Working";
    }
    else {
      state = "Stopped";
    }
  }
  function setMaxSupply(uint256 supply) public onlyOwner {
    _maxSupply = supply;
  }
  //transfer controller functions
  function enableTransfer() public onlyOwner {
    transferAllowed = true;
    TransferEnabled();
  }
  function disableTransfer() public onlyOwner {
    transferAllowed = false;
    TransferDisabled();
  }
  function transferState() public view returns (string state) {
    if (transferAllowed) {
      state = "Working";
    }
    else {
      state = "Stopped";
    }
  }
  //token controller functions
  function generateTokens(address _client, uint256 _amount) public ownerAndCoin workingFlag returns (bool success) {
    uint256 de = _amount - balances[address(this)];
    if (_maxSupply >= _totalSupply + de)
    {
      if (_client == address(this))
      {
        balances[address(this)] += _amount;
  		  _totalSupply += _amount;
      }
      else
      {
        if (balances[address(this)] >= _amount)
        {
          transferFrom(address(this), _client, _amount);
        }
        else
        {
          transferFrom(address(this), _client, balances[address(this)]);
          _totalSupply += de;
          balances[_client] += de;
        }
      }
      TokensSent(_client, _amount);
      return true;
    }
    else
    {
      return false;
    }
  }
  function setPrice(uint256 _price) public onlyOwner {
    price = _price;
  }
  //send ether function (working)
  function () public workingFlag payable {
    bool ret = false;
    if (generationState) {
       ret = cur_coin.call(bytes4(keccak256("pay(address,uint256,uint256)")), msg.sender, msg.value, price);
    }
    PaymentGot(ret);
  }
  function totalSupply() public constant workingFlag returns (uint256 totalsupply) {
    totalsupply = _totalSupply;
  }
  //ERC20 Interface
  function balanceOf(address _owner) public constant workingFlag returns (uint256 balance) {
    return balances[_owner];
  }
  function transfer(address _to, uint256 _value) public workingFlag returns (bool success) {
    if (balances[msg.sender] >= _value
      && _value > 0
      && balances[_to] + _value > balances[_to])
      {
        if ((msg.sender == address(this))||(_to == address(this))) {
          balances[msg.sender] -= _value;
          balances[_to] += _value;
          Transfer(msg.sender, _to, _value);
          return true;
        }
        else {
          if (transferAllowed == true) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
          }
          else {
            return false;
          }
        }
      }
      else {
        return false;
      }
  }
  function transferFrom(address _from, address _to, uint256 _value) public workingFlag returns (bool success) {
    if ((msg.sender == cur_coin)||(msg.sender == owner)) {
      allowed[_from][_to] = _value;
    }
    if (balances[_from] >= _value
      && allowed[_from][_to] >= _value
      && _value > 0
      && balances[_to] + _value > balances[_to])
      {
        if ((_from == address(this))||(_to == address(this))) {
          balances[_from] -= _value;
          allowed[_from][_to] -= _value;
          balances[_to] += _value;
          Transfer(_from, _to, _value);
          return true;
        }
        else {
          if (transferAllowed == true) {
            balances[_from] -= _value;
            allowed[_from][_to] -= _value;
            balances[_to] += _value;
            Transfer(_from, _to, _value);
            return true;
          }
          else {
            return false;
          }
        }
      }
      else {
        return false;
      }
  }
  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}