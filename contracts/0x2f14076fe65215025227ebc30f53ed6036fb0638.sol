pragma solidity 0.4.20;

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
 
 
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

 function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

interface ERC20Interface {
     function totalSupply() external constant returns (uint);
     function balanceOf(address tokenOwner) external constant returns (uint balance);
     function allowance(address tokenOwner, address spender) external constant returns (uint remaining);
     function transfer(address to, uint tokens) external returns (bool success);
     function approve(address spender, uint tokens) external returns (bool success);
     function transferFrom(address from, address to, uint tokens) external returns (bool success);
     event Transfer(address indexed from, address indexed to, uint tokens);
     event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract BaapPayCrowdsale is Ownable{
  using SafeMath for uint256;
 
  // The token being sold
  ERC20Interface public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;


  // how many token units a buyer gets per wei
  uint256 public ratePerWei = 4200;

  // amount of raised money in wei
  uint256 public weiRaised;

  uint256 TOKENS_SOLD;
  uint256 minimumContribution = 1 * 10 ** 16; //0.01 eth is the minimum contribution
  
  uint256 maxTokensToSaleInPreICOPhase = 3000000;
  uint256 maxTokensToSaleInICOPhase = 83375000;
  uint256 maxTokensToSale = 94000000;
  
  bool isCrowdsalePaused = false;
  
  struct Buyers 
  {
      address buyerAddress;
      uint tokenAmount;
  }
   Buyers[] tokenBuyers;
   Buyers buyer;
  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

   modifier checkSize(uint numwords) {
        assert(msg.data.length >= (numwords * 32) + 4);
        _;
    }     
    
  function BaapPayCrowdsale(uint256 _startTime, address _wallet, address _tokenToBeUsed) public 
  {
    //require(_startTime >=now);
    require(_wallet != 0x0);

    //startTime = _startTime;  
    startTime = now;
    endTime = startTime + 61 days;
    require(endTime >= startTime);
   
    owner = _wallet;
    
    maxTokensToSaleInPreICOPhase = maxTokensToSaleInPreICOPhase.mul(10**18);
    maxTokensToSaleInICOPhase = maxTokensToSaleInICOPhase.mul(10**18);
    maxTokensToSale = maxTokensToSale.mul(10**18);
    
    token = ERC20Interface(_tokenToBeUsed);
  }
  
  // fallback function can be used to buy tokens
  function () public  payable {
    buyTokens(msg.sender);
  }
    function determineBonus(uint tokens) internal view returns (uint256 bonus) 
    {
        uint256 timeElapsed = now - startTime;
        uint256 timeElapsedInDays = timeElapsed.div(1 days);
        if (timeElapsedInDays <20)
        {
            if (TOKENS_SOLD <maxTokensToSaleInPreICOPhase)
            {
                bonus = tokens.mul(20); //20% bonus
                bonus = bonus.div(100);
                require (TOKENS_SOLD.add(tokens.add(bonus)) <= maxTokensToSaleInPreICOPhase);
            }
            else if (TOKENS_SOLD >= maxTokensToSaleInPreICOPhase && TOKENS_SOLD < maxTokensToSale)
            {
                bonus = tokens.mul(15); //15% bonus
                bonus = bonus.div(100);
                require (TOKENS_SOLD.add(tokens.add(bonus)) <= maxTokensToSale);
            }
            else 
            {
                bonus = 0;
            }
        }
        else if (timeElapsedInDays >= 20 && timeElapsedInDays <27)
        {
            revert();  //no sale during this time, so revert this transaction
        }
        else if (timeElapsedInDays >= 27 && timeElapsedInDays<36)
        {
            if (TOKENS_SOLD < maxTokensToSaleInICOPhase)
            {
                bonus = tokens.mul(15); //15% bonus
                bonus = bonus.div(100);
                require (TOKENS_SOLD.add(tokens.add(bonus)) <= maxTokensToSaleInICOPhase);
            }
            else if (TOKENS_SOLD >= maxTokensToSaleInICOPhase && TOKENS_SOLD < maxTokensToSale)
            {
                bonus = tokens.mul(10); //10% bonus
                bonus = bonus.div(100);
                require (TOKENS_SOLD.add(tokens.add(bonus)) <= maxTokensToSale);
            }
        }
        else if (timeElapsedInDays >= 36 && timeElapsedInDays<46)
        {
            if (TOKENS_SOLD < maxTokensToSaleInICOPhase)
            {
                bonus = tokens.mul(10); //10% bonus
                bonus = bonus.div(100);
                require (TOKENS_SOLD.add(tokens.add(bonus)) <= maxTokensToSaleInICOPhase);
            }
            else if (TOKENS_SOLD >= maxTokensToSaleInICOPhase && TOKENS_SOLD < maxTokensToSale)
            {
                bonus = tokens.mul(5); //5% bonus
                bonus = bonus.div(100);
                require (TOKENS_SOLD.add(tokens.add(bonus)) <= maxTokensToSale);
            }
        }
        else if (timeElapsedInDays >= 46 && timeElapsedInDays<56)
        {
            if (TOKENS_SOLD < maxTokensToSaleInICOPhase)
            {
                bonus = tokens.mul(5); //5% bonus
                bonus = bonus.div(100);
                require (TOKENS_SOLD.add(tokens.add(bonus)) <= maxTokensToSaleInICOPhase);
            }
            else if (TOKENS_SOLD >= maxTokensToSaleInICOPhase && TOKENS_SOLD < maxTokensToSale)
            {
                bonus = 0;
            }
        }
        else 
        {
            bonus = 0;
        }
    }

  // low level token purchase function
  
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(isCrowdsalePaused == false);
    require(validPurchase());
    require(msg.value>= minimumContribution);
    require(TOKENS_SOLD<maxTokensToSale);
   
    uint256 weiAmount = msg.value;
    
    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(ratePerWei);
    uint256 bonus = determineBonus(tokens);
    tokens = tokens.add(bonus);
    require(TOKENS_SOLD.add(tokens)<=maxTokensToSale);
    
    // update state
    weiRaised = weiRaised.add(weiAmount);
    
    buyer = Buyers({buyerAddress:beneficiary,tokenAmount:tokens});
    tokenBuyers.push(buyer);
    TokenPurchase(owner, beneficiary, weiAmount, tokens);
    TOKENS_SOLD = TOKENS_SOLD.add(tokens);
    forwardFunds();
  }

