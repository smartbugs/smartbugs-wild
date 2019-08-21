contract aEthereumlotteryNet {
	/*
		aEthereumlotteryNet
		Coded by: iFA
		http://a.ethereumlottery.net
		ver: 1.0.1
	*/
	address private owner;
	uint private collectedFee;
	bool public contractEnabled = true;
	uint public ticketPrice = 1 finney; // 0.01 ether
	uint private feeP = 5; // 5 %
	uint private drawDelay = 7 days;
	uint private drawAtLeastTicketCount = 10000;
	uint private drawAtLeastPlayerCount = 10;
	uint private placeMultiple  =  10000;
	uint private place1P    	= 600063; // 60.0063 %
	uint private place2P    	= 240025; // 24.0025 %
	uint private place3P    	=  96010; //  9.6010 %
	uint private place4P    	=  38404; //  3.8404 %
	uint private place5P    	=  15362; //  1.5362 %
	uint private place6P    	=   6145; //  0.6145 %
	uint private place7P    	=   2458; //  0.2458 %
	uint private place8P    	=    983; //  0.0983 %
	uint private place9P    	=    393; //  0.0393 %
	uint private place10P       =    157; //  0.0157 %
	
	uint private constant prepareBlockDelay = 5;
	
	enum drawStatus_ { Wait, Prepared ,Done }
	
	struct players_s {
		address addr;
		uint ticketCount;
	}
	struct game_s {
		players_s[] players;
		uint startDate;
		uint endDate;
		uint totalTickets;
		uint prepareDrawBlock;
		drawStatus_ drawStatus;
	}
	game_s private game;
	
	mapping (address => uint) public balances;
	
	string constant public Information = "http://a.ethereumlottery.net";
	
	function Details() constant returns(uint start, uint end, uint tickets, uint players) {
		start = game.startDate;
		end = game.endDate;
		tickets = game.totalTickets;
		players = game.players.length;
	}
	function Prizes() constant returns(bool estimated, uint place1, uint place2, uint place3, 
	uint place4, uint place5, uint place6, uint place7, uint place8, uint place9, uint place10) {
		uint pot;
		if (game.totalTickets < drawAtLeastTicketCount) {
			estimated = true;
			pot = drawAtLeastTicketCount*ticketPrice*(100-feeP)/100;
		} else {
			estimated = false;
			pot = game.totalTickets*ticketPrice*(100-feeP)/100;
		}
		place1 = pot*place1P/placeMultiple/100;
		place2 = pot*place2P/placeMultiple/100;
		place3 = pot*place3P/placeMultiple/100;
		place4 = pot*place4P/placeMultiple/100;
		place5 = pot*place5P/placeMultiple/100;
		place6 = pot*place6P/placeMultiple/100;
		place7 = pot*place7P/placeMultiple/100;
		place8 = pot*place8P/placeMultiple/100;
		place9 = pot*place9P/placeMultiple/100;
		place10 = pot*place10P/placeMultiple/100;
	}
	function aEthereumlotteryNet() {
		owner = msg.sender;
		createNewDraw();
	}
	function () {
		BuyTickets();
	}
	function BuyTickets() OnlyInTime OnlyWhileWait onValidContract {
		if (msg.value < ticketPrice) { throw; }
		uint ticketsCount = msg.value / ticketPrice;
		if (game.totalTickets+ticketsCount >= 255**4) { throw; }
		if (msg.value > (ticketsCount * ticketPrice)) { if (msg.sender.send(msg.value - (ticketsCount * ticketPrice)) == false) { throw; } }
		game.totalTickets += ticketsCount;
		uint a;
		uint playersid = game.players.length;
		for ( a = 0 ; a < playersid ; a++ ) {
			if (game.players[a].addr == msg.sender) {
				game.players[a].ticketCount += ticketsCount;
				return;
			}
		}
		game.players.length += 1;
		game.players[playersid].addr = msg.sender;
		game.players[playersid].ticketCount = ticketsCount;
	}
	function PrepareDraw() external ReadyForPrepare onValidContract {
	    reFund();
		if (game.players.length < drawAtLeastPlayerCount && game.totalTickets < drawAtLeastTicketCount) {
			game.endDate = calcNextDrawTime();
		} else {
			game.prepareDrawBlock = block.number + prepareBlockDelay;
			game.drawStatus = drawStatus_.Prepared;
		}
	}
	event announceWinner(address addr,uint prize);
	function Draw() external OnlyWhilePrepared ReadyForDraw onValidContract {
	    reFund();
		bytes32 WinHash = makeHash();
		uint a;
		uint b;
		uint c;
		uint d;
		uint e;
		uint num;
		address[10] memory winners;
		bool next;
		for ( a = 0 ; a < 10 ; a++ ) {
			while (true) {
				next = true;
				if (b == 8) {
					WinHash = sha3(WinHash);
					b = 0;
				}
				num = getNum(WinHash,b) % game.totalTickets;
				d = 0;
				for ( c = 0 ; c < game.players.length ; c++ ) {
					d += game.players[c].ticketCount;
					if (d >= num) {
						for ( e = 0 ; e < 10 ; e++ ){
							if (game.players[c].addr == winners[e]) {
								next = false;
								break;
							}
						}
						if (next == true) {
							winners[a] = game.players[c].addr;
							break;
						}
					}
				}
				b++;
				if (next == true) { break; }
			}
		}
		uint fee = game.totalTickets * ticketPrice * feeP / 100;
		uint pot = game.totalTickets * ticketPrice - fee;
		collectedFee += fee;
		balances[winners[0]] += pot * place1P / placeMultiple / 100;
		balances[winners[1]] += pot * place2P / placeMultiple / 100;
		balances[winners[2]] += pot * place3P / placeMultiple / 100;
		balances[winners[3]] += pot * place4P / placeMultiple / 100;
		balances[winners[4]] += pot * place5P / placeMultiple / 100;
		balances[winners[5]] += pot * place6P / placeMultiple / 100;
		balances[winners[6]] += pot * place7P / placeMultiple / 100;
		balances[winners[7]] += pot * place8P / placeMultiple / 100;
		balances[winners[8]] += pot * place9P / placeMultiple / 100;
		balances[winners[9]] += pot * place10P / placeMultiple / 100;
		announceWinner(winners[0],balances[winners[0]]);
		announceWinner(winners[1],balances[winners[1]]);
		announceWinner(winners[2],balances[winners[2]]);
		announceWinner(winners[3],balances[winners[3]]);
		announceWinner(winners[4],balances[winners[4]]);
		announceWinner(winners[5],balances[winners[5]]);
		announceWinner(winners[6],balances[winners[6]]);
		announceWinner(winners[7],balances[winners[7]]);
		announceWinner(winners[8],balances[winners[8]]);
		announceWinner(winners[9],balances[winners[9]]);
		if (contractEnabled == true) {
			createNewDraw();
		} else {
			game.drawStatus = drawStatus_.Done;
		}
	}
	function GetPrize() external {
	    reFund();
	    if (contractEnabled) { 
            if (balances[msg.sender] == 0) { throw; }
        	if (msg.sender.send(balances[msg.sender]) == false) { throw; }
        	balances[msg.sender] = 0;
	    } else {
            for ( uint a = 0 ; a < game.players.length ; a++ ) {
    			if (game.players[a].addr == msg.sender) {
    			    if (game.players[a].ticketCount > 0) {
    			        if ( ! msg.sender.send(game.players[a].ticketCount * ticketPrice)) { throw; }
    			        game.totalTickets -= game.players[a].ticketCount;
    			        delete game.players[a];
    			    } else {
    			        throw;
    			    }
    			}
    		}
	    }
	}
	function OwnerGetFee() external OnlyOwner {
	    reFund();
		if (owner.send(collectedFee) == false) { throw; }
		collectedFee = 0;
	}
	function OwnerCloseContract() external OnlyOwner {
	    reFund();
	    if (!contractEnabled) { throw; }
		contractEnabled = false;
	}
	function createNewDraw() private {
		game.startDate = now;
		game.endDate = calcNextDrawTime();
		game.players.length = 0;
		game.totalTickets = 0;
		game.prepareDrawBlock = 0;
		game.drawStatus = drawStatus_.Wait;
	}
	function calcNextDrawTime() private returns (uint ret) {
		ret = 1461499200; // 2016.04.24 12:00:00
		while (ret < now) {
			ret += drawDelay;
		}
	}
	function makeHash() private returns (bytes32 hash) {
		for ( uint a = 0 ; a <= prepareBlockDelay ; a++ ) {
			hash = sha3(hash, block.blockhash(game.prepareDrawBlock - prepareBlockDelay + a));
		}
		hash = sha3(hash, game.players.length, game.totalTickets);
	}
	function reFund() private { if (msg.value > 0) { if (msg.sender.send(msg.value) == false) { throw; } } }
	function getNum(bytes32 a, uint i) private returns (uint) { return uint32(bytes4(bytes32(uint(a) * 2 ** (8 * (i*4))))); }
	modifier onValidContract() { if (!contractEnabled) { throw; } _ }
	modifier OnlyInTime() { if (game.endDate < now) { throw; } _ }
	modifier OnlyWhileWait() { if (game.drawStatus != drawStatus_.Wait) { throw; } _ }
	modifier OnlyWhilePrepared() { if (game.drawStatus != drawStatus_.Prepared) { throw; } _ }
	modifier ReadyForPrepare() { if (game.endDate > now || game.drawStatus != drawStatus_.Wait) { throw; } _ }
	modifier ReadyForDraw() { if (game.prepareDrawBlock > block.number) { throw; } _ }
	modifier OnlyOwner() { if (owner != msg.sender) { throw; } _ }
}