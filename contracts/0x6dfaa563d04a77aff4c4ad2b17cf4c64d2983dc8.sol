//                       , ; ,   .-'"""'-.   , ; ,
//                       \\|/  .'          '.  \|//
//                        \-;-/   ()   ()   \-;-/
//                        // ;               ; \\
//                       //__; :.         .; ;__\\
//                      `-----\'.'-.....-'.'/-----'
//                             '.'.-.-,_.'.'
//                               '(  (..-'
//                                 '-'
//   WHYSOS3RIOUS   PRESENTS :   
//   The ROULETH 
//
//  Play the Roulette on ethereum blockchain !
//  (or become an investor in the Casino and share the profits/losses.) 
//
//
//   website : www.WhySoS3rious.com/Rouleth
//               with a flashy roulette :) !
//
//   check latest contract version on website
//   V 1.0.2
//
// *** coded by WhySoS3rious, 2016.                                       ***//
// *** please do not copy without authorization                          ***//
// *** contact : reddit    /u/WhySoS3rious                               ***//
//
//
//  Stake : Variable, check on website for the max bet.
//  At launch the max stake is 0.05 ETH
//
//
//  How to play ?
//  1) Simplest (via transactions from your wallet, not an exchange) : 
//  Just send the value you want to bet to the contract and add enough gas 
//  (you can enter the max gas amount of ~4,5Million, any excess is refunded anyways)
//  This will by default place a bet on number 7
//  Wait 2 minutes (6 blocks) and send (with enough gas) 1 wei (or any amount, it will be refunded)
//  This will spin the wheel and you will receive * 35 your bet if you win.
//  Don't wait more than 200 blocks before you spin the wheel or your bet will expire.
//
//  2) Advanced (via contract functions, e.g. Mist, cf. tutorial on my website for more details) :
//  Import the contract in Mist wallet using the code of the ABI (link on my website)
//  Use the functions (betOnNumber, betOnColor ...) to place any type of bet you want
//  Provide the appropriate input (ex: check box Red or Black)
//  add the amount you want to bet.
//  wait 6 blocks, then use the function spinTheWheel, this will solve the bet.
//  You can only place one bet at a time before you spin the wheel.
//  Don't wait more than 200 blocks before you spin the wheel or your bet will expire.
//
//
//
//  Use the website to track your bets and the results of the spins
//
//
//   How to invest ?
//   Import the contract in Mist Wallet using the code of the ABI (link on my website)
//   Use the Invest function with an amount >10 Ether (can change, check on my website)
//   You will become an investor and share the profits and losses of the roulette
//   proportionally to your investment. There is a 2% fee on investment to help with the server/website
//   cost and also 2% on profit that go to the developper.
//   The rest of your investment goes directly to the payroll and 98% of profits are shared between 
//   investors relatively to their share of total. Losses are split similarly.
//   You can withdraw your funds at any time after the initial lock period (set to 1 week)
//   To withdraw use the function withdraw and specify the amoutn you want to withdraw in Wei.
//   If your withdraw brings your investment under 10 eth (the min invest, subject to change)
//   then you will execute a full withdraw and stop being an investor.
//   Check your current investor balance in Mist by using the information functions on the left side
//   If you want to update the balances to the last state (otherwise they are automatically
//   updated after each invest or withdraw), you can use the function manualUpdateBalances in Mist.
//   
//   The casino should be profitable in the long run (with 99% confidence). 
//   The maximum bet allowed has been computed through statistical analysis to yield high confidence 
//   in the long run survival of the casino. The maximum bet is always smaller than the current payroll 
//   of the casino * 35 (max pay multiplier) * casinoStatisticalLimit (statistical sample size that allows 
//   to have enough confidence in survival, set at 20 at start, should increase to 200 when we have more 
//   investors to increase the safety).
//   
//   At start there is a limit of 50 investors (can be changed via settings up to 150)
//   If there is no open position and you want to invest, you can try to buyout a current investor.
//   To buyout, you have to invest more than any investor whose funds are unlocked (after 1 week grace lock period)
//   If there are no remaining open position and all investors are under grace period, it is not possible to 
//   become a new investor in the casino.
//
//   At any time an investor can add funds to his investment with the withdraw function.
//   Doing so will refresh the lock period and secure your position.
//
//
//   A provably fair roulette :  note on Random Number Generation.
//   The roulette result is based on the hash of the 6th block after the player commits his bet.
//   This guarantees a provably fair roulette with equiprobable results and non predictable
//   unless someone has more computing power than all the Ethereum Network.
//   Yet Miners could try to exploit their position in 2 ways.
//   First they could try to mine 7 blocks in a row (to commit their bet based on result for a sure win),
//   but this is highly improbable and not predictible.
//   Second they could commit a bet, then wait 6 blocks and hope that they will be the one forming the 
//   block on which their commited bet depends. If this is the case and the hash they find is not a
//   winning one, they could decide to not share the block with the network but would lose 5 ether.
//   To counter this potential miner edge (=base win proba + (miner proba to find block)*base win proba )
//   we keep wager amounts far smaller than 5 Eth so that the miner prefers to get his block reward than cheat.
//   Note that a miner could place several bets on the same block to increase his potential profit from dropping a block
//   For this reason we limit the number of bets per block to 2 at start (configurable later if needed).
contract Rouleth
{

    //Variables, Structure
    address developer;
    uint8 blockDelay; //nb of blocks to wait before spin
    uint8 blockExpiration; //nb of blocks before bet expiration (due to hash storage limits)
    uint256 maxGamble; //max gamble value manually set by config
    uint maxBetsPerBlock; //limits the number of bets per blocks to prevent miner cheating
    uint nbBetsCurrentBlock; //counts the nb of bets in the block
    uint casinoStatisticalLimit;
    //Current gamble value possibly lower than config (<payroll/(20*35))
    uint256 currentMaxGamble; 
    //Gambles
    struct Gamble
    {
	address player;
        bool spinned; //Was the rouleth spinned ?
	bool win;
	BetTypes betType; //number/color/dozen/oddeven
	uint8 input; //stores number, color, dozen or oddeven
	uint256 wager;
	uint256 blockNumber; //block of bet -1
        uint8 wheelResult;
    }
    Gamble[] private gambles;
    uint firstActiveGamble; //pointer to track the first non spinned and non expired gamble.
    //Tracking progress of players
    mapping (address=>uint) gambleIndex; //current gamble index of the player
    enum Status {waitingForBet, waitingForSpin} Status status; //gamble status
    mapping (address=>Status) playerStatus; //progress of the player's gamble

    //**********************************************
    //        Management & Config FUNCTIONS        //
    //**********************************************
	function  Rouleth() private //creation settings
    { 
        developer = msg.sender;
        blockDelay=6; //delay to wait between bet and spin
	blockExpiration=200; //delay after which gamble expires
        maxGamble=50 finney; //0.05 ether as max bet to start (payroll of 35 eth)
        maxBetsPerBlock=2; // limit of 2 bets per block, to prevent multiple bets per miners (to keep max reward<5ETH)
        casinoStatisticalLimit=20;
    }
	
    modifier onlyDeveloper() {
	    if (msg.sender!=developer) throw;
	    _
    }
	
	function changeDeveloper(address new_dev)
        noEthSent
	    onlyDeveloper
	{
		developer=new_dev;
	}


    //Activate, Deactivate Betting
    enum States{active, inactive} States private state;
	function disableBetting()
    noEthSent
	onlyDeveloper
	{
            state=States.inactive;
	}
	function enableBetting()
	onlyDeveloper
        noEthSent
	{
            state=States.active;
	}
    
	modifier onlyActive
    {
        if (state==States.inactive) throw;
        _
    }

         //Change some settings within safety bounds
	function changeSettings(uint newCasinoStatLimit, uint newMaxBetsBlock, uint256 newMaxGamble, uint8 newMaxInvestor, uint256 newMinInvestment, uint256 newLockPeriod, uint8 newBlockDelay, uint8 newBlockExpiration)
	noEthSent
	onlyDeveloper
	{
	        // changes the statistical multiplier that guarantees the long run casino survival
	        if (newCasinoStatLimit<20) throw;
	        casinoStatisticalLimit=newCasinoStatLimit;
	        //Max number of bets per block to prevent miner cheating
	        maxBetsPerBlock=newMaxBetsBlock;
                //MAX BET : limited by payroll/(casinoStatisticalLimit*35) for statiscal confidence in longevity of casino
		if (newMaxGamble<=0 || newMaxGamble>=this.balance/(20*35)) throw; 
		else { maxGamble=newMaxGamble; }
                //MAX NB of INVESTORS (can only increase and max of 149)
                if (newMaxInvestor<setting_maxInvestors || newMaxInvestor>149) throw;
                else { setting_maxInvestors=newMaxInvestor;}
                //MIN INVEST : 
                setting_minInvestment=newMinInvestment;
                //Invest LOCK PERIOD
                if (setting_lockPeriod>5184000) throw; //2 months max
                setting_lockPeriod=newLockPeriod;
		        //Delay before roll :
		if (blockDelay<1) throw;
		        blockDelay=newBlockDelay;
                updateMaxBet();
		if (newBlockExpiration<100) throw;
		blockExpiration=newBlockExpiration;
	}
 

    //**********************************************
    //                 BETTING FUNCTIONS                    //
    //**********************************************

//***//basic betting without Mist or contract call
    //activates when the player only sends eth to the contract
    //without specifying any type of bet.
    function () 
   {
       //if player is not playing : bet on 7
       if (playerStatus[msg.sender]==Status.waitingForBet)  betOnNumber(7);
       //if player is already playing, spin the wheel
       else spinTheWheel();
    } 

    function updateMaxBet() private
    {
    //check that maxGamble setting is still within safety bounds
        if (payroll/(casinoStatisticalLimit*35) > maxGamble) 
		{ 
			currentMaxGamble=maxGamble;
                }
	else
		{ 
			currentMaxGamble = payroll/(20*35);
		}
     }

//***//Guarantees that gamble is under (statistical) safety limits for casino survival.
    function checkBetValue() private returns(uint256 playerBetValue)
    {
        updateMaxBet();
		if (msg.value > currentMaxGamble) //if above max, send difference back
		{
		    msg.sender.send(msg.value-currentMaxGamble);
		    playerBetValue=currentMaxGamble;
		}
                else
                { playerBetValue=msg.value; }
       }


    //check number of bets in block (to prevent miner cheating and keep max reward per block <5ETH)
    modifier checkNbBetsCurrentBlock()
    {
        if (gambles.length!=0 && block.number==gambles[gambles.length-1].blockNumber) nbBetsCurrentBlock+=1;
        else nbBetsCurrentBlock=0;
        if (nbBetsCurrentBlock>=maxBetsPerBlock) throw;
        _
    }
    //check that the player is not playing already (unless it has expired)
    modifier checkWaitingForBet{
        //if player is already in gamble
        if (playerStatus[msg.sender]!=Status.waitingForBet)
        {
             //case not expired
             if (gambles[gambleIndex[msg.sender]].blockNumber+blockExpiration>block.number) throw;
             //case expired
             else
             {
                  //add bet to PL and reset status
                  solveBet(msg.sender, 255, false, 0) ;

              }
        }
	_
	}

    //Possible bet types
    enum BetTypes{ number, color, parity, dozen, column, lowhigh} BetTypes private initbetTypes;

    function updateStatusPlayer() private
    expireGambles
    {
	playerStatus[msg.sender]=Status.waitingForSpin;
	gambleIndex[msg.sender]=gambles.length-1;
     }

//***//bet on Number	
    function betOnNumber(uint8 numberChosen)
    checkWaitingForBet
    onlyActive
    checkNbBetsCurrentBlock
    {
        //check that number chosen is valid and records bet
        if (numberChosen>36) throw;
		//check that wager is under limit
        uint256 betValue= checkBetValue();
	    gambles.push(Gamble(msg.sender, false, false, BetTypes.number, numberChosen, betValue, block.number, 37));
        updateStatusPlayer();
    }

//***// function betOnColor
	//bet type : color
	//input : 0 for red
	//input : 1 for black
    function betOnColor(bool Red, bool Black)
    checkWaitingForBet
    onlyActive
    checkNbBetsCurrentBlock
    {
        uint8 count;
        uint8 input;
        if (Red) 
        { 
             count+=1; 
             input=0;
         }
        if (Black) 
        {
             count+=1; 
             input=1;
         }
        if (count!=1) throw;
	//check that wager is under limit
        uint256 betValue= checkBetValue();
	    gambles.push(Gamble(msg.sender, false, false, BetTypes.color, input, betValue, block.number, 37));
        updateStatusPlayer();
    }

//***// function betOnLow_High
	//bet type : lowhigh
	//input : 0 for low
	//input : 1 for low
    function betOnLowHigh(bool Low, bool High)
    checkWaitingForBet
    onlyActive
    checkNbBetsCurrentBlock
    {
        uint8 count;
        uint8 input;
        if (Low) 
        { 
             count+=1; 
             input=0;
         }
        if (High) 
        {
             count+=1; 
             input=1;
         }
        if (count!=1) throw;
	//check that wager is under limit
        uint256 betValue= checkBetValue();
	gambles.push(Gamble(msg.sender, false, false, BetTypes.lowhigh, input, betValue, block.number, 37));
        updateStatusPlayer();
    }

//***// function betOnOdd_Even
	//bet type : parity
     //input : 0 for even
    //input : 1 for odd
    function betOnOddEven(bool Odd, bool Even)
    checkWaitingForBet
    onlyActive
    checkNbBetsCurrentBlock
    {
        uint8 count;
        uint8 input;
        if (Even) 
        { 
             count+=1; 
             input=0;
         }
        if (Odd) 
        {
             count+=1; 
             input=1;
         }
        if (count!=1) throw;
	//check that wager is under limit
        uint256 betValue= checkBetValue();
	gambles.push(Gamble(msg.sender, false, false, BetTypes.parity, input, betValue, block.number, 37));
        updateStatusPlayer();
    }


//***// function betOnDozen
//     //bet type : dozen
//     //input : 0 for first dozen
//     //input : 1 for second dozen
//     //input : 2 for third dozen
    function betOnDozen(bool First, bool Second, bool Third)
    checkWaitingForBet
    onlyActive
    checkNbBetsCurrentBlock
    {
         betOnColumnOrDozen(First,Second,Third, BetTypes.dozen);
    }


// //***// function betOnColumn
//     //bet type : column
//     //input : 0 for first column
//     //input : 1 for second column
//     //input : 2 for third column
    function betOnColumn(bool First, bool Second, bool Third)
    checkWaitingForBet
    onlyActive
    checkNbBetsCurrentBlock
    {
         betOnColumnOrDozen(First, Second, Third, BetTypes.column);
     }

    function betOnColumnOrDozen(bool First, bool Second, bool Third, BetTypes bet) private
    { 
        uint8 count;
        uint8 input;
        if (First) 
        { 
             count+=1; 
             input=0;
         }
        if (Second) 
        {
             count+=1; 
             input=1;
         }
        if (Third) 
        {
             count+=1; 
             input=2;
         }
        if (count!=1) throw;
	//check that wager is under limit
        uint256 betValue= checkBetValue();
	    gambles.push(Gamble(msg.sender, false, false, bet, input, betValue, block.number, 37));
        updateStatusPlayer();
    }

    //**********************************************
    // Spin The Wheel & Check Result FUNCTIONS//
    //**********************************************

	event Win(address player, uint8 result, uint value_won);
	event Loss(address player, uint8 result, uint value_loss);

    //check that player has to spin the wheel
    modifier checkWaitingForSpin{
        if (playerStatus[msg.sender]!=Status.waitingForSpin) throw;
	_
	}
    //Prevents accidental sending of Eth when you shouldn't
    modifier noEthSent()
    {
        if (msg.value>0) msg.sender.send(msg.value);
        _
    }

//***//function to spin
    function spinTheWheel()
    checkWaitingForSpin
    noEthSent
    {
        //check that the player waited for the delay before spin
        //and also that the bet is not expired (200 blocks limit)
	uint playerblock = gambles[gambleIndex[msg.sender]].blockNumber;
	if (block.number<playerblock+blockDelay || block.number>playerblock+blockExpiration) throw;
    else
	{
	    uint8 wheelResult;
        //Spin the wheel, Reset player status and record result
		wheelResult = uint8(uint256(block.blockhash(playerblock+blockDelay))%37);
		gambles[gambleIndex[msg.sender]].wheelResult=wheelResult;
        //check result against bet and pay if win
		checkBetResult(wheelResult, gambles[gambleIndex[msg.sender]].betType);
		updateFirstActiveGamble(gambleIndex[msg.sender]);
	}
    }

function updateFirstActiveGamble(uint bet_id) private
     {
         if (bet_id==firstActiveGamble)
         {   
              uint index;
              if (firstActiveGamble!=0) index=firstActiveGamble-1;
              while (true)
              {
                 if (index<gambles.length && gambles[index].spinned)
                 {
                     index=index+1;
                 }
                 else {break; }
               }
              firstActiveGamble=index;
              return;
          }
 }
	
//checks if there are expired gambles
modifier expireGambles{
    if (  (gambles.length!=0 && gambles.length-1>=firstActiveGamble ) 
          && gambles[firstActiveGamble].blockNumber + blockExpiration <= block.number && !gambles[firstActiveGamble].spinned )  
    { 
	solveBet(gambles[firstActiveGamble].player, 255, false, 0);
        updateFirstActiveGamble(firstActiveGamble);
    }
        _
}
	

     //CHECK BETS FUNCTIONS private
     function checkBetResult(uint8 result, BetTypes betType) private
     {
          //bet on Number
          if (betType==BetTypes.number) checkBetNumber(result);
          else if (betType==BetTypes.parity) checkBetParity(result);
          else if (betType==BetTypes.color) checkBetColor(result);
	 else if (betType==BetTypes.lowhigh) checkBetLowhigh(result);
	 else if (betType==BetTypes.dozen) checkBetDozen(result);
	else if (betType==BetTypes.column) checkBetColumn(result);
          updateMaxBet(); 
     }

     // function solve Bet once result is determined : sends to winner, adds loss to profit
     function solveBet(address player, uint8 result, bool win, uint8 multiplier) private
     {
        playerStatus[msg.sender]=Status.waitingForBet;
        gambles[gambleIndex[player]].spinned=true;
	uint bet_v = gambles[gambleIndex[player]].wager;
            if (win)
            {
		  gambles[gambleIndex[player]].win=true;
		  uint win_v = multiplier*bet_v;
                  player.send(win_v);
                  lossSinceChange+=win_v-bet_v;
		  Win(player, result, win_v);
             }
            else
            {
		Loss(player, result, bet_v);
                profitSinceChange+=bet_v;
            }

      }


     // checkbeton number(input)
    // bet type : number
    // input : chosen number
     function checkBetNumber(uint8 result) private
     {
            bool win;
            //win
	    if (result==gambles[gambleIndex[msg.sender]].input)
	    {
                  win=true;  
             }
             solveBet(msg.sender, result,win,35);
     }


     // checkbet on oddeven
    // bet type : parity
    // input : 0 for even, 1 for odd
     function checkBetParity(uint8 result) private
     {
            bool win;
            //win
	    if (result%2==gambles[gambleIndex[msg.sender]].input && result!=0)
	    {
                  win=true;                
             }
             solveBet(msg.sender,result,win,2);
        
     }
	
     // checkbet on lowhigh
     // bet type : lowhigh
     // input : 0 low, 1 high
     function checkBetLowhigh(uint8 result) private
     {
            bool win;
            //win
		 if (result!=0 && ( (result<19 && gambles[gambleIndex[msg.sender]].input==0)
			 || (result>18 && gambles[gambleIndex[msg.sender]].input==1)
			 ) )
	    {
                  win=true;
             }
             solveBet(msg.sender,result,win,2);
     }

     // checkbet on color
     // bet type : color
     // input : 0 red, 1 black
      uint[18] red_list=[1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36];
      function checkBetColor(uint8 result) private
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
                && ( (gambles[gambleIndex[msg.sender]].input==0 && red)  
                || ( gambles[gambleIndex[msg.sender]].input==1 && !red)  ) )
             {
                  win=true;
             }
             solveBet(msg.sender,result,win,2);
       }

     // checkbet on dozen
     // bet type : dozen
     // input : 0 first, 1 second, 2 third
     function checkBetDozen(uint8 result) private
     { 
            bool win;
            //win on first dozen
     		 if ( result!=0 &&
                      ( (result<13 && gambles[gambleIndex[msg.sender]].input==0)
     			||
                     (result>12 && result<25 && gambles[gambleIndex[msg.sender]].input==1)
                    ||
                     (result>24 && gambles[gambleIndex[msg.sender]].input==2) ) )
     	    {
                   win=true;                
             }
             solveBet(msg.sender,result,win,3);
     }

     // checkbet on column
     // bet type : column
     // input : 0 first, 1 second, 2 third
      function checkBetColumn(uint8 result) private
      {
             bool win;
             //win
             if ( result!=0
                && ( (gambles[gambleIndex[msg.sender]].input==0 && result%3==1)  
                || ( gambles[gambleIndex[msg.sender]].input==1 && result%3==2)
                || ( gambles[gambleIndex[msg.sender]].input==2 && result%3==0)  ) )
             {
                  win=true;
             }
             solveBet(msg.sender,result,win,3);
      }


