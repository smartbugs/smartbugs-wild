pragma solidity >=0.5.0 <0.6.0;


// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: lib/CanReclaimToken.sol
/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {

  /**
   * @dev Reclaim all ERC20 compatible tokens
   * @param token ERC20 The address of the token contract
   */
  function reclaimToken(IERC20 token) external onlyOwner {
    address payable owner = address(uint160(owner()));

    if (address(token) == address(0)) {
      owner.transfer(address(this).balance);
      return;
    }
    uint256 balance = token.balanceOf(address(this));
    token.transfer(owner, balance);
  }

}

// File: lib/PPQueue.sol
/**
 * @title PPQueue
 */
library PPQueue {
  struct Item {
    //    uint idx;
    bool exists;
    uint prev;
    uint next;
  }

  struct Queue {
    uint length;
    uint first;
    uint last;
    uint counter;
    mapping (uint => Item) items;
  }

  /**
   * @dev push item to fifo queue
   */
  function push(Queue storage queue, uint index) internal {
    require(!queue.items[index].exists);
    queue.items[index] = Item({
      exists: true,
      prev: queue.last,
      next: 0
      });

    if (queue.length == 0) {
      queue.first = index;
    } else {
      queue.items[queue.last].next = index;
    }

    //save last item queue idx
    queue.last = index;
    queue.length++;
  }

  /**
  * @dev pop item from fifo queue
  */
  function popf(Queue storage queue) internal returns (uint index) {
    index = queue.first;
    remove(queue, index);
  }

  /**
  * @dev pop item from lifo queue
  */
  function popl(Queue storage queue) internal returns (uint index) {
    index = queue.last;
    remove(queue, index);
  }

  /**
   * @dev remove an item from queue
   */
  function remove(Queue storage queue, uint index) internal {
    require(queue.length > 0);
    require(queue.items[index].exists);


    if (queue.items[index].prev != 0) {
      queue.items[queue.items[index].prev].next = queue.items[index].next;
    } else {
      //assume we delete first item
      queue.first = queue.items[index].next;
    }

    if (queue.items[index].next != 0) {
      queue.items[queue.items[index].next].prev = queue.items[index].prev;
    } else {
      //assume we delete last item
      queue.last = queue.items[index].prev;
    }
    //del from queue
    delete queue.items[index];
    queue.length--;

  }

  /**
  * @dev get queue length
  * @return uint
  */
  function len(Queue storage queue) internal view returns (uint) {
    //auto prevent existing of agents with updated address and same id
    return queue.length;
  }
}

// File: openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

// File: contracts/Referrals.sol

interface Affiliates {
  function plusByCode(address _token, uint256 _affCode, uint _amount) external payable;
  function upAffCode(uint256 _affCode) external view returns (uint);
  function setUpAffCodeByAddr(address _address, uint _upAffCode) external;
  function getAffCode(uint256 _a) external pure returns (uint);
  function sendAffReward(address _token, address _address) external returns (uint);
}

