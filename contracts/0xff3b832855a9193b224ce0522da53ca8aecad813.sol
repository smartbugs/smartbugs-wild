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

contract ASTRICOPreSale is Ownable {
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
  uint256 internal ALLOC_CROWDSALE    = 10000000 * decimalsConversion; // (10 ** uint256(decimals)); // 10 mill in ICO
  // we have already sold some
  // 
  // 90MIL      90000000
  // 10MIL      10000000
  // 90MIL 4DCP 900000000000
  // 10MIL 4dCP 100000000000

  uint internal BASIC_RATE        = 75 * decimalsConversion; // based on the price of ether at 330 USD
  uint internal PRICE_STAGE_PS    = 431 * decimalsConversion; 
  uint internal STAGE_PS_TIME_END = 60 minutes; // THIS IS TO BE SET PROPERLY
  uint internal PRICE_VARIABLE    = 0 * decimalsConversion;
  uint256 public astrSold         = 0;

  bool public halted;
  bool public crowdsaleClosed;

  // simple event to track purchases
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  modifier isNotHalted() {     require(!halted);    _;  }
  modifier afterDeadline() { if (now >= endTime) _; }

  /**
    * Constructor for ASTRICOPreSale
    * param _token  ASTRCoin   0x567354a9F8367ff25F6967C947239fe75649e64e
    * param _startTime start time for public sale
    * param _ethWallet all incoming eth transfered here. Use multisig wallet 0xeA173bf22d7fF1ad9695652432b8759A331d668b
    *
    *     *

0x80E7a4d750aDe616Da896C49049B7EdE9e04C191


1510911600
2017-11-17 17:40:00

1511758800
2017-11-27 13:00:00

    *
    * 90000000000
  */
    function ASTRICOPreSale() public  {

    crowdsaleClosed = false;
    halted          = false;
    startTime       = 1510911600; //1510563716; //_startTime;  make it +20 minutes for it to work
    endTime         = 1511758800; //_startTime + STAGE_FOUR_TIME_END; set start and end the same :/
    wallet          = ERC20(0x3baDA155408AB1C9898FDF28e545b51f2f9a65CC); // This wallet needs to give permission for the ICO to transfer Tokens  Ropsten 0xeA173bf22d7fF1ad9695652432b8759A331d668b
    ownerAddress    = ERC20(0x3EFAe2e152F62F5cc12cc0794b816d22d416a721);  // This is bad in theory but does fix the 2300 gas problem Ropsten 0xeA173bf22d7fF1ad9695652432b8759A331d668b
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
    wallet.transfer(msg.value); // transfer straight away PRESALE wallet
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
    return PRICE_STAGE_PS;
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


  // this closes it when we want to close - rather than waiting - this is BAD
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