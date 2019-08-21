pragma solidity ^0.4.18;

library CSCLib {

	uint constant MILLION = 1000000;
	uint constant GASLIMIT = 65000;


	struct Split {
		address to;
		uint ppm;
	}

	struct CSCStorage {
		mapping(address => uint) lastUserClaim;
		uint[] deposits;
		bool isClaimable;

		address developer;
		uint dev_fee;
		uint refer_fee;
		Split[] splits;
		mapping(address => uint) userSplit;
	}

	event SplitTransfer(address to, uint amount, uint balance);

	/*
	self: a storage pointer

	members: an array of addresses

	ppms: an array of integers that should sum to 1 million.
		Represents how much ether a user should get

	refer: the address of a referral contract that referred this user.
		Referral contract should be a claimable contract

	*/
	function init(CSCStorage storage self,  address[] members, uint[] ppms, address refer) internal {
		uint shift_amt = self.dev_fee / members.length;
		uint remainder = self.dev_fee % members.length * members.length / 10;
		uint dev_total = self.dev_fee + remainder;
		self.deposits.push(0);
		if(refer != 0x0){
			addSplit(self, Split({to: self.developer, ppm: dev_total - self.refer_fee}));
			addSplit(self, Split({to: refer, ppm: self.refer_fee}));
		} else {
			addSplit(self, Split({to: self.developer, ppm: dev_total}));
		}

		uint sum = 0;
		for(uint index = 0; index < members.length; index++) {
			sum += ppms[index];
			addSplit(self, Split({to: members[index], ppm: ppms[index] - shift_amt}));
		}
		require(sum >= MILLION - 1 && sum < MILLION + 1 );
	}

	function addSplit(CSCStorage storage self, Split newSplit) internal {
		require(newSplit.ppm > 0);
		uint index = self.userSplit[newSplit.to];
		if(index > 0) {
			newSplit.ppm += self.splits[index].ppm;
			self.splits[index] = newSplit;
		} else {
			self.userSplit[newSplit.to] = self.splits.length;
			self.lastUserClaim[newSplit.to] = self.deposits.length;
			self.splits.push(newSplit);
		}
	}

	function payAll(CSCStorage storage self) internal {
		for(uint index = 0; index < self.splits.length; index++) {
			uint value = (msg.value) * self.splits[index].ppm / MILLION;
			if(value > 0 ) {
				require(self.splits[index].to.call.gas(GASLIMIT).value(value)());
				SplitTransfer(self.splits[index].to, value, this.balance);
			}
		}
	}

	function getSplit(CSCStorage storage self, uint index) internal view returns (Split) {
		return self.splits[index];
	}

	function getSplitCount(CSCStorage storage self) internal view returns (uint count) {
		return self.splits.length;
	}

	function claimFor(CSCStorage storage self, address user) internal {
		require(self.isClaimable);
		uint sum = getClaimableBalanceFor(self, user);
		uint splitIndex = self.userSplit[user];
		self.lastUserClaim[user] = self.deposits.length;
		if(sum > 0) {
			require(self.splits[splitIndex].to.call.gas(GASLIMIT).value(sum)());
			SplitTransfer(self.splits[splitIndex].to, sum, this.balance);
		}
	}

	function claim(CSCStorage storage self)  internal {
		return claimFor(self, msg.sender);
	}

	function getClaimableBalanceFor(CSCStorage storage self, address user) internal view returns (uint balance) {
		uint splitIndex = self.userSplit[user];
		uint lastClaimIndex = self.lastUserClaim[user];
		uint unclaimed = 0;
		if(self.splits[splitIndex].to == user) {
			for(uint depositIndex = lastClaimIndex; depositIndex < self.deposits.length; depositIndex++) {
				uint value = self.deposits[depositIndex] * self.splits[splitIndex].ppm / MILLION;
				unclaimed += value;
			}
		}
		return unclaimed;
	}

	function getClaimableBalance(CSCStorage storage self)  internal view returns (uint balance) {
		return getClaimableBalanceFor(self, msg.sender);
	}

	function transfer(CSCStorage storage self, address to, uint ppm) internal {
		require(getClaimableBalanceFor(self, msg.sender) == 0.0);
		require(getClaimableBalanceFor(self, to) == 0.0);
		require(ppm > 0);
		// neither user can have a pending balance to use transfer
		uint splitIndex = self.userSplit[msg.sender];
		if(splitIndex > 0 && self.splits[splitIndex].to == msg.sender && self.splits[splitIndex].ppm >= ppm) {
			self.splits[splitIndex].ppm -= ppm;
			addSplit(self, Split({to: to, ppm: ppm}));
		}
	}

	function pay(CSCStorage storage self) internal {
		if(self.isClaimable) {
			self.deposits.push(msg.value);
		} else {
			payAll(self);
		}
	}
}
contract ClaimableSplitCoin {

	using CSCLib for CSCLib.CSCStorage;

	CSCLib.CSCStorage csclib;

	function ClaimableSplitCoin(address[] members, uint[] ppms, address refer, bool claimable) public {
		csclib.isClaimable = claimable;
		csclib.dev_fee = 2500;
		csclib.developer = 0xaB48Dd4b814EBcb4e358923bd719Cd5cd356eA16;
		csclib.refer_fee = 250;
		csclib.init(members, ppms, refer);
	}

	function () public payable {
		csclib.pay();
	}

	function developer() public view returns(address) {
		return csclib.developer;
	}

	function getSplitCount() public view returns (uint count) {
		return csclib.getSplitCount();
	}

	function splits(uint index) public view returns (address to, uint ppm) {
		return (csclib.splits[index].to, csclib.splits[index].ppm);
	}

	function isClaimable() public view returns (bool) {
		return csclib.isClaimable;
	}

	event SplitTransfer(address to, uint amount, uint balance);

	function claimFor(address user) public {
		csclib.claimFor(user);
	}

	function claim() public {
		csclib.claimFor(msg.sender);
	}

	function getClaimableBalanceFor(address user) public view returns (uint balance) {
		return csclib.getClaimableBalanceFor(user);
	}

	function getClaimableBalance() public view returns (uint balance) {
		return csclib.getClaimableBalanceFor(msg.sender);
	}

	function transfer(address to, uint ppm) public {
		csclib.transfer(to, ppm);
	}
}
contract SplitCoinFactory {
  mapping(address => address[]) public contracts;
  mapping(address => uint) public referralContracts;
  mapping(address => address) public referredBy;
  mapping(address => address[]) public referrals;
  address[] public deployed;
  event Deployed (
    address _deployed
  );


  function make(address[] users, uint[] ppms, address refer, bool claimable) public returns (address) {
    address referContract = referredBy[msg.sender];
    if(refer != 0x0 && referContract == 0x0 && contracts[refer].length > 0 ) {
      uint referContractIndex = referralContracts[refer] - 1;
      if(referContractIndex >= 0 && refer != msg.sender) {
        referContract = contracts[refer][referContractIndex];
        referredBy[msg.sender] = referContract;
        referrals[refer].push(msg.sender);
      }
    }
    address sc = new ClaimableSplitCoin(users, ppms, referContract, claimable);
    contracts[msg.sender].push(sc);
    deployed.push(sc);
    Deployed(sc);
    return sc;
  }

  function generateReferralAddress(address refer) public returns (address) {
    uint[] memory ppms = new uint[](1);
    address[] memory users = new address[](1);
    ppms[0] = 1000000;
    users[0] = msg.sender;

    address referralContract = make(users, ppms, refer, true);
    if(referralContract != 0x0) {
      uint index = contracts[msg.sender].length;
      referralContracts[msg.sender] = index;
    }
    return referralContract;
  }
}