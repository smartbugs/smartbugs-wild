pragma solidity ^0.4.25;

/***********************************************************
 * Easy Smart Contract
 *  - GAIN 5.3% PER 24 HOURS (every 5900 blocks) 40 days  
 *  - GAIN 5.6% PER 24 HOURS (every 5900 blocks) 30 days  
 *  - GAIN 6.6% PER 24 HOURS (every 5900 blocks) 20 days  
 *  - GAIN 7.6% PER 24 HOURS (every 5900 blocks) 15 days  
 *  - GAIN 8.5% PER 24 HOURS (every 5900 blocks) 12 days   
 *  - GAIN 3% PER 24 HOURS (every 5900 blocks) forever  
 *  
  * How to use:
 *  1. Send any amount of ether to make an investment (The Data input 1~6 investment category, the default is 1.)
 *  2. Claim your profit by sending 0 ether transaction (every day, every week, i don't care unless you're spending too much on GAS)
 *
 *  ****** When contract balance less than 0.0001eth, Automatically enter the next round
 * 
 * RECOMMENDED GAS LIMIT: 300000
 * RECOMMENDED GAS PRICE: https://ethgasstation.info/
 * 
 * 
 *  https://www.easysmart.biz
 *  https://t.me/easy_smart
 ***********************************************************/

