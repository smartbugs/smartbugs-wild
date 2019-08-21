contract PRNG_Challenge {

    // PRIVATE VARIABLES
    address private admin;
    uint256 private constant min_value = 100 finney; // 0.1 ETH
    
    // PUBLIC VARIABLES
    uint256 public constant lucky_number = 108435827775939881852079940206236050880764931249577763315065068000725104274235;
    uint256 public last_number;
    uint256 public attempts;
    address public winner;
    
    // EVENTS
    event Attempt(address Participant, uint256 Number);
    event Winner(address Winner_Address, uint256 Amount);

    // CONSTRUCTOR
    function PRNG_Challenge()
        private
    {
        admin = msg.sender;
        last_number = 0;
        attempts = 0;
        winner = 0;
    }

    // MODIFIERS
    modifier only_min_value() {
        if (msg.value < min_value) throw;
        _
    }
    modifier only_no_value() {
        if (msg.value != 0)  throw;
        _
    }
    modifier only_admin() {
        if (msg.sender != admin) throw;
        _
    }
    modifier not_killed() {
        if (winner != 0) throw;
        _
    }
    
    // CHALLENGE
    function challenge()
        private
    {
        address participant = msg.sender;
        uint64 shift_32 = uint64(4294967296); // Shift by 32 bit
        uint32 hash32 = uint32(sha3(msg.value,participant,participant.balance,block.blockhash(block.number-1),block.timestamp,block.number)); // Entropy
        uint64 hash64 = uint64(hash32)*shift_32 + uint32(sha3(hash32));
        uint96 hash96 = uint96(hash64)*shift_32 + uint32(sha3(hash64));
        uint128 hash128 = uint128(hash96)*shift_32 + uint32(sha3(hash96));
        uint160 hash160 = uint160(hash128)*shift_32 + uint32(sha3(hash128));
        uint192 hash192 = uint192(hash160)*shift_32 + uint32(sha3(hash160));
        uint224 hash224 = uint224(hash192)*shift_32 + uint32(sha3(hash192));
        uint256 hash256 = uint256(hash224)*shift_32 + uint32(sha3(hash224));
        if (hash256 == lucky_number) {
            Winner(participant, this.balance);
            if (!participant.send(this.balance)) throw;
            winner = participant;
        }
        last_number = hash256;
        attempts++;
        Attempt(participant, last_number);
    }
    
    // KILL
    function admin_kill()
        public
        not_killed()
        only_admin()
        only_no_value()
    {
        if (!admin.send(this.balance)) throw;
        winner = admin;
    }
    
    // DEFAULT FUNCTION
    function()
        public
        not_killed()
        only_min_value()
    {
        challenge();
    }

}