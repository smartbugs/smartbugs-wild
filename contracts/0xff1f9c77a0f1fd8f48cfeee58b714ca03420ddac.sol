pragma solidity ^0.4.8;

// version (ZK)


contract iE4RowEscrow {
	function getNumGamesStarted() constant returns (int ngames);
}


contract E4RowEscrow is iE4RowEscrow {

event StatEvent(string msg);
event StatEventI(string msg, uint val);
event StatEventA(string msg, address addr);

	uint constant MAX_PLAYERS = 5;

	enum EndReason  {erWinner, erTimeOut, erCancel}
	enum SettingStateValue  {debug, release, lockedRelease}

	struct gameInstance {
		address[5] players;
		uint[5] playerPots;
		uint numPlayers;

		bool active; // active
		bool allocd; //  allocated already. 
		uint started; // time game started
		uint lastMoved; // time game last moved
		uint payout; // payout amont
		address winner; // address of winner
		

		EndReason reasonEnded; // enum reason of ended
		
	}
	
	struct arbiter {
		mapping (uint => uint)  gameIndexes; // game handles

		uint arbToken; // 2 bytes
		uint gameSlots; // a counter of alloc'd game structs (they can be reused)
		uint gamesStarted; // total games started
		uint gamesCompleted;
		uint gamesCanceled; // also tied
		uint gamesTimedout;
		uint numPlayers;
		bool registered; 
		bool locked;
	}


	address public  owner; 	// owner is address that deployed contract
	address public  tokenPartner; 	// the address of partner that receives rake fees
	uint public numArbiters; 	// number of arbiters

	int numGamesStarted;	// total stats from all arbiters

	uint public numGamesCompleted; // ...
	uint public numGamesCanceled; 	// tied and canceled
	uint public numGamesTimedOut;	// ...

	uint public houseFeeHoldover; // hold fee till threshold
	uint public lastPayoutTime; 	// timestamp of last payout time


	// configurables
	uint public gameTimeOut;
	uint public registrationFee;
	uint public houseFeeThreshold;
	uint public payoutInterval;

	uint raGas; // for register arb
	uint sgGas;// for start game
	uint wpGas; // for winner paid
	uint rfGas; // for refund
	uint feeGas; // for rake fee payout

	SettingStateValue public settingsState = SettingStateValue.debug; 
	

	mapping (address => arbiter)  arbiters;
	mapping (uint => address)  arbiterTokens;
	mapping (uint => address)  arbiterIndexes;
	mapping (uint => gameInstance)  games;


	function E4RowEscrow() public
	{
		owner = msg.sender;
	}


	function applySettings(SettingStateValue _state, uint _fee, uint _threshold, uint _timeout, uint _interval)
	{
		if (msg.sender != owner) 
			throw;

		// ----------------------------------------------
		// these items are tweakable for game optimization
		// ----------------------------------------------
		houseFeeThreshold = _threshold;
		gameTimeOut = _timeout;
		payoutInterval = _interval;
	
		if (settingsState == SettingStateValue.lockedRelease) {
			StatEvent("Settings Tweaked");
			return;
		}

 	 	settingsState = _state;
		registrationFee = _fee;

		// set default op gas -  any futher settings done in set up gas
		raGas = 150000; 
		sgGas = 110000;
		wpGas = 20000; 
		rfGas = 20000; 
		feeGas = 360000; 

		StatEvent("Settings Changed");

	
	}

	//-----------------------------
	// return an arbiter token from an hGame
	//-----------------------------
	function ArbTokFromHGame(uint _hGame) returns (uint _tok)
	{ 
		_tok =  (_hGame / (2 ** 48)) & 0xffff;
	}


	//-----------------------------
	// suicide the contract, not called for release
	//-----------------------------
	function HaraKiri()
	{
		if ((msg.sender == owner) && (settingsState != SettingStateValue.lockedRelease))
			  suicide(tokenPartner);
		else
			StatEvent("Kill attempt failed");
	}




	//-----------------------------
	// default function
	// who are we to look a gift-horse in the mouth?
	//-----------------------------
 	function() payable  {
		StatEvent("thanks!");
  	}

	//------------------------------------------------------
	// check active game and valid player, return player index
	//-------------------------------------------------------
	function validPlayer(uint _hGame, address _addr)  internal returns( bool _valid, uint _pidx)
	{
		_valid = false;
		if (activeGame(_hGame)) {
			for (uint i = 0; i < games[_hGame].numPlayers; i++) {
				if (games[_hGame].players[i] == _addr) {
					_valid=true;
					_pidx = i;
					break;
				}
			}
		}			
	}

	//------------------------------------------------------
	// check valid player, return player index
	//-------------------------------------------------------
	function validPlayer2(uint _hGame, address _addr) internal  returns( bool _valid, uint _pidx)
	{
		_valid = false;
		for (uint i = 0; i < games[_hGame].numPlayers; i++) {
			if (games[_hGame].players[i] == _addr) {
				_valid=true;
				_pidx = i;
				break;
			}
		}
	}

	//------------------------------------------------------
	// check the arbiter is valid by comparing token
	//------------------------------------------------------
	function validArb(address _addr, uint _tok) internal  returns( bool _valid)
	{
		_valid = false;

		if ((arbiters[_addr].registered)
			&& (arbiters[_addr].arbToken == _tok)) 
			_valid = true;
	}

	//------------------------------------------------------
	// check the arbiter is valid without comparing token
	//------------------------------------------------------
	function validArb2(address _addr) internal  returns( bool _valid)
	{
		_valid = false;
		if (arbiters[_addr].registered)
			_valid = true;
	}

	//------------------------------------------------------
	// check if arbiter is locked out
	//------------------------------------------------------
	function arbLocked(address _addr) internal  returns( bool _locked)
	{
		_locked = false;
		if (validArb2(_addr)) 
			_locked = arbiters[_addr].locked;
	}

	//------------------------------------------------------
	// return if game is active
	//------------------------------------------------------
	function activeGame(uint _hGame) internal  returns( bool _valid)
	{
		_valid = false;
		if ((_hGame > 0)
			&& (games[_hGame].active))
			_valid = true;
	}


	//------------------------------------------------------
	// register game arbiter, max players of 5, pass in exact registration fee
	//------------------------------------------------------
	function registerArbiter(uint _numPlayers, uint _arbToken) public payable 
	{

		if (msg.value != registrationFee) {
			throw;  //Insufficient Fee
		}

		if (_arbToken == 0) {
			throw; // invalid token
		}

		if (arbTokenExists(_arbToken & 0xffff)) {
			throw; // Token Already Exists
		}

		if (arbiters[msg.sender].registered) {
			throw; // Arb Already Registered
		}
		
		if (_numPlayers > MAX_PLAYERS) {
			throw; // Exceeds Max Players
		}

		arbiters[msg.sender].gamesStarted = 0;
		arbiters[msg.sender].gamesCompleted = 0;
		arbiters[msg.sender].gamesCanceled = 0; 
		arbiters[msg.sender].gamesTimedout = 0;
		arbiters[msg.sender].locked = false;
		arbiters[msg.sender].arbToken = _arbToken & 0xffff;
		arbiters[msg.sender].numPlayers = _numPlayers;
		arbiters[msg.sender].registered = true;

		arbiterTokens[(_arbToken & 0xffff)] = msg.sender;
		arbiterIndexes[numArbiters++] = msg.sender;
	

		if (!tokenPartner.call.gas(raGas).value(msg.value)()) {
			//Statvent("Send Error"); // event never registers
		        throw;
		}
		StatEventI("Arb Added", _arbToken);
	}


	//------------------------------------------------------
	// start game.  pass in valid hGame containing token in top two bytes
	//------------------------------------------------------
	function startGame(uint _hGame, int _hkMax, address[] _players) public 

	{
		uint ntok = ArbTokFromHGame(_hGame);
		if (!validArb(msg.sender, ntok )) {
			StatEvent("Invalid Arb");
			return;
		}


		if (arbLocked(msg.sender)) {
			StatEvent("Arb Locked");
			return; 
		}

		arbiter xarb = arbiters[msg.sender];
		if (_players.length != xarb.numPlayers) { 
			StatEvent("Incorrect num players");
			return; 
		}

		if (games[_hGame].active) {
			// guard-rail. just in case to return funds
			abortGame(msg.sender, _hGame, EndReason.erCancel);

		} else if (_hkMax > 0) {
			houseKeep(_hkMax, ntok); 
		}

		if (!games[_hGame].allocd) {
			games[_hGame].allocd = true;
			xarb.gameIndexes[xarb.gameSlots++] = _hGame;
		} 
		numGamesStarted++; // always inc this one
		xarb.gamesStarted++;

		games[_hGame].active = true;
		games[_hGame].started = now; 
		games[_hGame].lastMoved = now; 
		games[_hGame].payout = 0; 
		games[_hGame].winner = address(0);

		games[_hGame].numPlayers = _players.length; // we'll be the judge of how many unique players
		for (uint i = 0; i< _players.length && i < MAX_PLAYERS; i++) {
	            games[_hGame].players[i] = _players[i];
		    games[_hGame].playerPots[i] = 0;
		}

		StatEventI("Game Added", _hGame);
		

	}
	
	//------------------------------------------------------
	// clean up game, set to inactive, refund any balances
	// called by housekeep ONLY
	//------------------------------------------------------
	function abortGame(address _arb, uint  _hGame, EndReason _reason) private returns(bool _success)
	{
	     gameInstance nGame = games[_hGame];
	     
		// find game in game id, 
		if (nGame.active) {
			_success = true;
			for (uint i = 0; i < nGame.numPlayers; i++) {
				if (nGame.playerPots[i] > 0) {
					address a = nGame.players[i];
					uint nsend = nGame.playerPots[i];
					nGame.playerPots[i] = 0;
					if (!a.call.gas(rfGas).value(nsend)()) {
						houseFeeHoldover += nsend; // cannot refund due to error, give to the house
					        StatEventA("Cannot Refund Address", a);
					}
				}
			}
			nGame.active = false;
			nGame.reasonEnded = _reason;
			if (_reason == EndReason.erCancel) {
				numGamesCanceled++;
				arbiters[_arb].gamesCanceled++;
				StatEvent("Game canceled");
			} else if (_reason == EndReason.erTimeOut) {
				numGamesTimedOut++;
				arbiters[_arb].gamesTimedout++;
				StatEvent("Game timed out");
			} else 
				StatEvent("Game aborted");
		}
	}


	//------------------------------------------------------
	// called by arbiter when winner is decided
	// *pass in high num for winnerbal for tie games
	//------------------------------------------------------
	function winnerDecided(uint _hGame, address _winner, uint _winnerBal) public
	{

		if (!validArb(msg.sender, ArbTokFromHGame(_hGame))) {
			StatEvent("Invalid Arb");	
			return; // no throw no change made
		}

		var (valid, pidx) = validPlayer(_hGame, _winner);
		if (!valid) {
			StatEvent("Invalid Player");	
			return;
		}

		arbiter xarb = arbiters[msg.sender];
		gameInstance xgame = games[_hGame];

		uint totalPot = 0;

		if (xgame.playerPots[pidx] < _winnerBal) {
		    abortGame(msg.sender, _hGame, EndReason.erCancel);
  		    return;
		}

		for (uint i = 0; i < xgame.numPlayers; i++) {
			totalPot += xgame.playerPots[i];
		}
		
		uint nportion;
		uint nremnant;
		if (totalPot > 0) {
		 	nportion = totalPot/50; // 2 percent fixed
			nremnant = totalPot-nportion;
		} else {
			nportion = 0;
			nremnant = 0;
		}
		

		xgame.lastMoved = now;
		xgame.active = false;
		xgame.reasonEnded = EndReason.erWinner;
		xgame.winner = _winner;
		xgame.payout = nremnant;
		
		if (nportion > 0) {
			houseFeeHoldover += nportion;
			if ((houseFeeHoldover > houseFeeThreshold)
				&& (now > (lastPayoutTime + payoutInterval))) {
				uint ntmpho = houseFeeHoldover;
				houseFeeHoldover = 0;
				lastPayoutTime = now; // reset regardless of succeed/fail
				if (!tokenPartner.call.gas(feeGas).value(ntmpho)()) {
					houseFeeHoldover = ntmpho; // put it back
					StatEvent("House-Fee Error1");
				} 
			}
		}
	
		for (i = 0; i < xgame.numPlayers; i++) {
			xgame.playerPots[i] = 0;
		}

		xarb.gamesCompleted++;
		numGamesCompleted++;
		if (nremnant > 0) {
			if (!_winner.call.gas(wpGas).value(uint(nremnant))()) {
				// StatEvent("Send Error");
			        throw; // if you cant pay the winner - very bad
			} else {
				StatEventI("Winner Paid", _hGame);		
			}
		}
	}

	//------------------------------------------------------
	// handle a bet made by a player, validate the player and game
	// add to players balance
	//------------------------------------------------------
	function handleBet(uint _hGame) public payable 
	{
		address narb = arbiterTokens[ArbTokFromHGame(_hGame)];
		if (narb == address(0)) {
			throw; // "Invalid hGame"
		}

		var (valid, pidx) = validPlayer(_hGame, msg.sender);
		if (!valid) {
			throw; // "Invalid Player"
		}

		games[_hGame].playerPots[pidx] += msg.value;
		games[_hGame].lastMoved = now;

		StatEventI("Bet Added", _hGame);

	}


	//------------------------------------------------------
	// return if arb token exists
	//------------------------------------------------------
	function arbTokenExists(uint _tok) constant returns (bool _exists)
	{
		_exists = false;
		if ((_tok > 0)
			&& (arbiterTokens[_tok] != address(0))
			&& arbiters[arbiterTokens[_tok]].registered)
			_exists = true;

	}




	//------------------------------------------------------
	// called by ico token contract 
	//------------------------------------------------------
	function getNumGamesStarted() constant returns (int _games) 
	{
		_games = numGamesStarted;
	}

	//------------------------------------------------------
	// return arbiter game stats
	//------------------------------------------------------
	function getArbInfo(uint _idx) constant  returns (address _addr, uint _started, uint _completed, uint _canceled, uint _timedOut) 
	{
		if (_idx >= numArbiters) {
			StatEvent("Invalid Arb");
			return;
		}
		_addr = arbiterIndexes[_idx];
		if ((_addr == address(0))
			|| (!arbiters[_addr].registered)) {
			StatEvent("Invalid Arb");
			return;
		}
		arbiter xarb = arbiters[_addr];
		_started = xarb.gamesStarted;
		_completed = xarb.gamesCompleted;
		_timedOut = xarb.gamesTimedout;
		_canceled = xarb.gamesCanceled;
	}


	//------------------------------------------------------
	// scan for a game 10 minutes old
	// if found abort the game, causing funds to be returned
	//------------------------------------------------------
	function houseKeep(int _max, uint _arbToken) public
	{	
		uint gi;
		address a;
		int aborted = 0;
		
		arbiter xarb = arbiters[msg.sender];// have to set it to something
	        
         
		if (msg.sender == owner) {
			for (uint ar = 0; (ar < numArbiters) && (aborted < _max) ; ar++) {
			    a = arbiterIndexes[ar];
			    xarb = arbiters[a];    

			    for ( gi = 0; (gi < xarb.gameSlots) && (aborted < _max); gi++) {
				gameInstance ngame0 = games[xarb.gameIndexes[gi]];
				if ((ngame0.active)
				    && ((now - ngame0.lastMoved) > gameTimeOut)) {
					abortGame(a, xarb.gameIndexes[gi], EndReason.erTimeOut);
					++aborted;
				}
			    }
			}

		} else {
			if (!validArb(msg.sender, _arbToken))
				StatEvent("Housekeep invalid arbiter");
			else {
			    a = msg.sender;
			    xarb = arbiters[a];    
			    for (gi = 0; (gi < xarb.gameSlots) && (aborted < _max); gi++) {
				gameInstance ngame1 = games[xarb.gameIndexes[gi]];
				if ((ngame1.active)
				    && ((now - ngame1.lastMoved) > gameTimeOut)) {
					abortGame(a, xarb.gameIndexes[gi], EndReason.erTimeOut);
					++aborted;
				}
			    }

			}	
		}
	}


	//------------------------------------------------------
	// return game info
	//------------------------------------------------------
	function getGameInfo(uint _hGame)  constant  returns (EndReason _reason, uint _players, uint _payout, bool _active, address _winner )
	{
		gameInstance ngame = games[_hGame];
		_active = ngame.active;
		_players = ngame.numPlayers;
		_winner = ngame.winner;
		_payout = ngame.payout;
		_reason = ngame.reasonEnded;

	}

	//------------------------------------------------------
	// return arbToken and low bytes from an HGame
	//------------------------------------------------------
	function checkHGame(uint _hGame) constant returns(uint _arbTok, uint _lowWords)
	{
		_arbTok = ArbTokFromHGame(_hGame);
		_lowWords = _hGame & 0xffffffffffff;
		
	}

	//------------------------------------------------------
	// get operation gas amounts
	//------------------------------------------------------
	function getOpGas() constant returns (uint _ra, uint _sg, uint _wp, uint _rf, uint _fg) 
	{
		_ra = raGas; // register arb
		_sg = sgGas; // start game
		_wp = wpGas; // winner paid
		_rf = rfGas; // refund
		_fg = feeGas; // rake fee gas
	}


	//------------------------------------------------------
	// set operation gas amounts for forwading operations
	//------------------------------------------------------
	function setOpGas(uint _ra, uint _sg, uint _wp, uint _rf, uint _fg) 
	{
		if (msg.sender != owner)
			throw;

		raGas = _ra;
		sgGas = _sg;
		wpGas = _wp;
		rfGas = _rf;
		feeGas = _fg;
	}

	//------------------------------------------------------
	// set a micheivous arbiter to locked
	//------------------------------------------------------
	function setArbiterLocked(address _addr, bool _lock)  public 
	{
		if (owner != msg.sender)  {
			throw; 
		} else if (!validArb2(_addr)) {
			StatEvent("invalid arb");
		} else {
			arbiters[_addr].locked = _lock;
		}
		
	}

	//------------------------------------------------------
	// flush the house fees whenever commanded to.
	// ignore the threshold and the last payout time
	// but this time only reset lastpayouttime upon success
	//------------------------------------------------------
	function flushHouseFees()
	{
		if (msg.sender != owner) {
			StatEvent("only owner calls this function");
		} else if (houseFeeHoldover > 0) {
			uint ntmpho = houseFeeHoldover;
			houseFeeHoldover = 0;
			if (!tokenPartner.call.gas(feeGas).value(ntmpho)()) {
				houseFeeHoldover = ntmpho; // put it back
				StatEvent("House-Fee Error2"); 
			} else {
				lastPayoutTime = now;
 				StatEvent("House-Fee Paid");
	 		}
		}

	}


	//------------------------------------------------------
	// set the token partner
	//------------------------------------------------------
	function setTokenPartner(address _addr) public
	{
		if (msg.sender != owner) {
			throw;
		} 

		if ((settingsState == SettingStateValue.lockedRelease) 
			&& (tokenPartner == address(0))) {
			tokenPartner = _addr;
			StatEvent("Token Partner Final!");
		} else if (settingsState != SettingStateValue.lockedRelease) {
			tokenPartner = _addr;
			StatEvent("Token Partner Assigned!");
		}
			
	}

	// ----------------------------
	// swap executor
	// ----------------------------
	function changeOwner(address _addr) 
	{
		if (msg.sender != owner
			|| settingsState == SettingStateValue.lockedRelease)
			 throw;

		owner = _addr;
	}



}