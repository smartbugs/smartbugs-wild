contract dEthereumlotteryNet {
	/*
		dEthereumlotteryNet
		Coded by: iFA
		http://d.ethereumlottery.net
		ver: 2.1.0
	*/
	
	/*
		Vars
	*/
	address private owner;
	uint private constant fee = 5;
	uint private constant investorFee = 50;
	uint private constant prepareBlockDelay = 4;
	uint private constant rollLossBlockDelay = 30;
	uint private constant investUnit = 1 ether;
	uint private constant extraRate = 130;
	uint private constant minimumRollPrice = 10 finney;
	uint private constant investMinDuration = 1 days;
	uint private constant BestRollRate = 26;
	
    bool public ContractEnabled = true;
	uint public Jackpot;
	uint public RollCount;
	uint public JackpotHits;
	
	uint private ContractDisabledBlock;
	uint private jackpot_;
	uint private extraJackpot_;
	uint private feeValue;
	uint private playersPot;
	
	struct rolls_s {
		uint blockNumber;
		bytes32 extraHash;
		bool valid;
		uint value;
		uint game;
		uint id;
	}
	
	mapping(address => rolls_s[]) private players;
	
	struct investors_s {
		address owner;
		uint value;
		uint balance;
		bool live;
		bool valid;
		uint timestamp;
	}
	
	investors_s[] private investors;
	
	string constant public Information = "http://d.ethereumlottery.net";
	
	/*
		Deploy
	*/
	function dEthereumlotteryNet() {
		owner = msg.sender;
		investors.length = 1;
	}
	
	/* 
		Constans functions
	*/
	function ChanceOfWinning(uint Value) constant returns(uint Rate, uint Bet) {
	    if (jackpot_ == 0) {
	        Rate = 0;
	        Bet = 0;
	        return;
	    }
		if (Value < minimumRollPrice) {
			Value = minimumRollPrice;
		}
		Rate = getRate(Value);
		Bet = getRealBet(Rate);
		if (Value < Bet) {
		    Rate++;
		    Bet = getRealBet(Rate);
		}
		if (Rate < BestRollRate) { 
		    Rate = BestRollRate;
		    Bet = getRealBet(Rate);
        }
	}
	function BetPriceLimit() constant returns(uint min,uint max) {
		min = minimumRollPrice;
		max = getRealBet(BestRollRate);
	}
	function Investors(address Address) constant returns(uint Investment, uint Balance, bool Live) {
		uint InvestorID = getInvestorByAddress(Address);
		if (InvestorID == 0 || ! investors[InvestorID].valid) {
			Investment = 0;
			Balance = 0;
			Live = false;
		}
		Investment = investors[InvestorID].value;
		Balance = investors[InvestorID].balance;
		Live = investors[InvestorID].live;
	}
	
	/*
		External functions
	*/
	/* Fallback */
	function () {
		PrepareRoll(0);
	}
	/* For Investors */
	function Invest() OnlyEnabled external {
		uint value_ = msg.value;
		if (value_ < investUnit) { throw; }
		if (value_ % investUnit > 0) { 
			if ( ! msg.sender.send(value_ % investUnit)) { throw; } 
			value_ = value_ - (value_ % investUnit);
		}
		uint InvestorID = getInvestorByAddress(msg.sender);
		if (InvestorID == 0) {
			InvestorID = investors.length;
			investors.length++;
		}
		if (investors[InvestorID].valid && investors[InvestorID].live) {
			investors[InvestorID].value += value_;
		} else {
			investors[InvestorID].value = value_;
		}
		investors[InvestorID].timestamp = now + investMinDuration;
		investors[InvestorID].valid = true;
		investors[InvestorID].live = true;
		investors[InvestorID].owner = msg.sender;
		jackpot_ += value_;
		setJackpot();
	}
	function GetMyInvestmentBalance() external noEther {
		uint InvestorID = getInvestorByAddress(msg.sender);
		if (InvestorID == 0) { throw; }
		if ( ! investors[InvestorID].valid) { throw; }
		if (investors[InvestorID].balance == 0) { throw; }
		if ( ! msg.sender.send( investors[InvestorID].balance )) { throw; }
		investors[InvestorID].balance = 0;
	}
	function CancelMyInvestment() external noEther {
		uint InvestorID = getInvestorByAddress(msg.sender);
		if (InvestorID == 0) { throw; }
		if ( ! investors[InvestorID].valid) { throw; }
		if (investors[InvestorID].timestamp > now && ContractEnabled) { throw; }
		uint balance_;
		if (investors[InvestorID].live) {
			jackpot_ -= investors[InvestorID].value;
			balance_ = investors[InvestorID].value;
			setJackpot();
		}
		if (investors[InvestorID].balance > 0) {
			balance_ += investors[InvestorID].balance;
		}
		if ( ! msg.sender.send( balance_ )) { throw; }
		delete investors[InvestorID];
	}
	/* For Players */
	function DoRoll() external noEther {
		uint value_;
		bool found;
		for ( uint a=0 ; a < players[msg.sender].length ; a++ ) {
			if (players[msg.sender][a].valid) {
			    if (players[msg.sender][a].blockNumber+rollLossBlockDelay <= block.number) {
			        uint feeValue_ = players[msg.sender][a].value/2;
			        feeValue += feeValue_;
			        investorAddFee(players[msg.sender][a].value - feeValue_);
					playersPot -= players[msg.sender][a].value;
					DoRollEvent(msg.sender, players[msg.sender][a].value, players[msg.sender][a].id, false, true, false, false, 0, 0, 0);
					delete players[msg.sender][a];
					found = true;
					continue;
			    }
				if ( ! ContractEnabled || jackpot_ == 0 || players[msg.sender][a].game != JackpotHits) {
					value_ += players[msg.sender][a].value;
					playersPot -= players[msg.sender][a].value;
					DoRollEvent(msg.sender, players[msg.sender][a].value, players[msg.sender][a].id, true, false, false, false, 0, 0, 0);
					delete players[msg.sender][a];
					found = true;
					continue;
				}
				if (players[msg.sender][a].blockNumber < block.number) {
					value_ += makeRoll(a);
					playersPot -= players[msg.sender][a].value;
					delete players[msg.sender][a];
					found = true;
					continue;
				}
			}
		}
		if ( ! found) { throw; }
		if (value_ > 0) { if ( ! msg.sender.send(value_)) { throw; } }
	}
	function PrepareRoll(uint seed) OnlyEnabled {
		if (msg.value < minimumRollPrice) { throw; }
		if (jackpot_ == 0) { throw; }
		uint _rate = getRate(msg.value);
		uint _realBet = getRealBet(_rate);
		if (msg.value < _realBet) {
		    _rate++;
		    _realBet = getRealBet(_rate);
		}
		if (_rate < BestRollRate) { 
		    _rate = BestRollRate;
		    _realBet = getRealBet(_rate);
        }
		if (msg.value-_realBet > 0) {
			if ( ! msg.sender.send( msg.value-_realBet )) { throw; }
		}
		for (uint a = 0 ; a < players[msg.sender].length ; a++) {
			if ( ! players[msg.sender][a].valid) {
				prepareRoll( a, _realBet, seed );
				return;
			}
		}
		players[msg.sender].length++;
		prepareRoll( players[msg.sender].length-1, _realBet, seed );
	}
	/* For Owner */
	function OwnerCloseContract() external OnlyOwner noEther {
		if ( ! ContractEnabled) {
		    if (ContractDisabledBlock < block.number) {
				if (playersPot == 0) { throw; }
				if ( ! msg.sender.send( playersPot )) { throw; }
				playersPot = 0;
		    }
		} else {
    		ContractEnabled = false;
    		ContractDisabledBlock = block.number+rollLossBlockDelay;
			ContractDisabled(ContractDisabledBlock);
    		feeValue += extraJackpot_;
    		extraJackpot_ = 0;
		}
	}
	function OwnerGetFee() external OnlyOwner noEther {
		if (feeValue == 0) { throw; }
		if ( ! owner.send(feeValue)) { throw; }
		feeValue = 0;
	}
	
	/*
		Private functions
	*/
	function setJackpot() private {
		Jackpot = extraJackpot_ + jackpot_;
	}
	function makeRoll(uint id) private returns(uint win) {
		uint feeValue_ = players[msg.sender][id].value * fee / 100 ;
		feeValue += feeValue_;
		uint investorFee_ = players[msg.sender][id].value * investorFee / 100;
		investorAddFee(investorFee_);
		extraJackpot_ += players[msg.sender][id].value - feeValue_ - investorFee_;
		setJackpot();
		bytes32 hash_ = players[msg.sender][id].extraHash;
		for ( uint a = 1 ; a <= prepareBlockDelay ; a++ ) {
			hash_ = sha3(hash_, block.blockhash(players[msg.sender][id].blockNumber - prepareBlockDelay+a));
		}
		uint _rate = getRate(players[msg.sender][id].value);
		uint bigNumber = uint64(hash_);
		if (bigNumber % _rate == 0 ) {
			win = Jackpot;
			for ( a=1 ; a < investors.length ; a++ ) {
				investors[a].live = false;
			}
			JackpotHits++;
			extraJackpot_ = 0;
			jackpot_ = 0;
			Jackpot = 0;
			DoRollEvent(msg.sender, win, players[msg.sender][id].id, false, false, false, true, bigNumber, _rate, bigNumber % _rate);
		} else {
			DoRollEvent(msg.sender, players[msg.sender][id].value, players[msg.sender][id].id, false, false, true, false, bigNumber, _rate, bigNumber % _rate);
		}
	}
	function investorAddFee(uint value) private {
		bool done;
		for ( uint a=1 ; a < investors.length ; a++ ) {
			if (investors[a].live && investors[a].valid) {
				investors[a].balance += value * investors[a].value / jackpot_;
				done = true;
			}
		}
		if ( ! done) {
			feeValue += value;
		}
	}
	function prepareRoll(uint rollID, uint bet, uint seed) private {
		RollCount++;
		players[msg.sender][rollID].blockNumber = block.number + prepareBlockDelay;
		players[msg.sender][rollID].extraHash = sha3(RollCount, now, seed);
		players[msg.sender][rollID].valid = true;
		players[msg.sender][rollID].value = bet;
		players[msg.sender][rollID].game = JackpotHits;
		players[msg.sender][rollID].id = RollCount;
		playersPot += bet;
		PrepareRollEvent(msg.sender, players[msg.sender][rollID].blockNumber, players[msg.sender][rollID].value, players[msg.sender][rollID].id);
	}
	
	/*
		Internal functions
	*/	
	function getRate(uint value) internal returns(uint){
		return jackpot_ * 1000000 / value * 100 / investorFee * extraRate / 100 / 1000000;
	}
	function getRealBet(uint rate) internal returns (uint) {
		return jackpot_ * 1000000 / ( rate * 1000000 * investorFee / extraRate);
	}
	function getInvestorByAddress(address Address) internal returns (uint id) {
		for ( id=1 ; id < investors.length ; id++ ) {
			if (investors[id].owner == Address) {
				return;
			}
		}
		return 0;
	}
	
	/*
		Events
	*/	
	event DoRollEvent(address Player, uint Value, uint RollID, bool Refund, bool LostBet, bool LossRoll, bool WinRoll, uint BigNumber, uint Rate, uint RollResult);
	event PrepareRollEvent(address Player, uint Block, uint Bet, uint RollID);
	event ContractDisabled(uint LossAllBetBlockNumber);
	
	/*
		Modifiers
	*/
	modifier noEther() { if (msg.value > 0) { throw; } _ }
	modifier OnlyOwner() { if (owner != msg.sender) { throw; } _ }
	modifier OnlyEnabled() { if ( ! ContractEnabled) { throw; } _ }
}