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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract DragonToken{
  function transferFrom(address _from, address _to, uint256 _value) returns(bool success);
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive. The contract requires a MintableToken that will be
 * minted as contributions arrive, note that the crowdsale contract
 * must be owner of the token in order to be able to mint it.
 */
contract Crowdsale is Ownable{
  using SafeMath for uint256;

  // The token being sold
  DragonToken public token;
  
  // The address of token reserves
  address public tokenReserve;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // token rate in wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   * @param releaseTime tokens unlock time
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount, uint256 releaseTime);
  
  /**
   * event upon endTime updated
   */
  event EndTimeUpdated();
  
  /**
   * Dragon token price updated
   */
  event DragonPriceUpdated();
  
  /**
   * event for token releasing
   * @param holder who is releasing his tokens
   */
  event TokenReleased(address indexed holder, uint256 amount);


  function Crowdsale() public {
  
    owner = 0xF615Ac471E066b5ae4BD211CC5044c7a31E89C4e; // overriding owner
    startTime = now;
    endTime = 1521187200;
    rate = 5000000000000000; // price in wei
    wallet = 0xF615Ac471E066b5ae4BD211CC5044c7a31E89C4e;
    token = DragonToken(0x814F67fA286f7572B041D041b1D99b432c9155Ee);
    tokenReserve = 0xdd870fa1b7c4700f2bd7f44238821c26f7392148;
  }

  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    uint256 lockedFor = assignTokens(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens, lockedFor);

    forwardFunds();
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }

  function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
    uint256 amount = weiAmount.div(rate);
    return amount.mul(100000000); // multiply with decimals
  }

  // send ether to the fund collection wallet
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  function updateEndTime(uint256 newTime) onlyOwner external {
    require(newTime > startTime);
    endTime = newTime;
    EndTimeUpdated();
  }
  
  function updateDragonPrice(uint256 weiAmount) onlyOwner external {
    require(weiAmount > 0);
    rate = weiAmount;
    DragonPriceUpdated();
  }
  
  mapping(address => uint256) balances;
  mapping(address => uint256) releaseTime;
  function assignTokens(address beneficiary, uint256 amount) private returns(uint256 lockedFor){
      lockedFor = now + 45 days;
      balances[beneficiary] = balances[beneficiary].add(amount);
      releaseTime[beneficiary] = lockedFor;
  }
  
  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
  

  function unlockTime(address _owner) public view returns (uint256 time) {
    return releaseTime[_owner];
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function releaseDragonTokens() public {
    require(now >= releaseTime[msg.sender]);
    
    uint256 amount = balances[msg.sender];
    require(amount > 0);
    
    balances[msg.sender] = 0;
    if(!token.transferFrom(tokenReserve,msg.sender,amount)){
        revert();
    }

    TokenReleased(msg.sender,amount);
  }
  
}