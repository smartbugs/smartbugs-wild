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

contract StarbaseEarlyPurchase {
    /*
     *  Constants
     */
    string public constant PURCHASE_AMOUNT_UNIT = 'CNY';    // Chinese Yuan
    string public constant PURCHASE_AMOUNT_RATE_REFERENCE = 'http://www.xe.com/currencytables/';
    uint public constant PURCHASE_AMOUNT_CAP = 9000000;

    /*
     *  Types
     */
    struct EarlyPurchase {
        address purchaser;
        uint amount;        // CNY based amount
        uint purchasedAt;   // timestamp
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
    uint public earlyPurchaseClosedAt;

    /*
     *  Modifiers
     */
    modifier noEther() {
        if (msg.value > 0) {
            throw;
        }
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

    modifier onlyBeforeCrowdsale() {
        if (address(starbaseCrowdsale) != 0 &&
            starbaseCrowdsale.startDate() > 0)
        {
            throw;
        }
        _;
    }

    modifier onlyEarlyPurchaseTerm() {
        if (earlyPurchaseClosedAt > 0) {
            throw;
        }
        _;
    }

    /*
     *  Contract functions
     */
    /// @dev Returns early purchased amount by purchaser's address
    /// @param purchaser Purchaser address
    function purchasedAmountBy(address purchaser)
        external
        constant
        noEther
        returns (uint amount)
    {
        for (uint i; i < earlyPurchases.length; i++) {
            if (earlyPurchases[i].purchaser == purchaser) {
                amount += earlyPurchases[i].amount;
            }
        }
    }

    /// @dev Returns total amount of raised funds by Early Purchasers
    function totalAmountOfEarlyPurchases()
        constant
        noEther
        returns (uint totalAmount)
    {
        for (uint i; i < earlyPurchases.length; i++) {
            totalAmount += earlyPurchases[i].amount;
        }
    }

    /// @dev Returns number of early purchases
    function numberOfEarlyPurchases()
        external
        constant
        noEther
        returns (uint)
    {
        return earlyPurchases.length;
    }

    /// @dev Append an early purchase log
    /// @param purchaser Purchaser address
    /// @param amount Purchase amount
    /// @param purchasedAt Timestamp of purchased date
    function appendEarlyPurchase(address purchaser, uint amount, uint purchasedAt)
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

        if (purchasedAt == 0 || purchasedAt > now) {
            throw;
        }

        earlyPurchases.push(EarlyPurchase(purchaser, amount, purchasedAt));
        return true;
    }

    /// @dev Close early purchase term
    function closeEarlyPurchase()
        external
        noEther
        onlyOwner
        returns (bool)
    {
        earlyPurchaseClosedAt = now;
    }

    /// @dev Setup function sets external contract's address
    /// @param starbaseCrowdsaleAddress Token address
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

    /// @dev Contract constructor function
    function StarbaseEarlyPurchase() noEther {
        owner = msg.sender;
    }

    /// @dev Fallback function always fails
    function () {
        throw;
    }
}


contract StarbaseEarlyPurchaseAmendment {
    /*
     *  Events
     */
    event EarlyPurchaseInvalidated(uint epIdx);
    event EarlyPurchaseAmended(uint epIdx);

    /*
     *  External contracts
     */
    AbstractStarbaseCrowdsale public starbaseCrowdsale;
    StarbaseEarlyPurchase public starbaseEarlyPurchase;

    /*
     *  Storage
     */
    address public owner;
    uint[] public invalidEarlyPurchaseIndexes;
    uint[] public amendedEarlyPurchaseIndexes;
    mapping (uint => StarbaseEarlyPurchase.EarlyPurchase) public amendedEarlyPurchases;

    /*
     *  Modifiers
     */
    modifier noEther() {
        if (msg.value > 0) {
            throw;
        }
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }

    modifier onlyBeforeCrowdsale() {
        if (address(starbaseCrowdsale) != 0 &&
            starbaseCrowdsale.startDate() > 0)
        {
            throw;
        }
        _;
    }

    modifier onlyEarlyPurchasesLoaded() {
        if (address(starbaseEarlyPurchase) == 0) {
            throw;
        }
        _;
    }

    /*
     *  Contract functions are compatible with original ones
     */
    /// @dev Returns an early purchase record
    /// @param earlyPurchaseIndex Index number of an early purchase
    function earlyPurchases(uint earlyPurchaseIndex)
        external
        constant
        onlyEarlyPurchasesLoaded
        returns (address purchaser, uint amount, uint purchasedAt)
    {
        return starbaseEarlyPurchase.earlyPurchases(earlyPurchaseIndex);
    }

    /// @dev Returns early purchased amount by purchaser's address
    /// @param purchaser Purchaser address
    function purchasedAmountBy(address purchaser)
        external
        constant
        noEther
        returns (uint amount)
    {
        StarbaseEarlyPurchase.EarlyPurchase[] memory normalizedEP =
            normalizedEarlyPurchases();
        for (uint i; i < normalizedEP.length; i++) {
            if (normalizedEP[i].purchaser == purchaser) {
                amount += normalizedEP[i].amount;
            }
        }
    }

    /// @dev Returns total amount of raised funds by Early Purchasers
    function totalAmountOfEarlyPurchases()
        constant
        noEther
        returns (uint totalAmount)
    {
        StarbaseEarlyPurchase.EarlyPurchase[] memory normalizedEP =
            normalizedEarlyPurchases();
        for (uint i; i < normalizedEP.length; i++) {
            totalAmount += normalizedEP[i].amount;
        }
    }

    /// @dev Returns number of early purchases
    function numberOfEarlyPurchases()
        external
        constant
        noEther
        returns (uint)
    {
        return normalizedEarlyPurchases().length;
    }

    /// @dev Setup function sets external contract's address
    /// @param starbaseCrowdsaleAddress Token address
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
     *  Contract functions
     */
    function invalidateEarlyPurchase(uint earlyPurchaseIndex)
        external
        noEther
        onlyOwner
        onlyEarlyPurchasesLoaded
        onlyBeforeCrowdsale
        returns (bool)
    {
        if (numberOfRawEarlyPurchases() <= earlyPurchaseIndex) {
            throw;  // Array Index Out of Bounds Exception
        }

        for (uint i; i < invalidEarlyPurchaseIndexes.length; i++) {
            if (invalidEarlyPurchaseIndexes[i] == earlyPurchaseIndex) {
                throw;  // disallow duplicated invalidation
            }
        }

        invalidEarlyPurchaseIndexes.push(earlyPurchaseIndex);
        EarlyPurchaseInvalidated(earlyPurchaseIndex);
        return true;
    }

    function isInvalidEarlyPurchase(uint earlyPurchaseIndex)
        constant
        noEther
        returns (bool)
    {
        if (numberOfRawEarlyPurchases() <= earlyPurchaseIndex) {
            throw;  // Array Index Out of Bounds Exception
        }

        for (uint i; i < invalidEarlyPurchaseIndexes.length; i++) {
            if (invalidEarlyPurchaseIndexes[i] == earlyPurchaseIndex) {
                return true;
            }
        }
        return false;
    }

    function amendEarlyPurchase(uint earlyPurchaseIndex, address purchaser, uint amount, uint purchasedAt)
        external
        noEther
        onlyOwner
        onlyEarlyPurchasesLoaded
        onlyBeforeCrowdsale
        returns (bool)
    {
        if (purchasedAt == 0 || purchasedAt > now) {
            throw;
        }

        if (numberOfRawEarlyPurchases() <= earlyPurchaseIndex) {
            throw;  // Array Index Out of Bounds Exception
        }

        if (isInvalidEarlyPurchase(earlyPurchaseIndex)) {
            throw;  // Invalid early purchase cannot be amended
        }

        if (!isAmendedEarlyPurchase(earlyPurchaseIndex)) {
            amendedEarlyPurchaseIndexes.push(earlyPurchaseIndex);
        }

        amendedEarlyPurchases[earlyPurchaseIndex] =
            StarbaseEarlyPurchase.EarlyPurchase(purchaser, amount, purchasedAt);
        EarlyPurchaseAmended(earlyPurchaseIndex);
        return true;
    }

    function isAmendedEarlyPurchase(uint earlyPurchaseIndex)
        constant
        noEther
        returns (bool)
    {
        if (numberOfRawEarlyPurchases() <= earlyPurchaseIndex) {
            throw;  // Array Index Out of Bounds Exception
        }

        for (uint i; i < amendedEarlyPurchaseIndexes.length; i++) {
            if (amendedEarlyPurchaseIndexes[i] == earlyPurchaseIndex) {
                return true;
            }
        }
        return false;
    }

    function loadStarbaseEarlyPurchases(address starbaseEarlyPurchaseAddress)
        external
        noEther
        onlyOwner
        onlyBeforeCrowdsale
        returns (bool)
    {
        if (starbaseEarlyPurchaseAddress == 0 ||
            address(starbaseEarlyPurchase) != 0)
        {
            throw;
        }

        starbaseEarlyPurchase = StarbaseEarlyPurchase(starbaseEarlyPurchaseAddress);
        if (starbaseEarlyPurchase.earlyPurchaseClosedAt() == 0) {
            throw;   // the early purchase must be closed
        }
        return true;
    }

    /// @dev Contract constructor function
    function StarbaseEarlyPurchaseAmendment() noEther {
        owner = msg.sender;
    }

    /// @dev Fallback function always fails
    function () {
        throw;
    }

    /**
     * Internal functions
     */
    function normalizedEarlyPurchases()
        constant
        internal
        returns (StarbaseEarlyPurchase.EarlyPurchase[] normalizedEP)
    {
        uint rawEPCount = numberOfRawEarlyPurchases();
        normalizedEP = new StarbaseEarlyPurchase.EarlyPurchase[](
            rawEPCount - invalidEarlyPurchaseIndexes.length);

        uint normalizedIdx;
        for (uint i; i < rawEPCount; i++) {
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

    function getEarlyPurchase(uint earlyPurchaseIndex)
        internal
        constant
        onlyEarlyPurchasesLoaded
        returns (StarbaseEarlyPurchase.EarlyPurchase)
    {
        var (purchaser, amount, purchasedAt) =
            starbaseEarlyPurchase.earlyPurchases(earlyPurchaseIndex);
        return StarbaseEarlyPurchase.EarlyPurchase(purchaser, amount, purchasedAt);
    }

    function numberOfRawEarlyPurchases()
        internal
        constant
        onlyEarlyPurchasesLoaded
        returns (uint)
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
    uint256 public totalAmountOfEarlyPurchasesInCny;

    // crowdsale
    uint256 public maxCrowdsaleCap;     // = 67M CNY - (total raised amount from EP)
    uint256 public totalAmountOfPurchasesInCny; // totalPreSale + totalCrowdsale
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

        totalAmountOfEarlyPurchasesInCny = totalAmountOfEarlyPurchases();

        // set the max cap of this crowdsale
        maxCrowdsaleCap = MAX_CAP.sub(totalAmountOfEarlyPurchasesInCny);

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
        onlyOwner
    {
        assert(startDate == 0 && block.number >= purchaseStartBlock);   // overwriting startDate is not permitted and it should be after the crowdsale start block
        startCrowdsale(timestamp);
    }

    /**
     * @dev Ends crowdsale
     * @param timestamp Timestamp at the crowdsale ended
     */
    function endCrowdsale(uint256 timestamp)
        external
        onlyOwner
    {
        assert(timestamp > 0 && timestamp <= now);
        assert(block.number > purchaseStartBlock && endedAt == 0);   // cannot end before it starts and overwriting time is not permitted
        endedAt = timestamp;
        totalAmountOfEarlyPurchasesInCny = totalAmountOfEarlyPurchases();
        totalAmountOfPurchasesInCny = totalRaisedAmountInCny();
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
                totalAmountOfPurchasesInCny;

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

            uint256 epTokenCalculationFromEPTokenAmount = SafeMath.mul(earlyPurchaseTokenAmount, earlyPurchaserPurchaseValue) / totalAmountOfEarlyPurchasesInCny;

            uint256 epTokenCalculationFromCrowdsaleTokenAmount = SafeMath.mul(crowdsaleTokenAmount, earlyPurchaserPurchaseValue) / totalAmountOfPurchasesInCny;

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
     * @dev Calculates total amount of tokens purchased includes bonus tokens.
     */
    function totalAmountOfCrowdsalePurchases() constant public returns (uint256 amount) {
        for (uint256 i; i < crowdsalePurchases.length; i++) {
            amount = SafeMath.add(amount, crowdsalePurchases[i].amount);
        }
    }

    /**
     * @dev Calculates total amount of tokens purchased without bonus conversion.
     */
    function totalAmountOfCrowdsalePurchasesWithoutBonus() constant public returns (uint256 amount) {
        for (uint256 i; i < crowdsalePurchases.length; i++) {
            amount = SafeMath.add(amount, crowdsalePurchases[i].rawAmount);
        }
    }

    /**
     * @dev Returns total raised amount in CNY (includes EP) and bonuses
     */
    function totalRaisedAmountInCny() constant public returns (uint256) {
        return SafeMath.add(totalAmountOfEarlyPurchases(), totalAmountOfCrowdsalePurchases());
    }

    /**
     * @dev Returns total amount of early purchases in CNY
     */
    function totalAmountOfEarlyPurchases() constant public returns(uint256) {
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
        uint256 presaleAmount = totalAmountOfCrowdsalePurchasesWithoutBonus();
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
            require(totalAmountOfCrowdsalePurchasesWithoutBonus() < maxCrowdsaleCap);   // check if the amount has already reached the cap

            uint256 crowdsaleTotalAmountAfterPurchase =
                SafeMath.add(totalAmountOfCrowdsalePurchasesWithoutBonus(), amount);

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

            if (amount.add(totalAmountOfCrowdsalePurchasesWithoutBonus()) >= bonusRange)
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