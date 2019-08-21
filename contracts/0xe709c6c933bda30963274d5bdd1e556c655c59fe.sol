contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

//token contract used as reward
contract token {
    mapping (address => uint256) public totalInvestmentOf;
    function transfer(address receiver, uint amount){  }
    function updateInvestmentTotal(address _to, uint256 _value){ }
    function burnUnsoldCoins(address _removeCoinsFrom){ }
}

contract Crowdsale is owned {
    uint public amountRaised;
    //20160 minutes (two weeks)
    uint public deadline;
    //1 token for 1 ETH week 1
    uint public price = 1 ether;
    //address of token used as reward
    token public tokenReward;
    Funder[] public funders;
    event FundTransfer(address backer, uint amount, bool isContribution);
    //crowdsale is open
    bool crowdsaleClosed = false;
    //countdown to week two price increase
    uint weekTwoPriceRiseBegin = now + 10080 * 1 minutes;
    //refund any remainders
    uint remainderRefund;
    uint amountAfterRefund;
    //80/20 split
    uint bankrollBeneficiaryAmount;
    uint etherollBeneficiaryAmount;
    //80% sent here at end of crowdsale
    address public beneficiary;
    //20% to etheroll
    address etherollBeneficiary = 0x5de92686587b10cd47e03b71f2e2350606fcaf14;

    //data structure to hold information about campaign contributors
    struct Funder {
        address addr;
        uint amount;
    }

    //owner
    function Crowdsale(
        address ifSuccessfulSendTo,
        uint durationInMinutes,
        //uint etherCostOfEachToken,
        token addressOfTokenUsedAsReward
    ) {
        beneficiary = ifSuccessfulSendTo;
        deadline = now + durationInMinutes * 1 minutes;
        //price = price;
        tokenReward = token(addressOfTokenUsedAsReward);
    }



    function () {
        //crowdsale period is over
        if(now > deadline) crowdsaleClosed = true;
        if (crowdsaleClosed) throw;
        uint amount = msg.value;

        //refund if value sent is below token price
        if(amount < price) throw;

        //week 1 price
        if(now < weekTwoPriceRiseBegin){
            //return any ETH in case of remainder
            remainderRefund = amount % price;
            if(remainderRefund > 0){
                //quietly refund any spare change
                msg.sender.send(remainderRefund);
                amountAfterRefund = amount-remainderRefund;
                tokenReward.transfer(msg.sender, amountAfterRefund / price);
                amountRaised += amountAfterRefund;
                funders[funders.length++] = Funder({addr: msg.sender, amount: amountAfterRefund});
                tokenReward.updateInvestmentTotal(msg.sender, amountAfterRefund);
                FundTransfer(msg.sender, amountAfterRefund, true);
            }

            //same but no remainder
            if(remainderRefund == 0){
                 amountRaised += amount;
                 tokenReward.transfer(msg.sender, amount / price);
                 funders[funders.length++] = Funder({addr: msg.sender, amount: amount});
                 tokenReward.updateInvestmentTotal(msg.sender, amount);
                 FundTransfer(msg.sender, amount, true);
            }
        }

        //week 2 price
        if(now >= weekTwoPriceRiseBegin){
            //price rise in week two
            //1 token for 1.5ETH
            if(price == 1 ether){price = (price*150)/100;}
            //tokenReward.transfer(msg.sender, amount / price, amount);
            //return any ETH in case of remainder
            remainderRefund = amount % price;
            if(remainderRefund > 0){
                //quietly refund any spare change
                msg.sender.send(remainderRefund);
                amountAfterRefund = amount-remainderRefund;
                tokenReward.transfer(msg.sender, amountAfterRefund / price);
                amountRaised += amountAfterRefund;
                funders[funders.length++] = Funder({addr: msg.sender, amount: amountAfterRefund});
                tokenReward.updateInvestmentTotal(msg.sender, amountAfterRefund);
                FundTransfer(msg.sender, amountAfterRefund, true);
            }

            //same but no remainder
            if(remainderRefund == 0){
                 tokenReward.transfer(msg.sender, amount / price);
                 amountRaised += amount;
                 funders[funders.length++] = Funder({addr: msg.sender, amount: amount});
                 tokenReward.updateInvestmentTotal(msg.sender, amount);
                 FundTransfer(msg.sender, amount, true);
            }
        }
    }

    //modifier for only after end of crowdsale
    modifier afterDeadline() { if (now >= deadline) _ }

    //modifier for only after week 1 price rise
    modifier afterPriceRise() { if (now >= weekTwoPriceRiseBegin) _ }

    /*checks if the time limit has been reached and ends the campaign
    anybody can call this after the deadline
    80% of funds sent to final etheroll bankroll SC
    20% of funds  sent to an address for etheroll salaries*/
    function checkGoalReached() afterDeadline {
        //house bankroll receives 80%
        bankrollBeneficiaryAmount = (amountRaised*80)/100;
        beneficiary.send(bankrollBeneficiaryAmount);
        FundTransfer(beneficiary, bankrollBeneficiaryAmount, false);
        //etheroll receives 20%
        etherollBeneficiaryAmount = (amountRaised*20)/100;
        etherollBeneficiary.send(etherollBeneficiaryAmount);
        FundTransfer(etherollBeneficiary, etherollBeneficiaryAmount, false);
        etherollBeneficiary.send(this.balance); // send any remaining balance to etherollBeneficiary anyway
        //burn any remaining unsold coins
        //tokenReward.burnUnsoldCoins();
        crowdsaleClosed = true;
    }

    //update token price week two
    //this does happen automatically when someone purchases tokens week 2
    //but nice to update for users
    function updateTokenPriceWeekTwo() afterPriceRise {
        //funky price updates
        if(price == 1 ether){price = (price*150)/100;}
    }

    function burnCoins(address _removeCoinsFrom)
        onlyOwner
    {
        tokenReward.burnUnsoldCoins(_removeCoinsFrom);
    }

    //in case of absolute emergency
    //returns all funds to investors
    //divestment schedule is better in the beneficiary contract as no gas limit concerns
    function returnFunds()
        onlyOwner
    {
        for (uint i = 0; i < funders.length; ++i) {
          funders[i].addr.send(funders[i].amount);
          FundTransfer(funders[i].addr, funders[i].amount, false);
        }
    }

}