pragma solidity ^0.4.11;

contract Ownable {
  address public owner;


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
    if (msg.sender != owner) {
      throw;
    }
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
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


contract BitcoinStore is Ownable {

  address constant public Bitcoin_address = 0xB6eD7644C69416d67B522e20bC294A9a9B405B31;
  uint tokenPrice = 35e14; // 0.0035 eth starting price
  uint tokenFactor = 1e8;

  function getBalance()
  public
  view
  returns (uint)
  {
      return ERC20Basic(Bitcoin_address).balanceOf(this);
  }

  function getPrice()
  public
  view
  returns (uint)
  {
      return tokenPrice;
  }

  function updatePrice(uint newPrice)
  onlyOwner
  {
      tokenPrice = newPrice;
  }

  function send(address _tokenAddr, address dest, uint value)
  onlyOwner
  {
      ERC20(_tokenAddr).transfer(dest, value);
  }

  /* fallback function for when ether is sent to the contract */
  function () external payable {
      uint buytokens = msg.value * tokenFactor / tokenPrice;
      require(getBalance() >= buytokens);
      ERC20(Bitcoin_address).transfer(msg.sender, buytokens);
  }

  function buy() public payable {
      uint buytokens = msg.value * tokenFactor / tokenPrice;
      require(getBalance() >= buytokens);
      ERC20(Bitcoin_address).transfer(msg.sender, buytokens);
  }

  function withdraw() onlyOwner {
      msg.sender.transfer(this.balance);
  }
}