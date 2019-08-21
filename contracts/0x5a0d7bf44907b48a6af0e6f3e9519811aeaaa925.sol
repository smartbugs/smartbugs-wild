pragma solidity 0.4.18;

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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

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

}


/**
 * @title Pausable token
 *
 * @dev StandardToken modified with pausable transfers.
 **/

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract CostumeToken is PausableToken {
  using SafeMath for uint256;

  // Token Details
  string public constant name = 'Costume Token';
  string public constant symbol = 'COST';
  uint8 public constant decimals = 18;

  // 200 Million Total Supply
  uint256 public constant totalSupply = 200e24;

  // 120 Million - Supply not for Crowdsale
  uint256 public initialSupply = 120e24;

  // 80 Million - Crowdsale limit
  uint256 public limitCrowdsale = 80e24;

  // Tokens Distributed - Crowdsale Buyers
  uint256 public tokensDistributedCrowdsale = 0;

  // The address of the crowdsale
  address public crowdsale;

  // -- MODIFIERS

  // Modifier, must be called from Crowdsale contract
  modifier onlyCrowdsale() {
    require(msg.sender == crowdsale);
    _;
  }

  // Constructor - send initial supply to owner
  function CostumeToken() public {
    balances[msg.sender] = initialSupply;
  }

  // Set crowdsale address, only by owner
  // @param - crowdsale address
  function setCrowdsaleAddress(address _crowdsale) external onlyOwner whenNotPaused {
    require(crowdsale == address(0));
    require(_crowdsale != address(0));
    crowdsale = _crowdsale;
  }

  // Distribute tokens, only by crowdsale
  // @param _buyer The buyer address
  // @param tokens The amount of tokens to send to that address
  function distributeCrowdsaleTokens(address _buyer, uint tokens) external onlyCrowdsale whenNotPaused {
    require(_buyer != address(0));
    require(tokens > 0);

    require(tokensDistributedCrowdsale < limitCrowdsale);
    require(tokensDistributedCrowdsale.add(tokens) <= limitCrowdsale);

    // Tick up the distributed amount
    tokensDistributedCrowdsale = tokensDistributedCrowdsale.add(tokens);

    // Add the funds to buyer address
    balances[_buyer] = balances[_buyer].add(tokens);
  }

}

