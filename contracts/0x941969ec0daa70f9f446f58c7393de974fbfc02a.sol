pragma solidity 0.4.15;

contract Ambi2 {
    function claimFor(address _address, address _owner) returns(bool);
    function hasRole(address _from, bytes32 _role, address _to) constant returns(bool);
    function isOwner(address _node, address _owner) constant returns(bool);
}

contract Ambi2Enabled {
    Ambi2 ambi2;

    modifier onlyRole(bytes32 _role) {
        if (address(ambi2) != 0x0 && ambi2.hasRole(this, _role, msg.sender)) {
            _;
        }
    }

    // Perform only after claiming the node, or claim in the same tx.
    function setupAmbi2(Ambi2 _ambi2) returns(bool) {
        if (address(ambi2) != 0x0) {
            return false;
        }

        ambi2 = _ambi2;
        return true;
    }
}


contract Ambi2EnabledFull is Ambi2Enabled {
    // Setup and claim atomically.
    function setupAmbi2(Ambi2 _ambi2) returns(bool) {
        if (address(ambi2) != 0x0) {
            return false;
        }
        if (!_ambi2.claimFor(this, msg.sender) && !_ambi2.isOwner(this, msg.sender)) {
            return false;
        }

        ambi2 = _ambi2;
        return true;
    }
}

contract AssetProxyInterface {
    function transferFromWithReference(address _from, address _to, uint _value, string _reference) returns(bool);
}

contract DeviceDataStorage is Ambi2EnabledFull {

    uint fee;
    address feeReceiver;

    AssetProxyInterface public assetProxy;

    struct Storage {
        address device;
        bytes32 description;
        uint number;
        string additionalInfo;
    }

    mapping (address => uint) public recordId;
    mapping (address => mapping (uint => Storage)) public recording;

    event DataWasRecorded(address device, uint id, bytes32 description, uint number, string additionalInfo);

    function setAssetProxy(AssetProxyInterface _assetProxy) onlyRole('admin') returns(bool) {
        assetProxy = AssetProxyInterface(_assetProxy);
        return true;
    }

    function setFeeRecieverValue(uint _fee, address _feeReceiver) onlyRole('admin') returns(bool) {
        fee = _fee;
        feeReceiver = _feeReceiver;
        return true;
    }

    function recordInfo(bytes32 _description, uint _number, string _additionalInfo) returns(bool) {
        require(assetProxy.transferFromWithReference(msg.sender, feeReceiver, fee, 'storage'));

        recording[msg.sender][recordId[msg.sender]].device = msg.sender;
        recording[msg.sender][recordId[msg.sender]].description = _description;
        recording[msg.sender][recordId[msg.sender]].number = _number;
        recording[msg.sender][recordId[msg.sender]].additionalInfo = _additionalInfo;
        DataWasRecorded(msg.sender, recordId[msg.sender], _description, _number, _additionalInfo);
        recordId[msg.sender]++;
        return true;
    }

    function deleteRecording(uint _id) returns(bool) {
        delete recording[msg.sender][_id];
        return true;
    }

    function getRecording(address _device, uint _id) constant returns(address, bytes32, uint, string) {
        Storage memory stor = recording[_device][_id];
        return (stor.device, stor.description, stor.number, stor.additionalInfo);
    }
}