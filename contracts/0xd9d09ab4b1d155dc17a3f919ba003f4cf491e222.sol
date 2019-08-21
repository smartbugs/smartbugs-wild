pragma solidity ^0.4.18;

contract Token {

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function balanceOf(address _owner) public constant returns (uint256 balance);
}

contract Crowdsale {

    address public crowdsaleOwner;
    address public crowdsaleBeneficiary;
    address public crowdsaleWallet;

    uint public amountRaised;
    uint public deadline;
    uint public period;
    uint public etherCost = 470;
    uint public started;

    Token public rewardToken;

    mapping(address => uint256) public balanceOf;

    bool public fundingGoalReached = false;
    bool public crowdsaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    function Crowdsale(
        address _beneficiaryThatOwnsTokens,
        uint _durationInDays,
        address _addressOfTokenUsedAsReward,
        address _crowdsaleWallet
    ) public {
        crowdsaleOwner = msg.sender;
        crowdsaleBeneficiary = _beneficiaryThatOwnsTokens;
        deadline = now + _durationInDays * 1 days;
        period = _durationInDays * 1 days / 3;
        rewardToken = Token(_addressOfTokenUsedAsReward);
        crowdsaleWallet = _crowdsaleWallet;
        started = now;
    }

    function stageNumber() public constant returns (uint stage) {
        require(now >= started);
        uint result = 1  + (now - started) / period;
        if (result > 3) {
            result = 3;
        }
        stage = result;
    }

    function calcTokenCost() public constant returns (uint tokenCost) {
        /* How many WEIs in half dollar */
        uint halfDollar = 1 ether / etherCost / 2;
        /* Get current stage for discount calculation */
        uint stage = stageNumber();
        /* For first stage price is 2 dollars, for second stage is 2.5 dollars & 3 dollars for others */
        if (stage == 1) {
            tokenCost = halfDollar * 4;
        } else if (stage == 2) {
            tokenCost = halfDollar * 5;
        } else {
            tokenCost = halfDollar * 6;
        }
    }

    function () public payable {
        /* Crowdsale shouldn't be closed */
        require(!crowdsaleClosed);
        /* Calculate & check number of tokens for that amount */
        uint amount = msg.value;
        uint tokens = amount / calcTokenCost();
        require(tokens > 0);
        /* Increase user's amount of WEI in crowdsale */
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        /* Transfer allowed tokens from crowdsale owner to sender */
        rewardToken.transferFrom(crowdsaleWallet, msg.sender, tokens);
        FundTransfer(msg.sender, amount, true);
        /* Check has goal been reached */
        checkGoalReached();
    }

    function checkGoalReached() public {
        uint256 tokensLeft = rewardToken.balanceOf(crowdsaleWallet);
        if (tokensLeft == 0) {
            fundingGoalReached = true;
            crowdsaleClosed = true;
            GoalReached(crowdsaleBeneficiary, amountRaised);
        } else if (now >= deadline) {
            crowdsaleClosed = true;
            GoalReached(crowdsaleBeneficiary, amountRaised);
        }
    }

    function withdraw() public {
        require(crowdsaleBeneficiary == msg.sender);
        if (crowdsaleBeneficiary.send(amountRaised)) {
            FundTransfer(crowdsaleBeneficiary, amountRaised, false);
        }
    }

    function updateEtherCost(uint _etherCost) public {
        require(msg.sender == crowdsaleOwner);
        etherCost = _etherCost;
    }
}