pragma solidity ^0.4.24;

// File: node_modules\zeppelin-solidity\contracts\math\Math.sol

/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

// File: node_modules\zeppelin-solidity\contracts\ownership\Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: node_modules\zeppelin-solidity\contracts\math\SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: node_modules\zeppelin-solidity\contracts\payment\Escrow.sol

/**
 * @title Escrow
 * @dev Base escrow contract, holds funds destinated to a payee until they
 * withdraw them. The contract that uses the escrow as its payment method
 * should be its owner, and provide public methods redirecting to the escrow's
 * deposit and withdraw.
 */
contract Escrow is Ownable {
  using SafeMath for uint256;

  event Deposited(address indexed payee, uint256 weiAmount);
  event Withdrawn(address indexed payee, uint256 weiAmount);

  mapping(address => uint256) private deposits;

  function depositsOf(address _payee) public view returns (uint256) {
    return deposits[_payee];
  }

  /**
  * @dev Stores the sent amount as credit to be withdrawn.
  * @param _payee The destination address of the funds.
  */
  function deposit(address _payee) public onlyOwner payable {
    uint256 amount = msg.value;
    deposits[_payee] = deposits[_payee].add(amount);

    emit Deposited(_payee, amount);
  }

  /**
  * @dev Withdraw accumulated balance for a payee.
  * @param _payee The address whose funds will be withdrawn and transferred to.
  */
  function withdraw(address _payee) public onlyOwner {
    uint256 payment = deposits[_payee];
    assert(address(this).balance >= payment);

    deposits[_payee] = 0;

    _payee.transfer(payment);

    emit Withdrawn(_payee, payment);
  }
}

// File: node_modules\zeppelin-solidity\contracts\payment\ConditionalEscrow.sol

/**
 * @title ConditionalEscrow
 * @dev Base abstract escrow to only allow withdrawal if a condition is met.
 */
contract ConditionalEscrow is Escrow {
  /**
  * @dev Returns whether an address is allowed to withdraw their funds. To be
  * implemented by derived contracts.
  * @param _payee The destination address of the funds.
  */
  function withdrawalAllowed(address _payee) public view returns (bool);

  function withdraw(address _payee) public {
    require(withdrawalAllowed(_payee));
    super.withdraw(_payee);
  }
}

// File: node_modules\zeppelin-solidity\contracts\payment\RefundEscrow.sol

/**
 * @title RefundEscrow
 * @dev Escrow that holds funds for a beneficiary, deposited from multiple parties.
 * The contract owner may close the deposit period, and allow for either withdrawal
 * by the beneficiary, or refunds to the depositors.
 */
contract RefundEscrow is Ownable, ConditionalEscrow {
  enum State { Active, Refunding, Closed }

  event Closed();
  event RefundsEnabled();

  State public state;
  address public beneficiary;

  /**
   * @dev Constructor.
   * @param _beneficiary The beneficiary of the deposits.
   */
  constructor(address _beneficiary) public {
    require(_beneficiary != address(0));
    beneficiary = _beneficiary;
    state = State.Active;
  }

  /**
   * @dev Stores funds that may later be refunded.
   * @param _refundee The address funds will be sent to if a refund occurs.
   */
  function deposit(address _refundee) public payable {
    require(state == State.Active);
    super.deposit(_refundee);
  }

  /**
   * @dev Allows for the beneficiary to withdraw their funds, rejecting
   * further deposits.
   */
  function close() public onlyOwner {
    require(state == State.Active);
    state = State.Closed;
    emit Closed();
  }

  /**
   * @dev Allows for refunds to take place, rejecting further deposits.
   */
  function enableRefunds() public onlyOwner {
    require(state == State.Active);
    state = State.Refunding;
    emit RefundsEnabled();
  }

  /**
   * @dev Withdraws the beneficiary's funds.
   */
  function beneficiaryWithdraw() public {
    require(state == State.Closed);
    beneficiary.transfer(address(this).balance);
  }

  /**
   * @dev Returns whether refundees can withdraw their deposits (be refunded).
   */
  function withdrawalAllowed(address _payee) public view returns (bool) {
    return state == State.Refunding;
  }
}

