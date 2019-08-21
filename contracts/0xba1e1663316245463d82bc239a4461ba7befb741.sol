pragma solidity ^0.4.18;

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
library ContractHelpers {
  function isContract(address addr) internal view returns (bool) {
      uint size;
      assembly { size := extcodesize(addr) }
      return size > 0;
    }
}

contract BetWinner is Ownable {
  address owner;

  // team has name and its total bet amount and bettors
  struct Team {
    string name;
    uint256 bets;
    address[] bettors;
    mapping(address => uint256) bettorAmount;
  }

  Team[] teams;
  uint8 public winningTeamIndex = 255; // 255 => not set

  // payout table for winners
  mapping(address => uint256) public payOuts;

  bool public inited;

  // timestamps
  uint32 public bettingStart;
  uint32 public bettingEnd;
  uint32 public winnerAnnounced;

  uint8 public feePercentage;
  uint public minimumBet;
  uint public totalFee;

  // events
  event BetPlaced(address indexed _from, uint8 indexed _teamId, uint _value);
  event Withdraw(address indexed _to, uint _value);
  event Started(uint bettingStartTime, uint numberOfTeams);
  event WinnerAnnounced(uint8 indexed teamIndex);

  // constructor
  function BetWinner() public Ownable() {
    feePercentage = 2;
    minimumBet = 100 szabo;
  }

  // get bettingStart, bettingEnd, winnerAnnounced, winnerIndex, teams count
  function betInfo() public view returns (uint32, uint32, uint32, uint8, uint) {
    return (bettingStart, bettingEnd, winnerAnnounced, winningTeamIndex, teams.length);
  }
  function bettingStarted() private view returns (bool) {
    return now >= bettingStart;
  }
  function bettingEnded() private view returns (bool) {
    return now >= bettingEnd;
  }

  // remember to add all teams before calling startBetting
  function addTeam(string _name) public onlyOwner {
    require(!inited);
    Team memory t = Team({
      name: _name,
      bets: 0,
      bettors: new address[](0)
    });
    teams.push(t);
  }
  
  // set betting start and stop times. after that teams cannot be added
  function startBetting(uint32 _bettingStart, uint32 _bettingEnd) public onlyOwner {
    require(!inited);

    bettingStart = _bettingStart;
    bettingEnd = _bettingEnd;

    inited = true;

    Started(bettingStart, teams.length - 1);
  }

  // get total bet amount for address for team
  function getBetAmount(uint8 teamIndex) view public returns (uint) {
    return teams[teamIndex].bettorAmount[msg.sender];
  }

  // get team data (name, total bets, bettor count)
  function getTeam(uint8 teamIndex) view public returns (string, uint, uint) {
    Team memory t = teams[teamIndex];
    return (t.name, t.bets, t.bettors.length);
  }

  // get total bets for every team
  function totalBets() view public returns (uint) {
    uint total = 0;
    for (uint i = 0; i < teams.length; i++) {
      total += teams[i].bets;
    }
    return total;
  }

  // place bet to team
  function bet(uint8 teamIndex) payable public {
    // betting has to be started and not ended and winningTeamIndex must be 255 (not announced)
    require(bettingStarted() && !bettingEnded() && winningTeamIndex == 255);
    // value must be at least minimum bet
    require(msg.value >= minimumBet);
    // must not be smart contract address
    require(!ContractHelpers.isContract(msg.sender));
    // check that we have team in that index we are betting
    require(teamIndex < teams.length);

    // get storage ref
    Team storage team = teams[teamIndex];
    // add bet to team
    team.bets += msg.value;

    // if new bettor, save address for paying winnings
    if (team.bettorAmount[msg.sender] == 0) {
      team.bettors.push(msg.sender);
    }

    // send event
    BetPlaced(msg.sender, teamIndex, msg.value);
    // add bettor betting amount, so we can pay correct amount if win
    team.bettorAmount[msg.sender] += msg.value;
  }

  // calculate fee from the losing portion of total pot
  function removeFeeAmount(uint totalPot, uint winnersPot) private returns(uint) {
    uint remaining = SafeMath.sub(totalPot, winnersPot);
    // if we only have winners, take no fee
    if (remaining == 0) {
      return 0;
    }

    // calculate fee
    uint feeAmount = SafeMath.div(remaining, 100);
    feeAmount = feeAmount * feePercentage;

    totalFee = feeAmount;
    // return loser side pot - fee = winnings
    return remaining - feeAmount;
  }

  // announce winner
  function announceWinner(uint8 teamIndex) public onlyOwner {
    // ensure we have a team here
    require(teamIndex < teams.length);
    // ensure that betting is ended before announcing winner and winner has not been announced
    require(bettingEnded() && winningTeamIndex == 255);
    winningTeamIndex = teamIndex;
    winnerAnnounced = uint32(now);

    WinnerAnnounced(teamIndex);
    // calculate payouts for winners
    calculatePayouts();
  }

  // calculate payouts
  function calculatePayouts() private {
    uint totalAmount = totalBets();
    Team storage wt = teams[winningTeamIndex];
    uint winTeamAmount = wt.bets;
    // if we have no winners, no need to do anything
    if (winTeamAmount == 0) {
      return;
    }

    // substract fee
    uint winnings = removeFeeAmount(totalAmount, winTeamAmount);

    // calc percentage of total pot for every winner bettor
    for (uint i = 0; i < wt.bettors.length; i++) {
      // get bet amount
      uint betSize = wt.bettorAmount[wt.bettors[i]];
      // get bettor percentage of pot
      uint percentage = SafeMath.div((betSize*100), winTeamAmount);
      // calculate winnings
      uint payOut = winnings * percentage;
      // add winnings and original bet = total payout
      payOuts[wt.bettors[i]] = SafeMath.div(payOut, 100) + betSize;
    }
  }

  // winner can withdraw payout after winner is announced
  function withdraw() public {
    // check that we have winner announced
    require(winnerAnnounced > 0 && uint32(now) > winnerAnnounced);
    // check that we have payout calculated for address.
    require(payOuts[msg.sender] > 0);

    // no double withdrawals
    uint po = payOuts[msg.sender];
    payOuts[msg.sender] = 0;

    Withdraw(msg.sender, po);
    // transfer payout to sender
    msg.sender.transfer(po);
  }

  // withdraw owner fee when winner is announced
  function withdrawFee() public onlyOwner {
    require(totalFee > 0);
    // owner cannot withdraw fee before winner is announced. This is incentive for contract owner to announce winner
    require(winnerAnnounced > 0 && now > winnerAnnounced);
    // make sure owner cannot withdraw more than fee amount
    msg.sender.transfer(totalFee);
    // set total fee to zero, so owner cannot empty whole contract
    totalFee = 0;
  }

  // cancel and set all bets to payouts
  function cancel() public onlyOwner {
    require (winningTeamIndex == 255);
    winningTeamIndex = 254;
    winnerAnnounced = uint32(now);

    Team storage t = teams[0];
    for (uint i = 0; i < t.bettors.length; i++) {
      payOuts[t.bettors[i]] += t.bettorAmount[t.bettors[i]];
    }
    Team storage t2 = teams[1];
    for (i = 0; i < t2.bettors.length; i++) {
      payOuts[t2.bettors[i]] += t2.bettorAmount[t2.bettors[i]];
    }
  }

  // can kill contract after winnerAnnounced + 8 weeks
  function kill() public onlyOwner {
    // cannot kill contract before winner is announced and it's been announced at least for 8 weeks
    require(winnerAnnounced > 0 && uint32(now) > (winnerAnnounced + 8 weeks));
    selfdestruct(msg.sender);
  }

  // prevent eth transfers to this contract
  function () public payable {
    revert();
  }
}