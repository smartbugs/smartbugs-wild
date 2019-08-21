pragma solidity ^0.4.18;

contract helper {
    
    function derive_sha256(string key, uint rounds) 
        public pure returns(bytes32 hash){
        if (rounds == 0) rounds = 1;
        hash = sha256(key);  
        for (uint i = 0; i < rounds-1; i++) {
            hash = sha256(hash);  
        }
    }
    
    function blind_sha256(string key, address caller) 
        public pure returns(bytes32 challenge){
        challenge = sha256(sha256(key),caller);
    }
    
    function double_blind_sha256(string key, address caller, address receiver) 
        public pure returns(bytes32 challenge){
        challenge = sha256(sha256(sha256(key),caller),receiver);
    }
    
}
contract owned {
    address public owner;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    /* Constructor */
    function owned() public {
        owner = msg.sender;
    }
    
}

contract QuantumLocksmith is owned, helper {
    uint public m_pending;

    struct lock {
        bool alive;
        bool proven;
        uint balance;
        string protocol;
        string key;
        address owner;
    }
    
    mapping(bytes32 => lock) public locks;

    // challenge the original owner validity
    function QuantumLocksmith(bytes32 ownerChallenge) public payable {
        require(uint(ownerChallenge) > 0);
        locks[ownerChallenge].alive = true;
        locks[ownerChallenge].balance = msg.value;
        m_pending++;
    }
    
    function lockDeposit(bytes32 challenge, string _protocol) public payable {
        require(uint(challenge) > 0);
        require(msg.value > 0);
        require(!locks[challenge].alive);
        locks[challenge].alive = true;
        locks[challenge].balance = msg.value;
        locks[challenge].owner = msg.sender;
        m_pending++;
        if (bytes(_protocol).length > 0) locks[challenge].protocol = _protocol;
    }
    
    function unlockDeposit(
        string key, 
        address receiver
    ) public {
        require(bytes(key).length > 0);
        // generate the challenge
        bytes32 k = sha256(sha256(key),msg.sender);
        address to = msg.sender;
        if (uint(receiver) > 0) {
            to = receiver;
            k = sha256(k,receiver);
        }
        if (locks[k].alive && !locks[k].proven) 
        {
            locks[k].proven = true;
            locks[k].key = key;
            m_pending--;
            uint sendValue = locks[k].balance;
            if (sendValue > 0) {
                locks[k].balance = 0;
                require(to.send(sendValue));
            }
        }
    }
    
    function depositToLock(bytes32 challenge) public payable {
        require(challenge != 0x0);
        require(msg.value > 0);
        require(locks[challenge].alive && !locks[challenge].proven);
        locks[challenge].balance += msg.value;
    }
    
    // do not allow this
    function() public payable { 
        require(msg.value == 0);
    }
    
    function kill(string key) public {
        if (msg.sender == owner) {
            bytes32 k = sha256(sha256(key),msg.sender);
            if (locks[k].alive && !locks[k].proven) 
                selfdestruct(owner); 
        }
    }
}