pragma solidity ^0.4.24;

// File: contracts/identity/ERC735.sol

/**
 * @title ERC735 Claim Holder
 * @notice Implementation by Origin Protocol
 * @dev https://github.com/OriginProtocol/origin/blob/master/origin-contracts/contracts/identity/ERC735.sol
 */
contract ERC735 {

    event ClaimRequested(
        uint256 indexed claimRequestId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri
    );
    event ClaimAdded(
        bytes32 indexed claimId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri
    );
    event ClaimRemoved(
        bytes32 indexed claimId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri
    );
    event ClaimChanged(
        bytes32 indexed claimId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri
    );

    struct Claim {
        uint256 topic;
        uint256 scheme;
        address issuer; // msg.sender
        bytes signature; // this.address + topic + data
        bytes data;
        string uri;
    }

    function getClaim(bytes32 _claimId)
        public view returns(uint256 topic, uint256 scheme, address issuer, bytes signature, bytes data, string uri);
    function getClaimIdsByTopic(uint256 _topic)
        public view returns(bytes32[] claimIds);
    function addClaim(uint256 _topic, uint256 _scheme, address issuer, bytes _signature, bytes _data, string _uri)
        public returns (bytes32 claimRequestId);
    function removeClaim(bytes32 _claimId)
        public returns (bool success);
}

// File: contracts/identity/ERC725.sol

/**
 * @title ERC725 Proxy Identity
 * @notice Implementation by Origin Protocol
 * @dev https://github.com/OriginProtocol/origin/blob/master/origin-contracts/contracts/identity/ERC725.sol
 */
contract ERC725 {

    uint256 constant MANAGEMENT_KEY = 1;
    uint256 constant ACTION_KEY = 2;
    uint256 constant CLAIM_SIGNER_KEY = 3;
    uint256 constant ENCRYPTION_KEY = 4;

    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Executed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Approved(uint256 indexed executionId, bool approved);

    function getKey(bytes32 _key) public view returns(uint256[] purposes, uint256 keyType, bytes32 key);
    function keyHasPurpose(bytes32 _key, uint256 _purpose) public view returns (bool exists);
    function getKeysByPurpose(uint256 _purpose) public view returns(bytes32[] keys);
    function addKey(bytes32 _key, uint256 _purpose, uint256 _keyType) public returns (bool success);
    function removeKey(bytes32 _key, uint256 _purpose) public returns (bool success);
    function execute(address _to, uint256 _value, bytes _data) public returns (uint256 executionId);
    function approve(uint256 _id, bool _approve) public returns (bool success);
}

// File: contracts/identity/KeyHolderLibrary.sol

/**
 * @title Library for KeyHolder.
 * @notice Fork of Origin Protocol's implementation at
 * https://github.com/OriginProtocol/origin/blob/master/origin-contracts/contracts/identity/KeyHolderLibrary.sol
 * We want to add purpose to already existing key.
 * We do not want to have purpose J if you have purpose I and I < J
 * Exception: we want a key of purpose 1 to have all purposes.
 * @author Talao, Polynomial.
 */
