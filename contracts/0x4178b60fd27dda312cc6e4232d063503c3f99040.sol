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

contract ERC20Interface {
     function totalSupply() public constant returns (uint);
     function balanceOf(address tokenOwner) public constant returns (uint balance);
     function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
     function transfer(address to, uint tokens) public returns (bool success);
     function approve(address spender, uint tokens) public returns (bool success);
     function transferFrom(address from, address to, uint tokens) public returns (bool success);
     event Transfer(address indexed from, address indexed to, uint tokens);
     event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract HashcoCoin is ERC20Interface,Ownable {

   using SafeMath for uint256;
   
   string public name;
   string public symbol;
   uint256 public decimals;

   uint256 public _totalSupply;
   mapping(address => uint256) tokenBalances;
   address ownerWallet;
   // Owner of account approves the transfer of an amount to another account
   mapping (address => mapping (address => uint256)) allowed;
   
   /**
   * @dev Contructor that gives msg.sender all of existing tokens.
   */
    function HashcoCoin(address wallet) public {
        owner = msg.sender;
        ownerWallet = wallet;
        name  = "HashcoCoin";
        symbol = "HCC";
        decimals = 18;
        _totalSupply = 60000000 * 10 ** uint(decimals);
        tokenBalances[wallet] = _totalSupply;   //Since we divided the token into 10^18 parts
    }
    
     // Get the token balance for account `tokenOwner`
     function balanceOf(address tokenOwner) public constant returns (uint balance) {
         return tokenBalances[tokenOwner];
     }
  
     // Transfer the balance from owner's account to another account
     function transfer(address to, uint tokens) public returns (bool success) {
         require(to != address(0));
         require(tokens <= tokenBalances[msg.sender]);
         tokenBalances[msg.sender] = tokenBalances[msg.sender].sub(tokens);
         tokenBalances[to] = tokenBalances[to].add(tokens);
         Transfer(msg.sender, to, tokens);
         return true;
     }
  
     /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= tokenBalances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    tokenBalances[_from] = tokenBalances[_from].sub(_value);
    tokenBalances[_to] = tokenBalances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
  
     /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

     // ------------------------------------------------------------------------
     // Total supply
     // ------------------------------------------------------------------------
     function totalSupply() public constant returns (uint) {
         return _totalSupply  - tokenBalances[address(0)];
     }
     
    
     
     // ------------------------------------------------------------------------
     // Returns the amount of tokens approved by the owner that can be
     // transferred to the spender's account
     // ------------------------------------------------------------------------
     function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
         return allowed[tokenOwner][spender];
     }
     
     /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

     
     // ------------------------------------------------------------------------
     // Don't accept ETH
     // ------------------------------------------------------------------------
     function () public payable {
         revert();
     }
 
 
     // ------------------------------------------------------------------------
     // Owner can transfer out any accidentally sent ERC20 tokens
     // ------------------------------------------------------------------------
     function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
         return ERC20Interface(tokenAddress).transfer(owner, tokens);
     }
     
     //only to be used by the ICO
     
     function mint(address wallet, address buyer, uint256 tokenAmount) public onlyOwner {
      require(tokenBalances[wallet] >= tokenAmount);               // checks if it has enough to sell
      tokenBalances[buyer] = tokenBalances[buyer].add(tokenAmount);                  // adds the amount to buyer's balance
      tokenBalances[wallet] = tokenBalances[wallet].sub(tokenAmount);                        // subtracts amount from seller's balance
      Transfer(wallet, buyer, tokenAmount); 
      _totalSupply = _totalSupply.sub(tokenAmount);
    }
}
contract HashcoCoinCrowdsale {
  using SafeMath for uint256;
 
  // The token being sold
  HashcoCoin public token;

  // address where funds are collected
  // address where tokens are deposited and from where we send tokens to buyers
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public ratePerWeiFirstPhase = 5263;
  uint256 public ratePerWeiSecondPhase = 3333;

  // amount of raised money in wei
  uint256 public weiRaised;

  uint256 TOKENS_SOLD;
  uint256 maxTokensToSale = 60000000 * 10 ** 18;
  
  
  bool isCrowdsalePaused = false;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function HashcoCoinCrowdsale(address _wallet) public 
  {
    require(_wallet != 0x0);

    wallet = _wallet;
    token = createTokenContract(wallet);
  }
  
   // creates the token to be sold.
  function createTokenContract(address wall) internal returns (HashcoCoin) {
    return new HashcoCoin(wall);
  }
  // fallback function can be used to buy tokens
  function () public payable {
    buyTokens(msg.sender);
  }
   
  // low level token purchase function
  // Minimum purchase can be of 1 ETH
  
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(isCrowdsalePaused == false);
    require(msg.value>0);
    require(TOKENS_SOLD<maxTokensToSale);
    uint256 weiAmount = msg.value;
    uint256 tokens;
    uint256 bonus;

    // calculate token amount to be transferred
    if (TOKENS_SOLD < 15000000 * 10 ** 18)
    {
        tokens = weiAmount.mul(ratePerWeiFirstPhase);
        require(TOKENS_SOLD+tokens<=maxTokensToSale);
    }
    else 
    {
        tokens = weiAmount.mul(ratePerWeiSecondPhase);
        require(TOKENS_SOLD+tokens<=maxTokensToSale);
    }
    bonus = tokens.mul(10);
    bonus = bonus.div(100);
    tokens = tokens.add(bonus);

    // update state
    weiRaised = weiRaised.add(weiAmount);
    TOKENS_SOLD = TOKENS_SOLD.add(tokens);
    require (TOKENS_SOLD<=maxTokensToSale);
    token.mint(wallet, beneficiary, tokens); 
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

    
    /**
     * function to change the price rate for phase 1
     * can only be called from owner wallet
     **/
     
    function setPriceRatePhase1(uint256 newPrice) public returns (bool) {
        require (msg.sender == wallet);
        ratePerWeiFirstPhase = newPrice;
    }
    
    /**
     * function to change the price rate for phase 1
     * can only be called from owner wallet
     **/
     
    function setPriceRatePhase2(uint256 newPrice) public returns (bool) {
        require (msg.sender == wallet);
        ratePerWeiSecondPhase = newPrice;
    }
    
     /**
     * function to pause the crowdsale 
     * can only be called from owner wallet
     **/
     
    function pauseCrowdsale() public returns(bool) {
        require(msg.sender==wallet);
        isCrowdsalePaused = true;
    }

    /**
     * function to resume the crowdsale if it is paused
     * can only be called from owner wallet
     * if the crowdsale has been stopped, this function would not resume it
     **/ 
    function resumeCrowdsale() public returns (bool) {
        require(msg.sender==wallet);
        isCrowdsalePaused = false;
    }
    
     // ------------------------------------------------------------------------
     // Remaining tokens for sale
     // ------------------------------------------------------------------------
     function remainingTokensForSale() public constant returns (uint) {
         return maxTokensToSale - TOKENS_SOLD;
     }
     
     function showMyTokenBalance() public constant returns (uint) {
         return token.balanceOf(msg.sender);
     }
}