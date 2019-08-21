contract cEthereumlotteryNet {
	/*
		cEthereumlotteryNet
		Coded by: iFA
		http://c.ethereumlottery.net
		ver: 2.0.0
	*/
	address owner;
	bool private contractEnabled = true;
	uint public constant ticketPrice = 10 finney;
	uint private constant defaultJackpot = 100 ether;
	uint private constant feep = 23;
	uint private constant hit3p = 35;
	uint private constant hit4p = 25;
	uint private constant hit5p = 40;
	uint8 private constant maxNumber = 30;
	uint private constant drawCheckStep = 100;
	uint private constant prepareBlockDelay = 5;
	uint private drawDelay = 7 days;
	uint private feeValue;

	struct hits_s {
		uint prize;
		uint count;
	}
	
	enum drawStatus_ { Wait, Prepared ,InProcess, Done }
	
	struct tickets_s {
		uint hits;
		bytes5 numbers;
	}
	
	struct games_s {
		uint startTime;
		uint endTime;
		uint jackpot;
		uint8[5] winningNumbers;
		mapping (uint => hits_s) hits;
		uint prizePot;
		drawStatus_ drawStatus;
		bytes32 winHash;
		mapping (uint => tickets_s) tickets;
		uint ticketsCount;
		uint checkedTickets;
		bytes32 nextHashOfSecretKey;
		uint prepareDrawBlock;
	}
	
	mapping(uint => games_s) private games;
	
	uint public CurrentGameId = 0;
	
	struct player_s {
		bool paid;
		uint[] tickets;
	}
	
	mapping(address => mapping(uint => player_s)) private players;
	uint private playersSize;
	
	string constant public Information = "http://c.ethereumlottery.net";
	
	function ContractStatus() constant returns (bool Enabled) {
		Enabled = contractEnabled;
	}
	function GameDetails(uint GameId) constant returns ( uint StartTime, uint EndTime, uint Jackpot, uint TicketsCount) {
		Jackpot = games[GameId].jackpot;
		TicketsCount = games[GameId].ticketsCount;
		StartTime = games[GameId].startTime;
		EndTime = games[GameId].endTime;
	}
	function DrawDetails(uint GameId) constant returns (
		string DrawStatus, bytes32 WinHash, uint8[5] WinningNumbers,
		uint Hit3Count, uint Hit4Count, uint Hit5Count,
		uint Hit3Prize, uint Hit4Prize, uint Hit5Prize) {
		DrawStatus = WritedrawStatus(games[GameId].drawStatus);
		if (games[GameId].drawStatus != drawStatus_.Wait) {
			WinningNumbers = games[GameId].winningNumbers;
			Hit3Count = games[GameId].hits[3].count;
			Hit4Count = games[GameId].hits[4].count;
			Hit5Count = games[GameId].hits[5].count;
			Hit3Prize = games[GameId].hits[3].prize;
			Hit4Prize = games[GameId].hits[4].prize;
			Hit5Prize = games[GameId].hits[5].prize;
			WinHash = games[GameId].winHash;
		} else {
			WinningNumbers = [0,0,0,0,0];
			Hit3Count = 0;
			Hit4Count = 0;
			Hit5Count = 0;
			Hit3Prize = 0;
			Hit4Prize = 0;
			Hit5Prize = 0;
			WinHash = 0;
		}
	}
	function CheckTickets(address Address,uint GameId,uint TicketNumber) constant returns (uint8[5] Numbers, uint Hits, bool Paid) {
		if (players[Address][GameId].tickets[TicketNumber] > 0) {
			Numbers[0] = uint8(uint40(games[GameId].tickets[players[Address][GameId].tickets[TicketNumber]].numbers) /256/256/256/256);
			Numbers[1] = uint8(uint40(games[GameId].tickets[players[Address][GameId].tickets[TicketNumber]].numbers) /256/256/256);
			Numbers[2] = uint8(uint40(games[GameId].tickets[players[Address][GameId].tickets[TicketNumber]].numbers) /256/256);
			Numbers[3] = uint8(uint40(games[GameId].tickets[players[Address][GameId].tickets[TicketNumber]].numbers) /256);
			Numbers[4] = uint8(games[GameId].tickets[players[Address][GameId].tickets[TicketNumber]].numbers);
			Numbers = sortWinningNumbers(Numbers);
			Hits = games[GameId].tickets[players[Address][GameId].tickets[TicketNumber]].hits;
			Paid = players[Address][GameId].paid;
		}
	}
	function CheckPrize(address Address, uint GameId) constant returns(uint Value) {
		if (players[Address][GameId].paid == false) {
		    if (contractEnabled) { 
    			if (games[GameId].drawStatus == drawStatus_.Done) {
    				for (uint b = 0 ; b < players[Address][GameId].tickets.length ; b++) {
    					if (games[GameId].tickets[players[Address][GameId].tickets[b]].hits == 3){
    						Value += games[GameId].hits[3].prize;
    					} else if (games[GameId].tickets[players[Address][GameId].tickets[b]].hits == 4){
    						Value += games[GameId].hits[4].prize;
    					} else if (games[GameId].tickets[players[Address][GameId].tickets[b]].hits == 5){
    						Value += games[GameId].hits[5].prize;
    					}
    				}
    			}
		    } else {
    		    if (GameId == CurrentGameId) {
    		        Value = players[msg.sender][GameId].tickets.length * ticketPrice;
    		    }
		    }
		}
	}
	function cEthereumlotteryNet() {
		owner = msg.sender;
		CreateNewDraw(defaultJackpot);
	}
	function GetPrize(uint GameId) external {
		uint Balance;
		uint GameBalance;
		if (players[msg.sender][GameId].paid == false) {
    		if (contractEnabled) { 
    		    if (games[GameId].drawStatus != drawStatus_.Done) { throw; }
        		for (uint b = 0 ; b < players[msg.sender][GameId].tickets.length ; b++) {
        			if (games[GameId].tickets[players[msg.sender][GameId].tickets[b]].hits == 3){
        				Balance += games[GameId].hits[3].prize;
        			} else if (games[GameId].tickets[players[msg.sender][GameId].tickets[b]].hits == 4){
        				Balance += games[GameId].hits[4].prize;
        			} else if (games[GameId].tickets[players[msg.sender][GameId].tickets[b]].hits == 5){
        				Balance += games[GameId].hits[5].prize;
        			}
        		}
        		players[msg.sender][GameId].paid = true;
        		games[GameId].prizePot -= Balance;
    		} else {
    		    if (GameId == CurrentGameId) {
    		        Balance = players[msg.sender][GameId].tickets.length * ticketPrice;
    		        players[msg.sender][GameId].paid = true;
    		    }
    		}
		}
		if (Balance > 0) {
			if (msg.sender.send(Balance) == false) { throw; }
		} else {
			throw;
		}
	}
	function AddTicket(bytes5[] tickets) OnlyEnabled IfInTime IfDrawWait external {
		uint ticketsCount = tickets.length;
		if (ticketsCount > 70 || ticketsCount == 0) { throw; }
		if (msg.value < ticketsCount * ticketPrice) { throw; }
		if (msg.value > (ticketsCount * ticketPrice)) { if (msg.sender.send(msg.value - (ticketsCount * ticketPrice)) == false) { throw; } }
		for (uint a = 0 ; a < ticketsCount ; a++) {
			if (!CheckNumbers(ConvertNumbers(tickets[a]))) { throw; }
			games[CurrentGameId].tickets[games[CurrentGameId].ticketsCount].numbers = tickets[a];
			players[msg.sender][CurrentGameId].tickets.length += 1;
			players[msg.sender][CurrentGameId].tickets[players[msg.sender][CurrentGameId].tickets.length-1] = games[CurrentGameId].ticketsCount;
			games[CurrentGameId].ticketsCount++;
		}
	}
	function () {
		throw;
	}
	function ProcessDraw() OnlyEnabled IfDrawProcess {
		uint StepCount = drawCheckStep;
		if (games[CurrentGameId].checkedTickets < games[CurrentGameId].ticketsCount) {
			for (uint a = games[CurrentGameId].checkedTickets ; a < games[CurrentGameId].ticketsCount ; a++) {
				if (StepCount == 0) { break; }
				for (uint b = 0 ; b < 5 ; b++) {
					for (uint c = 0 ; c < 5 ; c++) {
						if (uint8(uint40(games[CurrentGameId].tickets[a].numbers) / (256**b)) == games[CurrentGameId].winningNumbers[c]) {
							games[CurrentGameId].tickets[a].hits += 1;
						}
					}
				}
				games[CurrentGameId].checkedTickets += 1;
				StepCount -= 1;
			}
		}
		if (games[CurrentGameId].checkedTickets == games[CurrentGameId].ticketsCount) {
			for (a = 0 ; a < games[CurrentGameId].ticketsCount ; a++) {
				if (games[CurrentGameId].tickets[a].hits == 3) {
					games[CurrentGameId].hits[3].count +=1;
				} else if (games[CurrentGameId].tickets[a].hits == 4) {
					games[CurrentGameId].hits[4].count +=1;
				} else if (games[CurrentGameId].tickets[a].hits == 5) {
					games[CurrentGameId].hits[5].count +=1;
				}
			}
			if (games[CurrentGameId].hits[3].count > 0) { games[CurrentGameId].hits[3].prize = games[CurrentGameId].prizePot * hit3p / 100 / games[CurrentGameId].hits[3].count; }
			if (games[CurrentGameId].hits[4].count > 0) { games[CurrentGameId].hits[4].prize = games[CurrentGameId].prizePot * hit4p / 100 / games[CurrentGameId].hits[4].count; }
			if (games[CurrentGameId].hits[5].count > 0) { games[CurrentGameId].hits[5].prize = games[CurrentGameId].jackpot / games[CurrentGameId].hits[5].count; }
			uint NextJackpot;
			if (games[CurrentGameId].hits[5].count == 0) {
				NextJackpot = games[CurrentGameId].prizePot * hit5p / 100 + games[CurrentGameId].jackpot;
			} else {
				NextJackpot = defaultJackpot;
			}
			games[CurrentGameId].prizePot = (games[CurrentGameId].hits[3].count*games[CurrentGameId].hits[3].prize) + (games[CurrentGameId].hits[4].count*games[CurrentGameId].hits[4].prize) + (games[CurrentGameId].hits[5].count*games[CurrentGameId].hits[5].prize);
			games[CurrentGameId].drawStatus = drawStatus_.Done;
			CreateNewDraw(NextJackpot);
		}
	}
	function StartDraw() external OnlyEnabled IfDrawPrepared {
		if (games[CurrentGameId].prepareDrawBlock > block.number) { throw; }
		games[CurrentGameId].drawStatus = drawStatus_.InProcess;
		games[CurrentGameId].winHash = makeHash();
		games[CurrentGameId].winningNumbers = sortWinningNumbers(GetNumbersFromHash(games[CurrentGameId].winHash));
		feeValue += ticketPrice * games[CurrentGameId].ticketsCount * feep / 100;
		games[CurrentGameId].prizePot = ticketPrice * games[CurrentGameId].ticketsCount - feeValue;
		ProcessDraw();
	}
	function PrepareDraw() external OnlyEnabled ReadyForDraw {
		if (games[CurrentGameId].ticketsCount > 0) {
			games[CurrentGameId].drawStatus = drawStatus_.Prepared;
			games[CurrentGameId].prepareDrawBlock = block.number + prepareBlockDelay;
		} else {
			if (!contractEnabled) { throw; }
			games[CurrentGameId].endTime = calcNextDrawTime();
		}
	}
	function OwnerCloseContract() external OnlyOwner OnlyEnabled {
		contractEnabled = false;
		uint contractbalance = this.balance;
		for (uint a=0 ; a <= CurrentGameId ; a++) {
			contractbalance -= games[a].prizePot;
		}
		contractbalance -= games[CurrentGameId].ticketsCount * ticketPrice;
		if (contractbalance == 0 ) { throw; }
		if (owner.send(contractbalance) == false) { throw; }
		feeValue = 0;
	}
	function OwnerAddFunds() external OnlyOwner {
		return;
	}
	function OwnerGetFee() external OnlyOwner {
		if (feeValue == 0) { throw; }
		if (owner.send(feeValue) == false) { throw; }
		feeValue = 0;
	}
	function CreateNewDraw(uint Jackpot) private {
		CurrentGameId += 1;
		games[CurrentGameId].startTime = now;
		games[CurrentGameId].endTime = calcNextDrawTime();
		games[CurrentGameId].jackpot = Jackpot;
		games[CurrentGameId].drawStatus = drawStatus_.Wait;
	}
	function ConvertNumbers(bytes5 input) private returns (uint8[5] output){
		output[0] = uint8(uint40(input) /256/256/256/256);
		output[1] = uint8(uint40(input) /256/256/256);
		output[2] = uint8(uint40(input) /256/256);
		output[3] = uint8(uint40(input) /256);
		output[4] = uint8(input);
	}
	function CheckNumbers(uint8[5] tickets) private returns (bool ok) {
		for (uint8 a = 0 ; a < 5 ; a++) {
			if ((tickets[a] < 1 ) || (tickets[a] > maxNumber)) { return false; }
			for (uint8 b = 0 ; b < 5 ; b++) { if ((tickets[a] == tickets[b]) && (a != b)) {	return false; }	}
		}
		return true;
	}
	function GetNumbersFromHash(bytes32 hash) private returns (uint8[5] tickets) {
		bool ok = true;
		uint8 num = 0;
		uint hashpos = 0;
		uint8 a;
		for (a = 0 ; a < 5 ; a++) {
			while (true) {
				ok = true;
				if (hashpos == 32) {
					hashpos = 0;
					hash = sha3(hash);
				}
				num = GetPart(hash,hashpos);
				num = num%maxNumber+1;
				hashpos += 1;
				for (uint8 b = 0 ; b < 5 ; b++) {
					if (tickets[b] == num) {
						ok = false;
						break; 
					}
				}
				if (ok == true) {
					tickets[a] = num;
					break;
				}
			}
		}
	}
	function GetPart(bytes32 a, uint i) private returns (uint8) { return uint8(byte(bytes32(uint(a) * 2 ** (8 * i)))); }
	function WritedrawStatus(drawStatus_ input) private returns (string drawStatus) {
		if (input == drawStatus_.Wait) {
			drawStatus = "Wait";
		} else if (input == drawStatus_.InProcess) {
			drawStatus = "In Process";
		} else if (input == drawStatus_.Done) {
			drawStatus = "Done";
		} else if (input == drawStatus_.Prepared) {
			drawStatus = "Prepared";
		}
	}
	function sortWinningNumbers(uint8[5] numbers) private returns(uint8[5] sortednumbers) {
		sortednumbers = numbers;
		for (uint8 i=0; i<5; i++) {
			for (uint8 j=i+1; j<5; j++) {
				if (sortednumbers[i] > sortednumbers[j]) {
					uint8 t = sortednumbers[i];
					sortednumbers[i] = sortednumbers[j];
					sortednumbers[j] = t;
				}
			}
		}
	}
	function makeHash() private returns (bytes32 hash) {
		for ( uint a = 0 ; a <= prepareBlockDelay ; a++ ) {
			hash = sha3(hash, games[CurrentGameId].prepareDrawBlock - a);
		}
		hash = sha3(hash, block.difficulty, block.coinbase, block.timestamp, tx.origin, games[CurrentGameId].ticketsCount);
	}
	function calcNextDrawTime() private returns (uint ret) {
		ret = 1461499200; // 2016.04.24 12:00:00
		while (ret < now) {
			ret += drawDelay;
		}
	}
	modifier OnlyOwner() { if (owner != msg.sender) { throw; } _ }
	modifier OnlyEnabled() { if (!contractEnabled) { throw; } _	}
	modifier IfDrawWait() { if (games[CurrentGameId].drawStatus != drawStatus_.Wait) { throw; } _	}
	modifier IfDrawPrepared() { if (games[CurrentGameId].drawStatus != drawStatus_.Prepared) { throw; } _	}
	modifier IfDrawProcess() { if (games[CurrentGameId].drawStatus != drawStatus_.InProcess) { throw; } _	}
	modifier IfInTime() { if (games[CurrentGameId].endTime < now) { throw; } _ }
	modifier ReadyForDraw() { if (games[CurrentGameId].endTime > now || games[CurrentGameId].drawStatus != drawStatus_.Wait) { throw; } _ }
}