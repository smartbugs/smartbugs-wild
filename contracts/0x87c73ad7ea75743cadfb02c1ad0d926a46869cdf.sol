pragma solidity ^0.4.25;

/**
 *
 * Easy Investment Contract
 *  - GAIN 5% PER 24 HOURS
 *  - NO COMMISSION on your investment (every ether stays on contract's balance)
 *  - NO FEES are collected by the owner, in fact, there is no owner at all (just look at the code)
 *  - Rapid growth PROTECTION. The balance of the contract can not grow faster than 10% of the total investment every day
 *
 * How to use:
 *  1. Send any amount of ether to make an investment
 *  2a. Claim your profit by sending 0 ether transaction (every day, every week, i don't care unless you're spending too much on GAS)
 *  OR
 *  2b. Send more ether to reinvest AND get your profit at the same time
 *
 * RECOMMENDED GAS LIMIT: 100000
 * RECOMMENDED GAS PRICE: https://ethgasstation.info/
 *
 * Contract reviewed and approved by pros!
 *
 */
contract EasyInvest5 {

    // records amounts invested
    mapping (address => uint) public invested;
    // records timestamp at which investments were made
    mapping (address => uint) public dates;

    // records amount of all investments were made
    uint public totalInvested;
    // records the total allowable amount of investment. 50 ether to start
    uint public canInvest = 50 ether;
    // time of the update of allowable amount of investment
    uint public refreshTime = now + 24 hours;

    // this function called every time anyone sends a transaction to this contract
    function () external payable {
        // if sender (aka YOU) is invested more than 0 ether
        if (invested[msg.sender] != 0) {
            // calculate profit amount as such:
            // amount = (amount invested) * 5% * (time since last transaction) / 24 hours
            uint amount = invested[msg.sender] * 5 * (now - dates[msg.sender]) / 100 / 24 hours;

            // if profit amount is not enough on contract balance, will be sent what is left
            if (amount > address(this).balance) {
                amount = address(this).balance;
            }

            // send calculated amount of ether directly to sender (aka YOU)
            msg.sender.transfer(amount);
        }

        // record new timestamp
        dates[msg.sender] = now;

        // every day will be updated allowable amount of investment
        if (refreshTime <= now) {
            // investment amount is 10% of the total investment
            canInvest += totalInvested / 10;
            refreshTime += 24 hours;
        }

        if (msg.value > 0) {
            // deposit cannot be more than the allowed amount
            require(msg.value <= canInvest);
            // record invested amount of this transaction
            invested[msg.sender] += msg.value;
            // update allowable amount of investment and total invested
            canInvest -= msg.value;
            totalInvested += msg.value;
        }
    }
}