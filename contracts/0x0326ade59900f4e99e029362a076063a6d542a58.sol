pragma solidity ^0.4.19;


// Hedgely - v3
// radamosch@gmail.com
// https://hedgely.net

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



/**
 * Core Hedgely Contract
 */
contract Hedgely is Ownable {

    uint256 public numberSyndicateMembers;
    uint256 public totalSyndicateShares = 20000;
    uint256 public playersShareAllocation = 5000; // 25%
    uint256 public availableBuyInShares = 5000; // 25%
    uint256 public minimumBuyIn = 10;
    uint256 public buyInSharePrice = 1000000000000000; // wei = 0.001 ether
    uint256 public shareCycleSessionSize = 1000; // number of sessions in a share cycle
    uint256 public shareCycleIndex = 0; // current position in share cycle
    uint256 public shareCycle = 1;
    uint256 public currentSyndicateValue = 150000000000000000; // total value of syndicate to be divided among members

    // limit players/cycle to protect contract from multi-addres DOS gas attack (first 100 players on board counted)
    // will monitor this at share distribution execution and adjust if there are gas problems due to high numbers of players.
    uint256 public maxCyclePlayersConsidered = 100;

    address[] public cyclePlayers; // the players that have played this cycle
    uint256 public numberOfCyclePlayers = 0;

    struct somePlayer {
        uint256 playCount;
        uint256 profitShare; // currently claimable profit
        uint256 shareCycle; // represents the share cycle this player has last played
        uint256 winnings; // current available winnings (for withdrawal)
     }

    mapping(address => somePlayer ) private allPlayers; // all of the players

    struct member {
        uint256 numShares;
        uint256 profitShare;
     }

    address[] private syndicateMembers;
    mapping(address => member ) private members;

    event ProfitShare(
          uint256 _currentSyndicateValue,
          uint256 _numberSyndicateMembers,
          uint256 _totalOwnedShares,
          uint256 _profitPerShare
    );

    event Invest(
          address _from,
          uint256 _option,
          uint256 _value,
          uint256[10] _marketOptions,
          uint _blockNumber
    );

    event Winning(
          address _to,
          uint256 _amount,
          uint256 _session,
          uint256 _winningOption,
          uint _blockNumber
    );

    event EndSession(
          address _sessionEnder,
          uint256 _sessionNumber,
          uint256 _winningOption,
          uint256[10] _marketOptions,
          uint256 _blockNumber
    );

    event StartSession(
          uint256 _sessionNumber,
          uint256 _sessionEndTime,
          uint256[10] _marketOptions,
          uint256 _blockNumber
    );


    // shareholder profit claim
    function claimProfit() public {
      if (members[msg.sender].numShares==0) revert();
      uint256 profitShare = members[msg.sender].profitShare;
      if (profitShare>0){
        members[msg.sender].profitShare = 0;
        msg.sender.transfer(profitShare);
      }
    }

    // player profit claim
    function claimPlayerProfit() public {
      if (allPlayers[msg.sender].profitShare==0) revert();
      uint256 profitShare = allPlayers[msg.sender].profitShare;
      if (profitShare>0){
        allPlayers[msg.sender].profitShare = 0;
        msg.sender.transfer(profitShare);
      }
    }

    // player winnings claim
    function claimPlayerWinnings() public {
      if (allPlayers[msg.sender].winnings==0) revert();
      uint256 winnings = allPlayers[msg.sender].winnings;

      if (now > sessionEndTime && playerPortfolio[msg.sender][currentLowest]>0){
          // session has ended, this player may have winnings not yet allocated, but they should show up
         winnings+= SafeMath.mul(playerPortfolio[msg.sender][currentLowest],winningMultiplier);
         playerPortfolio[msg.sender][currentLowest]=0;
      }

      if (winnings>0){
        allPlayers[msg.sender].winnings = 0;
        msg.sender.transfer(winnings);
      }
    }

    // allocate player winnings
    function allocateWinnings(address _playerAddress, uint256 winnings) internal {
      allPlayers[_playerAddress].winnings+=winnings;
    }

    // utility to round to the game precision
    function roundIt(uint256 amount) internal constant returns (uint256)
    {
        // round down to correct preicision
        uint256 result = (amount/precision)*precision;
        return result;
    }

    // distribute profit among shareholders and players in top 10
    function distributeProfit() internal {

      uint256 totalOwnedShares = totalSyndicateShares-(playersShareAllocation+availableBuyInShares);
      uint256 profitPerShare = SafeMath.div(currentSyndicateValue,totalOwnedShares);

      if (profitPerShare>0){
          // foreach member , calculate their profitshare
          for(uint i = 0; i< numberSyndicateMembers; i++)
          {
            // do += so that acrues across share cycles.
            members[syndicateMembers[i]].profitShare+=SafeMath.mul(members[syndicateMembers[i]].numShares,profitPerShare);
          }
      } // end if profit for share

      uint256 topPlayerDistributableProfit =  SafeMath.div(currentSyndicateValue,4); // 25 %
      // player profit calculation
      uint256 numberOfRecipients = min(numberOfCyclePlayers,10); // even split among top players even if <10
      uint256 profitPerTopPlayer = roundIt(SafeMath.div(topPlayerDistributableProfit,numberOfRecipients));

      if (profitPerTopPlayer>0){

          // begin sorting the cycle players
          address[] memory arr = new address[](numberOfCyclePlayers);

          // copy the array to in memory - don't sort the global too expensive
          for(i=0; i<numberOfCyclePlayers && i<maxCyclePlayersConsidered; i++) {
            arr[i] = cyclePlayers[i];
          }
          address key;
          uint j;
          for(i = 1; i < arr.length; i++ ) {
            key = arr[i];

            for(j = i; j > 0 && allPlayers[arr[j-1]].playCount > allPlayers[key].playCount; j-- ) {
              arr[j] = arr[j-1];
            }
            arr[j] = key;
          }  // end sorting cycle players

          //arr now contains the sorted set of addresses for distribution

          // for each of the top 10 players distribute their profit.
          for(i = 0; i< numberOfRecipients; i++)
          {
            // do += so that acrues across share cycles - in case player profit is not claimed.
            if (arr[i]!=0) { // check no null addresses
              allPlayers[arr[i]].profitShare+=profitPerTopPlayer;
            }
          } // end for receipients

      } // end if profit for players


      // emit a profit share event
      ProfitShare(currentSyndicateValue, numberSyndicateMembers, totalOwnedShares , profitPerShare);

      // reset the cycle variables
      numberOfCyclePlayers=0;
      currentSyndicateValue=0;
      shareCycleIndex = 1;
      shareCycle++;
    }

    // updates the count for this player
    function updatePlayCount() internal{
      // first time playing this share cycle?
      if(allPlayers[msg.sender].shareCycle!=shareCycle){
          allPlayers[msg.sender].playCount=0;
          allPlayers[msg.sender].shareCycle=shareCycle;
          insertCyclePlayer();
      }
        allPlayers[msg.sender].playCount++;
        // note we don't touch profitShare or winnings because they need to roll over cycles if unclaimed
    }

    // convenience to manage a growing array
    function insertCyclePlayer() internal {
        if(numberOfCyclePlayers == cyclePlayers.length) {
            cyclePlayers.length += 1;
        }
        cyclePlayers[numberOfCyclePlayers++] = msg.sender;
    }

    // add new member of syndicate
    function addMember(address _memberAddress) internal {
       if (members[_memberAddress].numShares == 0){
              syndicateMembers.push(_memberAddress);
              numberSyndicateMembers++;
        }
    }

    // buy into syndicate
    function buyIntoSyndicate() public payable  {
        if(msg.value==0 || availableBuyInShares==0) revert();
        if(msg.value < minimumBuyIn*buyInSharePrice) revert();

        uint256 value = (msg.value/precision)*precision; // ensure precision
        uint256 allocation = value/buyInSharePrice;

        if (allocation >= availableBuyInShares){
            allocation = availableBuyInShares; // limit hit
        }
        availableBuyInShares-=allocation;
        addMember(msg.sender); // possibly add this member to the syndicate
        members[msg.sender].numShares+=allocation;
    }

    // how many shares?
    function memberShareCount() public  view returns (uint256) {
        return members[msg.sender].numShares;
    }

    // how much profit?
    function memberProfitShare() public  view returns (uint256) {
        return members[msg.sender].profitShare;
    }

    // For previous contributors to hedgely v0.1
    function allocateShares(uint256 allocation, address stakeholderAddress)  public onlyOwner {
        if (allocation > availableBuyInShares) revert();
        availableBuyInShares-=allocation;
        addMember(stakeholderAddress); // possibly add this member to the syndicate
        members[stakeholderAddress].numShares+=allocation;
    }

    function setShareCycleSessionSize (uint256 size) public onlyOwner {
        shareCycleSessionSize = size;
    }

    function setMaxCyclePlayersConsidered (uint256 numPlayersConsidered) public onlyOwner {
        maxCyclePlayersConsidered = numPlayersConsidered;
    }

    // returns the status of the player
    // note if the player share cycle!=shareCycle, then the playCount is stale - so return zero without setting it
    function playerStatus(address _playerAddress) public constant returns(uint256, uint256, uint256, uint256) {
         uint256 playCount = allPlayers[_playerAddress].playCount;
         if (allPlayers[_playerAddress].shareCycle!=shareCycle){playCount=0;}
         uint256 winnings = allPlayers[_playerAddress].winnings;
           if (now >sessionEndTime){
             // session has ended, this player may have winnings not yet allocated, but they should show up
              winnings+=  SafeMath.mul(playerPortfolio[_playerAddress][currentLowest],winningMultiplier);
           }
        return (playCount, allPlayers[_playerAddress].shareCycle, allPlayers[_playerAddress].profitShare , winnings);
    }

    function min(uint a, uint b) private pure returns (uint) {
           return a < b ? a : b;
    }


   // Array of players
   address[] private players;
   mapping(address => bool) private activePlayers;
   uint256 numPlayers = 0;

   // map each player address to their portfolio of investments
   mapping(address => uint256 [10] ) private playerPortfolio;

   uint256[10] private marketOptions;

   // The total amount of Ether bet for this current market
   uint256 public totalInvested;
   // The amount of Ether used to see the market
   uint256 private seedInvestment;

   // The total number of investments the users have made
   uint256 public numberOfInvestments;

   // The number that won the last game
   uint256 public numberWinner;

   // current session information
   uint256 public sessionNumber;
   uint256 public currentLowest;
   uint256 public currentLowestCount; // should count the number of currentLowest to prevent a tie

   uint256 public precision = 1000000000000000; // rounding to this will keep it to 1 finney resolution
   uint256 public minimumStake = 1 finney;

   uint256 public winningMultiplier; // what this session will yield 5x - 8x

   uint256 public sessionDuration = 20 minutes;
   uint256 public sessionEndTime = 0;

   function Hedgely() public {
     owner = msg.sender;
     members[msg.sender].numShares = 10000; // owner portion
     members[msg.sender].profitShare = 0;
     numberSyndicateMembers = 1;
     syndicateMembers.push(msg.sender);
     sessionNumber = 0;
     numPlayers = 0;
     resetMarket();
   }

    // the full amount invested in each option
   function getMarketOptions() public constant returns (uint256[10])
    {
        return marketOptions;
    }

    // each player can get their own portfolio
   function getPlayerPortfolio() public constant returns (uint256[10])
    {
        return playerPortfolio[msg.sender];
    }

    // the number of investors this session
    function numberOfInvestors() public constant returns(uint count) {
        return numPlayers;
    }


    // pseudo random - but does that matter?
    uint64 _seed = 0;
    function random(uint64 upper) private returns (uint64 randomNumber) {
       _seed = uint64(keccak256(keccak256(block.blockhash(block.number), _seed), now));
       return _seed % upper;
     }

    // resets the market conditions
   function resetMarket() internal {

     // check if share cycle is complete and if required distribute profits
     shareCycleIndex+=1;
     if (shareCycleIndex > shareCycleSessionSize){
       distributeProfit();
     }

    sessionNumber ++;
    winningMultiplier = 8; // always 8 better incentive to play
    numPlayers = 0;

    // randomize the initial market values
    uint256 sumInvested = 0;
    uint256[10] memory startingOptions;

    // player vs player optimized seeds
    // ante up slots
    startingOptions[0]=0;
    startingOptions[1]=0;
    startingOptions[2]=0;
    startingOptions[3]=precision*(random(2)); // between 0 and 1
    startingOptions[4]=precision*(random(3)+1); // between 1 and 3
    startingOptions[5]=precision*(random(2)+3); // between 3 and 4
    startingOptions[6]=precision*(random(3)+4); // between 4 and 6
    startingOptions[7]=precision*(random(3)+5); // between 5 and 7
    startingOptions[8]=precision*(random(3)+8); // between 8 and 10
    startingOptions[9]=precision*(random(3)+8); // between 8 and 10

    // shuffle the deck

      uint64 currentIndex = uint64(marketOptions.length);
      uint256 temporaryValue;
      uint64 randomIndex;

      // While there remain elements to shuffle...
      while (0 != currentIndex) {

        // Pick a remaining element...
        randomIndex = random(currentIndex);
        currentIndex -= 1;

        // And swap it with the current element.
        temporaryValue = startingOptions[currentIndex];
        startingOptions[currentIndex] = startingOptions[randomIndex];
        startingOptions[randomIndex] = temporaryValue;
      }

     marketOptions = startingOptions;
     playerPortfolio[this] = marketOptions;
     totalInvested =  sumInvested;
     seedInvestment = sumInvested;
     insertPlayer(this);
     numPlayers=1;
     numberOfInvestments = 10;

     currentLowest = findCurrentLowest();
     sessionEndTime = now + sessionDuration;
     StartSession(sessionNumber, sessionEndTime, marketOptions , now);

   }


    // main entry point for investors/players
    function invest(uint256 optionNumber) public payable {

      // Check that the number is within the range (uints are always>=0 anyway)
      assert(optionNumber <= 9);
      uint256 amount = roundIt(msg.value); // round to precision
      assert(amount >= minimumStake);

       // is this a new session starting?
      if (now> sessionEndTime){
        endSession();
        // auto invest them in the lowest market option (only fair, they missed transaction or hit start button)
        optionNumber = currentLowest;
      }

      uint256 holding = playerPortfolio[msg.sender][optionNumber];
      holding = SafeMath.add(holding, amount);
      playerPortfolio[msg.sender][optionNumber] = holding;

      marketOptions[optionNumber] = SafeMath.add(marketOptions[optionNumber],amount);

      numberOfInvestments += 1;
      totalInvested += amount;
      if (!activePlayers[msg.sender]){
                    insertPlayer(msg.sender);
                    activePlayers[msg.sender]=true;
       }

      Invest(msg.sender, optionNumber, amount, marketOptions, block.number);
      updatePlayCount(); // rank the player in leaderboard
      currentLowest = findCurrentLowest();

    } // end invest


    // find lowest option sets currentLowestCount>1 if there are more than 1 lowest
    function findCurrentLowest() internal returns (uint lowestOption) {

      uint winner = 0;
      uint lowestTotal = marketOptions[0];
      currentLowestCount = 0;
      for(uint i=0;i<10;i++)
      {
          if (marketOptions [i]<lowestTotal){
              winner = i;
              lowestTotal = marketOptions [i];
              currentLowestCount = 0;
          }
         if (marketOptions [i]==lowestTotal){currentLowestCount+=1;}
      }
      return winner;
    }

    // distribute winnings at the end of a session
    function endSession() internal {

      uint256 sessionWinnings = 0;
      if (currentLowestCount>1){
        numberWinner = 10; // no winner
      }else{
        numberWinner = currentLowest;
      }

      // record the end of session
      for(uint j=1;j<numPlayers;j++)
      {
        if (numberWinner<10 && playerPortfolio[players[j]][numberWinner]>0){
          uint256 winningAmount =  playerPortfolio[players[j]][numberWinner];
          uint256 winnings = SafeMath.mul(winningMultiplier,winningAmount); // n times the invested amount.
          sessionWinnings+=winnings;

          allocateWinnings(players[j],winnings); // allocate winnings

          Winning(players[j], winnings, sessionNumber, numberWinner,block.number); // we can pick this up on gui
        }
        playerPortfolio[players[j]] = [0,0,0,0,0,0,0,0,0,0];
        activePlayers[players[j]]=false;
      }

      EndSession(msg.sender, sessionNumber, numberWinner, marketOptions , block.number);

      uint256 playerInvestments = totalInvested-seedInvestment;

      if (sessionWinnings>playerInvestments){
        uint256 loss = sessionWinnings-playerInvestments; // this is a loss
        if (currentSyndicateValue>=loss){
          currentSyndicateValue-=loss;
        }else{
          currentSyndicateValue = 0;
        }
      }

      if (playerInvestments>sessionWinnings){
        currentSyndicateValue+=playerInvestments-sessionWinnings; // this is a gain
      }
      resetMarket();
    } // end session


    // convenience to manage a growing array
    function insertPlayer(address value) internal {
        if(numPlayers == players.length) {
            players.length += 1;
        }
        players[numPlayers++] = value;
    }


    // ----- admin functions in event of an issue --
    function setSessionDurationMinutes (uint256 _m) public onlyOwner {
        sessionDuration = _m * 1 minutes ;
    }

    function withdraw(uint256 amount) public onlyOwner {
        require(amount<=this.balance);
        if (amount==0){
            amount=this.balance;
        }
        owner.transfer(amount);
    }

   // In the event of catastrophe
    function kill()  public onlyOwner {
         if(msg.sender == owner)
            selfdestruct(owner);
    }

    // donations, funding, replenish
     function() public payable {}

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}