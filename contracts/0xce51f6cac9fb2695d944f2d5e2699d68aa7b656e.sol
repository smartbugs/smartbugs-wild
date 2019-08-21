pragma solidity ^0.4.15;

contract helper {
    
    function eccVerify(bytes32 hash, uint8 curve, bytes32 r, bytes32 s) 
        constant 
        returns(address publicKey) {
        publicKey = ecrecover(hash, curve, r, s);
    }
    
    function calcBindedBlindHash3(string key, address receiver) 
        constant returns(bytes32 lock) {
        lock = sha3(sha3(key),receiver);
    }
    
    function calcBindedBlindHash256(string key, address receiver) 
        constant returns(bytes32 lock) {
        lock = sha256(sha256(key),receiver);
    }
    
    function calcDoubleBindedBlindHash3(string key, address caller, address receiver) 
        constant returns(bytes32 lock) {
        lock = sha3(sha3(sha3(key),caller),receiver);
    }
    
    function calcDoubleBindedBlindHash256(string key, address caller, address receiver) 
        constant returns(bytes32 lock) {
        lock = sha256(sha256(sha256(key),caller),receiver);
    }
    
    function hash_sha256(string key, uint rounds) 
        constant returns(bytes32 sha256_hash) {
        if (rounds == 0) rounds = 1;
        sha256_hash = sha256(key);  
        for (uint i = 0; i < rounds-1; i++) {
            sha256_hash = sha256(sha256_hash);  
        }
    }
    
    function hash_sha3(string key, uint rounds)
        constant returns(bytes32 sha3_hash) {
        if (rounds == 0) rounds = 1;
        sha3_hash = sha3(key);  
        for (uint i = 0; i < rounds-1; i++) {
            sha3_hash = sha3(sha3_hash);  
        }
    }
    
    function hash_ripemd160(string key, uint rounds)
        constant returns(bytes32 r160_hash) {
        if (rounds == 0) rounds = 1;
        r160_hash = sha3(key);  
        for (uint i = 0; i < rounds-1; i++) {
            r160_hash = ripemd160(r160_hash);  
        }
    }
}
contract owned {
    address public owner;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    function owned() { owner = msg.sender; }
}

contract logger {
    
    event Unlock(address caller, string key, bytes32 proof);
    event Deposit(address from, uint value);
    event LogEvent(
        uint num_event,
        address from, 
        bytes4 sig, 
        bytes msgdata, 
        uint time,
        uint gasprice
        );
}

contract Locksmith is owned, logger, helper {
    uint public nonce;
    uint public m_proofs;
    bool public didProve;
    bytes32 public lock;
    string public protocol = "set by strong10, verify by strong7";
    
    struct proof {
        address prover;
        address receiver;
        string key;
        bytes32 lock;
    }
    
    mapping(uint => proof) public proofs;
    
    /* Constructor */
    function Locksmith() {
        owner = msg.sender;
    }
    
    function setLock(bytes32 _lock, string _protocol) onlyOwner {
        require(_lock != 0x0 && lock != _lock);
        lock = _lock;
        didProve = false;
        if (bytes(_protocol).length > 0) protocol = _protocol;
        logEvent();
    }
    
    function unlock(string key, address receiver, bytes32 newLock, string _protocol) {
        bytes32 k = sha3(sha3(key),msg.sender);
        if (uint(receiver) > 0) k = sha3(k,receiver);
        if (k == lock) {
            if (uint(receiver) > 0) owner = receiver;
            else owner = msg.sender;
            
            Unlock(msg.sender, key, lock);
            
            proofs[m_proofs].prover = msg.sender;
            proofs[m_proofs].receiver = (uint(receiver) == 0 ? msg.sender:receiver);
            proofs[m_proofs].key = key;
            proofs[m_proofs].lock = lock;
            m_proofs++;
            lock = newLock;
            didProve = (uint(newLock) == 0);
            if (bytes(_protocol).length > 0) 
                protocol = _protocol;
            if (this.balance > 0)
                require(owner.send(this.balance));
        }
        logEvent();
    }
    
    function sendTo(address _to, uint value) onlyOwner {
        require(didProve);
        require(this.balance >= value && value > 0);
        require(_to.send(value));
        logEvent();
    }
    
    function logEvent() internal {
        LogEvent(nonce++, msg.sender, msg.sig, msg.data, now, tx.gasprice);
    }
 
    function kill() onlyOwner { 
        require(didProve);
        selfdestruct(owner); 
    }
    
    function() payable {
        require(msg.value > 0);
        Deposit(msg.sender, msg.value);
    }
    
}