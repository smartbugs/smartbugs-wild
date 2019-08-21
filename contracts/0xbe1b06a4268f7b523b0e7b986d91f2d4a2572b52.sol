pragma solidity ^0.4.19;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract ERC20 {
  function balanceOf(address _owner) constant returns (uint256 balance) {}
  function transfer(address _to, uint256 _value) returns (bool success) {}
}

contract PresalePool {

  // SafeMath is a library to ensure that math operations do not have overflow errors
  // https://zeppelin-solidity.readthedocs.io/en/latest/safemath.html
  using SafeMath for uint;
  
  // The contract has 3 stages:
  // 1 - The initial state. Any addresses can deposit or withdraw eth to the contract.
  // 2 - The owner has closed the contract for further deposits. Contributors can still withdraw their eth from the contract.
  // 3 - The eth is sent from the contract to the receiver. Unused eth can be claimed by contributors immediately. Once tokens are sent to the contract,
  //     the owner enables withdrawals and contributors can withdraw their tokens.
  uint8 public contractStage = 1;
  
  // These variables are set at the time of contract creation
  // the address that creates the contract
  address public owner;
  // the minimum eth amount (in wei) that can be sent by a contributing address
  uint public contributionMin;
  // the maximum eth amount (in wei) that to be held by the contract
  uint public contractMax;
  // the % of tokens kept by the contract owner
  uint public feePct;
  // the address that the pool will be paid out to
  address public receiverAddress;
  
  // These variables are all initially set to 0 and will be set at some point during the contract
  // the amount of eth (in wei) sent to the receiving address (set in stage 3)
  uint public submittedAmount;
  // the % of contributed eth to be refunded to contributing addresses (set in stage 3)
  uint public refundPct;
  // the number of contributors to the pool
  uint public contributorCount;
  // the default token contract to be used for withdrawing tokens in stage 3
  address public activeToken;
  
  // a data structure for holding the contribution amount, cap, eth refund status, and token withdrawal status for each contributing address
  struct Contributor {
    bool refundedEth;
    uint balance;
    mapping (address => uint) tokensClaimed;
  }
  // a mapping that holds the contributor struct for each contributing address
  mapping (address => Contributor) contributors;
  
  // a data structure for holding information related to token withdrawals.
  struct TokenAllocation {
    ERC20 token;
    uint pct;
    uint claimRound;
    uint claimCount;
  }
  // a mapping that holds the token allocation struct for each token address
  mapping (address => TokenAllocation) distribution;
  
  
  // this modifier is used for functions that can only be accessed by the contract creator
  modifier onlyOwner () {
    require (msg.sender == owner);
    _;
  }
  
  // this modifier is used to prevent re-entrancy exploits during contract > contract interaction
  bool locked;
  modifier noReentrancy() {
    require(!locked);
    locked = true;
    _;
    locked = false;
  }
  
  event ContributorBalanceChanged (address contributor, uint totalBalance);
  event TokensWithdrawn (address receiver, uint amount);
  event EthRefunded (address receiver, uint amount);
  event ReceiverAddressChanged ( address _addr);
  event WithdrawalsOpen (address tokenAddr);
  event ERC223Received (address token, uint value);
   
  // These are internal functions used for calculating fees, eth and token allocations as %
  // returns a value as a % accurate to 20 decimal points
  function _toPct (uint numerator, uint denominator ) internal pure returns (uint) {
    return numerator.mul(10 ** 20) / denominator;
  }
  
  // returns % of any number, where % given was generated with toPct
  function _applyPct (uint numerator, uint pct) internal pure returns (uint) {
    return numerator.mul(pct) / (10 ** 20);
  }
  
  // This function is called at the time of contract creation and sets the initial variables.
  function PresalePool(address receiver, uint individualMin, uint poolMax, uint fee) public {
    require (fee < 100);
    require (100000000000000000 <= individualMin);
    require (individualMin <= poolMax);
    require (receiver != 0x00);
    owner = msg.sender;
    receiverAddress = receiver;
    contributionMin = individualMin;
    contractMax = poolMax;
    feePct = _toPct(fee,100);
  }
  
  // This function is called whenever eth is sent into the contract.
  // The amount sent is added to the balance in the Contributor struct associated with the sending address.
  function () payable public {
    require (contractStage == 1);
    require (this.balance <= contractMax);
    var c = contributors[msg.sender];
    uint newBalance = c.balance.add(msg.value);
    require (newBalance >= contributionMin);
    if (contributors[msg.sender].balance == 0) {
      contributorCount = contributorCount.add(1);
    }
    contributors[msg.sender].balance = newBalance;
    ContributorBalanceChanged(msg.sender, newBalance);
  }
    
  // This function is called to withdraw eth or tokens from the contract.
  // It can only be called by addresses that have a balance greater than 0.
  // If called during contract stages one or two, the full eth balance deposited into the contract will be returned and the contributor's balance will be reset to 0.
  // If called during stage three, the contributor's unused eth will be returned, as well as any available tokens.
  // The token address may be provided optionally to withdraw tokens that are not currently the default token (airdrops).
  function withdraw (address tokenAddr) public {
    var c = contributors[msg.sender];
    require (c.balance > 0);
    if (contractStage < 3) {
      uint amountToTransfer = c.balance;
      c.balance = 0;
      msg.sender.transfer(amountToTransfer);
      contributorCount = contributorCount.sub(1);
      ContributorBalanceChanged(msg.sender, 0);
    } else {
      _withdraw(msg.sender,tokenAddr);
    }  
  }
  
  // This function allows the contract owner to force a withdrawal to any contributor.
  // It is useful if a new round of tokens can be distributed but some contributors have
  // not yet withdrawn their previous allocation.
  function withdrawFor (address contributor, address tokenAddr) public onlyOwner {
    require (contractStage == 3);
    require (contributors[contributor].balance > 0);
    _withdraw(contributor,tokenAddr);
  }
  
  // This internal function handles withdrawals during stage three.
  // The associated events will fire to notify when a refund or token allocation is claimed.
  function _withdraw (address receiver, address tokenAddr) internal {
    assert (contractStage == 3);
    var c = contributors[receiver];
    if (tokenAddr == 0x00) {
      tokenAddr = activeToken;
    }
    var d = distribution[tokenAddr];
    require ( (refundPct > 0 && !c.refundedEth) || d.claimRound > c.tokensClaimed[tokenAddr] );
    if (refundPct > 0 && !c.refundedEth) {
      uint ethAmount = _applyPct(c.balance,refundPct);
      c.refundedEth = true;
      if (ethAmount == 0) return;
      if (ethAmount+10 > c.balance) {
        ethAmount = c.balance-10;
      }
      c.balance = c.balance.sub(ethAmount+10);
      receiver.transfer(ethAmount);
      EthRefunded(receiver,ethAmount);
    }
    if (d.claimRound > c.tokensClaimed[tokenAddr]) {
      uint amount = _applyPct(c.balance,d.pct);
      c.tokensClaimed[tokenAddr] = d.claimRound;
      d.claimCount = d.claimCount.add(1);
      if (amount > 0) {
        require (d.token.transfer(receiver,amount));
      }
      TokensWithdrawn(receiver,amount);
    }
  }
  
  // This function can be called during stages one or two to modify the maximum balance of the contract.
  // It can only be called by the owner. The amount cannot be set to lower than the current balance of the contract.
  function modifyMaxContractBalance (uint amount) public onlyOwner {
    require (contractStage < 3);
    require (amount >= contributionMin);
    require (amount >= this.balance);
    contractMax = amount;
  }
  
  // This callable function returns the total pool cap, current balance and remaining balance to be filled.
  function checkPoolBalance () view public returns (uint poolCap, uint balance, uint remaining) {
    return (contractMax,this.balance,contractMax.sub(this.balance));
  }
  
  // This callable function returns the balance, contribution cap, and remaining available balance of any contributor.
  function checkContributorBalance (address addr) view public returns (uint balance) {
    return contributors[addr].balance;
  }
  
  // This callable function returns the token balance that a contributor can currently claim.
  function checkAvailableTokens (address addr, address tokenAddr) view public returns (uint amount) {
    var c = contributors[addr];
    var d = distribution[tokenAddr];
    if (d.claimRound == c.tokensClaimed[tokenAddr]) return 0;
    return _applyPct(c.balance,d.pct);
  }
  
  // This function closes further contributions to the contract, advancing it to stage two.
  // It can only be called by the owner.  After this call has been made, contributing addresses
  // can still remove their eth from the contract but cannot deposit any more.
  function closeContributions () public onlyOwner {
    require (contractStage == 1);
    contractStage = 2;
  }
  
  // This function reopens the contract to further deposits, returning it to stage one.
  // It can only be called by the owner during stage two.
  function reopenContributions () public onlyOwner {
    require (contractStage == 2);
    contractStage = 1;
  }
  
  // This function sends the pooled eth to the receiving address, calculates the % of unused eth to be returned,
  // and advances the contract to stage three. It can only be called by the contract owner during stages one or two.
  // The amount to send (given in wei) must be specified during the call. As this function can only be executed once,
  // it is VERY IMPORTANT not to get the amount wrong.
  function submitPool (uint amountInWei) public onlyOwner noReentrancy {
    require (contractStage < 3);
    require (contributionMin <= amountInWei && amountInWei <= this.balance);
    uint b = this.balance;
    require (receiverAddress.call.value(amountInWei).gas(msg.gas.sub(5000))());
    submittedAmount = b.sub(this.balance);
    refundPct = _toPct(this.balance,b);
    contractStage = 3;
  }
  
  // This function opens the contract up for token withdrawals.
  // It can only be called by the owner during stage 3.  The owner specifies the address of an ERC20 token
  // contract that this contract has a balance in, and optionally a bool to prevent this token from being
  // the default withdrawal (in the event of an airdrop, for example).
  // The function can only be called if there is not currently a token distribution 
  function enableTokenWithdrawals (address tokenAddr, bool notDefault) public onlyOwner noReentrancy {
    require (contractStage == 3);
    if (notDefault) {
      require (activeToken != 0x00);
    } else {
      activeToken = tokenAddr;
    }
    var d = distribution[tokenAddr];
    require (d.claimRound == 0 || d.claimCount == contributorCount);
    d.token = ERC20(tokenAddr);
    uint amount = d.token.balanceOf(this);
    require (amount > 0);
    if (feePct > 0) {
      require (d.token.transfer(owner,_applyPct(amount,feePct)));
    }
    d.pct = _toPct(d.token.balanceOf(this),submittedAmount);
    d.claimCount = 0;
    d.claimRound = d.claimRound.add(1);
  }
  
  // This is a standard function required for ERC223 compatibility.
  function tokenFallback (address from, uint value, bytes data) public {
    ERC223Received (from, value);
  }
  
}