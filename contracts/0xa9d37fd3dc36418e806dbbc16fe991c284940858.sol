pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;
// File: contracts/src/shared/interfaces/CollateralizerInterface.sol




contract CollateralizerInterface {

	function unpackCollateralParametersFromBytes(
		bytes32 parameters
	) public pure returns (uint, uint, uint);

}

// File: contracts/src/shared/interfaces/DebtKernelInterface.sol



contract DebtKernelInterface {

	enum Errors {
		// Debt has been already been issued
		DEBT_ISSUED,
		// Order has already expired
		ORDER_EXPIRED,
		// Debt issuance associated with order has been cancelled
		ISSUANCE_CANCELLED,
		// Order has been cancelled
		ORDER_CANCELLED,
		// Order parameters specify amount of creditor / debtor fees
		// that is not equivalent to the amount of underwriter / relayer fees
		ORDER_INVALID_INSUFFICIENT_OR_EXCESSIVE_FEES,
		// Order parameters specify insufficient principal amount for
		// debtor to at least be able to meet his fees
		ORDER_INVALID_INSUFFICIENT_PRINCIPAL,
		// Order parameters specify non zero fee for an unspecified recipient
		ORDER_INVALID_UNSPECIFIED_FEE_RECIPIENT,
		// Order signatures are mismatched / malformed
		ORDER_INVALID_NON_CONSENSUAL,
		// Insufficient balance or allowance for principal token transfer
		CREDITOR_BALANCE_OR_ALLOWANCE_INSUFFICIENT
	}

	// solhint-disable-next-line var-name-mixedcase
	address public TOKEN_TRANSFER_PROXY;
	bytes32 constant public NULL_ISSUANCE_HASH = bytes32(0);

	/* NOTE(kayvon): Currently, the `view` keyword does not actually enforce the
	static nature of the method; this will change in the future, but for now, in
	order to prevent reentrancy we'll need to arbitrarily set an upper bound on
	the gas limit allotted for certain method calls. */
	uint16 constant public EXTERNAL_QUERY_GAS_LIMIT = 8000;

	mapping (bytes32 => bool) public issuanceCancelled;
	mapping (bytes32 => bool) public debtOrderCancelled;

	event LogDebtOrderFilled(
		bytes32 indexed _agreementId,
		uint _principal,
		address _principalToken,
		address indexed _underwriter,
		uint _underwriterFee,
		address indexed _relayer,
		uint _relayerFee
	);

	event LogIssuanceCancelled(
		bytes32 indexed _agreementId,
		address indexed _cancelledBy
	);

	event LogDebtOrderCancelled(
		bytes32 indexed _debtOrderHash,
		address indexed _cancelledBy
	);

	event LogError(
		uint8 indexed _errorId,
		bytes32 indexed _orderHash
	);

	struct Issuance {
		address version;
		address debtor;
		address underwriter;
		uint underwriterRiskRating;
		address termsContract;
		bytes32 termsContractParameters;
		uint salt;
		bytes32 agreementId;
	}

	struct DebtOrder {
		Issuance issuance;
		uint underwriterFee;
		uint relayerFee;
		uint principalAmount;
		address principalToken;
		uint creditorFee;
		uint debtorFee;
		address relayer;
		uint expirationTimestampInSec;
		bytes32 debtOrderHash;
	}

    function fillDebtOrder(
        address creditor,
        address[6] orderAddresses,
        uint[8] orderValues,
        bytes32[1] orderBytes32,
        uint8[3] signaturesV,
        bytes32[3] signaturesR,
        bytes32[3] signaturesS
    )
        public
        returns (bytes32 _agreementId);

}

// File: contracts/src/shared/interfaces/DebtTokenInterface.sol



contract DebtTokenInterface {

    function transfer(address _to, uint _tokenId) public;

    function exists(uint256 _tokenId) public view returns (bool);

}

// File: contracts/src/shared/interfaces/TokenTransferProxyInterface.sol



