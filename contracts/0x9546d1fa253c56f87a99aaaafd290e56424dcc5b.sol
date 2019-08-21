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
contract EtheeraToken is BasicToken,Ownable {

   using SafeMath for uint256;
   
   string public constant name = "ETHEERA";
   string public constant symbol = "ETA";
   uint256 public constant decimals = 18;

   uint256 public constant INITIAL_SUPPLY = 300000000;
   event Debug(string message, address addr, uint256 number);
   /**
   * @dev Contructor that gives msg.sender all of existing tokens.
   */
    function EtheeraToken(address wallet) public {
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
    
    function showMyTokenBalance(address addr) public view onlyOwner returns (uint tokenBalance) {
        tokenBalance = tokenBalances[addr];
        return tokenBalance;
    }
    
}
contract EtheeraCrowdsale {
  using SafeMath for uint256;
 
  // The token being sold
  EtheeraToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  // address where tokens are deposited and from where we send tokens to buyers
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public ratePerWei = 2000;

  // amount of raised money in wei
  uint256 public weiRaised;

  // flags to show whether soft cap / hard cap is reached
  bool public isSoftCapReached = false;
  bool public isHardCapReached = false;
    
  //this flag is set to true when ICO duration is over and soft cap is not reached  
  bool public refundToBuyers = false;
    
  // Soft cap of the ICO in ethers  
  uint256 public softCap = 6000;
    
  //Hard cap of the ICO in ethers
  uint256 public hardCap = 105000;
  
  //total tokens that have been sold  
  uint256 public tokens_sold = 0;

  //total tokens that are to be sold - this is 70% of the total supply i.e. 300000000
  uint maxTokensForSale = 210000000;
  
  //tokens that are reserved for the etheera team - this is 30% of the total supply  
  uint256 public tokensForReservedFund = 0;
  uint256 public tokensForAdvisors = 0;
  uint256 public tokensForFoundersAndTeam = 0;
  uint256 public tokensForMarketing = 0;
  uint256 public tokensForTournament = 0;

  bool ethersSentForRefund = false;

  // the buyers of tokens and the amount of ethers they sent in
  mapping(address=>uint256) usersThatBoughtETA;
 
  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function EtheeraCrowdsale(uint256 _startTime, address _wallet) public {

    startTime = _startTime;
    endTime = startTime + 60 days;
    
    require(endTime >= startTime);
    require(_wallet != 0x0);

    wallet = _wallet;
    token = createTokenContract(wallet);
  }

  function createTokenContract(address wall) internal returns (EtheeraToken) {
    return new EtheeraToken(wall);
  }

  // fallback function can be used to buy tokens
  function () public payable {
    buyTokens(msg.sender);
  }

  //determine the bonus with respect to time elapsed
  function determineBonus(uint tokens) internal view returns (uint256 bonus) {
    
    uint256 timeElapsed = now - startTime;
    uint256 timeElapsedInDays = timeElapsed.div(1 days);
    
    if (timeElapsedInDays <=29)
    {
        //early sale
        //valid for 7 days (1st week)
        //30000+ TOKEN PURCHASE AMOUNT / 33% BONUS
        if (tokens>30000 * 10 ** 18)
        {
            //33% bonus
            bonus = tokens.mul(33);
            bonus = bonus.div(100);
        }
        //10000+ TOKEN PURCHASE AMOUNT / 26% BONUS
        else if (tokens>10000 *10 ** 18 && tokens<= 30000 * 10 ** 18)
        {
            //26% bonus
            bonus = tokens.mul(26);
            bonus = bonus.div(100);
        }
        //3000+ TOKEN PURCHASE AMOUNT / 23% BONUS
        else if (tokens>3000 *10 ** 18 && tokens<= 10000 * 10 ** 18)
        {
            //23% bonus
            bonus = tokens.mul(23);
            bonus = bonus.div(100);
        }
        
        //75+ TOKEN PURCHASE AMOUNT / 20% BONUS
        else if (tokens>=75 *10 ** 18 && tokens<= 3000 * 10 ** 18)
        {
            //20% bonus
            bonus = tokens.mul(20);
            bonus = bonus.div(100);
        }
        else 
        {
            bonus = 0;
        }
    }
    else if (timeElapsedInDays>29 && timeElapsedInDays <=49)
    {
        //sale
        //from 7th day till 49th day (total 42 days or 6 weeks)
        //30000+ TOKEN PURCHASE AMOUNT / 15% BONUS
        if (tokens>30000 * 10 ** 18)
        {
            //15% bonus
            bonus = tokens.mul(15);
            bonus = bonus.div(100);
        }
        //10000+ TOKEN PURCHASE AMOUNT / 10% BONUS
        else if (tokens>10000 *10 ** 18 && tokens<= 30000 * 10 ** 18)
        {
            //10% bonus
            bonus = tokens.mul(10);
            bonus = bonus.div(100);
        }
        //3000+ TOKEN PURCHASE AMOUNT / 5% BONUS
        else if (tokens>3000 *10 ** 18 && tokens<= 10000 * 10 ** 18)
        {
            //5% bonus
            bonus = tokens.mul(5);
            bonus = bonus.div(100);
        }
        
        //75+ TOKEN PURCHASE AMOUNT / 3% BONUS
        else if (tokens>=75 *10 ** 18 && tokens<= 3000 * 10 ** 18)
        {
            //3% bonus
            bonus = tokens.mul(3);
            bonus = bonus.div(100);
        }
        else 
        {
            bonus = 0;
        }
    }
    else
    {
        //no bonuses after 7th week i.e. 49 days
        bonus = 0;
    }
  }

  // low level token purchase function
  // Minimum purchase can be of 75 ETA tokens
  
  function buyTokens(address beneficiary) public payable {
    
  //tokens not to be sent to 0x0
  require(beneficiary != 0x0);

  if(hasEnded() && !isHardCapReached)
  {
      if (!isSoftCapReached)
        refundToBuyers = true;
      burnRemainingTokens();
      beneficiary.transfer(msg.value);
  }
  
  else
  {
    //the purchase should be within duration and non zero
    require(validPurchase());
    
    // amount sent by the user
    uint256 weiAmount = msg.value;
    
    // calculate token amount to be sold
    uint256 tokens = weiAmount.mul(ratePerWei);
  
    require (tokens>=75 * 10 ** 18);
    
    //Determine bonus
    uint bonus = determineBonus(tokens);
    tokens = tokens.add(bonus);
  
    //can't sale tokens more than 21000000000
    require(tokens_sold + tokens <= maxTokensForSale * 10 ** 18);
  
    //30% of the tokens being sold are being accumulated for the etheera team
    updateTokensForEtheeraTeam(tokens);

    weiRaised = weiRaised.add(weiAmount);
    
    
    if (weiRaised >= softCap * 10 ** 18 && !isSoftCapReached)
    {
      isSoftCapReached = true;
    }
  
    if (weiRaised >= hardCap * 10 ** 18 && !isHardCapReached)
      isHardCapReached = true;
    
    token.mint(wallet, beneficiary, tokens);
    
    uint olderAmount = usersThatBoughtETA[beneficiary];
    usersThatBoughtETA[beneficiary] = weiAmount + olderAmount;
    
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    
    tokens_sold = tokens_sold.add(tokens);
    forwardFunds();
  }
 }

  // send ether to the fund collection wallet
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
    
    function burnRemainingTokens() internal
    {
        //burn all the unsold tokens as soon as the ICO is ended
        uint balance = token.showMyTokenBalance(wallet);
        require(balance>0);
        uint tokensForTeam = tokensForReservedFund + tokensForFoundersAndTeam + tokensForAdvisors +tokensForMarketing + tokensForTournament;
        uint tokensToBurn = balance.sub(tokensForTeam);
        require (balance >=tokensToBurn);
        address burnAddress = 0x0;
        token.mint(wallet,burnAddress,tokensToBurn);
    }
    
    function getRefund() public 
    {
        require(ethersSentForRefund && usersThatBoughtETA[msg.sender]>0);
        uint256 ethersSent = usersThatBoughtETA[msg.sender];
        require (wallet.balance >= ethersSent);
        msg.sender.transfer(ethersSent);
        uint256 tokensIHave = token.showMyTokenBalance(msg.sender);
        token.mint(msg.sender,0x0,tokensIHave);
    }
    
    function debitAmountToRefund() public payable 
    {
        require(hasEnded() && msg.sender == wallet && !isSoftCapReached && !ethersSentForRefund);
        require(msg.value >=weiRaised);
        ethersSentForRefund = true;
    }
    
    function updateTokensForEtheeraTeam(uint256 tokens) internal 
    {
        uint256 reservedFundTokens;
        uint256 foundersAndTeamTokens;
        uint256 advisorsTokens;
        uint256 marketingTokens;
        uint256 tournamentTokens;
        
        //10% of tokens for reserved fund
        reservedFundTokens = tokens.mul(10);
        reservedFundTokens = reservedFundTokens.div(100);
        tokensForReservedFund = tokensForReservedFund.add(reservedFundTokens);
    
        //15% of tokens for founders and team    
        foundersAndTeamTokens=tokens.mul(15);
        foundersAndTeamTokens= foundersAndTeamTokens.div(100);
        tokensForFoundersAndTeam = tokensForFoundersAndTeam.add(foundersAndTeamTokens);
    
        //3% of tokens for advisors
        advisorsTokens=tokens.mul(3);
        advisorsTokens= advisorsTokens.div(100);
        tokensForAdvisors= tokensForAdvisors.add(advisorsTokens);
    
        //1% of tokens for marketing
        marketingTokens = tokens.mul(1);
        marketingTokens= marketingTokens.div(100);
        tokensForMarketing= tokensForMarketing.add(marketingTokens);
        
        //1% of tokens for tournament 
        tournamentTokens=tokens.mul(1);
        tournamentTokens= tournamentTokens.div(100);
        tokensForTournament= tokensForTournament.add(tournamentTokens);
    }
    
    function withdrawTokensForEtheeraTeam(uint256 whoseTokensToWithdraw,address[] whereToSendTokens) public {
        //1 reserved fund, 2 for founders and team, 3 for advisors, 4 for marketing, 5 for tournament
        require(msg.sender == wallet && now>=endTime);
        uint256 lockPeriod = 0;
        uint256 timePassed = now - endTime;
        uint256 tokensToSend = 0;
        uint256 i = 0;
        if (whoseTokensToWithdraw == 1)
        {
          //15 months lockup period
          lockPeriod = 15 days * 30;
          require(timePassed >= lockPeriod);
          require (tokensForReservedFund >0);
          //allow withdrawal
          tokensToSend = tokensForReservedFund.div(whereToSendTokens.length);
                
          for (i=0;i<whereToSendTokens.length;i++)
          {
            token.mint(wallet,whereToSendTokens[i],tokensToSend);
          }
          tokensForReservedFund = 0;
        }
        else if (whoseTokensToWithdraw == 2)
        {
          //10 months lockup period
          lockPeriod = 10 days * 30;
          require(timePassed >= lockPeriod);
          require(tokensForFoundersAndTeam > 0);
          //allow withdrawal
          tokensToSend = tokensForFoundersAndTeam.div(whereToSendTokens.length);
                
          for (i=0;i<whereToSendTokens.length;i++)
          {
            token.mint(wallet,whereToSendTokens[i],tokensToSend);
          }            
          tokensForFoundersAndTeam = 0;
        }
        else if (whoseTokensToWithdraw == 3)
        {
            require (tokensForAdvisors > 0);
          //allow withdrawal
          tokensToSend = tokensForAdvisors.div(whereToSendTokens.length);        
          for (i=0;i<whereToSendTokens.length;i++)
          {
            token.mint(wallet,whereToSendTokens[i],tokensToSend);
          }
          tokensForAdvisors = 0;
        }
        else if (whoseTokensToWithdraw == 4)
        {
            require (tokensForMarketing > 0);
          //allow withdrawal
          tokensToSend = tokensForMarketing.div(whereToSendTokens.length);
                
          for (i=0;i<whereToSendTokens.length;i++)
          {
            token.mint(wallet,whereToSendTokens[i],tokensToSend);
          }
          tokensForMarketing = 0;
        }
        else if (whoseTokensToWithdraw == 5)
        {
            require (tokensForTournament > 0);
          //allow withdrawal
          tokensToSend = tokensForTournament.div(whereToSendTokens.length);
                
          for (i=0;i<whereToSendTokens.length;i++)
          {
            token.mint(wallet,whereToSendTokens[i],tokensToSend);
          }
          tokensForTournament = 0;
        }
        else 
        {
          //wrong input
          require (1!=1);
        }
    }
}