pragma solidity ^0.4.7;
contract TheEthereumLottery {
 /*
    Brief introduction:
    
    To play you need to pick 4 numbers (range 0-255) and provide them sorted to Play() function.
    To win you need to hit at least 1 number out of 4 WinningNums which will be announced once every week
    (or more often if the lottery will become more popular). If you hit all of the 4 numbers you will win
    about 10 million times more than you payed for lottery ticket. The exact values are provided as GuessXOutOf4
    entries in Ledger - notice that they are provided in Wei, not Ether (10^18 Wei = Ether).
    Use Withdraw() function to pay out.


    The advantage of TheEthereumLottery is that it uses secret random value which only owner knows (called TheRand).
    A hash of TheRand (called OpeningHash) is announced at the beginning of every draw (lets say draw number N) - 
    at this moment ticket price and the values of GuessXOutOf4 are publicly available and can not be changed.
    When draw N+1 is announced in a block X, a hash of block X-1 is assigned to ClosingHash field of draw N.
    After few minutes, owner announces TheRand which satisfy following expression: sha3(TheRand)==drawN.OpeningHash
    then Rand32B=sha3(TheRand, ClosingHash) is calculated an treated as a source for WinningNumbers, 
    also ClosingHash is changed to Rand32B as it might be more interesting for someone watching lottery ledger
    to see that number instead of hash of some block. 

    This approach (1) unable players to cheat, as as long as no one knows TheRand, 
    no one can predict what WinningNums will be, (2) unable owner to influence the WinningNums (in order to
    reduce average amount won) because OpeningHash=sha3(TheRand) was public before bets were made, and (3) reduces 
    owner capability of playing it's own lottery and making winning bets to very short window of one
    exactly the same block as new draw was announced - so anyone, with big probability, can think that if winning
    bet was made in this particular block - probably it was the owner, especially if no more bets were made 
    at this block (which is very likely).

    Withdraw is possible only after TheRand was announced, if the owner will not announce TheRand in 2 weeks,
    players can use Refund function in order to refund their ETH used to make bet. 
    That moment is called ExpirationTime on contract Ledger (which is visible from JSON interface).
 */
/*
  Name:
  TheEthereumLottery

  JSON interface:

[{"constant":true,"inputs":[],"name":"Announcements","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"IndexOfCurrentDraw","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"uint256"}],"name":"ledger","outputs":[{"name":"WinningNum1","type":"uint8"},{"name":"WinningNum2","type":"uint8"},{"name":"WinningNum3","type":"uint8"},{"name":"WinningNum4","type":"uint8"},{"name":"ClosingHash","type":"bytes32"},{"name":"OpeningHash","type":"bytes32"},{"name":"Guess4OutOf4","type":"uint256"},{"name":"Guess3OutOf4","type":"uint256"},{"name":"Guess2OutOf4","type":"uint256"},{"name":"Guess1OutOf4","type":"uint256"},{"name":"PriceOfTicket","type":"uint256"},{"name":"ExpirationTime","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"TheRand","type":"bytes32"}],"name":"CheckHash","outputs":[{"name":"OpeningHash","type":"bytes32"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"DrawIndex","type":"uint8"},{"name":"PlayerAddress","type":"address"}],"name":"MyBet","outputs":[{"name":"Nums","type":"uint8[4]"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"referral_fee","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"referral_ledger","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"MyNum1","type":"uint8"},{"name":"MyNum2","type":"uint8"},{"name":"MyNum3","type":"uint8"},{"name":"MyNum4","type":"uint8"}],"name":"Play","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"DrawIndex","type":"uint32"}],"name":"Withdraw","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"DrawIndex","type":"uint32"}],"name":"Refund","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"MyNum1","type":"uint8"},{"name":"MyNum2","type":"uint8"},{"name":"MyNum3","type":"uint8"},{"name":"MyNum4","type":"uint8"},{"name":"ref","type":"address"}],"name":"PlayReferred","outputs":[],"payable":true,"type":"function"},{"constant":false,"inputs":[],"name":"Withdraw_referral","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"Deposit_referral","outputs":[],"payable":true,"type":"function"},{"anonymous":false,"inputs":[{"indexed":true,"name":"IndexOfDraw","type":"uint256"},{"indexed":false,"name":"OpeningHash","type":"bytes32"},{"indexed":false,"name":"PriceOfTicketInWei","type":"uint256"},{"indexed":false,"name":"WeiToWin","type":"uint256"}],"name":"NewDrawReadyToPlay","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"IndexOfDraw","type":"uint32"},{"indexed":false,"name":"WinningNumber1","type":"uint8"},{"indexed":false,"name":"WinningNumber2","type":"uint8"},{"indexed":false,"name":"WinningNumber3","type":"uint8"},{"indexed":false,"name":"WinningNumber4","type":"uint8"},{"indexed":false,"name":"TheRand","type":"bytes32"}],"name":"DrawReadyToPayout","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"name":"Wei","type":"uint256"}],"name":"PlayerWon","type":"event"}]

*/
//constructor
function TheEthereumLottery()
{
  owner=msg.sender;
  ledger.length=0;
  IndexOfCurrentDraw=0;
  referral_fee=90;
}
modifier OnlyOwner()
{ // Modifier
  if (msg.sender != owner) throw;
  _;
}
address owner;
string public Announcements;//just additional feature
uint public IndexOfCurrentDraw;//starting from 0
uint8 public referral_fee;
mapping(address=>uint256) public referral_ledger;
struct bet_t {
  address referral;
  uint8[4] Nums;
  bool can_withdraw;//default==false
}
struct ledger_t {
  uint8 WinningNum1;
  uint8 WinningNum2;
  uint8 WinningNum3;
  uint8 WinningNum4;
  bytes32 ClosingHash;
  bytes32 OpeningHash;
  mapping(address=>bet_t) bets;
  uint Guess4OutOf4;
  uint Guess3OutOf4;
  uint Guess2OutOf4;
  uint Guess1OutOf4;
  uint PriceOfTicket;
  uint ExpirationTime;//for eventual refunds only, ~2 weeks after draw announced
}
ledger_t[] public ledger;
 
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@ Here begins what probably you want to analyze @@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function next_draw(bytes32 new_hash,
	  uint priceofticket,
	  uint guess4outof4,
	  uint guess3outof4,
	  uint guess2outof4,
	  uint guess1outof4
	  )
OnlyOwner
{
  ledger.length++;
  ledger[IndexOfCurrentDraw].ClosingHash =
    //sha3(block.blockhash(block.number-1));               //this, or
    //sha3(block.blockhash(block.number-1),block.coinbase);//this adds complexity, but safety remains the same
    block.blockhash(block.number-1);//adds noise to the previous draw
  //if you are just checking how it works, just pass the comment below, and come back when you finish analyzing
  //the contract - it explains how the owner could win this lottery 
  //if the owner was about to cheat, he has to make a bet, and then use this f-n. both in a single block.
  //its because if you know TheRand and blockhash of a last block before new draw then you can determine the numbers
  //achieving it would be actually simple, another contract is needed which would get signed owner tx of this f-n call
  //and just calculate what the numbers would be (the previous block hash is available), play with that nums,
  //and then run this f-n. It is guaranteed that both actions are made in a single block, as it is a single call
  //so if someone have made winning bet in exactly the same block as announcement of next draw,
  //then you can be suspicious that it was the owner
  //also assuming this scenario, TheRand needs to be present on that contract - so if transaction is not mined
  //immediately - it makes a window for anyone to do the same and win.
  IndexOfCurrentDraw=ledger.length-1;
  ledger[IndexOfCurrentDraw].OpeningHash = new_hash;
  ledger[IndexOfCurrentDraw].Guess4OutOf4=guess4outof4;
  ledger[IndexOfCurrentDraw].Guess3OutOf4=guess3outof4;
  ledger[IndexOfCurrentDraw].Guess2OutOf4=guess2outof4;
  ledger[IndexOfCurrentDraw].Guess1OutOf4=guess1outof4;
  ledger[IndexOfCurrentDraw].PriceOfTicket=priceofticket;
  ledger[IndexOfCurrentDraw].ExpirationTime=now + 2 weeks;//You can refund after ExpirationTime if owner will not announce TheRand satisfying TheHash
  NewDrawReadyToPlay(IndexOfCurrentDraw, new_hash, priceofticket, guess4outof4);//event
}
function announce_therand(uint32 index,
			  bytes32 the_rand
			  )
OnlyOwner
{
  if(sha3(the_rand)
     !=
     ledger[index].OpeningHash)
    throw;//this implies that if Numbers are present, broadcasted TheRand has to satisfy TheHash


  bytes32 combined_rand=sha3(the_rand, ledger[index].ClosingHash);//from this number we'll calculate WinningNums
  //usually the last 4 Bytes will be the WinningNumbers, but it is not always true, as some Byte could
  //be the same, then we need to take one more Byte from combined_rand and so on

  ledger[index].ClosingHash = combined_rand;//changes the closing blockhash to seed for WinningNums
    //this line is useless from the perspective of lottery
    //but maybe some of the players will find it interesting that something
    //which is connected to the WinningNums is present in a ledger


  //the algorithm of assigning an int from some range to single bet takes too much code
  uint8[4] memory Numbers;//relying on that combined_rand should be random - lets pick Nums into this array 

  uint8 i=0;//i = how many numbers are picked
  while(i<4)
    {
      Numbers[i]=uint8(combined_rand);//same as '=combined_rand%256;'
      combined_rand>>=8;//same as combined_rand/=256;
      for(uint j=0;j<i;++j)//is newly picked val in a set?
	if(Numbers[j]==Numbers[i]) {--i;break;}//yes, break back to while loop and look for another Num[i]
      ++i;
    }
  //probability that in 32 random bytes there was only 3 or less different ones ~=2.65e-55
  //it's like winning this lottery 2.16*10^46 times in a row
  //p.s. there are 174792640 possible combinations of picking 4 numbers out of 256

  //now we have to sort the values
  for(uint8 n=4;n>1;n--)//bubble sort
    {
      bool sorted=true; 
      for(uint8 k=0;k<n-1;++k)
	if(Numbers[k] > Numbers[k+1])//then mark array as not sorted & swap
	  {
	    sorted=false;
	    (Numbers[k], Numbers[k+1])=(Numbers[k+1], Numbers[k]);
	  }
      if(sorted) break;//breaks as soon as the array is sorted
    }

  
  ledger[index].WinningNum1 = Numbers[0];
  ledger[index].WinningNum2 = Numbers[1];
  ledger[index].WinningNum3 = Numbers[2];
  ledger[index].WinningNum4 = Numbers[3];
  
  DrawReadyToPayout(index,
		    Numbers[0],Numbers[1],Numbers[2],Numbers[3],
		    the_rand);//event
}

function PlayReferred(uint8 MyNum1,
		      uint8 MyNum2,
		      uint8 MyNum3,
		      uint8 MyNum4,
		      address ref
		      )
payable
{
  if(msg.value != ledger[IndexOfCurrentDraw].PriceOfTicket ||//to play you need to pay 
     ledger[IndexOfCurrentDraw].bets[msg.sender].Nums[3] != 0)//if your bet already exist
    throw;

  //if numbers are not sorted
  if(MyNum1 >= MyNum2 ||
     MyNum2 >= MyNum3 ||
     MyNum3 >= MyNum4
     )
    throw;//because you should sort the values yourself
  if(ref!=0)//when there is no refferal, function is cheaper for ~20k gas
    ledger[IndexOfCurrentDraw].bets[msg.sender].referral=ref;
  ledger[IndexOfCurrentDraw].bets[msg.sender].Nums[0]=MyNum1;
  ledger[IndexOfCurrentDraw].bets[msg.sender].Nums[1]=MyNum2;
  ledger[IndexOfCurrentDraw].bets[msg.sender].Nums[2]=MyNum3;
  ledger[IndexOfCurrentDraw].bets[msg.sender].Nums[3]=MyNum4;
  ledger[IndexOfCurrentDraw].bets[msg.sender].can_withdraw=true;
}
// Play wrapper:
function Play(uint8 MyNum1,
	      uint8 MyNum2,
	      uint8 MyNum3,
	      uint8 MyNum4
	      )
{
  PlayReferred(MyNum1,
	       MyNum2,
	       MyNum3,
	       MyNum4,
	       0//no referral
	       );
}
function Deposit_referral()//this function is not mandatory to become referral
  payable//might be used to not withdraw all the funds at once or to invest
{//probably needed only at the beginnings
  referral_ledger[msg.sender]+=msg.value;
}
function Withdraw_referral()
{
  uint val=referral_ledger[msg.sender];
  referral_ledger[msg.sender]=0;
  if(!msg.sender.send(val)) //payment
    throw;
}
function set_referral_fee(uint8 new_fee)
OnlyOwner
{
  if(new_fee<50 || new_fee>100)
    throw;//referrals have at least 50% of the income
  referral_fee=new_fee;
}
function Withdraw(uint32 DrawIndex)
{
  //if(msg.value!=0) //compiler deals with that, as there is no payable modifier in this f-n
  //  throw;//this function is free

  if(ledger[DrawIndex].bets[msg.sender].can_withdraw==false)
    throw;//throw if player didnt played

  //by default, every non existing value is equal to 0
  //so if there was no announcement WinningNums are zeros
  if(ledger[DrawIndex].WinningNum4 == 0)//the least possible value == 3
    throw;//this condition checks if the numbers were announced
  //see announce_therand f-n to see why this check is enough
  
  uint8 hits=0;
  uint8 i=0;
  uint8 j=0;
  uint8[4] memory playernum=ledger[DrawIndex].bets[msg.sender].Nums;
  uint8[4] memory nums;
  (nums[0],nums[1],nums[2],nums[3])=
    (ledger[DrawIndex].WinningNum1,
     ledger[DrawIndex].WinningNum2,
     ledger[DrawIndex].WinningNum3,
     ledger[DrawIndex].WinningNum4);
  //data ready
  
  while(i<4)//count player hits
    {//both arrays are sorted
      while(j<4 && playernum[j] < nums[i]) ++j;
      if(j==4) break;//nothing more to check - break loop here
      if(playernum[j] == nums[i]) ++hits;
      ++i;
    }
  if(hits==0) throw;
  uint256 win=0;
  if(hits==1) win=ledger[DrawIndex].Guess1OutOf4;
  if(hits==2) win=ledger[DrawIndex].Guess2OutOf4;
  if(hits==3) win=ledger[DrawIndex].Guess3OutOf4;
  if(hits==4) win=ledger[DrawIndex].Guess4OutOf4;
    
  ledger[DrawIndex].bets[msg.sender].can_withdraw=false;
  if(!msg.sender.send(win)) //payment
    throw;

  if(ledger[DrawIndex].bets[msg.sender].referral==0)//it was not referred bet
    referral_ledger[owner]+=win/100;
  else
    {
      referral_ledger[ledger[DrawIndex].bets[msg.sender].referral]+=
	win/10000*referral_fee;//(win/100)*(referral_fee/100);
      referral_ledger[owner]+=
	win/10000*(100-referral_fee);//(win/100)*((100-referral_fee)/100);
    }

  
  PlayerWon(win);//event
}
function Refund(uint32 DrawIndex)
{
  //if(msg.value!=0) //compiler deals with that, as there is no payable modifier in this f-n
  //  throw;//this function is free

  if(ledger[DrawIndex].WinningNum4 != 0)//if TheRand was announced, WinningNum4 >= 3
    throw; //no refund if there was a valid announce

  if(now < ledger[DrawIndex].ExpirationTime)
    throw;//no refund while there is still TIME to announce TheRand
  
 
  if(ledger[DrawIndex].bets[msg.sender].can_withdraw==false)
    throw;//throw if player didnt played or already refunded
  
  ledger[DrawIndex].bets[msg.sender].can_withdraw=false;
  if(!msg.sender.send(ledger[DrawIndex].PriceOfTicket)) //refund
    throw;
}
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@ Here ends what probably you wanted to analyze @@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function CheckHash(bytes32 TheRand)
  constant returns(bytes32 OpeningHash)
{
  return sha3(TheRand);
}
function MyBet(uint8 DrawIndex, address PlayerAddress)
  constant returns (uint8[4] Nums)
{//check your nums
  return ledger[DrawIndex].bets[PlayerAddress].Nums;
}
function announce(string MSG)
  OnlyOwner
{
  Announcements=MSG;
}
event NewDrawReadyToPlay(uint indexed IndexOfDraw,
			 bytes32 OpeningHash,
			 uint PriceOfTicketInWei,
			 uint WeiToWin);
event DrawReadyToPayout(uint32 indexed IndexOfDraw,
			uint8 WinningNumber1,
			uint8 WinningNumber2,
			uint8 WinningNumber3,
			uint8 WinningNumber4,
			bytes32 TheRand);
event PlayerWon(uint Wei);

}//contract