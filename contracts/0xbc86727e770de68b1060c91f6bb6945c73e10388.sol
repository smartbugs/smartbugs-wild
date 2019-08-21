pragma solidity ^0.4.18;

// File: contracts/InkMediator.sol

interface InkMediator {
  function mediationExpiry() external returns (uint32);
  function requestMediator(uint256 _transactionId, uint256 _transactionAmount, address _transactionOwner) external returns (bool);
  function confirmTransactionFee(uint256 _transactionAmount) external returns (uint256);
  function confirmTransactionAfterExpiryFee(uint256 _transactionAmount) external returns (uint256);
  function confirmTransactionAfterDisputeFee(uint256 _transactionAmount) external returns (uint256);
  function confirmTransactionByMediatorFee(uint256 _transactionAmount) external returns (uint256);
  function refundTransactionFee(uint256 _transactionAmount) external returns (uint256);
  function refundTransactionAfterExpiryFee(uint256 _transactionAmount) external returns (uint256);
  function refundTransactionAfterDisputeFee(uint256 _transactionAmount) external returns (uint256);
  function refundTransactionByMediatorFee(uint256 _transactionAmount) external returns (uint256);
  function settleTransactionByMediatorFee(uint256 _buyerAmount, uint256 _sellerAmount) external returns (uint256, uint256);
}

// File: contracts/InkOwner.sol

interface InkOwner {
  function authorizeTransaction(uint256 _id, address _buyer) external returns (bool);
}

// File: contracts/InkProtocolInterface.sol

interface InkProtocolInterface {
  // Event emitted when a transaction is initiated.
  event TransactionInitiated(
    uint256 indexed id,
    address owner,
    address indexed buyer,
    address indexed seller,
    address policy,
    address mediator,
    uint256 amount,
    // A hash string representing the metadata for the transaction. This is
    // somewhat arbitrary for the transaction. Only the transaction owner
    // will really know the original contents of the metadata and may choose
    // to share it at their discretion.
    bytes32 metadata
  );

  // Event emitted when a transaction has been accepted by the seller.
  event TransactionAccepted(
    uint256 indexed id
  );

  // Event emitted when a transaction has been disputed by the buyer.
  event TransactionDisputed(
    uint256 indexed id
  );

  // Event emitted when a transaction is escalated to the mediator by the
  // seller.
  event TransactionEscalated(
    uint256 indexed id
  );

  // Event emitted when a transaction is revoked by the seller.
  event TransactionRevoked(
    uint256 indexed id
  );

  // Event emitted when a transaction is revoked by the seller.
  event TransactionRefundedByMediator(
    uint256 indexed id,
    uint256 mediatorFee
  );

  // Event emitted when a transaction is settled by the mediator.
  event TransactionSettledByMediator(
    uint256 indexed id,
    uint256 buyerAmount,
    uint256 sellerAmount,
    uint256 buyerMediatorFee,
    uint256 sellerMediatorFee
  );

  // Event emitted when a transaction is confirmed by the mediator.
  event TransactionConfirmedByMediator(
    uint256 indexed id,
    uint256 mediatorFee
  );

  // Event emitted when a transaction is confirmed by the buyer.
  event TransactionConfirmed(
    uint256 indexed id,
    uint256 mediatorFee
  );

  // Event emitted when a transaction is refunded by the seller.
  event TransactionRefunded(
    uint256 indexed id,
    uint256 mediatorFee
  );

  // Event emitted when a transaction is confirmed by the seller after the
  // transaction expiry.
  event TransactionConfirmedAfterExpiry(
    uint256 indexed id,
    uint256 mediatorFee
  );

  // Event emitted when a transaction is confirmed by the buyer after it was
  // disputed.
  event TransactionConfirmedAfterDispute(
    uint256 indexed id,
    uint256 mediatorFee
  );

  // Event emitted when a transaction is refunded by the seller after it was
  // disputed.
  event TransactionRefundedAfterDispute(
    uint256 indexed id,
    uint256 mediatorFee
  );

  // Event emitted when a transaction is refunded by the buyer after the
  // escalation expiry.
  event TransactionRefundedAfterExpiry(
    uint256 indexed id,
    uint256 mediatorFee
  );

