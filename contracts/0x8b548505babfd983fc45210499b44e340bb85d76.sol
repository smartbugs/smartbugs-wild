pragma solidity ^0.4.19;

// Hedgely - The Ethereum Inverted Market
// radamosch@gmail.com
// Contract based investment game

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
 * @title Syndicate
 * @dev Syndicated profit sharing - for early adopters
 * Shares are not transferable -
 */
contract Syndicate is Ownable{

    uint256 public totalSyndicateShares = 20000;
    uint256 public availableEarlyPlayerShares = 5000;
    uint256 public availableBuyInShares = 5000;
    uint256 public minimumBuyIn = 10;
    uint256 public buyInSharePrice = 500000000000000; // wei = 0.0005 ether
    uint256 public shareCycleSessionSize = 1000; // number of sessions in a share cycle
    uint256 public shareCycleIndex = 0; // current position in share cycle
    uint256 public currentSyndicateValue = 0; // total value of syndicate to be divided among members
    uint256 public numberSyndicateMembers = 0;
    uint256 public syndicatePrecision = 1000000000000000;

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

    function Syndicate() public {
        members[msg.sender].numShares = 10000; // owner portion
        members[msg.sender].profitShare = 0;
        numberSyndicateMembers = 1;
        syndicateMembers.push(msg.sender);
    }

    // initiates a dividend of necessary, sends
    function claimProfit() public {
      if (members[msg.sender].numShares==0) revert(); // only syndicate members.
      uint256 profitShare = members[msg.sender].profitShare;
      if (profitShare>0){
        members[msg.sender].profitShare = 0;
        msg.sender.transfer(profitShare);
      }
    }

    // distribute profit amonge syndicate members on a percentage share basis
    function distributeProfit() internal {

      uint256 totalOwnedShares = totalSyndicateShares-(availableEarlyPlayerShares+availableBuyInShares);
      uint256 profitPerShare = SafeMath.div(currentSyndicateValue,totalOwnedShares);

      // foreach member , calculate their profitshare
      for(uint i = 0; i< numberSyndicateMembers; i++)
      {
        // do += so that acrues across share cycles.
        members[syndicateMembers[i]].profitShare+=SafeMath.mul(members[syndicateMembers[i]].numShares,profitPerShare);
      }

      // emit a profit share event
      ProfitShare(currentSyndicateValue, numberSyndicateMembers, totalOwnedShares , profitPerShare);

      currentSyndicateValue=0; // all the profit has been divided up
      shareCycleIndex = 0; // restart the share cycle count.
    }

    // allocate syndicate shares up to the limit.
    function allocateEarlyPlayerShare() internal {
        if (availableEarlyPlayerShares==0) return;
		    availableEarlyPlayerShares--;
       	addMember(); // possibly add this member to the syndicate
        members[msg.sender].numShares+=1;

    }

    // add new member of syndicate
    function addMember() internal {
    	 if (members[msg.sender].numShares == 0){
		          syndicateMembers.push(msg.sender);
		          numberSyndicateMembers++;
		    }
    }

    // buy into syndicate
    function buyIntoSyndicate() public payable  {
    		if(msg.value==0 || availableBuyInShares==0) revert();
      		if(msg.value < minimumBuyIn*buyInSharePrice) revert();

     		uint256 value = (msg.value/syndicatePrecision)*syndicatePrecision; // ensure precision
		    uint256 allocation = value/buyInSharePrice;

		    if (allocation >= availableBuyInShares){
		        allocation = availableBuyInShares; // limit hit
		    }
		    availableBuyInShares-=allocation;
		    addMember(); // possibly add this member to the syndicate
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

}


/**
 * Core Hedgely Contract
 */
contract Hedgely is Ownable, Syndicate {

   // Array of players
   address[] private players;
   mapping(address => bool) private activePlayers;
   uint256 numPlayers = 0;

   // map each player address to their portfolio of investments
   mapping(address => uint256 [10] ) private playerPortfolio;

   uint256 public totalHedgelyWinnings;
   uint256 public totalHedgelyInvested;

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
   uint256 public startingBlock;
   uint256 public endingBlock;
   uint256 public sessionBlockSize;
   uint256 public sessionNumber;
   uint256 public currentLowest;
   uint256 public currentLowestCount; // should count the number of currentLowest to prevent a tie

   uint256 public precision = 1000000000000000; // rounding to this will keep it to 1 finney resolution
   uint256 public minimumStake = 1 finney;

     event Invest(
           address _from,
           uint256 _option,
           uint256 _value,
           uint256[10] _marketOptions,
           uint _blockNumber
     );

     event EndSession(
           uint256 _sessionNumber,
           uint256 _winningOption,
           uint256[10] _marketOptions,
           uint256 _blockNumber
     );

     event StartSession(
           uint256 _sessionNumber,
           uint256 _sessionBlockSize,
           uint256[10] _marketOptions,
           uint256 _blockNumber
     );

    bool locked;
    modifier noReentrancy() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }

   function Hedgely() public {
     owner = msg.sender;
     sessionBlockSize = 100;
     sessionNumber = 0;
     totalHedgelyWinnings = 0;
     totalHedgelyInvested = 0;
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

    // generate a random number between 1 and 20 to seed a symbol
    function rand() internal returns (uint64) {
      return random(19)+1;
    }

    // pseudo random - but does that matter?
    uint64 _seed = 0;
    function random(uint64 upper) private returns (uint64 randomNumber) {
       _seed = uint64(keccak256(keccak256(block.blockhash(block.number), _seed), now));
       return _seed % upper;
     }

    // resets the market conditions
   function resetMarket() internal {

    sessionNumber ++;
    startingBlock = block.number;
    endingBlock = startingBlock + sessionBlockSize; // approximately every 5 minutes - can play with this
    numPlayers = 0;

    // randomize the initial market values
    uint256 sumInvested = 0;
    for(uint i=0;i<10;i++)
    {
        uint256 num =  rand();
        marketOptions[i] =num * precision; // wei
        sumInvested+=  marketOptions[i];
    }

     playerPortfolio[this] = marketOptions;
     totalInvested =  sumInvested;
     seedInvestment = sumInvested;
     insertPlayer(this);
     numPlayers=1;
     numberOfInvestments = 10;

     currentLowest = findCurrentLowest();
     StartSession(sessionNumber, sessionBlockSize, marketOptions , startingBlock);

   }


    // utility to round to the game precision
    function roundIt(uint256 amount) internal constant returns (uint256)
    {
        // round down to correct preicision
        uint256 result = (amount/precision)*precision;
        return result;
    }

    // main entry point for investors/players
    function invest(uint256 optionNumber) public payable noReentrancy {

      // Check that the number is within the range (uints are always>=0 anyway)
      assert(optionNumber <= 9);
      uint256 amount = roundIt(msg.value); // round to precision
      assert(amount >= minimumStake);

      uint256 holding = playerPortfolio[msg.sender][optionNumber];
      holding = SafeMath.add(holding, amount);
      playerPortfolio[msg.sender][optionNumber] = holding;

      marketOptions[optionNumber] = SafeMath.add(marketOptions[optionNumber],amount);

      numberOfInvestments += 1;
      totalInvested += amount;
      totalHedgelyInvested += amount;
      if (!activePlayers[msg.sender]){
                    insertPlayer(msg.sender);
                    activePlayers[msg.sender]=true;
       }

      Invest(msg.sender, optionNumber, amount, marketOptions, block.number);

      // possibly allocate syndicate shares
      allocateEarlyPlayerShare(); // allocate a single share per investment for early adopters

      currentLowest = findCurrentLowest();
      if (block.number >= endingBlock && currentLowestCount==1) distributeWinnings();

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
    function distributeWinnings() internal {

      if (currentLowestCount>1){
      return; // cannot end session because there is no lowest.
      }

      numberWinner = currentLowest;

      // record the end of session
      EndSession(sessionNumber, numberWinner, marketOptions , block.number);

      uint256 sessionWinnings = 0;
      for(uint j=1;j<numPlayers;j++)
      {
      if (playerPortfolio[players[j]][numberWinner]>0){
        uint256 winningAmount =  playerPortfolio[players[j]][numberWinner];
        uint256 winnings = SafeMath.mul(8,winningAmount); // eight times the invested amount.
        totalHedgelyWinnings+=winnings;
        sessionWinnings+=winnings;
        players[j].transfer(winnings); // don't throw here
      }

      playerPortfolio[players[j]] = [0,0,0,0,0,0,0,0,0,0];
      activePlayers[players[j]]=false;

      }

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

      // check if share cycle is complete and if required distribute profits
      shareCycleIndex+=1;
      if (shareCycleIndex >= shareCycleSessionSize){
        distributeProfit();
      }

      resetMarket();
    } // end distribute winnings


    // convenience to manage a growing array
    function insertPlayer(address value) internal {
        if(numPlayers == players.length) {
            players.length += 1;
        }
        players[numPlayers++] = value;
    }

   // We might vary this at some point
    function setsessionBlockSize (uint256 blockCount) public onlyOwner {
        sessionBlockSize = blockCount;
    }

    // ----- admin functions in event of an issue --

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