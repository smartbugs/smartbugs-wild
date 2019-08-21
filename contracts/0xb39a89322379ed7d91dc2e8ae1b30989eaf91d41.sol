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
//                                                                
//   ROCK PAPER SCISSORS
//   Challenge an opponent with an encrypted hand
//   www.matching-ethers.com/rps                 
//
//
// *** coded by WhySoS3rious, 2016.                                       ***//
// *** please do not copy without authorization                          ***//
// *** contact : reddit    /u/WhySoS3rious                               ***//

//          STAKE : 0.5 ETH
//          DRAW : Full refund
//          WIN : 0.995 ETH (house : 0.005)
//          EXPIRATION TIME : 1hour after duel starts (refreshed when one player reveals)
//          If only one player reveals, he wins after 1 hour if the other doesn't reveal
//          he will be paid automatically when other ppl play the game.
//          If both player don't reveal and forget the bet, it is refunded (-house)

//         HOW TO PLAY ?
//         1- Send a encrypted Hand (generated on the game's website)
//         2- Wait for opponent (can cancel if you wish)
//         3- Once matched, reveal your hand with the appropriate function and your secret
//         4- Wait for your duel to resolve and the automatic payout

//         ENCRYPT YOUR HAND
//         Encrypt your hands on the website or
//         directly with web3.js :  web3.sha3(secret+hand)

// exemple results with secret = "testing"
//hand = "rock" :  web3.sha3("testing"+"rock")
// 0x8935dc293ca2ee08e33bad4f4061699a8f59ec637081944145ca19cbc8b39473
//hand = "paper" : 
// 0x859743aa01286a6a1eba5dbbcc4cf8eeaf1cc953a3118799ba290afff7125501
//hand = "scissors" : 
//0x35ccbb689808295e5c51510ed28a96a729e963a12d09c4a7a4ba000c9777e897

