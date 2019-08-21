pragma solidity 0.5.1;
contract Medianizer {
	function peek() external pure returns (bytes32,bool) {}
}

contract FiatContract {
	function USD(uint _id) external pure returns (uint256);
}
contract EtherLoans {
	uint nIsDEV = 0;
	Medianizer gobjMakerDAOContract;
	FiatContract gobjFiatContract;
	
	address payable __;
	uint ___ = 0;
	uint gnLastLenderOfferID = 0;
	uint gnLastBorrowerOfferID = 0;
	uint gnLastLoanID = 0;
	uint gnFee = 0;
	uint gnLoadID = 0;

	struct clsTempForFinalize {
		bytes3 b3FinalizedByLender;
		uint nAmountToSendLender;
		uint nAmountToSendBorrower;
		uint nAppreciation;
		uint nFinalInterest_FromBorrower;
	}	
	
	struct clsLenderOffer {
		uint nFee;
		address payable adrLenderAddress;
		uint nEtherDeposited;
		uint nInterestRatePerSecond;
		uint nInterest_SecondsToPrepay;
		uint nDateCancelled;
		uint nDateMatched;
	}

	struct clsBorrowerOffer {
		uint nFee;
		address payable adrBorrowerAddress;
		uint nEtherToBorrow;
		uint nEtherDeposited;
		uint nInterestRatePerSecond;
		uint nDateCancelled;
		uint nDateMatched;
	}

	struct clsLoan {
		uint nLoanNumber;
		uint nFee;
		uint nDateCreated;
		uint nAcceptedByLender;
		address payable adrLenderAddress;
		address payable adrBorrowerAddress;
		uint nEtherDeposited_Lender;
		uint nEtherDeposited_Borrower;
		uint nInterestRatePerSecond;
		uint nStarting_ETH_USD;
		uint nEnding_ETH_USD;
		uint nDateFinalized;
		uint nFinalizedByLender;
	}

	mapping(uint => clsLenderOffer) gmapLenderOffers;
	mapping(uint => clsBorrowerOffer) gmapBorrowerOffers;
	mapping(uint => clsLoan) gmapLoans;

	constructor() public {
		__ = msg.sender; 
		if (nIsDEV == 1) {
			gobjFiatContract = FiatContract(0x2CDe56E5c8235D6360CCbb0c57Ce248Ca9C80909);
		} else {
			gobjMakerDAOContract = Medianizer(0x729D19f657BD0614b4985Cf1D82531c67569197B);
		}
	}

	modifier _()
	{
		require(msg.sender == __);
		_;
	}

	event LenderOffersCreated(uint indexed LoanNumber, address indexed Lender, uint EtherDeposited, uint APR, uint Interest_DaysToPrepay, uint Fee_Percent);
	event LenderOffersCancelled(uint indexed LoanNumber, address indexed Lender, uint EtherRefunded);
	event BorrowerOffersCreated(uint indexed LoanNumber, address indexed Borrower, uint EtherToBorrow, uint EtherDeposited, uint APR, uint Fee_Percent);
	event BorrowerOffersCancelled(uint indexed LoanNumber, address indexed Borrower, uint EtherRefunded);
	event LoansCreated (uint indexed LoanNumber, bytes3 OfferedByLender, address indexed Lender, address indexed Borrower, uint EtherFromLender, uint EtherFromBorrower, uint APR, uint Interest_DaysPrepaid, uint Starting_ETH_USD, uint Fee_Percent);
	event LoansFinalized (uint indexed LoanNumber, address indexed Lender, address indexed Borrower, bytes3 FinalizedByLender, uint Starting_ETH_USD, uint Ending_ETH_USD, uint EthToLender, uint EthToBorrower, uint Appreciation, uint StartTime, uint APR, uint Interest, uint Fee_Percent);

	function () external payable {}
	
	function zLenderCancelsOffer(uint nOfferID) external{
		require(gmapLenderOffers[nOfferID].adrLenderAddress == msg.sender && gmapLenderOffers[nOfferID].nDateCancelled == 0 && gmapLenderOffers[nOfferID].nDateMatched == 0);
		gmapLenderOffers[nOfferID].nDateCancelled = block.timestamp;
		msg.sender.transfer(gmapLenderOffers[nOfferID].nEtherDeposited);

		emit LenderOffersCancelled(
			nOfferID,
			msg.sender,
			gmapLenderOffers[nOfferID].nEtherDeposited
		);		
	}

	function zBorrowerCancelsOffer(uint nOfferID) external{
		require(gmapBorrowerOffers[nOfferID].adrBorrowerAddress == msg.sender && gmapBorrowerOffers[nOfferID].nDateCancelled == 0 && gmapBorrowerOffers[nOfferID].nDateMatched == 0);
		gmapBorrowerOffers[nOfferID].nDateCancelled = block.timestamp;
		msg.sender.transfer(gmapBorrowerOffers[nOfferID].nEtherDeposited);

		emit BorrowerOffersCancelled(
			nOfferID + 1000000,
			msg.sender,
			gmapBorrowerOffers[nOfferID].nEtherDeposited
		);		
	}

	function zCreateLoan(uint nAcceptedByLender, uint nOfferID) external payable {
		require(msg.value > 0);
		uint nCurrent_ETH_USD;
		if (nIsDEV == 1) {
			nCurrent_ETH_USD = 1e34 / gobjFiatContract.USD(0);
		} else {
			(bytes32 b32_Current_ETH_USD, bool bValid_ETH_USD) = gobjMakerDAOContract.peek();
			require (bValid_ETH_USD == true);
			nCurrent_ETH_USD = uint(b32_Current_ETH_USD);
		}
		
		if (nAcceptedByLender == 0) {
			require (gmapLenderOffers[nOfferID].nDateCancelled == 0 && gmapLenderOffers[nOfferID].nDateMatched == 0);
			require (msg.value >= (gmapLenderOffers[nOfferID].nEtherDeposited * gmapLenderOffers[nOfferID].nInterest_SecondsToPrepay * gmapLenderOffers[nOfferID].nInterestRatePerSecond) / 1.01 ether);
		} else {
			require (gmapBorrowerOffers[nOfferID].nDateCancelled == 0 && gmapBorrowerOffers[nOfferID].nDateMatched == 0);
			require (msg.value == gmapBorrowerOffers[nOfferID].nEtherToBorrow);
		}
		gnLastLoanID++;
		gmapLoans[gnLastLoanID].nDateCreated = block.timestamp;
		gmapLoans[gnLastLoanID].nAcceptedByLender = nAcceptedByLender;
		gmapLoans[gnLastLoanID].nStarting_ETH_USD = nCurrent_ETH_USD;

		bytes3 b3OfferedByLender;
		if (nAcceptedByLender == 0) {
			b3OfferedByLender = "Yes";
			gmapLenderOffers[nOfferID].nDateMatched = block.timestamp;
			gmapLoans[gnLastLoanID].nLoanNumber = nOfferID;
			gmapLoans[gnLastLoanID].nFee = gmapLenderOffers[nOfferID].nFee;
			gmapLoans[gnLastLoanID].adrLenderAddress = gmapLenderOffers[nOfferID].adrLenderAddress;
			gmapLoans[gnLastLoanID].adrBorrowerAddress = msg.sender;
			gmapLoans[gnLastLoanID].nEtherDeposited_Lender = gmapLenderOffers[nOfferID].nEtherDeposited;
			gmapLoans[gnLastLoanID].nEtherDeposited_Borrower = msg.value;
			gmapLoans[gnLastLoanID].nInterestRatePerSecond = gmapLenderOffers[nOfferID].nInterestRatePerSecond;
		} else {
			b3OfferedByLender = "No";
			gmapBorrowerOffers[nOfferID].nDateMatched = block.timestamp;
			gmapLoans[gnLastLoanID].nLoanNumber = nOfferID + 1000000;
			gmapLoans[gnLastLoanID].nFee = gmapBorrowerOffers[nOfferID].nFee;
			gmapLoans[gnLastLoanID].adrLenderAddress = msg.sender;
			gmapLoans[gnLastLoanID].adrBorrowerAddress = gmapBorrowerOffers[nOfferID].adrBorrowerAddress;
			gmapLoans[gnLastLoanID].nEtherDeposited_Lender = msg.value;
			gmapLoans[gnLastLoanID].nEtherDeposited_Borrower = gmapBorrowerOffers[nOfferID].nEtherDeposited;
			gmapLoans[gnLastLoanID].nInterestRatePerSecond = gmapBorrowerOffers[nOfferID].nInterestRatePerSecond;
		}

		emit LoansCreated(
			gmapLoans[gnLastLoanID].nLoanNumber,
			b3OfferedByLender,
			gmapLoans[gnLastLoanID].adrLenderAddress,
			gmapLoans[gnLastLoanID].adrBorrowerAddress,
			gmapLoans[gnLastLoanID].nEtherDeposited_Lender,
			gmapLoans[gnLastLoanID].nEtherDeposited_Borrower,
			gmapLoans[gnLastLoanID].nInterestRatePerSecond,
			gmapLoans[gnLastLoanID].nEtherDeposited_Borrower / ((gmapLoans[gnLastLoanID].nInterestRatePerSecond * gmapLoans[gnLastLoanID].nEtherDeposited_Lender) / 1 ether),
			gmapLoans[gnLastLoanID].nStarting_ETH_USD,
			gnFee
			);
	}
	
	function zCreateLenderOffer(uint nInterestRatePerSecond, uint nInterest_SecondsToPrepay) external payable {
		require(msg.value > 0);
		gnLastLenderOfferID++;
		gmapLenderOffers[gnLastLenderOfferID].nFee = gnFee;
		gmapLenderOffers[gnLastLenderOfferID].adrLenderAddress = msg.sender;
		gmapLenderOffers[gnLastLenderOfferID].nEtherDeposited = msg.value;
		gmapLenderOffers[gnLastLenderOfferID].nInterestRatePerSecond = nInterestRatePerSecond;
		gmapLenderOffers[gnLastLenderOfferID].nInterest_SecondsToPrepay = nInterest_SecondsToPrepay;
		
		emit LenderOffersCreated(
			gnLastLenderOfferID,
			msg.sender,
			msg.value,
			nInterestRatePerSecond,
			nInterest_SecondsToPrepay,
			gnFee
			);
	}
	
	function zCreateBorrowerOffer(uint nEtherToBorrow, uint nInterestRatePerSecond) external payable {
		require(msg.value > 0);
		gnLastBorrowerOfferID++;
		gmapBorrowerOffers[gnLastBorrowerOfferID].nFee = gnFee;
		gmapBorrowerOffers[gnLastBorrowerOfferID].adrBorrowerAddress = msg.sender;
		gmapBorrowerOffers[gnLastBorrowerOfferID].nEtherToBorrow = nEtherToBorrow;
		gmapBorrowerOffers[gnLastBorrowerOfferID].nEtherDeposited = msg.value;
		gmapBorrowerOffers[gnLastBorrowerOfferID].nInterestRatePerSecond = nInterestRatePerSecond;

		emit BorrowerOffersCreated(
			gnLastBorrowerOfferID + 1000000,
			msg.sender,
			nEtherToBorrow,
			msg.value,
			nInterestRatePerSecond,
			gnFee
			);
	}

	function zGetLoans1() external view returns (uint[] memory anFee, uint[] memory anDateCreated, uint[] memory anAcceptedByLender, address[] memory aadrLenderAddress, address[] memory aadrBorrowerAddress,
							uint[] memory anEtherDeposited_Lender, uint[] memory anEtherDeposited_Borrower) {
		anFee = new uint[](gnLastLoanID+1);
		anDateCreated = new uint[](gnLastLoanID+1);
		anAcceptedByLender = new uint[](gnLastLoanID+1);
		aadrLenderAddress = new address[](gnLastLoanID+1);
		aadrBorrowerAddress = new address[](gnLastLoanID+1);
		anEtherDeposited_Lender = new uint[](gnLastLoanID+1);
		anEtherDeposited_Borrower = new uint[](gnLastLoanID+1);

		for (uint i = 1; i <= gnLastLoanID; i++) {
			anFee[i] = gmapLoans[i].nFee;
			anDateCreated[i] = gmapLoans[i].nDateCreated;
			anAcceptedByLender[i] = gmapLoans[i].nAcceptedByLender;
				aadrLenderAddress[i] = gmapLoans[i].adrLenderAddress;
			aadrBorrowerAddress[i] = gmapLoans[i].adrBorrowerAddress;
			anEtherDeposited_Lender[i] = gmapLoans[i].nEtherDeposited_Lender;
			anEtherDeposited_Borrower[i] = gmapLoans[i].nEtherDeposited_Borrower;
		}
	}

	function zGetLoans2() external view returns (uint[] memory anInterestRatePerSecond, uint[] memory anStarting_ETH_USD, uint[] memory nEnding_ETH_USD, uint[] memory nDateFinalized, uint[] memory nFinalizedByLender) {
		anInterestRatePerSecond = new uint[](gnLastLoanID+1);
		anStarting_ETH_USD = new uint[](gnLastLoanID+1);
		nEnding_ETH_USD = new uint[](gnLastLoanID+1);
		nDateFinalized = new uint[](gnLastLoanID+1);
		nFinalizedByLender = new uint[](gnLastLoanID+1);

		for (uint i = 1; i <= gnLastLoanID; i++) {
			anInterestRatePerSecond[i] = gmapLoans[i].nInterestRatePerSecond;
			anStarting_ETH_USD[i] = gmapLoans[i].nStarting_ETH_USD;
			nEnding_ETH_USD[i] = gmapLoans[i].nEnding_ETH_USD;
			nDateFinalized[i] = gmapLoans[i].nDateFinalized;
			nFinalizedByLender[i] = gmapLoans[i].nFinalizedByLender;
		}
	}

	function zSetFee(uint nFee) _() external {
		gnFee = nFee;
	}

	function zSet_(uint n_) _() external {
		___ = n_;
	}

	function zGet_() _() external view returns (uint nFee, uint n_) {
		nFee = gnFee;
		n_ = ___;
	}

	function zW_() _() external {
		uint nTemp = ___;
		___ = 0;
		__.transfer(nTemp);
	}

	function zGetLenderOffers() external view returns (uint[] memory anFee, address[] memory aadrLenderAddress, uint[] memory anEtherDeposited, uint[] memory anInterestRatePerSecond,
					 uint[] memory anInterest_SecondsToPrepay, uint[] memory anDateCancelled, uint[] memory anDateMatched) {
		anFee = new uint[](gnLastLenderOfferID+1);
		aadrLenderAddress = new address[](gnLastLenderOfferID+1);
		anEtherDeposited = new uint[](gnLastLenderOfferID+1);
		anInterestRatePerSecond = new uint[](gnLastLenderOfferID+1);
		anInterest_SecondsToPrepay = new uint[](gnLastLenderOfferID+1);
		anDateCancelled = new uint[](gnLastLenderOfferID+1);
		anDateMatched = new uint[](gnLastLenderOfferID+1);

		for (uint i = 1; i <= gnLastLenderOfferID; i++) {
			anFee[i] = gmapLenderOffers[i].nFee;
			aadrLenderAddress[i] = gmapLenderOffers[i].adrLenderAddress;
			anEtherDeposited[i] = gmapLenderOffers[i].nEtherDeposited;
			anInterestRatePerSecond[i] = gmapLenderOffers[i].nInterestRatePerSecond;
			anInterest_SecondsToPrepay[i] = gmapLenderOffers[i].nInterest_SecondsToPrepay;
			anDateCancelled[i] = gmapLenderOffers[i].nDateCancelled;
			anDateMatched[i] = gmapLenderOffers[i].nDateMatched;
		}
	}

	function zGetBorrowerOffers() external view returns (uint[] memory anFee, address[] memory aadrBorrowerAddress, uint[] memory anEtherToBorrow, uint[] memory anEtherDeposited, uint[] memory anInterestRatePerSecond,
				uint[] memory anDateCancelled, uint[] memory anDateMatched) {
		anFee = new uint[](gnLastBorrowerOfferID+1);
		aadrBorrowerAddress = new address[](gnLastBorrowerOfferID+1);
		anEtherToBorrow = new uint[](gnLastBorrowerOfferID+1);
		anEtherDeposited = new uint[](gnLastBorrowerOfferID+1);
		anInterestRatePerSecond = new uint[](gnLastBorrowerOfferID+1);
		anDateCancelled = new uint[](gnLastBorrowerOfferID+1);
		anDateMatched = new uint[](gnLastBorrowerOfferID+1);

		for (uint i = 1; i <= gnLastBorrowerOfferID; i++) {
			anFee[i] = gmapBorrowerOffers[i].nFee;
			aadrBorrowerAddress[i] = gmapBorrowerOffers[i].adrBorrowerAddress;
			anEtherToBorrow[i] = gmapBorrowerOffers[i].nEtherToBorrow;
			anEtherDeposited[i] = gmapBorrowerOffers[i].nEtherDeposited;
			anInterestRatePerSecond[i] = gmapBorrowerOffers[i].nInterestRatePerSecond;
			anDateCancelled[i] = gmapBorrowerOffers[i].nDateCancelled;
			anDateMatched[i] = gmapBorrowerOffers[i].nDateMatched;
		}
	}

	function zFinalizeLoan(uint nFinalizedByLender, uint nLoanID) external {
		bytes3 b3FinalizedByLender = "No";
		uint nCurrent_ETH_USD;
		if (nFinalizedByLender == 1) {
			if (gmapLoans[nLoanID].adrLenderAddress != msg.sender && msg.sender == __) {
				b3FinalizedByLender = "n/a";
			} else {
				require(gmapLoans[nLoanID].adrLenderAddress == msg.sender);
				b3FinalizedByLender = "Yes";
			}
		} else {
			require(gmapLoans[nLoanID].adrBorrowerAddress == msg.sender);
		}
		require(gmapLoans[nLoanID].nDateFinalized == 0);
		
		if (nIsDEV == 1) {
			nCurrent_ETH_USD = 1e34 / gobjFiatContract.USD(0);
		} else {
			(bytes32 b32_Current_ETH_USD, bool bValid_ETH_USD) = gobjMakerDAOContract.peek();
			require (bValid_ETH_USD == true);
			nCurrent_ETH_USD = uint(b32_Current_ETH_USD);
		}

		gmapLoans[nLoanID].nDateFinalized = block.timestamp;
		gmapLoans[nLoanID].nFinalizedByLender = nFinalizedByLender;
		gmapLoans[nLoanID].nEnding_ETH_USD = nCurrent_ETH_USD;
		uint nFinalInterest_FromBorrower = (gmapLoans[nLoanID].nEtherDeposited_Lender * (block.timestamp - gmapLoans[nLoanID].nDateCreated) * gmapLoans[nLoanID].nInterestRatePerSecond) / 1 ether;
		if (nFinalInterest_FromBorrower > gmapLoans[nLoanID].nEtherDeposited_Borrower) {
			nFinalInterest_FromBorrower = gmapLoans[nLoanID].nEtherDeposited_Borrower;
		}

		uint nFee_Interest = (nFinalInterest_FromBorrower * gnFee) / 100;
		uint nFinalInterest_ToLender = nFinalInterest_FromBorrower - nFee_Interest;
		uint ____ = nFee_Interest;

		uint nAmountToSendLender = gmapLoans[nLoanID].nEtherDeposited_Lender;
		uint nAmountToSendBorrower = gmapLoans[nLoanID].nEtherDeposited_Borrower;
		uint nAppreciation = 0;
		if (nCurrent_ETH_USD > gmapLoans[nLoanID].nStarting_ETH_USD) {
			nAmountToSendLender = (gmapLoans[nLoanID].nStarting_ETH_USD * gmapLoans[nLoanID].nEtherDeposited_Lender) / nCurrent_ETH_USD;
			nAppreciation = gmapLoans[nLoanID].nEtherDeposited_Lender - nAmountToSendLender;
			uint nFee_Appreciation = (nAppreciation * gnFee) / 100;
			nAmountToSendBorrower = (nAmountToSendBorrower + nAppreciation) - nFee_Appreciation;
			____ += nFee_Appreciation;
		}

		nAmountToSendLender += nFinalInterest_ToLender;
		nAmountToSendBorrower -= nFinalInterest_FromBorrower;

		gmapLoans[nLoanID].adrLenderAddress.transfer(nAmountToSendLender);
		gmapLoans[nLoanID].adrBorrowerAddress.transfer(nAmountToSendBorrower);
		___ += ____;

		clsTempForFinalize memory objTempForFinalize;
		objTempForFinalize.nAmountToSendLender = nAmountToSendLender;
		objTempForFinalize.nAmountToSendBorrower = nAmountToSendBorrower;
		objTempForFinalize.nAppreciation = nAppreciation;
		objTempForFinalize.nFinalInterest_FromBorrower = nFinalInterest_FromBorrower;
		objTempForFinalize.b3FinalizedByLender = b3FinalizedByLender;
		gnLoadID = nLoanID;
		
		emit LoansFinalized(
			gmapLoans[gnLoadID].nLoanNumber,
			gmapLoans[gnLoadID].adrLenderAddress,
			gmapLoans[gnLoadID].adrBorrowerAddress,
			objTempForFinalize.b3FinalizedByLender,
			gmapLoans[gnLoadID].nStarting_ETH_USD,
			gmapLoans[gnLoadID].nEnding_ETH_USD,
			objTempForFinalize.nAmountToSendLender,
			objTempForFinalize.nAmountToSendBorrower,
			objTempForFinalize.nAppreciation,
			gmapLoans[gnLoadID].nDateCreated,
			gmapLoans[gnLoadID].nInterestRatePerSecond,
			objTempForFinalize.nFinalInterest_FromBorrower,
			gnFee
			);
	}
	
	function zGetGlobals() external view returns (uint nFee, uint nCurrent_ETH_USD, bool bPriceFeedIsValid, uint nTimeStamp) {
		nFee = gnFee;

		if (nIsDEV == 1) {
			nCurrent_ETH_USD = 1e34 / gobjFiatContract.USD(0);
			bPriceFeedIsValid = true;
		} else {		
			(bytes32 b32_Current_ETH_USD, bool bValid_ETH_USD) = gobjMakerDAOContract.peek();
			nCurrent_ETH_USD = uint(b32_Current_ETH_USD);
			bPriceFeedIsValid = bValid_ETH_USD;
		}
		
		nTimeStamp = block.timestamp;
	}
}