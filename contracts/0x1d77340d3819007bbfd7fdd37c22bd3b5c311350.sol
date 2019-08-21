contract RockPaperScissors {
  /*
    Brief introduction:
    the game is about to submit your pick (R/P/S) with fee to the blockchain,
    join players into pairs and withdraw 2x the fee, or just 1x the fee in case of draw.
    if there will be no other player in "LimitOfMinutes" minutes you can refund your fee.

    The whole thing is made by picking a random value called SECRET_RAND, where (SECRET_RAND % 3) gives 0,1 or 2 for Rock,Paper or Scissors,
    then taking a hash of SECRET_RAND and submitting it as your ticket.
    At this moment player waits for opponent. If there is no opponent in "LimitOfMinutes", player can refund or wait more.
    When both players sended their hashes then they have "LimitOfMinutes" minutes to announce their SECRET_RAND.
    As soon as both players provided their SECRET_RAND the withdraw is possible.
    If opponent will not announce his SECRET_RAND in LimitOfMinutes then the players bet is treated as a winning one.
    In any case (win, draw, refund) you should use Withdraw() function to pay out.

    There is fee of 1% for contract owner, charged while player withdraws.
    There is no fee for contract owner in case of refund.
   */

  /*
  JSON Interface:

[{"constant":true,"inputs":[],"name":"Announcement","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"HASH","type":"bytes32"}],"name":"play","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"MySecretRand","type":"bytes32"}],"name":"announce","outputs":[],"type":"function"},{"constant":true,"inputs":[{"name":"MyHash","type":"bytes32"}],"name":"IsPayoutReady__InfoFunction","outputs":[{"name":"Info","type":"string"}],"type":"function"},{"constant":true,"inputs":[{"name":"RockPaperOrScissors","type":"uint8"},{"name":"WriteHereSomeUniqeRandomStuff","type":"string"}],"name":"CreateHash","outputs":[{"name":"SendThisHashToStart","type":"bytes32"},{"name":"YourSecretRandKey","type":"bytes32"},{"name":"Info","type":"string"}],"type":"function"},{"constant":true,"inputs":[{"name":"SecretRand","type":"bytes32"}],"name":"WhatWasMyHash","outputs":[{"name":"HASH","type":"bytes32"}],"type":"function"},{"constant":false,"inputs":[{"name":"HASH","type":"bytes32"}],"name":"withdraw","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"LimitOfMinutes","outputs":[{"name":"","type":"uint8"}],"type":"function"},{"constant":true,"inputs":[],"name":"Cost","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"inputs":[],"type":"constructor"}]
 */
  modifier OnlyOwner()
  { // Modifier
    if (msg.sender != owner) throw;
    _
  }
  
  uint8 public LimitOfMinutes;//number of minutes you have to announce (1)your choice or (2)wait to withdraw funds back if no one else will play
  uint public Cost;
  string public Announcement;

  address owner;
  uint TimeOfLastPriceChange;
  mapping(bytes32=>bet_t) bets;
  uint playerssofar;
  struct bet_t {
    bytes32 OpponentHash;
    address sender;
    uint timestamp;
    int8 Pick;
    bool can_withdraw;//default==false
  }
  bytes32 LastHash;
  
  function RockPaperScissors()
  {
    playerssofar=0;
    owner=msg.sender;
    //SetInternalValues(limitofminutes, cost);
    LimitOfMinutes=255;
    Cost=100000000000000000;//0.1ETH
    TimeOfLastPriceChange = now - 255*60;
  }
  function SetInternalValues(uint8 limitofminutes, uint cost)
    OnlyOwner
  {
    LimitOfMinutes=limitofminutes;
    if(Cost!=cost)
      {
	Cost=cost;
	TimeOfLastPriceChange=now;
      }
  }
  function OwnerAnnounce(string announcement)
    OnlyOwner
  {
    Announcement=announcement;
  }
 
  function play(bytes32 HASH)
  {
    if(now < TimeOfLastPriceChange + LimitOfMinutes*60 || //the game is temprorary off 
       msg.value != Cost || // pay to play 
       //bets[HASH].can_withdraw == true ||//to play twice, give another random seed in CreateHash() f-n
       bets[HASH].sender != 0 || //throw because someone have already made this bet 
       HASH == 0 //this would be problematic situation
       )
      throw;

    bets[HASH].sender=msg.sender;
    bets[HASH].can_withdraw=true;
    if(playerssofar%2 == 1)
      {
	bets[HASH].OpponentHash=LastHash;
	bets[LastHash].OpponentHash=HASH;
      }
    else
      LastHash=HASH;
    bets[HASH].timestamp=now;
    playerssofar++;
  }

  function announce(bytes32 MySecretRand)
  {
    if(msg.value != 0 ||
       bets[sha3(MySecretRand)].can_withdraw==false)
      throw; //if you try to announce non existing bet (do not waste your gas)
    bets[sha3(MySecretRand)].Pick= int8( uint(MySecretRand)%3 + 1 );
    //there is no check of msg.sender. If your secret rand was guessed by someone else it is no longer secret
    //remember to give good 'random' seed as input of CreateHash f-n.
    bets[sha3(MySecretRand)].timestamp=now;
  }

  function withdraw(bytes32 HASH)
  { //3 ways to payout:
    //1: both sides announced their picks and you have won OR draw happend
    //2: no one else played - you can payout after LimitOfMinutes (100% refund)
    //3: you have announced your pick but opponent not (you have won)
    //note that both of you has "LimitOfMinutes" minutes to announce the SecretRand numbers after 2nd player played
    if(msg.value != 0 || 
       bets[HASH].can_withdraw == false)
      throw;

    if(bets[HASH].OpponentHash!=0 && //case 1
       bets[bets[HASH].OpponentHash].Pick != 0 && //check if opponent announced
       bets[HASH].Pick != 0 //check if player announced
       //it is impossible for val .Pick to be !=0 without broadcasting SecretRand
       )
      {
	int8 tmp = bets[HASH].Pick - bets[bets[HASH].OpponentHash].Pick;
	if(tmp==0)//draw?
	  {
	    bets[HASH].can_withdraw=false;
	    if(!bets[HASH].sender.send(Cost*99/100)) //return ETH
	      throw;
	    else
	      if(!owner.send(Cost/100))
		throw;
	  }
	else if(tmp == 1 || tmp == -2)//you have won
	  {
	    bets[HASH].can_withdraw=false;
	    bets[bets[HASH].OpponentHash].can_withdraw=false;
	    if(!bets[HASH].sender.send(2*Cost*99/100)) //refund
	      throw;	    
	    else
	      if(!owner.send(2*Cost/100))
		throw;
	  }
	else
	  throw;
      }
    else if(bets[HASH].OpponentHash==0 && //case 2
	    now > bets[HASH].timestamp + LimitOfMinutes*60)
      {
	bets[HASH].can_withdraw=false;
	if(!bets[HASH].sender.send(Cost)) //refund
	  throw;

	//if we are here that means we should repair playerssofar
	--playerssofar;
      }
    else if(bets[HASH].OpponentHash!=0 && 
	    bets[bets[HASH].OpponentHash].Pick == 0 && //opponent did not announced
	    bets[HASH].Pick != 0 //check if player announced
	    )//case 3
      {
	//now lets make sure that opponent had enough time to announce
	if(//now > (time of last interaction from player or opponent)
	   now > bets[HASH].timestamp + LimitOfMinutes*60 &&
	   now > bets[bets[HASH].OpponentHash].timestamp + LimitOfMinutes*60
	   )//then refund is possible
	  {
	    bets[HASH].can_withdraw=false;
	    bets[bets[HASH].OpponentHash].can_withdraw=false;
	    if(!bets[HASH].sender.send(2*Cost*99/100)) 
	      throw;
	    else
	      if(!owner.send(2*Cost/100))
		throw;
	  }
	else
	  throw;//you still need to wait some more time
      }
    else
      throw; //throw in any other case
    //here program flow jumps
    //and program ends
  }

  function IsPayoutReady__InfoFunction(bytes32 MyHash)
    constant
    returns (string Info) 
  {
    // "write your hash"
    // "you can send this hash and double your ETH!"
    // "wait for opponent [Xmin left]"
    // "you can announce your SecretRand"
    // "wait for opponent SecretRand"
    // "ready to withdraw - you have won!"
    // "you have lost, try again"
    if(MyHash == 0)
      return "write your hash";
    if(bets[MyHash].sender == 0) 
      return "you can send this hash and double your ETH!";
    if(bets[MyHash].sender != 0 &&
       bets[MyHash].can_withdraw==false) 
      return "this bet is burned";
    if(bets[MyHash].OpponentHash==0 &&
       now < bets[MyHash].timestamp + LimitOfMinutes*60)
      return "wait for other player";
    if(bets[MyHash].OpponentHash==0)
      return "no one played, use withdraw() for refund";
    
    //from now there is opponent
    bool timeforaction =
      (now < bets[MyHash].timestamp + LimitOfMinutes*60) ||
      (now < bets[bets[MyHash].OpponentHash].timestamp + LimitOfMinutes*60 );
    
    if(bets[MyHash].Pick == 0 &&
       timeforaction
       )
      return "you can announce your SecretRand";
    if(bets[MyHash].Pick == 0)
      return "you have failed to announce your SecretRand but still you can try before opponent withdraws";
    if(bets[bets[MyHash].OpponentHash].Pick == 0 &&
       timeforaction
       )
      return "wait for opponent SecretRand";


    bool win=false;
    bool draw=false;
    int8 tmp = bets[MyHash].Pick - bets[bets[MyHash].OpponentHash].Pick;
    if(tmp==0)//draw?
      draw=true;
    else if(tmp == 1 || tmp == -2)//you have won
      win=true;
    
    if(bets[bets[MyHash].OpponentHash].Pick == 0 ||
       win
       )
      return "you have won! now you can withdraw your ETH";
    if(draw)
      return "Draw happend! withdraw back your funds";


    return "you have lost, try again";
  }

  function WhatWasMyHash(bytes32 SecretRand)
    constant
    returns (bytes32 HASH) 
  {
    return sha3(SecretRand);
  }

  function CreateHash(uint8 RockPaperOrScissors, string WriteHereSomeUniqeRandomStuff)
    constant
    returns (bytes32 SendThisHashToStart,
	     bytes32 YourSecretRandKey,
	     string Info)
  {
    uint SecretRand;

    SecretRand=3*( uint(sha3(WriteHereSomeUniqeRandomStuff))/3 ) + (RockPaperOrScissors-1)%3;
    //SecretRand%3 ==
    //0 - Rock
    //1 - Paper
    //2 - Scissors

    if(RockPaperOrScissors==0)
      return(0,0, "enter 1 for Rock, 2 for Paper, 3 for Scissors");

    return (sha3(bytes32(SecretRand)),bytes32(SecretRand),  bets[sha3(bytes32(SecretRand))].sender != 0 ? "someone have already used this random string - try another one" :
                                                            SecretRand%3==0 ? "Rock" :
	                                                        SecretRand%3==1 ? "Paper" :
	                                                        "Scissors");
  }

}