pragma solidity ^0.4.17;

contract MultiKeyDailyLimitWallet {
	uint constant LIMIT_PRECISION = 1000000;
	// Fractional daily limits per key. In units of 1/LIMIT_PRECISION.
	mapping(address=>uint) public credentials;
	// Timestamp of last withdrawal.
	uint public lastWithdrawalTime;
	// Total withdrawn in last 24-hours. Resets if 24 hours passes with no activity.
	uint public dailyCount;
	uint public nonce;

	event OnWithdrawTo(address indexed from, address indexed to, uint amount,
		uint64 timestamp);

	function MultiKeyDailyLimitWallet(address[] keys, uint[] limits) public {
		require(keys.length == limits.length);
		for (uint i = 0; i < keys.length; i++) {
			var limit = limits[i];
			// limit should be in range 1-LIMIT_PRECISION
			require (limit > 0 && limit <= LIMIT_PRECISION);
			credentials[keys[i]] = limit;
		}
	}

	/* #IF TESTING
	function setLastWithdrawalTime(uint time) public {
		lastWithdrawalTime = time;
	}
	function setDailyCount(uint count) public {
		dailyCount = count;
	}
	function setNonce(uint _nonce) public {
		nonce = _nonce;
	}
	 #FI */

	function getRemainingLimit(address key) public view returns (uint) {
		var pct = credentials[key];
		if (pct == 0)
			return 0;

		var _dailyCount = dailyCount;
		if ((block.timestamp - lastWithdrawalTime) >= 1 days)
			_dailyCount = 0;

		var amt = ((this.balance + _dailyCount) * pct) / LIMIT_PRECISION;
		if (amt == 0 && this.balance > 0)
			amt = 1;
		if (_dailyCount >= amt)
			return 0;
		return amt - _dailyCount;
	}

	function withdrawTo(uint amount, address to, bytes signature) public {
		require(amount > 0 && to != address(this));
		assert(block.timestamp >= lastWithdrawalTime);

		var limit = getSignatureRemainingLimit(signature,
			keccak256(address(this), nonce, amount, to));
		require(limit >= amount);
		require(this.balance >= amount);

		// Reset daily count if it's been more than a day since last withdrawal.
		if ((block.timestamp - lastWithdrawalTime) >= 1 days)
			dailyCount = 0;

		lastWithdrawalTime = block.timestamp;
		dailyCount += amount;
		nonce++;
		to.transfer(amount);
		OnWithdrawTo(msg.sender, to, amount, uint64(block.timestamp));
	}

	function getSignatureRemainingLimit(bytes signature, bytes32 payload)
			private view returns (uint) {

		var addr = extractSignatureAddress(signature, payload);
		return getRemainingLimit(addr);
	}

	function extractSignatureAddress(bytes signature, bytes32 payload)
			private pure returns (address) {

		payload = keccak256("\x19Ethereum Signed Message:\n32", payload);
		bytes32 r;
		bytes32 s;
		uint8 v;
		assembly {
			r := mload(add(signature, 32))
			s := mload(add(signature, 64))
			v := and(mload(add(signature, 65)), 255)
		}
		if (v < 27)
			v += 27;
		require(v == 27 || v == 28);
		return ecrecover(payload, v, r, s);
	}

	function() public payable {}
}