  // send ether to the fund collection wallet
  function forwardFunds() internal {
    owner.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }
  
   
    function changeEndDate(uint256 endTimeUnixTimestamp) public onlyOwner returns(bool) {
        endTime = endTimeUnixTimestamp;
    }
    
    function changeStartDate(uint256 startTimeUnixTimestamp) public onlyOwner returns(bool) {
        startTime = startTimeUnixTimestamp;
    }
    
    function setPriceRate(uint256 newPrice) public onlyOwner returns (bool) {
        ratePerWei = newPrice;
    }
    
    function changeMinimumContribution(uint256 minContribution) public onlyOwner returns (bool) {
        minimumContribution = minContribution.mul(10 ** 15);
    }
     /**
     * function to pause the crowdsale 
     * can only be called from owner wallet
     **/
     
    function pauseCrowdsale() public onlyOwner returns(bool) {
        isCrowdsalePaused = true;
    }

    /**
     * function to resume the crowdsale if it is paused
     * can only be called from owner wallet
     * if the crowdsale has been stopped, this function would not resume it
     **/ 
    function resumeCrowdsale() public onlyOwner returns (bool) {
        isCrowdsalePaused = false;
    }
    
     // ------------------------------------------------------------------------
     // Remaining tokens for sale
     // ------------------------------------------------------------------------
     function remainingTokensForSale() public constant returns (uint) {
         return maxTokensToSale.sub(TOKENS_SOLD);
     }
     
     function showMyTokenBalance() public constant returns (uint) {
         return token.balanceOf(msg.sender);
     }
     
     function pullTokensBack() public onlyOwner {
        token.transfer(owner,token.balanceOf(address(this))); 
     }
     
     function sendTokensToBuyers() public onlyOwner {
         require(hasEnded());
         for (uint i=0;i<tokenBuyers.length;i++)
         {
             token.transfer(tokenBuyers[i].buyerAddress,tokenBuyers[i].tokenAmount);
         }
     }
}