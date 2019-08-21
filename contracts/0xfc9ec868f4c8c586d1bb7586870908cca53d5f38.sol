pragma solidity ^0.4.8;

/**
 * @title KittyItemToken interface 
 */
contract KittyItemToken {
  function transfer(address, uint256) public pure returns (bool) {}
  function transferAndApply(address, uint256) public pure returns (bool) {}
  function balanceOf(address) public pure returns (uint256) {}
}

/**
 * @title KittyItemMarket is a market contract for buying KittyItemTokens and 
 */
contract KittyItemMarket {

  struct Item {
    address itemContract;
    uint256 cost;  // in wei
    address artist;
    uint128 split;  // the percentage split the artist gets vs. KittyItemMarket.owner. A split of "6666" would mean the artist gets 66.66% of the funds
    uint256 totalFunds;
  }

  address public owner;
  mapping (string => Item) items;
  bool public paused = false;

  // events
  event Buy(string itemName);

  /**
   * KittyItemMarket constructor
   */
  function KittyItemMarket() public {
    owner = msg.sender;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public {
    require(msg.sender == owner);
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

  /**
   * @dev Pauses the market, not allowing any buyItem and buyItemAndApply
   * @param _paused the paused state of the contract
   */
  function setPaused(bool _paused) public {
    require(msg.sender == owner);
    paused = _paused;
  }

  /**
   * @dev You cannot return structs, return each attribute in Item struct
   * @param _itemName the KittyItemToken name in items
   */
  function getItem(string _itemName) view public returns (address, uint256, address, uint256, uint256) {
    return (items[_itemName].itemContract, items[_itemName].cost, items[_itemName].artist, items[_itemName].split, items[_itemName].totalFunds);
  }

  /**
   * @dev Add a KittyItemToken contract to be sold in the market
   * @param _itemName Name for items mapping
   * @param _itemContract contract address of KittyItemToken we're adding
   * @param _cost  cost of item in wei
   * @param _artist  artist addess to send funds to
   * @param _split  artist split. "6666" would be a 66.66% split.
   */
  function addItem(string _itemName, address _itemContract, uint256 _cost, address _artist, uint128 _split) public {
    require(msg.sender == owner);
    require(items[_itemName].itemContract == 0x0);  // item can't already exist
    items[_itemName] = Item(_itemContract, _cost, _artist, _split, 0);
  }

  /**
   * @dev Modify an item that is in the market
   * @param _itemName Name of item to modify
   * @param _itemContract modify KittyItemtoken contract address for item
   * @param _cost modify cost of item
   * @param _artist  modify artist addess to send funds to
   * @param _split  modify artist split
   */
  function modifyItem(string _itemName, address _itemContract, uint256 _cost, address _artist, uint128 _split) public {
    require(msg.sender == owner);
    require(items[_itemName].itemContract != 0x0);  // item should already exist
    Item storage item = items[_itemName];
    item.itemContract = _itemContract;
    item.cost = _cost;
    item.artist = _artist;
    item.split = _split;
  }

  /**
   * @dev Buy item from the market
   * @param _itemName Name of item to buy
   * @param _amount amount of item to buy
   */
  function buyItem(string _itemName, uint256 _amount) public payable {
    require(paused == false);
    require(items[_itemName].itemContract != 0x0);  // item should already exist
    Item storage item = items[_itemName];  // we're going to modify the item in storage
    require(msg.value >= item.cost * _amount);  // make sure user sent enough eth for the number of items they want
    item.totalFunds += msg.value;
    KittyItemToken kit = KittyItemToken(item.itemContract);
    kit.transfer(msg.sender, _amount);
    // emit events
    Buy(_itemName);
  }

  /**
   * @dev Buy item from the market and apply to kittyId
   * @param _itemName Name of item to buy
   * @param _kittyId  KittyId to apply the item
   */
  function buyItemAndApply(string _itemName, uint256 _kittyId) public payable {
    require(paused == false);
    // NOTE - can only be used to buy and apply 1 item
    require(items[_itemName].itemContract != 0x0);  // item should already exist
    Item storage item = items[_itemName];  // we're going to modify the item in storage
    require(msg.value >= item.cost);  // make sure user sent enough eth for 1 item
    item.totalFunds += msg.value;
    KittyItemToken kit = KittyItemToken(item.itemContract);
    kit.transferAndApply(msg.sender, _kittyId);
    // emit events
    Buy(_itemName);
  }

  /**
   * @dev split funds from Item sales between contract owner and artist
   * @param _itemName Item to split funds for
   */
  function splitFunds(string _itemName) public {
    require(msg.sender == owner);
    Item storage item = items[_itemName];  // we're going to modify the item in storage
    uint256 amountToArtist = item.totalFunds * item.split / 10000;
    uint256 amountToOwner = item.totalFunds - amountToArtist;
    item.artist.transfer(amountToArtist);
    owner.transfer(amountToOwner);
    item.totalFunds = 0;
  }

  /**
   * @dev return all _itemName tokens help by contract to contract owner
   * @param _itemName Item to return tokens to contract owner
   * @return whether the transfer was successful or not
   */
  function returnTokensToOwner(string _itemName) public returns (bool) {
    require(msg.sender == owner);
    Item storage item = items[_itemName];  // we're going to modify the item in storage
    KittyItemToken kit = KittyItemToken(item.itemContract);
    uint256 contractBalance = kit.balanceOf(this);
    kit.transfer(msg.sender, contractBalance);
    return true;
  }

}