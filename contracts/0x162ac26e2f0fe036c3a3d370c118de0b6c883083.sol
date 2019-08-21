pragma solidity ^0.4.3;

// © 2016 Ambisafe Inc. No reuse without written permission is allowed.

contract InchainICO {
    struct PendingOperation {
        mapping(address => bool) hasConfirmed;
        uint yetNeeded;
    }

    mapping(bytes32 => PendingOperation) pending;
    uint public required;
    mapping(address => bool) public isOwner;
    address[] public owners;

    event Confirmation(address indexed owner, bytes32 indexed operation, bool completed);

    function InchainICO(address[] _owners, uint _required) {
        if (_owners.length == 0 || _required == 0 || _required > _owners.length) {
            selfdestruct(msg.sender);
        }
        required = _required;
        for (uint i = 0; i < _owners.length; i++) {
            owners.push(_owners[i]);
            isOwner[_owners[i]] = true;
        }
    }

    function hasConfirmed(bytes32 _operation, address _owner) constant returns(bool) {
        return pending[_operation].hasConfirmed[_owner];
    }
    
    function n() constant returns(uint) {
        return required;
    }
    
    function m() constant returns(uint) {
        return owners.length;
    }

    modifier onlyowner() {
        if (!isOwner[msg.sender]) {
            throw;
        }
        _;
    }

    modifier onlymanyowners(bytes32 _operation) {
        if (_confirmAndCheck(_operation)) {
            _;
        }
    }

    function _confirmAndCheck(bytes32 _operation) onlyowner() internal returns(bool) {
        if (hasConfirmed(_operation, msg.sender)) {
            throw;
        }

        var pendingOperation = pending[_operation];
        if (pendingOperation.yetNeeded == 0) {
            pendingOperation.yetNeeded = required;
        }

        if (pendingOperation.yetNeeded <= 1) {
            Confirmation(msg.sender, _operation, true);
            _removeOperation(_operation);
            return true;
        } else {
            Confirmation(msg.sender, _operation, false);
            pendingOperation.yetNeeded--;
            pendingOperation.hasConfirmed[msg.sender] = true;
        }

        return false;
    }

    function _removeOperation(bytes32 _operation) internal {
        var pendingOperation = pending[_operation];
        for (uint i = 0; i < owners.length; i++) {
            if (pendingOperation.hasConfirmed[owners[i]]) {
                pendingOperation.hasConfirmed[owners[i]] = false;
            }
        }
        delete pending[_operation];
    }

    function send(address _to, uint _value) onlymanyowners(sha3(msg.data)) returns(bool) {
        return _to.send(_value);
    }

    // Accept all incoming ETH till the limit ~$10M.
    uint public totalRaised;
    function () payable {
        if (totalRaised + msg.value > 833000 ether) {
            throw;
        }
        totalRaised += msg.value;
    }
}