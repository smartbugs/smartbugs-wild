pragma solidity ^0.4.8;

contract Rouleth
{
  //Game and Global Variables, Structure of gambles
  address public developer;
  uint8 public blockDelay; //nb of blocks to wait before spin
  uint8 public blockExpiration; //nb of blocks before bet expiration (due to hash storage limits)
  uint256 public maxGamble; //max gamble value manually set by config
  uint256 public minGamble; //min gamble value manually set by config
  uint public maxBetsPerBlock; //limits the number of bets per blocks to prevent miner cheating
  uint nbBetsCurrentBlock; //counts the nb of bets in the block

    
  //Gambles
  enum BetTypes{number, color, parity, dozen, column, lowhigh} 
  struct Gamble
  {
    address player;
    bool spinned; //Was the rouleth spinned ?
    bool win;
    //Possible bet types
    BetTypes betType;
    uint8 input; //stores number, color, dozen or oddeven
    uint256 wager;
    uint256 blockNumber; //block of bet
    uint256 blockSpinned; //block of spin
    uint8 wheelResult;
  }
  Gamble[] private gambles;
  uint public totalGambles; 
  //Tracking progress of players
  mapping (address=>uint) gambleIndex; //current gamble index of the player
  //records current status of player
  enum Status {waitingForBet, waitingForSpin} mapping (address=>Status) playerStatus; 


  //**********************************************
  //        Management & Config FUNCTIONS        //
  //**********************************************

  function  Rouleth() //creation settings
  { 
    developer = msg.sender;
    blockDelay=0; //indicates which block after bet will be used for RNG
    blockExpiration=200; //delay after which gamble expires
    minGamble=50 finney; //configurable min bet
    maxGamble=750 finney; //configurable max bet
    maxBetsPerBlock=5; // limit of bets per block, to prevent multiple bets per miners
  }
    
  modifier onlyDeveloper() 
  {
    if (msg.sender!=developer) throw;
    _;
  }

  function addBankroll()
    onlyDeveloper
    payable {
  }

  function removeBankroll(uint256 _amount_wei)
    onlyDeveloper
  {
    if (!developer.send(_amount_wei)) throw;
  }
    
  function changeDeveloper_only_Dev(address new_dev)
    onlyDeveloper
  {
    developer=new_dev;
  }


  //Activate, Deactivate Betting
  enum States{active, inactive} States private contract_state;
    
  function disableBetting_only_Dev()
    onlyDeveloper
  {
    contract_state=States.inactive;
  }


  function enableBetting_only_Dev()
    onlyDeveloper
  {
    contract_state=States.active;

  }
    
  modifier onlyActive()
  {
    if (contract_state==States.inactive) throw;
    _;
  }



  //Change some settings within safety bounds
  function changeSettings_only_Dev(uint newMaxBetsBlock, uint256 newMinGamble, uint256 newMaxGamble, uint8 newBlockDelay, uint8 newBlockExpiration)
    onlyDeveloper
  {
    //Max number of bets per block to prevent miner cheating
    maxBetsPerBlock=newMaxBetsBlock;
    //MAX BET : limited by payroll/(casinoStatisticalLimit*35)
    if (newMaxGamble<newMinGamble) throw;  
    maxGamble=newMaxGamble; 
    minGamble=newMinGamble;
    //Delay before spin :
    blockDelay=newBlockDelay;
    if (newBlockExpiration < blockDelay + 250) throw;
    blockExpiration=newBlockExpiration;
  }


  //**********************************************
  //                 BETTING FUNCTIONS                    //
  //**********************************************

  //***//basic betting without Mist or contract call
  //activates when the player only sends eth to the contract
  //without specifying any type of bet.
  function ()
    payable
    {
      //defaut bet : bet on red
      betOnColor(false);
    } 

  //***//Guarantees that gamble is under max bet and above min.
  // returns bet value
  function checkBetValue() private returns(uint256)
  {
    uint256 playerBetValue;
    if (msg.value < minGamble) throw;
    if (msg.value > maxGamble){
      playerBetValue = maxGamble;
    }
    else{
      playerBetValue=msg.value;
    }
    return playerBetValue;
  }


  //check number of bets in block (to prevent miner cheating)
  modifier checkNbBetsCurrentBlock()
  {
    if (gambles.length!=0 && block.number==gambles[gambles.length-1].blockNumber) nbBetsCurrentBlock+=1;
    else nbBetsCurrentBlock=0;
    if (nbBetsCurrentBlock>=maxBetsPerBlock) throw;
    _;
  }


  //Function record bet called by all others betting functions
  function placeBet(BetTypes betType_, uint8 input_) private
  {
    if (playerStatus[msg.sender]!=Status.waitingForBet)
      {
	SpinTheWheel(msg.sender);
      }
    //Once this is done, we can record the new bet
    playerStatus[msg.sender]=Status.waitingForSpin;
    gambleIndex[msg.sender]=gambles.length;
    totalGambles++;
    //adapts wager to casino limits
    uint256 betValue = checkBetValue();
    gambles.push(Gamble(msg.sender, false, false, betType_, input_, betValue, block.number, 0, 37)); //37 indicates not spinned yet
    //refund excess bet (at last step vs re-entry)
    if (betValue < msg.value) 
      {
	if (msg.sender.send(msg.value-betValue)==false) throw;
      }
  }


  //***//bet on Number	
  function betOnNumber(uint8 numberChosen)
    payable
    onlyActive
    checkNbBetsCurrentBlock
  {
    //check that number chosen is valid and records bet
    if (numberChosen>36) throw;
    placeBet(BetTypes.number, numberChosen);
  }

  //***// function betOnColor
  //bet type : color
  //input : 0 for red
  //input : 1 for black
  function betOnColor(bool Black)
    payable
    onlyActive
    checkNbBetsCurrentBlock
  {
    uint8 input;
    if (!Black) 
      { 
	input=0;
      }
    else{
      input=1;
    }
    placeBet(BetTypes.color, input);
  }

  //***// function betOnLow_High
  //bet type : lowhigh
  //input : 0 for low
  //input : 1 for low
  function betOnLowHigh(bool High)
    payable
    onlyActive
    checkNbBetsCurrentBlock
  {
    uint8 input;
    if (!High) 
      { 
	input=0;
      }
    else 
      {
	input=1;
      }
    placeBet(BetTypes.lowhigh, input);
  }

  //***// function betOnOddEven
  //bet type : parity
  //input : 0 for even
  //input : 1 for odd
  function betOnOddEven(bool Odd)
    payable
    onlyActive
    checkNbBetsCurrentBlock
  {
    uint8 input;
    if (!Odd) 
      { 
	input=0;
      }
    else{
      input=1;
    }
    placeBet(BetTypes.parity, input);
  }

  //***// function betOnDozen
  //     //bet type : dozen
  //     //input : 0 for first dozen
  //     //input : 1 for second dozen
  //     //input : 2 for third dozen
  function betOnDozen(uint8 dozen_selected_0_1_2)
    payable
    onlyActive
    checkNbBetsCurrentBlock
  {
    if (dozen_selected_0_1_2 > 2) throw;
    placeBet(BetTypes.dozen, dozen_selected_0_1_2);
  }


  // //***// function betOnColumn
  //     //bet type : column
  //     //input : 0 for first column
  //     //input : 1 for second column
  //     //input : 2 for third column
  function betOnColumn(uint8 column_selected_0_1_2)
    payable
    onlyActive
    checkNbBetsCurrentBlock
  {
    if (column_selected_0_1_2 > 2) throw;
    placeBet(BetTypes.column, column_selected_0_1_2);
  }

  //**********************************************
  // Spin The Wheel & Check Result FUNCTIONS//
  //**********************************************

  event Win(address player, uint8 result, uint value_won, bytes32 bHash, bytes32 sha3Player, uint gambleId, uint bet);
  event Loss(address player, uint8 result, uint value_loss, bytes32 bHash, bytes32 sha3Player, uint gambleId, uint bet);

  //***//function to spin callable
  // no eth allowed
  function spinTheWheel(address spin_for_player)
  {
    SpinTheWheel(spin_for_player);
  }


  function SpinTheWheel(address playerSpinned) private
  {
    if (playerSpinned==0)
      {
	playerSpinned=msg.sender;         //if no index spins for the sender
      }

    //check that player has to spin
    if (playerStatus[playerSpinned]!=Status.waitingForSpin) throw;
    //redundent double check : check that gamble has not been spinned already
    if (gambles[gambleIndex[playerSpinned]].spinned==true) throw;
    //check that the player waited for the delay before spin
    //and also that the bet is not expired
    uint playerblock = gambles[gambleIndex[playerSpinned]].blockNumber;
    //too early to spin
    if (block.number<=playerblock+blockDelay) throw;
    //too late, bet expired, player lost
    else if (block.number>playerblock+blockExpiration)  solveBet(playerSpinned, 255, false, 1, 0, 0) ;
    //spin !
    else
      {
	uint8 wheelResult;
	//Spin the wheel, 
	bytes32 blockHash= block.blockhash(playerblock+blockDelay);
	//security check that the Hash is not empty
	if (blockHash==0) throw;
	// generate the hash for RNG from the blockHash and the player's address
	bytes32 shaPlayer = sha3(playerSpinned, blockHash, this);
	// get the final wheel result
	wheelResult = uint8(uint256(shaPlayer)%37);
	//check result against bet and pay if win
	checkBetResult(wheelResult, playerSpinned, blockHash, shaPlayer);
      }
  }
    

  //CHECK BETS FUNCTIONS private
  function checkBetResult(uint8 result, address player, bytes32 blockHash, bytes32 shaPlayer) private
  {
    BetTypes betType=gambles[gambleIndex[player]].betType;
    //bet on Number
    if (betType==BetTypes.number) checkBetNumber(result, player, blockHash, shaPlayer);
    else if (betType==BetTypes.parity) checkBetParity(result, player, blockHash, shaPlayer);
    else if (betType==BetTypes.color) checkBetColor(result, player, blockHash, shaPlayer);
    else if (betType==BetTypes.lowhigh) checkBetLowhigh(result, player, blockHash, shaPlayer);
    else if (betType==BetTypes.dozen) checkBetDozen(result, player, blockHash, shaPlayer);
    else if (betType==BetTypes.column) checkBetColumn(result, player, blockHash, shaPlayer);
  }

  // function solve Bet once result is determined : sends to winner, adds loss to profit
  function solveBet(address player, uint8 result, bool win, uint8 multiplier, bytes32 blockHash, bytes32 shaPlayer) private
  {
    //Update status and record spinned
    playerStatus[player]=Status.waitingForBet;
    gambles[gambleIndex[player]].wheelResult=result;
    gambles[gambleIndex[player]].spinned=true;
    gambles[gambleIndex[player]].blockSpinned=block.number;
    uint bet_v = gambles[gambleIndex[player]].wager;
	
    if (win)
      {
	gambles[gambleIndex[player]].win=true;
	uint win_v = (multiplier-1)*bet_v;
	Win(player, result, win_v, blockHash, shaPlayer, gambleIndex[player], bet_v);
	//send win!
	//safe send vs potential callstack overflowed spins
	if (player.send(win_v+bet_v)==false) throw;
      }
    else
      {
	Loss(player, result, bet_v-1, blockHash, shaPlayer, gambleIndex[player], bet_v);
	//send 1 wei to confirm spin if loss
	if (player.send(1)==false) throw;
      }

  }

  // checkbeton number(input)
  // bet type : number
  // input : chosen number
  function checkBetNumber(uint8 result, address player, bytes32 blockHash, bytes32 shaPlayer) private
  {
    bool win;
    //win
    if (result==gambles[gambleIndex[player]].input)
      {
	win=true;  
      }
    solveBet(player, result,win,36, blockHash, shaPlayer);
  }


  // checkbet on oddeven
  // bet type : parity
  // input : 0 for even, 1 for odd
  function checkBetParity(uint8 result, address player, bytes32 blockHash, bytes32 shaPlayer) private
  {
    bool win;
    //win
    if (result%2==gambles[gambleIndex[player]].input && result!=0)
      {
	win=true;                
      }
    solveBet(player,result,win,2, blockHash, shaPlayer);
  }
    
  // checkbet on lowhigh
  // bet type : lowhigh
  // input : 0 low, 1 high
  function checkBetLowhigh(uint8 result, address player, bytes32 blockHash, bytes32 shaPlayer) private
  {
    bool win;
    //win
    if (result!=0 && ( (result<19 && gambles[gambleIndex[player]].input==0)
		       || (result>18 && gambles[gambleIndex[player]].input==1)
		       ) )
      {
	win=true;
      }
    solveBet(player,result,win,2, blockHash, shaPlayer);
  }

  // checkbet on color
  // bet type : color
  // input : 0 red, 1 black
  uint[18] red_list=[1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36];
  function checkBetColor(uint8 result, address player, bytes32 blockHash, bytes32 shaPlayer) private
  {
    bool red;
    //check if red
    for (uint8 k; k<18; k++)
      { 
	if (red_list[k]==result) 
	  { 
	    red=true; 
	    break;
	  }
      }
    bool win;
    //win
    if ( result!=0
	 && ( (gambles[gambleIndex[player]].input==0 && red)  
	      || ( gambles[gambleIndex[player]].input==1 && !red)  ) )
      {
	win=true;
      }
    solveBet(player,result,win,2, blockHash, shaPlayer);
  }

  // checkbet on dozen
  // bet type : dozen
  // input : 0 first, 1 second, 2 third
  function checkBetDozen(uint8 result, address player, bytes32 blockHash, bytes32 shaPlayer) private
  { 
    bool win;
    //win on first dozen
    if ( result!=0 &&
	 ( (result<13 && gambles[gambleIndex[player]].input==0)
	   ||
	   (result>12 && result<25 && gambles[gambleIndex[player]].input==1)
	   ||
	   (result>24 && gambles[gambleIndex[player]].input==2) ) )
      {
	win=true;                
      }
    solveBet(player,result,win,3, blockHash, shaPlayer);
  }

  // checkbet on column
  // bet type : column
  // input : 0 first, 1 second, 2 third
  function checkBetColumn(uint8 result, address player, bytes32 blockHash, bytes32 shaPlayer) private
  {
    bool win;
    //win
    if ( result!=0
	 && ( (gambles[gambleIndex[player]].input==0 && result%3==1)  
	      || ( gambles[gambleIndex[player]].input==1 && result%3==2)
	      || ( gambles[gambleIndex[player]].input==2 && result%3==0)  ) )
      {
	win=true;
      }
    solveBet(player,result,win,3, blockHash, shaPlayer);
  }


  function checkMyBet(address player) constant returns(Status player_status, BetTypes bettype, uint8 input, uint value, uint8 result, bool wheelspinned, bool win, uint blockNb, uint blockSpin, uint gambleID)
  {
    player_status=playerStatus[player];
    bettype=gambles[gambleIndex[player]].betType;
    input=gambles[gambleIndex[player]].input;
    value=gambles[gambleIndex[player]].wager;
    result=gambles[gambleIndex[player]].wheelResult;
    wheelspinned=gambles[gambleIndex[player]].spinned;
    win=gambles[gambleIndex[player]].win;
    blockNb=gambles[gambleIndex[player]].blockNumber;
    blockSpin=gambles[gambleIndex[player]].blockSpinned;
    gambleID=gambleIndex[player];
    return;
  }
    
  function getGamblesList(uint256 index) constant returns(address player, BetTypes bettype, uint8 input, uint value, uint8 result, bool wheelspinned, bool win, uint blockNb, uint blockSpin)
  {
    player=gambles[index].player;
    bettype=gambles[index].betType;
    input=gambles[index].input;
    value=gambles[index].wager;
    result=gambles[index].wheelResult;
    wheelspinned=gambles[index].spinned;
    win=gambles[index].win;
    blockNb=gambles[index].blockNumber;
    blockSpin=gambles[index].blockSpinned;
    return;
  }

} //end of contract