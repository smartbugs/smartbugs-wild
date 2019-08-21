pragma solidity ^0.4.9;

contract ProofOfIdleness {
    address public organizer;
    
    // number of remaining participants
    uint public countRemaining = 0;
    
    // stores the last ping of every participants
    mapping (address => uint) public lastPing;
    
    // Events allow light clients to react on changes efficiently.
    event Eliminated(address a);
    event Pinged(address a, uint time);

    // This is the constructor whose code is
    // run only when the contract is created.
    function ProofOfIdleness() {
        organizer = msg.sender;
    }
    
    
    // function called when the user pings
    function idle() {
      if (lastPing[msg.sender] == 0)
        throw;
        
      lastPing[msg.sender] = now;
      Pinged(msg.sender, now);
    }
    
    
    // function called when a new user wants to join
    function join() payable { 
        if (lastPing[msg.sender] > 0 || msg.value != 1 ether)
            throw;
        
        lastPing[msg.sender] = now; 
        countRemaining = countRemaining + 1;
        Pinged(msg.sender, now);
        
        if (!organizer.send(0.01 ether)) {
          throw;
        }
    }
    
    
    // function used to eliminate address ̀`a'
    // will only succeed if the lastPing[a] is at least 27 hours old
    function eliminate(address a) {
      if (lastPing[a] == 0 || now <= lastPing[a] + 27 hours)
        throw;
        
      lastPing[a] = 0;
      countRemaining = countRemaining - 1;
      Eliminated(a);
    }
    
    
    // function used to claim the whole reward
    // will only succeed if called by the last remaining participant
    function claimReward() {
      if (lastPing[msg.sender] == 0 || countRemaining != 1)
        throw;
        
      if (!msg.sender.send(this.balance))
        throw;
    }
}