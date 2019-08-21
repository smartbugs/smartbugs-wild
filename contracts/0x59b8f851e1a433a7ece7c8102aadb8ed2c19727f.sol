/*
	WeeklyLotteryB
	Coded by: iFA
	http://wlb.ethereumlottery.net
	ver: 1.1
*/

contract WLBdrawsDBInterface {
	function newDraw(uint date, uint8[3] numbers, uint hit3Count, uint hit3Value, uint hit2Count, uint hit2Value);
	function getDraw(uint id) constant returns (uint date, uint8[3] numbers, uint hit3Count, uint hit3Value, uint hit2Count, uint hit2Value);
}

contract WeeklyLotteryB {
	/* structures */
	struct games_s {
		uint ticketsCount;
		mapping(bytes32 => uint) hit3Hash;
		mapping(bytes32 => uint) hit2Hash;
		uint startTimestamp;
		uint endTimestamp;
		bytes3 winningNumbersBytes;
		uint prepareBlock;
		bool drawDone;
		uint prizePot;
		uint hit3Count;
		uint hit3Value;
		uint hit2Count;
		uint hit2Value;
	}
	struct playerGames_s {
		bytes3[] numbersBytes;
		mapping(bytes32 => uint) hit3Hash;
		mapping(bytes32 => uint) hit2Hash;
		bool checked;
	}
	struct players_s {
		mapping(uint => playerGames_s) games;
	}
	struct investors_s {
		address owner;
		uint value;
		uint balance;
		bool live;
		bool valid;
		uint begins;
	}
	struct draws_s {
		uint date;
		uint gameID;
		bytes3 numbersBytes;
		uint hit3Count;
		uint hit3Value;
		uint hit2Count;
		uint hit2Value;
	}
	/* config */
	uint public constant ticketPrice = 100 finney; // 0.1 ether
	uint private constant drawMaxNumber = 50;
	uint private constant drawBlockDelay = 5;
	uint private constant prizeDismissDelay = 5;
	uint private constant contractDismissDelay = 5 weeks;
	uint private constant investUnit = 1 ether;
	uint private constant investMinimum = 10 ether;
	uint private constant investUserLimit = 200;
	uint private constant investMinDuration = 5; // 5 draw!
	uint private constant investIdleTime = 1 days;
	uint private constant forOwner = 2; //%
	uint private constant forInvestors = 40; //%
	uint private constant forHit2 = 30; //%
	/* variables */
	address private WLBdrawsDB;
	address private owner;
	uint private currentJackpot;
	uint private investmentsValue;
	uint private extraJackpot;
	uint private ticketCounter;
	uint private currentGame;
	uint private ownerBalance;
	bool public contractEnabled = true;
	uint private contractDisabledTimeStamp;
	mapping(address => players_s) private players;
	games_s[] private games;
	investors_s[] private investors;
	/* events */
	event NewTicketEvent(address Player, uint8 Number1, uint8 Number2, uint8 Number3);
	event ContractDisabledEvent(uint DeadlineTime);
	event DrawPrepareEvent(uint BlockNumber);
	event DrawEvent(uint GameID, uint8 Number1, uint8 Number2, uint8 Number3, uint Hit3Count, uint Hit3Value, uint Hit2Count, uint Hit2Value);
	event InvestAddEvent(address Investor, uint Value);
	event InvestCancelEvent(address Investor, uint Value);
	/* constructor */
	function WeeklyLotteryB(address _WLBdrawsDB) {
		WLBdrawsDB = _WLBdrawsDB;
		owner = msg.sender;
		currentGame = 1;
		games.length = 2;
		games[1].startTimestamp = now;
		games[1].endTimestamp = calcNextDrawTime();
	}
	/* constant functions */
	function Visit() constant returns (string) { return "http://wlb.ethereumlottery.net"; }
	function Draws(uint id) constant returns (uint date, uint8[3] Numbers, uint hit3Count, uint hit3Value, uint hit2Count, uint hit2Value) {
		return WLBdrawsDBInterface( WLBdrawsDB ).getDraw(id);
	}
	function CurrentGame() constant returns (uint GameID, uint Jackpot, uint Start, uint End, uint Tickets) {
		return (currentGame, currentJackpot, games[currentGame].startTimestamp, games[currentGame].endTimestamp, games[currentGame].ticketsCount);
	}
	function PlayerTickets(address Player, uint GameID, uint TicketID) constant returns (uint8[3] numbers, bool Checked) {
		return ( getNumbersFromBytes( players[Player].games[GameID].numbersBytes[TicketID] ), players[Player].games[GameID].checked);
	}
	function Investors(address Address) constant returns(uint Investment, uint Balance, bool Live) {
		var (found, InvestorID) = getInvestorByAddress(Address);
		if (found == false || ! investors[InvestorID].valid) {
			return (0, 0, false);
		}
		return (investors[InvestorID].value, investors[InvestorID].balance, investors[InvestorID].live);
	}
	function CheckPrize(address Address) constant returns(uint value) {
		uint gameID;
		uint gameLowID;
		uint8[3] memory numbers;
		uint hit3Count;
		uint hit2Count;
		if (currentGame < prizeDismissDelay) {
			gameLowID = 1;
		} else {
			gameLowID = currentGame-prizeDismissDelay;
		}
		for ( gameID=currentGame ; gameID>=gameLowID ; gameID-- ) {
			if ( ! players[Address].games[gameID].checked) {
				if (games[gameID].drawDone) {
					numbers = getNumbersFromBytes(games[gameID].winningNumbersBytes);
					hit3Count = players[Address].games[gameID].hit3Hash[sha3( numbers[0], numbers[1], numbers[2] )];
					value += hit3Count * games[gameID].hit3Value;
					hit2Count = players[Address].games[gameID].hit2Hash[sha3( numbers[0], numbers[1] )];
					hit2Count += players[Address].games[gameID].hit2Hash[sha3( numbers[0], numbers[2] )];
					hit2Count += players[Address].games[gameID].hit2Hash[sha3( numbers[1], numbers[2] )];
					hit2Count -= hit3Count*3;
					value += hit2Count * games[gameID].hit2Value;
				} else if ( ! contractEnabled && gameID == currentGame) {
					value += players[Address].games[gameID].numbersBytes.length * ticketPrice;
				}
			}
		}
	}
	/* callback function */
	function () {
		var Numbers = getNumbersFromHash(sha3(block.coinbase, now, ticketCounter));
		BuyTicket(Numbers[0],Numbers[1],Numbers[2]);
	}
	/* external functions for players */
	function BuyTicket(uint8 Number1, uint8 Number2, uint8 Number3) noContract OnlyEnabled {
		var Numbers = [Number1 , Number2 , Number3];
		if ( ! checkNumbers( Numbers )) { throw; }
		Numbers = sortNumbers(Numbers);
		if (msg.value < ticketPrice) { throw; }
		if (msg.value-ticketPrice > 0) { if ( ! msg.sender.send( msg.value-ticketPrice )) { throw; } }
		if (currentJackpot == 0) { throw; }
		if (games[currentGame].endTimestamp < now) { throw; }
		ticketCounter++;
		games[currentGame].ticketsCount++;
		bytes32 hash0 = sha3( Numbers[0], Numbers[1], Numbers[2] );
		bytes32 hash1 = sha3( Numbers[0], Numbers[1]);
		bytes32 hash2 = sha3( Numbers[0], Numbers[2]);
		bytes32 hash3 = sha3( Numbers[1], Numbers[2]);
		games[currentGame].hit3Hash[hash0]++;
		games[currentGame].hit2Hash[hash1]++;
		games[currentGame].hit2Hash[hash2]++;
		games[currentGame].hit2Hash[hash3]++;
		players[msg.sender].games[currentGame].numbersBytes.push ( getBytesFromNumbers(Numbers) );
		players[msg.sender].games[currentGame].hit3Hash[hash0]++;
		players[msg.sender].games[currentGame].hit2Hash[hash1]++;
		players[msg.sender].games[currentGame].hit2Hash[hash2]++;
		players[msg.sender].games[currentGame].hit2Hash[hash3]++;
		NewTicketEvent( msg.sender, Numbers[0], Numbers[1], Numbers[2] );
	}
	function CheckTickets() external noEther noContract {
		uint _value;
		uint _subValue;
		uint gameID;
		uint gameLowID;
		uint8[3] memory numbers;
		bool changed;
		uint hit3Count;
		uint hit2Count;
		if (currentGame < prizeDismissDelay) {
			gameLowID = 1;
		} else {
			gameLowID = currentGame-prizeDismissDelay;
		}
		for ( gameID=currentGame ; gameID>=gameLowID ; gameID-- ) {
			if ( ! players[msg.sender].games[gameID].checked) {
				if (games[gameID].drawDone) {
					numbers = getNumbersFromBytes(games[gameID].winningNumbersBytes);
					hit3Count = players[msg.sender].games[gameID].hit3Hash[sha3( numbers[0], numbers[1], numbers[2] )];
					_subValue += hit3Count * games[gameID].hit3Value;
					hit2Count = players[msg.sender].games[gameID].hit2Hash[sha3( numbers[0], numbers[1] )];
					hit2Count += players[msg.sender].games[gameID].hit2Hash[sha3( numbers[0], numbers[2] )];
					hit2Count += players[msg.sender].games[gameID].hit2Hash[sha3( numbers[1], numbers[2] )];
					hit2Count -= hit3Count*3;
					_subValue += hit2Count * games[gameID].hit2Value;
					games[gameID].prizePot -= _subValue;
					_value += _subValue;
					players[msg.sender].games[gameID].checked = true;
					changed = true;
				} else if ( ! contractEnabled && gameID == currentGame) {
					_value += players[msg.sender].games[gameID].numbersBytes.length * ticketPrice;
					players[msg.sender].games[gameID].checked = true;
					changed = true;
				}
			}
		}
		if ( ! changed) { throw; }
		if (_value > 0) { if ( ! msg.sender.send(_value)) { throw; } }
	}
	/* external functions for investors */
	function InvestAdd() external OnlyEnabled noContract {
		uint value_ = msg.value;
		if (value_ < investUnit) { throw; }
		if (value_ % investUnit > 0) { 
			if ( ! msg.sender.send( value_ % investUnit )) { throw; } 
			value_ = value_ - (value_ % investUnit);
		}
		if (value_ < investMinimum) { throw; }
		var (found, InvestorID) = getInvestorByAddress(msg.sender);
		if (found == false) {
			if (investors.length == investUserLimit) { throw; }
			InvestorID = investors.length;
			investors.length++;
		}
		if (investors[InvestorID].valid && investors[InvestorID].live) {
			investors[InvestorID].value += value_;
		} else {
			investors[InvestorID].value = value_;
		}
		investors[InvestorID].begins = currentGame;
		investors[InvestorID].valid = true;
		investors[InvestorID].live = true;
		investors[InvestorID].owner = msg.sender;
		investmentsValue += value_;
		setJackpot();
		InvestAddEvent(msg.sender, value_);
	}
	function InvestWithdraw() external noEther {
		var (found, InvestorID) = getInvestorByAddress(msg.sender);
		if (found == false) { throw; }
		if ( ! investors[InvestorID].valid) { throw; }
		uint _balance = investors[InvestorID].balance;
		if (_balance == 0) { throw; }
		investors[InvestorID].balance = 0;
		if ( ! msg.sender.send( _balance )) { throw; }
	}
	function InvestCancel() external noEther {
		var (found, InvestorID) = getInvestorByAddress(msg.sender);
		if (found == false) { throw; }
		if ( ! investors[InvestorID].valid) { throw; }
		if (contractEnabled) {
			if (investors[InvestorID].begins+investMinDuration > now) { throw; }
			if (games[currentGame].startTimestamp+investIdleTime > now) { throw; }
		}
		uint balance_;
		if (investors[InvestorID].live) {
			investmentsValue -= investors[InvestorID].value;
			balance_ = investors[InvestorID].value;
			setJackpot();
			InvestCancelEvent(msg.sender, investors[InvestorID].value);
		}
		if (investors[InvestorID].balance > 0) {
			balance_ += investors[InvestorID].balance;
		}
		delete investors[InvestorID];
		if ( ! msg.sender.send( balance_ )) { throw; }
	}
	/* draw functions for everyone*/
	function DrawPrepare() noContract OnlyEnabled noEther {
		if (games[currentGame].endTimestamp > now || games[currentGame].prepareBlock != 0) { throw; }
		games[currentGame].prepareBlock = block.number+drawBlockDelay;
		DrawPrepareEvent(games[currentGame].prepareBlock);
	}
	function Draw() noContract OnlyEnabled noEther {
		if (games[currentGame].prepareBlock == 0 || games[currentGame].prepareBlock > block.number) { throw; }
		bytes32 _hash;
		uint hit3Value;
		uint hit3Count;
		uint hit2Value;
		uint hit2Count;
		uint a;
		for ( a = 1 ; a <= drawBlockDelay ; a++ ) {
			_hash = sha3(_hash, block.blockhash(games[currentGame].prepareBlock - drawBlockDelay+a));
		}
		var numbers = getNumbersFromHash(_hash);
		games[currentGame].winningNumbersBytes = getBytesFromNumbers( numbers );
		hit3Count += games[currentGame].hit3Hash[ sha3( numbers[0], numbers[1],numbers[2] ) ];
		hit2Count += games[currentGame].hit2Hash[ sha3( numbers[0], numbers[1]) ];
		hit2Count += games[currentGame].hit2Hash[ sha3( numbers[0], numbers[2]) ];
		hit2Count += games[currentGame].hit2Hash[ sha3( numbers[1], numbers[2]) ];
		hit2Count -= hit3Count*3;
		uint totalPot = games[currentGame].ticketsCount*ticketPrice;
		hit2Value = ( totalPot * forHit2 / 100 );
		games[currentGame].prizePot = hit2Value;
		hit2Value = hit2Value / hit2Count;
		totalPot -= hit2Value;
		uint _ownerBalance = totalPot * forHit2 / 100;
		totalPot -= _ownerBalance;
		ownerBalance += _ownerBalance;
		uint _addInvestorsValue = totalPot * forInvestors / 100;
		addInvestorsValue(_addInvestorsValue);
		totalPot -= _addInvestorsValue;
		if (hit3Count > 0) {
			games[currentGame].prizePot += currentJackpot;
			for ( a=0 ; a < investors.length ; a++ ) {
				delete investors[a].live;
			}
			hit3Value = currentJackpot / hit3Count;
			extraJackpot = 0;
			investmentsValue = 0;
		}
		extraJackpot += totalPot;
		setJackpot();
		DrawEvent(currentGame, numbers[0], numbers[1], numbers[2], hit3Count, hit3Value, hit2Count, hit2Value);
		WLBdrawsDBInterface( WLBdrawsDB ).newDraw( now, numbers, hit3Count, hit3Value, hit2Count, hit2Value);
		games[currentGame].hit3Count = hit3Count;
		games[currentGame].hit3Value = hit3Value;
		games[currentGame].hit2Count = hit2Count;
		games[currentGame].hit2Value = hit2Value;
		games[currentGame].drawDone = true;
		newGame();
	}
	/* owner functions */
	function OwnerGetFee() external OnlyOwner {
		if (ownerBalance == 0) { throw; }
		if (owner.send(ownerBalance) == false) { throw; }
		ownerBalance = 0;
	}
	function OwnerCloseContract() external OnlyOwner noEther {
		if ( ! contractEnabled) {
			if (contractDisabledTimeStamp+contractDismissDelay < now) {
				suicide(owner);
			}
		} else {
			contractEnabled = false;
			contractDisabledTimeStamp = now;
			ContractDisabledEvent(contractDisabledTimeStamp+contractDismissDelay);
			ownerBalance += extraJackpot;
			extraJackpot = 0;
			games[currentGame].prizePot = games[currentGame].ticketsCount*ticketPrice;
		}
	}
	/* private functions */
	function addInvestorsValue(uint value) private {
		bool done;
		uint a;
		for ( a=0 ; a < investors.length ; a++ ) {
			if (investors[a].live && investors[a].valid) {
				investors[a].balance += value * investors[a].value / investmentsValue;
				done = true;
			}
		}
		if ( ! done) {
			ownerBalance += value;
		}
	}
	function newGame() private {
		currentGame++;
		uint gamesID = games.length;
		games.length++;
		games[gamesID].startTimestamp = now;
		games[gamesID].endTimestamp = calcNextDrawTime();
		if (games.length > prizeDismissDelay) {
			ownerBalance += games[currentGame-prizeDismissDelay].prizePot;
			delete games[currentGame-prizeDismissDelay];
		}
	}
	function getNumbersFromHash(bytes32 hash) private returns (uint8[3] numbers) {
		bool ok = true;
		uint8 num = 0;
		uint hashpos = 0;
		uint8 a;
		uint8 b;
		for (a = 0 ; a < numbers.length ; a++) {
			while (true) {
				ok = true;
				if (hashpos == 32) {
					hashpos = 0;
					hash = sha3(hash);
				}
				num = getPart( hash, hashpos );
				num = num % uint8(drawMaxNumber) + 1;
				hashpos += 1;
				for (b = 0 ; b < numbers.length ; b++) {
					if (numbers[b] == num) {
						ok = false;
						break; 
					}
				}
				if (ok == true) {
					numbers[a] = num;
					break;
				}
			}
		}
		numbers = sortNumbers( numbers );
	}
	function getPart(bytes32 a, uint i) private returns (uint8) { return uint8(byte(bytes32(uint(a) * 2 ** (8 * i)))); }
	function setJackpot() private {
		currentJackpot = investmentsValue + extraJackpot;
	}
	function getInvestorByAddress(address Address) private returns (bool found, uint id) {
		for ( id=0 ; id < investors.length ; id++ ) {
			if (investors[id].owner == Address) {
				return (true, id);
			}
		}
		return (false, 0);
	}
	function checkNumbers(uint8[3] Numbers) private returns (bool) {
		for ( uint a = 0 ; a < Numbers.length ; a++ ) {
			if (Numbers[a] > drawMaxNumber || Numbers[a] == 0) { return; }
			for ( uint b = 0 ; a < Numbers.length ; a++ ) {
				if (a != b && Numbers[a] == Numbers[b]) { return; }
			}
		}
		return true;
	}
	function calcNextDrawTime() private returns (uint ret) {
		ret = 1468152000;
		while (ret < now) {
			ret += 1 weeks;
		}
	}
	function sortNumbers(uint8[3] numbers) private returns(uint8[3] sNumbers) {
		sNumbers = numbers;
		for (uint8 i=0; i<numbers.length; i++) {
			for (uint8 j=i+1; j<numbers.length; j++) {
				if (sNumbers[i] > sNumbers[j]) {
					uint8 t = sNumbers[i];
					sNumbers[i] = sNumbers[j];
					sNumbers[j] = t;
				}
			}
		}
	}
	function getNumbersFromBytes(bytes3 Bytes) private returns (uint8[3] Numbers){
		Numbers[0] = uint8(Bytes);
		Numbers[1] = uint8(uint24(Bytes) /256);
		Numbers[2] = uint8(uint24(Bytes) /256/256);
	}
	function getBytesFromNumbers(uint8[3] Numbers) private returns (bytes3 Bytes) {
		return bytes3(uint(Numbers[0])+uint(Numbers[1])*256+uint(Numbers[2])*256*256);
	}
	/* modifiers */
	modifier noContract() {if (tx.origin != msg.sender) { throw; } _ }
	modifier noEther() { if (msg.value > 0) { throw; } _ }
	modifier OnlyOwner() { if (owner != msg.sender) { throw; } _ }
	modifier OnlyEnabled() { if ( ! contractEnabled) { throw; } _ }
}