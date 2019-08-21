pragma solidity 0.5.5;

library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract IERC20 {
    function transfer(address to, uint256 value) public returns (bool) {}
}

contract CurrentKing {
  using SafeMath for uint256;

  // initialize
  uint256 public REWARD_PER_WIN = 10000000;
  uint256 public CREATOR_REWARD = 100000;
  address public CREATOR_ADDRESS;
  address public GTT_ADDRESS;

  // game state params
  uint256 public lastPaidBlock;
  address public currentKing;

  constructor() public {
    CREATOR_ADDRESS = msg.sender;
    lastPaidBlock = block.number;
    currentKing = address(this);
  }

  // can only be called once
  function setTokenAddress(address _gttAddress) public {
    if (GTT_ADDRESS == address(0)) {
      GTT_ADDRESS = _gttAddress;
    }
  }

  function play() public {
    uint256 currentBlock = block.number;

    // pay old king
    if (currentBlock != lastPaidBlock) {
      payOut(currentBlock);

      // reinitialize
      lastPaidBlock = currentBlock;
    }

    // set new king
    currentKing = msg.sender;
  }

  function payOut(uint256 _currentBlock) internal {
    // calculate multiplier (# of unclaimed blocks)
    uint256 numBlocksToPayout = _currentBlock.sub(lastPaidBlock);

    IERC20(GTT_ADDRESS).transfer(currentKing, REWARD_PER_WIN.mul(numBlocksToPayout));
    IERC20(GTT_ADDRESS).transfer(CREATOR_ADDRESS, CREATOR_REWARD.mul(numBlocksToPayout));
  }
}