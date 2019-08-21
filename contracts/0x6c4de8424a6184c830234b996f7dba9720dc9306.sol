pragma solidity ^0.4.24;

/***
 *     ____ _  _    __ _ __ _  __   ___ __ _ __  _  _ ____ 
 *    (___ ( \/ )  (  / (  ( \/  \ / __(  / /  \/ )( (_  _)
 *     / __/)  (    )  (/    (  O ( (__ )  (  O ) \/ ( )(  
 *    (____(_/\_)  (__\_\_)__)\__/ \___(__\_\__/\____/(__) 
 * 
 *                         HAMSTER LEAGUE
 *                     
 *                     https://2Xknockout.me
 * 
 * Community:
 * https://discord.gg/GKHnMBs
 * http://t.me/Knockout2x
 * 
 */

contract XKnockoutHamster {
    
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
  uint256 base = 100000000000000000; //base is 0.1 ETH
  uint256 public startedAt = now; //every new deposit updates start timetoRegular
  uint256 public timeRemaining = 24 hours; //every +100 users in queue half decrease timeRemaining
  uint256 public devreward; //buy me a coffee
  uint public round = 1; //when time is up, contract resets automatically to next round
  uint public shift = 0; //regular queue shift
  uint public joined = 0; //stats
  uint public exited = 0; //stats
  bool public timetoRegular = true; //flag to switch queue
  
  constructor() public {
     dev = msg.sender;
  }
  
  function() public payable {
    if(checkRemaining()) { msg.sender.transfer(msg.value); 
    } else {
        if(msg.value == base) {
            addToList();
        } else if(msg.value == base.div(10)) {
            up();
        } else {
            revert("You should send 0.1 ETH to join the list or 0.01 ETH to up");
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
    
      if(timetoRegular) {
        //Regular queue  
        entityStructs[entityList[shift]].profit += base;
          if(entityStructs[entityList[shift]].profit == 2*base) {
              entityStructs[entityList[shift]].active = false;
              entityStructs[entityList[shift]].exit = now;
              entityList[shift].transfer( entityStructs[entityList[shift]].profit.mul(90).div(100) );
              devreward += entityStructs[entityList[shift]].profit.mul(10).div(100);
              exitREG();
              exited++;
              //Switch queue to vip
              if(lastVIPkey() != 9999) {
                  if(vipList[lastVIPkey()] != address(0)) timetoRegular = false;
              }
          }

      } else if (!timetoRegular) {
        //VIP queue
        uint lastVIP = lastVIPkey();
        entityStructs[vipList[lastVIP]].profit += base;
          if(entityStructs[vipList[lastVIP]].profit == 2*base) {
              entityStructs[vipList[lastVIP]].active = false;
              entityStructs[vipList[lastVIP]].exit = now;
              vipList[lastVIP].transfer( entityStructs[vipList[lastVIP]].profit.mul(90).div(100) );
              devreward += entityStructs[vipList[lastVIP]].profit.mul(10).div(100);
              exitVIP(vipList[lastVIP]);
              exited++;
              //Switch queue to regular
              timetoRegular = true;
          }     
      }
  }
  
  function up() internal {
      if(joined.sub(exited) < 3) revert("You are too alone to up");
      if(!entityStructs[msg.sender].active) revert("You are not in the list");
      if(entityStructs[msg.sender].vip && (now.sub(entityStructs[msg.sender].update)) < 600) revert ("Up allowed once per 10 min");
      
      if(!entityStructs[msg.sender].vip) {
          
          /*
           * When somebody UP first time, he gives an amazing chance to last one in the list
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
    delete entityList[shift];
    shift++;
    return true;
  }
  
  function getVipCount() public constant returns(uint entityCount) {
    return vipList.length;
  }

  function newVip(address entityAddress, bool entityData) internal returns(bool success) {
    entityStructs[entityAddress].vip = entityData;
    entityStructs[entityAddress].listPointer = vipList.push(entityAddress) - 1;
    return true;
  }

  function exitVIP(address entityAddress) internal returns(bool success) {
    //Supa dupa method to deal with arrays ^_^ 
    uint rowToDelete = entityStructs[entityAddress].listPointer;
    address keyToMove = vipList[vipList.length-1];
    vipList[rowToDelete] = keyToMove;
    entityStructs[keyToMove].listPointer = rowToDelete;
    vipList.length--;
    return true;
  }
  
  function lastVIPkey() public constant returns(uint) {
    //Dealing with arrays in Solidity is painful x_x
    if(vipList.length == 0) return 9999;
    uint limit = vipList.length-1;
    for(uint l=limit; l >= 0; l--) {
        if(vipList[l] != address(0)) {
            return l;
        } 
    }
    return 9999;
  }
  
  function lastREG() public view returns (address) {
     return entityList[shift];
  }
  
  function lastVIP() public view returns (address) {
      //Dealing with arrays in Solidity is painful x_x
      if(lastVIPkey() != 9999) {
        return vipList[lastVIPkey()];
      }
      return address(0);
  }
  
  function checkRemaining() public returns (bool) {
      /* If time has come, reset the contract
       * It's public because of possible gas issues, but nothing can happen
       * while now < timeRemaining.add(startedAt)
       */
      if(now >= timeRemaining.add(startedAt)) {
        //Killing VIP struct
        if(vipList.length > 0) {
            uint limit = vipList.length-1;
            for(uint l=limit; l >= 0; l--) {
                if(vipList[l] != address(0)) {
                    entityStructs[vipList[l]].active = false;
                    entityStructs[vipList[l]].vip = false;
                    entityStructs[vipList[l]].date = 0;
                } 
            }
        }
        //Killing Regular struct
        if(shift < entityList.length-1) {
            for(uint r = shift; r < entityList.length-1; r++) {
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
    * and decreased gas limit up to 200k. 
    * Lame auditors who can't understand the code, ping me at Discord.
    * IF YOU RIP THIS CODE YOU WILL DIE WITH CANCER
    */
}