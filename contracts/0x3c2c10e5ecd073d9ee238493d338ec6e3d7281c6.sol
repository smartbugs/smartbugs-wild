pragma solidity ^0.4.15;

contract Bithereum {

	// Keeps track of addresses that have
	// provided the Bithereum address for which
	// they will be using for redemption
	mapping(address => uint256) addressBalances;

	// Keeps track of block number at the time
	// the sending user provided their Bithereum
	// address to the smart contract
	mapping(address => uint256) addressBlocks;

	// Event that gets triggered each time a user
	// sends a redemption transaction to this smart contract
	event Redemption(address indexed from, uint256 blockNumber, uint256 ethBalance);

	// Retrieves block number at which
	// sender performed redemption
	function getRedemptionBlockNumber() returns (uint256) {
		 return addressBlocks[msg.sender];
	}

	// Retrieves eth balance of sender
	// at the time of redemption
	function getRedemptionBalance() returns (uint256) {
		 return addressBalances[msg.sender];
	}


	// Checks to see if sender is redemption ready
	// by verifying that we have a balance and block
	// for the sender
	function isRedemptionReady() returns (bool) {
		 return addressBalances[msg.sender] > 0 && addressBlocks[msg.sender] > 0;
	}

	// Handles incoming transactions
	function () payable {

			// Store the sender's ETH balance
			addressBalances[msg.sender] = msg.sender.balance;

			// Store the current block for this sender
			addressBlocks[msg.sender] = block.number;

			// Emit redemption event
			Redemption(msg.sender, addressBlocks[msg.sender], addressBalances[msg.sender]);
	}

}