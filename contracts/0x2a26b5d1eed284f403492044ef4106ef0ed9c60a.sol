pragma solidity ^0.4.24;

/* LORDS OF THE SNAILS

LOTS is a hot potato game on Ethereum.
Goal: gather enough eggs to win the round.

8 different Snails produce eggs consistently.
Grab a Snail to own it and get the eggs he previously laid.
Snag while owning a Snail to get accumulated eggs.

For each of the 8 Snails, there is one Lord.
Claim a Lord to own the corresponding Snail on round start.

Both Snails and Lords are ether hot potatoes with fixed increases.
Snails can only be acquired while the game is active.
Lords can only be acquired while the game is paused.

Snail cost starts at 0.01 ETH and rises by 0.01 for each level.
On a flip, the previous Snail owner is reimbursed the cost of his own flip.
On round end, Snail cost resets to 0.01 ETH.

With each flip, the level of the Snail flipped rises by 1.
Egg production for that Snail is 1 per second per level.

A global multiplier boosts bonus Eggs for flippers.
This multiplier rises by 1% per minute, and resets on a flip.

Lord cost starts at 0.05 eth and rises by 0.05 per level.
On a flip, the previous Lord receives his flip + 0.01 ETH.
Lord cost and level are permanent.
Lords receive dividends everytime a Grab or Snag is done on their snail.

Lord flips share a global egg bonus.
This bonus is fixed at 8 per second * round.
The bonus resets on a Lord flip or a round win.

Once a player reaches the required amount of eggs through Grab or Snag,
Their amount of eggs is reset to 0 and they win the round.
They receive the round pot, and the game enters a 24 hours downtime period.
Other players keep their Eggs from round to round.

*/

