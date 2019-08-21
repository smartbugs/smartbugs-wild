pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Mainsale {

  using SafeMath for uint256;

  address public owner;
  address public multisig;
  uint256 public endTimestamp;
  uint256 public totalRaised;
  uint256 public constant hardCap = 19333 ether;
  uint256 public constant MIN_CONTRIBUTION = 0.1 ether;
  uint256 public constant MAX_CONTRIBUTION = 1000 ether;
  uint256 public constant THIRTY_DAYS = 60 * 60 * 24 * 30;

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier belowCap() {
    require(totalRaised < hardCap);
    _;
  }

  modifier withinTimeLimit() {
    require(block.timestamp <= endTimestamp);
    _;
  }

  function Mainsale(address _multisig, uint256 _endTimestamp) {
    require (_multisig != 0 && _endTimestamp >= (block.timestamp + THIRTY_DAYS));
    owner = msg.sender;
    multisig = _multisig;
    endTimestamp = _endTimestamp;
  }
  
  function() payable belowCap withinTimeLimit {
    require(msg.value >= MIN_CONTRIBUTION && msg.value <= MAX_CONTRIBUTION);
    totalRaised = totalRaised.add(msg.value);
    uint contribution = msg.value;
    if (totalRaised > hardCap) {
      uint refundAmount = totalRaised.sub(hardCap);
      msg.sender.transfer(refundAmount);
      contribution = contribution.sub(refundAmount);
      refundAmount = 0;
      totalRaised = hardCap;
    }
    multisig.transfer(contribution);
  }

  function withdrawStuck() onlyOwner {
    multisig.transfer(this.balance);
  }

}