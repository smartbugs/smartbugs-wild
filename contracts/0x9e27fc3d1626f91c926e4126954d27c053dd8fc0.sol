pragma solidity ^0.5.0;

/**
 * Syndicate
 **/

/// @title A way to distribute ownership of Ether in time
/// @author Chance Hudson
/// @notice This contract can be used to manipulate ownership of Ether across
/// time. Funds are linearly distributed over the time period to recipients.
contract Syndicate {

  struct Payment {
    address sender;
    address payable receiver;
    uint256 timestamp;
    uint256 time;
    uint256 weiValue;
    uint256 weiPaid;
    bool isFork;
    uint256 parentIndex;
  }

  Payment[] public payments;
  mapping(uint256 => uint256[]) public paymentForks;

  event PaymentUpdated(uint256 index);
  event PaymentCreated(uint256 index);

  /// @notice Create a payment from `msg.sender` of amount `msg.value` to
  /// `_receiver` over `_time` seconds. The funds are linearly distributed in
  /// this time. The `_receiver` may fork the funds to another address but
  /// cannot manipulate the `_time` value.
  /// @param _receiver The address receiving the payment
  /// @param _time The payment time length, in seconds
  function paymentCreate(address payable _receiver, uint256 _time) public payable {
    // Verify that value has been sent
    require(msg.value > 0);
    // Verify the time is non-zero
    require(_time > 0);
    payments.push(Payment({
      sender: msg.sender,
      receiver: _receiver,
      timestamp: block.timestamp,
      time: _time,
      weiValue: msg.value,
      weiPaid: 0,
      isFork: false,
      parentIndex: 0
    }));
    paymentForks[payments.length - 1] = new uint256[](0);
    emit PaymentCreated(payments.length - 1);
  }

  /// @notice Withdraws the available funds at the current point in time from a
  /// payment to the receiver address.
  /// @dev May be invoked by anyone idempotently.
  /// @param index The payment index to settle
  function paymentSettle(uint256 index) public {
    requirePaymentIndexInRange(index);
    Payment storage payment = payments[index];
    uint256 owedWei = paymentWeiOwed(index);
    payment.weiPaid += owedWei;
    payment.receiver.transfer(owedWei);
    emit PaymentUpdated(index);
  }

  /// @notice Calculates the amount of wei owed on a payment at the current
  /// `block.timestamp`.
  /// @param index The payment index for which to determine wei owed
  /// @return The wei owed at the current point in time
  function paymentWeiOwed(uint256 index) public view returns (uint256) {
    requirePaymentIndexInRange(index);
    Payment memory payment = payments[index];
    // Calculate owed wei based on current time and total wei owed/paid
    return max(payment.weiPaid, payment.weiValue * min(block.timestamp - payment.timestamp, payment.time) / payment.time) - payment.weiPaid;
  }

  /// @notice Forks part of a payment to another address for the remaining time
  /// on a payment. Allows responsibility of funds to be delegated to other
  /// addresses by the payment recipient. A payment and all forks share the same
  /// completion time.
  /// @dev Payments may only be forked by the receiver address. The `_weiValue`
  /// being forked must be less than the wei currently available in the payment.
  /// @param index The payment index to be forked
  /// @param _receiver The fork payment recipient
  /// @param _weiValue The amount of wei to fork
  function paymentFork(uint256 index, address payable _receiver, uint256 _weiValue) public {
    requirePaymentIndexInRange(index);
    Payment storage payment = payments[index];
    // Make sure the payment receiver is operating
    require(msg.sender == payment.receiver);

    uint256 remainingWei = payment.weiValue - payment.weiPaid;
    uint256 remainingTime = max(0, payment.time - (block.timestamp - payment.timestamp));

    // Ensure there is more remainingWei than requested fork wei
    require(remainingWei > _weiValue);
    require(_weiValue > 0);

    // Create a new Payment of _weiValue to _receiver over the remaining time of
    // payment at index

    payment.weiValue -= _weiValue;

    // Now create the forked payment
    payments.push(Payment({
      sender: payment.receiver,
      receiver: _receiver,
      timestamp: block.timestamp,
      time: remainingTime,
      weiValue: _weiValue,
      weiPaid: 0,
      isFork: true,
      parentIndex: index
    }));
    uint256 forkIndex = payments.length - 1;
    paymentForks[forkIndex] = new uint256[](0);
    paymentForks[index].push(forkIndex);
    emit PaymentUpdated(index);
    emit PaymentCreated(forkIndex);
  }

  /// @notice Accessor for determining if a given payment has any forks.
  /// @param index The payment to check
  /// @return Whether payment `index` has been forked
  function isPaymentForked(uint256 index) public view returns (bool) {
    requirePaymentIndexInRange(index);
    return paymentForks[index].length > 0;
  }

  /// @notice Accessor for payment fork count.
  /// @param index The payment for which to get the fork count
  /// @return The number of time payment `index` has been forked
  function paymentForkCount(uint256 index) public view returns (uint256) {
    requirePaymentIndexInRange(index);
    return paymentForks[index].length;
  }

  /// @notice Accessor for determining if a payment is settled.
  /// @param index The payment to check
  /// @return Whether a payment has been fully paid
  function isPaymentSettled(uint256 index) public view returns (bool) {
    requirePaymentIndexInRange(index);
    return payments[index].weiValue == payments[index].weiPaid;
  }

  /// @dev Throws if `index` is out of range.
  /// @param index The payment index to check
  function requirePaymentIndexInRange(uint256 index) public view {
    require(index < payments.length);
  }

  /// @notice Accessor for payments array length.
  /// @return The number of payments that exist in the Syndicate
  function paymentCount() public view returns (uint) {
    return payments.length;
  }

  /// @dev Return the smaller of two values.
  function min(uint a, uint b) private pure returns (uint) {
    return a < b ? a : b;
  }

  /// @dev Return the larger of two values.
  function max(uint a, uint b) private pure returns (uint) {
    return a > b ? a : b;
  }
}