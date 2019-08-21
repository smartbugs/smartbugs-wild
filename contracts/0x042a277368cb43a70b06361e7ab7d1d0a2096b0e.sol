pragma solidity ^0.4.11;
contract FundariaBonusFund {
    
    mapping(address=>uint) public ownedBonus; // storing bonus wei
    mapping(address=>int) public investorsAccounts; // Fundaria investors accounts
    uint public finalTimestampOfBonusPeriod; // when the bonus period ends
    address registeringContractAddress; // contract which can register investors accounts
    address public fundariaTokenBuyAddress; // address of FundariaTokenBuy contract
    address creator; // creator address of this contract
    
    event BonusWithdrawn(address indexed bonusOwner, uint bonusValue);
    event AccountFilledWithBonus(address indexed accountAddress, uint bonusValue, int totalValue);
    
    function FundariaBonusFund() {
        creator = msg.sender;
    }
    
    // condition to be creator address to run some functions
    modifier onlyCreator { 
        if(msg.sender == creator) _; 
    }
    
    // condition for method to be executed only by bonus owner
    modifier onlyBonusOwner { 
        if(ownedBonus[msg.sender]>0) _; 
    }
    
    function setFundariaTokenBuyAddress(address _fundariaTokenBuyAddress) onlyCreator {
        fundariaTokenBuyAddress = _fundariaTokenBuyAddress;    
    }
    
    function setRegisteringContractAddress(address _registeringContractAddress) onlyCreator {
        registeringContractAddress = _registeringContractAddress;    
    }
    
    // availability for creator address to set when bonus period ends, but not later then current end moment
    function setFinalTimestampOfBonusPeriod(uint _finalTimestampOfBonusPeriod) onlyCreator {
        if(finalTimestampOfBonusPeriod==0 || _finalTimestampOfBonusPeriod<finalTimestampOfBonusPeriod)
            finalTimestampOfBonusPeriod = _finalTimestampOfBonusPeriod;    
    }
    
    
    // bonus creator can withdraw their wei after bonus period ended
    function withdrawBonus() onlyBonusOwner {
        if(now>finalTimestampOfBonusPeriod) {
            var bonusValue = ownedBonus[msg.sender];
            ownedBonus[msg.sender] = 0;
            BonusWithdrawn(msg.sender, bonusValue);
            msg.sender.transfer(bonusValue);
        }
    }
    
    // registering investor account
    function registerInvestorAccount(address accountAddress) {
        if(creator==msg.sender || registeringContractAddress==msg.sender) {
            investorsAccounts[accountAddress] = -1;    
        }
    }

    // bonus owner can transfer their bonus wei to any investor account before bonus period ended
    function fillInvestorAccountWithBonus(address accountAddress) onlyBonusOwner {
        if(investorsAccounts[accountAddress]==-1 || investorsAccounts[accountAddress]>0) {
            var bonusValue = ownedBonus[msg.sender];
            ownedBonus[msg.sender] = 0;
            if(investorsAccounts[accountAddress]==-1) investorsAccounts[accountAddress]==0; 
            investorsAccounts[accountAddress] += int(bonusValue);
            AccountFilledWithBonus(accountAddress, bonusValue, investorsAccounts[accountAddress]);
            accountAddress.transfer(bonusValue);
        }
    }
    
    // add information about bonus wei ownership
    function setOwnedBonus() payable {
        if(msg.sender == fundariaTokenBuyAddress)
            ownedBonus[tx.origin] += msg.value;         
    }
}