//INVESTORS FUNCTIONS


//total casino payroll
    uint256 payroll;
//Profit Loss since last investor change
    uint256 profitSinceChange;
    uint256 lossSinceChange;
//investor struct array (hard capped to 150)
    uint8 setting_maxInvestors = 50;
    struct Investor
    {
	    address investor;
	    uint256 time;
    }	
	Investor[150] private investors ;
    //Balances of the investors
    mapping (address=>uint256) balance; 
    //Investor lockPeriod
    //lock time to avoid invest and withdraw for refresh only
    //also time during which you cannot be outbet by a new investor if it is full
    uint256 setting_lockPeriod=604800 ; //1 week in sec
    uint256 setting_minInvestment=10 ether; //min amount to send when using invest()
    //if full and unlocked position, indicates the cheapest amount to outbid
    //otherwise cheapestUnlockedPosition=255
    uint8 cheapestUnlockedPosition; 
    uint256 minCurrentInvest; 
    //record open position index
    // =255 if full
    uint8 openPosition;
	
    event newInvest(address player, uint invest_v);


     function invest()
     {
          // check that min 10 ETH is sent (variable setting)
          if (msg.value<setting_minInvestment) throw;
          // check if already investor
          bool alreadyInvestor;
          // reset the position counters to values out of bounds
          openPosition=255;
          cheapestUnlockedPosition=255;
          minCurrentInvest=10000000000000000000000000;//
          // update balances before altering the investor shares
          updateBalances();
          // loop over investor's array to find if already investor, 
          // or openPosition and cheapest UnlockedPosition
          for (uint8 k = 0; k<setting_maxInvestors; k++)
          { 
               //captures an index of an open position
               if (investors[k].investor==0) openPosition=k; 
               //captures if already an investor 
               else if (investors[k].investor==msg.sender)
               {
                    investors[k].time=now; //refresh time invest
                    alreadyInvestor=true;
                }
               //captures the index of the investor with the min investment (after lock period)
               else if (investors[k].time+setting_lockPeriod<now && balance[investors[k].investor]<minCurrentInvest && investors[k].investor!=developer)
               {
                    cheapestUnlockedPosition=k;
                    minCurrentInvest=balance[investors[k].investor];
                }
           }
           //case New investor
           if (alreadyInvestor==false)
           {
                    //case : investor array not full, record new investor
                    if (openPosition!=255) investors[openPosition]=Investor(msg.sender, now);
                    //case : investor array full
                    else
                    {
                         //subcase : investor has not outbid or all positions under lock period
                         if (msg.value<=minCurrentInvest || cheapestUnlockedPosition==255) throw;
                         //subcase : investor outbid, record investor change and refund previous
                         else
                         {
                              address previous = investors[cheapestUnlockedPosition].investor;
                              if (previous.send(balance[previous])==false) throw;
                              balance[previous]=0;
                              investors[cheapestUnlockedPosition]=Investor(msg.sender, now);
                          }
                     }
            }
          //add investment to balance of investor and to payroll

          uint256 maintenanceFees=2*msg.value/100; //2% maintenance fees
          uint256 netInvest=msg.value - maintenanceFees;
          newInvest(msg.sender, netInvest);
          balance[msg.sender]+=netInvest; //add invest to balance
          payroll+=netInvest;
          //send maintenance fees to developer 
          if (developer.send(maintenanceFees)==false) throw;
          updateMaxBet();
      }

