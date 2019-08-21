pragma solidity ^0.4.19;

contract Crypland {

  struct Element {uint worth; uint level; uint cooldown;}
  struct Offer {uint startPrice; uint endPrice; uint startBlock; uint endBlock; bool isOffer;}

  bool public paused;
  address public owner;

  Element[][25][4] public elements;
  mapping (uint => mapping (uint => mapping (uint => address))) public addresses;
  mapping (uint => mapping (uint => mapping (uint => Offer))) public offers;

  event ElementBought(uint indexed group, uint indexed asset, uint indexed unit, address user, uint price, uint level, uint worth);
  event ElementUpgraded(uint indexed group, uint indexed asset, uint indexed unit, address user, uint price, uint level, uint worth);
  event ElementTransferred(uint indexed group, uint indexed asset, uint indexed unit, address user, uint price, uint level, uint worth);

  event UserUpgraded(address indexed user, uint group, uint asset, uint unit, uint price);
  event UserSold(address indexed user, uint group, uint asset, uint unit, uint price);
  event UserBought(address indexed user, uint group, uint asset, uint unit, uint price);

  function Crypland() public {
    owner = msg.sender;
    paused = false;
  }

  modifier whenOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  modifier whenElementHolder(uint group, uint asset, uint unit) {
    require(group >= 0 && group < 4);
    require(asset >= 0 && asset < 25);
    require(unit >= 0 && unit < elements[group][asset].length);
    require(addresses[group][asset][unit] == msg.sender);
    _;
  }

  modifier whenNotElementHolder(uint group, uint asset, uint unit) {
    require(group >= 0 && group < 4);
    require(asset >= 0 && asset < 25);
    require(unit >= 0 && unit < elements[group][asset].length);
    require(addresses[group][asset][unit] != msg.sender);
    _;
  }

  function ownerPause() external whenOwner whenNotPaused {
    paused = true;
  }

  function ownerUnpause() external whenOwner whenPaused {
    paused = false;
  }

  function ownerWithdraw(uint amount) external whenOwner {
    owner.transfer(amount);
  }

  function ownerDestroy() external whenOwner {
    selfdestruct(owner);
  }

  function publicGetAsset(uint group, uint asset) view public returns (uint, uint, uint, uint, uint) {
    return (
      calcAssetWorthIndex(asset),
      calcAssetBuyPrice(asset),
      calcAssetUpgradePrice(asset),
      calcAssetMax(asset),
      calcAssetAssigned(group, asset)
    );
  }

  function publicGetElement(uint group, uint asset, uint unit) view public returns (address, uint, uint, uint, uint, bool) {
    return (
      addresses[group][asset][unit],
      elements[group][asset][unit].level,
      calcElementWorth(group, asset, unit),
      calcElementCooldown(group, asset, unit),
      calcElementCurrentPrice(group, asset, unit),
      offers[group][asset][unit].isOffer
    );
  }

  function publicGetElementOffer(uint group, uint asset, uint unit) view public returns (uint, uint, uint, uint, uint) {
    return (
      offers[group][asset][unit].startPrice,
      offers[group][asset][unit].endPrice,
      offers[group][asset][unit].startBlock,
      offers[group][asset][unit].endBlock,
      block.number
    );
  }

  function userAssignElement(uint group, uint asset, address ref) public payable whenNotPaused {
    uint price = calcAssetBuyPrice(asset);

    require(group >= 0 && group < 4);
    require(asset >= 0 && asset < 23);
    require(calcAssetAssigned(group, asset) < calcAssetMax(asset));
    require(msg.value >= price);

    if (ref == address(0) || ref == msg.sender) {
      ref = owner;
    }

    uint paidWorth = uint(block.blockhash(block.number - asset)) % 100 + 1;
    Element memory paidElement = Element(paidWorth, 1, 0);
    uint paidUnit = elements[group][asset].push(paidElement) - 1;
    addresses[group][asset][paidUnit] = msg.sender;

    uint freeWorth = uint(block.blockhash(block.number - paidWorth)) % 100 + 1;
    Element memory freeElement = Element(freeWorth, 1, 0);
    uint freeUnit = elements[group][23].push(freeElement) - 1;
    addresses[group][23][freeUnit] = msg.sender;

    uint refWorth = uint(block.blockhash(block.number - freeWorth)) % 100 + 1;
    Element memory refElement = Element(refWorth, 1, 0);
    uint refUnit = elements[group][24].push(refElement) - 1;
    addresses[group][24][refUnit] = ref;

    ElementBought(group, asset, paidUnit, msg.sender, price, 1, paidWorth);
    ElementBought(group, 23, freeUnit, msg.sender, 0, 1, freeWorth);
    ElementBought(group, 24, refUnit, ref, 0, 1, refWorth);
    UserBought(msg.sender, group, asset, paidUnit, price);
    UserBought(msg.sender, group, 23, freeUnit, 0);
    UserBought(ref, group, 24, refUnit, 0);
  }

  function userUpgradeElement(uint group, uint asset, uint unit) public payable whenNotPaused whenElementHolder(group, asset, unit) {
    uint price = calcAssetUpgradePrice(asset);

    require(elements[group][asset][unit].cooldown < block.number);
    require(msg.value >= price);

    elements[group][asset][unit].level = elements[group][asset][unit].level + 1;
    elements[group][asset][unit].cooldown = block.number + ((elements[group][asset][unit].level - 1) * 120);
    
    ElementUpgraded(group, asset, unit, msg.sender, price, elements[group][asset][unit].level, calcElementWorth(group, asset, unit));
    UserUpgraded(msg.sender, group, asset, unit, price);
  }

  function userOfferSubmitElement(uint group, uint asset, uint unit, uint startPrice, uint endPrice, uint duration) public whenNotPaused whenElementHolder(group, asset, unit) {
    require(!offers[group][asset][unit].isOffer); 
    require(startPrice > 0 && endPrice > 0 && duration > 0 && startPrice >= endPrice);

    offers[group][asset][unit].isOffer = true;
    offers[group][asset][unit].startPrice = startPrice;
    offers[group][asset][unit].endPrice = endPrice;
    offers[group][asset][unit].startBlock = block.number;
    offers[group][asset][unit].endBlock = block.number + duration;
  }

  function userOfferCancelElement(uint group, uint asset, uint unit) public whenNotPaused whenElementHolder(group, asset, unit) {
    require(offers[group][asset][unit].isOffer);
    offers[group][asset][unit].isOffer = false;
    offers[group][asset][unit].startPrice = 0;
    offers[group][asset][unit].endPrice = 0;
    offers[group][asset][unit].startBlock = 0;
    offers[group][asset][unit].endBlock = 0;
  }

  function userOfferAcceptElement(uint group, uint asset, uint unit) public payable whenNotPaused whenNotElementHolder(group, asset, unit) {
    uint price = calcElementCurrentPrice(group, asset, unit);

    require(offers[group][asset][unit].isOffer);
    require(msg.value >= price);

    address seller = addresses[group][asset][unit];

    addresses[group][asset][unit] = msg.sender;
    offers[group][asset][unit].isOffer = false;

    seller.transfer(price * 97 / 100);
    msg.sender.transfer(msg.value - price);

    ElementTransferred(group, asset, unit, msg.sender, price, elements[group][asset][unit].level, calcElementWorth(group, asset, unit));
    UserBought(msg.sender, group, asset, unit, price);
    UserSold(seller, group, asset, unit, price);
  }

  function calcAssetWorthIndex(uint asset) pure internal returns (uint) {
    return asset < 23 ? (24 - asset) : 1;
  }

  function calcAssetBuyPrice(uint asset) pure internal returns (uint) {
    return asset < 23 ? ((24 - asset) * (25 - asset) * 10**15 / 2) : 0;
  }

  function calcAssetUpgradePrice(uint asset) pure internal returns (uint) {
    return calcAssetWorthIndex(asset) * 10**15;
  }

  function calcAssetMax(uint asset) pure internal returns (uint) {
    return asset < 23 ? ((asset + 1) * (asset + 2) / 2) : 2300;
  }

  function calcAssetAssigned(uint group, uint asset) view internal returns (uint) {
    return elements[group][asset].length;
  }

  function calcElementWorth(uint group, uint asset, uint unit) view internal returns (uint) {
    return elements[group][asset][unit].worth + ((elements[group][asset][unit].level - 1) * calcAssetWorthIndex(asset));
  }

  function calcElementCooldown(uint group, uint asset, uint unit) view internal returns (uint) {
    return elements[group][asset][unit].cooldown > block.number ? elements[group][asset][unit].cooldown - block.number : 0;
  }

  function calcElementCurrentPrice(uint group, uint asset, uint unit) view internal returns (uint) {
    uint price = 0;
    if (offers[group][asset][unit].isOffer) {
      if (block.number >= offers[group][asset][unit].endBlock) {
        price = offers[group][asset][unit].endPrice;
      } else if (block.number <= offers[group][asset][unit].startBlock) {
        price = offers[group][asset][unit].startPrice;
      } else if (offers[group][asset][unit].endPrice == offers[group][asset][unit].startPrice) {
        price = offers[group][asset][unit].endPrice;
      } else {
        uint currentBlockChange = block.number - offers[group][asset][unit].startBlock;
        uint totalBlockChange = offers[group][asset][unit].endBlock - offers[group][asset][unit].startBlock;
        uint totalPriceChange = offers[group][asset][unit].startPrice - offers[group][asset][unit].endPrice;
        uint currentPriceChange = currentBlockChange * totalPriceChange / totalBlockChange;
        price = offers[group][asset][unit].startPrice - currentPriceChange;
      }
    }

    return price;
  }
}