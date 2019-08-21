pragma solidity ^0.4.13;

contract ItemRegistry {
  using SafeMath for uint256;

  enum ItemClass {TIER1, TIER2, TIER3, TIER4}

  event Bought (uint256 indexed _itemId, address indexed _owner, uint256 _price);
  event Sold (uint256 indexed _itemId, address indexed _owner, uint256 _price);

  address public owner;
  uint256 cutNumerator = 5;
  uint256 cutDenominator = 100;

  uint256[] private listedItems;
  mapping (uint256 => address) private ownerOfItem;
  mapping (uint256 => uint256) private startingPriceOfItem;
  mapping (uint256 => uint256) private priceOfItem;
  mapping (uint256 => ItemClass) private classOfItem;

  function ItemRegistry () public {
    owner = msg.sender;
  }

  /* Modifiers */
  modifier onlyOwner() {
    require(owner == msg.sender);
    _;
  }

  /* Admin */
  function setOwner (address _owner) onlyOwner() public {
    owner = _owner;
  }

  function setCut (uint256 _n, uint256 _d) onlyOwner() public {
    cutNumerator = _n;
    cutDenominator = _d;
  }

  function withdraw () onlyOwner() public {
    owner.transfer(this.balance);
  }

  function listItem (uint256 _itemId, uint256 _price, ItemClass _class) onlyOwner() public {
    require(_price > 0);
    require(priceOfItem[_itemId] == 0);
    require(ownerOfItem[_itemId] == address(0));
    require(_class <= ItemClass.TIER4);

    ownerOfItem[_itemId] = owner;
    priceOfItem[_itemId] = _price;
    startingPriceOfItem[_itemId] = _price;
    classOfItem[_itemId] = _class;
    listedItems.push(_itemId);
  }

  function listMultipleItems (uint256[] _itemIds, uint256 _price, ItemClass _class) onlyOwner() external {
    for (uint256 i = 0; i < _itemIds.length; i++) {
      listItem(_itemIds[i], _price, _class);
    }
  }

  /* Read */
  function balanceOf (address _owner) public view returns (uint256 _balance) {
    uint256 counter = 0;

    for (uint256 i = 0; i < listedItems.length; i++) {
      if (ownerOf(listedItems[i]) == _owner) {
        counter++;
      }
    }

    return counter;
  }

  function ownerOf (uint256 _itemId) public view returns (address _owner) {
    return ownerOfItem[_itemId];
  }

  function startingPriceOf (uint256 _itemId) public view returns (uint256 _startingPrice) {
    return startingPriceOfItem[_itemId];
  }

  function priceOf (uint256 _itemId) public view returns (uint256 _price) {
    return priceOfItem[_itemId];
  }

  function classOf (uint256 _itemId) public view returns (ItemClass _class) {
    return classOfItem[_itemId];
  }

  function nextPriceOf (uint256 _itemId) public view returns (uint256 _nextPrice) {
    return calculateNextPrice(priceOf(_itemId), classOf(_itemId));
  }

  function allOf (uint256 _itemId) external view returns (address _owner, uint256 _startingPrice, uint256 _price, ItemClass _class, uint256 _nextPrice) {
    return (ownerOf(_itemId), startingPriceOf(_itemId), priceOf(_itemId), classOf(_itemId), nextPriceOf(_itemId));
  }

  function itemsOfOwner (address _owner) public view returns (uint256[] _items) {
    uint256[] memory items = new uint256[](balanceOf(_owner));

    uint256 itemCounter = 0;
    for (uint256 i = 0; i < listedItems.length; i++) {
      if (ownerOf(listedItems[i]) == _owner) {
        items[itemCounter] = listedItems[i];
        itemCounter += 1;
      }
    }

    return items;
  }

  function numberOfItemsForSale () public view returns (uint256 _n) {
    return listedItems.length;
  }

  function itemsForSaleLimit (uint256 _from, uint256 _take) public view returns (uint256[] _items) {
    uint256[] memory items = new uint256[](_take);

    for (uint256 i = 0; i < _take; i++) {
      items[i] = listedItems[_from + i];
    }

    return items;
  }

  function allItemsForSale () public view returns (uint256[] _items) {
    return listedItems;
  }

  /* Next price */
  function calculateNextPrice (uint256 _currentPrice, ItemClass _class) public pure returns (uint256 _newPrice) {
    if (_class == ItemClass.TIER1) {
      if (_currentPrice <= 0.05 ether) {
        return _currentPrice.mul(2); // 2
      } else if (_currentPrice <= 0.5 ether) {
        return _currentPrice.mul(117).div(100); // 1.17
      } else {
        return _currentPrice.mul(112).div(100); // 1.12
      }
    }

    if (_class == ItemClass.TIER2) {
      if (_currentPrice <= 0.1 ether) {
        return _currentPrice.mul(2); // 2
      } else if (_currentPrice <= 0.5 ether) {
        return _currentPrice.mul(118).div(100); // 1.18
      } else {
        return _currentPrice.mul(113).div(100); // 1.13
      }
    }

    if (_class == ItemClass.TIER3) {
      if (_currentPrice <= 0.15 ether) {
        return _currentPrice * 2; // 2
      } else if (_currentPrice <= 0.5 ether) {
        return _currentPrice.mul(119).div(100); // 1.19
      } else {
        return _currentPrice.mul(114).div(100); // 1.14
      }
    }

    if (_class == ItemClass.TIER4) {
      if (_currentPrice <= 0.2 ether) {
        return _currentPrice.mul(2); // 2
      } else if (_currentPrice <= 0.5 ether) {
        return _currentPrice.mul(120).div(100); // 1.2
      } else {
        return  _currentPrice.mul(115).div(100); // 1.15
      }
    }
  }

  /* Buy */
  function buy (uint256 _itemId) payable public {
    require(priceOf(_itemId) > 0);
    require(ownerOf(_itemId) != address(0));
    require(msg.value == priceOf(_itemId));
    require(ownerOf(_itemId) != msg.sender);
    require(!isContract(msg.sender));

    address oldOwner = ownerOf(_itemId);
    address newOwner = msg.sender;
    uint256 price = priceOf(_itemId);

    ownerOfItem[_itemId] = newOwner;
    priceOfItem[_itemId] = nextPriceOf(_itemId);

    Bought(_itemId, newOwner, price);
    Sold(_itemId, oldOwner, price);

    uint256 cut = 0;
    if (cutDenominator > 0 && cutNumerator > 0) {
      cut = price.mul(cutNumerator).div(cutDenominator);
    }

    oldOwner.transfer(price - cut);
  }

  /* Util */
  function isContract(address addr) internal view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) } // solium-disable-line
    return size > 0;
  }
}

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