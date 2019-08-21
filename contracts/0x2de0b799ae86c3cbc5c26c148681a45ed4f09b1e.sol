pragma solidity ^0.4.18;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  function Ownable() public {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
contract UpfiringStore is Ownable {
  using SafeMath for uint;
  mapping(bytes32 => mapping(address => uint)) private payments;
  mapping(bytes32 => mapping(address => uint)) private paymentDates;
  mapping(address => uint) private balances;
  mapping(address => uint) private totalReceiving;
  mapping(address => uint) private totalSpending;
  function UpfiringStore() public {}
  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
  function totalReceivingOf(address _owner) public view returns (uint balance) {
    return totalReceiving[_owner];
  }
  function totalSpendingOf(address _owner) public view returns (uint balance) {
    return totalSpending[_owner];
  }
  function check(bytes32 _hash, address _from, uint _availablePaymentTime) public view returns (uint amount) {
    uint _amount = payments[_hash][_from];
    uint _date = paymentDates[_hash][_from];
    if (_amount > 0 && (_date + _availablePaymentTime) > now) {
      return _amount;
    } else {
      return 0;
    }
  }
  function payment(bytes32 _hash, address _from, uint _amount) onlyOwner public returns (bool result) {
    payments[_hash][_from] = payments[_hash][_from].add(_amount);
    paymentDates[_hash][_from] = now;
    return true;
  }
  function subBalance(address _owner, uint _amount) onlyOwner public returns (bool result) {
    require(balances[_owner] >= _amount);
    balances[_owner] = balances[_owner].sub(_amount);
    totalSpending[_owner] = totalSpending[_owner].add(_amount);
    return true;
  }
  function addBalance(address _owner, uint _amount) onlyOwner public returns (bool result) {
    balances[_owner] = balances[_owner].add(_amount);
    totalReceiving[_owner] = totalReceiving[_owner].add(_amount);
    return true;
  }
}
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Upfiring is Ownable {
  using SafeMath for uint;
  ERC20 public token;
  UpfiringStore public store;
  uint8 public torrentOwnerPercent = 50;
  uint8 public seedersProfitMargin = 3;
  uint public availablePaymentTime = 86400; //seconds
  uint public minWithdraw = 0;
  event Payment(string _torrent, uint _amount, address indexed _from);
  event Refill(address indexed _to, uint _amount);
  event Withdraw(address indexed _to, uint _amount);
  event Pay(address indexed _to, uint _amount, bytes32 _hash);
  event ChangeBalance(address indexed _to, uint _balance);
  event LogEvent(string _log);
  function Upfiring(UpfiringStore _store, ERC20 _token, uint8 _torrentOwnerPercent, uint8 _seedersProfitMargin, uint _minWithdraw) public {
    require(_store != address(0));
    require(_token != address(0));
    require(_torrentOwnerPercent != 0);
    require(_seedersProfitMargin != 0);
    store = _store;
    token = _token;
    torrentOwnerPercent = _torrentOwnerPercent;
    seedersProfitMargin = _seedersProfitMargin;
    minWithdraw = _minWithdraw;
  }
  function() external payable {
    revert();
  }
  function balanceOf(address _owner) public view returns (uint balance) {
    return store.balanceOf(_owner);
  }
  function totalReceivingOf(address _owner) public view returns (uint balance) {
    return store.totalReceivingOf(_owner);
  }
  function totalSpendingOf(address _owner) public view returns (uint balance) {
    return store.totalSpendingOf(_owner);
  }
  function check(string _torrent, address _from) public view returns (uint amount) {
    return store.check(torrentToHash(_torrent), _from, availablePaymentTime);
  }
  function torrentToHash(string _torrent) internal pure returns (bytes32 _hash)  {
    return sha256(_torrent);
  }
  function refill(uint _amount) external {
    require(_amount != uint(0));
    require(token.transferFrom(msg.sender, address(this), _amount));
    store.addBalance(msg.sender, _amount);
    ChangeBalance(msg.sender, store.balanceOf(msg.sender));
    Refill(msg.sender, _amount);
  }
  function withdraw(uint _amount) external {
    require(_amount >= minWithdraw);
    require(token.balanceOf(address(this)) >= _amount);
    require(token.transfer(msg.sender, _amount));
    require(store.subBalance(msg.sender, _amount));
    ChangeBalance(msg.sender, store.balanceOf(msg.sender));
    Withdraw(msg.sender, _amount);
  }
  function pay(string _torrent, uint _amount, address _owner, address[] _seeders, address[] _freeSeeders) external {
    require(_amount != uint(0));
    require(_owner != address(0));
    bytes32 _hash = torrentToHash(_torrent);
    require(store.subBalance(msg.sender, _amount));
    store.payment(_hash, msg.sender, _amount);
    Payment(_torrent, _amount, msg.sender);
    ChangeBalance(msg.sender, store.balanceOf(msg.sender));
    sharePayment(_hash, _amount, _owner, _seeders, _freeSeeders);
  }
  function sharePayment(bytes32 _hash, uint _amount, address _owner, address[] _seeders, address[] _freeSeeders) internal {
    if ((_seeders.length + _freeSeeders.length) == 0) {
      payTo(_owner, _amount, _hash);
    } else {
      uint _ownerAmount = _amount.mul(torrentOwnerPercent).div(100);
      uint _otherAmount = _amount.sub(_ownerAmount);
      uint _realOtherAmount = shareSeeders(_seeders, _freeSeeders, _otherAmount, _hash);
      payTo(_owner, _amount.sub(_realOtherAmount), _hash);
    }
  }
  function shareSeeders(address[] _seeders, address[] _freeSeeders, uint _amount, bytes32 _hash) internal returns (uint){
    uint _dLength = _freeSeeders.length.add(_seeders.length.mul(seedersProfitMargin));
    uint _dAmount = _amount.div(_dLength);
    payToList(_seeders, _dAmount.mul(seedersProfitMargin), _hash);
    payToList(_freeSeeders, _dAmount, _hash);
    return _dLength.mul(_dAmount);
  }
  function payToList(address[] _seeders, uint _amount, bytes32 _hash) internal {
    if (_seeders.length > 0) {
      for (uint i = 0; i < _seeders.length; i++) {
        address _seeder = _seeders[i];
        payTo(_seeder, _amount, _hash);
      }
    }
  }
  function payTo(address _to, uint _amount, bytes32 _hash) internal {
    require(store.addBalance(_to, _amount));
    Pay(_to, _amount, _hash);
    ChangeBalance(_to, store.balanceOf(_to));
  }
  function migrateStore(address _to) onlyOwner public {
    store.transferOwnership(_to);
  }
  function setAvailablePaymentTime(uint _availablePaymentTime) onlyOwner public {
    availablePaymentTime = _availablePaymentTime;
  }
  function setSeedersProfitMargin(uint8 _seedersProfitMargin) onlyOwner public {
    seedersProfitMargin = _seedersProfitMargin;
  }
  function setTorrentOwnerPercent(uint8 _torrentOwnerPercent) onlyOwner public {
    torrentOwnerPercent = _torrentOwnerPercent;
  }
  function setMinWithdraw(uint _minWithdraw) onlyOwner public {
    minWithdraw = _minWithdraw;
  }
}