contract Crowdsale is Pausable {
   using SafeMath for uint256;

   // The token being sold
   CostumeToken public token;

   // 12.15.2017 - 12:00:00 GMT
   uint256 public startTime = 1513339200;

   // 1.31.2018 - 12:00:00 GMT
   uint256 public endTime = 1517400000;

   // Costume Wallet
   address public wallet;

   // Set tier rates
   uint256 public rate = 3400;
   uint256 public rateTier2 = 3200;
   uint256 public rateTier3 = 3000;
   uint256 public rateTier4 = 2800;

   // The maximum amount of wei for each tier
   // 20 Million Intervals
   uint256 public limitTier1 = 20e24;
   uint256 public limitTier2 = 40e24;
   uint256 public limitTier3 = 60e24;

   // 80 Million Tokens available for crowdsale
   uint256 public constant maxTokensRaised = 80e24;

   // The amount of wei raised
   uint256 public weiRaised = 0;

   // The amount of tokens raised
   uint256 public tokensRaised = 0;

   // 0.1 ether minumum per contribution
   uint256 public constant minPurchase = 100 finney;

   // Crowdsale tokens not purchased
   bool public remainingTransfered = false;

   // The number of transactions
   uint256 public numberOfTransactions;

   // -- DATA-SETS

   // Amount each address paid for tokens
   mapping(address => uint256) public crowdsaleBalances;

   // Amount of tokens each address received
   mapping(address => uint256) public tokensBought;

   // -- EVENTS

   // Trigger TokenPurchase event
   event TokenPurchase(address indexed buyer, uint256 value, uint256 amountOfTokens);

   // Crowdsale Ended
   event Finalized();

   // -- MODIFIERS

   // Only allow the execution of the function before the crowdsale starts
   modifier beforeStarting() {
      require(now < startTime);
      _;
   }

   // Main Constructor
   // @param _wallet - Fund wallet address
   // @param _tokenAddress - Associated token address
   // @param _startTime - Crowdsale start time
   // @param _endTime - Crowdsale end time
   function Crowdsale(
      address _wallet,
      address _tokenAddress,
      uint256 _startTime,
      uint256 _endTime
   ) public {
      require(_wallet != address(0));
      require(_tokenAddress != address(0));

      if (_startTime > 0 && _endTime > 0) {
          require(_startTime < _endTime);
      }

      wallet = _wallet;
      token = CostumeToken(_tokenAddress);

      if (_startTime > 0) {
          startTime = _startTime;
      }

      if (_endTime > 0) {
          endTime = _endTime;
      }

   }

   /// Buy tokens fallback
   function () external payable {
      buyTokens();
   }

   /// Buy tokens main
   function buyTokens() public payable whenNotPaused {
      require(validPurchase());

      uint256 tokens = 0;
      uint256 amountPaid = adjustAmountValue();

      if (tokensRaised < limitTier1) {

         // Tier 1
         tokens = amountPaid.mul(rate);

         // If the amount of tokens that you want to buy gets out of this tier
         if (tokensRaised.add(tokens) > limitTier1) {

            tokens = adjustTokenTierValue(amountPaid, limitTier1, 1, rate);
         }

      } else if (tokensRaised >= limitTier1 && tokensRaised < limitTier2) {

         // Tier 2
         tokens = amountPaid.mul(rateTier2);

          // Breaks tier cap
         if (tokensRaised.add(tokens) > limitTier2) {
            tokens = adjustTokenTierValue(amountPaid, limitTier2, 2, rateTier2);
         }

      } else if (tokensRaised >= limitTier2 && tokensRaised < limitTier3) {

         // Tier 3
         tokens = amountPaid.mul(rateTier3);

         // Breaks tier cap
         if (tokensRaised.add(tokens) > limitTier3) {
            tokens = adjustTokenTierValue(amountPaid, limitTier3, 3, rateTier3);
         }

      } else if (tokensRaised >= limitTier3) {

         // Tier 4
         tokens = amountPaid.mul(rateTier4);

      }

      weiRaised = weiRaised.add(amountPaid);
      tokensRaised = tokensRaised.add(tokens);
      token.distributeCrowdsaleTokens(msg.sender, tokens);

      // Keep the records
      tokensBought[msg.sender] = tokensBought[msg.sender].add(tokens);

      // Broadcast event
      TokenPurchase(msg.sender, amountPaid, tokens);

      // Update records
      numberOfTransactions = numberOfTransactions.add(1);

      forwardFunds(amountPaid);
   }

   // Forward funds to fund wallet
   function forwardFunds(uint256 amountPaid) internal whenNotPaused {

     // Send directly to dev wallet
     wallet.transfer(amountPaid);
   }

   // Adjust wei based on tier, refund if necessaey
   function adjustAmountValue() internal whenNotPaused returns(uint256) {
      uint256 amountPaid = msg.value;
      uint256 differenceWei = 0;

      // Check final tier
      if(tokensRaised >= limitTier3) {
         uint256 addedTokens = tokensRaised.add(amountPaid.mul(rateTier4));

         // Have we reached the max?
         if(addedTokens > maxTokensRaised) {

            // Find the amount over the max
            uint256 difference = addedTokens.sub(maxTokensRaised);
            differenceWei = difference.div(rateTier4);
            amountPaid = amountPaid.sub(differenceWei);
         }
      }

      // Update balances dataset
      crowdsaleBalances[msg.sender] = crowdsaleBalances[msg.sender].add(amountPaid);

      // Transfer at the end
      if (differenceWei > 0) msg.sender.transfer(differenceWei);

      return amountPaid;
   }

   // Set / change tier rates
   // @param tier1 - tier4 - Rate per tier
   function setTierRates(uint256 tier1, uint256 tier2, uint256 tier3, uint256 tier4)
      external onlyOwner whenNotPaused {

      require(tier1 > 0 && tier2 > 0 && tier3 > 0 && tier4 > 0);
      require(tier1 > tier2 && tier2 > tier3 && tier3 > tier4);

      rate = tier1;
      rateTier2 = tier2;
      rateTier3 = tier3;
      rateTier4 = tier4;
   }

   // Adjust token per tier, return wei if necessay
   // @param amount - Amount buyer paid
   // @param tokensThisTier - Tokens in tier
   // @param tierSelected - The current tier
   // @param _rate - Current rate
   function adjustTokenTierValue(
      uint256 amount,
      uint256 tokensThisTier,
      uint256 tierSelected,
      uint256 _rate
   ) internal returns(uint256 totalTokens) {
      require(amount > 0 && tokensThisTier > 0 && _rate > 0);
      require(tierSelected >= 1 && tierSelected <= 4);

      uint weiThisTier = tokensThisTier.sub(tokensRaised).div(_rate);
      uint weiNextTier = amount.sub(weiThisTier);
      uint tokensNextTier = 0;
      bool returnTokens = false;

      // If there's excessive wei for the last tier, refund those
      if(tierSelected != 4) {

         tokensNextTier = calculateTokensPerTier(weiNextTier, tierSelected.add(1));

      } else {

         returnTokens = true;

      }

      totalTokens = tokensThisTier.sub(tokensRaised).add(tokensNextTier);

      // Do the transfer at the end
      if (returnTokens) msg.sender.transfer(weiNextTier);
   }

   // Return token amount based on wei paid
   // @param weiPaid - Amount buyer paid
   // @param tierSelected - The current tier
   function calculateTokensPerTier(uint256 weiPaid, uint256 tierSelected)
        internal constant returns(uint256 calculatedTokens)
    {
      require(weiPaid > 0);
      require(tierSelected >= 1 && tierSelected <= 4);

      if (tierSelected == 1) {

         calculatedTokens = weiPaid.mul(rate);

      } else if (tierSelected == 2) {

         calculatedTokens = weiPaid.mul(rateTier2);

      } else if (tierSelected == 3) {

         calculatedTokens = weiPaid.mul(rateTier3);

      } else {

         calculatedTokens = weiPaid.mul(rateTier4);
     }
   }

   // Confirm valid purchase
   function validPurchase() internal constant returns(bool) {
      bool withinPeriod = now >= startTime && now <= endTime;
      bool nonZeroPurchase = msg.value > 0;
      bool withinTokenLimit = tokensRaised < maxTokensRaised;
      bool minimumPurchase = msg.value >= minPurchase;

      return withinPeriod && nonZeroPurchase && withinTokenLimit && minimumPurchase;
   }

   // Check if sale ended
   function hasEnded() public constant returns(bool) {
       return now > endTime || tokensRaised >= maxTokensRaised;
   }

   // Finalize if ended
   function completeCrowdsale() external onlyOwner whenNotPaused {
       require(hasEnded());

       // Transfer left over tokens
       transferTokensLeftOver();

       // Call finalized event
       Finalized();
   }

   // Transfer any remaining tokens from Crowdsale
   function transferTokensLeftOver() internal {
       require(!remainingTransfered);
       require(maxTokensRaised > tokensRaised);

       remainingTransfered = true;

       uint256 remainingTokens = maxTokensRaised.sub(tokensRaised);
       token.distributeCrowdsaleTokens(msg.sender, remainingTokens);
   }

   // Change dates before crowdsale has started
   // @param _startTime - New start time
   // @param _endTime - New end time
   function changeDates(uint256 _startTime, uint256 _endTime)
        external onlyOwner beforeStarting
    {

       if (_startTime > 0 && _endTime > 0) {
           require(_startTime < _endTime);
       }

       if (_startTime > 0) {
           startTime = _startTime;
       }

       if (_endTime > 0) {
           endTime = _endTime;
       }
   }

   // Change the end date
   // @param _endTime - New end time
   function changeEndDate(uint256 _endTime) external onlyOwner {
       require(_endTime > startTime);
       require(_endTime > now);
       require(!hasEnded());

       if (_endTime > 0) {
           endTime = _endTime;
       }
   }

}