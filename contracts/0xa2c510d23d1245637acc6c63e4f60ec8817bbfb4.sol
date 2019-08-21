pragma solidity ^0.4.25;

/**
  Info
*/

contract Test {
    address constant private PROMO1 = 0x51A2BF880F4db7713E95498833308ffE4D61d080;
	address constant private PROMO2 = 0x1e8f7BD53c898625cDc2416ae5f1c446A16dd8D9;
	address constant private TECH = 0x36413D58cA47520575889EE3E02E7Bb508b3D1E8;
    uint constant public PROMO_PERCENT1 = 1;
	uint constant public PROMO_PERCENT2 = 1;
	uint constant public TECH_PERCENT = 1;
    uint constant public MULTIPLIER = 110;
    
    struct Deposit {
        address depositor; 
        uint128 deposit;  
        uint128 expect;   
    }

    Deposit[] private queue;
    uint public currentReceiverIndex = 0;

    function () public payable {
        if(msg.value > 0){
            require(gasleft() >= 220000, "We require more gas!"); 
            require(msg.value >= 0.01 ether && msg.value <= 0.011 ether); 
            
            queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value*MULTIPLIER/100)));
            uint promo1 = msg.value*PROMO_PERCENT1/100;
            PROMO1.send(promo1);
			uint promo2 = msg.value*PROMO_PERCENT2/100;
            PROMO2.send(promo2);
			uint tech = msg.value*TECH_PERCENT/100;
            TECH.send(tech);
            pay();
        }
    }

    function pay() private {
        uint128 money = uint128(address(this).balance);
        for(uint i=0; i<queue.length; i++){
            uint idx = currentReceiverIndex + i;
            Deposit storage dep = queue[idx]; 
            if(money >= dep.expect){  
                dep.depositor.send(dep.expect); 
                money -= dep.expect;            
                delete queue[idx];
            }else{
                dep.depositor.send(money); 
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