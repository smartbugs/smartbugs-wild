/* A contract to store a list of messages. Obtainable as events. */

contract store {

    address owner;

    uint16 public contentCount = 0;
    
    event content(string datainfo, address sender, uint payment);
    modifier onlyowner { if (msg.sender == owner) _ } 
    
    function store() public { owner = msg.sender; }
    
    ///TODO: remove in release
    function kill() onlyowner { suicide(owner); }

    function flush() onlyowner {
        owner.send(this.balance);
    }

    function add(string datainfo) {
        contentCount++;
        content(datainfo, msg.sender, msg.value);
    }
}