  // Event emitted when a transaction is confirmed by the buyer after the
  // mediation expiry.
  event TransactionConfirmedAfterEscalation(
    uint256 indexed id
  );

  // Event emitted when a transaction is refunded by the seller after the
  // mediation expiry.
  event TransactionRefundedAfterEscalation(
    uint256 indexed id
  );

  // Event emitted when a transaction is settled by either the buyer or the
  // seller after the mediation expiry.
  event TransactionSettled(
    uint256 indexed id,
    uint256 buyerAmount,
    uint256 sellerAmount
  );

  // Event emitted when a transaction's feedback is updated by the buyer.
  event FeedbackUpdated(
    uint256 indexed transactionId,
    uint8 rating,
    bytes32 comment
  );

  // Event emitted an account is (unidirectionally) linked to another account.
  // For two accounts to be acknowledged as linked, the linkage must be
  // bidirectional.
  event AccountLinked(
    address indexed from,
    address indexed to
  );

  /* Protocol */
  function link(address _to) external;
  function createTransaction(address _seller, uint256 _amount, bytes32 _metadata, address _policy, address _mediator) external returns (uint256);
  function createTransaction(address _seller, uint256 _amount, bytes32 _metadata, address _policy, address _mediator, address _owner) external returns (uint256);
  function revokeTransaction(uint256 _id) external;
  function acceptTransaction(uint256 _id) external;
  function confirmTransaction(uint256 _id) external;
  function confirmTransactionAfterExpiry(uint256 _id) external;
  function refundTransaction(uint256 _id) external;
  function refundTransactionAfterExpiry(uint256 _id) external;
  function disputeTransaction(uint256 _id) external;
  function escalateDisputeToMediator(uint256 _id) external;
  function settleTransaction(uint256 _id) external;
  function refundTransactionByMediator(uint256 _id) external;
  function confirmTransactionByMediator(uint256 _id) external;
  function settleTransactionByMediator(uint256 _id, uint256 _buyerAmount, uint256 _sellerAmount) external;
  function provideTransactionFeedback(uint256 _id, uint8 _rating, bytes32 _comment) external;

