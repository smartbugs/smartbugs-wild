pragma solidity >=0.4.22 <0.6.0;

interface token {
    function transfer(address receiver, uint amount) external;
    
}

contract Crowdsale {
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint256 public price;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constructor
     *
     * Setup the owner
     */
    constructor(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint etherCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers / 1000000000000 * 1 ether;
        price = 1 ether / etherCostOfEachToken;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable external {
        require(!crowdsaleClosed);
        uint amount = msg.value;
        require(amount >= 1 ether);
        
        if (amountRaised <= fundingGoal){
        
                uint tmpAmount = amountRaised + amount;
            
                if (tmpAmount > fundingGoal) {
                    amount = fundingGoal - amountRaised;
                }
                
                balanceOf[msg.sender] += amount;
                amountRaised += amount;
                tokenReward.transfer(msg.sender, amount / price);
                emit FundTransfer(msg.sender, amount, true);
            }
            
        
        if (amountRaised == fundingGoal) {
            checkGoalReached();
        }
    
        
        
        
    }

    /**
     * Check if goal was reached
     *
     * Checks if the goal or time limit has been reached and ends the campaign
     */
    function checkGoalReached() private {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            emit GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
        
       
    }


    /**
     * Withdraw the funds
     *
     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
     * sends the entire amount to the beneficiary. If goal was not reached, each contributor can withdraw
     * the amount they contributed.
     */
    function safeWithdrawal() public {
        if (beneficiary == msg.sender) {
            if (msg.sender.send(amountRaised)) {
               emit FundTransfer(beneficiary, amountRaised, false);
               crowdsaleClosed = true;
               
               if (amountRaised <= fundingGoal) {
                    uint amount = fundingGoal - amountRaised; 
                    tokenReward.transfer(beneficiary, amount / price);
               }
            }
            
            // if (amountRaised <= fundingGoal) {
            //     uint amount = fundingGoal - amountRaised; 
            //     tokenReward.transfer(beneficiary, (amount * 100000000) / price);
            // }
            
            // emit FundTransfer(beneficiary, amountRaised, false);
            // crowdsaleClosed = true;
           
            
        }
    }
}