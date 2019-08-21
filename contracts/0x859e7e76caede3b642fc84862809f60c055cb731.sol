pragma solidity ^0.4.7;
/// @title EarlyPurchase contract - Keep track of purchased amount by Early Purchasers
/// @author Starbase PTE. LTD. - <info@starbase.co>
contract AbstractStarbaseCrowdsale {
    function startDate() constant returns (uint256 startDate) {}
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