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

contract TrainingField is AccessControl{
    // Addresses for other contracts realm interacts with. 
    address public angelCardDataContract;
    address public petCardDataContract;
    address public accessoryDataContract;
    
    // events
     event EventSuccessfulTraining(uint64 angelId,uint64 pet1ID,uint64 pet2ID);
    

    /*** DATA TYPES ***/


    struct Angel {
        uint64 angelId;
        uint8 angelCardSeriesId;
        address owner;
        uint16 battlePower;
        uint8 aura;
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
    

    // write functions
    function SetAngelCardDataContact(address _angelCardDataContract) onlyCREATOR external {
        angelCardDataContract = _angelCardDataContract;
    }
    function SetPetCardDataContact(address _petCardDataContract) onlyCREATOR external {
        petCardDataContract = _petCardDataContract;
    }
       
        function checkTraining (uint64 angelID, uint64  pet1ID, uint64 pet2ID) private returns (uint8) {
              IAngelCardData angelCardData = IAngelCardData(angelCardDataContract);
              IPetCardData petCardData = IPetCardData(petCardDataContract);
        
        //check if training function has improper parameters 
        if (pet1ID == pet2ID) {return 0;}
        if ((pet1ID <= 0) || (pet1ID > petCardData.getTotalPets())) {return 0;}
        if ((pet2ID <= 0) || (pet2ID > petCardData.getTotalPets())) {return 0;}
        if ((angelID <= 0) || (angelID > angelCardData.getTotalAngels())) {return 0;}
        return 1;
}

        function Train (uint64 angelID, uint64  pet1ID, uint64 pet2ID) external  {
        uint8 canTrain = checkTraining(angelID, pet1ID, pet2ID);
        if (canTrain == 0 ) {revert();}
        IAngelCardData angelCardData = IAngelCardData(angelCardDataContract);
        IPetCardData petCardData = IPetCardData(petCardDataContract);
        
        Pet memory pet1;
        Pet memory pet2;
        Angel memory angel;
        (,,,angel.aura,,,,,,,angel.owner) = angelCardData.getAngel(angelID);
        (,,,,pet1.auraRed,pet1.auraBlue,pet1.auraYellow,pet1.lastTrainingTime,,pet1.owner) = petCardData.getPet(pet1ID);
        (,,,,pet2.auraRed,pet2.auraBlue,pet2.auraYellow,pet2.lastTrainingTime,,pet2.owner) = petCardData.getPet(pet2ID);
     
     //can't train with someone else's pets. 
     if ((angel.owner != msg.sender) || (pet1.owner != msg.sender) || (pet2.owner!= msg.sender)) {revert();}
     //check that you haven't trained for 24 hours 24 *60 * 60 
     if ((now < (pet1.lastTrainingTime+86400)) || (now < (pet1.lastTrainingTime+60))) {revert();}
    
    //AngelRed is a 0 when the angel�s aura isnt� compatible with Red and 1 when it is. 
 
    uint32 AngelRed = 0;
    uint32 AngelBlue = 0;
    uint32 AngelYellow = 0;
 
    if ((angel.aura == 4) || (angel.aura == 3) || (angel.aura == 2)) {AngelRed = 1;} 
    if ((angel.aura == 0) || (angel.aura == 2) || (angel.aura == 5)) {AngelBlue = 1;}
    if ((angel.aura == 3) || (angel.aura == 1) || (angel.aura == 5)) {AngelYellow = 1;}

    //You can�t Gain new aura colors, only strengthen the ones you have, so first make sure it HAS a red Aura before increasing it. 
    
   
    
    //Set Results
    petCardData.setPetAuras(pet1ID,uint8(findAuras(pet1.auraRed, pet1.auraRed,pet2.auraRed, AngelRed)),uint8(findAuras(pet1.auraBlue, pet1.auraBlue,pet2.auraBlue, AngelBlue)), uint8(findAuras(pet1.auraYellow, pet1.auraYellow,pet2.auraYellow, AngelYellow)) );
     petCardData.setPetAuras(pet2ID,uint8(findAuras(pet2.auraRed, pet1.auraRed,pet2.auraRed, AngelRed)),uint8(findAuras(pet2.auraBlue, pet1.auraBlue,pet2.auraBlue, AngelBlue)), uint8(findAuras(pet2.auraYellow, pet1.auraYellow,pet2.auraYellow, AngelYellow)) );
    petCardData.setPetLastTrainingTime(pet1ID);
    petCardData.setPetLastTrainingTime(pet2ID);
   EventSuccessfulTraining(angelID, pet1ID, pet2ID);


        } 
        
         function findAuras (uint16 petBaseAura, uint32 pet1Aura, uint32 pet2Aura, uint32 angelAura) private returns (uint32) {
        //Increase by 1 if there is one compatible pet and 2 if there are two. 
         if ((petBaseAura >=250) || (petBaseAura == 0)) {return petBaseAura;}
         //max value allowed. 
         if ((pet1Aura != 0) && (angelAura == 1)) {
         if (pet2Aura != 0) {return petBaseAura + 2;}
        else {return petBaseAura + 1;}
        }
        return petBaseAura;    
        
    }
        
      function kill() onlyCREATOR external {
        selfdestruct(creatorAddress);
    }
}