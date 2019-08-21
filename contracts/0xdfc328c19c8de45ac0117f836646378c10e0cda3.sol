pragma solidity ^0.4.8;

contract WinMatrix
 {
   function getCoeff(uint16 n) external returns (uint256);
   function getBetsProcessed() external constant returns (uint16);
 }

contract SmartRouletteToken 
{
   function emission(address player, address partner, uint256 value_bet, uint256 coef_player, uint256 coef_partner) external returns(uint256, uint8);
   function isOperationBlocked() external constant returns (bool);
}

contract SmartAffiliate 
{   
   function getAffiliateInfo(address player) external constant returns(address affiliate, uint16 coef_affiliate, uint16 coef_player);
}

/*
** User interface for SmartRoulette https://smartroulette.io
*/
contract SmartRoulette
{
  address developer;
  address operator;

  // Wait BlockDelay blocks before generate random number
  uint8 BlockDelay;

  // Maximum bet value for game (one credit is currentMaxBet/256)
  uint256 currentMaxBet;    

  // maximum games count per block
  uint64 maxGamblesPerBlock;
        
  // Enable\disable to place new bets
  bool ContractState;

  // table with winner coefficients
  WinMatrix winMatrix;

  SmartRouletteToken smartToken;

  address public profitDistributionContract;

  SmartAffiliate smartAffiliateContract;

  uint16 constant maxTypeBets = 157;
  
  // Default coef for token emission (if SmartAffiliate contract is not setup)
  uint16 CoefPlayerEmission;   
  // 
  mapping (uint8 => uint8) private minCreditsOnBet;
  mapping (uint8 => uint8) private maxCreditsOnBet;

  struct GameInfo
  {
       address player;
       uint256 blockNumber;
       uint8 wheelResult;
       uint256 bets;
       bytes32 values;
       bytes32 values2;
  } 
       
  GameInfo[] private gambles;

   enum GameStatus {Success, Skipped, Stop}

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
        
        winMatrix = WinMatrix(0x073D6621E9150bFf9d1D450caAd3c790b6F071F2);
        if (winMatrix.getBetsProcessed() != maxTypeBets) throw;
        
        smartToken = SmartRouletteToken(0xcced5b8288086be8c38e23567e684c3740be4d48);

        currentMaxBet = 2560 finney; // 2.56 ether
        BlockDelay = 1;        
        maxGamblesPerBlock = 5;        
        ContractState  = true;  
        bankrolLimit = 277 ether;
        profitLimit  = 50 ether;
        CoefPlayerEmission = 100; // default 1%
   }

   function changeSettings(uint256 newMaxBet, uint8 newBlockDelay) public onlyDeveloper 
   {             
      BlockDelay = newBlockDelay;
      // rounds to 2 digts
      newMaxBet = newMaxBet / 2560000000000000000 * 2560000000000000000;  
      if (newMaxBet != currentMaxBet) 
      {
        currentMaxBet = newMaxBet;
        SettingsChanged();
      }
   }

   uint256 bankrolLimit;
   uint256 profitLimit;
   uint256 lastDistributedProfit;
   uint256 lastDateDistributedProfit;
   
   function getDistributeProfitsInfo() public constant returns (uint256 lastProfit, uint256 lastDate)
   {
      lastProfit = lastDistributedProfit;
      lastDate = lastDateDistributedProfit;
   }

   function setProfitDistributionContract(address contractAddress) onlyDeveloper
   {
      if (profitDistributionContract > 0) throw;
      profitDistributionContract = contractAddress;
   }

   function setSmartAffiliateContract(address contractAddress) onlyDeveloper
   {
      if (address(smartAffiliateContract) > 0) throw;
      smartAffiliateContract = SmartAffiliate(contractAddress);
   }

   function distributeProfits(uint256 gasValue) onlyDeveloperOrOperator
   {
      if (profitDistributionContract > 0 && this.balance >= (bankrolLimit+profitLimit))
      {
         uint256 diff = this.balance - bankrolLimit;
         if (address(profitDistributionContract).call.gas(gasValue).value(diff)() == false) throw;
         lastDistributedProfit = diff;
         lastDateDistributedProfit = block.timestamp;
      }      
   }

   function getTokenSettings() public constant returns(uint16 Coef_player, uint256 BankrolLimit, uint256 ProfitLimit)
   {
      Coef_player = CoefPlayerEmission;      
      BankrolLimit = bankrolLimit;
      ProfitLimit = profitLimit;
   }

   function changeTokenSettings(uint16 newCoef_player, uint256 newBankrolLimit, uint256 newProfitLimit) onlyDeveloper
   {
      CoefPlayerEmission  = newCoef_player;      
      bankrolLimit = newBankrolLimit;
      profitLimit  = newProfitLimit;
   }

   function changeMinBet(uint8[157] value) onlyDeveloper
   {
     // value[i] == 0 means skip this value
     // value[i] == 255 means value will be 0
     // Raw mapping minCreditsOnBet changes from 0 to 254, 
     // when compare with real bet we add +1, so min credits changes from 1 to 255
     for(var i=0;i<157;i++) 
     {
        if (value[i] > 0) 
        {
           if (value[i] == 255)
             minCreditsOnBet[i] = 0;     
           else  
             minCreditsOnBet[i] = value[i];
        }
     }
     SettingsChanged();
   }

   function changeMaxBet(uint8[157] value) onlyDeveloper
   {
     // value[i] == 0 means skip this value
     // value[i] == 255 means value will be 0
     // Raw mapping maxCreditsOnBet hold values that reduce max bet from 255 to 0     
     // If we want to calculate real max bet value we should do: 256 - maxCreditsOnBet[i]
     // example: if mapping holds 0 it means, that max bet will be 256 - 0 = 256
     //          if mapping holds 50 it means, that max bet will be 256 - 50 = 206 
     for(var i=0;i<157;i++) 
     {
       if (value[i] > 0) 
       {
          if (value[i] == 255)
             maxCreditsOnBet[i] = 0;     
           else  
             maxCreditsOnBet[i] = 255 - value[i];              
       }
     }
     SettingsChanged();
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
   function getBetValue(bytes32 values, uint8 n, uint8 nBit) private constant returns (uint256)
   {
        // bet in credits (1..256) 
        uint256 bet = uint256(values[32 - n]) + 1;

        if (bet < uint256(minCreditsOnBet[nBit]+1)) throw;   //default: bet < 0+1
        if (bet > uint256(256-maxCreditsOnBet[nBit])) throw; //default: bet > 256-0      

        return currentMaxBet * bet / 256;        
   }

   // n - number player bet
   // nBit - betIndex
   function getBetValueByGamble(GameInfo memory gamble, uint8 n, uint8 nBit) private constant returns (uint256) 
   {
      if (n <= 32) return getBetValue(gamble.values , n, nBit);
      if (n <= 64) return getBetValue(gamble.values2, n - 32, nBit);
      // there are 64 maximum unique bets (positions) in one game
      throw;
   }
  
   function totalGames() constant returns (uint256)
   {
       return gambles.length;
   }
   
   function getSettings() constant returns(uint256 maxBet, uint256 oneCredit, uint8[157] _minCreditsOnBet, uint8[157] _maxCreditsOnBet, uint8 blockDelay, bool contractState)
    {
        maxBet    = currentMaxBet;
        oneCredit = currentMaxBet / 256; 
        blockDelay = BlockDelay;      
        for(var i = 0;i < maxTypeBets;i++)  
        {
          _minCreditsOnBet[i] = minCreditsOnBet[i] + 1;
          _maxCreditsOnBet[i] = 255 - maxCreditsOnBet[i];
        }     
        contractState        = ContractState;
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

    event PlayerBet(uint256 gambleId, uint256 playerTokens);
    event EndGame(address player, uint8 result, uint256 gambleId);
    event SettingsChanged();
    event ErrorLog(address player, string message);
    event GasLog(string msg, uint256 level, uint256 gas);

   function totalBetValue(GameInfo memory g) private constant returns (uint256)
   {              
       uint256 totalBetsValue = 0; 
       uint8 nPlayerBetNo = 0;
       uint8 betsCount = uint8(bytes32(g.bets)[0]);

       for(uint8 i = 0; i < maxTypeBets;i++) 
        if (isBitSet(g.bets, i))
        {
          totalBetsValue += getBetValueByGamble(g, nPlayerBetNo+1, i);
          nPlayerBetNo++;

          if (betsCount == 1) break;
          betsCount--;          
        }

       return totalBetsValue;
   }

   function totalBetCount(GameInfo memory g) private constant returns (uint256)
   {              
       uint256 totalBets = 0; 
       for(uint8 i=0; i < maxTypeBets;i++) 
        if (isBitSet(g.bets, i)) totalBets++;          
       return totalBets;   
   }

   function placeBet(uint256 bets, bytes32 values1,bytes32 values2) public payable
   {
       if (ContractState == false)
       {
         ErrorLog(msg.sender, "ContractDisabled");
         if (msg.sender.send(msg.value) == false) throw;
         return;
       }

       var gamblesLength = gambles.length;

       if (gamblesLength > 0)
       {
          uint8 gamblesCountInCurrentBlock = 0;
          for(var i = gamblesLength - 1;i > 0; i--)
          {
            if (gambles[i].blockNumber == block.number) 
            {
               if (gambles[i].player == msg.sender)
               {
                   ErrorLog(msg.sender, "Play twice the same block");
                   if (msg.sender.send(msg.value) == false) throw;
                   return;
               }

               gamblesCountInCurrentBlock++;
               if (gamblesCountInCurrentBlock >= maxGamblesPerBlock)
               {
                  ErrorLog(msg.sender, "maxGamblesPerBlock");
                  if (msg.sender.send(msg.value) == false) throw;
                  return;
               }
            }
            else
            {
               break;
            }
          }
       }
       
       var _currentMaxBet = currentMaxBet;

       if (msg.value < _currentMaxBet/256 || bets == 0)
       {
          ErrorLog(msg.sender, "Wrong bet value");
          if (msg.sender.send(msg.value) == false) throw;
          return;
       }

       if (msg.value > _currentMaxBet)
       {
          ErrorLog(msg.sender, "Limit for table");
          if (msg.sender.send(msg.value) == false) throw;
          return;
       }

       GameInfo memory g = GameInfo(msg.sender, block.number, 37, bets, values1,values2);

       if (totalBetValue(g) != msg.value)
       {
          ErrorLog(msg.sender, "Wrong bet value");
          if (msg.sender.send(msg.value) == false) throw;
          return;
       }       

       address affiliate = 0;
       uint16 coef_affiliate = 0;
       uint16 coef_player;
       if (address(smartAffiliateContract) > 0)
       {        
         (affiliate, coef_affiliate, coef_player) = smartAffiliateContract.getAffiliateInfo(msg.sender);   
       }
       else
       {
         coef_player = CoefPlayerEmission;
       }

       uint256 playerTokens;
       uint8 errorCodeEmission;
       
       (playerTokens, errorCodeEmission) = smartToken.emission(msg.sender, affiliate, msg.value, coef_player, coef_affiliate);
       if (errorCodeEmission != 0)
       {
          if (errorCodeEmission == 1) 
            ErrorLog(msg.sender, "token operations stopped");
          else if (errorCodeEmission == 2) 
            ErrorLog(msg.sender, "contract is not in a games list");
          else if (errorCodeEmission == 3) 
            ErrorLog(msg.sender, "incorect player address");
          else if (errorCodeEmission == 4) 
            ErrorLog(msg.sender, "incorect value bet");
          else if (errorCodeEmission == 5) 
            ErrorLog(msg.sender, "incorect Coefficient emissions");
          
          if (msg.sender.send(msg.value) == false) throw;
          return;
       }

       gambles.push(g);

       PlayerBet(gamblesLength, playerTokens); 
   }

    function Invest() payable onlyDeveloper
    {      
    }

    function GetGameIndexesToProcess() public constant returns (uint256[64] gameIndexes)
    {           
      uint8 index = 0;
      for(int256 i = int256(gambles.length) - 1;i >= 0;i--)
      {      
         GameInfo memory g = gambles[uint256(i)];
         if (block.number - g.blockNumber >= 256) break;

         if (g.wheelResult == 37 && block.number >= g.blockNumber + BlockDelay)
         { 
            gameIndexes[index++] = uint256(i + 1);
         }
      }      
    }

    uint256 lastBlockGamesProcessed;

    function ProcessGames(uint256[] gameIndexes, bool simulate) 
    {
      if (!simulate)
      {
         if (lastBlockGamesProcessed == block.number)  return;
         lastBlockGamesProcessed = block.number;
      }

      uint8 delay = BlockDelay;
      uint256 length = gameIndexes.length;
      bool success = false;
      for(uint256 i = 0;i < length;i++)
      {      
         if (ProcessGame(gameIndexes[i], delay) == GameStatus.Success) success = true;         
      }      
      if (simulate && !success) throw;
    }
    
    function ProcessGameExt(uint256 index) public returns (GameStatus)
    {
      return ProcessGame(index, BlockDelay);
    }

    function ProcessGame(uint256 index, uint256 delay) private returns (GameStatus)
    {            
      GameInfo memory g = gambles[index];
      if (block.number - g.blockNumber >= 256) return GameStatus.Stop;

      if (g.wheelResult == 37 && block.number > g.blockNumber + delay)
      {            
         gambles[index].wheelResult = getRandomNumber(g.player, g.blockNumber);
                 
         uint256 playerWinnings = getGameResult(gambles[index]);
         if (playerWinnings > 0) 
         {
            if (g.player.send(playerWinnings) == false) throw;
         }

         EndGame(g.player, gambles[index].wheelResult, index);
         return GameStatus.Success;
      }

      return GameStatus.Skipped;
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
      GameInfo memory gamble = gambles[gambleId];
      if (gamble.wheelResult != 200) throw;

      gambles[gambleId].wheelResult = calculateRandomNumberByBlockhash(blockHash, gamble.player);      

      uint256 playerWinnings = getGameResult(gambles[gambleId]);
      if (playerWinnings > 0)
      {
        if (gamble.player.send(playerWinnings) == false) throw;
      }      

      EndGame(gamble.player, gamble.wheelResult, gambleId);
    }


    function preliminaryGameResult(uint64 gambleIndex) constant returns (uint64 gambleId, address player, uint256 blockNumber, uint256 totalWin, uint8 wheelResult, uint256 bets, uint256 values1, uint256 values2, uint256 nTotalBetValue, uint256 nTotalBetCount) 
    { 
      GameInfo memory g = gambles[uint256(gambleIndex)];
      
      if (g.wheelResult == 37 && block.number > g.blockNumber + BlockDelay)
      {
         gambles[gambleIndex].wheelResult = getRandomNumber(g.player, g.blockNumber);
         return getGame(gambleIndex);
      }
      throw;      
    }

    // Preliminary game result before real transaction is mined
    function calcRandomNumberAndGetPreliminaryGameResult(uint256 blockHash, uint64 gambleIndex) constant returns (uint64 gambleId, address player, uint256 blockNumber, uint256 totalWin, uint8 wheelResult, uint256 bets, uint256 values1, uint256 values2, uint256 nTotalBetValue, uint256 nTotalBetCount)
    { 
      GameInfo memory g = gambles[uint256(gambleIndex)];      
      g.wheelResult = calculateRandomNumberByBlockhash(blockHash, g.player);      

      gambleId = gambleIndex;
      player = g.player;
      wheelResult = g.wheelResult;      
      totalWin = getGameResult(g);
      blockNumber = g.blockNumber;              
      nTotalBetValue = totalBetValue(g);
      nTotalBetCount = totalBetCount(g);
      bets = g.bets;
      values1 = uint256(g.values);
      values2 = uint256(g.values2);     
    }

    function getGameResult(GameInfo memory game) private constant returns (uint256 totalWin) 
    {
        totalWin = 0;
        uint8 nPlayerBetNo = 0;
        // we sent count bets at last byte 
        uint8 betsCount = uint8(bytes32(game.bets)[0]); 
        for(uint8 i=0; i<maxTypeBets; i++)
        {                      
            if (isBitSet(game.bets, i))
            {              
              var winMul = winMatrix.getCoeff(getIndex(i, game.wheelResult)); // get win coef
              if (winMul > 0) winMul++; // + return player bet
              totalWin += winMul * getBetValueByGamble(game, nPlayerBetNo+1,i);
              nPlayerBetNo++; 

              if (betsCount == 1) break;
              betsCount--;
            }
        }        
    }

    function getGame(uint64 index) constant returns (uint64 gambleId, address player, uint256 blockNumber, uint256 totalWin, uint8 wheelResult, uint256 bets, uint256 values1, uint256 values2, uint256 nTotalBetValue, uint256 nTotalBetCount) 
    {
        gambleId = index;
        player = gambles[index].player;
        totalWin = getGameResult(gambles[index]);
        blockNumber = gambles[index].blockNumber;        
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