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
    uint256 c = a / b;
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