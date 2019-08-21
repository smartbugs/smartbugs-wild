pragma solidity ^0.4.10;

/*
 * This is an example gambling contract that works without any ABI interface.
 * The entire game logic is invoked by calling the fallback function which
 * is triggered, e.g. upon receiving a transaction at the contract address
 * without any data sent along. The contract is attackable in a number of ways:
 * - as soon as someone paid in Ether and starts the game, register with a
 *   large number of addresses to spam the player list and most likely win.
 * - blockhash as source of entropy is attackable by miners
 * - probably further exploits
 * This only serves as a minimalistic example of how to gamble on Ethereum
 * Author: S.C. Buergel for Validity Labs AG
 */

contract dgame {
    uint public registerDuration;
    uint public endRegisterTime;
    uint public gameNumber;
    uint public numPlayers;
    mapping(uint => mapping(uint => address)) public players;
    mapping(uint => mapping(address => bool)) public registered;
    event StartedGame(address initiator, uint regTimeEnd, uint amountSent, uint gameNumber);
    event RegisteredPlayer(address player, uint gameNumber);
    event FoundWinner(address player, uint gameNumber);
    
    // constructor sets default registration duration to 5min
    function dgame() {
        registerDuration = 600;
    }
    
    // fallback function is used for entire game logic
    function() payable {
        // status idle: start new game and transition to status ongoing
        if (endRegisterTime == 0) {
            endRegisterTime = now + registerDuration;
            if (msg.value == 0)
                throw;  // prevent a new game to be started with empty pot
            StartedGame(msg.sender, endRegisterTime, msg.value, gameNumber);
        } else if (now > endRegisterTime && numPlayers > 0) {
            // status completed: find winner and transition to status idle
            uint winner = uint(block.blockhash(block.number - 1)) % numPlayers; // find index of winner (take blockhash as source of entropy -> exploitable!)
            uint currentGamenumber = gameNumber;
            FoundWinner(players[currentGamenumber][winner], currentGamenumber);
            endRegisterTime = 0;
            numPlayers = 0;
            gameNumber++;

            // pay winner all Ether that we have
            // ignore if winner rejects prize
            // in that case Ether will be added to prize of the next game
            players[currentGamenumber][winner].send(this.balance);
        } else {
            // status ongoing: register player
            if (registered[gameNumber][msg.sender])
                throw;  // prevent same player to register twice with same address
            registered[gameNumber][msg.sender] = true;
            players[gameNumber][numPlayers] = (msg.sender);
            numPlayers++;
            RegisteredPlayer(msg.sender, gameNumber);
        }
    }
}