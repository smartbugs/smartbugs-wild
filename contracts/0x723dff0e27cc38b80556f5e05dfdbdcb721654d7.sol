pragma solidity ^0.4.4;
contract DFS {
  
    struct Deposit {
        uint amount;
        uint plan;
        uint time;
        uint payed;
        address sender;
    }
    uint numDeposits;
    mapping (uint => Deposit) deposits;
    
    address constant owner1 = 0x8D98b4360F20FD285FF38bd2BB2B0e4E9159D77e;
    address constant owner2 = 0x1D8850Ff087b3256Cb98945D478e88bAeF892Bd4;
    
    function makeDeposit(
        uint plan,
        address ref1,
        address ref2,
        address ref3
    ) payable {

        /* minimum amount is 3 ether, plan must be 1, 2 or 3 */
        if (msg.value < 3 ether || (plan != 1 && plan !=2 && plan !=3)) {
            throw;
        }

        uint amount;
        /* maximum amount is 1000 ether */
        if (msg.value > 1000 ether) {
            if(!msg.sender.send(msg.value - 1000 ether)) {
                throw;
            }
            amount = 1000 ether;
        } else {
            amount = msg.value;
        }
        
        deposits[numDeposits++] = Deposit({
            sender: msg.sender,
            time: now,
            amount: amount,
            plan: plan,
            payed: 0,
        });
        
        /* fee */
        if(!owner1.send(amount *  5/2 / 100)) {
            throw;
        }
        if(!owner2.send(amount *  5/2 / 100)) {
            throw;
        }
        
        /* referral rewards */
        if(ref1 != address(0x0)){
            /* 1st level referral rewards */
            if(!ref1.send(amount * 5 / 100)) {
                throw;
            }
            if(ref2 != address(0x0)){
                /* 2nd level referral rewards */
                if(!ref2.send(amount * 2 / 100)) {
                    throw;
                }
                if(ref3 != address(0x0)){
                    /* 3nd level referral rewards */
                    if(!ref3.send(amount / 100)) {
                        throw;
                    }
                }
            }
        }
    }

    uint i;

    function pay(){

        while (i < numDeposits && msg.gas > 200000) {

            uint rest =  (now - deposits[i].time) % 1 days;
            uint depositDays =  (now - deposits[i].time - rest) / 1 days;
            uint profit;
            uint amountToWithdraw;
            
            if(deposits[i].plan == 1){
                if(depositDays > 30){
                    depositDays = 30;
                }
                profit = deposits[i].amount * depositDays  * 7/2 / 100;
            }
            
            if(deposits[i].plan == 2){
                if(depositDays > 90){
                    depositDays = 90;
                }
                profit = deposits[i].amount * depositDays  * 27/20 / 100;
            }
            
            if(deposits[i].plan == 3){
                if(depositDays > 180){
                    depositDays = 180;
                }
                profit = deposits[i].amount * depositDays  * 9/10 / 100;
            }
            
 
            if(profit > deposits[i].payed){
                amountToWithdraw = profit - deposits[i].payed;
                if(this.balance > amountToWithdraw){
                    if(!deposits[i].sender.send(amountToWithdraw)) {}
                    deposits[i].payed = profit;
                } else {
                    return;
                }
            }
            i++;
        }
        if(i == numDeposits){
             i = 0;
        }
    }
}