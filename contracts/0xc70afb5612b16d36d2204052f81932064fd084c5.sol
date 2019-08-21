pragma solidity ^0.4.20;

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
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract MintableToken {
  event Mint(address indexed to, uint256 amount);
  function leave() public;
  function mint(address _to, uint256 _amount) public returns (bool);
}

contract CryptoColors is Pausable {
  using SafeMath for uint256;

  // CONSTANT

  string public constant name = "Pixinch Color";
  string public constant symbol = "PCLR";
  uint public constant totalSupply = 16777216;

  // PUBLIC VARs
  // the total number of colors bought
  uint256 public totalBoughtColor;
  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;
  
  // address where funds are collected
  address public wallet;
  // price for a color
  uint256 public colorPrice;
  // nb token supply when a color is bought
  uint public supplyPerColor;
  // the part on the supply that is collected by Pixinch
  uint8 public ownerPart;

  uint8 public bonusStep;
  uint public nextBonusStepLimit = 500000;

  // MODIFIER
  
  /**
  * @dev Guarantees msg.sender is owner of the given token
  * @param _index uint256 Index of the token to validate its ownership belongs to msg.sender
  */
  modifier onlyOwnerOf(uint _index) {
    require(tree[_index].owner == msg.sender);
    _;
  }

  /**
  * @dev Garantee index and token are valid value
  */
  modifier isValid(uint _tokenId, uint _index) {
    require(_validToken(_tokenId) && _validIndex(_index));
    _;
  }

  /**
  * @dev Guarantees all color have been sold
  */
  modifier whenActive() {
    require(isCrowdSaleActive());
    _;
  }

  /**
  * @dev Guarantees all color have been sold
  */
  modifier whenGameActive() {
    require(isGameActivated());
    _;
  }

  // EVENTS
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event ColorPurchased(address indexed from, address indexed to, uint256 color, uint256 value);
  event ColorReserved(address indexed to, uint256 qty);


  // PRIVATE
  // amount of raised money in wei and cap in wei
  uint256 weiRaised;
  uint256 cap;
  // part of mint token for the wallet
  uint8 walletPart;
  // address of the mintable token
  MintableToken token;
  // starting color price
  uint startPrice = 10 finney;

  struct BlockRange {
    uint start;
    uint end;
    uint next;
    address owner;
    uint price;
  }

  BlockRange[totalSupply+1] tree;
  // minId available in the tree
  uint minId = 1;
  // min block index available in the tree;
  uint lastBlockId = 0;
  // mapping of owner and range index in the tree
  mapping(address => uint256[]) ownerRangeIndex;
  // Mapping from token ID to approved address
  mapping (uint256 => address) tokenApprovals;
  // pending payments
  mapping(address => uint) private payments;
  // mapping owner balance
  mapping(address => uint) private ownerBalance;
  

  // CONSTRUCTOR

  function CryptoColors(uint256 _startTime, uint256 _endTime, address _token, address _wallet) public {
    require(_token != address(0));
    require(_wallet != address(0));
    require(_startTime > 0);
    require(_endTime > now);

    owner = msg.sender;
    
    colorPrice = 0.001 ether;
    supplyPerColor = 4;
    ownerPart = 50;
    walletPart = 50;

    startTime = _startTime;
    endTime = _endTime;
    cap = 98000 ether;
    
    token = MintableToken(_token);
    wallet = _wallet;
    
    // booked for airdrop and rewards
    reserveRange(owner, 167770);
  }

  // fallback function can be used to buy tokens
  function () external payable {
    buy();
  }

  // VIEWS
  
  function myPendingPayment() public view returns (uint) {
    return payments[msg.sender];
  }

  function isGameActivated() public view returns (bool) {
    return totalSupply == totalBoughtColor || now > endTime;
  }

  function isCrowdSaleActive() public view returns (bool) {
    return now < endTime && now >= startTime && weiRaised < cap;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return ownerBalance[_owner];
  }

  function ownerOf(uint256 _tokenId) whenGameActive public view returns (address owner) {
    require(_validToken(_tokenId));
    uint index = lookupIndex(_tokenId);
    return tree[index].owner;
  }

  // return tokens index own by address (including history)
  function tokensIndexOf(address _owner, bool _withHistory) whenGameActive public view returns (uint[] result) {
    require(_owner != address(0));
    if (_withHistory) {
      return ownerRangeIndex[_owner];
    } else {
      uint[] memory indexes = ownerRangeIndex[_owner];
      result = new uint[](indexes.length);
      uint i = 0;
      for (uint index = 0; index < indexes.length; index++) {
        BlockRange storage br = tree[indexes[index]];
        if (br.owner == _owner) {
          result[i] = indexes[index];
          i++;
        }
      }
      return;
    }
  }

  function approvedFor(uint256 _tokenId) whenGameActive public view returns (address) {
    require(_validToken(_tokenId));
    return tokenApprovals[_tokenId];
  }

  /**
  * @dev Gets the range store at the specified index.
  * @param _index The index to query the tree of.
  * @return An Array of value is this order: start, end, owner, next, price.
  */
  function getRange(uint _index) public view returns (uint, uint, address, uint, uint) {
    BlockRange storage range = tree[_index];
    require(range.owner != address(0));
    return (range.start, range.end, range.owner, range.next, range.price);
  }

  function lookupIndex(uint _tokenId) public view returns (uint index) {
    return lookupIndex(_tokenId, 1);
  }

  function lookupIndex(uint _tokenId, uint _start) public view returns (uint index) {
    if (_tokenId > totalSupply || _tokenId > minId) {
      return 0;
    }
    BlockRange storage startBlock = tree[_tokenId];
    if (startBlock.owner != address(0)) {
      return _tokenId;
    }
    index = _start;
    startBlock = tree[index];
    require(startBlock.owner != address(0));
    while (startBlock.end < _tokenId && startBlock.next != 0 ) {
      index = startBlock.next;
      startBlock = tree[index];
    }
    return;
  }

  // PAYABLE

  function buy() public payable whenActive whenNotPaused returns (string thanks) {
    require(msg.sender != address(0));
    require(msg.value.div(colorPrice) > 0);
    uint _nbColors = 0;
    uint value = msg.value;
    if (totalSupply > totalBoughtColor) {
      (_nbColors, value) = buyColors(msg.sender, value);
    }
    if (totalSupply == totalBoughtColor) {
      // require(value >= colorPrice && weiRaised.add(value) <= cap);
      if (weiRaised.add(value) > cap) {
        value = cap.sub(weiRaised);
      }
      _nbColors = _nbColors.add(value.div(colorPrice));
      mintPin(msg.sender, _nbColors);
      if (weiRaised == cap ) {
        endTime = now;
        token.leave();
      }
    }
    forwardFunds(value);
    return "thank you for your participation.";
  }

  function purchase(uint _tokenId) public payable whenGameActive {
    uint _index = lookupIndex(_tokenId);
    return purchaseWithIndex(_tokenId, _index);
  }
  
  function purchaseWithIndex(uint _tokenId, uint _index) public payable whenGameActive isValid(_tokenId, _index) {
    require(msg.sender != address(0));

    BlockRange storage bRange = tree[_index];
    require(bRange.start <= _tokenId && _tokenId <= bRange.end);
    if (bRange.start < bRange.end) {
      // split and update index;
      _index = splitRange(_index, _tokenId, _tokenId);
      bRange = tree[_index];
    }

    uint price = bRange.price;
    address prevOwner = bRange.owner;
    require(msg.value >= price && prevOwner != msg.sender);
    if (prevOwner != address(0)) {
      payments[prevOwner] = payments[prevOwner].add(price);
      ownerBalance[prevOwner]--;
    }
    // add is less expensive than mul
    bRange.price = bRange.price.add(bRange.price);
    bRange.owner = msg.sender;

    // update ownedColors
    ownerRangeIndex[msg.sender].push(_index);
    ownerBalance[msg.sender]++;

    ColorPurchased(prevOwner, msg.sender, _tokenId, price);
    msg.sender.transfer(msg.value.sub(price));
  }

  // PUBLIC

  function updateToken(address _token) onlyOwner public {
    require(_token != address(0));
    token = MintableToken(_token);
  }

  function updateWallet(address _wallet) onlyOwner public {
    require(_wallet != address(0));
    wallet = _wallet;
  }

  function withdrawPayment() public whenGameActive {
    uint refund = payments[msg.sender];
    payments[msg.sender] = 0;
    msg.sender.transfer(refund);
  }

  function transfer(address _to, uint256 _tokenId) public {
    uint _index = lookupIndex(_tokenId);
    return transferWithIndex(_to, _tokenId, _index);
  }
  
  function transferWithIndex(address _to, uint256 _tokenId, uint _index) public isValid(_tokenId, _index) onlyOwnerOf(_index) {
    BlockRange storage bRange = tree[_index];
    if (bRange.start > _tokenId || _tokenId > bRange.end) {
      _index = lookupIndex(_tokenId, _index);
      require(_index > 0);
      bRange = tree[_index];
    }
    if (bRange.start < bRange.end) {
      _index = splitRange(_index, _tokenId, _tokenId);
      bRange = tree[_index];
    }
    require(_to != address(0) && bRange.owner != _to);
    bRange.owner = _to;
    ownerRangeIndex[msg.sender].push(_index);
    Transfer(msg.sender, _to, _tokenId);
    ownerBalance[_to]++;
    ownerBalance[msg.sender]--;
  }

  function approve(address _to, uint256 _tokenId) public {
    uint _index = lookupIndex(_tokenId);
    return approveWithIndex(_to, _tokenId, _index);
  }
  
  function approveWithIndex(address _to, uint256 _tokenId, uint _index) public isValid(_tokenId, _index) onlyOwnerOf(_index) {
    require(_to != address(0));
    BlockRange storage bRange = tree[_index];
    if (bRange.start > _tokenId || _tokenId > bRange.end) {
      _index = lookupIndex(_tokenId, _index);
      require(_index > 0);
      bRange = tree[_index];
    }
    require(_to != bRange.owner);
    if (bRange.start < bRange.end) {
      splitRange(_index, _tokenId, _tokenId);
    }
    tokenApprovals[_tokenId] = _to;
    Approval(msg.sender, _to, _tokenId);
  }

  function takeOwnership(uint256 _tokenId) public {
    uint index = lookupIndex(_tokenId);
    return takeOwnershipWithIndex(_tokenId, index);
  }

  function takeOwnershipWithIndex(uint256 _tokenId, uint _index) public isValid(_tokenId, _index) {
    require(tokenApprovals[_tokenId] == msg.sender);
    BlockRange storage bRange = tree[_index];
    require(bRange.start <= _tokenId && _tokenId <= bRange.end);
    ownerBalance[bRange.owner]--;
    bRange.owner = msg.sender;
    ownerRangeIndex[msg.sender].push(_index); 
    ownerBalance[msg.sender]++;
    Transfer(bRange.owner, msg.sender, _tokenId);
    delete tokenApprovals[_tokenId];
  }


  // INTERNAL
  function forwardFunds(uint256 value) private {
    wallet.transfer(value);
    weiRaised = weiRaised.add(value);
    msg.sender.transfer(msg.value.sub(value));
  }

  function mintPin(address _to, uint _nbColors) private {
    uint _supply = supplyPerColor.mul(_nbColors);
    if (_supply == 0) {
      return;
    }
    uint _ownerPart = _supply.mul(ownerPart)/100;
    token.mint(_to, uint256(_ownerPart.mul(100000000)));
    uint _walletPart = _supply.mul(walletPart)/100;
    token.mint(wallet, uint256(_walletPart.mul(100000000)));
  }

  function buyColors(address _to, uint256 value) private returns (uint _nbColors, uint valueRest) {
    _nbColors = value.div(colorPrice);
    if (bonusStep < 3 && totalBoughtColor.add(_nbColors) > nextBonusStepLimit) {
      uint max = nextBonusStepLimit.sub(totalBoughtColor);
      uint val = max.mul(colorPrice);
      if (max == 0 || val > value) {
        return (0, value);
      }
      valueRest = value.sub(val);
      reserveColors(_to, max);
      uint _c;
      uint _v;
      (_c, _v) = buyColors(_to, valueRest);
      return (_c.add(max), _v.add(val));
    }
    reserveColors(_to, _nbColors);
    return (_nbColors, value);
  }

  function reserveColors(address _to, uint _nbColors) private returns (uint) {
    if (_nbColors > totalSupply - totalBoughtColor) {
      _nbColors = totalSupply - totalBoughtColor;
    }
    if (_nbColors == 0) {
      return;
    }
    reserveRange(_to, _nbColors);
    ColorReserved(_to, _nbColors);
    mintPin(_to, _nbColors);
    checkForSteps();
    return _nbColors;
  }

  function checkForSteps() private {
    if (bonusStep < 3 && totalBoughtColor >= nextBonusStepLimit) {
      if ( bonusStep == 0) {
        colorPrice = colorPrice + colorPrice;
      } else {
        colorPrice = colorPrice + colorPrice - (1 * 0.001 finney);
      }
      bonusStep = bonusStep + 1;
      nextBonusStepLimit = nextBonusStepLimit + (50000 + (bonusStep+1) * 100000);
    }
    if (isGameActivated()) {
      colorPrice = 1 finney;
      ownerPart = 70;
      walletPart = 30;
      endTime = now.add(120 hours);
    }
  }

  function _validIndex(uint _index) internal view returns (bool) {
    return _index > 0 && _index < tree.length;
  }

  function _validToken(uint _tokenId) internal pure returns (bool) {
    return _tokenId > 0 && _tokenId <= totalSupply;
  }

  function reserveRange(address _to, uint _nbTokens) internal {
    require(_nbTokens <= totalSupply);
    BlockRange storage rblock = tree[minId];
    rblock.start = minId;
    rblock.end = minId.add(_nbTokens).sub(1);
    rblock.owner = _to;
    rblock.price = startPrice;
    
    rblock = tree[lastBlockId];
    rblock.next = minId;
    
    lastBlockId = minId;
    ownerRangeIndex[_to].push(minId);
    
    ownerBalance[_to] = ownerBalance[_to].add(_nbTokens);
    minId = minId.add(_nbTokens);
    totalBoughtColor = totalBoughtColor.add(_nbTokens);
  }

  function splitRange(uint index, uint start, uint end) internal returns (uint) {
    require(index > 0);
    require(start <= end);
    BlockRange storage startBlock = tree[index];
    require(startBlock.start < startBlock.end && startBlock.start <= start && startBlock.end >= end);

    BlockRange memory rblockUnique = tree[start];
    rblockUnique.start = start;
    rblockUnique.end = end;
    rblockUnique.owner = startBlock.owner;
    rblockUnique.price = startBlock.price;
    
    uint nextStart = end.add(1);
    if (nextStart <= totalSupply) {
      rblockUnique.next = nextStart;

      BlockRange storage rblockEnd = tree[nextStart];
      rblockEnd.start = nextStart;
      rblockEnd.end = startBlock.end;
      rblockEnd.owner = startBlock.owner;
      rblockEnd.next = startBlock.next;
      rblockEnd.price = startBlock.price;
    }

    if (startBlock.start < start) {
      startBlock.end = start.sub(1);
    } else {
      startBlock.end = start;
    }
    startBlock.next = start;
    tree[start] = rblockUnique;
    // update own color
    if (rblockUnique.next != startBlock.next) {
      ownerRangeIndex[startBlock.owner].push(startBlock.next);
    }
    if (rblockUnique.next != 0) {
      ownerRangeIndex[startBlock.owner].push(rblockUnique.next);
    }
    
    return startBlock.next;
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