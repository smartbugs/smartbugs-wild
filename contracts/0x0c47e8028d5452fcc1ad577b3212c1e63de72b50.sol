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

contract IAngelCardData is AccessControl, Enums {
    uint8 public totalAngelCardSeries;
    uint64 public totalAngels;

    
    // write
    // angels
    function createAngelCardSeries(uint8 _angelCardSeriesId, uint _basePrice,  uint64 _maxTotal, uint8 _baseAura, uint16 _baseBattlePower, uint64 _liveTime) onlyCREATOR external returns(uint8);
    function updateAngelCardSeries(uint8 _angelCardSeriesId, uint64 _newPrice, uint64 _newMaxTotal) onlyCREATOR external;
    function setAngel(uint8 _angelCardSeriesId, address _owner, uint _price, uint16 _battlePower) onlySERAPHIM external returns(uint64);
    function addToAngelExperienceLevel(uint64 _angelId, uint _value) onlySERAPHIM external;
    function setAngelLastBattleTime(uint64 _angelId) onlySERAPHIM external;
    function setAngelLastVsBattleTime(uint64 _angelId) onlySERAPHIM external;
    function setLastBattleResult(uint64 _angelId, uint16 _value) onlySERAPHIM external;
    function addAngelIdMapping(address _owner, uint64 _angelId) private;
    function transferAngel(address _from, address _to, uint64 _angelId) onlySERAPHIM public returns(ResultCode);
    function ownerAngelTransfer (address _to, uint64 _angelId)  public;
    function updateAngelLock (uint64 _angelId, bool newValue) public;
    function removeCreator() onlyCREATOR external;

    // read
    function getAngelCardSeries(uint8 _angelCardSeriesId) constant public returns(uint8 angelCardSeriesId, uint64 currentAngelTotal, uint basePrice, uint64 maxAngelTotal, uint8 baseAura, uint baseBattlePower, uint64 lastSellTime, uint64 liveTime);
    function getAngel(uint64 _angelId) constant public returns(uint64 angelId, uint8 angelCardSeriesId, uint16 battlePower, uint8 aura, uint16 experience, uint price, uint64 createdTime, uint64 lastBattleTime, uint64 lastVsBattleTime, uint16 lastBattleResult, address owner);
    function getOwnerAngelCount(address _owner) constant public returns(uint);
    function getAngelByIndex(address _owner, uint _index) constant public returns(uint64);
    function getTotalAngelCardSeries() constant public returns (uint8);
    function getTotalAngels() constant public returns (uint64);
    function getAngelLockStatus(uint64 _angelId) constant public returns (bool);
}
 
contract AngelWrapper721 is AccessControl, Enums {
  //Events
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event MarketplaceTransfer(address indexed _from, address indexed _to, uint256 _tokenId, address _marketplace);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);


//Storage
 
   
    address public angelCardDataContract = 0x6d2e76213615925c5fc436565b5ee788ee0e86dc;
    
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
        bool ownerLock;
    }




    
    function SetAngelCardDataContact(address _angelCardDataContract) onlyCREATOR external {
       angelCardDataContract = _angelCardDataContract;
    }

  function balanceOf(address _owner) public view returns (uint256 _balance) {
           IAngelCardData angelCardData = IAngelCardData(angelCardDataContract);
           return angelCardData.getOwnerAngelCount(_owner);
  }
  
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
            IAngelCardData angelCardData = IAngelCardData(angelCardDataContract);
            address owner;
        (,,,,,,,,,,owner) = angelCardData.getAngel(uint64(_tokenId));
            return owner;
  }
  
  function getTokenByIndex (address _owner, uint index) constant public returns (uint64) {
      //returns the angel number of the index-th item in that addresses angel list. 
             IAngelCardData angelCardData = IAngelCardData(angelCardDataContract);
        return uint64(angelCardData.getAngelByIndex(_owner, index));
        
  }
	

        
         function getAngel(uint64 _angelId) constant public returns(uint64 angelId, uint8 angelCardSeriesId, uint16 battlePower, uint8 aura, uint16 experience, uint price, address owner) {
        IAngelCardData angelCardData = IAngelCardData(angelCardDataContract);
        (angelId,angelCardSeriesId, battlePower, aura,experience,price,,,,, owner) = angelCardData.getAngel(_angelId);
      
    }
        
        
       
    
    function getTokenLockStatus(uint64 _tokenId) constant public returns (bool) {
       IAngelCardData angelCardData = IAngelCardData(angelCardDataContract);
       return angelCardData.getAngelLockStatus(_tokenId);
       
    }
    
   
 
  function transfer(address _to, uint256 _tokenId) public {
      
        IAngelCardData angelCardData = IAngelCardData(angelCardDataContract);
       address owner;
       (,,,,,,,,, owner) = angelCardData.getAngel(uint64(_tokenId));
      
       if ((seraphims[msg.sender] == true)  || (owner == msg.sender))
       {
         angelCardData.transferAngel(owner,_to, uint64 (_tokenId)) ;
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