pragma solidity ^0.4.18;


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
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) public view returns (uint256);
	function transferFrom(address from, address to, uint256 value) public returns (bool);
	function approve(address spender, uint256 value) public returns (bool);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract DetailedERC20 is ERC20 {
	string public name;
	string public symbol;
	uint8 public decimals;

	function DetailedERC20(string _name, string _symbol, uint8 _decimals) public {
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
	}
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
	 * @dev Increase the amount of tokens that an owner allowed to a spender.
	 *
	 * approve should be called when allowed[_spender] == 0. To increment
	 * allowed value is better to use this function to avoid 2 calls (and wait until
	 * the first transaction is mined)
	 * From MonolithDAO Token.sol
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
	 * approve should be called when allowed[_spender] == 0. To decrement
	 * allowed value is better to use this function to avoid 2 calls (and wait until
	 * the first transaction is mined)
	 * From MonolithDAO Token.sol
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
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
	event Mint(address indexed to, uint256 amount);
	event MintFinished();

	bool public mintingFinished = false;


	modifier canMint() {
		require(!mintingFinished);
		_;
	}

	/**
	 * @dev Function to mint tokens
	 * @param _to The address that will receive the minted tokens.
	 * @param _amount The amount of tokens to mint.
	 * @return A boolean that indicates if the operation was successful.
	 */
	function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
		totalSupply = totalSupply.add(_amount);
		balances[_to] = balances[_to].add(_amount);
		Mint(_to, _amount);
		Transfer(address(0), _to, _amount);
		return true;
	}

	/**
	 * @dev Function to stop minting new tokens.
	 * @return True if the operation was successful.
	 */
	function finishMinting() onlyOwner canMint public returns (bool) {
		mintingFinished = true;
		MintFinished();
		return true;
	}
}


/**
 * @title Capped token
 * @dev Mintable token with a token cap.
 */

