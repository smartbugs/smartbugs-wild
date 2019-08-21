pragma solidity >=0.4.22 <0.6.0;


//-----------------------------------------------------------------------------
/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization
/// control functions, this simplifies the implementation of "user permissions".
//-----------------------------------------------------------------------------
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


//-----------------------------------------------------------------------------
/// @title Crusades Configurations
//-----------------------------------------------------------------------------
contract CrusadesConfig is Ownable {
    //=========================================================================
    // RESOURCES
    //=========================================================================
    string[] public resourceTypes;
    
    function addNewResourceType (string calldata _description) external onlyOwner {
        resourceTypes.push(_description);
    }
    
    function resourcesLength () external view returns (uint) {
        return resourceTypes.length;
    }
    
    //=========================================================================
    // PLANET
    //=========================================================================
    struct CrusadesTileData {
        string description;
        uint weight;
        mapping (uint => uint) resourceIdToYield;
    }
    struct CrusadesCoordinates {
        uint x;
        uint y;
    }
    struct CrusadesPlanetTile {
        uint tileDataId;                        // id of the data
        uint cityId;                            // The ID of the city on this tile. 0 if none.
        // an array of coordinates of all neighboring tiles
        // neighbors[0] = up + left
        // neighbors[1] = up
        // neighbors[2] = up + right
        // neighbors[3] = down + left
        // neighbors[4] = down
        // neighbors[5] = down + right
        CrusadesCoordinates[6] neighbors;
        
    }
    
    mapping (uint => CrusadesTileData) public idToTileData;
    mapping (uint => mapping (uint => CrusadesPlanetTile)) public planetTiles;

    function setTileData (
        uint _tileId, 
        string calldata _description, 
        uint _weight,
        uint[] calldata _resourceYields
    ) external onlyOwner {
        require (_resourceYields.length == resourceTypes.length);
        CrusadesTileData storage tileData = idToTileData[_tileId];
        tileData.description = _description;
        tileData.weight = _weight;
        for (uint i = 0; i < _resourceYields.length; ++i) {
            tileData.resourceIdToYield[i] = _resourceYields[i];
        }
    }

    function initializePlanetTile (
        uint _xCoordinate, 
        uint _yCoordinate, 
        uint _tileDataId
    ) external onlyOwner {
        CrusadesPlanetTile storage planetTile = planetTiles[_xCoordinate][_yCoordinate];
        planetTile.tileDataId = _tileDataId;
        
        // TODO: EDGE CHECKING FOR WRAPPING OF COORDINATES ON GLOBE
        // neighbor up + left
        planetTile.neighbors[0].x = _xCoordinate - 1;
        planetTile.neighbors[0].y = _yCoordinate - 1;
        
        // neighbor up
        planetTile.neighbors[1].x = _xCoordinate;
        planetTile.neighbors[1].y = _yCoordinate - 1;
        
        // neighbor up + right
        planetTile.neighbors[2].x = _xCoordinate + 1;
        planetTile.neighbors[2].y = _yCoordinate - 1;
        
        // neighbor down + left
        planetTile.neighbors[3].x = _xCoordinate - 1;
        planetTile.neighbors[3].y = _yCoordinate + 1;
        
        // neighbor up + left
        planetTile.neighbors[4].x = _xCoordinate;
        planetTile.neighbors[4].y = _yCoordinate + 1;
        
        // neighbor up + left
        planetTile.neighbors[5].x = _xCoordinate + 1;
        planetTile.neighbors[5].y = _yCoordinate + 1;
    }

    function addCityToPlanetTile (
        uint _xCoordinate, 
        uint _yCoordinate, 
        uint _cityId
    ) external onlyOwner {
        planetTiles[_xCoordinate][_yCoordinate].cityId = _cityId;
    }
    
    function getPlanetTile(uint _xCoordinate, uint _yCoordinate) external view returns (
        uint tileDataId,
        uint cityId,
        uint[] memory neighborsXCoordinates,
        uint[] memory neighborsYCoordinates
    ) {
        tileDataId = planetTiles[_xCoordinate][_yCoordinate].tileDataId;
        cityId = planetTiles[_xCoordinate][_yCoordinate].cityId;
        neighborsXCoordinates = new uint[](6);
        neighborsYCoordinates = new uint[](6);
        for (uint i = 0; i < 6; ++i) {
            neighborsXCoordinates[i] = planetTiles[_xCoordinate][_yCoordinate].neighbors[i].x;
            neighborsYCoordinates[i] = planetTiles[_xCoordinate][_yCoordinate].neighbors[i].y;
        }
    }
    
    function getResourceYield(uint _tileId) external view returns (uint[] memory resources) {
        resources = new uint[](resourceTypes.length);
        for (uint i = 0; i < resources.length; ++i) {
            resources[i] = idToTileData[_tileId].resourceIdToYield[i];
        }
    }
    
    function getNeighbors(uint _originX, uint _originY, uint _distance) external view returns (
        uint[] memory neighborsXCoordinates, 
        uint[] memory neighborsYCoordinates
    ) {
        require (_distance > 0 && _distance < 3);
        // the formula is 3n^2 + 3n
        neighborsXCoordinates = new uint[]((_distance ** 2 * 3) + (3 * _distance));
        neighborsYCoordinates = new uint[]((_distance ** 2 * 3) + (3 * _distance));
        for (uint i = 0; i < 6; ++i) {
            if (planetTiles[_originX][_originY].neighbors[i].x != 0 || planetTiles[_originX][_originY].neighbors[i].y != 0) {
                neighborsXCoordinates[i] = planetTiles[_originX][_originY].neighbors[i].x;
                neighborsYCoordinates[i] = planetTiles[_originX][_originY].neighbors[i].y;
            }
            if (_distance == 2) {
                for(i = 0; i < 6; ++i) {
                    if (planetTiles[_originX][_originY].neighbors[i].x != 0 || planetTiles[_originX][_originY].neighbors[i].y != 0) {
                        neighborsXCoordinates[i] = planetTiles[_originX][_originY].neighbors[i].x;
                        neighborsYCoordinates[i] = planetTiles[_originX][_originY].neighbors[i].y;
                    }
                }
            }
        }
    }
    
    function getHarvest(uint _originX, uint _originY) external view returns (
        uint[] memory
    ) {
        // the formula is 3n^2 + 3n
        CrusadesCoordinates[] memory neighborCoordinates = new CrusadesCoordinates[](6);
        for (uint i = 0; i < 6; ++i) {
            if (planetTiles[_originX][_originY].neighbors[i].x != 0 || planetTiles[_originX][_originY].neighbors[i].y != 0) {
                neighborCoordinates[i] = planetTiles[_originX][_originY].neighbors[i];
            }
        }
        
        uint[] memory resourcesToHarvest = new uint[](resourceTypes.length);
        for (uint i = 0; i < neighborCoordinates.length; ++i) {
            uint tileId = planetTiles[neighborCoordinates[i].x][neighborCoordinates[i].y].tileDataId;
            for (uint j = 0; j < resourceTypes.length; ++j) {
                resourcesToHarvest[j] += idToTileData[tileId].resourceIdToYield[j];
            }
        }
    }
    
    //=========================================================================
    // TROOPS
    //=========================================================================
    struct CrusadesTroopData {
        string description;
        mapping (uint => uint) troopAttributeIdToValue;
        mapping (uint => uint) resourceIdToCost;
    }
    
    mapping (uint => CrusadesTroopData) public idToTroopData;
    mapping (uint => mapping (uint => int)) public typeIdToTypeIdToEffectiveness;
    string[] public troopAttributes;

    
    function addNewTroopAttribute (string calldata _description) external onlyOwner {
        troopAttributes.push(_description);
    }
    
    function initializeTroopData (
        uint _troopId,
        string calldata _description,
        uint[] calldata _troopAttributeValues,
        uint[] calldata _resourceCosts
    ) external onlyOwner {
        require (_resourceCosts.length == resourceTypes.length);
        require (_troopAttributeValues.length == troopAttributes.length);
        CrusadesTroopData storage troopData = idToTroopData[_troopId];
        troopData.description = _description;
        for (uint i = 0; i < _troopAttributeValues.length; ++i) {
            troopData.troopAttributeIdToValue[i] = _troopAttributeValues[i];
        }
        for(uint i = 0; i < _resourceCosts.length; ++i) {
            troopData.resourceIdToCost[i] = _resourceCosts[i];
        }
    }
    
    function getTroopAttributeValue(uint _troopId, uint _attributeId) external view returns (uint) {
        return idToTroopData[_troopId].troopAttributeIdToValue[_attributeId];
    }
    
    function getTroopResourceCost(uint _troopId, uint _resourceId) external view returns (uint) {
        return idToTroopData[_troopId].resourceIdToCost[_resourceId];
    }
    
    //=========================================================================
    // MODIFIERS
    //=========================================================================
    string[] public modifiers;
    function addNewModifier (string calldata _description) external onlyOwner {
        modifiers.push(_description);
    }
    function modifiersLength () external view returns (uint) {
        return modifiers.length;
    }
    
    //=========================================================================
    // POLICIES
    //=========================================================================
    struct CrusadesPolicyData {
        string description;
        mapping (uint => uint) resourceIdToCost;
        mapping (uint => bool) policyIdToRequired;
        mapping (uint => int) modifierIdToAmountChangedByThisPolicy;
    }
    
    mapping (uint => CrusadesPolicyData) public idToPolicyData;
    
    function setPolicyData (
        uint _policyId,
        string calldata _description,
        uint[] calldata _resourceCosts, 
        uint[] calldata _requirements, 
        int[] calldata _modifiers
    ) external onlyOwner {
        require (_resourceCosts.length == resourceTypes.length);
        require (_modifiers.length == modifiers.length);
        CrusadesPolicyData storage policyData = idToPolicyData[_policyId];
        policyData.description = _description;
        for (uint i = 0; i < _resourceCosts.length; ++i) {
            policyData.resourceIdToCost[i] = _resourceCosts[i];
        }
        for (uint i = 0; i < _requirements.length; ++i) {
            policyData.policyIdToRequired[_requirements[i]] = true;
        }
        for (uint i = 0; i < _modifiers.length; ++i){
            policyData.modifierIdToAmountChangedByThisPolicy[i] = _modifiers[i];
        }
    }
    
    //=========================================================================
    // BUILDINGS
    //=========================================================================
    struct CrusadesBuildingData {
        string description;
        mapping (uint => mapping(uint => uint)) buildingLevelToAttributeIdToValue;
        mapping (uint => mapping(uint => uint)) buildingLevelToResourceIdToCost;
    }
    
    mapping (uint => CrusadesBuildingData) public idToBuildingData;
    string[] public buildingAttributes;
    
    function addNewBuildingAttribute (string calldata _description) external onlyOwner {
        buildingAttributes.push(_description);
    }
    
    function initializeBuildingData (
        uint _buildingId,
        string calldata _description
    ) external onlyOwner {
        idToBuildingData[_buildingId].description = _description;
    }
    
    function setBuildingAttributesByLevel(
        uint _buildingId, 
        uint _buildingLevel, 
        uint[] calldata _attributeValues
    ) external onlyOwner {
        require(_attributeValues.length == buildingAttributes.length);
        for (uint i = 0; i < _attributeValues.length; ++i) {
            idToBuildingData[_buildingId].buildingLevelToAttributeIdToValue[_buildingLevel][i] = _attributeValues[i];
        }
        
    }
    
    function setBuildingCostsByLevel(
        uint _buildingId,
        uint _buildingLevel,
        uint[] calldata _resourceCosts
    ) external onlyOwner {
        require(_resourceCosts.length == resourceTypes.length);
        for(uint i = 0; i < _resourceCosts.length; ++i) {
            idToBuildingData[_buildingId].buildingLevelToResourceIdToCost[_buildingLevel][i] = _resourceCosts[i];
        }
    }
    
    function getBuildingAttributeValue(
        uint _buildingId,
        uint _buildingLevel,
        uint _attributeId
    ) external view returns (uint) {
        return idToBuildingData[_buildingId].buildingLevelToAttributeIdToValue[_buildingLevel][_attributeId];
    }
    
    function getBuildingResourceCost(
        uint _buildingId, 
        uint _buildingLevel, 
        uint _resourceId
    ) external view returns (uint) {
        return idToBuildingData[_buildingId].buildingLevelToResourceIdToCost[_buildingLevel][_resourceId];
    }
    
    //=========================================================================
    // OTHER CONFIGURATIONS
    //=========================================================================
    uint public cityPrice = 1 ether / 5;
    uint public harvestInterval = 1 hours;
    uint public maxHarvests = 8;
    string[] public customizations;
    mapping (uint => string) public customizationIdToSkin;
    mapping (uint => string) public customizationIdToChroma;
    
    function changeCityPrice(uint _newPrice) external onlyOwner {
        require (_newPrice > 0);
        cityPrice = _newPrice;
    }
    
    function changeHarvestInterval(uint _newInterval) external onlyOwner {
        require (_newInterval > 0);
        cityPrice = _newInterval;
    }
}