//***// Withdraw function (only after lockPeriod)
    // input : amount to withdraw in Wei (leave empty for full withdraw)
    // if your withdraw brings your balance under the min investment required,
    // your balance is fully withdrawn
	event withdraw(address player, uint withdraw_v);
	
    function withdrawInvestment(uint256 amountToWithdrawInWei)
    noEthSent
    {
        //before withdraw, update balances of the investors with the Profit and Loss sinceChange
        updateBalances();
	//check that amount requested is authorized  
	if (amountToWithdrawInWei>balance[msg.sender]) throw;
        //retrieve investor ID
        uint8 investorID=255;
        for (uint8 k = 0; k<setting_maxInvestors; k++)
        {
               if (investors[k].investor==msg.sender)
               {
                    investorID=k;
                    break;
               }
        }
           if (investorID==255) throw; //stop if not an investor
           //check if investment lock period is over
           if (investors[investorID].time+setting_lockPeriod>now) throw;
           //if balance left after withdraw is still above min investment accept partial withdraw
           if (balance[msg.sender]-amountToWithdrawInWei>=setting_minInvestment && amountToWithdrawInWei!=0)
           {
               balance[msg.sender]-=amountToWithdrawInWei;
               payroll-=amountToWithdrawInWei;
               //send amount to investor (with security if transaction fails)
               if (msg.sender.send(amountToWithdrawInWei)==false) throw;
	       withdraw(msg.sender, amountToWithdrawInWei);
           }
           else
           //if amountToWithdraw=0 : user wants full withdraw
           //if balance after withdraw is < min invest, withdraw all and delete investor
           {
               //send amount to investor (with security if transaction fails)
               uint256 fullAmount=balance[msg.sender];
               payroll-=fullAmount;
               balance[msg.sender]=0;
               if (msg.sender.send(fullAmount)==false) throw;
               //delete investor
               delete investors[investorID];
   	       withdraw(msg.sender, fullAmount);
            }
          updateMaxBet();
     }

