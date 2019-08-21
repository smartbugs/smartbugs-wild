contract dEthereumlotteryNet {
	/*
		dEthereumlotteryNet
		Coded by: iFA
		https://d.ethereumlottery.net
		ver: 1.0.0
	*/
	address private owner;
	uint private constant fee = 5;
	uint private constant investorFee = 50;
	uint private constant prepareBlockDelay = 4;
	uint private constant rollLossBlockDelay = 30;
	uint private constant investUnit = 1 ether;
	uint private constant extraDifficulty = 130;
	uint private constant minimumRollPrice = 10 finney;
	uint private constant minimumRollDiv = 10;
	uint private constant difficultyMultipler = 1000000;
	uint private constant investMinDuration = 1 days;
	
    bool public ContractEnabled = true;
    uint public ContractDisabledBlock;
	uint public Jackpot;
	uint public RollCount;
	uint public JackpotHits;
	
	uint private jackpot_;
	uint private extraJackpot_;
	uint private feeValue;
	
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
	
	function ChanceOfWinning(uint Bet) constant returns(uint Rate) {
		Rate = getDifficulty(Bet);
		if (Bet < minimumRollPrice) { Rate = 0; }
		if (jackpot_/minimumRollDiv < Bet) { Rate = 0; }
	}
	function BetPriceLimit() constant returns(uint min,uint max) {
		min = minimumRollPrice;
		max = jackpot_/minimumRollDiv;
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
	function dEthereumlotteryNet() {
		owner = msg.sender;
	}
	function Invest() OnlyEnabled external {
		uint value_ = msg.value;
		if (value_ < investUnit) { throw; }
		if (value_ % investUnit > 0) { 
			if (msg.sender.send(value_ % investUnit) == false) { throw; } 
			value_ = value_ - (value_ % investUnit);
		}
		for ( uint a=0 ; a < investors.length ; a++ ) {
			if (investors[a].valid == false) {
				newInvest(a,msg.sender,value_);
				return;
			}
		}
		investors.length++;
		newInvest(investors.length-1,msg.sender,value_);
	}
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
	function GetMyInvestFee() external {
		reFund();
		uint balance_;
		for ( uint a=0 ; a < investors.length ; a++ ) {
			if (investors[a].owner == msg.sender && investors[a].valid == true) {
				balance_ = investors[a].balance;
				investors[a].valid = false;
			}
		}
		if (balance_ > 0) { if (msg.sender.send(balance_) == false) { throw; } }
	}
	function CancelMyInvest() external {
		reFund();
		uint balance_;
		for ( uint a=0 ; a < investors.length ; a++ ) {
			if (investors[a].owner == msg.sender && investors[a].valid == true && investors[a].timestamp < now) {
				if (investors[a].live == true) {
					balance_ = investors[a].value + investors[a].balance;
					jackpot_ -= investors[a].value;
					delete investors[a];
				} else {
					balance_ = investors[a].balance;
					delete investors[a];
				}
			}
		}
		setJackpot();
		if (balance_ > 0) { if (msg.sender.send(balance_) == false) { throw; } }
	}
	function setJackpot() private {
		Jackpot = extraJackpot_ + jackpot_;
	}
	function DoRoll() external {
		reFund();
		uint value_;
		bool found;
		for ( uint a=0 ; a < players[msg.sender].length ; a++ ) {
			if (players[msg.sender][a].valid == true) {
			    if (players[msg.sender][a].blockNumber+rollLossBlockDelay <= block.number) {
			        uint feeValue_ = players[msg.sender][a].value/2;
			        feeValue += feeValue_;
			        investorAddFee(players[msg.sender][a].value - feeValue_);
					delete players[msg.sender][a];
					found = true;
					continue;
			    }
				if (ContractEnabled == false || jackpot_ == 0 || players[msg.sender][a].game != JackpotHits) {
					value_ += players[msg.sender][a].value;
					delete players[msg.sender][a];
					found = true;
					continue;
				}
				if (players[msg.sender][a].blockNumber < block.number) {
					value_ += makeRoll(a);
					delete players[msg.sender][a];
					found = true;
					continue;
				}
			}
		}
		if (value_ > 0) { if (msg.sender.send(value_) == false) { throw; } }
		if (found == false) { throw; }
	}
	event RollEvent(address Player,uint Difficulty, uint Result, uint Number, uint Win);
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
		uint difficulty_ = getDifficulty(players[msg.sender][id].value);
		uint bigNumber = uint64(hash_);
		if (bigNumber * difficultyMultipler % difficulty_ == 0) {
			win = Jackpot;
			for ( a=0 ; a < investors.length ; a++ ) {
				investors[a].live = false;
			}
			JackpotHits++;
			extraJackpot_ = 0;
			jackpot_ = 0;
			Jackpot = 0;
		}
		RollEvent(msg.sender, difficulty_, bigNumber * difficultyMultipler % difficulty_, bigNumber * difficultyMultipler,win);
		delete players[msg.sender][id];
	}
	function getDifficulty(uint value) private returns(uint){
		return jackpot_ * difficultyMultipler / value * 100 / investorFee * extraDifficulty / 100;
	}
	function investorAddFee(uint value) private {
		for ( uint a=0 ; a < investors.length ; a++ ) {
			if (investors[a].live == true) {
				investors[a].balance += value * investors[a].value / jackpot_;
			}
		}
	}
	event PrepareRollEvent(address Player, uint Block);
	function prepareRoll(uint rollID, uint seed) private {
		players[msg.sender][rollID].blockNumber = block.number + prepareBlockDelay;
		players[msg.sender][rollID].extraHash = sha3(RollCount, now, seed);
		players[msg.sender][rollID].valid = true;
		players[msg.sender][rollID].value = msg.value;
		players[msg.sender][rollID].game = JackpotHits;
		RollCount++;
		PrepareRollEvent(msg.sender, players[msg.sender][rollID].blockNumber);
	}
	function PrepareRoll(uint seed) OnlyEnabled {
		if (msg.value < minimumRollPrice) { throw; }
		if (jackpot_/minimumRollDiv < msg.value) { throw; }
		if (jackpot_ == 0) { throw; }
		for (uint a = 0 ; a < players[msg.sender].length ; a++) {
			if (players[msg.sender][a].valid == false) {
				prepareRoll(a,seed);
				return;
			}
		}
		players[msg.sender].length++;
		prepareRoll(players[msg.sender].length-1,seed);
	}
	function () {
		PrepareRoll(0);
	}
	function reFund() private { if (msg.value > 0) { if (msg.sender.send(msg.value) == false) { throw; } } }
	function OwnerCloseContract() external OnlyOwner {
		reFund();
		if (ContractEnabled == false) {
		    if (ContractDisabledBlock < block.number) {
		        uint balance_ = this.balance;
		        for ( uint a=0 ; a < investors.length ; a++ ) {
		            balance_ -= investors[a].balance;
		        }
		        if (balance_ > 0) {
                    if (msg.sender.send(balance_) == false) { throw; }
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
		if (owner.send(feeValue) == false) { throw; }
		feeValue = 0;
	}
	modifier OnlyOwner() { if (owner != msg.sender) { throw; } _ }
	modifier OnlyEnabled() { if (!ContractEnabled) { throw; } _	}
}