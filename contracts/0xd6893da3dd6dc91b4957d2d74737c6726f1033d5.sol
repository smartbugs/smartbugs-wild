/**
  MAX150-Smoothly growing and long living multiplier without WHALES!, which returns 150% of your Deposit!

  A small limit on the Deposit eliminates the problems with the WHALES, which is very much inhibited the previous version of the contract and significantly prolongs its life!

  Automatic payouts!
  Full reports on the funds spent on advertising in the group!
  No errors, holes, automated payments do NOT NEED administration!
  Created and tested by professionals!
  The code is fully documented in Russian, each line is clear!
 
  Website: http://MAX150.com/
  The group in the telegram: https://t.me/MAX150

  1. Send any non-zero amount to the contract address
     - amount from 0.01 to 2 ETH
     - gas limit minimum 250,000
     - you'll be in line.
  2. Wait a little
  3. ...
  4. PROFIT! You received 150% of your Deposit.

  How is that possible?
  1. The first investor in the queue (you will be the first very soon) receives payments from
     new investors until they receive 150% of their Deposit
  2. Payments can come in several parts or all at once
  3. Once you receive 150% of your Deposit, you are removed from the queue
  4. You can make multiple deposits at once
  5. The balance of this contract shall usually be in area 0, because all of the proceeds
     immediately sent to the payment

     Thus, the latter pay first, and investors who have reached 150% of the Deposit,
     are removed from the queue, giving way to the rest

                new investor --|               brand new investor --|
                 investor5     |                 new investor       |
                 investor4     |     =======>      investor5        |
                 investor3     |                   investor4        |
                 investor2    <|                   investor3        |
                 investor1   <-|                   investor2   <----|  (pay until 150%)

*/

contract MAX150 {
    // E-wallet to pay for advertising
    address constant private ADS_SUPPORT = 0x0625b84dBAf2288e7E85ADEa8c5670A3eDEAeEE9;

    // The address of the wallet to invest back into the project
    address constant private TECH_SUPPORT = 0xA4bF3B49435F25531f36D219EC65f5eE77fd7a0a;

    // The percentage of Deposit is 5%
    uint constant public ADS_PERCENT = 5;

    // Deposit percentage for investment in the project 2%
    uint constant public TECH_PERCENT = 2;
    
    // Payout percentage for all participants
    uint constant public MULTIPLIER = 150;

    // The maximum Deposit amount = 2 ether, so that everyone can participate and whales do not slow down and do not scare investors
    uint constant public MAX_LIMIT = 2 ether;

    // The Deposit structure contains information about the Deposit
    struct Deposit {
        address depositor; // The owner of the Deposit
        uint128 deposit;   // Deposit amount
        uint128 expect;    // Payment amount (instantly 150% of the Deposit)
    }

    // Turn
    Deposit[] private queue;

    // The number of the Deposit to be processed can be found in the Read contract section
    uint public currentReceiverIndex = 0;

    // This function receives all deposits, saves them and makes instant payments
    function () public payable {
        // If the Deposit amount is greater than zero
        if(msg.value > 0){
            // Check the minimum gas limit of 220 000, otherwise cancel the Deposit and return the money to the depositor
            require(gasleft() >= 220000, "We require more gas!");

            // Check the maximum Deposit amount
            require(msg.value <= MAX_LIMIT, "Deposit is too big");

            // Add a Deposit to the queue, write down that he needs to pay 150% of the Deposit amount
            queue.push(Deposit(msg.sender, uint128(msg.value), uint128(msg.value * MULTIPLIER / 100)));

            // Send a percentage to promote the project
            uint ads = msg.value * ADS_PERCENT / 100;
            ADS_SUPPORT.transfer(ads);

            // We send a percentage for technical support of the project
            uint tech = msg.value * TECH_PERCENT / 100;
            TECH_SUPPORT.transfer(tech);

            // Call the payment function first in the queue Deposit
            pay();
        }
    }

    // The function is used to pay first in line deposits
    // Each new transaction processes 1 to 4+ depositors at the beginning of the queue 
    // Depending on the remaining gas
    function pay() private {
        // We will try to send all the money available on the contract to the first depositors in the queue
        uint128 money = uint128(address(this).balance);

        // We pass through the queue
        for(uint i = 0; i < queue.length; i++) {

            uint idx = currentReceiverIndex + i;  // We get the number of the first Deposit in the queue

            Deposit storage dep = queue[idx]; // We get information about the first Deposit

            if(money >= dep.expect) {  // If we have enough money for the full payment, we pay him everything
                dep.depositor.transfer(dep.expect); // Send him money
                money -= dep.expect; // Update the amount of remaining money

                // the Deposit has been fully paid, remove it
                delete queue[idx];
            } else {
                // We get here if we do not have enough money to pay everything, but only part of it
                dep.depositor.transfer(money); // Send all remaining
                dep.expect -= money;       // Update the amount of remaining money
                break;                     // Exit the loop
            }

            if (gasleft() <= 50000)         // Check if there is still gas, and if it is not, then exit the cycle
                break;                     //  The next depositor will make the payment next in line
        }

        currentReceiverIndex += i; // Update the number of the first Deposit in the queue
    }

    // Shows information about the Deposit by its number (idx), you can follow in the Read contract section
    // You can get the Deposit number (idx) by calling the getDeposits function()
    function getDeposit(uint idx) public view returns (address depositor, uint deposit, uint expect){
        Deposit storage dep = queue[idx];
        return (dep.depositor, dep.deposit, dep.expect);
    }

    // Shows the number of deposits of a particular investor
    function getDepositsCount(address depositor) public view returns (uint) {
        uint c = 0;
        for(uint i=currentReceiverIndex; i<queue.length; ++i){
            if(queue[i].depositor == depositor)
                c++;
        }
        return c;
    }

    // Shows all deposits (index, deposit, expect) of a certain investor, you can follow in the Read contract section
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
    
    // Shows a length of the queue can be monitored in the Read section of the contract
    function getQueueLength() public view returns (uint) {
        return queue.length - currentReceiverIndex;
    }

}