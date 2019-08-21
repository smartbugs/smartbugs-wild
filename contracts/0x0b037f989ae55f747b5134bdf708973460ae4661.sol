pragma solidity ^0.4.11;

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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant public returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) tokenBalances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(tokenBalances[msg.sender]>=_value);
    tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(_value);
    tokenBalances[_to] = tokenBalances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant public returns (uint256 balance) {
    return tokenBalances[_owner];
  }

}

contract DRIVRNetworkToken is BasicToken,Ownable {

   using SafeMath for uint256;
   
   string public constant name = "DRIVR Network";
   string public constant symbol = "DVR";
   uint256 public constant decimals = 18;

   uint256 public constant INITIAL_SUPPLY = 750000000;
  /**
   * @dev Contructor that gives msg.sender all of existing tokens.
   */
    function DRIVRNetworkToken(address wallet) public {
        owner = msg.sender;
        totalSupply = INITIAL_SUPPLY * 10 ** 18;
        tokenBalances[wallet] = totalSupply;   //Since we divided the token into 10^18 parts
    }

    function mint(address wallet, address buyer, uint256 tokenAmount) public onlyOwner {
      require(tokenBalances[wallet] >= tokenAmount);               // checks if it has enough to sell
      tokenBalances[buyer] = tokenBalances[buyer].add(tokenAmount);                  // adds the amount to buyer's balance
      tokenBalances[wallet] = tokenBalances[wallet].sub(tokenAmount);                        // subtracts amount from seller's balance
      Transfer(wallet, buyer, tokenAmount); 
      totalSupply = totalSupply.sub(tokenAmount);
    }
    function showMyTokenBalance(address addr) public view returns (uint tokenBalance) {
        tokenBalance = tokenBalances[addr];
    }
}
contract DrivrCrowdsale {
  using SafeMath for uint256;
 
  // The token being sold
  DRIVRNetworkToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  // address where tokens are deposited and from where we send tokens to buyers
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public ratePerWei = 20000;

  // amount of raised money in wei
  uint256 public weiRaised;
  uint256 public duration = 75 days; //2 weeks and 2 months are 75 days
  uint256 TOKENS_SOLD;
  uint256 maxTokensToSaleInPrivateInvestmentPhase = 172500000 * 10 ** 18;
  uint256 maxTokensToSaleInPreICOPhase = 392500000 * 10 ** 18;
  uint256 maxTokensToSaleInICOPhase = 655000000 * 10 ** 18;
  uint256 maxTokensToSale = 655000000 * 10 ** 18;
  
  
  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event Debug(string message);

  function DrivrCrowdsale(uint256 _startTime, address _wallet) public 
  {
    require(_startTime >= now);
    startTime = _startTime;   
    endTime = startTime + duration;
    
    require(endTime >= startTime);
    require(_wallet != 0x0);

    wallet = _wallet;
    token = createTokenContract(wallet);
  }
  
  // creates the token to be sold.
  function createTokenContract(address wall) internal returns (DRIVRNetworkToken) {
    return new DRIVRNetworkToken(wall);
  }

  // fallback function can be used to buy tokens
  function () public payable {
    buyTokens(msg.sender);
  }

    function determineBonus(uint tokens) internal view returns (uint256 bonus) 
    {
        uint256 timeElapsed = now - startTime;
        uint256 timeElapsedInDays = timeElapsed.div(1 days);
        if (timeElapsedInDays <15)
        {
            if (TOKENS_SOLD < maxTokensToSaleInPrivateInvestmentPhase)
            {
                //15% bonus
                bonus = tokens.mul(15); //15% bonus
                bonus = bonus.div(100);
                require (TOKENS_SOLD + tokens + bonus <= maxTokensToSaleInPrivateInvestmentPhase);
            }
            else if (TOKENS_SOLD >= maxTokensToSaleInPrivateInvestmentPhase && TOKENS_SOLD < maxTokensToSaleInPreICOPhase)
            {
                bonus = tokens.mul(10); //10% bonus
                bonus = bonus.div(100);
                require (TOKENS_SOLD + tokens + bonus <= maxTokensToSaleInPreICOPhase);
            }
            else if (TOKENS_SOLD >= maxTokensToSaleInPreICOPhase && TOKENS_SOLD < maxTokensToSaleInICOPhase)
            {
                bonus = tokens.mul(5); //5% bonus
                bonus = bonus.div(100);
                require (TOKENS_SOLD + tokens + bonus <= maxTokensToSaleInICOPhase);
            }
            else 
            {
                bonus = 0;
            }
        }
        else if (timeElapsedInDays >= 15 && timeElapsedInDays<43)
        {
            if (TOKENS_SOLD < maxTokensToSaleInPreICOPhase)
            {
                bonus = tokens.mul(10); //10% bonus
                bonus = bonus.div(100);
                require (TOKENS_SOLD + tokens + bonus <= maxTokensToSaleInPreICOPhase);
            }
            else if (TOKENS_SOLD >= maxTokensToSaleInPreICOPhase && TOKENS_SOLD < maxTokensToSaleInICOPhase)
            {
                bonus = tokens.mul(5); //5% bonus
                bonus = bonus.div(100);
                require (TOKENS_SOLD + tokens + bonus <= maxTokensToSaleInICOPhase);
            }
            else 
            {
                bonus = 0;
            }
        }
        else if (timeElapsedInDays >= 43 && timeElapsedInDays<=75)
        {
            if (TOKENS_SOLD < maxTokensToSaleInICOPhase)
            {
                bonus = tokens.mul(5); //5% bonus
                bonus = bonus.div(100);
                require (TOKENS_SOLD + tokens + bonus <= maxTokensToSaleInICOPhase);
            }
            else 
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
  // Minimum purchase can be of 1 ETH
  
  function buyTokens(address beneficiary) public payable {
    
    require(beneficiary != 0x0 && validPurchase() && TOKENS_SOLD<maxTokensToSale);
    require(msg.value >= 1 * 10 ** 17);
    uint256 weiAmount = msg.value;
    
    // calculate token amount to be created
    
    uint256 tokens = weiAmount.mul(ratePerWei);
    uint256 bonus = determineBonus(tokens);
    tokens = tokens.add(bonus);
    require(TOKENS_SOLD+tokens<=maxTokensToSale);
    
    // update state
    weiRaised = weiRaised.add(weiAmount);
    token.mint(wallet, beneficiary, tokens); 
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    TOKENS_SOLD = TOKENS_SOLD.add(tokens);
    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
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
  
    function setPriceRate(uint256 newPrice) public returns (bool) {
        require (msg.sender == wallet);
        ratePerWei = newPrice;
    }
}