contract LordsOfTheSnails {
    using SafeMath for uint;
    
    /* EVENTS */
    
    event WonRound (address indexed player, uint eth, uint round);
    event StartedRound (uint round);
    event GrabbedSnail (address indexed player, uint snail, uint eth, uint egg, uint playeregg);
    event SnaggedEgg (address indexed player, uint snail, uint egg, uint playeregg);
    event ClaimedLord (address indexed player, uint lord, uint eth, uint egg, uint playeregg);
    event WithdrewBalance (address indexed player, uint eth);
    event PaidThrone (address indexed player, uint eth);
    event BoostedPot (address indexed player, uint eth);

    /* CONSTANTS */
    
    uint256 constant SNAIL_COST     = 0.01 ether; //per level
    uint256 constant LORD_COST      = 0.05 ether; //per level
    uint256 constant SNAG_COST      = 0.002 ether; //fixed
    uint256 constant DOWNTIME       = 86400; //24 hours between rounds, in seconds
    uint256 constant WIN_REQ        = 1000000; //per round
    address constant SNAILTHRONE    = 0x261d650a521103428C6827a11fc0CBCe96D74DBc;

    /* STRUCTS */

    struct Snail {
        uint256 level;
        uint256 lastSnag;
        address owner;
    }
    
    Snail[8] colorSnail;
    
    struct Lord {
        uint256 level;
        address owner;
    }
    
    Lord[8] lord;
    
    /* VARIABLES */
    
    //State of the game
    bool public gameActive = false;
    
    //Current round
    uint256 public round;
    
    //Timestamp for next round start
    uint256 public nextRoundStart;
    
    //Requirement to win round
    uint256 public victoryEgg;
    
    //Current egg leader
    address public leader;
    
    //Last global Snail grab
    uint256 public lastGrab;
    
    //Last global Lord claim
    uint256 public lastClaim;
    
    //Game pot
    uint256 public snailPot;
    
    //Round pot, part of the snailPot set at round start
    uint256 public roundPot;
    
    //Divs for SnailThrone
    uint256 public thronePot;
    
    /* MAPPINGS */
    
    mapping (address => uint256) playerEgg;
    mapping (address => uint256) playerBalance;
    
    /* FUNCTIONS */

    // Constructor 
    // Sets all snails and lords to level 1 and msg.sender
    // Starts downtime period

    constructor() public {

        Lord memory _lord = Lord({
            level: 1,
            owner: msg.sender
        });
        
        lord[0] =  _lord;
        lord[1] =  _lord;
        lord[2] =  _lord;
        lord[3] =  _lord;
        lord[4] =  _lord;
        lord[5] =  _lord;
        lord[6] =  _lord;
        lord[7] =  _lord;
        
        leader = msg.sender;
        lastClaim = now;
        nextRoundStart = now.add(DOWNTIME);
    }
    
    //-- PRIVATE --//
    
    // PotSplit
    // 80% to snailPot, 10% to thronePot, 10% to lord owner
    
    function PotSplit(uint256 _msgValue, uint256 _id) private {
        
        snailPot = snailPot.add(_msgValue.mul(8).div(10));
        thronePot = thronePot.add(_msgValue.div(10));
        address _owner = lord[_id].owner;
        playerBalance[_owner] = playerBalance[_owner].add(_msgValue.div(10));
    }
    
    // WinRound
    // Gives the roundpot to winner, pauses game
    
    function WinRound(address _msgSender) private {
        gameActive = false;
		lastClaim = now; //let's avoid a race to flip the moment round ends
        nextRoundStart = now.add(DOWNTIME);
        playerEgg[_msgSender] = 0;
        playerBalance[_msgSender] = playerBalance[_msgSender].add(roundPot);
        
        emit WonRound(_msgSender, roundPot, round);
    }
    
    //-- PUBLIC --//
    
    // BeginRound
    // Sets proper values, then starts the round
    // roundPot = 10% of snailPot, winReq = 1MM * round
    
    function BeginRound() public {
        require(now >= nextRoundStart, "downtime isn't over yet");
        require(gameActive == false, "game is already active");
        
        for(uint256 i = 0; i < 8; i++){
            colorSnail[i].level = 1;
            colorSnail[i].lastSnag = now;
            colorSnail[i].owner = lord[i].owner;
        }

		round = round.add(1);
        victoryEgg = round.mul(WIN_REQ);
        roundPot = snailPot.div(10);
        snailPot = snailPot.sub(roundPot);
        lastGrab = now;
        gameActive = true;
        
        emit StartedRound(round);
    }
    
    function GrabSnail(uint256 _id) public payable {
        require(gameActive == true, "game is paused");
        require(tx.origin == msg.sender, "no contracts allowed");
        
        //check cost
        uint256 _cost = ComputeSnailCost(_id);
        require(msg.value == _cost, "wrong amount of ETH");
        
        //split 0.01eth to pot
        PotSplit(SNAIL_COST, _id);
        
        //give value - 0.01eth to previous owner
        uint256 _prevReward = msg.value.sub(SNAIL_COST);
        address _prevOwner = colorSnail[_id].owner;
        playerBalance[_prevOwner] = playerBalance[_prevOwner].add(_prevReward);
        
        //compute eggs, set last hatch then give to flipper
        uint256 _reward = ComputeEgg(true, _id);
        colorSnail[_id].lastSnag = now;
        playerEgg[msg.sender] = playerEgg[msg.sender].add(_reward);
        
        //give snail to flipper, raise level
        colorSnail[_id].owner = msg.sender;
        colorSnail[_id].level = colorSnail[_id].level.add(1);
        
        //set last flip to now
        lastGrab = now;
        
        //check if flipper ends up winning round
        if(playerEgg[msg.sender] >= victoryEgg){
            WinRound(msg.sender);
        } else {
            emit GrabbedSnail(msg.sender, _id, _cost, _reward, playerEgg[msg.sender]);
        }
        
        //check if flipper becomes leader
        if(playerEgg[msg.sender] > playerEgg[leader]){
            leader = msg.sender;
        }
    }
    
    function ClaimLord(uint256 _id) public payable {
        require(gameActive == false, "lords can only flipped during downtime");
        require(tx.origin == msg.sender, "no contracts allowed");
        
        //check cost
        uint256 _cost = ComputeLordCost(_id);
        require(msg.value == _cost, "wrong amount of ETH");
        
        uint256 _potSplit = 0.04 ether;
        //split 0.04eth to pot
        PotSplit(_potSplit, _id);
        
        //give value - 0.04eth to previous owner
        uint256 _prevReward = msg.value.sub(_potSplit);
        address _prevOwner = lord[_id].owner;
        playerBalance[_prevOwner] = playerBalance[_prevOwner].add(_prevReward);

        //compute bonus eggs and give to flipper
        uint256 _reward = ComputeLordBonus();
        playerEgg[msg.sender] = playerEgg[msg.sender].add(_reward);
        
        //give lord to flipper, raise level
        lord[_id].owner = msg.sender;
        lord[_id].level = lord[_id].level.add(1);
    
        //set last lord flip to now
        lastClaim = now;
        
        //check if flipper becomes leader
        if(playerEgg[msg.sender] > playerEgg[leader]){
            leader = msg.sender;
        }
        
        emit ClaimedLord(msg.sender, _id, _cost, _reward, playerEgg[msg.sender]);
    }
    
    function SnagEgg(uint256 _id) public payable {
        require(gameActive == true, "can't snag during downtime");
        require(msg.value == SNAG_COST, "wrong ETH amount (should be 0.002eth)");
		require(colorSnail[_id].owner == msg.sender, "own this snail to snag their eggs");
        
        //split msg.value
        PotSplit(SNAG_COST, _id);
        
        //compute eggs, set last hatch then give reward
        uint256 _reward = ComputeEgg(false, _id);
        colorSnail[_id].lastSnag = now;
        playerEgg[msg.sender] = playerEgg[msg.sender].add(_reward);
         
        //check if snagger ends up winning round
        if(playerEgg[msg.sender] >= victoryEgg){
            WinRound(msg.sender);
        } else {
            emit SnaggedEgg(msg.sender, _id, _reward, playerEgg[msg.sender]);
        }
        
        //check if snagger becomes leader
        if(playerEgg[msg.sender] > playerEgg[leader]){
            leader = msg.sender;
        }
    }
    
    //-- MANAGEMENT --//
    
    // WithdrawBalance
    // Withdraws the ETH balance of a player to his wallet
    
    function WithdrawBalance() public {
        require(playerBalance[msg.sender] > 0, "no ETH in player balance");
        
        uint _amount = playerBalance[msg.sender];
        playerBalance[msg.sender] = 0;
        msg.sender.transfer(_amount);
        
        emit WithdrewBalance(msg.sender, _amount);
    }
    
    // PayThrone
    // Sends thronePot to SnailThrone
    
    function PayThrone() public {
        uint256 _payThrone = thronePot;
        thronePot = 0;
        if (!SNAILTHRONE.call.value(_payThrone)()){
            revert();
        }
        
        emit PaidThrone(msg.sender, _payThrone);
    }
    
    // fallback function
    // Feeds the snailPot
    
    function() public payable {
        snailPot = snailPot.add(msg.value);
        
        emit BoostedPot(msg.sender, msg.value);
    }
    
    //-- COMPUTATIONS --//
    
    // ComputeSnailCost
    // Returns cost to buy a particular snail
    // Cost = next level * SNAIL_COST
    
    function ComputeSnailCost(uint256 _id) public view returns(uint256){
        uint256 _cost = (colorSnail[_id].level.add(1)).mul(SNAIL_COST);
        return _cost;
    }
    
    // ComputeLordCost
    // Returns cost to buy a particular snail
    // Cost = next level * SNAIL_COST
    
    function ComputeLordCost(uint256 _id) public view returns(uint256){
        uint256 _cost = (lord[_id].level.add(1)).mul(LORD_COST);
        return _cost;
    }
    
    // ComputeEgg
    // Returns eggs produced since last snag
    // 1 per second per level
    // Multiplies by bonus if flip (1% per minute)
    
    function ComputeEgg(bool _flip, uint256 _id) public view returns(uint256) {
        
        //Get bonus (in %)
        uint256 _bonus = 100;
        if(_flip == true){
            _bonus = _bonus.add((now.sub(lastGrab)).div(60));
        }
        
        //Calculate eggs
        uint256 _egg = now.sub(colorSnail[_id].lastSnag);
        _egg = _egg.mul(colorSnail[_id].level).mul(_bonus).div(100);
        return _egg;
    }
    
    // ComputeLordBonus
    // Returns bonus eggs for flipping a lord
    // Bonus = 8 per second per round
	// (With 24h downtime, roughly 2/3 of the req in worst/best case)
    
    function ComputeLordBonus() public view returns(uint256){
        return (now.sub(lastClaim)).mul(8).mul(round);
    }
    
    //-- GETTERS --//
    
    function GetSnailLevel(uint256 _id) public view returns(uint256){
        return colorSnail[_id].level;
    }
    
    function GetSnailSnag(uint256 _id) public view returns(uint256){
        return colorSnail[_id].lastSnag;
    }
    
    function GetSnailOwner(uint256 _id) public view returns(address){
        return colorSnail[_id].owner;
    }
    
    function GetLordLevel(uint256 _id) public view returns(uint256){
        return lord[_id].level;
    }
    
    function GetLordOwner(uint256 _id) public view returns(address){
        return lord[_id].owner;
    }
    
    function GetPlayerBalance(address _player) public view returns(uint256){
        return playerBalance[_player];
    }
    
    function GetPlayerEgg(address _player) public view returns(uint256){
        return playerEgg[_player];
    }
}

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