pragma solidity ^0.4.18;

/** 
 * BlackBox - Secure Ether Storage
 * Proof Of Concept - Lock ether with a proof set derived off-chain.  The proof
 * encodes a blinded receiver to accept funds once the correct caller executes 
 * the unlockAmount() function with the correct seed.
*/ 

contract Secure {
    enum Algorithm { sha, keccak }

    // function for off-chain proof derivation.  Use the return values as input for the 
    // lockAmount() function.  Execute unlockAmount() with the correct caller 
    // and seed to transfer funds to an encoded recipient.
    function generateProof(
        string seed,
        address caller, 
        address receiver,
        Algorithm algorithm
    ) pure public returns(bytes32 hash, bytes32 operator, bytes32 check, address check_receiver, bool valid) {
        (hash, operator, check) = _escrow(seed, caller, receiver, algorithm);
        check_receiver = address(hash_data(hash_seed(seed, algorithm), algorithm)^operator);
        valid = (receiver == check_receiver);
        if (check_receiver == 0) check_receiver = caller;
    }

    function _escrow(
        string seed, 
        address caller, 
        address receiver,
        Algorithm algorithm
    ) pure internal returns(bytes32 index, bytes32 operator, bytes32 check) {
        require(caller != receiver && caller != 0);
        bytes32 x = hash_seed(seed, algorithm);
        if (algorithm == Algorithm.sha) {
            index = sha256(x, caller);
            operator = sha256(x)^bytes32(receiver);
            check = x^sha256(receiver);
        } else {
            index = keccak256(x, caller);
            operator = keccak256(x)^bytes32(receiver);
            check = x^keccak256(receiver);
        }
    }
    
    // internal function for hashing the seed
    function hash_seed(
        string seed, 
        Algorithm algorithm
    ) pure internal returns(bytes32) {
        if (algorithm == Algorithm.sha) {
            return sha256(seed);
        } else {
            return keccak256(seed);
        }
    }
    
   // internal function for hashing bytes
    function hash_data(
        bytes32 key, 
        Algorithm algorithm
    ) pure internal returns(bytes32) {
        if (algorithm == Algorithm.sha) {
            return sha256(key);
        } else {
            return keccak256(key);
        }
    }
    
    // internal function for hashing an address
    function blind(
        address addr,
        Algorithm algorithm
    ) pure internal returns(bytes32) {
        if (algorithm == Algorithm.sha) {
            return sha256(addr);
        } else {
            return keccak256(addr);
        }
    }
    
}


contract BlackBox is Secure {
    address public owner;

    // stored proof info
    struct Proof {
        uint256 balance;
        bytes32 operator;
        bytes32 check;
    }
    
    mapping(bytes32 => Proof) public proofs;
    mapping(bytes32 => bool) public used;
    mapping(address => uint256) private donations;

    // events for audit purposes
    event Unlocked(string _key, bytes32 _hash, address _receiver);
    event Locked(bytes32 _hash, bytes32 _operator, bytes32 _check);
    event Donation(address _from, uint256 value);
    
    function BlackBox() public {
        owner = msg.sender;
    }

    /// @dev lockAmount - Lock ether with a proof
    /// @param hash Hash Key used to index the proof
    /// @param operator A derived operator to encode the intended recipient
    /// @param check A derived operator to check the operation
    function lockAmount(
        bytes32 hash,
        bytes32 operator,
        bytes32 check
    ) public payable {
        // protect invalid entries on value transfer
        if (msg.value > 0) {
            require(hash != 0 && operator != 0 && check != 0);
        }
        // check existence
        require(!used[hash]);
        // lock the ether
        proofs[hash].balance = msg.value;
        proofs[hash].operator = operator;
        proofs[hash].check = check;
        // track unique keys
        used[hash] = true;
        Locked(hash, operator, check);
    }

    /// @dev unlockAmount - Verify a proof to transfer the locked funds
    /// @param seed Secret used to derive the proof set
    /// @param algorithm Hash algorithm type
    function unlockAmount(
        string seed,
        Algorithm algorithm
    ) public payable {
        require(msg.value == 0);
        bytes32 hash = 0x0;
        bytes32 operator = 0x0;
        bytes32 check = 0x0;
        // calculate the proof
        (hash, operator, check) = _escrow(seed, msg.sender, 0, algorithm);
        // check existence
        require(used[hash]);
        // calculate the receiver and transfer
        address receiver = address(proofs[hash].operator^operator);
        // verify integrity of operation
        require(proofs[hash].check^hash_seed(seed, algorithm) == blind(receiver, algorithm));
        // check for valid transfer
        if (receiver == address(this) || receiver == 0) receiver = msg.sender;
        // get locked balance to avoid recursive attacks
        uint bal = proofs[hash].balance;
        // owner collecting donations
        if (donations[msg.sender] > 0) {
            bal += donations[msg.sender];
            delete donations[msg.sender];
        }
        // delete the entry to free up memory
        delete proofs[hash];
        // check the balance to send to the receiver
        if (bal <= this.balance && bal > 0) {
            // transfer to receiver 
            // this could fail if receiver is another contract, so fallback
            if(!receiver.send(bal)){
                require(msg.sender.send(bal));
            }
        }
        Unlocked(seed, hash, receiver);
    }
    
    // deposits get stored for the owner
    function() public payable {
        require(msg.value > 0);
        donations[owner] += msg.value;
        Donation(msg.sender, msg.value);
    }
    
}