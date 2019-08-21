pragma solidity ^0.4.16;

interface token {
    function transfer(address receiver, uint amount) public;
}

contract Crowdsale {
    address public beneficiary;
    address public burner;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;

    uint public pricePresale = 10000;
    uint public priceRound1 = 5000;
    uint public priceRound2 = 4500;
    uint public priceRound3 = 4000;
    uint public priceRound4 = 3500;

    uint public totalSupply = 61200000 * 1 ether;
    uint public supplyRound1 = 10000000 * 1 ether;
    uint public supplyRound2 = 10000000 * 1 ether;
    uint public supplyRound3 = 10000000 * 1 ether;
    uint public supplyRound4 = 10000000 * 1 ether;
    uint private suppyLeft;

    // define amount of tokens to be sent to the funds, in percentages
    uint public erotixFundMultiplier = 50;
    uint public foundersFundMultiplier = 3;

    uint public requestedTokens;
    uint public amountAvailable;

    bool round1Open = true;
    bool round2Open = false;
    bool round3Open = false;
    bool round4Open = false;
    bool soldOut = false;

    address public erotixFund = 0x1a0cc2B7F7Cb6fFFd3194A2AEBd78A4a072915Be;
    // Smart contract which releases received ERX on the 1st of March 2019
    address public foundersFund = 0xaefe05643b613823dBAF6245AFb819Fd56fBdd22;

    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constructor function
     *
     * Setup the owner
     */
    function Crowdsale(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint endOfCrowdsale,
        address addressOfTokenUsedAsReward,
        address burnAddress
    ) public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = endOfCrowdsale;
        tokenReward = token(addressOfTokenUsedAsReward);
        burner = burnAddress;
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public {
        require(!crowdsaleClosed);
        require(!soldOut);
        uint amount = msg.value;

        bool orderFilled = false;

        while(!orderFilled) {
            uint orderRate;
            uint curSupply;

            if(round1Open) {
                orderRate = priceRound1;
                curSupply = supplyRound1;
            } else if(round2Open) {
                orderRate = priceRound2;
                curSupply = supplyRound2;
            } else if(round3Open) {
                orderRate = priceRound3;
                curSupply = supplyRound3;
            } else if(round4Open) {
                orderRate = priceRound4;
                curSupply = supplyRound4;
            }

            requestedTokens = amount * orderRate;

            if (requestedTokens <= curSupply) {
                balanceOf[msg.sender] += amount;
                amountRaised += amount;

                //send tokens to investor
                tokenReward.transfer(msg.sender, amount * orderRate);
                //send tokens to funds
                tokenReward.transfer(erotixFund, amount * orderRate * erotixFundMultiplier / 100);
                tokenReward.transfer(foundersFund, amount * orderRate * foundersFundMultiplier / 100);

                FundTransfer(msg.sender, amount, true);

                // update supply
                if(round1Open) {
                    supplyRound1 -= requestedTokens;
                } else if(round2Open) {
                    supplyRound2 -= requestedTokens;
                } else if(round3Open) {
                    supplyRound3 -= requestedTokens;
                } else if(round4Open) {
                    supplyRound4 -= requestedTokens;
                }

                orderFilled = true;
            } else {
                // Not enough supply left, sell remaining supply
                amountAvailable = curSupply / orderRate;
                balanceOf[msg.sender] += amountAvailable;
                amountRaised += amountAvailable;

                //send tokens to investor
                tokenReward.transfer(msg.sender, amountAvailable * orderRate);
                //send tokens to funds
                tokenReward.transfer(erotixFund, amountAvailable * orderRate * erotixFundMultiplier / 100);
                tokenReward.transfer(foundersFund, amountAvailable * orderRate * foundersFundMultiplier / 100);

                FundTransfer(msg.sender, amountAvailable, true);

                // set amount of eth left
                amount -= amountAvailable;

                // update supply and close round
                supplyRound1 = 0;

                if(round1Open) {
                    supplyRound1 = 0;
                    round1Open = false;
                    round2Open = true;
                } else if(round2Open) {
                    supplyRound2 = 0;
                    round2Open = false;
                    round3Open = true;
                } else if(round3Open) {
                    supplyRound3 = 0;
                    round3Open = false;
                    round4Open = true;
                } else if(round4Open) {
                    supplyRound4 = 0;
                    round4Open = false;
                    soldOut = true;

                    // send back remaining eth
                    msg.sender.send(amount);
                }
            }
        }
    }

    /**
     * Check if goal was reached
     *
     * Checks if the goal or time limit has been reached and ends the campaign
     */
    function checkGoalReached() public {
        if (now >= deadline || soldOut) {
            if (amountRaised >= fundingGoal){
                fundingGoalReached = true;
                GoalReached(beneficiary, amountRaised);
            }
            crowdsaleClosed = true;

            suppyLeft = supplyRound1 + supplyRound2 + supplyRound3 + supplyRound4;

            if (suppyLeft > 0) {
                tokenReward.transfer(burner, suppyLeft);
                tokenReward.transfer(burner, suppyLeft * erotixFundMultiplier / 100);
                tokenReward.transfer(burner, suppyLeft * foundersFundMultiplier / 100);
            }
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

        if (crowdsaleClosed) {
            if (fundingGoalReached && beneficiary == msg.sender) {
                if (beneficiary.send(amountRaised)) {
                    FundTransfer(beneficiary, amountRaised, false);
                }
            }
        }
    }
}