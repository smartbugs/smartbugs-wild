pragma solidity ^0.4.8;

library ArrayLib {
  // Inserts to keep array sorted (assumes input array is sorted)
	function insertInPlace(uint8[] storage self, uint8 n) {
		uint8 insertingIndex = 0;

		while (self.length > 0 && insertingIndex < self.length && self[insertingIndex] < n) {
			insertingIndex += 1;
		}

		self.length += 1;
		for (uint8 i = uint8(self.length) - 1; i > insertingIndex; i--) {
			self[i] = self[i - 1];
		}

		self[insertingIndex] = n;
	}
}

library DeckLib {
	using ArrayLib for uint8[];

	enum Suit { Spades, Hearts, Clubs, Diamonds }
	uint8 constant cardsPerSuit = 13;
	uint8 constant suits = 4;
	uint8 constant totalCards = cardsPerSuit * suits;

	struct Deck {
		uint8[] usedCards; // always has to be sorted
		address player;
		uint256 gameID;
	}

	function init(Deck storage self, uint256 gameID)  {
		self.usedCards = new uint8[](0);
		self.player = msg.sender;
		self.gameID = gameID;
	}

	function getCard(Deck storage self, uint256 blockNumber)  returns (uint8)  {
		uint cardIndex = self.usedCards.length;
		if (cardIndex >= totalCards) throw;
		uint8 r = uint8(getRandomNumber(blockNumber, self.player, self.gameID, cardIndex, totalCards - cardIndex));

		for (uint8 i = 0; i < cardIndex; i++) {
			if (self.usedCards[i] <= r) r += 1;
		}

		self.usedCards.insertInPlace(r);

		return r;
	}

	function cardDescription(uint8 self) constant returns (Suit, uint8) {
		return (Suit(self / cardsPerSuit), cardFacevalue(self));
	}

	function cardEmojified(uint8 self) constant returns (uint8, string) {
		string memory emojiSuit;

		var (suit, number) = cardDescription(self);
		if (suit == Suit.Clubs) emojiSuit = "♣️";
		else if (suit == Suit.Diamonds) emojiSuit = "♦️";
		else if (suit == Suit.Hearts) emojiSuit = "♥️";
		else if (suit == Suit.Spades) emojiSuit = "♠️";

		return (number, emojiSuit);
	}

	function cardFacevalue(uint8 self) constant returns (uint8) {
		return 1 + self % cardsPerSuit;
	}

	function blackjackValue(uint8 self) constant returns (uint8) {
		uint8 cardValue = cardFacevalue(self);
		return cardValue < 10 ? cardValue : 10;
	}

	function getRandomNumber(uint b, address player, uint256 gameID, uint n, uint m) constant returns (uint) {
		// Uses blockhash as randomness source.
		// Credits: https://github.com/Bunjin/Rouleth/blob/master/Provably_Fair_No_Cheating.md
		bytes32 blockHash = block.blockhash(b);
		if (blockHash == 0x0) throw;
		return uint(uint256(keccak256(blockHash, player, gameID, n)) % m);

	}
}



