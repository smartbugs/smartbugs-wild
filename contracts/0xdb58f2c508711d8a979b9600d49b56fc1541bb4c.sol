pragma solidity ^0.5.0;

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
    uint256 public registerDuration = 600;
    uint256 public endRegisterTime;
    uint256 public gameNumber;
    uint256 public numPlayers;
    mapping(uint256 => mapping(uint256 => address payable)) public players;
    mapping(uint256 => mapping(address => bool)) public registered;
    event StartedGame(address initiator, uint256 regTimeEnd, uint256 amountSent, uint256 gameNumber);
    event RegisteredPlayer(address player, uint256 gameNumber);
    event FoundWinner(address player, uint256 gameNumber);
    
    // fallback function is used for entire game logic
    function() external payable {
        // status idle: start new game and transition to status ongoing
        if (endRegisterTime == 0) {
            endRegisterTime = block.timestamp + registerDuration;
            require(msg.value > 0); // prevent a new game to be started with empty pot
            emit StartedGame(msg.sender, endRegisterTime, msg.value, gameNumber);
        } else if (block.timestamp > endRegisterTime && numPlayers > 0) {
            // status completed: find winner and transition to status idle
            uint256 winner = uint256(blockhash(block.number - 1)) % numPlayers; // find index of winner (take blockhash as source of entropy -> exploitable!)
            uint256 currentGamenumber = gameNumber;
            emit FoundWinner(players[currentGamenumber][winner], currentGamenumber);
            endRegisterTime = 0;
            numPlayers = 0;
            gameNumber++;

            // pay winner all Ether that we have
            // ignore if winner rejects prize
            // in that case Ether will be added to prize of the next game
            players[currentGamenumber][winner].send(address(this).balance);
        } else {
            // status ongoing: register player
            require(!registered[gameNumber][msg.sender]); // prevent same player to register twice with same address
            registered[gameNumber][msg.sender] = true;
            players[gameNumber][numPlayers] = (msg.sender);
            numPlayers++;
            emit RegisteredPlayer(msg.sender, gameNumber);
        }
    }
}