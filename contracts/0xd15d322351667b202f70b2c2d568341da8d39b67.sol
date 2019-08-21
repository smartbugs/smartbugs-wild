pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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

  function add(uint256 a, uint256 b) internal pure returns (uint256) {  //was constant
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/************************************************************************************************
 * 
 *************************************************************************************************/

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC20 { 
    function transfer(address receiver, uint amount) public ;
    function transferFrom(address sender, address receiver, uint amount) public returns(bool success); // do token.approve on the ICO contract
    function balanceOf(address _owner) constant public returns (uint256 balance);
}

/************************************************************************************************
 * 
 *************************************************************************************************/

contract ASTRICOSale is Ownable {
  ERC20 public token;  // using the ASTRCoin token - will set an address

  // start and end of the sale - 4 weeks
  uint256 public startTime;
  uint256 public endTime;

  // where funds are collected 

  address public wallet;  // beneficiary
  address public ownerAddress;  // deploy owner

  // amount of raised money in wei
  uint256 public weiRaised;
  
  uint8 internal decimals             = 4; // 4 decimal places should be enough in general
  uint256 internal decimalsConversion = 10 ** uint256(decimals);
  uint256 internal ALLOC_CROWDSALE    = 90000000 * decimalsConversion; // (10 ** uint256(decimals)); // 90 mill in ICO

  // 90MIL      90000000
  // 10MIL      10000000
  // 90MIL 4DCP 900000000000

  uint internal BASIC_RATE        = 631 * decimalsConversion; // based on the price of ether at 755 USD
  uint public   PRICE_VARIABLE    = 0 * decimalsConversion;

  //TIME LIMITS

  uint256 public astrSold            = 0;

  bool public halted;
  bool public crowdsaleClosed;

  // simple event to track purchases
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  modifier isNotHalted() {     require(!halted);    _;  }
  modifier afterDeadline() { if (now >= endTime) _; }


  /**
    * Constructor for ASTRICOSale
    *
    * 1513908673
    *  Friday, December 22, 2017 10:11:13 AM GMT+08:00
    *
    * 1517414400
    * Thursday, February 1, 2018 12:00:00 AM GMT+08:00
    *
    * 90000000000
  */
  // function ASTRCoinCrowdSale(address _token, uint256 _startTime, address _ethWallet) public  {
    function ASTRICOSale() public  {

    // require(_startTime >= now);
    // require(_ethWallet != 0x0);   

    crowdsaleClosed = false;
    halted          = false;
    startTime       = 1513908673; // Friday, December 22, 2017 10:11:13 AM GMT+08:00
    endTime         = 1517414400; // Thursday, February 1, 2018 12:00:00 AM GMT+08:00
    wallet          = ERC20(0x3baDA155408AB1C9898FDF28e545b51f2f9a65CC); // This wallet needs to give permission for the ICO to transfer Tokens 
    ownerAddress    = ERC20(0x3EFAe2e152F62F5cc12cc0794b816d22d416a721);  // This is bad in theory but does fix the 2300 gas problem 
    token           = ERC20(0x80E7a4d750aDe616Da896C49049B7EdE9e04C191); // Ropsten we have pregenerated thiss
  }

        // fallback function can be used to buy tokens
  function () public payable {
    require(msg.sender                 != 0x0);
    require(validPurchase());
    require(!halted); // useful to test if we have paused it
    uint256 weiAmount                  = msg.value; // money sent in wei
    uint256 tokens                     = SafeMath.div(SafeMath.mul(weiAmount, getCurrentRate()), 1 ether);
    require(ALLOC_CROWDSALE - astrSold >= tokens);
    weiRaised                          += weiAmount;
    astrSold                           += tokens;
    token.transferFrom(ownerAddress, msg.sender, tokens);
    wallet.transfer(msg.value); // transfer straight away wallet
  }


  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = (msg.value != 0);
    bool astrAvailable = (ALLOC_CROWDSALE - astrSold) > 0; 
    return withinPeriod && nonZeroPurchase && astrAvailable && ! crowdsaleClosed;
  }

  function getCurrentRate() internal constant returns (uint256) {  
    if( PRICE_VARIABLE > 0 ) {
      return PRICE_VARIABLE; // we can manually set prices if we want
    }

    return BASIC_RATE;
  }


  // this closes it when we want to close - rather than waiting 
  function setNewRate(uint256 _coinsPerEther) onlyOwner public {
    if( _coinsPerEther > 0 ) {
        PRICE_VARIABLE = _coinsPerEther * decimalsConversion;
    }
  }
    // this closes it when we want to close - rather than waiting 
  function setFixedRate() onlyOwner public {
     PRICE_VARIABLE = 0 * decimalsConversion;
  }


  // this closes it when we want to close - rather than waiting - this is bad
  function closeSaleAnyway() onlyOwner public {
      // wallet.transfer(weiRaised);
      crowdsaleClosed = true;
    }

    // this closes it when we want to close - rather than waiting 
  function safeCloseSale()  onlyOwner afterDeadline public {
    // wallet.transfer(weiRaised);
    crowdsaleClosed = true;
  }

  function pause() onlyOwner public {
    halted = true;
  }


  function unpause() onlyOwner public {
    halted = false;
  }
}