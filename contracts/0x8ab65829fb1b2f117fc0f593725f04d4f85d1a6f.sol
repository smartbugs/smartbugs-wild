pragma solidity 0.4.19;


contract InterfaceDeusETH {
    bool public gameOver;
    bool public gameOverByUser;
    function getHolder(uint256 _id) public returns (address);
    function changeHolder(uint256 _id, address _newholder) public returns (bool);
}


contract StockExchange {
    bool public started = false;

    //7200 - 120 minutes
    uint256 public stopTimeLength = 7200;
    uint256 public stopTime = 0;

    //max token supply
    uint256 public cap = 50;

    address public owner;

    // address of tokens
    address public deusETH;

    mapping(uint256 => uint256) public priceList;
    mapping(uint256 => address) public holderList;

    InterfaceDeusETH private lottery = InterfaceDeusETH(0x0);

    event TokenSale(uint256 indexed id, uint256 price);
    event TokenBack(uint256 indexed id);
    event TokenSold(uint256 indexed id, uint256 price);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function StockExchange() public {
        owner = msg.sender;
    }

    function setLottery(address _lottery) public onlyOwner {
        require(!started);
        lottery = InterfaceDeusETH(_lottery);
        deusETH = _lottery;
        started = true;
    }

    function sale(uint256 _id, uint256 _price) public returns (bool) {
        require(started);
        require(_id > 0 && _id <= cap);
        require(!lottery.gameOver());
        require(!lottery.gameOverByUser());
        require(now > stopTime);
        require(lottery.getHolder(_id) == msg.sender);

        priceList[_id] = _price;
        holderList[_id] = msg.sender;

        assert(lottery.changeHolder(_id, this));
        TokenSale(_id, _price);
        return true;
    }

    function getBackToken(uint256 _id) public returns (bool) {
        require(started);
        require(_id > 0 && _id <= cap);
        require(!lottery.gameOver());
        require(!lottery.gameOverByUser());
        require(now > stopTime);
        require(holderList[_id] == msg.sender);

        holderList[_id] = 0x0;
        priceList[_id] = 0;
        assert(lottery.changeHolder(_id, msg.sender));
        TokenBack(_id);
        return true;
    }

    function buy(uint256 _id) public payable returns (bool) {
        require(started);
        require(_id > 0 && _id <= cap);
        require(!lottery.gameOver());
        require(!lottery.gameOverByUser());
        require(now > stopTime);

        require(priceList[_id] == msg.value);
        address oldHolder = holderList[_id];
        holderList[_id] = 0x0;
        priceList[_id] = 0;

        assert(lottery.changeHolder(_id, msg.sender));

        oldHolder.transfer(msg.value);
        TokenSold(_id, msg.value);
        return true;
    }

    function pause() public onlyOwner {
        stopTime = now + stopTimeLength;
    }

    function getTokenPrice(uint _id) public view returns(uint256) {
        return priceList[_id];
    }
}