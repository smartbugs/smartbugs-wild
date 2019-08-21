contract AbstractDaoChallenge {
	function isMember (DaoAccount account, address allegedOwnerAddress) returns (bool);
	function tokenPrice() returns (uint256);
}

contract DaoAccount
{
	/**************************
			    Constants
	***************************/

	/**************************
					Events
	***************************/

	// No events

	/**************************
	     Public variables
	***************************/

	address public daoChallenge; // the DaoChallenge this account belongs to

	// Owner of the challenge with backdoor access.
  // Remove for a real DAO contract:
  address public challengeOwner;

	/**************************
	     Private variables
	***************************/

	uint256 tokenBalance; // number of tokens in this account
  address owner;        // owner of the tokens

	/**************************
			     Modifiers
	***************************/

	modifier noEther() {if (msg.value > 0) throw; _}

	modifier onlyOwner() {if (owner != msg.sender) throw; _}

	modifier onlyDaoChallenge() {if (daoChallenge != msg.sender) throw; _}

	modifier onlyChallengeOwner() {if (challengeOwner != msg.sender) throw; _}

	/**************************
	 Constructor and fallback
	**************************/

  function DaoAccount (address _owner, address _challengeOwner) noEther {
    owner = _owner;
    daoChallenge = msg.sender;
		tokenBalance = 0;

    // Remove for a real DAO contract:
    challengeOwner = _challengeOwner;
	}

	function () {
		throw;
	}

	/**************************
	     Private functions
	***************************/

	/**************************
			 Public functions
	***************************/

	function getOwnerAddress() constant returns (address ownerAddress) {
		return owner;
	}

	function getTokenBalance() constant returns (uint256 tokens) {
		return tokenBalance;
	}

	function buyTokens() onlyDaoChallenge returns (uint256 tokens) {
		uint256 amount = msg.value;
		uint256 tokenPrice = AbstractDaoChallenge(daoChallenge).tokenPrice();

		// No free tokens:
		if (amount == 0) throw;

		// No fractional tokens:
		if (amount % tokenPrice != 0) throw;

		tokens = amount / tokenPrice;

		tokenBalance += tokens;

		return tokens;
	}

	function transfer(uint256 tokens, DaoAccount recipient) noEther onlyDaoChallenge {
		if (tokens == 0 || tokenBalance == 0 || tokenBalance < tokens) throw;
		if (tokenBalance - tokens > tokenBalance) throw; // Overflow
		tokenBalance -= tokens;
		recipient.receiveTokens(tokens);
	}

	function receiveTokens(uint256 tokens) {
		// Check that the sender is a DaoAccount and belongs to our DaoChallenge
		DaoAccount sender = DaoAccount(msg.sender);
		if (!AbstractDaoChallenge(daoChallenge).isMember(sender, sender.getOwnerAddress())) throw;

		if (tokens > sender.getTokenBalance()) throw;

		// Protect against overflow:
		if (tokenBalance + tokens < tokenBalance) throw;

		tokenBalance += tokens;
	}

	// The owner of the challenge can terminate it. Don't use this in a real DAO.
	function terminate() noEther onlyChallengeOwner {
		suicide(challengeOwner);
	}
}

contract DaoChallenge
{
	/**************************
					Constants
	***************************/


	/**************************
					Events
	***************************/

	event notifyTerminate(uint256 finalBalance);
	event notifyTokenIssued(uint256 n, uint256 price, uint deadline);

	event notifyNewAccount(address owner, address account);
	event notifyBuyToken(address owner, uint256 tokens, uint256 price);
	event notifyTransfer(address owner, address recipient, uint256 tokens);

	/**************************
	     Public variables
	***************************/

	// For the current token issue:
	uint public tokenIssueDeadline = now;
	uint256 public tokensIssued = 0;
	uint256 public tokensToIssue = 0;
	uint256 public tokenPrice = 1000000000000000; // 1 finney

	mapping (address => DaoAccount) public daoAccounts;

	/**************************
			 Private variables
	***************************/

	// Owner of the challenge; a real DAO doesn't an owner.
	address challengeOwner;

	/**************************
					 Modifiers
	***************************/

	modifier noEther() {if (msg.value > 0) throw; _}

	modifier onlyChallengeOwner() {if (challengeOwner != msg.sender) throw; _}

	/**************************
	 Constructor and fallback
	**************************/

	function DaoChallenge () {
		challengeOwner = msg.sender; // Owner of the challenge. Don't use this in a real DAO.
	}

	function () noEther {
	}

	/**************************
	     Private functions
	***************************/

	function accountFor (address accountOwner, bool createNew) private returns (DaoAccount) {
		DaoAccount account = daoAccounts[accountOwner];

		if(account == DaoAccount(0x00) && createNew) {
			account = new DaoAccount(accountOwner, challengeOwner);
			daoAccounts[accountOwner] = account;
			notifyNewAccount(accountOwner, address(account));
		}

		return account;
	}

	/**************************
	     Public functions
	***************************/

	function createAccount () {
		accountFor(msg.sender, true);
	}

	// Check if a given account belongs to this DaoChallenge.
	function isMember (DaoAccount account, address allegedOwnerAddress) returns (bool) {
		if (account == DaoAccount(0x00)) return false;
		if (allegedOwnerAddress == 0x00) return false;
		if (daoAccounts[allegedOwnerAddress] == DaoAccount(0x00)) return false;
		// allegedOwnerAddress is passed in for performance reasons, but not trusted
		if (daoAccounts[allegedOwnerAddress] != account) return false;
		return true;
	}

	function getTokenBalance () constant noEther returns (uint256 tokens) {
		DaoAccount account = accountFor(msg.sender, false);
		if (account == DaoAccount(0x00)) return 0;
		return account.getTokenBalance();
	}

	// n: max number of tokens to be issued
	// price: in szabo, e.g. 1 finney = 1,000 szabo = 0.001 ether
	// deadline: unix timestamp in seconds
	function issueTokens (uint256 n, uint256 price, uint deadline) noEther onlyChallengeOwner {
		// Only allow one issuing at a time:
		if (now < tokenIssueDeadline) throw;

		// Deadline can't be in the past:
		if (deadline < now) throw;

		// Issue at least 1 token
		if (n == 0) throw;

		tokenPrice = price * 1000000000000;
		tokenIssueDeadline = deadline;
		tokensToIssue = n;
		tokensIssued = 0;

		notifyTokenIssued(n, price, deadline);
	}

	function buyTokens () returns (uint256 tokens) {
		tokens = msg.value / tokenPrice;

		if (now > tokenIssueDeadline) throw;
		if (tokensIssued >= tokensToIssue) throw;

		// This hopefully prevents issuing too many tokens
		// if there's a race condition:
		tokensIssued += tokens;
		if (tokensIssued > tokensToIssue) throw;

	  DaoAccount account = accountFor(msg.sender, true);
		if (account.buyTokens.value(msg.value)() != tokens) throw;

		notifyBuyToken(msg.sender, tokens, msg.value);
		return tokens;
 	}

	function transfer(uint256 tokens, address recipient) noEther {
		DaoAccount account = accountFor(msg.sender, false);
		if (account == DaoAccount(0x00)) throw;

		DaoAccount recipientAcc = accountFor(recipient, false);
		if (recipientAcc == DaoAccount(0x00)) throw;

		account.transfer(tokens, recipientAcc);
		notifyTransfer(msg.sender, recipient, tokens);
	}

	// The owner of the challenge can terminate it. Don't use this in a real DAO.
	function terminate() noEther onlyChallengeOwner {
		notifyTerminate(this.balance);
		suicide(challengeOwner);
	}
}