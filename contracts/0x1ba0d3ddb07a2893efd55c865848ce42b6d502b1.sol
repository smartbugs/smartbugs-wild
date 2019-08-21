pragma solidity ^0.4.18;

/* 
 * IGNITE RATINGS "PHASED DISCOUNT" CROWDSALE CONTRACT. COPYRIGHT 2018 TRUSTIC HOLDING INC. Author - Damon Barnard (damon@igniteratings.com)
 * CONTRACT DEPLOYS A CROWDSALE WITH TIME-BASED REDUCING DISCOUNTS.
 */

interface token {
    function transfer(address receiver, uint amount) public;
}

/*
 * CONTRACT PERMITS IGNITE TO RECLAIM UNSOLD IGNT
 */
contract withdrawToken {
    function transfer(address _to, uint _value) external returns (bool success);
    function balanceOf(address _owner) external constant returns (uint balance);
}

/*
 * SAFEMATH - MATH OPERATIONS WITH SAFETY CHECKS THAT THROW ON ERROR
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/*
 * CROWDSALE CONTRACT CONSTRUCTOR
 */
contract Crowdsale {
    using SafeMath for uint256;

    address public owner; /* CONTRACT OWNER */
    address public operations; /* OPERATIONS MULTISIG WALLET */
    address public index; /* IGNITE INDEX WALLET */
    uint256 public amountRaised; /* TOTAL ETH CONTRIBUTIONS*/
    uint256 public amountRaisedPhase; /* ETH CONTRIBUTIONS SINCE LAST WITHDRAWAL EVENT */
    uint256 public tokensSold; /* TOTAL TOKENS SOLD */
    uint256 public phase1Price; /* PHASE 1 TOKEN PRICE */
    uint256 public phase2Price; /* PHASE 2 TOKEN PRICE */
    uint256 public phase3Price; /* PHASE 3 TOKEN PRICE */
    uint256 public phase4Price; /* PHASE 4 TOKEN PRICE */
    uint256 public phase5Price; /* PHASE 5 TOKEN PRICE */
    uint256 public phase6Price; /* PHASE 6 TOKEN PRICE */
    uint256 public startTime; /* CROWDSALE START TIME */
    token public tokenReward; /* IGNT */
    mapping(address => uint256) public contributionByAddress;

    event FundTransfer(address backer, uint amount, bool isContribution);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Crowdsale(
        uint saleStartTime,
        address ownerAddress,
        address operationsAddress,
        address indexAddress,
        address rewardTokenAddress

    ) public {
        startTime = saleStartTime; /* SETS START TIME */
        owner = ownerAddress; /* SETS OWNER */
        operations = operationsAddress; /* SETS OPERATIONS MULTISIG WALLET */
        index = indexAddress; /* SETS IGNITE INDEX WALLET */
        phase1Price = 0.00600 ether; /* SETS PHASE 1 TOKEN PRICE */
        phase2Price = 0.00613 ether; /* SETS PHASE 2 TOKEN PRICE */
        phase3Price = 0.00627 ether; /* SETS PHASE 3 TOKEN PRICE */
        phase4Price = 0.00640 ether; /* SETS PHASE 4 TOKEN PRICE */
        phase5Price = 0.00653 ether; /* SETS PHASE 5 TOKEN PRICE */
        phase6Price = 0.00667 ether; /* SETS PHASE 6 TOKEN PRICE */
        tokenReward = token(rewardTokenAddress); /* SETS IGNT AS CONTRACT REWARD */
    }

    /*
     * FALLBACK FUNCTION FOR ETH CONTRIBUTIONS - SET OUT PER DISCOUNT PHASE FOR EASE OF UNDERSTANDING/TRANSPARENCY
     */
    function () public payable {
        uint256 amount = msg.value;
        require(now > startTime);
        require(amount <= 1000 ether);

        if(now < startTime.add(7 days)) { /* SETS PAYMENT RULES FOR CROWDSALE PHASE 1 */
            contributionByAddress[msg.sender] = contributionByAddress[msg.sender].add(amount);
            amountRaised = amountRaised.add(amount);
            amountRaisedPhase = amountRaisedPhase.add(amount);
            tokensSold = tokensSold.add(amount.mul(10**18).div(phase1Price));
            tokenReward.transfer(msg.sender, amount.mul(10**18).div(phase1Price));
            FundTransfer(msg.sender, amount, true);
        }

        else if(now > startTime.add(7 days) && now < startTime.add(14 days)) { /* SETS PAYMENT RULES FOR CROWDSALE PHASE 2 */
            contributionByAddress[msg.sender] = contributionByAddress[msg.sender].add(amount);
            amountRaised = amountRaised.add(amount);
            amountRaisedPhase = amountRaisedPhase.add(amount);
            tokensSold = tokensSold.add(amount.mul(10**18).div(phase2Price));
            tokenReward.transfer(msg.sender, amount.mul(10**18).div(phase2Price));
            FundTransfer(msg.sender, amount, true);
        }

        else if(now > startTime.add(14 days) && now < startTime.add(21 days)) { /* SETS PAYMENT RULES FOR CROWDSALE PHASE 3 */
            contributionByAddress[msg.sender] = contributionByAddress[msg.sender].add(amount);
            amountRaised = amountRaised.add(amount);
            amountRaisedPhase = amountRaisedPhase.add(amount);
            tokensSold = tokensSold.add(amount.mul(10**18).div(phase3Price));
            tokenReward.transfer(msg.sender, amount.mul(10**18).div(phase3Price));
            FundTransfer(msg.sender, amount, true);
        }

        else if(now > startTime.add(21 days) && now < startTime.add(28 days)) { /* SETS PAYMENT RULES FOR CROWDSALE PHASE 4 */
            contributionByAddress[msg.sender] = contributionByAddress[msg.sender].add(amount);
            amountRaised = amountRaised.add(amount);
            amountRaisedPhase = amountRaisedPhase.add(amount);
            tokensSold = tokensSold.add(amount.mul(10**18).div(phase4Price));
            tokenReward.transfer(msg.sender, amount.mul(10**18).div(phase4Price));
            FundTransfer(msg.sender, amount, true);
        }

        else if(now > startTime.add(28 days) && now < startTime.add(35 days)) { /* SETS PAYMENT RULES FOR CROWDSALE PHASE 5 */
            contributionByAddress[msg.sender] = contributionByAddress[msg.sender].add(amount);
            amountRaised = amountRaised.add(amount);
            amountRaisedPhase = amountRaisedPhase.add(amount);
            tokensSold = tokensSold.add(amount.mul(10**18).div(phase5Price));
            tokenReward.transfer(msg.sender, amount.mul(10**18).div(phase5Price));
            FundTransfer(msg.sender, amount, true);
        }

        else if(now > startTime.add(35 days)) { /* SETS PAYMENT RULES FOR CROWDSALE PHASE 6 */
            contributionByAddress[msg.sender] = contributionByAddress[msg.sender].add(amount);
            amountRaised = amountRaised.add(amount);
            amountRaisedPhase = amountRaisedPhase.add(amount);
            tokensSold = tokensSold.add(amount.mul(10**18).div(phase6Price));
            tokenReward.transfer(msg.sender, amount.mul(10**18).div(phase6Price));
            FundTransfer(msg.sender, amount, true);
        }
    }

    /*
     * ALLOW IGNITE TO RECLAIM UNSOLD IGNT
     */
    function withdrawTokens(address tokenContract) external onlyOwner {
        withdrawToken tc = withdrawToken(tokenContract);

        tc.transfer(owner, tc.balanceOf(this));
    }
    
    /*
     * ALLOW IGNITE TO WITHDRAW CROWDSALE PROCEEDS TO OPERATIONS AND INDEX WALLETS
     */
    function withdrawEther() external onlyOwner {
        uint256 total = this.balance;
        uint256 operationsSplit = 40;
        uint256 indexSplit = 60;
        operations.transfer(total * operationsSplit / 100);
        index.transfer(total * indexSplit / 100);
    }
}