pragma solidity ^0.4.25;

contract Formula1Game {

    address public support;

	uint constant public PRIZE_PERCENT = 5;
    uint constant public SUPPORT_PERCENT = 2;
    
    uint constant public MAX_INVESTMENT =  0.1 ether;
    uint constant public MIN_INVESTMENT = 0.01 ether;
    uint constant public MIN_INVESTMENT_FOR_PRIZE = 0.01 ether;
    uint constant public GAS_PRICE_MAX = 14; 
    uint constant public MAX_IDLE_TIME = 10 minutes; 

    uint constant public SIZE_TO_SAVE_INVEST = 10; 
    uint constant public TIME_TO_SAVE_INVEST = 5 minutes; 
    
    uint8[] MULTIPLIERS = [
        125, 
        135, 
        145 
    ];

    struct Deposit {
        address depositor; 
        uint128 deposit;  
        uint128 expect;    
    }

    struct DepositCount {
        int128 stage;
        uint128 count;
    }

    struct LastDepositInfo {
        uint128 index;
        uint128 time;
    }

    Deposit[] private queue;  

    uint public currentReceiverIndex = 0; 
    uint public currentQueueSize = 0; 
    LastDepositInfo public lastDepositInfoForPrize; 
    LastDepositInfo public previosDepositInfoForPrize; 

    uint public prizeAmount = 0; 
    uint public prizeStageAmount = 0; 
    int public stage = 0; 
    uint128 public lastDepositTime = 0; 
    
    mapping(address => DepositCount) public depositsMade; 

    constructor() public {
        support = msg.sender; 
        proceedToNewStage(getCurrentStageByTime() + 1);
    }
    
    function () public payable {
        require(tx.gasprice <= GAS_PRICE_MAX * 1000000000);
        require(gasleft() >= 250000, "We require more gas!"); 
        
        checkAndUpdateStage();
        
        if(msg.value > 0){
            require(msg.value >= MIN_INVESTMENT && msg.value <= MAX_INVESTMENT); 
            require(lastDepositInfoForPrize.time <= now + MAX_IDLE_TIME); 
            
            require(getNextStageStartTime() >= now + MAX_IDLE_TIME + 10 minutes);
            
            if(currentQueueSize < SIZE_TO_SAVE_INVEST){ 
                
                addDeposit(msg.sender, msg.value);
                
            } else {
                
                addDeposit(msg.sender, msg.value);
                pay(); 
                
            }
            
        } else if(msg.value == 0 && currentQueueSize > SIZE_TO_SAVE_INVEST){
            
            withdrawPrize(); 
            
        } else if(msg.value == 0){
            
            require(currentQueueSize <= SIZE_TO_SAVE_INVEST); 
            require(lastDepositTime > 0 && (now - lastDepositTime) >= TIME_TO_SAVE_INVEST); 
            
            returnPays(); 
            
        } 
    }

    function pay() private {
        
        uint balance = address(this).balance;
        uint128 money = 0;
        
        if(balance > prizeStageAmount) 
            money = uint128(balance - prizeStageAmount);
        
        uint128 moneyS = uint128(money*SUPPORT_PERCENT/100);
        support.send(moneyS);
        money -= moneyS;
        
        for(uint i=currentReceiverIndex; i<currentQueueSize; i++){

            Deposit storage dep = queue[i]; 

            if(money >= dep.expect){  
                    
                dep.depositor.send(dep.expect); 
                money -= dep.expect;          
                
                delete queue[i];
                
            }else{
                
                dep.depositor.send(money);      
                money -= dep.expect;            
                break;                     
            }

            if(gasleft() <= 50000)         
                break;                     
        }

        currentReceiverIndex = i; 
    }
    
    function returnPays() private {
        
        uint balance = address(this).balance;
        uint128 money = 0;
        
        if(balance > prizeAmount) 
            money = uint128(balance - prizeAmount);
        
        
        for(uint i=currentReceiverIndex; i<currentQueueSize; i++){

            Deposit storage dep = queue[i]; 

                dep.depositor.send(dep.deposit); 
                money -= dep.deposit;            
                
                
                delete queue[i];

        }

        prizeStageAmount = 0; 
        proceedToNewStage(getCurrentStageByTime() + 1);
    }

    function addDeposit(address depositor, uint value) private {
        
        DepositCount storage c = depositsMade[depositor];
        if(c.stage != stage){
            c.stage = int128(stage);
            c.count = 0;
        }

        
        if(value >= MIN_INVESTMENT_FOR_PRIZE){
            previosDepositInfoForPrize = lastDepositInfoForPrize;
            lastDepositInfoForPrize = LastDepositInfo(uint128(currentQueueSize), uint128(now));
        }

        
        uint multiplier = getDepositorMultiplier(depositor);
        
        push(depositor, value, value*multiplier/100);

        
        c.count++;

        lastDepositTime = uint128(now);
        
        
        prizeStageAmount += value*PRIZE_PERCENT/100;
    }

    function checkAndUpdateStage() private {
        int _stage = getCurrentStageByTime();

        require(_stage >= stage); 

        if(_stage != stage){
            proceedToNewStage(_stage);
        }
    }

    function proceedToNewStage(int _stage) private {
        
        stage = _stage;
        currentQueueSize = 0; 
        currentReceiverIndex = 0;
        lastDepositTime = 0;
        prizeAmount += prizeStageAmount; 
        prizeStageAmount = 0;
        delete queue;
        delete previosDepositInfoForPrize;
        delete lastDepositInfoForPrize;
    }

    function withdrawPrize() private {
        
        require(lastDepositInfoForPrize.time > 0 && lastDepositInfoForPrize.time <= now - MAX_IDLE_TIME, "The last depositor is not confirmed yet");
        
        require(currentReceiverIndex <= lastDepositInfoForPrize.index, "The last depositor should still be in queue");

        uint balance = address(this).balance;
        
        uint prize = balance;
        if(previosDepositInfoForPrize.index > 0){
            uint prizePrevios = prize*10/100;
            queue[previosDepositInfoForPrize.index].depositor.transfer(prizePrevios);
            prize -= prizePrevios;
        }

        queue[lastDepositInfoForPrize.index].depositor.send(prize);
        
        proceedToNewStage(getCurrentStageByTime() + 1);
    }

    function push(address depositor, uint deposit, uint expect) private {
        
        Deposit memory dep = Deposit(depositor, uint128(deposit), uint128(expect));
        assert(currentQueueSize <= queue.length); 
        if(queue.length == currentQueueSize)
            queue.push(dep);
        else
            queue[currentQueueSize] = dep;

        currentQueueSize++;
    }

    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }

    function getDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=currentReceiverIndex; i<currentQueueSize; ++i){
            if(queue[i].depositor == depositor)
                c++;
        }
        return c;
    }

    function getQueueLength() public view returns (uint) {
        return currentQueueSize - currentReceiverIndex;
    }

    function getDepositorMultiplier(address depositor) public view returns (uint) {
        DepositCount storage c = depositsMade[depositor];
        uint count = 0;
        if(c.stage == getCurrentStageByTime())
            count = c.count;
        if(count < MULTIPLIERS.length)
            return MULTIPLIERS[count];

        return MULTIPLIERS[MULTIPLIERS.length - 1];
    }

    function getCurrentStageByTime() public view returns (int) {
        return int(now - 17847 * 86400 - 9 * 3600) / (24 * 60 * 60);
    }

    function getNextStageStartTime() public view returns (uint) {
        return 17847 * 86400 + 9 * 3600 + uint((getCurrentStageByTime() + 1) * 24 * 60 * 60); 
    }

    function getCurrentCandidateForPrize() public view returns (address addr, int timeLeft){
        if(currentReceiverIndex <= lastDepositInfoForPrize.index && lastDepositInfoForPrize.index < currentQueueSize){
            Deposit storage d = queue[lastDepositInfoForPrize.index];
            addr = d.depositor;
            timeLeft = int(lastDepositInfoForPrize.time + MAX_IDLE_TIME) - int(now);
        }
    }
}