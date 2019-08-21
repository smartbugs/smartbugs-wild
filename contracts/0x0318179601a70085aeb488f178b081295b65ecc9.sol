contract self_store {

    address owner;

    uint public contentCount = 0;
    
    event content(string datainfo, uint indexed version);
    modifier onlyowner { if (msg.sender == owner) _ }
    
    function self_store() public { owner = msg.sender; }
    
    ///TODO: remove in release
    function kill() onlyowner { suicide(owner); }

    function flush() onlyowner {
        owner.send(this.balance);
    }

    function add(string datainfo, uint version) onlyowner {
        contentCount++;
        content(datainfo, version);
    }
}