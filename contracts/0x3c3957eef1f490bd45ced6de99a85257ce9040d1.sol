pragma solidity ^0.4.17;

contract PreSale {
    
    event Pause();
    event Unpause();

    address public adminAddress;

    bool public paused = false;
    
    modifier onlyAdmin() {
        require(msg.sender == adminAddress);
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
    
    function pause() public onlyAdmin whenNotPaused returns(bool) {
        paused = true;
        Pause();
        return true;
    }

    function unpause() public onlyAdmin whenPaused returns(bool) {
        paused = false;
        Unpause();
        return true;
    }
    
    function PreSale() public {
        paused = true;
        adminAddress = msg.sender;
    }
    
    function withdrawBalance() external onlyAdmin {
        adminAddress.transfer(this.balance);
    }
    
    function _random(uint _lower, uint _range, uint _jump) internal view returns (uint) {
        uint number = uint(block.blockhash(block.number - _jump)) % _range;
        if (number < _lower) {
            number = _lower;
        }
        return number;
    }
    
    event preSaleCreated(uint saleId, uint heroId, uint price);
    event preSaleSuccess(address buyer, uint saleId, uint heroId, uint price);
    event autoPreSaleSuccess(address buyer, uint heroId);
    event priceChanged(uint saleId, uint newPrice);
    event auctionCreated(uint auctionId, uint heroId, uint startPrice);
    event bidSuccess(uint auctionId, address bidder, uint bidAmount);
    event drawItemLottery(address player, uint numOfItem);
    event drawHeroLottery(address player, bool win);

    
    struct Sale {
        uint heroId;
        uint price;
        bool ifSold;
    }
    
    struct Auction {
        uint heroId;
        uint currentPrice;
        address bidder;
    }
    
    Sale[] sales;
    Auction[] auctions;
    
    uint public oneEth = 1 ether;
    
    mapping (uint => address) public heroIdToBuyer;
    mapping (address => uint) public BuyerLotteryTimes;
    mapping (address => uint) public playerWinItems;
    mapping (address => uint) public playerWinHeroes;
    
    function createPreSale(
        uint _heroId,
        uint _price
    ) 
        public 
        onlyAdmin 
        returns (uint)
    {
        Sale memory _sale = Sale({
            heroId: _heroId,
            price: _price,
            ifSold: false
        });
        
        uint newSaleId = sales.push(_sale) - 1;
        
        preSaleCreated(newSaleId, _heroId, _price);
        
        return newSaleId;
    }
    
    function multiCreate(uint _startId, uint _amount, uint _price) public onlyAdmin {
        for (uint i; i < _amount; i++) {
            createPreSale(_startId + i, _price);
        }
    }
    
    function changePrice(uint _saleId, uint _price) public onlyAdmin {
        Sale storage sale = sales[_saleId];
        require(sale.ifSold == false);
        sale.price = _price;
        priceChanged(_saleId, _price);
    }
    
    function totalSales() public view returns (uint) {
        return sales.length;
    }
    
    function buyPreSale(uint _saleId) 
        public
        payable
        whenNotPaused
    {
        Sale storage _sale = sales[_saleId];
        
        require(_sale.ifSold == false);
        uint _heroId = _sale.heroId;
        uint _price = _sale.price;
        require(msg.value >= _price);
        require(heroIdToBuyer[_heroId] == address(0));
        
        heroIdToBuyer[_heroId] = msg.sender;
        _sale.ifSold = true;
        uint lotteryTime = _price/oneEth + 1;
        BuyerLotteryTimes[msg.sender] += lotteryTime;
        
        preSaleSuccess(msg.sender, _saleId, _heroId, _price);
        
    }
    uint public standFeeBefore500 = 800 finney;
    uint public standFeeAfter500 = 500 finney;
    function setAutoBuyFee(uint _fee, uint _pick) public onlyAdmin returns (uint) {
        require(_pick == 0 || _pick == 1);
        if (_pick == 0) {
            standFeeBefore500 = _fee;
            return standFeeBefore500;
        } else if (_pick == 1) {
            standFeeAfter500 = _fee;
            return standFeeAfter500;
        }
    }
    
    
    function autoBuy(uint _heroId) public payable whenNotPaused{
        require(heroIdToBuyer[_heroId] == address(0));
        require(_heroId >= 101 && _heroId <= 998);
        require(_heroId != 200 && _heroId != 300 && _heroId != 400 && _heroId != 500 && _heroId != 600 && _heroId != 700 && _heroId != 800 && _heroId != 900);
        require(_heroId != 111 && _heroId != 222 && _heroId != 333 && _heroId != 444 && _heroId != 555 && _heroId != 666 && _heroId != 777 && _heroId != 888 && _heroId != 999);
        
        if (_heroId < 500) {
            require(msg.value >= standFeeBefore500);
            heroIdToBuyer[_heroId] = msg.sender;
        } else {
            require(msg.value >= standFeeAfter500);
            heroIdToBuyer[_heroId] = msg.sender;
        }
        
        BuyerLotteryTimes[msg.sender] ++;
        autoPreSaleSuccess(msg.sender, _heroId);
    }
    
    function getPreSale(uint _saleId) public view returns(
        uint heroId,
        uint price,
        address buyer
    ) {
        Sale memory sale = sales[_saleId];
        
        heroId = sale.heroId;
        price = sale.price;
        buyer = heroIdToBuyer[heroId];
    }
    
    function createAuction(uint _heroId, uint _startPrice) public onlyAdmin returns (uint) {
        Auction memory auction = Auction({
            heroId: _heroId,
            currentPrice: _startPrice,
            bidder: address(0)
        });
        uint newAuctionId = auctions.push(auction) - 1;
        
        auctionCreated(newAuctionId, _heroId, _startPrice);
        
        return newAuctionId;
    }
    
    uint public transferFee = 10 finney;
    
    function setTransferFee(uint _fee) public onlyAdmin {
        transferFee = _fee;
    }
    
    function bidAuction(uint _auctionId) public payable whenNotPaused{
        Auction storage auction = auctions[_auctionId];
        require(auction.bidder != msg.sender);
        require(msg.value > auction.currentPrice);
        if (auction.bidder != address(0)) {
            address lastBidder = auction.bidder;
            lastBidder.transfer(auction.currentPrice - transferFee);
        }
        auction.currentPrice = msg.value;
        auction.bidder = msg.sender;
        BuyerLotteryTimes[msg.sender] ++;
        
        bidSuccess(_auctionId, msg.sender, msg.value);
    }
    
    function getAuction(uint _auctionId) public view returns (
        uint heroId,
        uint currentPrice,
        address bidder
    ) {
        Auction memory auction = auctions[_auctionId];
        
        heroId = auction.heroId;
        currentPrice = auction.currentPrice;
        bidder = auction.bidder;
    }
    
    function totalAuctions() public view returns (uint) {
        return auctions.length;
    }
    
    function _ItemRandom(uint _jump) internal view returns (uint) {
        uint num = _random(0,1000,_jump);
        if (num >= 0 && num <= 199) {
            return 2;
        } else if (num >= 200 && num <= 449) {
            return 1;
        } else if (num >= 450 && num <= 649) {
            return 0;
        } else if (num >= 650 && num <= 799) {
            return 3;
        } else if (num >= 800 && num <= 899) {
            return 4;
        } else if (num >= 900 && num <= 969) {
            return 5;
        } else if (num >= 970 && num <= 999) {
            return 6;
        }
    }
    
    uint rad = _random(1,13,1);
    
    function itemLottery() public whenNotPaused returns (uint) {
        require(BuyerLotteryTimes[msg.sender] >= 1);
        uint _jump = _random(1, 89, rad);
        if (rad < 13) {
            rad ++;
        } else {
            rad = 1;
        }
        BuyerLotteryTimes[msg.sender] --;
        uint result = _ItemRandom(_jump);
        playerWinItems[msg.sender] += result;
        drawItemLottery(msg.sender, result);
        return result;
    }
    
    function heroLottery() public whenNotPaused returns (bool) {
        require(BuyerLotteryTimes[msg.sender] >= 1);
        uint _jump = _random(1, 89, rad);
        if (rad < 13) {
            rad ++;
        } else {
            rad = 1;
        }
        BuyerLotteryTimes[msg.sender] --;
        bool result = false;
        uint lottery = _random(10, 100, _jump);
        if (lottery == 10) {
            result = true;
            playerWinHeroes[msg.sender] ++;
        }
        drawHeroLottery(msg.sender, result);
        return result;
    }
    
}