pragma solidity ^0.4.15;

library SafeMathLib {

  function times(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function minus(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function plus(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a);
    return c;
  }

  function divide(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

}

//basic ownership contract
contract Owned {
    address public owner;

    //ensures only owner can call functions
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    //constructor makes sets owner to contract deployer
    function Owned() public { owner = msg.sender;}

    //update owner
    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
        NewOwner(msg.sender, _newOwner);
    }

    event NewOwner(address indexed oldOwner, address indexed newOwner);
}

/**
 * Collect funds from presale investors to be manually send to the crowdsale smart contract later.
 *
 * - Collect funds from pre-sale investors
 * - Send funds to an specified address when the pre-sale ends
 * 
 */ 
contract DadaPresaleFundCollector is Owned {

  using SafeMathLib for uint;

  address public presaleAddressAmountHolder = 0xF636c93F98588b7F1624C8EC4087702E5BE876b6;

  /** How much they have invested */
  mapping(address => uint) public balances;

  /** What is the minimum buy in */
  uint constant maximumIndividualCap = 500 ether;
  // Limit in Ether for this contract to allow investment
  uint constant etherCap = 3000 ether;

  /** Have we begun to move funds */
  bool public moving;

  // turned off while doing initial configuration of the whitelist
  bool public isExecutionAllowed;

  // turned on when the refund function is allowed to be isExecutionAllowed
  bool public isRefundAllowed;
  
  // Used to handle if the cap was reached due to investment received 
  // in either Bitcoin or USD
  bool public isCapReached;

  bool public isFinalized;

  mapping (address => bool) public whitelist;

  event Invested(address investor, uint value);
  event Refunded(address investor, uint value);
  event WhitelistUpdated(address whitelistedAddress, bool isWhitelisted);
  event EmptiedToWallet(address wallet);

  /**
   * Create presale contract where lock up period is given days
   */
  function DadaPresaleFundCollector() public {

  }

  /**
  * Whitelist handler function 
  **/
  function updateWhitelist(address whitelistedAddress, bool isWhitelisted) public onlyOwner {
    whitelist[whitelistedAddress] = isWhitelisted;
    WhitelistUpdated(whitelistedAddress, isWhitelisted);
  }

  /**
   * Participate in the presale.
   */
  function invest() public payable {
    // execution shoulf be turned ON
    require(isExecutionAllowed);
    // the cap shouldn't be reached yet
    require(!isCapReached);
    // the final balance of the contract should not be greater than
    // the etherCap
    uint currentBalance = this.balance;
    require(currentBalance <= etherCap);

    // Cannot invest anymore through crowdsale when moving has begun
    require(!moving);
    address investor = msg.sender;
    // the investor is whitlisted
    require(whitelist[investor]);
    
    // the total balance of the user shouldn't be greater than the maximumIndividualCap
    require((balances[investor].plus(msg.value)) <= maximumIndividualCap);

    require(msg.value <= maximumIndividualCap);
    balances[investor] = balances[investor].plus(msg.value);
    // if the cap is reached then turn ON the flag
    if (currentBalance == etherCap){
      isCapReached = true;
    }
    Invested(investor, msg.value);
  }

  /**
   * Allow refund if isRefundAllowed is ON.
   */
  function refund() public {
    require(isRefundAllowed);
    address investor = msg.sender;
    require(this.balance > 0);
    require(balances[investor] > 0);
    // We have started to move funds
    moving = true;
    uint amount = balances[investor];
    balances[investor] = 0;
    investor.transfer(amount);
    Refunded(investor, amount);
  }

  // utility functions
  function emptyToWallet() public onlyOwner {
    require(!isFinalized);
    isFinalized = true;
    moving = true;
    presaleAddressAmountHolder.transfer(this.balance);
    EmptiedToWallet(presaleAddressAmountHolder); 
  }  

  function flipExecutionSwitchTo(bool state) public onlyOwner{
    isExecutionAllowed = state;
  }

  function flipCapSwitchTo(bool state) public onlyOwner{
    isCapReached = state;
  }

  function flipRefundSwitchTo(bool state) public onlyOwner{
    isRefundAllowed = state;
  }

  function flipFinalizedSwitchTo(bool state) public onlyOwner{
    isFinalized = state;
  }

  function flipMovingSwitchTo(bool state) public onlyOwner{
    moving = state;
  }  

  /** Explicitly call function from your wallet. */
  function() public payable {
    revert();
  }
}