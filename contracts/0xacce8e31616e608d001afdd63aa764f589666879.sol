pragma solidity ^0.4.11;
contract FundariaToken {
    uint public totalSupply;
    uint public supplyLimit;
    address public fundariaPoolAddress;
    
    function supplyTo(address, uint);
    function tokenForWei(uint) returns(uint);
    function weiForToken(uint) returns(uint);    
         
}

contract FundariaBonusFund {
    function setOwnedBonus() payable {}    
}

contract FundariaTokenBuy {
        
    address public fundariaBonusFundAddress;  // address of Fundaria 'bonus fund' contract
    address public fundariaTokenAddress; // address of Fundaria token contract
    
    uint public bonusPeriod = 64 weeks; // bonus period from moment of this contract creating
    uint constant bonusIntervalsCount = 9; // decreasing of bonus share with time
    uint public startTimestampOfBonusPeriod; // when the bonus period starts
    uint public finalTimestampOfBonusPeriod; // when the bonus period ends
    
    // for keeping of data to define bonus share at the moment of calling buy()    
    struct bonusData {
        uint timestamp;
        uint shareKoef;
    }
    
    // array to keep bonus related data
    bonusData[9] bonusShedule;
    
    address creator; // creator address of this contract
    // condition to be creator address to run some functions
    modifier onlyCreator { 
        if(msg.sender == creator) _;
    }
    
    function FundariaTokenBuy(address _fundariaTokenAddress) {
        fundariaTokenAddress = _fundariaTokenAddress;
        startTimestampOfBonusPeriod = now;
        finalTimestampOfBonusPeriod = now+bonusPeriod;
        for(uint8 i=0; i<bonusIntervalsCount; i++) {
            // define timestamps of bonus period intervals
            bonusShedule[i].timestamp = finalTimestampOfBonusPeriod-(bonusPeriod*(bonusIntervalsCount-i-1)/bonusIntervalsCount);
            // koef for decreasing bonus share
            bonusShedule[i].shareKoef = bonusIntervalsCount-i;
        }
        creator = msg.sender;
    }
    
    function setFundariaBonusFundAddress(address _fundariaBonusFundAddress) onlyCreator {
        fundariaBonusFundAddress = _fundariaBonusFundAddress;    
    } 
    
    // finish bonus if needed (if bonus system not efficient)
    function finishBonusPeriod() onlyCreator {
        finalTimestampOfBonusPeriod = now;    
    }
    
    // if token bought successfuly
    event TokenBought(address buyer, uint tokenToBuyer, uint weiForFundariaPool, uint weiForBonusFund, uint remnantWei);
    
    function buy() payable {
        require(msg.value>0);
        // use Fundaria token contract functions
        FundariaToken ft = FundariaToken(fundariaTokenAddress);
        // should be enough tokens before supply reached limit
        require(ft.supplyLimit()-1>ft.totalSupply());
        // tokens to buyer according to course
        var tokenToBuyer = ft.tokenForWei(msg.value);
        // should be enogh ether for at least 1 token
        require(tokenToBuyer>=1);
        // every second token goes to creator address
        var tokenToCreator = tokenToBuyer;
        uint weiForFundariaPool; // wei distributed to Fundaria pool
        uint weiForBonusFund; // wei distributed to Fundaria bonus fund
        uint returnedWei; // remnant
        // if trying to buy more tokens then supply limit
        if(ft.totalSupply()+tokenToBuyer+tokenToCreator > ft.supplyLimit()) {
            // how many tokens are supposed to buy?
            var supposedTokenToBuyer = tokenToBuyer;
            // get all remaining tokens and devide them between reciepents
            tokenToBuyer = (ft.supplyLimit()-ft.totalSupply())/2;
            // every second token goes to creator address
            tokenToCreator = tokenToBuyer; 
            // tokens over limit
            var excessToken = supposedTokenToBuyer-tokenToBuyer;
            // wei to return to buyer
            returnedWei = ft.weiForToken(excessToken);
        }
        
        // remaining wei for tokens
        var remnantValue = msg.value-returnedWei;
        // if bonus period is over
        if(now>finalTimestampOfBonusPeriod) {
            weiForFundariaPool = remnantValue;            
        } else {
            uint prevTimestamp;
            for(uint8 i=0; i<bonusIntervalsCount; i++) {
                // find interval to get needed bonus share
                if(bonusShedule[i].timestamp>=now && now>prevTimestamp) {
                    // wei to be distributed into the Fundaria bonus fund
                    weiForBonusFund = remnantValue*bonusShedule[i].shareKoef/(bonusIntervalsCount+1);    
                }
                prevTimestamp = bonusShedule[i].timestamp;    
            }
            // wei for Fundaria pool
            weiForFundariaPool = remnantValue-weiForBonusFund;           
        }
        // use Fundaria token contract function to distribute tokens to creator address
        ft.supplyTo(creator, tokenToCreator);
        // transfer wei for bought tokens to Fundaria pool
        (ft.fundariaPoolAddress()).transfer(weiForFundariaPool);
        // if we have wei for buyer to be saved in bonus fund
        if(weiForBonusFund>0) {
            FundariaBonusFund fbf = FundariaBonusFund(fundariaBonusFundAddress);
            // distribute bonus wei to bonus fund
            fbf.setOwnedBonus.value(weiForBonusFund)();
        }
        // if have remnant, return it to buyer
        if(returnedWei>0) msg.sender.transfer(returnedWei);
        // use Fundaria token contract function to distribute tokens to buyer
        ft.supplyTo(msg.sender, tokenToBuyer);
        // inform about 'token bought' event
        TokenBought(msg.sender, tokenToBuyer, weiForFundariaPool, weiForBonusFund, returnedWei);
    }
    
    // Prevents accidental sending of ether
    function () {
	    throw; 
    }      

}