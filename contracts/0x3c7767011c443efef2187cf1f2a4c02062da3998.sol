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

contract CratePreSale is Ownable {
    
    // ------ STATE ------ 
    uint256 constant public MAX_CRATES_TO_SELL = 3900; // Max no. of robot crates to ever be sold
    uint256 constant public PRESALE_END_TIMESTAMP = 1518699600; // End date for the presale - no purchases can be made after this date - Midnight 16 Feb 2018 UTC

    uint256 public appreciationRateWei = 400000000000000;  
    uint256 public currentPrice = appreciationRateWei; // initalise the price to the appreciation rate
    uint32 public cratesSold;
    
    mapping (address => uint32) public userCrateCount; // store how many crates a user has bought
    mapping (address => uint[]) public userToRobots; // store the DNA/robot information of bought crates
    
    // ------ EVENTS ------ 
    event LogCratePurchase( 
        address indexed _from,
        uint256 _value,
        uint32 _quantity
        );


    // ------ FUNCTIONS ------ 
    function getPrice() view public returns (uint256) {
        return currentPrice;
    }

    function getRobotsForUser( address _user ) view public returns (uint[]) {
        return userToRobots[_user];
    }

    function incrementPrice() private { 
        // Decrease the rate of increase of the crate price
        // as the crates become more expensive
        // to avoid runaway pricing
        // (halving rate of increase at 0.1 ETH, 0.2 ETH, 0.3 ETH).
        if ( currentPrice == 100000000000000000 ) {
            appreciationRateWei = 200000000000000;
        } else if ( currentPrice == 200000000000000000) {
            appreciationRateWei = 100000000000000;
        } else if (currentPrice == 300000000000000000) {
            appreciationRateWei = 50000000000000;
        }
        currentPrice += appreciationRateWei;
    }

    function purchaseCrate() payable public {
        require(now < PRESALE_END_TIMESTAMP); // Check presale is still ongoing
        require(cratesSold < MAX_CRATES_TO_SELL); // Check max crates sold is less than hard limit
        require(msg.value >= currentPrice); // Check buyer sent sufficient funds to purchase
        if (msg.value > currentPrice) { //overpaid, return excess
            msg.sender.transfer(msg.value-currentPrice);
        }
        userCrateCount[msg.sender] += 1;
        cratesSold++;
        incrementPrice();
        userToRobots[msg.sender].push(genRandom());
        LogCratePurchase(msg.sender, msg.value, 1);

    }

    // ROBOT FORMAT
    // [3 digits - RARITY][2 digits - PART] * 4 (4 parts)
    // e.g. [140][20][218][04]
    // Presale exclusives are encoded by extending the range of the part by 1
    // ie lamborghini will be the 23rd body. If 23 (or a multiple of it) is generated, a lamborghini will be awarded.
    //RARITY INFORMATION:
    //All parts are of equal rarity, except for presale exclusives.
    //A three-digit modifier precedes each part, denoting whether it is of type
    //normal, rare shadow, or legendary gold.
    //Shadow has a 10% chance of applying for the presale (2% in game)
    //Gold has a 5% chance of applying for the presale (1% in game).
    function genRandom() private view returns (uint) {
        uint rand = uint(keccak256(block.blockhash(block.number-1)));
        return uint(rand % (10 ** 20));
    }

    //owner only withdrawal function for the presale
    function withdraw() onlyOwner public {
        owner.transfer(this.balance);
    }
}