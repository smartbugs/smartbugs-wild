pragma solidity ^0.4.6;

//
//  This is an Ethereum Race ( and coder challenge )
//
//  To support this game please make sure you check out the sponsor in the public sponsor variable of each game
//
//  how to play:
//
//  1) 20 racers can register, race starting fee is 50 ether per entry (only one entry per person allowed!)
//  2) Once 20 racers have registered, anyone can start the race by hitting the start_the_race() function
//  3) Once the race has started, every racer has to hit the drive() function as often as they can
//  4) After approx 30 mins (~126 blocks) the race ends, and the winner can claim his price
//         (price is all entry fees, as well as whatever was in the additional_price_money pool to start with )
//      
//  Please note that we'll try to find a different sponsor for each race (who contributes to the additional_price_money pool)
//  Dont forget to check out the sponsor of this game!
//
//  Please send any comments or questions about this game to philipp.burkard@yahoo.com, I will try to respond within a day.
//  Languages spoken: English, German, a little Spanish
//

contract TheGreatEtherRace {

   mapping(uint256 => address) public racers; //keeps racers (index 1..total_racers)
   mapping(address => uint256) public racer_index; // address to index
   
   mapping(address => uint256) public distance_driven; // keeps track of the race/progress of players
   
   string public sponsor;
   
   uint256 public total_racers;      // number of racers, once reached the race can start
   uint256 public registered_racers; // how many racers do we have already
   uint256 public registration_fee;  // how much is it to participate
   uint256 public additional_price_money;
   uint256 public race_start_block;  // block number that indicates when the race starts (set after everyone has signed up)
   
   address public winner;
   
   address developer_address; // to give developer his 5 ether fee
   address creator;

   enum EvtStatus { SignUp, ReadyToStart, Started, Finished }
   EvtStatus public eventStatus;
   
   function getStatus() constant returns (string) {
       if (eventStatus == EvtStatus.SignUp) return "SignUp";
       if (eventStatus == EvtStatus.ReadyToStart) return "ReadyToStart";
       if (eventStatus == EvtStatus.Started) return "Started";
       if (eventStatus == EvtStatus.Finished) return "Finished";
   }
   
   function additional_incentive() public payable { // additional ether to win, on top of other racers contribution
       additional_price_money += msg.value;
   }
   
   function TheGreatEtherRace(string p_sponsor){ // create the contract
       sponsor = p_sponsor;
       total_racers = 20;
       registered_racers = 0;
       registration_fee = 50 ether;
       eventStatus = EvtStatus.SignUp;
       developer_address = 0x6d5719Ff464c6624C30225931393F842E3A4A41a;
       creator = msg.sender;
   }
   
   /// 1) SIGN UP FOR THE RACE (only one entry per person allowed)
   
   function() payable { // buy starting position by simply transferring 
        uint store;
        if ( msg.value < registration_fee ) throw;    // not enough paid to 
        if ( racer_index[msg.sender] > 0  ) throw;    // already part of the race
        if ( eventStatus != EvtStatus.SignUp ) throw; // are we still in signup phase
        
        registered_racers++;
        racer_index[msg.sender] = registered_racers;  // store racer index/position
        racers[registered_racers] = msg.sender;       // store racer by index/position
        if ( registered_racers >= total_racers){      // race is full, lets begin..
            eventStatus = EvtStatus.ReadyToStart;     // no more buy in's possible
            race_start_block = block.number + 42;  // race can start ~ 10 minutes after last person has signed up
        }
   }
   
   /// 2) START THE RACE
   
   function start_the_race() public {
       if ( eventStatus != EvtStatus.ReadyToStart ) throw; // race is not ready to be started yet
       if (block.number < race_start_block) throw;            // race starting block not yet reached
       eventStatus = EvtStatus.Started;
   }
   
   /// 3) DRIVE AS FAST AS YOU CAN (hit this function as often as you can within the next 30 mins )
   function drive() public {
       if ( eventStatus != EvtStatus.Started ) throw;
       
       if ( block.number > race_start_block + 126 ){ 
           
           eventStatus = EvtStatus.Finished;
           
           // find winner
           winner = racers[1];
           for (uint256 idx = 2; idx <= registered_racers; idx++){
               if ( distance_driven[racers[idx]] > distance_driven[winner]  ) // note: in case of equal distance, the racer who signed up earlier wins
                    winner = racers[idx];
           }
           return;
       }
       distance_driven[msg.sender]++; // drive 1 unit
   }
   
   // 4) CLAIM WINNING MONEY
   
   function claim_price_money() public {
       
       if  (eventStatus == EvtStatus.Finished){
                uint winning_amount = this.balance - 5 ether;  // balance minus 5 ether fee
                if (!winner.send(winning_amount)) throw;       // send to winner
                if (!developer_address.send(5 ether)) throw;   // send 5 ether to developer
       }
       
   }

   
   // cleanup no earlier than 3 days after race (to allow for enough time to claim), or while noone has yet registered
   function cleanup() public {
       if (msg.sender != creator) throw;
       if (
             registered_racers == 0 ||    // noone has yet registered
             eventStatus == EvtStatus.Finished && block.number > race_start_block + 18514 // finished, and 3 days have passed
          ){
           selfdestruct(creator);
       } 
       else throw;
   }
    
}