pragma solidity ^0.4.11;

contract Ownable {

  address public owner;

  function Ownable() public {
    owner = msg.sender;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    owner = newOwner;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

}

contract LotsData is Ownable {

    struct Property {
        string parcel;
        string street;
        string city;
        string state;
        string zip;
        uint64 creationTime;
    }

    struct Auction {
        address seller;
        uint128 startingPriceWei;
        uint128 endingPriceWei;
        uint64 duration;
        uint64 creationTime;
    }

    struct Escrow {
        address seller;
        address buyer;
        uint128 amount;
    }

    event Transfer(address from, address to, uint256 propertyId);
    event AuctionCreated(uint256 propertyId, uint256 startingPriceWei, uint256 endingPriceWei, uint256 duration);
    event AuctionCompleted(uint256 propertyId, uint256 priceWei, address winner);
    event AuctionCancelled(uint256 propertyId);
        
    Property[] properties;

    mapping (uint256 => address) public propertyIdToOwner;
    mapping (uint256 => Auction) public propertyIdToAuction;
    mapping (uint256 => Escrow) public propertyIdToEscrow;
    
}

contract LotsApis is LotsData {

    function getProperty(uint256 _id) external view returns (string parcel, string street, string city, string state, string zip) {
        Property storage property = properties[_id];
        parcel = property.parcel;
        street = property.street;
        city = property.city;
        state = property.state;
        zip = property.zip;
    }
    
    function registerProperty(string parcel, string street, string city, string state, string zip) external onlyOwner {        
        _registerProperty(parcel, street, city, state, zip);
    } 

    function _registerProperty(string parcel, string street, string city, string state, string zip) internal {        
        Property memory _property = Property({
            parcel: parcel,
            street: street,
            city: city,
            state: state,
            zip: zip,
            creationTime: uint64(now)
        });

        uint256 newPropertyId = properties.push(_property) - 1;
        _transfer(0, msg.sender, newPropertyId);
    }
    
    function transfer(address _to, uint256 _propertyId) external {
        require(_to != address(0));
        require(_to != address(this));
        require(propertyIdToOwner[_propertyId] == msg.sender);
        Auction storage auction = propertyIdToAuction[_propertyId];
        require(auction.creationTime == 0);
        _transfer(msg.sender, _to, _propertyId);
    }

    function ownerOf(uint256 _propertyId) external view returns (address owner) {
        owner = propertyIdToOwner[_propertyId];
        require(owner != address(0));
    }
    
    function createAuction(uint256 _propertyId, uint256 _startingPriceWei, uint256 _endingPriceWei, uint256 _duration) external onlyOwner {
        require(_startingPriceWei > _endingPriceWei);
        require(_startingPriceWei > 0);
        require(_startingPriceWei == uint256(uint128(_startingPriceWei)));
        require(_endingPriceWei == uint256(uint128(_endingPriceWei)));
        require(_duration == uint256(uint64(_duration)));
        require(propertyIdToOwner[_propertyId] == msg.sender);

        Auction memory auction = Auction(
            msg.sender,
            uint128(_startingPriceWei),
            uint128(_endingPriceWei),
            uint64(_duration),
            uint64(now)
        );

        propertyIdToAuction[_propertyId] = auction;

        AuctionCreated(_propertyId, _startingPriceWei, _endingPriceWei, _duration);
    }
    
    function bid(uint256 _propertyId) external payable {
        Auction storage auction = propertyIdToAuction[_propertyId];
        require(auction.startingPriceWei > 0);

        uint256 price = _getAuctionPrice(auction);
        require(msg.value >= price);

        Escrow memory escrow = Escrow({
                seller: auction.seller,
                buyer: msg.sender,
                amount: uint128(price)
        });

        delete propertyIdToAuction[_propertyId];
        propertyIdToEscrow[_propertyId] = escrow;

        msg.sender.transfer(msg.value - price);        
        AuctionCompleted(_propertyId, price, msg.sender);
    }

    function cancelEscrow(uint256 _propertyId) external onlyOwner {
        Escrow storage escrow = propertyIdToEscrow[_propertyId];
        require(escrow.amount > 0);

        escrow.buyer.transfer(escrow.amount);
        delete propertyIdToEscrow[_propertyId];
    }

    function closeEscrow(uint256 _propertyId) external onlyOwner {
        Escrow storage escrow = propertyIdToEscrow[_propertyId];
        require(escrow.amount > 0);

        escrow.seller.transfer(escrow.amount);
         _transfer(escrow.seller, escrow.buyer, _propertyId);
        delete propertyIdToEscrow[_propertyId];
    }

    function cancelAuction(uint256 _propertyId) external {
        Auction storage auction = propertyIdToAuction[_propertyId];
        require(auction.startingPriceWei > 0);

        require(msg.sender == auction.seller);
        delete propertyIdToAuction[_propertyId];
        AuctionCancelled(_propertyId);
    }
    
    function getAuction(uint256 _propertyId) external view returns(address seller, uint256 startingPriceWei, uint256 endingPriceWei, uint256 duration, uint256 startedAt) {
        Auction storage auction = propertyIdToAuction[_propertyId];
        require(auction.startingPriceWei > 0);

        return (auction.seller, auction.startingPriceWei, auction.endingPriceWei, auction.duration, auction.creationTime);
    }

    function getAuctionPrice(uint256 _propertyId) external view returns (uint256) {
        Auction storage auction = propertyIdToAuction[_propertyId];
        require(auction.startingPriceWei > 0);

        return _getAuctionPrice(auction);
    }

    function _transfer(address _from, address _to, uint256 _propertyId) internal {
        propertyIdToOwner[_propertyId] = _to;        
        Transfer(_from, _to, _propertyId);
    }

    function _getAuctionPrice(Auction storage _auction) internal view returns (uint256) {
        uint256 secondsPassed = 0;

        if (now > _auction.creationTime) {
            secondsPassed = now - _auction.creationTime;
        }

        uint256 price = _auction.endingPriceWei;

        if (secondsPassed < _auction.duration) {
            uint256 priceSpread = _auction.startingPriceWei - _auction.endingPriceWei;
            uint256 deltaPrice = priceSpread * secondsPassed / _auction.duration;
            price = _auction.startingPriceWei - deltaPrice;
        }

        return price;
    }
}


contract LotsMain is LotsApis {

    function LotsMain() public payable {
        owner = msg.sender;
    }

    function() external payable {
        require(msg.sender == address(0));
    }
}