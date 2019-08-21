pragma solidity ^0.4.24;

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
  constructor() public {
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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint256 public totalSupply;

  /**
   * @param _owner The address from which the balance will be retrieved
   * @return The balance
   */
  function balanceOf(address _owner) public constant returns (uint256 balance);

  /**
   * @notice send `_value` token to `_to` from `msg.sender`
   * @param _to The address of the recipient
   * @param _value The amount of token to be transferred
   * @return Whether the transfer was successful or not
   */
  function transfer(address _to, uint256 _value) public returns (bool success);

  /**
   * @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
   * @param _from The address of the sender
   * @param _to The address of the recipient
   * @param _value The amount of token to be transferred
   * @return Whether the transfer was successful or not
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

  /**
   * @notice `msg.sender` approves `_spender` to spend `_value` tokens
   * @param _spender The address of the account able to transfer the tokens
   * @param _value The amount of tokens to be approved for transfer
   * @return Whether the approval was successful or not
   */
  function approve(address _spender, uint256 _value) public returns (bool success);

  /**
   * @param _owner The address of the account owning tokens
   * @param _spender The address of the account able to transfer the tokens
   * @return Amount of remaining tokens allowed to spent
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

  /**
   * MUST trigger when tokens are transferred, including zero value transfers.
   */
  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  /**
   * MUST trigger on any successful call to approve(address _spender, uint256 _value)
   */
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

library SafeMath {
	/**
	* @notice Adds two numbers, throws on overflow.
	*/
	function add(
		uint256 a,
		uint256 b
	)
		internal pure returns (uint256 c)
	{
		c = a + b;
		assert(c >= a);
		return c;
	}

	/**
	* @notice Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
	*/
	function sub(
		uint256 a,
		uint256 b
	)
		internal pure returns (uint256)
	{
		assert(b <= a);
		return a - b;
	}


	/**
	* @notice Multiplies two numbers, throws on overflow.
	*/
	function mul(
		uint256 a,
		uint256 b
	)
		internal pure returns (uint256 c)
	{
		if (a == 0) {
				return 0;
		}
		c = a * b;
		assert(c / a == b);
		return c;
	}

	/**
	* @dev Integer division of two numbers, truncating the quotient.
	*/
	function div(
		uint256 a,
		uint256 b
	)
		internal pure returns (uint256)
	{
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		// uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return a / b;
	}
}

contract F2KToken is ERC20, Ownable {
	// Adding safe calculation methods to uint256
	using SafeMath for uint256;

	// Defining balances mapping (ERC20)
	mapping(address => uint256) balances;

	// Defining allowances mapping (ERC20)
	mapping(address => mapping(address => uint256)) allowed;

	// Defining addresses allowed to bypass global freeze
	mapping(address => bool) public freezeBypassing;

	// Defining addresses that have custom lockups periods
	mapping(address => uint256) public lockupExpirations;

	// Token Symbol
	string public constant symbol = "F2K";

	// Token Name
	string public constant name = "Farm2Kitchen Token";

	// Token Decimals
	uint8 public constant decimals = 2;

	// global freeze one-way toggle
	bool public tradingLive;

	// Total supply of token
	uint256 public totalSupply;

    constructor() public {
        totalSupply = 280000000 * (10 ** uint256(decimals));
        balances[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

	/**
	 * @notice Event for Lockup period applied to address
	 * @param owner Specific lockup address target
	 * @param until Timestamp when lockup end (seconds since epoch)
	 */
	event LockupApplied(
		address indexed owner,
		uint256 until
	);
	
	/**
	 * @notice distribute tokens to an address
	 * @param to Who will receive the token
	 * @param tokenAmount How much token will be sent
	 */
	function distribute(
			address to,
			uint256 tokenAmount
	)
			public onlyOwner
	{
			require(tokenAmount > 0);
			require(tokenAmount <= balances[msg.sender]);

			balances[msg.sender] = balances[msg.sender].sub(tokenAmount);
			balances[to] = balances[to].add(tokenAmount);

			emit Transfer(owner, to, tokenAmount);
	}

	/**
	 * @notice Prevents the given wallet to transfer its token for the given duration.
	 *      This methods resets the lock duration if one is already in place.
	 * @param wallet The wallet address to lock
	 * @param duration How much time is the token locked from now (in sec)
	 */
	function lockup(
			address wallet,
			uint256 duration
	)
			public onlyOwner
	{
			uint256 lockupExpiration = duration.add(now);
			lockupExpirations[wallet] = lockupExpiration;
			emit LockupApplied(wallet, lockupExpiration);
	}

	/**
	 * @notice choose if an address is allowed to bypass the global freeze
	 * @param to Target of the freeze bypass status update
	 * @param status New status (if true will bypass)
	 */
	function setBypassStatus(
			address to,
			bool status
	)
			public onlyOwner
	{
			freezeBypassing[to] = status;
	}

	/**
	 * @notice One-way toggle to allow trading (remove global freeze)
	 * @param status New status (if true will bypass)
	 */
	function setTrading(
			bool status
	) 
		public onlyOwner 
	{
			tradingLive = status;
	}

	/**
	 * @notice Modifier that checks if the conditions are met for a token to be
	 * tradable. To be so, it must :
	 *  - Global Freeze must be removed, or, "from" must be allowed to bypass it
	 *  - "from" must not be in a custom lockup period
	 * @param from Who to check the status
	 */
	modifier tradable(address from) {
			require(
					(tradingLive || freezeBypassing[from]) && //solium-disable-line indentation
					(lockupExpirations[from] <= now)
			);
			_;
	}

	/**
	 * @notice Return the total supply of the token
	 * @dev This function is part of the ERC20 standard 
	 * @return {"totalSupply": "The token supply"}
	 */
	function totalSupply() public view returns (uint256 supply) {
			return totalSupply;
	}

	/**
	 * @notice Get the token balance of `owner`
	 * @dev This function is part of the ERC20 standard
	 * @param owner The wallet to get the balance of
	 * @return {"balance": "The balance of `owner`"}
	 */
	function balanceOf(
			address owner
	)
			public view returns (uint256 balance)
	{
			return balances[owner];
	}

	/**
	 * @notice Transfers `amount` from msg.sender to `destination`
	 * @dev This function is part of the ERC20 standard
	 * @param to The address that receives the tokens
	 * @param tokenAmount Token amount to transfer
	 * @return {"success": "If the operation completed successfuly"}
	 */
	function transfer(
			address to,
			uint256 tokenAmount
	)
			public tradable(msg.sender) returns (bool success)
	{
			require(tokenAmount > 0);
			require(tokenAmount <= balances[msg.sender]);

			balances[msg.sender] = balances[msg.sender].sub(tokenAmount);
			balances[to] = balances[to].add(tokenAmount);
			emit Transfer(msg.sender, to, tokenAmount);
			return true;
	}

	/**
	 * @notice Transfer tokens from an address to another one
	 * through an allowance made before
	 * @dev This function is part of the ERC20 standard
	 * @param from The address that sends the tokens
	 * @param to The address that receives the tokens
	 * @param tokenAmount Token amount to transfer
	 * @return {"success": "If the operation completed successfuly"}
	 */
	function transferFrom(
			address from,
			address to,
			uint256 tokenAmount
	)
			public tradable(from) returns (bool success)
	{
			require(tokenAmount > 0);
			require(tokenAmount <= balances[from]);
			require(tokenAmount <= allowed[from][msg.sender]);
			
			balances[from] = balances[from].sub(tokenAmount);
			allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokenAmount);
			balances[to] = balances[to].add(tokenAmount);
			
			emit Transfer(from, to, tokenAmount);
			return true;
	}
	
	/**
	 * @notice Approve an address to send `tokenAmount` tokens to `msg.sender` (make an allowance)
	 * @dev This function is part of the ERC20 standard
	 * @param spender The allowed address
	 * @param tokenAmount The maximum amount allowed to spend
	 * @return {"success": "If the operation completed successfuly"}
	 */
	function approve(
			address spender,
			uint256 tokenAmount
	)
			public returns (bool success)
	{
			allowed[msg.sender][spender] = tokenAmount;
			emit Approval(msg.sender, spender, tokenAmount);
			return true;
	}

	/**
	* @notice Increase the amount of tokens that an owner allowed to a spender.
	* To increment allowed value it is better to use this function to avoid double withdrawal attack. 
	* @param spender The address which will spend the funds.
	* @param tokenAmount The amount of tokens to increase the allowance by.
	*/
	function increaseApproval(
			address spender,
			uint tokenAmount
	)
			public returns (bool)
	{
			allowed[msg.sender][spender] = (allowed[msg.sender][spender].add(tokenAmount));
			emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
			
			return true;
	}

	/**
	* @notice Decrease the amount of tokens that an owner allowed to a spender.
	* To decrease the allowed value it is better to use this function to avoid double withdrawal attack. 
	* @param spender The address which will spend the funds.
	* @param tokenAmount The amount of tokens to decrease the allowance by.
	*/
	function decreaseApproval(
			address spender,
			uint tokenAmount
	)
			public returns (bool)
	{
			uint oldValue = allowed[msg.sender][spender];
			if (tokenAmount > oldValue) {
				allowed[msg.sender][spender] = 0;
			} else {
				allowed[msg.sender][spender] = oldValue.sub(tokenAmount);
			}
			emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
			
			return true;
	}
	
	/**
	 * @notice Get the remaining allowance for a spender on a given address
	 * @dev This function is part of the ERC20 standard
	 * @param tokenOwner The address that owns the tokens
	 * @param spender The spender
	 * @return {"remaining": "The amount of tokens remaining in the allowance"}
	 */
	function allowance(
			address tokenOwner,
			address spender
	)
			public view returns (uint256 remaining)
	{
			return allowed[tokenOwner][spender];
	}

	function burn(
			uint tokenAmount
	) 
			public onlyOwner returns (bool)
	{
		require(balances[msg.sender] >= tokenAmount);
		balances[msg.sender] = balances[msg.sender].sub(tokenAmount);
		totalSupply = totalSupply.sub(tokenAmount);
		return true;
	}

	/**
	 * @notice Permits to withdraw any ERC20 tokens that have been mistakingly sent to this contract
	 * @param tokenAddress The received ERC20 token address
	 * @param tokenAmount The amount of ERC20 tokens to withdraw from this contract
	 * @return {"success": "If the operation completed successfuly"}
	 */
	function withdrawERC20Token(
			address tokenAddress,
			uint256 tokenAmount
	)
			public onlyOwner returns (bool success)
	{
			return ERC20(tokenAddress).transfer(owner, tokenAmount);
	}

}