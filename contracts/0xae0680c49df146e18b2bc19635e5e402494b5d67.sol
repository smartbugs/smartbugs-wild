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


	/**************************
	     Private variables
	***************************/

	uint256 tokenBalance; // number of tokens in this account
  address owner;        // owner of the otkens
	address daoChallenge; // the DaoChallenge this account belongs to
	uint256 tokenPrice;

  // Owner of the challenge with backdoor access.
  // Remove for a real DAO contract:
  address challengeOwner;

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

  function DaoAccount (address _owner, uint256 _tokenPrice, address _challengeOwner) noEther {
    owner = _owner;
		tokenPrice = _tokenPrice;
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

	function getTokenBalance() constant returns (uint256 tokens) {
		return tokenBalance;
	}

	function buyTokens() onlyDaoChallenge returns (uint256 tokens) {
		uint256 amount = msg.value;

		// No free tokens:
		if (amount == 0) throw;

		// No fractional tokens:
		if (amount % tokenPrice != 0) throw;

		tokens = amount / tokenPrice;

		tokenBalance += tokens;

		return tokens;
	}

	function withdraw(uint256 tokens) noEther onlyDaoChallenge {
		if (tokens == 0 || tokenBalance == 0 || tokenBalance < tokens) throw;
		tokenBalance -= tokens;
		if(!owner.call.value(tokens * tokenPrice)()) throw;
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

	uint256 constant public tokenPrice = 1000000000000000; // 1 finney

	/**************************
					Events
	***************************/

	event notifyTerminate(uint256 finalBalance);

	event notifyNewAccount(address owner, address account);
	event notifyBuyToken(address owner, uint256 tokens, uint256 price);
	event notifyWithdraw(address owner, uint256 tokens);

	/**************************
	     Public variables
	***************************/

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
			account = new DaoAccount(accountOwner, tokenPrice, challengeOwner);
			daoAccounts[accountOwner] = account;
			notifyNewAccount(accountOwner, address(account));
		}

		return account;
	}

	/**************************
	     Public functions
	***************************/

	function getTokenBalance () constant noEther returns (uint256 tokens) {
		DaoAccount account = accountFor(msg.sender, false);
		if (account == DaoAccount(0x00)) return 0;
		return account.getTokenBalance();
	}

	function buyTokens () returns (uint256 tokens) {
	  DaoAccount account = accountFor(msg.sender, true);
		tokens = account.buyTokens.value(msg.value)();

		notifyBuyToken(msg.sender, tokens, msg.value);
		return tokens;
 	}

	function withdraw(uint256 tokens) noEther {
		DaoAccount account = accountFor(msg.sender, false);
		if (account == DaoAccount(0x00)) throw;

		account.withdraw(tokens);
		notifyWithdraw(msg.sender, tokens);
	}

	// The owner of the challenge can terminate it. Don't use this in a real DAO.
	function terminate() noEther onlyChallengeOwner {
		notifyTerminate(this.balance);
		suicide(challengeOwner);
	}
}