pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

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

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

/**
 * @title ERC721Token
 * Generic implementation for the required functionality of the ERC721 standard
 */
contract EtherTv is Ownable {
  using SafeMath for uint256;

  Show[] private shows;
  uint256 public devOwed;

  // dividends
  mapping (address => uint256) public userDividends;

  // Events
  event ShowPurchased(
    uint256 _tokenId,
    address oldOwner,
    address newOwner,
    uint256 price,
    uint256 nextPrice
  );

  // Purchasing Caps for Determining Next Pool Cut
  uint256 constant private FIRST_CAP  = 0.5 ether;
  uint256 constant private SECOND_CAP = 1.0 ether;
  uint256 constant private THIRD_CAP  = 3.0 ether;
  uint256 constant private FINAL_CAP  = 5.0 ether;

  // Struct to store Show Data
  struct Show {
    uint256 price;  // Current price of the item.
    uint256 payout; // The percent of the pool rewarded.
    address owner;  // Current owner of the item.
  }

  function createShow(uint256 _payoutPercentage) onlyOwner() public {
    // payout must be greater than 0
    require(_payoutPercentage > 0);
    
    // create new token
    var show = Show({
      price: 0.005 ether,
      payout: _payoutPercentage,
      owner: this
    });

    shows.push(show);
  }

  function createMultipleShows(uint256[] _payoutPercentages) onlyOwner() public {
    for (uint256 i = 0; i < _payoutPercentages.length; i++) {
      createShow(_payoutPercentages[i]);
    }
  }

  function getShow(uint256 _showId) public view returns (
    uint256 price,
    uint256 nextPrice,
    uint256 payout,
    uint256 effectivePayout,
    address owner
  ) {
    var show = shows[_showId];
    price = show.price;
    nextPrice = getNextPrice(show.price);
    payout = show.payout;
    effectivePayout = show.payout.mul(10000).div(getTotalPayout());
    owner = show.owner;
  }

  /**
  * @dev Determines next price of token
  * @param _price uint256 ID of current price
  */
  function getNextPrice (uint256 _price) private pure returns (uint256 _nextPrice) {
    if (_price < FIRST_CAP) {
      return _price.mul(200).div(100);
    } else if (_price < SECOND_CAP) {
      return _price.mul(135).div(100);
    } else if (_price < THIRD_CAP) {
      return _price.mul(125).div(100);
    } else if (_price < FINAL_CAP) {
      return _price.mul(117).div(100);
    } else {
      return _price.mul(115).div(100);
    }
  }

  function calculatePoolCut (uint256 _price) private pure returns (uint256 _poolCut) {
    if (_price < FIRST_CAP) {
      return _price.mul(7).div(100); // 7%
    } else if (_price < SECOND_CAP) {
      return _price.mul(6).div(100); // 6%
    } else if (_price < THIRD_CAP) {
      return _price.mul(5).div(100); // 5%
    } else if (_price < FINAL_CAP) {
      return _price.mul(4).div(100); // 4%
    } else {
      return _price.mul(3).div(100); // 3%
    }
  }

  /**
  * @dev Purchase show from previous owner
  * @param _tokenId uint256 of token
  */
  function purchaseShow(uint256 _tokenId) public payable {
    var show = shows[_tokenId];
    uint256 price = show.price;
    address oldOwner = show.owner;
    address newOwner = msg.sender;

    // revert checks
    require(price > 0);
    require(msg.value >= price);
    require(oldOwner != msg.sender);

    uint256 purchaseExcess = msg.value.sub(price);

    // Calculate pool cut for taxes.
    
    // 4% goes to developers
    uint256 devCut = price.mul(4).div(100);
    devOwed = devOwed.add(devCut);

    // 3 - 7% goes to shareholders
    uint256 shareholderCut = calculatePoolCut(price);
    distributeDividends(shareholderCut);

    // Transfer payment to old owner minus the developer's and pool's cut.
    uint256 excess = price.sub(devCut).sub(shareholderCut);

    if (oldOwner != address(this)) {
      oldOwner.transfer(excess);
    }

    // set new price
    uint256 nextPrice = getNextPrice(price);
    show.price = nextPrice;

    // set new owner
    show.owner = newOwner;

    // Send refund to owner if needed
    if (purchaseExcess > 0) {
      newOwner.transfer(purchaseExcess);
    }

    // raise event
    ShowPurchased(_tokenId, oldOwner, newOwner, price, nextPrice);
  }

  function distributeDividends(uint256 _shareholderCut) private {
    uint256 totalPayout = getTotalPayout();

    for (uint256 i = 0; i < shows.length; i++) {
      var show = shows[i];
      var payout = _shareholderCut.mul(show.payout).div(totalPayout);
      userDividends[show.owner] = userDividends[show.owner].add(payout);
    }
  }

  function getTotalPayout() private view returns(uint256) {
    uint256 totalPayout = 0;

    for (uint256 i = 0; i < shows.length; i++) {
      var show = shows[i];
      totalPayout = totalPayout.add(show.payout);
    }

    return totalPayout;
  }

  /**
  * @dev Withdraw dev's cut
  */
  function withdraw() onlyOwner public {
    owner.transfer(devOwed);
    devOwed = 0;
  }

  /**
  * @dev Owner can withdraw their accumulated dividends
  */
  function withdrawDividends() public {
    uint256 dividends = userDividends[msg.sender];
    userDividends[msg.sender] = 0;
    msg.sender.transfer(dividends);
  }

}