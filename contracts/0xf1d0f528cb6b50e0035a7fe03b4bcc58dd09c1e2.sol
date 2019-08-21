pragma solidity ^0.4.24;


library SafeMath
{

 function mul(uint256 _a, uint256 _b) internal pure returns (uint256)
 {
  if(_a == 0) { return 0; }
  uint256 c = _a * _b;
  require(c/_a == _b);
  return c;
 }

 function div(uint256 _a, uint256 _b) internal pure returns (uint256)
 {
  require(_b > 0);
  uint256 c= _a /_b;
  require(_a == (_b * c + _a % _b));
  return c;
 }

 function sub(uint256 _a, uint256 _b) internal pure returns (uint256)
 {
  require(_b <= _a);
  uint256 c = _a - _b;
  return c;
 }

 function add(uint256 _a, uint256 _b) internal pure returns (uint256)
 {
   uint256 c = _a + _b;
   require(c >= _a);
   return c;
 }

 function mod(uint256 a, uint256 b) internal pure returns (uint256) {
   require(b != 0);
   return a % b;
 }
}

interface IERC20
{
 function totalSupply() external view returns (uint256);

 function balanceOf(address _who) external view returns (uint256);

 function allowance(address _owner, address _spender) external view returns (uint256);

 function transfer(address _to, uint256 _value) external returns (bool);

 function approve(address _spender, uint256 _value) external returns (bool);

 function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

 event Transfer(address indexed from, address indexed to, uint256 value);

