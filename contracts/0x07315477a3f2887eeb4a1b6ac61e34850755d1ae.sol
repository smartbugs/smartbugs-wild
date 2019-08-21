// Copyright (c) 2016 Chronicled, Inc. All rights reserved.
// http://explorer.chronicled.org
// http://demo.chronicled.org
// http://chronicled.org

contract Registrar {
    address public registrar;

    /**

    * Created event, gets triggered when a new registrant gets created
    * event
    * @param registrant - The registrant address.
    * @param registrar - The registrar address.
    * @param data - The data of the registrant.
    */
    event Created(address indexed registrant, address registrar, bytes data);

    /**
    * Updated event, gets triggered when a new registrant id Updated
    * event
    * @param registrant - The registrant address.
    * @param registrar - The registrar address.
    * @param data - The data of the registrant.
    */
    event Updated(address indexed registrant, address registrar, bytes data, bool active);

    /**
    * Error event.
    * event
    * @param code - The error code.
    * 1: Permission denied.
    * 2: Duplicate Registrant address.
    * 3: No such Registrant.
    */
    event Error(uint code);

    struct Registrant {
        address addr;
        bytes data;
        bool active;
    }

    mapping(address => uint) public registrantIndex;
    Registrant[] public registrants;

    /**
    * Function can't have ether.
    * modifier
    */
    modifier noEther() {
        if (msg.value > 0) throw;
        _
    }

    modifier isRegistrar() {
      if (msg.sender != registrar) {
        Error(1);
        return;
      }
      else {
        _
      }
    }

    /**
    * Construct registry with and starting registrants lenght of one, and registrar as msg.sender
    * constructor
    */
    function Registrar() {
        registrar = msg.sender;
        registrants.length++;
    }

    /**
    * Add a registrant, only registrar allowed
    * public_function
    * @param _registrant - The registrant address.
    * @param _data - The registrant data string.
    */
    function add(address _registrant, bytes _data) isRegistrar noEther returns (bool) {
        if (registrantIndex[_registrant] > 0) {
            Error(2); // Duplicate registrant
            return false;
        }
        uint pos = registrants.length++;
        registrants[pos] = Registrant(_registrant, _data, true);
        registrantIndex[_registrant] = pos;
        Created(_registrant, msg.sender, _data);
        return true;
    }

    /**
    * Edit a registrant, only registrar allowed
    * public_function
    * @param _registrant - The registrant address.
    * @param _data - The registrant data string.
    */
    function edit(address _registrant, bytes _data, bool _active) isRegistrar noEther returns (bool) {
        if (registrantIndex[_registrant] == 0) {
            Error(3); // No such registrant
            return false;
        }
        Registrant registrant = registrants[registrantIndex[_registrant]];
        registrant.data = _data;
        registrant.active = _active;
        Updated(_registrant, msg.sender, _data, _active);
        return true;
    }

    /**
    * Set new registrar address, only registrar allowed
    * public_function
    * @param _registrar - The new registrar address.
    */
    function setNextRegistrar(address _registrar) isRegistrar noEther returns (bool) {
        registrar = _registrar;
        return true;
    }

    /**
    * Get if a regsitrant is active or not.
    * constant_function
    * @param _registrant - The registrant address.
    */
    function isActiveRegistrant(address _registrant) constant returns (bool) {
        uint pos = registrantIndex[_registrant];
        return (pos > 0 && registrants[pos].active);
    }

    /**
    * Get all the registrants.
    * constant_function
    */
    function getRegistrants() constant returns (address[]) {
        address[] memory result = new address[](registrants.length-1);
        for (uint j = 1; j < registrants.length; j++) {
            result[j-1] = registrants[j].addr;
        }
        return result;
    }

    /**
    * Function to reject value sends to the contract.
    * fallback_function
    */
    function () noEther {}

    /**
    * Desctruct the smart contract. Since this is first, alpha release of Open Registry for IoT, updated versions will follow.
    * Registry's discontinue must be executed first.
    */
    function discontinue() isRegistrar noEther {
      selfdestruct(msg.sender);
    }
}


