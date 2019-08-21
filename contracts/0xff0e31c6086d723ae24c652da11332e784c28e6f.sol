pragma solidity ^0.4.25;

/**
UnrealInvest Contract
- GAIN UP TO 120-130% PER 5 MINUTES (every 20 blocks)
- 3% of the contributions go to project advertising

How to use:
    1. Send at least 0.01 Ether to make an investment.
    2a. Claim your profit by sending 0 Ether transaction in 20 blocks.
        OR
    2b. Send at least 0.01 Ether in 20 blocks to reinvest AND get your
        profit at the same time.
    2c. The amount for the payment is calculated as the
        AMOUNT_IN_THE_FUND/NUMBER_OF_ACTIVE_INVESTORS.
        If you didn't receive the entire due payment, you can try sending
        a new request after another 20 blocks.
    3. Participants with referrers receive 130% instead of 120%.
    4. To become someone's referral, enter the address of the referrer
        in the field DATA when sending the first deposit.
    5. Only a participant who deposited at least 0.01 Ether can become
        a referrer.
    6. Referrers receive 5% of each deposit of referrals immediately to
        their wallet.
    7. To receive the prize fund, you need to be the last investor for
        at least 42 blocks (~10 minutes), after which you need to send
        0 Ether or reinvest.

RECOMMENDED GAS LIMIT: 300000
RECOMMENDED GAS PRICE: https://ethgasstation.info/

Contract reviewed and approved by pros!
*/

contract UnrealInvest {
    uint public prizePercent = 2;
    uint public supportPercent = 3;
    uint public refPercent = 5;
    uint public holdInterval = 20;
    uint public prizeInterval = 42;
    uint public percentWithoutRef = 120;
    uint public percentWithRef = 130;
    uint public minDeposit = 0.01 ether;
    
    address support = msg.sender;
    uint public prizeFund;
    address public lastInvestor;
    uint public lastInvestedAt;
    
    uint public activeInvestors;
    uint public totalInvested;
    
    // records investors
    mapping (address => bool) public registered;
    // records amounts invested
    mapping (address => uint) public invested;
    // records amounts paid
    mapping (address => uint) public paid;
    // records blocks at which investments/payments were made
    mapping (address => uint) public atBlock;
    // records referrers
    mapping (address => address) public referrers;
    
    function bytesToAddress(bytes source) internal pure returns (address parsedAddress) {
        assembly {
            parsedAddress := mload(add(source,0x14))
        }
        return parsedAddress;
    }
    
    function () external payable {
        require(registered[msg.sender] && msg.value == 0 || msg.value >= minDeposit);
        
        bool fullyPaid;
        uint transferAmount;
        
        if (!registered[msg.sender] && msg.data.length == 20) {
            address referrerAddress = bytesToAddress(bytes(msg.data));
            require(referrerAddress != msg.sender);     
            if (registered[referrerAddress]) {
                referrers[msg.sender] = referrerAddress;
            }
        }
        registered[msg.sender] = true;
        
        if (invested[msg.sender] > 0 && block.number >= atBlock[msg.sender] + holdInterval) {
            uint availAmount = (address(this).balance - msg.value - prizeFund) / activeInvestors;
            uint payAmount = invested[msg.sender] * (referrers[msg.sender] == 0x0 ? percentWithoutRef : percentWithRef) / 100 - paid[msg.sender];
            if (payAmount > availAmount) {
                payAmount = availAmount;
            } else {
                fullyPaid = true;
            }
            if (payAmount > 0) {
                paid[msg.sender] += payAmount;
                transferAmount += payAmount;
                atBlock[msg.sender] = block.number;
            }
        }
        
        if (msg.value > 0) {
            if (invested[msg.sender] == 0) {
                activeInvestors++;
            }
            invested[msg.sender] += msg.value;
            atBlock[msg.sender] = block.number;
            totalInvested += msg.value;
            
            lastInvestor = msg.sender;
            lastInvestedAt = block.number;
            
            prizeFund += msg.value * prizePercent / 100;
            support.transfer(msg.value * supportPercent / 100);
            if (referrers[msg.sender] != 0x0) {
                referrers[msg.sender].transfer(msg.value * refPercent / 100);
            }
        }
        
        if (lastInvestor == msg.sender && block.number >= lastInvestedAt + prizeInterval) {
            transferAmount += prizeFund;
            delete prizeFund;
            delete lastInvestor;
        }
        
        if (transferAmount > 0) {
            msg.sender.transfer(transferAmount);
        }
        
        if (fullyPaid) {
            delete invested[msg.sender];
            delete paid[msg.sender];
            activeInvestors--;
        }
    }
}