pragma solidity ^0.4.13;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract AbstractStarbaseToken {
    function isFundraiser(address fundraiserAddress) public returns (bool);
    function company() public returns (address);
    function allocateToCrowdsalePurchaser(address to, uint256 value) public returns (bool);
    function allocateToMarketingSupporter(address to, uint256 value) public returns (bool);
}


contract AbstractStarbaseCrowdsale {
    function startDate() constant returns (uint256) {}
    function endedAt() constant returns (uint256) {}
    function isEnded() constant returns (bool);
    function totalRaisedAmountInCny() constant returns (uint256);
    function numOfPurchasedTokensOnCsBy(address purchaser) constant returns (uint256);
    function numOfPurchasedTokensOnEpBy(address purchaser) constant returns (uint256);
}

/// @title EarlyPurchase contract - Keep track of purchased amount by Early Purchasers
/// @author Starbase PTE. LTD. - <info@starbase.co>
contract StarbaseEarlyPurchase {
    /*
     *  Constants
     */
    string public constant PURCHASE_AMOUNT_UNIT = 'CNY';    // Chinese Yuan
    string public constant PURCHASE_AMOUNT_RATE_REFERENCE = 'http://www.xe.com/currencytables/';
    uint256 public constant PURCHASE_AMOUNT_CAP = 9000000;

    /*
     *  Types
     */
    struct EarlyPurchase {
        address purchaser;
        uint256 amount;        // CNY based amount
        uint256 purchasedAt;   // timestamp
    }

    /*
     *  External contracts
     */
    AbstractStarbaseCrowdsale public starbaseCrowdsale;

    /*
     *  Storage
     */
    address public owner;
    EarlyPurchase[] public earlyPurchases;
    uint256 public earlyPurchaseClosedAt;

    /*
     *  Modifiers
     */
    modifier noEther() {
        require(msg.value == 0);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyBeforeCrowdsale() {
        assert(address(starbaseCrowdsale) == address(0) || starbaseCrowdsale.startDate() == 0);
        _;
    }

    modifier onlyEarlyPurchaseTerm() {
        assert(earlyPurchaseClosedAt <= 0);
        _;
    }

    /*
     *  Contract functions
     */

    /**
     * @dev Returns early purchased amount by purchaser's address
     * @param purchaser Purchaser address
     */
    function purchasedAmountBy(address purchaser)
        external
        constant
        noEther
        returns (uint256 amount)
    {
        for (uint256 i; i < earlyPurchases.length; i++) {
            if (earlyPurchases[i].purchaser == purchaser) {
                amount += earlyPurchases[i].amount;
            }
        }
    }

    /**
     * @dev Returns total amount of raised funds by Early Purchasers
     */
    function totalAmountOfEarlyPurchases()
        constant
        noEther
        public
        returns (uint256 totalAmount)
    {
        for (uint256 i; i < earlyPurchases.length; i++) {
            totalAmount += earlyPurchases[i].amount;
        }
    }

    /**
     * @dev Returns number of early purchases
     */
    function numberOfEarlyPurchases()
        external
        constant
        noEther
        returns (uint256)
    {
        return earlyPurchases.length;
    }

    /**
     * @dev Append an early purchase log
     * @param purchaser Purchaser address
     * @param amount Purchase amount
     * @param purchasedAt Timestamp of purchased date
     */
    function appendEarlyPurchase(address purchaser, uint256 amount, uint256 purchasedAt)
        external
        noEther
        onlyOwner
        onlyBeforeCrowdsale
        onlyEarlyPurchaseTerm
        returns (bool)
    {
        if (amount == 0 ||
            totalAmountOfEarlyPurchases() + amount > PURCHASE_AMOUNT_CAP)
        {
            return false;
        }

        assert(purchasedAt != 0 || purchasedAt <= now);

        earlyPurchases.push(EarlyPurchase(purchaser, amount, purchasedAt));
        return true;
    }

    /**
     * @dev Close early purchase term
     */
    function closeEarlyPurchase()
        external
        noEther
        onlyOwner
        returns (bool)
    {
        earlyPurchaseClosedAt = now;
    }

    /**
     * @dev Setup function sets external contract's address
     * @param starbaseCrowdsaleAddress Token address
     */
    function setup(address starbaseCrowdsaleAddress)
        external
        noEther
        onlyOwner
        returns (bool)
    {
        if (address(starbaseCrowdsale) == 0) {
            starbaseCrowdsale = AbstractStarbaseCrowdsale(starbaseCrowdsaleAddress);
            return true;
        }
        return false;
    }

    /**
     * @dev Contract constructor function
     */
    function StarbaseEarlyPurchase() noEther {
        owner = msg.sender;
    }
}

/// @title EarlyPurchaseAmendment contract - Amend early purchase records of the original contract
/// @author Starbase PTE. LTD. - <support@starbase.co>
contract StarbaseEarlyPurchaseAmendment {
    /*
     *  Events
     */
    event EarlyPurchaseInvalidated(uint256 epIdx);
    event EarlyPurchaseAmended(uint256 epIdx);

    /*
     *  External contracts
     */
    AbstractStarbaseCrowdsale public starbaseCrowdsale;
    StarbaseEarlyPurchase public starbaseEarlyPurchase;

    /*
     *  Storage
     */
    address public owner;
    uint256[] public invalidEarlyPurchaseIndexes;
    uint256[] public amendedEarlyPurchaseIndexes;
    mapping (uint256 => StarbaseEarlyPurchase.EarlyPurchase) public amendedEarlyPurchases;

    /*
     *  Modifiers
     */
    modifier noEther() {
        require(msg.value == 0);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyBeforeCrowdsale() {
        assert(address(starbaseCrowdsale) == address(0) || starbaseCrowdsale.startDate() == 0);
        _;
    }

    modifier onlyEarlyPurchasesLoaded() {
        assert(address(starbaseEarlyPurchase) != address(0));
        _;
    }

    /*
     *  Functions below are compatible with starbaseEarlyPurchase contract
     */

    /**
     * @dev Returns an early purchase record
     * @param earlyPurchaseIndex Index number of an early purchase
     */
    function earlyPurchases(uint256 earlyPurchaseIndex)
        external
        constant
        onlyEarlyPurchasesLoaded
        returns (address purchaser, uint256 amount, uint256 purchasedAt)
    {
        return starbaseEarlyPurchase.earlyPurchases(earlyPurchaseIndex);
    }

    /**
     * @dev Returns early purchased amount by purchaser's address
     * @param purchaser Purchaser address
     */
    function purchasedAmountBy(address purchaser)
        external
        constant
        noEther
        returns (uint256 amount)
    {
        StarbaseEarlyPurchase.EarlyPurchase[] memory normalizedEP =
            normalizedEarlyPurchases();
        for (uint256 i; i < normalizedEP.length; i++) {
            if (normalizedEP[i].purchaser == purchaser) {
                amount += normalizedEP[i].amount;
            }
        }
    }

    /**
     * @dev Returns total amount of raised funds by Early Purchasers
     */
    function totalAmountOfEarlyPurchases()
        constant
        noEther
        public
        returns (uint256 totalAmount)
    {
        StarbaseEarlyPurchase.EarlyPurchase[] memory normalizedEP =
            normalizedEarlyPurchases();
        for (uint256 i; i < normalizedEP.length; i++) {
            totalAmount += normalizedEP[i].amount;
        }
    }

    /**
     * @dev Returns number of early purchases
     */
    function numberOfEarlyPurchases()
        external
        constant
        noEther
        returns (uint256)
    {
        return normalizedEarlyPurchases().length;
    }

    /**
     * @dev Sets up function sets external contract's address
     * @param starbaseCrowdsaleAddress Token address
     */
    function setup(address starbaseCrowdsaleAddress)
        external
        noEther
        onlyOwner
        returns (bool)
    {
        if (address(starbaseCrowdsale) == 0) {
            starbaseCrowdsale = AbstractStarbaseCrowdsale(starbaseCrowdsaleAddress);
            return true;
        }
        return false;
    }

    /*
     *  Contract functions unique to StarbaseEarlyPurchaseAmendment
     */

     /**
      * @dev Invalidate early purchase
      * @param earlyPurchaseIndex Index number of the purchase
      */
    function invalidateEarlyPurchase(uint256 earlyPurchaseIndex)
        external
        noEther
        onlyOwner
        onlyEarlyPurchasesLoaded
        onlyBeforeCrowdsale
        returns (bool)
    {
        assert(numberOfRawEarlyPurchases() > earlyPurchaseIndex); // Array Index Out of Bounds Exception

        for (uint256 i; i < invalidEarlyPurchaseIndexes.length; i++) {
            assert(invalidEarlyPurchaseIndexes[i] != earlyPurchaseIndex);
        }

        invalidEarlyPurchaseIndexes.push(earlyPurchaseIndex);
        EarlyPurchaseInvalidated(earlyPurchaseIndex);
        return true;
    }

    /**
     * @dev Checks whether early purchase is invalid
     * @param earlyPurchaseIndex Index number of the purchase
     */
    function isInvalidEarlyPurchase(uint256 earlyPurchaseIndex)
        constant
        noEther
        public
        returns (bool)
    {
        assert(numberOfRawEarlyPurchases() > earlyPurchaseIndex); // Array Index Out of Bounds Exception


        for (uint256 i; i < invalidEarlyPurchaseIndexes.length; i++) {
            if (invalidEarlyPurchaseIndexes[i] == earlyPurchaseIndex) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Amends a given early purchase with data
     * @param earlyPurchaseIndex Index number of the purchase
     * @param purchaser Purchaser's address
     * @param amount Value of purchase
     * @param purchasedAt Purchase timestamp
     */
    function amendEarlyPurchase(uint256 earlyPurchaseIndex, address purchaser, uint256 amount, uint256 purchasedAt)
        external
        noEther
        onlyOwner
        onlyEarlyPurchasesLoaded
        onlyBeforeCrowdsale
        returns (bool)
    {
        assert(purchasedAt != 0 || purchasedAt <= now);

        assert(numberOfRawEarlyPurchases() > earlyPurchaseIndex);

        assert(!isInvalidEarlyPurchase(earlyPurchaseIndex)); // Invalid early purchase cannot be amended

        if (!isAmendedEarlyPurchase(earlyPurchaseIndex)) {
            amendedEarlyPurchaseIndexes.push(earlyPurchaseIndex);
        }

        amendedEarlyPurchases[earlyPurchaseIndex] =
            StarbaseEarlyPurchase.EarlyPurchase(purchaser, amount, purchasedAt);
        EarlyPurchaseAmended(earlyPurchaseIndex);
        return true;
    }

    /**
     * @dev Checks whether early purchase is amended
     * @param earlyPurchaseIndex Index number of the purchase
     */
    function isAmendedEarlyPurchase(uint256 earlyPurchaseIndex)
        constant
        noEther
        returns (bool)
    {
        assert(numberOfRawEarlyPurchases() > earlyPurchaseIndex); // Array Index Out of Bounds Exception

        for (uint256 i; i < amendedEarlyPurchaseIndexes.length; i++) {
            if (amendedEarlyPurchaseIndexes[i] == earlyPurchaseIndex) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Loads early purchases data to StarbaseEarlyPurchaseAmendment contract
     * @param starbaseEarlyPurchaseAddress Address from starbase early purchase
     */
    function loadStarbaseEarlyPurchases(address starbaseEarlyPurchaseAddress)
        external
        noEther
        onlyOwner
        onlyBeforeCrowdsale
        returns (bool)
    {
        assert(starbaseEarlyPurchaseAddress != 0 ||
            address(starbaseEarlyPurchase) == 0);

        starbaseEarlyPurchase = StarbaseEarlyPurchase(starbaseEarlyPurchaseAddress);
        assert(starbaseEarlyPurchase.earlyPurchaseClosedAt() != 0); // the early purchase must be closed

        return true;
    }

    /**
     * @dev Contract constructor function. It sets owner
     */
    function StarbaseEarlyPurchaseAmendment() noEther {
        owner = msg.sender;
    }

    /**
     * Internal functions
     */

    /**
     * @dev Normalizes early purchases data
     */
    function normalizedEarlyPurchases()
        constant
        internal
        returns (StarbaseEarlyPurchase.EarlyPurchase[] normalizedEP)
    {
        uint256 rawEPCount = numberOfRawEarlyPurchases();
        normalizedEP = new StarbaseEarlyPurchase.EarlyPurchase[](
            rawEPCount - invalidEarlyPurchaseIndexes.length);

        uint256 normalizedIdx;
        for (uint256 i; i < rawEPCount; i++) {
            if (isInvalidEarlyPurchase(i)) {
                continue;   // invalid early purchase should be ignored
            }

            StarbaseEarlyPurchase.EarlyPurchase memory ep;
            if (isAmendedEarlyPurchase(i)) {
                ep = amendedEarlyPurchases[i];  // amended early purchase should take a priority
            } else {
                ep = getEarlyPurchase(i);
            }

            normalizedEP[normalizedIdx] = ep;
            normalizedIdx++;
        }
    }

    /**
     * @dev Fetches early purchases data
     */
    function getEarlyPurchase(uint256 earlyPurchaseIndex)
        internal
        constant
        onlyEarlyPurchasesLoaded
        returns (StarbaseEarlyPurchase.EarlyPurchase)
    {
        var (purchaser, amount, purchasedAt) =
            starbaseEarlyPurchase.earlyPurchases(earlyPurchaseIndex);
        return StarbaseEarlyPurchase.EarlyPurchase(purchaser, amount, purchasedAt);
    }

    /**
     * @dev Returns raw number of early purchases
     */
    function numberOfRawEarlyPurchases()
        internal
        constant
        onlyEarlyPurchasesLoaded
        returns (uint256)
    {
        return starbaseEarlyPurchase.numberOfEarlyPurchases();
    }
}


contract Certifier {
	event Confirmed(address indexed who);
	event Revoked(address indexed who);
	function certified(address) public constant returns (bool);
	function get(address, string) public constant returns (bytes32);
	function getAddress(address, string) public constant returns (address);
	function getUint(address, string) public constant returns (uint);
}

/**
 * @title Crowdsale contract - Starbase crowdsale to create STAR.
 * @author Starbase PTE. LTD. - <info@starbase.co>
 */
contract StarbaseCrowdsale is Ownable {
    using SafeMath for uint256;
    /*
     *  Events
     */
    event CrowdsaleEnded(uint256 endedAt);
    event StarbasePurchasedWithEth(address purchaser, uint256 amount, uint256 rawAmount, uint256 cnyEthRate);
    event CnyEthRateUpdated(uint256 cnyEthRate);
    event CnyBtcRateUpdated(uint256 cnyBtcRate);
    event QualifiedPartnerAddress(address qualifiedPartner);

    /**
     *  External contracts
     */
    AbstractStarbaseToken public starbaseToken;
    StarbaseEarlyPurchaseAmendment public starbaseEpAmendment;
    Certifier public picopsCertifier;

    /**
     *  Constants
     */
    uint256 constant public crowdsaleTokenAmount = 125000000e18;
    uint256 constant public earlyPurchaseTokenAmount = 50000000e18;
    uint256 constant public MIN_INVESTMENT = 1; // min is 1 Wei
    uint256 constant public MAX_CAP = 67000000; // in CNY. approximately 10M USD. (includes raised amount from both EP and CS)
    string public constant PURCHASE_AMOUNT_UNIT = 'CNY';  // Chinese Yuan

    /**
     * Types
     */
    struct CrowdsalePurchase {
        address purchaser;
        uint256 amount;        // CNY based amount with bonus
        uint256 rawAmount;     // CNY based amount no bonus
        uint256 purchasedAt;   // timestamp
    }

    struct QualifiedPartners {
        uint256 amountCap;
        uint256 amountRaised;
        bool    bonaFide;
        uint256 commissionFeePercentage; // example 5 will calculate the percentage as 5%
    }

    /*
     *  Enums
     */
    enum BonusMilestones {
        First,
        Second,
        Third,
        Fourth,
        Fifth
    }

    // Initialize bonusMilestones
    BonusMilestones public bonusMilestones = BonusMilestones.First;

    /**
     *  Storage
     */
    uint public numOfDeliveredCrowdsalePurchases;  // index to keep the number of crowdsale purchases have already been processed by `withdrawPurchasedTokens`
    uint public numOfDeliveredEarlyPurchases;  // index to keep the number of early purchases have already been processed by `withdrawPurchasedTokens`
    uint256 public numOfLoadedEarlyPurchases; // index to keep the number of early purchases that have already been loaded by `loadEarlyPurchases`

    // early purchase
    address[] public earlyPurchasers;
    mapping (address => uint256) public earlyPurchasedAmountBy; // early purchased amount in CNY per purchasers' address
    bool public earlyPurchasesLoaded = false;  // returns whether all early purchases are loaded into this contract
    uint256 public totalAmountOfEarlyPurchases; // including 20% bonus

    // crowdsale
    bool public presalePurchasesLoaded = false; // returns whether all presale purchases are loaded into this contract
    uint256 public maxCrowdsaleCap;     // = 67M CNY - (total raised amount from EP)
    uint256 public totalAmountOfCrowdsalePurchases; // in CNY, including bonuses
    uint256 public totalAmountOfCrowdsalePurchasesWithoutBonus; // in CNY
    mapping (address => QualifiedPartners) public qualifiedPartners;
    uint256 public purchaseStartBlock;  // crowdsale purchases can be accepted from this block number
    uint256 public startDate;
    uint256 public endedAt;
    CrowdsalePurchase[] public crowdsalePurchases;
    mapping (address => uint256) public crowdsalePurchaseAmountBy; // crowdsale purchase amount in CNY per purchasers' address
    uint256 public cnyBtcRate; // this rate won't be used from a smart contract function but external system
    uint256 public cnyEthRate;

    // bonus milestones
    uint256 public firstBonusEnds;
    uint256 public secondBonusEnds;
    uint256 public thirdBonusEnds;
    uint256 public fourthBonusEnds;

    // after the crowdsale
    mapping (address => uint256) public numOfPurchasedTokensOnCsBy;    // the number of tokens purchased on the crowdsale by a purchaser
    mapping (address => uint256) public numOfPurchasedTokensOnEpBy;    // the number of tokens early purchased by a purchaser

    /**
     *  Modifiers
     */
    modifier minInvestment() {
        // User has to send at least the ether value of one token.
        assert(msg.value >= MIN_INVESTMENT);
        _;
    }

    modifier whenNotStarted() {
        assert(startDate == 0);
        _;
    }

    modifier whenEnded() {
        assert(isEnded());
        _;
    }

    modifier hasBalance() {
        assert(this.balance > 0);
        _;
    }
    modifier rateIsSet(uint256 _rate) {
        assert(_rate != 0);
        _;
    }

    modifier whenNotEnded() {
        assert(!isEnded());
        _;
    }

    modifier tokensNotDelivered() {
        assert(numOfDeliveredCrowdsalePurchases == 0);
        assert(numOfDeliveredEarlyPurchases == 0);
        _;
    }

    modifier onlyFundraiser() {
        assert(address(starbaseToken) != 0);
        assert(starbaseToken.isFundraiser(msg.sender));
        _;
    }

    modifier onlyQualifiedPartner() {
        assert(qualifiedPartners[msg.sender].bonaFide);
        _;
    }

    modifier onlyQualifiedPartnerORPicopsCertified() {
        assert(qualifiedPartners[msg.sender].bonaFide || picopsCertifier.certified(msg.sender));
        _;
    }

    /**
     * Contract functions
     */
    /**
     * @dev Contract constructor function sets owner address and
     *      address of StarbaseEarlyPurchaseAmendment contract.
     * @param starbaseEpAddr The address that holds the early purchasers Star tokens
     * @param picopsCertifierAddr The address of the PICOPS certifier.
     *                            See also https://picops.parity.io/#/details
     */
    function StarbaseCrowdsale(address starbaseEpAddr, address picopsCertifierAddr) {
        require(starbaseEpAddr != 0 && picopsCertifierAddr != 0);
        owner = msg.sender;
        starbaseEpAmendment = StarbaseEarlyPurchaseAmendment(starbaseEpAddr);
        picopsCertifier = Certifier(picopsCertifierAddr);
    }

    /**
     * @dev Fallback accepts payment for Star tokens with Eth
     */
    function() payable {
        redirectToPurchase();
    }

    /**
     * External functions
     */

    /**
     * @dev Setup function sets external contracts' addresses and set the max crowdsale cap
     * @param starbaseTokenAddress Token address.
     * @param _purchaseStartBlock Block number to start crowdsale
     */
    function setup(address starbaseTokenAddress, uint256 _purchaseStartBlock)
        external
        onlyOwner
        returns (bool)
    {
        require(starbaseTokenAddress != address(0));
        require(address(starbaseToken) == 0);
        starbaseToken = AbstractStarbaseToken(starbaseTokenAddress);
        purchaseStartBlock = _purchaseStartBlock;

        // set the max cap of this crowdsale
        maxCrowdsaleCap = MAX_CAP.sub(totalAmountOfEarlyPurchasesWithoutBonus());

        assert(maxCrowdsaleCap > 0);

        return true;
    }

    /**
     * @dev Transfers raised funds to company's wallet address at any given time.
     */
    function withdrawForCompany()
        external
        onlyFundraiser
        hasBalance
    {
        address company = starbaseToken.company();
        require(company != address(0));
        company.transfer(this.balance);
    }

    /**
     * @dev Update start block Number for the crowdsale
     */
    function updatePurchaseStartBlock(uint256 _purchaseStartBlock)
        external
        whenNotStarted
        onlyFundraiser
        returns (bool)
    {
        purchaseStartBlock = _purchaseStartBlock;
        return true;
    }

    /**
     * @dev Update the CNY/ETH rate to record purchases in CNY
     */
    function updateCnyEthRate(uint256 rate)
        external
        onlyFundraiser
        returns (bool)
    {
        cnyEthRate = rate;
        CnyEthRateUpdated(cnyEthRate);
        return true;
    }

    /**
     * @dev Update the CNY/BTC rate to record purchases in CNY
     */
    function updateCnyBtcRate(uint256 rate)
        external
        onlyFundraiser
        returns (bool)
    {
        cnyBtcRate = rate;
        CnyBtcRateUpdated(cnyBtcRate);
        return true;
    }

    /**
     * @dev Allow for the possibility for contract owner to start crowdsale
     */
    function ownerStartsCrowdsale(uint256 timestamp)
        external
        whenNotStarted
        onlyOwner
    {
        assert(block.number >= purchaseStartBlock);   // this should be after the crowdsale start block
        startCrowdsale(timestamp);
    }

    /**
     * @dev Ends crowdsale
     *      This may be executed by an owner if the raised funds did not reach the map cap
     * @param timestamp Timestamp at the crowdsale ended
     */
    function endCrowdsale(uint256 timestamp)
        external
        onlyOwner
    {
        assert(timestamp > 0 && timestamp <= now);
        assert(block.number >= purchaseStartBlock && endedAt == 0);   // cannot end before it starts and overwriting time is not permitted
        endedAt = timestamp;
        CrowdsaleEnded(endedAt);
    }

    /**
     * @dev Ends crowdsale
     *      This may be executed by purchaseWithEth when the raised funds reach the map cap
     */
    function endCrowdsale() internal {
        assert(block.number >= purchaseStartBlock && endedAt == 0);
        endedAt = now;
        CrowdsaleEnded(endedAt);
    }

    /**
     * @dev Deliver tokens to purchasers according to their purchase amount in CNY
     */
    function withdrawPurchasedTokens()
        external
        whenEnded
        returns (bool)
    {
        assert(earlyPurchasesLoaded);
        assert(address(starbaseToken) != 0);

        /*
         * “Value” refers to the contribution of the User:
         *  {crowdsale_purchaser_token_amount} =
         *  {crowdsale_token_amount} * {crowdsalePurchase_value} / {earlypurchase_value} + {crowdsale_value}.
         *
         * Example: If a User contributes during the Contribution Period 100 CNY (including applicable
         * Bonus, if any) and the total amount early purchases amounts to 6’000’000 CNY
         * and total amount raised during the Contribution Period is 30’000’000, then he will get
         * 347.22 STAR = 125’000’000 STAR * 100 CNY / 30’000’000 CNY + 6’000’000 CNY.
        */

        if (crowdsalePurchaseAmountBy[msg.sender] > 0) {
            uint256 crowdsalePurchaseValue = crowdsalePurchaseAmountBy[msg.sender];
            crowdsalePurchaseAmountBy[msg.sender] = 0;

            uint256 tokenCount =
                SafeMath.mul(crowdsaleTokenAmount, crowdsalePurchaseValue) /
                totalRaisedAmountInCny();

            numOfPurchasedTokensOnCsBy[msg.sender] =
                SafeMath.add(numOfPurchasedTokensOnCsBy[msg.sender], tokenCount);
            assert(starbaseToken.allocateToCrowdsalePurchaser(msg.sender, tokenCount));
            numOfDeliveredCrowdsalePurchases++;
        }

        /*
         * “Value” refers to the contribution of the User:
         * {earlypurchaser_token_amount} =
         * {earlypurchaser_token_amount} * ({earlypurchase_value} / {total_earlypurchase_value})
         *  + {crowdsale_token_amount} * ({earlypurchase_value} / {earlypurchase_value} + {crowdsale_value}).
         *
         * Example: If an Early Purchaser contributes 100 CNY (including Bonus of 20%) and the
         * total amount of early purchases amounts to 6’000’000 CNY and the total amount raised
         * during the Contribution Period is 30’000’000 CNY, then he will get 1180.55 STAR =
         * 50’000’000 STAR * 100 CNY / 6’000’000 CNY + 125’000’000 STAR * 100 CNY /
         * 30’000’000 CNY + 6’000’000 CNY
         */

        if (earlyPurchasedAmountBy[msg.sender] > 0) {  // skip if is not an early purchaser
            uint256 earlyPurchaserPurchaseValue = earlyPurchasedAmountBy[msg.sender];
            earlyPurchasedAmountBy[msg.sender] = 0;

            uint256 epTokenCalculationFromEPTokenAmount = SafeMath.mul(earlyPurchaseTokenAmount, earlyPurchaserPurchaseValue) / totalAmountOfEarlyPurchases;

            uint256 epTokenCalculationFromCrowdsaleTokenAmount = SafeMath.mul(crowdsaleTokenAmount, earlyPurchaserPurchaseValue) / totalRaisedAmountInCny();

            uint256 epTokenCount = SafeMath.add(epTokenCalculationFromEPTokenAmount, epTokenCalculationFromCrowdsaleTokenAmount);

            numOfPurchasedTokensOnEpBy[msg.sender] = SafeMath.add(numOfPurchasedTokensOnEpBy[msg.sender], epTokenCount);
            assert(starbaseToken.allocateToCrowdsalePurchaser(msg.sender, epTokenCount));
            numOfDeliveredEarlyPurchases++;
        }

        return true;
    }

    /**
     * @dev Load early purchases from the contract keeps track of them
     */
    function loadEarlyPurchases() external onlyOwner returns (bool) {
        if (earlyPurchasesLoaded) {
            return false;    // all EPs have already been loaded
        }

        uint256 numOfOrigEp = starbaseEpAmendment
            .starbaseEarlyPurchase()
            .numberOfEarlyPurchases();

        for (uint256 i = numOfLoadedEarlyPurchases; i < numOfOrigEp && msg.gas > 200000; i++) {
            if (starbaseEpAmendment.isInvalidEarlyPurchase(i)) {
                numOfLoadedEarlyPurchases = SafeMath.add(numOfLoadedEarlyPurchases, 1);
                continue;
            }
            var (purchaser, amount,) =
                starbaseEpAmendment.isAmendedEarlyPurchase(i)
                ? starbaseEpAmendment.amendedEarlyPurchases(i)
                : starbaseEpAmendment.earlyPurchases(i);
            if (amount > 0) {
                if (earlyPurchasedAmountBy[purchaser] == 0) {
                    earlyPurchasers.push(purchaser);
                }
                // each early purchaser receives 20% bonus
                uint256 bonus = SafeMath.mul(amount, 20) / 100;
                uint256 amountWithBonus = SafeMath.add(amount, bonus);

                earlyPurchasedAmountBy[purchaser] = SafeMath.add(earlyPurchasedAmountBy[purchaser], amountWithBonus);
                totalAmountOfEarlyPurchases = totalAmountOfEarlyPurchases.add(amountWithBonus);
            }

            numOfLoadedEarlyPurchases = SafeMath.add(numOfLoadedEarlyPurchases, 1);
        }

        assert(numOfLoadedEarlyPurchases <= numOfOrigEp);
        if (numOfLoadedEarlyPurchases == numOfOrigEp) {
            earlyPurchasesLoaded = true;    // enable the flag
        }
        return true;
    }

    /**
     * @dev Load presale purchases from the contract keeps track of them
     * @param starbaseCrowdsalePresale Starbase presale contract address
     */
    function loadPresalePurchases(address starbaseCrowdsalePresale)
        external
        onlyOwner
        whenNotEnded
    {
        require(starbaseCrowdsalePresale != 0);
        require(!presalePurchasesLoaded);
        StarbaseCrowdsale presale = StarbaseCrowdsale(starbaseCrowdsalePresale);
        for (uint i; i < presale.numOfPurchases(); i++) {
            var (purchaser, amount, rawAmount, purchasedAt) =
                presale.crowdsalePurchases(i);  // presale purchase
            crowdsalePurchases.push(CrowdsalePurchase(purchaser, amount, rawAmount, purchasedAt));

            // Increase the sums
            crowdsalePurchaseAmountBy[purchaser] = SafeMath.add(crowdsalePurchaseAmountBy[purchaser], amount);
            totalAmountOfCrowdsalePurchases = totalAmountOfCrowdsalePurchases.add(amount);
            totalAmountOfCrowdsalePurchasesWithoutBonus = totalAmountOfCrowdsalePurchasesWithoutBonus.add(rawAmount);
        }
        presalePurchasesLoaded = true;
    }

    /**
      * @dev Set qualified crowdsale partner i.e. Bitcoin Suisse address
      * @param _qualifiedPartner Address of the qualified partner that can purchase during crowdsale
      * @param _amountCap Ether value which partner is able to contribute
      * @param _commissionFeePercentage Integer that represents the fee to pay qualified partner 5 is 5%
      */
    function setQualifiedPartner(address _qualifiedPartner, uint256 _amountCap, uint256 _commissionFeePercentage)
        external
        onlyOwner
    {
        assert(!qualifiedPartners[_qualifiedPartner].bonaFide);
        qualifiedPartners[_qualifiedPartner].bonaFide = true;
        qualifiedPartners[_qualifiedPartner].amountCap = _amountCap;
        qualifiedPartners[_qualifiedPartner].commissionFeePercentage = _commissionFeePercentage;
        QualifiedPartnerAddress(_qualifiedPartner);
    }

    /**
     * @dev Remove address from qualified partners list.
     * @param _qualifiedPartner Address to be removed from the list.
     */
    function unlistQualifiedPartner(address _qualifiedPartner) external onlyOwner {
        assert(qualifiedPartners[_qualifiedPartner].bonaFide);
        qualifiedPartners[_qualifiedPartner].bonaFide = false;
    }

    /**
     * @dev Update whitelisted address amount allowed to raise during the presale.
     * @param _qualifiedPartner Qualified Partner address to be updated.
     * @param _amountCap Amount that the address is able to raise during the presale.
     */
    function updateQualifiedPartnerCapAmount(address _qualifiedPartner, uint256 _amountCap) external onlyOwner {
        assert(qualifiedPartners[_qualifiedPartner].bonaFide);
        qualifiedPartners[_qualifiedPartner].amountCap = _amountCap;
    }

    /**
     * Public functions
     */

    /**
     * @dev Returns boolean for whether crowdsale has ended
     */
    function isEnded() constant public returns (bool) {
        return (endedAt > 0 && endedAt <= now);
    }

    /**
     * @dev Returns number of purchases to date.
     */
    function numOfPurchases() constant public returns (uint256) {
        return crowdsalePurchases.length;
    }

    /**
     * @dev Returns total raised amount in CNY (includes EP) and bonuses
     */
    function totalRaisedAmountInCny() constant public returns (uint256) {
        return totalAmountOfEarlyPurchases.add(totalAmountOfCrowdsalePurchases);
    }

    /**
     * @dev Returns total amount of early purchases in CNY and bonuses
     */
    function totalAmountOfEarlyPurchasesWithBonus() constant public returns(uint256) {
       return starbaseEpAmendment.totalAmountOfEarlyPurchases().mul(120).div(100);
    }

    /**
     * @dev Returns total amount of early purchases in CNY
     */
    function totalAmountOfEarlyPurchasesWithoutBonus() constant public returns(uint256) {
       return starbaseEpAmendment.totalAmountOfEarlyPurchases();
    }

    /**
     * @dev Allows qualified crowdsale partner to purchase Star Tokens
     */
    function purchaseAsQualifiedPartner()
        payable
        public
        rateIsSet(cnyEthRate)
        onlyQualifiedPartner
        returns (bool)
    {
        require(msg.value > 0);
        qualifiedPartners[msg.sender].amountRaised = SafeMath.add(msg.value, qualifiedPartners[msg.sender].amountRaised);

        assert(qualifiedPartners[msg.sender].amountRaised <= qualifiedPartners[msg.sender].amountCap);

        uint256 rawAmount = SafeMath.mul(msg.value, cnyEthRate) / 1e18;
        recordPurchase(msg.sender, rawAmount, now);

        if (qualifiedPartners[msg.sender].commissionFeePercentage > 0) {
            sendQualifiedPartnerCommissionFee(msg.sender, msg.value);
        }

        return true;
    }

    /**
     * @dev Allows user to purchase STAR tokens with Ether
     */
    function purchaseWithEth()
        payable
        public
        minInvestment
        whenNotEnded
        rateIsSet(cnyEthRate)
        onlyQualifiedPartnerORPicopsCertified
        returns (bool)
    {
        require(purchaseStartBlock > 0 && block.number >= purchaseStartBlock);

        if (startDate == 0) {
            startCrowdsale(block.timestamp);
        }

        uint256 rawAmount = SafeMath.mul(msg.value, cnyEthRate) / 1e18;
        recordPurchase(msg.sender, rawAmount, now);

        if (totalAmountOfCrowdsalePurchasesWithoutBonus >= maxCrowdsaleCap) {
            endCrowdsale(); // ends this crowdsale automatically
        }

        return true;
    }

    /**
     * Internal functions
     */

    /**
     * @dev Initializes Starbase crowdsale
     */
    function startCrowdsale(uint256 timestamp) internal {
        startDate = timestamp;
        uint256 presaleAmount = totalAmountOfCrowdsalePurchasesWithoutBonus;
        if (maxCrowdsaleCap > presaleAmount) {
            uint256 mainSaleCap = maxCrowdsaleCap.sub(presaleAmount);
            uint256 twentyPercentOfCrowdsalePurchase = mainSaleCap.mul(20).div(100);

            // set token bonus milestones in cny total crowdsale purchase
            firstBonusEnds =  twentyPercentOfCrowdsalePurchase;
            secondBonusEnds = firstBonusEnds.add(twentyPercentOfCrowdsalePurchase);
            thirdBonusEnds =  secondBonusEnds.add(twentyPercentOfCrowdsalePurchase);
            fourthBonusEnds = thirdBonusEnds.add(twentyPercentOfCrowdsalePurchase);
        }
    }

    /**
     * @dev Abstract record of a purchase to Tokens
     * @param purchaser Address of the buyer
     * @param rawAmount Amount in CNY as per the CNY/ETH rate used
     * @param timestamp Timestamp at the purchase made
     */
    function recordPurchase(
        address purchaser,
        uint256 rawAmount,
        uint256 timestamp
    )
        internal
        returns(uint256 amount)
    {
        amount = rawAmount; // amount to check reach of max cap. it does not care for bonus tokens here

        // presale transfers which occurs before the crowdsale ignores the crowdsale hard cap
        if (block.number >= purchaseStartBlock) {
            require(totalAmountOfCrowdsalePurchasesWithoutBonus < maxCrowdsaleCap);   // check if the amount has already reached the cap

            uint256 crowdsaleTotalAmountAfterPurchase =
                SafeMath.add(totalAmountOfCrowdsalePurchasesWithoutBonus, amount);

            // check whether purchase goes over the cap and send the difference back to the purchaser.
            if (crowdsaleTotalAmountAfterPurchase > maxCrowdsaleCap) {
              uint256 difference = SafeMath.sub(crowdsaleTotalAmountAfterPurchase, maxCrowdsaleCap);
              uint256 ethValueToReturn = SafeMath.mul(difference, 1e18) / cnyEthRate;
              purchaser.transfer(ethValueToReturn);
              amount = SafeMath.sub(amount, difference);
              rawAmount = amount;
            }
        }

        amount = getBonusAmountCalculation(amount); // at this point amount bonus is calculated

        CrowdsalePurchase memory purchase = CrowdsalePurchase(purchaser, amount, rawAmount, timestamp);
        crowdsalePurchases.push(purchase);
        StarbasePurchasedWithEth(msg.sender, amount, rawAmount, cnyEthRate);
        crowdsalePurchaseAmountBy[purchaser] = SafeMath.add(crowdsalePurchaseAmountBy[purchaser], amount);
        totalAmountOfCrowdsalePurchases = totalAmountOfCrowdsalePurchases.add(amount);
        totalAmountOfCrowdsalePurchasesWithoutBonus = totalAmountOfCrowdsalePurchasesWithoutBonus.add(rawAmount);
        return amount;
    }

    /**
     * @dev Calculates amount with bonus for bonus milestones
     */
    function calculateBonus
        (
            BonusMilestones nextMilestone,
            uint256 amount,
            uint256 bonusRange,
            uint256 bonusTier,
            uint256 results
        )
        internal
        returns (uint256 result, uint256 newAmount)
    {
        uint256 bonusCalc;

        if (amount <= bonusRange) {
            bonusCalc = amount.mul(bonusTier).div(100);

            if (amount.add(totalAmountOfCrowdsalePurchasesWithoutBonus) >= bonusRange)
                bonusMilestones = nextMilestone;

            result = results.add(amount).add(bonusCalc);
            newAmount = 0;

        } else {
            bonusCalc = bonusRange.mul(bonusTier).div(100);
            bonusMilestones = nextMilestone;
            result = results.add(bonusRange).add(bonusCalc);
            newAmount = amount.sub(bonusRange);
        }
    }

    /**
     * @dev Fetchs Bonus tier percentage per bonus milestones
     */
    function getBonusAmountCalculation(uint256 amount) internal returns (uint256) {
        if (block.number < purchaseStartBlock) {
            uint256 bonusFromAmount = amount.mul(30).div(100); // presale has 30% bonus
            return amount.add(bonusFromAmount);
        }

        // range of each bonus milestones
        uint256 firstBonusRange = firstBonusEnds;
        uint256 secondBonusRange = secondBonusEnds.sub(firstBonusEnds);
        uint256 thirdBonusRange = thirdBonusEnds.sub(secondBonusEnds);
        uint256 fourthBonusRange = fourthBonusEnds.sub(thirdBonusEnds);
        uint256 result;

        if (bonusMilestones == BonusMilestones.First)
            (result, amount) = calculateBonus(BonusMilestones.Second, amount, firstBonusRange, 20, result);

        if (bonusMilestones == BonusMilestones.Second)
            (result, amount) = calculateBonus(BonusMilestones.Third, amount, secondBonusRange, 15, result);

        if (bonusMilestones == BonusMilestones.Third)
            (result, amount) = calculateBonus(BonusMilestones.Fourth, amount, thirdBonusRange, 10, result);

        if (bonusMilestones == BonusMilestones.Fourth)
            (result, amount) = calculateBonus(BonusMilestones.Fifth, amount, fourthBonusRange, 5, result);

        return result.add(amount);
    }

    /**
     * @dev Fetchs Bonus tier percentage per bonus milestones
     * @dev qualifiedPartner Address of partners that participated in pre sale
     * @dev amountSent Value sent by qualified partner
     */
    function sendQualifiedPartnerCommissionFee(address qualifiedPartner, uint256 amountSent) internal {
        //calculate the commission fee to send to qualified partner
        uint256 commissionFeePercentageCalculationAmount = SafeMath.mul(amountSent, qualifiedPartners[qualifiedPartner].commissionFeePercentage) / 100;

        // send commission fee amount
        qualifiedPartner.transfer(commissionFeePercentageCalculationAmount);
    }

    /**
     * @dev redirectToPurchase Redirect to adequate purchase function within the smart contract
     */
    function redirectToPurchase() internal {
        if (block.number < purchaseStartBlock) {
            purchaseAsQualifiedPartner();
        } else {
            purchaseWithEth();
        }
    }
}

/**
 * @title Starbase Crowdsale Contract Withdrawal contract - Provides an function
          to withdraw STAR token according to crowdsale results
 * @author Starbase PTE. LTD. - <info@starbase.co>
 */
contract StarbaseCrowdsaleContractW is Ownable {
    using SafeMath for uint256;

    /*
     *  Events
     */
    event TokenWithdrawn(address purchaser, uint256 tokenCount);
    event CrowdsalePurchaseBonusLog(
        uint256 purchaseIdx, uint256 rawAmount, uint256 bonus);

    /**
     *  External contracts
     */
    AbstractStarbaseToken public starbaseToken;
    StarbaseCrowdsale public starbaseCrowdsale;
    StarbaseEarlyPurchaseAmendment public starbaseEpAmendment;

    /**
     *  Constants
     */
    uint256 constant public crowdsaleTokenAmount = 125000000e18;
    uint256 constant public earlyPurchaseTokenAmount = 50000000e18;

    /**
     *  Storage
     */

    // early purchase
    address[] public earlyPurchasers;
    mapping (address => uint256) public earlyPurchasedAmountBy; // early purchased amount in CNY per purchasers' address
    bool public earlyPurchasesLoaded = false;  // returns whether all early purchases are loaded into this contract
    uint256 public totalAmountOfEarlyPurchases; // including bonus
    uint public numOfDeliveredEarlyPurchases;  // index to keep the number of early purchases have already been processed by `withdrawPurchasedTokens`
    uint256 public numOfLoadedEarlyPurchases; // index to keep the number of early purchases that have already been loaded by `loadEarlyPurchases`

    // crowdsale
    uint256 public totalAmountOfCrowdsalePurchases; // in CNY, including bonuses
    uint256 public totalAmountOfCrowdsalePurchasesWithoutBonus; // in CNY
    uint256 public startDate;
    uint256 public endedAt;
    mapping (address => uint256) public crowdsalePurchaseAmountBy; // crowdsale purchase amount in CNY per purchasers' address
    uint public numOfDeliveredCrowdsalePurchases;  // index to keep the number of crowdsale purchases have already been processed by `withdrawPurchasedTokens`

    // crowdsale contract withdrawal
    bool public crowdsalePurchasesLoaded = false;   // returns whether all crowdsale purchases are loaded into this contract
    uint256 public numOfLoadedCrowdsalePurchases; // index to keep the number of crowdsale purchases that have already been loaded by `loadCrowdsalePurchases`
    uint256 public totalAmountOfPresalePurchasesWithoutBonus;  // in CNY

    // after the crowdsale
    mapping (address => bool) public tokenWithdrawn;    // returns whether purchased tokens were withdrawn by a purchaser
    mapping (address => uint256) public numOfPurchasedTokensOnCsBy;    // the number of tokens purchased on the crowdsale by a purchaser
    mapping (address => uint256) public numOfPurchasedTokensOnEpBy;    // the number of tokens early purchased by a purchaser

    /**
     *  Modifiers
     */
    modifier whenEnded() {
        assert(isEnded());
        _;
    }

    /**
     * Contract functions
     */

    /**
     * @dev Reject all incoming Ether transfers
     */
    function () { revert(); }

    /**
     * External functions
     */

    /**
     * @dev Setup function sets external contracts' address
     * @param starbaseTokenAddress Token address.
     * @param StarbaseCrowdsaleAddress Token address.
     */
    function setup(address starbaseTokenAddress, address StarbaseCrowdsaleAddress)
        external
        onlyOwner
    {
        require(starbaseTokenAddress != address(0) && StarbaseCrowdsaleAddress != address(0));
        require(address(starbaseToken) == 0 && address(starbaseCrowdsale) == 0);

        starbaseToken = AbstractStarbaseToken(starbaseTokenAddress);
        starbaseCrowdsale = StarbaseCrowdsale(StarbaseCrowdsaleAddress);
        starbaseEpAmendment = StarbaseEarlyPurchaseAmendment(starbaseCrowdsale.starbaseEpAmendment());

        require(starbaseCrowdsale.startDate() > 0);
        startDate = starbaseCrowdsale.startDate();

        require(starbaseCrowdsale.endedAt() > 0);
        endedAt = starbaseCrowdsale.endedAt();
    }

    /**
     * @dev Load crowdsale purchases from the contract keeps track of them
     * @param numOfPresalePurchases Number of presale purchase
     */
    function loadCrowdsalePurchases(uint256 numOfPresalePurchases)
        external
        onlyOwner
        whenEnded
    {
        require(!crowdsalePurchasesLoaded);

        uint256 numOfPurchases = starbaseCrowdsale.numOfPurchases();

        for (uint256 i = numOfLoadedCrowdsalePurchases; i < numOfPurchases && msg.gas > 200000; i++) {
            var (purchaser, amount, rawAmount,) =
                starbaseCrowdsale.crowdsalePurchases(i);

            uint256 bonus;
            if (i < numOfPresalePurchases) {
                bonus = rawAmount * 30 / 100;   // presale: 30% bonus
                totalAmountOfPresalePurchasesWithoutBonus =
                    totalAmountOfPresalePurchasesWithoutBonus.add(rawAmount);
            } else {
                bonus = calculateBonus(rawAmount); // mainsale: 20% ~ 0% bonus
            }

            // Update amount with bonus
            CrowdsalePurchaseBonusLog(i, rawAmount, bonus);
            amount = rawAmount + bonus;

            // Increase the sums
            crowdsalePurchaseAmountBy[purchaser] = SafeMath.add(crowdsalePurchaseAmountBy[purchaser], amount);
            totalAmountOfCrowdsalePurchases = totalAmountOfCrowdsalePurchases.add(amount);
            totalAmountOfCrowdsalePurchasesWithoutBonus = totalAmountOfCrowdsalePurchasesWithoutBonus.add(rawAmount);

            numOfLoadedCrowdsalePurchases++;    // Increase the index
        }

        assert(numOfLoadedCrowdsalePurchases <= numOfPurchases);
        if (numOfLoadedCrowdsalePurchases == numOfPurchases) {
            crowdsalePurchasesLoaded = true;    // enable the flag
        }
    }

    /**
     * @dev Add early purchases
     */
    function addEarlyPurchases() external onlyOwner returns (bool) {
        if (earlyPurchasesLoaded) {
            return false;    // all EPs have already been loaded
        }

        uint256 numOfOrigEp = starbaseEpAmendment
            .starbaseEarlyPurchase()
            .numberOfEarlyPurchases();

        for (uint256 i = numOfLoadedEarlyPurchases; i < numOfOrigEp && msg.gas > 200000; i++) {
            if (starbaseEpAmendment.isInvalidEarlyPurchase(i)) {
                numOfLoadedEarlyPurchases = SafeMath.add(numOfLoadedEarlyPurchases, 1);
                continue;
            }
            var (purchaser, amount,) =
                starbaseEpAmendment.isAmendedEarlyPurchase(i)
                ? starbaseEpAmendment.amendedEarlyPurchases(i)
                : starbaseEpAmendment.earlyPurchases(i);
            if (amount > 0) {
                if (earlyPurchasedAmountBy[purchaser] == 0) {
                    earlyPurchasers.push(purchaser);
                }
                // each early purchaser receives 10% bonus
                uint256 bonus = SafeMath.mul(amount, 10) / 100;
                uint256 amountWithBonus = SafeMath.add(amount, bonus);

                earlyPurchasedAmountBy[purchaser] = SafeMath.add(earlyPurchasedAmountBy[purchaser], amountWithBonus);
                totalAmountOfEarlyPurchases = totalAmountOfEarlyPurchases.add(amountWithBonus);
            }

            numOfLoadedEarlyPurchases = SafeMath.add(numOfLoadedEarlyPurchases, 1);
        }

        assert(numOfLoadedEarlyPurchases <= numOfOrigEp);
        if (numOfLoadedEarlyPurchases == numOfOrigEp) {
            earlyPurchasesLoaded = true;    // enable the flag
        }

        return true;
    }

    /**
     * @dev Deliver tokens to purchasers according to their purchase amount in CNY
     */
    function withdrawPurchasedTokens()
        external
        whenEnded
    {
        require(crowdsalePurchasesLoaded);
        assert(earlyPurchasesLoaded);
        assert(address(starbaseToken) != 0);

        // prevent double withdrawal
        require(!tokenWithdrawn[msg.sender]);
        tokenWithdrawn[msg.sender] = true;

        /*
         * “Value” refers to the contribution of the User:
         *  {crowdsale_purchaser_token_amount} =
         *  {crowdsale_token_amount} * {crowdsalePurchase_value} / {earlypurchase_value} + {crowdsale_value}.
         *
         * Example: If a User contributes during the Contribution Period 100 CNY (including applicable
         * Bonus, if any) and the total amount early purchases amounts to 6’000’000 CNY
         * and total amount raised during the Contribution Period is 30’000’000, then he will get
         * 347.22 STAR = 125’000’000 STAR * 100 CNY / 30’000’000 CNY + 6’000’000 CNY.
        */

        if (crowdsalePurchaseAmountBy[msg.sender] > 0) {
            uint256 crowdsalePurchaseValue = crowdsalePurchaseAmountBy[msg.sender];
            uint256 tokenCount =
                SafeMath.mul(crowdsaleTokenAmount, crowdsalePurchaseValue) /
                totalRaisedAmountInCny();

            numOfPurchasedTokensOnCsBy[msg.sender] =
                SafeMath.add(numOfPurchasedTokensOnCsBy[msg.sender], tokenCount);
            assert(starbaseToken.allocateToCrowdsalePurchaser(msg.sender, tokenCount));
            numOfDeliveredCrowdsalePurchases++;
            TokenWithdrawn(msg.sender, tokenCount);
        }

        /*
         * “Value” refers to the contribution of the User:
         * {earlypurchaser_token_amount} =
         * {earlypurchaser_token_amount} * ({earlypurchase_value} / {total_earlypurchase_value})
         *  + {crowdsale_token_amount} * ({earlypurchase_value} / {earlypurchase_value} + {crowdsale_value}).
         *
         * Example: If an Early Purchaser contributes 100 CNY (including Bonus) and the
         * total amount of early purchases amounts to 6’000’000 CNY and the total amount raised
         * during the Contribution Period is 30’000’000 CNY, then he will get 1180.55 STAR =
         * 50’000’000 STAR * 100 CNY / 6’000’000 CNY + 125’000’000 STAR * 100 CNY /
         * 30’000’000 CNY + 6’000’000 CNY
         */

        if (earlyPurchasedAmountBy[msg.sender] > 0) {  // skip if is not an early purchaser
            uint256 earlyPurchaserPurchaseValue = earlyPurchasedAmountBy[msg.sender];
            uint256 epTokenCalculationFromEPTokenAmount = SafeMath.mul(earlyPurchaseTokenAmount, earlyPurchaserPurchaseValue) / totalAmountOfEarlyPurchases;
            uint256 epTokenCalculationFromCrowdsaleTokenAmount = SafeMath.mul(crowdsaleTokenAmount, earlyPurchaserPurchaseValue) / totalRaisedAmountInCny();
            uint256 epTokenCount = SafeMath.add(epTokenCalculationFromEPTokenAmount, epTokenCalculationFromCrowdsaleTokenAmount);

            numOfPurchasedTokensOnEpBy[msg.sender] = SafeMath.add(numOfPurchasedTokensOnEpBy[msg.sender], epTokenCount);
            assert(starbaseToken.allocateToCrowdsalePurchaser(msg.sender, epTokenCount));
            numOfDeliveredEarlyPurchases++;
            TokenWithdrawn(msg.sender, epTokenCount);
        }
    }

    /**
     * Public functions
     */

    /**
     * @dev Returns boolean for whether crowdsale has ended
     */
    function isEnded() constant public returns (bool) {
        return (starbaseCrowdsale != address(0) && endedAt > 0);
    }

    /**
     * @dev Returns total raised amount in CNY (includes EP) and bonuses
     */
    function totalRaisedAmountInCny() constant public returns (uint256) {
        return totalAmountOfEarlyPurchases.add(totalAmountOfCrowdsalePurchases);
    }

    /**
     * Internal functions
     */

    /**
     * @dev Calculates bonus of a purchase
     */
    function calculateBonus(uint256 rawAmount)
        internal
        returns (uint256 bonus)
    {
        uint256 purchasedAmount =
            totalAmountOfCrowdsalePurchasesWithoutBonus
                .sub(totalAmountOfPresalePurchasesWithoutBonus);
        uint256 e1 = starbaseCrowdsale.firstBonusEnds();
        uint256 e2 = starbaseCrowdsale.secondBonusEnds();
        uint256 e3 = starbaseCrowdsale.thirdBonusEnds();
        uint256 e4 = starbaseCrowdsale.fourthBonusEnds();
        return calculateBonusInRange(purchasedAmount, rawAmount, 0, e1, 20)
            .add(calculateBonusInRange(purchasedAmount, rawAmount, e1, e2, 15))
            .add(calculateBonusInRange(purchasedAmount, rawAmount, e2, e3, 10))
            .add(calculateBonusInRange(purchasedAmount, rawAmount, e3, e4, 5));
    }

    function calculateBonusInRange(
        uint256 purchasedAmount,
        uint256 rawAmount,
        uint256 bonusBegin,
        uint256 bonusEnd,
        uint256 bonusTier
    )
        public
        constant
        returns (uint256 bonus)
    {
        uint256 sum = purchasedAmount + rawAmount;
        if (purchasedAmount > bonusEnd || sum < bonusBegin) {
            return 0;   // out of this range
        }

        uint256 min = purchasedAmount <= bonusBegin ? bonusBegin : purchasedAmount;
        uint256 max = bonusEnd <= sum ? bonusEnd : sum;
        return max.sub(min) * bonusTier / 100;
    }
}