library KeyHolderLibrary {
    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event PurposeAdded(bytes32 indexed key, uint256 indexed purpose);
    event ExecutionRequested(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event ExecutionFailed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Executed(uint256 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Approved(uint256 indexed executionId, bool approved);

    struct Key {
        uint256[] purposes; //e.g., MANAGEMENT_KEY = 1, ACTION_KEY = 2, etc.
        uint256 keyType; // e.g. 1 = ECDSA, 2 = RSA, etc.
        bytes32 key;
    }

    struct KeyHolderData {
        uint256 executionNonce;
        mapping (bytes32 => Key) keys;
        mapping (uint256 => bytes32[]) keysByPurpose;
        mapping (uint256 => Execution) executions;
    }

    struct Execution {
        address to;
        uint256 value;
        bytes data;
        bool approved;
        bool executed;
    }

    function init(KeyHolderData storage _keyHolderData)
        public
    {
        bytes32 _key = keccak256(abi.encodePacked(msg.sender));
        _keyHolderData.keys[_key].key = _key;
        _keyHolderData.keys[_key].purposes.push(1);
        _keyHolderData.keys[_key].keyType = 1;
        _keyHolderData.keysByPurpose[1].push(_key);
        emit KeyAdded(_key, 1, 1);
    }

    function getKey(KeyHolderData storage _keyHolderData, bytes32 _key)
        public
        view
        returns(uint256[] purposes, uint256 keyType, bytes32 key)
    {
        return (
            _keyHolderData.keys[_key].purposes,
            _keyHolderData.keys[_key].keyType,
            _keyHolderData.keys[_key].key
        );
    }

    function getKeyPurposes(KeyHolderData storage _keyHolderData, bytes32 _key)
        public
        view
        returns(uint256[] purposes)
    {
        return (_keyHolderData.keys[_key].purposes);
    }

    function getKeysByPurpose(KeyHolderData storage _keyHolderData, uint256 _purpose)
        public
        view
        returns(bytes32[] _keys)
    {
        return _keyHolderData.keysByPurpose[_purpose];
    }

    function addKey(KeyHolderData storage _keyHolderData, bytes32 _key, uint256 _purpose, uint256 _type)
        public
        returns (bool success)
    {
        require(_keyHolderData.keys[_key].key != _key, "Key already exists"); // Key should not already exist
        if (msg.sender != address(this)) {
            require(keyHasPurpose(_keyHolderData, keccak256(abi.encodePacked(msg.sender)), 1), "Sender does not have management key"); // Sender has MANAGEMENT_KEY
        }

        _keyHolderData.keys[_key].key = _key;
        _keyHolderData.keys[_key].purposes.push(_purpose);
        _keyHolderData.keys[_key].keyType = _type;

        _keyHolderData.keysByPurpose[_purpose].push(_key);

        emit KeyAdded(_key, _purpose, _type);

        return true;
    }

    // We want to be able to add purpose to an existing key.
    function addPurpose(KeyHolderData storage _keyHolderData, bytes32 _key, uint256 _purpose)
        public
        returns (bool)
    {
        require(_keyHolderData.keys[_key].key == _key, "Key does not exist"); // Key should already exist
        if (msg.sender != address(this)) {
            require(keyHasPurpose(_keyHolderData, keccak256(abi.encodePacked(msg.sender)), 1), "Sender does not have management key"); // Sender has MANAGEMENT_KEY
        }

        _keyHolderData.keys[_key].purposes.push(_purpose);

        _keyHolderData.keysByPurpose[_purpose].push(_key);

        emit PurposeAdded(_key, _purpose);

        return true;
    }

    function approve(KeyHolderData storage _keyHolderData, uint256 _id, bool _approve)
        public
        returns (bool success)
    {
        require(keyHasPurpose(_keyHolderData, keccak256(abi.encodePacked(msg.sender)), 2), "Sender does not have action key");
        require(!_keyHolderData.executions[_id].executed, "Already executed");

        emit Approved(_id, _approve);

        if (_approve == true) {
            _keyHolderData.executions[_id].approved = true;
            success = _keyHolderData.executions[_id].to.call(_keyHolderData.executions[_id].data, 0);
            if (success) {
                _keyHolderData.executions[_id].executed = true;
                emit Executed(
                    _id,
                    _keyHolderData.executions[_id].to,
                    _keyHolderData.executions[_id].value,
                    _keyHolderData.executions[_id].data
                );
                return;
            } else {
                emit ExecutionFailed(
                    _id,
                    _keyHolderData.executions[_id].to,
                    _keyHolderData.executions[_id].value,
                    _keyHolderData.executions[_id].data
                );
                return;
            }
        } else {
            _keyHolderData.executions[_id].approved = false;
        }
        return true;
    }

    function execute(KeyHolderData storage _keyHolderData, address _to, uint256 _value, bytes _data)
        public
        returns (uint256 executionId)
    {
        require(!_keyHolderData.executions[_keyHolderData.executionNonce].executed, "Already executed");
        _keyHolderData.executions[_keyHolderData.executionNonce].to = _to;
        _keyHolderData.executions[_keyHolderData.executionNonce].value = _value;
        _keyHolderData.executions[_keyHolderData.executionNonce].data = _data;

        emit ExecutionRequested(_keyHolderData.executionNonce, _to, _value, _data);

        if (
            keyHasPurpose(_keyHolderData, keccak256(abi.encodePacked(msg.sender)),1) ||
            keyHasPurpose(_keyHolderData, keccak256(abi.encodePacked(msg.sender)),2)
        ) {
            approve(_keyHolderData, _keyHolderData.executionNonce, true);
        }

        _keyHolderData.executionNonce++;
        return _keyHolderData.executionNonce-1;
    }

    function removeKey(KeyHolderData storage _keyHolderData, bytes32 _key, uint256 _purpose)
        public
        returns (bool success)
    {
        if (msg.sender != address(this)) {
            require(keyHasPurpose(_keyHolderData, keccak256(abi.encodePacked(msg.sender)), 1), "Sender does not have management key"); // Sender has MANAGEMENT_KEY
        }

        require(_keyHolderData.keys[_key].key == _key, "No such key");
        emit KeyRemoved(_key, _purpose, _keyHolderData.keys[_key].keyType);

        // Remove purpose from key
        uint256[] storage purposes = _keyHolderData.keys[_key].purposes;
        for (uint i = 0; i < purposes.length; i++) {
            if (purposes[i] == _purpose) {
                purposes[i] = purposes[purposes.length - 1];
                delete purposes[purposes.length - 1];
                purposes.length--;
                break;
            }
        }

        // If no more purposes, delete key
        if (purposes.length == 0) {
            delete _keyHolderData.keys[_key];
        }

        // Remove key from keysByPurpose
        bytes32[] storage keys = _keyHolderData.keysByPurpose[_purpose];
        for (uint j = 0; j < keys.length; j++) {
            if (keys[j] == _key) {
                keys[j] = keys[keys.length - 1];
                delete keys[keys.length - 1];
                keys.length--;
                break;
            }
        }

        return true;
    }

    function keyHasPurpose(KeyHolderData storage _keyHolderData, bytes32 _key, uint256 _purpose)
        public
        view
        returns(bool isThere)
    {
        if (_keyHolderData.keys[_key].key == 0) {
            isThere = false;
        }

        uint256[] storage purposes = _keyHolderData.keys[_key].purposes;
        for (uint i = 0; i < purposes.length; i++) {
            // We do not want to have purpose J if you have purpose I and I < J
            // Exception: we want purpose 1 to have all purposes.
            if (purposes[i] == _purpose || purposes[i] == 1) {
                isThere = true;
                break;
            }
        }
    }
}

// File: contracts/identity/KeyHolder.sol

/**
 * @title Manages an ERC 725 identity keys.
 * @notice Fork of Origin Protocol's implementation at
 * https://github.com/OriginProtocol/origin/blob/master/origin-contracts/contracts/identity/KeyHolder.sol
 *
 * We defined our own set of "sub-ACTION" keys:
 * - 20001 = read private profile & documents (grants isReader()).
 *  Usefull for contracts, for instance to add import contracts.
 * - 20002 = write "Private profile" & Documents (except issueDocument)
 * - 20003 = read Partnerships
 * - 20004 = blacklist / unblacklist for identityboxSendtext/identityboxSendfile
 * We also use:
 * - 3 = CLAIM = to issueDocument
 *
 * Moreover we can add purpose to already existing key.
 */
contract KeyHolder is ERC725 {
    KeyHolderLibrary.KeyHolderData keyHolderData;

    constructor() public {
        KeyHolderLibrary.init(keyHolderData);
    }

    function getKey(bytes32 _key)
        public
        view
        returns(uint256[] purposes, uint256 keyType, bytes32 key)
    {
        return KeyHolderLibrary.getKey(keyHolderData, _key);
    }

    function getKeyPurposes(bytes32 _key)
        public
        view
        returns(uint256[] purposes)
    {
        return KeyHolderLibrary.getKeyPurposes(keyHolderData, _key);
    }

    function getKeysByPurpose(uint256 _purpose)
        public
        view
        returns(bytes32[] _keys)
    {
        return KeyHolderLibrary.getKeysByPurpose(keyHolderData, _purpose);
    }

    function addKey(bytes32 _key, uint256 _purpose, uint256 _type)
        public
        returns (bool success)
    {
        return KeyHolderLibrary.addKey(keyHolderData, _key, _purpose, _type);
    }

    function addPurpose(bytes32 _key, uint256 _purpose)
        public
        returns (bool)
    {
        return KeyHolderLibrary.addPurpose(keyHolderData, _key, _purpose);
    }

    function approve(uint256 _id, bool _approve)
        public
        returns (bool success)
    {
        return KeyHolderLibrary.approve(keyHolderData, _id, _approve);
    }

    function execute(address _to, uint256 _value, bytes _data)
        public
        returns (uint256 executionId)
    {
        return KeyHolderLibrary.execute(keyHolderData, _to, _value, _data);
    }

    function removeKey(bytes32 _key, uint256 _purpose)
        public
        returns (bool success)
    {
        return KeyHolderLibrary.removeKey(keyHolderData, _key, _purpose);
    }

    function keyHasPurpose(bytes32 _key, uint256 _purpose)
        public
        view
        returns(bool exists)
    {
        return KeyHolderLibrary.keyHasPurpose(keyHolderData, _key, _purpose);
    }

}

// File: contracts/identity/ClaimHolderLibrary.sol

/**
 * @title Library for ClaimHolder.
 * @notice Fork of Origin Protocol's implementation at
 * https://github.com/OriginProtocol/origin/blob/master/origin-contracts/contracts/identity/ClaimHolderLibrary.sol
 * @author Talao, Polynomial.
 */
library ClaimHolderLibrary {
    event ClaimAdded(
        bytes32 indexed claimId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri
    );
    event ClaimRemoved(
        bytes32 indexed claimId,
        uint256 indexed topic,
        uint256 scheme,
        address indexed issuer,
        bytes signature,
        bytes data,
        string uri
    );

    struct Claim {
        uint256 topic;
        uint256 scheme;
        address issuer; // msg.sender
        bytes signature; // this.address + topic + data
        bytes data;
        string uri;
    }

    struct Claims {
        mapping (bytes32 => Claim) byId;
        mapping (uint256 => bytes32[]) byTopic;
    }

    function addClaim(
        KeyHolderLibrary.KeyHolderData storage _keyHolderData,
        Claims storage _claims,
        uint256 _topic,
        uint256 _scheme,
        address _issuer,
        bytes _signature,
        bytes _data,
        string _uri
    )
        public
        returns (bytes32 claimRequestId)
    {
        if (msg.sender != address(this)) {
            require(KeyHolderLibrary.keyHasPurpose(_keyHolderData, keccak256(abi.encodePacked(msg.sender)), 3), "Sender does not have claim signer key");
        }

        bytes32 claimId = keccak256(abi.encodePacked(_issuer, _topic));

        if (_claims.byId[claimId].issuer != _issuer) {
            _claims.byTopic[_topic].push(claimId);
        }

        _claims.byId[claimId].topic = _topic;
        _claims.byId[claimId].scheme = _scheme;
        _claims.byId[claimId].issuer = _issuer;
        _claims.byId[claimId].signature = _signature;
        _claims.byId[claimId].data = _data;
        _claims.byId[claimId].uri = _uri;

        emit ClaimAdded(
            claimId,
            _topic,
            _scheme,
            _issuer,
            _signature,
            _data,
            _uri
        );

        return claimId;
    }

    /**
     * @dev Slightly modified version of Origin Protocol's implementation.
     * getBytes for signature was originally getBytes(_signature, (i * 65), 65)
     * and now isgetBytes(_signature, (i * 32), 32)
     * and if signature is empty, just return empty.
     */
    function addClaims(
        KeyHolderLibrary.KeyHolderData storage _keyHolderData,
        Claims storage _claims,
        uint256[] _topic,
        address[] _issuer,
        bytes _signature,
        bytes _data,
        uint256[] _offsets
    )
        public
    {
        uint offset = 0;
        for (uint16 i = 0; i < _topic.length; i++) {
            if (_signature.length > 0) {
                addClaim(
                    _keyHolderData,
                    _claims,
                    _topic[i],
                    1,
                    _issuer[i],
                    getBytes(_signature, (i * 32), 32),
                    getBytes(_data, offset, _offsets[i]),
                    ""
                );
            } else {
                addClaim(
                    _keyHolderData,
                    _claims,
                    _topic[i],
                    1,
                    _issuer[i],
                    "",
                    getBytes(_data, offset, _offsets[i]),
                    ""
                );
            }
            offset += _offsets[i];
        }
    }

    function removeClaim(
        KeyHolderLibrary.KeyHolderData storage _keyHolderData,
        Claims storage _claims,
        bytes32 _claimId
    )
        public
        returns (bool success)
    {
        if (msg.sender != address(this)) {
            require(KeyHolderLibrary.keyHasPurpose(_keyHolderData, keccak256(abi.encodePacked(msg.sender)), 1), "Sender does not have management key");
        }

        emit ClaimRemoved(
            _claimId,
            _claims.byId[_claimId].topic,
            _claims.byId[_claimId].scheme,
            _claims.byId[_claimId].issuer,
            _claims.byId[_claimId].signature,
            _claims.byId[_claimId].data,
            _claims.byId[_claimId].uri
        );

        delete _claims.byId[_claimId];
        return true;
    }

    /**
     * @dev "Update" self-claims.
     */
    function updateSelfClaims(
        KeyHolderLibrary.KeyHolderData storage _keyHolderData,
        Claims storage _claims,
        uint256[] _topic,
        bytes _data,
        uint256[] _offsets
    )
        public
    {
        uint offset = 0;
        for (uint16 i = 0; i < _topic.length; i++) {
            removeClaim(
                _keyHolderData,
                _claims,
                keccak256(abi.encodePacked(msg.sender, _topic[i]))
            );
            addClaim(
                _keyHolderData,
                _claims,
                _topic[i],
                1,
                msg.sender,
                "",
                getBytes(_data, offset, _offsets[i]),
                ""
            );
            offset += _offsets[i];
        }
    }

    function getClaim(Claims storage _claims, bytes32 _claimId)
        public
        view
        returns(
          uint256 topic,
          uint256 scheme,
          address issuer,
          bytes signature,
          bytes data,
          string uri
        )
    {
        return (
            _claims.byId[_claimId].topic,
            _claims.byId[_claimId].scheme,
            _claims.byId[_claimId].issuer,
            _claims.byId[_claimId].signature,
            _claims.byId[_claimId].data,
            _claims.byId[_claimId].uri
        );
    }

    function getBytes(bytes _str, uint256 _offset, uint256 _length)
        internal
        pure
        returns (bytes)
    {
        bytes memory sig = new bytes(_length);
        uint256 j = 0;
        for (uint256 k = _offset; k < _offset + _length; k++) {
            sig[j] = _str[k];
            j++;
        }
        return sig;
    }
}

// File: contracts/identity/ClaimHolder.sol

/**
 * @title Manages ERC 735 claims.
 * @notice Fork of Origin Protocol's implementation at
 * https://github.com/OriginProtocol/origin/blob/master/origin-contracts/contracts/identity/ClaimHolder.sol
 * @author Talao, Polynomial.
 */
contract ClaimHolder is KeyHolder, ERC735 {

    ClaimHolderLibrary.Claims claims;

    function addClaim(
        uint256 _topic,
        uint256 _scheme,
        address _issuer,
        bytes _signature,
        bytes _data,
        string _uri
    )
        public
        returns (bytes32 claimRequestId)
    {
        return ClaimHolderLibrary.addClaim(
            keyHolderData,
            claims,
            _topic,
            _scheme,
            _issuer,
            _signature,
            _data,
            _uri
        );
    }

    function addClaims(
        uint256[] _topic,
        address[] _issuer,
        bytes _signature,
        bytes _data,
        uint256[] _offsets
    )
        public
    {
        ClaimHolderLibrary.addClaims(
            keyHolderData,
            claims,
            _topic,
            _issuer,
            _signature,
            _data,
            _offsets
        );
    }

    function removeClaim(bytes32 _claimId) public returns (bool success) {
        return ClaimHolderLibrary.removeClaim(keyHolderData, claims, _claimId);
    }

    function updateSelfClaims(
        uint256[] _topic,
        bytes _data,
        uint256[] _offsets
    )
        public
    {
        ClaimHolderLibrary.updateSelfClaims(
            keyHolderData,
            claims,
            _topic,
            _data,
            _offsets
        );
    }

    function getClaim(bytes32 _claimId)
        public
        view
        returns(
            uint256 topic,
            uint256 scheme,
            address issuer,
            bytes signature,
            bytes data,
            string uri
        )
    {
        return ClaimHolderLibrary.getClaim(claims, _claimId);
    }

    function getClaimIdsByTopic(uint256 _topic)
        public
        view
        returns(bytes32[] claimIds)
    {
        return claims.byTopic[_topic];
    }
}

// File: contracts/ownership/OwnableUpdated.sol

/**
 * @title Ownable
 * @notice Implementation by OpenZeppelin
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */
contract OwnableUpdated {
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
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
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

// File: contracts/Foundation.sol

/**
 * @title Foundation contract.
 * @author Talao, Polynomial.
 */
contract Foundation is OwnableUpdated {

    // Registered foundation factories.
    mapping(address => bool) public factories;

    // Owners (EOA) to contract addresses relationships.
    mapping(address => address) public ownersToContracts;

    // Contract addresses to owners relationships.
    mapping(address => address) public contractsToOwners;

    // Index of known contract addresses.
    address[] private contractsIndex;

    // Members (EOA) to contract addresses relationships.
    // In a Partnership.sol inherited contract, this allows us to create a
    // modifier for most read functions in this contract that will authorize
    // any account associated with an authorized Partnership contract.
    mapping(address => address) public membersToContracts;

    // Index of known members for each contract.
    // These are EOAs that were added once, even if removed now.
    mapping(address => address[]) public contractsToKnownMembersIndexes;

    // Events for factories.
    event FactoryAdded(address _factory);
    event FactoryRemoved(address _factory);

    /**
     * @dev Add a factory.
     */
    function addFactory(address _factory) external onlyOwner {
        factories[_factory] = true;
        emit FactoryAdded(_factory);
    }

    /**
     * @dev Remove a factory.
     */
    function removeFactory(address _factory) external onlyOwner {
        factories[_factory] = false;
        emit FactoryRemoved(_factory);
    }

    /**
     * @dev Modifier for factories.
     */
    modifier onlyFactory() {
        require(
            factories[msg.sender],
            "You are not a factory"
        );
        _;
    }

    /**
     * @dev Set initial owner of a contract.
     */
    function setInitialOwnerInFoundation(
        address _contract,
        address _account
    )
        external
        onlyFactory
    {
        require(
            contractsToOwners[_contract] == address(0),
            "Contract already has owner"
        );
        require(
            ownersToContracts[_account] == address(0),
            "Account already has contract"
        );
        contractsToOwners[_contract] = _account;
        contractsIndex.push(_contract);
        ownersToContracts[_account] = _contract;
        membersToContracts[_account] = _contract;
    }

    /**
     * @dev Transfer a contract to another account.
     */
    function transferOwnershipInFoundation(
        address _contract,
        address _newAccount
    )
        external
    {
        require(
            (
                ownersToContracts[msg.sender] == _contract &&
                contractsToOwners[_contract] == msg.sender
            ),
            "You are not the owner"
        );
        ownersToContracts[msg.sender] = address(0);
        membersToContracts[msg.sender] = address(0);
        ownersToContracts[_newAccount] = _contract;
        membersToContracts[_newAccount] = _contract;
        contractsToOwners[_contract] = _newAccount;
        // Remark: we do not update the contracts members.
        // It's the new owner's responsability to remove members, if needed.
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * This is called through the contract.
     */
    function renounceOwnershipInFoundation() external returns (bool success) {
        // Remove members.
        delete(contractsToKnownMembersIndexes[msg.sender]);
        // Free the EOA, so he can become owner of a new contract.
        delete(ownersToContracts[contractsToOwners[msg.sender]]);
        // Assign the contract to no one.
        delete(contractsToOwners[msg.sender]);
        // Return.
        success = true;
    }

    /**
     * @dev Add a member EOA to a contract.
     */
    function addMember(address _member) external {
        require(
            ownersToContracts[msg.sender] != address(0),
            "You own no contract"
        );
        require(
            membersToContracts[_member] == address(0),
            "Address is already member of a contract"
        );
        membersToContracts[_member] = ownersToContracts[msg.sender];
        contractsToKnownMembersIndexes[ownersToContracts[msg.sender]].push(_member);
    }

    /**
     * @dev Remove a member EOA to a contract.
     */
    function removeMember(address _member) external {
        require(
            ownersToContracts[msg.sender] != address(0),
            "You own no contract"
        );
        require(
            membersToContracts[_member] == ownersToContracts[msg.sender],
            "Address is not member of this contract"
        );
        membersToContracts[_member] = address(0);
        contractsToKnownMembersIndexes[ownersToContracts[msg.sender]].push(_member);
    }

    /**
     * @dev Getter for contractsIndex.
     * The automatic getter can not return array.
     */
    function getContractsIndex()
        external
        onlyOwner
        view
        returns (address[])
    {
        return contractsIndex;
    }

    /**
     * @dev Prevents accidental sending of ether.
     */
    function() public {
        revert("Prevent accidental sending of ether");
    }
}

// File: contracts/token/TalaoToken.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title TalaoMarketplace
 * @dev This contract is allowing users to buy or sell Talao tokens at a price set by the owner
 * @author Blockchain Partner
 */
contract TalaoMarketplace is Ownable {
  using SafeMath for uint256;

  TalaoToken public token;

  struct MarketplaceData {
    uint buyPrice;
    uint sellPrice;
    uint unitPrice;
  }

  MarketplaceData public marketplace;

  event SellingPrice(uint sellingPrice);
  event TalaoBought(address buyer, uint amount, uint price, uint unitPrice);
  event TalaoSold(address seller, uint amount, uint price, uint unitPrice);

  /**
  * @dev Constructor of the marketplace pointing to the TALAO token address
  * @param talao the talao token address
  **/
  constructor(address talao)
      public
  {
      token = TalaoToken(talao);
  }

  /**
  * @dev Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
  * @param newSellPrice price the users can sell to the contract
  * @param newBuyPrice price users can buy from the contract
  * @param newUnitPrice to manage decimal issue 0,35 = 35 /100 (100 is unit)
  */
  function setPrices(uint256 newSellPrice, uint256 newBuyPrice, uint256 newUnitPrice)
      public
      onlyOwner
  {
      require (newSellPrice > 0 && newBuyPrice > 0 && newUnitPrice > 0, "wrong inputs");
      marketplace.sellPrice = newSellPrice;
      marketplace.buyPrice = newBuyPrice;
      marketplace.unitPrice = newUnitPrice;
  }

  /**
  * @dev Allow anyone to buy tokens against ether, depending on the buyPrice set by the contract owner.
  * @return amount the amount of tokens bought
  **/
  function buy()
      public
      payable
      returns (uint amount)
  {
      amount = msg.value.mul(marketplace.unitPrice).div(marketplace.buyPrice);
      token.transfer(msg.sender, amount);
      emit TalaoBought(msg.sender, amount, marketplace.buyPrice, marketplace.unitPrice);
      return amount;
  }

  /**
  * @dev Allow anyone to sell tokens for ether, depending on the sellPrice set by the contract owner.
  * @param amount the number of tokens to be sold
  * @return revenue ethers sent in return
  **/
  function sell(uint amount)
      public
      returns (uint revenue)
  {
      require(token.balanceOf(msg.sender) >= amount, "sender has not enough tokens");
      token.transferFrom(msg.sender, this, amount);
      revenue = amount.mul(marketplace.sellPrice).div(marketplace.unitPrice);
      msg.sender.transfer(revenue);
      emit TalaoSold(msg.sender, amount, marketplace.sellPrice, marketplace.unitPrice);
      return revenue;
  }

  /**
   * @dev Allows the owner to withdraw ethers from the contract.
   * @param ethers quantity of ethers to be withdrawn
   * @return true if withdrawal successful ; false otherwise
   */
  function withdrawEther(uint256 ethers)
      public
      onlyOwner
  {
      if (this.balance >= ethers) {
          msg.sender.transfer(ethers);
      }
  }

  /**
   * @dev Allow the owner to withdraw tokens from the contract.
   * @param tokens quantity of tokens to be withdrawn
   */
  function withdrawTalao(uint256 tokens)
      public
      onlyOwner
  {
      token.transfer(msg.sender, tokens);
  }


  /**
  * @dev Fallback function ; only owner can send ether.
  **/
  function ()
      public
      payable
      onlyOwner
  {

  }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}


/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock {
  using SafeERC20 for ERC20Basic;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint256 public releaseTime;

  function TokenTimelock(ERC20Basic _token, address _beneficiary, uint256 _releaseTime) public {
    require(_releaseTime > now);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   * @dev Removed original require that amount released was > 0 ; releasing 0 is fine
   */
  function release() public {
    require(now >= releaseTime);

    uint256 amount = token.balanceOf(this);

    token.safeTransfer(beneficiary, amount);
  }
}


/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 * @notice Talao token transfer function cannot fail thus there's no need for revocation.
 */
contract TokenVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(uint256 amount);
  event Revoked();

  // beneficiary of tokens after they are released
  address public beneficiary;

  uint256 public cliff;
  uint256 public start;
  uint256 public duration;

  bool public revocable;

  mapping (address => uint256) public released;
  mapping (address => bool) public revoked;

  /**
   * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all
   * of the balance will have vested.
   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
   * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
   * @param _duration duration in seconds of the period in which the tokens will vest
   * @param _revocable whether the vesting is revocable or not
   */
  function TokenVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {
    require(_beneficiary != address(0));
    require(_cliff <= _duration);

    beneficiary = _beneficiary;
    revocable = _revocable;
    duration = _duration;
    cliff = _start.add(_cliff);
    start = _start;
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   * @dev Removed original require that amount released was > 0 ; releasing 0 is fine
   * @param token ERC20 token which is being vested
   */
  function release(ERC20Basic token) public {
    uint256 unreleased = releasableAmount(token);

    released[token] = released[token].add(unreleased);

    token.safeTransfer(beneficiary, unreleased);

    Released(unreleased);
  }

  /**
   * @notice Allows the owner to revoke the vesting. Tokens already vested
   * remain in the contract, the rest are returned to the owner.
   * @param token ERC20 token which is being vested
   */
  function revoke(ERC20Basic token) public onlyOwner {
    require(revocable);
    require(!revoked[token]);

    uint256 balance = token.balanceOf(this);

    uint256 unreleased = releasableAmount(token);
    uint256 refund = balance.sub(unreleased);

    revoked[token] = true;

    token.safeTransfer(owner, refund);

    Revoked();
  }

  /**
   * @dev Calculates the amount that has already vested but hasn't been released yet.
   * @param token ERC20 token which is being vested
   */
  function releasableAmount(ERC20Basic token) public view returns (uint256) {
    return vestedAmount(token).sub(released[token]);
  }

  /**
   * @dev Calculates the amount that has already vested.
   * @param token ERC20 token which is being vested
   */
  function vestedAmount(ERC20Basic token) public view returns (uint256) {
    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released[token]);

    if (now < cliff) {
      return 0;
    } else if (now >= start.add(duration) || revoked[token]) {
      return totalBalance;
    } else {
      return totalBalance.mul(now.sub(start)).div(duration);
    }
  }
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function Crowdsale(uint256 _rate, uint256 _startTime, uint256 _endTime, address _wallet) public {
    require(_rate > 0);
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_wallet != address(0));

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    wallet = _wallet;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  // removed view to be overriden
  function validPurchase() internal returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }


}


/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() public {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }
}


/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function RefundVault(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}



/**
 * @title RefundableCrowdsale
 * @dev Extension of Crowdsale contract that adds a funding goal, and
 * the possibility of users getting a refund if goal is not met.
 * Uses a RefundVault as the crowdsale's vault.
 */
contract RefundableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;

  // minimum amount of funds to be raised in weis
  uint256 public goal;

  // refund vault used to hold funds while crowdsale is running
  RefundVault public vault;

  function RefundableCrowdsale(uint256 _goal) public {
    require(_goal > 0);
    vault = new RefundVault(wallet);
    goal = _goal;
  }

  // We're overriding the fund forwarding from Crowdsale.
  // In addition to sending the funds, we want to call
  // the RefundVault deposit function
  function forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }

  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());

    vault.refund(msg.sender);
  }

  // vault finalization task, called when owner calls finalize()
  function finalization() internal {
    if (goalReached()) {
      vault.close();
    } else {
      vault.enableRefunds();
    }

    super.finalization();
  }

  function goalReached() public view returns (bool) {
    return weiRaised >= goal;
  }

}


