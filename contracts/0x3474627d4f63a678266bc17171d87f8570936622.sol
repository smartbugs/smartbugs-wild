contract Splitter {
    
    bool _classic;
    address _owner;
    
    function Splitter() {
        _owner = msg.sender;

        // Balance on classic is 0.000007625764205414 (at the time of this contract)
        if (address(0xbf4ed7b27f1d666546e30d74d50d173d20bca754).balance < 1 ether) {
            _classic = true;
        }
    }

    function isClassic() constant returns (bool) {
        return _classic;
    }
    
    // Returns the ether on the real network to the sender, while forwarding
    // the classic ether to a new address.
    function split(address classicAddress) {
        if (_classic){
            if (!(classicAddress.send(msg.value))) {
                throw;
            }
        } else {
            if (!(msg.sender.send(msg.value))) {
                throw;
            }
        }
    }

    function claimDonations(uint balance) {
        if (_owner != msg.sender) { return; }
        if (!(_owner.send(balance))) {
            throw;
        }
    }
}