  /* ERC20 */
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function increaseApproval(address spender, uint addedValue) public returns (bool);
  function decreaseApproval(address spender, uint subtractedValue) public returns (bool);
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: contracts/InkProtocolCore.sol

/// @title Ink Protocol: Decentralized reputation and payments for peer-to-peer marketplaces.
contract InkProtocolCore is InkProtocolInterface, StandardToken {
  string public constant name = "Ink Protocol";
  string public constant symbol = "XNK";
  uint8 public constant decimals = 18;

  uint256 private constant gasLimitForExpiryCall = 1000000;
  uint256 private constant gasLimitForMediatorCall = 4000000;

  enum Expiry {
    Transaction, // 0
    Fulfillment, // 1
    Escalation,  // 2
    Mediation    // 3
  }

  enum TransactionState {
    // This is an internal state to represent an uninitialized transaction.
    Null,                     // 0

    Initiated,                // 1
    Accepted,                 // 2
    Disputed,                 // 3
    Escalated,                // 4
    Revoked,                  // 5
    RefundedByMediator,       // 6
    SettledByMediator,        // 7
    ConfirmedByMediator,      // 8
    Confirmed,                // 9
    Refunded,                 // 10
    ConfirmedAfterExpiry,     // 11
    ConfirmedAfterDispute,    // 12
    RefundedAfterDispute,     // 13
    RefundedAfterExpiry,      // 14
    ConfirmedAfterEscalation, // 15
    RefundedAfterEscalation,  // 16
    Settled                   // 17
  }

  // The running ID counter for all Ink Transactions.
  uint256 private globalTransactionId = 0;

  // Mapping of all transactions by ID (globalTransactionId).
  mapping(uint256 => Transaction) internal transactions;

  // The struct definition for an Ink Transaction.
  struct Transaction {
    // The address of the buyer on the transaction.
    address buyer;
    // The address of the seller on the transaction.
    address seller;
    // The address of the policy contract for the transaction.
    address policy;
    // The address of the mediator contract for the transaction.
    address mediator;
    // The state of the transaction.
    TransactionState state;
    // The (block) time that the transaction transitioned to its current state.
    // This value is only set for the states that need it to be set (states
    // with an expiry involved).
    uint256 stateTime;
    // The XNK amount of the transaction.
    uint256 amount;
  }


  /*
    Constructor
  */

  function InkProtocolCore() internal {
    // Start with a total supply of 500,000,000 Ink Tokens (XNK).
    totalSupply_ = 500000000000000000000000000;
  }


  /*
    ERC20 override functions
  */

  function transfer(address _to, uint256 _value) public returns (bool) {
   // Don't allow token transfers to the Ink contract.
   require(_to != address(this));

   return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
   // Don't allow token transfers to the Ink contract.
   require(_to != address(this));

   return super.transferFrom(_from, _to, _value);
  }


  /*
    Account linking functions

    Functions used by users and agents to declare a unidirectionally account
    linking.
  */

  // Called by a user who wishes to link with another _account.
  function link(address _to) external {
    require(_to != address(0));
    require(_to != msg.sender);

    AccountLinked({
      from: msg.sender,
      to: _to
    });
  }


  /*
    Transaction functions
  */

  function createTransaction(address _seller, uint256 _amount, bytes32 _metadata, address _policy, address _mediator) external returns (uint256) {
    return _createTransaction(_seller, _amount, _metadata, _policy, _mediator, address(0));
  }

  function createTransaction(address _seller, uint256 _amount, bytes32 _metadata, address _policy, address _mediator, address _owner) external returns (uint256) {
    return _createTransaction(_seller, _amount, _metadata, _policy, _mediator, _owner);
  }

  function revokeTransaction(uint256 _id) external {
    _revokeTransaction(_id, _findTransactionForBuyer(_id));
  }

  function acceptTransaction(uint256 _id) external {
    _acceptTransaction(_id, _findTransactionForSeller(_id));
  }

  function confirmTransaction(uint256 _id) external {
    _confirmTransaction(_id, _findTransactionForBuyer(_id));
  }

  function confirmTransactionAfterExpiry(uint256 _id) external {
    _confirmTransactionAfterExpiry(_id, _findTransactionForSeller(_id));
  }

  function refundTransaction(uint256 _id) external {
    _refundTransaction(_id, _findTransactionForSeller(_id));
  }

  function refundTransactionAfterExpiry(uint256 _id) external {
    _refundTransactionAfterExpiry(_id, _findTransactionForBuyer(_id));
  }

  function disputeTransaction(uint256 _id) external {
    _disputeTransaction(_id, _findTransactionForBuyer(_id));
  }

  function escalateDisputeToMediator(uint256 _id) external {
    _escalateDisputeToMediator(_id, _findTransactionForSeller(_id));
  }

  function settleTransaction(uint256 _id) external {
    _settleTransaction(_id, _findTransactionForParty(_id));
  }

  function refundTransactionByMediator(uint256 _id) external {
    _refundTransactionByMediator(_id, _findTransactionForMediator(_id));
  }

  function confirmTransactionByMediator(uint256 _id) external {
    _confirmTransactionByMediator(_id, _findTransactionForMediator(_id));
  }

  function settleTransactionByMediator(uint256 _id, uint256 _buyerAmount, uint256 _sellerAmount) external {
    _settleTransactionByMediator(_id, _findTransactionForMediator(_id), _buyerAmount, _sellerAmount);
  }

  function provideTransactionFeedback(uint256 _id, uint8 _rating, bytes32 _comment) external {
    _provideTransactionFeedback(_id, _findTransactionForBuyer(_id), _rating, _comment);
  }


  /*
    Private functions
  */

  function _createTransaction(address _seller, uint256 _amount, bytes32 _metadata, address _policy, address _mediator, address _owner) private returns (uint256) {
    require(_seller != address(0) && _seller != msg.sender);
    require(_owner != msg.sender && _owner != _seller);
    require(_amount > 0);

    // Per specifications, if a mediator is involved then a policy is required.
    // Otherwise, policy must be a zero address.
    if (_mediator == address(0)) {
      require(_policy == address(0));
    } else {
      require(_policy != address(0));
    }

    // Increment the transaction.
    uint256 id = globalTransactionId++;

    // Create the transaction.
    Transaction storage transaction = transactions[id];
    transaction.buyer = msg.sender;
    transaction.seller = _seller;
    transaction.state = TransactionState.Initiated;
    transaction.amount = _amount;
    transaction.policy = _policy;

    _resolveMediator(id, transaction, _mediator, _owner);
    _resolveOwner(id, _owner);

    // Emit the event.
    TransactionInitiated({
      id: id,
      owner: _owner,
      buyer: msg.sender,
      seller: _seller,
      policy: _policy,
      mediator: _mediator,
      amount: _amount,
      metadata: _metadata
    });

    // Place the buyer's tokens in escrow (ie. this contract).
    _transferFrom(msg.sender, this, _amount);

    // Return the newly created transaction's id.
    return id;
  }

  function _revokeTransaction(uint256 _id, Transaction storage _transaction) private {
    require(_transaction.state == TransactionState.Initiated);

    TransactionRevoked({ id: _id });

    _transferFromEscrow(_transaction.buyer, _transaction.amount);

    _cleanupTransaction(_id, _transaction, false);
  }

  function _acceptTransaction(uint256 _id, Transaction storage _transaction) private {
    require(_transaction.state == TransactionState.Initiated);

    if (_transaction.mediator != address(0)) {
      _updateTransactionState(_transaction, TransactionState.Accepted);
    }

    TransactionAccepted({ id: _id });

    if (_transaction.mediator == address(0)) {
      // If there is no mediator involved, the transaction is immediately confirmed.
      _completeTransaction(_id, _transaction, TransactionState.Confirmed, _transaction.seller);
    }
  }

  function _confirmTransaction(uint256 _id, Transaction storage _transaction) private {
    TransactionState finalState;

    if (_transaction.state == TransactionState.Accepted) {
      finalState = TransactionState.Confirmed;
    } else if (_transaction.state == TransactionState.Disputed) {
      finalState = TransactionState.ConfirmedAfterDispute;
    } else if (_transaction.state == TransactionState.Escalated) {
      require(_afterExpiry(_transaction, _fetchExpiry(_transaction, Expiry.Mediation)));
      finalState = TransactionState.ConfirmedAfterEscalation;
    } else {
      revert();
    }

    _completeTransaction(_id, _transaction, finalState, _transaction.seller);
  }

  function _confirmTransactionAfterExpiry(uint256 _id, Transaction storage _transaction) private {
    require(_transaction.state == TransactionState.Accepted);
    require(_afterExpiry(_transaction, _fetchExpiry(_transaction, Expiry.Transaction)));

    _completeTransaction(_id, _transaction, TransactionState.ConfirmedAfterExpiry, _transaction.seller);
  }

  function _refundTransaction(uint256 _id, Transaction storage _transaction) private {
    TransactionState finalState;

    if (_transaction.state == TransactionState.Accepted) {
      finalState = TransactionState.Refunded;
    } else if (_transaction.state == TransactionState.Disputed) {
      finalState = TransactionState.RefundedAfterDispute;
    } else if (_transaction.state == TransactionState.Escalated) {
      require(_afterExpiry(_transaction, _fetchExpiry(_transaction, Expiry.Mediation)));
      finalState = TransactionState.RefundedAfterEscalation;
    } else {
      revert();
    }

    _completeTransaction(_id, _transaction, finalState, _transaction.buyer);
  }

  function _refundTransactionAfterExpiry(uint256 _id, Transaction storage _transaction) private {
    require(_transaction.state == TransactionState.Disputed);
    require(_afterExpiry(_transaction, _fetchExpiry(_transaction, Expiry.Escalation)));

    _completeTransaction(_id, _transaction, TransactionState.RefundedAfterExpiry, _transaction.buyer);
  }

  function _disputeTransaction(uint256 _id, Transaction storage _transaction) private {
    require(_transaction.state == TransactionState.Accepted);
    require(_afterExpiry(_transaction, _fetchExpiry(_transaction, Expiry.Fulfillment)));

    _updateTransactionState(_transaction, TransactionState.Disputed);

    TransactionDisputed({ id: _id });
  }

  function _escalateDisputeToMediator(uint256 _id, Transaction storage _transaction) private {
    require(_transaction.state == TransactionState.Disputed);

    _updateTransactionState(_transaction, TransactionState.Escalated);

    TransactionEscalated({ id: _id });
  }

  function _settleTransaction(uint256 _id, Transaction storage _transaction) private {
    require(_transaction.state == TransactionState.Escalated);
    require(_afterExpiry(_transaction, _fetchExpiry(_transaction, Expiry.Mediation)));

    // Divide the escrow amount in half and give it to the buyer. There's
    // a possibility that one account will get slightly more than the other.
    // We have decided to give the lesser amount to the buyer (arbitrarily).
    uint256 buyerAmount = _transaction.amount.div(2);
    // The remaining amount is given to the seller.
    uint256 sellerAmount = _transaction.amount.sub(buyerAmount);

    TransactionSettled({
      id: _id,
      buyerAmount: buyerAmount,
      sellerAmount: sellerAmount
    });

    _transferFromEscrow(_transaction.buyer, buyerAmount);
    _transferFromEscrow(_transaction.seller, sellerAmount);

    _cleanupTransaction(_id, _transaction, true);
  }

  function _refundTransactionByMediator(uint256 _id, Transaction storage _transaction) private {
    require(_transaction.state == TransactionState.Escalated);

    _completeTransaction(_id, _transaction, TransactionState.RefundedByMediator, _transaction.buyer);
  }

  function _confirmTransactionByMediator(uint256 _id, Transaction storage _transaction) private {
    require(_transaction.state == TransactionState.Escalated);

    _completeTransaction(_id, _transaction, TransactionState.ConfirmedByMediator, _transaction.seller);
  }

  function _settleTransactionByMediator(uint256 _id, Transaction storage _transaction, uint256 _buyerAmount, uint256 _sellerAmount) private {
    require(_transaction.state == TransactionState.Escalated);
    require(_buyerAmount.add(_sellerAmount) == _transaction.amount);

    uint256 buyerMediatorFee;
    uint256 sellerMediatorFee;

    (buyerMediatorFee, sellerMediatorFee) = InkMediator(_transaction.mediator).settleTransactionByMediatorFee(_buyerAmount, _sellerAmount);

    // Require that the sum of the fees be no more than the transaction's amount.
    require(buyerMediatorFee <= _buyerAmount && sellerMediatorFee <= _sellerAmount);

    TransactionSettledByMediator({
      id: _id,
      buyerAmount: _buyerAmount,
      sellerAmount: _sellerAmount,
      buyerMediatorFee: buyerMediatorFee,
      sellerMediatorFee: sellerMediatorFee
    });

    _transferFromEscrow(_transaction.buyer, _buyerAmount.sub(buyerMediatorFee));
    _transferFromEscrow(_transaction.seller, _sellerAmount.sub(sellerMediatorFee));
    _transferFromEscrow(_transaction.mediator, buyerMediatorFee.add(sellerMediatorFee));

    _cleanupTransaction(_id, _transaction, true);
  }

  function _provideTransactionFeedback(uint256 _id, Transaction storage _transaction, uint8 _rating, bytes32 _comment) private {
    // The transaction must be completed (Null state with a buyer) to allow
    // feedback.
    require(_transaction.state == TransactionState.Null);

    // As per functional specifications, ratings must be an integer between
    // 1 and 5, inclusive.
    require(_rating >= 1 && _rating <= 5);

    FeedbackUpdated({
      transactionId: _id,
      rating: _rating,
      comment: _comment
    });
  }

  function _completeTransaction(uint256 _id, Transaction storage _transaction, TransactionState _finalState, address _transferTo) private {
    uint256 mediatorFee = _fetchMediatorFee(_transaction, _finalState);

    if (_finalState == TransactionState.Confirmed) {
      TransactionConfirmed({ id: _id, mediatorFee: mediatorFee });
    } else if (_finalState == TransactionState.ConfirmedAfterDispute) {
      TransactionConfirmedAfterDispute({ id: _id, mediatorFee: mediatorFee });
    } else if (_finalState == TransactionState.ConfirmedAfterEscalation) {
      TransactionConfirmedAfterEscalation({ id: _id });
    } else if (_finalState == TransactionState.ConfirmedAfterExpiry) {
      TransactionConfirmedAfterExpiry({ id: _id, mediatorFee: mediatorFee });
    } else if (_finalState == TransactionState.Refunded) {
      TransactionRefunded({ id: _id, mediatorFee: mediatorFee });
    } else if (_finalState == TransactionState.RefundedAfterDispute) {
      TransactionRefundedAfterDispute({ id: _id, mediatorFee: mediatorFee });
    } else if (_finalState == TransactionState.RefundedAfterEscalation) {
      TransactionRefundedAfterEscalation({ id: _id });
    } else if (_finalState == TransactionState.RefundedAfterExpiry) {
      TransactionRefundedAfterExpiry({ id: _id, mediatorFee: mediatorFee });
    } else if (_finalState == TransactionState.RefundedByMediator) {
      TransactionRefundedByMediator({ id: _id, mediatorFee: mediatorFee });
    } else if (_finalState == TransactionState.ConfirmedByMediator) {
      TransactionConfirmedByMediator({ id: _id, mediatorFee: mediatorFee });
    }

    _transferFromEscrow(_transferTo, _transaction.amount.sub(mediatorFee));
    _transferFromEscrow(_transaction.mediator, mediatorFee);

    _cleanupTransaction(_id, _transaction, true);
  }

  function _fetchExpiry(Transaction storage _transaction, Expiry _expiryType) private returns (uint32) {
    uint32 expiry;
    bool success;

    if (_expiryType == Expiry.Transaction) {
      success = _transaction.policy.call.gas(gasLimitForExpiryCall)(bytes4(keccak256("transactionExpiry()")));
    } else if (_expiryType == Expiry.Fulfillment) {
      success = _transaction.policy.call.gas(gasLimitForExpiryCall)(bytes4(keccak256("fulfillmentExpiry()")));
    } else if (_expiryType == Expiry.Escalation) {
      success = _transaction.policy.call.gas(gasLimitForExpiryCall)(bytes4(keccak256("escalationExpiry()")));
    } else if (_expiryType == Expiry.Mediation) {
      success = _transaction.mediator.call.gas(gasLimitForExpiryCall)(bytes4(keccak256("mediationExpiry()")));
    }

    if (success) {
      assembly {
        if eq(returndatasize(), 0x20) {
          let _freeMemPointer := mload(0x40)
          returndatacopy(_freeMemPointer, 0, 0x20)
          expiry := mload(_freeMemPointer)
        }
      }
    }

    return expiry;
  }

  function _fetchMediatorFee(Transaction storage _transaction, TransactionState _finalState) private returns (uint256) {
    if (_transaction.mediator == address(0)) {
      return 0;
    }

    uint256 mediatorFee;
    bool success;

    if (_finalState == TransactionState.Confirmed) {
      success = _transaction.mediator.call.gas(gasLimitForMediatorCall)(bytes4(keccak256("confirmTransactionFee(uint256)")), _transaction.amount);
    } else if (_finalState == TransactionState.ConfirmedAfterExpiry) {
      success = _transaction.mediator.call.gas(gasLimitForMediatorCall)(bytes4(keccak256("confirmTransactionAfterExpiryFee(uint256)")), _transaction.amount);
    } else if (_finalState == TransactionState.ConfirmedAfterDispute) {
      success = _transaction.mediator.call.gas(gasLimitForMediatorCall)(bytes4(keccak256("confirmTransactionAfterDisputeFee(uint256)")), _transaction.amount);
    } else if (_finalState == TransactionState.ConfirmedByMediator) {
      mediatorFee = InkMediator(_transaction.mediator).confirmTransactionByMediatorFee(_transaction.amount);
    } else if (_finalState == TransactionState.Refunded) {
      success = _transaction.mediator.call.gas(gasLimitForMediatorCall)(bytes4(keccak256("refundTransactionFee(uint256)")), _transaction.amount);
    } else if (_finalState == TransactionState.RefundedAfterExpiry) {
      success = _transaction.mediator.call.gas(gasLimitForMediatorCall)(bytes4(keccak256("refundTransactionAfterExpiryFee(uint256)")), _transaction.amount);
    } else if (_finalState == TransactionState.RefundedAfterDispute) {
      success = _transaction.mediator.call.gas(gasLimitForMediatorCall)(bytes4(keccak256("refundTransactionAfterDisputeFee(uint256)")), _transaction.amount);
    } else if (_finalState == TransactionState.RefundedByMediator) {
      mediatorFee = InkMediator(_transaction.mediator).refundTransactionByMediatorFee(_transaction.amount);
    }

    if (success) {
      assembly {
        if eq(returndatasize(), 0x20) {
          let _freeMemPointer := mload(0x40)
          returndatacopy(_freeMemPointer, 0, 0x20)
          mediatorFee := mload(_freeMemPointer)
        }
      }

      // The mediator's fee cannot be more than transaction's amount.
      if (mediatorFee > _transaction.amount) {
        mediatorFee = 0;
      }
    } else {
      require(mediatorFee <= _transaction.amount);
    }

    return mediatorFee;
  }

  function _resolveOwner(uint256 _transactionId, address _owner) private {
    if (_owner != address(0)) {
      // If an owner is specified, it must authorize the transaction.
      require(InkOwner(_owner).authorizeTransaction(
        _transactionId,
        msg.sender
      ));
    }
  }

  function _resolveMediator(uint256 _transactionId, Transaction storage _transaction, address _mediator, address _owner) private {
    if (_mediator != address(0)) {
      // The mediator must accept the transaction otherwise we abort.
      require(InkMediator(_mediator).requestMediator(_transactionId, _transaction.amount, _owner));

      // Assign the mediator to the transaction.
      _transaction.mediator = _mediator;
    }
  }

  function _afterExpiry(Transaction storage _transaction, uint32 _expiry) private view returns (bool) {
    return now.sub(_transaction.stateTime) >= _expiry;
  }

  function _findTransactionForBuyer(uint256 _id) private view returns (Transaction storage transaction) {
    transaction = _findTransaction(_id);
    require(msg.sender == transaction.buyer);
  }

  function _findTransactionForSeller(uint256 _id) private view returns (Transaction storage transaction) {
    transaction = _findTransaction(_id);
    require(msg.sender == transaction.seller);
  }

  function _findTransactionForParty(uint256 _id) private view returns (Transaction storage transaction) {
    transaction = _findTransaction(_id);
    require(msg.sender == transaction.buyer || msg.sender == transaction.seller);
  }

  function _findTransactionForMediator(uint256 _id) private view returns (Transaction storage transaction) {
    transaction = _findTransaction(_id);
    require(msg.sender == transaction.mediator);
  }

  function _findTransaction(uint256 _id) private view returns (Transaction storage transaction) {
    transaction = transactions[_id];
    require(_id < globalTransactionId);
  }

  function _transferFrom(address _from, address _to, uint256 _value) private returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(_from, _to, _value);

    return true;
  }

