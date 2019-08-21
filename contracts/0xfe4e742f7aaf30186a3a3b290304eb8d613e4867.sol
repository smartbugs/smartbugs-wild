pragma solidity ^0.4.24;

// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
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
  function isOwner() public view returns(bool) {
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

// File: node_modules/openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /// @dev counter to allow mutex lock with only one SSTORE operation
  uint256 private _guardCounter;

  constructor() internal {
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

// File: node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
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
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
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
    if (address(token) == address(0)) {
      owner().transfer(address(this).balance);
      return;
    }
    uint256 balance = token.balanceOf(this);
    token.transfer(owner(), balance);
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
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
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

// File: contracts/Fights.sol

interface HEROES {
  function getLevel(uint256 tokenId) external view returns (uint256);
  function getGenes(uint256 tokenId) external view returns (uint256);
  function getRace(uint256 tokenId) external view returns (uint256);
  function lock(uint256 tokenId, uint256 lockedTo, bool onlyFreeze) external returns (bool);
  function unlock(uint256 tokenId) external returns (bool);
  function ownerOf(uint256 tokenId) external view returns (address);
  function addWin(uint256 tokenId, uint winsCount, uint levelUp) external returns (bool);
  function addLoss(uint256 tokenId, uint256 lossesCount, uint levelDown) external returns (bool);
}

//Crypto Hero Rocket coin
interface CHR {
  //  function mint(address _to, uint256 _amount) external returns (bool);
  function burn(address _from, uint256 _amount) external returns (bool);
}


contract Fights is Ownable, ServiceRole, ReentrancyGuard, CanReclaimToken {
  using SafeMath for uint256;

  event SetFightInterval(uint startsFrom, uint pastFightsCount, uint fightsInterval, uint fightPeriod, uint applicationPeriod, uint betsPeriod);
  event EnterArena(uint tokenId, uint fightId, uint startsAt, uint level, uint enemyRace);
  event ChangeEnemy(uint tokenId, uint fightId, uint enemyRace);
  event LeaveArena(uint tokenId, uint fightId, Result result, uint level);
  event StartFight(uint fightId, uint startAt);
  event RemoveFight(uint fightId);
  event FightResult(uint fightId, uint[] races, uint[] values);
  event FinishFight(uint fightId, uint startedAt, uint finishedAt, uint startCheckedAt, uint finishCheckedAt);

  HEROES public heroes;
  CHR public coin;

  enum Result {QUAIL, WIN, LOSS, DRAW}

  struct Fighter {
    uint index;
    bool exists;
    uint race;
    uint level;
    uint enemyRace;
    bool finished;
  }

  struct Race {
    uint index;
    bool exists;
    uint count; //число участников данной рассы
    uint enemyCount; //число игроков выбравших эту расу соперником
    uint levelSum; //сумма всех уникальных значений уровней
    //level => count
    mapping(uint => uint) levelCount; // количество участников по уровням
    //результат битвы в универсальных единицах, может быть отрицательным (32бит)
    //измеряется в % изменении курса валюты по отношению к доллару на начало и конец периода
    //пример курс BTC на 12:00 - 6450.33, на 17:00 - 6387.22, изменение = (6387.22 - 6450.33) / 6450.33 = -0,009784 = -0.978%
    //учитываем 3 знака после запятой и переводим в целое число умножи на 1000 = -978
    int32 result;
  }

  struct Fight {
    uint startedAt;
    uint finishedAt;
    uint startCheckedAt;
    uint finishCheckedAt;
    //index участника => tokenId
    mapping(uint => uint) arena;
    //tokenId => структура Бойца
    mapping(uint => Fighter) fighters;
    uint fightersCount;
    // raceId => Race
    mapping(uint => Race) races;
    // race index => raceId
    mapping(uint => uint) raceList;
    uint raceCount;
  }


  //массив произошедших битв, в него помещаются только id состоявшихся битв
  uint[] public fightsList;
  //tokenId => fightId помним ид последней битвы персонажа, чтобы он мог выйти с использованием монетки
  mapping(uint => uint[]) public characterFights;

  //id битвы, жестко привязан к интервалам времени
  //т.е. если интервал = 1 час, то через 10 часов даже если не было ни одной битвы, id = 10
  //fightId => Fight
  mapping(uint => Fight) fights;

  //структура описывающая интервалы битв
  struct FightInterval {
    uint fightsInterval;
    uint startsFrom;
    uint fightsCount; //число уже завершенных битв до этого интервала
    uint betsPeriod;
    uint applicationPeriod;
    uint fightPeriod;
  }

  //массив хранит историю изменений настроек битв
  //чтобы можно было иметь доступ к прошлым битвам, в случае если интервалы изменится
  FightInterval[] public intervalHistory;

  uint public constant FightEpoch = 1542240000; //Thursday, 15 November 2018 г., 0:00:00
  uint public minBetsLevel = 5;
  bool public allowEnterDuringBets = true;

  modifier onlyOwnerOf(uint256 _tokenId) {
    require(heroes.ownerOf(_tokenId) == msg.sender);
    _;
  }

  constructor(HEROES _heroes, CHR _coin) public {
    require(address(_heroes) != address(0));
    require(address(_coin) != address(0));
    heroes = _heroes;
    coin = _coin;

    //  uint public fightsInterval = 12 * 60 * 60; //12 hours, интервал с которым проводятся бои
    //  uint public betsPeriod = 2 * 60 * 60; //период в течении которого доступны ставки 2 hours
    //  uint public applicationPeriod = 11 * 60 * 60; //11 hours, период в течении которого можно подать заявку на участие в бою до начала боя
    //  uint public fightPeriod = 5 * 60 * 60;//длительность боя, 5 часов

    intervalHistory.push(FightInterval({
      fightPeriod: 5 * 60 * 60, //длительность боя, 5 часов,
      startsFrom : FightEpoch,
      fightsCount : 0,
      fightsInterval : 12 * 60 * 60, //12 hours, интервал с которым проводятся бои,
      betsPeriod : 2 * 60 * 60, //период в течении которого доступны ставки 2 hours,
      applicationPeriod : 11 * 60 * 60 //11 hours, период в течении которого можно подать заявку на участие в бою до начала боя
      }));
  }

  /// @notice The fallback function payable
  function() external payable {
    require(msg.value > 0);
    address(heroes).transfer(msg.value);
  }

  function addService(address account) public onlyOwner {
    _addService(account);
  }

  function removeService(address account) public onlyOwner {
    _removeService(account);
  }


  //устанавливает новые значения интервалов битв
  function setFightInterval(uint _fightsInterval, uint _applicationPeriod, uint _betsPeriod, uint _fightPeriod) external onlyOwner {
    FightInterval memory i = _getFightIntervalAt(now);
    //todo проверить )
    // количество интервалов прошедших с момента последней записи в истории
    uint intervalsCount = (now - i.startsFrom) / i.fightsInterval + 1;
    FightInterval memory ni = FightInterval({
      fightsInterval : _fightsInterval,
      startsFrom : i.startsFrom + i.fightsInterval * intervalsCount,
      fightsCount : intervalsCount + i.fightsCount,
      applicationPeriod : _applicationPeriod,
      betsPeriod : _betsPeriod,
      fightPeriod : _fightPeriod
      });
    intervalHistory.push(ni);
    emit SetFightInterval(ni.startsFrom, ni.fightsCount, _fightsInterval, _fightPeriod, _applicationPeriod, _betsPeriod);
  }

  //устанавливает новые значения дополнительных параметров
  function setParameters(uint _minBetsLevel, bool _allowEnterDuringBets) external onlyOwner {
    minBetsLevel = _minBetsLevel;
    allowEnterDuringBets = _allowEnterDuringBets;
  }

  function enterArena(uint _tokenId, uint _enemyRace) public onlyOwnerOf(_tokenId) {
    //only if finished last fight
    require(isAllowed(_tokenId));
    uint intervalId = _getFightIntervalIdAt(now);
    FightInterval memory i = intervalHistory[intervalId];
    uint nextStartsAt = _getFightStartsAt(intervalId, 1);
    //вступить в арену можно только в период приема заявок
    require(now >= nextStartsAt - i.applicationPeriod);
    //вступить в арену можно только до начала битвы или до начала ставок
    require(now < nextStartsAt - (allowEnterDuringBets ? 0 : i.betsPeriod));

    uint nextFightId = getFightId(intervalId, 1);
    Fight storage f = fights[nextFightId];
    //на всякий случай, если мы вдруг решим закрыть определенную битву в будущем
//    require(f.finishedAt != 0);

    //участник еще не на арене
    require(!f.fighters[_tokenId].exists);

    uint level = heroes.getLevel(_tokenId);
    uint race = heroes.getRace(_tokenId);
    require(race != _enemyRace);

    //начать fight если он еще не был начат
    if (f.startedAt == 0) {
      f.startedAt = nextStartsAt;
      fightsList.push(nextFightId);
      emit StartFight(nextFightId, nextStartsAt);
      //todo что еще?
    }

    //добавляем на арену
    f.fighters[_tokenId] = Fighter({
      exists : true,
      finished : false,
      index : f.fightersCount,
      race : race,
      enemyRace : _enemyRace,
      level: level
      });
    f.arena[f.fightersCount++] = _tokenId;
    //запоминаем в списке битв конкретного токена
    characterFights[_tokenId].push(nextFightId);

    Race storage r = f.races[race];
    if (!r.exists) {
      r.exists = true;
      r.index = f.raceCount;
      f.raceList[f.raceCount++] = race;
    }
    r.count++;
    //для будущего расчета выигрыша
    //учет только игроков 5 и выше уровня
    if (level >= minBetsLevel) {
      //если еще не было участников с таким уровнем, считаем что это новый уникальный
      if (r.levelCount[level] == 0) {
        //суммируем уникальное значения уровня
        r.levelSum = r.levelSum.add(level);
      }
      //счетчик количества игроков с данным уровнем
      r.levelCount[level]++;
    }
    //учтем вражескую расу, просто создаем ее и добавляем в список, без изменения количеств,
    //чтобы потом с бэкенда было проще пройтись по списку рас
    Race storage er = f.races[_enemyRace];
    if (!er.exists) {
      er.exists = true;
      er.index = f.raceCount;
      f.raceList[f.raceCount++] = _enemyRace;
    }
    er.enemyCount++;

    //устанавливаем блокировку до конца битвы
    require(heroes.lock(_tokenId, nextStartsAt + i.fightPeriod, false));
    emit EnterArena(_tokenId, nextFightId, nextStartsAt, level, _enemyRace);

  }


  function changeEnemy(uint _tokenId, uint _enemyRace) public onlyOwnerOf(_tokenId) {
    uint fightId = characterLastFightId(_tokenId);

    //последняя битва должны существовать
    require(fightId != 0);
    Fight storage f = fights[fightId];
    Fighter storage fr = f.fighters[_tokenId];
    //участник уже на арене
    //todo излишне, такого быть не должно, проанализировать
    require(fr.exists);
    //только если еще не завершена битва для  данного бойца
    require(!fr.finished);

    //поменять на новую только
    require(fr.enemyRace != _enemyRace);

    FightInterval memory i = _getFightIntervalAt(f.startedAt);

    //требуем либо текущее время до начала ставок
    //todo излишне, достаточно now < f.startedAt - params.betsPeriod
    //т.к. в теории игрок не может находится до начала периода заявок
    require(now >= f.startedAt - i.applicationPeriod && now < f.startedAt - i.betsPeriod && f.finishedAt != 0);

    fr.enemyRace = _enemyRace;

    //уменьшаем счетчик расс врагов
    Race storage er_old = f.races[fr.enemyRace];
    er_old.enemyCount--;

    if (er_old.count == 0 && er_old.enemyCount == 0) {
      f.races[f.raceList[--f.raceCount]].index = er_old.index;
      f.raceList[er_old.index] = f.raceList[f.raceCount];
      delete f.arena[f.raceCount];
      delete f.races[fr.enemyRace];
    }

    //учтем вражескую расу, просто создаем ее и добавляем в список, без изменения количеств,
    //чтобы потом с бэкенда было проще пройтись по списку рас
    Race storage er_new = f.races[_enemyRace];
    if (!er_new.exists) {
      er_new.index = f.raceCount;
      f.raceList[f.raceCount++] = _enemyRace;
    }
    er_new.enemyCount++;
    emit ChangeEnemy(_tokenId, fightId, _enemyRace);
  }

  function reenterArena(uint _tokenId, uint _enemyRace, bool _useCoin) public onlyOwnerOf(_tokenId) {
    uint fightId = characterLastFightId(_tokenId);
    //последняя битва должны существовать
    require(fightId != 0);
    Fight storage f = fights[fightId];
    Fighter storage fr = f.fighters[_tokenId];
    //участник уже на арене
    //todo излишне, такого быть не должно, проанализировать
    require(fr.exists);
    //нельзя перезайти из не начатой битвы
//    require (f.startedAt != 0);

    //только если еще не завершена битва для  данного бойца
    require(!fr.finished);

    //требуем либо текущее время после конца битвы, которая завершена
    require(f.finishedAt != 0 && now > f.finishedAt);

    Result result = Result.QUAIL;

    //обработка результатов
    if (f.races[f.fighters[_tokenId].race].result > f.races[f.fighters[_tokenId].enemyRace].result) {
      result = Result.WIN;
      //wins +1, level + 1
      heroes.addWin(_tokenId, 1, 1);
    } else if (f.races[f.fighters[_tokenId].race].result < f.races[f.fighters[_tokenId].enemyRace].result) {
      result = Result.LOSS;
      //засчитываем поражение
      if (_useCoin) {
        require(coin.burn(heroes.ownerOf(_tokenId), 1));
        //losses +1, level the same
        heroes.addLoss(_tokenId, 1, 0);
      } else {
        //losses +1, level - 1
        heroes.addLoss(_tokenId, 1, 1);
      }
    } else {
      //todo ничья
//      result = Result.QUAIL;
    }
    fr.finished = true;

    emit LeaveArena(_tokenId, fightId, result, fr.level);
    //вход на арену
    enterArena(_tokenId, _enemyRace);
  }


  //покинуть арену можно до начала ставок или после окончания, и естественно только последнюю
  function leaveArena(uint _tokenId, bool _useCoin) public onlyOwnerOf(_tokenId) {
    uint fightId = characterLastFightId(_tokenId);

    //последняя битва должны существовать
    require(fightId != 0);
    Fight storage f = fights[fightId];
    Fighter storage fr = f.fighters[_tokenId];
    //участник уже на арене
    //todo излишне, такого быть не должно, проанализировать
    require(fr.exists);

    //нельзя покинуть не начатую битву
    //    require (f.startedAt != 0);

    //только если еще не завершена битва для  данного бойца
    require(!fr.finished);

    FightInterval memory i = _getFightIntervalAt(f.startedAt);

    //требуем либо текущее время до начала ставок, либо уже после конца битвы, которая завершена
    require(now < f.startedAt - i.betsPeriod || (f.finishedAt != 0 && now > f.finishedAt));
    Result result = Result.QUAIL;
    //выход до начала битвы
    if (f.finishedAt == 0) {

      Race storage r = f.races[fr.race];
      //учет только игроков 5 и выше уровня
      if (fr.level >= minBetsLevel) {
        //уменьшаем счетчик игроков этого уровня
        r.levelCount[fr.level]--;
        //если это был последний игрок
        if (r.levelCount[fr.level] == 0) {
          r.levelSum = r.levelSum.sub(fr.level);
        }
      }
      r.count--;

      Race storage er = f.races[fr.enemyRace];
      er.enemyCount--;

      //если больше не осталось игроков в этих расах удаляем их
      if (r.count == 0 && r.enemyCount == 0) {
        f.races[f.raceList[--f.raceCount]].index = r.index;
        f.raceList[r.index] = f.raceList[f.raceCount];
        delete f.arena[f.raceCount];
        delete f.races[fr.race];
      }
      if (er.count == 0 && er.enemyCount == 0) {
          f.races[f.raceList[--f.raceCount]].index = er.index;
        f.raceList[er.index] = f.raceList[f.raceCount];
        delete f.arena[f.raceCount];
        delete f.races[fr.enemyRace];
      }

      // удалить с арены
      f.fighters[f.arena[--f.fightersCount]].index = fr.index;
      f.arena[fr.index] = f.arena[f.fightersCount];
      delete f.arena[f.fightersCount];
      delete f.fighters[_tokenId];
      //удаляем из списка битв
      delete characterFights[_tokenId][characterFights[_tokenId].length--];

      //todo если участник последний - то удалить битву
      if (f.fightersCount == 0) {
        delete fights[fightId];
        emit RemoveFight(fightId);
      }
    } else {

      //выход после окончания битвы
      if (f.races[f.fighters[_tokenId].race].result > f.races[f.fighters[_tokenId].enemyRace].result) {
        result = Result.WIN;
        heroes.addWin(_tokenId, 1, 1);
      } else if (f.races[f.fighters[_tokenId].race].result < f.races[f.fighters[_tokenId].enemyRace].result) {
        result = Result.LOSS;
        //засчитываем поражение
        if (_useCoin) {
          //сжигаем 1 монетку
          require(coin.burn(heroes.ownerOf(_tokenId), 1));
          //при использовании монетки не уменьшаем уровень, при этом счетчик поражений +1
          heroes.addLoss(_tokenId, 1, 0);
        } else {
          heroes.addLoss(_tokenId, 1, 1);
        }
      } else {
        //todo ничья
        result = Result.DRAW;
      }

      fr.finished = true;
    }
    //разблокируем игрока
    require(heroes.unlock(_tokenId));
    emit LeaveArena(_tokenId, fightId, result, fr.level);

  }

  function fightsCount() public view returns (uint) {
    return fightsList.length;
  }

  //возвращает id битвы актуальный в данный момент
  function getCurrentFightId() public view returns (uint) {
    return getFightId(_getFightIntervalIdAt(now), 0);
  }

  function getNextFightId() public view returns (uint) {
    return getFightId(_getFightIntervalIdAt(now), 1);
  }

  function getFightId(uint intervalId, uint nextShift) internal view returns (uint) {
    FightInterval memory i = intervalHistory[intervalId];
    return (now - i.startsFrom) / i.fightsInterval + i.fightsCount + nextShift;
  }

  function characterFightsCount(uint _tokenId) public view returns (uint) {
    return characterFights[_tokenId].length;
  }

  function characterLastFightId(uint _tokenId) public view returns (uint) {
    //    require(characterFights[_tokenId].length > 0);
    return characterFights[_tokenId].length > 0 ? characterFights[_tokenId][characterFights[_tokenId].length - 1] : 0;
  }

  function characterLastFight(uint _tokenId) public view returns (
    uint index,
    uint race,
    uint level,
    uint enemyRace,
    bool finished
  ) {
    return getFightFighter(characterLastFightId(_tokenId), _tokenId);
  }

  function getFightFighter(uint _fightId, uint _tokenId) public view returns (
    uint index,
    uint race,
    uint level,
    uint enemyRace,
    bool finished
  ) {
    Fighter memory fr = fights[_fightId].fighters[_tokenId];
    return (fr.index, fr.race, fr.level, fr.enemyRace, fr.finished);
  }

  function getFightArenaFighter(uint _fightId, uint _fighterIndex) public view returns (
    uint tokenId,
    uint race,
    uint level,
    uint enemyRace,
    bool finished
  ) {
    uint _tokenId = fights[_fightId].arena[_fighterIndex];
    Fighter memory fr = fights[_fightId].fighters[_tokenId];
    return (_tokenId, fr.race, fr.level, fr.enemyRace, fr.finished);
  }

  function getFightRaces(uint _fightId) public view returns(uint[]) {
    Fight storage f = fights[_fightId];
    if (f.startedAt == 0) return;
    uint[] memory r = new uint[](f.raceCount);
    for(uint i; i < f.raceCount; i++) {
      r[i] = f.raceList[i];
    }
    return r;
  }

  function getFightRace(uint _fightId, uint _race) external view returns (
    uint index,
    uint count, //число участников данной рассы
    uint enemyCount, //число игроков выбравших эту расу соперником
    int32 result
  ){
    Race memory r = fights[_fightId].races[_race];
    return (r.index, r.count, r.enemyCount, r.result);
  }

  function getFightRaceLevelStat(uint _fightId, uint _race, uint _level) external view returns (
    uint levelCount, //число участников данной рассы данного уровня
    uint levelSum //сумма уникальных значений всех уровней данной рассы
  ){
    Race storage r = fights[_fightId].races[_race];
    return (r.levelCount[_level], r.levelSum);
  }

  function getFightResult(uint _fightId, uint _tokenId) public view returns (Result) {
//    uint fightId = getCharacterLastFightId(_tokenId);
    //    require(fightId != 0);
    Fight storage f = fights[_fightId];
    Fighter storage fr = f.fighters[_tokenId];
    //участник существует
    if (!fr.exists) {
      return Result.QUAIL;
    }
//    return (int(f.races[fr.race].result) - int(f.races[fr.enemyRace].result));
    return f.races[fr.race].result > f.races[fr.enemyRace].result ? Result.WIN : f.races[fr.race].result < f.races[fr.enemyRace].result ? Result.LOSS : Result.DRAW;
  }


  function isAllowed(uint tokenId) public view returns (bool) {
    uint fightId = characterLastFightId(tokenId);
    return fightId == 0 ? true : fights[fightId].fighters[tokenId].finished;
  }

  function getCurrentFight() public view returns (
    uint256 fightId,
    uint256 startedAt,
    uint256 finishedAt,
    uint256 startCheckedAt,
    uint256 finishCheckedAt,
    uint256 fightersCount,
    uint256 raceCount
  ) {
    fightId = getCurrentFightId();
    (startedAt, finishedAt, startCheckedAt, finishCheckedAt, fightersCount, raceCount) = getFight(fightId);
  }

  function getNextFight() public view returns (
    uint256 fightId,
    uint256 startedAt,
    uint256 finishedAt,
    uint256 startCheckedAt,
    uint256 finishCheckedAt,
    uint256 fightersCount,
    uint256 raceCount
  ) {
    fightId = getNextFightId();
    (startedAt, finishedAt, startCheckedAt, finishCheckedAt, fightersCount, raceCount) = getFight(fightId);
  }

  function getFight(uint _fightId) public view returns (
    uint256 startedAt,
    uint256 finishedAt,
    uint256 startCheckedAt,
    uint256 finishCheckedAt,
    uint256 fightersCount,
    uint256 raceCount
  ) {
    Fight memory f = fights[_fightId];
    return (f.startedAt, f.finishedAt, f.startCheckedAt, f.finishCheckedAt, f.fightersCount, f.raceCount);
  }

  function getNextFightInterval() external view returns (
    uint fightId,
    uint currentTime,
    uint applicationStartAt,
    uint betsStartAt,
    uint fightStartAt,
    uint fightFinishAt
  ) {
    uint intervalId = _getFightIntervalIdAt(now);
    fightId = getFightId(intervalId, 1);
    (currentTime, applicationStartAt, betsStartAt, fightStartAt, fightFinishAt) = _getFightInterval(intervalId, 1);
  }

  function getCurrentFightInterval() external view returns (
    uint fightId,
    uint currentTime,
    uint applicationStartAt,
    uint betsStartAt,
    uint fightStartAt,
    uint fightFinishAt
  ) {
    uint intervalId = _getFightIntervalIdAt(now);
    fightId = getFightId(intervalId, 0);
    (currentTime, applicationStartAt, betsStartAt, fightStartAt, fightFinishAt) = _getFightInterval(intervalId, 0);
  }

  function _getFightInterval(uint intervalId, uint nextShift) internal view returns (
//    uint fightId,
    uint currentTime,
    uint applicationStartAt,
    uint betsStartAt,
    uint fightStartAt,
    uint fightFinishAt
  ) {

    fightStartAt = _getFightStartsAt(intervalId, nextShift);

    FightInterval memory i = intervalHistory[intervalId];
    currentTime = now;
    applicationStartAt = fightStartAt - i.applicationPeriod;
    betsStartAt = fightStartAt - i.betsPeriod;
    fightFinishAt = fightStartAt + i.fightPeriod;
  }

  function _getFightStartsAt(uint intervalId, uint nextShift) internal view returns (uint) {
    FightInterval memory i = intervalHistory[intervalId];
    uint intervalsCount = (now - i.startsFrom) / i.fightsInterval + nextShift;
    return i.startsFrom + i.fightsInterval * intervalsCount;
  }


  function getCurrentIntervals() external view returns (
    uint fightsInterval,
    uint fightPeriod,
    uint applicationPeriod,
    uint betsPeriod
  ) {
    FightInterval memory i = _getFightIntervalAt(now);
    fightsInterval = i.fightsInterval;
    fightPeriod = i.fightPeriod;
    applicationPeriod = i.applicationPeriod;
    betsPeriod = i.betsPeriod;
  }


  function _getFightIntervalAt(uint _time)  internal view returns (FightInterval memory) {
    return intervalHistory[_getFightIntervalIdAt(_time)];
  }


  function _getFightIntervalIdAt(uint _time)  internal view returns (uint) {
    require(intervalHistory.length>0);
    //    if (intervalHistory.length == 0) return 0;

    // Shortcut for the actual value
    if (_time >= intervalHistory[intervalHistory.length - 1].startsFrom)
      return intervalHistory.length - 1;
    if (_time < intervalHistory[0].startsFrom) return 0;

    // Binary search of the value in the array
    uint min = 0;
    uint max = intervalHistory.length - 1;
    while (max > min) {
      uint mid = (max + min + 1) / 2;
      if (intervalHistory[mid].startsFrom <= _time) {
        min = mid;
      } else {
        max = mid - 1;
      }
    }
    return min;
  }


  //устанавливает результаты для битвы для всех расс
  //принимает 2 соответствующих массива id расс и значений результата битвы
  //значения 32битные, упакованы в uint256
  // !!! закрытие битвы отдельной функцией, т.к. результатов может быть очень много и не уложится в один вызов !!!
  function setFightResult(uint fightId, uint count, uint[] packedRaces, uint[] packedResults) public onlyService {
    require(packedRaces.length == packedResults.length);
    require(packedRaces.length * 8 >= count);

    Fight storage f = fights[fightId];
    require(f.startedAt != 0 && f.finishedAt == 0);

    //    f.finishedAt = now;
    for (uint i = 0; i < count; i++) {
//      for (uint n = 0; n < 8 || ; n++) {
        f.races[_upack(packedRaces[i / 8], i % 8)].result = int32(_upack(packedResults[i / 8], i % 8));
//      }
    }
    emit FightResult(fightId, packedRaces, packedResults);

  }

  //close the fight, save check points time
  function finishFight(uint fightId, uint startCheckedAt, uint finishCheckedAt) public onlyService {
    Fight storage f = fights[fightId];
    require(f.startedAt != 0 && f.finishedAt == 0);
    FightInterval memory i = _getFightIntervalAt(f.startedAt);
    //нельзя закрыть до истечения периода битвы
    require(now >= f.startedAt + i.fightPeriod);
    f.finishedAt = now;
    f.startCheckedAt = startCheckedAt;
    f.finishCheckedAt = finishCheckedAt;
    emit FinishFight(fightId, f.startedAt, f.finishedAt, startCheckedAt, finishCheckedAt);
  }

  //extract n-th 32-bit int from uint
  function _upack(uint _v, uint _n) internal pure returns (uint) {
    //    _n = _n & 7; //be sure < 8
    return (_v >> (32 * _n)) & 0xFFFFFFFF;
  }

  //merge n-th 32-bit int to uint
  function _puck(uint _v, uint _n, uint _x) internal pure returns (uint) {
    //    _n = _n & 7; //be sure < 8
    //number = number & ~(1 << n) | (x << n);
    return _v & ~(0xFFFFFFFF << (32 * _n)) | ((_x & 0xFFFFFFFF) << (32 * _n));
  }
}