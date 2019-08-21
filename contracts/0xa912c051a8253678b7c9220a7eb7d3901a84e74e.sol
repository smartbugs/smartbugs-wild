//
//     Multisend
//  Crypto Duel Coin Multisend
//
//       Crypto Duel Coin (CDC) is a cryptocurrency for online game and online casino. Our goal is very simple. It is create and operate an online game website   where the dedicated token is used. We will develop a lot of exciting games such as cards, roulette, chess, board games and original games and build the game website where people around the world can feel free to join.

// 
//     INFORMATION
//  Name: Crypto Duel Coin 
//  Symbol: CDC
//  Decimal: 18
//  Supply: 40,000,000,000
// 
//
//
//
//
//  Website = http://cryptoduelcoin.com/   Twitter = https://twitter.com/CryptoDuelCoin
//
//
//  Telegram = https://t.me/CryptoDuelCoin  Medium = https://medium.com/crypto-duel-coin
//
//
// 
// 
//
// Crypto Duel Coin 


pragma solidity ^0.4.11;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control 
 * functions, this simplifies the implementation of "user permissions". 
 */
contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }
 
  modifier onlyOwner() {
    if (msg.sender != owner) {
      revert();
    }
    _;
  }
 
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
}
 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint);
  function transferFrom(address from, address to, uint value);
  function approve(address spender, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract CyyptoDuelCoin is Ownable {

    function multisend(address _tokenAddr, address[] dests, uint256[] values)
    onlyOwner
    returns (uint256) {
        uint256 i = 0;
        while (i < dests.length) {
           ERC20(_tokenAddr).transfer(dests[i], values[i]);
           i += 1;
        }
        return(i);
    }
}