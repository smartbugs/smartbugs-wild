contract Etherization {
    
    // 1 eth starting price
    uint public START_PRICE = 1000000000000000000;
    // 0.8 eth city build price
    uint public CITY_PRICE = 800000000000000000;
    // 0.5 eth building build price
    uint public BUILDING_PRICE = 500000000000000000;
    // 0.2 eth unit build price
    uint public UNIT_PRICE = 200000000000000000;
    // 0.02 eth unit maintenance price
    uint public MAINT_PRICE = 20000000000000000;
    // 0.1 eth min withdraw amount to prevent spam
    uint public MIN_WTH = 100000000000000000;
    
    // minimum time to wait between moves in seconds
    uint public WAIT_TIME = 14400;
    uint MAP_ROWS = 34;
    uint MAP_COLS = 34;
    
    
    struct City {
        uint owner;
        string name;
        // 0 - quarry, 1 - farm, 2 - woodworks, 3 - metalworks, 4 -stables
        bool[5] buildings;
        // 1 - pikemen, 2 - swordsmen, 3 - horsemen
        uint[10] units; //maximum num of units per city 10
        uint[2] rowcol;
        int previousID;
        int nextID;
    }
    
    struct Player {
        // Player address
        address etherAddress;
        // Their name
        string name;
        // Their treasury balance
        uint treasury;
        // Their capitol
        uint capitol;
        // Number of cities the player has under control
        uint numCities;
        uint numUnits;
        // When was their last move (based on block.timestamp)
        uint lastTimestamp;
    }
    
    Player player;
    Player[] public players;
    uint public numPlayers = 0;
    
    mapping(address => uint) playerIDs;
    mapping(uint => uint) public playerMsgs;
    
    City city;
    City[] public cities;
    uint public numCities = 0;
    
    uint[] public quarryCities;
    uint[] public farmCities;
    uint[] public woodworksCities;
    uint[] public metalworksCities;
    uint[] public stablesCities;
    
    uint[34][34] public map;

    address wizardAddress;
    
    address utilsAddress;
    address utilsAddress2;
    
    // Sum of all players' balances
    uint public totalBalances = 0;

    // Used to ensure only the owner can do some things.
    modifier onlywizard { if (msg.sender == wizardAddress) _ }
    
    // Used to ensure only the utils contract can do some things.
    modifier onlyutils { if (msg.sender == utilsAddress || msg.sender == utilsAddress2) _ }



    // Sets up defaults.
    function Etherization() {
        wizardAddress = msg.sender;
    }

    function start(string playerName, string cityName, uint row, uint col, uint rowref, uint colref) {
        
        
        // If they paid too little, reject and refund their money.
        if (msg.value < START_PRICE) {
            //msg.sender.send(msg.value);
            //playerMsgs[msg.sender] = "Not enough ether sent to found a city and start playing. Sending back any eth sent...";
            return;
        }
        // If the player already exists
        if (playerIDs[msg.sender] > 0) {
            //msg.sender.send(msg.value);
            //playerMsgs[msg.sender] =  "You already founded an etherization. Lookup your player ID by calling getMyPlayerID(). Sending back any eth sent...";
            return;
        }
        
        player.etherAddress = msg.sender;
        player.name = playerName;
        player.treasury = msg.value;
        totalBalances += msg.value;
        player.capitol = numCities;
        player.numCities = 1;
        player.numUnits = 1;

        players.push(player);
        
        city.owner = numPlayers;
        city.name = cityName;
        // the first city in the game has a quarry and a farm by default
        if(numCities <= 0) {
            city.buildings[0] = true;
            quarryCities.push(0);
            city.buildings[1] = true;
            farmCities.push(0);
            city.rowcol[0] = 10;
            city.rowcol[1] = 10;
            map[10][10] = numPlayers+1;
        } else {
            city.buildings[0] = false;
            city.buildings[1] = false;
            if(row>33 || col>33 || rowref>33 || colref>33 || int(row)-int(rowref) > int(1) || int(row)-int(rowref) < int(-1) || int(col)-int(colref) > int(1) || int(col)-int(colref) < int(-1) || map[row][col]>0 || map[rowref][colref]<=0) {
                throw;
            }
            city.rowcol[0] = row;
            city.rowcol[1] = col;
            map[row][col] = numPlayers+1;
            
            players[numPlayers].treasury -= START_PRICE;
            // distribute build funds to production type building owners
            uint productionCut;
            uint i;
            productionCut = START_PRICE / quarryCities.length;
            for(i=0; i < quarryCities.length; i++) {
                players[cities[quarryCities[i]].owner].treasury += productionCut;
            }
        }
        city.units[0] = 1;  //pikemen guards a city by default
        city.previousID = -1;
        city.nextID = -1;
        
        cities.push(city);
        
        playerIDs[msg.sender] = numPlayers+1; //to distinguish it from the default 0
        numPlayers++;
        numCities++;
        
        playerMsgs[playerIDs[msg.sender]-1] = 1 + row*100 + col*10000;
        players[numPlayers-1].lastTimestamp = now;
    }
    
    function deposit() {
        players[playerIDs[msg.sender]-1].treasury += msg.value;
        totalBalances += msg.value;
    }
    
    function withdraw(uint amount) {
        if(int(playerIDs[msg.sender])-1 < 0) {
            throw;
        }
        uint playerID = playerIDs[msg.sender]-1;
        if(timePassed(playerID) < WAIT_TIME) {
            playerMsgs[playerIDs[msg.sender]-1] = 2;
            return;        
        }
        if(amount < players[playerID].treasury && amount > MIN_WTH) {
            players[playerID].treasury -= amount;
            totalBalances -= amount;
            players[playerID].etherAddress.send((amount*99)/100); //keep 1% as commission
        }
    }
    
    
    
    function getMyPlayerID() constant returns (int ID) {
        return int(playerIDs[msg.sender])-1;
    }
    
    function getMyMsg() constant returns (uint s) {
        return playerMsgs[playerIDs[msg.sender]-1];
    }
    
    function getCity(uint cityID) constant returns (uint owner, string cityName, bool[5] buildings, uint[10] units, uint[2] rowcol, int previousID, int nextID) {
        return (cities[cityID].owner, cities[cityID].name, cities[cityID].buildings, cities[cityID].units, cities[cityID].rowcol, cities[cityID].previousID, cities[cityID].nextID);
    }
    
    
    function timePassed(uint playerID) constant returns (uint tp) {
        return (now - players[playerID].lastTimestamp);
    }


    // Used only by the wizard to check his commission.
    function getCommission() onlywizard constant returns (uint com) {
        return this.balance-totalBalances;
    }

    // Used only by the wizard to collect his commission.
    function sweepCommission(uint amount) onlywizard {
        if(amount < this.balance-totalBalances) {
            wizardAddress.send(amount);
        }
    }
    
    
    
    function setUtils(address a) onlywizard {
        utilsAddress = a;
    }
    
    function setUtils2(address a) onlywizard {
        utilsAddress2 = a;
    }
    
    function getPlayerID(address sender) onlyutils constant returns (uint playerID) {
        if(int(playerIDs[sender])-1 < 0) {
            throw;
        }
        return playerIDs[sender]-1;
    }
    
    function getWwLength() constant returns (uint length) {
        return woodworksCities.length;
    }
    
    function getMwLength() constant returns (uint length) {
        return metalworksCities.length;
    }
    
    function getStLength() constant returns (uint length) {
        return stablesCities.length;
    }
    
    function getFmLength() constant returns (uint length) {
        return farmCities.length;
    }
    
    function getQrLength() constant returns (uint length) {
        return quarryCities.length;
    }
    
    
    function setMsg(address sender, uint s) onlyutils {
        playerMsgs[playerIDs[sender]-1] = s;
    }
    
    function setNumCities(uint nc) onlyutils {
        numCities = nc;
    }
    
    function setUnit(uint cityID, uint i, uint unitType) onlyutils {
        cities[cityID].units[i] = unitType;
    }
    
    function setOwner(uint cityID, uint owner) onlyutils {
        cities[cityID].owner = owner;
    }
    
    function setName(uint cityID, string name) onlyutils {
        cities[cityID].name = name;
    }
    
    function setPreviousID(uint cityID, int previousID) onlyutils {
        cities[cityID].previousID = previousID;
    }
    
    function setNextID(uint cityID, int nextID) onlyutils {
        cities[cityID].nextID = nextID;
    }
    
    function setRowcol(uint cityID, uint[2] rowcol) onlyutils {
        cities[cityID].rowcol = rowcol;
    }
    
    function setMap(uint row, uint col, uint ind) onlyutils {
        map[row][col] = ind;
    }
    
    function setCapitol(uint playerID, uint capitol) onlyutils {
        players[playerID].capitol = capitol;
    }

    function setNumUnits(uint playerID, uint numUnits) onlyutils {
        players[playerID].numUnits = numUnits;
    }
    
    function setNumCities(uint playerID, uint numCities) onlyutils {
        players[playerID].numCities = numCities;
    }
    
    function setTreasury(uint playerID, uint treasury) onlyutils {
        players[playerID].treasury = treasury;
    }
    
    function setLastTimestamp(uint playerID, uint timestamp) onlyutils {
        players[playerID].lastTimestamp = timestamp;
    }
    
    function setBuilding(uint cityID, uint buildingType) onlyutils {
        cities[cityID].buildings[buildingType] = true;
        if(buildingType == 0) {
            quarryCities.push(cityID);
        } else if(buildingType == 1) {
            farmCities.push(cityID);
        } else if(buildingType == 2) {
            woodworksCities.push(cityID);
        } else if(buildingType == 3) {
            metalworksCities.push(cityID);
        } else if(buildingType == 4) {
            stablesCities.push(cityID);
        }
    }
    
    function pushCity() onlyutils {
        city.buildings[0] = false;
        city.buildings[1] = false;
        cities.push(city);
    }

}





