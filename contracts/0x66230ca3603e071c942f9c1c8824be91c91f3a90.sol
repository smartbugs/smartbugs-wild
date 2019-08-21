contract SellOrder {
  /**************************
          Constants
  ***************************/

  /**************************
          Events
  ***************************/

  /**************************
       Public variables
  ***************************/

  // Owner of the challenge with backdoor access.
  // Remove for a real DAO contract:
  address public challengeOwner;
  address public owner; // DaoAccount that created the order
  uint256 public tokens;
  uint256 public price; // Wei per token

  /**************************
       Private variables
  ***************************/


  /**************************
           Modifiers
  ***************************/

  modifier noEther() {if (msg.value > 0) throw; _}

  modifier onlyOwner() {if (owner != msg.sender) throw; _}

  modifier onlyChallengeOwner() {if (challengeOwner != msg.sender) throw; _}

  /**************************
   Constructor and fallback
  **************************/

  function SellOrder (uint256 _tokens, uint256 _price, address _challengeOwner) noEther {
    owner = msg.sender;

    tokens = _tokens;
    price = _price;

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

  function cancel () noEther onlyOwner {
    suicide(owner);
  }

  function execute () {
    if (msg.value != tokens * price) throw;

    // Tokens are sent to the buyer in DaoAccount.executeSellOrder()
    // Send ether to seller:
    suicide(owner);
  }

  // The owner of the challenge can terminate it. Don't use this in a real DAO.
  function terminate() noEther onlyChallengeOwner {
    suicide(challengeOwner);
  }
}
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

  function placeSellOrder(uint256 tokens, uint256 price) noEther onlyDaoChallenge returns (SellOrder) {
    if (tokens == 0 || tokenBalance == 0 || tokenBalance < tokens) throw;
    if (tokenBalance - tokens > tokenBalance) throw; // Overflow
    tokenBalance -= tokens;

    SellOrder order = new SellOrder(tokens, price, challengeOwner);
    return order;
  }

  function cancelSellOrder(SellOrder order) noEther onlyDaoChallenge {
    uint256 tokens = order.tokens();
    tokenBalance += tokens;
    order.cancel();
  }

  function executeSellOrder(SellOrder order) onlyDaoChallenge {
    uint256 tokens = order.tokens();
    tokenBalance += tokens;
    order.execute.value(msg.value)();
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
  event notifyPlaceSellOrder(uint256 tokens, uint256 price);
  event notifyCancelSellOrder();
  event notifyExecuteSellOrder(uint256 tokens, uint256 price);

	/**************************
	     Public variables
	***************************/

	// For the current token issue:
	uint public tokenIssueDeadline = now;
	uint256 public tokensIssued = 0;
	uint256 public tokensToIssue = 0;
	uint256 public tokenPrice = 1000000000000000; // 1 finney

	mapping (address => DaoAccount) public daoAccounts;
  mapping (address => SellOrder) public sellOrders;

  // Owner of the challenge; a real DAO doesn't an owner.
  address public challengeOwner;

	/**************************
			 Private variables
	***************************/

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

  function getBalance () constant noEther returns (uint256) {
    DaoAccount account = accountFor(msg.sender, false);
    if (account == DaoAccount(0x00)) return 0;
    return account.balance;
  }

	function getTokenBalance () constant noEther returns (uint256 tokens) {
		DaoAccount account = accountFor(msg.sender, false);
		if (account == DaoAccount(0x00)) return 0;
		return account.getTokenBalance();
	}

	// n: max number of tokens to be issued
	// price: in wei, e.g. 1 finney = 0.001 eth = 1000000000000000 wei
	// deadline: unix timestamp in seconds
	function issueTokens (uint256 n, uint256 price, uint deadline) noEther onlyChallengeOwner {
		// Only allow one issuing at a time:
		if (now < tokenIssueDeadline) throw;

		// Deadline can't be in the past:
		if (deadline < now) throw;

		// Issue at least 1 token
		if (n == 0) throw;

		tokenPrice = price;
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

  function placeSellOrder(uint256 tokens, uint256 price) noEther returns (SellOrder) {
    DaoAccount account = accountFor(msg.sender, false);
    if (account == DaoAccount(0x00)) throw;

    SellOrder order = account.placeSellOrder(tokens, price);

    sellOrders[address(order)] = order;

    notifyPlaceSellOrder(tokens, price);
    return order;
  }

  function cancelSellOrder(address addr) noEther {
    DaoAccount account = accountFor(msg.sender, false);
    if (account == DaoAccount(0x00)) throw;

    SellOrder order = sellOrders[addr];
    if (order == SellOrder(0x00)) throw;

    if (order.owner() != address(account)) throw;

    sellOrders[addr] = SellOrder(0x00);

    account.cancelSellOrder(order);

    notifyCancelSellOrder();
  }

  function executeSellOrder(address addr) {
    // Fefuse if no ether is sent. SellOrder checks the exact amount.
    if (msg.value == 0) throw;

    DaoAccount account = accountFor(msg.sender, true);

    SellOrder order = sellOrders[addr];
    if (order == SellOrder(0x00)) throw;

    // Don't execute your own oder:
    if (order.owner() == address(account)) throw;

    uint256 tokens = order.tokens();
    uint256 price = order.price();

    // If order is successful, forget it (might not be necessary)
    sellOrders[addr] = SellOrder(0x00);

    account.executeSellOrder.value(msg.value)(order);

    notifyExecuteSellOrder(tokens, price);
  }

	// The owner of the challenge can terminate it. Don't use this in a real DAO.
	function terminate() noEther onlyChallengeOwner {
		notifyTerminate(this.balance);
		suicide(challengeOwner);
	}
}