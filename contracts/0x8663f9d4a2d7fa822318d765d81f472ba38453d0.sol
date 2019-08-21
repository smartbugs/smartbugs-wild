pragma solidity ^0.4.15;

/// @title DNNToken contract - Main DNN contract
/// @author Dondrey Taylor - <dondrey@dnn.media>
contract DNNToken {
    enum DNNSupplyAllocations {
        EarlyBackerSupplyAllocation,
        PRETDESupplyAllocation,
        TDESupplyAllocation,
        BountySupplyAllocation,
        WriterAccountSupplyAllocation,
        AdvisorySupplyAllocation,
        PlatformSupplyAllocation
    }
    function balanceOf(address who) constant public returns (uint256);
    function issueTokens(address, uint256, DNNSupplyAllocations) public pure returns (bool) {}
}

/// @title DNNHODLGame contrac
/// @author Dondrey Taylor - <dondrey@dnn.media>
contract DNNHODLGame {

  // DNN Token
  DNNToken public dnnToken;

  // Owner
  address owner = 0x3Cf26a9FE33C219dB87c2e50572e50803eFb2981;

  // Stores largest HODLER information
  uint256 public largestHODLERBalance = 0;
  address public largestHODLERAddress = 0x0;

  // Stores last largest HODLER information
  uint256 public lastLargestHODLERBalance = 0;
  address public lastLargestHODLER = 0x0;

	// Event that gets triggered each time a user
	// sends a redemption transaction to this smart contract
  event WINNER(address indexed to, uint256 dnnBalance, uint256 dnnWon);
	event HODLER(address indexed to, uint256 dnnBalance);
	event NEWLARGESTHODLER(address indexed from, uint256 dnnBalance);

  // Owner
  modifier onlyOwner() {
      require (msg.sender == owner);
      _;
  }

  // Decide DNN Winner
  function decideWinner(uint256 dnnToReward, DNNToken.DNNSupplyAllocations allocationType)
    public
    onlyOwner
  {
      if (!dnnToken.issueTokens(largestHODLERAddress, dnnToReward, allocationType)) {
          revert();
      }
      else {
          emit WINNER(largestHODLERAddress, largestHODLERBalance, dnnToReward);
          lastLargestHODLER = largestHODLERAddress;
          lastLargestHODLERBalance = largestHODLERBalance;
          largestHODLERAddress = 0x0;
          largestHODLERBalance = 0;
      }
  }

  // Constructor
  constructor() public
  {
      dnnToken = DNNToken(0x9D9832d1beb29CC949d75D61415FD00279f84Dc2);
  }

	// Handles incoming transactions
	function () public payable {

      // Sender address
      address dnnHODLER = msg.sender;

      // Sender balance
      uint256 dnnHODLERBalance = dnnToken.balanceOf(msg.sender);

      // Check if the senders balance is the largest
      if (largestHODLERBalance <= dnnHODLERBalance) {
          if ( (lastLargestHODLER != dnnHODLER) ||
              (lastLargestHODLER == dnnHODLER && lastLargestHODLERBalance < dnnHODLERBalance)
          ) {
              largestHODLERBalance = dnnHODLERBalance;
              largestHODLERAddress = dnnHODLER;
              emit NEWLARGESTHODLER(msg.sender, dnnHODLERBalance);
          }
      }

      emit HODLER(msg.sender, dnnHODLERBalance);

      if (msg.value > 0) {
          owner.transfer(msg.value);
      }
	}
}