contract Crypted_RPS
{
    address owner;
    uint256 gambleValue;
    uint256 expirationTime;
    uint256 house;
    uint256 houseTotal;
    modifier noEthSent(){
        if (msg.value>0) msg.sender.send(msg.value);
        _
    }
    modifier onlyOwner() {
	    if (msg.sender!=owner) throw;
	    _
    }
    modifier equalGambleValue() {
	if (msg.value < gambleValue) throw;
        if (msg.value > gambleValue) msg.sender.send(msg.value-gambleValue);
	_
    }

    struct PlayerWaiting
    {
        bool full;
        address player;
        bytes32 cryptedHand;
    }
    PlayerWaiting playerWaiting;

    struct Duel2Decrypt
    {
	address player_1;
        bytes32 cryptedHand_1;
        address player_2;
 	bytes32 cryptedHand_2;
        bool decrypted;
        uint256 timeStamp;
    }
    Duel2Decrypt[] duels2Decrypt;
    uint firstActiveDuel2; //index du premier duel2 non resolu

    struct Duel1Decrypt
   {
	address player_1;
        string hand_1;
        address player_2;
	bytes32 cryptedHand_2;
        bool decrypted;
        uint256 timeStamp;
    }
    Duel1Decrypt[] duels1Decrypt;
    uint firstActiveDuel1;

    struct Result  
    {
       address player_1;
       string hand_1;
       address player_2;
       string hand_2;
       uint result; //0 draw, 1 wins, 2 wins
    }
    Result[] results;


    mapping (address => uint) player_progress;
    // 0 not here, 1 waiting, 2 2crypted, 3 1crypted
    mapping (address => uint) player_bet_id;
    mapping (address => uint) player_bet_position;

    function getPlayerStatus(address player, uint option) constant returns (uint result)
    {
         if (option==0) {result = player_progress[player];}
         else if (option==1) {result= player_bet_id[player];}
         else if (option==2) {result = player_bet_position[player];}
         return result;
    }


    mapping (string => mapping(string => int)) payoffMatrix;
    //constructor
    function Crypted_RPS()
    {
	owner= msg.sender;
	gambleValue = 500000 szabo;
        house = 2500 szabo;
        expirationTime = 3600;   //1 hour
        payoffMatrix["rock"]["rock"] = 0;
        payoffMatrix["rock"]["paper"] = 2;
        payoffMatrix["rock"]["scissors"] = 1;
        payoffMatrix["paper"]["rock"] = 1;
        payoffMatrix["paper"]["paper"] = 0;
        payoffMatrix["paper"]["scissors"] = 2;
        payoffMatrix["scissors"]["rock"] = 2;
        payoffMatrix["scissors"]["paper"] = 1;
        payoffMatrix["scissors"]["scissors"] = 0;
    }

    function () {throw;} //no callback, use the functions to play

    modifier payexpired2Duel{
        if (duels2Decrypt.length>firstActiveDuel2 && duels2Decrypt[firstActiveDuel2].timeStamp + expirationTime <= now) {
            duels2Decrypt[firstActiveDuel2].player_1.send(gambleValue-house);
            duels2Decrypt[firstActiveDuel2].player_2.send(gambleValue-house);
            houseTotal+=2*house;
            player_progress[duels2Decrypt[firstActiveDuel2].player_1]=0;
            player_progress[duels2Decrypt[firstActiveDuel2].player_2]=0;
            duels2Decrypt[firstActiveDuel2].decrypted = true;
            updateFirstDuel2(firstActiveDuel2);
        }
        _
    }

    modifier payexpired1Duel{
        if (duels1Decrypt.length>firstActiveDuel1 && (duels1Decrypt[firstActiveDuel1].timeStamp + expirationTime) < now) {
            duels1Decrypt[firstActiveDuel1].player_1.send(2*(gambleValue-house));
            houseTotal+=2*house;
            duels1Decrypt[firstActiveDuel1].decrypted = true;
            player_progress[duels1Decrypt[firstActiveDuel1].player_1]=0;
            player_progress[duels1Decrypt[firstActiveDuel1].player_2]=0;
            results.push(Result(duels1Decrypt[firstActiveDuel1].player_1, duels1Decrypt[firstActiveDuel1].hand_1, duels1Decrypt[firstActiveDuel1].player_2,"expired", 1));
            updateFirstDuel1(firstActiveDuel1);
           
        }
        _
    }
        

    function cancelWaitingForOpponent()
    noEthSent {
        if (msg.sender==playerWaiting.player && playerWaiting.full)
        {
             msg.sender.send(gambleValue);
             playerWaiting.full=false;
             player_progress[msg.sender]=0;
        }
        else { throw;}
    }	


    function sendCryptedHand(bytes32 cryptedH)
    equalGambleValue
    payexpired2Duel
    payexpired1Duel
    {
          uint progress = player_progress[msg.sender];
          uint position = player_bet_position[msg.sender];
          //one not resolved duel per player only
          if ( progress==3 && position==1 )throw;
          if (progress == 2 ) throw; 
          if (progress ==  1 ) throw; //no selfdueling
          if (!playerWaiting.full) 
          {
              playerWaiting.player=msg.sender;
              playerWaiting.cryptedHand= cryptedH;
              playerWaiting.full=true;
              player_progress[msg.sender]=1;
          }
          else
          {
               duels2Decrypt.push( Duel2Decrypt(playerWaiting.player, playerWaiting.cryptedHand, msg.sender, cryptedH, false, now) );
                player_progress[playerWaiting.player]=2;
                player_bet_id[playerWaiting.player]=duels2Decrypt.length-1;
                player_bet_position[playerWaiting.player]=0;
                player_progress[msg.sender]=2;
                player_bet_id[msg.sender]=duels2Decrypt.length-1;
                player_bet_position[msg.sender]=1;         
                playerWaiting.full=false;
          }

    }


    function revealRock(string secret)
    {
        bytes32 hashRevealed = sha3(secret, "rock");
        reveal(hashRevealed, "rock");
    }
    function revealPaper(string secret)
    {
        bytes32 hashRevealed = sha3(secret, "paper");
        reveal(hashRevealed, "paper");
    }
    function revealScissors(string secret)
    {
        bytes32 hashRevealed = sha3(secret, "scissors");
        reveal(hashRevealed, "scissors");
    }

    function reveal(bytes32 hashRevealed, string hand) private
    noEthSent
   {

        uint progress =  getPlayerStatus(msg.sender,0);
        uint bet_id     =  getPlayerStatus(msg.sender,1);
        uint position  =  getPlayerStatus(msg.sender,2);
        

        bytes32 hashStored;        
        if (progress==2)  //duel not revealed
        { 
            if (position == 0)
            {
                 hashStored = duels2Decrypt[bet_id].cryptedHand_1;
            }
            else
            {
                 hashStored = duels2Decrypt[bet_id].cryptedHand_2;
            }
        }
        else if (progress==3 && position==1) //duel half revealed already
        { 
                hashStored = duels1Decrypt[bet_id].cryptedHand_2;
        }
        else { throw;} //player has nothing to reveal

	if (hashStored==hashRevealed)
        {
              decryptHand(hand, progress, bet_id, position);
        }
        else
        {
             throw; //wrong secret or hand
         }
    }
    
    function  decryptHand(string hand, uint progress, uint bet_id, uint position) private
    {
             address op_add;
             bytes32 op_cH;

         if (progress==2)
         {  
             if (position==0) 
             {
                 op_add = duels2Decrypt[bet_id].player_2;
                 op_cH = duels2Decrypt[bet_id].cryptedHand_2;

             }
             else
             {
                 op_add = duels2Decrypt[bet_id].player_1;
                 op_cH = duels2Decrypt[bet_id].cryptedHand_1;
             }

              duels1Decrypt.push(Duel1Decrypt(msg.sender,hand,op_add, op_cH, false, now));
              duels2Decrypt[bet_id].decrypted=true;
              updateFirstDuel2(bet_id);
              player_progress[msg.sender]=3;
              player_bet_id[msg.sender]=duels1Decrypt.length-1;
              player_bet_position[msg.sender]=0;
              player_progress[op_add]=3;
              player_bet_id[op_add]=duels1Decrypt.length-1;
              player_bet_position[op_add]=1;

         }
         else if (progress==3 && position==1)
         {
              op_add = duels1Decrypt[bet_id].player_1;
              string op_h = duels1Decrypt[bet_id].hand_1;
              duels1Decrypt[bet_id].decrypted=true;
              uint result = payDuel(op_add, op_h, msg.sender, hand);
              results.push(Result(op_add, op_h, msg.sender,hand, result));
              updateFirstDuel1(bet_id);
              player_progress[msg.sender]=0;
              player_progress[op_add]=0;
          }
     }

     function updateFirstDuel2(uint bet_id) private
     {
         if (bet_id==firstActiveDuel2)
         {   
              uint index;
              while (true) {
                 if (index<duels2Decrypt.length && duels2Decrypt[index].decrypted){
                     index=index+1;
                 }
                 else {break; }
              }
              firstActiveDuel2=index;
              return;
          }
      }

     function updateFirstDuel1(uint bet_id) private
     {
         if (bet_id==firstActiveDuel1)
         {   
              uint index;
              while (true) {
                 if (index<duels1Decrypt.length && duels1Decrypt[index].decrypted){
                     index=index+1;
                 }
                 else {break; }
              }
              firstActiveDuel1=index;
              return;
          }
      }

     // in case there is too much expired duels in queue for automatic payout, 
     //I can help to catch up
     function manualPayExpiredDuel() 
     onlyOwner
     payexpired2Duel
     payexpired1Duel
     noEthSent
     {
         return;
     }

     //payout
     function payDuel(address player_1, string hand_1, address player_2, string hand_2) private returns(uint result) 
     {
              if (payoffMatrix[hand_1][hand_2]==0) //draw
              {player_1.send(gambleValue); player_2.send(gambleValue); result=0;}
              else if (payoffMatrix[hand_1][hand_2]==1) //1 win
              {player_1.send(2*(gambleValue-house)); result=1; houseTotal+=2*house;}
              if (payoffMatrix[hand_1][hand_2]==2) //2 wins
              {player_2.send(2*(gambleValue-house)); result=2; houseTotal+=2*house;}
              return result;
      }

     function payHouse() 
     onlyOwner
     noEthSent {
         owner.send(houseTotal);
         houseTotal=0;
     }

     function getFirstActiveDuel1() constant returns(uint fAD1) {
         return firstActiveDuel1;}
     function getLastDuel1() constant returns(uint lD1) {
         return duels1Decrypt.length;}
     function getDuel1(uint index) constant returns(address p1, string h1, address p2, bool dC, uint256 tS) {
         p1 = duels1Decrypt[index].player_1;
         h1 = duels1Decrypt[index].hand_1;
         p2 = duels1Decrypt[index].player_2;
         dC = duels1Decrypt[index].decrypted;
         tS  = duels1Decrypt[index].timeStamp;
     }

     function getFirstActiveDuel2() constant returns(uint fAD2) {
         return firstActiveDuel2;}
     function getLastDuel2() constant returns(uint lD2) {
         return duels2Decrypt.length;}
     function getDuel2(uint index) constant returns(address p1, address p2, bool dC, uint256 tS) {
         p1 = duels2Decrypt[index].player_1;
         p2 = duels2Decrypt[index].player_2;
         dC = duels2Decrypt[index].decrypted;
         tS  = duels2Decrypt[index].timeStamp;
     }

     function getPlayerWaiting() constant returns(address p, bool full) {
         p = playerWaiting.player;
         full = playerWaiting.full;
     }

     function getLastResult() constant returns(uint lD2) {
         return results.length;}
     function getResults(uint index) constant returns(address p1, string h1, address p2, string h2, uint r) {
         p1 = results[index].player_1;
         h1 = results[index].hand_1;
         p2 = results[index].player_2;
         h2 = results[index].hand_2;
         r = results[index].result;
     }


}