contract Registry {
    // Address of the Registrar contract which holds all the Registrants
    address public registrarAddress;
    // Address of the account which deployed the contract. Used only to configure contract.
    address public deployerAddress;

    /**
    * Creation event that gets triggered when a thing is created.
    * event
    * @param ids - The identity of the thing.
    * @param owner - The owner address.
    */
    event Created(bytes32[] ids, address indexed owner);

    /**
    * Update event that gets triggered when a thing is updated.
    * event
    * @param ids - The identity of the thing.
    * @param owner - The owner address.
    * @param isValid - The validity of the thing.
    */
    event Updated(bytes32[] ids, address indexed owner, bool isValid);

    /**
    * Delete event, triggered when Thing is deleted.
    * event
    * @param ids - The identity of the thing.
    * @param owner - The owner address.
    */
    event Deleted(bytes32[] ids, address indexed owner);

    /**
    * Generic error event.
    * event
    * @param code - The error code.
    * @param reference - Related references data for the Error event, e.g.: Identity, Address, etc.
    * 1: Identity collision, already assigned to another Thing.
    * 2: Not found, identity does not exist.
    * 3: Unauthorized, modification only by owner.
    * 4: Unknown schema specified.
    * 5: Incorrect input, at least one identity is required.
    * 6: Incorrect input, data is required.
    * 7: Incorrect format of the identity, schema length and identity length cannot be empty.
    * 8: Incorrect format of the identity, identity must be padded with trailing 0s.
    * 9: Contract already configured
    */
    event Error(uint code, bytes32[] reference);

    struct Thing {
      // All identities of a Thing. e.g.: BLE ID, public key, etc.
      bytes32[] identities;
      // Metadata of the Thing. Hex of ProtoBuffer structure.
      bytes32[] data;
      // Registrant address, who have added the thing.
      address ownerAddress;
      // Index of ProtoBuffer schema used. Optimized to fit in one bytes32.
      uint88 schemaIndex;
      // Status of the Thing. false if compromised, revoked, etc.
      bool isValid;
    }

    // Things are stored in the array
    Thing[] public things;

    // Identity to Thing index pointer for lookups and duplicates prevention.
    mapping(bytes32 => uint) public idToThing;

    // Content of ProtoBuffer schema.
    bytes[] public schemas;

    /**
    * Function can't contain Ether value.
    * modifier
    */
    modifier noEther() {
        if (msg.value > 0) throw;
        _
    }

    /**
    * Allow only registrants to exec the function.
    * modifier
    */
    modifier isRegistrant() {
        Registrar registrar = Registrar(registrarAddress);
        if (registrar.isActiveRegistrant(msg.sender)) {
            _
        }
    }

    /**
    * Allow only registrar to exec the function.
    * modifier
    */
    modifier isRegistrar() {
        Registrar registrar = Registrar(registrarAddress);
        if (registrar.registrar() == msg.sender) {
            _
        }
    }

    /**
    * Initialization of the contract
    * constructor
    */
    function Registry() {
        // Initialize arrays. Leave first element empty, since mapping points non-existent keys to 0.
        things.length++;
        schemas.length++;
        deployerAddress = msg.sender;
    }

    /**
    * Add Identities to already existing Thing.
    * internal_function
    * @param _thingIndex - The position of the Thing in the array.
    * @param _ids - Identities of the Thing in chunked format. Maximum size of one Identity is 2057 bytes32 elements.
    */
    function _addIdentities(uint _thingIndex, bytes32[] _ids) internal returns(bool){
        // Checks if there's duplicates and creates references
        if (false == _rewireIdentities(_ids, 0, _thingIndex, 0)) {
            return false;
        }

        // Thing don't have Identities yet.
        if (things[_thingIndex].identities.length == 0) {
            // Copy directly. Cheaper than one by one.
            things[_thingIndex].identities = _ids;
        }
        else {
            // _ids array current element pointer.
            // uint32 technically allows to put 128Gb of Identities into one Thing.
            uint32 cell = uint32(things[_thingIndex].identities.length);
            // Copy new IDs to the end of array one by one
            things[_thingIndex].identities.length += _ids.length;
            // If someone will provide _ids array with more than 2^32, it will go into infinite loop at a caller's expense.
            for (uint32 k = 0; k < _ids.length; k++) {
                things[_thingIndex].identities[cell++] = _ids[k];
            }
        }
        return true;
    }

    /**
    * Point provided Identities to the desired "things" array index in the lookup hash table idToThing.
    * internal_function
    * @param _ids - Identities of the Thing.
    * @param _oldIndex - Previous index that this Identities pointed to, prevents accidental rewiring and duplicate Identities.
    * @param _newIndex - things array index the Identities should point to.
    * @param _newIndex - things array index the Identities should point to.
    * @param _idsForcedLength — Internal use only. Zero by default. Used to revert side effects if execution fails at any point.
    *       Prevents infinity loop in recursion. Though recursion is not desirable, it's used to avoid over-complication of the code.
    */
    function _rewireIdentities(bytes32[] _ids, uint _oldIndex, uint _newIndex, uint32 _idsForcedLength) internal returns(bool) {
        // Current ID cell pointer
        uint32 cell = 0;
        // Length of namespace part of the Identity in URN format
        uint16 urnNamespaceLength;
        // Length of ID part of the Identity, though only uint16 needed but extended to uint24 for correct calculations.
        uint24 idLength;
        // Array cells used for current ID. uint24 to match idLength type, so no conversions needed.
        uint24 cellsPerId;
        // Hash of current ID
        bytes32 idHash;
        // How many bytes of payload are there in the last cell of single ID.
        uint8 lastCellBytesCnt;
        // Number of elements that needs to be processed in _ids array
        uint32 idsLength = _idsForcedLength > 0 ? _idsForcedLength : uint32(_ids.length);

        // No Identities provided
        if (idsLength == 0) {
            Error(5, _ids);
            return false;
        }

        // Each ID
        while (cell < idsLength) {
            // Get length of schema. First byte of packed ID.
            // Means that next urnNamespaceLength bytes is the schema definition.
            urnNamespaceLength = uint8(_ids[cell][0]);
            // Length of ID part of this URN Identity.
            idLength =
                // First byte
                uint16(_ids[cell + (urnNamespaceLength + 1) / 32][(urnNamespaceLength + 1) % 32]) * 2 ** 8 |
                // Second byte
                uint8(_ids[cell + (urnNamespaceLength + 2) / 32][(urnNamespaceLength + 2) % 32]);

            // We deal with the new Identity (instead rewiring after deletion)
            if (_oldIndex == 0 && (urnNamespaceLength == 0 || idLength == 0)) {
                // Incorrect Identity structure.
                Error(7, _ids);

                // If at least one Identity already wired. And if this is not a recursive call.
                if (cell > 0 && _idsForcedLength == 0) {
                    _rewireIdentities(_ids, _newIndex, _oldIndex, cell); // Revert changes made so far
                }
                return false;
            }

            // Total bytes32 cells devoted for this ID. Maximum 2057 is possible.
            cellsPerId = (idLength + urnNamespaceLength + 3) / 32;
            if ((idLength + urnNamespaceLength + 3) % 32 != 0) {
                // Identity uses one more cell partially
                cellsPerId++;
                // For new identity, ensure that complies with the format, specifically padding is done with 0s.
                // This prevents from adding duplicated identities, which might be accepted because generate a different hash.
                if (_oldIndex == 0) {
                    // How many bytes the ID occupies in the last cell.
                    lastCellBytesCnt = uint8((idLength + urnNamespaceLength + 3) % 32);

                    // Check if padded with zeros. Explicitly converting 2 into uint256 for correct calculations.
                    if (uint256(_ids[cell + cellsPerId - 1]) * (uint256(2) ** (lastCellBytesCnt * 8)) > 0) {  // Bitwise left shift, result have to be 0
                        // Identity is not padded with 0s
                        Error(8, _ids);
                        // If at least one Identity already wired. And if this is not a recursive call.
                        if (cell > 0 && _idsForcedLength == 0) {
                            _rewireIdentities(_ids, _newIndex, _oldIndex, cell); // Revert changes made so far
                        }
                        return false;
                    }
                }
            }

            // Single Identity array
            bytes32[] memory id = new bytes32[](cellsPerId);

            for (uint8 j = 0; j < cellsPerId; j++) {
                id[j] = _ids[cell++];
            }

            // Uniqueness check and reference for lookups
            idHash = sha3(id);

            // If it points to where it's expected.
            if (idToThing[idHash] == _oldIndex) {
                // Wire Identity
                idToThing[idHash] = _newIndex;
            } else {
                // References to a wrong Thing, e.g. Identity already exists, etc.
                Error(1, _ids);
                // If at least one Identity already wired. And if this is not a recursive call.
                if (cell - cellsPerId > 0 && _idsForcedLength == 0) {
                    _rewireIdentities(_ids, _newIndex, _oldIndex, cell - cellsPerId); // Revert changes made so far
                }
                return false;
            }
        }

        return true;
    }


    //
    // Public Functions
    //


    /**
    * Set the registrar address for the contract, (This function can be called only once).
    * public_function
    * @param _registrarAddress - The Registrar contract address.
    */
    function configure(address _registrarAddress) noEther returns(bool) {
        // Convert into array to properly generate Error event
        bytes32[] memory ref = new bytes32[](1);
        ref[0] = bytes32(registrarAddress);

        if (msg.sender != deployerAddress) {
            Error(3, ref);
            return false;
        }

        if (registrarAddress != 0x0) {
            Error(9, ref);
            return false;
        }

        registrarAddress = _registrarAddress;
        return true;
    }

    /**
    * Create a new Thing in the Registry, only for registrants.
    * public_function
    * @param _ids - The chunked identities array.
    * @param _data - Thing chunked data array.
    * @param _schemaIndex - Index of the schema to parse Thing's data.
    */
    function createThing(bytes32[] _ids, bytes32[] _data, uint88 _schemaIndex) isRegistrant returns(bool) {
        // No data provided
        if (_data.length == 0) {
            Error(6, _ids);
            return false;
        }

        if (_schemaIndex >= schemas.length || _schemaIndex == 0) {
            Error(4, _ids);
            return false;
        }

        // Wiring identities to non-existent Thing.
        // This optimization reduces transaction cost by 100k of gas on avg (or by 3x), in case if _rewireIdentities will fail.
        // Which leads to less damage to the caller, who provided incorrect data.
        if (false == _rewireIdentities(_ids, 0, things.length, 0)) {
            // Incorrect IDs format or duplicate Identities provided.
            return false;
        }

        // Now after all verifications passed we can add a the Thing.
        things.length++;
        // Creating structure in-place is 11k gas cheaper than assigning parameters separately.
        // That's why methods like updateThingData, addIdentities are not reused here.
        things[things.length - 1] = Thing(_ids, _data, msg.sender, _schemaIndex, true);

        // "Broadcast" event
        Created(_ids, msg.sender);
        return true;
    }

    /**
    * Create multiple Things at once.
    * Review: user should be aware that if there will be not enough identities transaction will run out of gas.
    * Review: user should be aware that providing too many identities will result in some of them not being used.
    * public_function
    * @param _ids - The Thing's IDs to be added in bytes32 chunks
    * @param _idsPerThing — number of IDs per thing, in relevant order
    * @param _data - The data chunks
    * @param _dataLength - The data length of every Thing to add, in relevant order
    * @param _schemaIndex -Index of the schema to parse Thing's data
    */
    function createThings(bytes32[] _ids, uint16[] _idsPerThing, bytes32[] _data, uint16[] _dataLength, uint88 _schemaIndex) isRegistrant noEther  {
        // Current _id array index
        uint16 idIndex = 0;
        // Current _data array index
        uint16 dataIndex = 0;
        // Counter of total id cells per one thing
        uint24 idCellsPerThing = 0;
        // Length of namespace part of the Identity in URN format
        uint16 urnNamespaceLength;
        // Length of ID part of the Identity, though only uint16 needed but extended to uint24 for correct calculations.
        uint24 idLength;

        // Each Thing
        for (uint16 i = 0; i < _idsPerThing.length; i++) {
            // Reset for each thing
            idCellsPerThing = 0;
            // Calculate number of cells for current Thing
            for (uint16 j = 0; j < _idsPerThing[i]; j++) {
                urnNamespaceLength = uint8(_ids[idIndex + idCellsPerThing][0]);
                idLength =
                    // First byte
                    uint16(_ids[idIndex + idCellsPerThing + (urnNamespaceLength + 1) / 32][(urnNamespaceLength + 1) % 32]) * 2 ** 8 |
                    // Second byte
                    uint8(_ids[idIndex + idCellsPerThing + (urnNamespaceLength + 2) / 32][(urnNamespaceLength + 2) % 32]);

                idCellsPerThing += (idLength + urnNamespaceLength + 3) / 32;
                if ((idLength + urnNamespaceLength + 3) % 32 != 0) {
                    idCellsPerThing++;
                }
            }

            // Extract ids for a single Thing
            bytes32[] memory ids = new bytes32[](idCellsPerThing);
            // Reusing var name to maintain stack size in limits
            for (j = 0; j < idCellsPerThing; j++) {
                ids[j] = _ids[idIndex++];
            }

            bytes32[] memory data = new bytes32[](_dataLength[i]);
            for (j = 0; j < _dataLength[i]; j++) {
                data[j] = _data[dataIndex++];
            }

            createThing(ids, data, _schemaIndex);
        }
    }

    /**
    * Add new IDs to the Thing, only registrants allowed.
    * public_function
    * @param _id - ID of the existing Thing
    * @param _newIds - IDs to be added.
    */
    function addIdentities(bytes32[] _id, bytes32[] _newIds) isRegistrant noEther returns(bool) {
        var index = idToThing[sha3(_id)];

        // There no Thing with such ID
        if (index == 0) {
            Error(2, _id);
            return false;
        }

        if (_newIds.length == 0) {
            Error(5, _id);
            return false;
        }

        if (things[index].ownerAddress != 0x0 && things[index].ownerAddress != msg.sender) {
            Error(3, _id);
            return false;
        }

        if (_addIdentities(index, _newIds)) {
            Updated(_id, things[index].ownerAddress, things[index].isValid);
            return true;
        }
        return false;
    }

    /**
    * Update Thing's data.
    * public_function
    * @param _id - The identity array.
    * @param _data - Thing data array.
    * @param _schemaIndex - The schema index of the schema to parse the thing.
    */
    function updateThingData(bytes32[] _id, bytes32[] _data, uint88 _schemaIndex) isRegistrant noEther returns(bool) {
        uint index = idToThing[sha3(_id)];

        if (index == 0) {
            Error(2, _id);
            return false;
        }

        if (things[index].ownerAddress != 0x0 && things[index].ownerAddress != msg.sender) {
            Error(3, _id);
            return false;
        }

        if (_schemaIndex > schemas.length || _schemaIndex == 0) {
            Error(4, _id);
            return false;
        }

        if (_data.length == 0) {
            Error(6, _id);
            return false;
        }

        things[index].schemaIndex = _schemaIndex;
        things[index].data = _data;
        Updated(_id, things[index].ownerAddress, things[index].isValid);
        return true;
    }

    /**
    * Set validity of a thing, only registrants allowed.
    * public_function
    * @param _id - The identity to change.
    * @param _isValid - The new validity of the thing.
    */
    function setThingValid(bytes32[] _id, bool _isValid) isRegistrant noEther returns(bool) {
        uint index = idToThing[sha3(_id)];

        if (index == 0) {
            Error(2, _id);
            return false;
        }

        if (things[index].ownerAddress != msg.sender) {
            Error(3, _id);
            return false;
        }

        things[index].isValid = _isValid;
        // Broadcast event
        Updated(_id, things[index].ownerAddress, things[index].isValid);
        return true;
    }

    /**
    * Delete previously added Thing
    * public_function
    * @param _id - One of Thing's Identities.
    */
    function deleteThing(bytes32[] _id) isRegistrant noEther returns(bool) {
        uint index = idToThing[sha3(_id)];

        if (index == 0) {
            Error(2, _id);
            return false;
        }

        if (things[index].ownerAddress != msg.sender) {
            Error(3, _id);
            return false;
        }

        // Rewire Thing's identities to index 0, e.g. delete.
        if (false == _rewireIdentities(things[index].identities, index, 0, 0)) {
            // Cannot rewire, should never happen
            return false;
        }

        // Put last element in place of deleted one
        if (index != things.length - 1) {
            // Rewire identities of the last Thing to the new prospective index.
            if (false == _rewireIdentities(things[things.length - 1].identities, things.length - 1, index, 0)) {
                // Cannot rewire, should never happen
                _rewireIdentities(things[index].identities, 0, index, 0); // Rollback
                return false;
            }

            // "Broadcast" event with identities before they're lost.
            Deleted(things[index].identities, things[index].ownerAddress);

            // Move last Thing to the place of deleted one.
            things[index] = things[things.length - 1];
        }

        // Delete last Thing
        things.length--;

        return true;
    }

    /**
    * Get length of the schemas array
    * constant_function
    */
    function getSchemasLenght() constant returns(uint) {
        return schemas.length;
    }

    /**
    * Get Thing's information
    * constant_function
    * @param _id - identity of the thing.
    */
    function getThing(bytes32[] _id) constant returns(bytes32[], bytes32[], uint88, bytes, address, bool) {
        var index = idToThing[sha3(_id)];
        // No such Thing
        if (index == 0) {
            Error(2, _id);
            return;
        }
        Thing thing = things[index];
        return (thing.identities, thing.data, thing.schemaIndex, schemas[thing.schemaIndex], thing.ownerAddress, thing.isValid);
    }

    /**
    * Check if Thing is present in the registry by it's ID
    * constant_function
    * @param _id - identity for lookup.
    */

    // Todo: reevaluate this method. Do we need it?
    function thingExist(bytes32[] _id) constant returns(bool) {
        return idToThing[sha3(_id)] > 0;
    }

    /**
    * Create a new schema. Provided as hex of ProtoBuf-encoded schema data.
    * public_function
    * @param _schema - New schema string to add.
    */
    function createSchema(bytes _schema) isRegistrar noEther returns(uint) {
        uint pos = schemas.length++;
        schemas[pos] = _schema;
        return pos;
    }

    /**
    * Fallback
    */
    function () noEther {}


    /**
    * Desctruct the smart contract. Since this is first, alpha release of Open Registry for IoT, updated versions will follow.
    * Execute this prior to Registrar's contract discontinue()
    */
    function discontinue() isRegistrar noEther returns(bool) {
      selfdestruct(msg.sender);
      return true;
    }
}