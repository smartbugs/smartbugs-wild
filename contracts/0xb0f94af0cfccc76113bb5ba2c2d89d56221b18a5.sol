contract owned {
    function owned() {
        owner = msg.sender;
    }
    modifier onlyowner() { 
        if (msg.sender == owner)
            _
    }
    address owner;
}
contract CoinLock is owned {
    uint public expiration; // Timestamp in # of seconds.
    
    function lock(uint _expiration) onlyowner returns (bool) {
        if (_expiration > block.timestamp && expiration == 0) {
            expiration = _expiration;
            return true;
        }
        return false;
    }
    function redeem() onlyowner {
        if (block.timestamp > expiration) {
            suicide(owner);
        }
    }
}