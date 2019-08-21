pragma solidity ^0.4.17;

contract AccessControl {
    address public creatorAddress;
    uint16 public totalSeraphims = 0;
    mapping (address => bool) public seraphims;

    bool public isMaintenanceMode = true;
 
    modifier onlyCREATOR() {
        require(msg.sender == creatorAddress);
        _;
    }

    modifier onlySERAPHIM() {
        require(seraphims[msg.sender] == true);
        _;
    }
    
    modifier isContractActive {
        require(!isMaintenanceMode);
        _;
    }
    
    // Constructor
    function AccessControl() public {
        creatorAddress = msg.sender;
    }
    

    function addSERAPHIM(address _newSeraphim) onlyCREATOR public {
        if (seraphims[_newSeraphim] == false) {
            seraphims[_newSeraphim] = true;
            totalSeraphims += 1;
        }
    }
    
    function removeSERAPHIM(address _oldSeraphim) onlyCREATOR public {
        if (seraphims[_oldSeraphim] == true) {
            seraphims[_oldSeraphim] = false;
            totalSeraphims -= 1;
        }
    }

    function updateMaintenanceMode(bool _isMaintaining) onlyCREATOR public {
        isMaintenanceMode = _isMaintaining;
    }

  
} 

contract SafeMath {
    function safeAdd(uint x, uint y) pure internal returns(uint) {
      uint z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint x, uint y) pure internal returns(uint) {
      assert(x >= y);
      uint z = x - y;
      return z;
    }

    function safeMult(uint x, uint y) pure internal returns(uint) {
      uint z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

    function getRandomNumber(uint16 maxRandom, uint8 min, address privateAddress) constant public returns(uint8) {
        uint256 genNum = uint256(block.blockhash(block.number-1)) + uint256(privateAddress);
        return uint8(genNum % (maxRandom - min + 1)+min);
    }
}

contract Enums {
    enum ResultCode {
        SUCCESS,
        ERROR_CLASS_NOT_FOUND,
        ERROR_LOW_BALANCE,
        ERROR_SEND_FAIL,
        ERROR_NOT_OWNER,
        ERROR_NOT_ENOUGH_MONEY,
        ERROR_INVALID_AMOUNT
    }

    enum AngelAura { 
        Blue, 
        Yellow, 
        Purple, 
        Orange, 
        Red, 
        Green 
    }
}

contract IAngelCardData is AccessControl, Enums {
    uint8 public totalAngelCardSeries;
    uint64 public totalAngels;

    
    // write
    // angels
    function createAngelCardSeries(uint8 _angelCardSeriesId, uint _basePrice,  uint64 _maxTotal, uint8 _baseAura, uint16 _baseBattlePower, uint64 _liveTime) onlyCREATOR external returns(uint8);
    function updateAngelCardSeries(uint8 _angelCardSeriesId) onlyCREATOR external;
    function setAngel(uint8 _angelCardSeriesId, address _owner, uint _price, uint16 _battlePower) onlySERAPHIM external returns(uint64);
    function addToAngelExperienceLevel(uint64 _angelId, uint _value) onlySERAPHIM external;
    function setAngelLastBattleTime(uint64 _angelId) onlySERAPHIM external;
    function setAngelLastVsBattleTime(uint64 _angelId) onlySERAPHIM external;
    function setLastBattleResult(uint64 _angelId, uint16 _value) onlySERAPHIM external;
    function addAngelIdMapping(address _owner, uint64 _angelId) private;
    function transferAngel(address _from, address _to, uint64 _angelId) onlySERAPHIM public returns(ResultCode);
    function ownerAngelTransfer (address _to, uint64 _angelId)  public;

    // read
    function getAngelCardSeries(uint8 _angelCardSeriesId) constant public returns(uint8 angelCardSeriesId, uint64 currentAngelTotal, uint basePrice, uint64 maxAngelTotal, uint8 baseAura, uint baseBattlePower, uint64 lastSellTime, uint64 liveTime);
    function getAngel(uint64 _angelId) constant public returns(uint64 angelId, uint8 angelCardSeriesId, uint16 battlePower, uint8 aura, uint16 experience, uint price, uint64 createdTime, uint64 lastBattleTime, uint64 lastVsBattleTime, uint16 lastBattleResult, address owner);
    function getOwnerAngelCount(address _owner) constant public returns(uint);
    function getAngelByIndex(address _owner, uint _index) constant public returns(uint64);
    function getTotalAngelCardSeries() constant public returns (uint8);
    function getTotalAngels() constant public returns (uint64);
}


contract AngelCardData is IAngelCardData, SafeMath {
    /*** EVENTS ***/
    event CreatedAngel(uint64 angelId);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /*** DATA TYPES ***/
    struct AngelCardSeries {
        uint8 angelCardSeriesId;
        uint basePrice; 
        uint64 currentAngelTotal;
        uint64 maxAngelTotal;
        AngelAura baseAura;
        uint baseBattlePower;
        uint64 lastSellTime;
        uint64 liveTime;
    }

    struct Angel {
        uint64 angelId;
        uint8 angelCardSeriesId;
        address owner;
        uint16 battlePower;
        AngelAura aura;
        uint16 experience;
        uint price;
        uint64 createdTime;
        uint64 lastBattleTime;
        uint64 lastVsBattleTime;
        uint16 lastBattleResult;
    }

    /*** STORAGE ***/

    mapping(uint8 => AngelCardSeries) public angelCardSeriesCollection;
    mapping(uint64 => Angel) public angelCollection;
    mapping(address => uint64[]) public ownerAngelCollection;
    uint256 public prevSeriesSelloutHours;
    
    /*** FUNCTIONS ***/
    //*** Write Access ***//
    function AngelCardData() public {
        
    }
  

    function createAngelCardSeries(uint8 _angelCardSeriesId, uint _basePrice,  uint64 _maxTotal, uint8 _baseAura, uint16 _baseBattlePower, uint64 _liveTime) onlyCREATOR external returns(uint8) {
         if ((now > 1516692600) || (totalAngelCardSeries >= 24)) {revert();}
        //This confirms that no one, even the develoopers, can create any angel series after JAN/23/2018 @ 7:30 am (UTC) or more than the original 24 series.

        AngelCardSeries storage angelCardSeries = angelCardSeriesCollection[_angelCardSeriesId];
        angelCardSeries.angelCardSeriesId = _angelCardSeriesId;
        angelCardSeries.basePrice = _basePrice; 
        angelCardSeries.maxAngelTotal = _maxTotal;
        angelCardSeries.baseAura = AngelAura(_baseAura);
        angelCardSeries.baseBattlePower = _baseBattlePower;
        angelCardSeries.lastSellTime = 0;
        angelCardSeries.liveTime = _liveTime;

        totalAngelCardSeries += 1;
        return totalAngelCardSeries;
    }

    // This is called every 5 days to set the basePrice and maxAngelTotal for the angel series based on buy pressure of the last card
    function updateAngelCardSeries(uint8 _angelCardSeriesId) onlyCREATOR external {
        // Require that the series is above the Arel card
        if (_angelCardSeriesId < 4) 
            revert();
        //don't need to use safesubtract here because above we already reverted id less than 4. 
        AngelCardSeries memory seriesMinusOne = angelCardSeriesCollection[_angelCardSeriesId - 1];
        AngelCardSeries storage seriesStorage = angelCardSeriesCollection[_angelCardSeriesId];
        //In case no conditions are true, then no change. 
        seriesStorage.maxAngelTotal = seriesMinusOne.maxAngelTotal;
        if (seriesMinusOne.currentAngelTotal >= seriesMinusOne.maxAngelTotal) {
            prevSeriesSelloutHours = (safeSubtract(seriesMinusOne.lastSellTime,seriesMinusOne.liveTime))/3600;
        } else {
            prevSeriesSelloutHours = 120;
        }

        // Set the new basePrice for the angelCardSeries
        //Lower by 0.65 eth if didn't sell out, until min of 0.005 eth
        if (prevSeriesSelloutHours > 100) { 
            if (seriesMinusOne.basePrice > 70000000000000000) 
            {seriesStorage.basePrice = seriesMinusOne.basePrice - 65000000000000000;}
            else {seriesStorage.basePrice = 5000000000000000;}
        }
        //Increase by 0.005 ETH for 100-sell out hours. Price increases faster based on demand. 
        else {seriesStorage.basePrice = seriesMinusOne.basePrice+((100-prevSeriesSelloutHours)*5000000000000000);}
        
        // Adjust the maxTotal for the angelCardSeries
        //Don't need safeMath here because we are already checking values. 
        if (prevSeriesSelloutHours < 100 && seriesMinusOne.maxAngelTotal <= 435) {
            seriesStorage.maxAngelTotal = seriesMinusOne.maxAngelTotal+15;
        } else if (prevSeriesSelloutHours > 100 && seriesMinusOne.maxAngelTotal >= 60) {
            seriesStorage.maxAngelTotal = seriesMinusOne.maxAngelTotal-15;
        }
        // Need to set this incase no cards  sell, so that other calculations don't break
        seriesStorage.lastSellTime = uint64(now);
    }

    function setAngel(uint8 _angelCardSeriesId, address _owner, uint _price, uint16 _battlePower) onlySERAPHIM external returns(uint64) {
        AngelCardSeries storage series = angelCardSeriesCollection[_angelCardSeriesId];
    
        if (series.currentAngelTotal >= series.maxAngelTotal) {
            revert();
        }
       else { 
        totalAngels += 1;
        Angel storage angel = angelCollection[totalAngels];
        series.currentAngelTotal += 1;
        series.lastSellTime = uint64(now);
        angel.angelId = totalAngels;
        angel.angelCardSeriesId = _angelCardSeriesId;
        angel.owner = _owner;
        angel.battlePower = _battlePower; 
        angel.aura = series.baseAura;
        angel.experience = 0;
        angel.price = _price;
        angel.createdTime = uint64(now);
        angel.lastBattleTime = 0;
        angel.lastVsBattleTime = 0;
        angel.lastBattleResult = 0;
        addAngelIdMapping(_owner, angel.angelId);
        return angel.angelId;
       }
    }
     
    function addToAngelExperienceLevel(uint64 _angelId, uint _value) onlySERAPHIM external {
        Angel storage angel = angelCollection[_angelId];
        if (angel.angelId == _angelId) {
            angel.experience = uint16(safeAdd(angel.experience, _value));
        }
    }

    function setAngelLastBattleTime(uint64 _angelId) onlySERAPHIM external {
        Angel storage angel = angelCollection[_angelId];
        if (angel.angelId == _angelId) {
            angel.lastBattleTime = uint64(now);
        }
    }

    function setAngelLastVsBattleTime(uint64 _angelId) onlySERAPHIM external {
        Angel storage angel = angelCollection[_angelId];
        if (angel.angelId == _angelId) {
            angel.lastVsBattleTime = uint64(now);
        }
    }

    function setLastBattleResult(uint64 _angelId, uint16 _value) onlySERAPHIM external {
        Angel storage angel = angelCollection[_angelId];
        if (angel.angelId == _angelId) {
            angel.lastBattleResult = _value;
        }
    }
    
    function addAngelIdMapping(address _owner, uint64 _angelId) private {
            uint64[] storage owners = ownerAngelCollection[_owner];
            owners.push(_angelId);
            Angel storage angel = angelCollection[_angelId];
            angel.owner = _owner;
    }
//Anyone can transfer their own angel by sending a transaction with the address to transfer to from the address that owns it. 
    function ownerAngelTransfer (address _to, uint64 _angelId)  public  {
        
       if ((_angelId > totalAngels) || (_angelId == 0)) {revert();}
       Angel storage angel = angelCollection[_angelId];
        if (msg.sender == _to) {revert();}
        if (angel.owner != msg.sender) {
            revert();
        }
        else {
        angel.owner = _to;
        addAngelIdMapping(_to, _angelId);
        }
    }
    function transferAngel(address _from, address _to, uint64 _angelId) onlySERAPHIM public returns(ResultCode) {
        Angel storage angel = angelCollection[_angelId];
        if (_from == _to) {revert();}
        if (angel.owner != _from) {
            return ResultCode.ERROR_NOT_OWNER;
        }
        angel.owner = _to;
        addAngelIdMapping(_to, _angelId);
        return ResultCode.SUCCESS;
    }

  
   
    //*** Read Access ***//
    function getAngelCardSeries(uint8 _angelCardSeriesId) constant public returns(uint8 angelCardSeriesId, uint64 currentAngelTotal, uint basePrice, uint64 maxAngelTotal, uint8 baseAura, uint baseBattlePower, uint64 lastSellTime, uint64 liveTime) {
        AngelCardSeries memory series = angelCardSeriesCollection[_angelCardSeriesId];
        angelCardSeriesId = series.angelCardSeriesId;
        currentAngelTotal = series.currentAngelTotal;
        basePrice = series.basePrice;
        maxAngelTotal = series.maxAngelTotal;
        baseAura = uint8(series.baseAura);
        baseBattlePower = series.baseBattlePower;
        lastSellTime = series.lastSellTime;
        liveTime = series.liveTime;
    }


    function getAngel(uint64 _angelId) constant public returns(uint64 angelId, uint8 angelCardSeriesId, uint16 battlePower, uint8 aura, uint16 experience, uint price, uint64 createdTime, uint64 lastBattleTime, uint64 lastVsBattleTime, uint16 lastBattleResult, address owner) {
        Angel memory angel = angelCollection[_angelId];
        angelId = angel.angelId;
        angelCardSeriesId = angel.angelCardSeriesId;
        battlePower = angel.battlePower;
        aura = uint8(angel.aura);
        experience = angel.experience;
        price = angel.price;
        createdTime = angel.createdTime;
        lastBattleTime = angel.lastBattleTime;
        lastVsBattleTime = angel.lastVsBattleTime;
        lastBattleResult = angel.lastBattleResult;
        owner = angel.owner;
    }

    function getOwnerAngelCount(address _owner) constant public returns(uint) {
        return ownerAngelCollection[_owner].length;
    }

    function getAngelByIndex(address _owner, uint _index) constant public returns(uint64) {
        if (_index >= ownerAngelCollection[_owner].length) {
            return 0; }
        return ownerAngelCollection[_owner][_index];
    }

    function getTotalAngelCardSeries() constant public returns (uint8) {
        return totalAngelCardSeries;
    }

    function getTotalAngels() constant public returns (uint64) {
        return totalAngels;
    }
}