//***// updates balances with Profit Losses when there is a withdraw/deposit of investors

	function manualUpdateBalances()
	expireGambles
	noEthSent
	{
	    updateBalances();
	}
    function updateBalances() private
    {
         //split Profits
         uint256 profitToSplit;
         uint256 lossToSplit;
         if (profitSinceChange==0 && lossSinceChange==0)
         { return; }
         
         else
         {
             // Case : Global profit (more win than losses)
             // 2% fees for developer on global profit (if profit>loss)
             if (profitSinceChange>lossSinceChange)
             {
                profitToSplit=profitSinceChange-lossSinceChange;
                uint256 developerFees=profitToSplit*2/100;
                profitToSplit-=developerFees;
                if (developer.send(developerFees)==false) throw;
             }
             else
             {
                lossToSplit=lossSinceChange-profitSinceChange;
             }
         
         //share the loss and profits between all invest 
         //(proportionnaly. to each investor balance)
         uint totalShared;
             for (uint8 k=0; k<setting_maxInvestors; k++)
             {
                 address inv=investors[k].investor;
                 if (inv==0) continue;
                 else
                 {
                       if (profitToSplit!=0) 
                       {
                           uint profitShare=(profitToSplit*balance[inv])/payroll;
                           balance[inv]+=profitShare;
                           totalShared+=profitShare;
                       }
                       if (lossToSplit!=0) 
                       {
                           uint lossShare=(lossToSplit*balance[inv])/payroll;
                           balance[inv]-=lossShare;
                           totalShared+=lossShare;
                           
                       }
                 }
             }
          // update payroll
          if (profitToSplit !=0) 
          {
              payroll+=profitToSplit;
              balance[developer]+=profitToSplit-totalShared;
          }
          if (lossToSplit !=0) 
          {
              payroll-=lossToSplit;
              balance[developer]-=lossToSplit-totalShared;
          }
          profitSinceChange=0; //reset Profit;
          lossSinceChange=0; //reset Loss ;
          
          }
     }
     
     
     //INFORMATION FUNCTIONS
     
     function checkProfitLossSinceInvestorChange() constant returns(uint profit, uint loss)
     {
        profit=profitSinceChange;
        loss=lossSinceChange;
        return;
     }

    function checkInvestorBalance(address investor) constant returns(uint balanceInWei)
    {
          balanceInWei=balance[investor];
          return;
     }

    function getInvestorList(uint index) constant returns(address investor, uint endLockPeriod)
    {
          investor=investors[index].investor;
          endLockPeriod=investors[index].time+setting_lockPeriod;
          return;
    }
	

	function investmentEntryCost() constant returns(bool open_position, bool unlocked_position, uint buyout_amount, uint investLockPeriod)
	{
		if (openPosition!=255) open_position=true;
		if (cheapestUnlockedPosition!=255) 
		{
			unlocked_position=true;
			buyout_amount=minCurrentInvest;
		}
		investLockPeriod=setting_lockPeriod;
		return;
	}
	
	function getSettings() constant returns(uint maxBet, uint8 blockDelayBeforeSpin)
	{
	    maxBet=currentMaxGamble;
	    blockDelayBeforeSpin=blockDelay;
	    return ;
	}

	function getFirstActiveDuel() constant returns(uint _firstActiveGamble)
	{
            _firstActiveGamble=firstActiveGamble;
	    return ;
	}

	
    function checkMyBet(address player) constant returns(Status player_status, BetTypes bettype, uint8 input, uint value, uint8 result, bool wheelspinned, bool win, uint blockNb)
    {
          player_status=playerStatus[player];
          bettype=gambles[gambleIndex[player]].betType;
          input=gambles[gambleIndex[player]].input;
          value=gambles[gambleIndex[player]].wager;
          result=gambles[gambleIndex[player]].wheelResult;
          wheelspinned=gambles[gambleIndex[player]].spinned;
          win=gambles[gambleIndex[player]].win;
	blockNb=gambles[gambleIndex[player]].blockNumber;
	  return;
     }

} //end of contract