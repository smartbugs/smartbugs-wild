pragma solidity ^0.4.17;

interface ERC20Token {
	function balanceOf(address tokenOwner)
		public view returns (uint balance);
 	function transfer(address to, uint tokens)
		public returns (bool success);
	function symbol() public view returns (string);
	function name() public view returns (string);
	function decimals() public view returns (uint8);
}

contract MultiKeyDailyLimitWallet {
	uint constant LIMIT_PRECISION = 1000000;
	// Fractional daily limits per key. In units of 1/LIMIT_PRECISION.
	mapping(address=>uint) public credentials;
	// Timestamp of last withdrawal, by token (0x0 is ether).
	mapping(address=>uint) public lastWithdrawalTime;
	// Total withdrawn in last 24-hours, by token (0x0 is ether).
	// Resets if 24 hours passes with no activity.
	mapping(address=>uint) public dailyCount;
	uint public nonce;

	event OnWithdrawTo(
		address indexed token,
		address indexed from,
		address indexed to,
		uint amount,
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
	function setLastWithdrawalTime(address token, uint time) external {
		lastWithdrawalTime[token] = time;
	}
	function setDailyCount(address token, uint count) external {
		dailyCount[token] = count;
	}
	 #FI */

	function getAdjustedDailyCount(address token)
			private view returns (uint) {

		var _dailyCount = dailyCount[token];
		if ((block.timestamp - lastWithdrawalTime[token]) >= 1 days)
			_dailyCount = 0;
		return _dailyCount;
	}

	function getRemainingLimit(address token, address key)
			public view returns (uint) {

		var pct = credentials[key];
		if (pct == 0)
			return 0;

		var _dailyCount = getAdjustedDailyCount(token);
		var balance = getBalance(token);
		var amt = ((balance + _dailyCount) * pct) / LIMIT_PRECISION;
		if (amt == 0 && balance > 0)
			amt = 1;
		if (_dailyCount >= amt)
			return 0;
		return amt - _dailyCount;
	}

	function withdrawTo(
			address token,
			uint amount,
			address to,
			bytes signature) external {

		require(amount > 0 && to != address(this));
		assert(block.timestamp >= lastWithdrawalTime[token]);

		var limit = getSignatureRemainingLimit(
			signature,
			keccak256(address(this), token, nonce, amount, to),
			token);

		require(limit >= amount);
		require(getBalance(token) >= amount);

		dailyCount[token] = getAdjustedDailyCount(token) + amount;
		lastWithdrawalTime[token] = block.timestamp;
		nonce++;
		_transfer(token, to, amount);
		OnWithdrawTo(token, msg.sender, to, amount, uint64(block.timestamp));
	}

	function getBalance(address token) public view returns (uint) {
		if (token != 0x0) {
			// Token.
			return ERC20Token(token).balanceOf(address(this));
		}
		return this.balance;
	}

	function _transfer(address token, address to, uint amount)
	 		private {

		if (token != 0x0) {
			// Transfering a token.
			require(ERC20Token(token).transfer(to, amount));
			return;
		}
		to.transfer(amount);
	}

	function getSignatureRemainingLimit(
			bytes signature,
			bytes32 payload,
			address token)
			private view returns (uint) {

		var addr = extractSignatureAddress(signature, payload);
		return getRemainingLimit(token, addr);
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