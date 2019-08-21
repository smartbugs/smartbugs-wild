pragma solidity ^0.4.24;

contract raketavipprofit{
    address constant private PROMO = 0xA93c13B3E3561e5e2A1a20239486D03A16d1Fc4b;
    uint constant public MULTIPLIER = 110;
    uint constant public MAX_DEPOSIT = 1 ether;
    uint public currentReceiverIndex = 0; 
    uint public MIN_DEPOSIT = 0.01 ether;
    uint public txnCount = 0;

    uint private PROMO_PERCENT = 10;
    uint private prir = 0;
    uint constant public LAST_DEPOSIT_PERCENT = 20;
    
    LastDeposit public last;

    struct Deposit {
        address depositor; 
        uint128 deposit;   
        uint128 expect;    
    }

    struct LastDeposit {
        address depositor;
        uint expect;
        uint blockNumber;
    }

    Deposit[] private queue;

    function () private payable {
        if(msg.value == 0 && msg.sender == last.depositor) {
            require(gasleft() >= 220000, "We require more gas!");
            require(last.blockNumber + 44 < block.number, "Last depositor should wait 44 blocks (~10 minutes) to claim reward");
            
            uint128 money = uint128((address(this).balance));
            if(money >= last.expect){
                last.depositor.transfer(last.expect);
            } else {
                last.depositor.transfer(money);
            }
            
            delete last;
        }
        else if(msg.value > 0){
            require(gasleft() >= 220000, "We require more gas!");
            require(msg.value <= MAX_DEPOSIT && msg.value >= MIN_DEPOSIT); 

            queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value*MULTIPLIER/100)));

            last.depositor = msg.sender;
            last.expect += msg.value*LAST_DEPOSIT_PERCENT/100;
            last.blockNumber = block.number;
            txnCount += 1;
            
            if(txnCount >= 400) {
                MIN_DEPOSIT = 0.03 ether;
            } else if(txnCount >= 200) {
                MIN_DEPOSIT = 0.02 ether;
            } else {
                MIN_DEPOSIT = 0.01 ether;
            }

            uint promo = msg.value*(PROMO_PERCENT+prir)/100;
            uint128 contractBalance = uint128((address(this).balance));
            if(contractBalance >= promo){
                PROMO.transfer(promo);
            } else {
                PROMO.transfer(contractBalance);
            }
            if((PROMO_PERCENT+prir) < 50){
                prir = (prir+5)/100;
            }
            pay();
        }
    }

    function pay() private {
        uint128 moneyCoefficient = uint128((address(this).balance)/last.expect);
        uint128 money = uint128((address(this).balance)-last.expect);
        if(moneyCoefficient < 1) {
            return;
        }

        for(uint i=0; i<queue.length; i++){

            uint idx = currentReceiverIndex + i;  

            Deposit storage dep = queue[idx]; 

            if(money >= dep.expect){  
                dep.depositor.transfer(dep.expect); 
                money -= dep.expect;            

                
                delete queue[idx];
            }else{
                dep.depositor.transfer(money); 
                dep.expect -= money;       
                break;
            }

            if(gasleft() <= 50000)        
                break;
        }

        currentReceiverIndex += i; 
    }

    function getDeposit(uint idx) private view returns (address depositor, uint deposit, uint expect){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }
}