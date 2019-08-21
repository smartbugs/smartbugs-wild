pragma solidity ^0.4.11;

// File: zeppelin-solidity/contracts/math/Math.sol

/**
 * @title Math
 * @dev Assorted math operations
 */

library Math {
  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: contracts/StandingOrder.sol

/**
 * @title Standing order
 * @dev Lifecycle of a standing order:
 *  - the payment amount per interval is set at construction time and can not be changed afterwards
 *  - the payee is set by the owner and can not be changed after creation
 *  - at <startTime> (unix timestamp) the first payment is due
 *  - every <intervall> seconds the next payment is due
 *  - the owner can add funds to the order contract at any time
 *  - the owner can withdraw only funds that do not (yet) belong to the payee
 *  - the owner can terminate a standingorder anytime. Termination results in:
 *    - No further funding being allowed
 *    - order marked as "terminated" and not being displayed anymore in owner UI
 *    - as long as there are uncollected funds entitled to the payee, it is still displayed in payee UI
 *    - the payee can still collect funds owned to him
 *
 *   * Terminology *
 *   "withdraw" -> performed by owner - transfer funds stored in contract back to owner
 *   "collect"  -> performed by payee - transfer entitled funds from contract to payee
 *
 *   * How does a payment work? *
 *   Since a contract can not trigger a payment by itself, it provides the method "collectFunds" for the payee.
 *   The payee can always query the contract to determine how many funds he is entitled to collect.
 *   The payee can call "collectFunds" to initiate transfer of entitled funds to his address.
 */
contract StandingOrder {

    using SafeMath for uint;
    using Math for uint;

    address public owner;        /** The owner of this order */
    address public payee;        /** The payee is the receiver of funds */
    uint public startTime;       /** Date and time (unix timestamp - seconds since 1970) when first payment can be claimed by payee */
    uint public paymentInterval; /** Interval for payments (Unit: seconds) */
    uint public paymentAmount;   /** How much can payee claim per period (Unit: Wei) */
    uint public claimedFunds;    /** How much funds have been claimed already (Unit: Wei) */
    string public ownerLabel;    /** Label (set by contract owner) */
    bool public isTerminated;    /** Marks order as terminated */
    uint public terminationTime; /** Date and time (unix timestamp - seconds since 1970) when order terminated */

    modifier onlyPayee() {
        require(msg.sender == payee);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /** Event triggered when payee collects funds */
    event Collect(uint amount);
    /** Event triggered when contract gets funded */
    event Fund(uint amount);
    /** Event triggered when owner withdraws funds */
    event Withdraw(uint amount);

    /**
     * Constructor
     * @param _owner The owner of the contract
     * @param _payee The payee - the account that can collect payments from this contract
     * @param _paymentInterval Interval for payments, unit: seconds
     * @param _paymentAmount The amount payee can claim per period, unit: wei
     * @param _startTime Date and time (unix timestamp - seconds since 1970) when first payment can be claimed by payee
     * @param _label Label for contract, e.g "rent" or "weekly paycheck"
     */
    function StandingOrder(
        address _owner,
        address _payee,
        uint _paymentInterval,
        uint _paymentAmount,
        uint _startTime,
        string _label
    )
        payable
    {
        // Sanity check parameters
        require(_paymentInterval > 0);
        require(_paymentAmount > 0);
        // Following check is not exact for unicode strings, but here i just want to make sure that some label is provided
        // See https://ethereum.stackexchange.com/questions/13862/is-it-possible-to-check-string-variables-length-inside-the-contract/13886
        require(bytes(_label).length > 2);

        // Set owner to _owner, as msg.sender is the StandingOrderFactory contract
        owner = _owner;

        payee = _payee;
        paymentInterval = _paymentInterval;
        paymentAmount = _paymentAmount;
        ownerLabel = _label;
        startTime = _startTime;
        isTerminated = false;
    }

    /**
     * Fallback function.
     * Allows adding funds to existing order. Will throw in case the order is terminated!
     */
    function() payable {
        if (isTerminated) {
            // adding funds not allowed for terminated orders
            revert();
        }
        // Log Fund event
        Fund(msg.value);
    }

    /**
     * Determine how much funds payee is entitled to collect
     * Note that this might be more than actual funds available!
     * @return Number of wei that payee is entitled to collect
     */
    function getEntitledFunds() constant returns (uint) {
        // First check if the contract startTime has been reached at all
        if (now < startTime) {
            // startTime not yet reached
            return 0;
        }

        // startTime has been reached, so add first payment
        uint entitledAmount = paymentAmount;

        // Determine endTime for calculation. If order has been terminated -> terminationTime, otherwise current time
        uint endTime = isTerminated ? terminationTime : now;

        // calculate number of complete intervals since startTime
        uint runtime = endTime.sub(startTime);
        uint completeIntervals = runtime.div(paymentInterval); // Division always truncates, so implicitly rounding down here.
        entitledAmount = entitledAmount.add(completeIntervals.mul(paymentAmount));

        // subtract already collected funds
        return entitledAmount.sub(claimedFunds);
    }

    /**
     * Determine how much funds are available for payee to collect
     * This can be less than the entitled amount if the contract does not have enough funds to cover the due payments,
     * in other words: The owner has not put enough funds into the contract.
     * @return Number of wei that payee can collect
     */
    function getUnclaimedFunds() constant returns (uint) {
        // don't return more than available balance
        return getEntitledFunds().min256(this.balance);
    }

    /**
     * Determine how much funds are still owned by owner (not yet reserved for payee)
     * Note that this can be negative in case contract is not funded enough to cover entitled amount for payee!
     * @return number of wei belonging owner, negative if contract is missing funds to cover payments
     */
    function getOwnerFunds() constant returns (int) {
        // Conversion from unsigned int to int will produce unexpected results only for very large
        // numbers (2^255 and greater). This is about 5.7e+58 ether.
        // -> There will be no situation when the contract balance (this.balance) will hit this limit
        // -> getEntitledFunds() might end up hitting this limit when the contract creator INTENTIONALLY sets
        //    any combination of absurdly high payment rate, low interval or a startTime way in the past.
        //    Being entitled to more than 5.7e+58 ether obviously will never be an expected usecase
        // Therefor the conversion can be considered safe here.
        return int256(this.balance) - int256(getEntitledFunds());
    }

    /**
     * Collect payment
     * Can only be called by payee. This will transfer all available funds (see getUnclaimedFunds) to payee
     * @return amount that has been transferred!
     */
    function collectFunds() onlyPayee returns(uint) {
        uint amount = getUnclaimedFunds();
        if (amount <= 0) {
            // nothing to collect :-(
            revert();
        }

        // keep track of collected funds
        claimedFunds = claimedFunds.add(amount);

        // create log entry
        Collect(amount);

        // initiate transfer of unclaimed funds to payee
        payee.transfer(amount);

        return amount;
    }

    /**
     * Withdraw requested amount back to owner.
     * Only funds not (yet) reserved for payee can be withdrawn. So it is not possible for the owner
     * to withdraw unclaimed funds - They can only be claimed by payee!
     * Withdrawing funds does not terminate the order, at any time owner can fund it again!
     * @param amount Number of wei owner wants to withdraw
     */
    function WithdrawOwnerFunds(uint amount) onlyOwner {
        int intOwnerFunds = getOwnerFunds(); // this might be negative in case of underfunded contract!
        if (intOwnerFunds <= 0) {
            // nothing available to withdraw :-(
            revert();
        }
        // conversion int -> uint is safe here as I'm checking <= 0 above!
        uint256 ownerFunds = uint256(intOwnerFunds);

        if (amount > ownerFunds) {
            // Trying to withdraw more than available!
            revert();
        }

        // Log Withdraw event
        Withdraw(amount);

        owner.transfer(amount);
    }

    /**
     * Terminate order
     * Marks the order as terminated.
     * Can only be executed if no ownerfunds are left
     */
    function Terminate() onlyOwner {
        assert(getOwnerFunds() <= 0);
        terminationTime = now;
        isTerminated = true;
    }
}


/**
 * @title StandingOrder factory
 */
contract StandingOrderFactory {
    // keep track who issued standing orders
    mapping (address => StandingOrder[]) public standingOrdersByOwner;
    // keep track of payees of standing orders
    mapping (address => StandingOrder[]) public standingOrdersByPayee;

    // Events
    event LogOrderCreated(
        address orderAddress,
        address indexed owner,
        address indexed payee
    );

    /**
     * Create a new standing order
     * The owner of the new order will be the address that called this function (msg.sender)
     * @param _payee The payee - the account that can collect payments from this contract
     * @param _paymentInterval Interval for payments, unit: seconds
     * @param _paymentAmount The amount payee can claim per period, unit: wei
     * @param _startTime Date and time (unix timestamp - seconds since 1970) when first payment can be claimed by payee
     * @param _label Label for contract, e.g "rent" or "weekly paycheck"
     * @return Address of new created standingOrder contract
     */
    function createStandingOrder(address _payee, uint _paymentAmount, uint _paymentInterval, uint _startTime, string _label) returns (StandingOrder) {
        StandingOrder so = new StandingOrder(msg.sender, _payee, _paymentInterval, _paymentAmount, _startTime, _label);
        standingOrdersByOwner[msg.sender].push(so);
        standingOrdersByPayee[_payee].push(so);
        LogOrderCreated(so, msg.sender, _payee);
        return so;
    }

    /**
     * Determine how many orders are owned by caller (msg.sender)
     * @return Number of orders
     */
    function getNumOrdersByOwner() constant returns (uint) {
        return standingOrdersByOwner[msg.sender].length;
    }

    /**
     * Get order by index from the Owner mapping
     * @param index Index of order
     * @return standing order address
     */
    function getOwnOrderByIndex(uint index) constant returns (StandingOrder) {
        return standingOrdersByOwner[msg.sender][index];
    }

    /**
     * Determine how many orders are paying to caller (msg.sender)
     * @return Number of orders
     */
    function getNumOrdersByPayee() constant returns (uint) {
        return standingOrdersByPayee[msg.sender].length;
    }

    /**
     * Get order by index from the Payee mapping
     * @param index Index of order
     * @return standing order address
     */
    function getPaidOrderByIndex(uint index) constant returns (StandingOrder) {
        return standingOrdersByPayee[msg.sender][index];
    }
}