pragma solidity ^0.4.24;

/* SLUGROAD

Simple Fomo Game with fair scaling.
Slugroad has 3 different tracks: different networks, with different settings.
This is the Ethereum track.

A car drives to hyperspeed.
Speed starts at a min of 100mph and rises to a max 1000mph over 7 days.

Buy Slugs with ETH.
Slugs persist between loops!

Get ETH divs from other Slug buys.
Use your earned ETH to Time Warp, buying Slugs for a cheaper price.

Throw Slugs on the windshield to stop the car (+6 minute timer) and become the Driver.

As the driver, you earn miles according to your speed.
Trade 6000 miles for 1% of the pot.

Once the car reaches hyperspeed, the Driver starts draining the pot.
0.01% is drained every second, up to a maximum of 36% in one hour.

The Driver can jump out of the window at any moment to secure his gains.
Once the Driver jumps out, the car drives freely.
Timer resets to 1 hour.
The wheel goes to the starter, but he gets no reward if the car crosses the finish line.

If someone else throws Slugs before the Driver jumps out, he takes the wheel.
Timer resets to 6 minutes, and the Driver gets nothing!

If the Driver keeps the wheel for one hour in hyperspeed, he gets the full pot.
Then we move to loop 2 immediately, on a 7 days timer.

Slug price: (0.000025 + (loopchest/10000)) / loop
The price of slugs initially rises then lowers through a loop, as the pot is drained.
With each new loop, the price of slugs decrease significantly (cancel out early advantage)

Players can Skip Ahead with the ether they won.
Slug price changes to (0.000025 + (loopchest/10000)) / (loop + 1)
Traveling through time will always be more fruitful than buying.

Pot split:
- 60% divs
- 20% slugBank (reserve pot)
- 10% loopChest (round pot)
- 10% snailthrone

*/

