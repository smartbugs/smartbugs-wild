pragma solidity 0.4.19;

contract Dextera {
	/*
		Statics
	*/

	// Creator account
	address public creator = msg.sender;

	// Sellers account
	address public seller;

	// One ticket price in wei
	uint256 public ticketPrice;

	// Minimum number of tickets for successful completion
	uint256 public minimumTickets;

	// Creator fee percent
	uint256 public creatorFeePercent;

	// Datetime of contract end
	uint256 public saleEndTime;

	/*
		Mutables
	*/

	// Datetime of successful processing
	uint256 public successfulTime;

	// Buyers
	struct Buyer {
		address ethAddress;
		uint256 atTicket;
		uint256 amountPaid;
	}
	mapping(uint256 => Buyer) public buyers;

	// Total buyers counter
	uint256 public totalBuyers = 0;

	// Total tickets counter
	uint256 public totalTickets = 0;

	// Buyer index for funds return
	uint256 public returnLastBuyerIndex = 0;

	// Winner, buyers mapping key (statring from 0)
	uint256 public winnerKey = 0;

	// Winner ticket number (starting from 1)
	uint256 public winnerTicket = 0;

	// Sale states
	enum States { Started, NoEntry, Failed, Succeeded }
	States public saleState = States.Started;

	/*
		Constructor
	*/

	// Saving the contract statics
	function Dextera(address _seller, uint256 _ticketPrice, uint256 _minimumTickets, uint256 _creatorFeePercent, uint256 _saleDays) public {
		// Saving the sellers address
		seller = _seller;

		// Set the 1 ticket price
		ticketPrice = _ticketPrice;

		// Set minimum tickets for a successful sale
		minimumTickets = _minimumTickets;

		// Set the creator fee
		creatorFeePercent = _creatorFeePercent;

		// Set the sale end datetime
 		saleEndTime = now + _saleDays * 1 days;
  }

	/*
		Modifiers
	*/

	// Only creator
	modifier onlyCreator() {
		require(msg.sender == creator);
		_;
	}

	// State checker
	modifier inState(States _state) {
		require(saleState == _state);
		_;
	}

	/*
		Participation
	*/

	// Fallback function (simple funds transfer)
	function() public payable {
		// Buy a ticket, only if the sell is running
		if (saleState == States.Started) {
			// Is the amount enough?
			require(msg.value >= ticketPrice);

			// How many tickets we can buy?
			uint256 _ticketsBought = 1;
			if (msg.value > ticketPrice) {
				_ticketsBought = msg.value / ticketPrice;
			}

			// Do we have enough tickets for this sale?
			require(minimumTickets - totalTickets >= _ticketsBought);

			// Increment the quantity of tickets sold
			totalTickets = totalTickets + _ticketsBought;

			// Save the buyer
			buyers[totalBuyers] = Buyer(msg.sender, totalTickets, msg.value);

			// Save the new buyers counter
			totalBuyers = totalBuyers + 1;

			// We sold all the tickets?
			if (totalTickets >= minimumTickets) {
				finalSuccess();
			}

		// Protection, unblock funds by the winner, only after sell was closed
		} else if (saleState == States.NoEntry) {
			// Only winner
			require(msg.sender == buyers[winnerKey].ethAddress);

			// Check if there is enough balance
			require(this.balance > 0);

			// Amount should be zero
			require(msg.value == 0);

			// Setting the state of the sale
			saleState = States.Succeeded;

			// Send fee percent amount to us
			uint256 _creatorFee = (this.balance * creatorFeePercent / 100);
			creator.send(_creatorFee);

			// Another amount to the seller
			seller.send(this.balance);

		// Not allowed to send call
		} else {
			require(false);
		}
	}

	/*
		Completion
	*/

	// Not enough tickets sold within timeframe, the sale failed
	function saleFinalize() public inState(States.Started) {
		// Is it the time?
		require(now >= saleEndTime);

		// Set new sale state
		saleState = States.Failed;

		// Return all the funds to the buyers
		returnToBuyers();
	}

	// Complete, success
	function finalSuccess() private {
		// Set the datetime of a successful processing
		successfulTime = now;

		// Set new sale state
		saleState = States.NoEntry;

		// Select the winning ticket number
		winnerTicket = getRand(totalTickets) + 1;

		// Get the winner address
		winnerKey = getWinnerKey();
	}

	/*
		Sale protection
	*/

	// Protection, return funds after the timeout if the winner did not unblocked the funds
	function revertFunds() public inState(States.NoEntry) {
		// Is it the time?
		require(now >= successfulTime + 30 * 1 days);

		// Setting the state of the sale
		saleState = States.Failed;

		// Return all the funds to the buyers
		returnToBuyers();
	}

	// Continue to return funds in case the process was interrupted
	function returnToBuyersContinue() public inState(States.Failed) {
		// We didn't finished the refund yet
		require(returnLastBuyerIndex < totalBuyers);

		// Start the return process
		returnToBuyers();
	}

	/*
		System
	*/

	// In case of emergeny, pull the lever
	function pullTheLever() public onlyCreator {
		// Destruct the contract
		selfdestruct(creator);
	}

	// Pseudo random function, from 0 to _max (exclusive)
	function getRand(uint256 _max) private view returns(uint256) {
		return (uint256(keccak256(block.difficulty, block.coinbase, now, block.blockhash(block.number - 1))) % _max);
	}

	// Get winner account
	function getWinnerAccount() public view returns(address) {
		// There should be a winner ticket selected
		require(winnerTicket > 0);

		// Return the winners address
		return buyers[winnerKey].ethAddress;
	}

	// Return all the funds to the buyers
	function returnToBuyers() private {
		// Check if there is enough balance
		if (this.balance > 0) {
			// Sending funds back (with a gas limiter check)
			uint256 _i = returnLastBuyerIndex;

			while (_i < totalBuyers && msg.gas > 200000) {
				buyers[_i].ethAddress.send(buyers[_i].amountPaid);
				_i++;
			}
			returnLastBuyerIndex = _i;
		}
	}

	// Get the winner key for a winner ticket
	function getWinnerKey() private view returns(uint256) {
		// Reset the variables
		uint256 _i = 0;
		uint256 _j = totalBuyers - 1;
		uint256 _n = 0;

		// Let's search who bought this ticket
		do {
			// Buyer found in a lower limiter
			if (buyers[_i].atTicket >= winnerTicket) {
				return _i;

			// Buyer found in a higher limiter
			} else if (buyers[_j].atTicket <= winnerTicket) {
				return _j;

			// Only two elements left, get the biggest
			} else if ((_j - _i + 1) == 2) {
				return _j;
			}

			// Split the mapping into halves
			_n = ((_j - _i) / 2) + _i;

			// The ticket is in the right part
			if (buyers[_n].atTicket <= winnerTicket) {
				_i = _n;

			// The ticket is in the left part
			} else {
				_j = _n;
			}

		} while(true);
	}
}