  function _transferFromEscrow(address _to, uint256 _value) private returns (bool) {
    if (_value > 0) {
      return _transferFrom(this, _to, _value);
    }

    return true;
  }

  function _updateTransactionState(Transaction storage _transaction, TransactionState _state) private {
    _transaction.state = _state;
    _transaction.stateTime = now;
  }

  function _cleanupTransaction(uint256 _id, Transaction storage _transaction, bool _completed) private {
    // Remove data that is no longer needed on the contract.

    if (_completed) {
      delete _transaction.state;
      delete _transaction.seller;
      delete _transaction.policy;
      delete _transaction.mediator;
      delete _transaction.stateTime;
      delete _transaction.amount;
    } else {
      delete transactions[_id];
    }
  }
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

// File: zeppelin-solidity/contracts/token/ERC20/TokenVesting.sol

/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract TokenVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(uint256 amount);
  event Revoked();

  // beneficiary of tokens after they are released
  address public beneficiary;

  uint256 public cliff;
  uint256 public start;
  uint256 public duration;

  bool public revocable;

  mapping (address => uint256) public released;
  mapping (address => bool) public revoked;

  /**
   * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all
   * of the balance will have vested.
   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
   * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
   * @param _duration duration in seconds of the period in which the tokens will vest
   * @param _revocable whether the vesting is revocable or not
   */
  function TokenVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {
    require(_beneficiary != address(0));
    require(_cliff <= _duration);

    beneficiary = _beneficiary;
    revocable = _revocable;
    duration = _duration;
    cliff = _start.add(_cliff);
    start = _start;
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   * @param token ERC20 token which is being vested
   */
  function release(ERC20Basic token) public {
    uint256 unreleased = releasableAmount(token);

    require(unreleased > 0);

    released[token] = released[token].add(unreleased);

    token.safeTransfer(beneficiary, unreleased);

    Released(unreleased);
  }

  /**
   * @notice Allows the owner to revoke the vesting. Tokens already vested
   * remain in the contract, the rest are returned to the owner.
   * @param token ERC20 token which is being vested
   */
  function revoke(ERC20Basic token) public onlyOwner {
    require(revocable);
    require(!revoked[token]);

    uint256 balance = token.balanceOf(this);

    uint256 unreleased = releasableAmount(token);
    uint256 refund = balance.sub(unreleased);

    revoked[token] = true;

    token.safeTransfer(owner, refund);

    Revoked();
  }

  /**
   * @dev Calculates the amount that has already vested but hasn't been released yet.
   * @param token ERC20 token which is being vested
   */
  function releasableAmount(ERC20Basic token) public view returns (uint256) {
    return vestedAmount(token).sub(released[token]);
  }

  /**
   * @dev Calculates the amount that has already vested.
   * @param token ERC20 token which is being vested
   */
  function vestedAmount(ERC20Basic token) public view returns (uint256) {
    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released[token]);

    if (now < cliff) {
      return 0;
    } else if (now >= start.add(duration) || revoked[token]) {
      return totalBalance;
    } else {
      return totalBalance.mul(now.sub(start)).div(duration);
    }
  }
}

