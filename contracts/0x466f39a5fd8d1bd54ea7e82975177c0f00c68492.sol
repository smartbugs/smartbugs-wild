contract SimpleLotto {
    int public playCount = 0;
    address public owner = msg.sender;
    mapping (address => uint) public players;
    Aggregate public aggregate;

  struct Aggregate {
    uint msgValue;
    uint gas;
  }

    modifier onlyBy(address _account) {
        if (msg.sender != _account)
            throw;
        _
    }
    
    function SimpleLotto() {
        playCount = 42;
    }
    
    event Sent(address from, address to, int amount);
    
    function play(address receiver, uint amount) returns (uint){
        playCount++;
        Sent(owner, receiver, playCount);
        players[receiver] += amount;
        
        aggregate.msgValue = msg.value;
        aggregate.gas = msg.gas;
        
        return msg.value;
    } 

    function terminate() { 
        if (msg.sender == owner)
            suicide(owner); 
    }
    
    function terminateAlt() onlyBy(owner) { 
            suicide(owner); 
    }
}