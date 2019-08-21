pragma solidity ^0.4.24;

// --> http://lucky9.io <-- Ethereum Lottery.
//
// - 1 of 3 chance to win half of the JACKPOT! And every 999th ticket grabs 80% of the JACKPOT!
//
// - The house edge is 1% of the ticket price, 1% reserved for transactions.
//
// - The winnings are distributed by the Smart Contract automatically.
//
// - Smart Contract address: 0x53c2C4Ee7E625d0E415288d6e4E3F38a1BCB2038
// - More details at: https://etherscan.io/address/0x53c2C4Ee7E625d0E415288d6e4E3F38a1BCB2038
//
// - NOTE: Ensure sufficient gas limit for transaction to succeed. Gas limit 150000 should be sufficient.
//
// --- GOOD LUCK! ---
//

contract lucky9io {
    // Public variables
    uint public house_edge = 0;
    uint public jackpot = 0;
    address public last_winner;
    uint public last_win_wei = 0;
    uint public total_wins_wei = 0;
    uint public total_wins_count = 0;

    // Internal variables
    bool private game_alive = true;
    address private owner = 0x5Bf066c70C2B5e02F1C6723E72e82478Fec41201;
    uint private entry_number = 0;
    uint private value = 0;

    modifier onlyOwner() {
     require(msg.sender == owner, "Sender not authorized.");
     _;
    }

    function () public payable {
        // Only accept ticket purchases if the game is ON
        require(game_alive == true);

        // Price of the ticket is 0.009 ETH
        require(msg.value / 1000000000000000 == 9);

        // House edge + Jackpot (1% is reserved for transactions)
        jackpot = jackpot + (msg.value * 98 / 100);
        house_edge = house_edge + (msg.value / 100);

        // Owner does not participate in the play, only adds up to the JACKPOT
        if(msg.sender == owner) return;

        // Increasing the ticket number
        entry_number = entry_number + 1;

        // Let's see if the ticket is the 999th...
        if(entry_number % 999 == 0) {
            // We have a WINNER !!!

            // Calculate the prize money
            uint win_amount_999 = jackpot * 80 / 100;
            jackpot = jackpot - win_amount_999;

            // Set the statistics
            last_winner = msg.sender;
            last_win_wei = win_amount;
            total_wins_count = total_wins_count + 1;
            total_wins_wei = total_wins_wei + win_amount_999;

            // Pay the winning
            msg.sender.transfer(win_amount_999);
            return;
        } else {
            // Get the lucky number
            uint lucky_number = uint(keccak256(abi.encodePacked((entry_number+block.number), blockhash(block.number))));

            if(lucky_number % 3 == 0) {
                // We have a WINNER !!!

                // Calculate the prize money
                uint win_amount = jackpot * 50 / 100;
                if(address(this).balance - house_edge < win_amount) {
                    win_amount = (address(this).balance-house_edge) * 50 / 100;
                }

                jackpot = jackpot - win_amount;

                // Set the statistics
                last_winner = msg.sender;
                last_win_wei = win_amount;
                total_wins_count = total_wins_count + 1;
                total_wins_wei = total_wins_wei + win_amount;

                // Pay the winning
                msg.sender.transfer(win_amount);
            }

            return;
        }
    }

    function getBalance() constant public returns (uint256) {
        return address(this).balance;
    }

    function getTotalTickets() constant public returns (uint256) {
        return entry_number;
    }

    function getLastWin() constant public returns (uint256) {
        return last_win_wei;
    }

    function getLastWinner() constant public returns (address) {
        return last_winner;
    }

    function getTotalWins() constant public returns (uint256) {
        return total_wins_wei;
    }

    function getTotalWinsCount() constant public returns (uint256) {
        return total_wins_count;
    }

    // Owner functions
    function stopGame() public onlyOwner {
        game_alive = false;
        return;
    }

    function startGame() public onlyOwner {
        game_alive = true;
        return;
    }

    function transferHouseEdge(uint amount) public onlyOwner payable {
        require(amount <= house_edge);
        require((address(this).balance - amount) > 0);

        owner.transfer(amount);
        house_edge = house_edge - amount;
    }
}