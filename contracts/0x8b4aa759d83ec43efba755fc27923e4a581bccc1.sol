contract BlockChainChallenge {
    
  address admin;
  address leader;
  bytes32 leaderHash;
  bytes32 difficulty;
  bytes32 difficultyWorldRecord;
  uint fallenLeaders;
  uint startingTime;
  uint gameLength;
  string leaderMessage;
  string defaultLeaderMessage;
  mapping (address => uint) winners;
  
  event Begin(string log);
  event Leader(string log, address newLeader, bytes32 newHash);
  event GameOver(string log);
  event Winner (string log, address winner);
  event NoWinner (string log);
  event WorldRecord (string log, bytes32 DifficultyRecord, address RecordHolder);
  
  function BlockChainChallenge(){ 
      
    //Admin Backdoor
    admin = msg.sender;

    //Starting Time
    startingTime = block.timestamp;
    
    //Game Length (TODO: Change to 1 weeks)
    gameLength = 1 weeks;

    //Initial seed for the first challenge. This should always be in rotation afterward.
    leaderHash = sha3("09F911029D74E35BD84156C5635688C0");

    //First leader is the creator of the contract
    leader = msg.sender;

    //The placeholder leader message
    defaultLeaderMessage = "If you're this weeks leader, you own this field. Write a message here.";
    leaderMessage = defaultLeaderMessage;
    
    //This difficulty starts as easy as possible. Any XOR will be less, to start.
    difficulty = leaderHash;
    
    //Seed the world record
    difficultyWorldRecord = leaderHash;
    
    //Counter for successful collisions this week.
    fallenLeaders = 0;

    Begin("Collide the most bits of the leader's hash to replace the leader. Leader will win any bounty at the end of the week.");

  }
  
  function reset() private{
      
      //Make the hash unpredictable.
      leaderHash = sha3(block.timestamp);
      
      //Reset the leader message
      leaderMessage = defaultLeaderMessage;
      difficulty = leaderHash;
      leader = admin;
      fallenLeaders = 0;
  }
  
  function checkDate() private returns (bool success) {
      
      //Are we one week beyond the last game? TODO change time for mainnet
      if (block.timestamp > (startingTime + gameLength)) {
          
          //If so, log winner. If the admin "wins", it's because no one else won.
          if(leader != admin){
            Winner("Victory! Game will be reset to end in 1 week (in block time).", leader);
            leader.send(this.balance);
          }else NoWinner("No winner! Game will be reset to end in 1 week (in block time).");

          startingTime = block.timestamp;

          //Reset
          reset();
          return true;
      }
      return false;
  }

  function overthrow(string challengeData) returns (bool success){
        
        //Create hash from player data sent to contract
        var challengeHash = sha3(challengeData);

        //Check One: Submission too late, reset game w/ new hash
        if(checkDate())
            return false;
        
        //Check Two: Cheating - of course last hash will collide!
        if(challengeHash == leaderHash)
            return false;

        //Check Three: Core gaming logic favoring collisions of MSB
        if((challengeHash ^ leaderHash) > difficulty)
          return false;

        //If player survived the checks, they've overcome difficulty level and beat the leader.
        //Update the difficulty. This makes the game progressively harder through the week.
        difficulty = (challengeHash ^ leaderHash);
        
        //Did they set a record?
        challengeWorldRecord(difficulty);
        
        //We have a new Leader
        leader = msg.sender;
        
        //The winning hash is our new hash. This undoes any work being done by competition!
        leaderHash = challengeHash;
        
        //Announce our new victor. Congratulations!    
        Leader("New leader! This is their address, and the new hash to collide.", leader, leaderHash);
        
        //Add to historical Winners
        winners[msg.sender]++;
        
        //Keep track of how many new leaders we've had this week.
        fallenLeaders++;
        
        return true;
  }
  
  function challengeWorldRecord (bytes32 difficultyChallenge) private {
      if(difficultyChallenge < difficultyWorldRecord) {
        difficultyWorldRecord = difficultyChallenge;
        WorldRecord("A record setting collision occcured!", difficultyWorldRecord, msg.sender);
      }
  }
  
  function changeLeaderMessage(string newMessage){
        //The leader gets to talk all kinds of shit. If abuse, might remove.
        if(msg.sender == leader)
            leaderMessage = newMessage;
  }
  
  //The following functions designed for mist UI
  function currentLeader() constant returns (address CurrentLeaderAddress){
      return leader;
  }
  function Difficulty() constant returns (bytes32 XorMustBeLessThan){
      return difficulty;
  }
  function TargetHash() constant returns (bytes32 leadingHash){
      return leaderHash;
  }
  function LeaderMessage() constant returns (string MessageOfTheDay){
      return leaderMessage;
  }
  function FallenLeaders() constant returns (uint Victors){
      return fallenLeaders;
  }
  function GameEnds() constant returns (uint EndingTime){
      return startingTime + gameLength;
  }
  function getWins(address check) constant returns (uint wins){
      return winners[check];
  }

  function kill(){
      if (msg.sender == admin){
        GameOver("The challenge has ended.");
        selfdestruct(admin);
      }
  }
}