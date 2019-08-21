pragma solidity ^0.4.8;

contract WinMatrix
 {
   function getCoeff(uint16 n) external returns (uint256);
   function getBetsProcessed() external constant returns (uint16);
 }

contract SmartRoulette
{
    address developer;
    address operator;

    // Wait BlockDelay blocks before spin the wheel 
    uint8 BlockDelay;

    // Maximum bet value for game
    uint256 currentMaxBet;    

    // maximum games count per block
    uint64 maxBetsPerBlock;
    uint64 nbBetsCurrentBlock;
    
    // Enable\disable to place new bets
    bool ContractState;

    // table with winner coefficients
    WinMatrix winMatrix;

    uint16 constant maxTypeBets = 157;

    //
    uint256 private SmartRouletteLimit = 1;

   // last game index for player (used for fast access)
   mapping (address => uint64) private gambleIndex;   
   
   // 
   uint8 defaultMinCreditsOnBet; 
   //
   mapping (uint8 => uint8) private minCreditsOnBet;

   struct Gamble
   {
        address player;
        uint256 blockNumber;
        uint256 blockSpinned;
        uint8 wheelResult;
        uint256 bets;
        bytes32 values;
        bytes32 values2;
   }
       
   Gamble[] private gambles;

   enum BetTypes{number0, number1,number2,number3,number4,number5,number6,number7,number8,number9,
     number10,number11,number12,number13,number14,number15,number16,number17,number18,number19,number20,number21,
     number22,number23,number24,number25,number26,number27,number28,number29,number30,number31,number32,number33,
     number34,number35,number36, red, black, odd, even, dozen1,dozen2,dozen3, column1,column2,column3, low,high,
     pair_01, pair_02, pair_03, pair_12, pair_23, pair_36, pair_25, pair_14, pair_45, pair_56, pair_69, pair_58, pair_47,
     pair_78, pair_89, pair_912, pair_811, pair_710, pair_1011, pair_1112, pair_1215, pair_1518, pair_1617, pair_1718, pair_1720,
     pair_1619, pair_1922, pair_2023, pair_2124, pair_2223, pair_2324, pair_2528, pair_2629, pair_2730, pair_2829, pair_2930, pair_1114,
     pair_1013, pair_1314, pair_1415, pair_1316, pair_1417, pair_1821, pair_1920, pair_2021, pair_2225, pair_2326, pair_2427, pair_2526,
     pair_2627, pair_2831, pair_2932, pair_3033, pair_3132, pair_3233, pair_3134, pair_3235, pair_3336, pair_3435, pair_3536, corner_0_1_2_3,
     corner_1_2_5_4, corner_2_3_6_5, corner_4_5_8_7, corner_5_6_9_8, corner_7_8_11_10, corner_8_9_12_11, corner_10_11_14_13, corner_11_12_15_14,
     corner_13_14_17_16, corner_14_15_18_17, corner_16_17_20_19, corner_17_18_21_20, corner_19_20_23_22, corner_20_21_24_23, corner_22_23_26_25,
     corner_23_24_27_26, corner_25_26_29_28, corner_26_27_30_29, corner_28_29_32_31, corner_29_30_33_32, corner_31_32_35_34, corner_32_33_36_35,
     three_0_2_3, three_0_1_2, three_1_2_3, three_4_5_6, three_7_8_9, three_10_11_12, three_13_14_15, three_16_17_18, three_19_20_21, three_22_23_24,
     three_25_26_27, three_28_29_30, three_31_32_33, three_34_35_36, six_1_2_3_4_5_6, six_4_5_6_7_8_9, six_7_8_9_10_11_12, six_10_11_12_13_14_15,
     six_13_14_15_16_17_18, six_16_17_18_19_20_21, six_19_20_21_22_23_24, six_22_23_24_25_26_27, six_25_26_27_28_29_30, six_28_29_30_31_32_33,
     six_31_32_33_34_35_36}
   

   function SmartRoulette() internal
   {        
        developer  = msg.sender;
        operator   = msg.sender;
        
        winMatrix = WinMatrix(0xDA16251B2977F86cB8d4C3318e9c6F92D7fC1A8f);
        if (winMatrix.getBetsProcessed() != maxTypeBets) throw;

        BlockDelay = 1;        
        maxBetsPerBlock = 5;
        defaultMinCreditsOnBet = 1;   
        ContractState  = true;  
   }

   function updateMaxBet() private onlyDeveloper 
   {      
      uint256 newMaxBet = this.balance/(35*SmartRouletteLimit);

      // rounds to 2 digts
      newMaxBet = newMaxBet / 2560000000000000000 * 2560000000000000000;  
      if (newMaxBet != currentMaxBet) 
      {
        currentMaxBet = newMaxBet;
        SettingsChanged(currentMaxBet, currentMaxBet / 256,  defaultMinCreditsOnBet, minCreditsOnBet[uint8(BetTypes.low)], minCreditsOnBet[uint8(BetTypes.dozen1)], BlockDelay, ContractState);
      }
   }

   function changeSettings(uint256 NewSmartRouletteLimit, uint64 NewMaxBetsPerBlock, uint8 NewBlockDelay, uint8 MinCreditsOnBet50, uint8 MinCreditsOnBet33, uint8 NewDefaultMinCreditsOnBet) onlyDeveloper
   {
     if (NewSmartRouletteLimit > 0) SmartRouletteLimit = NewSmartRouletteLimit;

     BlockDelay = NewBlockDelay;     

     if (NewMaxBetsPerBlock != 0) maxBetsPerBlock = NewMaxBetsPerBlock;     

      if (MinCreditsOnBet50 > 0)
      {
        minCreditsOnBet[uint8(BetTypes.low)] = MinCreditsOnBet50;
        minCreditsOnBet[uint8(BetTypes.high)] = MinCreditsOnBet50;
        minCreditsOnBet[uint8(BetTypes.red)] = MinCreditsOnBet50;
        minCreditsOnBet[uint8(BetTypes.black)] = MinCreditsOnBet50;
        minCreditsOnBet[uint8(BetTypes.odd)] = MinCreditsOnBet50;
        minCreditsOnBet[uint8(BetTypes.even)] = MinCreditsOnBet50;
      }  

      if (MinCreditsOnBet33 > 0)
      {
        minCreditsOnBet[uint8(BetTypes.dozen1)] = MinCreditsOnBet33;
        minCreditsOnBet[uint8(BetTypes.dozen2)] = MinCreditsOnBet33;
        minCreditsOnBet[uint8(BetTypes.dozen3)] = MinCreditsOnBet33;
        minCreditsOnBet[uint8(BetTypes.column1)] = MinCreditsOnBet33;
        minCreditsOnBet[uint8(BetTypes.column2)] = MinCreditsOnBet33;
        minCreditsOnBet[uint8(BetTypes.column3)] = MinCreditsOnBet33;
      }

      if (NewDefaultMinCreditsOnBet > 0) defaultMinCreditsOnBet = NewDefaultMinCreditsOnBet;

     updateMaxBet();
   }
   
   function deleteContract() onlyDeveloper  
   {
        suicide(msg.sender);
   }

   // bit from 0 to 255
   function isBitSet(uint256 data, uint8 bit) private constant returns (bool ret)
   {
       assembly {
            ret := iszero(iszero(and(data, exp(2,bit))))
        }
        return ret;
   }

   // unique combination of bet and wheelResult, used for access to WinMatrix
   function getIndex(uint16 bet, uint16 wheelResult) private constant returns (uint16)
   {
      return (bet+1)*256 + (wheelResult+1);
   }

   // n form 1 <= to <= 32
   function getBetValue(bytes32 values, uint8 n) private constant returns (uint256)
   {
        // bet in credits (1..256) 
        uint256 bet = uint256(values[32-n])+1;

         // check min bet
        uint8 minCredits = minCreditsOnBet[n];
        if (minCredits == 0) minCredits = defaultMinCreditsOnBet;
        if (bet < minCredits) throw;
        
        // bet in wei
        bet = currentMaxBet*bet/256;
        if (bet > currentMaxBet) throw;         

        return bet;        
   }

   function getBetValueByGamble(Gamble gamble, uint8 n) private constant returns (uint256) 
   {
      if (n<=32) return getBetValue(gamble.values, n);
      if (n<=64) return getBetValue(gamble.values2, n-32);
      // there are 64 maximum unique bets (positions) in one game
      throw;
   }
  
   function totalGames() constant returns (uint256)
   {
       return gambles.length;
   }
   
   function getSettings() constant returns(uint256 maxBet, uint256 oneCredit, uint8 MinBetInCredits, uint8 MinBetInCredits_50,uint8 MinBetInCredits_33, uint8 blockDelayBeforeSpin, bool contractState)
    {
        maxBet=currentMaxBet;
        oneCredit=currentMaxBet / 256; 
        blockDelayBeforeSpin=BlockDelay;        
        MinBetInCredits = defaultMinCreditsOnBet;
        MinBetInCredits_50 = minCreditsOnBet[uint8(BetTypes.low)]; 
        MinBetInCredits_33 = minCreditsOnBet[uint8(BetTypes.column1)]; 
        contractState = ContractState;
        return;
    }
   
    modifier onlyDeveloper() 
    {
       if (msg.sender != developer) throw;
       _;
    }

    modifier onlyDeveloperOrOperator() 
    {
       if (msg.sender != developer && msg.sender != operator) throw;
       _;
    }

   function disableBetting_only_Dev()
    onlyDeveloperOrOperator
    {
        ContractState=false;
    }


    function changeOperator(address newOperator) onlyDeveloper
    {
       operator = newOperator;
    }

    function enableBetting_only_Dev()
    onlyDeveloperOrOperator
    {
        ContractState=true;

    }

    event PlayerBet(address player, uint256 block, uint256 gambleId);
    event EndGame(address player, uint8 result, uint256 gambleId);
    event SettingsChanged(uint256 maxBet, uint256 oneCredit, uint8 DefaultMinBetInCredits, uint8 MinBetInCredits50, uint8 MinBetInCredits33, uint8 blockDelayBeforeSpin, bool contractState);
    event ErrorLog(address player, string message);

   function totalBetValue(Gamble g) private constant returns (uint256)
   {              
       uint256 totalBetsValue = 0; 
       uint8 nPlayerBetNo = 0;
       for(uint8 i=0; i < maxTypeBets;i++) 
        if (isBitSet(g.bets, i))
        {
          totalBetsValue += getBetValueByGamble(g, nPlayerBetNo+1);
          nPlayerBetNo++;
        }

       return totalBetsValue;
   }

   function totalBetCount(Gamble g) private constant returns (uint256)
   {              
       uint256 totalBets = 0; 
       for(uint8 i=0; i < maxTypeBets;i++) 
        if (isBitSet(g.bets, i)) totalBets++;          
       return totalBets;   
   }

   function placeBet(uint256 bets, bytes32 values1,bytes32 values2)  payable
   {
       if (ContractState == false)
       {
         ErrorLog(msg.sender, "ContractDisabled");
         if (msg.sender.send(msg.value) == false) throw;
         return;
       } 

       if (nbBetsCurrentBlock >= maxBetsPerBlock) 
       {
         ErrorLog(msg.sender, "checkNbBetsCurrentBlock");
         if (msg.sender.send(msg.value) == false) throw;
         return;
       }

       if (msg.value < currentMaxBet/256 || bets == 0)
       {
          ErrorLog(msg.sender, "Wrong bet value");
          if (msg.sender.send(msg.value) == false) throw;
          return;
       }

       if (msg.value > currentMaxBet)
       {
          ErrorLog(msg.sender, "Limit for table");
          if (msg.sender.send(msg.value) == false) throw;
          return;
       }

       Gamble memory g = Gamble(msg.sender, block.number, 0, 37, bets, values1,values2);

       if (totalBetValue(g) != msg.value)
       {
          ErrorLog(msg.sender, "Wrong bet value");
          if (msg.sender.send(msg.value) == false) throw;
          return;
       }       

       uint64 index = gambleIndex[msg.sender];
       if (index != 0)
       {
          if (gambles[index-1].wheelResult == 37) 
          {
            ErrorLog(msg.sender, "previous game is not finished");
            if (msg.sender.send(msg.value) == false) throw;
            return;
          }
       }

       if (gambles.length != 0 && block.number==gambles[gambles.length-1].blockNumber) 
        nbBetsCurrentBlock++;
       else 
        nbBetsCurrentBlock = 0;

       // gambleIndex is index of gambles array + 1
       gambleIndex[msg.sender] = uint64(gambles.length + 1);

       gambles.push(g);
            
       PlayerBet(msg.sender, block.number, gambles.length - 1);
   }

    function Invest() payable
    {
      updateMaxBet();
    }

    function SpinTheWheel(address playerSpinned) 
    {
        if (playerSpinned==0){
           playerSpinned=msg.sender;
        }

        uint64 index = gambleIndex[playerSpinned];
        if (index == 0) 
        {
          ErrorLog(playerSpinned, "No games for player");
          return;
        }
        index--;        

        if (gambles[index].wheelResult != 37)
        {
          ErrorLog(playerSpinned, "Gamble already spinned");
          return;
        } 

        uint256 playerblock = gambles[index].blockNumber;
        
        if (block.number <= playerblock + BlockDelay) 
        {
          ErrorLog(msg.sender, "Wait for playerblock+blockDelay");
          return;          
        }

        gambles[index].wheelResult = getRandomNumber(gambles[index].player, playerblock);
        gambles[index].blockSpinned = block.number;
        
        if (gambles[index].player.send(getGameResult(index)) == false) throw;

        EndGame(gambles[index].player, gambles[index].wheelResult, index);        
    }

    function getRandomNumber(address player, uint256 playerblock) private returns(uint8 wheelResult)
    {
        // block.blockhash - hash of the given block - only works for 256 most recent blocks excluding current
        bytes32 blockHash = block.blockhash(playerblock+BlockDelay); 
        
        if (blockHash==0) 
        {
          ErrorLog(msg.sender, "Cannot generate random number");
          wheelResult = 200;
        }
        else
        {
          bytes32 shaPlayer = sha3(player, blockHash);
    
          wheelResult = uint8(uint256(shaPlayer)%37);
        }    
    }

    function calculateRandomNumberByBlockhash(uint256 blockHash, address player) public constant returns (uint8 wheelResult) 
    { 
          bytes32 shaPlayer = sha3(player, blockHash);
    
          wheelResult = uint8(uint256(shaPlayer)%37);
    }

    function emergencyFixGameResult(uint64 gambleId, uint256 blockHash) onlyDeveloperOrOperator
    {
      // Probably this function will never be called, but
      // if game was not spinned in 256 blocks then block.blockhash will returns always 0 and 
      // we should fix this manually (you can check result with public function calculateRandomNumberByBlockhash)
      Gamble memory gamble = gambles[gambleId];
      if (gamble.wheelResult != 200) throw;

      gambles[gambleId].wheelResult = calculateRandomNumberByBlockhash(blockHash, gamble.player);
      gambles[gambleId].blockSpinned = block.number;

      if (gamble.player.send(getGameResult(gambleId)) == false) throw;

      EndGame(gamble.player, gamble.wheelResult, gambleId);
    }

    // 
    function checkGameResult(address playerSpinned) constant returns (uint64 gambleId, address player, uint256 blockNumber, uint256 blockSpinned, uint256 totalWin, uint8 wheelResult, uint256 bets, uint256 values1, uint256 values2, uint256 nTotalBetValue, uint256 nTotalBetCount) 
    {
        if (playerSpinned==0){
           playerSpinned=msg.sender;
        }

        uint64 index = gambleIndex[playerSpinned];
        if (index == 0) throw;
        index--;        

        uint256 playerblock = gambles[index].blockNumber;        
        if (block.number <= playerblock + BlockDelay) throw;
        
        gambles[index].wheelResult = getRandomNumber(gambles[index].player, playerblock);
        gambles[index].blockSpinned = block.number;
        
        return getGame(index);      
    }

    function getGameResult(uint64 index) private constant returns (uint256 totalWin) 
    {
        Gamble memory game = gambles[index];
        totalWin = 0;
        uint8 nPlayerBetNo = 0;
        for(uint8 i=0; i<maxTypeBets; i++)
        {                      
            if (isBitSet(game.bets, i))
            {              
              var winMul = winMatrix.getCoeff(getIndex(i, game.wheelResult)); // get win coef
              if (winMul > 0) winMul++; // + return player bet
              totalWin += winMul * getBetValueByGamble(game, nPlayerBetNo+1);
              nPlayerBetNo++; 
            }
        }
        if (totalWin == 0) totalWin = 1 wei; // 1 wei if lose                      
    }

    function getGame(uint64 index) constant returns (uint64 gambleId, address player, uint256 blockNumber, uint256 blockSpinned, uint256 totalWin, uint8 wheelResult, uint256 bets, uint256 values1, uint256 values2, uint256 nTotalBetValue, uint256 nTotalBetCount) 
    {
        gambleId = index;
        player = gambles[index].player;
        totalWin = getGameResult(index);
        blockNumber = gambles[index].blockNumber;
        blockSpinned = gambles[index].blockSpinned;
        wheelResult = gambles[index].wheelResult;
        nTotalBetValue = totalBetValue(gambles[index]);
        nTotalBetCount = totalBetCount(gambles[index]);
        bets = gambles[index].bets;
        values1 = uint256(gambles[index].values);
        values2 = uint256(gambles[index].values2);        
    }

   function() 
   {
      throw;
   }
   

}