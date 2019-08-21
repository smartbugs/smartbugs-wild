pragma solidity 0.4.18;

// File: contracts/KnowsConstants.sol

contract KnowsConstants {
    // 2/4/18 @ 6:30 PM EST, the deadline for bets
    uint public constant GAME_START_TIME = 1517787000;
}

// File: contracts/KnowsSquares.sol

// knows what a valid box is
contract KnowsSquares {
    modifier isValidSquare(uint home, uint away) {
        require(home >= 0 && home < 10);
        require(away >= 0 && away < 10);
        _;
    }
}

// File: contracts/interfaces/IKnowsTime.sol

interface IKnowsTime {
    function currentTime() public view returns (uint);
}

// File: contracts/KnowsTime.sol

// knows what time it is
contract KnowsTime is IKnowsTime {
    function currentTime() public view returns (uint) {
        return now;
    }
}

// File: contracts/interfaces/IKnowsVoterStakes.sol

interface IKnowsVoterStakes {
    function getVoterStakes(address voter, uint asOfBlock) public view returns (uint);
}

// File: contracts/interfaces/IScoreOracle.sol

interface IScoreOracle {
    function getSquareWins(uint home, uint away) public view returns (uint numSquareWins, uint totalWins);
    function isFinalized() public view returns (bool);
}

// File: zeppelin-solidity/contracts/math/Math.sol

/**
 * @title Math
 * @dev Assorted math operations
 */

library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/Squares.sol

contract Squares is KnowsConstants, KnowsTime, KnowsSquares, IKnowsVoterStakes {
    using SafeMath for uint;

    function Squares(IScoreOracle _oracle, address _developer) public {
        oracle = _oracle;
        developer = _developer;
    }

    // the oracle for the scores
    IScoreOracle public oracle;

    // the developer of the smart contract
    address public developer;

    // staked ether for each player and each box
    mapping(address => uint[10][10]) public totalSquareStakesByUser;

    // total stakes for each box
    uint[10][10] public totalSquareStakes;

    // the total stakes for each user
    mapping(address => uint) public totalUserStakes;

    // the overall total of money stakes in the grid
    uint public totalStakes;

    event LogBet(address indexed better, uint indexed home, uint indexed away, uint stake);

    function bet(uint home, uint away) public payable isValidSquare(home, away) {
        require(msg.value > 0);
        require(currentTime() < GAME_START_TIME);

        // the stake is the message value
        uint stake = msg.value;

        // add the stake amount to the overall total
        totalStakes = totalStakes.add(stake);

        // add their stake to the total user stakes
        totalUserStakes[msg.sender] = totalUserStakes[msg.sender].add(stake);

        // add their stake to their own accounting
        totalSquareStakesByUser[msg.sender][home][away] = totalSquareStakesByUser[msg.sender][home][away].add(stake);

        // add it to the total stakes as well
        totalSquareStakes[home][away] = totalSquareStakes[home][away].add(stake);

        LogBet(msg.sender, home, away, stake);
    }

    event LogPayout(address indexed winner, uint payout, uint donation);

    // calculate the winnings owed for a user's bet on a particular square
    function getWinnings(address user, uint home, uint away) public view returns (uint winnings) {
        // the square wins and the total wins are used to calculate
        // the percentage of the total stake that the square is worth
        var (numSquareWins, totalWins) = oracle.getSquareWins(home, away);

        return totalSquareStakesByUser[user][home][away]
            .mul(totalStakes)
            .mul(numSquareWins)
            .div(totalWins)
            .div(totalSquareStakes[home][away]);
    }

    // called by the winners to collect winnings for a box
    function collectWinnings(uint home, uint away, uint donationPercentage) public isValidSquare(home, away) {
        // score must be finalized
        require(oracle.isFinalized());

        // optional donation
        require(donationPercentage <= 100);

        // we cannot pay out more than we have
        // but we should not prevent paying out what we do have
        // this should never happen since integer math always truncates, we should only end up with too much
        // however it's worth writing in the protection
        uint winnings = Math.min256(this.balance, getWinnings(msg.sender, home, away));

        require(winnings > 0);

        // the donation amount
        uint donation = winnings.mul(donationPercentage).div(100);

        uint payout = winnings.sub(donation);

        // clear their stakes - can only collect once
        totalSquareStakesByUser[msg.sender][home][away] = 0;

        msg.sender.transfer(payout);
        developer.transfer(donation);

        LogPayout(msg.sender, payout, donation);
    }

    function getVoterStakes(address voter, uint asOfBlock) public view returns (uint) {
        return totalUserStakes[voter];
    }
}