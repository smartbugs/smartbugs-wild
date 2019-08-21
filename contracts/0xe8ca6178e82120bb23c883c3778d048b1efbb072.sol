pragma solidity ^0.4.11;

contract token {
    function transferFrom(address, address, uint) returns(bool){}
    function burn() {}
}

contract SafeMath {
    //internals

    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        Assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        Assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        Assert(c >= a && c >= b);
        return c;
    }

    function Assert(bool assertion) internal {
        if (!assertion) {
            revert();
        }
    }
}


contract Crowdsale is SafeMath {
    /*Owner's address*/
    address public owner;
    /* tokens will be transferred from BAP's address */
    address public initialTokensHolder = 0xB27590b9d328bA0396271303e24db44132531411;
    /* if the funding goal is not reached, investors may withdraw their funds */
    uint public fundingGoal =  260000000;
    /* the maximum amount of tokens to be sold */
    uint public maxGoal     = 2100000000;
    /* how much has been raised by crowdale (in ETH) */
    uint public amountRaised;
    /* the start date of the crowdsale 12:00 am 31/11/2017 */
    uint public start = 1508929200;
    /* the start date of the crowdsale 11:59 pm 10/11/2017*/
    uint public end =   1508936400;
    /*token's price  1ETH = 15000 KRB*/
    uint public tokenPrice = 15000;
    /* the number of tokens already sold */
    uint public tokensSold;
    /* the address of the token contract */
    token public tokenReward;
    /* the balances (in ETH) of all investors */
    mapping(address => uint256) public balanceOf;
    /*this mapping tracking allowed specific investor to invest and their referral */
    mapping(address => address) public permittedInvestors;
    /* indicated if the funding goal has been reached. */
    bool public fundingGoalReached = false;
    /* indicates if the crowdsale has been closed already */
    bool public crowdsaleClosed = false;
    /* this wallet will store all the fund made by ICO after ICO success*/
    address beneficiary = 0x12bF8E198A6474FC65cEe0e1C6f1C7f23324C8D5;
    /* notifying transfers and the success of the crowdsale*/
    event GoalReached(address TokensHolderAddr, uint amountETHRaised);
    event FundTransfer(address backer, uint amount, uint amountRaisedInICO, uint amountTokenSold, uint tokensHaveSold);
    event TransferToReferrer(address indexed backer, address indexed referrerAddress, uint commission, uint amountReferralHasInvested, uint tokensReferralHasBought);
    event AllowSuccess(address indexed investorAddr, address referralAddr);
    event Withdraw(address indexed recieve, uint amount);

    function changeTime(uint _start, uint _end){
        start = _start;
        end   = _end;
    }

    function changeMaxMin(uint _min, uint _max){
        fundingGoal = _min;
        maxGoal     = _max;
    }

    /*  initialization, set the token address */
    function Crowdsale() {
        tokenReward = token(0x1960edc283c1c7b9fba34da4cc1aa665eec0587e);
        owner = msg.sender;
    }

    /* invest by sending ether to the contract. */
    function () payable {
        invest();
    }

    function invest() payable {
        if(permittedInvestors[msg.sender] == 0x0) {
            revert();
        }
        uint amount = msg.value;
        uint numTokens = safeMul(amount, tokenPrice) / 1000000000000000000; // 1 ETH
        if (now < start || now > end || safeAdd(tokensSold, numTokens) > maxGoal) {
            revert();
        }
        balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender], amount);
        amountRaised = safeAdd(amountRaised, amount);
        tokensSold += numTokens;
        if (!tokenReward.transferFrom(initialTokensHolder, msg.sender, numTokens)) {
            revert();
        }
        if(permittedInvestors[msg.sender] != initialTokensHolder) {
            uint commission = safeMul(numTokens, 5) / 100;
            if(commission != 0){
                /* we plus maxGoal for referrer in value param to distinguish between tokens for investors and tokens for referrer.
                This value will be subtracted in token contract */
                if (!tokenReward.transferFrom(initialTokensHolder, permittedInvestors[msg.sender], safeAdd(commission, maxGoal))) {
                    revert();
                }
                TransferToReferrer(msg.sender, permittedInvestors[msg.sender], commission, amount, numTokens);
            }
        }

        FundTransfer(msg.sender, amount, amountRaised, tokensSold, numTokens);
    }

    modifier afterDeadline() {
        if (now < end) {
            revert();
        }
        _;

    }
    modifier onlyOwner {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    /* checks if the goal or time limit has been reached and ends the campaign */
    function checkGoalReached() {
        if((tokensSold >= fundingGoal && now >= end) || (tokensSold >= maxGoal)) {
            fundingGoalReached = true;
            crowdsaleClosed = true;
            tokenReward.burn();
            sendToBeneficiary();
            GoalReached(initialTokensHolder, amountRaised);
        }
        if(now >= end) {
            crowdsaleClosed = true;
        }
    }

    function allowInvest(address investorAddress, address referralAddress) onlyOwner external {
        require(permittedInvestors[investorAddress] == 0x0);
        if(referralAddress != 0x0 && permittedInvestors[referralAddress] == 0x0) revert();
        permittedInvestors[investorAddress] = referralAddress == 0x0 ? initialTokensHolder : referralAddress;
        AllowSuccess(investorAddress, referralAddress);
    }

    /* send money to beneficiary */
    function sendToBeneficiary() internal {
        beneficiary.transfer(this.balance);
    }


    /*if the ICO is fail, investors will call this function to get their money back */
    function safeWithdrawal() afterDeadline {
        require(this.balance != 0);
        if(!crowdsaleClosed) revert();
        uint amount = balanceOf[msg.sender];
        if(address(this).balance >= amount) {
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                msg.sender.transfer(amount);
                Withdraw(msg.sender, amount);
            }
        }
    }

    function kill() onlyOwner {
        selfdestruct(beneficiary);
    }
}