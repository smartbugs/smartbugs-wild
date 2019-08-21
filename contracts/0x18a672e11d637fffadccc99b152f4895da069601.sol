//                       , ; ,   .-'"""'-.   , ; ,
//                       \\|/  .'          '.  \|//
//                        \-;-/   ()   ()   \-;-/
//                        // ;               ; \\
//                       //__; :.         .; ;__\\
//                      `-----\'.'-.....-'.'/-----'
//                             '.'.-.-,_.'.'
//                               '(  (..-'
//                                 '-'
//  ROULETH 
//
//  Play the Roulette on ethereum blockchain !
//  (or become a member of Rouleth's Decentralized Organisation  and contribute to the bankroll.) 
//
//
//
//   check latest contract address version on the current website interface
//   V 2
//
//
//

contract Rouleth
{
    //Game and Global Variables, Structure of gambles
    address developer;
    uint8 blockDelay; //nb of blocks to wait before spin
    uint8 blockExpiration; //nb of blocks before bet expiration (due to hash storage limits)
    uint256 maxGamble; //max gamble value manually set by config
    uint256 minGamble; //min gamble value manually set by config
    uint maxBetsPerBlock; //limits the number of bets per blocks to prevent miner cheating
    uint nbBetsCurrentBlock; //counts the nb of bets in the block
    uint casinoStatisticalLimit; //ratio payroll and max win
    //Current gamble value possibly lower than limit auto
    uint256 currentMaxGamble; 
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
    uint totalGambles; 
    //Tracking progress of players
    mapping (address=>uint) gambleIndex; //current gamble index of the player
    //records current status of player
    enum Status {waitingForBet, waitingForSpin} mapping (address=>Status) playerStatus; 


    //**********************************************
    //        Management & Config FUNCTIONS        //
    //**********************************************

    function  Rouleth() private //creation settings
    { 
        developer = msg.sender;
        blockDelay=1; //indicates which block after bet will be used for RNG
	blockExpiration=200; //delay after which gamble expires
        minGamble=50 finney; //configurable min bet
        maxGamble=500 finney; //configurable max bet
        maxBetsPerBlock=5; // limit of bets per block, to prevent multiple bets per miners
        casinoStatisticalLimit=100; //we are targeting at least 400
    }
    
    modifier onlyDeveloper() 
    {
	if (msg.sender!=developer) throw;
	_
    }
    
    function changeDeveloper_only_Dev(address new_dev)
    noEthSent
    onlyDeveloper
    {
	developer=new_dev;
    }

    //Prevents accidental sending of Eth when you shouldn't
    modifier noEthSent()
    {
        if (msg.value>0) 
	{
	    throw;
	}
        _
    }


    //Activate, Deactivate Betting
    enum States{active, inactive} States private contract_state;
    
    function disableBetting_only_Dev()
    noEthSent
    onlyDeveloper
    {
        contract_state=States.inactive;
    }


    function enableBetting_only_Dev()
    noEthSent
    onlyDeveloper
    {
        contract_state=States.active;

    }
    
    modifier onlyActive()
    {
        if (contract_state==States.inactive) throw;
        _
    }



    //Change some settings within safety bounds
    function changeSettings_only_Dev(uint newCasinoStatLimit, uint newMaxBetsBlock, uint256 newMinGamble, uint256 newMaxGamble, uint16 newMaxInvestor, uint256 newMinInvestment,uint256 newMaxInvestment, uint256 newLockPeriod, uint8 newBlockDelay, uint8 newBlockExpiration)
    noEthSent
    onlyDeveloper
    {


        // changes the statistical multiplier that guarantees the long run casino survival
        if (newCasinoStatLimit<100) throw;
        casinoStatisticalLimit=newCasinoStatLimit;
        //Max number of bets per block to prevent miner cheating
        maxBetsPerBlock=newMaxBetsBlock;
        //MAX BET : limited by payroll/(casinoStatisticalLimit*35)
        if (newMaxGamble<newMinGamble) throw;  
	else { maxGamble=newMaxGamble; }
        //Min Bet
        if (newMinGamble<0) throw; 
	else { minGamble=newMinGamble; }
        //MAX NB of DAO members (can only increase (within bounds) or stay equal)
        //this number of members can only increase after 25k spins on Rouleth
        //refuse change of max number of members if less than 25k spins played
        if (newMaxInvestor!=setting_maxInvestors && gambles.length<25000) throw;
        if ( newMaxInvestor<setting_maxInvestors 
             || newMaxInvestor>investors.length) throw;
        else { setting_maxInvestors=newMaxInvestor;}
        //computes the results of the vote of the VIP members, fees to apply to new members
        computeResultVoteExtraInvestFeesRate();
        if (newMaxInvestment<newMinInvestment) throw;
        //MIN INVEST : 
        setting_minInvestment=newMinInvestment;
        //MAX INVEST : 
        setting_maxInvestment=newMaxInvestment;
        //Invest LOCK PERIOD
	//1 year max
	//can also serve as a failsafe to shutdown withdraws for a period
        if (setting_lockPeriod>360 days) throw; 
        setting_lockPeriod=newLockPeriod;
        //Delay before spin :
	blockDelay=newBlockDelay;
	if (newBlockExpiration<blockDelay+20) throw;
	blockExpiration=newBlockExpiration;
        updateMaxBet();
    }


    //**********************************************
    //                 Nicknames FUNCTIONS                    //
    //**********************************************

    //User set nickname
    mapping (address => string) nicknames;
    function setNickname(string name) 
    noEthSent
    {
        if (bytes(name).length >= 2 && bytes(name).length <= 30)
            nicknames[msg.sender] = name;
    }
    function getNickname(address _address) constant returns(string _name) {
        _name = nicknames[_address];
    }

    
    //**********************************************
    //                 BETTING FUNCTIONS                    //
    //**********************************************

    //***//basic betting without Mist or contract call
    //activates when the player only sends eth to the contract
    //without specifying any type of bet.
    function () 
    {
	//defaut bet : bet on red
	betOnColor(true,false);
    } 

    //Admin function that
    //recalculates max bet
    //updated after each bet and change of bankroll
    function updateMaxBet() private
    {
	//check that setting is still within safety bounds
        if (payroll/(casinoStatisticalLimit*35) > maxGamble) 
	{ 
	    currentMaxGamble=maxGamble;
        }
	else
	{ 
	    currentMaxGamble = payroll/(casinoStatisticalLimit*35);
	}
    }


    //***//Guarantees that gamble is under max bet and above min.
    // returns bet value
    function checkBetValue() private returns(uint256 playerBetValue)
    {
        if (msg.value < minGamble) throw;
	if (msg.value > currentMaxGamble) //if above max, send difference back
	{
            playerBetValue=currentMaxGamble;
	}
        else
        { playerBetValue=msg.value; }
        return;
    }


    //check number of bets in block (to prevent miner cheating)
    modifier checkNbBetsCurrentBlock()
    {
        if (gambles.length!=0 && block.number==gambles[gambles.length-1].blockNumber) nbBetsCurrentBlock+=1;
        else nbBetsCurrentBlock=0;
        if (nbBetsCurrentBlock>=maxBetsPerBlock) throw;
        _
    }


    //Function record bet called by all others betting functions
    function placeBet(BetTypes betType_, uint8 input_) private
    {
	// Before we record, we may have to spin the past bet if the croupier bot 
	// is down for some reason or if the player played again too quickly.
	// This would fail though if the player tries too play to quickly (in consecutive block).
	// gambles should be spaced by at least a block
	// the croupier bot should spin within 2 blocks (~30 secs) after your bet.
	// if the bet expires it is added to casino profit, otherwise it would be a way to cheat
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
        if (betValue<msg.value) 
        {
 	    if (msg.sender.send(msg.value-betValue)==false) throw;
        }
    }


    //***//bet on Number	
    function betOnNumber(uint8 numberChosen)
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
    function betOnColor(bool Red, bool Black)
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
        placeBet(BetTypes.color, input);
    }

    //***// function betOnLow_High
    //bet type : lowhigh
    //input : 0 for low
    //input : 1 for low
    function betOnLowHigh(bool Low, bool High)
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
        placeBet(BetTypes.lowhigh, input);
    }

    //***// function betOnOddEven
    //bet type : parity
    //input : 0 for even
    //input : 1 for odd
    function betOnOddEven(bool Odd, bool Even)
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
        placeBet(BetTypes.parity, input);
    }


    //***// function betOnDozen
    //     //bet type : dozen
    //     //input : 0 for first dozen
    //     //input : 1 for second dozen
    //     //input : 2 for third dozen
    function betOnDozen(bool First, bool Second, bool Third)
    {
        betOnColumnOrDozen(First,Second,Third, BetTypes.dozen);
    }


    // //***// function betOnColumn
    //     //bet type : column
    //     //input : 0 for first column
    //     //input : 1 for second column
    //     //input : 2 for third column
    function betOnColumn(bool First, bool Second, bool Third)
    {
        betOnColumnOrDozen(First, Second, Third, BetTypes.column);
    }

    function betOnColumnOrDozen(bool First, bool Second, bool Third, BetTypes bet) private
    onlyActive
    checkNbBetsCurrentBlock
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
        placeBet(bet, input);
    }


    //**********************************************
    // Spin The Wheel & Check Result FUNCTIONS//
    //**********************************************

    event Win(address player, uint8 result, uint value_won, bytes32 bHash, bytes32 sha3Player, uint gambleId);
    event Loss(address player, uint8 result, uint value_loss, bytes32 bHash, bytes32 sha3Player, uint gambleId);

    //***//function to spin callable
    // no eth allowed
    function spinTheWheel(address spin_for_player)
    noEthSent
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
            bytes32 shaPlayer = sha3(playerSpinned, blockHash);
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
        updateMaxBet();  //at the end, update the Max possible bet
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
            lossSinceChange+=win_v;
            Win(player, result, win_v, blockHash, shaPlayer, gambleIndex[player]);
            //send win!
	    //safe send vs potential callstack overflowed spins
            if (player.send(win_v+bet_v)==false) throw;
        }
        else
        {
	    Loss(player, result, bet_v-1, blockHash, shaPlayer, gambleIndex[player]);
            profitSinceChange+=bet_v-1;
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


    //D.A.O. FUNCTIONS


    //total casino payroll
    uint256 payroll;
    //Profit Loss since last investor change
    uint256 profitSinceChange;
    uint256 lossSinceChange;
    //DAO members struct array (hard capped to 777 members (77 VIP + 700 extra members) )
    struct Investor
    {
	address investor;
	uint256 time;
    }	
    
    Investor[777] private investors; //array of 777 elements (max Rouleth's members nb.)
    uint16 setting_maxInvestors = 77; //Initially restricted to 77 VIP Members
    //Balances of the DAO members
    mapping (address=>uint256) balance; 
    //lockPeriod
    //minimum membership time
    uint256 setting_lockPeriod=30 days ;
    uint256 setting_minInvestment=100 ether; //min amount to send when using "invest()"
    uint256 setting_maxInvestment=200 ether; //max amount to send when using "invest()"
    
    event newInvest(address player, uint invest_v, uint net_invest_v);


    //Become a DAO member.
    function invest()
    {
        // update balances before altering the shares            
        updateBalances();
        uint256 netInvest;
        uint excess;
        // reset the open position counter to values out of bounds
        // =999 if full
        uint16 openPosition=999;
        bool alreadyInvestor;
        // loop over array to find if already member, 
        // and record a potential openPosition
        for (uint16 k = 0; k<setting_maxInvestors; k++)
        { 
            // captures an index of an open position
            if (investors[k].investor==0) openPosition=k; 
            // captures if already a member 
            else if (investors[k].investor==msg.sender)
            {
                alreadyInvestor=true;
                break;
            }
        }
        //new Member
        if (!alreadyInvestor)
        {
            // check that more than min is sent (variable setting)
            if (msg.value<setting_minInvestment) throw;
            // check that less than max is sent (variable setting)
            // otherwise refund
            if (msg.value>setting_maxInvestment)
            {
                excess=msg.value-setting_maxInvestment;
  		netInvest=setting_maxInvestment;
            }
	    else
	    {
		netInvest=msg.value;
	    }
            //members can't become a VIP member after the initial period
            if (setting_maxInvestors >77 && openPosition<77) throw;
            //case : array not full, record new member
            else if (openPosition!=999) investors[openPosition]=Investor(msg.sender, now);
            //case : array full
            else
            {
                throw;
            }
        }
        //already a member
        else
        {
            netInvest=msg.value;
            //is already above the max balance allowed or is sending
	    // too much refuse additional invest
            if (balance[msg.sender]+msg.value>setting_maxInvestment)
            {
                throw;
            }
	    // this additionnal amount should be of at least 1/5 of "setting_minInvestment" (vs spam)
	    if (msg.value<setting_minInvestment/5) throw;
        }

        // add to balance of member and to bankroll
        // 10% of initial 77 VIP members investment is allocated to
        // game developement provider chosen by Rouleth DAO
	// 90% to bankroll
        //share that will be allocated to game dev
        uint256 developmentAllocation;
        developmentAllocation=10*netInvest/100; 
        netInvest-=developmentAllocation;
        //send game development allocation to Rouleth DAO or tech provider
        if (developer.send(developmentAllocation)==false) throw;

	// Apply extra entry fee once casino has been opened to extra members
	// that fee will be shared between the VIP members and represents the increment of
	// market value of their shares in Rouleth to outsiders
	// warning if a VIP adds to its initial invest after the casino has been opened to 
	// extra members he will pay have to pay this fee.
        if (setting_maxInvestors>77)
        {
            // % of extra member's investment that rewards VIP funders
            // Starts at 100%
            // is set by a vote and computed when settings are changed
            // to allow more investors
            uint256 entryExtraCost=voted_extraInvestFeesRate*netInvest/100;
            // add to VIP profit (to be shared by later call by dev.)
            profitVIP += entryExtraCost;
            netInvest-=entryExtraCost;
        }
        newInvest(msg.sender, msg.value, netInvest);//event log
        balance[msg.sender]+=netInvest; //add to balance
        payroll+=netInvest; //add to bankroll
        updateMaxBet();
        //refund potential excess
        if (excess>0) 
        {
            if (msg.sender.send(excess)==false) throw;
        }
    }


    //Allows to transfer your DAO account to another address
    //target should not be currently a DAO member of rouleth
    //enter twice the address to make sure you make no mistake.
    //this can't be reversed if you don't own the target account
    function transferInvestorAccount(address newInvestorAccountOwner, address newInvestorAccountOwner_confirm)
    noEthSent
    {
        if (newInvestorAccountOwner!=newInvestorAccountOwner_confirm) throw;
        if (newInvestorAccountOwner==0) throw;
        //retrieve investor ID
        uint16 investorID=999;
        for (uint16 k = 0; k<setting_maxInvestors; k++)
        {
	    //new address cant be of a current investor
            if (investors[k].investor==newInvestorAccountOwner) throw;

	    //retrieve investor id
            if (investors[k].investor==msg.sender)
            {
                investorID=k;
            }
        }
        if (investorID==999) throw; //stop if not a member
	else
	    //accept and execute change of address
	    //votes on entryFeesRate are not transfered
	    //new address should vote again
	{
	    balance[newInvestorAccountOwner]=balance[msg.sender];
	    balance[msg.sender]=0;
            investors[investorID].investor=newInvestorAccountOwner;
	}
    }
    
    //***// Withdraw function (only after lockPeriod)
    // input : amount to withdraw in Wei (leave empty for full withdraw)
    // if your withdraw brings your balance under the min required,
    // your balance is fully withdrawn
    event withdraw(address player, uint withdraw_v);
    
    function withdrawInvestment(uint256 amountToWithdrawInWei)
    noEthSent
    {
	//vs spam withdraw min 1/10 of min
	if (amountToWithdrawInWei!=0 && amountToWithdrawInWei<setting_minInvestment/10) throw;
        //before withdraw, update balances with the Profit and Loss sinceChange
        updateBalances();
	//check that amount requested is authorized  
	if (amountToWithdrawInWei>balance[msg.sender]) throw;
        //retrieve member ID
        uint16 investorID=999;
        for (uint16 k = 0; k<setting_maxInvestors; k++)
        {
            if (investors[k].investor==msg.sender)
            {
                investorID=k;
                break;
            }
        }
        if (investorID==999) throw; //stop if not a member
        //check if investment lock period is over
        if (investors[investorID].time+setting_lockPeriod>now) throw;
        //if balance left after withdraw is still above min accept partial withdraw
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
            //if balance after withdraw is < min invest, withdraw all and delete member
        {
            //send amount to member (with security if transaction fails)
            uint256 fullAmount=balance[msg.sender];
            payroll-=fullAmount;
            balance[msg.sender]=0;

	    //delete member
            delete investors[investorID];
            if (msg.sender.send(fullAmount)==false) throw;
   	    withdraw(msg.sender, fullAmount);
        }
        updateMaxBet();
    }

    //***// updates balances with Profit Losses when there is a withdraw/deposit
    // can be called by dev for accounting when there are no more changes
    function manualUpdateBalances_only_Dev()
    noEthSent
    onlyDeveloper
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
            // 20% fees for game development on global profit (if profit>loss)
            if (profitSinceChange>lossSinceChange)
            {
                profitToSplit=profitSinceChange-lossSinceChange;
                uint256 developerFees=profitToSplit*20/100;
                profitToSplit-=developerFees;
                if (developer.send(developerFees)==false) throw;
            }
            else
            {
                lossToSplit=lossSinceChange-profitSinceChange;
            }
            
            //share the loss and profits between all DAO members 
            //(proportionnaly. to each one's balance)

            uint totalShared;
            for (uint16 k=0; k<setting_maxInvestors; k++)
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
                    else if (lossToSplit!=0) 
                    {
                        uint lossShare=(lossToSplit*balance[inv])/payroll;
                        balance[inv]-=lossShare;
                        totalShared+=lossShare;
                        
                    }
                }
            }
            // update bankroll
	    // and handle potential very small left overs from integer div.
            if (profitToSplit !=0) 
            {
		payroll+=profitToSplit;
		balance[developer]+=profitToSplit-totalShared;
            }
            else if (lossToSplit !=0) 
            {
		payroll-=lossToSplit;
		balance[developer]-=lossToSplit-totalShared;
            }
            profitSinceChange=0; //reset Profit;
            lossSinceChange=0; //reset Loss ;
        }
    }
    

    //VIP Voting on Extra Invest Fees Rate
    //mapping records 100 - vote
    mapping (address=>uint) hundredminus_extraInvestFeesRate;
    // max fee is 99%
    // a fee of 100% indicates that the VIP has never voted.
    function voteOnNewEntryFees_only_VIP(uint8 extraInvestFeesRate_0_to_99)
    noEthSent
    {
        if (extraInvestFeesRate_0_to_99<1 || extraInvestFeesRate_0_to_99>99) throw;
        hundredminus_extraInvestFeesRate[msg.sender]=100-extraInvestFeesRate_0_to_99;
    }

    uint256 payrollVIP;
    uint256 voted_extraInvestFeesRate;
    function computeResultVoteExtraInvestFeesRate() private
    {
        payrollVIP=0;
        voted_extraInvestFeesRate=0;
        //compute total payroll of the VIPs
        //compute vote results among VIPs
        for (uint8 k=0; k<77; k++)
        {
            if (investors[k].investor==0) continue;
            else
            {
                //don't count vote if the VIP never voted
                if (hundredminus_extraInvestFeesRate[investors[k].investor]==0) continue;
                else
                {
                    payrollVIP+=balance[investors[k].investor];
                    voted_extraInvestFeesRate+=hundredminus_extraInvestFeesRate[investors[k].investor]*balance[investors[k].investor];
                }
            }
        }
	//compute final result
	    if (payrollVIP!=0)
	    {
            voted_extraInvestFeesRate=100-voted_extraInvestFeesRate/payrollVIP;
     	    }
    }


    //Split the profits of the VIP members on extra members' contribution
    uint profitVIP;
    function splitProfitVIP_only_Dev()
    noEthSent
    onlyDeveloper
    {
        payrollVIP=0;
        //compute total payroll of the VIPs
        for (uint8 k=0; k<77; k++)
        {
            if (investors[k].investor==0) continue;
            else
            {
                payrollVIP+=balance[investors[k].investor];
            }
        }
        //split the profits of the VIP members on extra member's contribution
	uint totalSplit;
        for (uint8 i=0; i<77; i++)
        {
            if (investors[i].investor==0) continue;
            else
            {
		uint toSplit=balance[investors[i].investor]*profitVIP/payrollVIP;
                balance[investors[i].investor]+=toSplit;
		totalSplit+=toSplit;
            }
        }
	//take care of Integer Div remainders, and add to bankroll
	balance[developer]+=profitVIP-totalSplit;
	payroll+=profitVIP;
	//reset var profitVIP
        profitVIP=0;
    }

    
    //INFORMATION FUNCTIONS
    function checkProfitLossSinceInvestorChange() constant returns(uint profit_since_update_balances, uint loss_since_update_balances, uint profit_VIP_since_update_balances)
    {
        profit_since_update_balances=profitSinceChange;
        loss_since_update_balances=lossSinceChange;
        profit_VIP_since_update_balances=profitVIP;	
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
    
    function investmentEntryInfos() constant returns(uint current_max_nb_of_investors, uint investLockPeriod, uint voted_Fees_Rate_on_extra_investments)
    {
    	investLockPeriod=setting_lockPeriod;
    	voted_Fees_Rate_on_extra_investments=voted_extraInvestFeesRate;
    	current_max_nb_of_investors=setting_maxInvestors;
    	return;
    }
    
    function getSettings() constant returns(uint maxBet, uint8 blockDelayBeforeSpin)
    {
    	maxBet=currentMaxGamble;
    	blockDelayBeforeSpin=blockDelay;
    	return ;
    }

    function getTotalGambles() constant returns(uint _totalGambles)
    {
        _totalGambles=totalGambles;
    	return ;
    }
    
    function getPayroll() constant returns(uint payroll_at_last_update_balances)
    {
        payroll_at_last_update_balances=payroll;
    	return ;
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