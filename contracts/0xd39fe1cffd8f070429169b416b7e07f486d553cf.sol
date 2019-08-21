contract store {

    address owner;

    uint public contentCount = 0;
    
    event content(string datainfo, uint indexed version, address indexed sender, uint indexed datatype, uint timespan, uint payment);
    modifier onlyowner { if (msg.sender == owner) _ } 
    
    function store() public { owner = msg.sender; }
    
    ///TODO: remove in release
    function kill() onlyowner { suicide(owner); }

    function flush() onlyowner {
        owner.send(this.balance);
    }

    function add(string datainfo, uint version, uint datatype, uint timespan) {
        //item listing
        if(datatype == 1) {
          //2 weeks listing costs 0,04 USD = 0,004 ether
          if(timespan <= 1209600) {
            if(msg.value < (4 finney)) return;
          //4 weeks listing costs 0,06 USD = 0,006 ether
          } else if(timespan <= 2419200) {
            if(msg.value < (6 finney)) return;
          //limit 4 weeks max
          } else {
            timespan = 2419200;
            if(msg.value < (6 finney)) return;
          }
        }

        //revert higher payment transactions
        if(msg.value > (6 finney)) throw;

        contentCount++;
        content(datainfo, version, msg.sender, datatype, timespan, msg.value);
    }
}