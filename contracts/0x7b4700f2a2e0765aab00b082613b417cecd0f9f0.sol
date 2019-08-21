pragma solidity ^0.4.5;

contract PPBC_API {

   /*******************************************************************************
        PADDYPOWER.BLOCKCHAIN Promo Concept/Proposal, RFP Response / PoC
        Module PPBC_API - back-end module
        
        [private API],  v1.22, 2016 11 27 
        $Id: add rcs tag $
        
        vendor presentation/  @TowerRoom, 12/12/16 10am
        
        @MC/KC - Refer to instructions at PP Tech Vendor Portal
        
        Abstract: Blockchain Contract API Demo, providing access to 3:5 and 2:5 betting odds 
        (3:5 for FIRST bet only, 2:5 for consecutive bets)
        
   ********************************************************************************/

   // Do not invoke contract directly (API code protected), only via main PPBC contract
   //       ToDo: protect API with passcode/hash

    // declare variables
    address paddyAdmin;          // contract owner          
    uint256 public gamesPlayed;  // Game Counter
    
    mapping ( address => bool ) alreadyPlayed; // Ensure every user can only play ONCE using the 3:5 odds
                                               // to prevent abuse of benef. odds.
                                               // Consecutive games from the same account only run at 2:5 odds.

    /* GetMinimumBet_ether()  ToDo: add doc @MC*/
    /* GetMaximumBet_ether()  ToDo: add doc @MC*/
    // Minimum/Maximum Bet (in ETHER) that can be placed: 1 ether - 10% of available Ether Winning Pool       
    function GetMinimumBet_Ether() constant returns (uint256){ return 1;   }
    function GetMaximumBet_Ether() constant returns (uint256){ return GetMaximumBet() / 1000000000000000000;  } 
    function GetMinimumBet() returns (uint256) { return 1 ether; }   // Minimum Bet that can be placed: 1 ether       
    function GetMaximumBet() returns (uint256) { return this.balance/10; }   // Maximum Bet that can be placed: 10% of available Ether Winning Pool        

    /* PlaceBet using Access Code, and Mode parameter */
    /********************************************************************
        First game for any account will run at 3:5 odds (double win).
        Consecutive  game for any account will run at 2:5 odds (double win).

        Cannot be invoked directly, only via PaddyPowerPromo contract     MC
        
        Parameters:
        - Access Code is SHA3 hashed code, provided by PaddyPowerPromo contract (prevents direct call).
    *******************************************************************************************/
    
    function _api_PlaceBet () payable {
    //function _api_PlaceBet (uint256 accessCode, bool modeA) payable {
        //
        // Note total transaction cost ~ 100-200K Gas    
        // START Initial checks
        // use Sha3 for increased API security (cannot be "converted back" to original accessCode) - prevents direct access
        // if ( sha3( accessCode ) != 19498834600303040700126754596537880312193431075463488515213744382615666721600) throw; 
        // @MC disabled access check for PoC, ToDo: enable for Prod release, and allow change of hash if compromised
        
        // Check if Bet amount is within limits 1 ether to 10% of winning pool (account) balance
        if (msg.value < GetMinimumBet() || (msg.value + 1) > GetMaximumBet() ) throw; 
        
        // Only allow x games per block - to ensure outcome is as random as possible
        uint256 cntBlockUsed = blockUsed[block.number];  
        if (cntBlockUsed > maxGamesPerBlock) throw; 
        blockUsed[block.number] = cntBlockUsed + 1; 
          
        gamesPlayed++;            // game counter
        lastPlayer = msg.sender;  // remember last player, part of seed for random number generator
        // END initial checks
        
        // START - Set winning odds
        uint winnerOdds = 3;  // 3 out of 5 win (for first game)
        uint totalPartition  = 5;  
        
        if (alreadyPlayed[msg.sender]){  // has user played before? then odds are 2:5, not 3:5
            winnerOdds = 2; 
        }
        
        alreadyPlayed[msg.sender] = true; // remember that user has already played for next time
        
        // expand partitions to % (minimizes rounding), calculate winning change in % (x out of 100)
        winnerOdds = winnerOdds * 20;  // 3*20 = 60% winning chance, or 2*20 = 40% winning chance
        totalPartition = totalPartition * 20;    // 5*20 = 100%
        // END - Set winning odds
        
        // Create new random number
        uint256 random = createRandomNumber(totalPartition); // creates a random number between 0 and 99

        // check if user won
        if (random <= winnerOdds ){
            if (!msg.sender.send(msg.value * 2)) // winner double
                throw; // roll back if there was an error
        }
        // GAME FINISHED.
    }


      ///////////////////////////////////////////////
     // Random Number Generator
    //////////////////////////////////////////////

    address lastPlayer;
    uint256 private seed1;
    uint256 private seed2;
    uint256 private seed3;
    uint256 private seed4;
    uint256 private seed5;
    uint256 private lastBlock;
    uint256 private lastRandom;
    uint256 private lastGas;
    uint256 private customSeed;
    
    function createRandomNumber(uint maxnum) payable returns (uint256) {
        uint cnt;
        for (cnt = 0; cnt < lastRandom % 5; cnt++){lastBlock = lastBlock - block.timestamp;} // randomize gas
        uint256 random = 
                  block.difficulty + block.gaslimit + 
                  block.timestamp + msg.gas + 
                  msg.value + tx.gasprice + 
                  seed1 + seed2 + seed3 + seed4 + seed5;
        random = random + uint256(block.blockhash(block.number - (lastRandom+1))[cnt]) +
                  (gamesPlayed*1234567890) * lastBlock + customSeed;
        random = random + uint256(lastPlayer) +  uint256(sha3(msg.sender)[cnt]);
        lastBlock = block.number;
        seed5 = seed4; seed4 = seed3; seed3 = seed2;
        seed2 = seed1; seed1 = (random / 43) + lastRandom; 
        bytes32 randomsha = sha3(random);
        lastRandom = (uint256(randomsha[cnt]) * maxnum) / 256;
        
        return lastRandom ;
        
    }
    
    
    ///////////////////////////////////////////////
    // Maintenance    ToDo: doc @MC
    /////////////////////////////
    uint256 public maxGamesPerBlock;  // Block limit
    mapping ( uint256 => uint256 ) blockUsed;  // prevent more than X games per block; 
                                               //
    
    function PPBC_API()  { // Constructor: ToDo: obfuscate
        //initialize
        gamesPlayed = 0;
        paddyAdmin = msg.sender;
        lastPlayer = msg.sender;
        seed1 = 2; seed2 = 3; seed3 = 5; seed4 = 7; seed5 = 11;
        lastBlock = 0;
        customSeed = block.number;
        maxGamesPerBlock = 3;
    }
    
    modifier onlyOwner {
        if (msg.sender != paddyAdmin) throw;
        _;
    }

    function _maint_withdrawFromPool (uint256 amt) onlyOwner{ // balance to stay below approved limit / comply with regulation
            if (!paddyAdmin.send(amt)) throw;
    }
    
    function () payable onlyOwner { // default function, used by PaddyAdmin to deposit into winning pool, only owner can do this
    }
    
    function _maint_EndPromo () onlyOwner {
         selfdestruct(paddyAdmin); 
    }

    function _maint_setBlockLimit (uint256 n_limit) onlyOwner {
         maxGamesPerBlock = n_limit;
    }
    
    function _maint_setCustomSeed(uint256 newSeed) onlyOwner {
        customSeed = newSeed;
    }
    
    function _maint_updateOwner (address newOwner) onlyOwner {
        paddyAdmin = newOwner;
    }
    
}