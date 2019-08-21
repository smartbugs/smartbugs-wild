contract Ethereum_twelve_bagger
{

string[24] hexComparison;							//declares global variables
string hexcomparisonchr;
string A;
uint8 i;
uint8 lotteryticket;
address creator;
int lastgainloss;
string lastresult;
uint lastblocknumberused;
bytes32 lastblockhashused;
uint8 hashLastNumber;
address player;
uint8 result;
uint128 wager; 
 
 

   function  Ethereum_twelve_bagger() private 
    { 
        creator = msg.sender; 								
    }

  function Set_your_game_number(string Set_your_game_number)			//sets game number
 {	result=0;
    	A=Set_your_game_number;
     	uint128 wager = uint128(msg.value); 
	comparisonchr(A);
	if(i>=16)//Changes capital letters to small letters
	{i-=6;}
 	checkBet();
	returnmoneycreator(result,wager);
}

 

    function comparisonchr(string A) private					//changes stringhex input to base ten
    {    hexComparison= ["0", "1", "2", "3", "4","5","6","7","8","9","a","b","c","d","e","f","A","B","C","D","E","F","K","N.A."];
	for (i = 0; i < 24; i ++) 
{

	hexcomparisonchr=hexComparison[i];

    

	bytes memory a = bytes(hexcomparisonchr);
 	bytes memory b = bytes(A);
        
          
        
          if (a[0]==b[0])
              return ;

}}


 

	function checkBet() private

 { 
	lotteryticket=i;
	player=msg.sender;
        
                
    
  		  
    	if((msg.value * 12) > this.balance) 					// contract has to have 12*wager funds to be able to pay out. (current balance includes the wager sent)
    	{
    		lastresult = "Bet is larger than games's ability to pay";
    		lastgainloss = 0;
    		msg.sender.send(msg.value); // return wager
    		return;
    	}
    	else if (msg.value == 0)
    	{
    		lastresult = "Wager was zero";
    		lastgainloss = 0;
    		// nothing wagered, nothing returned
    		return;
    	}
    		
    	uint128 wager = uint128(msg.value);          				// limiting to uint128 guarantees that conversion to int256 will stay positive
    	
    	lastblocknumberused = (block.number-1)  ;				//Last available blockhash is in the previous block
    	lastblockhashused = block.blockhash(lastblocknumberused);		//Cheks the last available blockhash

    	
    	hashLastNumber=uint8(lastblockhashused & 0xf);				//Changes blockhash's last number to base ten

   	 if(lotteryticket==18)							//Checks that input is 0-9 or a-f
	{
	lastresult = "give a character between 0-9 or a-f";
	msg.sender.send(msg.value);
	return;
	}

	else if (lotteryticket==16 && msg.sender == creator)			//Creator can kill contract. Contract does not hold players money.
	{
		suicide(creator);} 

	else if(lotteryticket != hashLastNumber)
	{
	    	lastgainloss = int(wager) * -1;
	    	lastresult = "Loss";
	    	result=1;
	    									// Player lost. Return nothing.
	    	return;
	}
	    else if(lotteryticket==hashLastNumber)
	{
	    	lastgainloss =(12*wager);
	    	lastresult = "Win!";
	    	msg.sender.send(wager * 12);  					// Player won. Return bet and winnings.
	} 	
    }

	function returnmoneycreator(uint8 result,uint128 wager) private		//If game has over 50 eth, contract will send all additional eth to owner
	{
	if (result==1&&this.balance>50000000000000000000)
	{creator.send(wager);
	return; 
	}
 
	else if
	(
	result==1&&this.balance>20000000000000000000)				//If game has over 20 eth, contract will send œ of any additional eth to owner
	{creator.send(wager/2);
	return; }
	}
 
/**********
functions below give information about the game in Ethereum Wallet
 **********/
 
 	function Results_of_the_last_round() constant returns (string last_result,string Last_player_s_lottery_ticket,address last_player,string The_right_lottery_number,int Player_s_gain_or_Loss_in_Wei,string info)
    { 
   	last_player=player;	
	Last_player_s_lottery_ticket=hexcomparisonchr;
	The_right_lottery_number=hexComparison[hashLastNumber];
	last_result=lastresult;
	Player_s_gain_or_Loss_in_Wei=lastgainloss;
	info = "The right lottery number is the last character of the most recent blockhash available during the game. One Eth is 10**18 Wei.";
	
 
    }

 	function Last_block_number_and_blockhash_used() constant returns (uint last_blocknumber_used,bytes32 last_blockhash_used)
    {
        last_blocknumber_used=lastblocknumberused;
	last_blockhash_used=lastblockhashused;


    }
    
   
	function Game_balance_in_Ethers() constant returns (uint balance, string info)
    { 
        info = "Game balance is shown in full Ethers";
    	balance=(this.balance/10**18);

    }
    
   
}