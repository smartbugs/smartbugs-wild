pragma solidity ^0.4.24;

library KeyHolderLibrary {
    event KeyAdded(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
    event KeyRemoved(bytes32 indexed key, uint256 indexed purpose, uint256 indexed keyType);
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
        require(!keyHasPurpose(_keyHolderData, _key, _purpose), "Key already exists with same purpose"); // Key should not already exist with same purpose
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

    function addKeys(KeyHolderData storage _keyHolderData, bytes32[] _keys, uint256 _purpose, uint256 _type)
        public
        returns (bool success)
    {
        for (uint16 i = 0; i < _keys.length; i++) {
            addKey(
                _keyHolderData,
                _keys[i],
                _purpose,
                _type
            );
        }

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

        if (keyHasPurpose(_keyHolderData, keccak256(abi.encodePacked(msg.sender)),1) || keyHasPurpose(_keyHolderData, keccak256(abi.encodePacked(msg.sender)),2)) {
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
        returns(bool result)
    {
        bool isThere;
        if (_keyHolderData.keys[_key].key == 0) {
            return false;
        }

        uint256[] storage purposes = _keyHolderData.keys[_key].purposes;
        for (uint i = 0; i < purposes.length; i++) {
            if (purposes[i] <= _purpose) {
                isThere = true;
                break;
            }
        }
        return isThere;
    }
}

library ClaimHolderLibrary {
    event ClaimAdded(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

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
            bytes32 sender = keccak256(abi.encodePacked(msg.sender));
            require(KeyHolderLibrary.keyHasPurpose(_keyHolderData, sender, 1) ||
                    KeyHolderLibrary.keyHasPurpose(_keyHolderData, sender, 3), "Sender does not have claim signer key");
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
            addClaim(
                _keyHolderData,
                _claims,
                _topic[i],
                1,
                _issuer[i],
                getBytes(_signature, (i * 65), 65),
                getBytes(_data, offset, _offsets[i]),
                ""
            );
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

contract ERC735 {
    event ClaimRequested(uint256 indexed claimRequestId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimAdded(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimChanged(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    struct Claim {
        uint256 topic;
        uint256 scheme;
        address issuer; // msg.sender
        bytes signature; // this.address + topic + data
        bytes data;
        string uri;
    }

    function getClaim(bytes32 _claimId) public view returns(uint256 topic, uint256 scheme, address issuer, bytes signature, bytes data, string uri);
    function getClaimIdsByTopic(uint256 _topic) public view returns(bytes32[] claimIds);
    function addClaim(uint256 _topic, uint256 _scheme, address issuer, bytes _signature, bytes _data, string _uri) public returns (bytes32 claimRequestId);
    function removeClaim(bytes32 _claimId) public returns (bool success);
}

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

    function addKeys(bytes32[] _keys, uint256 _purpose, uint256 _type)
        public
        returns (bool success)
    {
        return KeyHolderLibrary.addKeys(keyHolderData, _keys, _purpose, _type);
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

contract managed {
    address public admin;

    constructor() public {
        admin = msg.sender;
    }

    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }

    function transferOwnership(address newAdmin) onlyAdmin public {
        admin = newAdmin;
    }
}

contract WhooseWalletAdmin is managed {
    mapping(address => address) contracts;

    function addContract(address addr) public returns(bool success) {
        contracts[addr] = addr;
        return true;
    }

    function removeContract(address addr) public onlyAdmin returns(bool success) {
        delete contracts[addr];
        return true;
    }

    function getContract(address addr) public view onlyAdmin returns(address addr_res) {
        return contracts[addr];
    }

    // ERC725
    function getKey(address _walletAddress, bytes32 _key)
        public view onlyAdmin returns(uint256[] purposes, uint256 keyType, bytes32 key) {
        WhooseWallet _wallet = WhooseWallet(_walletAddress);
        return _wallet.getKey(_key);
    }

    function keyHasPurpose(address _walletAddress, bytes32 _key, uint256 _purpose)
        public view onlyAdmin returns (bool exists) {
        WhooseWallet _wallet = WhooseWallet(_walletAddress);
        return _wallet.keyHasPurpose(_key, _purpose);
    }

    function getKeysByPurpose(address _walletAddress, uint256 _purpose)
        public view onlyAdmin returns(bytes32[] keys) {
        WhooseWallet _wallet = WhooseWallet(_walletAddress);
        return _wallet.getKeysByPurpose(_purpose);
    }

    function addKey(address _walletAddress, bytes32 _key, uint256 _purpose, uint256 _keyType)
        public onlyAdmin returns (bool success) {
        WhooseWallet _wallet = WhooseWallet(_walletAddress);
        return _wallet.addKey(_key, _purpose, _keyType);
    }

    function addKeys(address _walletAddress, bytes32[] _keys, uint256 _purpose, uint256 _keyType)
        public onlyAdmin returns (bool success) {
        WhooseWallet _wallet = WhooseWallet(_walletAddress);
        return _wallet.addKeys(_keys, _purpose, _keyType);
    }

    function removeKey(address _walletAddress, bytes32 _key, uint256 _purpose)
        public onlyAdmin returns (bool success) {
        WhooseWallet _wallet = WhooseWallet(_walletAddress);
        return _wallet.removeKey(_key, _purpose);
    }

    function execute(address _walletAddress, address _to, uint256 _value, bytes _data)
        public onlyAdmin returns (uint256 executionId) {
        WhooseWallet _wallet = WhooseWallet(_walletAddress);
        return _wallet.execute(_to, _value, _data);
    }

    function approve(address _walletAddress, uint256 _id, bool _approve)
        public onlyAdmin returns (bool success) {
        WhooseWallet _wallet = WhooseWallet(_walletAddress);
        return _wallet.approve(_id, _approve);
    }

    // ERC735
    function getClaim(address _walletAddress, bytes32 _claimId)
        public onlyAdmin view returns(uint256 topic, uint256 scheme, address issuer, bytes signature, bytes data, string uri) {
        WhooseWallet _wallet = WhooseWallet(_walletAddress);
        return _wallet.getClaim(_claimId);
    }

    function getClaimIdsByTopic(address _walletAddress, uint256 _topic)
        public onlyAdmin view returns(bytes32[] claimIds) {
        WhooseWallet _wallet = WhooseWallet(_walletAddress);
        return _wallet.getClaimIdsByTopic(_topic);
    }

    function addClaim(address _walletAddress, uint256 _topic, uint256 _scheme, address issuer, bytes _signature, bytes _data, string _uri)
        public onlyAdmin returns (bytes32 claimRequestId) {
        WhooseWallet _wallet = WhooseWallet(_walletAddress);
        return _wallet.addClaim(_topic, _scheme, issuer, _signature, _data, _uri);
    }

    function removeClaim(address _walletAddress, bytes32 _claimId)
        public onlyAdmin returns (bool success) {
        WhooseWallet _wallet = WhooseWallet(_walletAddress);
        return _wallet.removeClaim(_claimId);
    }

    function kill(address _walletAddress)
        public onlyAdmin returns (bool success) {
        WhooseWallet _wallet = WhooseWallet(_walletAddress);
        _wallet.destruct();
        return true;
    }
}

contract WhooseWallet is ClaimHolder {
    address whooseWalletAdminAddress = 0x6babebb9657257F83492D457E7f41B2524368dE6;

    constructor() public {
        bytes32 _admin = keccak256(abi.encodePacked(whooseWalletAdminAddress));
        addKey(_admin, 1, 1);

        WhooseWalletAdmin _walletAdmin = WhooseWalletAdmin(whooseWalletAdminAddress);
        _walletAdmin.addContract(address(this));
    }

    function destruct() public {
        if (msg.sender != address(this) && whooseWalletAdminAddress != address(this)) {
            bytes32 sender = keccak256(abi.encodePacked(msg.sender));
            require(KeyHolderLibrary.keyHasPurpose(keyHolderData, sender, 1), "Sender does not have management key");
        }

        selfdestruct(whooseWalletAdminAddress);
    }
}