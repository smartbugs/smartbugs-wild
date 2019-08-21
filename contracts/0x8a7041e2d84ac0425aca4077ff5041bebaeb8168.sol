pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

	/**
	* @dev Multiplies two numbers, throws on overflow.
	*/
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}

	/**
	* @dev Integer division of two numbers, truncating the quotient.
	*/
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

	/**
	* @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
	*/
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	/**
	* @dev Adds two numbers, throws on overflow.
	*/
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
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
	function totalSupply() public view returns (uint256);
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


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
	using SafeMath for uint256;

	mapping(address => uint256) balances;

	uint256 totalSupply_;

	/**
	* @dev total number of tokens in existence
	*/
	function totalSupply() public view returns (uint256) {
		return totalSupply_;
	}

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
 * @title Sebastian
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
contract SebastianToken is StandardToken, Ownable {
	using SafeMath for uint256;

	string public name = "Sebastian";
	string public symbol = "SEB";
	uint256 public decimals = 5;

	uint256 public totalSupply = 1000000000 * (10 ** uint256(decimals));

	/**
	 * @dev Constructor that gives msg.sender all of existing tokens.
	 */
	function SebastianToken(string _name, string _symbol, uint256 _decimals, uint256 _totalSupply) public {
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
		totalSupply = _totalSupply;

		totalSupply_ = _totalSupply;
		balances[msg.sender] = totalSupply;
	}

	/**
	 * @dev if ether is sent to this address, send it back.
	 */
	function () public payable {
		revert();
	}
}

/**
 * @title SebastianTokenSale
 * @dev ICO Contract
 */
