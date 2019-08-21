pragma solidity ^0.4.19;
interface token {
    function transfer(address receiver, uint amount) public;
}
contract ForeignToken {
    function balanceOf(address _owner) public constant returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}

contract PODSSale {
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;
    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    function PODSSale() public {
        beneficiary = address(0x0D2e5bd9C6DDc363586061C6129D6122f0D7a2CB);
        fundingGoal = 80 ether;
        deadline = now + 43210 minutes; 
        price = 25000;
        tokenReward = token(address(0xEa29Ac8Bf5001592178F6Cd1275A1D0433F94C5B));
    }
    function () public payable {
        require(!crowdsaleClosed);
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount * price);
        FundTransfer(msg.sender, amount, true);
    }
    modifier afterDeadline() { if (now >= deadline) _; }
    function checkGoalReached() public afterDeadline {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }
    function safeWithdrawal() public {
        if (beneficiary == msg.sender) {
                beneficiary.transfer(this.balance);
                FundTransfer(beneficiary, this.balance, false);
        }
    }
    function withdrawForeignTokens(address _tokenContract) public returns (bool) {
        if (msg.sender != beneficiary) { revert(); }

        ForeignToken tokenf = ForeignToken(_tokenContract);

        uint256 amount = tokenf.balanceOf(address(this));
        return tokenf.transfer(beneficiary, amount);
    }
}