pragma solidity 0.5.5;

contract IERC20 {
    function transfer(address to, uint256 value) public returns (bool) {}
}

contract GasPrice {

  // initialize
  uint256 public REWARD_PER_WIN = 12500000;
  uint256 public CREATOR_REWARD = 125000;
  address public CREATOR_ADDRESS;
  address public GTT_ADDRESS;
  uint256 public ONE_HUNDRED_GWEI = 100000000000;

  // game state params
  uint256 public currLowest;
  uint256 public lastPayoutBlock;
  address public currWinner;

  constructor() public {
    CREATOR_ADDRESS = msg.sender;
    lastPayoutBlock = block.number;
    currWinner = address(this);
  }

  // can only be called once
  function setTokenAddress(address _gttAddress) public {
    if (GTT_ADDRESS == address(0)) {
      GTT_ADDRESS = _gttAddress;
    }
  }

  function play() public {
    uint256 currentBlock = block.number;

    // pay out last winner
    if (lastPayoutBlock < currentBlock) {
      payOut(currWinner);

      // reinitialize
      lastPayoutBlock = currentBlock;
      currLowest = ONE_HUNDRED_GWEI;
    }

    // set current winner
    if (tx.gasprice <= currLowest) {
      currLowest = tx.gasprice;
      currWinner = msg.sender;
    }
  }

  function payOut(address winner) internal {
    IERC20(GTT_ADDRESS).transfer(winner, REWARD_PER_WIN);
    IERC20(GTT_ADDRESS).transfer(CREATOR_ADDRESS, CREATOR_REWARD);
  }
}