// File: contracts/InkProtocol.sol

/// @title Ink Protocol: Decentralized reputation and payments for peer-to-peer marketplaces.
contract InkProtocol is InkProtocolCore {
  // Allocation addresses.
  address public constant __address0__ = 0xA13febeEde2B2924Ce8b27c1512874D3576fEC16;
  address public constant __address1__ = 0xc5bA7157b5B69B0fAe9332F30719Eecd79649486;
  address public constant __address2__ = 0x29a4b44364A8Bcb6e4d9dd60c222cCaca286ebf2;
  address public constant __address3__ = 0xc1DC1e5C3970E22201C5DAB0841abB2DD6499D3F;
  address public constant __address4__ = 0x0746d0b67BED258d94D06b15859df8dbd990eC3D;

  /*
    Constructor for Mainnet.
  */

  function InkProtocol() public {
    // Unsold tokens due to token sale hard cap.
    balances[__address0__] = 19625973697895500000000000;
    Transfer(address(0), __address0__, balanceOf(__address0__));

    // Allocate 32% to contract for distribution.
    // Vesting starts Feb 28, 2018 @ 00:00:00 GMT
    TokenVesting vesting1 = new TokenVesting(__address1__, 1519776000, 0, 3 years, false);
    balances[vesting1] = 160000000000000000000000000;
    Transfer(address(0), vesting1, balanceOf(vesting1));

    // Allocate 32% to contract for Listia Inc.
    // Vesting starts Feb 28, 2018 @ 00:00:00 GMT
    TokenVesting vesting2 = new TokenVesting(__address2__, 1519776000, 0, 3 years, false);
    balances[vesting2] = 160000000000000000000000000;
    Transfer(address(0), vesting2, balanceOf(vesting2));

    // Allocate 6% to wallet for Listia Marketplace credit conversion.
    balances[__address3__] = 30000000000000000000000000;
    Transfer(address(0), __address3__, balanceOf(__address3__));

    // Allocate to wallet for token sale distribution.
    balances[__address4__] = 130374026302104500000000000;
    Transfer(address(0), __address4__, balanceOf(__address4__));
  }
}