library GameLib {
  using DeckLib for *;

  uint8 constant houseLimit = 17;
  uint8 constant target = 21;

  enum ComparaisonResult { First, Second, Tie }
  enum GameState { InitialCards, Waiting, Hit, Stand, DoubleDown, Finished }
  enum GameResult { Ongoing, House, Tie, Player, PlayerNatural }

  struct Game {
    address player;
    uint256 bet;
    uint256 payout;
    uint256 gameID;

    DeckLib.Deck deck;
    uint8[] houseCards;
    uint8[] playerCards;

    uint256 actionBlock; // Block on which commitment to perform an action happens.

    GameState state;
    GameResult result;

    bool closed;
  }

  function init(Game storage self, uint256 gameID) {
    self.player = msg.sender;
    self.bet = msg.value;
    self.payout = 0;
    self.houseCards = new uint8[](0);
    self.playerCards = new uint8[](0);
    self.actionBlock = block.number;
    self.state = GameState.InitialCards;
    self.result = GameResult.Ongoing;
    self.closed = false;
    self.gameID = gameID;

    self.deck.init(gameID);
  }

  function tick(Game storage self) returns (bool) {
    if (block.number <= self.actionBlock) return false; // Can't tick yet
    if (self.actionBlock + 255 < block.number) {
      endGame(self, GameResult.House);
      return true;
    }
    if (!needsTick(self)) return true; // not needed, everything is fine
    if (self.state == GameState.InitialCards) dealInitialCards(self);
    if (self.state == GameState.Hit) dealHitCard(self);
    if (self.state == GameState.DoubleDown) {
      dealHitCard(self);
      forceStand(self);
    }

    if (self.state == GameState.Stand) {
      dealHouseCards(self);
      checkGameResult(self);
    } else {
      checkGameContinues(self);
    }

    return true;
  }

  function needsTick(Game storage self) constant returns (bool) {
    if (self.state == GameState.Waiting) return false;
    if (self.state == GameState.Finished) return false;

    return true;
  }

  function checkGameResult(Game storage self)  {
    uint8 houseHand = countHand(self.houseCards);

    if (houseHand == target && self.houseCards.length == 2) return endGame(self, GameResult.House); // House natural

    ComparaisonResult result = compareHands(houseHand, countHand(self.playerCards));
    if (result == ComparaisonResult.First) return endGame(self, GameResult.House);
    if (result == ComparaisonResult.Second) return endGame(self, GameResult.Player);

    endGame(self, GameResult.Tie);
  }

  function checkGameContinues(Game storage self)  {
    uint8 playerHand = countHand(self.playerCards);
    if (playerHand == target && self.playerCards.length == 2) return endGame(self, GameResult.PlayerNatural); // player natural
    if (playerHand > target) return endGame(self, GameResult.House); // Player busted
    if (playerHand == target && self.state == GameState.Waiting) {
      // Player is forced to stand with 21 (but should not  already standing, ie in double down)
      forceStand(self);
    }
  }

  function forceStand(Game storage self) {
    uint256 currentActionBlock = self.actionBlock;
    playerDecision(self, GameState.Stand);
    self.actionBlock = currentActionBlock;
    if (!tick(self)) throw; // Forces tick, commitment to play actually happened past block
  }

  function canDoubleDown(Game storage self) returns (bool) {
    if (self.playerCards.length > 2) return false;
    uint8 totalPlayer = countHand(self.playerCards);
    if (totalPlayer < 9 || totalPlayer > 11) return false;
    if (msg.value != self.bet) return false;
    return true;
  }

  function playerDecision(Game storage self, GameState decision)  {
    if (self.state != GameState.Waiting) throw;
    if (decision != GameState.Hit && decision != GameState.Stand && decision != GameState.DoubleDown) throw;

    if (decision == GameState.DoubleDown){
      if (!canDoubleDown(self)) throw;
      self.bet += msg.value;
    }

    self.state = decision;
    self.actionBlock = block.number;
  }

  function dealInitialCards(Game storage self) private {
    self.playerCards.push(self.deck.getCard(self.actionBlock));
    self.houseCards.push(self.deck.getCard(self.actionBlock));
    self.playerCards.push(self.deck.getCard(self.actionBlock));
    self.state = GameState.Waiting;
  }

  function dealHitCard(Game storage self) private {
    self.playerCards.push(self.deck.getCard(self.actionBlock));
    self.state = GameState.Waiting;
  }

  function dealHouseCards(Game storage self) private {
    self.houseCards.push(self.deck.getCard(self.actionBlock));
    if (countHand(self.houseCards) < houseLimit) dealHouseCards(self);
  }

  function endGame(Game storage self, GameResult result) {
    self.result = result;
    self.state = GameState.Finished;
    self.payout = payoutForResult(self.result, self.bet);

    closeGame(self);
  }

  function closeGame(Game storage self) private {
    if (self.closed) throw; // cannot re-close
    if (self.state != GameState.Finished) throw; // not closable

    self.closed = true;

    if (self.payout > 0) {
      if (!self.player.send(self.payout)) throw;
    }
  }

  function payoutForResult(GameResult result, uint256 bet) private returns (uint256) {
    if (result == GameResult.PlayerNatural) return bet * 5 / 2; // bet + 1.5x bet
    if (result == GameResult.Player) return bet * 2; // doubles bet
    if (result == GameResult.Tie) return bet; // returns bet

    return 0;
  }

  function countHand(uint8[] memory hand)  returns (uint8) {
    uint8[] memory possibleSums = new uint8[](1);

    for (uint i = 0; i < hand.length; i++) {
      uint8 value = hand[i].blackjackValue();
      uint l = possibleSums.length;
      for (uint j = 0; j < l; j++) {
        possibleSums[j] += value;
        if (value == 1) { // is Ace
          possibleSums = appendArray(possibleSums, possibleSums[j] + 10); // Fork possible sum with 11 as ace value.
        }
      }
    }

    return bestSum(possibleSums);
  }

  function bestSum(uint8[] possibleSums)  returns (uint8 bestSum) {
    bestSum = 50; // very bad hand
    for (uint i = 0; i < possibleSums.length; i++) {
      if (compareHands(bestSum, possibleSums[i]) == ComparaisonResult.Second) {
        bestSum = possibleSums[i];
      }
    }
    return;
  }

  function appendArray(uint8[] memory array, uint8 n)  returns (uint8[] memory) {
    uint8[] memory newArray = new uint8[](array.length + 1);
    for (uint8 i = 0; i < array.length; i++) {
      newArray[i] = array[i];
    }
    newArray[array.length] = n;
    return newArray;
  }

  function compareHands(uint8 a, uint8 b)  returns (ComparaisonResult) {
    if (a <= target && b <= target) {
      if (a > b) return ComparaisonResult.First;
      if (a < b) return ComparaisonResult.Second;
    }

    if (a > target && b > target) {
      if (a < b) return ComparaisonResult.First;
      if (a > b) return ComparaisonResult.Second;
    }

    if (a > target) return ComparaisonResult.Second;
    if (b > target) return ComparaisonResult.First;

    return ComparaisonResult.Tie;
  }
}