contract EtherizationUtils {
    
    //uint[2] sRowcol;
    //uint[2] tRowcol;
    
    Etherization public e;
    
    address wizardAddress;
    
    // Used to ensure only the owner can do some things.
    modifier onlywizard { if (msg.sender == wizardAddress) _ }
    
    
    function EtherizationUtils() {
        wizardAddress = msg.sender;
    }
    
    function sete(address a) onlywizard {
        e = Etherization(a);
    }
    
    
    function buyBuilding(uint cityID, uint buildingType) {
        uint playerID = e.getPlayerID(msg.sender);
        
        if(e.timePassed(playerID) < e.WAIT_TIME()) {
            e.setMsg(msg.sender, 2);
            return;        
        }
        
        uint owner;
        (owner,) = e.cities(cityID);
        if(playerID != owner || cityID > e.numCities()-1) {
            e.setMsg(msg.sender, 3);
            return;
        }
        if(buildingType<0 || buildingType>4) {
            e.setMsg(msg.sender, 4);
            return;            
        }
        bool[5] memory buildings;
        uint[2] memory rowcol;
        (,,buildings,,rowcol,,) = e.getCity(cityID);
        if(buildings[buildingType]) {
            e.setMsg(msg.sender, 5);
            return; 
        }
        uint treasury;
        (,,treasury,,,,) = e.players(owner);
        if(treasury < e.BUILDING_PRICE()) {
            e.setMsg(msg.sender, 6);
            return;
        }

        e.setTreasury(playerID, treasury-e.BUILDING_PRICE());
        
        // distribute build funds to production type building owners
        uint productionCut;
        uint i;
        productionCut = e.BUILDING_PRICE() / e.getQrLength();
        for(i=0; i < e.getQrLength(); i++) {
           (owner,) = e.cities(e.quarryCities(i));
           (,,treasury,,,,) = e.players(owner);
           e.setTreasury(owner, treasury+productionCut);
        }

        e.setBuilding(cityID, buildingType);
        
        e.setMsg(msg.sender, 7 + rowcol[0]*100 + rowcol[1]*10000);
        e.setLastTimestamp(playerID, now);
    }
    
    function buyUnit(uint cityID, uint unitType) {
        uint playerID = e.getPlayerID(msg.sender);
        
        if(e.timePassed(playerID) < e.WAIT_TIME()) {
            e.setMsg(msg.sender, 2);
            return;        
        }
        
        uint owner;
        (owner,) = e.cities(cityID);
        if(playerID != owner || cityID > e.numCities()-1) {
            e.setMsg(msg.sender, 8);
            return;
        }
        if(unitType<1 || unitType>3) {
            e.setMsg(msg.sender, 9);
            return;            
        }
        uint numUnits;
        uint treasury;
        (,,treasury,,,numUnits,) = e.players(owner);
        uint maint = numUnits*e.MAINT_PRICE();
        if(treasury < e.UNIT_PRICE() + maint) {
            e.setMsg(msg.sender, 10);
            return;
        }
        if(unitType==1&&e.getWwLength()==0 || unitType==2&&e.getMwLength()==0 || unitType==3&&e.getStLength()==0) {
            e.setMsg(msg.sender, 11);
            return;
        }
        // try to add the unit at the last empty garrison spot
        uint[10] memory units;
        uint[2] memory rowcol;
        (,,,units,rowcol,,) = e.getCity(cityID);
        for(uint i=0; i < units.length; i++) {
            if(units[i] < 1) {
               e.setUnit(cityID, i, unitType);
               e.setNumUnits(playerID, numUnits+1);
               e.setTreasury(playerID, treasury-e.UNIT_PRICE()-maint);
               // distribute build funds to production type building owners
               uint productionCut;
               uint j;
               // pikemen
               if(unitType == 1) {
                   productionCut = e.UNIT_PRICE() / e.getWwLength();
                   for(j=0; j < e.getWwLength(); j++) {
                       (owner,) = e.cities(e.woodworksCities(j));
                       (,,treasury,,,,) = e.players(owner);
                       e.setTreasury(owner, treasury+productionCut);
                   }
               }
               else if(unitType == 2) {
                   productionCut = e.UNIT_PRICE() / e.getMwLength();
                   for(j=0; j < e.getMwLength(); j++) {
                       (owner,) = e.cities(e.metalworksCities(j));
                       (,,treasury,,,,) = e.players(owner);
                       e.setTreasury(owner, treasury+productionCut);
                   }
               }
               else if(unitType == 3) {
                   productionCut = e.UNIT_PRICE() / e.getStLength();
                   for(j=0; j < e.getStLength(); j++) {
                       (owner,) = e.cities(e.stablesCities(j));
                       (,,treasury,,,,) = e.players(owner);
                       e.setTreasury(owner, treasury+productionCut);
                   }
               }
               // pay maintenance for all other units to farm owners
               uint maintCut = maint / e.getFmLength();
               for(j=0; j < e.getFmLength(); j++) {
                   (owner,) = e.cities(e.farmCities(j));
                   (,,treasury,,,,) = e.players(owner);
                   e.setTreasury(owner, treasury+maintCut);
               }
               e.setMsg(msg.sender, 12 + rowcol[0]*100 + rowcol[1]*10000);
               e.setLastTimestamp(playerID, now);
               return;
            }
        }
        e.setMsg(msg.sender, 13);
    }
    
    function moveUnits(uint source, uint target, uint[] unitIndxs) {
        uint[2] memory sRowcol;
        uint[2] memory tRowcol;
        uint[10] memory unitsS;
        uint[10] memory unitsT;
        
        uint playerID = e.getPlayerID(msg.sender);
        
        if(e.timePassed(playerID) < e.WAIT_TIME()) {
            e.setMsg(msg.sender, 2);
            return;        
        }

        uint ownerS;
        uint ownerT;
        (ownerS,,,unitsS,sRowcol,,) = e.getCity(source);
        (ownerT,,,unitsT,tRowcol,,) = e.getCity(target);
        if(playerID != ownerS || playerID != ownerT || int(sRowcol[0])-int(tRowcol[0]) > int(1) || int(sRowcol[0])-int(tRowcol[0]) < int(-1) || int(sRowcol[1])-int(tRowcol[1]) > int(1) || int(sRowcol[1])-int(tRowcol[1]) < int(-1)) {
        //if(playerID != ownerS || playerID != ownerT || source > e.numCities()-1 || target > e.numCities()-1) {
        //if(playerID != ownerS || playerID != ownerT) {    
            e.setMsg(msg.sender, 14);
            return;
        }
        
        uint j = 0;
        for(uint i=0; i<unitIndxs.length; i++) {
            if(unitsS[unitIndxs[i]] < 1) {
                continue;   //skip for non-unit
            }
            for(; j<unitsT.length; j++) {
                if(unitsT[j] == 0) {
                    e.setUnit(target, j, unitsS[unitIndxs[i]]);
                    unitsS[unitIndxs[i]] = 0;
                    e.setUnit(source, unitIndxs[i], 0);
                    j++;
                    break;
                }
            }
            if(j == unitsT.length) {
                e.setMsg(msg.sender, 15);
                e.setLastTimestamp(playerID, now);
                return; //target city garrison filled
            }
        }
        e.setMsg(msg.sender, 16);
        e.setLastTimestamp(playerID, now);
    }
    
}