contract EasySmart {
    using SafeMath              for *;

    address public promoAddr_ = address(0xfCFbaFfD975B107B2Bcd58BF71DC78fBeBB6215D);

    uint256 ruleSum_ = 6;

    uint256 G_DayBlocks = 5900;
    
    uint256 public rId_ = 1;
    mapping (uint256 => ESDatasets.Round) public round_; 

    mapping (uint256 => mapping(address => uint256)) public pIDxAddr_;  
    mapping (uint256 => mapping(uint256 => ESDatasets.Player)) public player_; 
    mapping (uint256 => ESDatasets.Plan) private plan_;   
	
	function GetIdByAddr(address addr) public 
	    view returns(uint256)
	{
	    return pIDxAddr_[rId_][addr];
	}
	

	function GetPlayerByUid(uint256 uid) public 
	    view returns(uint256)
	{
	    ESDatasets.Player storage player = player_[rId_][uid];

	    return
	    (
	        player.planCount
	    );
	}
	
    function GetPlanByUid(uint256 uid) public 
	    view returns(uint256[],uint256[],uint256[],uint256[],uint256[],bool[])
	{
	    uint256[] memory planIds = new  uint256[] (player_[rId_][uid].planCount);
	    uint256[] memory startBlocks = new  uint256[] (player_[rId_][uid].planCount);
	    uint256[] memory investeds = new  uint256[] (player_[rId_][uid].planCount);
	    uint256[] memory atBlocks = new  uint256[] (player_[rId_][uid].planCount);
	    uint256[] memory payEths = new  uint256[] (player_[rId_][uid].planCount);
	    bool[] memory isCloses = new  bool[] (player_[rId_][uid].planCount);
	    
        for(uint i = 0; i < player_[rId_][uid].planCount; i++) {
	        planIds[i] = player_[rId_][uid].plans[i].planId;
	        startBlocks[i] = player_[rId_][uid].plans[i].startBlock;
	        investeds[i] = player_[rId_][uid].plans[i].invested;
	        atBlocks[i] = player_[rId_][uid].plans[i].atBlock;
	        payEths[i] = player_[rId_][uid].plans[i].payEth;
	        isCloses[i] = player_[rId_][uid].plans[i].isClose;
	    }
	    
	    return
	    (
	        planIds,
	        startBlocks,
	        investeds,
	        atBlocks,
	        payEths,
	        isCloses
	    );
	}
	
function GetPlanTimeByUid(uint256 uid) public 
	    view returns(uint256[])
	{
	    uint256[] memory startTimes = new  uint256[] (player_[rId_][uid].planCount);

        for(uint i = 0; i < player_[rId_][uid].planCount; i++) {
	        startTimes[i] = player_[rId_][uid].plans[i].startTime;
	    }
	    
	    return
	    (
	        startTimes
	    );
	}	

    constructor() public {
        plan_[1] = ESDatasets.Plan(530,40);
        plan_[2] = ESDatasets.Plan(560,30);
        plan_[3] = ESDatasets.Plan(660,20);
        plan_[4] = ESDatasets.Plan(760,15);
        plan_[5] = ESDatasets.Plan(850,12);
        plan_[6] = ESDatasets.Plan(300,0);
        
        round_[rId_].startTime = now;

    }
	
	function register_(address addr) private{
        round_[rId_].nowUserId = round_[rId_].nowUserId.add(1);
        
        address _addr = addr;
        
        pIDxAddr_[rId_][_addr] = round_[rId_].nowUserId;

        player_[rId_][round_[rId_].nowUserId].addr = _addr;
        player_[rId_][round_[rId_].nowUserId].planCount = 0;
        
	}
	
    
    // this function called every time anyone sends a transaction to this contract
    function () external payable {
        if (msg.value == 0) {
            withdraw();
        } else {
            invest();
        }
    } 	
    
    function invest() private {
	    uint256 _planId = bytesToUint(msg.data);
	    
	    if (_planId<1 || _planId > ruleSum_) {
	        _planId = 1;
	    }
        
		//get uid
		uint256 uid = pIDxAddr_[rId_][msg.sender];
		
		//first
		if (uid == 0) {
		    register_(msg.sender);
			uid = round_[rId_].nowUserId;
		}
		
        // record block number and invested amount (msg.value) of this transaction
        uint256 planCount = player_[rId_][uid].planCount;
        player_[rId_][uid].plans[planCount].planId = _planId;
        player_[rId_][uid].plans[planCount].startTime = now;
        player_[rId_][uid].plans[planCount].startBlock = block.number;
        player_[rId_][uid].plans[planCount].atBlock = block.number;
        player_[rId_][uid].plans[planCount].invested = msg.value;
        player_[rId_][uid].plans[planCount].payEth = 0;
        player_[rId_][uid].plans[planCount].isClose = false;
        
        player_[rId_][uid].planCount = player_[rId_][uid].planCount.add(1);

        round_[rId_].ethSum = round_[rId_].ethSum.add(msg.value);
        
        if (msg.value > 1000000000) {

            uint256 promoFee = (msg.value.mul(5)).div(100);
            promoAddr_.transfer(promoFee);
            
        } 
        
    }
   
	
	function withdraw() private {
	    require(msg.value == 0, "withdraw fee is 0 ether, please set the exact amount");
	    
	    uint256 uid = pIDxAddr_[rId_][msg.sender];
	    require(uid != 0, "no invest");

        for(uint i = 0; i < player_[rId_][uid].planCount; i++) {
	        if (player_[rId_][uid].plans[i].isClose) {
	            continue;
	        }

            ESDatasets.Plan plan = plan_[player_[rId_][uid].plans[i].planId];
            
            uint256 blockNumber = block.number;
            bool bClose = false;
            if (plan.dayRange > 0) {
                
                uint256 endBlockNumber = player_[rId_][uid].plans[i].startBlock.add(plan.dayRange*G_DayBlocks);
                if (blockNumber > endBlockNumber){
                    blockNumber = endBlockNumber;
                    bClose = true;
                }
            }
            
            uint256 amount = player_[rId_][uid].plans[i].invested * plan.interest / 10000 * (blockNumber - player_[rId_][uid].plans[i].atBlock) / G_DayBlocks;

            // send calculated amount of ether directly to sender (aka YOU)
            address sender = msg.sender;
            sender.send(amount);

            // record block number and invested amount (msg.value) of this transaction
            player_[rId_][uid].plans[i].atBlock = block.number;
            player_[rId_][uid].plans[i].isClose = bClose;
            player_[rId_][uid].plans[i].payEth += amount;
        }
        
        if (this.balance < 100000000000000) { //0.0001eth
            rId_ = rId_.add(1);
            round_[rId_].startTime = now;
        }
	}
	
    function bytesToUint(bytes b) private returns (uint256){
        uint256 number;
        for(uint i=0;i<b.length;i++){
            number = number + uint(b[i])*(2**(8*(b.length-(i+1))));
        }
        return number;
    }	
}

/***********************************************************
 * @title SafeMath v0.1.9
 * @dev Math operations with safety checks that throw on error
 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor
 * - added sqrt
 * - added sq
 * - added pwr 
 * - changed asserts to requires with error log outputs
 * - removed div, its useless
 ***********************************************************/
 library SafeMath {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
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
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
    
    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    
    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }
    
    /**
     * @dev x to the power of y 
     */
    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else 
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}

/***********************************************************
 * ESDatasets library
 ***********************************************************/
library ESDatasets {
    
    struct Round {
        uint256 nowUserId;
        uint256 ethSum;
        uint256 startTime;
    }
    
    struct Player {
        address addr;   // player address
        uint256 planCount;
        mapping(uint256=>PalyerPlan) plans;
    }
    
    struct PalyerPlan {
        uint256 planId;
        uint256 startTime;
        uint256 startBlock;
        uint256 invested;    //
        uint256 atBlock;    // 
        uint256 payEth;
        bool isClose;
    }

    struct Plan {
        uint256 interest;    // interest per day %%
        uint256 dayRange;    // days, 0 means No time limit
    }    
}