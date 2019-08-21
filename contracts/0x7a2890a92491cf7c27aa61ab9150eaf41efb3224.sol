pragma solidity ^0.4.0;

contract EZTanks{
    
    // STRUCTS HERE
    struct TankObject{
        // type of tank 
        uint256 typeID; 

        // tank quality
        uint8[4] upgrades;
        uint8 exp;
        uint8 next;
        bool inBattle;
        
        // stats
        address tankOwner;
        uint256 earningsIndex; 
        
        // buying & selling 
        bool inAuction;
        uint256 currAuction;
    }

    struct TankType{
        uint256 startPrice;
        uint256 currPrice;
        uint256 earnings;

        // battle stats
        uint32 baseHealth;
        uint32 baseAttack;
        uint32 baseArmor;
        uint32 baseSpeed;

        uint32 numTanks;
    }
    
    struct AuctionObject{
        uint tank; // tank id
        uint startPrice;
        uint endPrice;
        uint startTime;
        uint duration;
        bool alive;
    }
    
    // EVENTS HERE
    event EventWithdraw (
       address indexed player,
       uint256 amount
    ); 

    event EventUpgradeTank (
        address indexed player,
        uint256 tankID,
        uint8 upgradeChoice
    ); 
    
    event EventAuction (
        address indexed player,
        uint256 tankID,
        uint256 startPrice,
        uint256 endPrice,
        uint256 duration,
        uint256 currentTime
    );
        
    event EventCancelAuction (
        uint256 indexed tankID,
        address owner
    ); 
    
    event EventBid (
        uint256 indexed tankID,
        address indexed buyer
    ); 
    
    event EventBuyTank (
        address indexed player,
        uint256 productID,
        uint256 tankID,
        uint256 newPrice
    ); 

    event EventCashOutTank(
        address indexed player,
        uint256 amount
    );

    event EventJoinedBattle(
        address indexed player,
        uint256 indexed tankID
    );

    event EventQuitBattle(
        address indexed player,
        uint256 indexed tankID
    );
    
    event EventBattleOver();
    
    // FIELDS HERE
    
    // contract fields 
    uint8 feeAmt = 3;
    uint8 tournamentTaxRate = 5;
    address owner;


    // battle!
    uint256 tournamentAmt = 0;
    uint8 teamSize = 5;
    uint256 battleFee = 1 ether / 1000;
    uint256[] battleTeams;

    // tank fields
    uint256 newTypeID = 1;
    uint256 newTankID = 1;
    uint256 newAuctionID = 1;
    
    mapping (uint256 => TankType) baseTanks;
    mapping (uint256 => TankObject) tanks; //maps tankID to tanks
    mapping (address => uint256[]) userTanks;
    mapping (uint => AuctionObject) auctions; //maps auctionID to auction
    mapping (address => uint) balances; 

    // MODIFIERS HERE
    modifier isOwner {
        require(msg.sender == owner);
        _;
    }
    
    // CTOR
    function EZTanks() public payable{
        // init owner
        owner = msg.sender;
        balances[owner] += msg.value;

        // basic tank
        newTankType(1 ether / 80, 1 ether / 1000, 2500, 50, 40, 3);

        // bulky tank
        newTankType(1 ether / 50, 1 ether / 1000, 5500, 50, 41, 3);

        // speeder tank
        newTankType(1 ether / 50, 1 ether / 1000, 2000, 50, 40, 5);

        // powerful tank
        newTankType(1 ether / 50, 1 ether / 1000, 3000, 53, 39, 3);

        // armor tank
        newTankType(1 ether / 50, 1 ether / 1000, 4000, 51, 43, 2);

        // better than basic tank
        newTankType(1 ether / 40, 1 ether / 200, 3000, 52, 41, 4);
    }

    // ADMINISTRATIVE FUNCTIONS

    function setNewOwner(address newOwner) public isOwner{
        owner = newOwner;
    }

    // create a new tank type 
    function newTankType ( 
        uint256 _startPrice,
        uint256 _earnings,
        uint32 _baseHealth,
        uint32 _baseAttack,
        uint32 _baseArmor,
        uint32 _baseSpeed
    ) public isOwner {
        baseTanks[newTypeID++] = TankType({
            startPrice : _startPrice,
            currPrice : _startPrice,
            earnings : _earnings,
            baseAttack : _baseAttack,
            baseArmor : _baseArmor,
            baseSpeed : _baseSpeed,
            baseHealth : _baseHealth,
            numTanks : 0
        });

    }
    
    // fee from auctioning
    function changeFeeAmt (uint8 _amt) public isOwner {
        require(_amt > 0 && _amt < 100);
        feeAmt = _amt;
    }

    // rate to fund tournament
    function changeTournamentTaxAmt (uint8 _rate) public isOwner {
        require(_rate > 0 && _rate < 100);
        tournamentTaxRate = _rate;
    }

    function changeTeamSize(uint8 _size) public isOwner {
        require(_size > 0);
        teamSize = _size;
    }

    // cost to enter battle
    function changeBattleFee(uint256 _fee) public isOwner {
        require(_fee > 0);
        battleFee = _fee;
    }
    
    // INTERNAL FUNCTIONS

    function delTankFromUser(address user, uint256 value) internal {
        uint l = userTanks[user].length;

        for(uint i=0; i<l; i++){
            if(userTanks[user][i] == value){
                delete userTanks[user][i];
                userTanks[user][i] = userTanks[user][l-1];
                userTanks[user].length = l-1;
                return;
            }
        }
    }

    // USER FUNCTIONS

    function withdraw (uint256 _amount) public payable {
        // validity checks
        require (_amount >= 0); 
        require (this.balance >= _amount); 
        require (balances[msg.sender] >= _amount); 
        
        // return everything is withdrawing 0
        if (_amount == 0){
            _amount = balances[msg.sender];
        }
        
        require(msg.sender.send(_amount));
        balances[msg.sender] -= _amount; 
        
        EventWithdraw (msg.sender, _amount);
    }
    
    
    function auctionTank (uint _tankID, uint _startPrice, uint _endPrice, uint256 _duration) public {
        require (_tankID > 0 && _tankID < newTankID);
        require (tanks[_tankID].tankOwner == msg.sender);
        require (!tanks[_tankID].inBattle);
        require (!tanks[_tankID].inAuction);
        require (tanks[_tankID].currAuction == 0);
        require (_startPrice >= _endPrice);
        require (_startPrice > 0 && _endPrice >= 0);
        require (_duration > 0);
        
        auctions[newAuctionID] = AuctionObject(_tankID, _startPrice, _endPrice, now, _duration, true);
        tanks[_tankID].inAuction = true;
        tanks[_tankID].currAuction = newAuctionID;
        
        newAuctionID++;

        EventAuction (msg.sender, _tankID, _startPrice, _endPrice, _duration, now);
    }
    
    // buy tank from auction
    function bid (uint256 _tankID) public payable {
        // validity checks
        require (_tankID > 0 && _tankID < newTankID); // check if tank is valid
        require (tanks[_tankID].inAuction == true); // check if tank is currently in auction
        
        
        uint256 auctionID = tanks[_tankID].currAuction;
        uint256 currPrice = getCurrAuctionPriceAuctionID(auctionID);
        
        require (currPrice >= 0); 
        require (msg.value >= currPrice); 
        
        if(msg.value > currPrice){
            balances[msg.sender] += (msg.value - currPrice);
        }


        // calculate new balances
        uint256 fee = (currPrice*feeAmt) / 100; 

        //update tournamentAmt
        uint256 tournamentTax = (fee*tournamentTaxRate) / 100;
        tournamentAmt += tournamentTax;
    
        balances[tanks[_tankID].tankOwner] += currPrice - fee;
        balances[owner] += (fee - tournamentTax); 

        // update object fields
        address formerOwner = tanks[_tankID].tankOwner;

        tanks[_tankID].tankOwner = msg.sender;
        tanks[_tankID].inAuction = false; 
        auctions[tanks[_tankID].currAuction].alive = false; 
        tanks[_tankID].currAuction = 0; 

        // update userTanks
        userTanks[msg.sender].push(_tankID);
        delTankFromUser(formerOwner, _tankID);

        EventBid (_tankID, msg.sender);
    }
    
    function cancelAuction (uint256 _tankID) public {
        require (_tankID > 0 && _tankID < newTankID); 
        require (tanks[_tankID].inAuction); 
        require (tanks[_tankID].tankOwner == msg.sender); 
        
        // update tank object
        tanks[_tankID].inAuction = false; 
        auctions[tanks[_tankID].currAuction].alive = false; 
        tanks[_tankID].currAuction = 0; 

        EventCancelAuction (_tankID, msg.sender);
    }

    function buyTank (uint32 _typeID) public payable {
        require(_typeID > 0 && _typeID < newTypeID);
        require (baseTanks[_typeID].currPrice > 0 && msg.value > 0); 
        require (msg.value >= baseTanks[_typeID].currPrice); 
        
        if (msg.value > baseTanks[_typeID].currPrice){
            balances[msg.sender] += msg.value - baseTanks[_typeID].currPrice;
        }
        
        baseTanks[_typeID].currPrice += baseTanks[_typeID].earnings;
        
        uint256 earningsIndex = baseTanks[_typeID].numTanks + 1;
        baseTanks[_typeID].numTanks += 1;

        tanks[newTankID++] = TankObject ({
            typeID : _typeID,
            upgrades : [0,0,0,0],
            exp: 0,
            next: 0,
            inBattle : false,
            tankOwner : msg.sender,
            earningsIndex : earningsIndex,
            inAuction : false,
            currAuction : 0
        });

        uint256 price = baseTanks[_typeID].startPrice;
        uint256 tournamentProceeds = (price * tournamentTaxRate) / 100;

        balances[owner] += baseTanks[_typeID].startPrice - tournamentProceeds;
        tournamentAmt += tournamentProceeds;

        userTanks[msg.sender].push(newTankID-1);
        
        EventBuyTank (msg.sender, _typeID, newTankID-1, baseTanks[_typeID].currPrice);
    }

    //cashing out the money that a tank has earned
    function cashOutTank (uint256 _tankID) public {
        // validity checks
        require (_tankID > 0 && _tankID < newTankID); 
        require (tanks[_tankID].tankOwner == msg.sender);
        require (!tanks[_tankID].inAuction && tanks[_tankID].currAuction == 0);
        require (!tanks[_tankID].inBattle);

        
        uint256 tankType = tanks[_tankID].typeID;
        uint256 numTanks = baseTanks[tankType].numTanks;

        uint256 amount = getCashOutAmount(_tankID);

        require (this.balance >= amount); 
        require (amount > 0);
        
        require(tanks[_tankID].tankOwner.send(amount));
        tanks[_tankID].earningsIndex = numTanks;
        
        EventCashOutTank (msg.sender, amount);
    }
    
    // 0 -> health, 1 -> attack, 2 -> armor, 3 -> speed
    function upgradeTank (uint256 _tankID, uint8 _upgradeChoice) public payable {
        // validity checks
        require (_tankID > 0 && _tankID < newTankID); 
        require (tanks[_tankID].tankOwner == msg.sender); 
        require (!tanks[_tankID].inAuction);
        require (!tanks[_tankID].inBattle);
        require (_upgradeChoice >= 0 && _upgradeChoice < 4); 
        
        // no overflow!
        require(tanks[_tankID].upgrades[_upgradeChoice] + 1 > tanks[_tankID].upgrades[_upgradeChoice]);

        uint256 upgradePrice = baseTanks[tanks[_tankID].typeID].startPrice / 4;
        require (msg.value >= upgradePrice); 

        tanks[_tankID].upgrades[_upgradeChoice]++; 

        if(msg.value > upgradePrice){
            balances[msg.sender] += msg.value-upgradePrice; 
        }

        uint256 tournamentProceeds = (upgradePrice * tournamentTaxRate) / 100;

        balances[owner] += (upgradePrice - tournamentProceeds); 
        tournamentAmt += tournamentProceeds;
        
        EventUpgradeTank (msg.sender, _tankID, _upgradeChoice);
    }

    function battle(uint256 _tankID) public payable {
        require(_tankID >0 && _tankID < newTankID);
        require(tanks[_tankID].tankOwner == msg.sender);
        require(!tanks[_tankID].inAuction);
        require(!tanks[_tankID].inBattle);
        require(msg.value >= battleFee);

        if(msg.value > battleFee){
            balances[msg.sender] += (msg.value - battleFee);
        }

        tournamentAmt += battleFee;
        
        EventJoinedBattle(msg.sender, _tankID);

        // upgrade from exp
        if(tanks[_tankID].exp == 5){
            tanks[_tankID].upgrades[tanks[_tankID].next++]++;
            tanks[_tankID].exp = 0;
            if(tanks[_tankID].next == 4){
                tanks[_tankID].next = 0;
            }
        }

        // add to teams
        if(battleTeams.length < 2*teamSize - 1){
            battleTeams.push(_tankID);
            tanks[_tankID].inBattle = true;

        // time to battle!
        } else {
            battleTeams.push(_tankID);

            uint256[4] memory teamA;
            uint256[4] memory teamB;
            uint256[4] memory temp;

            for(uint i=0; i<teamSize; i++){
                temp = getCurrentStats(battleTeams[i]);
                teamA[0] += temp[0];
                teamA[1] += temp[1];
                teamA[2] += temp[2];
                teamA[3] += temp[3];

                temp = getCurrentStats(battleTeams[teamSize+i]);
                teamB[0] += temp[0];
                teamB[1] += temp[1];
                teamB[2] += temp[2];
                teamB[3] += temp[3];
            }

            // lower score is better
            uint256 diffA = teamA[1] - teamB[2];
            uint256 diffB = teamB[1] - teamA[2];
            
            diffA = diffA > 0 ? diffA : 1;
            diffB = diffB > 0 ? diffB : 1;

            uint256 teamAScore = teamB[0] / (diffA * teamA[3]);
            uint256 teamBScore = teamA[0] / (diffB * teamB[3]);

            if((teamB[0] % (diffA * teamA[3])) != 0) {
                teamAScore += 1;
            }

            if((teamA[0] % (diffB * teamB[3])) != 0) {
                teamBScore += 1;
            }

            uint256 toDistribute = tournamentAmt / teamSize;
            tournamentAmt -= teamSize*toDistribute;

            if(teamAScore <= teamBScore){
                for(i=0; i<teamSize; i++){
                    balances[tanks[battleTeams[i]].tankOwner] += toDistribute;   
                }
            } else {
                for(i=0; i<teamSize; i++){
                    balances[tanks[battleTeams[teamSize+i]].tankOwner] += toDistribute;   
                }
                   
            }

            for(i=0; i<2*teamSize; i++){
                tanks[battleTeams[i]].inBattle = false;
                tanks[battleTeams[i]].exp++;
            }

            EventBattleOver();

            battleTeams.length = 0;
        }
    }

    function quitBattle(uint256 _tankID) public {
        require(_tankID >0 && _tankID < newTankID);
        require(tanks[_tankID].tankOwner == msg.sender);
        require(tanks[_tankID].inBattle);
        
        uint l = battleTeams.length;

        for(uint i=0; i<l; i++){
            if(battleTeams[i] == _tankID){
                EventQuitBattle(msg.sender, _tankID);

                delete battleTeams[i];
                battleTeams[i] = battleTeams[l-1];
                battleTeams.length = l-1;
                tanks[_tankID].inBattle = false;

                return;
            }
        }
    }

    // CONVENIENCE GETTER METHODS
    
    function getCurrAuctionPriceTankID (uint256 _tankID) public constant returns (uint256 price){
        require (tanks[_tankID].inAuction);
        uint256 auctionID = tanks[_tankID].currAuction;

        return getCurrAuctionPriceAuctionID(auctionID);
    }
    
    function getPlayerBalance(address _playerID) public constant returns (uint256 balance){
        return balances[_playerID];
    }
    
    function getContractBalance() public constant isOwner returns (uint256){
        return this.balance;
    }

    function getTankOwner(uint256 _tankID) public constant returns (address) {
        require(_tankID > 0 && _tankID < newTankID);
        return tanks[_tankID].tankOwner;
    }

    function getOwnedTanks(address _add) public constant returns (uint256[]){
        return userTanks[_add];
    }

    function getTankType(uint256 _tankID) public constant returns (uint256) {
        require(_tankID > 0 && _tankID < newTankID);
        return tanks[_tankID].typeID;
    }

    function getCurrTypePrice(uint256 _typeID) public constant returns (uint256) {
        require(_typeID > 0 && _typeID < newTypeID);
        return baseTanks[_typeID].currPrice;
    }

    function getNumTanksType(uint256 _typeID) public constant returns (uint256) {
        require(_typeID > 0 && _typeID < newTypeID);
        return baseTanks[_typeID].numTanks;
    }
    
    function getNumTanks() public constant returns(uint256){
        return newTankID-1;
    }

    function checkTankAuction(uint256 _tankID) public constant returns (bool) {
        require(0 < _tankID && _tankID < newTankID);
        return tanks[_tankID].inAuction;
    }

    function getCurrAuctionPriceAuctionID(uint256 _auctionID) public constant returns (uint256){
        require(_auctionID > 0 && _auctionID < newAuctionID);

        AuctionObject memory currAuction = auctions[_auctionID];

        // calculate the current auction price       
        uint256 currPrice = currAuction.startPrice;
        uint256 diff = ((currAuction.startPrice-currAuction.endPrice) / (currAuction.duration)) * (now-currAuction.startTime);


        if (currPrice-diff < currAuction.endPrice || diff > currPrice){ 
            currPrice = currAuction.endPrice;  
        } else {
            currPrice -= diff;
        }

        return currPrice;
    }

    // returns [tankID, currPrice, alive]
    function getAuction(uint256 _auctionID) public constant returns (uint256[3]){
        require(_auctionID > 0 && _auctionID < newAuctionID);

        uint256 tankID = auctions[_auctionID].tank;
        uint256 currPrice = getCurrAuctionPriceAuctionID(_auctionID);
        bool alive = auctions[_auctionID].alive;

        uint256[3] memory out;
        out[0] = tankID;
        out[1] = currPrice;
        out[2] = alive ? 1 : 0;

        return out;
    }
 
    function getUpgradePrice(uint256 _tankID) public constant returns (uint256) {
        require(_tankID >0 && _tankID < newTankID);
        return baseTanks[tanks[_tankID].typeID].startPrice / 4;
    }

    // [health, attack, armor, speed]
    function getUpgradeAmt(uint256 _tankID) public constant returns (uint8[4]) {
        require(_tankID > 0 && _tankID < newTankID);

        return tanks[_tankID].upgrades;
    }

    // [health, attack, armor, speed]
    function getCurrentStats(uint256 _tankID) public constant returns (uint256[4]) {
        require(_tankID > 0 && _tankID < newTankID);

        TankType memory baseType = baseTanks[tanks[_tankID].typeID];
        uint8[4] memory upgrades = tanks[_tankID].upgrades;
        uint256[4] memory out;

        out[0] = baseType.baseHealth + (upgrades[0] * baseType.baseHealth / 4);
        out[1] = baseType.baseAttack + upgrades[1]; 
        out[2] = baseType.baseArmor + upgrades[2];
        out[3] = baseType.baseSpeed + upgrades[3];
        
        return out;
    }

    function inBattle(uint256 _tankID) public constant returns (bool) {
        require(_tankID > 0 && _tankID < newTankID);
        return tanks[_tankID].inBattle;
    }

    function getCurrTeamSizes() public constant returns (uint) {
        return battleTeams.length;
    }

    function getBattleTeamSize() public constant returns (uint8) {
        return teamSize;
    }

    function donate() public payable {
        require(msg.value > 0);
        tournamentAmt += msg.value;
    }

    function getTournamentAmt() public constant returns (uint256) {
        return tournamentAmt;
    }

    function getBattleFee() public constant returns (uint256){
        return battleFee;
    }

    function getTournamentRate() public constant returns (uint8){
        return tournamentTaxRate;
    }

    function getCurrFeeRate() public constant returns (uint8) {
        return feeAmt;
    }
    
    // [startPrice, currPrice, earnings, baseHealth, baseAttack, baseArmor, baseSpeed, numTanks] 
    function getBaseTypeStats(uint256 _typeID) public constant returns (uint256[8]){
        require(0 < _typeID && _typeID < newTypeID);
        uint256[8] memory out;

        out[0] = baseTanks[_typeID].startPrice;
        out[1] = baseTanks[_typeID].currPrice;
        out[2] = baseTanks[_typeID].earnings;
        out[3] = baseTanks[_typeID].baseHealth;
        out[4] = baseTanks[_typeID].baseAttack;
        out[5] = baseTanks[_typeID].baseArmor;
        out[6] = baseTanks[_typeID].baseSpeed;
        out[7] = baseTanks[_typeID].numTanks;

        return out;
    }

    function getCashOutAmount(uint256 _tankID) public constant returns (uint256) {
        require(0 < _tankID && _tankID < newTankID);

        uint256 tankType = tanks[_tankID].typeID;
        uint256 earnings = baseTanks[tankType].earnings;
        uint256 earningsIndex = tanks[_tankID].earningsIndex;
        uint256 numTanks = baseTanks[tankType].numTanks;

        return earnings * (numTanks - earningsIndex);
    }

    // returns [exp, next]
    function getExp(uint256 _tankID) public constant returns (uint8[2]){
        require(0<_tankID && _tankID < newTankID);

        uint8[2] memory out;
        out[0] = tanks[_tankID].exp;
        out[1] = tanks[_tankID].next;

        return out;
    }
}