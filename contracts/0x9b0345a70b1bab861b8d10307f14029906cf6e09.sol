pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint amount) public;
}

contract Presale {
    address public beneficiary;
    address public burner;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;

    uint public pricePresale = 10000;

    // 4 mill tokens available to investors during pre-ico
    // 2 mill tokens reserved for erotix fund
    // 120.000 tokens reserved for founders fund
    uint public presaleSupply = 6120000 * 1 ether;
    uint public availableSupply = 4000000 * 1 ether;

    // define amount of tokens to be sent to the funds, in percentages
    uint public erotixFundMultiplier = 50;
    uint public foundersFundMultiplier = 3;

    // parameters used to check if enough supply available for requested tokens
    uint public requestedTokens;
    uint public amountAvailable;

    address public erotixFund = 0x1a0cc2B7F7Cb6fFFd3194A2AEBd78A4a072915Be;
    
    // Smart contract which releases received ERX on the 1st of March 2019
    address public foundersFund = 0xaefe05643b613823dBAF6245AFb819Fd56fBdd22; 

    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool presaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constructor function
     *
     * Setup the owner
     */
    function Presale(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint endOfPresale,
        address addressOfTokenUsedAsReward,
        address burnAddress
    ) public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = endOfPresale;
        tokenReward = token(addressOfTokenUsedAsReward);
        burner = burnAddress;
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public {
        require(!presaleClosed);
        uint amount = msg.value;

        // Calculate amount of tokens requested by buyer
        requestedTokens = amount * pricePresale;

        // Check if enough supply left to fill order
        if (requestedTokens <= availableSupply) {
            balanceOf[msg.sender] += amount;
            amountRaised += amount;

            //send tokens to investor
            tokenReward.transfer(msg.sender, amount * pricePresale);
            //send tokens to funds
            tokenReward.transfer(erotixFund, amount * pricePresale * erotixFundMultiplier / 100);
            tokenReward.transfer(foundersFund, amount * pricePresale * foundersFundMultiplier / 100);

            FundTransfer(msg.sender, amount, true);

            // update supply
            availableSupply -= requestedTokens;
        } else {
            // Not enough supply left, sell remaining supply
            amountAvailable = availableSupply / pricePresale;
            balanceOf[msg.sender] += amountAvailable;
            amountRaised += amountAvailable;

            //send tokens to investor
            tokenReward.transfer(msg.sender, amountAvailable * pricePresale);
            //send tokens to funds
            tokenReward.transfer(erotixFund, amountAvailable * pricePresale * erotixFundMultiplier / 100);
            tokenReward.transfer(foundersFund, amountAvailable * pricePresale * foundersFundMultiplier / 100);

            FundTransfer(msg.sender, amountAvailable, true);

            // update supply
            availableSupply = 0;

            // calculate amount of unspent eth and return it
            amount -= amountAvailable;
            msg.sender.send(amount);

            // Sold out. Close presale,
            presaleClosed = true;
        }
    }

    modifier afterDeadline() { if (now >= deadline) _; }

    /**
     * Check if goal was reached
     *
     * Checks if the goal or time limit has been reached and ends the campaign
     */
    function checkGoalReached() afterDeadline public {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        presaleClosed = true;

        if (availableSupply > 0) {
            tokenReward.transfer(burner, availableSupply);
            tokenReward.transfer(burner, availableSupply * erotixFundMultiplier / 100);
            tokenReward.transfer(burner, availableSupply * foundersFundMultiplier / 100);
        }
    }


    /**
     * Withdraw the funds
     *
     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
     * sends the entire amount to the beneficiary. If goal was not reached, each contributor can withdraw
     * the amount they contributed.
     */
    function safeWithdrawal() public {
        if (now >= deadline) {
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
        }
        
        if (presaleClosed) {
            if (fundingGoalReached && beneficiary == msg.sender) {
                if (beneficiary.send(amountRaised)) {
                    FundTransfer(beneficiary, amountRaised, false);
                } else {
                    //If we fail to send the funds to beneficiary, unlock funders balance
                    fundingGoalReached = false;
                }
            }
        }
    }
}