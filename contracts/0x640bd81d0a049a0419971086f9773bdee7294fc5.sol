pragma solidity ^0.4.25;


contract Fast50plus {
    //Address for marketing expences
    address constant private MARKETING = 0x82770c9dE54e316a9eba378516A3314Bc17FAcbe;
    //Percent for marketing expences
    uint constant public MARKETING_PERCENT = 8;
    uint constant public MAX_PERCENT = 110;
    
    struct Deposit {
        address depositor; 
        uint128 deposit;  
        uint128 expect;   
    }

    Deposit[] private queue;  
    uint public currentReceiverIndex = 0;
    
    function () public payable {
        if(msg.value > 0){
            
            require(gasleft() >= 220000);
            require(msg.value <= 7.5 ether);
            
            queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value*MAX_PERCENT/100)));
            uint promo = msg.value*MARKETING_PERCENT/100;
            MARKETING.transfer(promo);
            pay();
        }
    }
    
    function pay() private {
        //Try to send all the money on contract to the first investors in line
        uint128 money = uint128(address(this).balance);

        //We will do cycle on the queue
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
    
    function getQueueLength() public view returns (uint) {
        return queue.length - currentReceiverIndex;
    }

}