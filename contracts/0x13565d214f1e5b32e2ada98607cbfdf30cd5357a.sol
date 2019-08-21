pragma solidity ^0.4.24;

/***
 *     ____ _  _    __ _ __ _  __   ___ __ _ __  _  _ ____ 
 *    (___ ( \/ )  (  / (  ( \/  \ / __(  / /  \/ )( (_  _)
 *     / __/)  (    )  (/    (  O ( (__ )  (  O ) \/ ( )(  
 *    (____(_/\_)  (__\_\_)__)\__/ \___(__\_\__/\____/(__) 
 * 
 *                         REGULAR LEAGUE
 *                     
 *                     https://2Xknockout.me
 * 
 * COMMUNITY
 * https://discord.gg/GKHnMBs
 * http://t.me/Knockout2x
 * 
 * HOW IT WORKS
 * Join the queue and wait. Each new user moves you down. 
 * When you reach last place and someone join the list you will exit with X2
 * 
 * #   Users    Deposit        Description
 * 2 | USER B | 0.5 ETH | 0.5 ETH moves to USER A
 * 1 | USER A | 0.5 ETH | +0.5 ETH
 *   |  EXIT  |         | USER A exit with +1 ETH
 * 
 * FEATURES
 * -- VIP
 * Don't want to wait? Up your position in the list to penult place. Fee is 10% of league deposit and it is allowed once per 10 minutes.
 * -- TIMER & AUTO RESET
 * Timer is set for 24 hours. When it's up, queue drops and league starts over 
 * from the beginning. Every +100 new users in the list decrease remaining 
 * time by half. This is automated!
 * -- LUCKY CHANCE
 * When someone UP first time, he gives an amazing chance to the last one 
 * shift to his place at regular queue
 * -- JACKPOT ON RESET 
 * Any ETH stored at contract transfers to the latest VIP as a bonus
 * 
 * GAS LIMITS
 * Dealing with arrays in Solidity is a pain.
 * Set gas limit to 300000
 * In the wild it uses 160k-230k, but anyway set it to 300k (unused gas will refund)
 * 
 */

