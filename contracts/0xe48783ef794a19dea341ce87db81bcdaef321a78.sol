pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0 uint256 c = a / b;
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 */
contract token { function transfer(address receiver, uint amount){  } }
contract AfdltIEO {
  using SafeMath for uint256;

  
  // address where funds are collected
  address public wallet;
  // token address
  address public AFDLT;

  uint256 public price = 110000000;

  token tokenReward;

  // mapping (address => uint) public contributions;
  

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


  constructor() public{
    //You will change this to your wallet where you need the ETH 
    wallet = 0xcfbD73A1404A2CBf956e9E506ff5006601BCd2A4;

    //Here will come the checksum address we got
    AFDLT = 0xd8a8843b0a5aba6b030e92b3f4d669fad8a5be50;


    tokenReward = token(AFDLT);
  }

  bool public started = true;

  function startSale() public{
    if (msg.sender != wallet) revert();
    started = true;
  }

  function stopSale() public{
    if(msg.sender != wallet) revert();
    started = false;
  }

  function setPrice(uint256 _price) public{
    if(msg.sender != wallet) revert();
    price = _price;
  }
  function changeWallet(address _wallet) public{
  	if(msg.sender != wallet) revert();
  	wallet = _wallet;
  }

  function changeTokenReward(address _token) public{
    if(msg.sender!=wallet) revert();
    tokenReward = token(_token);
    AFDLT = _token;
  }

  // fallback function can be used to buy tokens
  function () payable public{
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) payable public{
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;


    // calculate token amount to be sent
    uint256 tokens = ((weiAmount) * price).div(10**14);
     if (tokens >= 2000000000000*10**4) {
        tokens = tokens.add(tokens.mul(20)/100);
        
      }else if (tokens >= 1500000000000*10**4) {
        tokens = tokens.add(tokens.mul(15)/100);
        
      }else if (tokens >= 1000000000000*10**4) {
        tokens = tokens.add(tokens.mul(12)/100);
        
      }else if (tokens >= 500000000000*10**4) {
        tokens = tokens.add(tokens.mul(10)/100);
        
      }else if (tokens >= 100000000000*10**4) {
        tokens = tokens.add(tokens.mul(8)/100);
      }else if (tokens >= 10000000000*10**4) {
        tokens = tokens.add(tokens.mul(5)/100);
      }else if (tokens >= 1000000000*10**4) {
        tokens = tokens.add(tokens.mul(3)/100);
      }if (tokens >= 500000000*10**4) {
        tokens = tokens.add(tokens.mul(2)/100);
      }
      else {
        tokens = tokens;
      }
    
    
   
    weiRaised = weiRaised.add(weiAmount);
    
   
    tokenReward.transfer(beneficiary, tokens);
    emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    // wallet.transfer(msg.value);
    if (!wallet.send(msg.value)) {
      revert();
    }
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = started;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  function withdrawTokens(uint256 _amount) public{
    if(msg.sender!=wallet) revert();
    tokenReward.transfer(wallet,_amount);
  }
}