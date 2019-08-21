pragma solidity ^0.4.15;

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

contract Finalizable is Ownable {

	bool public isFinalized = false;

	event Finalized();

	function finalize() onlyOwner public {
		require (!isFinalized);
		//require (hasEnded());

		finalization();
		Finalized();

		isFinalized = true ;
	}

	function finalization() internal {

	}
}

contract TopiaCoinSAFTSale is Ownable, Finalizable {

	event PaymentExpected(bytes8 paymentIdentifier); // Event
	event PaymentExpectationCancelled(bytes8 paymentIdentifier); // Event
	event PaymentSubmitted(address payor, bytes8 paymentIdentifier, uint256 paymentAmount); // Event
	event PaymentAccepted(address payor, bytes8 paymentIdentifier, uint256 paymentAmount); // Event
	event PaymentRejected(address payor, bytes8 paymentIdentifier, uint256 paymentAmount); // Event
	event UnableToAcceptPayment(address payor, bytes8 paymentIdentifier, uint256 paymentAmount); // Event
	event UnableToRejectPayment(address payor, bytes8 paymentIdentifier, uint256 paymentAmount); // Event
	
	event SalesWalletUpdated(address oldWalletAddress, address newWalletAddress); // Event
	event PaymentManagerUpdated(address oldPaymentManager, address newPaymentManager); // Event

	event SaleOpen(); // Event
	event SaleClosed(); // Event

	mapping (bytes8 => Payment) payments;
	address salesWallet = 0x0;
	address paymentManager = 0x0;
	bool public saleStarted = false;

	// Structure for storing payment infromation
	struct Payment {
		address from;
		bytes8 paymentIdentifier;
		bytes32 paymentHash;
		uint256 paymentAmount;
		uint date;
		uint8 status; 
	}

	uint8 PENDING_STATUS = 10;
	uint8 PAID_STATUS = 20;
	uint8 ACCEPTED_STATUS = 22;
	uint8 REJECTED_STATUS = 40;

	modifier onlyOwnerOrManager() {
		require(msg.sender == owner || msg.sender == paymentManager);
		_;
	}

	function TopiaCoinSAFTSale(address _salesWallet, address _paymentManager) 
		Ownable () 
	{
		require (_salesWallet != 0x0);

		salesWallet = _salesWallet;
		paymentManager = _paymentManager;
		saleStarted = false;
	}

	// Updates the wallet to which all payments are sent.
	function updateSalesWallet(address _salesWallet) onlyOwner {
		require(_salesWallet != 0x0) ;
		require(_salesWallet != salesWallet);

		address oldWalletAddress = salesWallet ;
		salesWallet = _salesWallet;

		SalesWalletUpdated(oldWalletAddress, _salesWallet);
	}

	// Updates the wallet to which all payments are sent.
	function updatePaymentManager(address _paymentManager) onlyOwner {
		require(_paymentManager != 0x0) ;
		require(_paymentManager != paymentManager);

		address oldPaymentManager = paymentManager ;
		paymentManager = _paymentManager;

		PaymentManagerUpdated(oldPaymentManager, _paymentManager);
	}

	// Updates the state of the contact so that it will start accepting payments.
	function startSale() onlyOwner {
		require (!saleStarted);
		require (!isFinalized);

		saleStarted = true;
		SaleOpen();
	}

	// Instructs the contract that it should expect a payment with the given identifier to be made.
	function expectPayment(bytes8 _paymentIdentifier, bytes32 _paymentHash) onlyOwnerOrManager {
		// Sale must be running in order to expect payments
		require (saleStarted);
		require (!isFinalized);

		// Sanity check the parameters
		require (_paymentIdentifier != 0x0);

		// Look up the payment identifier.  We expect to find an empty Payment record.
		Payment storage p = payments[_paymentIdentifier];

		require (p.status == 0);
		require (p.from == 0x0);

		p.paymentIdentifier = _paymentIdentifier;
		p.paymentHash = _paymentHash;
		p.date = now;
		p.status = PENDING_STATUS;

		payments[_paymentIdentifier] = p;

		PaymentExpected(_paymentIdentifier);
	}

	// Instruct the contract should stop expecting a payment with the given identifier
	function cancelExpectedPayment(bytes8 _paymentIdentifier) onlyOwnerOrManager {
				// Sale must be running in order to expect payments
		require (saleStarted);
		require (!isFinalized);

		// Sanity check the parameters
		require (_paymentIdentifier != 0x0);

		// Look up the payment identifier.  We expect to find an empty Payment record.
		Payment storage p = payments[_paymentIdentifier];

		require(p.paymentAmount == 0);
		require(p.status == 0 || p.status == 10);

		p.paymentIdentifier = 0x0;
		p.paymentHash = 0x0;
		p.date = 0;
		p.status = 0;

		payments[_paymentIdentifier] = p;

		PaymentExpectationCancelled(_paymentIdentifier);
	}

	// Submits a payment to the contract with the spcified payment identifier.  If the contract is
	// not expecting the specified payment, then the payment is held.  Expected payemnts are automatically
	// accepted and forwarded to the sales wallet.
	function submitPayment(bytes8 _paymentIdentifier, uint32 nonce) payable {
		require (saleStarted);
		require (!isFinalized);

		// Sanity Check the Parameters
		require (_paymentIdentifier != 0x0);

		Payment storage p = payments[_paymentIdentifier];

		require (p.status == PENDING_STATUS);
		require (p.from == 0x0);
		require (p.paymentHash != 0x0);
		require (msg.value > 0);

		// Calculate the Payment Hash and insure it matches the expected hash
		require (p.paymentHash == calculateHash(_paymentIdentifier, msg.value, nonce)) ;

		bool forwardPayment = (p.status == PENDING_STATUS);
		
		p.from = msg.sender;
		p.paymentIdentifier = _paymentIdentifier;
		p.date = now;
		p.paymentAmount = msg.value;
		p.status = PAID_STATUS;

		payments[_paymentIdentifier] = p;

		PaymentSubmitted (p.from, p.paymentIdentifier, p.paymentAmount);

		if ( forwardPayment ) {
			sendPaymentToWallet (p) ;
		}
	}

	// Accepts a pending payment and forwards the payment amount to the sales wallet.
	function acceptPayment(bytes8 _paymentIdentifier) onlyOwnerOrManager {
		// Sanity Check the Parameters
		require (_paymentIdentifier != 0x0);

		Payment storage p = payments[_paymentIdentifier];

		require (p.from != 0x0) ;
		require (p.status == PAID_STATUS);

		sendPaymentToWallet(p);
	}

	// Rejects a pending payment and returns the payment to the payer.
	function rejectPayment(bytes8 _paymentIdentifier) onlyOwnerOrManager {
		// Sanity Check the Parameters
		require (_paymentIdentifier != 0x0);

		Payment storage p = payments[_paymentIdentifier] ;

		require (p.from != 0x0) ;
		require (p.status == PAID_STATUS);

		refundPayment(p) ;
	}

	// ******** Utility Methods ********
	// Might be removed before deploying the Smart Contract Live.

	// Returns the payment information for a particular payment identifier.
	function verifyPayment(bytes8 _paymentIdentifier) constant onlyOwnerOrManager returns (address from, uint256 paymentAmount, uint date, bytes32 paymentHash, uint8 status)  {
		Payment storage payment = payments[_paymentIdentifier];

		return (payment.from, payment.paymentAmount, payment.date, payment.paymentHash, payment.status);
	}

	// Kills this contract.  Used only during debugging.
	// TODO: Remove this method before deploying Smart Contract.
	function kill() onlyOwner {
		selfdestruct(msg.sender);
	}

	// ******** Internal Methods ********

	// Internal function that transfers the ether sent with a payment on to the sales wallet.
	function sendPaymentToWallet(Payment _payment) internal {

		if ( salesWallet.send(_payment.paymentAmount) ) {
			_payment.status = ACCEPTED_STATUS;

			payments[_payment.paymentIdentifier] = _payment;

			PaymentAccepted (_payment.from, _payment.paymentIdentifier, _payment.paymentAmount);
		} else {
			UnableToAcceptPayment (_payment.from, _payment.paymentIdentifier, _payment.paymentAmount);
		}
	}

	// Internal function that transfers the ether sent with a payment back to the sender.
	function refundPayment(Payment _payment) internal {
		if ( _payment.from.send(_payment.paymentAmount)  ) {
			_payment.status = REJECTED_STATUS;

			payments[_payment.paymentIdentifier] = _payment;

			PaymentRejected (_payment.from, _payment.paymentIdentifier, _payment.paymentAmount);
		} else {
			UnableToRejectPayment (_payment.from, _payment.paymentIdentifier, _payment.paymentAmount);
		}
	}

	// Calculates the hash for the provided payment information.
	// TODO: Make this method internal before deploying Smart Contract.
	function calculateHash(bytes8 _paymentIdentifier, uint256 _amount, uint32 _nonce) constant returns (bytes32 hash) {
		return sha3(_paymentIdentifier, _amount, _nonce);
	}

	function finalization() internal {
		saleStarted = false;
		SaleClosed();
	}
}