contract SebastianTokenSale is Ownable {

	using SafeMath for uint256;

	// The token being sold, this holds reference to main token contract
	SebastianToken public token;

	// timestamp when sale starts
	uint256 public startingTimestamp = 1518696000;

	// timestamp when sale ends
	uint256 public endingTimestamp = 1521115200;

	// how many token units a buyer gets per ether
	uint256 public tokenPriceInEth = 0.0001 ether;

	// amount of token to be sold on sale
	uint256 public tokensForSale = 400000000 * 1E5;

	// amount of token sold so far
	uint256 public totalTokenSold;

	// amount of ether raised in sale
	uint256 public totalEtherRaised;

	// ether raised per wallet
	mapping(address => uint256) public etherRaisedPerWallet;

	// wallet which will receive the ether funding
	address public wallet;

	// is contract close and ended
	bool internal isClose = false;

	// wallet changed
	event WalletChange(address _wallet, uint256 _timestamp);

	// token purchase event
	event TokenPurchase(address indexed _purchaser, address indexed _beneficiary, uint256 _value, uint256 _amount, uint256 _timestamp);

	// manual transfer by owner for external purchase
	event TransferManual(address indexed _from, address indexed _to, uint256 _value, string _message);

	/**
	 * @dev Constructor that initializes token contract with token address in parameter
	 *
	 * @param _token Address of Token Contract
	 * @param _startingTimestamp Start time of Sale in Timestamp.
	 * @param _endingTimestamp End time of Sale in Timestamp.
	 * @param _tokensPerEth Number of Tokens to convert per 1 ETH.
	 * @param _tokensForSale Number of Tokens available for sale.
	 * @param _wallet Backup Wallet Address where funds should be transfered when contract is closed or Owner wants to Withdraw.
	 *
	 */
	function SebastianTokenSale(address _token, uint256 _startingTimestamp, uint256 _endingTimestamp, uint256 _tokensPerEth, uint256 _tokensForSale, address _wallet) public {
		// set token
		token = SebastianToken(_token);

		startingTimestamp = _startingTimestamp;
		endingTimestamp = _endingTimestamp;
		tokenPriceInEth =  1E18 / _tokensPerEth; // Calculating Price of 1 Token in ETH 
		tokensForSale = _tokensForSale;

		// set wallet
		wallet = _wallet;
	}

	/**
	 * @dev Function that validates if the purchase is valid by verifying the parameters
	 *
	 * @param value Amount of ethers sent
	 * @param amount Total number of tokens user is trying to buy.
	 *
	 * @return checks various conditions and returns the bool result indicating validity.
	 */
	function isValidPurchase(uint256 value, uint256 amount) internal constant returns (bool) {
		// check if timestamp is falling in the range
		bool validTimestamp = startingTimestamp <= block.timestamp && endingTimestamp >= block.timestamp;

		// check if value of the ether is valid
		bool validValue = value != 0;

		// check if rate of the token is clearly defined
		bool validRate = tokenPriceInEth > 0;

		// check if the tokens available in contract for sale
		bool validAmount = tokensForSale.sub(totalTokenSold) >= amount && amount > 0;

		// validate if all conditions are met
		return validTimestamp && validValue && validRate && validAmount && !isClose;
	}

	
	/**
	 * @dev Function that accepts ether value and returns the token amount
	 *
	 * @param value Amount of ethers sent
	 *
	 * @return checks various conditions and returns the bool result indicating validity.
	 */
	function calculate(uint256 value) public constant returns (uint256) {
		uint256 tokenDecimals = token.decimals();
		uint256 tokens = value.mul(10 ** tokenDecimals).div(tokenPriceInEth);
		return tokens;
	}
	
	/**
	 * @dev Default fallback method which will be called when any ethers are sent to contract
	 */
	function() public payable {
		buyTokens(msg.sender);
	}

	/**
	 * @dev Function that is called either externally or by default payable method
	 *
	 * @param beneficiary who should receive tokens
	 */
	function buyTokens(address beneficiary) public payable {
		require(beneficiary != address(0));

		// amount of ethers sent
		uint256 value = msg.value;

		// calculate token amount from the ethers sent
		uint256 tokens = calculate(value);

		// validate the purchase
		require(isValidPurchase(value , tokens));

		// update the state to log the sold tokens and raised ethers.
		totalTokenSold = totalTokenSold.add(tokens);
		totalEtherRaised = totalEtherRaised.add(value);
		etherRaisedPerWallet[msg.sender] = etherRaisedPerWallet[msg.sender].add(value);

		// transfer tokens from contract balance to beneficiary account. calling ERC223 method
		token.transfer(beneficiary, tokens);
		
		// log event for token purchase
		TokenPurchase(msg.sender, beneficiary, value, tokens, now);
	}

	/**
	* @dev transmit token for a specified address. 
	* This is owner only method and should be called using web3.js if someone is trying to buy token using bitcoin or any other altcoin.
	* 
	* @param _to The address to transmit to.
	* @param _value The amount to be transferred.
	* @param _message message to log after transfer.
	*/
	function transferManual(address _to, uint256 _value, string _message) onlyOwner public returns (bool) {
		require(_to != address(0));

		// transfer tokens manually from contract balance
		token.transfer(_to , _value);
		TransferManual(msg.sender, _to, _value, _message);
		return true;
	}

	/**
	* @dev withdraw funds 
	* This will set the withdrawal wallet
	* 
	* @param _wallet The address to transmit to.
	*/	
	function setWallet(address _wallet) onlyOwner public returns(bool) {
		// set wallet 
		wallet = _wallet;
		WalletChange(_wallet , now);
		return true;
	}

	/**
	* @dev Method called by owner of contract to withdraw funds
	*/
	function withdraw() onlyOwner public {
		wallet.transfer(this.balance);
	}

	/**
	* @dev close contract 
	* This will send remaining token balance to owner
	* This will distribute available funds across team members
	*/	
	function close() onlyOwner public {
		// send remaining tokens back to owner.
		uint256 tokens = token.balanceOf(this); 
		token.transfer(owner , tokens);

		// withdraw funds 
		withdraw();

		// mark the flag to indicate closure of the contract
		isClose = true;
	}
}