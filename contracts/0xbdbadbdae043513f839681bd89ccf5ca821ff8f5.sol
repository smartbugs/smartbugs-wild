pragma solidity ^0.4.19;

contract token {
    function transfer(address receiver, uint256 amount);
    function balanceOf(address _owner) constant returns (uint256 balance);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
}

contract GasCrowdsale {
    using SafeMath for uint256;
    
    address public beneficiary;
    uint256 public fundingGoal;
    uint256 public amountRaised;
    uint256 public startdate;
    uint256 public deadline;
    uint256 public price;
    uint256 public fundTransferred;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;

    //event GoalReached(address recipient, uint256 totalAmountRaised);
    //event FundTransfer(address backer, uint256 amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function GasCrowdsale() {
        beneficiary = 0x007FB3e94dCd7C441CAA5b87621F275d199Dff81;
        fundingGoal = 8000 ether;
        startdate = now;
        deadline = 1520640000;
        price = 0.0003 ether;
        tokenReward = token(0x75c79b88facE8892E7043797570c390bc2Db52A7);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable {
        require(!crowdsaleClosed);
        uint256 bonus;
        uint256 amount = msg.value;
        balanceOf[msg.sender] = balanceOf[msg.sender].add(amount);
        amountRaised = amountRaised.add(amount);
        
        //add bounus for funders
        amount =  amount.div(price);
        bonus = amount.mul(35).div(100);
        amount = amount.add(bonus);
        
        amount = amount.mul(100000000);
        tokenReward.transfer(msg.sender, amount);
        //FundTransfer(msg.sender, amount, true);
    }

    modifier afterDeadline() { if (now >= deadline) _; }

    /**
     *ends the campaign after deadline
     */
     
    function endCrowdsale() afterDeadline {
        crowdsaleClosed = true;
    }
    
    function getTokensBack() {
        uint256 remaining = tokenReward.balanceOf(this);
        if(msg.sender == beneficiary){
           tokenReward.transfer(beneficiary, remaining); 
        }
    }

    /**
     * Withdraw the funds
     */
    function safeWithdrawal() {
        if (beneficiary == msg.sender) {
            if(fundTransferred != amountRaised){
               uint256 transferfund;
               transferfund = amountRaised.sub(fundTransferred);
               fundTransferred = fundTransferred.add(transferfund);
               beneficiary.send(transferfund);
            } 
        }
    }
}