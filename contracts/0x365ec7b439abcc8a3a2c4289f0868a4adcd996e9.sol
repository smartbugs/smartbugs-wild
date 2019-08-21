pragma solidity ^0.4.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public Master;


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        Master = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyMaster() {
        require(msg.sender == Master);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newMaster.
     * @param newMaster The address to transfer ownership to.
     */
    function transferOwnership(address newMaster) public onlyMaster {
        if (newMaster != address(0)) {
            Master = newMaster;
        }
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
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev modifier to allow actions only when the contract IS NOT paused
     */
    modifier whenPaused {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyMaster whenNotPaused returns (bool) {
        paused = true;
        Pause();
        return true;
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyMaster whenPaused returns (bool) {
        paused = false;
        Unpause();
        return true;
    }
}

//
contract UpgradeInterface {

    function isUpgradeInterface() public pure returns (bool) {
        return true;
    }

    function tryUpgrade(uint32 carID, uint8 upgradeID) public returns (bool);

}

contract EtherRacingCore is Ownable, Pausable {

    uint64 _seed = 0;

    function random(uint64 upper) internal returns (uint64) {
        _seed = uint64(keccak256(keccak256(block.blockhash(block.number), _seed), now));
        return _seed % upper;
    }

    struct CarProduct {
        string name;
        uint32 basePR; // 44.4 * 100 => 4440
        uint32 baseTopSpeed; // 155mph * 100 => 15500
        uint32 baseAcceleration; // 2.70s * 100 => 270
        uint32 baseBraking; // 99ft * 100 => 9900
        uint32 baseGrip; // 1.20g * 100 => 120

        // variables for auction
        uint256 startPrice;
        uint256 currentPrice;

        uint256 earning;
        uint256 createdAt;

        //
        uint32 entityCounter;
        bool sale;
    }

    struct CarEntity {
        uint32 productID;
        address owner;
        address earner;
        bool selling;
        uint256 auctionID;

        // Each car has unique stats.
        uint32 level;
        uint32 exp;
        uint64 genes;
        uint8[8] upgrades;

        //
        uint32 lastCashoutIndex;
    }


    struct AuctionEntity {
        uint32 carID;
        uint256 startPrice;
        uint256 finishPrice;
        uint256 startTime;
        uint256 duration;
    }

    //
    uint32 public newCarID = 1;
    uint32 public newCarProductID = 1;
    uint256 public newAuctionID = 1;
    bool canInit = true;

    mapping(uint32 => CarEntity) cars;
    mapping(uint32 => CarProduct) carProducts;
    mapping(uint256 => AuctionEntity) auctions;
    mapping(address => uint256) balances;

    event EventCashOut (
        address indexed player,
        uint256 amount
    );

    event EventWinReward (
        address indexed player,
        uint256 amount
    );

    event EventUpgradeCar (
        address indexed player,
        uint32 carID,
        uint8 statID,
        uint8 upgradeLevel
    );

    event EventLevelUp (
        uint32 carID,
        uint32 level,
        uint32 exp
    );

    event EventTransfer (
        address indexed player,
        address indexed receiver,
        uint32 carID
    );

    event EventTransferAction (
        address indexed player,
        address indexed receiver,
        uint32 carID,
        uint8 actionType
    );

    event EventAuction (
        address indexed player,
        uint32 carID,
        uint256 startPrice,
        uint256 finishPrice,
        uint256 duration,
        uint256 createdAt
    );

    event EventCancelAuction (
        uint32 carID
    );

    event EventBid (
        address indexed player,
        uint32 carID
    );

    event EventProduct (
        uint32 productID,
        string name,
        uint32 basePR,
        uint32 baseTopSpeed,
        uint32 baseAcceleration,
        uint32 baseBraking,
        uint32 baseGrip,
        uint256 price,
        uint256 earning,
        uint256 createdAt
    );

    event EventProductEndSale (
        uint32 productID
    );

    event EventBuyCar (
        address indexed player,
        uint32 productID,
        uint32 carID
    );


    UpgradeInterface upgradeInterface;
    uint256 public constant upgradePrice = 50 finney;
    uint256 public constant ownerCut = 500;

    function setUpgradeAddress(address _address) external onlyMaster {
        UpgradeInterface c = UpgradeInterface(_address);
        require(c.isUpgradeInterface());

        // Set the new contract address
        upgradeInterface = c;
    }

    function EtherRacingCore() public {

        addCarProduct("ER-1", 830,  15500, 530, 11200, 90,  10 finney,   0.1 finney);
        addCarProduct("ER-2", 1910, 17100, 509, 10700, 95,  50 finney,   0.5 finney);
        addCarProduct("ER-3", 2820, 18300, 450, 10500, 100, 100 finney,  1 finney);
        addCarProduct("ER-4", 3020, 17700, 419, 10400, 99,  500 finney,  5 finney);
        addCarProduct("ER-5", 4440, 20500, 379, 10100, 99,  1000 finney, 10 finney);
        addCarProduct("ER-6", 4520, 22000, 350, 10400, 104, 1500 finney, 15 finney);
        addCarProduct("ER-7", 4560, 20500, 340, 10200, 104, 2000 finney, 20 finney);
        addCarProduct("ER-8", 6600, 21700, 290, 9100,  139, 2500 finney, 25 finney);
    }

    function CompleteInit() public onlyMaster {
        canInit = false;
    }

    function cashOut(uint256 _amount) public whenNotPaused {
        require(_amount >= 0);
        require(_amount == uint256(uint128(_amount)));
        require(this.balance >= _amount);
        require(balances[msg.sender] >= _amount);

        if (_amount == 0)
            _amount = balances[msg.sender];

        balances[msg.sender] -= _amount;

        if (!msg.sender.send(_amount))
            balances[msg.sender] += _amount;

        EventCashOut(msg.sender, _amount);
    }

    function cashOutCar(uint32 _carID) public whenNotPaused {
        require(_carID > 0 && _carID < newCarID);
        require(cars[_carID].owner == msg.sender);
        uint256 _amount = getCarEarning(_carID);
        require(this.balance >= _amount);
        require(_amount > 0);

        var car = cars[_carID];

        var lastCashoutIndex = car.lastCashoutIndex;
        var limitCashoutIndex = carProducts[car.productID].entityCounter;

        //
        cars[_carID].lastCashoutIndex = limitCashoutIndex;

        // if fail, revert.
        if (!car.owner.send(_amount))
            cars[_carID].lastCashoutIndex = lastCashoutIndex;

        EventCashOut(msg.sender, _amount);
    }

    function upgradeCar(uint32 _carID, uint8 _statID) public payable whenNotPaused {
        require(_carID > 0 && _carID < newCarID);
        require(cars[_carID].owner == msg.sender);
        require(_statID >= 0 && _statID < 8);
        require(cars[_statID].upgrades[_statID] < 20);
        require(msg.value >= upgradePrice);
        require(upgradeInterface != address(0));

        //
        if (upgradeInterface.tryUpgrade(_carID, _statID)) {
            cars[_carID].upgrades[_statID]++;
        }

        //
        balances[msg.sender] += msg.value - upgradePrice;
        balances[Master] += upgradePrice;

        EventUpgradeCar(msg.sender, _carID, _statID, cars[_carID].upgrades[_statID]);
    }

    function levelUpCar(uint32 _carID, uint32 _level, uint32 _exp) public onlyMaster {
        require(_carID > 0 && _carID < newCarID);

        cars[_carID].level = _level;
        cars[_carID].exp = _exp;

        EventLevelUp(_carID, _level, _exp);
    }

    function _transfer(uint32 _carID, address _receiver) public whenNotPaused {
        require(_carID > 0 && _carID < newCarID);
        require(cars[_carID].owner == msg.sender);
        require(msg.sender != _receiver);
        require(cars[_carID].selling == false);
        cars[_carID].owner = _receiver;
        cars[_carID].earner = _receiver;

        EventTransfer(msg.sender, _receiver, _carID);
    }

    function _transferAction(uint32 _carID, address _receiver, uint8 _ActionType) public whenNotPaused {
        require(_carID > 0 && _carID < newCarID);
        require(cars[_carID].owner == msg.sender);
        require(msg.sender != _receiver);
        require(cars[_carID].selling == false);
        cars[_carID].owner = _receiver;

        EventTransferAction(msg.sender, _receiver, _carID, _ActionType);
    }

    function addAuction(uint32 _carID, uint256 _startPrice, uint256 _finishPrice, uint256 _duration) public whenNotPaused {
        require(_carID > 0 && _carID < newCarID);
        require(cars[_carID].owner == msg.sender);
        require(cars[_carID].selling == false);
        require(_startPrice >= _finishPrice);
        require(_startPrice > 0 && _finishPrice >= 0);
        require(_duration > 0);
        require(_startPrice == uint256(uint128(_startPrice)));
        require(_finishPrice == uint256(uint128(_finishPrice)));

        auctions[newAuctionID] = AuctionEntity(_carID, _startPrice, _finishPrice, now, _duration);
        cars[_carID].selling = true;
        cars[_carID].auctionID = newAuctionID++;

        EventAuction(msg.sender, _carID, _startPrice, _finishPrice, _duration, now);
    }

    function bid(uint32 _carID) public payable whenNotPaused {
        require(_carID > 0 && _carID < newCarID);
        require(cars[_carID].selling == true);

        //
        uint256 currentPrice = getCarCurrentPriceAuction(_carID);
        require(currentPrice >= 0);
        require(msg.value >= currentPrice);

        //
        uint256 marketFee = currentPrice * ownerCut / 10000;
        balances[cars[_carID].owner] += currentPrice - marketFee;
        balances[Master] += marketFee;
        balances[msg.sender] += msg.value - currentPrice;

        //
        cars[_carID].owner = msg.sender;
        cars[_carID].selling = false;
        delete auctions[cars[_carID].auctionID];
        cars[_carID].auctionID = 0;

        //
        EventBid(msg.sender, _carID);
    }

    // Cancel auction
    function cancelAuction(uint32 _carID) public whenNotPaused {
        require(_carID > 0 && _carID < newCarID);
        require(cars[_carID].selling == true);
        require(cars[_carID].owner == msg.sender);
        // only owner can do this.
        cars[_carID].selling = false;
        delete auctions[cars[_carID].auctionID];
        cars[_carID].auctionID = 0;

        //
        EventCancelAuction(_carID);
    }

    function addCarProduct(string _name, uint32 pr,
        uint32 topSpeed, uint32 acceleration, uint32 braking, uint32 grip, uint256 _price, uint256 _earning) public onlyMaster {
        carProducts[newCarProductID++] = CarProduct(_name,
            pr, topSpeed, acceleration, braking, grip, _price, _price, _earning, now, 0, true);

        EventProduct(newCarProductID - 1, _name,
            pr, topSpeed, acceleration, braking, grip, _price, _earning, now);
    }

    // car sales are limited
    function endSaleCarProduct(uint32 _carProductID) public onlyMaster {
        require(_carProductID > 0 && _carProductID < newCarProductID);
        carProducts[_carProductID].sale = false;

        EventProductEndSale(_carProductID);
    }

    function addCarInit(address owner, uint32 _carProductID, uint32 level, uint32 exp, uint64 genes) public onlyMaster {
        require(canInit == true);
        require(_carProductID > 0 && _carProductID < newCarProductID);

        //
        carProducts[_carProductID].currentPrice += carProducts[_carProductID].earning;

        //
        cars[newCarID++] = CarEntity(_carProductID, owner, owner, false, 0,
            level, exp, genes,
            [0, 0, 0, 0, 0, 0, 0, 0], ++carProducts[_carProductID].entityCounter);

        //
        EventBuyCar(owner, _carProductID, newCarID - 1);
    }

    function buyCar(uint32 _carProductID) public payable {
        require(_carProductID > 0 && _carProductID < newCarProductID);
        require(carProducts[_carProductID].currentPrice > 0 && msg.value > 0);
        require(msg.value >= carProducts[_carProductID].currentPrice);
        require(carProducts[_carProductID].sale);

        //
        if (msg.value > carProducts[_carProductID].currentPrice)
            balances[msg.sender] += msg.value - carProducts[_carProductID].currentPrice;

        carProducts[_carProductID].currentPrice += carProducts[_carProductID].earning;

        //
        cars[newCarID++] = CarEntity(_carProductID, msg.sender, msg.sender, false, 0,
            1, 0, random(~uint64(0)),
            [0, 0, 0, 0, 0, 0, 0, 0], ++carProducts[_carProductID].entityCounter);

        // send balance to Master
        balances[Master] += carProducts[_carProductID].startPrice;

        //
        EventBuyCar(msg.sender, _carProductID, newCarID - 1);
    }

    function getCarProductName(uint32 _id) public constant returns (string) {
        return carProducts[_id].name;
    }

    function getCarProduct(uint32 _id) public constant returns (uint32[6]) {
        var carProduct = carProducts[_id];
        return [carProduct.basePR,
        carProduct.baseTopSpeed,
        carProduct.baseAcceleration,
        carProduct.baseBraking,
        carProduct.baseGrip,
        uint32(carProducts[_id].createdAt)];
    }

    function getCarDetails(uint32 _id) public constant returns (uint64[12]) {
        var car = cars[_id];
        return [uint64(car.productID),
        uint64(car.genes),
        uint64(car.upgrades[0]),
        uint64(car.upgrades[1]),
        uint64(car.upgrades[2]),
        uint64(car.upgrades[3]),
        uint64(car.upgrades[4]),
        uint64(car.upgrades[5]),
        uint64(car.upgrades[6]),
        uint64(car.upgrades[7]),
        uint64(car.level),
        uint64(car.exp)
        ];
    }

    function getCarOwner(uint32 _id) public constant returns (address) {
        return cars[_id].owner;
    }

    function getCarSelling(uint32 _id) public constant returns (bool) {
        return cars[_id].selling;
    }

    function getCarAuctionID(uint32 _id) public constant returns (uint256) {
        return cars[_id].auctionID;
    }

    function getCarEarning(uint32 _id) public constant returns (uint256) {
        var car = cars[_id];
        var carProduct = carProducts[car.productID];
        var limitCashoutIndex = carProduct.entityCounter;

        //
        return carProduct.earning *
            (limitCashoutIndex - car.lastCashoutIndex);
    }

    function getCarCount() public constant returns (uint32) {
        return newCarID-1;
    }

    function getCarCurrentPriceAuction(uint32 _id) public constant returns (uint256) {
        require(getCarSelling(_id));
        var car = cars[_id];
        var currentAuction = auctions[car.auctionID];
        uint256 currentPrice = currentAuction.startPrice
        - (((currentAuction.startPrice - currentAuction.finishPrice) / (currentAuction.duration)) * (now - currentAuction.startTime));
        if (currentPrice < currentAuction.finishPrice)
            currentPrice = currentAuction.finishPrice;
        return currentPrice;
    }

    function getCarProductCurrentPrice(uint32 _id) public constant returns (uint256) {
        return carProducts[_id].currentPrice;
    }

    function getCarProductEarning(uint32 _id) public constant returns (uint256) {
        return carProducts[_id].earning;
    }

    function getCarProductCount() public constant returns (uint32) {
        return newCarProductID-1;
    }

    function getPlayerBalance(address _player) public constant returns (uint256) {
        return balances[_player];
    }
}