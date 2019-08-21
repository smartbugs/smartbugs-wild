pragma solidity ^0.4.17;

/*
-----------------------------------
Signals Society Membership Contract
-----------------------------------
*/

/**
 * @title Ownable
 * @dev Ownership functionality
 */
contract Ownable {
  address public owner;
  address public bot;
  // constructor, sets original owner address
  function Ownable() public {
    owner = msg.sender;
  }
  // modifier to restruct function use to the owner
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }    
  // modifier to restruct function use to the bot
  modifier onlyBot() {
    require(msg.sender == bot);
    _;
  }
  // lets owner change his address
  function changeOwner(address addr) public onlyOwner {
      owner = addr;
  }
  // lets owner change the bot's address    
  function changeBot(address addr) public onlyOwner {
      bot = addr;
  }
  // allows destruction of contract only if balance is empty
  function kill() public onlyOwner {
		require(this.balance == 0);
		selfdestruct(owner);
	}
}

 /**
 * @title Memberships
 * @dev anages membership prices
 */
contract Memberships is Ownable {
  // enumerates memberships (0, 1, 2)
  enum Membership { Day, Month, Lifetime }
  // holds the prices for the memberships
  mapping (uint => uint) internal prices;
  // returns the price for a single membership
  function getMembershipPrice(Membership membership) public view returns(uint) {
    return prices[uint(membership)];
  }
  // lets the owner set the price for a single membership
  function setMembershipPrice(Membership membership, uint amount) public onlyOwner {    
		require(amount > 0);
    prices[uint(membership)] = amount;
  }
}

 /**
 * @title MembSignalsSociety Contract
 */
contract SignalsSociety is Ownable, Memberships {

  // lets the bot know a deposit was made
  event Deposited(address account, uint amount, uint balance, uint timestamp);
  // lets the bot know a membership was paid
  event MembershipPaid(address account, Membership membership, uint timestamp);

  // store the amount of ETH deposited by each account.
  mapping (address => uint) public balances;

  // deposits ETH to a user's account
  function deposit(address account, uint amount) public {
    // deposit the amount to the user's account
    balances[account] += amount;
    // let the bot know something was deposited
    Deposited(account, amount, balances[account], now);
  }
  // accepts the membership payment by moving eth from the user's account
  // to the owner's account
  function acceptMembership(address account, Membership membership, uint discount, address reseller, uint comission) public onlyBot {
    // get the price for the membership they selected minus any discounts for special promotions
    uint price = getMembershipPrice(membership) - discount;
    // make sure they have enough balance to pay for it
    require(balances[account] >= price);
    // remove the payment from the user's account
    balances[account] -= price;
    // if this comes from a reseller
    if (reseller != 0x0) {
      // send the reseller his comission
      reseller.transfer(comission);
      // sent SS the rest
      owner.transfer(price - comission);
    } else {
      // otherwise send it all to ss
      owner.transfer(price);
    }    
    // let the bot know the membership was paid
    MembershipPaid(account, membership, now);
  }
  // default function.  Called when a user sends ETH to the contract.
  // deposits the eth to their bank account
  function () public payable {
    deposit(msg.sender, msg.value);
  }
}