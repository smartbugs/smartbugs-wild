//! Copyright Parity Technologies, 2017.
//! Released under the Apache Licence 2.

pragma solidity ^0.4.17;

/// Stripped down ERC20 standard token interface.
contract Token {
	function transfer(address _to, uint256 _value) public returns (bool success);
}

// From Certifier.sol
contract Certifier {
	event Confirmed(address indexed who);
	event Revoked(address indexed who);
	function certified(address) public constant returns (bool);
	function get(address, string) public constant returns (bytes32);
	function getAddress(address, string) public constant returns (address);
	function getUint(address, string) public constant returns (uint);
}

/// Simple modified second price auction contract. Price starts high and monotonically decreases
/// until all tokens are sold at the current price with currently received funds.
/// The price curve has been chosen to resemble a logarithmic curve
/// and produce a reasonable auction timeline.
contract SecondPriceAuction {
	// Events:

	/// Someone bought in at a particular max-price.
	event Buyin(address indexed who, uint accounted, uint received, uint price);

	/// Admin injected a purchase.
	event Injected(address indexed who, uint accounted, uint received);

	/// Admin uninjected a purchase.
	event Uninjected(address indexed who);

	/// At least 5 minutes has passed since last Ticked event.
	event Ticked(uint era, uint received, uint accounted);

	/// The sale just ended with the current price.
	event Ended(uint price);

	/// Finalised the purchase for `who`, who has been given `tokens` tokens.
	event Finalised(address indexed who, uint tokens);

	/// Auction is over. All accounts finalised.
	event Retired();

	// Constructor:

	/// Simple constructor.
	/// Token cap should take be in whole tokens, not smallest divisible units.
	function SecondPriceAuction(
		address _certifierContract,
		address _tokenContract,
		address _treasury,
		address _admin,
		uint _beginTime,
		uint _tokenCap
	)
		public
	{
		certifier = Certifier(_certifierContract);
		tokenContract = Token(_tokenContract);
		treasury = _treasury;
		admin = _admin;
		beginTime = _beginTime;
		tokenCap = _tokenCap;
		endTime = beginTime + 28 days;
	}

	// No default function, entry-level users
	function() public { assert(false); }

	// Public interaction:

	/// Buyin function. Throws if the sale is not active and when refund would be needed.
	function buyin(uint8 v, bytes32 r, bytes32 s)
		public
		payable
		when_not_halted
		when_active
		only_eligible(msg.sender, v, r, s)
	{
		flushEra();

		// Flush bonus period:
		if (currentBonus > 0) {
			// Bonus is currently active...
			if (now >= beginTime + BONUS_MIN_DURATION				// ...but outside the automatic bonus period
				&& lastNewInterest + BONUS_LATCH <= block.number	// ...and had no new interest for some blocks
			) {
				currentBonus--;
			}
			if (now >= beginTime + BONUS_MAX_DURATION) {
				currentBonus = 0;
			}
			if (buyins[msg.sender].received == 0) {	// We have new interest
				lastNewInterest = uint32(block.number);
			}
		}

		uint accounted;
		bool refund;
		uint price;
		(accounted, refund, price) = theDeal(msg.value);

		/// No refunds allowed.
		require (!refund);

		// record the acceptance.
		buyins[msg.sender].accounted += uint128(accounted);
		buyins[msg.sender].received += uint128(msg.value);
		totalAccounted += accounted;
		totalReceived += msg.value;
		endTime = calculateEndTime();
		Buyin(msg.sender, accounted, msg.value, price);

		// send to treasury
		treasury.transfer(msg.value);
	}

	/// Like buyin except no payment required and bonus automatically given.
	function inject(address _who, uint128 _received)
		public
		only_admin
		only_basic(_who)
		before_beginning
	{
		uint128 bonus = _received * uint128(currentBonus) / 100;
		uint128 accounted = _received + bonus;

		buyins[_who].accounted += accounted;
		buyins[_who].received += _received;
		totalAccounted += accounted;
		totalReceived += _received;
		endTime = calculateEndTime();
		Injected(_who, accounted, _received);
	}

	/// Reverses a previous `inject` command.
	function uninject(address _who)
		public
		only_admin
		before_beginning
	{
		totalAccounted -= buyins[_who].accounted;
		totalReceived -= buyins[_who].received;
		delete buyins[_who];
		endTime = calculateEndTime();
		Uninjected(_who);
	}

	/// Mint tokens for a particular participant.
	function finalise(address _who)
		public
		when_not_halted
		when_ended
		only_buyins(_who)
	{
		// end the auction if we're the first one to finalise.
		if (endPrice == 0) {
			endPrice = totalAccounted / tokenCap;
			Ended(endPrice);
		}

		// enact the purchase.
		uint total = buyins[_who].accounted;
		uint tokens = total / endPrice;
		totalFinalised += total;
		delete buyins[_who];
		require (tokenContract.transfer(_who, tokens));

		Finalised(_who, tokens);

		if (totalFinalised == totalAccounted) {
			Retired();
		}
	}

	// Prviate utilities:

	/// Ensure the era tracker is prepared in case the current changed.
	function flushEra() private {
		uint currentEra = (now - beginTime) / ERA_PERIOD;
		if (currentEra > eraIndex) {
			Ticked(eraIndex, totalReceived, totalAccounted);
		}
		eraIndex = currentEra;
	}

	// Admin interaction:

	/// Emergency function to pause buy-in and finalisation.
	function setHalted(bool _halted) public only_admin { halted = _halted; }

	/// Emergency function to drain the contract of any funds.
	function drain() public only_admin { treasury.transfer(this.balance); }

	// Inspection:

	/**
	 * The formula for the price over time.
	 *
	 * This is a hand-crafted formula (no named to the constants) in order to
	 * provide the following requirements:
	 *
	 * - Simple reciprocal curve (of the form y = a + b / (x + c));
	 * - Would be completely unreasonable to end in the first 48 hours;
	 * - Would reach $65m effective cap in 4 weeks.
	 *
	 * The curve begins with an effective cap (EC) of over $30b, more ether
	 * than is in existance. After 48 hours, the EC reduces to approx. $1b.
	 * At just over 10 days, the EC has reduced to $200m, and half way through
	 * the 19th day it has reduced to $100m.
	 *
	 * Here's the curve: https://www.desmos.com/calculator/k6iprxzcrg?embed
	 */

	/// The current end time of the sale assuming that nobody else buys in.
	function calculateEndTime() public constant returns (uint) {
		var factor = tokenCap / DIVISOR * USDWEI;
		return beginTime + 40000000 * factor / (totalAccounted + 5 * factor) - 5760;
	}

	/// The current price for a single indivisible part of a token. If a buyin happens now, this is
	/// the highest price per indivisible token part that the buyer will pay. This doesn't
	/// include the discount which may be available.
	function currentPrice() public constant when_active returns (uint weiPerIndivisibleTokenPart) {
		return (USDWEI * 40000000 / (now - beginTime + 5760) - USDWEI * 5) / DIVISOR;
	}

	/// Returns the total indivisible token parts available for purchase right now.
	function tokensAvailable() public constant when_active returns (uint tokens) {
		uint _currentCap = totalAccounted / currentPrice();
		if (_currentCap >= tokenCap) {
			return 0;
		}
		return tokenCap - _currentCap;
	}

	/// The largest purchase than can be made at present, not including any
	/// discount.
	function maxPurchase() public constant when_active returns (uint spend) {
		return tokenCap * currentPrice() - totalAccounted;
	}

	/// Get the number of `tokens` that would be given if the sender were to
	/// spend `_value` now. Also tell you what `refund` would be given, if any.
	function theDeal(uint _value)
		public
		constant
		when_active
		returns (uint accounted, bool refund, uint price)
	{
		uint _bonus = bonus(_value);

		price = currentPrice();
		accounted = _value + _bonus;

		uint available = tokensAvailable();
		uint tokens = accounted / price;
		refund = (tokens > available);
	}

	/// Any applicable bonus to `_value`.
	function bonus(uint _value)
		public
		constant
		when_active
		returns (uint extra)
	{
		return _value * uint(currentBonus) / 100;
	}

	/// True if the sale is ongoing.
	function isActive() public constant returns (bool) { return now >= beginTime && now < endTime; }

	/// True if all buyins have finalised.
	function allFinalised() public constant returns (bool) { return now >= endTime && totalAccounted == totalFinalised; }

	/// Returns true if the sender of this transaction is a basic account.
	function isBasicAccount(address _who) internal constant returns (bool) {
		uint senderCodeSize;
		assembly {
			senderCodeSize := extcodesize(_who)
		}
	    return senderCodeSize == 0;
	}

	// Modifiers:

	/// Ensure the sale is ongoing.
	modifier when_active { require (isActive()); _; }

	/// Ensure the sale has not begun.
	modifier before_beginning { require (now < beginTime); _; }

	/// Ensure the sale is ended.
	modifier when_ended { require (now >= endTime); _; }

	/// Ensure we're not halted.
	modifier when_not_halted { require (!halted); _; }

	/// Ensure `_who` is a participant.
	modifier only_buyins(address _who) { require (buyins[_who].accounted != 0); _; }

	/// Ensure sender is admin.
	modifier only_admin { require (msg.sender == admin); _; }

	/// Ensure that the signature is valid, `who` is a certified, basic account,
	/// the gas price is sufficiently low and the value is sufficiently high.
	modifier only_eligible(address who, uint8 v, bytes32 r, bytes32 s) {
		require (
			ecrecover(STATEMENT_HASH, v, r, s) == who &&
			certifier.certified(who) &&
			isBasicAccount(who) &&
			msg.value >= DUST_LIMIT
		);
		_;
	}

	/// Ensure sender is not a contract.
	modifier only_basic(address who) { require (isBasicAccount(who)); _; }

	// State:

	struct Account {
		uint128 accounted;	// including bonus & hit
		uint128 received;	// just the amount received, without bonus & hit
	}

	/// Those who have bought in to the auction.
	mapping (address => Account) public buyins;

	/// Total amount of ether received, excluding phantom "bonus" ether.
	uint public totalReceived = 0;

	/// Total amount of ether accounted for, including phantom "bonus" ether.
	uint public totalAccounted = 0;

	/// Total amount of ether which has been finalised.
	uint public totalFinalised = 0;

	/// The current end time. Gets updated when new funds are received.
	uint public endTime;

	/// The price per token; only valid once the sale has ended and at least one
	/// participant has finalised.
	uint public endPrice;

	/// Must be false for any public function to be called.
	bool public halted;

	/// The current percentage of bonus that purchasers get.
	uint8 public currentBonus = 15;

	/// The last block that had a new participant.
	uint32 public lastNewInterest;

	// Constants after constructor:

	/// The tokens contract.
	Token public tokenContract;

	/// The certifier.
	Certifier public certifier;

	/// The treasury address; where all the Ether goes.
	address public treasury;

	/// The admin address; auction can be paused or halted at any time by this.
	address public admin;

	/// The time at which the sale begins.
	uint public beginTime;

	/// Maximum amount of tokens to mint. Once totalAccounted / currentPrice is
	/// greater than this, the sale ends.
	uint public tokenCap;

	// Era stuff (isolated)
	/// The era for which the current consolidated data represents.
	uint public eraIndex;

	/// The size of the era in seconds.
	uint constant public ERA_PERIOD = 5 minutes;

	// Static constants:

	/// Anything less than this is considered dust and cannot be used to buy in.
	uint constant public DUST_LIMIT = 5 finney;

	/// The hash of the statement which must be signed in order to buyin.
	/// The meaning of this hash is:
	///
	/// parity.api.util.sha3(parity.api.util.asciiToHex("\x19Ethereum Signed Message:\n" + tscs.length + tscs))
	/// where `toUTF8 = x => unescape(encodeURIComponent(x))`
	/// and `tscs` is the toUTF8 called on the contents of https://gist.githubusercontent.com/gavofyork/5a530cad3b19c1cafe9148f608d729d2/raw/a116b507fd6d96036037f3affd393994b307c09a/gistfile1.txt
	bytes32 constant public STATEMENT_HASH = 0x2cedb9c5443254bae6c4f44a31abcb33ec27a0bd03eb58e22e38cdb8b366876d;

	/// Minimum duration after sale begins that bonus is active.
	uint constant public BONUS_MIN_DURATION = 1 hours;

	/// Minimum duration after sale begins that bonus is active.
	uint constant public BONUS_MAX_DURATION = 24 hours;

	/// Number of consecutive blocks where there must be no new interest before bonus ends.
	uint constant public BONUS_LATCH = 2;

	/// Number of Wei in one USD, constant.
	uint constant public USDWEI = 3226 szabo;

	/// Divisor of the token.
	uint constant public DIVISOR = 1000;
}