contract SimpleLotto {
    int public playCount = 0;
    int public playCount1;
    address public owner = msg.sender;
    mapping (address => uint) public players;
    My public aloha;

  struct My {
    string a;
    int b;
  }

    modifier onlyBy(address _account) {
        if (msg.sender != _account)
            throw;
        _
    }
    
    function SimpleLotto() {
        playCount1 = 42;
    }
    
    event Sent(address from, address to, int amount);
    
    function play(address receiver, uint amount) returns (uint){
        playCount++;
        playCount1++;
        Sent(owner, receiver, playCount);
        players[receiver] += amount;
        
        aloha.a = "hi";
        aloha.b = playCount1;
        
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