contract CappedToken is MintableToken {

	uint256 public cap;

	function CappedToken(uint256 _cap) public {
		require(_cap > 0);
		cap = _cap;
	}

	/**
	 * @dev Function to mint tokens
	 * @param _to The address that will receive the minted tokens.
	 * @param _amount The amount of tokens to mint.
	 * @return A boolean that indicates if the operation was successful.
	 */
	function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
		require(totalSupply.add(_amount) <= cap);

		return super.mint(_to, _amount);
	}

}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

	event Burn(address indexed burner, uint256 value);

	/**
	 * @dev Burns a specific amount of tokens.
	 * @param _value The amount of token to be burned.
	 */
	function burn(uint256 _value) public {
		require(_value <= balances[msg.sender]);
		// no need to require value <= totalSupply, since that would imply the
		// sender's balance is greater than the totalSupply, which *should* be an assertion failure

		address burner = msg.sender;
		balances[burner] = balances[burner].sub(_value);
		totalSupply = totalSupply.sub(_value);
		Burn(burner, _value);
	}
}


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
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
	using SafeMath for uint256;

	// The token being sold
	MintableToken public token;

	// start and end timestamps where investments are allowed (both inclusive)
	uint256 public startTime;
	uint256 public endTime;

	// address where funds are collected
	address public wallet;

	// how many token units a buyer gets per wei
	uint256 public rate;

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


	function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
		require(_startTime >= now);
		require(_endTime >= _startTime);
		require(_rate > 0);
		require(_wallet != address(0));

		token = createTokenContract();
		startTime = _startTime;
		endTime = _endTime;
		rate = _rate;
		wallet = _wallet;
	}

	// creates the token to be sold.
	// override this method to have crowdsale of a specific mintable token.
	function createTokenContract() internal returns (MintableToken) {
		return new MintableToken();
	}


	// fallback function can be used to buy tokens
	function () external payable {
		buyTokens(msg.sender);
	}

	// low level token purchase function
	function buyTokens(address beneficiary) public payable {
		require(beneficiary != address(0));
		require(validPurchase());

		uint256 weiAmount = msg.value;

		// calculate token amount to be created
		uint256 tokens = weiAmount.mul(rate);

		// update state
		weiRaised = weiRaised.add(weiAmount);

		token.mint(beneficiary, tokens);
		TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

		forwardFunds();
	}

	// send ether to the fund collection wallet
	// override to create custom fund forwarding mechanisms
	function forwardFunds() internal {
		wallet.transfer(msg.value);
	}

	// @return true if the transaction can buy tokens
	function validPurchase() internal view returns (bool) {
		bool withinPeriod = now >= startTime && now <= endTime;
		bool nonZeroPurchase = msg.value != 0;
		return withinPeriod && nonZeroPurchase;
	}

	// @return true if crowdsale event has ended
	function hasEnded() public view returns (bool) {
		return now > endTime;
	}


}

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract CappedCrowdsale is Crowdsale {
	using SafeMath for uint256;

	uint256 public cap;

	function CappedCrowdsale(uint256 _cap) public {
		require(_cap > 0);
		cap = _cap;
	}

	// overriding Crowdsale#validPurchase to add extra cap logic
	// @return true if investors can buy at the moment
	function validPurchase() internal view returns (bool) {
		bool withinCap = weiRaised.add(msg.value) <= cap;
		return super.validPurchase() && withinCap;
	}

	// overriding Crowdsale#hasEnded to add cap logic
	// @return true if crowdsale event has ended
	function hasEnded() public view returns (bool) {
		bool capReached = weiRaised >= cap;
		return super.hasEnded() || capReached;
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

contract BftToken is DetailedERC20, CappedToken, BurnableToken, PausableToken {

	CappedCrowdsale public crowdsale;

	function BftToken(
		uint256 _tokenCap,
		uint8 _decimals,
		CappedCrowdsale _crowdsale
	)
	DetailedERC20("BF Token", "BFT", _decimals)
	CappedToken(_tokenCap) public {

		crowdsale = _crowdsale;
	}

	// ----------------------------------------------------------------------------------------------------------------
	// the following is the functionality to upgrade this token smart contract to a new one

	MintableToken public newToken = MintableToken(0x0);
	event LogRedeem(address beneficiary, uint256 amount);

	modifier hasUpgrade() {
		require(newToken != MintableToken(0x0));
		_;
	}

	function upgrade(MintableToken _newToken) onlyOwner public {
		newToken = _newToken;
	}

	// overriding BurnableToken#burn to make disable it for public use
	function burn(uint256 _value) public {
		revert();
		_value = _value; // to silence compiler warning
	}

	function redeem() hasUpgrade public {

		var balance = balanceOf(msg.sender);

		// burn the tokens in this token smart contract
		super.burn(balance);

		// mint tokens in the new token smart contract
		require(newToken.mint(msg.sender, balance));
		LogRedeem(msg.sender, balance);
	}

	// ----------------------------------------------------------------------------------------------------------------
	// we override the token transfer functions to block transfers before startTransfersDate timestamp

	modifier canDoTransfers() {
		require(hasCrowdsaleFinished());
		_;
	}

	function hasCrowdsaleFinished() view public returns(bool) {
		return crowdsale.hasEnded();
	}

	function transfer(address _to, uint256 _value) public canDoTransfers returns (bool) {
		return super.transfer(_to, _value);
	}

	function transferFrom(address _from, address _to, uint256 _value) public canDoTransfers returns (bool) {
		return super.transferFrom(_from, _to, _value);
	}

	function approve(address _spender, uint256 _value) public canDoTransfers returns (bool) {
		return super.approve(_spender, _value);
	}

	function increaseApproval(address _spender, uint _addedValue) public canDoTransfers returns (bool success) {
		return super.increaseApproval(_spender, _addedValue);
	}

	function decreaseApproval(address _spender, uint _subtractedValue) public canDoTransfers returns (bool success) {
		return super.decreaseApproval(_spender, _subtractedValue);
	}

	// ----------------------------------------------------------------------------------------------------------------
	// functionality to change the token ticker - in case of conflict

	function changeSymbol(string _symbol) onlyOwner public {
		symbol = _symbol;
	}

	function changeName(string _name) onlyOwner public {
		name = _name;
	}
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

/**
 * @title TokenTimelock
 * @dev TokenTimelock is a token holder contract that will allow a
 * beneficiary to extract the tokens after a given release time
 */
contract TokenTimelock {
  using SafeERC20 for ERC20Basic;

  // ERC20 basic token contract being held
  ERC20Basic public token;

  // beneficiary of tokens after they are released
  address public beneficiary;

  // timestamp when token release is enabled
  uint256 public releaseTime;

  function TokenTimelock(ERC20Basic _token, address _beneficiary, uint256 _releaseTime) public {
    require(_releaseTime > now);
    token = _token;
    beneficiary = _beneficiary;
    releaseTime = _releaseTime;
  }

  /**
   * @notice Transfers tokens held by timelock to beneficiary.
   */
  function release() public {
    require(now >= releaseTime);

    uint256 amount = token.balanceOf(this);
    require(amount > 0);

    token.safeTransfer(beneficiary, amount);
  }
}

contract BftCrowdsale is CappedCrowdsale, Pausable {

	uint8 public constant tokenDecimals = 18;
	uint256 public constant etherInWei = 10**uint256(tokenDecimals);
	uint256 public constant tokenCap = 1000000000 * etherInWei;

	uint256 public SALE_CAP_USD;
	uint256 public BUYER_CAP_LOW_USD;
	uint256 public BUYER_CAP_HIGH_USD;

	uint256 public constant PRICE_MULTIPLIER = 100;
	uint256 public constant TOKENS_PER_USD = 10;

	uint256 public etherPrice = PRICE_MULTIPLIER;
	uint256 public buyerCapLowEther = etherInWei;
	uint256 public buyerCapHighEther = etherInWei;
	uint256 public saleHardCapEther = etherInWei;
	uint256 public mintRate = TOKENS_PER_USD;

	address public preSaleBfPlatform;
	address public company;
	address public rewardPool;
	address public shareholders;
	address public tokenSaleCosts;

	// smart contracts that will lock tokens for a pre-defined time
	TokenTimelock public companyHolding2y;
	TokenTimelock public shareholdersHolding1y;

	// address permissioned to whitelist public sale addresses
	mapping(address => bool) whitelist;

	mapping(address => bool) operators;
	event LogOperatorAdd(address newOperator);
	event LogOperatorRem(address newOperator);

	modifier onlyOperator() {
		require(operators[msg.sender]);
		_;
	}

	modifier onlyWhitelisted(address _address) {
		require(whitelist[_address]);
		_;
	}

	function BftCrowdsale(
		uint256 _startTime,
		uint256 _endTime,
		uint256 _etherPrice,
		address _wallet,

	// addresses with pre-minted tokens
		address _preSaleBfPlatform,
		address _company,
		address _rewardPool,
		address _shareholders,
		address _tokenSaleCosts,

	// owner of the whitelist function
		address _operator,
		address _admin,

		uint256 _saleCapUsd,
		uint256 _buyerCapLowUsd,
		uint256 _buyerCapHighUsd
	)
	CappedCrowdsale(saleHardCapEther)
	Crowdsale(_startTime, _endTime, mintRate, _wallet) public {

		require(_preSaleBfPlatform != address(0x0));
		require(_company != address(0x0));
		require(_rewardPool != address(0x0));
		require(_shareholders != address(0x0));
		require(_tokenSaleCosts != address(0x0));
		require(_operator != address(0x0));

		SALE_CAP_USD = _saleCapUsd;
		BUYER_CAP_LOW_USD = _buyerCapLowUsd;
		BUYER_CAP_HIGH_USD = _buyerCapHighUsd;

		preSaleBfPlatform = _preSaleBfPlatform;
		company = _company;
		rewardPool = _rewardPool;
		shareholders = _shareholders;
		tokenSaleCosts = _tokenSaleCosts;

		addOperator(_operator);
		updateEtherPrice(_etherPrice);
		createHoldings();
		preMintTokens();

		// transfer ownership the the admin multi-sig
		transferOwnership(_admin);
	}

	function updateEtherPrice(uint256 _price) onlyOwner public {
		require(_price > 0);
		require(now < startTime);

		etherPrice = _price;
		buyerCapLowEther = BUYER_CAP_LOW_USD.mul(etherInWei).mul(PRICE_MULTIPLIER).div(etherPrice);
		buyerCapHighEther = BUYER_CAP_HIGH_USD.mul(etherInWei).mul(PRICE_MULTIPLIER).div(etherPrice);
		saleHardCapEther = SALE_CAP_USD.mul(etherInWei).mul(PRICE_MULTIPLIER).div(etherPrice);
		mintRate = TOKENS_PER_USD.mul(etherPrice).div(PRICE_MULTIPLIER);

		// update vars on parent contracts
		cap = saleHardCapEther;
		rate = mintRate;
	}

	function createHoldings() internal {
		companyHolding2y = new TokenTimelock(token, company, startTime+2 years);
		shareholdersHolding1y = new TokenTimelock(token, shareholders, startTime+1 years);
	}

	function preMintTokens() internal {
		token.mint(preSaleBfPlatform, 300000000 * etherInWei);
		token.mint(companyHolding2y, 300000000 * etherInWei);
		token.mint(rewardPool, 200000000 * etherInWei);
		token.mint(shareholdersHolding1y, 100000000 * etherInWei);
		token.mint(tokenSaleCosts, 70000000 * etherInWei);
	}

	function checkSaleEnded() internal {
		// if no further purchases are possible due to lower buyer cap
		if(saleHardCapEther.sub(weiRaised) < buyerCapLowEther) {
			token.mint(rewardPool, tokenCap.sub(token.totalSupply()));
		}
	}

	// overriding CappedCrowdsale#validPurchase to add extra low/high limits logic
	// @return true if investors can buy at the moment
	function validPurchase() whenNotPaused
	internal view returns (bool) {
		bool aboveLowBuyerCap = (msg.value >= buyerCapLowEther);
		bool underMaxBuyerCap = (msg.value <= buyerCapHighEther);
		return super.validPurchase() && aboveLowBuyerCap && underMaxBuyerCap;
	}

	// overriding Crowdsale#hasEnded to add token cap logic
	// @return true if crowdsale event has ended
	function hasEnded() public view returns (bool) {
		bool tokenCapReached = token.totalSupply() == tokenCap;
		return super.hasEnded() || tokenCapReached;
	}

	function buyTokens(address beneficiary)
	onlyWhitelisted(beneficiary)
	whenNotPaused
	public payable {
		require(token.balanceOf(beneficiary)==0);
		super.buyTokens(beneficiary);
		checkSaleEnded();
	}

	// creates the token to be sold.
	// override this method to have crowdsale of a specific mintable token.
	function createTokenContract() internal returns (MintableToken) {
		return new BftToken(tokenCap, tokenDecimals, this);
	}

	function addWhitelist(address[] beneficiaries) onlyOperator public {
		for (uint i = 0; i < beneficiaries.length; i++) {
			whitelist[beneficiaries[i]] = true;
		}
	}

	function remWhitelist(address[] beneficiaries) onlyOperator public {
		for (uint i = 0; i < beneficiaries.length; i++) {
			whitelist[beneficiaries[i]] = false;
		}
	}

	function isWhitelisted(address beneficiary) view public returns(bool) {
		return whitelist[beneficiary];
	}

	function addOperator(address _operator) onlyOwner public {
		operators[_operator] = true;
		LogOperatorAdd(_operator);
	}

	function remOperator(address _operator) onlyOwner public {
		operators[_operator] = false;
		LogOperatorAdd(_operator);
	}

	function isOperator(address _operator) view public returns(bool) {
		return operators[_operator];
	}

	function transferTokenOwnership(address _newOwner) onlyOwner public {
		// only allow transfer at the end of the sale
		require(hasEnded());
		// stop the minting process on the token as we only allow the crowdsale to mint
		token.finishMinting();
		token.transferOwnership(_newOwner);
	}
}