pragma solidity ^0.4.23;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  // state variables
  address owner;

  // modifiers
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // constructor
  function Ownable() public {
    owner = msg.sender;
  }

  /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
  function transferOwnership(address newOwner) onlyOwner {
    owner = newOwner;
  }

}

contract Transaction is Ownable {
  // custom types
  struct TransactionNeoPlace {
    uint id;
    address seller;
    address buyer;
    bytes16 itemId;
    bytes8 typeItem;
    string location;
    string pictureHash;
    bytes16 receiptHash;
    string comment;
    bytes8 status;
    uint256 _price;
  }

  // state variables
  mapping(uint => TransactionNeoPlace) public transactions;
  mapping(bytes16 => uint256) public fundsLocked;

  uint transactionCounter;

  // events
  event BuyItem(
    uint indexed _id,
    bytes16 indexed _itemId,
    address _seller,
    address _buyer,
    uint256 _price
  );

  function kill() public onlyOwner {
    selfdestruct(owner);
  }

  // fetch the number of transactions in the contract
  function getNumberOfTransactions() public view returns (uint) {
    return transactionCounter;
  }

  // fetch and return all sales of the seller
  function getSales() public view returns (uint[]) {
    // prepare output array
    uint[] memory transactionIds = new uint[](transactionCounter);

    uint numberOfSales = 0;

    // iterate over transactions
    for(uint i = 1; i <= transactionCounter; i++) {
      // keep the ID if the transaction owns to the seller
      if(transactions[i].seller == msg.sender) {
        transactionIds[numberOfSales] = transactions[i].id;
        numberOfSales++;
      }
    }

    // copy the transactionIds array into a smaller getSales array
    uint[] memory sales = new uint[](numberOfSales);
    for(uint j = 0; j < numberOfSales; j++) {
      sales[j] = transactionIds[j];
    }
    return sales;
  }

  // fetch and return all purchases of the buyer
  function getPurchases() public view returns (uint[]) {
    // prepare output array
    uint[] memory transactionIds = new uint[](transactionCounter);

    uint numberOfBuy = 0;

    // iterate over transactions
    for(uint i = 1; i <= transactionCounter; i++) {
      // keep the ID if the transaction owns to the seller
      if(transactions[i].buyer == msg.sender) {
        transactionIds[numberOfBuy] = transactions[i].id;
        numberOfBuy++;
      }
    }

    // copy the transactionIds array into a smaller getBuy array
    uint[] memory buy = new uint[](numberOfBuy);
    for(uint j = 0; j < numberOfBuy; j++) {
      buy[j] = transactionIds[j];
    }
    return buy;
  }

  // new transaction / buy item
  function buyItem(address _seller, bytes16 _itemId, bytes8 _typeItem, string _location, string _pictureHash, string _comment, bytes8 _status, uint256 _price) payable public {
    // address not null
    require(_seller != 0x0);
    // seller don't allow to buy his own item
    require(msg.sender != _seller);

    require(_itemId.length > 0);
    require(_typeItem.length > 0);
    require(bytes(_location).length > 0);
    require(bytes(_pictureHash).length > 0);
    //require(bytes(_comment).length > 0);

    require(msg.value == _price);


    // lock and put the funds in escrow
    //_seller.transfer(msg.value);
    fundsLocked[_itemId]=fundsLocked[_itemId] + _price;

    // new transaction
    transactionCounter++;

    // store the new transaction
    transactions[transactionCounter] = TransactionNeoPlace(
      transactionCounter,
      _seller,
      msg.sender,
      _itemId,
      _typeItem,
      _location,
      _pictureHash,
      "",
      _comment,
      _status,
      _price
    );

    // trigger the new transaction
    BuyItem(transactionCounter, _itemId, _seller, msg.sender, _price);
  }

  // send additional funds
  //TODO merge with unlockFunds
  function sendAdditionalFunds(address _seller, bytes16 _itemId, uint256 _price) payable public {
    // address not null
    require(_seller != 0x0);
    // seller don't allow to buy his own item
    require(msg.sender != _seller);

    require(_itemId.length > 0);

    require(msg.value == _price);

    for(uint i = 0; i <= transactionCounter; i++) {
      if(transactions[i].itemId == _itemId) {

        require(msg.sender == transactions[i].buyer);
        require(stringToBytes8("paid") == transactions[i].status);
        address seller = transactions[i].seller;
        transactions[i]._price = transactions[i]._price + msg.value;

        //transfer fund from client to vendor
        seller.transfer(msg.value);

        break;
      }
    }
  }

  function unlockFunds(bytes16 _itemId) public {

    for(uint i = 0; i <= transactionCounter; i++) {
      if(transactions[i].itemId == _itemId) {

        require(msg.sender == transactions[i].buyer);
        require(stringToBytes8("paid") != transactions[i].status);
        address buyer = transactions[i].buyer;
        address seller = transactions[i].seller;
        uint256 priceTransaction = transactions[i]._price;

        require(fundsLocked[_itemId]>0);
        fundsLocked[_itemId]=fundsLocked[_itemId] - (priceTransaction);

        //transfer fund from client to vendor
        seller.transfer(priceTransaction);

        transactions[i].status = stringToBytes8('paid');

        break;
      }
    }
  }

   function sendAmount(address seller) payable public {
      // address not null
      require(seller != 0x0);
      // seller don't allow to buy his own item
      require(msg.sender != seller);

      seller.transfer(msg.value);
   }

  function stringToBytes8(string memory source) returns (bytes8 result) {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly {
      result := mload(add(source, 8))
    }
  }

}