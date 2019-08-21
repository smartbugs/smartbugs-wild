pragma solidity ^0.4.18;

contract Owned {
  address owner;

  function Owned() public {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function transferOwner(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

  function getOwner() public view returns (address) {
    return owner;
  }
}

contract HolyPiggyStorage {
  struct Wish {
    bytes name;
    bytes content;
    uint256 time;
    uint256 tribute;
  }
  Wish[] wishes;
  mapping(address => uint256[]) wishesIdx;

  address godAddress;
  address serviceProvider;
  uint256 serviceFeeNumerator;
  uint256 serviceFeeDenominator;
  uint256 minimumWishTribute;
  uint256 accumulatedServiceFee;
}

contract HolyPiggy is HolyPiggyStorage, Owned {
  function() public payable {}

  function HolyPiggy(address god) public {
    godAddress = god;
    serviceFeeNumerator = 1;
    serviceFeeDenominator = 50;
    minimumWishTribute = 0;
  }

  function getGodAddress() external view returns (address) {
    return godAddress;
  }

  event PostWish(address addr, uint256 id, bytes name, bytes content, uint256 time, uint256 tribute);

  function setServiceProvider(address addr) public onlyOwner {
    serviceProvider = addr;
  }

  function getServiceProvider() external view returns (address) {
    return serviceProvider;
  }

  function setServiceFee(uint256 n, uint256 d) public onlyServiceProvider {
    serviceFeeNumerator = n;
    serviceFeeDenominator = d;
  }

  function getAccumulatedServiceFee() external view returns (uint256) {
    return accumulatedServiceFee;
  }

  function getServiceFeeNumerator() external view returns (uint256) {
    return serviceFeeNumerator;
  }

  function getServiceFeeDenominator() external view returns (uint256) {
    return serviceFeeDenominator;
  }

  function getMinimumWishTribute() external view returns (uint256) {
    return minimumWishTribute;
  }

  function setMinimumWishTribute(uint256 tribute) public onlyOwner {
    minimumWishTribute = tribute;
  }

  modifier onlyServiceProvider() {
    require(msg.sender == serviceProvider);
    _;
  }

  function withdrawServiceFee() public onlyServiceProvider {
    uint256 fee = accumulatedServiceFee;
    accumulatedServiceFee = 0;
    serviceProvider.transfer(fee);
  }

  function postWish(bytes name, bytes content) public payable {
    require(msg.value > 0);
    require(serviceProvider != address(0));
    // (1+n/d)t = v  solve for n/d*t, which is the fee
    // t = d/(n+d)*v
    // fee = n/(n+d)*v
    uint256 serviceFee = msg.value * serviceFeeNumerator / (serviceFeeDenominator + serviceFeeNumerator);
    uint256 tribute = msg.value - serviceFee;
    require(tribute > minimumWishTribute);
    assert(accumulatedServiceFee + serviceFee > accumulatedServiceFee);
    
    uint256 id = wishes.length;
    var wish = Wish(name, content, now, tribute);
    wishes.push(wish);
    wishesIdx[msg.sender].push(id);
    accumulatedServiceFee = accumulatedServiceFee + serviceFee;
    godAddress.transfer(tribute);

    PostWish(msg.sender, id, name, content, now, tribute);
  }

  function countWishes() external view returns (uint256) {
    return wishes.length;
  }

  function getWishName(uint256 idx) external view returns (bytes) {
    return wishes[idx].name;
  }

  function getWishContent(uint256 idx) external view returns (bytes) {
    return wishes[idx].content;
  }
  
  function getWishTime(uint256 idx) external view returns (uint256) {
    return wishes[idx].time;
  }

  function getWishTribute(uint256 idx) external view returns (uint256) {
    return wishes[idx].tribute;
  }

  function getWishIdxesAt(address addr) external view returns (uint256[]) {
    return wishesIdx[addr];
  }

  function getWishIdxAt(address addr, uint256 pos) external view returns (uint256) {
    return wishesIdx[addr][pos];
  }

  function countWishesAt(address addr) external view returns (uint256) {
    return wishesIdx[addr].length;
  }
}