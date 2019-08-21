pragma solidity ^0.4.16;
////
interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }
////
contract AsinerumShareToken {
  string public name = "Asinerum Share";
  string public symbol = "ARS";
  uint8 public decimals = 15;
  uint64 public totalTokens = 172000000;
  uint64 public priceTokenToCoin = 5000;
  uint256 public totalSupply;
  address public ownerWallet;
  ////
  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) public allowance;
  event Transfer(address indexed from, address indexed to, uint256 value);
  ////
  function AsinerumShareToken() public {
    totalSupply = totalTokens * 10 ** uint256(decimals);
    balanceOf[msg.sender] = totalSupply;
    ownerWallet = msg.sender;
  }
  function _transfer(address _from, address _to, uint256 _value) internal {
    require(_to != 0x0);
    require(balanceOf[_from] >= _value);
    require(balanceOf[_to] + _value > balanceOf[_to]);
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
    Transfer(_from, _to, _value);
  }
  function transfer(address _to, uint256 _value) public {
    _transfer(msg.sender, _to, _value);
  }
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
    require(_value <= allowance[_from][msg.sender]);
    allowance[_from][msg.sender] -= _value;
    _transfer(_from, _to, _value);
    return true;
  }
  function approve(address _spender, uint256 _value) public returns (bool success) {
    allowance[msg.sender][_spender] = _value;
    return true;
  }
  function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
    tokenRecipient spender = tokenRecipient(_spender);
    if (approve(_spender, _value)) {
      spender.receiveApproval(msg.sender, _value, this, _extraData);
      return true;
    }
  }
  function () payable public {
    uint256 amount = msg.value * priceTokenToCoin;
    amount = amount / 10 ** (18-uint256(decimals));
    _transfer(ownerWallet, msg.sender, amount);
  }
}