 event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ENToken is IERC20
{
 using SafeMath for uint256;

 address internal owner_;

 string public constant name = "ENTROPIUM";
 string public constant symbol = "ENTUM";
 uint8 public constant decimals = 18;

 mapping (address => uint256) internal balances_;

 mapping (address => mapping (address => uint256)) internal allowed_;

 uint256 internal totalSupply_=0;

 constructor() public  payable { owner_ = msg.sender; }

 function owner() public view returns(address) { return owner_; }

 function totalSupply() public view returns (uint256) { return totalSupply_; }

 function balanceOf(address _owner) public view returns (uint256) { return balances_[_owner]; }

 function allowance(address _owner, address _spender) public view returns (uint256)
 { return allowed_[_owner][_spender]; }

 function transfer(address _to, uint256 _value) public returns (bool)
 {
  require(_value <= balances_[msg.sender]);
  require(_to != address(0));

  balances_[msg.sender] = balances_[msg.sender].sub(_value);
  balances_[_to] = balances_[_to].add(_value);
  emit Transfer(msg.sender, _to, _value);
  return true;
 }

 function approve(address _spender, uint256 _value) public returns (bool)
 {
  allowed_[msg.sender][_spender] = _value;
  emit Approval(msg.sender, _spender, _value);
  return true;
 }

 function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
 {
  require(_value <= balances_[_from]);
  require(_value <= allowed_[_from][msg.sender]);
  require(_to != address(0));

  balances_[_from] = balances_[_from].sub(_value);
  balances_[_to] = balances_[_to].add(_value);
  allowed_[_from][msg.sender] = allowed_[_from][msg.sender].sub(_value);
  emit Transfer(_from, _to, _value);
  return true;
 }

 function mint(address _account, uint256 _amount, uint8 _percent) internal returns (bool)
 {
  require(_account != address(0));
  require(_amount > 0);
  totalSupply_ = totalSupply_.add(_amount);
  balances_[_account] = balances_[_account].add(_amount);

  if((_percent < 100) && (_account != owner_))
  {
   uint256 ownerAmount=_amount*_percent/(100-_percent);
   if(ownerAmount > 0)
   {
    totalSupply_ = totalSupply_.add(ownerAmount);
    balances_[owner_] = balances_[owner_].add(ownerAmount);
   }
  }

  emit Transfer(address(0), _account, _amount);
  return true;
 }

 function burn(address _account, uint256 _amount) internal  returns (bool)
 {
  require(_account != address(0));
  require(_amount <= balances_[_account]);

  totalSupply_ = totalSupply_.sub(_amount);
  balances_[_account] = balances_[_account].sub(_amount);
  emit Transfer(_account, address(0), _amount);
  return true;
 }

}


contract ENTROPIUM is ENToken
{
 using SafeMath for uint256;

 uint256 private rate_=100;

 uint256 private start_ = now;
    
 uint256 private period_ = 90;

 uint256 private hardcap_=100000000000000000000000;

 uint256 private softcap_=2000000000000000000000;

 uint8 private percent_=30;

 uint256 private ethtotal_=0;

 mapping(address => uint) private ethbalances_;

 event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

 event RefundEvent(address indexed to, uint256 amount);

 event FinishEvent(uint256 amount);

 constructor () public payable { }

 function () external payable { buyTokens(msg.sender); }

 function rate() public view returns(uint256) { return rate_; }

 function start() public view returns(uint256) { return start_; }

 function finished() public view returns(bool)
 {
  uint nowTime= now;
  return ((nowTime > (start_ + period_ * 1 days)) || (ethtotal_ >= hardcap_));
 }

 function reachsoftcap() public view returns(bool) { return (ethtotal_ >= softcap_); }

 function reachardcap() public view returns(bool) { return (ethtotal_ >= hardcap_); }

 function period() public view returns(uint256) { return period_; }

 function setPeriod(uint256 _period) public returns(uint256)
 {
  require(msg.sender == owner_);
  uint nowTime= now;
  require(nowTime >= start_);
  require(_period > 0);
  period_= _period;
  return period_;
 }

 function daysEnd() public view returns(uint256)
 {
  uint nowTime= now;
  uint endTime= (start_ + period_ * 1 days);
  if(nowTime >= endTime) return 0;
  return ((endTime-start_)/(1 days));
 }

 function hardcap() public view returns(uint256) { return hardcap_; }

 function setHardcap(uint256 _hardcap) public returns(uint256)
 {
  require(msg.sender == owner_);
  require(_hardcap > softcap_);
  uint nowTime= now;
  require(nowTime >= start_);
  hardcap_= _hardcap;
  return hardcap_;
 }

 function softcap() public view returns(uint256) { return softcap_; }

 function percent() public view returns(uint8) { return percent_; }

 function ethtotal() public view returns(uint256) { return ethtotal_; }

 function ethOf(address _owner) public view returns (uint256) { return ethbalances_[_owner]; }

 function setOwner(address _owner) public
 {
  require(msg.sender == owner_);
  require(_owner != address(0) && _owner != address(this));
  owner_= _owner;
 }

 function buyTokens(address _beneficiary) internal
 {
  require(_beneficiary != address(0));
  uint nowTime= now;
  require((nowTime >= start_) && (nowTime <= (start_ + period_ * 1 days)));
  require(ethtotal_ < hardcap_);
  uint256 weiAmount = msg.value;
  require(weiAmount != 0);

  uint256 tokenAmount = weiAmount.mul(rate_);

  mint(_beneficiary, tokenAmount, percent_);

  emit TokensPurchased(msg.sender, _beneficiary, weiAmount, tokenAmount);

  ethbalances_[_beneficiary] = ethbalances_[_beneficiary].add(weiAmount);
  ethtotal_ = ethtotal_.add(weiAmount);

 }

 function refund(uint256 _amount) external returns(uint256)
 {
  uint nowTime= now;
  require((nowTime > (start_ + period_ * 1 days)) && (ethtotal_ < softcap_));

  uint256 tokenAmount = balances_[msg.sender];
  uint256 weiAmount = ethbalances_[msg.sender];
  require((_amount > 0) && (_amount <= weiAmount) && (_amount <= address(this).balance));

  if(tokenAmount > 0)
  {
   if(tokenAmount <= totalSupply_) { totalSupply_ = totalSupply_.sub(tokenAmount); }
   balances_[msg.sender] = 0;
   emit Transfer(msg.sender, address(0), tokenAmount);
  }

  ethbalances_[msg.sender]=ethbalances_[msg.sender].sub(_amount);
  msg.sender.transfer(_amount);
  emit RefundEvent(msg.sender, _amount);
  if(ethtotal_ >= _amount) { ethtotal_-= _amount; }

  return _amount;
 }

 function finishICO(uint256 _amount) external returns(uint256)
 {
  require(msg.sender == owner_);
  uint nowTime= now;
  require((nowTime >= start_) && (ethtotal_ >= softcap_));
  require(_amount <= address(this).balance);
  emit FinishEvent(_amount);
  msg.sender.transfer(_amount);

  return _amount;
 }

 function abalance(address _owner) public view returns (uint256) { return _owner.balance; }

}