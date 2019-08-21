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

contract PreSale is Ownable {
    uint256 constant public INCREASE_RATE = 350000000000000;
    uint256 constant public START_TIME = 1514228838;
    uint256 constant public END_TIME =   1524251238;

    uint256 public eggsSold;
    mapping (address => uint32) public eggs;

    bool private paused = false; 

    function PreSale() payable public {
    }

    event EggsPurchased(address indexed purchaser, uint256 value, uint32 quantity);
    
    event EggsRedeemed(address indexed sender, uint256 eggs);

    function bulkPurchageEgg() payable public {
        require(now > START_TIME);
        require(now < END_TIME);
        require(paused == false);
        require(msg.value >= (eggPrice() * 5 + INCREASE_RATE * 10));
        eggs[msg.sender] = eggs[msg.sender] + 5;
        eggsSold = eggsSold + 5;
        EggsPurchased(msg.sender, msg.value, 5);
    }
    
    function purchaseEgg() payable public {
        require(now > START_TIME);
        require(now < END_TIME);
        require(paused == false);
        require(msg.value >= eggPrice());

        eggs[msg.sender] = eggs[msg.sender] + 1;
        eggsSold = eggsSold + 1;
        
        EggsPurchased(msg.sender, msg.value, 1);
    }
    
    function redeemEgg(address targetUser) public returns(uint256) {
        require(paused == false);
        require(eggs[targetUser] > 0);

        EggsRedeemed(targetUser, eggs[targetUser]);

        var userEggs = eggs[targetUser];
        eggs[targetUser] = 0;
        return userEggs;
    }

    function eggPrice() view public returns(uint256) {
        return (eggsSold + 1) * INCREASE_RATE;
    }

    function withdrawal() onlyOwner public {
        owner.transfer(this.balance);
    }

    function pause() onlyOwner public {
        paused = true;
    }
    
    function resume() onlyOwner public {
        paused = false;
    }

    function isPaused () onlyOwner public view returns(bool) {
        return paused;
    }
}