pragma solidity ^0.4.25;
//Highly profitable fork of EasyInvest
//GAIN 8% per day until you return your deposit and 4% per day after that
//5% for advertising
contract EasyInvestPRO {
   
    mapping (address => uint256) public balance; //balances of investors
    mapping (address => uint256) public overallPayment; //overall payments for each investor
    mapping (address => uint256) public timestamp; //last investment time
    mapping (address => uint16) public rate; //interest rate for each investor
    address ads = 0x0c58F9349bb915e8E3303A2149a58b38085B4822; //advertising address
    
    
    function() external payable {
        
        ads.transfer(msg.value/20); //Send 5% for advertising
        //if investor already returned his deposit then his rate become 4%
        if(balance[msg.sender]>=overallPayment[msg.sender])
            rate[msg.sender]=80;
        else
            rate[msg.sender]=40;
        //payments    
        if (balance[msg.sender] != 0){
            uint256 paymentAmount = balance[msg.sender]*rate[msg.sender]/1000*(now-timestamp[msg.sender])/86400;
            // if investor receive more than 200 percent his balance become zero
            if (paymentAmount+overallPayment[msg.sender]>= 2*balance[msg.sender])
                balance[msg.sender]=0;
            // if profit amount is not enough on contract balance, will be sent what is left
            if (paymentAmount > address(this).balance) {
                paymentAmount = address(this).balance;
            }    
            msg.sender.transfer(paymentAmount);
            overallPayment[msg.sender]+=paymentAmount;
        }
        timestamp[msg.sender] = now;
        balance[msg.sender] += msg.value;
        
    }
}