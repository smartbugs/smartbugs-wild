/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract OwnableExtended {
  address public owner;
  address public admin;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function OwnableExtended() {
    owner = msg.sender;
    admin = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Throws if called by any account other than the owner or admin.
   */
  modifier onlyAdmin() {
    require(msg.sender == owner || msg.sender == admin);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

  /**
  * @dev Allows the current owner to change admin of the contract
  * @param newAdmin The new admin address
  */
  function changeAdmin(address newAdmin) onlyOwner {
    if (newAdmin != address(0)) {
      admin = newAdmin;
    }
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract iChampion {
    uint256 public currentGameBlockNumber;

    function buyTicket(address) returns (uint256, uint256) {}
    function startGame() returns (bool) {}
    function finishCurrentGame() returns (address) {}
    function setGamePrize(uint256, uint256) {}
}

contract Ottolotto is OwnableExtended {
    using SafeMath for uint256;
    using SafeMath for uint8;
    
    event StartedGame(uint256 indexed _game, uint256 _nextGame);
    event GameProgress(uint256 indexed _game, uint256 _processed, uint256 _toProcess);
    event Ticket(uint256 indexed _game, address indexed _address, bytes3 bet);
    event Win(address indexed _address, uint256 indexed _game, uint256 _matches, uint256 _amount, uint256 _time);
    event Jackpot(address indexed _address, uint256 indexed _game, uint256 _amount, uint256 _time);
    event RaisedByPartner(address indexed _partner, uint256 _game, uint256 _amount, uint256 _time);
    event ChampionGameStarted(uint256 indexed _game, uint256 _time);
    event ChampionGameFinished(uint256 indexed _game, address indexed _winner, uint256 _amount, uint256 _time);

    struct Winner {
        address player;
        bytes3  bet;
        uint8   matches;
    }
    
    struct Bet {
        address player;
        bytes3  bet;
    }

    struct TicketBet {
        bytes3  bet;
        bool    isPayed;
    }

    iChampion public champion;

    mapping(address => mapping(uint256 => TicketBet[])) tickets;
    mapping(uint256 => Bet[]) gameBets;
    mapping(uint256 => Winner[]) winners;
    mapping(uint256 => uint256) weiRaised;
    mapping(uint256 => uint256) gameStartBlock;
    mapping(uint256 => uint32[7]) gameStats;
    mapping(uint256 => bool) gameCalculated;
    mapping(uint256 => uint256) gameCalculationProgress;
    mapping(uint8 => uint8) percents;
    mapping(address => address) partner;
    mapping(address => address[]) partners;

    uint256 public jackpot;
    
    uint256 public gameNext;
    uint256 public gamePlayed;  
    uint8   public gameDuration = 6;

    bool public gamePlayedStatus = false;
    
    uint64  public ticketPrice = 0.001 ether;
    
    function Ottolotto() {}
    
    function init(address _champion) onlyOwner {
        require(gameNext == 0);
        gameNext = block.number;
        
        percents[1] = 5;
        percents[2] = 8;
        percents[3] = 12;
        percents[4] = 15;
        percents[5] = 25;
        percents[6] = 35;

        champion = iChampion(_champion);
    }

    function getGamePrize(uint256 _game)
            constant returns (uint256) {
        return weiRaised[_game];            
    }
    
    function getGameStartBlock(uint256 _game) 
            constant returns (uint256) {
        return gameStartBlock[_game];
    }
    
    function getGameCalculationProgress(uint256 _game) 
            constant returns (uint256) {
        return gameCalculationProgress[_game];
    }

    function getPlayersCount(uint256 _game)
            constant returns (uint256) {
        return gameBets[_game].length;
    }

    function getGameCalculatedStats(uint256 _game)
            constant returns (uint32[7]) {
        return gameStats[_game];
    }

    function getPartner(address _player) constant returns (address) {
        return partner[_player];
    }

    function getPartners(address _player) 
            constant returns (address[]) {
        return partners[_player];
    }

    function getBet(address _player, uint256 _game) 
        constant returns (bytes3[]) {
        bytes3[] memory bets = new bytes3[](tickets[_player][_game].length);
        for (uint32 i = 0; i < tickets[_player][_game].length; i++) {
            bets[i] = tickets[_player][_game][i].bet;
        }        
        return bets;
    }

    function getWinners(uint256 _game) 
            constant returns (address[]) {
        address[] memory _winners = new address[](winners[_game].length);
        for (uint32 i = 0; i < winners[_game].length; i++) {
            _winners[i] = winners[_game][i].player;
        }
        return _winners;
    }

    function betsArePayed(address _player, uint256 _game) constant returns (bool) {
        uint256 startBlock = getGameStartBlock(_game);
        for (uint16 i = 0; i < tickets[_player][_game].length; i++) {
            if (tickets[_player][_game][i].isPayed == false) {
                uint8 matches = getMatches(startBlock, tickets[_player][_game][i].bet);
                if (matches > 0) {
                    return false;
                }
            }
        }
        return true;
    }

    function getGameBlocks(uint256 _game) 
            constant returns(bytes32[]) {
        uint256 startBlock = getGameStartBlock(_game);
        bytes32[] memory blocks = new bytes32[](6);
        uint8 num = 0;
        for (startBlock; startBlock + num <= startBlock + gameDuration - 1; num++) {
            blocks[num] = block.blockhash(startBlock + num);
        }
        
        return blocks;
    }
    
    function toBytes(uint8 n1, uint8 n2, uint8 n3, uint8 n4, uint8 n5, uint8 n6) 
            internal constant returns (bytes3) {
        return bytes3(16**5*n1+16**4*n2+16**3*n3+16**2*n4+16**1*n5+n6);
    }
    
    function modifyBet(bytes32 _bet, uint256 _step) 
            internal constant returns (bytes32) {
        return _bet >> (232 + (_step * 4 - 4)) << 252 >> 252;
    }

    function modifyBlock(uint256 _blockNumber) 
            internal constant returns (bytes32) {
        return block.blockhash(_blockNumber) << 252 >> 252;
    }
    
    function equalNumber(bytes32 _bet, uint256 _game, uint256 _endBlock) 
            internal constant returns (bool) {
        uint256 step = _endBlock - _game;
        if (modifyBlock(_game) ^ modifyBet(_bet, step) == 0) {
            return true;
        }
        
        return false;
    }
    
    function makeBet(uint8 n1, uint8 n2, uint8 n3, uint8 n4, uint8 n5, uint8 n6, address _partner) 
            payable returns (bool) {
        require(msg.value == ticketPrice);
                
        bytes3 uBet = toBytes(n1, n2, n3, n4, n5, n6);
        Bet memory pBet = Bet({player: msg.sender, bet: uBet});
        TicketBet memory tBet = TicketBet({bet: uBet, isPayed: false});

        tickets[msg.sender][gameNext].push(tBet);
        gameBets[gameNext].push(pBet);
        
        weiRaised[gameNext] += ticketPrice;
        
        Ticket(gameNext, msg.sender, uBet);

        champion.buyTicket(msg.sender);

        if (_partner != 0x0 && partner[msg.sender] == 0x0) {
            addPartner(_partner, msg.sender);
        }

        return true;
    }

    function startGame() onlyAdmin returns (bool) {
        gamePlayed = gameNext;
        gameNext = block.number;
        gamePlayedStatus = true;

        gameStartBlock[gamePlayed] = gameNext + gameDuration;


        jackpot += weiRaised[gamePlayed].mul(percents[6]).div(100);
        StartedGame(gamePlayed, gameNext);

        return true;
    }

    function getMatches(uint256 _game, bytes3 _bet) 
            constant returns (uint8) {
        bytes32 bet = bytes32(_bet);
        uint256 endBlock = _game + gameDuration;
        uint8 matches = 0;
        for (; endBlock > _game; _game++) {
            if (equalNumber(bet, _game, endBlock)) {
                matches++;
                continue;
            }
            break;
        }
        
        return matches;
    }
        
    function getAllMatches(uint256 _game) 
            constant returns (uint256[]) {
        uint256 startBlock = getGameStartBlock(_game);
        uint256[] memory matches = new uint256[](7);
        for (uint32 i = 0; i < gameBets[_game].length; i++) {
            Bet memory bet = gameBets[_game][i];
            uint8 matched = getMatches(startBlock, bet.bet);
            if (matched == 0) {
                continue;
            }
            (matched == 1) ? matches[1] += 1 : 
            (matched == 2) ? matches[2] += 1 : 
            (matched == 3) ? matches[3] += 1 : 
            (matched == 4) ? matches[4] += 1 :
            (matched == 5) ? matches[5] += 1 :
            (matched == 6) ? matches[6] += 1 : matches[6] += 0;
        }
        
        return matches;
    }

    function gameIsOver(uint256 _game) 
            constant returns (bool) {
        if (gameStartBlock[_game] == 0) {
            return false;
        }

        return (gameStartBlock[_game] + gameDuration - 1) < block.number;   
    }

    function gameIsCalculated(uint256 _game)
            constant returns (bool) {
        return gameCalculated[_game];
    }

    function updateGameToCalculated(uint256 _game) internal {
        gameCalculated[_game] = true;
        gamePlayedStatus = false;
    }

    function processGame(uint256 _game, uint256 calculationStep) returns (bool) {
        require(gamePlayedStatus == true);
        require(gameIsOver(_game));

        if (gameIsCalculated(_game)) {
            return true;
        }


        if (gameCalculationProgress[_game] == gameBets[_game].length) {
            updateGameToCalculated(_game);
            return true;
        } 

        uint256 steps = calculationStep;
        if (gameCalculationProgress[_game] + steps > gameBets[_game].length) {
            steps -= gameCalculationProgress[_game] + steps - gameBets[_game].length;
        }
    
        uint32[] memory matches = new uint32[](7);
        uint256 to = gameCalculationProgress[_game] + steps;
        uint256 startBlock = getGameStartBlock(_game);
        for (; gameCalculationProgress[_game] < to; gameCalculationProgress[_game]++) {
            Bet memory bet = gameBets[_game][gameCalculationProgress[_game]];
            uint8 matched = getMatches(startBlock, bet.bet);
            if (matched == 0) {
                continue;
            }
            (matched == 1) ? matches[1] += 1 : 
            (matched == 2) ? matches[2] += 1 : 
            (matched == 3) ? matches[3] += 1 : 
            (matched == 4) ? matches[4] += 1 :
            (matched == 5) ? matches[5] += 1 :
            (matched == 6) ? matches[6] += 1 : gameStats[_game][6];
        }

        for (uint8 i = 1; i <= 6; i++) {
            gameStats[_game][i] += matches[i];
        }

        GameProgress(_game, gameCalculationProgress[_game], gameBets[_game].length);
        if (gameCalculationProgress[_game] == gameBets[_game].length) {
            updateGameToCalculated(_game);
            distributeRaisedWeiToJackpot(_game);
            return true;
        }

        return false;
    }

    function distributeRaisedWeiToJackpot(uint256 _game) internal {
        for (uint8 i = 1; i <= 5; i ++) {
            if (gameStats[_game][i] == 0) {
                jackpot += weiRaised[_game].mul(percents[i]).div(100);
            }
        }
    }

    function distributeFunds(uint256 weiWin, uint256 _game, uint8 matched, address _player) 
            internal {
        uint256 toOwner = weiWin.div(5);
        uint256 toPartner = 0;

        if (partner[_player] != 0x0) {
            toPartner = toOwner.mul(5).div(100);
            partner[_player].transfer(toPartner);
            RaisedByPartner(_player, _game, toPartner, now);
        }

        _player.transfer(weiWin - toOwner);
        owner.transfer(toOwner - toPartner);

        Win(_player, _game, matched, weiWin, now);
        if (matched == 6) {
            Jackpot(_player, _game, weiWin, now);
        }
    }

    function getPrize(address _player, uint256 _game, bytes3 _bet, uint16 _index) 
            returns (bool) {
        TicketBet memory ticket = tickets[_player][_game][_index];

        if (ticket.isPayed || ticket.bet != _bet) {
            return false;
        }
        
        uint256 startBlock = getGameStartBlock(_game);
        uint8 matched = getMatches(startBlock, ticket.bet);
        if (matched == 0) {
            return false;
        }

        uint256 weiWin = 0;
        if (matched != 6) {
            uint256 weiByMatch = weiRaised[gamePlayed].mul(percents[matched]).div(100);
            weiWin = weiByMatch.div(gameStats[_game][matched]);
        } else {
            weiWin = jackpot.div(gameStats[_game][matched]);
            jackpot -= weiWin;
        }
        
        distributeFunds(weiWin, _game, matched, _player);

        ticket.isPayed = true;
        tickets[_player][_game][_index] = ticket;

        winners[gamePlayed].push(Winner({
            player: _player,
            bet: ticket.bet,
            matches: matched
        }));

        return true;
    }

    function addPartner(address _partner, address _player) 
            internal returns (bool) {
        if (partner[_player] != 0x0) {
            return false;
        }

        partner[_player] = _partner;
        partners[_partner].push(_player);

        return true;
    }

    // champion
    function startChampionGame() onlyAdmin {
        champion.startGame();

        uint256 currentGame = champion.currentGameBlockNumber();
        ChampionGameStarted(currentGame, now);
    }

    function finishChampionGame() onlyAdmin {
        uint256 currentGame = champion.currentGameBlockNumber();
        
        address winner = champion.finishCurrentGame();
        require(winner != 0x0);

        champion.setGamePrize(currentGame, jackpot);

        winner.transfer(jackpot - jackpot.div(5));
        owner.transfer(jackpot.div(5));

        ChampionGameFinished(currentGame, winner, jackpot, now);

        jackpot = 0;
    }
}