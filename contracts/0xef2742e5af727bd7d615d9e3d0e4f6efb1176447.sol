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

contract DnaMixer {
    function mixDna(uint256 dna1, uint256 dna2, uint256 seed) public pure returns (uint256);
}


contract CpData is Ownable {

    struct Girl {
        uint256 dna;
        uint64 creationTime;
        uint32 sourceGirl1;
        uint32 sourceGirl2;
        uint16 gen;
        uint8 combinesLeft;
        uint64 combineCooledDown;
    }

    struct Auction {
        address seller;
        uint128 startingPriceWei;
        uint128 endingPriceWei;
        uint64 duration;
        uint64 creationTime;
        bool isCombine;
    }

    event NewGirl(address owner, uint256 girlId, uint256 sourceGirl1, uint256 sourceGirl2, uint256 dna);
    event Transfer(address from, address to, uint256 girlId);
    event AuctionCreated(uint256 girlId, uint256 startingPriceWei, uint256 endingPriceWei, uint256 duration, bool isCombine);
    event AuctionCompleted(uint256 girlId, uint256 priceWei, address winner);
    event AuctionCancelled(uint256 girlId);

    uint256 public constant OWNERS_AUCTION_CUT = 350;

    uint256 public constant MAX_PROMO_GIRLS = 6000;
    uint256 public promoCreatedCount;
    
    uint256 public constant MAX_GEN0_GIRLS = 30000;
    uint256 public gen0CreatedCount;
        
    DnaMixer public dnaMixer;

    Girl[] girls;

    mapping (uint256 => address) public girlIdToOwner;
    mapping (uint256 => Auction) public girlIdToAuction;
    
}


