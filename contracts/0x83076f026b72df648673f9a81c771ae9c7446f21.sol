pragma solidity ^0.5.5;


contract Ownable {
    
    mapping(address => bool) internal owner;
    
    event AddedOwner(address newOwner);
    event RemovedOwner(address removedOwner);

    constructor () public {
        owner[msg.sender] = true;
    }

    modifier ownerOnly() {
        require(owner[msg.sender]);
        _;
    }

    function ownerAdd(address _newOwner) ownerOnly public {
        require(_newOwner != address(0));
        owner[_newOwner] = true;
        
        emit AddedOwner(_newOwner);
    }

    function ownerRemove(address _toRemove) ownerOnly public {
        require(_toRemove != address(0));
        require(_toRemove != msg.sender);
        //owner[_toRemove] = false;
        delete owner[_toRemove];
        
        emit RemovedOwner(_toRemove);
    }
}


contract RunOnChain is Ownable {


    struct Mensuration {
        string Longitude;
        string Latitude;
        string Elevatio;
        uint256 GpsDatetime;
        uint256 DeviceDatetime;
    }
    
    mapping (uint256 => mapping (uint256 => Mensuration[])) internal Mensurations;
    
    
    constructor () public Ownable() { }
    
    
    function insertMensuration(uint256 eventId, uint256 runnerId, string memory gpsLongitude, string memory gpsLatitude, string memory gpsElevation, uint256 gpsDatetime, uint256 deviceDatetime) public ownerOnly() returns (bool) 
    {
        require(eventId>0 && runnerId>0 && bytes(gpsLongitude).length>0 && bytes(gpsLatitude).length>0 && bytes(gpsElevation).length>0 && gpsDatetime>0 && deviceDatetime>0);
        
        Mensuration memory mensuTemp;
        mensuTemp.Longitude = gpsLongitude;
        mensuTemp.Latitude = gpsLatitude;
        mensuTemp.Elevatio = gpsElevation;
        mensuTemp.GpsDatetime = gpsDatetime;
        mensuTemp.DeviceDatetime = deviceDatetime;
        
        Mensurations[eventId][runnerId].push(mensuTemp);
        
        return true;
    }
    
    
    function getInfo(uint256 eventId, uint256 runnerId) public ownerOnly() view returns (string memory)
    {
        require(eventId >0 && runnerId>0);
        
        string memory ret = "{";
        uint256 arrayLength = Mensurations[eventId][runnerId].length;
        
        ret = string(abi.encodePacked(ret, '"EventId": "', uint2str(eventId), '", '));
        ret = string(abi.encodePacked(ret, '"RunnerId": "', uint2str(runnerId), '", '));
        
        ret = string(abi.encodePacked(ret, '"Mensurations": ['));
        for (uint i=0; i<arrayLength; i++)
        {
            ret = string(abi.encodePacked(ret, '{'));
            ret = string(abi.encodePacked(ret, '"GpsLongitude": "', Mensurations[eventId][runnerId][i].Longitude, '", '));
            ret = string(abi.encodePacked(ret, '"GpsLatitude": "', Mensurations[eventId][runnerId][i].Latitude, '", '));
            ret = string(abi.encodePacked(ret, '"GpsElevation": "', Mensurations[eventId][runnerId][i].Elevatio, '"'));
            ret = string(abi.encodePacked(ret, '"GpsDatetime": "', uint2str(Mensurations[eventId][runnerId][i].GpsDatetime), '"'));
            ret = string(abi.encodePacked(ret, '"DeviceDatetime": "', uint2str(Mensurations[eventId][runnerId][i].DeviceDatetime), '"'));
            ret = string(abi.encodePacked(ret, '}'));
            
            if(i<arrayLength-1 && arrayLength>1)
                ret = string(abi.encodePacked(ret, ', '));
        }
        ret = string(abi.encodePacked(ret, "]"));
    
        ret = string(abi.encodePacked(ret, "}"));
                
        
        return ret;
    }
    
    function kill() public ownerOnly()  returns (bool)
    {
        selfdestruct(msg.sender);
    }
    
    
    function uint2str(uint _i) internal pure returns (string memory _uintAsString)
    {
        if (_i == 0) { return "0"; }
        uint j = _i;
        uint len;
        while (j != 0) { len++; j /= 10; }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) { bstr[k--] = byte(uint8(48 + _i % 10)); _i /= 10; }
        return string(bstr);
    }
    
}