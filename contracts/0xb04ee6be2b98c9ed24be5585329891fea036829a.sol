pragma solidity ^0.4.11;

interface token {
    function transfer(address receiver, uint amount) public;
}



contract Crowdsale {
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;
    bool changePrice = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    event ChangePrice(uint prices);
    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function Crowdsale(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    )public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 finney;
        deadline = now + durationInMinutes * 1 minutes;
        price = etherCostOfEachToken * 1 finney;
        tokenReward = token(addressOfTokenUsedAsReward);
    }


    function () public payable {
        require(!crowdsaleClosed);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount / price);
        FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() { if (now >= deadline) _; }

    /**
     * Check if goal was reached
     *
     * Checks if the goal or time limit has been reached and ends the campaign
     */
    function checkGoalReached() public afterDeadline {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }

    //transfer token to the owner of the contract (beneficiary)//afterDeadline
        function transferToken(uint amount)public afterDeadline {  
        if (beneficiary == msg.sender)
        {            
            tokenReward.transfer(msg.sender, amount);  
            FundTransfer(msg.sender, amount, true);          
        }
       
    }


 
    function safeWithdrawal()public afterDeadline {
        if (!fundingGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }

        if (fundingGoalReached && beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                FundTransfer(beneficiary, amountRaised, false);
            } else {
                //If we fail to send the funds to beneficiary, unlock funders balance
                fundingGoalReached = false;
            }
        }
    }
    function checkPriceCrowdsale(uint newPrice1, uint newPrice2)public {
        if (beneficiary == msg.sender) {          
           price = (newPrice1 * 1 finney)+(newPrice2 * 1 szabo);
           ChangePrice(price);
           changePrice = true;
        }

    }
}