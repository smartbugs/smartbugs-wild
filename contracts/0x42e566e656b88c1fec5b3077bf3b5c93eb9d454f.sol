pragma solidity ^0.4.24;

contract MultiSend {

  struct Receiver {
    address addr;
    uint amount;
  }

  event MultiTransfer (
    address from,
    uint total,
    Receiver[] receivers
  );

  address owner;

  constructor () public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(owner == msg.sender, "msg sender is not owner!");
    _;
  }

  function close() public onlyOwner {
    selfdestruct(owner);
  }

  function _safeTransfer(address _to, uint _amount) internal {
      require(_to != 0);
      _to.transfer(_amount);
  }

  function multiTransfer(address[] _addresses, uint[] _amounts)
    payable public returns(bool)
  {
      require(_addresses.length == _amounts.length);
      Receiver[] memory receivers = new Receiver[](_addresses.length);
      uint toReturn = msg.value;
      for (uint i = 0; i < _addresses.length; i++) {
          _safeTransfer(_addresses[i], _amounts[i]);
          toReturn = SafeMath.sub(toReturn, _amounts[i]);
          receivers[i].addr = _addresses[i];
          receivers[i].amount = _amounts[i]; 
      }
      emit MultiTransfer(msg.sender, msg.value, receivers);
      return true;
  }
}

library SafeMath
{
  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}