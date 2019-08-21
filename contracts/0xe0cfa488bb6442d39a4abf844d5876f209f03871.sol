contract dEthereumlotteryNet {
	/*
		dEthereumlotteryNet
		Coded by: iFA
		https://d.ethereumlottery.net
		ver: 2.0.0
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
    uint public ContractDisabledBlock;
	uint public Jackpot;
	uint public RollCount;
	uint public JackpotHits;
	
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
	
	investors_s[] investors;
	
	string constant public Information = "https://d.ethereumlottery.net";
	
	/*
		Deploy
	*/
	function dEthereumlotteryNet() {
		owner = msg.sender;
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
	function Investors(uint id) constant returns(address Owner, uint Investment, uint Balance, bool Live) {
		if (id < investors.length) {
			Owner = investors[id].owner;
			Investment = investors[id].value;
			Balance = investors[id].balance;
			Live = investors[id].live;
		} else {
			Owner = 0;
			Investment = 0;
			Balance = 0;
			Live = false;
		}
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
		for ( uint a=0 ; a < investors.length ; a++ ) {
			if ( ! investors[a].valid) {
				newInvest(a,msg.sender,value_);
				return;
			}
		}
		investors.length++;
		newInvest(investors.length-1,msg.sender,value_);
	}
	function GetMyInvestFee() external {
		reFund();
		uint balance_;
		for ( uint a=0 ; a < investors.length ; a++ ) {
			if (investors[a].owner == msg.sender && ! investors[a].valid) {
				balance_ = investors[a].balance;
				investors[a].valid = false;
			}
		}
		if (balance_ > 0) { if ( ! msg.sender.send(balance_)) { throw; } }
	}
	function CancelMyInvest() external {
		reFund();
		uint balance_;
		for ( uint a=0 ; a < investors.length ; a++ ) {
			if ((investors[a].owner == msg.sender && investors[a].valid)) {
			    if (investors[a].timestamp < now || ! ContractEnabled) {
    				if (investors[a].live) {
    					balance_ = investors[a].value + investors[a].balance;
    					jackpot_ -= investors[a].value;
    					delete investors[a];
    				} else {
    					balance_ = investors[a].balance;
    					delete investors[a];
    				}
			    }
			}
		}
		setJackpot();
		if (balance_ > 0) { if ( ! msg.sender.send(balance_)) { throw; } }
	}
	/* For Players */
	function DoRoll() external {
		reFund();
		uint value_;
		bool found;
		for ( uint a=0 ; a < players[msg.sender].length ; a++ ) {
			if (players[msg.sender][a].valid) {
			    if (players[msg.sender][a].blockNumber+rollLossBlockDelay <= block.number) {
			        uint feeValue_ = players[msg.sender][a].value/2;
			        feeValue += feeValue_;
			        investorAddFee(players[msg.sender][a].value - feeValue_);
					playersPot -= players[msg.sender][a].value;
					delete players[msg.sender][a];
					found = true;
					continue;
			    }
				if ( ! ContractEnabled || jackpot_ == 0 || players[msg.sender][a].game != JackpotHits) {
					value_ += players[msg.sender][a].value;
					playersPot -= players[msg.sender][a].value;
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
		if (value_ > 0) { if (msg.sender.send(value_)) { throw; } }
		if ( ! found) { throw; }
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
	function OwnerCloseContract() external OnlyOwner {
		reFund();
		if ( ! ContractEnabled) {
		    if (ContractDisabledBlock < block.number) {
		        uint balance_ = this.balance;
		        for ( uint a=0 ; a < investors.length ; a++ ) {
		            balance_ -= investors[a].balance;
		        }
		        if (balance_ > 0) {
                    if ( ! msg.sender.send(balance_)) { throw; }
		        }
		    }
		} else {
    		ContractEnabled = false;
    		ContractDisabledBlock = block.number+rollLossBlockDelay;
    		feeValue += extraJackpot_;
    		extraJackpot_ = 0;
		}
	}
	function OwnerGetFee() external OnlyOwner {
		reFund();
		if (feeValue == 0) { throw; }
		if ( ! owner.send(feeValue)) { throw; }
		feeValue = 0;
	}
	
	/*
		Private functions
	*/
	function newInvest(uint investorsID, address investor, uint value) private {
		investors[investorsID].owner = investor;
		investors[investorsID].value = value;
		investors[investorsID].balance = 0;
		investors[investorsID].valid = true;
		investors[investorsID].live = true;
		investors[investorsID].timestamp = now + investMinDuration;
		jackpot_ += value;
		setJackpot();
	}
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
			for ( a=0 ; a < investors.length ; a++ ) {
				investors[a].live = false;
			}
			JackpotHits++;
			extraJackpot_ = 0;
			jackpot_ = 0;
			Jackpot = 0;
		}
		RollEvent(msg.sender, _rate, bigNumber % _rate, bigNumber ,win);
		delete players[msg.sender][id];
	}
	function investorAddFee(uint value) private {
		bool done;
		for ( uint a=0 ; a < investors.length ; a++ ) {
			if (investors[a].live) {
				investors[a].balance += value * investors[a].value / jackpot_;
				done = true;
			}
		}
		if ( ! done) {
			feeValue += value;
		}
	}
	function reFund() private { if (msg.value > 0) { if ( ! msg.sender.send(msg.value)) { throw; } } }
	function prepareRoll(uint rollID, uint bet, uint seed) private {
		players[msg.sender][rollID].blockNumber = block.number + prepareBlockDelay;
		players[msg.sender][rollID].extraHash = sha3(RollCount, now, seed);
		players[msg.sender][rollID].valid = true;
		players[msg.sender][rollID].value = bet;
		players[msg.sender][rollID].game = JackpotHits;
		RollCount++;
		playersPot += bet;
		PrepareRollEvent(msg.sender, players[msg.sender][rollID].blockNumber, bet);
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
	
	/*
		Events
	*/	
	event RollEvent(address Player, uint Rate, uint Result, uint Number, uint Win);
	event PrepareRollEvent(address Player, uint Block, uint Bet);
	
	/*
		Modifiders
	*/
	modifier OnlyOwner() { if (owner != msg.sender) { throw; } _ }
	modifier OnlyEnabled() { if ( ! ContractEnabled) { throw; } _ }
}