pragma solidity ^0.5.7;

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
    // assert(b > 0); // Solidity automatically throws when dividing by 0 uint256 c = a / b;
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

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded 
 to a wallet
 * as they arrive.
 */
interface token { 
  function transfer(address receiver, uint amount) external returns (bool) ; 
  function balanceOf(address holder) external view returns (uint) ;
}
contract Crowdsale {
  using SafeMath for uint256;


  // address where funds are collected
  address payable public wallet;
  // token address
  address public addressOfTokenUsedAsReward;

  uint256 public price = 75000;
  uint256 public tokensSold;

  token tokenReward;

  // amount of raised money in wei
  uint256 public weiRaised;

  mapping (address => uint) public balances;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  constructor () public {
    //You will change this to your wallet where you need the ETH 
    wallet = 0x41d5e81BFBCb4eB82F9d7Fda41b9FE2759C69564;
    
    //Here will come the checksum address we got
    addressOfTokenUsedAsReward = 0x0B44547be0A0Df5dCd5327de8EA73680517c5a54;

    tokenReward = token(addressOfTokenUsedAsReward);
  }

  bool public started = true;

  function startSale() public {
    require (msg.sender == wallet);
    started = true;
  }

  function stopSale() public {
    require(msg.sender == wallet);
    started = false;
  }

  function setPrice(uint256 _price) public {
    require(msg.sender == wallet);
    price = _price;
  }
  function changeWallet(address payable _wallet) public {
    require (msg.sender == wallet);
    wallet = _wallet;
  }


  // fallback function can be used to buy tokens
  function () payable external {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) payable public {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;


    // calculate token amount to be sent
    uint256 tokens = (weiAmount) * price;//weiamount * price 
    // uint256 tokens = (weiAmount/10**(18-decimals)) * price;//weiamount * price 

    // update state
    weiRaised = weiRaised.add(weiAmount);

    // tokenReward.transfer(beneficiary, tokens);
    tokensSold = tokensSold.add(tokens);

    // ensure the smart contract has enough tokens to sell
    require(tokenReward.balanceOf(address(this)).sub(tokensSold) >= tokens);

    // allocate tokens to benefeciary
    balances[beneficiary] = balances[beneficiary].add(tokens);

    emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds();
  }

  function claimTokens() public {
    // ensure benefeciary has enough tokens
    require(started == false && balances[msg.sender] > 0);

    tokenReward.transfer(msg.sender, balances[msg.sender]);

    // now benefeciary doesn't have any tokens
    balances[msg.sender] = 0;
  }

  function myBalance() public view returns (uint) {
    return balances[msg.sender];
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
     wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = started;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  function withdrawTokens(uint256 _amount) public {
    
    require (msg.sender == wallet && 
      tokenReward.balanceOf(address(this)).sub(tokensSold) >= _amount);

    tokenReward.transfer(wallet,_amount);
  }
}