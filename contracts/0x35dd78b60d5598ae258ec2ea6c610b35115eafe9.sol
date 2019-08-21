pragma solidity ^0.4.24;

/**
 * The PlutoCommyLotto contract is a communist bidding/lottery system. It shares 80% of the prize with everyone who didn't win. The winner gets 20%.
 */
contract PlutoCommyLotto {

	address public maintenanceFunds; //holds capital for reinvestment in case there's no activity for too long.

	uint public currentCicle = 0;
	uint public numBlocksForceEnd = 5760;//5760;
	uint public jackpotPossibilities = 5000000;//5000000;
	uint public winnerPct = 20; //20%
	uint public commyPct = 80; //80%
	uint public lastJackpotResult; //for easy auditing.

	uint private costIncrementNormal = 5; //0.5%
	uint private idealReserve = 60 finney;
	uint private minTicketCost = 1 finney / 10;
	uint private baseTicketProportion = 30;
	uint private maintenanceTickets = 50;
	
	struct Cicle {
		mapping (address => uint) ticketsByHash;
		address lastPlayer;
		uint number; 
		uint initialBlock;
		uint numTickets;
		uint currentTicketCost;
		uint lastJackpotChance;
		uint winnerPot; 
		uint commyPot; 
		uint commyReward;
		uint lastBetBlock;
		bool isActive;
	}

	mapping (uint => Cicle) public cicles;

	//////////###########//////////
	modifier onlyInitOnce() { 
		require(currentCicle == 0); 
		_; 
	}
	modifier onlyLastPlayer(uint cicleNumber) { 
		require(msg.sender == cicles[cicleNumber].lastPlayer); 
		_; 
	}
	modifier onlyIfNoActivity(uint cicleNumber) { 
		require(block.number - cicles[cicleNumber].lastBetBlock > numBlocksForceEnd);
		_; 
	}
	modifier onlyActiveCicle(uint cicleNumber) { 
		require(cicles[cicleNumber].isActive == true);
		_; 
	}
	modifier onlyInactiveCicle(uint cicleNumber) { 
		require(cicles[cicleNumber].isActive == false);
		_; 
	}
	modifier onlyWithTickets(uint cicleNumber) { 
		require(cicles[cicleNumber].ticketsByHash[msg.sender] > 0);
		_; 
	}
	modifier onlyValidCicle(uint cicleNumber) { 
		require(cicleNumber <= currentCicle);
		_; 
	}
	//////////###########//////////

	function init() public payable onlyInitOnce() {
		maintenanceFunds = msg.sender;
		createNewCicle();
		
		idealReserve = msg.value;

		uint winnerVal = msg.value * winnerPct / 100;
		cicles[currentCicle].winnerPot += winnerVal;
		cicles[currentCicle].commyPot += msg.value - winnerVal;
		cicles[currentCicle].currentTicketCost = ((cicles[currentCicle].winnerPot + cicles[currentCicle].commyPot) / baseTicketProportion);
		
		setCommyReward(currentCicle);
	}

	event NewCicle(uint indexed cicleNumber, uint firstBlock);
	function createNewCicle() private {
		currentCicle += 1;
		cicles[currentCicle] = Cicle({ number:currentCicle,
									initialBlock:block.number,
									numTickets:maintenanceTickets,
									lastPlayer:maintenanceFunds,
									lastJackpotChance:0,
									lastBetBlock:block.number,
									winnerPot:0,
									commyPot:0,
									commyReward:0,
									currentTicketCost:0,
									isActive:false });

		cicles[currentCicle].ticketsByHash[maintenanceFunds] = maintenanceTickets;

		if(currentCicle != 1) {
			cicles[currentCicle-1].ticketsByHash[maintenanceFunds] = 0;
			if (cicles[currentCicle-1].commyReward * maintenanceTickets > idealReserve) {
				cicles[currentCicle].winnerPot = idealReserve * winnerPct / 100;
				cicles[currentCicle].commyPot = idealReserve * commyPct / 100;
				maintenanceFunds.transfer(cicles[currentCicle-1].commyReward * maintenanceTickets - idealReserve);
			} else {
				if(cicles[currentCicle-1].numTickets == maintenanceTickets) {
					cicles[currentCicle].winnerPot = cicles[currentCicle-1].winnerPot;
					cicles[currentCicle].commyPot = cicles[currentCicle-1].commyPot;
				} else {
					cicles[currentCicle].winnerPot = (cicles[currentCicle-1].commyReward * maintenanceTickets) * winnerPct / 100;
					cicles[currentCicle].commyPot = (cicles[currentCicle-1].commyReward * maintenanceTickets) * commyPct / 100;
				}
			}

			setCommyReward(currentCicle);
			cicles[currentCicle].currentTicketCost = (cicles[currentCicle].winnerPot + cicles[currentCicle].commyPot) / baseTicketProportion;
			if(cicles[currentCicle].currentTicketCost < minTicketCost) {
				cicles[currentCicle].currentTicketCost = minTicketCost;
			}
		}
				
		cicles[currentCicle].isActive = true;
		emit NewCicle(currentCicle, block.number);
	}

	function setCommyReward(uint cicleNumber) private {
		cicles[cicleNumber].commyReward = cicles[cicleNumber].commyPot / (cicles[cicleNumber].numTickets-1);
	}

	event NewBet(uint indexed cicleNumber, address indexed player, uint instantPrize, uint jackpotChance, uint jackpotResult, bool indexed hasHitJackpot);
	function bet() public payable {
		require (msg.value >= cicles[currentCicle].currentTicketCost);

		cicles[currentCicle].lastBetBlock = block.number;
		cicles[currentCicle].ticketsByHash[msg.sender] += 1;

		uint commyVal = cicles[currentCicle].currentTicketCost * commyPct / 100;
		cicles[currentCicle].winnerPot += msg.value - commyVal;
		cicles[currentCicle].commyPot += commyVal;
		cicles[currentCicle].numTickets += 1;
		cicles[currentCicle].currentTicketCost += cicles[currentCicle].currentTicketCost * costIncrementNormal / 1000;
		cicles[currentCicle].lastJackpotChance = block.number - cicles[currentCicle].initialBlock;
		cicles[currentCicle].lastPlayer = msg.sender;
		setCommyReward(currentCicle);

		if(getJackpotResult(currentCicle) == true)
		{
			emit NewBet(currentCicle, cicles[currentCicle].lastPlayer, cicles[currentCicle].winnerPot, cicles[currentCicle].lastJackpotChance, lastJackpotResult, true);
			endCicle(currentCicle, true);
		} else {
			emit NewBet(currentCicle, msg.sender, 0, cicles[currentCicle].lastJackpotChance, lastJackpotResult, false);
		}
	}

	function getJackpotResult(uint cicleNumber) private returns (bool isWinner) {
		lastJackpotResult = uint(blockhash(block.number-1)) % jackpotPossibilities;

		if(lastJackpotResult < cicles[cicleNumber].lastJackpotChance) {
			isWinner = true;
		}
	}

	event CicleEnded(uint indexed cicleNumber, address winner, uint winnerPrize, uint commyReward, uint lastBlock, bool jackpotVictory);
	function endCicle(uint cicleNumber, bool jackpotVictory) private {
		cicles[cicleNumber].isActive = false;
		emit CicleEnded(cicleNumber, cicles[cicleNumber].lastPlayer, cicles[cicleNumber].winnerPot, cicles[cicleNumber].commyReward, block.number, jackpotVictory);
		createNewCicle();
	}

	function finishByInactivity(uint cicleNumber) public onlyIfNoActivity(cicleNumber) onlyActiveCicle(cicleNumber){
		endCicle(cicleNumber, false);
	}

	function withdraw(uint cicleNumber) public onlyValidCicle(cicleNumber) onlyInactiveCicle(cicleNumber) onlyWithTickets(cicleNumber) {
		uint numTickets = cicles[cicleNumber].ticketsByHash[msg.sender];			
		cicles[cicleNumber].ticketsByHash[msg.sender] = 0;

		if(msg.sender != cicles[cicleNumber].lastPlayer){
			msg.sender.transfer(cicles[cicleNumber].commyReward * numTickets);
		} else {
			if(numTickets == 1){
				msg.sender.transfer(cicles[cicleNumber].winnerPot);
			} else {
				msg.sender.transfer(cicles[cicleNumber].winnerPot + (cicles[cicleNumber].commyReward * (numTickets - 1)));
			}
		}
	}

	function claimPrizeByInactivity(uint cicleNumber) public onlyValidCicle(cicleNumber) onlyActiveCicle(cicleNumber) onlyIfNoActivity(cicleNumber) onlyLastPlayer(cicleNumber) {
		endCicle(cicleNumber, false);
		withdraw(cicleNumber);
	}

	//////
	//Getters for dapp:
	function getCicle(uint cicleNumber) public view returns (address lastPlayer,
														uint number,
														uint initialBlock,
														uint numTickets,
														uint currentTicketCost,
														uint lastJackpotChance,
														uint winnerPot,
														uint commyPot,
														uint commyReward,
														uint lastBetBlock,
														bool isActive){
		Cicle memory myCurrentCicle = cicles[cicleNumber];

		return (myCurrentCicle.lastPlayer,
				myCurrentCicle.number,
				myCurrentCicle.initialBlock,
				myCurrentCicle.numTickets,
				myCurrentCicle.currentTicketCost,
				myCurrentCicle.lastJackpotChance,
				myCurrentCicle.winnerPot,
				myCurrentCicle.commyPot,
				myCurrentCicle.commyReward,
				myCurrentCicle.lastBetBlock,
				myCurrentCicle.isActive);
	}

	function getMyTickets(address myAddress, uint cicleNumber) public view returns (uint myTickets) {
		return cicles[cicleNumber].ticketsByHash[myAddress];
	}
}