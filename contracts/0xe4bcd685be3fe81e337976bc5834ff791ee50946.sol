pragma solidity ^0.4.23;

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private reentrancyLock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
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


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract PriceUpdaterInterface {
  enum Currency { ETH, BTC, WME, WMZ, WMR, WMX }

  uint public decimalPrecision = 3;

  mapping(uint => uint) public price;
}

contract CrowdsaleInterface {
  uint public rate;
  uint public minimumAmount;

  function externalBuyToken(address _beneficiary, PriceUpdaterInterface.Currency _currency, uint _amount, uint _tokens) external;
}

contract MerchantControllerInterface {
  mapping(uint => uint) public totalInvested;
  mapping(uint => bool) public paymentId;

  function calcPrice(PriceUpdaterInterface.Currency _currency, uint _tokens) public view returns(uint);
  function buyTokens(address _beneficiary, PriceUpdaterInterface.Currency _currency, uint _amount, uint _tokens, uint _paymentId) external;
}

contract MerchantController is MerchantControllerInterface, ReentrancyGuard, Ownable {
  using SafeMath for uint;

  PriceUpdaterInterface public priceUpdater;
  CrowdsaleInterface public crowdsale;

  constructor(PriceUpdaterInterface _priceUpdater, CrowdsaleInterface _crowdsale) public  {
    priceUpdater = _priceUpdater;
    crowdsale = _crowdsale;
  }

  function calcPrice(PriceUpdaterInterface.Currency _currency, uint _tokens) 
      public 
      view 
      returns(uint) 
  {
    uint priceInWei = _tokens.mul(1 ether).div(crowdsale.rate());
    if (_currency == PriceUpdaterInterface.Currency.ETH) {
      return priceInWei;
    }
    uint etherPrice = priceUpdater.price(uint(PriceUpdaterInterface.Currency.ETH));
    uint priceInEur = priceInWei.mul(etherPrice).div(1 ether);

    uint currencyPrice = priceUpdater.price(uint(_currency));
    uint tokensPrice = priceInEur.mul(currencyPrice);
    
    return tokensPrice;
  }

  function buyTokens(
    address _beneficiary,
    PriceUpdaterInterface.Currency _currency,
    uint _amount,
    uint _tokens,
    uint _paymentId)
      external
      onlyOwner
      nonReentrant
  {
    require(_beneficiary != address(0));
    require(_currency != PriceUpdaterInterface.Currency.ETH);
    require(_amount != 0);
    require(_tokens >= crowdsale.minimumAmount());
    require(_paymentId != 0);
    require(!paymentId[_paymentId]);
    paymentId[_paymentId] = true;
    crowdsale.externalBuyToken(_beneficiary, _currency, _amount, _tokens);
  }
}