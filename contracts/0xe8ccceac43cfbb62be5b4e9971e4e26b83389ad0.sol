pragma solidity ^0.4.17;

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



contract IAccessoryData is AccessControl, Enums {
    uint8 public totalAccessorySeries;    
    uint32 public totalAccessories;
    
 
    /*** FUNCTIONS ***/
    //*** Write Access ***//
    function createAccessorySeries(uint8 _AccessorySeriesId, uint32 _maxTotal, uint _price) onlyCREATOR public returns(uint8) ;
	function setAccessory(uint8 _AccessorySeriesId, address _owner) onlySERAPHIM external returns(uint64);
   function addAccessoryIdMapping(address _owner, uint64 _accessoryId) private;
	function transferAccessory(address _from, address _to, uint64 __accessoryId) onlySERAPHIM public returns(ResultCode);
    function ownerAccessoryTransfer (address _to, uint64 __accessoryId)  public;
    
    //*** Read Access ***//
    function getAccessorySeries(uint8 _accessorySeriesId) constant public returns(uint8 accessorySeriesId, uint32 currentTotal, uint32 maxTotal, uint price) ;
	function getAccessory(uint _accessoryId) constant public returns(uint accessoryID, uint8 AccessorySeriesID, address owner);
	function getOwnerAccessoryCount(address _owner) constant public returns(uint);
	function getAccessoryByIndex(address _owner, uint _index) constant public returns(uint) ;
    function getTotalAccessorySeries() constant public returns (uint8) ;
    function getTotalAccessories() constant public returns (uint);
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


contract IPetCardData is AccessControl, Enums {
    uint8 public totalPetCardSeries;    
    uint64 public totalPets;
    
    // write
    function createPetCardSeries(uint8 _petCardSeriesId, uint32 _maxTotal) onlyCREATOR public returns(uint8);
    function setPet(uint8 _petCardSeriesId, address _owner, string _name, uint8 _luck, uint16 _auraRed, uint16 _auraYellow, uint16 _auraBlue) onlySERAPHIM external returns(uint64);
    function setPetAuras(uint64 _petId, uint8 _auraRed, uint8 _auraBlue, uint8 _auraYellow) onlySERAPHIM external;
    function setPetLastTrainingTime(uint64 _petId) onlySERAPHIM external;
    function setPetLastBreedingTime(uint64 _petId) onlySERAPHIM external;
    function addPetIdMapping(address _owner, uint64 _petId) private;
    function transferPet(address _from, address _to, uint64 _petId) onlySERAPHIM public returns(ResultCode);
    function ownerPetTransfer (address _to, uint64 _petId)  public;
    function setPetName(string _name, uint64 _petId) public;

    // read
    function getPetCardSeries(uint8 _petCardSeriesId) constant public returns(uint8 petCardSeriesId, uint32 currentPetTotal, uint32 maxPetTotal);
    function getPet(uint _petId) constant public returns(uint petId, uint8 petCardSeriesId, string name, uint8 luck, uint16 auraRed, uint16 auraBlue, uint16 auraYellow, uint64 lastTrainingTime, uint64 lastBreedingTime, address owner);
    function getOwnerPetCount(address _owner) constant public returns(uint);
    function getPetByIndex(address _owner, uint _index) constant public returns(uint);
    function getTotalPetCardSeries() constant public returns (uint8);
    function getTotalPets() constant public returns (uint);
}

  

   
	

contract Realm is AccessControl, Enums, SafeMath {
    // Addresses for other contracts realm interacts with. 
    address public angelCardDataContract;
    address public petCardDataContract;
    address public accessoryDataContract;
    
    // events
    event EventCreateAngel(address indexed owner, uint64 angelId);
    event EventCreatePet(address indexed owner, uint petId);
     event EventCreateAccessory(address indexed owner, uint accessoryId);
    

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

    struct PetCardSeries {
        uint8 petCardSeriesId;
        uint32 currentPetTotal;
        uint32 maxPetTotal;
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

    struct Pet {
        uint64 petId;
        uint8 petCardSeriesId;
        address owner;
        string name;
        uint8 luck;
        uint16 auraRed;
        uint16 auraYellow;
        uint16 auraBlue;
        uint64 lastTrainingTime;
        uint64 lastBreedingTime;
        uint price; 
        uint64 liveTime;
    }
    
      struct AccessorySeries {
        uint8 AccessorySeriesId;
        uint32 currentTotal;
        uint32 maxTotal;
        uint price;
    }

    struct Accessory {
        uint32 accessoryId;
        uint8 accessorySeriesId;
        address owner;
    }

    // write functions
    function SetAngelCardDataContact(address _angelCardDataContract) onlyCREATOR external {
        angelCardDataContract = _angelCardDataContract;
    }
    function SetPetCardDataContact(address _petCardDataContract) onlyCREATOR external {
        petCardDataContract = _petCardDataContract;
    }
    function SetAccessoryDataContact(address _accessoryDataContract) onlyCREATOR external {
        accessoryDataContract = _accessoryDataContract;
    }


    function withdrawEther() external onlyCREATOR {
    creatorAddress.transfer(this.balance);
}

    //Create each mint of a petCard
     function createPet(uint8 _petCardSeriesId, string _newname) isContractActive external {
        IPetCardData petCardData = IPetCardData(petCardDataContract);
        PetCardSeries memory petSeries;
      
      
        (,petSeries.currentPetTotal, petSeries.maxPetTotal) = petCardData.getPetCardSeries(_petCardSeriesId);

        
        if (petSeries.currentPetTotal >= petSeries.maxPetTotal) { revert ();}
        
        //timechecks - in case people try to interact with the contract directly and get pets before they are available
        if (_petCardSeriesId > 4) {revert();} //Pets higher than 4 come from battle, breeding, or marketplace. 
        if ((_petCardSeriesId == 2) && (now < 1518348600)) {revert();}
        if ((_petCardSeriesId == 3) && (now < 1520076600)) {revert();}
        if ((_petCardSeriesId == 4) && (now < 1521804600)) {revert();}
         
        //first find pet luck
        uint8 _newLuck = getRandomNumber(19, 10, msg.sender);
        
        
        uint16 _auraRed = 0;
        uint16 _auraYellow = 0;
        uint16 _auraBlue = 0;
        
        uint32 _auraColor = getRandomNumber(2,0,msg.sender);
        if (_auraColor == 0) { _auraRed = 2;}
        if (_auraColor == 1) { _auraYellow = 2;}
        if (_auraColor == 2) { _auraBlue = 2;}
        
        uint64 petId = petCardData.setPet(_petCardSeriesId, msg.sender, _newname, _newLuck, _auraRed, _auraYellow, _auraBlue);
        
        EventCreatePet(msg.sender, petId);
    }

 //Create each mint of a Accessory card 
     function createAccessory(uint8 _accessorySeriesId) isContractActive external payable {
        if (_accessorySeriesId > 18) {revert();} 
    IAccessoryData AccessoryData = IAccessoryData(accessoryDataContract);
      AccessorySeries memory accessorySeries;
      (,accessorySeries.currentTotal, accessorySeries.maxTotal, accessorySeries.price) = AccessoryData.getAccessorySeries(_accessorySeriesId);
    if (accessorySeries.currentTotal >= accessorySeries.maxTotal) { revert ();}
      if (msg.value < accessorySeries.price) { revert();}
     uint64 accessoryId = AccessoryData.setAccessory(_accessorySeriesId, msg.sender);
     
     EventCreateAccessory(msg.sender, accessoryId);
    }
    
    
    // created every mint of an angel card
    function createAngel(uint8 _angelCardSeriesId) isContractActive external payable {
        IAngelCardData angelCardData = IAngelCardData(angelCardDataContract);
        AngelCardSeries memory series;
        (, series.currentAngelTotal, series.basePrice, series.maxAngelTotal,,series.baseBattlePower, series.lastSellTime, series.liveTime) = angelCardData.getAngelCardSeries(_angelCardSeriesId);
      
      if ( _angelCardSeriesId > 24) {revert();}
        //Checked here and in angelCardData
        if (series.currentAngelTotal >= series.maxAngelTotal) { revert();}
        if (_angelCardSeriesId > 3) {
            // check is it within the  release schedule
            if (now < series.liveTime) {
            revert();
            }
        }
        // Verify the price paid for card is correct
        if (series.basePrice > msg.value) {revert(); }
        
        // add angel
        uint64 angelId = angelCardData.setAngel(_angelCardSeriesId, msg.sender, msg.value, uint16(series.baseBattlePower+getRandomNumber(10,0,msg.sender)));
        
        EventCreateAngel(msg.sender, angelId);
    }
      function kill() onlyCREATOR external {
        selfdestruct(creatorAddress);
    }
}