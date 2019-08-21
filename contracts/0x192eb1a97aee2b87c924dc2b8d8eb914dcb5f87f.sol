pragma solidity ^0.4.15;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
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
  function Ownable() {
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
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {

    address public constant BURN_ADDRESS = 0;

    event Burn(address indexed burner, uint256 value);

	
	function burnTokensInternal(address _address, uint256 _value) internal {
        require(_value > 0);
        require(_value <= balances[_address]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = _address;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
		Transfer(burner, BURN_ADDRESS, _value);
		
	}
		
}

/**
 * @title Handelion Token
 * @dev Main token used for Handelion crowdsale
 */
 contract HIONToken is BurnableToken, Ownable
 {
	
	/** Handelion token name official name. */
	string public constant name = "HION Token by Handelion"; 
	 
	 /** Handelion token official symbol.*/
	string public constant symbol = "HION"; 

	/** Number of decimal units for Handelion token */
	uint256 public constant decimals = 18;

	/* Preissued token amount */
	uint256 public constant PREISSUED_AMOUNT = 29750000 * 1 ether;
			
	/** 
	 * Indicates wheather token transfer is allowed. Token transfer is allowed after crowdsale is over. 
	 * Before crowdsale is over only token owner is allowed to transfer tokens to investors.
	 */
	bool public transferAllowed = false;
			
	/** Raises when initial amount of tokens is preissued */
	event LogTokenPreissued(address ownereAddress, uint256 amount);
	
	
	modifier canTransfer(address sender)
	{
		require(transferAllowed || sender == owner);
		
		_;
	}
	
	/**
	 * Creates and initializes Handelion token
	 */
	function HIONToken()
	{
		// Address of token creator. The creator of this token is major holder of all preissued tokens before crowdsale starts
		owner = msg.sender;
	 
		// Send all pre-created tokens to token creator address
		totalSupply = totalSupply.add(PREISSUED_AMOUNT);
		balances[owner] = balances[owner].add(PREISSUED_AMOUNT);
		
		LogTokenPreissued(owner, PREISSUED_AMOUNT);
	}
	
	/**
	 * Returns Token creator address
	 */
	function getCreatorAddress() public constant returns(address creatorAddress)
	{
		return owner;
	}
	
	/**
	 * Gets total supply of Handelion token
	 */
	function getTotalSupply() public constant returns(uint256)
	{
		return totalSupply;
	}
	
	/**
	 * Gets number of remaining tokens
	 */
	function getRemainingTokens() public constant returns(uint256)
	{
		return balanceOf(owner);
	}	
	
	/**
	 * Allows token transfer. Should be called after crowdsale is over
	 */
	function allowTransfer() onlyOwner public
	{
		transferAllowed = true;
	}
	
	
	/**
	 * Overrides transfer function by adding check whether transfer is allwed
	 */
	function transfer(address _to, uint256 _value) canTransfer(msg.sender) public returns (bool)	
	{
		super.transfer(_to, _value);
	}

	/**
	 * Override transferFrom function and adds a check whether transfer is allwed
	 */
	function transferFrom(address _from, address _to, uint256 _value) canTransfer(_from) public returns (bool) {	
		super.transferFrom(_from, _to, _value);
	}
	
	/**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
		burnTokensInternal(msg.sender, _value);
    }

    /**
     * @dev Burns a specific amount of tokens for specific address. Can be called only by token owner.
	 * @param _address 
     * @param _value The amount of token to be burned.
     */
    function burn(address _address, uint256 _value) public onlyOwner {
		burnTokensInternal(_address, _value);
    }
}

/*
 * Stoppable
 *
 * Abstract contract that allows children to implement an
 * emergency stop mechanism.
 *
 *
 */
contract Stoppable is Ownable {
  bool public stopped;

  modifier stopInEmergency {
    require(!stopped);
    _;
  }

  modifier stopNonOwnersInEmergency {
    require(!stopped || msg.sender == owner);
    _;
  }

  modifier onlyInEmergency {
    require(stopped);
    _;
  }

  // called by the owner on emergency, triggers stopped state
  function stop() external onlyOwner {
    stopped = true;
  }

  // called by the owner on end of emergency, returns to normal state
  function unstop() external onlyOwner onlyInEmergency {
    stopped = false;
  }

}

/**
 * Handelion ICO crowdsale.
 * 
 */
contract HANDELIONdiscountSALE is Ownable, Stoppable
{
	using SafeMath for uint256;

	struct FundingTier {
		uint256 cap;
		uint256 rate;
	}
		
	/** Handelion token we are selling in this crowdsale */
	HIONToken public token; 
	
	/** Token price tiers and caps */
	FundingTier public tier1;
	
	FundingTier public tier2;
	
	FundingTier public tier3;
	
	FundingTier public tier4;
	
	FundingTier public tier5;	

	/** inclusive start timestamps of crowdsale */
	uint256 public startTime;

	/** inclusive end timestamp of crowedsale */
	uint256 public endTime;

	/** address where funds are collected */
	address public multisigWallet;
	
	/** minimal amount of sold tokens for crowdsale to be considered as successful */
	uint256 public minimumTokenAmount;

	/** maximal number of tokens we can sell */
	uint256 public maximumTokenAmount;

	// amount of raised money in wei
	uint256 public weiRaised;

	/** amount of sold tokens */
	uint256 public tokensSold;

	/** number of unique investors */
	uint public investorCount;

	/** Identifies whether crowdsale has been finalized */
	bool public finalized;

	/** Identifies wheather refund is opened */
	bool public isRefunding;

	/** Amount of received ETH by investor */
	mapping (address => uint256) public investedAmountOf;

	/** Amount of selled tokens by investor */
	mapping (address => uint256) public tokenAmountOf;
	
	/**
	* event for token purchase logging
	* @param purchaser who paid for the tokens
	* @param beneficiary who got the tokens
	* @param value weis paid for purchase
	* @param amount amount of tokens purchased
	*/
	event LogTokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

	event LogCrowdsaleStarted();

	event LogCrowdsaleFinalized(bool isGoalReached);

	event LogRefundingOpened(uint256 refundAmount);

	event LogInvestorRefunded(address investorAddress, uint256 refundedAmount);
	
	/**
	 * Start date: 08-12-2017 12:00 GMT
	 * End date: 31-03-2018 12:00 GMT
	 */
	function HANDELIONdiscountSALE() 
	{
		createTokenContract();
		
		startTime = 1512734400;
		endTime = 1522497600;

		multisigWallet = 0x7E23cFa050d23B9706a071dEd0A62d30AE6BB6c8;
		
		minimumTokenAmount = 4830988 * 1 ether;
		maximumTokenAmount = 29750000 * 1 ether;

		tokensSold = 0;
		weiRaised = 0;

		tier1 = FundingTier({cap: 2081338 * 1 ether, rate: 480});
		tier2 = FundingTier({cap: 4830988 * 1 ether, rate: 460});
		tier3 = FundingTier({cap: 9830988 * 1 ether, rate: 440});
		tier4 = FundingTier({cap: 14830988 * 1 ether, rate: 420});
		tier5 = FundingTier({cap: 23184738 * 1 ether, rate: 400});

		finalized = false;
	}
	
	 
	/**
	 * Overriding function to create HandelionToken
	 */
	function createTokenContract() internal
	{
		token = HIONToken(0xa089273724e07644da9739a708e544800d925115);
	}
	
	function calculateTierTokens(FundingTier _tier, uint256 _amount, uint256 _currentTokenAmount) constant internal returns (uint256)
	{
		uint256 maxTierTokens = _tier.cap.sub(_currentTokenAmount);

		if (maxTierTokens <= 0)
		{
			return 0;
		}
				
		uint256 tokenCount = _amount.mul(_tier.rate);
			
		if (tokenCount > maxTierTokens)
		{
			tokenCount = maxTierTokens;
		}
			
		return tokenCount;
	}
	
	function calculateTokenAmount(uint256 _weiAmount) constant internal returns (uint256)
	{		
		uint256 nTokens = tokensSold;
		uint256 remainingWei = _weiAmount;
		uint256 tierTokens = 0;
		
		if (nTokens < tier1.cap)
		{			
			tierTokens = calculateTierTokens(tier1, remainingWei, nTokens);
			nTokens = nTokens.add(tierTokens);		
			remainingWei = remainingWei.sub(tierTokens.div(tier1.rate));
		}
		
		if (remainingWei > 0 && nTokens < tier2.cap)
		{
			tierTokens = calculateTierTokens(tier2, remainingWei, nTokens);
			nTokens = nTokens.add(tierTokens);			
			remainingWei = remainingWei.sub(tierTokens.div(tier2.rate));
		}

		if (remainingWei > 0 && nTokens < tier3.cap)
		{
			tierTokens = calculateTierTokens(tier3, remainingWei, nTokens);
			nTokens = nTokens.add(tierTokens);			
			remainingWei = remainingWei.sub(tierTokens.div(tier3.rate));
		}

		if (remainingWei > 0 && nTokens < tier4.cap)
		{
			tierTokens = calculateTierTokens(tier4, remainingWei, nTokens);
			nTokens = nTokens.add(tierTokens);			
			remainingWei = remainingWei.sub(tierTokens.div(tier4.rate));
		}

		if (remainingWei > 0 && nTokens < tier5.cap)
		{
			tierTokens = calculateTierTokens(tier5, remainingWei, nTokens);
			nTokens = nTokens.add(tierTokens);			
			remainingWei = remainingWei.sub(tierTokens.div(tier5.rate));
		}		
		
		require(remainingWei == 0);
		
		return nTokens.sub(tokensSold);
	}	

	// fallback function can be used to buy tokens
	function () public payable {
		buyTokens(msg.sender);
	}

	// low level token purchase function
	function buyTokens(address beneficiary) public payable stopInEmergency 
	{
		require(beneficiary != address(0));
		require(validPurchase());

		uint256 weiAmount = msg.value;

		// calculate token amount to be created
		//uint256 tokens = weiAmount.mul(rate);
		uint256 tokens = calculateTokenAmount(weiAmount);

		// Check whether within this ttransaction we will not overflow maximum token amount
		require(tokensSold.add(tokens) <= maximumTokenAmount);

		// update state
		weiRaised = weiRaised.add(weiAmount);
		tokensSold = tokensSold.add(tokens);
		investedAmountOf[beneficiary] = investedAmountOf[beneficiary].add(weiAmount);
		tokenAmountOf[beneficiary] = tokenAmountOf[beneficiary].add(tokens);

		// forward tokens to purchaser
		forwardTokens(beneficiary, tokens);

		LogTokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

		// forward ETH to multisig wallet
		forwardFunds();
	}

	/**
	 * This function just transfers tokens to beneficiary address. 
	 * It should be used for cases when investor buys tokens using other currencies
	 */
	function transferTokens(address beneficiary, uint256 amount) public onlyOwner
	{
		require(beneficiary != address(0));
		require(amount > 0);

		uint256 weiAmount = amount * 1 ether;
		
		tokensSold = tokensSold.add(weiAmount);
		tokenAmountOf[beneficiary] = tokenAmountOf[beneficiary].add(weiAmount);
		
		forwardTokens(beneficiary, weiAmount);
	}
	
		/**
	 * This function just transfers tokens with decimals to beneficiary address. 
	 * It should be used for cases when investor buys tokens using other currencies
	 */
	function transferTokensWei(address beneficiary, uint256 amount) public onlyOwner
	{
		require(beneficiary != address(0));
		require(amount > 0);

		uint256 weiAmount = amount;
		
		tokensSold = tokensSold.add(weiAmount);
		tokenAmountOf[beneficiary] = tokenAmountOf[beneficiary].add(weiAmount);
		
		forwardTokens(beneficiary, weiAmount);
	}
	
	// send ether to the fund collection wallet
	// override to create custom fund forwarding mechanisms
	function forwardFunds() internal {
		multisigWallet.transfer(msg.value);
	}
	
	/**
	 * Forward handelion tokens to purchaset
	 */
	function forwardTokens(address _purchaser, uint256 _amount) internal
	{
		token.transfer(_purchaser, _amount);
	}

	/**
	* Closes crowdsale and changes its state to Finalized. 
	* Warning - this action is undoable!
	*/
	function finalize() public onlyOwner
	{
		finalized = true;
		
		LogCrowdsaleFinalized(goalReached());
	}
	
	/**
	 * Burns all caller tokens
	 *
	 */
	function burnTokensInternal(address _address, uint256 tokenAmount) internal
	{
		require(_address != address(0));
		
		uint256 tokensToBurn = tokenAmount;
		uint256 maxTokens = token.balanceOf(_address);
		
		if (tokensToBurn > maxTokens)
		{
			tokensToBurn = maxTokens;
		}
		
		token.burn(_address, tokensToBurn);
	}
		
	/**
	 * Burns remaining tokens which are not sold during crowdsale
	 */
	function burnRemainingTokens() public onlyOwner
	{
		burnTokensInternal(this, getRemainingTokens());
	}
		
		
	/**
	 * Gets remaining tokens on a contract
	 */
	function getRemainingTokens() public constant returns(uint256)
	{
		return token.getRemainingTokens();
	}
	
	/**
	 * Gets total supply of tokens
	 */
	function getTotalSupply() constant returns (uint256 res)
	{
		return token.getTotalSupply();
	}
	
	/**
	 * Gets amount of token of specific investor
	 */
	function getTokenAmountOf(address investor) constant returns (uint256 res)
	{
		return token.balanceOf(investor);
	}

	// @return true if the transaction can buy tokens
	function validPurchase() internal constant returns (bool) {
		bool withinPeriod = now >= startTime && now <= endTime;
		bool nonZeroPurchase = msg.value != 0;
		bool notFinalized = !finalized;
		bool maxCapNotReached = tokensSold < maximumTokenAmount;

		return withinPeriod && nonZeroPurchase && notFinalized && maxCapNotReached;
	}

	function goalReached() public constant returns (bool)
	{
		return tokensSold >= minimumTokenAmount;
	}

	// @return true if crowdsale event has ended
	function hasEnded() public constant returns (bool) {
		return now > endTime;
	}	
}