// File: contracts\ClinicAllRefundEscrow.sol

/**
 * @title ClinicAllRefundEscrow
 * @dev Escrow that holds funds for a beneficiary, deposited from multiple parties.
 * The contract owner may close the deposit period, and allow for either withdrawal
 * by the beneficiary, or refunds to the depositors.
 */
contract ClinicAllRefundEscrow is RefundEscrow {
  using Math for uint256;

  struct RefundeeRecord {
    bool isRefunded;
    uint256 index;
  }

  mapping(address => RefundeeRecord) public refundees;
  address[] internal refundeesList;

  event Deposited(address indexed payee, uint256 weiAmount);
  event Withdrawn(address indexed payee, uint256 weiAmount);

  mapping(address => uint256) private deposits;
  mapping(address => uint256) private beneficiaryDeposits;

  // Amount of wei deposited by beneficiary
  uint256 public beneficiaryDepositedAmount;

  // Amount of wei deposited by investors to CrowdSale
  uint256 public investorsDepositedToCrowdSaleAmount;

  /**
   * @dev Constructor.
   * @param _beneficiary The beneficiary of the deposits.
   */
  constructor(address _beneficiary)
  RefundEscrow(_beneficiary)
  public {
  }

  function depositsOf(address _payee) public view returns (uint256) {
    return deposits[_payee];
  }

  function beneficiaryDepositsOf(address _payee) public view returns (uint256) {
    return beneficiaryDeposits[_payee];
  }



  /**
   * @dev Stores funds that may later be refunded.
   * @param _refundee The address funds will be sent to if a refund occurs.
   */
  function deposit(address _refundee) public payable {
    uint256 amount = msg.value;
    beneficiaryDeposits[_refundee] = beneficiaryDeposits[_refundee].add(amount);
    beneficiaryDepositedAmount = beneficiaryDepositedAmount.add(amount);
  }

  /**
 * @dev Stores funds that may later be refunded.
 * @param _refundee The address funds will be sent to if a refund occurs.
 * @param _value The amount of funds will be sent to if a refund occurs.
 */
  function depositFunds(address _refundee, uint256 _value) public onlyOwner {
    require(state == State.Active, "Funds deposition is possible only in the Active state.");

    uint256 amount = _value;
    deposits[_refundee] = deposits[_refundee].add(amount);
    investorsDepositedToCrowdSaleAmount = investorsDepositedToCrowdSaleAmount.add(amount);

    emit Deposited(_refundee, amount);

    RefundeeRecord storage _data = refundees[_refundee];
    _data.isRefunded = false;

    if (_data.index == uint256(0)) {
      refundeesList.push(_refundee);
      _data.index = refundeesList.length.sub(1);
    }
  }

  /**
  * @dev Allows for the beneficiary to withdraw their funds, rejecting
  * further deposits.
  */
  function close() public onlyOwner {
    super.close();
  }

  function withdraw(address _payee) public onlyOwner {
    require(state == State.Refunding, "Funds withdrawal is possible only in the Refunding state.");
    require(depositsOf(_payee) > 0, "An investor should have non-negative deposit for withdrawal.");

    RefundeeRecord storage _data = refundees[_payee];
    require(_data.isRefunded == false, "An investor should not be refunded.");

    uint256 payment = deposits[_payee];
    assert(address(this).balance >= payment);

    deposits[_payee] = 0;

    investorsDepositedToCrowdSaleAmount = investorsDepositedToCrowdSaleAmount.sub(payment);

    _payee.transfer(payment);

    emit Withdrawn(_payee, payment);

    _data.isRefunded = true;

    removeRefundeeByIndex(_data.index);
  }

  /**
  @dev Owner can do manual refund here if investore has "BAD" money
  @param _payee address of investor that needs to refund with next manual ETH sending
  */
  function manualRefund(address _payee) public onlyOwner {
    require(depositsOf(_payee) > 0, "An investor should have non-negative deposit for withdrawal.");

    RefundeeRecord storage _data = refundees[_payee];
    require(_data.isRefunded == false, "An investor should not be refunded.");

    deposits[_payee] = 0;
    _data.isRefunded = true;

    removeRefundeeByIndex(_data.index);
  }

  /**
  * @dev Remove refundee referenced index from the internal list
  * @param _indexToDelete An index in an array for deletion
  */
  function removeRefundeeByIndex(uint256 _indexToDelete) private {
    if ((refundeesList.length > 0) && (_indexToDelete < refundeesList.length)) {
      uint256 _lastIndex = refundeesList.length.sub(1);
      refundeesList[_indexToDelete] = refundeesList[_lastIndex];
      refundeesList.length--;
    }
  }
  /**
  * @dev Get refundee list length
  */
  function refundeesListLength() public onlyOwner view returns (uint256) {
    return refundeesList.length;
  }

  /**
  * @dev Auto refund
  * @param _txFee The cost of executing refund code
  */
  function withdrawChunk(uint256 _txFee, uint256 _chunkLength) public onlyOwner returns (uint256, address[]) {
    require(state == State.Refunding, "Funds withdrawal is possible only in the Refunding state.");

    uint256 _refundeesCount = refundeesList.length;
    require(_chunkLength >= _refundeesCount);
    require(_txFee > 0, "Transaction fee should be above zero.");
    require(_refundeesCount > 0, "List of investors should not be empty.");
    uint256 _weiRefunded = 0;
    require(address(this).balance > (_chunkLength.mul(_txFee)), "Account's ballance should allow to pay all tx fees.");
    address[] memory _refundeesListCopy = new address[](_chunkLength);

    uint256 i;
    for (i = 0; i < _chunkLength; i++) {
      address _refundee = refundeesList[i];
      RefundeeRecord storage _data = refundees[_refundee];
      if (_data.isRefunded == false) {
        if (depositsOf(_refundee) > _txFee) {
          uint256 _deposit = depositsOf(_refundee);
          if (_deposit > _txFee) {
            _weiRefunded = _weiRefunded.add(_deposit);
            uint256 _paymentWithoutTxFee = _deposit.sub(_txFee);
            _refundee.transfer(_paymentWithoutTxFee);
            emit Withdrawn(_refundee, _paymentWithoutTxFee);
            _data.isRefunded = true;
            _refundeesListCopy[i] = _refundee;
          }
        }
      }
    }

    for (i = 0; i < _chunkLength; i++) {
      if (address(0) != _refundeesListCopy[i]) {
        RefundeeRecord storage _dataCleanup = refundees[_refundeesListCopy[i]];
        require(_dataCleanup.isRefunded == true, "Investors in this list should be refunded.");
        removeRefundeeByIndex(_dataCleanup.index);
      }
    }

    return (_weiRefunded, _refundeesListCopy);
  }

  /**
  * @dev Auto refund
  * @param _txFee The cost of executing refund code
  */
  function withdrawEverything(uint256 _txFee) public onlyOwner returns (uint256, address[]) {
    require(state == State.Refunding, "Funds withdrawal is possible only in the Refunding state.");
    return withdrawChunk(_txFee, refundeesList.length);
  }

  /**
  * @dev Withdraws the part of beneficiary's funds.
  */
  function beneficiaryWithdrawChunk(uint256 _value) public onlyOwner {
    require(_value <= address(this).balance, "Withdraw part can not be more than current balance");
    beneficiaryDepositedAmount = beneficiaryDepositedAmount.sub(_value);
    beneficiary.transfer(_value);
  }

  /**
  * @dev Withdraws all beneficiary's funds.
  */
  function beneficiaryWithdrawAll() public onlyOwner {
    uint256 _value = address(this).balance;
    beneficiaryDepositedAmount = beneficiaryDepositedAmount.sub(_value);
    beneficiary.transfer(_value);
  }

}