pragma solidity ^0.4.11;

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
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded 
 to a wallet
 * as they arrive.
 */
contract token { function transfer(address receiver, uint amount){  } }
contract Crowdsale {
  using SafeMath for uint256;

  // uint256 durationInMinutes;
  // address where funds are collected
  address public wallet;
  // token address
  address public addressOfTokenUsedAsReward1;
  address public addressOfTokenUsedAsReward2;
  address public addressOfTokenUsedAsReward3;
  address public addressOfTokenUsedAsReward4;
  address public addressOfTokenUsedAsReward5;

  uint256 public price = 7500;

  token tokenReward1;
  token tokenReward2;
  token tokenReward3;
  token tokenReward4;
  token tokenReward5;

  // mapping (address => uint) public contributions;
  


  // start and end timestamps where investments are allowed (both inclusive)
  // uint256 public startTime;
  // uint256 public endTime;
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


  function Crowdsale() {
    //You will change this to your wallet where you need the ETH 
    wallet = 0xE37C4541C34e4A8785DaAA9aEb5005DdD29854ac;
    // durationInMinutes = _durationInMinutes;
    //Here will come the checksum address we got
    //aircoin
    addressOfTokenUsedAsReward1 = 0xBD17Dfe402f1Afa41Cda169297F8de48d6Dfb613;
    //diamond
    addressOfTokenUsedAsReward2 = 0x489DF6493C58642e6a4651dDcd4145eaFBAA1018;
    //silver
    addressOfTokenUsedAsReward3 = 0x404a639086eda1B9C8abA3e34a5f8145B4B04ea5;
    //usdgold
    addressOfTokenUsedAsReward4 = 0x00755562Dfc1F409ec05d38254158850E4e8362a;
    //worldcoin
    addressOfTokenUsedAsReward5 = 0xE7AE9dc8F5F572e4f80655C4D0Ffe32ec16fF0E3;


    tokenReward1 = token(addressOfTokenUsedAsReward1);
    tokenReward2 = token(addressOfTokenUsedAsReward2);
    tokenReward3 = token(addressOfTokenUsedAsReward3);
    tokenReward4 = token(addressOfTokenUsedAsReward4);
    tokenReward5 = token(addressOfTokenUsedAsReward5);
  }

  bool public started = true;

  function startSale(){
    if (msg.sender != wallet) throw;
    started = true;
  }

  function stopSale(){
    if(msg.sender != wallet) throw;
    started = false;
  }

  function setPrice(uint256 _price){
    if(msg.sender != wallet) throw;
    price = _price;
  }
  function changeWallet(address _wallet){
  	if(msg.sender != wallet) throw;
  	wallet = _wallet;
  }

  // function changeTokenReward(address _token){
  //   if(msg.sender!=wallet) throw;
  //   tokenReward = token(_token);
  // }

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token `purchase function
  function buyTokens(address beneficiary) payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // if(weiAmount < 10**16) throw;
    // if(weiAmount > 50*10**18) throw;

    // calculate token amount to be sent
    uint256 tokens = (weiAmount/10**10) * price;//weiamount * price 
    // uint256 tokens = (weiAmount/10**(18-decimals)) * price;//weiamount * price 

    // update state
    weiRaised = weiRaised.add(weiAmount);
    
    // if(contributions[msg.sender].add(weiAmount)>10*10**18) throw;
    // contributions[msg.sender] = contributions[msg.sender].add(weiAmount);

    tokenReward1.transfer(beneficiary, tokens);
    tokenReward2.transfer(beneficiary, tokens);
    tokenReward3.transfer(beneficiary, tokens);
    tokenReward4.transfer(beneficiary, tokens);
    tokenReward5.transfer(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    // wallet.transfer(msg.value);
    if (!wallet.send(msg.value)) {
      throw;
    }
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = started;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  function withdrawTokens1(uint256 _amount) {
    if(msg.sender!=wallet) throw;
    tokenReward1.transfer(wallet,_amount);
  }
  function withdrawTokens2(uint256 _amount) {
    if(msg.sender!=wallet) throw;
    tokenReward2.transfer(wallet,_amount);
  }
  function withdrawTokens3(uint256 _amount) {
    if(msg.sender!=wallet) throw;
    tokenReward3.transfer(wallet,_amount);
  }
  function withdrawTokens4(uint256 _amount) {
    if(msg.sender!=wallet) throw;
    tokenReward4.transfer(wallet,_amount);
  }
  function withdrawTokens5(uint256 _amount) {
    if(msg.sender!=wallet) throw;
    tokenReward5.transfer(wallet,_amount);
  }
}