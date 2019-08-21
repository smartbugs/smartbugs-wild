pragma solidity ^0.4.19;

contract SafeMath {
	function safeAdd(uint256 x, uint256 y) pure internal returns(uint256) {
		uint256 z = x + y;
		if (z < x || z < y) revert();
		return z;
	}
	function safeSubtract(uint256 x, uint256 y) pure internal returns(uint256) {
		if (x < y) revert();
		return x - y;
	}
	function safeMult(uint256 x, uint256 y) pure internal returns(uint256) {
		if (x == 0) return 0;
		uint256 z = x * y;
		if (z/x != y) revert();
		return z;
	}
}

contract AccessMgr {
	address public mOwner;
	
	mapping(address => uint) public mModerators;
	address[] public mModeratorKeys;
	
	function AccessMgr() public {
		mOwner = msg.sender;
	}
	
	modifier Owner {
		if (msg.sender != mOwner)
			revert();
		_;
	}
	
	modifier Moderators {
		if (msg.sender != mOwner && mModerators[msg.sender] == 0)
			revert();
		_;
	}
	
	function changeOwner(address owner) Owner public {
		if (owner != address(0x0))
			mOwner = owner;
	}
	
	function addModerator(address moderator) Owner public {
		if (moderator != address(0x0)) {
			if (mModerators[moderator] > 0)
				return;
			mModerators[moderator] = mModeratorKeys.length;
			mModeratorKeys.push(moderator);
		}
	}
	
	function removeModerator(address moderator) Owner public {
		uint256 index = mModerators[moderator];
		if (index == 0) return;
		uint256 last = mModeratorKeys.length - 1;
		address lastMod = mModeratorKeys[last];
		
		index--;
		
		mModeratorKeys[index] = lastMod;
		delete mModeratorKeys[last];
		mModeratorKeys.length--;
		
		delete mModerators[moderator];
		
		mModerators[lastMod] = index;
	}
}

contract UserMgr is SafeMath {
	struct User {
		uint256 balance;
		uint256[] hostedItems;
		uint256[] inventory;
	}

	mapping(address => User) public mUsers;
	
	function UserMgr() public {}
	
	function getUser(address addr) public view returns (string name, uint256 balance, uint256[] hostedItems, uint256[] inventory) {
		User memory user = mUsers[addr];
		return (
			"Anonymous",
			user.balance,
			user.hostedItems,
			user.inventory);
	}
	
	function userDeposit() payable public {
		User storage user = mUsers[msg.sender];
		user.balance = safeAdd(user.balance, msg.value);
	}
	
	function userWithdraw() payable public {
		address sender = msg.sender;
		User storage user = mUsers[sender];
		uint256 amount = user.balance;
		if (amount == 0) revert();
		user.balance = msg.value;
		require(sender.send(amount));
	}
}

contract ItemMgr {
	struct Item {
		string name;
		address hostAddress;
		uint256 price;
		uint256 numSold;
		uint256 basePrice;
		uint256 growthAmount;
		uint256 growthPeriod;
		address[] purchases;
	}

	Item[] public mItems;

	function ItemMgr() public {}

	function getNumItems() public view returns (uint256 count) {
		return mItems.length;
	}

	function getItem(uint256 index) public view
			returns (string name, address hostAddress, uint256 price, uint256 numSold,
					uint256 basePrice, uint256 growthAmount, uint256 growthPeriod) {
		uint256 length = mItems.length;
		if (index >= length) index = length-1;
		Item memory item = mItems[index];
		return (
			item.name, item.hostAddress, item.price, item.numSold,
			item.basePrice, item.growthAmount, item.growthPeriod
		);
	}
}

contract PonziBaseProcessor is SafeMath, AccessMgr, UserMgr, ItemMgr {
	
	uint256 public mHostFee = 0;
	
	event ItemCreated(address host, uint256 itemId);
	event ItemBought(address buyer, uint256 itemId, uint256 number, uint256 price, uint256 refund);
	
	function PonziBaseProcessor() public {
		mOwner = msg.sender;
	}
	
	function setHostFee(uint256 hostFee) Owner public {
		mHostFee = hostFee;
	}
	
	function createItem(string name, uint256 basePrice, uint256 growthAmount, uint256 growthPeriod) payable public returns (uint256 itemId) {
		address sender = msg.sender;
		User storage user = mUsers[sender];
		uint256 balance = user.balance;
		
		if (msg.value > 0)
			balance = safeAdd(balance, msg.value);
		
		if (basePrice <= 0)
			revert(); // Base price must be non-zero.
		
		//if (growthAmount <= 0) Allow non-growing items.
		//	revert(); // Growth amount must be non-zero.
		
		if (growthPeriod <= 0)
			revert(); // Growth period must be non-zero.
		
		if (bytes(name).length > 32)
			revert(); // Name must be 32 characters max.
		
		uint256 fee = basePrice;
		uint256 minFee = mHostFee;
		if (fee < minFee)
			fee = minFee;
		
		if (balance < fee)
			revert(); // Insufficient balance.
		
		uint256 id = mItems.length;
		mItems.length++;
		
		Item storage item = mItems[id];
		item.name = name;
		item.hostAddress = sender;
		item.price = basePrice;
		item.numSold = 0;
		item.basePrice = basePrice;
		item.growthAmount = growthAmount;
		item.growthPeriod = growthPeriod;
		
		item.purchases.push(mOwner);
		item.purchases.push(sender);
		
		balance = safeSubtract(balance, fee);
		user.balance = balance;
		user.hostedItems.push(id);
		user.inventory.push(id);
		
		User storage owner = mUsers[mOwner];
		owner.balance = safeAdd(owner.balance, fee);
		
		if (mOwner != sender) {
			owner.inventory.push(id);
		}
		
		ItemCreated(sender, id);
		
		return id;
	}
	
	function buyItem(uint256 id) payable public {
		address sender = msg.sender;
		User storage user = mUsers[sender];
		uint256 balance = user.balance;
		
		if (msg.value > 0)
			balance = safeAdd(balance, msg.value);
		
		Item storage item = mItems[id];
		uint256 price = item.price;
		
		if (price == 0)
			revert(); // Item not found.
		
		if (balance < price)
			revert(); // Insufficient balance.
		
		balance = safeSubtract(balance, price);
		user.balance = balance;
		user.inventory.push(id);
		
		uint256 length = item.purchases.length;
		
		uint256 refund = price;
		uint256 dividend = price / length;
		for (uint256 i=0; i<length; i++) {
			User storage holder = mUsers[item.purchases[i]];
			holder.balance = safeAdd(holder.balance, dividend);
			refund -= dividend;
		}
		// Consume the lost fraction when dividing as insurance for the contract,
		// but still report the refund value in the event.
		// user.balance += refund;
		
		item.purchases.push(sender);
		uint256 numSold = item.numSold++;
		
		if (item.numSold % item.growthPeriod == 0)
			item.price = safeAdd(item.price, item.growthAmount);
		
		ItemBought(sender, id, numSold, price, refund);
	}
}