contract Blockjack {
  
  event GameEnded(uint256 gameID, address player, uint gameResult, uint256 wager, uint256 payout, uint8 playerHand, uint8 houseHand);
  event GameNeedsTick(uint256 gameID, address player, uint256 actionBlock);

  using GameLib for GameLib.Game;

  GameLib.Game[] games;
  mapping (address => uint256) public currentGame;

  // Initial settings
  uint256 public minBet = 10 finney;
  uint256 public maxBet = 500 finney;
  bool public allowsNewGames = true;
  uint256 public maxBlockActions = 10;

  mapping (uint256 => uint256) blockActions;

  //main
  address public DX;
  address public DEV;

  uint256 public initialBankroll;
  uint256 public currentBankroll;

  mapping (address => bool) public isOwner;

  modifier onlyOwner {
    if (!isOwner[msg.sender]) throw;
    _;
  }

  modifier only(address x) {
    if (msg.sender != x) throw;
    _;
  }

  modifier onlyPlayer(uint256 gameID) {
    if (msg.sender != games[gameID].player) throw;
    _;
  }

  modifier blockActionProtected {
    blockActions[block.number] += 1;
    if (blockActions[block.number] > maxBlockActions) throw;
    _;
  }

  function Blockjack(address _DX, address _DEV) {
    DX = _DX;
    DEV = _DEV;
    games.length += 1;
    games[0].init(0); // Init game 0 so indices start on 1
    games[0].player = this;
    isOwner[DX] = true;
    isOwner[DEV] = true;
  }

  function () payable {
    startGame();
  }

  function startGame() blockActionProtected payable {
    if (!allowsNewGames) throw;
    if (msg.value < minBet) throw;
    if (msg.value > maxBet) throw;

    // check if player has game opened
    uint256 currentGameId = currentGame[msg.sender];
    if (games.length > currentGameId) {
      GameLib.Game openedGame = games[currentGameId];
      if (openedGame.player == msg.sender && !openedGame.closed) { // Check for index 0 mapping problems
	if (!openedGame.tick()) throw;
	if (!openedGame.closed) throw; // cannot start game with on-going game
	recordEndedGame(currentGameId);
      }
    }
    uint256 newGameID = games.length;

    games.length += 1;
    games[newGameID].init(newGameID);
    currentGame[msg.sender] = newGameID;
    tickRequiredLog(games[newGameID]);
  }

  function hit(uint256 gameID) onlyPlayer(gameID) blockActionProtected {
    GameLib.Game game = games[gameID];
    if (!game.tick()) throw;
    game.playerDecision(GameLib.GameState.Hit);
    tickRequiredLog(game);
  }

  function doubleDown(uint256 gameID) onlyPlayer(gameID) blockActionProtected payable {
    GameLib.Game game = games[gameID];
    if (!game.tick()) throw;
    game.playerDecision(GameLib.GameState.DoubleDown);
    tickRequiredLog(game);
  }

  function stand(uint256 gameID) onlyPlayer(gameID) blockActionProtected {
    GameLib.Game game = games[gameID];
    if (!game.tick()) throw;
    game.playerDecision(GameLib.GameState.Stand);
    tickRequiredLog(game);
  }

  function gameTick(uint256 gameID) blockActionProtected {
    GameLib.Game openedGame = games[gameID];
    if (openedGame.closed) throw;
    if (!openedGame.tick()) throw;
    if (openedGame.closed) recordEndedGame(gameID);
  }

  function recordEndedGame(uint gameID) private {
    GameLib.Game openedGame = games[gameID];

    //vs potential overflow when croupier is not ticking frequently enough
    if(currentBankroll + openedGame.bet > openedGame.payout){
      currentBankroll = currentBankroll + openedGame.bet - openedGame.payout;
    }

    GameEnded(
	      openedGame.gameID,
	      openedGame.player,
	      uint(openedGame.result),
	      openedGame.bet,
	      openedGame.payout,
	      GameLib.countHand(openedGame.playerCards),
	      GameLib.countHand(openedGame.houseCards)
	      );
  }

  function tickRequiredLog(GameLib.Game storage game) private {
    GameNeedsTick(game.gameID, game.player, game.actionBlock);
  }

  // Constants

  function gameState(uint i) constant returns (uint8[], uint8[], uint8, uint8, uint256, uint256, uint8, uint8, bool, uint256) {
    GameLib.Game game = games[i];

    return (
	    game.houseCards,
	    game.playerCards,
	    GameLib.countHand(game.houseCards),
	    GameLib.countHand(game.playerCards),
	    game.bet,
	    game.payout,
	    uint8(game.state),
	    uint8(game.result),
	    game.closed,
	    game.actionBlock
	    );
  }


  function changeDev(address newDev) only(DEV) {
    isOwner[DEV] = false;
    DEV = newDev;
    isOwner[DEV] = true;
  }

  function changeDX(address newDX) only(DX) {
    isOwner[DX] = false;
    DX = newDX;
    isOwner[DX] = true;
  }

  function setSettings(uint256 _min, uint256 _max, uint256 _maxBlockActions) only(DX) {
    minBet = _min;
    maxBet = _max;
    maxBlockActions = _maxBlockActions;
  }

  function registerOwner(address _new_watcher) only(DX) {
    isOwner[_new_watcher] = true;
  }

  function removeOwner(address _old_watcher) only(DX) {
    isOwner[_old_watcher] = false;
  }

  function stopBlockjack() onlyOwner {
    allowsNewGames = false;
  }

  function startBlockjack() only(DX) {
    allowsNewGames = true;
  }

  function addBankroll() only(DX) payable {
    initialBankroll += msg.value;
    currentBankroll += msg.value;
  }

  function migrateBlockjack() only(DX) {
    stopBlockjack();
    shareProfits();
    suicide(DX);
  }

  uint256 DX_PROFITS = 90;
  uint256 DEV_PROFITS = 10;
  uint256 PROFITS_BASE = 100;
  
  function shareProfits() onlyOwner{
    if (currentBankroll <= initialBankroll) return; // there are no profits
    uint256 profit = currentBankroll - initialBankroll;
    uint256 notSent;
    if (!DX.send(profit * DX_PROFITS / PROFITS_BASE)) {
      notSent = profit * DX_PROFITS / PROFITS_BASE;
    }
    if (!DEV.send(profit * DEV_PROFITS / PROFITS_BASE)){
      notSent = profit * DEV_PROFITS / PROFITS_BASE;
    }
    currentBankroll -= profit - notSent;
  }


  
}