contract Slugroad {
    using SafeMath for uint;
    
    /* Events */
    
    event WithdrewBalance (address indexed player, uint eth);
    event BoughtSlug (address indexed player, uint eth, uint slug);
    event SkippedAhead (address indexed player, uint eth, uint slug);
    event TradedMile (address indexed player, uint eth, uint mile);
    event BecameDriver (address indexed player, uint eth);
    event TookWheel (address indexed player, uint eth);
    event ThrewSlug (address indexed player);
    event JumpedOut (address indexed player, uint eth);
    event TimeWarped (address indexed player, uint indexed loop, uint eth);
    event NewLoop (address indexed player, uint indexed loop);
    event PaidThrone (address indexed player, uint eth);
    event BoostedPot (address indexed player, uint eth);    

    /* Constants */
    
    uint256 constant public RACE_TIMER_START    = 604800; //7 days
    uint256 constant public HYPERSPEED_LENGTH   = 3600; //1 hour
	uint256 constant public THROW_SLUG_REQ      = 200; //slugs to become driver
    uint256 constant public DRIVER_TIMER_BOOST  = 360; //6 minutes
    uint256 constant public SLUG_COST_FLOOR     = 0.000025 ether; //4 zeroes
    uint256 constant public DIV_SLUG_COST       = 10000; //loop pot divider
    uint256 constant public TOKEN_MAX_BUY       = 1 ether; //max allowed eth in one buy transaction
    uint256 constant public MIN_SPEED           = 100;
    uint256 constant public MAX_SPEED           = 1000;
    uint256 constant public ACCEL_FACTOR        = 672; //inverse of acceleration per second
    uint256 constant public MILE_REQ            = 6000; //required miles for 1% of the pot
    address constant public SNAILTHRONE         = 0x261d650a521103428C6827a11fc0CBCe96D74DBc;
	
    /* Variables */
    
    // Race starter
    address public starter;
    bool public gameStarted;
    
    // loop, timer, driver
    uint256 public loop;
    uint256 public timer;
    address public driver;
    
    // Are we in hyperspeed?
    bool public hyperSpeed = false;
    
    // Last driver claim
    uint256 public lastHijack;
    
    // Pots
    uint256 public loopChest;
    uint256 public slugBank;
    uint256 public thronePot;
    
    // Divs for one slug, max amount of slugs
    uint256 public divPerSlug;
    uint256 public maxSlug;
    	
    /* Mappings */
    
    mapping (address => uint256) public slugNest;
    mapping (address => uint256) public playerBalance;
    mapping (address => uint256) public claimedDiv;
    mapping (address => uint256) public mile;
	
    /* Functions */
    
    //-- GAME START --
    
    // Constructor
    // Sets msg.sender as starter, to start the game properly
    
    constructor() public {
        starter = msg.sender;
        gameStarted = false;
    }
    
    // StartRace
    // Initialize timer
    // Set starter as driver (starter can't win or trade miles)
    // Buy tokens for value of message
    
    function StartRace() public payable {
        require(gameStarted == false);
        require(msg.sender == starter);
        
        timer = now.add(RACE_TIMER_START).add(HYPERSPEED_LENGTH);
        loop = 1;
        gameStarted = true;
        lastHijack = now;
        driver = starter;
        BuySlug();
    }

    //-- PRIVATE --

    // PotSplit
    // Called on buy and hatch
    // 60% divs, 20% slugBank, 10% loopChest, 10% thronePot
    
    function PotSplit(uint256 _msgValue) private {
        divPerSlug = divPerSlug.add(_msgValue.mul(3).div(5).div(maxSlug));
        slugBank = slugBank.add(_msgValue.div(5));
        loopChest = loopChest.add(_msgValue.div(10));
        thronePot = thronePot.add(_msgValue.div(10));
    }
    
    // ClaimDiv
    // Sends player dividends to his playerBalance
    // Adjusts claimable dividends
    
    function ClaimDiv() private {
        uint256 _playerDiv = ComputeDiv(msg.sender);
        
        if(_playerDiv > 0){
            //Add new divs to claimed divs
            claimedDiv[msg.sender] = claimedDiv[msg.sender].add(_playerDiv);
                
            //Send divs to playerBalance
            playerBalance[msg.sender] = playerBalance[msg.sender].add(_playerDiv);
        }
    }
    
    // BecomeDriver
    // Gives driver role, and miles to previous driver
    
    function BecomeDriver() private {
        
        //give miles to previous driver
        uint256 _mile = ComputeMileDriven();
        mile[driver] = mile[driver].add(_mile);
        
        //if we're in hyperspeed, the new driver ends up 6 minutes before hyperspeed
        if(now.add(HYPERSPEED_LENGTH) >= timer){
            timer = now.add(DRIVER_TIMER_BOOST).add(HYPERSPEED_LENGTH);
            
            emit TookWheel(msg.sender, loopChest);
            
        //else, simply add 6 minutes to timer    
        } else {
            timer = timer.add(DRIVER_TIMER_BOOST);
            
            emit BecameDriver(msg.sender, loopChest);
        }
        
        lastHijack = now;
        driver = msg.sender;
    }
    
    //-- ACTIONS --
    
    // TimeWarp
    // Call manually when race is over
    // Distributes loopchest and miles to winner, moves to next loop 
    
    function TimeWarp() public {
		require(gameStarted == true, "game hasn't started yet");
        require(now >= timer, "race isn't finished yet");
        
        //give miles to driver
        uint256 _mile = ComputeMileDriven();
        mile[driver] = mile[driver].add(_mile);
        
        //Reset timer and start new loop 
        timer = now.add(RACE_TIMER_START).add(HYPERSPEED_LENGTH);
        loop = loop.add(1);
        
        //Adjust loop and slug pots
        uint256 _nextPot = slugBank.div(2);
        slugBank = slugBank.sub(_nextPot);
        
        //Make sure the car isn't driving freely
        if(driver != starter){
            
            //Calculate reward
            uint256 _reward = loopChest;
        
            //Change loopchest
            loopChest = _nextPot;
        
            //Give reward
            playerBalance[driver] = playerBalance[driver].add(_reward);
        
            emit TimeWarped(driver, loop, _reward);
            
        //Else, start a new loop with different event    
        } else {
            
            //Change loopchest
            loopChest = loopChest.add(_nextPot);

            emit NewLoop(msg.sender, loop);
        }
        
        lastHijack = now;
        //msg.sender becomes Driver
        driver = msg.sender;
    }
    
    // BuySlug
    // Get token price, adjust maxSlug and divs, give slugs
    
    function BuySlug() public payable {
        require(gameStarted == true, "game hasn't started yet");
        require(tx.origin == msg.sender, "contracts not allowed");
        require(msg.value <= TOKEN_MAX_BUY, "maximum buy = 1 ETH");
		require(now <= timer, "race is over!");
        
        //Calculate price and resulting slugs
        uint256 _slugBought = ComputeBuy(msg.value, true);
            
        //Adjust player claimed divs
        claimedDiv[msg.sender] = claimedDiv[msg.sender].add(_slugBought.mul(divPerSlug));
            
        //Change maxSlug before new div calculation
        maxSlug = maxSlug.add(_slugBought);
            
        //Divide incoming ETH
        PotSplit(msg.value);
            
        //Add player slugs
        slugNest[msg.sender] = slugNest[msg.sender].add(_slugBought);
        
		emit BoughtSlug(msg.sender, msg.value, _slugBought);
		
        //Become driver if player bought at least 200 slugs
        if(_slugBought >= 200){
            BecomeDriver();
        }       
    }
    
    // SkipAhead
    // Functions like BuySlug, using player balance
    // Less cost per Slug (+1 loop)
    
    function SkipAhead() public {
        require(gameStarted == true, "game hasn't started yet");
        ClaimDiv();
        require(playerBalance[msg.sender] > 0, "no ether to timetravel");
		require(now <= timer, "race is over!");
        
        //Calculate price and resulting slugs
        uint256 _etherSpent = playerBalance[msg.sender];
        uint256 _slugHatched = ComputeBuy(_etherSpent, false);
            
        //Adjust player claimed divs (reinvest + new slugs) and balance
        claimedDiv[msg.sender] = claimedDiv[msg.sender].add(_slugHatched.mul(divPerSlug));
        playerBalance[msg.sender] = 0;
            
        //Change maxSlug before new div calculation
        maxSlug = maxSlug.add(_slugHatched);
                    
        //Divide reinvested ETH
        PotSplit(_etherSpent);
            
        //Add player slugs
        slugNest[msg.sender] = slugNest[msg.sender].add(_slugHatched);
        
		emit SkippedAhead(msg.sender, _etherSpent, _slugHatched);
		
        //Become driver if player hatched at least 200 slugs
        if(_slugHatched >= 200){
            BecomeDriver();
        }
    }
    
    // WithdrawBalance
    // Sends player ingame ETH balance to his wallet
    
    function WithdrawBalance() public {
        ClaimDiv();
        require(playerBalance[msg.sender] > 0, "no ether to withdraw");
        
        uint256 _amount = playerBalance[msg.sender];
        playerBalance[msg.sender] = 0;
        msg.sender.transfer(_amount);
        
        emit WithdrewBalance(msg.sender, _amount);
    }
    
    // ThrowSlug
    // Throws slugs on the windshield to claim Driver
    
    function ThrowSlug() public {
        require(gameStarted == true, "game hasn't started yet");
        require(slugNest[msg.sender] >= THROW_SLUG_REQ, "not enough slugs in nest");
        require(now <= timer, "race is over!");
        
        //Call ClaimDiv so ETH isn't blackholed
        ClaimDiv();
            
        //Remove slugs
        maxSlug = maxSlug.sub(THROW_SLUG_REQ);
        slugNest[msg.sender] = slugNest[msg.sender].sub(THROW_SLUG_REQ);
            
        //Adjust msg.sender claimed dividends
        claimedDiv[msg.sender] = claimedDiv[msg.sender].sub(THROW_SLUG_REQ.mul(divPerSlug));
        
		emit ThrewSlug(msg.sender);
		
        //Run become driver function
        BecomeDriver();
    }
    
    // JumpOut
    // Driver jumps out of the car to secure his ETH gains
    // Give him his miles as well
    
    function JumpOut() public {
        require(gameStarted == true, "game hasn't started yet");
        require(msg.sender == driver, "can't jump out if you're not in the car!");
        require(msg.sender != starter, "starter isn't allowed to be driver");
        
        //give miles to driver
        uint256 _mile = ComputeMileDriven();
        mile[driver] = mile[driver].add(_mile);
        
        //calculate reward
        uint256 _reward = ComputeHyperReward();
            
        //remove reward from pot
        loopChest = loopChest.sub(_reward);
            
        //put timer back to 1 hours (+1 hour of hyperspeed)
        timer = now.add(HYPERSPEED_LENGTH.mul(2));
            
        //give player his reward
        playerBalance[msg.sender] = playerBalance[msg.sender].add(_reward);
        
        //set driver as the starter
        driver = starter;
        
        //set lastHijack to reset miles count to 0 (easier on frontend)
        lastHijack = now;
            
        emit JumpedOut(msg.sender, _reward);
    }
    
    // TradeMile
    // Exchanges player miles for part of the pot
    
    function TradeMile() public {
        require(mile[msg.sender] >= MILE_REQ, "not enough miles for a reward");
        require(msg.sender != starter, "starter isn't allowed to trade miles");
        require(msg.sender != driver, "can't trade miles while driver");
        
        //divide player miles by req
		uint256 _mile = mile[msg.sender].div(MILE_REQ);
		
		//can't get more than 20% of the pot at once
		if(_mile > 20){
		    _mile = 20;
		}
        
        //calculate reward
        uint256 _reward = ComputeMileReward(_mile);
        
        //remove reward from pot
        loopChest = loopChest.sub(_reward);
        
        //lower player miles by amount spent
        mile[msg.sender] = mile[msg.sender].sub(_mile.mul(MILE_REQ));
        
        //give player his reward
        playerBalance[msg.sender] = playerBalance[msg.sender].add(_reward);
        
        emit TradedMile(msg.sender, _reward, _mile);
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
    // Feeds the slugBank
    
    function() public payable {
        slugBank = slugBank.add(msg.value);
        
        emit BoostedPot(msg.sender, msg.value);
    }
    
    //-- VIEW --

    // ComputeHyperReward
    // Returns ETH reward for driving in hyperspeed
    // Reward = HYPERSPEED_LENGTH - (timer - now) * 0.01% * loopchest
    // 0.01% = /10000
    // This will throw before we're in hyperspeed, so account for that in frontend
    
    function ComputeHyperReward() public view returns(uint256) {
        uint256 _remainder = timer.sub(now);
        return HYPERSPEED_LENGTH.sub(_remainder).mul(loopChest).div(10000);
    }

    // ComputeSlugCost
    // Returns ETH required to buy one slug
    // 1 slug = (S_C_FLOOR + (loopchest / DIV_SLUG_COST)) / loop 
    // On hatch, add 1 to loop
    
    function ComputeSlugCost(bool _isBuy) public view returns(uint256) {
        if(_isBuy == true){
            return (SLUG_COST_FLOOR.add(loopChest.div(DIV_SLUG_COST))).div(loop);
        } else {
            return (SLUG_COST_FLOOR.add(loopChest.div(DIV_SLUG_COST))).div(loop.add(1));
        }
    }
    
    // ComputeBuy
    // Returns slugs bought for a given amount of ETH
    // True = buy, false = hatch
    
    function ComputeBuy(uint256 _ether, bool _isBuy) public view returns(uint256) {
        uint256 _slugCost;
        if(_isBuy == true){
            _slugCost = ComputeSlugCost(true);
        } else {
            _slugCost = ComputeSlugCost(false);
        }
        return _ether.div(_slugCost);
    }
    
    // ComputeDiv
    // Returns unclaimed divs for a player
    
    function ComputeDiv(address _player) public view returns(uint256) {
        //Calculate share of player
        uint256 _playerShare = divPerSlug.mul(slugNest[_player]);
		
        //Subtract already claimed divs
    	_playerShare = _playerShare.sub(claimedDiv[_player]);
        return _playerShare;
    }
    
    // ComputeSpeed
    // Returns current speed
    // speed = maxspeed - ((timer - _time - 1 hour) / accelFactor)
    
    function ComputeSpeed(uint256 _time) public view returns(uint256) {
        
        //check we're not in hyperspeed
        if(timer > _time.add(HYPERSPEED_LENGTH)){
            
            //check we're not more than 7 days away from end
            if(timer.sub(_time) < RACE_TIMER_START){
                return MAX_SPEED.sub((timer.sub(_time).sub(HYPERSPEED_LENGTH)).div(ACCEL_FACTOR));
            } else {
                return MIN_SPEED; //more than 7 days away
            }
        } else {
            return MAX_SPEED; //hyperspeed
        }
    }
    
    // ComputeMileDriven
    // Returns miles driven during this driver session
    
    function ComputeMileDriven() public view returns(uint256) {
        uint256 _speedThen = ComputeSpeed(lastHijack);
        uint256 _speedNow = ComputeSpeed(now);
        uint256 _timeDriven = now.sub(lastHijack);
        uint256 _averageSpeed = (_speedNow.add(_speedThen)).div(2);
        return _timeDriven.mul(_averageSpeed).div(HYPERSPEED_LENGTH);
    }
    
    // ComputeMileReward
    // Returns ether reward for a given multiplier of the req
    
    function ComputeMileReward(uint256 _reqMul) public view returns(uint256) {
        return _reqMul.mul(loopChest).div(100);
    }
    
    // GetNest
    // Returns player slugs
    
    function GetNest(address _player) public view returns(uint256) {
        return slugNest[_player];
    }
    
    // GetMile
    // Returns player mile
    
    function GetMile(address _player) public view returns(uint256) {
        return mile[_player];
    }
    
    // GetBalance
    // Returns player balance
    
    function GetBalance(address _player) public view returns(uint256) {
        return playerBalance[_player];
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