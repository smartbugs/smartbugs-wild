contract DaoChallenge
{
	modifier noEther() {if (msg.value > 0) throw; _}

	modifier onlyOwner() {if (owner != msg.sender) throw; _}

	event notifySellToken(uint256 n, address buyer);
	event notifyRefundToken(uint256 n, address tokenHolder);
	event notifyTranferToken(uint256 n, address sender, address recipient);
	event notifyTerminate(uint256 finalBalance);

	/* This creates an array with all balances */
  mapping (address => uint256) public tokenBalanceOf;

	uint256 constant tokenPrice = 1000000000000000; // 1 finney

	// Owner of the challenge; a real DAO doesn't an owner.
	address owner;

	function DaoChallenge () {
		owner = msg.sender; // Owner of the challenge. Don't use this in a real DAO.
	}

	function () {
		address sender = msg.sender;
		uint256 amount = msg.value;

		// No fractional tokens:
		if (amount % tokenPrice != 0) {
			throw;
		}
		tokenBalanceOf[sender] += amount / tokenPrice;
		notifySellToken(amount, sender);
	}

	// This uses call.value()() rather than send(), but only sends to msg.sender
	function withdrawEtherOrThrow(uint256 amount) {
		bool result = msg.sender.call.value(amount)();
		if (!result) {
			throw;
		}
	}

	function refund() noEther {
		address sender = msg.sender;
		uint256 tokenBalance = tokenBalanceOf[sender];
		if (tokenBalance == 0) { throw; }
		tokenBalanceOf[sender] = 0;
		withdrawEtherOrThrow(tokenBalance * tokenPrice);
		notifyRefundToken(tokenBalance, sender);
	}

	function transfer(address recipient, uint256 tokens) noEther {
		address sender = msg.sender;

		if (tokenBalanceOf[sender] < tokens) throw;
		if (tokenBalanceOf[recipient] + tokens < tokenBalanceOf[recipient]) throw; // Check for overflows
		tokenBalanceOf[sender] -= tokens;
		tokenBalanceOf[recipient] += tokens;
		notifyTranferToken(tokens, sender, recipient);
	}

	// The owner of the challenge can terminate it. Don't use this in a real DAO.
	function terminate() noEther onlyOwner {
		notifyTerminate(this.balance);
		suicide(owner);
	}
}