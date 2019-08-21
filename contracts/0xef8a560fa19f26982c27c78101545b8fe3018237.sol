pragma solidity ^0.4.0;

contract EtherTanks {
    
    struct TankHull {
        uint32 armor; // Hull's armor value
        uint32 speed; // Hull's speed value
        uint8 league; // The battle league which allows to play with this hull type
    }
    
    struct TankWeapon {
        uint32 minDamage; // Weapon minimal damage value
        uint32 maxDamage; // Weapon maximum damage value
        uint32 attackSpeed; // Weapon's attack speed value
        uint8 league; // The battle league which allows to play with this weapon type
    }
    
    struct TankProduct {
        string name; // Tank's name
        uint32 hull; // Hull's ID
        uint32 weapon; // Weapon's ID
        // Unfortunately, it's impossible to define the variable inside the struct as constant.
        // However, you can read this smart-contract and see that there are no changes at all related to the start prices.
        uint256 startPrice;
        uint256 currentPrice; // The current price. Changes every time someone buys this kind of tank
        uint256 earning; // The amount of earning each owner of this tank gets when someone buys this type of tank
        uint256 releaseTime; // The moment when it will be allowed to buy this type of tank
        uint32 amountOfTanks; // The amount of tanks with this kind of product
        
    }
        
    struct TankEntity {
        uint32 productID;
        uint8[4] upgrades;
        address owner; // The address of the owner of this tank
        address earner; // The address of the earner of this tank who get paid
        bool selling; // Is this tank on the auction now?
        uint256 auctionEntity; // If it's on the auction,
        uint256 earned; // Total funds earned with this tank
        uint32 exp; // Tank's experience
        uint32 lastCashoutIndex; // Last amount of tanks existing in the game with the same ProductID
    }
    

    struct AuctionEntity {
        uint32 tankId;
        uint256 startPrice;
        uint256 finishPrice;
        uint256 startTime;
        uint256 duration;
    }
    
    event EventCashOut (
       address indexed player,
       uint256 amount
       ); //;-)
    
    event EventLogin (
        address indexed player,
        string hash
        ); //;-)
    
    event EventUpgradeTank (
        address indexed player,
        uint32 tankID,
        uint8 upgradeChoice
        ); // ;-)
    
    event EventTransfer (
        address indexed player,
        address indexed receiver,
        uint32 tankID
        ); // ;-)
        
    event EventTransferAction (
        address indexed player,
        address indexed receiver,
        uint32 tankID,
        uint8 ActionType
        ); // ;-)
        
    event EventAuction (
        address indexed player,
        uint32 tankID,
        uint256 startPrice,
        uint256 finishPrice,
        uint256 duration,
        uint256 currentTime
        ); // ;-)
    event EventCancelAuction (
        uint32 tankID
        ); // ;-)
    
    event EventBid (
        uint32 tankID  
        ); // ;-)
    
    event EventProduct (
        uint32 productID,
        string name,
        uint32 hull,
        uint32 weapon,
        uint256 price,
        uint256 earning,
        uint256 releaseTime,
        uint256 currentTime
        ); // ;-)
        
    event EventBuyTank (
        address indexed player,
        uint32 productID,
        uint32 tankID
        ); // ;-)

    
    address public UpgradeMaster; // Earns fees for upgrading tanks (0.05 Eth)
    address public AuctionMaster; // Earns fees for producing auctions (3%)
    address public TankSellMaster; // Earns fees for selling tanks (start price)
    address public ExportMaster; // Exports tanks from the previous contract.
    bool public canExport = true; // If false -- the exporting is not allowed for this contract forever, so it's safe.
    // No modifiers were needed, because each access is checked no more than one time in the whole code,
    // So calling "require(msg.sender == UpgradeMaster);" is enough.
    
    function ChangeUpgradeMaster (address _newMaster) public {
        require(msg.sender == UpgradeMaster);
        UpgradeMaster = _newMaster;
    }
    
    function ChangeTankSellMaster (address _newMaster) public {
        require(msg.sender == TankSellMaster);
        TankSellMaster = _newMaster;
    }
    
    function ChangeAuctionMaster (address _newMaster) public {
        require(msg.sender == AuctionMaster);
        AuctionMaster = _newMaster;
    }
    
    function FinishedExporting () public {
        require(msg.sender == ExportMaster);
        canExport = false; // Now, the exporting process has been finished, so we do not need to export anything anymore. Done.
    }
    
    function EtherTanks() public {
        
        UpgradeMaster = msg.sender;
        AuctionMaster = msg.sender;
        TankSellMaster = msg.sender;
        ExportMaster = msg.sender;

        // Creating 11 hulls
        newTankHull(100, 5, 1);
        newTankHull(60, 6, 2);
        newTankHull(140, 4, 1);
        newTankHull(200, 3, 1);
        newTankHull(240, 3, 1);
        newTankHull(200, 6, 2);
        newTankHull(360, 4, 2);
        newTankHull(180, 9, 3);
        newTankHull(240, 8, 3);
        newTankHull(500, 4, 2);
        newTankHull(440, 6, 3);
        
        // Creating 11 weapons
        newTankWeapon(6, 14, 5, 1);
        newTankWeapon(18, 26, 3, 2);
        newTankWeapon(44, 66, 2, 1);
        newTankWeapon(21, 49, 3, 1);
        newTankWeapon(60, 90, 2, 2);
        newTankWeapon(21, 49, 2, 2);
        newTankWeapon(48, 72, 3, 2);
        newTankWeapon(13, 29, 9, 3);
        newTankWeapon(36, 84, 4, 3);
        newTankWeapon(120, 180, 2, 3);
        newTankWeapon(72, 108, 4, 3);
        
        // Creating first 11 tank types
        newTankProduct("LT-1", 1, 1, 10000000000000000, 100000000000000, now);
        newTankProduct("LT-2", 2, 2, 50000000000000000, 500000000000000, now);
        newTankProduct("MT-1", 3, 3, 100000000000000000, 1000000000000000, now);
        newTankProduct("HT-1", 4, 4, 500000000000000000, 5000000000000000, now);
        newTankProduct("SPG-1", 5, 5, 500000000000000000, 5000000000000000, now);
        newTankProduct("MT-2", 6, 6, 700000000000000000, 7000000000000000, now+(60*60*2));
        newTankProduct("HT-2", 7, 7, 1500000000000000000, 15000000000000000, now+(60*60*5));
        newTankProduct("LT-3", 8, 8, 300000000000000000, 3000000000000000, now+(60*60*8));
        newTankProduct("MT-3", 9, 9, 1500000000000000000, 15000000000000000, now+(60*60*24));
        newTankProduct("SPG-2", 10, 10, 2000000000000000000, 20000000000000000, now+(60*60*24*2));
        newTankProduct("HT-3", 11, 11, 2500000000000000000, 25000000000000000, now+(60*60*24*3));
    }
    
    function cashOut (uint256 _amount) public payable {
        require (_amount >= 0); //just in case
        require (_amount == uint256(uint128(_amount))); // Just some magic stuff
        require (this.balance >= _amount); // Checking if this contract has enought money to pay
        require (balances[msg.sender] >= _amount); // Checking if player has enough funds on his balance
        if (_amount == 0){
            _amount = balances[msg.sender];
            // If the requested amount is 0, it means that player wants to cashout the whole amount of balance
        }
        if (msg.sender.send(_amount)){ // Sending funds and if the transaction is successful
            balances[msg.sender] -= _amount; // Changing the amount of funds on the player's in-game balance
        }
        
        EventCashOut (msg.sender, _amount);
        return;
    }
    
    function cashOutTank (uint32 _tankID) public payable {
        require (_tankID > 0 && _tankID < newIdTank); // Checking if the tank exists
        require (tanks[_tankID].owner == msg.sender); // Checking if sender owns this tank
        uint256 _amount = tankProducts[tanks[_tankID].productID].earning*(tankProducts[tanks[_tankID].productID].amountOfTanks-tanks[_tankID].lastCashoutIndex);
        require (this.balance >= _amount); // Checking if this contract has enought money to pay
        require (_amount > 0);
        
        if (tanks[_tankID].owner.send(_amount)){ // Sending funds and if the transaction is successful
            tanks[_tankID].lastCashoutIndex = tankProducts[tanks[_tankID].productID].amountOfTanks; // Changing the amount of funds on the player's in-game balance
        }
        
        EventCashOut (msg.sender, _amount);
        return;
    }
    
    function login (string _hash) public {
        EventLogin (msg.sender, _hash);
        return;
    }
    
    //upgrade tank
    // @_upgradeChoice: 0 is for armor, 1 is for damage, 2 is for speed, 3 is for attack speed
    function upgradeTank (uint32 _tankID, uint8 _upgradeChoice) public payable {
        require (_tankID > 0 && _tankID < newIdTank); // Checking if the tank exists
        require (tanks[_tankID].owner == msg.sender); // Checking if sender owns this tank
        require (_upgradeChoice >= 0 && _upgradeChoice < 4); // Has to be between 0 and 3
        require (tanks[_tankID].upgrades[_upgradeChoice] < 5); // Only 5 upgrades are allowed for each type of tank's parametres
        require (msg.value >= upgradePrice); // Checking if there is enough amount of money for the upgrade
        tanks[_tankID].upgrades[_upgradeChoice]++; // Upgrading
        balances[msg.sender] += msg.value-upgradePrice; // Returning the rest amount of money back to the tank owner
        balances[UpgradeMaster] += upgradePrice; // Sending the amount of money spent on the upgrade to the contract creator
        
        EventUpgradeTank (msg.sender, _tankID, _upgradeChoice);
        return;
    }
    
    
    // Transfer. Using for sending tanks to another players
    function _transfer (uint32 _tankID, address _receiver) public {
        require (_tankID > 0 && _tankID < newIdTank); // Checking if the tank exists
        require (tanks[_tankID].owner == msg.sender); //Checking if sender owns this tank
        require (msg.sender != _receiver); // Checking that the owner is not sending the tank to himself
        require (tanks[_tankID].selling == false); //Making sure that the tank is not on the auction now
        tanks[_tankID].owner = _receiver; // Changing the tank's owner
        tanks[_tankID].earner = _receiver; // Changing the tank's earner address

        EventTransfer (msg.sender, _receiver, _tankID);
        return;
    }
    
    // Transfer Action. Using for sending tanks to EtherTanks' contracts. For example, the battle-area contract.
    function _transferAction (uint32 _tankID, address _receiver, uint8 _ActionType) public {
        require (_tankID > 0 && _tankID < newIdTank); // Checking if the tank exists
        require (tanks[_tankID].owner == msg.sender); // Checking if sender owns this tank
        require (msg.sender != _receiver); // Checking that the owner is not sending the tank to himself
        require (tanks[_tankID].selling == false); // Making sure that the tank is not on the auction now
        tanks[_tankID].owner = _receiver; // Changing the tank's owner
        
        // As you can see, we do not change the earner here.
        // It means that technically speaking, the tank's owner is still getting his earnings.
        // It's logically that this method (transferAction) will be used for sending tanks to the battle area contract or some other contracts which will be interacting with tanks
        // Be careful with this method! Do not call it to transfer tanks to another player!
        // The reason you should not do this is that the method called "transfer" changes the owner and earner, so it is possible to change the earner address to the current owner address any time.
        // However, for our special contracts like battle area, you are able to read this contract and make sure that your tank will not be sent to anyone else, only back to you.
        // So, please, do not use this method to send your tanks to other players. Use it just for interacting with EtherTanks' contracts, which will be listed on EtherTanks.com
        
        EventTransferAction (msg.sender, _receiver, _tankID, _ActionType);
        return;
    }
    
    //selling
    function sellTank (uint32 _tankID, uint256 _startPrice, uint256 _finishPrice, uint256 _duration) public {
        require (_tankID > 0 && _tankID < newIdTank);
        require (tanks[_tankID].owner == msg.sender);
        require (tanks[_tankID].selling == false); // Making sure that the tank is not on the auction already
        require (_startPrice >= _finishPrice);
        require (_startPrice > 0 && _finishPrice >= 0);
        require (_duration > 0);
        require (_startPrice == uint256(uint128(_startPrice))); // Just some magic stuff
        require (_finishPrice == uint256(uint128(_finishPrice))); // Just some magic stuff
        
        auctions[newIdAuctionEntity] = AuctionEntity(_tankID, _startPrice, _finishPrice, now, _duration);
        tanks[_tankID].selling = true;
        tanks[_tankID].auctionEntity = newIdAuctionEntity++;
        
        EventAuction (msg.sender, _tankID, _startPrice, _finishPrice, _duration, now);
    }
    
    //bidding function, people use this to buy tanks
    function bid (uint32 _tankID) public payable {
        require (_tankID > 0 && _tankID < newIdTank); // Checking if the tank exists
        require (tanks[_tankID].selling == true); // Checking if this tanks is on the auction now
        AuctionEntity memory currentAuction = auctions[tanks[_tankID].auctionEntity]; // The auction entity for this tank. Just to make the line below easier to read
        uint256 currentPrice = currentAuction.startPrice-(((currentAuction.startPrice-currentAuction.finishPrice)/(currentAuction.duration))*(now-currentAuction.startTime));
        // The line above calculates the current price using the formula StartPrice-(((StartPrice-FinishPrice)/Duration)*(CurrentTime-StartTime)
        if (currentPrice < currentAuction.finishPrice){ // If the auction duration time has been expired
            currentPrice = currentAuction.finishPrice;  // Setting the current price as finishPrice 
        }
        require (currentPrice >= 0); // Who knows :)
        require (msg.value >= currentPrice); // Checking if the buyer sent the amount of money which is more or equal the current price
        
        // All is fine, changing balances and changing tank's owner
        uint256 marketFee = (currentPrice/100)*3; // Calculating 3% of the current price as a fee
        balances[tanks[_tankID].owner] += currentPrice-marketFee; // Giving [current price]-[fee] amount to seller
        balances[AuctionMaster] += marketFee; // Sending the fee amount to the contract creator's balance
        balances[msg.sender] += msg.value-currentPrice; //Return the rest amount to buyer
        tanks[_tankID].owner = msg.sender; // Changing the owner of the tank
        tanks[_tankID].selling = false; // Change the tank status to "not selling now"
        delete auctions[tanks[_tankID].auctionEntity]; // Deleting the auction entity from the storage for auctions -- we don't need it anymore
        tanks[_tankID].auctionEntity = 0; // Not necessary, but deleting the ID of auction entity which was deleted in the operation above
        
        EventBid (_tankID);
    }
    
    //cancel auction
    function cancelAuction (uint32 _tankID) public {
        require (_tankID > 0 && _tankID < newIdTank); // Checking if the tank exists
        require (tanks[_tankID].selling == true); // Checking if this tanks is on the auction now
        require (tanks[_tankID].owner == msg.sender); // Checking if sender owns this tank
        tanks[_tankID].selling = false; // Change the tank status to "not selling now"
        delete auctions[tanks[_tankID].auctionEntity]; // Deleting the auction entity from the storage for auctions -- we don't need it anymore
        tanks[_tankID].auctionEntity = 0; // Not necessary, but deleting the ID of auction entity which was deleted in the operation above
        
        EventCancelAuction (_tankID);
    }
    
    
    function newTankProduct (string _name, uint32 _hull, uint32 _weapon, uint256 _price, uint256 _earning, uint256 _releaseTime) private {
        tankProducts[newIdTankProduct++] = TankProduct(_name, _hull, _weapon, _price, _price, _earning, _releaseTime, 0);
        
        EventProduct (newIdTankProduct-1, _name, _hull, _weapon, _price, _earning, _releaseTime, now);
    }
    
    function newTankHull (uint32 _armor, uint32 _speed, uint8 _league) private {
        tankHulls[newIdTankHull++] = TankHull(_armor, _speed, _league);
    }
    
    function newTankWeapon (uint32 _minDamage, uint32 _maxDamage, uint32 _attackSpeed, uint8 _league) private {
        tankWeapons[newIdTankWeapon++] = TankWeapon(_minDamage, _maxDamage, _attackSpeed, _league);
    }
    
    function exportTank (address _owner, uint32 _tankproductID) public {
        require (canExport == true); // Can be called only if the process of exporting is allowed
        tankProducts[_tankproductID].currentPrice += tankProducts[_tankproductID].earning;
        tanks[newIdTank++] = TankEntity (_tankproductID, [0, 0, 0, 0], _owner, _owner, false, 0, 0, 0, ++tankProducts[_tankproductID].amountOfTanks);
        EventBuyTank (msg.sender, _tankproductID, newIdTank-1);
    }
    
    function buyTank (uint32 _tankproductID) public payable {
        require (tankProducts[_tankproductID].currentPrice > 0 && msg.value > 0); //value is more than 0, price is more than 0
        require (msg.value >= tankProducts[_tankproductID].currentPrice); //value is higher than price
        require (tankProducts[_tankproductID].releaseTime <= now); //checking if this tank was released.
        // Basically, the releaseTime was implemented just to give a chance to get the new tank for as many players as possible.
        // It prevents the using of bots.
        
        if (msg.value > tankProducts[_tankproductID].currentPrice){
            // If player payed more, put the rest amount of money on his balance
            balances[msg.sender] += msg.value-tankProducts[_tankproductID].currentPrice;
        }
        
        tankProducts[_tankproductID].currentPrice += tankProducts[_tankproductID].earning;
        
        /*for (uint32 index = 1; index < newIdTank; index++){
            if (tanks[index].productID == _tankproductID){
                balances[tanks[index].earner] += tankProducts[_tankproductID].earning;
                tanks[index].earned += tankProducts[_tankproductID].earning;
            }
        }*/
        // This is why we decided to create the new contract - to avoid loops. Our suggestion to you: NEVER EVER USE LOOPS IN SMART-CONTRACTS
        
        if (tanksBeforeTheNewTankType() == 0 && newIdTankProduct <= 121){
            newTankType();
        }
        
        tanks[newIdTank++] = TankEntity (_tankproductID, [0, 0, 0, 0], msg.sender, msg.sender, false, 0, 0, 0, ++tankProducts[_tankproductID].amountOfTanks);

        // After all owners of the same type of tank got their earnings, admins get the amount which remains and no one need it
        // Basically, it is the start price of the tank.
        balances[TankSellMaster] += tankProducts[_tankproductID].startPrice;
        
        EventBuyTank (msg.sender, _tankproductID, newIdTank-1);
        return;
    }
    
    // This is the tricky method which creates the new type tank.
    function newTankType () public {
        if (newIdTankProduct > 121){
            return;
        }
        //creating new tank type!
        if (createNewTankHull < newIdTankHull - 1 && createNewTankWeapon >= newIdTankWeapon - 1) {
            createNewTankWeapon = 1;
            createNewTankHull++;
        } else {
            createNewTankWeapon++;
            if (createNewTankHull == createNewTankWeapon) {
                createNewTankWeapon++;
            }
        }
        newTankProduct ("Tank", uint32(createNewTankHull), uint32(createNewTankWeapon), 200000000000000000, 3000000000000000, now+(60*60));
        return;
    }
    
    // Our storage, keys are listed first, then mappings.
    // Of course, instead of some mappings we could use arrays, but why not
    
    uint32 public newIdTank = 1; // The next ID for the new tank
    uint32 public newIdTankProduct = 1; // The next ID for the new tank type
    uint32 public newIdTankHull = 1; // The next ID for the new hull
    uint32 public newIdTankWeapon = 1; // The new ID for the new weapon
    uint32 public createNewTankHull = 1; // For newTankType()
    uint32 public createNewTankWeapon = 0; // For newTankType()
    uint256 public newIdAuctionEntity = 1; // The next ID for the new auction entity

    mapping (uint32 => TankEntity) tanks; // The storage 
    mapping (uint32 => TankProduct) tankProducts;
    mapping (uint32 => TankHull) tankHulls;
    mapping (address => uint32[]) tankOwners;
    mapping (uint32 => TankWeapon) tankWeapons;
    mapping (uint256 => AuctionEntity) auctions;
    mapping (address => uint) balances;

    uint256 public constant upgradePrice = 50000000000000000; // The fee which the UgradeMaster earns for upgrading tanks

    function getTankName (uint32 _ID) public constant returns (string){
        return tankProducts[_ID].name;
    }
    
    function getTankProduct (uint32 _ID) public constant returns (uint32[6]){
        return [tankHulls[tankProducts[_ID].hull].armor, tankHulls[tankProducts[_ID].hull].speed, tankWeapons[tankProducts[_ID].weapon].minDamage, tankWeapons[tankProducts[_ID].weapon].maxDamage, tankWeapons[tankProducts[_ID].weapon].attackSpeed, uint32(tankProducts[_ID].releaseTime)];
    }
    
    function getTankDetails (uint32 _ID) public constant returns (uint32[6]){
        return [tanks[_ID].productID, uint32(tanks[_ID].upgrades[0]), uint32(tanks[_ID].upgrades[1]), uint32(tanks[_ID].upgrades[2]), uint32(tanks[_ID].upgrades[3]), uint32(tanks[_ID].exp)];
    }
    
    function getTankOwner(uint32 _ID) public constant returns (address){
        return tanks[_ID].owner;
    }
    
    function getTankSell(uint32 _ID) public constant returns (bool){
        return tanks[_ID].selling;
    }
    
    function getTankTotalEarned(uint32 _ID) public constant returns (uint256){
        return tanks[_ID].earned;
    }
    
    function getTankAuctionEntity (uint32 _ID) public constant returns (uint256){
        return tanks[_ID].auctionEntity;
    }
    
    function getCurrentPrice (uint32 _ID) public constant returns (uint256){
        return tankProducts[_ID].currentPrice;
    }
    
    function getProductEarning (uint32 _ID) public constant returns (uint256){
        return tankProducts[_ID].earning;
    }
    
    function getTankEarning (uint32 _ID) public constant returns (uint256){
        return tankProducts[tanks[_ID].productID].earning*(tankProducts[tanks[_ID].productID].amountOfTanks-tanks[_ID].lastCashoutIndex);
    }
    
    function getCurrentPriceAuction (uint32 _ID) public constant returns (uint256){
        require (getTankSell(_ID));
        AuctionEntity memory currentAuction = auctions[tanks[_ID].auctionEntity]; // The auction entity for this tank. Just to make the line below easier to read
        uint256 currentPrice = currentAuction.startPrice-(((currentAuction.startPrice-currentAuction.finishPrice)/(currentAuction.duration))*(now-currentAuction.startTime));
        if (currentPrice < currentAuction.finishPrice){ // If the auction duration time has been expired
            currentPrice = currentAuction.finishPrice;  // Setting the current price as finishPrice 
        }
        return currentPrice;
    }
    
    function getPlayerBalance(address _player) public constant returns (uint256){
        return balances[_player];
    }
    
    function getContractBalance() public constant returns (uint256){
        return this.balance;
    }
    
    function howManyTanks() public constant returns (uint32){
        return newIdTankProduct;
    }
    
    function tanksBeforeTheNewTankType() public constant returns (uint256){
        return 1000+(((newIdTankProduct)+10)*((newIdTankProduct)+10)*(newIdTankProduct-11))-newIdTank;
    }
}

/*
    The previous contract address: 0xca5088449b96c225801ced8e9efdcae1e0c92a3d
    
    EtherTanks.com
    EthereTanks.com
*/