pragma solidity ^0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract SMEBankingPlatformToken {
  function transfer(address to, uint256 value) public returns (bool);
  function balanceOf(address who) public constant returns (uint256);
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


contract Sale is Ownable {
  using SafeMath for uint256;

  SMEBankingPlatformToken public token;

  mapping(address=>bool) public participated;

   // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei (for < 1ETH purchases)
  uint256 public rate = 28000;

  // how many token units a buyer gets per wei (for < 5ETH purchases)
  uint256 public rate1 = 32000;

  // how many token units a buyer gets per wei (for < 10ETH purchases)
  uint256 public rate5 = 36000;

  // how many token units a buyer gets per wei (for >= 10ETH purchases)
  uint256 public rate10 = 40000;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function Sale(address _tokenAddress, address _wallet) public {
    token = SMEBankingPlatformToken(_tokenAddress);
    wallet = _wallet;
  }

  function () external payable {
    buyTokens(msg.sender);
  }

  function setRate(uint256 _rate) public onlyOwner {
    require(_rate > 0);
    rate = _rate;
  }

  function setRate1(uint256 _rate) public onlyOwner {
    require(_rate > 0);
    rate1 = _rate;
  }

  function setRate5(uint256 _rate) public onlyOwner {
    require(_rate > 0);
    rate5 = _rate;
  }

  function setRate10(uint256 _rate) public onlyOwner {
    require(_rate > 0);
    rate10 = _rate;
  }

  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(msg.value != 0);

    uint256 weiAmount = msg.value;

    uint256 tokens = getTokenAmount(beneficiary, weiAmount);

    weiRaised = weiRaised.add(weiAmount);

    token.transfer(beneficiary, tokens);

    TokenPurchase(
      msg.sender,
      beneficiary,
      weiAmount,
      tokens
    );

    participated[beneficiary] = true;

    forwardFunds();
  }

  function getTokenAmount(address beneficiary, uint256 weiAmount) internal view returns(uint256) {
    uint256 tokenAmount;

    if (weiAmount >= 10 ether) {
      tokenAmount = weiAmount.mul(rate10);
    } else if (weiAmount >= 5 ether) {
      tokenAmount = weiAmount.mul(rate5);
    } else if (weiAmount >= 1 ether) {
      tokenAmount = weiAmount.mul(rate1);
    } else {
      tokenAmount = weiAmount.mul(rate);
    }

    if (!participated[beneficiary] && weiAmount >= 0.01 ether) {
      tokenAmount = tokenAmount.add(200 * 10 ** 18);
    }

    return tokenAmount;
  }

  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}


contract SMEBankingPlatformSale2 is Sale {
  function SMEBankingPlatformSale2(address _tokenAddress, address _wallet) public
    Sale(_tokenAddress, _wallet)
  {

  }

  function drainRemainingTokens () public onlyOwner {
    token.transfer(owner, token.balanceOf(this));
  }
}