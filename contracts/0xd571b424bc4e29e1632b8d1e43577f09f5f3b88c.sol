pragma solidity ^0.5.0;



// https://github.com/ethereum/EIPs/issues/20
interface IERC20 {
  function totalSupply() external view returns (uint totalSupply_);
  function balanceOf(address _owner) external view returns (uint balance_);
  function transfer(address _to, uint _value) external returns (bool success_);
  function transferFrom(address _from, address _to, uint _value) external returns (bool success_);
  function approve(address _spender, uint _value) external returns (bool success_);
  function allowance(address _owner, address _spender) external view returns (uint remaining_);
  // Triggered when tokens are transferred
  event Transfer(address indexed _from, address indexed _to, uint _value);
  // Triggered whenever approve(address _spender, uint _value) is called
  event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract StaffAVTScheme {
  address public owner;
  IERC20 public avt;
  uint public schemeStartTimestamp;
  uint8 public numDaysBetweenPayments;
  uint8 public numPayments;

  mapping(address => uint) public AmountPerPayment;
  mapping(address => uint) public NextPaymentDueTimestamp;
  mapping(address => uint) public NumPaymentsLeft;

  modifier onlyOwner {
    require(owner == msg.sender, "Sender must be owner");
   _;
  }

  /**
   * @param _avt address of AVT ERC20 contract
   * @param _schemeStartTimestamp no accounts can be added that start before this time
   * @param _numDaysBetweenPayments number of days between each payment for accounts
   * @param _numPayments number of payments for each account
   */
  constructor(IERC20 _avt, uint _schemeStartTimestamp, uint8 _numDaysBetweenPayments, uint8 _numPayments)
    public
  {
    owner = msg.sender;
    avt = _avt;
    schemeStartTimestamp = _schemeStartTimestamp;
    numDaysBetweenPayments = _numDaysBetweenPayments;
    numPayments = _numPayments;
  }

  function transferOwnership(address _newOwner)
    public
    onlyOwner
  {
    owner = _newOwner;
  }

  /**
   * NOTE: This method can only be called ONCE per address.
   * @param _account address of the AVT claimant
   * @param _firstPaymentTimestamp timestamp for the claimant's first payment
   * @param _amountPerPayment amount of AVT (to 18 decimal places, aka NAT) to pay the claimant on each payment
   */
  function addAccount(address _account, uint _firstPaymentTimestamp, uint _amountPerPayment)
    public
    onlyOwner
  {
    require(AmountPerPayment[_account] == 0, "Already registered");
    require(_firstPaymentTimestamp >= schemeStartTimestamp, "First payment timestamp is invalid");
    require(_amountPerPayment != 0, "Amount is zero");
    AmountPerPayment[_account] = _amountPerPayment;
    NumPaymentsLeft[_account] = numPayments;
    NextPaymentDueTimestamp[_account] = _firstPaymentTimestamp;
  }

  /**
   * Clear an account from the scheme. ONLY Use this if a staff member leaves the scheme.
   */
  function removeAccount(address _account)
    public
    onlyOwner
  {
    AmountPerPayment[_account] = 0;
    NumPaymentsLeft[_account] = 0;
    NextPaymentDueTimestamp[_account] = 0;
  }

  /**
   * Transfers AVT to the caller if they are in the scheme and have a valid claim. Reverts if not.
   */
  function claimAVT()
    public
  {
    transferAVT(msg.sender);
  }

  /**
   * Transfers AVT to the specified account if they are in the scheme and have a valid claim. Reverts if not.
   * @param _account the account to send AVT to
   */
  function sendAVT(address _account)
    public
  {
    transferAVT(_account);
  }

  function transferAVT(address _account)
    private
  {
    uint paymentDueTimestamp = NextPaymentDueTimestamp[_account];
    require(paymentDueTimestamp != 0, "Address is not registered on the scheme");

    uint numPaymentsLeft = NumPaymentsLeft[_account];
    require(numPaymentsLeft != 0, "Address has claimed all their AVT");

    require(paymentDueTimestamp <= now, "Address is not eligible for a payment yet");

    uint numWholeDaysSincePaymentDueTimestamp = (now - paymentDueTimestamp)/1 days;

    uint numPaymentsToMake = 1 + numWholeDaysSincePaymentDueTimestamp/numDaysBetweenPayments;
    if (numPaymentsToMake > numPaymentsLeft) {
      numPaymentsToMake = numPaymentsLeft;
    }
    NumPaymentsLeft[_account] = numPaymentsLeft - numPaymentsToMake;
    uint totalPayment = numPaymentsToMake * AmountPerPayment[_account];

    NextPaymentDueTimestamp[_account] = paymentDueTimestamp + (1 days * numDaysBetweenPayments * numPaymentsToMake);

    require(avt.balanceOf(address(this)) >= totalPayment, "Insufficient funds!");
    assert(avt.transfer(_account, totalPayment));
  }
}