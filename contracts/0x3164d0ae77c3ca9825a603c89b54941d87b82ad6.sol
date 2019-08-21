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

contract DeviceReputation is Ambi2EnabledFull {

    mapping (address => mapping (bytes32 => bool)) public reputationProblems;

    event ReputationProblems(address device, string description);
    event ReputationClear(address device, string description);

    function setReputationProblems(address _device, string _description)
        onlyRole('admin')
        returns(bool)
    {
        reputationProblems[_device][keccak256(_description)] = true;
        ReputationProblems(_device, _description);
        return true;
    }

    function reputationClear(address _device, string _description)
        onlyRole('admin')
        returns(bool)
    {
        reputationProblems[_device][keccak256(_description)] = false;
        ReputationClear(_device, _description);
        return true;
    }

    function getReputationProblems(address _device, string _description) public constant returns(bool) {
        return reputationProblems[_device][keccak256(_description)];
    }
}