pragma solidity ^0.4.25;

/**
 *
 * Easy Invest FOREVER NEVERENDING Contract
 *  - GAIN VARIABLE INTEREST EVERY 5900 blocks (approx. 24 hours) UP TO 10% PER DAY (dependent on incoming and outgoing ETH) but minimum of 0.05% for longevity.
 *  - ZERO SUM GAME WITH ADDED LINKED DAPPS BRINGING POSITIVE EXPECTATION
 *  - NO FEES are collected by the owner, in fact, there is no owner at all (just look at the code)
 *  - ADDED GAME ELEMENT OF CHOOSING THE BEST TIME TO WITHDRAW TO MAXIMIZE INTEREST (less frequent withdrawals at higher interest rates will return faster)
 *  - ONLY 90ETH balance increase per day above previous high needed for 10% interest so whales will boost the contract to newer heights to receive higher interest.
 *  - NO USA ALLOWED - - NO COMMISSION on your investment (every ether stays in contract's balance)
 *  - For Fairness on high interest days, a maximum of only 10% of total investment can be returned per withdrawal so you should make withdrawals regularly or lose the extra interest.
 * 
 * How to use:
 *  1. Send any amount of ether to make an investment
 *  2a. Claim your profit by sending 0 ether transaction (every day, every week, i don't care unless you're spending too much on GAS)
 *  OR
 *  2b. Send more ether to reinvest AND get your profit at the same time
 *
 * RECOMMENDED GAS LIMIT: 70000
 * RECOMMENDED GAS PRICE: https://ethgasstation.info/
 *
 * Contract reviewed and approved by pros!
 *
 */
contract EasyInvestForeverNeverending {
    mapping (address => uint256) public invested;   // records amounts invested
    mapping (address => uint256) public atBlock;    // records blocks at which investments were made
	uint256 public previousBalance = 0;             // stores the HIGHEST previous contract balance in steps of 5900 blocks (for current interest calculation)
	uint256 public calculatedLow = 0;			    // stores the next calculated low after a NEW HIGH is reached, assuming no further investment, based on the calculated interest for the new high and the total investment up until then
	uint256 public investedTotal = 0;				// stores the total invested for the calculation of calculatedLow
	uint256 public interestRate = 0;                // stores current interest percentage rate multiplied by 100 - i.e. 1000 is 10% and minimum is 5 or 0.05%
	uint256 public nextBlock = block.number + 5900; // next block number to adjust interestRate
	
    // this function called every time anyone sends a transaction to this contract
    function () external payable {
		investedTotal += msg.value;                 // update total invested amount
		        
        if (block.number >= nextBlock) {            // update interestRate, calculatedLow, previousBalance and nextBlock if block.number has increased enough (every 5900 blocks)
		    uint256 currentBalance= address(this).balance;
		    if (currentBalance < previousBalance) currentBalance = previousBalance; else calculatedLow = 0; // added code to recalculate low only after a new high is reached
			interestRate = (currentBalance - previousBalance) / 10e16 + 100;            // 1% interest base percentage increments 1% for every 10ETH balance increase each period
			interestRate = (interestRate > 1000) ? 1000 : interestRate;  // enforce max of 10% (min is automatically 1% - lower amounts refined later)
			previousBalance = currentBalance ;      // if contract has fallen, currentBalance remains at the previous high and balance has to catch up for higher interest
			if (calculatedLow == 0) calculatedLow = currentBalance - (investedTotal * interestRate / 10000); // new high has been reached so new calculatedLow must be determined based on the new interest rate
			uint256 currentGrowth = 0;  // temp variable which stores magnitude of progress towards high from calculatedLow
			if (currentBalance > calculatedLow) currentGrowth = currentBalance - calculatedLow;
			if (interestRate == 100) interestRate = 100 * currentGrowth / (previousBalance - calculatedLow);  // interest hasn't gone over 1% so calculate the true interest rate
			interestRate = (interestRate < 5) ? 5 : interestRate; // enforce minimum interest rate of 0.05%
			nextBlock += 5900 * ((block.number - nextBlock) / 5900 + 1);            // covers rare cases where there have been no transactions for over a day (unlikely)
		}
		
		if (invested[msg.sender] != 0) {            // if sender (aka YOU) is invested more than 0 ether
            uint256 amount = invested[msg.sender] * interestRate / 10000 * (block.number - atBlock[msg.sender]) / 5900;   // interest amount = (amount invested) * interestRate% * (blocks since last transaction) / 5900
            amount = (amount > invested[msg.sender] / 10) ? invested[msg.sender] / 10 : amount;  // limit interest to no more than 10% of invested amount per withdrawal
            msg.sender.transfer(amount);            // send calculated amount of ether directly to sender (aka YOU)
        }

        atBlock[msg.sender] = block.number;         // record block number of this transaction
		invested[msg.sender] += msg.value;          // update invested amount (msg.value) of this transaction
		
		
	}
}