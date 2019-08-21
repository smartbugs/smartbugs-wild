pragma solidity ^0.5.7;

/* SNAILNUMBER

Simple game contract to let players pick a magic number.
The number has no importance in itself, but will be used in another game!

Players must bid higher than the previous bid to enter their number.
Whoever has the highest bid at the end of a 24 hours period wins.
The winner gets a share of all the ETH, based on how quickly he bid.
The rest of the ETH is sent to SnailThrone as divs.

*/

contract SnailNumber {
	using SafeMath for uint;
	
	event GameBid (address indexed player, uint eth, uint number, uint pot, uint winnerShare);
	event GameEnd (address indexed player, uint leaderReward, uint throneReward, uint number);
	
	address payable constant SNAILTHRONE= 0x261d650a521103428C6827a11fc0CBCe96D74DBc;
    uint256 constant SECONDS_IN_DAY = 86400;
    uint256 constant numberMin = 300;
    uint256 constant numberMax = 3000;
    
    uint256 public pot;
    uint256 public bid;
    address payable public leader;
    uint256 public shareToWinner;
    uint256 public shareToThrone;
    uint256 public timerEnd;
    uint256 public timerStart;
    uint256 public number;
    
    address payable dev;
    
    // CONSTRUCTOR
    // Sets end timer to 24 hours
    
    constructor() public {
        timerStart = now;
        timerEnd = now.add(SECONDS_IN_DAY);
        dev = msg.sender;
    }
    
    // BID
    // Lets player pick number
    // Locks his potential winnings
    
    function Bid(uint256 _number) payable public {
        require(now < timerEnd, "game is over!");
        require(msg.value > bid, "not enough to beat current leader");
        require(_number >= numberMin, "number too low");
        require(_number <= numberMax, "number too high");

        pot = pot.add(msg.value);
        shareToWinner = ComputeShare();
        uint256 _share = 100;
        shareToThrone = _share.sub(shareToWinner);
        leader = msg.sender;
        number = _number;
            
        emit GameBid(msg.sender, msg.value, number, pot, shareToWinner);
    }
    
    // END 
    // Can be called manually after the game ends
    // Sends pot to winner and snailthrone
    
    function End() public {
        require(now > timerEnd, "game is still running!");
        
        uint256 _throneReward = pot.mul(shareToThrone).div(100);
        pot = pot.sub(_throneReward);
        (bool success, bytes memory data) = SNAILTHRONE.call.value(_throneReward)("");
        require(success);
        
        uint256 _winnerReward = pot;
        pot = 0;
        leader.transfer(_winnerReward);
        
        emit GameEnd(leader, _winnerReward, _throneReward, number);
    }
    
    // COMPUTESHARE 
    // Calculates the share of the winner and of the throne, based on time lapsed
    // Decreasing % from 100 to 0. The earlier the bid, the more money
    
    function ComputeShare() public view returns(uint256) {
        uint256 _length = timerEnd.sub(timerStart);
        uint256 _currentPoint = timerEnd.sub(now);
        return _currentPoint.mul(100).div(_length);
    }
    
    // ESCAPEHATCH
    // Just in case a bug stops the "End" function, dev can withdraw all ETH
    // But *only* a full day after the game has already ended!
    
    function EscapeHatch() public {
        require(msg.sender == dev, "you're not the dev");
        require(now > timerEnd.add(SECONDS_IN_DAY), "escape hatch only available 24h after end");
        
        dev.transfer(address(this).balance);
    }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}