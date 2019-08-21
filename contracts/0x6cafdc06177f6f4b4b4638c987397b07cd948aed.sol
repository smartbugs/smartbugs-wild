contract JackPot {
    address public host;
	uint minAmount;
    uint[] public contributions;
    address[] public contributors;
	uint public numPlayers;
	uint public nextDraw;
	bytes32 public seedHash;
	bytes32 random;	

    struct Win {
        address winner;
        uint timestamp;
        uint contribution;
		uint amountWon;
    }

    Win[] public recentWins;
    uint recentWinsCount = 10;
	
	function insert_contribution(address addr, uint value) internal {
		// check if array needs extending
		if(numPlayers == contributions.length) {
			// extend the arrays
			contributions.length += 1;
			contributors.length += 1;
		}
		contributions[numPlayers] = value;
		contributors[numPlayers++] = addr;
	}
	
	function getContributions(address addr) constant returns (uint) {
        uint i;
        for (i=0; i < numPlayers; i++) {
			if (contributors[i] == addr) { // if in the list already
				break;
			}
		}
		
		if(i == numPlayers) { // Did not find sender already in the list
            return 0;
        } else {
			return contributions[i];
		}
    }
	
	function JackPot() {
        host = msg.sender;
		seedHash = sha3('aaaa');
		minAmount = 10 * 1 finney;
        recentWinsCount = 10;
		nextDraw = 1234;
    }

    function() {
        addToContribution();
    }

    function addToContribution() {
        addValueToContribution(msg.value);
    }

    function addValueToContribution(uint value) internal {
        // First, make sure this is a valid transaction.
        if(value < minAmount) throw;
	    uint i;
        for (i=0; i < numPlayers; i++) {
			if (contributors[i] == msg.sender) { // Already contributed?
				break;
			}
		}
		
		if(i == numPlayers) { // Did not find sender already in the list
			insert_contribution(msg.sender, value);
        } else {
			contributions[i]+= value; // Update amount
		}
		
		random = sha3(random, block.blockhash(block.number - 1));		
    }
	
	//drawPot triggered from Host after time has passed or pot is matured.
	function drawPot(string seed, string newSeed) {
		if(msg.sender != host) throw;
		if (sha3(seed) == seedHash) {
			
			// Initialize seedHash for next draw
			seedHash = sha3(newSeed);
			// Choose a winner using the seed as random
			uint winner_index = selectWinner(seed);

			// Send the developer a 1% fee
			host.send(this.balance / 100);
			
			uint amountWon = this.balance; 
			
			// Send the winner the remaining balance on the contract.
			contributors[winner_index].send(this.balance);
			
			// Make a note that someone won, then start all over!
			recordWin(winner_index, amountWon);

			reset();
			nextDraw = now + 7 days;	

		}
	}

	function setDrawDate(uint _newDraw) {
		if(msg.sender != host) throw;
		nextDraw = _newDraw;
	}
	
	
    function selectWinner(string seed) internal returns (uint winner_index) {

        uint semirandom = uint(sha3(random, seed)) % this.balance;
        for(uint i = 0; i < numPlayers; ++i) {
            if(semirandom < contributions[i]) return i;
            semirandom -= contributions[i];
        }
    }

    function recordWin(uint winner_index, uint amount) internal {
        if(recentWins.length < recentWinsCount) {
            recentWins.length++;
        } else {
            // Already at capacity for the number of winners to remember.
            // Forget the oldest one by shifting each entry 'left'
            for(uint i = 0; i < recentWinsCount - 1; ++i) {
                recentWins[i] = recentWins[i + 1];
            }
        }

        recentWins[recentWins.length - 1] = Win(contributors[winner_index], block.timestamp, contributions[winner_index], amount);
    }

    function reset() internal {
        // Clear the lists with min gas after the draw.
		numPlayers = 0;
    }


    /* This should only be needed if a bug is discovered
    in the code and the contract must be destroyed. */
    function destroy() {
        if(msg.sender != host) throw;

        // Refund everyone's contributions.
        for(uint i = 0; i < numPlayers; ++i) {
            contributors[i].send(contributions[i]);
        }

		reset();
        selfdestruct(host);
    }
}