contract TokenTransferProxyInterface {}

// File: contracts/src/shared/interfaces/ContractRegistryInterface.sol







contract ContractRegistryInterface {

    CollateralizerInterface public collateralizer;
    DebtKernelInterface public debtKernel;
    DebtTokenInterface public debtToken;
    TokenTransferProxyInterface public tokenTransferProxy;

    function ContractRegistryInterface(
        address _collateralizer,
        address _debtKernel,
        address _debtToken,
        address _tokenTransferProxy
    )
        public
    {
        collateralizer = CollateralizerInterface(_collateralizer);
        debtKernel = DebtKernelInterface(_debtKernel);
        debtToken = DebtTokenInterface(_debtToken);
        tokenTransferProxy = TokenTransferProxyInterface(_tokenTransferProxy);
    }

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
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: contracts/src/shared/libraries/SignaturesLibrary.sol




contract SignaturesLibrary {
	bytes constant internal PREFIX = "\x19Ethereum Signed Message:\n32";

	struct ECDSASignature {
		uint8 v;
		bytes32 r;
		bytes32 s;
	}

	function isValidSignature(
		address signer,
		bytes32 hash,
		ECDSASignature signature
	)
		public
		pure
		returns (bool valid)
	{
		bytes32 prefixedHash = keccak256(PREFIX, hash);
		return ecrecover(prefixedHash, signature.v, signature.r, signature.s) == signer;
	}
}

// File: contracts/src/shared/libraries/OrderLibrary.sol




contract OrderLibrary {
	struct DebtOrder {
		address kernelVersion;
		address issuanceVersion;
		uint principalAmount;
		address principalToken;
		uint collateralAmount;
		address collateralToken;
		address debtor;
		uint debtorFee;
		address creditor;
		uint creditorFee;
		address relayer;
		uint relayerFee;
		address underwriter;
		uint underwriterFee;
		uint underwriterRiskRating;
		address termsContract;
		bytes32 termsContractParameters;
		uint expirationTimestampInSec;
		uint salt;
		SignaturesLibrary.ECDSASignature debtorSignature;
		SignaturesLibrary.ECDSASignature creditorSignature;
		SignaturesLibrary.ECDSASignature underwriterSignature;
	}

	function unpackDebtOrder(DebtOrder memory order)
		public
		pure
		returns (
	        address[6] orderAddresses,
	        uint[8] orderValues,
	        bytes32[1] orderBytes32,
	        uint8[3] signaturesV,
	        bytes32[3] signaturesR,
	        bytes32[3] signaturesS
		)
	{
		return (
			[order.issuanceVersion, order.debtor, order.underwriter, order.termsContract, order.principalToken, order.relayer],
            [order.underwriterRiskRating, order.salt, order.principalAmount, order.underwriterFee, order.relayerFee, order.creditorFee, order.debtorFee, order.expirationTimestampInSec],
			[order.termsContractParameters],
            [order.debtorSignature.v, order.creditorSignature.v, order.underwriterSignature.v],
			[order.debtorSignature.r, order.creditorSignature.r, order.underwriterSignature.r],
			[order.debtorSignature.s, order.creditorSignature.s, order.underwriterSignature.s]
		);
	}
}

// File: contracts/src/CreditorDrivenLoans/DecisionEngines/libraries/LTVDecisionEngineTypes.sol






contract LTVDecisionEngineTypes
{
	// The parameters used during the consent and decision evaluations.
	struct Params {
		address creditor;
		// The values and signature for the creditor commitment hash.
		CreditorCommitment creditorCommitment;
		// Price feed data.
		Price principalPrice;
		Price collateralPrice;
		// A DebtOrderData is required to confirm parity with the submitted order.
		OrderLibrary.DebtOrder order;
	}

	struct Price {
		uint value;
		uint timestamp;
		address tokenAddress;
		SignaturesLibrary.ECDSASignature signature;
	}

	struct CreditorCommitment {
		CommitmentValues values;
		SignaturesLibrary.ECDSASignature signature;
	}

	struct CommitmentValues {
		uint maxLTV;
		address priceFeedOperator;
	}

	struct SimpleInterestParameters {
		uint principalTokenIndex;
		uint principalAmount;
        uint interestRate;
        uint amortizationUnitType;
        uint termLengthInAmortizationUnits;
	}

	struct CollateralParameters {
		uint collateralTokenIndex;
		uint collateralAmount;
		uint gracePeriodInDays;
	}
}

// File: contracts/src/shared/interfaces/TermsContractInterface.sol




contract TermsContractInterface {

	function registerTermStart(
        bytes32 agreementId,
        address debtor
    ) public returns (bool _success);

	function registerRepayment(
        bytes32 agreementId,
        address payer,
        address beneficiary,
        uint256 unitsOfRepayment,
        address tokenAddress
    ) public returns (bool _success);

	function getExpectedRepaymentValue(
        bytes32 agreementId,
        uint256 timestamp
    ) public view returns (uint256);

	function getValueRepaidToDate(
        bytes32 agreementId
    ) public view returns (uint256);

	function getTermEndTimestamp(
        bytes32 _agreementId
    ) public view returns (uint);

}

// File: contracts/src/shared/interfaces/SimpleInterestTermsContractInterface.sol




contract SimpleInterestTermsContractInterface is TermsContractInterface {

    function unpackParametersFromBytes(
        bytes32 parameters
    ) public pure returns (
        uint _principalTokenIndex,
        uint _principalAmount,
        uint _interestRate,
        uint _amortizationUnitType,
        uint _termLengthInAmortizationUnits
    );

}

// File: contracts/src/CreditorDrivenLoans/DecisionEngines/LTVDecisionEngine.sol



// External dependencies


// Libraries




// Interfaces




contract LTVDecisionEngine is LTVDecisionEngineTypes, SignaturesLibrary, OrderLibrary
{
	using SafeMath for uint;

	uint public constant PRECISION = 4;

	uint public constant MAX_PRICE_TTL_IN_SECONDS = 600;

	ContractRegistryInterface public contractRegistry;

	function LTVDecisionEngine(address _contractRegistry) public {
        contractRegistry = ContractRegistryInterface(_contractRegistry);
    }

	function evaluateConsent(Params params, bytes32 commitmentHash)
		public view returns (bool)
	{
		// Checks that the given creditor values were signed by the creditor.
		if (!isValidSignature(
			params.creditor,
			commitmentHash,
			params.creditorCommitment.signature
		)) {
			// We return early if the creditor values were not signed correctly.
			return false;
		}

		// Checks that the given price feed data was signed by the price feed operator.
		return (
			verifyPrices(
				params.creditorCommitment.values.priceFeedOperator,
				params.principalPrice,
				params.collateralPrice
			)
		);
	}

	// Returns true if the creditor-initiated order has not expired, and the LTV is below the max.
	function evaluateDecision(Params memory params)
		public view returns (bool _success)
	{
		LTVDecisionEngineTypes.Price memory principalTokenPrice = params.principalPrice;
		LTVDecisionEngineTypes.Price memory collateralTokenPrice = params.collateralPrice;

		uint maxLTV = params.creditorCommitment.values.maxLTV;
		OrderLibrary.DebtOrder memory order = params.order;

		uint collateralValue = collateralTokenPrice.value;

		if (isExpired(order.expirationTimestampInSec)) {
			return false;
		}

		if (order.collateralAmount == 0 || collateralValue == 0) {
			return false;
		}

		uint ltv = computeLTV(
			principalTokenPrice.value,
			collateralTokenPrice.value,
			order.principalAmount,
			order.collateralAmount
		);

		uint maxLTVWithPrecision = maxLTV.mul(10 ** (PRECISION.sub(2)));

		return ltv <= maxLTVWithPrecision;
	}

	function hashCreditorCommitmentForOrder(CommitmentValues commitmentValues, OrderLibrary.DebtOrder order)
	public view returns (bytes32)
	{
		bytes32 termsContractCommitmentHash =
			getTermsContractCommitmentHash(order.termsContract, order.termsContractParameters);

		return keccak256(
			// order values
			order.creditor,
			order.kernelVersion,
			order.issuanceVersion,
			order.termsContract,
			order.principalToken,
			order.salt,
			order.principalAmount,
			order.creditorFee,
			order.expirationTimestampInSec,
			// commitment values
			commitmentValues.maxLTV,
			commitmentValues.priceFeedOperator,
			// hashed terms contract commitments
			termsContractCommitmentHash
		);
	}

	function getTermsContractCommitmentHash(
		address termsContract,
		bytes32 termsContractParameters
	) public view returns (bytes32) {
		SimpleInterestParameters memory simpleInterestParameters =
			unpackSimpleInterestParameters(termsContract, termsContractParameters);

		CollateralParameters memory collateralParameters =
			unpackCollateralParameters(termsContractParameters);

		return keccak256(
			// unpacked termsContractParameters
			simpleInterestParameters.principalTokenIndex,
			simpleInterestParameters.principalAmount,
			simpleInterestParameters.interestRate,
			simpleInterestParameters.amortizationUnitType,
			simpleInterestParameters.termLengthInAmortizationUnits,
			collateralParameters.collateralTokenIndex,
			collateralParameters.gracePeriodInDays
		);
	}

	function unpackSimpleInterestParameters(
		address termsContract,
		bytes32 termsContractParameters
	)
		public pure returns (SimpleInterestParameters)
	{
		// use simple interest terms contract interface to unpack simple interest terms
		SimpleInterestTermsContractInterface simpleInterestTermsContract = SimpleInterestTermsContractInterface(termsContract);

		var (principalTokenIndex, principalAmount, interestRate, amortizationUnitType, termLengthInAmortizationUnits) =
			simpleInterestTermsContract.unpackParametersFromBytes(termsContractParameters);

		return SimpleInterestParameters({
			principalTokenIndex: principalTokenIndex,
			principalAmount: principalAmount,
			interestRate: interestRate,
			amortizationUnitType: amortizationUnitType,
			termLengthInAmortizationUnits: termLengthInAmortizationUnits
		});
	}

	function unpackCollateralParameters(
		bytes32 termsContractParameters
	)
		public view returns (CollateralParameters)
	{
		CollateralizerInterface collateralizer = CollateralizerInterface(contractRegistry.collateralizer());

		var (collateralTokenIndex, collateralAmount, gracePeriodInDays) =
			collateralizer.unpackCollateralParametersFromBytes(termsContractParameters);

		return CollateralParameters({
			collateralTokenIndex: collateralTokenIndex,
			collateralAmount: collateralAmount,
			gracePeriodInDays: gracePeriodInDays
		});
	}

	function verifyPrices(
		address priceFeedOperator,
		LTVDecisionEngineTypes.Price principalPrice,
		LTVDecisionEngineTypes.Price collateralPrice
	)
		internal view returns (bool)
	{
		uint minPriceTimestamp = block.timestamp - MAX_PRICE_TTL_IN_SECONDS;

		if (principalPrice.timestamp < minPriceTimestamp ||
			collateralPrice.timestamp < minPriceTimestamp) {
			return false;
		}

		bytes32 principalPriceHash = keccak256(
			principalPrice.value,
			principalPrice.tokenAddress,
			principalPrice.timestamp
		);

		bytes32 collateralPriceHash = keccak256(
			collateralPrice.value,
			collateralPrice.tokenAddress,
			collateralPrice.timestamp
		);

		bool principalPriceValid = isValidSignature(
			priceFeedOperator,
			principalPriceHash,
			principalPrice.signature
		);

		// We return early if the principal price information was not signed correctly.
		if (!principalPriceValid) {
			return false;
		}

		return isValidSignature(
			priceFeedOperator,
			collateralPriceHash,
			collateralPrice.signature
		);
	}

	function computeLTV(
		uint principalTokenPrice,
		uint collateralTokenPrice,
		uint principalAmount,
		uint collateralAmount
	)
		internal constant returns (uint)
	{
		uint principalValue = principalTokenPrice.mul(principalAmount).mul(10 ** PRECISION);
		uint collateralValue = collateralTokenPrice.mul(collateralAmount);

		return principalValue.div(collateralValue);
	}

	function isExpired(uint expirationTimestampInSec)
		internal view returns (bool expired)
	{
		return expirationTimestampInSec < block.timestamp;
	}
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: contracts/src/CreditorDrivenLoans/libraries/CreditorProxyErrors.sol

contract CreditorProxyErrors {
    enum Errors {
            DEBT_OFFER_CANCELLED,
            DEBT_OFFER_ALREADY_FILLED,
            DEBT_OFFER_NON_CONSENSUAL,
            CREDITOR_BALANCE_OR_ALLOWANCE_INSUFFICIENT,
            DEBT_OFFER_CRITERIA_NOT_MET
        }

    event CreditorProxyError(
        uint8 indexed _errorId,
        address indexed _creditor,
        bytes32 indexed _creditorCommitmentHash
    );
}

// File: contracts/src/CreditorDrivenLoans/libraries/CreditorProxyEvents.sol



contract CreditorProxyEvents {

    event DebtOfferCancelled(
        address indexed _creditor,
        bytes32 indexed _creditorCommitmentHash
    );

    event DebtOfferFilled(
        address indexed _creditor,
        bytes32 indexed _creditorCommitmentHash,
        bytes32 indexed _agreementId
    );
}

// File: contracts/src/CreditorDrivenLoans/interfaces/CreditorProxyCoreInterface.sol






contract CreditorProxyCoreInterface is CreditorProxyErrors, CreditorProxyEvents { }

// File: contracts/src/CreditorDrivenLoans/CreditorProxyCore.sol



// External libraries

// Internal interfaces

// Shared interfaces



contract CreditorProxyCore is CreditorProxyCoreInterface {

	uint16 constant public EXTERNAL_QUERY_GAS_LIMIT = 8000;

	ContractRegistryInterface public contractRegistry;

	/**
	 * Helper function for transferring a specified amount of tokens between two parties.
	 */
	function transferTokensFrom(
		address _token,
		address _from,
		address _to,
		uint _amount
	)
		internal
		returns (bool _success)
	{
		return ERC20(_token).transferFrom(_from, _to, _amount);
	}

	/**
     * Helper function for querying this contract's allowance for transferring the given token.
     */
	function getAllowance(
		address token,
		address owner,
		address granter
	)
		internal
		view
	returns (uint _allowance)
	{
		// Limit gas to prevent reentrancy.
		return ERC20(token).allowance.gas(EXTERNAL_QUERY_GAS_LIMIT)(
			owner,
			granter
		);
	}
}

// File: contracts/src/CreditorDrivenLoans/LTVCreditorProxy.sol



// Internal interfaces

// Internal mixins




contract LTVCreditorProxy is CreditorProxyCore, LTVDecisionEngine {

	mapping (bytes32 => bool) public debtOfferCancelled;
	mapping (bytes32 => bool) public debtOfferFilled;

	bytes32 constant internal NULL_ISSUANCE_HASH = bytes32(0);

	function LTVCreditorProxy(address _contractRegistry) LTVDecisionEngine(_contractRegistry)
		public
	{
		contractRegistry = ContractRegistryInterface(_contractRegistry);
	}

	function fillDebtOffer(LTVDecisionEngineTypes.Params params)
		public returns (bytes32 agreementId)
	{
		OrderLibrary.DebtOrder memory order = params.order;
		CommitmentValues memory commitmentValues = params.creditorCommitment.values;

		bytes32 creditorCommitmentHash = hashCreditorCommitmentForOrder(commitmentValues, order);

		if (!evaluateConsent(params, creditorCommitmentHash)) {
			emit CreditorProxyError(uint8(Errors.DEBT_OFFER_NON_CONSENSUAL), order.creditor, creditorCommitmentHash);
			return NULL_ISSUANCE_HASH;
		}

		if (debtOfferFilled[creditorCommitmentHash]) {
			emit CreditorProxyError(uint8(Errors.DEBT_OFFER_ALREADY_FILLED), order.creditor, creditorCommitmentHash);
			return NULL_ISSUANCE_HASH;
		}

		if (debtOfferCancelled[creditorCommitmentHash]) {
			emit CreditorProxyError(uint8(Errors.DEBT_OFFER_CANCELLED), order.creditor, creditorCommitmentHash);
			return NULL_ISSUANCE_HASH;
		}

		if (!evaluateDecision(params)) {
			emit CreditorProxyError(
				uint8(Errors.DEBT_OFFER_CRITERIA_NOT_MET),
				order.creditor,
				creditorCommitmentHash
			);
			return NULL_ISSUANCE_HASH;
		}

		address principalToken = order.principalToken;

		// The allowance that the token transfer proxy has for this contract's tokens.
		uint tokenTransferAllowance = getAllowance(
			principalToken,
			address(this),
			contractRegistry.tokenTransferProxy()
		);

		uint totalCreditorPayment = order.principalAmount.add(order.creditorFee);

		// Ensure the token transfer proxy can transfer tokens from the creditor proxy
		if (tokenTransferAllowance < totalCreditorPayment) {
			require(setTokenTransferAllowance(principalToken, totalCreditorPayment));
		}

		// Transfer principal from creditor to CreditorProxy
		if (totalCreditorPayment > 0) {
			require(
				transferTokensFrom(
					principalToken,
					order.creditor,
					address(this),
					totalCreditorPayment
				)
			);
		}

		agreementId = sendOrderToKernel(order);

		require(agreementId != NULL_ISSUANCE_HASH);

		debtOfferFilled[creditorCommitmentHash] = true;

		contractRegistry.debtToken().transfer(order.creditor, uint256(agreementId));

		emit DebtOfferFilled(order.creditor, creditorCommitmentHash, agreementId);

		return agreementId;
	}

	function sendOrderToKernel(DebtOrder memory order) internal returns (bytes32 id)
	{
		address[6] memory orderAddresses;
		uint[8] memory orderValues;
		bytes32[1] memory orderBytes32;
		uint8[3] memory signaturesV;
		bytes32[3] memory signaturesR;
		bytes32[3] memory signaturesS;

		(orderAddresses, orderValues, orderBytes32, signaturesV, signaturesR, signaturesS) = unpackDebtOrder(order);

		return contractRegistry.debtKernel().fillDebtOrder(
			address(this),
			orderAddresses,
			orderValues,
			orderBytes32,
			signaturesV,
			signaturesR,
			signaturesS
		);
	}

	function cancelDebtOffer(LTVDecisionEngineTypes.Params params) public returns (bool) {
		LTVDecisionEngineTypes.CommitmentValues memory commitmentValues = params.creditorCommitment.values;
		OrderLibrary.DebtOrder memory order = params.order;

		// sender must be the creditor.
		require(msg.sender == order.creditor);

		bytes32 creditorCommitmentHash = hashCreditorCommitmentForOrder(commitmentValues, order);

		// debt offer must not already be filled.
		require(!debtOfferFilled[creditorCommitmentHash]);

		debtOfferCancelled[creditorCommitmentHash] = true;

		emit DebtOfferCancelled(order.creditor, creditorCommitmentHash);

		return true;
	}

	/**
     * Helper function for approving this address' allowance to Dharma's token transfer proxy.
     */
	function setTokenTransferAllowance(
		address token,
		uint amount
	)
		internal
		returns (bool _success)
	{
		return ERC20(token).approve(
			address(contractRegistry.tokenTransferProxy()),
			amount
		);
	}
}