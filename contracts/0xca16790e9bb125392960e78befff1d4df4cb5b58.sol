pragma solidity ^0.4.5;

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
  uint registerDuration;
  uint endRegisterTime;
  address[] players;
  string debug;

  // constructor sets default registration duration to 180s
  function dgame() {
    registerDuration = 180;
  }

  // fallback function is used to register players and pay winner
  function () payable {
    if (players.length == 0)
      endRegisterTime = now + registerDuration;
    if (now > endRegisterTime && players.length > 0) {
      // find index of winner (take blockhash as source of entropy -> exploitable!)
      uint winner = uint(block.blockhash(block.number - 1)) % players.length;
      
      // pay winner all Ether that we have
      // ignore if winner rejects prize
      // in that case Ether will be added to prize of the next game
      players[winner].send(this.balance);
      
      // delete all players to allow for a next game
      delete players;
    }
    else
      players.push(msg.sender);
  }
  
}