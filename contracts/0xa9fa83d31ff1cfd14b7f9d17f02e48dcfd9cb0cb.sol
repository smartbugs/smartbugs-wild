pragma solidity ^0.4.9;

/*
Protect The Castle !

The castle is under attack and needs the help of its citizens to support the cost of war.

If you are a loyal citizen and help to finance the defense of the castle, the King will pay you back 2 times what you invested when its fund will allow him to.

If no one contributes to the reparation for 6 hours, the castle will fall under the attack and the last 3 citizens who financed the defense will get the King’s Piggy bank (respectively 55%, 30% and 15%).

If you are the first one to invest after the castle has fallen, you will be the new King's Jester and take 3% of all the transactions until the castle falls again.

There are always some people to bribe, so a small fee of 3% is taken to ensure the system keeps working.

NO SURRENDER EDITION - no self-destruct - this game will run forever!
*/

contract ProtectTheCastle {
    // King's Jester
    address public jester;
    // Record the last Reparation time
    uint public lastReparation;
    // Piggy Bank Amount
    uint public piggyBank;

    // Collected Fee Amount
    uint public collectedFee;

    // Track the citizens who helped to repair the castle
    address[] public citizensAddresses;
    uint[] public citizensAmounts;
    uint32 public totalCitizens;
    uint32 public lastCitizenPaid;
    // Bribed Citizen who made the system works
    address public bribedCitizen;
    // Record how many times the castle has fallen
    uint32 public round;
    // Amount already paid back in this round
    uint public amountAlreadyPaidBack;
    // Amount invested in this round
    uint public amountInvested;

    uint constant SIX_HOURS = 60 * 60 * 6;

    function ProtectTheCastle() {
        // Define the first castle
        bribedCitizen = msg.sender;
        jester = msg.sender;
        lastReparation = block.timestamp;
        amountAlreadyPaidBack = 0;
        amountInvested = 0;
        totalCitizens = 0;
    }

    function repairTheCastle() payable returns(bool) {
        uint amount = msg.value;
        // Check if the minimum amount if reached
        if (amount < 10 finney) {
            msg.sender.send(msg.value);
            return false;
        }
        // If the amount received is more than 100 ETH return the difference
        if (amount > 100 ether) {
            msg.sender.send(msg.value - 100 ether);
            amount = 100 ether;
        }

        // Check if the Castle has fell
        if (lastReparation + SIX_HOURS < block.timestamp) {
            // Send the Piggy Bank to the last 3 citizens
            // If there is no one who contributed this last 6 hours, no action needed
            if (totalCitizens == 1) {
                // If there is only one Citizen who contributed, he gets the full Pigg Bank
                citizensAddresses[citizensAddresses.length - 1].send(piggyBank);
            } else if (totalCitizens == 2) {
                // If only 2 citizens contributed
                citizensAddresses[citizensAddresses.length - 1].send(piggyBank * 65 / 100);
                citizensAddresses[citizensAddresses.length - 2].send(piggyBank * 35 / 100);
            } else if (totalCitizens >= 3) {
                // If there are 3 or more citizens who contributed
                citizensAddresses[citizensAddresses.length - 1].send(piggyBank * 55 / 100);
                citizensAddresses[citizensAddresses.length - 2].send(piggyBank * 30 / 100);
                citizensAddresses[citizensAddresses.length - 3].send(piggyBank * 15 / 100);
            }

            // Define the new Piggy Bank
            piggyBank = 0;

            // Define the new Castle
            jester = msg.sender;
            lastReparation = block.timestamp;
            citizensAddresses.push(msg.sender);
            citizensAmounts.push(amount * 2);
            totalCitizens += 1;
            amountInvested += amount;

            // All goes to the Piggy Bank
            piggyBank += amount;

            // The Jester take 3%
            jester.send(amount * 3 / 100);

            // The bribed Citizen takes 3%
            collectedFee += amount * 3 / 100;

            round += 1;
        } else {
            // The Castle is still up
            lastReparation = block.timestamp;
            citizensAddresses.push(msg.sender);
            citizensAmounts.push(amount * 2);
            totalCitizens += 1;
            amountInvested += amount;

            // 5% goes to the Piggy Bank
            piggyBank += (amount * 5 / 100);

            // The Jester takes 3%
            jester.send(amount * 3 / 100);

            // The bribed Citizen takes 3%
            collectedFee += amount * 3 / 100;

            while (citizensAmounts[lastCitizenPaid] < (address(this).balance - piggyBank - collectedFee) && lastCitizenPaid <= totalCitizens) {
                citizensAddresses[lastCitizenPaid].send(citizensAmounts[lastCitizenPaid]);
                amountAlreadyPaidBack += citizensAmounts[lastCitizenPaid];
                lastCitizenPaid += 1;
            }
        }
    }

    // fallback function
    function() payable {
        repairTheCastle();
    }

    // When the bribed Citizen decides to give his seat to someone else
    function newBribedCitizen(address newBribedCitizen) {
        if (msg.sender == bribedCitizen) {
            bribedCitizen = newBribedCitizen;
        }
    }

    // When the bribed Citizen decides to collect his fees
    function collectFee() payable {
        if (msg.sender == bribedCitizen) {
            bribedCitizen.send(collectedFee);
        }
    }

    // When the jester can't handle it anymore, he can give his position to someone else
    function newJester(address newJester) {
        if (msg.sender == jester) {
            jester = newJester;
        }
    }       
}