contract XKnockoutRegular2 {
    
  using SafeMath for uint256;

  struct EntityStruct {
    bool active;
    bool vip;
    uint listPointer;
    uint256 date;
    uint256 update;
    uint256 exit;
    uint256 profit;
  }
  
  mapping(address => EntityStruct) public entityStructs;
  address[] public entityList;
  address[] public vipList;
  address dev;
  uint256 base = 500000000000000000; //base is 0.5 ETH
  uint256 public startedAt = now; //every new deposit updates start timetoRegular
  uint256 public timeRemaining = 24 hours; //every +100 users in queue half decrease timeRemaining
  uint256 public devreward; //buy me a coffee
  uint public round = 1; //when time is up, contract will reset automatically to next round
  uint public shift = 0; //regular queue shift
  uint public joined = 0; //stats
  uint public exited = 0; //stats
  bool public timetoRegular = true; //flag to switch queue
  
  constructor() public {
     dev = msg.sender;
  }
  
  function() public payable {
    if(!checkRemaining()) { 
        if(msg.value == base) {
            addToList();
        } else if(msg.value == base.div(10)) {
            up();
        } else {
            revert("Send 0.5 ETH to join the list or 0.05 ETH to up");
        }   
    }
  }
  
  function addToList() internal {
      if(entityStructs[msg.sender].active) revert("You are already in the list");
      
      newEntity(msg.sender, true);
      joined++;
	  startedAt = now;
      entityStructs[msg.sender].date = now;
      entityStructs[msg.sender].profit = 0;
      entityStructs[msg.sender].update = 0;
      entityStructs[msg.sender].exit = 0;
      entityStructs[msg.sender].active = true;
      entityStructs[msg.sender].vip = false;
      
      /* EXIT */
    
      if(timetoRegular) {   
        //Regular exit
        entityStructs[entityList[shift]].profit += base;
        if(entityStructs[entityList[shift]].profit == 2*base) {
            exitREG();
        }
      } else {
        //VIP exit
        uint lastVIP = lastVIPkey();
        entityStructs[vipList[lastVIP]].profit += base;
          if(entityStructs[vipList[lastVIP]].profit == 2*base) {
              exitVIP(vipList[lastVIP]);
          }     
      }
  }
  
  function up() internal {
      if(joined.sub(exited) < 3) revert("You are too alone to up");
      if(!entityStructs[msg.sender].active) revert("You are not in the list");
      if(entityStructs[msg.sender].vip && (now.sub(entityStructs[msg.sender].update)) < 600) revert ("Up allowed once per 10 min");
      
      if(!entityStructs[msg.sender].vip) {
          
          /*
           * When somebody UP first time, he gives an amazing chance to the last one in the list
           * shift to his place at regular queue
           */
           
            uint rowToDelete = entityStructs[msg.sender].listPointer;
            address keyToMove = entityList[entityList.length-1];
            entityList[rowToDelete] = keyToMove;
            entityStructs[keyToMove].listPointer = rowToDelete;
            entityList.length--;
           
           //Add to VIP
           entityStructs[msg.sender].update = now;
           entityStructs[msg.sender].vip = true;
           newVip(msg.sender, true);
           
           devreward += msg.value; //goes to marketing
           
      } else if (entityStructs[msg.sender].vip) {
          
          //User up again
          entityStructs[msg.sender].update = now;
          delete vipList[entityStructs[msg.sender].listPointer];
          newVip(msg.sender, true);
          devreward += msg.value; //goes to marketing
      }
  }

  function newEntity(address entityAddress, bool entityData) internal returns(bool success) {
    entityStructs[entityAddress].active = entityData;
    entityStructs[entityAddress].listPointer = entityList.push(entityAddress) - 1;
    return true;
  }

  function exitREG() internal returns(bool success) {
    entityStructs[entityList[shift]].active = false;
    entityStructs[entityList[shift]].exit = now;
    entityList[shift].transfer( entityStructs[entityList[shift]].profit.mul(90).div(100) );
    devreward += entityStructs[entityList[shift]].profit.mul(10).div(100);
    exited++;
    delete entityList[shift];
    shift++;
    //Switch queue to vip
    if(lastVIPkey() != 9999) {
     timetoRegular = false;
    }
    return true;
  }

  function newVip(address entityAddress, bool entityData) internal returns(bool success) {
    entityStructs[entityAddress].vip = entityData;
    entityStructs[entityAddress].listPointer = vipList.push(entityAddress) - 1;
    return true;
  }

  function exitVIP(address entityAddress) internal returns(bool success) {
    uint lastVIP = lastVIPkey();
    entityStructs[vipList[lastVIP]].active = false;
    entityStructs[vipList[lastVIP]].exit = now;
    vipList[lastVIP].transfer( entityStructs[vipList[lastVIP]].profit.mul(90).div(100) );
    devreward += entityStructs[vipList[lastVIP]].profit.mul(10).div(100);
    //Supa dupa method to deal with arrays ^_^ 
    uint rowToDelete = entityStructs[entityAddress].listPointer;
    address keyToMove = vipList[vipList.length-1];
    vipList[rowToDelete] = keyToMove;
    entityStructs[keyToMove].listPointer = rowToDelete;
    vipList.length--;
    exited++;
    //Switch queue to regular
    timetoRegular = true;
    return true;
  }
  
    function lastREGkey() public constant returns(uint) {
        if(entityList.length == 0) return 9999;
        if(shift == entityList.length) return 9999; //empty reg queue
        
        uint limit = entityList.length-1;
        for(uint l=limit; l >= 0; l--) {
            if(entityList[l] != address(0)) {
                return l;
            } 
        }
        return 9999;
    }
  
  function lastVIPkey() public constant returns(uint) {
        if(vipList.length == 0) return 9999;
        uint limit = vipList.length-1;
        for(uint j=limit; j >= 0; j--) {
            if(vipList[j] != address(0)) {
                return j;
            } 
        }
        return 9999;
    }
  
  function checkRemaining() public returns (bool) {
      /* If time has come, reset the contract
       * It's public because of possible gas issues, but nothing can happen
       * while now < timeRemaining.add(startedAt)
       */
      if(now >= timeRemaining.add(startedAt)) {
        //Killing VIP struct
        if(lastVIPkey() != 9999) {
            uint limit = vipList.length-1;
            for(uint l=limit; l >= 0; l--) {
                if(vipList[l] != address(0)) {
                    entityStructs[vipList[l]].active = false;
                    entityStructs[vipList[l]].vip = false;
                    entityStructs[vipList[l]].date = 0;
                }
                if(l == 0) break;
            }
        }
        //Killing Regular struct
        if(lastREGkey() != 9999) {
            for(uint r = shift; r <= entityList.length-1; r++) {
                entityStructs[entityList[r]].active = false;
                entityStructs[entityList[r]].date = 0;
            }
        }
        //Buy me a coffee
        rewardDev();
        //If any ETH stored at contract, send it to latest VIP as a bonus
        if(address(this).balance.sub(devreward) > 0) {
            if(lastVIPkey() != 9999) {
                vipList[lastVIPkey()].transfer(address(this).balance);
            }
        }
        //Switch vars to initial state
        vipList.length=0;
        entityList.length=0;
        shift = 0;
        startedAt = now;
        timeRemaining = 24 hours;
        timetoRegular = true;
        exited = joined = 0;
        round++;
        return true;
      }
      
      //Decrease timeRemaining: every 100 users in queue divides it by half 
      uint range = joined.sub(exited).div(100);
      if(range != 0) {
        timeRemaining = timeRemaining.div(range.mul(2));  
      } 
      return false;
  }    
  
  function rewardDev() public {
      //No one can modify devreward constant, it's safe from manipulations
      dev.transfer(devreward);
      devreward = 0;
  }  
  
  function queueVIP() public view returns (address[]) {
      //Return durty queue
      return vipList;
  }
  
  function queueREG() public view returns (address[]) {
      //Return durty queue
      return entityList;
  }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    
   /* 
    * Message to other devs:
    * Dealing with arrays in Solidity is a pain. Here we realized some supa dupa methods
    * and decreased gas limit up to 220k. 
    * Lame auditors who can't understand the code, ping me at Discord.
    * IF YOU RIP THIS CODE YOU WILL DIE WITH CANCER
    */
}