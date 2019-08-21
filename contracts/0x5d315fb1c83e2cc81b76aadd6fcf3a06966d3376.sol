pragma solidity ^0.4.19;

// Wolf Crypto pooling contract for Refereum
// written by @iamdefinitelyahuman

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


contract WhiteList {
   function checkMemberLevel (address addr) view public returns (uint) {}
}


contract PresalePool {

  // SafeMath is a library to ensure that math operations do not have overflow errors
  // https://zeppelin-solidity.readthedocs.io/en/latest/safemath.html
  using SafeMath for uint;
  
  // The contract has 3 stages:
  // 1 - The initial state. The owner is able to add addresses to the whitelist, and any whitelisted addresses can deposit or withdraw eth to the contract.
  // 2 - The owner has closed the contract for further deposits. Whitelisted addresses can still withdraw eth from the contract.
  // 3 - The eth is sent from the contract to the receiver. Unused eth can be claimed by contributors immediately. Once tokens are sent to the contract,
  //     the owner enables withdrawals and contributors can withdraw their tokens.
  uint8 public contractStage = 1;
  
  // These variables are set at the time of contract creation
  // the address that creates the contract
  address public owner;
  // the minimum eth amount (in wei) that can be sent by a whitelisted address
  uint public contributionMin;
  // the maximum eth amount (in wei) that can be sent by a whitelisted address
  uint[] public contributionCaps;
  // the % of tokens kept by the contract owner
  uint public feePct;
  // the address that the pool will be paid out to
  address public receiverAddress;
  // the maximum gas price allowed for deposits in stage 1
  uint constant public maxGasPrice = 50000000000;
  // the whitelisting contract
  WhiteList public whitelistContract;
  
  // These variables are all initially set to 0 and will be set at some point during the contract
  // the amount of eth (in wei) present in the contract when it was submitted
  uint public finalBalance;
  // an array containing eth amounts to be refunded in stage 3
  uint[] public ethRefundAmount;
  // the default token contract to be used for withdrawing tokens in stage 3
  address public activeToken;
  
  // a data structure for holding the contribution amount, cap, eth refund status, and token withdrawal status for each whitelisted address
  struct Contributor {
    bool authorized;
    uint ethRefund;
    uint balance;
    uint cap;
    mapping (address => uint) tokensClaimed;
  }
  // a mapping that holds the contributor struct for each whitelisted address
  mapping (address => Contributor) whitelist;
  
  // a data structure for holding information related to token withdrawals.
  struct TokenAllocation {
    ERC20 token;
    uint[] pct;
    uint balanceRemaining;
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
  
  // Events triggered throughout contract execution
  // These can be watched via geth filters to keep up-to-date with the contract
  event ContributorBalanceChanged (address contributor, uint totalBalance);
  event TokensWithdrawn (address receiver, uint amount);
  event EthRefunded (address receiver, uint amount);
  event WithdrawalsOpen (address tokenAddr);
  event ERC223Received (address token, uint value);
  event EthRefundReceived (address sender, uint amount);
   
  // These are internal functions used for calculating fees, eth and token allocations as %
  // returns a value as a % accurate to 20 decimal points
  function _toPct (uint numerator, uint denominator ) internal pure returns (uint) {
    return numerator.mul(10 ** 20) / denominator;
  }
  
  // returns % of any number, where % given was generated with toPct
  function _applyPct (uint numerator, uint pct) internal pure returns (uint) {
    return numerator.mul(pct) / (10 ** 20);
  }
  
  // This function is called at the time of contract creation,
  // it sets the initial variables and whitelists the contract owner.
  function PresalePool(address receiverAddr, address whitelistAddr, uint individualMin, uint[] capAmounts, uint fee) public {
    require (receiverAddr != 0x00);
    require (fee < 100);
    require (100000000000000000 <= individualMin);
    require (capAmounts.length>1 && capAmounts.length<256);
    for (uint8 i=1; i<capAmounts.length; i++) {
      require (capAmounts[i] <= capAmounts[0]);
    }
    owner = msg.sender;
    receiverAddress = receiverAddr;
    contributionMin = individualMin;
    contributionCaps = capAmounts;
    feePct = _toPct(fee,100);
    whitelistContract = WhiteList(whitelistAddr);
    whitelist[msg.sender].authorized = true;
  }
  
  // This function is called whenever eth is sent into the contract.
  // The send will fail unless the contract is in stage one and the sender has been whitelisted.
  // The amount sent is added to the balance in the Contributor struct associated with the sending address.
  function () payable public {
    if (contractStage == 1) {
      _ethDeposit();
    } else if (contractStage == 3) {
      _ethRefund();
    } else revert();
  }
  
  // Internal function for handling eth deposits during contract stage one.
  function _ethDeposit () internal {
    assert (contractStage == 1);
    require (tx.gasprice <= maxGasPrice);
    require (this.balance <= contributionCaps[0]);
    var c = whitelist[msg.sender];
    uint newBalance = c.balance.add(msg.value);
    require (newBalance >= contributionMin);
    require (newBalance <= _checkCap(msg.sender));
    c.balance = newBalance;
    ContributorBalanceChanged(msg.sender, newBalance);
  }
  
  // Internal function for handling eth refunds during stage three.
  function _ethRefund () internal {
    assert (contractStage == 3);
    require (msg.sender == owner || msg.sender == receiverAddress);
    require (msg.value >= contributionMin);
    ethRefundAmount.push(msg.value);
    EthRefundReceived(msg.sender, msg.value);
  }
  
  // This function is called to withdraw eth or tokens from the contract.
  // It can only be called by addresses that are whitelisted and show a balance greater than 0.
  // If called during contract stages one or two, the full eth balance deposited into the contract will be returned and the contributor's balance will be reset to 0.
  // If called during stage three, the contributor's unused eth will be returned, as well as any available tokens.
  // The token address may be provided optionally to withdraw tokens that are not currently the default token (airdrops).
  function withdraw (address tokenAddr) public {
    var c = whitelist[msg.sender];
    require (c.balance > 0);
    if (contractStage < 3) {
      uint amountToTransfer = c.balance;
      c.balance = 0;
      msg.sender.transfer(amountToTransfer);
      ContributorBalanceChanged(msg.sender, 0);
    } else {
      _withdraw(msg.sender,tokenAddr);
    }  
  }
  
  // This function allows the contract owner to force a withdrawal to any contributor.
  function withdrawFor (address contributor, address tokenAddr) public onlyOwner {
    require (contractStage == 3);
    require (whitelist[contributor].balance > 0);
    _withdraw(contributor,tokenAddr);
  }
  
  // This internal function handles withdrawals during stage three.
  // The associated events will fire to notify when a refund or token allocation is claimed.
  function _withdraw (address receiver, address tokenAddr) internal {
    assert (contractStage == 3);
    var c = whitelist[receiver];
    if (tokenAddr == 0x00) {
      tokenAddr = activeToken;
    }
    var d = distribution[tokenAddr];
    require ( (ethRefundAmount.length > c.ethRefund) || d.pct.length > c.tokensClaimed[tokenAddr] );
    if (ethRefundAmount.length > c.ethRefund) {
      uint pct = _toPct(c.balance,finalBalance);
      uint ethAmount = 0;
      for (uint i=c.ethRefund; i<ethRefundAmount.length; i++) {
        ethAmount = ethAmount.add(_applyPct(ethRefundAmount[i],pct));
      }
      c.ethRefund = ethRefundAmount.length;
      if (ethAmount > 0) {
        receiver.transfer(ethAmount);
        EthRefunded(receiver,ethAmount);
      }
    }
    if (d.pct.length > c.tokensClaimed[tokenAddr]) {
      uint tokenAmount = 0;
      for (i=c.tokensClaimed[tokenAddr]; i<d.pct.length; i++) {
        tokenAmount = tokenAmount.add(_applyPct(c.balance,d.pct[i]));
      }
      c.tokensClaimed[tokenAddr] = d.pct.length;
      if (tokenAmount > 0) {
        require(d.token.transfer(receiver,tokenAmount));
        d.balanceRemaining = d.balanceRemaining.sub(tokenAmount);
        TokensWithdrawn(receiver,tokenAmount);
      }  
    }
    
  }
  
  // This function can only be executed by the owner, it adds an address to the whitelist.
  // To execute, the contract must be in stage 1, the address cannot already be whitelisted, and the address cannot be a contract itself.
  // Blocking contracts from being whitelisted prevents attacks from unexpected contract to contract interaction - very important!
  function authorize (address addr, uint cap) public onlyOwner {
    require (contractStage == 1);
    _checkWhitelistContract(addr);
    require (!whitelist[addr].authorized);
    require ((cap > 0 && cap < contributionCaps.length) || (cap >= contributionMin && cap <= contributionCaps[0]) );
    uint size;
    assembly { size := extcodesize(addr) }
    require (size == 0);
    whitelist[addr].cap = cap;
    whitelist[addr].authorized = true;
  }
  
  // This function is used by the owner to authorize many addresses in a single call.
  // Each address will be given the same cap, and the cap must be one of the standard levels.
  function authorizeMany (address[] addr, uint cap) public onlyOwner {
    require (addr.length < 255);
    require (cap > 0 && cap < contributionCaps.length);
    for (uint8 i=0; i<addr.length; i++) {
      authorize(addr[i], cap);
    }
  }
  
  // This function is called by the owner to remove an address from the whitelist.
  // It may only be executed during stages 1 and 2.  Any eth sent by the address is refunded and their personal cap is set to 0.
  // It will throw if the address is still authorised in the whitelist contract.
  function revoke (address addr) public onlyOwner {
    require (contractStage < 3);
    require (whitelist[addr].authorized);
    require (whitelistContract.checkMemberLevel(addr) == 0);
    whitelist[addr].authorized = false;
    if (whitelist[addr].balance > 0) {
      uint amountToTransfer = whitelist[addr].balance;
      whitelist[addr].balance = 0;
      addr.transfer(amountToTransfer);
      ContributorBalanceChanged(addr, 0);
    }
  }
  
  // This function is called by the owner to modify the contribution cap of a whitelisted address.
  // If the current contribution balance exceeds the new cap, the excess balance is refunded.
  function modifyIndividualCap (address addr, uint cap) public onlyOwner {
    require (contractStage < 3);
    require (cap < contributionCaps.length || (cap >= contributionMin && cap <= contributionCaps[0]) );
    _checkWhitelistContract(addr);
    var c = whitelist[addr];
    require (c.authorized);
    uint amount = c.balance;
    c.cap = cap;
    uint capAmount = _checkCap(addr);
    if (amount > capAmount) {
      c.balance = capAmount;
      addr.transfer(amount.sub(capAmount));
      ContributorBalanceChanged(addr, capAmount);
    }
  }
  
  // This function is called by the owner to modify the cap for a contribution level.
  // The cap can only be increased, not decreased, and cannot exceed the contract limit.
  function modifyLevelCap (uint level, uint cap) public onlyOwner {
    require (contractStage < 3);
    require (level > 0 && level < contributionCaps.length);
    require (contributionCaps[level] < cap && contributionCaps[0] >= cap);
    contributionCaps[level] = cap;
  }
  
  // This function changes every level cap at once.
  function modifyLevelCaps (uint[] cap) public onlyOwner {
    require (contractStage < 3);
    require (cap.length == contributionCaps.length-1);
    for (uint8 i = 1; i<contributionCaps.length; i++) {
      modifyLevelCap(i,cap[i-1]);
    }
  }
  
  
  // This function can be called during stages one or two to modify the maximum balance of the contract.
  // It can only be called by the owner. The amount cannot be set to lower than the current balance of the contract.
  function modifyMaxContractBalance (uint amount) public onlyOwner {
    require (contractStage < 3);
    require (amount >= contributionMin);
    require (amount >= this.balance);
    contributionCaps[0] = amount;
    for (uint8 i=1; i<contributionCaps.length; i++) {
      if (contributionCaps[i]>amount) contributionCaps[i]=amount;
    }
  }
  
  // This internal function returns the cap amount of a whitelisted address.
  function _checkCap (address addr) internal returns (uint) {
    _checkWhitelistContract(addr);
    var c = whitelist[addr];
    if (!c.authorized) return 0;
    if (c.cap<contributionCaps.length) return contributionCaps[c.cap];
    return c.cap; 
  }
  
  // This internal function checks if an address is whitelisted in the whitelist contract.
  function _checkWhitelistContract (address addr) internal {
    var c = whitelist[addr];
    if (!c.authorized) {
      var level = whitelistContract.checkMemberLevel(addr);
      if (level == 0 || level >= contributionCaps.length) return;
      c.cap = level;
      c.authorized = true;
    }
  }
  
  // This callable function returns the total pool cap, current balance and remaining balance to be filled.
  function checkPoolBalance () view public returns (uint poolCap, uint balance, uint remaining) {
    if (contractStage == 1) {
      remaining = contributionCaps[0].sub(this.balance);
    } else {
      remaining = 0;
    }
    return (contributionCaps[0],this.balance,remaining);
  }
  
  // This callable function returns the balance, contribution cap, and remaining available balance of any contributor.
  function checkContributorBalance (address addr) view public returns (uint balance, uint cap, uint remaining) {
    var c = whitelist[addr];
    if (!c.authorized) {
      cap = whitelistContract.checkMemberLevel(addr);
      if (cap == 0) return (0,0,0);
    } else {
      cap = c.cap;
    }
    balance = c.balance;
    if (contractStage == 1) {
      if (cap<contributionCaps.length) {
        cap = contributionCaps[cap];
      }
      remaining = cap.sub(balance);
      if (contributionCaps[0].sub(this.balance) < remaining) remaining = contributionCaps[0].sub(this.balance);
    } else {
      remaining = 0;
    }
    return (balance, cap, remaining);
  }
  
  // This callable function returns the token balance that a contributor can currently claim.
  function checkAvailableTokens (address addr, address tokenAddr) view public returns (uint tokenAmount) {
    var c = whitelist[addr];
    var d = distribution[tokenAddr];
    for (uint i=c.tokensClaimed[tokenAddr]; i<d.pct.length; i++) {
      tokenAmount = tokenAmount.add(_applyPct(c.balance,d.pct[i]));
    }
    return tokenAmount;
  }
  
  // This function closes further contributions to the contract, advancing it to stage two.
  // It can only be called by the owner.  After this call has been made, whitelisted addresses
  // can still remove their eth from the contract but cannot contribute any more.
  function closeContributions () public onlyOwner {
    require (contractStage == 1);
    contractStage = 2;
  }
  
  // This function reopens the contract to contributions and further whitelisting, returning it to stage one.
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
    finalBalance = this.balance;
    require (receiverAddress.call.value(amountInWei).gas(msg.gas.sub(5000))());
    ethRefundAmount.push(this.balance);
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
    if (d.pct.length==0) d.token = ERC20(tokenAddr);
    uint amount = d.token.balanceOf(this).sub(d.balanceRemaining);
    require (amount > 0);
    if (feePct > 0) {
      require (d.token.transfer(owner,_applyPct(amount,feePct)));
    }
    amount = d.token.balanceOf(this).sub(d.balanceRemaining);
    d.balanceRemaining = d.token.balanceOf(this);
    d.pct.push(_toPct(amount,finalBalance));
  }
  
  // This is a standard function required for ERC223 compatibility.
  function tokenFallback (address from, uint value, bytes data) public {
    ERC223Received (from, value);
  }
  
}