pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint amount);
}

contract Crowdsale {
    address public beneficiary;  
    uint public fundingGoal;   
    uint public amountRaised;   
    uint public deadline;      
    uint public price;    
    token public tokenReward;   

    mapping(address => uint256) public balanceOf;
    bool public fundingGoalReached = false;  
    bool public crowdsaleClosed = false;   

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    event LogAmount(uint amount);

    
    function Crowdsale(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint weiCostOfEachToken,
        address addressOfTokenUsedAsReward) {
            beneficiary = ifSuccessfulSendTo;
            fundingGoal = fundingGoalInEthers * 1 ether;
            deadline = now + durationInMinutes * 1 minutes;
            price = weiCostOfEachToken * 1 wei;
            tokenReward = token(addressOfTokenUsedAsReward);   
    }

    
    function () payable {
        require(!crowdsaleClosed);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        LogAmount(amount);
        tokenReward.transfer(msg.sender, 2000 * (amount / price));
        FundTransfer(msg.sender, amount, true);
    }

    
    modifier afterDeadline() { if (now >= deadline) _; }

    function checkGoalReached() afterDeadline {
        fundingGoalReached = true;
        GoalReached(beneficiary, amountRaised);
        crowdsaleClosed = true;
    }


    function safeWithdrawal() afterDeadline {
    
    if (fundingGoalReached && beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                FundTransfer(beneficiary, amountRaised, false);/**/
            } else {
                //If we fail to send the funds to beneficiary, unlock funders balance
                fundingGoalReached = false;
            }
        }
    }
}