pragma solidity 0.4.19;

contract Base {
  function isContract(address _addr) constant internal returns(bool) {
    uint size;
    if (_addr == 0) return false;
    assembly {
        size := extcodesize(_addr)
    }
    return size > 0;
  }
}

//TODO change to interface if that ever gets added to the parser
contract RngRequester {
  function acceptRandom(bytes32 id, bytes result);
}

//TODO change to interface if that ever gets added to the parser
contract CryptoLuckRng {
  function requestRandom(uint8 numberOfBytes) payable returns(bytes32);

  function getFee() returns(uint256);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

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

contract StateQuickEth is Ownable {
  //Certain parameters of the game can only be changed if the game is stopped.
  //Rules shouldn't be changed while the game is going on :)
  //
  //This way, the owner can't e.g. lock up contributed funds or such, 
  //by updating the game params to bad values, like minimum 1 million participants, etc.
  modifier gameStopped {
    require(!gameRunning);
    
    _;
  }

  uint16 internal constant MANUAL_WITHDRAW_INTERVAL = 1 hours;
  
  bool public gameRunning;
  
  //Instead of being able to stop the game outright, the owner can only "schedule"
  //for the game to stop at the end of the current round.
  //Game stays locked until explicitly restarted.
  bool public stopGameOnNextRound;

  //When someone sends ETH to the contract, what's the minimum gas the tx should have,
  //so that it can execute the draw. 
  uint32 public minGasForDrawing = 350000;
  
  //Ideally, we dont want the execution of a lottery to last too long, 
  //so require a decent gas price when drawing. 6 GWEI
  uint256 public minGasPriceForDrawing = 6000000000;

  //This reward should cover the gas cost for drawing.
  //At the end of each lottery, the drawer will be refunded this amount 
  //(0.002 eth to start with) - about 350k gas at 6 gwei price.
  uint256 public rewardForDrawing = 2 finney;

  //House takes a 1% fee (10/1000). Can be updated when game is stopped.
  //Value is divided by 1000 instead of 100, to be able to use fractional percentages e.g., 1.5%
  uint8 public houseFee = 10;

  //Min and max contribution of this lottery.   
  uint256 public minContribution = 20 finney;
  uint256 public maxContribution = 1 ether;
  
  //Max bonus tickets for drawer.
  uint256 public maxBonusTickets = 5;
  
  //Percentage of tickets purchased, awarded as bonus to the drawer.
  uint8 public bonusTicketsPercentage = 1;
  
  //Minimum entries required to allow a draw to happen
  uint16 public requiredEntries = 5;
  
  //Allow at least 60 minutes between draws, to have a minimally decent prize pool.
  uint256 public requiredTimeBetweenDraws = 60 minutes;

  address public rngAddress;
  ////////////////////////////////////////////////////////
  //Owner methods

  //Game rules - can only be changed if the game is stopped.
  function updateHouseFee(uint8 _value) public onlyOwner gameStopped {
    houseFee = _value;
  }

  function updateMinContribution(uint256 _value) public onlyOwner gameStopped {
    minContribution = _value;
  }

  function updateMaxContribution(uint256 _value) public onlyOwner gameStopped {
    maxContribution = _value;
  }

  function updateRequiredEntries(uint16 _value) public onlyOwner gameStopped {
    requiredEntries = _value;
  }

  function updateRequiredTimeBetweenDraws(uint256 _value) public onlyOwner gameStopped {
    requiredTimeBetweenDraws = _value;
  }
  //END of Game rules
  /////

  //Logistics
  function updateMaxBonusTickets(uint256 _value) public onlyOwner {
    maxBonusTickets = _value;
  }

  function updateBonusTicketsPercentage(uint8 _value) public onlyOwner {
    bonusTicketsPercentage = _value;
  }

  function updateStopGameOnNextRound(bool _value) public onlyOwner {
    stopGameOnNextRound = _value;
  }

  function restartGame() public onlyOwner {
    gameRunning = true;
  }
  
  function updateMinGasForDrawing(uint32 newGasAmount) public onlyOwner {
    minGasForDrawing = newGasAmount;
  }

  function updateMinGasPriceForDrawing(uint32 newGasPrice) public onlyOwner {
    minGasPriceForDrawing = newGasPrice;
  }

  function updateRngAddress(address newAddress) public onlyOwner {
    require(rngAddress != 0x0);
    rngAddress = newAddress;
  }

  function updateRewardForDrawing(uint256 newRewardForDrawing) public onlyOwner {
    require(newRewardForDrawing > 0);

    rewardForDrawing = newRewardForDrawing;
  }
  //END Logistics

  //END owner methods  
}

//
//-----------------------------
// <<<<Contract begins here>>>>
//-----------------------------
//
//* CryptoLuck Lottery Game 
//* Quick, ETH
//* Version: 1
//* Website: https://cryptoluck.fun
//*
contract CryptoLuckQuickEthV1 is RngRequester, StateQuickEth, Base {
  using SafeMath for uint;

  modifier onlyRng {
    require(msg.sender == rngAddress);
    
    _;
  }

  event LogLotteryResult(
    uint32 indexed lotteryId, 
    uint8 status,
    bytes32 indexed oraclizeId, 
    bytes oraclizeResult
  );
  
  struct Lottery {
    uint256 prizePool;
    uint256 totalContributions;
    uint256 oraclizeFees;
    
    uint256 drawerBonusTickets;
    
    mapping (address => uint256) balances;
    address[] participants;
      
    address winner;
    address drawer;

    bytes32[] oraclizeIds;
    bytes oraclizeResult;

    uint256 winningNumber;

    //0 => initial state, open
    //1 => finalized with success
    //2 => finalized with error (e.g. due to Oraclize not returning proper results etc)
    uint8 status;

    bool awaitingOraclizeCallback;
  }
  
  bool public useOraclize;
  //Keep track of all lotteries. Stats ftw
  uint32 public currentLotteryId = 0;
  mapping (uint32 => Lottery) public lotteries;
  
  //1 finney == 0.001 ETH. Estimating for a run of ETH to 1000 USD, that's $1 per ticket.
  uint256 public ticketPrice = 1 finney;
  
  //Timestamp to keep track of when the last draw happened
  uint256 public lastDrawTs;
  
  uint256 public houseBalance = 0;
  
  function CryptoLuckQuickEthV1(address _rngAddress, bool _useOraclize) {
    stopGameOnNextRound = false;
    gameRunning = true;
    
    require(_rngAddress != 0x0);

    rngAddress = _rngAddress;
    useOraclize = _useOraclize;
    
    //Initialize lottery draw to contract deploy time - 
    //that's when we "start" the lottery.
    lastDrawTs = block.timestamp;
  }

  //Convenience method to return the current lottery
  function currentLottery() view internal returns (Lottery storage) {
    return lotteries[currentLotteryId];
  }

  /////////////////
  //Lottery flow:
  //STEP 1: send ETH to enter lottery 
  function () public payable {
    // Disallow contracts - this avoids a whole host of issues, automations etc.
    require(!isContract(msg.sender));
    
    // Disallow deposits if game is not running
    require(gameRunning);
    
    // Require the sender to be able to purchase at least 1 ticket
    require(msg.value >= ticketPrice);
    
    uint256 existingBalance = currentLottery().balances[msg.sender];
    
    //Total contribution should be at least the minimum contribution (0.05 ETH to start with)
    require(msg.value + existingBalance >= minContribution);
    //But their total contribution must not exceed max contribution
    require(msg.value + existingBalance <= maxContribution);
    
    updatePlayerBalance(currentLotteryId);
    
    //If the requirements for a draw are met, and the gas price and gas limit are OK as well,
    //execute the draw.
    if (mustDraw() && gasRequirementsOk()) {
      draw();
    }
  }

  //Ensure there's enough gas left (minGasForDrawing is an estimate)
  //and that the gas price is enough to ensure it doesnt take an eternity to process the draw tx.
  function gasRequirementsOk() view private returns(bool) {
    return (msg.gas >= minGasForDrawing) && (tx.gasprice >= minGasPriceForDrawing);
  }

  /////////////////
  //STEP 2: store balance
  //
  //When someone sends Ether to this contract, we keep track of their total contribution.
  function updatePlayerBalance(uint32 lotteryId) private returns(uint) {
    Lottery storage lot = lotteries[lotteryId];
    
    //if current lottery is locked, since we made the call to Oraclize for the random number,
    //but we haven't received the response yet, put the player's ether into the next lottery instead.
    if (lot.awaitingOraclizeCallback) {
      updatePlayerBalance(lotteryId + 1);
      return;
    }

    address participant = msg.sender;
    
    //If we dont have this participant in the balances mapping, 
    //then it's a new address, so add it to the participants list, to keep track of the address.
    if (lot.balances[participant] == 0) {
      lot.participants.push(participant);
    }
    
    //Increase the total contribution of this address (people can buy multiple times from the same address)
    lot.balances[participant] = lot.balances[participant].add(msg.value);
    //And the prize pool, of course.
    lot.prizePool = lot.prizePool.add(msg.value);
    
    return lot.balances[participant];
  }
  
  /////////////////
  //STEP 3: when someone contributes to the lottery, check to see if we've met the requirements for a draw yet.
  function mustDraw() view private returns (bool) {
    Lottery memory lot = currentLottery();
    
    //At least 60 mins have elapsed since the last draw
    bool timeDiffOk = now - lastDrawTs >= requiredTimeBetweenDraws;
    
    //We have at least 5 participants
    bool minParticipantsOk = lot.participants.length >= requiredEntries;

    return minParticipantsOk && timeDiffOk;
  }

  /////////////////
  //STEP 4: If STEP 3 is a-ok, execute the draw, request a random number from our RNG provider.
  //Flow will be resumed when the RNG provider contract receives the Oraclize callback, and in turn
  //calls back into the lottery contract.
  function draw() private {
    Lottery storage lot = currentLottery();
    
    lot.awaitingOraclizeCallback = true;
    
    //Record total contributions for posterity and for correct calculation of the result,
    //since the prize pool is used to pay for the Oraclize fees.
    lot.totalContributions = lot.prizePool;

    //Track who was the drawer of the lottery, to be awarded the drawer bonuses: 
    //extra ticket(s) and some ETH to cover the gas cost
    lot.drawer = msg.sender;

    lastDrawTs = now;
    
    requestRandom();
  }

  /////////////////
  //STEP 5: Generate a random number between 0 and the sum of purchased tickets, using Oraclize random DS.
  function requestRandom() private {
    Lottery storage lot = currentLottery();
    
    CryptoLuckRng rngContract = CryptoLuckRng(rngAddress);
    
    //RNG provider returns the estimated Oraclize fee
    uint fee = rngContract.getFee();
    
    //Pay oraclize query from the prize pool and keep track of all fees paid 
    //(usually, only 1 fee, but can be more if the first call fails)
    lot.prizePool = lot.prizePool.sub(fee);
    lot.oraclizeFees = lot.oraclizeFees.add(fee);
    
    //Store the query ID so we can match it on callback, to ensure we are receiving a legit callback.
    //Ask for a 7 bytes number. max is 72'057'594'037'927'936, should be ok :)
    bytes32 oraclizeId = rngContract.requestRandom.value(fee)(7);
    
    lot.oraclizeIds.push(oraclizeId);
  }

  /////////////////
  //STEP 6: callback from the RNG provider - find the winner based on the generated random number
  function acceptRandom(bytes32 reqId, bytes result) public onlyRng {
    Lottery storage lot = currentLottery();
    
    //Verify the current lottery matches its oraclizeID with the supplied one, 
    //if we use Oraclize on this network (true for non-dev ones)
    if (useOraclize) {
      require(currentOraclizeId() == reqId);
    }
    
    //Store the raw result.
    lot.oraclizeResult = result;

    //Award bonus tickets to the drawer.
    uint256 bonusTickets = calculateBonusTickets(lot.totalContributions);

    lot.drawerBonusTickets = bonusTickets;

    //Compute total tickets in the draw, including the bonus ones.
    uint256 totalTickets = bonusTickets + (lot.totalContributions / ticketPrice);
    
    //mod with totalTickets to get a number in [0..totalTickets - 1]
    //add 1 to bring it in the range of [1, totalTickets], since we start our interval slices at 1 (see below)
    lot.winningNumber = 1 + (uint(keccak256(result)) % totalTickets);

    findWinner();

    LogLotteryResult(currentLotteryId, 1, reqId, result);
  }
  
  //STEP 6': Drawer receives bonus tickets, to cover the higher gas consumption and incentivize people to do so.
  function calculateBonusTickets(uint256 totalContributions) view internal returns(uint256) {
    
    //1% of all contributions
    uint256 bonusTickets = (totalContributions * bonusTicketsPercentage / 100) / ticketPrice;
    
    //bonus = between 1 to maxBonusTickets (initially, 5)
    if (bonusTickets == 0) {
       bonusTickets = 1;
    }

    if (bonusTickets > maxBonusTickets) {
      bonusTickets = maxBonusTickets;
    }
    
    return bonusTickets;
  }

  /////////////////
  //STEP 7: determine winner by figuring out which address owns the interval 
  // encompassing the generated random number and pay the winner.
  function findWinner() private {
    Lottery storage lot = currentLottery();
    
    uint256 currentLocation = 1;

    for (uint16 i = 0; i < lot.participants.length; i++) {
      address participant = lot.participants[i];
      
      //A1 bought 70 tickets => head = 1 + 70 - 1 => owns [1, 70]; at the end of the loop, location ++
      //A2 bought 90 tickets => head = 71 + 90 - 1 => owns [71, 160]; increment, etc
      uint256 finalTickets = lot.balances[participant] / ticketPrice;
      
      //The drawer receives some bonus tickets, for the effort of having executed the lottery draw.
      if (participant == lot.drawer) {
        finalTickets += lot.drawerBonusTickets;
      }

      currentLocation += finalTickets - 1; 
      
      if (currentLocation >= lot.winningNumber) {
          lot.winner = participant;
          break;
      }
      //move to the "start" of the next interval, for the next participant.
      currentLocation += 1; 
    }
    
    //Prize is all current balance on current lottery, minus the house fee and reward for drawing
    uint256 prize = lot.prizePool;

    //Calculate house fee and track it. 
    //House fee is integer per mille, e,g, 5 = 0.5%, thus, divide by 1000 to get the percentage
    uint256 houseShare = houseFee * prize / 1000;
    
    houseBalance = houseBalance.add(houseShare);
    
    //deduct the house share and the reward for drawing from the prize pool.
    prize = prize.sub(houseShare);
    prize = prize.sub(rewardForDrawing);
    
    lot.status = 1;
    lot.awaitingOraclizeCallback = false;
    
    lot.prizePool = prize;

    //Transfer the prize to the winner
    lot.winner.transfer(prize);
    
    //Transfer the reward for drawing to the drawer.
    //(should cover most of the gas paid for executing the draw)
    lot.drawer.transfer(rewardForDrawing);

    finalizeLottery();
  } 
  
  //END lottery flow
  ////////////////////
  
  //Function which moves on to the next lottery and stops the next round if indicated
  function finalizeLottery() private {
    currentLotteryId += 1;

    if (stopGameOnNextRound) {
      gameRunning = false;
      stopGameOnNextRound = false;
    }
  }

  function currentOraclizeId() view private returns(bytes32) {
    Lottery memory lot = currentLottery();
    
    return lot.oraclizeIds[lot.oraclizeIds.length - 1];
  }

  //Allow players to withdraw their money in case the lottery fails.
  //Can happen if the oraclize call fails 2 times
  function withdrawFromFailedLottery(uint32 lotteryId) public {
    address player = msg.sender;
    
    Lottery storage lot = lotteries[lotteryId];
    
    //can only withdraw from failed lotteries
    require(lot.status == 2);
    
    //can withdraw contributed balance, minus the fees that have been paid to Oraclize, divided/supported among all participants
    uint256 playerBalance = lot.balances[player].sub(lot.oraclizeFees / lot.participants.length);
    //require to have something to send back
    require(playerBalance > 0);

    //update the local balances
    lot.balances[player] = 0;
    lot.prizePool = lot.prizePool.sub(playerBalance);

    //send to player
    player.transfer(playerBalance);
  }

  /////////////////////////////////////////////////////////////////
  //Public methods outside lottery flow
  
  //In case ETH is needed in the contract for whatever reason.
  //Generally, the owner of the house will top up the contract, so increase the house balance.
  //PS: If someone else tops up the house, thanks! :)
  function houseTopUp() public payable {
    houseBalance = houseBalance.add(msg.value);
  }
  
  //Allow the owner to withdraw the house fees + house top ups.
  function houseWithdraw() public onlyOwner {
    owner.transfer(houseBalance);
  }

  //In case the lottery gets stuck, oraclize doesnt call back etc., need a way to retry.
  function manualDraw() public onlyOwner {
    Lottery storage lot = currentLottery();
    //Only for open lotteries
    require(lot.status == 0);
    
    //Allow the owner to draw only when it would normally be allowed
    require(mustDraw());
    
    //Also, ensure there's at least 1 hr since the call to oraclize has been made.
    //If the result didnt come in 1 hour, then something is wrong with oraclize, so it's ok to try again.
    require(now - lastDrawTs > MANUAL_WITHDRAW_INTERVAL);

    //If we try to draw manually but we already have 2 Oraclize requests logged, then we need to fail the lottery.
    //then something is wrong with Oraclize - maybe down or someone at Oraclize trying to meddle with the results.
    //As such, fail the lottery, move on to the next and allow people to withdraw their money from this one.
    if (lot.oraclizeIds.length == 2) {
      lot.status = 2;
      lot.awaitingOraclizeCallback = false;
      
      LogLotteryResult(currentLotteryId, 2, lot.oraclizeIds[lot.oraclizeIds.length - 1], "");

      finalizeLottery();
    } else {
      draw();
    }
  }

  
  ///////////

  //Helper methods.
  function balanceInLottery(uint32 lotteryId, address player) view public returns(uint) {
    return lotteries[lotteryId].balances[player];
  }

  function participantsOf(uint32 lotteryId) view public returns (address[]) {
    return lotteries[lotteryId].participants;
  }

  function oraclizeIds(uint32 lotteryId) view public returns(bytes32[]) {
    return lotteries[lotteryId].oraclizeIds;
  }
}