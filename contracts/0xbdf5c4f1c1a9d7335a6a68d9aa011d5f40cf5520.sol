contract Token {
    
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address owner) constant returns (uint256 balance);
    function transfer(address to, uint256 value) returns (bool success);
    function transferFrom(address from, address to, uint256 value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);
    function allowance(address owner, address spender) constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract SingularDTVToken is Token {
    function issueTokens(address _for, uint tokenCount) returns (bool);
}
contract SingularDTVFund {
    function workshop() returns (address);
    function softWithdrawRevenueFor(address forAddress) returns (uint);
}




contract SingularDTVCrowdfunding {

    /*
     *  External contracts
     */
    SingularDTVToken public singularDTVToken;
    SingularDTVFund public singularDTVFund;

    /*
     *  Constants
     */
    uint constant public CAP = 1000000000; 
    uint constant public CROWDFUNDING_PERIOD = 4 weeks; 
    uint constant public TOKEN_LOCKING_PERIOD = 2 years; 
    uint constant public TOKEN_TARGET = 534000000; 

    /*
     *  Enums
     */
    enum Stages {
        CrowdfundingGoingAndGoalNotReached,
        CrowdfundingEndedAndGoalNotReached,
        CrowdfundingGoingAndGoalReached,
        CrowdfundingEndedAndGoalReached
    }

    /*
     *  Storage
     */
    address public owner;
    uint public startDate;
    uint public fundBalance;
    uint public baseValue = 1250 szabo; 
    uint public valuePerShare = baseValue; 

    
    mapping (address => uint) public investments;

    
    Stages public stage = Stages.CrowdfundingGoingAndGoalNotReached;

    /*
     *  Modifiers
     */
    modifier noEther() {
        if (msg.value > 0) {
            throw;
        }
        _
    }

    modifier onlyOwner() {
        
        if (msg.sender != owner) {
            throw;
        }
        _
    }

    modifier minInvestment() {
        
        if (msg.value < valuePerShare) {
            throw;
        }
        _
    }

    modifier atStage(Stages _stage) {
        if (stage != _stage) {
            throw;
        }
        _
    }

    modifier atStageOR(Stages _stage1, Stages _stage2) {
        if (stage != _stage1 && stage != _stage2) {
            throw;
        }
        _
    }

    modifier timedTransitions() {
        uint crowdfundDuration = now - startDate;
        if (crowdfundDuration >= 22 days) {
            valuePerShare = baseValue * 1500 / 1000;
        }
        else if (crowdfundDuration >= 18 days) {
            valuePerShare = baseValue * 1375 / 1000;
        }
        else if (crowdfundDuration >= 14 days) {
            valuePerShare = baseValue * 1250 / 1000;
        }
        else if (crowdfundDuration >= 10 days) {
            valuePerShare = baseValue * 1125 / 1000;
        }
        else {
            valuePerShare = baseValue;
        }
        if (crowdfundDuration >= CROWDFUNDING_PERIOD) {
            if (stage == Stages.CrowdfundingGoingAndGoalNotReached) {
                stage = Stages.CrowdfundingEndedAndGoalNotReached;
            }
            else if (stage == Stages.CrowdfundingGoingAndGoalReached) {
                stage = Stages.CrowdfundingEndedAndGoalReached;
            }
        }
        _
    }

    /*
     *  Contract functions
     */
    
    function checkInvariants() constant internal {
        if (fundBalance > this.balance) {
            throw;
        }
    }

    
    function emergencyCall()
        external
        noEther
        returns (bool)
    {
        if (fundBalance > this.balance) {
            if (this.balance > 0 && !singularDTVFund.workshop().send(this.balance)) {
                throw;
            }
            return true;
        }
        return false;
    }

    
    function fund()
        external
        timedTransitions
        atStageOR(Stages.CrowdfundingGoingAndGoalNotReached, Stages.CrowdfundingGoingAndGoalReached)
        minInvestment
        returns (uint)
    {
        uint tokenCount = msg.value / valuePerShare; 
        if (singularDTVToken.totalSupply() + tokenCount > CAP) {
            
            tokenCount = CAP - singularDTVToken.totalSupply();
        }
        uint investment = tokenCount * valuePerShare; 
        
        if (msg.value > investment && !msg.sender.send(msg.value - investment)) {
            throw;
        }
        
        fundBalance += investment;
        investments[msg.sender] += investment;
        if (!singularDTVToken.issueTokens(msg.sender, tokenCount)) {
            
            throw;
        }
        
        if (stage == Stages.CrowdfundingGoingAndGoalNotReached) {
            if (singularDTVToken.totalSupply() >= TOKEN_TARGET) {
                stage = Stages.CrowdfundingGoingAndGoalReached;
            }
        }
        
        if (stage == Stages.CrowdfundingGoingAndGoalReached) {
            if (singularDTVToken.totalSupply() == CAP) {
                stage = Stages.CrowdfundingEndedAndGoalReached;
            }
        }
        checkInvariants();
        return tokenCount;
    }

    
    function withdrawFunding()
        external
        noEther
        timedTransitions
        atStage(Stages.CrowdfundingEndedAndGoalNotReached)
        returns (bool)
    {
        
        uint investment = investments[msg.sender];
        investments[msg.sender] = 0;
        fundBalance -= investment;
        
        if (investment > 0  && !msg.sender.send(investment)) {
            throw;
        }
        checkInvariants();
        return true;
    }

    
    function withdrawForWorkshop()
        external
        noEther
        timedTransitions
        atStage(Stages.CrowdfundingEndedAndGoalReached)
        returns (bool)
    {
        uint value = fundBalance;
        fundBalance = 0;
        if (value > 0  && !singularDTVFund.workshop().send(value)) {
            throw;
        }
        checkInvariants();
        return true;
    }

    
    
    function changeBaseValue(uint valueInWei)
        external
        noEther
        onlyOwner
        returns (bool)
    {
        baseValue = valueInWei;
        return true;
    }

    
    function twoYearsPassed()
        constant
        external
        noEther
        returns (bool)
    {
        return now - startDate >= TOKEN_LOCKING_PERIOD;
    }

    
    function campaignEndedSuccessfully()
        constant
        external
        noEther
        returns (bool)
    {
        if (stage == Stages.CrowdfundingEndedAndGoalReached) {
            return true;
        }
        return false;
    }

    
    
    
    function updateStage()
        external
        timedTransitions
        noEther
        returns (Stages)
    {
        return stage;
    }

    
    
    
    function setup(address singularDTVFundAddress, address singularDTVTokenAddress)
        external
        onlyOwner
        noEther
        returns (bool)
    {
        if (address(singularDTVFund) == 0 && address(singularDTVToken) == 0) {
            singularDTVFund = SingularDTVFund(singularDTVFundAddress);
            singularDTVToken = SingularDTVToken(singularDTVTokenAddress);
            return true;
        }
        return false;
    }

    
    function SingularDTVCrowdfunding() noEther {
        
        owner = msg.sender;
        
        startDate = now;
    }

    
    function () {
        throw;
    }
}