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

contract DeviceActivationInterface {
    function isActivated(address _device) public constant returns (bool);
}

contract DeviceReputationInterface {
    function getReputationProblems(address _device, string _description) public constant returns(bool);
}

contract Statuses is Ambi2EnabledFull {

    DeviceActivationInterface public activation;
    DeviceReputationInterface public reputation;

    event TransactionCancelled(address to, uint value, string reference, address sender);
    event TransactionCancelledICAP(bytes32 icap, uint value, string reference, address sender);
    event TransactionSucceeded(address to, uint value, string reference, address sender);
    event TransactionSucceededICAP(bytes32 icap, uint value, string reference, address sender);

    function _isValidStatus(address _sender, string _reference) internal returns(bool) {
        if (!activation.isActivated(_sender)) {
            return false;
        }
        if (reputation.getReputationProblems(_sender, _reference)) {
            return false;
        }
        return true;
    }

    function setActivation(DeviceActivationInterface _activation) onlyRole('admin') returns(bool) {
        activation = DeviceActivationInterface(_activation);
        return true;
    }

    function setReputation(DeviceReputationInterface _reputation) onlyRole('admin') returns(bool) {
        reputation = DeviceReputationInterface(_reputation);
        return true;
    }

    function checkStatus(address _to, uint _value, string _reference, address _sender) returns(bool) {
        if (_isValidStatus(_sender, _reference)) {
            TransactionSucceeded(_to, _value, _reference, _sender);
            return true;
        }
        TransactionCancelled(_to, _value, _reference, _sender);
        return false;
    }

    function checkStatusICAP(bytes32 _icap, uint _value, string _reference, address _sender) returns(bool) {
        if (_isValidStatus(_sender, _reference)) {
            TransactionSucceededICAP(_icap, _value, _reference, _sender);
            return true;
        }
        TransactionCancelledICAP(_icap, _value, _reference, _sender);
        return false;
    }
}