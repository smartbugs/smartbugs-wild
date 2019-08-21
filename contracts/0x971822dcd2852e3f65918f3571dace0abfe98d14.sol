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


  

   
	


contract AccessoryData is IAccessoryData, SafeMath {
    /*** EVENTS ***/
    event CreatedAccessory (uint64 accessoryId);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /*** DATA TYPES ***/
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


    /*** STORAGE ***/
    mapping(uint8 => AccessorySeries) public AccessorySeriesCollection;
    mapping(uint => Accessory) public AccessoryCollection;
    mapping(address => uint64[]) public ownerAccessoryCollection;
    
    /*** FUNCTIONS ***/
    //*** Write Access ***//
    function AccessoryData() public {
      
    }

    //*** Accessories***/
    function createAccessorySeries(uint8 _AccessorySeriesId, uint32 _maxTotal, uint _price) onlyCREATOR public returns(uint8) {
        
        if ((now > 1516642200) || (totalAccessorySeries >= 18)) {revert();}
        //This confirms that no one, even the develoopers, can create any accessorySeries after JAN/22/2018 @ 05:30pm (UTC) or more than the original 18 series. 
        AccessorySeries storage accessorySeries = AccessorySeriesCollection[_AccessorySeriesId];
        accessorySeries.AccessorySeriesId = _AccessorySeriesId;
        accessorySeries.maxTotal = _maxTotal;
        accessorySeries.price = _price;

        totalAccessorySeries += 1;
        return totalAccessorySeries;
    }
	
	function setAccessory(uint8 _seriesIDtoCreate, address _owner) external onlySERAPHIM returns(uint64) { 
        AccessorySeries storage series = AccessorySeriesCollection[_seriesIDtoCreate];
        if (series.maxTotal <= series.currentTotal) {revert();}
        else {
        totalAccessories += 1;
        series.currentTotal +=1;
       Accessory storage accessory = AccessoryCollection[totalAccessories];
        accessory.accessoryId = totalAccessories;
       accessory.accessorySeriesId = _seriesIDtoCreate;
        accessory.owner = _owner;
        uint64[] storage owners = ownerAccessoryCollection[_owner];
        owners.push(accessory.accessoryId);
       }
        
    }

    
   function addAccessoryIdMapping(address _owner, uint64 _accessoryId) private  {
            uint64[] storage owners = ownerAccessoryCollection[_owner];
          owners.push(_accessoryId);
          Accessory storage accessory = AccessoryCollection[_accessoryId];
          accessory.owner = _owner;
    
   }
    

	
	function transferAccessory(address _from, address _to, uint64 __accessoryId) onlySERAPHIM public returns(ResultCode) {
        Accessory storage accessory = AccessoryCollection[__accessoryId];
        if (accessory.owner != _from) {
            return ResultCode.ERROR_NOT_OWNER;
        }
        if (_from == _to) {revert();}
     addAccessoryIdMapping(_to, __accessoryId);
        return ResultCode.SUCCESS;
    }
  function ownerAccessoryTransfer (address _to, uint64 __accessoryId)  public  {
     //Any owner of an accessory can call this function to transfer their accessory to any other address. 
     
       if ((__accessoryId > totalAccessories) || ( __accessoryId == 0)) {revert();}
         Accessory storage accessory = AccessoryCollection[__accessoryId];
        if (msg.sender == _to) {revert();} //can't send an accessory to yourself
        if (accessory.owner != msg.sender) {revert();} //can't send an accessory you don't own. 
        else {
        accessory.owner = _to;
      addAccessoryIdMapping(_to, __accessoryId);
        }
    }

    //*** Read Access ***//
    function getAccessorySeries(uint8 _accessorySeriesId) constant public returns(uint8 accessorySeriesId, uint32 currentTotal, uint32 maxTotal, uint price) {
        AccessorySeries memory series = AccessorySeriesCollection[_accessorySeriesId];
        accessorySeriesId = series.AccessorySeriesId;
        currentTotal = series.currentTotal;
        maxTotal = series.maxTotal;
        price = series.price;
    }
	
	function getAccessory(uint _accessoryId) constant public returns(uint accessoryID, uint8 AccessorySeriesID, address owner) {
        Accessory memory accessory = AccessoryCollection[_accessoryId];
        accessoryID = accessory.accessoryId;
        AccessorySeriesID = accessory.accessorySeriesId;
        owner = accessory.owner;
  
       
    }
	
	function getOwnerAccessoryCount(address _owner) constant public returns(uint) {
        return ownerAccessoryCollection[_owner].length;
    }
	
	function getAccessoryByIndex(address _owner, uint _index) constant public returns(uint) {
        if (_index >= ownerAccessoryCollection[_owner].length)
            return 0;
        return ownerAccessoryCollection[_owner][_index];
    }

    function getTotalAccessorySeries() constant public returns (uint8) {
        return totalAccessorySeries;
    }

    function getTotalAccessories() constant public returns (uint) {
        return totalAccessories;
    }
}