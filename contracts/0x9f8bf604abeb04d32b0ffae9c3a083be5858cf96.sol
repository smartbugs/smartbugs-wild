contract GameOfThrones {
    address public trueGods;
    // King's Jester
    address public jester;
    // Record the last collection time
    uint public lastCollection;
    // Record the last fell time
    uint public lastFell;
    // Record king life
    uint public onThrone;
    uint public kingCost;
    // Piggy Bank Amount
    uint public piggyBank;
    // Collected Fee Amount
    uint public godBank;
    uint public jesterBank;
    uint public kingBank;

    // Track the citizens who helped to arm race
    address[] public citizensAddresses;
    uint[] public citizensAmounts;
    uint32 public totalCitizens;
    uint32 public lastCitizenPaid;
    // The mad king establishes the government
    address public madKing;
    // Record how many times the castle had fell
    uint32 public round;
    // Amount already paid back in this round
    uint public amountAlreadyPaidBack;
    // Amount invested in this round
    uint public amountInvested;

    uint constant TWENTY_FOUR_HOURS = 60 * 60 * 24;
    uint constant PEACE_PERIOD = 60 * 60 * 240;

    function GameOfThrones() {
        // Define the first castle
        trueGods = msg.sender;
        madKing = msg.sender;
        jester = msg.sender;
        lastFell = block.timestamp;
        lastCollection = block.timestamp;
        onThrone = block.timestamp;
        kingCost = 1 ether;
        amountAlreadyPaidBack = 0;
        amountInvested = 0;
        totalCitizens = 0;
    }

    function protectKingdom() returns(bool) {
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
        if (lastCollection + TWENTY_FOUR_HOURS < block.timestamp) {
            // Send the Piggy Bank to the last 3 citizens
            // If there is no one who contributed this last 24 hours, no action needed
            if (totalCitizens == 1) {
                // If there is only one Citizen who contributed, he gets the full Pigg Bank
                citizensAddresses[citizensAddresses.length - 1].send(piggyBank * 95 / 100);
            } else if (totalCitizens == 2) {
                // If only 2 citizens contributed
                citizensAddresses[citizensAddresses.length - 1].send(piggyBank * 60 / 100);
                citizensAddresses[citizensAddresses.length - 2].send(piggyBank * 35 / 100);
            } else if (totalCitizens >= 3) {
                // If there is 3 or more citizens who contributed
                citizensAddresses[citizensAddresses.length - 1].send(piggyBank * 50 / 100);
                citizensAddresses[citizensAddresses.length - 2].send(piggyBank * 30 / 100);
                citizensAddresses[citizensAddresses.length - 3].send(piggyBank * 15 / 100);
            }

            godBank += piggyBank * 5 / 100;
            // Define the new Piggy Bank
            piggyBank = 0;

            // Define the new Castle
            jester = msg.sender;

            lastFell = block.timestamp;
            citizensAddresses.push(msg.sender);
            citizensAmounts.push(amount * 110 / 100);
            totalCitizens += 1;
            investInTheSystem(amount);
            godAutomaticCollectFee();
            // 95% goes to the Piggy Bank
            piggyBank += amount * 90 / 100;

            round += 1;
        } else {
            if (lastFell + TWENTY_FOUR_HOURS * 2 >= block.timestamp) {
                citizensAddresses.push(msg.sender);
                citizensAmounts.push(amount * 130 / 100);
            } else {
                citizensAddresses.push(msg.sender);
                citizensAmounts.push(amount * 110 / 100);
            }
            totalCitizens += 1;
            investInTheSystem(amount);

            while (citizensAmounts[lastCitizenPaid] < (address(this).balance - piggyBank - godBank - kingBank - jesterBank) && lastCitizenPaid <= totalCitizens) {
                citizensAddresses[lastCitizenPaid].send(citizensAmounts[lastCitizenPaid]);
                amountAlreadyPaidBack += citizensAmounts[lastCitizenPaid];
                lastCitizenPaid += 1;
            }
        }
    }

    // fallback function
    function() internal {
        protectKingdom();
    }

    function investInTheSystem(uint amount) internal {
        // The Castle is still up
        lastCollection = block.timestamp;
        amountInvested += amount;
        // The Jetster takes 5%
        jesterBank += amount * 5 / 100;
        // The mad king takes 5%
        kingBank += amount * 5 / 100;
        // 5% goes to the Piggy Bank
        piggyBank += (amount * 5 / 100);

        kingAutomaticCollectFee();
        jesterAutomaticCollectFee();
    }

    // When the mad king decides to give his seat to someone else
    // the king cost will be reset to 1 ether
    function abdicate() {
        if (msg.sender == madKing && msg.sender != trueGods) {
            madKing.send(kingBank);
            if (piggyBank > kingCost * 40 / 100) {
                madKing.send(kingCost * 40 / 100);
                piggyBank -= kingCost * 40 / 100;
            }
            else {
                madKing.send(piggyBank);
                piggyBank = 0;
            }

            madKing = trueGods;
            kingCost = 1 ether;
        }
    }

    function murder() {
        uint amount = 100 finney;
        if (msg.value >= amount && msg.sender != jester) {
            // return jester
            jester.send(jesterBank);
            jesterBank = 0;

            jester = msg.sender;
            msg.sender.send(msg.value - amount);
            investInTheSystem(amount);
        } else {
            throw;
        }
    }

    // Anyone can usurpation the kingship
    function usurpation() {
        uint amount = msg.value;
        // Add more money for king usurpation cost
        if (msg.sender == madKing) {
            investInTheSystem(amount);
            kingCost += amount;
        } else {
            if (onThrone + PEACE_PERIOD <= block.timestamp && amount >= kingCost * 150 / 100) {
                // return the fees to before king
                madKing.send(kingBank);
                // offer sacrifices to the Gods
                godBank += amount * 5 / 100;
                // new king
                kingCost = amount;
                madKing = msg.sender;
                onThrone = block.timestamp;
                investInTheSystem(amount);
            } else {
                throw;
            }
        }
    }

    // When the king decides to collect his fees
    function collectFee() {
        if (msg.sender == trueGods) {
            trueGods.send(godBank);
        }
    }

    function godAutomaticCollectFee() internal {
        if (godBank >= 1 ether) {
          trueGods.send(godBank);
          godBank = 0;
        }
    }

    function kingAutomaticCollectFee() internal {
        if (kingBank >= 100 finney) {
          madKing.send(kingBank);
          kingBank = 0;
        }
    }

    function jesterAutomaticCollectFee() internal {
        if (jesterBank >= 100 finney) {
          jester.send(jesterBank);
          jesterBank = 0;
        }
    }
}