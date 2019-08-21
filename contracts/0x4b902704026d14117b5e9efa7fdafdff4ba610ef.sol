contract DaoAccount
{
	/**************************
			    Constants
	***************************/

	uint256 constant tokenPrice = 1000000000000000; // 1 finney

	/**************************
					Events
	***************************/

	// No events
	
	/**************************
	     Public variables
	***************************/

  uint256 public tokenBalance; // number of tokens in this account

	/**************************
	     Private variables
	***************************/

  address owner;        // owner of the otkens
	address daoChallenge; // the DaoChallenge this account belongs to

  // Owner of the challenge with backdoor access.
  // Remove for a real DAO contract:
  address challengeOwner;

	/**************************
			     Modifiers
	***************************/

	modifier noEther() {if (msg.value > 0) throw; _}

	modifier onlyOwner() {if (owner != msg.sender) throw; _}

	modifier onlyChallengeOwner() {if (challengeOwner != msg.sender) throw; _}

	/**************************
	 Constructor and fallback
	**************************/

  function DaoAccount (address _owner, address _challengeOwner) {
    owner = _owner;
    daoChallenge = msg.sender;

    // Remove for a real DAO contract:
    challengeOwner = _challengeOwner;
	}

  // Only owner can fund:
	function () onlyOwner returns (uint256 newBalance){
		uint256 amount = msg.value;

		// No fractional tokens:
		if (amount % tokenPrice != 0) {
			throw;
		}

    uint256 tokens = amount / tokenPrice;

		tokenBalance += tokens;

    return tokenBalance;
	}

	/**************************
	     Private functions
	***************************/

	// This uses call.value()() rather than send(), but only sends to msg.sender
  // who is also the owner.
	function withdrawEtherOrThrow(uint256 amount) private {
    if (msg.sender != owner) throw;
		bool result = owner.call.value(amount)();
		if (!result) {
			throw;
		}
	}

	/**************************
			 Public functions
	***************************/

	function refund() noEther onlyOwner {
		if (tokenBalance == 0) throw;
		tokenBalance = 0;
		withdrawEtherOrThrow(tokenBalance * tokenPrice);
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

	// No Constants

	/**************************
					Events
	***************************/

	event notifyTerminate(uint256 finalBalance);

	/**************************
	     Public variables
	***************************/

	/**************************
			 Private variables
	***************************/

	// Owner of the challenge; a real DAO doesn't an owner.
	address owner;

	mapping (address => DaoAccount) private daoAccounts;

	/**************************
					 Modifiers
	***************************/

	modifier noEther() {if (msg.value > 0) throw; _}

	modifier onlyOwner() {if (owner != msg.sender) throw; _}

	/**************************
	 Constructor and fallback
	**************************/

	function DaoChallenge () {
		owner = msg.sender; // Owner of the challenge. Don't use this in a real DAO.
	}

	function () noEther {
	}

	/**************************
	     Private functions
	***************************/

	// No private functions

	/**************************
	     Public functions
	***************************/

	function createAccount () noEther returns (DaoAccount account) {
		address accountOwner = msg.sender;
		address challengeOwner = owner; // Don't use in a real DAO

		// One account per address:
		if(daoAccounts[accountOwner] != DaoAccount(0x00)) throw;

		daoAccounts[accountOwner] = new DaoAccount(accountOwner, challengeOwner);
		return daoAccounts[accountOwner];
	}

	function myAccount () noEther returns (DaoAccount) {
		address accountOwner = msg.sender;
		return daoAccounts[accountOwner];
	}

	// The owner of the challenge can terminate it. Don't use this in a real DAO.
	function terminate() noEther onlyOwner {
		notifyTerminate(this.balance);
		suicide(owner);
	}
}