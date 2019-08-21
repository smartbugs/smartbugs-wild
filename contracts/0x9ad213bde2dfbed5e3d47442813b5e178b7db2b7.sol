pragma solidity ^0.4.24;

contract Fog {
  address public owner;

  event OwnershipTransferred(
    address indexed owner,
    address indexed newOwner
  );

  event Winner(address indexed to, uint indexed value);
  event CupCake(address indexed to, uint indexed value);
  event Looser(address indexed from, uint indexed value);

  constructor() public {
    owner = msg.sender;
  }

  function move(uint256 direction) public payable {
    require(tx.origin == msg.sender);

    uint doubleValue = mul(msg.value, 2);
    uint minValue = 10000000000000000; // 0.01 Ether

    // Check for minValue and make sure we have enough balance
    require(msg.value >= minValue && doubleValue <= address(this).balance);

    // Roll biased towards direction
    uint dice = uint(keccak256(abi.encodePacked(now + uint(msg.sender) + direction))) % 3;

    // Winner
    if (dice == 2) {
      msg.sender.transfer(doubleValue);
      emit Winner(msg.sender, doubleValue);

    // Looser
    } else {
      // Coin biased towards direction
      uint coin = uint(keccak256(abi.encodePacked(now + uint(msg.sender) + direction))) % 2;

      // CupCake
      if (coin == 1) {
        // Woa! Refund 80%
        uint eightyPercent = div(mul(msg.value, 80), 100);

        msg.sender.transfer(eightyPercent);
        emit CupCake(msg.sender, eightyPercent);

      // Looser
      } else {
        emit Looser(msg.sender, msg.value);
      }
    }
  }

  function drain(uint value) public onlyOwner {
    require(value > 0 && value < address(this).balance);
    owner.transfer(value);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function() public payable { }

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
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }
}