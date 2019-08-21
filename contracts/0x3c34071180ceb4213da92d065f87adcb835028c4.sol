pragma solidity ^0.4.13;

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

contract CryptoScams {
  using SafeMath for uint256;  
  event Bought (uint256 indexed _scamId, address indexed _owner, uint256 _price);
  event Sold (uint256 indexed _scamId, address indexed _owner, uint256 _price);  
  address public owner;
  uint256[] private scams; 
  mapping (uint256 => uint256) private startingPriceOfScam;
  mapping (uint256 => uint256) private priceOfScam;
  mapping (uint256 => address) private ownerOfScam;
  mapping (uint256 => string) private nameOfScam;
  uint256 cutPercent = 5;

  function CryptoScams () public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(owner == msg.sender);
    _;
  }
  
  function setCut (uint256 _n) onlyOwner() public {
	  require(_n >= 0 && _n <= 10);
    cutPercent = _n;
  }

  function withdraw () onlyOwner() public {
    owner.transfer(this.balance);
  }

  function setOwner (address _owner) onlyOwner() public {
    owner = _owner;
  }

  function listScam (uint256 _scamId, string _name, uint256 _price) onlyOwner() public {
    require(_price > 0);
    require(priceOfScam[_scamId] == 0);
    require(ownerOfScam[_scamId] == address(0));
    ownerOfScam[_scamId] = owner;
    priceOfScam[_scamId] = _price;
    startingPriceOfScam[_scamId] = _price;
    nameOfScam[_scamId] = _name;
    scams.push(_scamId);
  }
  
  function getScam(uint256 _scamId) public view returns (address _owner, uint256 _price, string _name) {
    _owner = ownerOfScam[_scamId];
    _price = priceOfScam[_scamId];
    _name = nameOfScam[_scamId];
  }

  function getOwner (uint256 _scamId) public view returns (address _owner) {
    return ownerOfScam[_scamId];
  }

  function startingPriceOf (uint256 _scamId) public view returns (uint256 _startingPrice) {
    return startingPriceOfScam[_scamId];
  }
  
  function priceOf (uint256 _scamId) public view returns (uint256 _price) {
    return priceOfScam[_scamId];
  }

  function nextPriceOf (uint256 _scamId) public view returns (uint256 _nextPrice) {
    return calculateNextPrice(priceOf(_scamId));
  }

  function allScamsForSale () public view returns (uint256[] _scams) {
    return scams;
  }
  
  function getNumberOfScams () public view returns (uint256 _n) {
    return scams.length;
  }

  function calculateNextPrice (uint256 _currentPrice) public pure returns (uint256 _newPrice) {
	  return _currentPrice.mul(125).div(100); // 1.25
  }

  function buy (uint256 _scamId) payable public {
    require(!isContract(msg.sender));
    require(priceOf(_scamId) > 0);
    require(getOwner(_scamId) != address(0));
    require(msg.value == priceOf(_scamId));
    require(getOwner(_scamId) != msg.sender);
    address previousOwner = getOwner(_scamId);
    address newOwner = msg.sender;
    uint256 price = priceOf(_scamId);
    ownerOfScam[_scamId] = newOwner;
    priceOfScam[_scamId] = nextPriceOf(_scamId);
    Bought(_scamId, newOwner, price);
    Sold(_scamId, previousOwner, price);
    uint256 cutAmount = price.mul(cutPercent).div(100);
    previousOwner.transfer(price - cutAmount);
  }

  function isContract(address addr) internal view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }
}