/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  // removed view to be overriden
  function validPurchase() internal returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

/**
 * @title ProgressiveIndividualCappedCrowdsale
 * @dev Extension of Crowdsale with a progressive individual cap
 * @dev This contract is not made for crowdsale superior to 256 * TIME_PERIOD_IN_SEC
 * @author Request.network ; some modifications by Blockchain Partner
 */
contract ProgressiveIndividualCappedCrowdsale is RefundableCrowdsale, CappedCrowdsale {

    uint public startGeneralSale;
    uint public constant TIME_PERIOD_IN_SEC = 1 days;
    uint public constant minimumParticipation = 10 finney;
    uint public constant GAS_LIMIT_IN_WEI = 5E10 wei; // limit gas price -50 Gwei wales stopper
    uint256 public baseEthCapPerAddress;

    mapping(address=>uint) public participated;

    function ProgressiveIndividualCappedCrowdsale(uint _baseEthCapPerAddress, uint _startGeneralSale)
        public
    {
        baseEthCapPerAddress = _baseEthCapPerAddress;
        startGeneralSale = _startGeneralSale;
    }

    /**
     * @dev setting cap before the general sale starts
     * @param _newBaseCap the new cap
     */
    function setBaseCap(uint _newBaseCap)
        public
        onlyOwner
    {
        require(now < startGeneralSale);
        baseEthCapPerAddress = _newBaseCap;
    }

    /**
     * @dev overriding CappedCrowdsale#validPurchase to add an individual cap
     * @return true if investors can buy at the moment
     */
    function validPurchase()
        internal
        returns(bool)
    {
        bool gasCheck = tx.gasprice <= GAS_LIMIT_IN_WEI;
        uint ethCapPerAddress = getCurrentEthCapPerAddress();
        participated[msg.sender] = participated[msg.sender].add(msg.value);
        bool enough = participated[msg.sender] >= minimumParticipation;
        return participated[msg.sender] <= ethCapPerAddress && enough && gasCheck;
    }

    /**
     * @dev Get the current individual cap.
     * @dev This amount increase everyday in an exponential way. Day 1: base cap, Day 2: 2 * base cap, Day 3: 4 * base cap ...
     * @return individual cap in wei
     */
    function getCurrentEthCapPerAddress()
        public
        constant
        returns(uint)
    {
        if (block.timestamp < startGeneralSale) return 0;
        uint timeSinceStartInSec = block.timestamp.sub(startGeneralSale);
        uint currentPeriod = timeSinceStartInSec.div(TIME_PERIOD_IN_SEC).add(1);

        // for currentPeriod > 256 will always return 0
        return (2 ** currentPeriod.sub(1)).mul(baseEthCapPerAddress);
    }
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

/**
 * @title TalaoToken
 * @dev This contract details the TALAO token and allows freelancers to create/revoke vault access, appoint agents.
 * @author Blockchain Partner
 */
contract TalaoToken is MintableToken {
  using SafeMath for uint256;

  // token details
  string public constant name = "Talao";
  string public constant symbol = "TALAO";
  uint8 public constant decimals = 18;

  // the talao marketplace address
  address public marketplace;

  // talao tokens needed to create a vault
  uint256 public vaultDeposit;
  // sum of all talao tokens desposited
  uint256 public totalDeposit;

  struct FreelanceData {
      // access price to the talent vault
      uint256 accessPrice;
      // address of appointed talent agent
      address appointedAgent;
      // how much the talent is sharing with its agent
      uint sharingPlan;
      // how much is the talent deposit
      uint256 userDeposit;
  }

  // structure that defines a client access to a vault
  struct ClientAccess {
      // is he allowed to access the vault
      bool clientAgreement;
      // the block number when access was granted
      uint clientDate;
  }

  // Vault allowance client x freelancer
  mapping (address => mapping (address => ClientAccess)) public accessAllowance;

  // Freelance data is public
  mapping (address=>FreelanceData) public data;

  enum VaultStatus {Closed, Created, PriceTooHigh, NotEnoughTokensDeposited, AgentRemoved, NewAgent, NewAccess, WrongAccessPrice}

  // Those event notifies UI about vaults action with vault status
  // Closed Vault access closed
  // Created Vault access created
  // PriceTooHigh Vault access price too high
  // NotEnoughTokensDeposited not enough tokens to pay deposit
  // AgentRemoved agent removed
  // NewAgent new agent appointed
  // NewAccess vault access granted to client
  // WrongAccessPrice client not enough token to pay vault access
  event Vault(address indexed client, address indexed freelance, VaultStatus status);

  modifier onlyMintingFinished()
  {
      require(mintingFinished == true, "minting has not finished");
      _;
  }

  /**
  * @dev Let the owner set the marketplace address once minting is over
  *      Possible to do it more than once to ensure maintainability
  * @param theMarketplace the marketplace address
  **/
  function setMarketplace(address theMarketplace)
      public
      onlyMintingFinished
      onlyOwner
  {
      marketplace = theMarketplace;
  }

  /**
  * @dev Same ERC20 behavior, but require the token to be unlocked
  * @param _spender address The address that will spend the funds.
  * @param _value uint256 The amount of tokens to be spent.
  **/
  function approve(address _spender, uint256 _value)
      public
      onlyMintingFinished
      returns (bool)
  {
      return super.approve(_spender, _value);
  }

  /**
  * @dev Same ERC20 behavior, but require the token to be unlocked and sells some tokens to refill ether balance up to minBalanceForAccounts
  * @param _to address The address to transfer to.
  * @param _value uint256 The amount to be transferred.
  **/
  function transfer(address _to, uint256 _value)
      public
      onlyMintingFinished
      returns (bool result)
  {
      return super.transfer(_to, _value);
  }

  /**
  * @dev Same ERC20 behavior, but require the token to be unlocked
  * @param _from address The address which you want to send tokens from.
  * @param _to address The address which you want to transfer to.
  * @param _value uint256 the amount of tokens to be transferred.
  **/
  function transferFrom(address _from, address _to, uint256 _value)
      public
      onlyMintingFinished
      returns (bool)
  {
      return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Set allowance for other address and notify
   *      Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
   * @param _spender The address authorized to spend
   * @param _value the max amount they can spend
   * @param _extraData some extra information to send to the approved contract
   */
  function approveAndCall(address _spender, uint256 _value, bytes _extraData)
      public
      onlyMintingFinished
      returns (bool)
  {
      tokenRecipient spender = tokenRecipient(_spender);
      if (approve(_spender, _value)) {
          spender.receiveApproval(msg.sender, _value, this, _extraData);
          return true;
      }
  }

  /**
   * @dev Allows the owner to withdraw ethers from the contract.
   * @param ethers quantity in weis of ethers to be withdrawn
   * @return true if withdrawal successful ; false otherwise
   */
  function withdrawEther(uint256 ethers)
      public
      onlyOwner
  {
      msg.sender.transfer(ethers);
  }

  /**
   * @dev Allow the owner to withdraw tokens from the contract without taking tokens from deposits.
   * @param tokens quantity of tokens to be withdrawn
   */
  function withdrawTalao(uint256 tokens)
      public
      onlyOwner
  {
      require(balanceOf(this).sub(totalDeposit) >= tokens, "too much tokens asked");
      _transfer(this, msg.sender, tokens);
  }

  /******************************************/
  /*      vault functions start here        */
  /******************************************/

  /**
  * @dev Allows anyone to create a vault access.
  *      Vault deposit is transferred to token contract and sum is stored in totalDeposit
  *      Price must be lower than Vault deposit
  * @param price to pay to access certificate vault
  */
  function createVaultAccess (uint256 price)
      public
      onlyMintingFinished
  {
      require(accessAllowance[msg.sender][msg.sender].clientAgreement==false, "vault already created");
      require(price<=vaultDeposit, "price asked is too high");
      require(balanceOf(msg.sender)>vaultDeposit, "user has not enough tokens to send deposit");
      data[msg.sender].accessPrice=price;
      super.transfer(this, vaultDeposit);
      totalDeposit = totalDeposit.add(vaultDeposit);
      data[msg.sender].userDeposit=vaultDeposit;
      data[msg.sender].sharingPlan=100;
      accessAllowance[msg.sender][msg.sender].clientAgreement=true;
      emit Vault(msg.sender, msg.sender, VaultStatus.Created);
  }

  /**
  * @dev Closes a vault access, deposit is sent back to freelance wallet
  *      Total deposit in token contract is reduced by user deposit
  */
  function closeVaultAccess()
      public
      onlyMintingFinished
  {
      require(accessAllowance[msg.sender][msg.sender].clientAgreement==true, "vault has not been created");
      require(_transfer(this, msg.sender, data[msg.sender].userDeposit), "token deposit transfer failed");
      accessAllowance[msg.sender][msg.sender].clientAgreement=false;
      totalDeposit=totalDeposit.sub(data[msg.sender].userDeposit);
      data[msg.sender].sharingPlan=0;
      emit Vault(msg.sender, msg.sender, VaultStatus.Closed);
  }

  /**
  * @dev Internal transfer function used to transfer tokens from an address to another without prior authorization.
  *      Only used in these situations:
  *           * Send tokens from the contract to a token buyer (buy() function)
  *           * Send tokens from the contract to the owner in order to withdraw tokens (withdrawTalao(tokens) function)
  *           * Send tokens from the contract to a user closing its vault thus claiming its deposit back (closeVaultAccess() function)
  * @param _from address The address which you want to send tokens from.
  * @param _to address The address which you want to transfer to.
  * @param _value uint256 the amount of tokens to be transferred.
  * @return true if transfer is successful ; should throw otherwise
  */
  function _transfer(address _from, address _to, uint _value)
      internal
      returns (bool)
  {
      require(_to != 0x0, "destination cannot be 0x0");
      require(balances[_from] >= _value, "not enough tokens in sender wallet");

      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      emit Transfer(_from, _to, _value);
      return true;
  }

  /**
  * @dev Appoint an agent or a new agent
  *      Former agent is replaced by new agent
  *      Agent will receive token on behalf of the freelance talent
  * @param newagent agent to appoint
  * @param newplan sharing plan is %, 100 means 100% for freelance
  */
  function agentApproval (address newagent, uint newplan)
      public
      onlyMintingFinished
  {
      require(newplan>=0&&newplan<=100, "plan must be between 0 and 100");
      require(accessAllowance[msg.sender][msg.sender].clientAgreement==true, "vault has not been created");
      emit Vault(data[msg.sender].appointedAgent, msg.sender, VaultStatus.AgentRemoved);
      data[msg.sender].appointedAgent=newagent;
      data[msg.sender].sharingPlan=newplan;
      emit Vault(newagent, msg.sender, VaultStatus.NewAgent);
  }

  /**
   * @dev Set the quantity of tokens necessary for vault access creation
   * @param newdeposit deposit (in tokens) for vault access creation
   */
  function setVaultDeposit (uint newdeposit)
      public
      onlyOwner
  {
      vaultDeposit = newdeposit;
  }

  /**
  * @dev Buy unlimited access to a freelancer vault
  *      Vault access price is transfered from client to agent or freelance depending on the sharing plan
  *      Allowance is given to client and one stores block.number for future use
  * @param freelance the address of the talent
  * @return true if access is granted ; false if not
  */
  function getVaultAccess (address freelance)
      public
      onlyMintingFinished
      returns (bool)
  {
      require(accessAllowance[freelance][freelance].clientAgreement==true, "vault does not exist");
      require(accessAllowance[msg.sender][freelance].clientAgreement!=true, "access was already granted");
      require(balanceOf(msg.sender)>data[freelance].accessPrice, "user has not enough tokens to get access to vault");

      uint256 freelance_share = data[freelance].accessPrice.mul(data[freelance].sharingPlan).div(100);
      uint256 agent_share = data[freelance].accessPrice.sub(freelance_share);
      if(freelance_share>0) super.transfer(freelance, freelance_share);
      if(agent_share>0) super.transfer(data[freelance].appointedAgent, agent_share);
      accessAllowance[msg.sender][freelance].clientAgreement=true;
      accessAllowance[msg.sender][freelance].clientDate=block.number;
      emit Vault(msg.sender, freelance, VaultStatus.NewAccess);
      return true;
  }

  /**
  * @dev Simple getter to retrieve talent agent
  * @param freelance talent address
  * @return address of the agent
  **/
  function getFreelanceAgent(address freelance)
      public
      view
      returns (address)
  {
      return data[freelance].appointedAgent;
  }

  /**
  * @dev Simple getter to check if user has access to a freelance vault
  * @param freelance talent address
  * @param user user address
  * @return true if access granted or false if not
  **/
  function hasVaultAccess(address freelance, address user)
      public
      view
      returns (bool)
  {
      return ((accessAllowance[user][freelance].clientAgreement) || (data[freelance].appointedAgent == user));
  }

}

// File: contracts/identity/Identity.sol

/**
 * @title The Identity is where ERC 725/735 and our custom code meet.
 * @author Talao, Polynomial.
 * @notice Mixes ERC 725/735, foundation, token,
 * constructor values that never change (creator, category, encryption keys)
 * and provides a box to receive decentralized files and texts.
 */
contract Identity is ClaimHolder {

    // Foundation contract.
    Foundation foundation;

    // Talao token contract.
    TalaoToken public token;

    // Identity information struct.
    struct IdentityInformation {
        // Address of this contract creator (factory).
        // bytes16 left on SSTORAGE 1 after this.
        address creator;

        // Identity category.
        // 1001 => 1999: Freelancer.
        // 2001 => 2999: Freelancer team.
        // 3001 => 3999: Corporate marketplace.
        // 4001 => 4999: Public marketplace.
        // 5001 => 5999: Service provider.
        // ..
        // 64001 => 64999: ?
        // bytes14 left after this on SSTORAGE 1.
        uint16 category;

        // Asymetric encryption key algorithm.
        // We use an integer to store algo with offchain references.
        // 1 => RSA 2048
        // bytes12 left after this on SSTORAGE 1.
        uint16 asymetricEncryptionAlgorithm;

        // Symetric encryption key algorithm.
        // We use an integer to store algo with offchain references.
        // 1 => AES 128
        // bytes10 left after this on SSTORAGE 1.
        uint16 symetricEncryptionAlgorithm;

        // Asymetric encryption public key.
        // This one can be used to encrypt content especially for this
        // contract owner, which is the only one to have the private key,
        // offchain of course.
        bytes asymetricEncryptionPublicKey;

        // Encrypted symetric encryption key (in Hex).
        // When decrypted, this passphrase can regenerate
        // the symetric encryption key.
        // This key encrypts and decrypts data to be shared with many people.
        // Uses 0.5 SSTORAGE for AES 128.
        bytes symetricEncryptionEncryptedKey;

        // Other encrypted secret we might use.
        bytes encryptedSecret;
    }
    // This contract Identity information.
    IdentityInformation public identityInformation;

    // Identity box: blacklisted addresses.
    mapping(address => bool) public identityboxBlacklisted;

    // Identity box: event when someone sent us a text.
    event TextReceived (
        address indexed sender,
        uint indexed category,
        bytes text
    );

    // Identity box: event when someone sent us an decentralized file.
    event FileReceived (
        address indexed sender,
        uint indexed fileType,
        uint fileEngine,
        bytes fileHash
    );

    /**
     * @dev Constructor.
     */
    constructor(
        address _foundation,
        address _token,
        uint16 _category,
        uint16 _asymetricEncryptionAlgorithm,
        uint16 _symetricEncryptionAlgorithm,
        bytes _asymetricEncryptionPublicKey,
        bytes _symetricEncryptionEncryptedKey,
        bytes _encryptedSecret
    )
        public
    {
        foundation = Foundation(_foundation);
        token = TalaoToken(_token);
        identityInformation.creator = msg.sender;
        identityInformation.category = _category;
        identityInformation.asymetricEncryptionAlgorithm = _asymetricEncryptionAlgorithm;
        identityInformation.symetricEncryptionAlgorithm = _symetricEncryptionAlgorithm;
        identityInformation.asymetricEncryptionPublicKey = _asymetricEncryptionPublicKey;
        identityInformation.symetricEncryptionEncryptedKey = _symetricEncryptionEncryptedKey;
        identityInformation.encryptedSecret = _encryptedSecret;
    }

    /**
     * @dev Owner of this contract, in the Foundation sense.
     * We do not allow this to be used externally,
     * since a contract could fake ownership.
     * In other contracts, you have to call the Foundation to
     * know the real owner of this contract.
     */
    function identityOwner() internal view returns (address) {
        return foundation.contractsToOwners(address(this));
    }

    /**
     * @dev Check in Foundation if msg.sender is the owner of this contract.
     * Same remark.
     */
    function isIdentityOwner() internal view returns (bool) {
        return msg.sender == identityOwner();
    }

    /**
     * @dev Modifier version of isIdentityOwner.
     */
    modifier onlyIdentityOwner() {
        require(isIdentityOwner(), "Access denied");
        _;
    }

    /**
     * @dev Owner functions require open Vault in token.
     */
    function isActiveIdentityOwner() public view returns (bool) {
        return isIdentityOwner() && token.hasVaultAccess(msg.sender, msg.sender);
    }

    /**
     * @dev Modifier version of isActiveOwner.
     */
    modifier onlyActiveIdentityOwner() {
        require(isActiveIdentityOwner(), "Access denied");
        _;
    }

    /**
     * @dev Does this contract owner have an open Vault in the token?
     */
    function isActiveIdentity() public view returns (bool) {
        return token.hasVaultAccess(identityOwner(), identityOwner());
    }

    /**
     * @dev Does msg.sender have an ERC 725 key with certain purpose,
     * and does the contract owner have an open Vault in the token?
     */
    function hasIdentityPurpose(uint256 _purpose) public view returns (bool) {
        return (
            keyHasPurpose(keccak256(abi.encodePacked(msg.sender)), _purpose) &&
            isActiveIdentity()
        );
    }

    /**
     * @dev Modifier version of hasKeyForPurpose
     */
    modifier onlyIdentityPurpose(uint256 _purpose) {
        require(hasIdentityPurpose(_purpose), "Access denied");
        _;
    }

    /**
     * @dev "Send" a text to this contract.
     * Text can be encrypted on this contract asymetricEncryptionPublicKey,
     * before submitting a TX here.
     */
    function identityboxSendtext(uint _category, bytes _text) external {
        require(!identityboxBlacklisted[msg.sender], "You are blacklisted");
        emit TextReceived(msg.sender, _category, _text);
    }

    /**
     * @dev "Send" a "file" to this contract.
     * File should be encrypted on this contract asymetricEncryptionPublicKey,
     * before upload on decentralized file storage,
     * before submitting a TX here.
     */
    function identityboxSendfile(
        uint _fileType, uint _fileEngine, bytes _fileHash
    )
        external
    {
        require(!identityboxBlacklisted[msg.sender], "You are blacklisted");
        emit FileReceived(msg.sender, _fileType, _fileEngine, _fileHash);
    }

    /**
     * @dev Blacklist an address in this Identity box.
     */
    function identityboxBlacklist(address _address)
        external
        onlyIdentityPurpose(20004)
    {
        identityboxBlacklisted[_address] = true;
    }

    /**
     * @dev Unblacklist.
     */
    function identityboxUnblacklist(address _address)
        external
        onlyIdentityPurpose(20004)
    {
        identityboxBlacklisted[_address] = false;
    }
}

/**
 * @title Interface with clones or inherited contracts.
 */
interface IdentityInterface {
    function identityInformation()
        external
        view
        returns (address, uint16, uint16, uint16, bytes, bytes, bytes);
    function identityboxSendtext(uint, bytes) external;
}

// File: contracts/math/SafeMathUpdated.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */
library SafeMathUpdated {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

// File: contracts/access/Partnership.sol

/**
 * @title Provides partnership features between contracts.
 * @notice If msg.sender is the owner, in the Foundation sense
 * (see Foundation.sol, of another partnership contract that is
 * authorized in this partnership contract,
 * then he passes isPartnershipMember().
 * Obviously this function is meant to be used in modifiers
 * in contrats that inherit of this one and provide "restricted" content.
 * Partnerships are symetrical: when you request a partnership,
 * you automatically authorize the requested partnership contract.
 * Same thing when you remove a partnership.
 * This is done through symetrical functions,
 * where the user submits a tx on his own Partnership contract to ask partnership
 * to another and not on the other contract.
 * Convention here: _function = to be called by another partnership contract.
 * @author Talao, Polynomial.
 */
contract Partnership is Identity {

    using SafeMathUpdated for uint;

    // Foundation contract.
    Foundation foundation;

    // Authorization status.
    enum PartnershipAuthorization { Unknown, Authorized, Pending, Rejected, Removed }

    // Other Partnership contract information.
    struct PartnershipContract {
        // Authorization of this contract.
        // bytes31 left after this on SSTORAGE 1.
        PartnershipAuthorization authorization;
        // Date of partnership creation.
        // Let's avoid the 2038 year bug, even if this contract will be dead
        // a lot sooner! It costs nothing, so...
        // bytes26 left after this on SSTORAGE 1.
        uint40 created;
        // His symetric encryption key,
        // encrypted on our asymetric encryption public key.
        bytes symetricEncryptionEncryptedKey;
    }
    // Our main registry of Partnership contracts.
    mapping(address => PartnershipContract) internal partnershipContracts;

    // Index of known partnerships (contracts which interacted at least once).
    address[] internal knownPartnershipContracts;

    // Total of authorized Partnerships contracts.
    uint public partnershipsNumber;

    // Event when another Partnership contract has asked partnership.
    event PartnershipRequested();

    // Event when another Partnership contract has authorized our request.
    event PartnershipAccepted();

    /**
     * @dev Constructor.
     */
    constructor(
        address _foundation,
        address _token,
        uint16 _category,
        uint16 _asymetricEncryptionAlgorithm,
        uint16 _symetricEncryptionAlgorithm,
        bytes _asymetricEncryptionPublicKey,
        bytes _symetricEncryptionEncryptedKey,
        bytes _encryptedSecret
    )
        Identity(
            _foundation,
            _token,
            _category,
            _asymetricEncryptionAlgorithm,
            _symetricEncryptionAlgorithm,
            _asymetricEncryptionPublicKey,
            _symetricEncryptionEncryptedKey,
            _encryptedSecret
        )
        public
    {
        foundation = Foundation(_foundation);
        token = TalaoToken(_token);
        identityInformation.creator = msg.sender;
        identityInformation.category = _category;
        identityInformation.asymetricEncryptionAlgorithm = _asymetricEncryptionAlgorithm;
        identityInformation.symetricEncryptionAlgorithm = _symetricEncryptionAlgorithm;
        identityInformation.asymetricEncryptionPublicKey = _asymetricEncryptionPublicKey;
        identityInformation.symetricEncryptionEncryptedKey = _symetricEncryptionEncryptedKey;
        identityInformation.encryptedSecret = _encryptedSecret;
    }

    /**
     * @dev This function will be used in inherited contracts,
     * to restrict read access to members of Partnership contracts
     * which are authorized in this contract.
     */
    function isPartnershipMember() public view returns (bool) {
        return partnershipContracts[foundation.membersToContracts(msg.sender)].authorization == PartnershipAuthorization.Authorized;
    }

    /**
     * @dev Modifier version of isPartnershipMember.
     * Not used for now, but could be useful.
     */
    modifier onlyPartnershipMember() {
        require(isPartnershipMember());
        _;
    }

    /**
     * @dev Get partnership status in this contract for a user.
     */
    function getMyPartnershipStatus()
        external
        view
        returns (uint authorization)
    {
        // If msg.sender has no Partnership contract, return Unknown (0).
        if (foundation.membersToContracts(msg.sender) == address(0)) {
            return uint(PartnershipAuthorization.Unknown);
        } else {
            return uint(partnershipContracts[foundation.membersToContracts(msg.sender)].authorization);
        }
    }

    /**
     * @dev Get the list of all known Partnership contracts.
     */
    function getKnownPartnershipsContracts()
        external
        view
        onlyIdentityPurpose(20003)
        returns (address[])
    {
        return knownPartnershipContracts;
    }

    /**
     * @dev Get a Partnership contract information.
     */
    function getPartnership(address _hisContract)
        external
        view
        onlyIdentityPurpose(20003)
        returns (uint, uint, uint40, bytes, bytes)
    {
        (
            ,
            uint16 hisCategory,
            ,
            ,
            bytes memory hisAsymetricEncryptionPublicKey,
            ,
        ) = IdentityInterface(_hisContract).identityInformation();
        return (
            hisCategory,
            uint(partnershipContracts[_hisContract].authorization),
            partnershipContracts[_hisContract].created,
            hisAsymetricEncryptionPublicKey,
            partnershipContracts[_hisContract].symetricEncryptionEncryptedKey
        );
    }

    /**
     * @dev Request partnership.
     * The owner of this contract requests a partnership
     * with another Partnership contract
     * through THIS contract.
     * We send him our symetric encryption key as well,
     * encrypted on his symetric encryption public key.
     * Encryption done offchain before submitting this TX.
     */
    function requestPartnership(address _hisContract, bytes _ourSymetricKey)
        external
        onlyIdentityPurpose(1)
    {
        // We can only request partnership with a contract
        // if he's not already Known or Removed in our registry.
        // If he is, we symetrically are already in his partnerships.
        // Indeed when he asked a partnership with us,
        // he added us in authorized partnerships.
        require(
            partnershipContracts[_hisContract].authorization == PartnershipAuthorization.Unknown ||
            partnershipContracts[_hisContract].authorization == PartnershipAuthorization.Removed
        );
        // Request partnership in the other contract.
        // Open interface on his contract.
        PartnershipInterface hisInterface = PartnershipInterface(_hisContract);
        bool success = hisInterface._requestPartnership(_ourSymetricKey);
        // If partnership request was a success,
        if (success) {
            // If we do not know the Partnership contract yet,
            if (partnershipContracts[_hisContract].authorization == PartnershipAuthorization.Unknown) {
                // Then add it to our partnerships index.
                knownPartnershipContracts.push(_hisContract);
            }
            // Authorize Partnership contract in our contract.
            partnershipContracts[_hisContract].authorization = PartnershipAuthorization.Authorized;
            // Record date of partnership creation.
            partnershipContracts[_hisContract].created = uint40(now);
            // Give the Partnership contrat's owner an ERC 725 "Claim" key.
            addKey(keccak256(abi.encodePacked(foundation.contractsToOwners(_hisContract))), 3, 1);
            // Give the Partnership contract an ERC 725 "Claim" key.
            addKey(keccak256(abi.encodePacked(_hisContract)), 3, 1);
            // Increment our number of partnerships.
            partnershipsNumber = partnershipsNumber.add(1);
        }
    }

    /**
     * @dev Symetry of requestPartnership.
     * Called by Partnership contract wanting to partnership.
     * He sends us his symetric encryption key as well,
     * encrypted on our symetric encryption public key.
     * So we can decipher all his content.
     */
    function _requestPartnership(bytes _hisSymetricKey)
        external
        returns (bool success)
    {
        require(
            partnershipContracts[msg.sender].authorization == PartnershipAuthorization.Unknown ||
            partnershipContracts[msg.sender].authorization == PartnershipAuthorization.Removed
        );
        // If this Partnership contract is Unknown,
        if (partnershipContracts[msg.sender].authorization == PartnershipAuthorization.Unknown) {
            // Add the new partnership to our partnerships index.
            knownPartnershipContracts.push(msg.sender);
            // Record date of partnership creation.
            partnershipContracts[msg.sender].created = uint40(now);
        }
        // Write Pending to our partnerships contract registry.
        partnershipContracts[msg.sender].authorization = PartnershipAuthorization.Pending;
        // Record his symetric encryption key,
        // encrypted on our asymetric encryption public key.
        partnershipContracts[msg.sender].symetricEncryptionEncryptedKey = _hisSymetricKey;
        // Event for this contrat owner's UI.
        emit PartnershipRequested();
        // Return success.
        success = true;
    }

    /**
     * @dev Authorize Partnership.
     * Before submitting this TX, we must have encrypted our
     * symetric encryption key on his asymetric encryption public key.
     */
    function authorizePartnership(address _hisContract, bytes _ourSymetricKey)
        external
        onlyIdentityPurpose(1)
    {
        require(
            partnershipContracts[_hisContract].authorization == PartnershipAuthorization.Pending,
            "Partnership must be Pending"
        );
        // Authorize the Partnership contract in our contract.
        partnershipContracts[_hisContract].authorization = PartnershipAuthorization.Authorized;
        // Record the date of partnership creation.
        partnershipContracts[_hisContract].created = uint40(now);
        // Give the Partnership contrat's owner an ERC 725 "Claim" key.
        addKey(keccak256(abi.encodePacked(foundation.contractsToOwners(_hisContract))), 3, 1);
        // Give the Partnership contract an ERC 725 "Claim" key.
        addKey(keccak256(abi.encodePacked(_hisContract)), 3, 1);
        // Increment our number of partnerships.
        partnershipsNumber = partnershipsNumber.add(1);
        // Log an event in the new authorized partner contract.
        PartnershipInterface hisInterface = PartnershipInterface(_hisContract);
        hisInterface._authorizePartnership(_ourSymetricKey);
    }

    /**
     * @dev Allows other Partnership contract to send an event when authorizing.
     * He sends us also his symetric encryption key,
     * encrypted on our asymetric encryption public key.
     */
    function _authorizePartnership(bytes _hisSymetricKey) external {
        require(
            partnershipContracts[msg.sender].authorization == PartnershipAuthorization.Authorized,
            "You have no authorized partnership"
        );
        partnershipContracts[msg.sender].symetricEncryptionEncryptedKey = _hisSymetricKey;
        emit PartnershipAccepted();
    }

    /**
     * @dev Reject Partnership.
     */
    function rejectPartnership(address _hisContract)
        external
        onlyIdentityPurpose(1)
    {
        require(
            partnershipContracts[_hisContract].authorization == PartnershipAuthorization.Pending,
            "Partner must be Pending"
        );
        partnershipContracts[_hisContract].authorization = PartnershipAuthorization.Rejected;
    }

    /**
     * @dev Remove Partnership.
     */
    function removePartnership(address _hisContract)
        external
        onlyIdentityPurpose(1)
    {
        require(
            (
                partnershipContracts[_hisContract].authorization == PartnershipAuthorization.Authorized ||
                partnershipContracts[_hisContract].authorization == PartnershipAuthorization.Rejected
            ),
            "Partnership must be Authorized or Rejected"
        );
        // Remove ourselves in the other Partnership contract.
        PartnershipInterface hisInterface = PartnershipInterface(_hisContract);
        bool success = hisInterface._removePartnership();
        // If success,
        if (success) {
            // If it was an authorized partnership,
            if (partnershipContracts[_hisContract].authorization == PartnershipAuthorization.Authorized) {
                // Remove the partnership creation date.
                delete partnershipContracts[_hisContract].created;
                // Remove his symetric encryption key.
                delete partnershipContracts[_hisContract].symetricEncryptionEncryptedKey;
                // Decrement our number of partnerships.
                partnershipsNumber = partnershipsNumber.sub(1);
            }
            // If there is one, remove ERC 725 "Claim" key for Partnership contract owner.
            if (keyHasPurpose(keccak256(abi.encodePacked(foundation.contractsToOwners(_hisContract))), 3)) {
                removeKey(keccak256(abi.encodePacked(foundation.contractsToOwners(_hisContract))), 3);
            }
            // If there is one, remove ERC 725 "Claim" key for Partnership contract.
            if (keyHasPurpose(keccak256(abi.encodePacked(_hisContract)), 3)) {
                removeKey(keccak256(abi.encodePacked(_hisContract)), 3);
            }
            // Change his partnership to Removed in our contract.
            // We want to have Removed instead of resetting to Unknown,
            // otherwise if partnership is initiated again with him,
            // our knownPartnershipContracts would have a duplicate entry.
            partnershipContracts[_hisContract].authorization = PartnershipAuthorization.Removed;
        }
    }

    /**
     * @dev Symetry of removePartnership.
     * Called by the Partnership contract breaking partnership with us.
     */
    function _removePartnership() external returns (bool success) {
        // He wants to break partnership with us, so we break too.
        // If it was an authorized partnership,
        if (partnershipContracts[msg.sender].authorization == PartnershipAuthorization.Authorized) {
            // Remove date of partnership creation.
            delete partnershipContracts[msg.sender].created;
            // Remove his symetric encryption key.
            delete partnershipContracts[msg.sender].symetricEncryptionEncryptedKey;
            // Decrement our number of partnerships.
            partnershipsNumber = partnershipsNumber.sub(1);
        }
        // Would have liked to remove ERC 725 "Claim" keys here.
        // Unfortunately we can not automate this. Indeed it would require
        // the Partnership contract to have an ERC 725 Management key.

        // Remove his authorization.
        partnershipContracts[msg.sender].authorization = PartnershipAuthorization.Removed;
        // We return to the calling contract that it's done.
        success = true;
    }

    /**
     * @dev Internal function to remove partnerships before selfdestruct.
     */
    function cleanupPartnership() internal returns (bool success) {
        // For each known Partnership contract
        for (uint i = 0; i < knownPartnershipContracts.length; i++) {
            // If it was an authorized partnership,
            if (partnershipContracts[knownPartnershipContracts[i]].authorization == PartnershipAuthorization.Authorized) {
                // Remove ourselves in the other Partnership contract.
                PartnershipInterface hisInterface = PartnershipInterface(knownPartnershipContracts[i]);
                hisInterface._removePartnership();
            }
        }
        success = true;
    }
}


/**
 * @title Interface with clones, inherited contracts or services.
 */
interface PartnershipInterface {
    function _requestPartnership(bytes) external view returns (bool);
    function _authorizePartnership(bytes) external;
    function _removePartnership() external returns (bool success);
    function getKnownPartnershipsContracts() external returns (address[]);
    function getPartnership(address)
        external
        returns (uint, uint, uint40, bytes, bytes);
}

// File: contracts/access/Permissions.sol

/**
 * @title Permissions contract.
 * @author Talao, Polynomial.
 * @notice See ../identity/KeyHolder.sol as well.
 */
contract Permissions is Partnership {

    // Foundation contract.
    Foundation foundation;

    // Talao token contract.
    TalaoToken public token;

    /**
     * @dev Constructor.
     */
    constructor(
        address _foundation,
        address _token,
        uint16 _category,
        uint16 _asymetricEncryptionAlgorithm,
        uint16 _symetricEncryptionAlgorithm,
        bytes _asymetricEncryptionPublicKey,
        bytes _symetricEncryptionEncryptedKey,
        bytes _encryptedSecret
    )
        Partnership(
            _foundation,
            _token,
            _category,
            _asymetricEncryptionAlgorithm,
            _symetricEncryptionAlgorithm,
            _asymetricEncryptionPublicKey,
            _symetricEncryptionEncryptedKey,
            _encryptedSecret
        )
        public
    {
        foundation = Foundation(_foundation);
        token = TalaoToken(_token);
        identityInformation.creator = msg.sender;
        identityInformation.category = _category;
        identityInformation.asymetricEncryptionAlgorithm = _asymetricEncryptionAlgorithm;
        identityInformation.symetricEncryptionAlgorithm = _symetricEncryptionAlgorithm;
        identityInformation.asymetricEncryptionPublicKey = _asymetricEncryptionPublicKey;
        identityInformation.symetricEncryptionEncryptedKey = _symetricEncryptionEncryptedKey;
        identityInformation.encryptedSecret = _encryptedSecret;
    }

    /**
     * @dev Is msg.sender a "member" of this contract, in the Foundation sense?
     */
    function isMember() public view returns (bool) {
        return foundation.membersToContracts(msg.sender) == address(this);
    }

    /**
     * @dev Read authorization for inherited contracts "private" data.
     */
    function isReader() public view returns (bool) {
        // Get Vault access price in the token for this contract owner,
        // in the Foundation sense.
        (uint accessPrice,,,) = token.data(identityOwner());
        // OR conditions for Reader:
        // 1) Same code for
        // 1.1) Sender is this contract owner and has an open Vault in the token.
        // 1.2) Sender has vaultAccess to this contract owner in the token.
        // 2) Owner has open Vault in the token and:
        // 2.1) Sender is a member of this contract,
        // 2.2) Sender is a member of an authorized Partner contract
        // 2.3) Sender has an ERC 725 20001 key "Reader"
        // 2.4) Owner has a free vaultAccess in the token
        return(
            token.hasVaultAccess(identityOwner(), msg.sender) ||
            (
                token.hasVaultAccess(identityOwner(), identityOwner()) &&
                (
                    isMember() ||
                    isPartnershipMember() ||
                    hasIdentityPurpose(20001) ||
                    (accessPrice == 0 && msg.sender != address(0))
                )
            )
        );
    }

    /**
     * @dev Modifier version of isReader.
     */
    modifier onlyReader() {
        require(isReader(), "Access denied");
        _;
    }
}

// File: contracts/content/Profile.sol

/**
 * @title Profile contract.
 * @author Talao, Polynomial, Slowsense, Blockchain Partner.
 */
contract Profile is Permissions {

    // "Private" profile.
    // Access controlled by Permissions.sol.
    // Nothing is really private on the blockchain,
    // so data should be encrypted on symetric key.
    struct PrivateProfile {
        // Private email.
        bytes email;

        // Mobile number.
        bytes mobile;
    }
    PrivateProfile internal privateProfile;

    /**
     * @dev Get private profile.
     */
    function getPrivateProfile()
        external
        view
        onlyReader
        returns (bytes, bytes)
    {
        return (
            privateProfile.email,
            privateProfile.mobile
        );
    }

    /**
     * @dev Set private profile.
     */
    function setPrivateProfile(
        bytes _privateEmail,
        bytes _mobile
    )
        external
        onlyIdentityPurpose(20002)
    {
        privateProfile.email = _privateEmail;
        privateProfile.mobile = _mobile;
    }
}

// File: contracts/content/Documents.sol

/**
 * @title A Documents contract allows to manage documents and share them.
 * @notice Also contracts that have an ERC 725 Claim key (3)
 * can add certified documents.
 * @author Talao, Polynomial, SlowSense, Blockchain Partners.
 */
contract Documents is Permissions {

    using SafeMathUpdated for uint;

    // Document struct.
    struct Document {

        // True if "published", false if "unpublished".
        // 31 bytes remaining in SSTORAGE 1 after this.
        bool published;

        // True if doc is encrypted.
        // 30 bytes remaining in SSTORAGE 1 after this.
        bool encrypted;

        // Position in index.
        // 28 bytes remaining in SSTORAGE 1 after this.
        uint16 index;

        // Type of document:
        // ...
        // 50000 => 59999: experiences
        // 60000 => max: certificates
        // 26 bytes remaining in SSTORAGE 1 after this.
        uint16 docType;

        // Version of document type: 1 = "work experience version 1" document, if type_doc = 1
        // 24 bytes remaining in SSTORAGE 1 after this.
        uint16 docTypeVersion;

        // ID of related experience, for certificates.
        // 22 bytes remaining in SSTORAGE 1 after this.
        uint16 related;

        // ID of the file location engine.
        // 1 = IPFS, 2 = Swarm, 3 = Filecoin, ...
        // 20 bytes remaining in SSTORAGE 1 after this.
        uint16 fileLocationEngine;

        // Issuer of the document.
        // SSTORAGE 1 full after this.
        address issuer;

        // Checksum of the file (SHA-256 offchain).
        // SSTORAGE 2 filled after this.
        bytes32 fileChecksum;

        // Expiration date.
        uint40 expires;

        // Hash of the file location in a decentralized engine.
        // Example: IPFS hash, Swarm hash, Filecoin hash...
        // Uses 1 SSTORAGE for IPFS.
        bytes fileLocationHash;
    }

    // Documents registry.
    mapping(uint => Document) internal documents;

    // Documents index.
    uint[] internal documentsIndex;

    // Documents counter.
    uint internal documentsCounter;

    // Event: new document added.
    event DocumentAdded (uint id);

    // Event: document removed.
    event DocumentRemoved (uint id);

    // Event: certificate issued.
    event CertificateIssued (bytes32 indexed checksum, address indexed issuer, uint id);

    // Event: certificate accepted.
    event CertificateAccepted (bytes32 indexed checksum, address indexed issuer, uint id);

    /**
     * @dev Document getter.
     * @param _id uint Document ID.
     */
    function getDocument(uint _id)
        external
        view
        onlyReader
        returns (
            uint16,
            uint16,
            uint40,
            address,
            bytes32,
            uint16,
            bytes,
            bool,
            uint16
        )
    {
        Document memory doc = documents[_id];
        require(doc.published);
        return(
            doc.docType,
            doc.docTypeVersion,
            doc.expires,
            doc.issuer,
            doc.fileChecksum,
            doc.fileLocationEngine,
            doc.fileLocationHash,
            doc.encrypted,
            doc.related
        );
    }

    /**
     * @dev Get all published documents.
     */
    function getDocuments() external view onlyReader returns (uint[]) {
        return documentsIndex;
    }

    /**
     * @dev Create a document.
     */
    function createDocument(
        uint16 _docType,
        uint16 _docTypeVersion,
        uint40 _expires,
        bytes32 _fileChecksum,
        uint16 _fileLocationEngine,
        bytes _fileLocationHash,
        bool _encrypted
    )
        external
        onlyIdentityPurpose(20002)
        returns(uint)
    {
        require(_docType < 60000);
        _createDocument(
            _docType,
            _docTypeVersion,
            _expires,
            msg.sender,
            _fileChecksum,
            _fileLocationEngine,
            _fileLocationHash,
            _encrypted,
            0
        );
        return documentsCounter;
    }

    /**
     * @dev Issue a certificate.
     */
    function issueCertificate(
        uint16 _docType,
        uint16 _docTypeVersion,
        bytes32 _fileChecksum,
        uint16 _fileLocationEngine,
        bytes _fileLocationHash,
        bool _encrypted,
        uint16 _related
    )
        external
        returns(uint)
    {
        require(
            keyHasPurpose(keccak256(abi.encodePacked(foundation.membersToContracts(msg.sender))), 3) &&
            isActiveIdentity() &&
            _docType >= 60000
        );
        uint id = _createDocument(
            _docType,
            _docTypeVersion,
            0,
            foundation.membersToContracts(msg.sender),
            _fileChecksum,
            _fileLocationEngine,
            _fileLocationHash,
            _encrypted,
            _related
        );
        emit CertificateIssued(_fileChecksum, foundation.membersToContracts(msg.sender), id);
        return id;
    }

    /**
     * @dev Accept a certificate.
     */
    function acceptCertificate(uint _id) external onlyIdentityPurpose(20002) {
        Document storage doc = documents[_id];
        require(!doc.published && doc.docType >= 60000);
        // Add to index.
        doc.index = uint16(documentsIndex.push(_id).sub(1));
        // Publish.
        doc.published = true;
        // Unpublish related experience, if published.
        if (documents[doc.related].published) {
            _deleteDocument(doc.related);
        }
        // Emit event.
        emit CertificateAccepted(doc.fileChecksum, doc.issuer, _id);
    }

    /**
     * @dev Create a document.
     */
    function _createDocument(
        uint16 _docType,
        uint16 _docTypeVersion,
        uint40 _expires,
        address _issuer,
        bytes32 _fileChecksum,
        uint16 _fileLocationEngine,
        bytes _fileLocationHash,
        bool _encrypted,
        uint16 _related
    )
        internal
        returns(uint)
    {
        // Increment documents counter.
        documentsCounter = documentsCounter.add(1);
        // Storage pointer.
        Document storage doc = documents[documentsCounter];
        // For certificates:
        // - add the related experience
        // - do not add to index
        // - do not publish.
        if (_docType >= 60000) {
            doc.related = _related;
        } else {
            // Add to index.
            doc.index = uint16(documentsIndex.push(documentsCounter).sub(1));
            // Publish.
            doc.published = true;
        }
        // Common data.
        doc.encrypted = _encrypted;
        doc.docType = _docType;
        doc.docTypeVersion = _docTypeVersion;
        doc.expires = _expires;
        doc.fileLocationEngine = _fileLocationEngine;
        doc.issuer = _issuer;
        doc.fileChecksum = _fileChecksum;
        doc.fileLocationHash = _fileLocationHash;
        // Emit event.
        emit DocumentAdded(documentsCounter);
        // Return document ID.
        return documentsCounter;
    }

    /**
     * @dev Remove a document.
     */
    function deleteDocument (uint _id) external onlyIdentityPurpose(20002) {
        _deleteDocument(_id);
    }

    /**
     * @dev Remove a document.
     */
    function _deleteDocument (uint _id) internal {
        Document storage docToDelete = documents[_id];
        require (_id > 0);
        require(docToDelete.published);
        // If the removed document is not the last in the index,
        if (docToDelete.index < (documentsIndex.length).sub(1)) {
            // Find the last document of the index.
            uint lastDocId = documentsIndex[(documentsIndex.length).sub(1)];
            Document storage lastDoc = documents[lastDocId];
            // Move it in the index in place of the document to delete.
            documentsIndex[docToDelete.index] = lastDocId;
            // Update this document that was moved from last position.
            lastDoc.index = docToDelete.index;
        }
        // Remove last element from index.
        documentsIndex.length --;
        // Unpublish document.
        docToDelete.published = false;
        // Emit event.
        emit DocumentRemoved(_id);
    }

    /**
     * @dev "Update" a document.
     * Updating a document makes no sense technically.
     * Here we provide a function that deletes a doc & create a new one.
     * But for UX it's very important to have this in 1 transaction.
     */
    function updateDocument(
        uint _id,
        uint16 _docType,
        uint16 _docTypeVersion,
        uint40 _expires,
        bytes32 _fileChecksum,
        uint16 _fileLocationEngine,
        bytes _fileLocationHash,
        bool _encrypted
    )
        external
        onlyIdentityPurpose(20002)
        returns (uint)
    {
        require(_docType < 60000);
        _deleteDocument(_id);
        _createDocument(
            _docType,
            _docTypeVersion,
            _expires,
            msg.sender,
            _fileChecksum,
            _fileLocationEngine,
            _fileLocationHash,
            _encrypted,
            0
        );
        return documentsCounter;
    }
}


/**
 * @title Interface with clones, inherited contracts or services.
 */
interface DocumentsInterface {
    function getDocuments() external returns(uint[]);
    function getDocument(uint)
        external
        returns (
            uint16,
            uint16,
            uint40,
            address,
            bytes32,
            uint16,
            bytes,
            bool,
            uint16
        );
}

// File: contracts/Workspace.sol

/**
 * @title A Workspace contract.
 * @author Talao, Polynomial, SlowSense, Blockchain Partners.
 */
contract Workspace is Permissions, Profile, Documents {

    /**
     * @dev Constructor.
     */
    constructor(
        address _foundation,
        address _token,
        uint16 _category,
        uint16 _asymetricEncryptionAlgorithm,
        uint16 _symetricEncryptionAlgorithm,
        bytes _asymetricEncryptionPublicKey,
        bytes _symetricEncryptionEncryptedKey,
        bytes _encryptedSecret
    )
        Permissions(
            _foundation,
            _token,
            _category,
            _asymetricEncryptionAlgorithm,
            _symetricEncryptionAlgorithm,
            _asymetricEncryptionPublicKey,
            _symetricEncryptionEncryptedKey,
            _encryptedSecret
        )
        public
    {
        foundation = Foundation(_foundation);
        token = TalaoToken(_token);
        identityInformation.creator = msg.sender;
        identityInformation.category = _category;
        identityInformation.asymetricEncryptionAlgorithm = _asymetricEncryptionAlgorithm;
        identityInformation.symetricEncryptionAlgorithm = _symetricEncryptionAlgorithm;
        identityInformation.asymetricEncryptionPublicKey = _asymetricEncryptionPublicKey;
        identityInformation.symetricEncryptionEncryptedKey = _symetricEncryptionEncryptedKey;
        identityInformation.encryptedSecret = _encryptedSecret;
    }

    /**
     * @dev Destroy contract.
     */
    function destroyWorkspace() external onlyIdentityOwner {
        if (cleanupPartnership() && foundation.renounceOwnershipInFoundation()) {
            selfdestruct(msg.sender);
        }
    }

    /**
     * @dev Prevents accidental sending of ether.
     */
    function() public {
        revert();
    }
}