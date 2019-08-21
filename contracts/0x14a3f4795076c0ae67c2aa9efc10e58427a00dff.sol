pragma solidity ^0.4.0;

/*

                                  # #  ( )
                                  ___#_#___|__
                              _  |____________|  _
                       _=====| | |            | | |==== _
                 =====| |.---------------------------. | |====
   <--------------------'   .  .  .  .  .  .  .  .   '--------------/
     \                                                             /
      \___________________________________________________________/
  wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
   wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww 

*/

contract EtherShipsCore {

    struct ShipProduct {
        string name; // Ship's name
        uint32 armor; // Armor value
        uint32 speed; // Speed value
        uint32 minDamage; // Ship's minimal damage value
        uint32 maxDamage; // Ship's maximum damage value
        uint32 attackSpeed; // Ship's attack speed value
        uint8 league; // The battle league which allows to play with this ship type
        // Unfortunately, it's impossible to define the variable inside the struct as constant.
        // However, you can read this smart-contract and see that there are no changes at all related to the start prices.
        uint256 startPrice;
        uint256 currentPrice; // The current price. Changes every time someone buys this kind of ship
        uint256 earning; // The amount of earning each owner of this ship gets when someone buys this type of ship
        uint256 releaseTime; // The moment when it will be allowed to buy this type of ship
        uint32 amountOfShips; // The amount of ships with this kind of product

    }

    struct ShipEntity {
        uint32 productID;
        uint8[4] upgrades;
        address owner; // The address of the owner of this ship
        address earner; // The address of the earner of this ship who get paid
        bool selling; // Is this ship on the auction now?
        uint256 auctionEntity; // If it's on the auction,
        uint256 earned; // Total funds earned with this ship
        uint32 exp; // ship's experience
        uint32 lastCashoutIndex; // Last amount of ships existing in the game with the same ProductID
    }

    struct AuctionEntity {
        uint32 shipID;
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

    event EventUpgradeShip (
        address indexed player,
        uint32 shipID,
        uint8 upgradeChoice
        ); // ;-)

    event EventTransfer (
        address indexed player,
        address indexed receiver,
        uint32 shipID
        ); // ;-)

    event EventTransferAction (
        address indexed player,
        address indexed receiver,
        uint32 shipID,
        uint8 ActionType
        ); // ;-)

    event EventAuction (
        address indexed player,
        uint32 shipID,
        uint256 startPrice,
        uint256 finishPrice,
        uint256 duration,
        uint256 currentTime
        ); // ;-)
        
    event EventCancelAuction (
        uint32 shipID
        ); // ;-)

    event EventBid (
        uint32 shipID
        ); // ;-)

    event EventBuyShip (
        address indexed player,
        uint32 productID,
        uint32 shipID
        ); // ;-)

    address public UpgradeMaster; // Earns fees for upgrading ships (0.05 Eth)
    address public AuctionMaster; // Earns fees for producing auctions (3%)
    address public ShipSellMaster; // Earns fees for selling ships (start price)

    function ChangeUpgradeMaster (address _newMaster) public {
        require(msg.sender == UpgradeMaster);
        UpgradeMaster = _newMaster;
    }

    function ChangeShipSellMaster (address _newMaster) public {
        require(msg.sender == ShipSellMaster);
        ShipSellMaster = _newMaster;
    }

    function ChangeAuctionMaster (address _newMaster) public {
        require(msg.sender == AuctionMaster);
        AuctionMaster = _newMaster;
    }

    function EtherShipsCore() public {

        UpgradeMaster = msg.sender;
        AuctionMaster = msg.sender;
        ShipSellMaster = msg.sender;

        // Creating ship types
        //name, armor, speed, minDamage, maxDamage, attackSpeed, league, start price, earning, release time
        
        newShipProduct("L-Raz", 50, 5, 5, 40, 5, 1, 50000000000000000, 500000000000000, now);
        newShipProduct("L-Vip", 50, 4, 6, 35, 6, 1, 50000000000000000, 500000000000000, now+(60*60*3));
        newShipProduct("L-Rapt", 50, 5, 5, 35, 5, 1, 50000000000000000, 500000000000000, now+(60*60*6));
        newShipProduct("L-Slash", 50, 5, 5, 30, 6, 1, 50000000000000000, 500000000000000, now+(60*60*12));
        newShipProduct("L-Stin", 50, 5, 5, 40, 5, 1, 50000000000000000, 500000000000000, now+(60*60*24));
        newShipProduct("L-Scor", 50, 4, 5, 35, 5, 1, 50000000000000000, 500000000000000, now+(60*60*48));
        
        newShipProduct("Sub-Sc", 60, 5, 45, 115, 4, 2, 100000000000000000, 1000000000000000, now);
        newShipProduct("Sub-Cycl", 70, 4, 40, 115, 4, 2, 100000000000000000, 1000000000000000, now+(60*60*6));
        newShipProduct("Sub-Deep", 80, 5, 45, 120, 4, 2, 100000000000000000, 1000000000000000, now+(60*60*12));
        newShipProduct("Sub-Sp", 90, 4, 50, 120, 3, 2, 100000000000000000, 1000000000000000, now+(60*60*24));
        newShipProduct("Sub-Ab", 100, 5, 55, 130, 3, 2, 100000000000000000, 1000000000000000, now+(60*60*48));

        newShipProduct("M-Sp", 140, 4, 40, 120, 4, 3, 200000000000000000, 2000000000000000, now);
        newShipProduct("M-Arma", 150, 4, 40, 115, 5, 3, 200000000000000000, 2000000000000000, now+(60*60*12));
        newShipProduct("M-Penetr", 160, 4, 35, 120, 6, 3, 200000000000000000, 2000000000000000, now+(60*60*24));
        newShipProduct("M-Slice", 170, 4, 45, 120, 3, 3, 200000000000000000, 2000000000000000, now+(60*60*36));
        newShipProduct("M-Hell", 180, 3, 35, 120, 2, 3, 200000000000000000, 2000000000000000, now+(60*60*48));

        newShipProduct("H-Haw", 210, 3, 65, 140, 3, 4, 400000000000000000, 4000000000000000, now);
        newShipProduct("H-Fat", 220, 3, 75, 150, 2, 4, 400000000000000000, 4000000000000000, now+(60*60*24));
        newShipProduct("H-Beh", 230, 2, 85, 160, 2, 4, 400000000000000000, 4000000000000000, now+(60*60*48));
        newShipProduct("H-Mamm", 240, 2, 100, 170, 2, 4, 400000000000000000, 4000000000000000, now+(60*60*72));
        newShipProduct("H-BigM", 250, 2, 120, 180, 3, 4, 400000000000000000, 4000000000000000, now+(60*60*96));

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

        balances[msg.sender] -= _amount; // Changing the amount of funds on the player's in-game balance

        if (!msg.sender.send(_amount)){ // Sending funds and if the transaction is failed
            balances[msg.sender] += _amount; // Returning the amount of funds on the player's in-game balance
        }

        EventCashOut (msg.sender, _amount);
        return;
    }

    function cashOutShip (uint32 _shipID) public payable {

        require (_shipID > 0 && _shipID < newIdShip); // Checking if the ship exists
        require (ships[_shipID].owner == msg.sender); // Checking if sender owns this ship
        uint256 _amount = shipProducts[ships[_shipID].productID].earning*(shipProducts[ships[_shipID].productID].amountOfShips-ships[_shipID].lastCashoutIndex);
        require (this.balance >= _amount); // Checking if this contract has enought money to pay
        require (_amount > 0);

        uint32 lastIndex = ships[_shipID].lastCashoutIndex;

        ships[_shipID].lastCashoutIndex = shipProducts[ships[_shipID].productID].amountOfShips; // Changing the amount of funds on the ships's in-game balance

        if (!ships[_shipID].owner.send(_amount)){ // Sending funds and if the transaction is failed
            ships[_shipID].lastCashoutIndex = lastIndex; // Changing the amount of funds on the ships's in-game balance
        }

        EventCashOut (msg.sender, _amount);
        return;
    }

    function login (string _hash) public {
        EventLogin (msg.sender, _hash);
        return;
    }

    //upgrade ship
    // @_upgradeChoice: 0 is for armor, 1 is for damage, 2 is for speed, 3 is for attack speed
    function upgradeShip (uint32 _shipID, uint8 _upgradeChoice) public payable {
        require (_shipID > 0 && _shipID < newIdShip); // Checking if the ship exists
        require (ships[_shipID].owner == msg.sender); // Checking if sender owns this ship
        require (_upgradeChoice >= 0 && _upgradeChoice < 4); // Has to be between 0 and 3
        require (ships[_shipID].upgrades[_upgradeChoice] < 5); // Only 5 upgrades are allowed for each type of ship's parametres
        require (msg.value >= upgradePrice); // Checking if there is enough amount of money for the upgrade
        ships[_shipID].upgrades[_upgradeChoice]++; // Upgrading
        balances[msg.sender] += msg.value-upgradePrice; // Returning the rest amount of money back to the ship owner
        balances[UpgradeMaster] += upgradePrice; // Sending the amount of money spent on the upgrade to the contract creator

        EventUpgradeShip (msg.sender, _shipID, _upgradeChoice);
        return;
    }


    // Transfer. Using for sending ships to another players
    function _transfer (uint32 _shipID, address _receiver) public {
        require (_shipID > 0 && _shipID < newIdShip); // Checking if the ship exists
        require (ships[_shipID].owner == msg.sender); //Checking if sender owns this ship
        require (msg.sender != _receiver); // Checking that the owner is not sending the ship to himself
        require (ships[_shipID].selling == false); //Making sure that the ship is not on the auction now
        ships[_shipID].owner = _receiver; // Changing the ship's owner
        ships[_shipID].earner = _receiver; // Changing the ship's earner address

        EventTransfer (msg.sender, _receiver, _shipID);
        return;
    }

    // Transfer Action. Using for sending ships to EtherArmy's contracts. For example, the battle-area contract.
    function _transferAction (uint32 _shipID, address _receiver, uint8 _ActionType) public {
        require (_shipID > 0 && _shipID < newIdShip); // Checking if the ship exists
        require (ships[_shipID].owner == msg.sender); // Checking if sender owns this ship
        require (msg.sender != _receiver); // Checking that the owner is not sending the ship to himself
        require (ships[_shipID].selling == false); // Making sure that the ship is not on the auction now
        ships[_shipID].owner = _receiver; // Changing the ship's owner

        // As you can see, we do not change the earner here.
        // It means that technically speaking, the ship's owner is still getting his earnings.
        // It's logically that this method (transferAction) will be used for sending ships to the battle area contract or some other contracts which will be interacting with ships
        // Be careful with this method! Do not call it to transfer ships to another player!
        // The reason you should not do this is that the method called "transfer" changes the owner and earner, so it is possible to change the earner address to the current owner address any time.
        // However, for our special contracts like battle area, you are able to read this contract and make sure that your ship will not be sent to anyone else, only back to you.
        // So, please, do not use this method to send your ships to other players. Use it just for interacting with Etherships' contracts, which will be listed on Etherships.com

        EventTransferAction (msg.sender, _receiver, _shipID, _ActionType);
        return;
    }

    //selling
    function sellShip (uint32 _shipID, uint256 _startPrice, uint256 _finishPrice, uint256 _duration) public {
        require (_shipID > 0 && _shipID < newIdShip);
        require (ships[_shipID].owner == msg.sender);
        require (ships[_shipID].selling == false); // Making sure that the ship is not on the auction already
        require (_startPrice >= _finishPrice);
        require (_startPrice > 0 && _finishPrice >= 0);
        require (_duration > 0);
        require (_startPrice == uint256(uint128(_startPrice))); // Just some magic stuff
        require (_finishPrice == uint256(uint128(_finishPrice))); // Just some magic stuff

        auctions[newIdAuctionEntity] = AuctionEntity(_shipID, _startPrice, _finishPrice, now, _duration);
        ships[_shipID].selling = true;
        ships[_shipID].auctionEntity = newIdAuctionEntity++;

        EventAuction (msg.sender, _shipID, _startPrice, _finishPrice, _duration, now);
    }

    //bidding function, people use this to buy ships
    function bid (uint32 _shipID) public payable {
        require (_shipID > 0 && _shipID < newIdShip); // Checking if the ship exists
        require (ships[_shipID].selling == true); // Checking if this ships is on the auction now
        AuctionEntity memory currentAuction = auctions[ships[_shipID].auctionEntity]; // The auction entity for this ship. Just to make the line below easier to read
        uint256 currentPrice = currentAuction.startPrice-(((currentAuction.startPrice-currentAuction.finishPrice)/(currentAuction.duration))*(now-currentAuction.startTime));
        // The line above calculates the current price using the formula StartPrice-(((StartPrice-FinishPrice)/Duration)*(CurrentTime-StartTime)
        if (currentPrice < currentAuction.finishPrice){ // If the auction duration time has been expired
            currentPrice = currentAuction.finishPrice;  // Setting the current price as finishPrice
        }
        require (currentPrice >= 0); // Who knows :)
        require (msg.value >= currentPrice); // Checking if the buyer sent the amount of money which is more or equal the current price

        // All is fine, changing balances and changing ship's owner
        uint256 marketFee = (currentPrice/100)*3; // Calculating 3% of the current price as a fee
        balances[ships[_shipID].owner] += currentPrice-marketFee; // Giving [current price]-[fee] amount to seller
        balances[AuctionMaster] += marketFee; // Sending the fee amount to the contract creator's balance
        balances[msg.sender] += msg.value-currentPrice; //Return the rest amount to buyer
        ships[_shipID].owner = msg.sender; // Changing the owner of the ship
        ships[_shipID].selling = false; // Change the ship status to "not selling now"
        delete auctions[ships[_shipID].auctionEntity]; // Deleting the auction entity from the storage for auctions -- we don't need it anymore
        ships[_shipID].auctionEntity = 0; // Not necessary, but deleting the ID of auction entity which was deleted in the operation above

        EventBid (_shipID);
    }

    //cancel auction
    function cancelAuction (uint32 _shipID) public {
        require (_shipID > 0 && _shipID < newIdShip); // Checking if the ship exists
        require (ships[_shipID].selling == true); // Checking if this ships is on the auction now
        require (ships[_shipID].owner == msg.sender); // Checking if sender owns this ship
        ships[_shipID].selling = false; // Change the ship status to "not selling now"
        delete auctions[ships[_shipID].auctionEntity]; // Deleting the auction entity from the storage for auctions -- we don't need it anymore
        ships[_shipID].auctionEntity = 0; // Not necessary, but deleting the ID of auction entity which was deleted in the operation above

        EventCancelAuction (_shipID);
    }


    function newShipProduct (string _name, uint32 _armor, uint32 _speed, uint32 _minDamage, uint32 _maxDamage, uint32 _attackSpeed, uint8 _league, uint256 _price, uint256 _earning, uint256 _releaseTime) private {
        shipProducts[newIdShipProduct++] = ShipProduct(_name, _armor, _speed, _minDamage, _maxDamage, _attackSpeed, _league, _price, _price, _earning, _releaseTime, 0);
    }

    function buyShip (uint32 _shipproductID) public payable {
        require (shipProducts[_shipproductID].currentPrice > 0 && msg.value > 0); //value is more than 0, price is more than 0
        require (msg.value >= shipProducts[_shipproductID].currentPrice); //value is higher than price
        require (shipProducts[_shipproductID].releaseTime <= now); //checking if this ship was released.
        // Basically, the releaseTime was implemented just to give a chance to get the new ship for as many players as possible.
        // It prevents the using of bots.

        if (msg.value > shipProducts[_shipproductID].currentPrice){
            // If player payed more, put the rest amount of money on his balance
            balances[msg.sender] += msg.value-shipProducts[_shipproductID].currentPrice;
        }

        shipProducts[_shipproductID].currentPrice += shipProducts[_shipproductID].earning;

        ships[newIdShip++] = ShipEntity (_shipproductID, [0, 0, 0, 0], msg.sender, msg.sender, false, 0, 0, 0, ++shipProducts[_shipproductID].amountOfShips);

        // After all owners of the same type of ship got their earnings, admins get the amount which remains and no one need it
        // Basically, it is the start price of the ship.
        balances[ShipSellMaster] += shipProducts[_shipproductID].startPrice;

        EventBuyShip (msg.sender, _shipproductID, newIdShip-1);
        return;
    }

    // Our storage, keys are listed first, then mappings.
    // Of course, instead of some mappings we could use arrays, but why not

    uint32 public newIdShip = 1; // The next ID for the new ship
    uint32 public newIdShipProduct = 1; // The next ID for the new ship type
    uint256 public newIdAuctionEntity = 1; // The next ID for the new auction entity

    mapping (uint32 => ShipEntity) ships; // The storage
    mapping (uint32 => ShipProduct) shipProducts;
    mapping (uint256 => AuctionEntity) auctions;
    mapping (address => uint) balances;

    uint256 public constant upgradePrice = 5000000000000000; // The fee which the UgradeMaster earns for upgrading ships. Fee: 0.005 Eth

    function getShipName (uint32 _ID) public constant returns (string){
        return shipProducts[_ID].name;
    }

    function getShipProduct (uint32 _ID) public constant returns (uint32[7]){
        return [shipProducts[_ID].armor, shipProducts[_ID].speed, shipProducts[_ID].minDamage, shipProducts[_ID].maxDamage, shipProducts[_ID].attackSpeed, uint32(shipProducts[_ID].releaseTime), uint32(shipProducts[_ID].league)];
    }

    function getShipDetails (uint32 _ID) public constant returns (uint32[6]){
        return [ships[_ID].productID, uint32(ships[_ID].upgrades[0]), uint32(ships[_ID].upgrades[1]), uint32(ships[_ID].upgrades[2]), uint32(ships[_ID].upgrades[3]), uint32(ships[_ID].exp)];
    }

    function getShipOwner(uint32 _ID) public constant returns (address){
        return ships[_ID].owner;
    }

    function getShipSell(uint32 _ID) public constant returns (bool){
        return ships[_ID].selling;
    }

    function getShipTotalEarned(uint32 _ID) public constant returns (uint256){
        return ships[_ID].earned;
    }

    function getShipAuctionEntity (uint32 _ID) public constant returns (uint256){
        return ships[_ID].auctionEntity;
    }

    function getCurrentPrice (uint32 _ID) public constant returns (uint256){
        return shipProducts[_ID].currentPrice;
    }

    function getProductEarning (uint32 _ID) public constant returns (uint256){
        return shipProducts[_ID].earning;
    }

    function getShipEarning (uint32 _ID) public constant returns (uint256){
        return shipProducts[ships[_ID].productID].earning*(shipProducts[ships[_ID].productID].amountOfShips-ships[_ID].lastCashoutIndex);
    }

    function getCurrentPriceAuction (uint32 _ID) public constant returns (uint256){
        require (getShipSell(_ID));
        AuctionEntity memory currentAuction = auctions[ships[_ID].auctionEntity]; // The auction entity for this ship. Just to make the line below easier to read
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

    function howManyShips() public constant returns (uint32){
        return newIdShipProduct;
    }

}

/*
    EtherArmy.com
    Ethertanks.com
    Etheretanks.com
*/