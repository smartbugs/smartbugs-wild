pragma solidity ^0.4.18;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



contract CaiShen is Ownable {
    struct Gift {
        bool exists;        // 0 Only true if this exists
        uint giftId;        // 1 The gift ID
        address giver;      // 2 The address of the giver
        address recipient;  // 3 The address of the recipient
        uint expiry;        // 4 The expiry datetime of the timelock as a
                            //   Unix timestamp
        uint amount;        // 5 The amount of ETH
        bool redeemed;      // 6 Whether the funds have already been redeemed
        string giverName;   // 7 The giver's name
        string message;     // 8 A message from the giver to the recipient
        uint timestamp;     // 9 The timestamp of when the gift was given
    }

    // Total fees gathered since the start of the contract or the last time
    // fees were collected, whichever is latest
    uint public feesGathered;

    // Each gift has a unique ID. If you increment this value, you will get
    // an unused gift ID.
    uint public nextGiftId;

    // Maps each recipient address to a list of giftIDs of Gifts they have
    // received.
    mapping (address => uint[]) public recipientToGiftIds;

    // Maps each gift ID to its associated gift.
    mapping (uint => Gift) public giftIdToGift;

    event Constructed (address indexed by, uint indexed amount);

    event CollectedAllFees (address indexed by, uint indexed amount);

    event DirectlyDeposited(address indexed from, uint indexed amount);

    event Gave (uint indexed giftId,
                address indexed giver,
                address indexed recipient,
                uint amount, uint expiry);

    event Redeemed (uint indexed giftId,
                    address indexed giver,
                    address indexed recipient,
                    uint amount);

    // Constructor
    function CaiShen() public payable {
        Constructed(msg.sender, msg.value);
    }

    // Fallback function which allows this contract to receive funds.
    function () public payable {
        // Sending ETH directly to this contract does nothing except log an
        // event.
        DirectlyDeposited(msg.sender, msg.value);
    }

    //// Getter functions:

    function getGiftIdsByRecipient (address recipient) 
    public view returns (uint[]) {
        return recipientToGiftIds[recipient];
    }

    //// Contract functions:

    // Call this function while sending ETH to give a gift.
    // @recipient: the recipient's address
    // @expiry: the Unix timestamp of the expiry datetime.
    // @giverName: the name of the giver
    // @message: a personal message
    // Tested in test/test_give.js and test/TestGive.sol
    function give (address recipient, uint expiry, string giverName, string message)
    public payable returns (uint) {
        address giver = msg.sender;

        // Validate the giver address
        assert(giver != address(0));

        // The gift must be a positive amount of ETH
        uint amount = msg.value;
        require(amount > 0);
        
        // The expiry datetime must be in the future.
        // The possible drift is only 12 minutes.
        // See: https://consensys.github.io/smart-contract-best-practices/recommendations/#timestamp-dependence
        require(expiry > now);

        // The giver and the recipient must be different addresses
        require(giver != recipient);

        // The recipient must be a valid address
        require(recipient != address(0));

        // Make sure nextGiftId is 0 or positive, or this contract is buggy
        assert(nextGiftId >= 0);

        // Calculate the contract owner's fee
        uint feeTaken = fee(amount);
        assert(feeTaken >= 0);

        // Increment feesGathered
        feesGathered = SafeMath.add(feesGathered, feeTaken);

        // Shave off the fee from the amount
        uint amtGiven = SafeMath.sub(amount, feeTaken);
        assert(amtGiven > 0);

        // If a gift with this new gift ID already exists, this contract is buggy.
        assert(giftIdToGift[nextGiftId].exists == false);

        // Update the mappings
        recipientToGiftIds[recipient].push(nextGiftId);
        giftIdToGift[nextGiftId] = 
            Gift(true, nextGiftId, giver, recipient, expiry, 
            amtGiven, false, giverName, message, now);

        uint giftId = nextGiftId;

        // Increment nextGiftId
        nextGiftId = SafeMath.add(giftId, 1);

        // If a gift with this new gift ID already exists, this contract is buggy.
        assert(giftIdToGift[nextGiftId].exists == false);

        // Log the event
        Gave(giftId, giver, recipient, amount, expiry);

        return giftId;
    }

    // Call this function to redeem a gift of ETH.
    // Tested in test/test_redeem.js
    function redeem (uint giftId) public {
        // The giftID should be 0 or positive
        require(giftId >= 0);

        // The gift must exist and must not have already been redeemed
        require(isValidGift(giftIdToGift[giftId]));

        // The recipient must be the caller of this function
        address recipient = giftIdToGift[giftId].recipient;
        require(recipient == msg.sender);

        // The current datetime must be the same or after the expiry timestamp
        require(now >= giftIdToGift[giftId].expiry);

        //// If the following assert statements are triggered, this contract is
        //// buggy.

        // The amount must be positive because this is required in give()
        uint amount = giftIdToGift[giftId].amount;
        assert(amount > 0);

        // The giver must not be the recipient because this was asserted in give()
        address giver = giftIdToGift[giftId].giver;
        assert(giver != recipient);

        // Make sure the giver is valid because this was asserted in give();
        assert(giver != address(0));

        // Update the gift to mark it as redeemed, so that the funds cannot be
        // double-spent
        giftIdToGift[giftId].redeemed = true;

        // Transfer the funds
        recipient.transfer(amount);

        // Log the event
        Redeemed(giftId, giftIdToGift[giftId].giver, recipient, amount);
    }

    // Calculate the contract owner's fee
    // Tested in test/test_fee.js
    function fee (uint amount) public pure returns (uint) {
        if (amount <= 0.01 ether) {
            return 0;
        } else if (amount > 0.01 ether) {
            return SafeMath.div(amount, 100);
        }
    }

    // Transfer the fees collected thus far to the contract owner.
    // Only the contract owner may invoke this function.
    // Tested in test/test_collect_fees.js
    function collectAllFees () public onlyOwner {
        // Store the fee amount in a temporary variable
        uint amount = feesGathered;

        // Make sure that the amount is positive
        require(amount > 0);

        // Set the feesGathered state variable to 0
        feesGathered = 0;

        // Make the transfer
        owner.transfer(amount);

        CollectedAllFees(owner, amount);
    }

    // Returns true only if the gift exists and has not already been
    // redeemed
    function isValidGift(Gift gift) private pure returns (bool) {
        return gift.exists == true && gift.redeemed == false;
    }
}