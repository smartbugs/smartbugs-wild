/*
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


/*
 * Haltable
 *
 * Abstract contract that allows children to implement an
 * emergency stop mechanism. Differs from Pausable by causing a throw
 * instead of return when in halt mode.
 *
 *
 * Originally envisioned in FirstBlood ICO contract.
 */
contract Haltable is Ownable {
  bool public halted;

  modifier stopInEmergency {
    if (halted) throw;
    _;
  }

  modifier onlyInEmergency {
    if (!halted) throw;
    _;
  }

  // called by the owner on emergency, triggers stopped state
  function halt() external onlyOwner {
    halted = true;
  }

  // called by the owner on end of emergency, returns to normal state
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }

}



/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

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

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}



/**
 * Forward Ethereum payments to another wallet and track them with an event.
 *
 * Allows to identify customers who made Ethereum payment for a central token issuance.
 * Furthermore allow making a payment on behalf of another address.
 *
 * Allow pausing to signal the end of the crowdsale.
 */
contract PaymentForwarder is Haltable, SafeMath {

  /** Who will get all ETH in the end */
  address public teamMultisig;

  /** Total incoming money */
  uint public totalTransferred;

  /** How many distinct customers we have that have made a payment */
  uint public customerCount;

  /** Total incoming money per centrally tracked customer id */
  mapping(uint128 => uint) public paymentsByCustomer;

  /** Total incoming money per benefactor address */
  mapping(address => uint) public paymentsByBenefactor;

  /** A customer has made a payment. Benefactor is the address where the tokens will be ultimately issued.*/
  event PaymentForwarded(address source, uint amount, uint128 customerId, address benefactor);

  /**
   * @param _teamMultisig Team multisig receives the deposited payments.
   *
   * @param _owner Owner is able to pause and resume crowdsale
   */
  function PaymentForwarder(address _owner, address _teamMultisig) {
    teamMultisig = _teamMultisig;
    owner = _owner;
  }

  /**
   * Pay on a behalf of an address.
   *
   * We log the payment event, so that the server can keep tally of the invested amounts
   * and token receivers.
   *
   * The actual payment is forwarded to the team multisig.
   *
   * @param customerId Identifier in the central database, UUID v4 - this is used to note customer by email
   *
   */
  function pay(uint128 customerId, address benefactor) public stopInEmergency payable {

    uint weiAmount = msg.value;

    if(weiAmount == 0) {
      throw; // No invalid payments
    }

    if(customerId == 0) {
      throw; // We require to record customer id for the server side processing
    }

    if(benefactor == 0) {
      throw; // Bad payment address
    }

    PaymentForwarded(msg.sender, weiAmount, customerId, benefactor);

    totalTransferred = safeAdd(totalTransferred, weiAmount);

    if(paymentsByCustomer[customerId] == 0) {
      customerCount++;
    }

    paymentsByCustomer[customerId] = safeAdd(paymentsByCustomer[customerId], weiAmount);

    // We track benefactor addresses for extra safety;
    // In the case of central ETH issuance tracking has problems we can
    // construct ETH contributions solely based on blockchain data
    paymentsByBenefactor[benefactor] = safeAdd(paymentsByBenefactor[benefactor], weiAmount);

    // May run out of gas
    if(!teamMultisig.send(weiAmount)) throw;
  }

  /**
   * Pay on a behalf of the sender.
   *
   * @param customerId Identifier in the central database, UUID v4
   *
   */
  function payForMyself(uint128 customerId) public payable {
    pay(customerId, msg.sender);
  }

}