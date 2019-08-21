pragma solidity ^0.4.20;

library safeMath
{
  function add(uint256 a, uint256 b) internal pure returns (uint256)
  {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256)
  {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }
  function mul(uint256 a, uint256 b) internal pure returns (uint256)
  {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256)
  {
    require(b > 0);
    uint256 c = a / b;
    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256)
  {
    require(b != 0);
    return a % b;
  }
}

contract Event
{
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Deposit(address indexed sender, uint256 amount , string status);
  event TokenBurn(address indexed from, uint256 value);
  event TokenAdd(address indexed from, uint256 value);
  event Set_Status(string changedStatus);
  event Set_TokenReward(uint256 changedTokenReward);
  event Set_TimeStamp(uint256 ico_open_time, uint256 ico_closed_time);
  event WithdrawETH(uint256 amount);
  event BlockedAddress(address blockedAddress);
  event TempLockedAddress(address tempLockAddress, uint256 unlockTime);
}

contract Variable
{
  string public name;
  string public symbol;
  uint256 public decimals;
  uint256 public totalSupply;
  address public owner;
  string public status;

  uint256 internal _decimals;
  uint256 internal tokenReward;
  uint256 internal ico_open_time;
  uint256 internal ico_closed_time;
  bool internal transferLock;
  bool internal depositLock;

  mapping (address => bool) public allowedAddress;
  mapping (address => bool) public blockedAddress;
  mapping (address => uint256) public tempLockedAddress;

  mapping (address => uint256) public balanceOf;

  constructor() public
  {
    name = "PURIECO";
    symbol = "PEC";
    decimals = 18;
    _decimals = 10 ** uint256(decimals);
    tokenReward = 0;
    totalSupply = _decimals * 8800000000;
    status = "";
    ico_open_time = 0; // 18.01.01 00:00:00 1514732400;
    ico_closed_time = 0;
    transferLock = true;
    depositLock = true;
    owner =  msg.sender;
    balanceOf[owner] = totalSupply;
    allowedAddress[owner] = true;
  }
}

contract Modifiers is Variable
{
  modifier isOwner
  {
    require(owner == msg.sender);
    _;
  }

  modifier isValidAddress
  {
    require(0x0 != msg.sender);
    _;
  }
}

contract Set is Variable, Modifiers, Event
{
  function setStatus(string _status) public isOwner returns(bool success)
  {
    status = _status;
    emit Set_Status(status);
    return true;
  }
  function setTokenReward(uint256 _tokenReward) public isOwner returns(bool success)
  {
    tokenReward = _tokenReward;
    emit Set_TokenReward(tokenReward);
    return true;
  }
  function setTimeStamp(uint256 _ico_open_time,uint256 _ico_closed_time) public isOwner returns(bool success)
  {
    ico_open_time = _ico_open_time;
    ico_closed_time = _ico_closed_time;

    emit Set_TimeStamp(ico_open_time, ico_closed_time);
    return true;
  }
  function setTransferLock(bool _transferLock) public isOwner returns(bool success)
  {
    transferLock = _transferLock;
    return true;
  }
  function setDepositLock(bool _depositLock) public isOwner returns(bool success)
  {
    depositLock = _depositLock;
    return true;
  }
  function setTimeStampStatus(uint256 _ico_open_time, uint256 _ico_closed_time, string _status) public isOwner returns(bool success)
  {
    ico_open_time = _ico_open_time;
    ico_closed_time = _ico_closed_time;
    status = _status;
    emit Set_TimeStamp(ico_open_time,ico_closed_time);
    emit Set_Status(status);
    return true;
  }
}

contract manageAddress is Variable, Modifiers, Event
{

  function add_allowedAddress(address _address) public isOwner
  {
    allowedAddress[_address] = true;
  }

  function add_blockedAddress(address _address) public isOwner
  {
    require(_address != owner);
    blockedAddress[_address] = true;
    emit BlockedAddress(_address);
  }

  function delete_allowedAddress(address _address) public isOwner
  {
    require(_address != owner);
    allowedAddress[_address] = false;
  }

  function delete_blockedAddress(address _address) public isOwner
  {
    blockedAddress[_address] = false;
  }
}

contract Get is Variable, Modifiers
{
  using safeMath for uint256;

  function get_tokenTime() public view returns(uint256 start, uint256 stop)
  {
    return (ico_open_time,ico_closed_time);
  }
  function get_transferLock() public view returns(bool)
  {
    return transferLock;
  }
  function get_depositLock() public view returns(bool)
  {
    return depositLock;
  }
  function get_tokenReward() public view returns(uint256)
  {
    return tokenReward;
  }
}

contract Admin is Variable, Modifiers, Event
{
  using safeMath for uint256;

  function admin_transfer_tempLockAddress(address _to, uint256 _value, uint256 _unlockTime) public isOwner returns(bool success)
  {
    require(_value > 0);
    require(balanceOf[msg.sender] >= _value);
    require(balanceOf[_to].add(_value) >= balanceOf[_to]);
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
    tempLockedAddress[_to] = _unlockTime;
    emit Transfer(msg.sender, _to, _value);
    emit TempLockedAddress(_to, _unlockTime);
    return true;
  }
  function admin_transferFrom(address _from, address _to, uint256 _value) public isOwner returns(bool success)
  {
    require(_value > 0);
    require(balanceOf[msg.sender] >= _value);
    balanceOf[_from] = balanceOf[_from].sub(_value);
    balanceOf[_to] = balanceOf[_to].add(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }
  function admin_tokenBurn(uint256 _value) public isOwner returns(bool success)
  {
    require(_value > 0);
    require(balanceOf[msg.sender] >= _value);
    balanceOf[msg.sender] -= _value;
    totalSupply -= _value;
    emit TokenBurn(msg.sender, _value);
    return true;
  }
  function admin_tokenAdd(uint256 _value) public isOwner returns(bool success)
  {
    require(_value > 0);
    balanceOf[msg.sender] = balanceOf[msg.sender].add(_value);
    totalSupply = totalSupply.add(_value);
    emit TokenAdd(msg.sender, _value);
    return true;
  }
  function admin_renewLockedAddress(address _address, uint256 _unlockTime) public isOwner returns(bool success)
  {
    tempLockedAddress[_address] = _unlockTime;
    emit TempLockedAddress(_address, _unlockTime);
    return true;
  }
}

contract PEC is Variable, Event, Get, Set, Admin, manageAddress
{
  function() payable public
  {
    require(msg.value > 0);
    require(ico_open_time < block.timestamp && ico_closed_time > block.timestamp);
    require(!depositLock);
    uint256 tokenValue;
    tokenValue = (msg.value).mul(tokenReward);
    require(balanceOf[owner] >= tokenValue);
    require(balanceOf[msg.sender].add(tokenValue) >= balanceOf[msg.sender]);
    emit Deposit(msg.sender, msg.value, status);
    balanceOf[owner] -= tokenValue;
    balanceOf[msg.sender] += tokenValue;
    emit Transfer(owner, msg.sender, tokenValue);
  }
  function transfer(address _to, uint256 _value) public isValidAddress
  {
    require(!blockedAddress[msg.sender] && !blockedAddress[_to]);
    require(_value > 0 && _to != msg.sender);
    require(balanceOf[msg.sender] >= _value);
    require(allowedAddress[msg.sender] || transferLock == false);
    require(tempLockedAddress[msg.sender] < block.timestamp);
    balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
    balanceOf[_to] = balanceOf[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
  }
  function ETH_withdraw(uint256 amount) public isOwner returns(bool)
  {
    owner.transfer(amount);
    emit WithdrawETH(amount);
    return true;
  }
}