contract CpInternals is CpData {

    function _transfer(address _from, address _to, uint256 _girlId) internal {
        girlIdToOwner[_girlId] = _to;        
        Transfer(_from, _to, _girlId);
    }

    function _createGirl(uint256 _sourceGirlId1, uint256 _sourceGirlId2, uint256 _gen, uint256 _dna, address _owner) internal returns (uint) {
        require(_sourceGirlId1 < girls.length || _sourceGirlId1 == 0);
        require(_sourceGirlId2 < girls.length || _sourceGirlId2 == 0);
        require(_gen < 65535);

        Girl memory _girl = Girl({
            dna: _dna,
            sourceGirl1: uint32(_sourceGirlId1),
            sourceGirl2: uint32(_sourceGirlId2),
            gen: uint16(_gen),
            creationTime: uint64(now),
            combinesLeft: 10,
            combineCooledDown: 0
        });

        uint256 newGirlId = girls.push(_girl) - 1;
        NewGirl(_owner, newGirlId, _sourceGirlId1, _sourceGirlId2, _girl.dna);
        _transfer(0, _owner, newGirlId);

        return newGirlId;
    }

     function _combineGirls(Girl storage _sourceGirl1, Girl storage _sourceGirl2, uint256 _girl1Id, uint256 _girl2Id, address _owner) internal returns(uint256) {
        uint16 maxGen = _sourceGirl1.gen;

        if (_sourceGirl2.gen > _sourceGirl1.gen) {
            maxGen = _sourceGirl2.gen;
        }

        uint256 seed = block.number + maxGen + block.timestamp;
        uint256 newDna = dnaMixer.mixDna(_sourceGirl1.dna, _sourceGirl2.dna, seed);

        _sourceGirl1.combinesLeft -= 1;
        _sourceGirl2.combinesLeft -= 1;
        _sourceGirl1.combineCooledDown = uint64(now) + 6 hours;
        _sourceGirl2.combineCooledDown = uint64(now) + 6 hours;

        return _createGirl(_girl1Id, _girl2Id, maxGen + 1, newDna, _owner);
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


contract CpApis is CpInternals {

    function getGirl(uint256 _id) external view returns (uint256 dna, uint256 sourceGirlId1, uint256 sourceGirlId2, uint256 gen, uint256 creationTime, uint8 combinesLeft, uint64 combineCooledDown) {
        Girl storage girl = girls[_id];
        dna = girl.dna;
        sourceGirlId1 = girl.sourceGirl1;
        sourceGirlId2 = girl.sourceGirl2;
        gen = girl.gen;
        creationTime = girl.creationTime;
        combinesLeft = girl.combinesLeft;
        combineCooledDown = girl.combineCooledDown;
    }

    function createPromoGirl(uint256 _dna) external onlyOwner {
        require(promoCreatedCount < MAX_PROMO_GIRLS);

        promoCreatedCount++;
        _createGirl(0, 0, 0, _dna, owner);
    }

    function createGen0(uint256 _dna) external onlyOwner {
        require(gen0CreatedCount < MAX_GEN0_GIRLS);

        gen0CreatedCount++;
        _createGirl(0, 0, 0, _dna, owner);
    }

    function setDnaMixerAddress(address _address) external onlyOwner {
        dnaMixer = DnaMixer(_address);
    }
    
    function transfer(address _to, uint256 _girlId) external {
        require(_to != address(0));
        require(_to != address(this));
        require(girlIdToOwner[_girlId] == msg.sender);
        Auction storage auction = girlIdToAuction[_girlId];
        require(auction.creationTime == 0);
        _transfer(msg.sender, _to, _girlId);
    }

    function ownerOf(uint256 _girlId) external view returns (address owner) {
        owner = girlIdToOwner[_girlId];
        require(owner != address(0));
    }
    
    function createAuction(uint256 _girlId, uint256 _startingPriceWei, uint256 _endingPriceWei, uint256 _duration, bool _isCombine) external {
        require(_startingPriceWei > _endingPriceWei);
        require(_startingPriceWei > 0);
        require(_startingPriceWei == uint256(uint128(_startingPriceWei)));
        require(_endingPriceWei == uint256(uint128(_endingPriceWei)));
        require(_duration == uint256(uint64(_duration)));
        require(girlIdToOwner[_girlId] == msg.sender);

        if (_isCombine) {
            Girl storage girl = girls[_girlId];
            require(girl.combinesLeft > 0);
            require(girl.combineCooledDown < now);
        }

        Auction memory auction = Auction(
            msg.sender,
            uint128(_startingPriceWei),
            uint128(_endingPriceWei),
            uint64(_duration),
            uint64(now),
            _isCombine
        );

        girlIdToAuction[_girlId] = auction;

        AuctionCreated(_girlId, _startingPriceWei, _endingPriceWei, _duration, _isCombine);
    }
    
    function bid(uint256 _girlId, uint256 _myGirl) external payable {
        Auction storage auction = girlIdToAuction[_girlId];

        require(auction.startingPriceWei > 0);
        require(!auction.isCombine || (auction.isCombine && _girlId > 0));

        uint256 price = _getAuctionPrice(auction);
        require(msg.value >= price);
        bool isCombine = auction.isCombine;

        if (isCombine) {
            Girl storage sourceGirl1 = girls[_girlId];
            Girl storage sourceGirl2 = girls[_myGirl];
    
            require(sourceGirl1.combinesLeft > 0);
            require(sourceGirl2.combinesLeft > 0);
            require(sourceGirl1.combineCooledDown < now);
            require(sourceGirl2.combineCooledDown < now);
        }

        address seller = auction.seller;
        delete girlIdToAuction[_girlId];

        if (price > 0) {
            uint256 cut = price * (OWNERS_AUCTION_CUT / 10000);
            seller.transfer(price - cut);
        }

        msg.sender.transfer(msg.value - price);

        if (isCombine) {
            _combineGirls(sourceGirl1, sourceGirl2, _girlId, _myGirl, msg.sender);
        } else {
            _transfer(seller, msg.sender, _girlId);
        }

        AuctionCompleted(_girlId, price, msg.sender);
    }

    function combineMyGirls(uint256 _girlId1, uint256 _girlId2) external payable {
        require(_girlId1 != _girlId2);
        require(girlIdToOwner[_girlId1] == msg.sender);
        require(girlIdToOwner[_girlId2] == msg.sender);
                        
        Girl storage sourceGirl1 = girls[_girlId1];
        Girl storage sourceGirl2 = girls[_girlId2];

        require(sourceGirl1.combinesLeft > 0);
        require(sourceGirl2.combinesLeft > 0);
        require(sourceGirl1.combineCooledDown < now);
        require(sourceGirl2.combineCooledDown < now);

        _combineGirls(sourceGirl1, sourceGirl2, _girlId1, _girlId2, msg.sender);
    }

    function cancelAuction(uint256 _girlId) external {
        Auction storage auction = girlIdToAuction[_girlId];
        require(auction.startingPriceWei > 0);

        require(msg.sender == auction.seller);
        delete girlIdToAuction[_girlId];
        AuctionCancelled(_girlId);
    }
    
    function getAuction(uint256 _girlId) external view returns(address seller, uint256 startingPriceWei, uint256 endingPriceWei, uint256 duration, uint256 startedAt, bool isCombine) {
        Auction storage auction = girlIdToAuction[_girlId];
        require(auction.startingPriceWei > 0);

        return (auction.seller, auction.startingPriceWei, auction.endingPriceWei, auction.duration, auction.creationTime, auction.isCombine);
    }

    function getGirlsAuctionPrice(uint256 _girlId) external view returns (uint256) {
        Auction storage auction = girlIdToAuction[_girlId];
        require(auction.startingPriceWei > 0);

        return _getAuctionPrice(auction);
    }

    function withdrawBalance() external onlyOwner {
        owner.transfer(this.balance);
    }
}


contract CryptoPussyMain is CpApis {

    function CryptoPussyMain() public payable {
        owner = msg.sender;
        _createGirl(0, 0, 0, uint256(-1), owner);
    }

    function() external payable {
        require(msg.sender == address(0));
    }
}