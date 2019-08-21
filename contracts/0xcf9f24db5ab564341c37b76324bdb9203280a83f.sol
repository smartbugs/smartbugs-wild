pragma solidity ^0.4.24;

contract fastum{
    uint public start = 6648350;
    uint public nowblock = now;
    modifier saleIsOn() {
    	require(block.number > start);
    	_;
    }
    address constant private PROMO = 0xA93c13B3E3561e5e2A1a20239486D03A16d1Fc4b;
    uint constant public MULTIPLIER = 115;
    uint constant public MAX_DEPOSIT = 1 ether;
    uint public currentReceiverIndex = 0; 
    uint public txnCount =0;
    uint public MIN_DEPOSIT = 0.01 ether;
    uint private PROMO_PERCENT = 15;
    uint constant public LAST_DEPOSIT_PERCENT = 10;
    
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

    function () saleIsOn private  payable {
        if(msg.value == 0 && msg.sender == last.depositor) {
            require(gasleft() >= 220000, "We require more gas!");
            require(last.blockNumber + 45 < block.number, "Last depositor should wait 45 blocks (~9-11 minutes) to claim reward");
            
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
            
            if(txnCount > 200) {
                MIN_DEPOSIT = 0.05 ether;
            } else if(txnCount > 150) {
                MIN_DEPOSIT = 0.04 ether;
            } else if(txnCount > 100) {
                MIN_DEPOSIT = 0.03 ether;
            }else if(txnCount > 50) {
                MIN_DEPOSIT = 0.02 ether;
            }else {
                MIN_DEPOSIT = 0.01 ether;
            }

            uint promo = msg.value*PROMO_PERCENT/100;
            uint128 contractBalance = uint128((address(this).balance));
            if(contractBalance >= promo){
                PROMO.transfer(promo);
            } else {
                PROMO.transfer(contractBalance);
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

    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }
    
    function getDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=currentReceiverIndex; i<queue.length; ++i){
            if(queue[i].depositor == depositor)
                c++;
        }
        return c;
    }

    function getDeposits(address depositor) public view returns (uint[] idxs, uint128[] deposits, uint128[] expects) {
        uint c = getDepositsCount(depositor);

        idxs = new uint[](c);
        deposits = new uint128[](c);
        expects = new uint128[](c);

        if(c > 0) {
            uint j = 0;
            for(uint i=currentReceiverIndex; i<queue.length; ++i){
                Deposit storage dep = queue[i];
                if(dep.depositor == depositor){
                    idxs[j] = i;
                    deposits[j] = dep.deposit;
                    expects[j] = dep.expect;
                    j++;
                }
            }
        }
    }
    
}