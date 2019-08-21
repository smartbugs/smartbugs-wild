pragma solidity ^0.4.18;

/**
 * @title ERC721 interface
 * @dev see https://github.com/ethereum/eips/issues/721
 */


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
 
contract PetWrapper721 is AccessControl, Enums {
  //Events
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event MarketplaceTransfer(address indexed _from, address indexed _to, uint256 _tokenId, address _marketplace);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);


//Storage
 
   
    address public petCardDataContract =0xB340686da996b8B3d486b4D27E38E38500A9E926;
    
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
    }




    
    function SetPetCardDataContact(address _petCardDataContract) onlyCREATOR external {
       petCardDataContract = _petCardDataContract;
    }

  function balanceOf(address _owner) public view returns (uint256 _balance) {
         IPetCardData petCardData = IPetCardData(petCardDataContract);
           return petCardData.getOwnerPetCount(_owner);
  }
  
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
            IPetCardData petCardData = IPetCardData(petCardDataContract);
            address owner;
             (,,,,,,,,, owner) = petCardData.getPet(uint64(_tokenId));
            return owner;
  }
  
  function getTokenByIndex (address _owner, uint index) constant public returns (uint64) {
      //returns the angel number of the index-th item in that addresses angel list. 
         IPetCardData petCardData = IPetCardData(petCardDataContract);
        return uint64(petCardData.getPetByIndex(_owner, index));
        
  }
	

     function getPet(uint _petId) constant public returns(uint petId, uint8 petCardSeriesId, uint8 luck, uint16 auraRed, uint16 auraBlue, uint16 auraYellow, address owner) {
         IPetCardData petCardData = IPetCardData(petCardDataContract);
         (petId,petCardSeriesId,,luck, auraRed, auraBlue, auraYellow,, , owner) = petCardData.getPet(_petId);

    }
	
        
        
       
    
    function getTokenLockStatus(uint64 _tokenId) constant public returns (bool) {
       return false;
       //lock is not implemented for pet tokens. 
       
    }
    
 
  function transfer(address _to, uint256 _tokenId) public {
      
        IPetCardData petCardData = IPetCardData(petCardDataContract);
       address owner;
         (,,,,,,,,,owner) = petCardData.getPet(_tokenId);
      
       if ((seraphims[msg.sender] == true)  || (owner == msg.sender))
       {
         petCardData.transferPet(owner,_to, uint64 (_tokenId)) ;
         Transfer(owner, _to, _tokenId);
         MarketplaceTransfer(owner,  _to, _tokenId, msg.sender);
           
       }
      else {revert();}
  }
  function approve(address _to, uint256 _tokenId) public
  {
      //this function should never be called - instead, use updateAccessoryLock from the accessoryData contract;
      revert();
      
  }
  function takeOwnership(uint256 _tokenId) public
  { 
     //this function should never be called - instead use transfer
     revert();
  }
    function kill() onlyCREATOR external {
        selfdestruct(creatorAddress);
    }
    }