pragma solidity 0.4.19;

contract EtherSpace {
    // This contract was heavily inspired by EtherTanks/EtherArmy.
    
    address public owner;
    
    struct ShipProduct {
        uint16 class; // 
        uint256 startPrice; // initial price
        uint256 currentPrice; // The current price. Changes every time someone buys this kind of ship
        uint256 earning; // The amount of earning each owner of this ship gets when someone buys this type of ship
        uint64 amount; // The amount of ships issued
    }
    
    struct ShipEntity {
        uint16 model;
        address owner; // The address of the owner of this ship
        uint64 lastCashoutIndex; // Last amount existing in the game with the same ProductID
        bool battle;
        uint32 battleWins;
        uint32 battleLosses;
    }
    
    // event EventProduct (
    //     uint16 model,
    //     uint16 class,
    //     uint256 price,
    //     uint256 earning,
    //     uint256 currentTime
    // ); 
    
    event EventCashOut (
        address indexed player,
        uint256 amount
    );
        
    event EventBuyShip (
        address indexed player,
        uint16 productID,
        uint64 shipID
    );
    
    event EventAddToBattle (
        address indexed player,
        uint64 id
    );
    event EventRemoveFromBattle (
        address indexed player,
        uint64 id
    );
    event EventBattle (
        address indexed player,
        uint64 id,
        uint64 idToAttack,
        uint64 idWinner
    );
        
    function EtherSpace() public {
        owner = msg.sender;
        
        newShipProduct(0,   50000000000000000,   500000000000000); // 0.05, 0.0005
        newShipProduct(0,   70000000000000000,   700000000000000); // 0.07, 0.0007
        newShipProduct(0,   70000000000000000,   700000000000000); // 0.07, 0.0007
        newShipProduct(0,   70000000000000000,   700000000000000); // 0.07, 0.0007
        newShipProduct(0,  100000000000000000,  1000000000000000); // 0.10, 0.0010
        newShipProduct(0,  100000000000000000,  1000000000000000); // 0.10, 0.0010
        newShipProduct(0,  300000000000000000,  3000000000000000); // 0.30, 0.0030
        newShipProduct(0,  300000000000000000,  3000000000000000); // 0.30, 0.0030
        newShipProduct(0,  500000000000000000,  5000000000000000); // 0.50, 0.0050
        newShipProduct(0,  500000000000000000,  5000000000000000); // 0.50, 0.0050
        newShipProduct(0,  700000000000000000,  7000000000000000); // 0.70, 0.0070
        newShipProduct(0,  700000000000000000,  7000000000000000); // 0.70, 0.0070
        newShipProduct(0,  750000000000000000,  7500000000000000); // 0.75, 0.0075
        newShipProduct(0, 1000000000000000000, 10000000000000000); // 1.00, 0.0100
        newShipProduct(0, 2300000000000000000, 23000000000000000); // 2.30, 0.0230
    }
    
    uint64 public newIdShip = 0; // The next ID for the new ship
    uint16 public newModelShipProduct = 0; // The next model when creating ships
    mapping (uint64 => ShipEntity) public ships; // The storage 
    mapping (uint16 => ShipProduct) shipProducts;
    mapping (address => uint64[]) shipOwners;
    mapping (address => uint) balances;
    
    function newShipProduct (uint16 _class, uint256 _price, uint256 _earning) private {
        shipProducts[newModelShipProduct++] = ShipProduct(_class, _price, _price, _earning, 0);
        
        // EventProduct (newModelShipProduct-1, _class, _price, _earning, now);
    }
    
    function cashOut () public payable { // shouldnt be payable
        uint _balance = balances[msg.sender];
        
        for (uint64 index=0; index<shipOwners[msg.sender].length; index++) {
            uint64 id = shipOwners[msg.sender][index]; // entity id
            uint16 model = ships[id].model; // product model id
            
            _balance += shipProducts[model].earning * (shipProducts[model].amount - ships[id].lastCashoutIndex);

            ships[id].lastCashoutIndex = shipProducts[model].amount;
        }
        
        require (this.balance >= _balance); // Checking if this contract has enought money to pay
        
        balances[msg.sender] = 0;
        msg.sender.transfer(_balance);
        
        EventCashOut (msg.sender, _balance);
        return;
    }
    
    function buyShip (uint16 _shipModel) public payable {
        require (msg.value >= shipProducts[_shipModel].currentPrice); //value is higher than price
        require (shipOwners[msg.sender].length <= 10); // max 10 ships allowed per player

        if (msg.value > shipProducts[_shipModel].currentPrice){
            // If player payed more, put the rest amount of money on his balance
            balances[msg.sender] += msg.value - shipProducts[_shipModel].currentPrice;
        }
        
        shipProducts[_shipModel].currentPrice += shipProducts[_shipModel].earning;
    
        ships[newIdShip++] = ShipEntity(_shipModel, msg.sender, ++shipProducts[_shipModel].amount, false, 0, 0);

        shipOwners[msg.sender].push(newIdShip-1);

        // After all owners of the same type of ship got their earnings, admins get the amount which remains and no one need it
        // Basically, it is the start price of the ship.
        balances[owner] += shipProducts[_shipModel].startPrice;
        
        EventBuyShip (msg.sender, _shipModel, newIdShip-1);
        return;
    }
    
    // Management
    function newShip (uint16 _class, uint256 _price, uint256 _earning) public {
        require (owner == msg.sender);
        
        shipProducts[newModelShipProduct++] = ShipProduct(_class, _price, _price, _earning, 0);
    }
    
    function changeOwner(address _newOwner) public {
        require (owner == msg.sender);
        
        owner = _newOwner;
    }
    
    // Battle Functions
    
    uint battleStake = 50000000000000000; // 0.05
    uint battleFee = 5000000000000000; // 0.005 or 5%
    
    uint nonce = 0;
    function rand(uint min, uint max) public returns (uint){
        nonce++;
        return uint(sha3(nonce+uint256(block.blockhash(block.number-1))))%(min+max+1)-min;
    }
    
    function addToBattle(uint64 _id) public payable {
        require (msg.value == battleStake); // must pay exactly the battle stake
        require (msg.sender == ships[_id].owner); // must be the owner
        
        ships[_id].battle = true;
        
        EventAddToBattle(msg.sender, _id);
    }
    function removeFromBattle(uint64 _id) public {
        require (msg.sender == ships[_id].owner); // must be the owner
        
        ships[_id].battle = false;
        balances[msg.sender] += battleStake;
        
        EventRemoveFromBattle(msg.sender, _id);
    }
    
    function battle(uint64 _id, uint64 _idToAttack) public payable {
        require (msg.sender == ships[_id].owner); // must be the owner
        require (msg.value == battleStake); // must pay exactly the battle stake
        require (ships[_idToAttack].battle == true); // ship to attack must be in battle mode
        require (ships[_id].battle == false); // attacking ship must not be offered for battle
        
        uint randNumber = rand(0,1);
        
        if (randNumber == 1) {
            ships[_id].battleWins++;
            ships[_idToAttack].battleLosses++;
            
            balances[ships[_id].owner] += (battleStake * 2) - battleFee;
            
            EventBattle(msg.sender, _id, _idToAttack, _id);
            
        } else {
            ships[_id].battleLosses++;
            ships[_idToAttack].battleWins++;
            
            balances[ships[_idToAttack].owner] += (battleStake * 2) - battleFee;
            
            EventBattle(msg.sender, _id, _idToAttack, _idToAttack);
        }
        
        balances[owner] += battleFee;
        
        ships[_idToAttack].battle = false;
    }
    
    // UI Functions
    function getPlayerShipModelById(uint64 _id) public constant returns (uint16) {
        return ships[_id].model;
    }
    function getPlayerShipOwnerById(uint64 _id) public constant returns (address) {
        return ships[_id].owner;
    }
    function getPlayerShipBattleById(uint64 _id) public constant returns (bool) {
        return ships[_id].battle;
    }
    function getPlayerShipBattleWinsById(uint64 _id) public constant returns (uint32) {
        return ships[_id].battleWins;
    }
    function getPlayerShipBattleLossesById(uint64 _id) public constant returns (uint32) {
        return ships[_id].battleLosses;
    }
    
    function getPlayerShipCount(address _player) public constant returns (uint) {
        return shipOwners[_player].length;
    }
    
    function getPlayerShipModelByIndex(address _player, uint index) public constant returns (uint16) {
        return ships[shipOwners[_player][index]].model;
    }
    
    function getPlayerShips(address _player) public constant returns (uint64[]) {
        return shipOwners[_player];
    }
    
    function getPlayerBalance(address _player) public constant returns (uint256) {
        uint _balance = balances[_player];
        
        for (uint64 index=0; index<shipOwners[_player].length; index++) {
            uint64 id = shipOwners[_player][index]; // entity id
            uint16 model = ships[id].model; // product model id

            _balance += shipProducts[model].earning * (shipProducts[model].amount - ships[id].lastCashoutIndex);
        }
        
        return _balance;
    }
    
    function getShipProductClassByModel(uint16 _model) public constant returns (uint16) {
        return shipProducts[_model].class;
    }
    function getShipProductStartPriceByModel(uint16 _model) public constant returns (uint256) {
        return shipProducts[_model].startPrice;
    }
    function getShipProductCurrentPriceByModel(uint16 _model) public constant returns (uint256) {
        return shipProducts[_model].currentPrice;
    }
    function getShipProductEarningByModel(uint16 _model) public constant returns (uint256) {
        return shipProducts[_model].earning;
    }
    function getShipProductAmountByModel(uint16 _model) public constant returns (uint64) {
        return shipProducts[_model].amount;
    }
    
    function getShipProductCount() public constant returns (uint16) {
        return newModelShipProduct;
    }
    function getShipCount() public constant returns (uint64) {
        return newIdShip;
    }
}