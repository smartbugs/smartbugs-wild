pragma solidity ^0.4.2;

/*
*  @notice the token contract used as reward 
*/
contract token {

    /*
    *  @notice exposes the transfer method of the token contract
    *  @param _receiver address receiving tokens
    *  @param _amount number of tokens being transferred       
    */    
    function transfer(address _receiver, uint _amount) returns (bool success) { }

    /*
    *  @notice exposes the priviledgedAddressBurnUnsoldCoins method of the token contract
    *  burns all unsold coins  
    */     
    function priviledgedAddressBurnUnsoldCoins(){ }

}

/*
`* is owned
*/
contract owned {

    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function ownerTransferOwnership(address newOwner)
        onlyOwner
    {
        owner = newOwner;
    }

}

/*
* safe math
*/
contract DSSafeAddSub {

    function safeToAdd(uint a, uint b) internal returns (bool) {
        return (a + b >= a);
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        if (!safeToAdd(a, b)) throw;
        return a + b;
    }

    function safeToSubtract(uint a, uint b) internal returns (bool) {
        return (b <= a);
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        if (!safeToSubtract(a, b)) throw;
        return a - b;
    } 

}

/* 
*  EtherollCrowdfund contract
*  Funds sent to this address transfer a customized ERC20 token to msg.sender for the duration of the crowdfund
*  Deployment order:
*  EtherollToken, EtherollCrowdfund
*  1) Send tokens to this
*  2) Assign this as priviledgedAddress in EtherollToken
*  3) Call updateTokenStatus in EtherollToken 
*  -- crowdfund is open --
*  4) safeWithdraw onlyAfterDeadline in this
*  5) ownerBurnUnsoldTokens onlyAfterDeadline in this
*  6) updateTokenStatus in EtherollToken freezes/thaws tokens
*/
contract EtherollCrowdfund is owned, DSSafeAddSub {

    /*
    *  checks only after crowdfund deadline
    */    
    modifier onlyAfterDeadline() { 
        if (now < deadline) throw;
        _; 
    }

    /*
    *  checks only in emergency
    */    
    modifier isEmergency() { 
        if (!emergency) throw;
        _; 
    } 

    /* the crowdfund goal */
    uint public fundingGoal;
    /* 1 week countdown to price increase */
    uint public weekTwoPriceRiseBegin = now + 10080 * 1 minutes;    
    /* 80% to standard multi-sig wallet contract is house bankroll  */
    address public bankRollBeneficiary;      
    /* 20% to etheroll wallet*/
    address public etherollBeneficiary;         
    /* total amount of ether raised */
    uint public amountRaised;
    /* two weeks */
    uint public deadline;
    /* 0.01 ETH per token base price */
    uint public price = 10000000000000000;
    /* address of token used as reward */
    token public tokenReward;
    /* crowdsale is open */
    bool public crowdsaleClosed = false;  
    /* 80% of funds raised */
    uint public bankrollBeneficiaryAmount;
    /* 20% of funds raised */    
    uint public etherollBeneficiaryAmount;
    /* map balance of address */
    mapping (address => uint) public balanceOf; 
    /* funding goal has not been reached */ 
    bool public fundingGoalReached = false;   
    /* escape hatch for all in emergency */
    bool public emergency = false; 

    /* log events */
    event LogFundTransfer(address indexed Backer, uint indexed Amount, bool indexed IsContribution);  
    event LogGoalReached(address indexed Beneficiary, uint indexed AmountRaised);       

    /*
    *  @param _ifSuccessfulSendToBeneficiary receives 80% of ether raised end of crowdfund
    *  @param _ifSuccessfulSendToEtheroll receives 20% of ether raised end of crowdfund
    *  @param _fundingGoalInEthers the funding goal of the crowdfund
    *  @param _durationInMinutes the length of the crowdfund in minutes
    *  @param _addressOfTokenUsedAsReward the token address   
    */  
    function EtherollCrowdfund(
        /* multi-sig address to send 80% */        
        address _ifSuccessfulSendToBeneficiary,
        /* address to send 20% */
        address _ifSuccessfulSendToEtheroll,
        /* funding goal */
        uint _fundingGoalInEthers,
        /* two weeks: 20160 minutes*/
        uint _durationInMinutes,
        /* token */
        token _addressOfTokenUsedAsReward
    ) {
        bankRollBeneficiary = _ifSuccessfulSendToBeneficiary;
        etherollBeneficiary = _ifSuccessfulSendToEtheroll;
        fundingGoal = _fundingGoalInEthers * 1 ether;
        deadline = now + _durationInMinutes * 1 minutes;
        tokenReward = token(_addressOfTokenUsedAsReward);
    }
  
    /*
    *  @notice public function
    *  default function is payable
    *  responsible for transfer of tokens based on price, msg.sender and msg.value
    *  tracks investment total of msg.sender 
    *  refunds any spare change
    */      
    function ()
        payable
    {

        /* crowdfund period is over */
        if(now > deadline) crowdsaleClosed = true;  

        /* crowdsale is closed */
        if (crowdsaleClosed) throw;

        /* do not allow creating 0 */        
        if (msg.value == 0) throw;      

        /* 
        *  transfer tokens
        *  check/set week two price rise
        */
        if(now < weekTwoPriceRiseBegin) {
                      
            /* week 1 power token conversion * 2: 1 ETH = 200 tokens */
            if(tokenReward.transfer(msg.sender, ((msg.value*price)/price)*2)) {
                LogFundTransfer(msg.sender, msg.value, true); 
            } else {
                throw;
            }

        }else{
            /* week 2 conversion: 1 ETH = 100 tokens */
            if(tokenReward.transfer(msg.sender, (msg.value*price)/price)) {
                LogFundTransfer(msg.sender, msg.value, true); 
            } else {
                throw;
            }            

        } 

        /* add to amountRaised */
        amountRaised = safeAdd(amountRaised, msg.value);          

        /* track ETH balanceOf address in case emergency refund is required */  
        balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender], msg.value);

    }    

    /*
    *  @notice public function
    *  onlyAfterDeadline
    *  moves ether to beneficiary contracts if goal reached
    *  if goal not reached msg.sender can withdraw their deposit
    */     
    function safeWithdraw() public
        onlyAfterDeadline
    {

        if (amountRaised >= fundingGoal){
            /* allows funds to be moved to beneficiary */
            fundingGoalReached = true;
            /* log event */            
            LogGoalReached(bankRollBeneficiary, amountRaised);           
        }    
            
        /* close crowdsale */
        crowdsaleClosed = true;  
                        
        /* 
        *  public 
        *  funding goal not reached 
        *  manual refunds
        */
        if (!fundingGoalReached) {
            calcRefund(msg.sender);
        }
        
        /* 
        *  onlyOwner can call
        *  funding goal reached 
        *  move funds to beneficiary addresses
        */        
        if (msg.sender == owner && fundingGoalReached) {

            /* multi-sig bankrollBeneficiary receives 80% */
            bankrollBeneficiaryAmount = (this.balance*80)/100;   

            /* send to trusted address bankRollBeneficiary 80% */      
            if (bankRollBeneficiary.send(bankrollBeneficiaryAmount)) {  

                /* log event */              
                LogFundTransfer(bankRollBeneficiary, bankrollBeneficiaryAmount, false);
            
                /* etherollBeneficiary receives remainder */
                etherollBeneficiaryAmount = this.balance;                  

                /* send to trusted address etherollBeneficiary the remainder */
                if(!etherollBeneficiary.send(etherollBeneficiaryAmount)) throw;

                /* log event */        
                LogFundTransfer(etherollBeneficiary, etherollBeneficiaryAmount, false);                 

            } else {

                /* allow manual refunds via safeWithdrawal */
                fundingGoalReached = false;

            }
        }
    }  

    /*
    *  @notice internal function
    *  @param _addressToRefund the address being refunded
    *  accessed via public functions emergencyWithdraw and safeWithdraw
    *  calculates refund amount available for an address  
    */     
    function calcRefund(address _addressToRefund) internal
    {
        /* assigns var amount to balance of _addressToRefund */
        uint amount = balanceOf[_addressToRefund];
        /* sets balance to 0 */
        balanceOf[_addressToRefund] = 0;
        /* is there any balance? */
        if (amount > 0) {
            /* call to untrusted address */
            if (_addressToRefund.call.value(amount)()) {
                /* log event */
                LogFundTransfer(_addressToRefund, amount, false);
            } else {
                /* unsuccessful send so reset the balance */
                balanceOf[_addressToRefund] = amount;
            }
        } 
    }     
   

    /*
    *  @notice public function
    *  emergency manual refunds
    */     
    function emergencyWithdraw() public
        isEmergency    
    {
        /* manual refunds */
        calcRefund(msg.sender);
    }        

    /*
    *  @notice owner restricted function   
    *  @param _newEmergencyStatus boolean
    *  sets contract mode to emergency status to allow individual withdraw via emergencyWithdraw()
    */    
    function ownerSetEmergencyStatus(bool _newEmergencyStatus) public
        onlyOwner 
    {        
        /* close crowdsale */
        crowdsaleClosed = _newEmergencyStatus;
        /* allow manual refunds via emergencyWithdraw */
        emergency = _newEmergencyStatus;        
    } 

    /*
    *  @notice  owner restricted function 
    *  burns any unsold tokens at end of crowdfund
    */      
    function ownerBurnUnsoldTokens()
        onlyOwner
        onlyAfterDeadline
    {
        tokenReward.priviledgedAddressBurnUnsoldCoins();
    }         


}