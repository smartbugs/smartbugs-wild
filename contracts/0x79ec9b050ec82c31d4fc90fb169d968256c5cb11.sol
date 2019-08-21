contract StakeProver {

    struct info_pair {
        address publisher;
        uint stake; // how much was in the account at the time of transaction
        uint burned; // you can optionally burn Ether by sending it when calling the publish function
        uint timestamp;
    }

    mapping(bytes32 => info_pair) public hash_db;

    function publish(bytes32 hashed_val) {
        if (hash_db[hashed_val].publisher != address(0)) {
            // You can only publish the message once
            throw;
        }
        hash_db[hashed_val].publisher = msg.sender;
        hash_db[hashed_val].stake = msg.sender.balance;
        hash_db[hashed_val].burned = msg.value;
        hash_db[hashed_val].timestamp = now;
    }

   function get_publisher(bytes32 hashed_val) constant returns (address) {
        return hash_db[hashed_val].publisher;
    }

    function get_stake(bytes32 hashed_val) constant returns (uint) {
        return hash_db[hashed_val].stake;
    }

    function get_timestamp(bytes32 hashed_val) constant returns (uint) {
        return hash_db[hashed_val].timestamp;
    }

    function get_burned(bytes32 hashed_val) constant returns (uint) {
        return hash_db[hashed_val].burned;
    }
}