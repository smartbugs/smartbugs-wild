/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

contract Clicker  {

    using SafeMath for uint;

    uint public points;
    uint public pps; // points per second
    uint public multiplier;
    uint public upgrades;
    uint public basecost;
    uint public ppsBase;
    uint public checkpoint = now;

    function Clicker() public {
        _reset();
    }

    function upgrade() external {
        claimPoints();

        uint cost = getCost();

        points = points.sub(cost);
        pps = pps.add(ppsBase);
        upgrades = upgrades.add(1);
    }

    function calculatePoints() public view returns (uint) {
        uint secondsPassed = now.sub(checkpoint);
        uint pointsEarned = secondsPassed.mul(pps);
        return points.add(pointsEarned);
    }

    function getCost() public view returns (uint) {
        return basecost.mul(multiplier ** upgrades);
    }

    function claimPoints() public {
        points = calculatePoints();
        checkpoint = now;
    }

    function won() public view returns (bool) {
        uint secondsPassed = now - checkpoint;
        uint pointsEarned = secondsPassed * pps;
        uint total = points + pointsEarned;
        // If we overflow then we win
        if (total < points) {
            return true;
        }
        return false;
    }

    function prestige() external {
        require(won());
        _reset();
    }

    function _reset() internal {
        points = 1;
        pps = 1;
        multiplier = 2;
        upgrades = 1;
        basecost = 1;
        ppsBase = ppsBase.add(1); // each prestige we increase the pps base
        checkpoint = now;
    }

    function getLevel() external view returns (uint) {
        return ppsBase;
    }
}