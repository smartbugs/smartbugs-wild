pragma solidity ^0.4.18;
/**
* @title ICO CONTRACT
* @dev ERC-20 Token Standard Compliant
* @author Fares A. Akel C. f.antonio.akel@gmail.com
*/

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

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public{
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

contract token {

  function balanceOf(address _owner) public constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) public returns (bool success);

}


contract Crowdsale is Ownable {
  using SafeMath for uint256;
  // The token being sold
  token public token_reward;
  // start and end timestamps where investments are allowed (both inclusive
  
  //uint256 public start_time = now; //for testing
  uint256 public start_time = 1517846400; //02/05/2018 @ 4:00pm (UTC) or 5 PM (UTC + 1)
  uint256 public end_Time = 1519563600; // 02/25/2018 @ 1:00pm (UTC) or 2 PM (UTC + 1)
  uint256 public phase_1_remaining_tokens  = 50000000 * (10 ** uint256(18));
  uint256 public phase_2_remaining_tokens  = 25000000 * (10 ** uint256(18));
  uint256 public phase_3_remaining_tokens  = 15000000 * (10 ** uint256(18));
  uint256 public phase_4_remaining_tokens  = 10000000 * (10 ** uint256(18));

  uint256 public phase_1_token_price  = 5;// 5 cents
  uint256 public phase_2_token_price  = 6;// 6 cents
  uint256 public phase_3_token_price  = 7;// 7 cents
  uint256 public phase_4_token_price  = 8;// 8 cents

  // address where funds are collected
  address public wallet;
  // Ether to $ price
  uint256 public eth_to_usd = 1000;
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
  // rate change event
  event EthToUsdChanged(address indexed owner, uint256 old_eth_to_usd, uint256 new_eth_to_usd);
  
  // constructor
  function Crowdsale(address tokenContractAddress) public{
    wallet = 0x8716Be0540Fa6882CB0C05a804cC286B3CEb4a35;//wallet where ETH will be transferred
    token_reward = token(tokenContractAddress);
  }
  
 function tokenBalance() constant public returns (uint256){
    return token_reward.balanceOf(this);
  }

  function phase_1_rate() constant public returns (uint256){
    return eth_to_usd.mul(100).div(phase_1_token_price);
  }

  function phase_2_rate() constant public returns (uint256){
    return eth_to_usd.mul(100).div(phase_2_token_price);
  }

  function phase_3_rate() constant public returns (uint256){
    return eth_to_usd.mul(100).div(phase_3_token_price);
  }

  function phase_4_rate() constant public returns (uint256){
    return eth_to_usd.mul(100).div(phase_4_token_price);
  }

  // return specific rate
  function getRate() constant public returns (uint256){
    if(phase_1_remaining_tokens > 0){
      return phase_1_rate();
    }else if(phase_2_remaining_tokens > 0){
      return phase_2_rate();
    }else if(phase_3_remaining_tokens > 0){
      return phase_3_rate();
    }else if(phase_4_remaining_tokens > 0){
      return phase_4_rate();
    }else{
      return 0;
    }
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= start_time && now <= end_Time;
    bool allPhaseFinished = phase_4_remaining_tokens > 0;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase && allPhaseFinished;
  }


  // check token availibility for current phase and max allowed token balance
  function transferIfTokenAvailable(uint256 _tokens, uint256 _weiAmount, address _beneficiary) internal returns (bool){

    uint256 total_token_to_transfer = 0;
    uint256 wei_amount_remaining = 0;
    if(phase_1_remaining_tokens > 0){
      if(_tokens > phase_1_remaining_tokens){
        wei_amount_remaining = _weiAmount.sub(_weiAmount.div(phase_1_rate()));
        uint256 tokens_from_phase_2 = wei_amount_remaining.mul(phase_2_rate());
        total_token_to_transfer = phase_1_remaining_tokens.add(tokens_from_phase_2);
        phase_1_remaining_tokens = 0;
        phase_2_remaining_tokens = phase_2_remaining_tokens.sub(tokens_from_phase_2);
      }else{
        phase_1_remaining_tokens = phase_1_remaining_tokens.sub(_tokens);
        total_token_to_transfer = _tokens;
      }
    }else if(phase_2_remaining_tokens > 0){
      if(_tokens > phase_2_remaining_tokens){
        wei_amount_remaining = _weiAmount.sub(_weiAmount.div(phase_2_rate()));
        uint256 tokens_from_phase_3 = wei_amount_remaining.mul(phase_3_rate());
        total_token_to_transfer = phase_2_remaining_tokens.add(tokens_from_phase_3);
        phase_2_remaining_tokens = 0;
        phase_3_remaining_tokens = phase_3_remaining_tokens.sub(tokens_from_phase_3);
      }else{
        phase_2_remaining_tokens = phase_2_remaining_tokens.sub(_tokens);
        total_token_to_transfer = _tokens;
      }
      
    }else if(phase_3_remaining_tokens > 0){
      if(_tokens > phase_3_remaining_tokens){
        wei_amount_remaining = _weiAmount.sub(_weiAmount.div(phase_3_rate()));
        uint256 tokens_from_phase_4 = wei_amount_remaining.mul(phase_4_rate());
        total_token_to_transfer = phase_3_remaining_tokens.add(tokens_from_phase_4);
        phase_3_remaining_tokens = 0;
        phase_4_remaining_tokens = phase_4_remaining_tokens.sub(tokens_from_phase_4);
      }else{
        phase_3_remaining_tokens = phase_3_remaining_tokens.sub(_tokens);
        total_token_to_transfer = _tokens;
      }
      
    }else if(phase_4_remaining_tokens > 0){
      if(_tokens > phase_3_remaining_tokens){
        total_token_to_transfer = 0;
      }else{
        phase_4_remaining_tokens = phase_4_remaining_tokens.sub(_tokens);
        total_token_to_transfer = _tokens;
      }
    }else{
      total_token_to_transfer = 0;
    }
    if(total_token_to_transfer > 0){
      token_reward.transfer(_beneficiary, total_token_to_transfer);
      TokenPurchase(msg.sender, _beneficiary, _weiAmount, total_token_to_transfer);
      return true;
    }else{
      return false;
    }
    
  }

  // fallback function can be used to buy tokens
  function () payable public{
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());
    uint256 weiAmount = msg.value;
    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(getRate());
    // Check is there are enough token available for current phase and per person  
    require(transferIfTokenAvailable(tokens, weiAmount, beneficiary));
    // update state
    weiRaised = weiRaised.add(weiAmount);
    
    forwardFunds();
  }
  
  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }
  
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > end_Time;
  }
  // function to transfer token back to owner
  function transferBack(uint256 tokens) onlyOwner public returns (bool){
    token_reward.transfer(owner, tokens);
    return true;
  }
  // function to change rate
  function changeEth_to_usd(uint256 _eth_to_usd) onlyOwner public returns (bool){
    EthToUsdChanged(msg.sender, eth_to_usd, _eth_to_usd);
    eth_to_usd = _eth_to_usd;
    return true;
  }
}