contract Referrals is Ownable, ReentrancyGuard {
  using SafeMath for uint;

  //1% - 100, 10% - 1000 50% - 5000
  uint256[] public affLevelReward;
  Affiliates public aff;

  constructor (address _aff) public {
    require(_aff != address(0));
    aff = Affiliates(_aff);

    // two upper levels for each: winner and loser
    // total sum of level's % must be 100%
    //1% - 100, 10% - 1000 50% - 5000
    affLevelReward.push(0); // level 0, 10% - player self - cacheback
    affLevelReward.push(8000); // level 1, 70% of affPool
    affLevelReward.push(2000); // level 2, 20% of affPool
  }


  //AFFILIATES
  function setAffiliateLevel(uint256 _level, uint256 _rewardPercent) external onlyOwner {
    require(_level < affLevelReward.length);
    affLevelReward[_level] = _rewardPercent;
  }

  function incAffiliateLevel(uint256 _rewardPercent) external onlyOwner {
    affLevelReward.push(_rewardPercent);
  }

  function decAffiliateLevel() external onlyOwner {
    delete affLevelReward[affLevelReward.length--];
  }

  function affLevelsCount() external view returns (uint) {
    return affLevelReward.length;
  }

  function _distributeAffiliateReward(uint256 _sum, uint256 _affCode, uint256 _level, bool _cacheBack) internal {
    uint upAffCode = aff.upAffCode(_affCode);

    if (affLevelReward[_level] > 0 && _affCode != 0 && (_level > 0 || (_cacheBack && upAffCode != 0))) {
      uint total = _getPercent(_sum, affLevelReward[_level]);
      aff.plusByCode.value(total)(address(0x0), _affCode, total);
    }

    if (affLevelReward.length > ++_level) {
      _distributeAffiliateReward(_sum, upAffCode, _level, false);
    }
  }

  function getAffReward() external nonReentrant {
    aff.sendAffReward(address(0x0), msg.sender);
  }

  //1% - 100, 10% - 1000 50% - 5000
  function _getPercent(uint256 _v, uint256 _p) internal pure returns (uint)    {
    return _v.mul(_p) / 10000;
  }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol
/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: lib/ServiceRole.sol
contract ServiceRole {
  using Roles for Roles.Role;

  event ServiceAdded(address indexed account);
  event ServiceRemoved(address indexed account);

  Roles.Role private services;

  constructor() internal {
    _addService(msg.sender);
  }

  modifier onlyService() {
    require(isService(msg.sender));
    _;
  }

  function isService(address account) public view returns (bool) {
    return services.has(account);
  }

  function renounceService() public {
    _removeService(msg.sender);
  }

  function _addService(address account) internal {
    services.add(account);
    emit ServiceAdded(account);
  }

  function _removeService(address account) internal {
    services.remove(account);
    emit ServiceRemoved(account);
  }
}

// File: contracts/Services.sol
contract Services is Ownable,ServiceRole {
  constructor() public{

  }

  function addService(address account) external onlyOwner {
    _addService(account);
  }

  function removeService(address account) external onlyOwner {
    _removeService(account);
  }

}

// File: contracts/BetLevels.sol
contract BetLevels is Ownable {

  //value => level
  mapping(uint => uint) betLevels;
  //array of avail bets values
  uint[] public betLevelValues;

  constructor () public {
    //zero level = 0, skip it
    betLevelValues.length += 8;
    _setBetLevel(1, 0.01 ether);
    _setBetLevel(2, 0.05 ether);
    _setBetLevel(3, 0.1 ether);
    _setBetLevel(4, 0.5 ether);
    _setBetLevel(5, 1 ether);
    _setBetLevel(6, 5 ether);
    _setBetLevel(7, 10 ether);
  }

  function addBetLevel(uint256 value) external onlyOwner {
    require(betLevelValues.length == 0 || betLevelValues[betLevelValues.length - 1] < value);
    betLevelValues.length++;
    _setBetLevel(betLevelValues.length - 1, value);
  }

  function _setBetLevel(uint level, uint value) internal {
    betLevelValues[level] = value;
    betLevels[value] = level;
  }

  function setBetLevel(uint level, uint value) external onlyOwner {
    require(betLevelValues.length > level);
    require(betLevelValues[level] != value);
    delete betLevels[betLevelValues[level]];
    _setBetLevel(level, value);
  }

  function betLevelsCount() external view returns (uint) {
    return betLevelValues.length;
  }

  function getBetLevel(uint value) internal view returns (uint level) {
    level = betLevels[value];
    require(level != 0);
  }
}

// File: contracts/BetIntervals.sol
contract BetIntervals is Ownable {
  event SetInterval(uint startsFrom, uint pastCount, uint newInterval, uint newPeriod);

  uint public constant BetEpoch = 1550534400; //Tuesday, 19 February 2019 г., 0:00:00


  struct RoundInterval {
    uint interval;
    uint from;
    uint count;
    uint period;
  }
  RoundInterval[] public intervalHistory;

  constructor() public{
    intervalHistory.push(RoundInterval({
      period : 10 * 60,
      from : BetEpoch,
      count : 0,
      interval : 15 * 60
      }));
  }

  function setInterval(uint _interval, uint _period) external onlyOwner {
    RoundInterval memory i = _getRoundIntervalAt(now);
    uint intervalsCount = (now - i.from) / i.interval + 1;
    RoundInterval memory ni = RoundInterval({
      interval : _interval,
      from : i.from + i.interval * intervalsCount,
      count : intervalsCount + i.count,
      period : _period
      });
    intervalHistory.push(ni);
    emit SetInterval(ni.from, ni.count, _interval, _period);
  }

  function getCurrentRoundId() public view returns (uint) {
    return getRoundIdAt(now, 0);
  }

  function getNextRoundId() public view returns (uint) {
    return getRoundIdAt(now, 1);
  }

  function getRoundIdAt(uint _time, uint _shift) public view returns (uint) {
    uint intervalId = _getRoundIntervalIdAt(_time);
    RoundInterval memory i = intervalHistory[intervalId];
    return _time > i.from ? (_time - i.from) / i.interval + i.count + _shift : 0;

  }


  function getCurrentRoundInterval() public view returns (uint interval, uint period) {
    return getRoundIntervalAt(now);
  }

  function getRoundIntervalAt(uint _time) public view returns (uint interval, uint period) {
    RoundInterval memory i = _getRoundIntervalAt(_time);
    interval = i.interval;
    period = i.period;
  }

  function getCurrentRoundInfo() public view returns (
    uint roundId,
    uint startAt,
    uint finishAt
  ) {
    return getRoundInfoAt(now, 0);
  }

  function getNextRoundInfo() public view returns (
    uint roundId,
    uint startAt,
    uint finishAt
  ) {
    return getRoundInfoAt(now, 1);
  }

  function getRoundInfoAt(uint _time, uint _shift) public view returns (
    uint roundId,
    uint startAt,
    uint finishAt
  ) {
    RoundInterval memory i = _getRoundIntervalAt(_time);

    uint intervalsCount = _time > i.from ? (_time - i.from) / i.interval + _shift : 0;
    startAt = i.from + i.interval * intervalsCount;
    roundId = i.count + intervalsCount;
    finishAt = i.period + startAt;
  }


  function _getRoundIntervalAt(uint _time) internal view returns (RoundInterval memory) {
    return intervalHistory[_getRoundIntervalIdAt(_time)];
  }


  function _getRoundIntervalIdAt(uint _time) internal view returns (uint) {
    require(intervalHistory.length > 0);
    //    if (intervalHistory.length == 0) return 0;
    // Shortcut for the actual value
    if (_time >= intervalHistory[intervalHistory.length - 1].from)
      return intervalHistory.length - 1;
    if (_time < intervalHistory[0].from) return 0;

    // Binary search of the value in the array
    uint min = 0;
    uint max = intervalHistory.length - 1;
    while (max > min) {
      uint mid = (max + min + 1) / 2;
      if (intervalHistory[mid].from <= _time) {
        min = mid;
      } else {
        max = mid - 1;
      }
    }
    return min;
  }

}

// File: contracts/ReservedValue.sol

contract ReservedValue is Ownable {
  using SafeMath for uint;
  event Income(address source, uint256 amount);

  address payable public wallet;
  //total reserved eth amount
  uint256 public totalReserved;

  constructor(address payable _w) public {
    require(_w != address(0));
    wallet = _w;

  }

  function setWallet(address payable _w) external onlyOwner {
    require(address(_w) != address(0));
    wallet = _w;
  }

  /// @notice The fallback function payable
  function() external payable {
    require(msg.value > 0);
    _flushBalance();
  }

  function _flushBalance() internal {
    uint256 balance = address(this).balance.sub(totalReserved);
    if (balance > 0) {
      address(wallet).transfer(balance);
      emit Income(address(this), balance);
    }
  }

  function _incTotalReserved(uint value) internal {
    totalReserved = totalReserved.add(value);
  }

  function _decTotalReserved(uint value) internal {
    totalReserved = totalReserved.sub(value);
  }
}

// File: contracts/Bets.sol
contract Bets is Ownable, ReservedValue, BetIntervals, BetLevels, Referrals, Services, CanReclaimToken {
  using SafeMath for uint;

  event BetCreated(address indexed bettor, uint betId, uint index, uint allyRace, uint enemyRace, uint betLevel, uint value, uint utmSource);
  event BetAccepted(uint betId, uint opBetId, uint roundId);
  event BetCanceled(uint betId);
  event BetRewarded(uint winBetId, uint loseBetId, uint reward, bool noWin);
  event BetRoundCalculated(uint roundId, uint winnerRace, uint loserRace, uint betLevel, uint pool, uint bettorCount);
  event StartBetRound(uint roundId, uint startAt, uint finishAt);
  event RoundRaceResult(uint roundId, uint raceId, int32 result);
  event FinishBetRound(uint roundId, uint startCheckedAt, uint finishCheckedAt);

  using PPQueue for PPQueue.Queue;

  struct Bettor {
    uint counter;
    mapping(uint => uint) bets;
  }

  struct Race {
    uint index;
    bool exists;
    uint count;
    int32 result;
  }

  struct BetRound {
    uint startedAt;
    uint finishedAt;
    uint startCheckedAt;
    uint finishCheckedAt;
    uint[] bets;
    mapping(uint => Race) races;
    uint[] raceList;
  }

  uint[] public roundsList;

  //roundId => BetRound
  mapping(uint => BetRound) betRounds;

  struct Bet {
    address payable bettor;
    uint roundId;
    uint allyRace;
    uint enemyRace;
    uint value;
    uint level;
    uint opBetId;
    uint reward;
    bool active;
  }

  struct BetStat {
    uint sum;
    uint pool;
    uint affPool;
    uint count;
    bool taxed;
  }

  uint public lastBetId;
  mapping(uint => Bet)  bets;
  mapping(address => Bettor)  bettors;

  struct BetData {
    mapping(uint => BetStat) stat;
    PPQueue.Queue queue;
  }

  //betLevel => allyRace => enemyRace => BetData
  mapping(uint => mapping(uint => mapping(uint => BetData))) betData;

  //raceId => allowed
  mapping(uint => bool) public allowedRace;

  uint public systemFeePcnt;
  uint public affPoolPcnt;


  constructor(address payable _w, address _aff) ReservedValue(_w) Referrals(_aff) public payable {
    //    systemFee 5% (from loser sum)
    //    affPoolPercent 5% (from loser  sum)
    setFee(500, 500);

    //allow races, BTC,LTC,ETH by default
    allowedRace[1] = true;
    allowedRace[2] = true;
    allowedRace[4] = true;
    allowedRace[10] = true;
    allowedRace[13] = true;
  }

  function setFee(uint _systemFee, uint _affFee) public onlyOwner
  {
    systemFeePcnt = _systemFee;
    affPoolPcnt = _affFee;
  }

  function allowRace(uint _race, bool _allow) external onlyOwner {
    allowedRace[_race] = _allow;
  }

  function makeBet(uint allyRace, uint enemyRace, uint _affCode, uint _source) public payable {
    require(allyRace != enemyRace && allowedRace[allyRace] && allowedRace[enemyRace]);
    //require bet level exists
    uint level = getBetLevel(msg.value);

    Bet storage bet = bets[++lastBetId];
    bet.active = true;
    bet.bettor = msg.sender;
    bet.allyRace = allyRace;
    bet.enemyRace = enemyRace;
    bet.value = msg.value;
    bet.level = level;

    //save bet to bettor list && inc. bets count
    bettors[bet.bettor].bets[++bettors[bet.bettor].counter] = lastBetId;

    emit BetCreated(bet.bettor, lastBetId, bettors[bet.bettor].counter, allyRace, enemyRace, level, msg.value, _source);

    //upd queue
    BetData storage allyData = betData[level][allyRace][enemyRace];
    BetData storage enemyData = betData[level][enemyRace][allyRace];

    //if there is nobody on opposite side
    if (enemyData.queue.len() == 0) {
      allyData.queue.push(lastBetId);
    } else {
      //accepting bet
      uint nextRoundId = _startNextRound();
      uint opBetId = enemyData.queue.popf();
      bet.opBetId = opBetId;
      bet.roundId = nextRoundId;
      bets[opBetId].opBetId = lastBetId;
      bets[opBetId].roundId = nextRoundId;

      //upd fight stat
      allyData.stat[nextRoundId].sum = allyData.stat[nextRoundId].sum.add(msg.value);
      allyData.stat[nextRoundId].count++;

      enemyData.stat[nextRoundId].sum = enemyData.stat[nextRoundId].sum.add(bets[opBetId].value);
      enemyData.stat[nextRoundId].count++;
      if (!betRounds[nextRoundId].races[allyRace].exists) {
        betRounds[nextRoundId].races[allyRace].exists = true;
        betRounds[nextRoundId].races[allyRace].index = betRounds[nextRoundId].raceList.length;
        betRounds[nextRoundId].raceList.push(allyRace);
      }
      betRounds[nextRoundId].races[allyRace].count++;

      if (!betRounds[nextRoundId].races[enemyRace].exists) {
        betRounds[nextRoundId].races[enemyRace].exists = true;
        betRounds[nextRoundId].races[enemyRace].index = betRounds[nextRoundId].raceList.length;
        betRounds[nextRoundId].raceList.push(enemyRace);
      }
      betRounds[nextRoundId].races[enemyRace].count++;
      betRounds[nextRoundId].bets.push(opBetId);
      betRounds[nextRoundId].bets.push(lastBetId);

      emit BetAccepted(opBetId, lastBetId, nextRoundId);
    }
    _incTotalReserved(msg.value);

    // update last affiliate
    aff.setUpAffCodeByAddr(bet.bettor, _affCode);
  }

  function _startNextRound() internal returns (uint nextRoundId) {
    uint nextStartAt;
    uint nextFinishAt;
    (nextRoundId, nextStartAt, nextFinishAt) = getNextRoundInfo();
    
    if (betRounds[nextRoundId].startedAt == 0) {
      betRounds[nextRoundId].startedAt = nextStartAt;
      roundsList.push(nextRoundId);
      emit StartBetRound(nextRoundId, nextStartAt, nextFinishAt);
    }
  }

  function cancelBettorBet(address bettor, uint betIndex) external onlyService {
    _cancelBet(bettors[bettor].bets[betIndex]);
  }

  function cancelMyBet(uint betIndex) external nonReentrant {
    _cancelBet(bettors[msg.sender].bets[betIndex]);
  }

  function cancelBet(uint betId) external nonReentrant {
    require(bets[betId].bettor == msg.sender);
    _cancelBet(betId);
  }

  function _cancelBet(uint betId) internal {
    Bet storage bet = bets[betId];
    require(bet.active);
    //can cancel only not yet accepted bets
    require(bet.roundId == 0);

    //upd queue
    BetData storage allyData = betData[bet.level][bet.allyRace][bet.enemyRace];
    allyData.queue.remove(betId);

    _decTotalReserved(bet.value);
    bet.bettor.transfer(bet.value);
    emit BetCanceled(betId);

    // del bet
    delete bets[betId];
  }


  function _calcRoundLevel(uint level, uint allyRace, uint enemyRace, uint roundId) internal returns (int32 allyResult, int32 enemyResult){
    require(betRounds[roundId].startedAt != 0 && betRounds[roundId].finishedAt != 0);

    allyResult = betRounds[roundId].races[allyRace].result;
    enemyResult = betRounds[roundId].races[enemyRace].result;

    if (allyResult < enemyResult) {
      (allyRace, enemyRace) = (enemyRace, allyRace);
    }
    BetData storage winnerData = betData[level][allyRace][enemyRace];
    BetData storage loserData = betData[level][enemyRace][allyRace];

    if (!loserData.stat[roundId].taxed) {
      loserData.stat[roundId].taxed = true;

      //check if really winner
      if (allyResult != enemyResult) {
        //system fee
        uint fee = _getPercent(loserData.stat[roundId].sum, systemFeePcnt);
        _decTotalReserved(fee);

        //affiliate %
        winnerData.stat[roundId].affPool = _getPercent(loserData.stat[roundId].sum, affPoolPcnt);
        //calc pool for round
        winnerData.stat[roundId].pool = loserData.stat[roundId].sum - fee - winnerData.stat[roundId].affPool;

        emit BetRoundCalculated(roundId, allyRace, enemyRace, level, winnerData.stat[roundId].pool, winnerData.stat[roundId].count);
      }
    }

    if (!winnerData.stat[roundId].taxed) {
      winnerData.stat[roundId].taxed = true;
    }
  }

  function rewardBettorBet(address bettor, uint betIndex) external onlyService {
    _rewardBet(bettors[bettor].bets[betIndex]);
  }

  function rewardMyBet(uint betIndex) external nonReentrant {
    _rewardBet(bettors[msg.sender].bets[betIndex]);
  }

  function rewardBet(uint betId) external nonReentrant {
    require(bets[betId].bettor == msg.sender);
    _rewardBet(betId);
  }


  function _rewardBet(uint betId) internal {
    Bet storage bet = bets[betId];
    require(bet.active);
    //only accepted bets
    require(bet.roundId != 0);
    (int32 allyResult, int32 enemyResult) = _calcRoundLevel(bet.level, bet.allyRace, bet.enemyRace, bet.roundId);

    //disabling bet
    bet.active = false;
    if (allyResult >= enemyResult) {
      bet.reward = bet.value;
      if (allyResult > enemyResult) {
        //win
        BetStat memory s = betData[bet.level][bet.allyRace][bet.enemyRace].stat[bet.roundId];
        bet.reward = bet.reward.add(s.pool / s.count);

        // winner's affiliates + loser's affiliates
        uint affPool = s.affPool / s.count;
        _decTotalReserved(affPool);
        // affiliate pool is 1/2 of total aff. pool, per each winner and loser
        _distributeAffiliateReward(affPool >> 1, aff.getAffCode(uint(bet.bettor)), 0, false); //no cacheback to winner
        _distributeAffiliateReward(affPool >> 1, aff.getAffCode(uint(bets[bet.opBetId].bettor)), 0, true); //cacheback to looser
      }


      bet.bettor.transfer(bet.reward);
      _decTotalReserved(bet.reward);
      emit BetRewarded(betId, bet.opBetId, bet.reward, allyResult == enemyResult);
    }
    _flushBalance();
  }


  function provisionBetReward(uint betId) public view returns (uint reward) {
    Bet storage bet = bets[betId];
    if (!bet.active) {
      return 0;
    }

    int32 allyResult = betRounds[bet.roundId].races[bet.allyRace].result;
    int32 enemyResult = betRounds[bet.roundId].races[bet.enemyRace].result;

    if (allyResult < enemyResult) {
      return 0;
    }
    reward = bet.value;

    BetData storage allyData = betData[bet.level][bet.allyRace][bet.enemyRace];
    BetData storage enemyData = betData[bet.level][bet.enemyRace][bet.allyRace];

    if (allyResult > enemyResult) {
      //win
      if (!enemyData.stat[bet.roundId].taxed) {
        uint pool = enemyData.stat[bet.roundId].sum - _getPercent(enemyData.stat[bet.roundId].sum, systemFeePcnt + affPoolPcnt);
        reward = bet.value.add(pool / allyData.stat[bet.roundId].count);
      } else {
        reward = bet.value.add(allyData.stat[bet.roundId].pool / allyData.stat[bet.roundId].count);
      }
    }
  }

  function provisionBettorBetReward(address bettor, uint betIndex) public view returns (uint reward) {
    return provisionBetReward(bettors[bettor].bets[betIndex]);
  }

  function finalizeBetRound(uint betLevel, uint allyRace, uint enemyRace, uint roundId) external onlyService {
    _calcRoundLevel(betLevel, allyRace, enemyRace, roundId);
    _flushBalance();
  }

  function roundsCount() external view returns (uint) {
    return roundsList.length;
  }

  function getBettorsBetCounter(address bettor) external view returns (uint) {
    return bettors[bettor].counter;
  }

  function getBettorsBetId(address bettor, uint betIndex) external view returns (uint betId) {
    return bettors[bettor].bets[betIndex];
  }

  function getBettorsBets(address bettor) external view returns (uint[] memory betIds) {
    Bettor storage b = bettors[bettor];
    uint j;
    for (uint i = 1; i <= b.counter; i++) {
      if (b.bets[i] != 0) {
        j++;
      }
    }
    if (j > 0) {
      betIds = new uint[](j);
      j = 0;
      for (uint i = 1; i <= b.counter; i++) {
        if (b.bets[i] != 0) {
          betIds[j++] = b.bets[i];
        }
      }
    }
  }


  function getBet(uint betId) public view returns (
    address bettor,
    bool active,
    uint roundId,
    uint allyRace,
    uint enemyRace,
    uint value,
    uint level,
    uint opBetId,
    uint reward
  ) {
    Bet memory b = bets[betId];
    return (b.bettor, b.active, b.roundId, b.allyRace, b.enemyRace, b.value, b.level, b.opBetId, b.reward);
  }

  function getBetRoundStat(uint roundId, uint allyRace, uint enemyRace, uint level) public view returns (
    uint sum,
    uint pool,
    uint affPool,
    uint count,
    bool taxed
  ) {
    BetStat memory bs = betData[level][allyRace][enemyRace].stat[roundId];
    return (bs.sum, bs.pool, bs.affPool, bs.count, bs.taxed);
  }

  function getBetQueueLength(uint allyRace, uint enemyRace, uint level) public view returns (uint) {
    return betData[level][allyRace][enemyRace].queue.len();
  }

  function getCurrentBetRound() public view returns (
    uint roundId,
    uint startedAt,
    uint finishedAt,
    uint startCheckedAt,
    uint finishCheckedAt,
    uint betsCount,
    uint raceCount
  ) {
    roundId = getCurrentRoundId();
    (startedAt, finishedAt, startCheckedAt, finishCheckedAt, betsCount, raceCount) = getBetRound(roundId);
  }

  function getNextBetRound() public view returns (
    uint roundId,
    uint startedAt,
    uint finishedAt,
    uint startCheckedAt,
    uint finishCheckedAt,
    uint betsCount,
    uint raceCount
  ) {
    roundId = getCurrentRoundId() + 1;
    (startedAt, finishedAt, startCheckedAt, finishCheckedAt, betsCount, raceCount) = getBetRound(roundId);
  }

  function getBetRound(uint roundId) public view returns (
    uint startedAt,
    uint finishedAt,
    uint startCheckedAt,
    uint finishCheckedAt,
    uint betsCount,
    uint raceCount
  ) {
    BetRound memory b = betRounds[roundId];
    return (b.startedAt, b.finishedAt, b.startCheckedAt, b.finishCheckedAt, b.bets.length, b.raceList.length);
  }

  function getBetRoundBets(uint roundId) public view returns (uint[] memory betIds) {
    return betRounds[roundId].bets;
  }

  function getBetRoundBetId(uint roundId, uint betIndex) public view returns (uint betId) {
    return betRounds[roundId].bets[betIndex];
  }


  function getBetRoundRaces(uint roundId) public view returns (uint[] memory raceIds) {
    return betRounds[roundId].raceList;
  }

  function getBetRoundRaceStat(uint roundId, uint raceId) external view returns (
    uint index,
    uint count,
    int32 result
  ){
    Race memory r = betRounds[roundId].races[raceId];
    return (r.index, r.count, r.result);
  }

  function setBetRoundResult(uint roundId, uint count, uint[] memory packedRaces, uint[] memory packedResults) public onlyService {
    require(packedRaces.length == packedResults.length);
    require(packedRaces.length * 8 >= count);

    BetRound storage r = betRounds[roundId];
    require(r.startedAt != 0 && r.finishedAt == 0);

    uint raceId;
    int32 result;
    for (uint i = 0; i < count; i++) {
      raceId = _upack(packedRaces[i / 8], i % 8);
      result = int32(_upack(packedResults[i / 8], i % 8));
      r.races[raceId].result = result;
      emit RoundRaceResult(roundId, raceId, result);
    }
  }

  function finishBetRound(uint roundId, uint startCheckedAt, uint finishCheckedAt) public onlyService {
    BetRound storage r = betRounds[roundId];
    require(r.startedAt != 0 && r.finishedAt == 0);
    uint finishAt;
    (, , finishAt) = getRoundInfoAt(r.startedAt, 0);
    require(now >= finishAt);
    r.finishedAt = finishAt;
    r.startCheckedAt = startCheckedAt;
    r.finishCheckedAt = finishCheckedAt;
    emit FinishBetRound(roundId, startCheckedAt, finishCheckedAt);
  }

  //extract n-th 32-bit int from uint
  function _upack(uint _v, uint _n) internal pure returns (uint) {
    //    _n = _n & 7; //be sure < 8
    return (_v >> (32 * _n)) & 0xFFFFFFFF;
  }

}