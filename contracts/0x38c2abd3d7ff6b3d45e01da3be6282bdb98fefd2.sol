pragma solidity ^0.4.18;

/**
 * @title Implementation of token that conforms the ERC-20 Token Standard
 */
contract Restriction {
	address internal owner = msg.sender;
	mapping(address => bool) internal granted;

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
	/**
	* @notice Change the owner of the contract
	* @param _owner New owner
	*/
	function changeOwner(address _owner) external onlyOwner {
		require(_owner != address(0) && _owner != owner);
		owner = _owner;
		ChangeOwner(owner);
	}
	event ChangeOwner(address indexed _owner);
} 

/**
 * @dev Interface of contracts that will receive tokens
 */
interface TokenReceiver {
    function tokenFallback(address, uint256, bytes) external;
}

/**
 * @dev Basic token
 */
contract BasicToken is Restriction {
	string public name;
	string public symbol;
	uint8 public decimals = 0;
	uint256 public totalSupply = 0;

	mapping(address => uint256) private balances;

	event Transfer(address indexed _from, address indexed _to, uint256 _value);	

	/**
	* @dev Construct a token.
	* @param _name The name of the token.
	* @param _symbol The symbol of the token.
	* @param _decimals The decimals of the token.
	* @param _supply The initial supply of the token.
	*/
	function BasicToken(string _name, string _symbol, uint8 _decimals, uint256 _supply) public {
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
		_mintTokens(_supply);
	}
	/**
	* @dev Get the balance of the given holder.
	* @param _holder The address of the token holder to query the the balance of.
	* @return The token amount owned by the holder.
	*/
	function balanceOf(address _holder) external view returns (uint256) {
		return balances[_holder];
	}
	/**
	* @dev Transfer tokens to a specified holder.
	* @param _to The address to transfer to.
	* @param _amount The amount to be transferred.
	* @return returns true on success or throw on failure
	*/
	function transfer(address _to, uint256 _amount) external returns (bool) {
		return _transfer(msg.sender, _to, _amount, "");
	}
	/**
	* @dev Transfer tokens to a specified holder.
	* @param _to The address to transfer to.
	* @param _amount The amount to be transferred.
	* @param _data The data that is attached to this transaction.
	* @return returns true on success or throw on failure
	*/
	function transfer(address _to, uint256 _amount, bytes _data) external returns (bool) {
		return _transfer(msg.sender, _to, _amount, _data);
	}
	/**
	* @dev Transfer tokens from one address to another
	* @param _from The address from which you want to transfer tokens
	* @param _to The address to which you want to transfer tokens
	* @param _amount The amount of tokens to be transferred
	* @param _data The data that is attached to this transaction.
	* @return returns true on success or throw on failure
	*/
	function _transfer(address _from, address _to, uint256 _amount, bytes _data) internal returns (bool) {
		require(_to != address(0)
			&& _to != address(this)
			&& _from != address(0)
			&& _from != _to
			&& _amount > 0
			&& balances[_from] >= _amount
			&& balances[_to] + _amount > balances[_to]
		);
		balances[_from] -= _amount;
		balances[_to] += _amount;
		uint size;
		assembly {
			size := extcodesize(_to)
		}
		if(size > 0){
			TokenReceiver(_to).tokenFallback(msg.sender, _amount, _data);
		}
		Transfer(_from, _to, _amount);
		return true;
	}
	/**
	* @dev Mint tokens.
	* @param _amount The amount of tokens to mint.
	* @return returns true on success or throw on failure
	*/
	function _mintTokens(uint256 _amount) internal onlyOwner returns (bool success){
		require(totalSupply + _amount > totalSupply);
		totalSupply += _amount;
		balances[msg.sender] += _amount;
		Transfer(address(0), msg.sender, _amount);
		return true;
	}
	/**
	* @dev Burn tokens.
	* @param _amount The amount of tokens to burn.
	* @return returns true on success or throw on failure
	*/
	function _burnTokens(uint256 _amount) internal returns (bool success){
		require(balances[msg.sender] > _amount);
		totalSupply -= _amount;
		balances[owner] -= _amount;
		Transfer(msg.sender, address(0), _amount);
		return true;
	}
}

contract ERC20Compatible {
	mapping(address => mapping(address => uint256)) private allowed;

	event Approval(address indexed _owner, address indexed _spender, uint256 _value);	
	function _transfer(address _from, address _to, uint256 _amount, bytes _data) internal returns (bool success);

	/**
	* @dev Get the amount of tokens that a holder allowed other holder to spend.
	* @param _owner The address of the owner.
	* @param _spender The address of the spender.
	* @return amount The amount of tokens still available for the spender.
	*/
	function allowance(address _owner, address _spender) external constant returns (uint256 amount) {
		return allowed[_owner][_spender];
	}
	/**
	* @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
	* @param _spender The address of the holder who will spend the tokens of the msg.sender.
	* @param _amount The amount of tokens allow to be spent.
	* @return returns true on success or throw on failure
	*/
	function approve(address _spender, uint256 _amount) external returns (bool success) {
		require( _spender != address(0) 
			&& _spender != msg.sender 
			&& (_amount == 0 || allowed[msg.sender][_spender] == 0)
		);
		allowed[msg.sender][_spender] = _amount;
		Approval(msg.sender, _spender, _amount);
		return true;
	}
	/**
	* @dev Transfer tokens from one holder to the other holder.
	* @param _from The address from which the tokens will be transfered.
	* @param _to The address to which the tokens will be transfered.
	* @param _amount The amount of tokens to be transferred.
	* @return returns true on success or throw on failure
	*/
	function transferFrom(address _from, address _to, uint256 _amount) external returns (bool success) {
		require(allowed[_from][msg.sender] >= _amount);
		allowed[_from][msg.sender] -= _amount;
		return _transfer(_from, _to, _amount, "");
	}
}

contract Regulatable is Restriction {
	function _mintTokens(uint256 _amount) internal onlyOwner returns (bool success);
	function _burnTokens(uint256 _amount) internal returns (bool success);
	/**
	* @notice Mint more tokens
	* @param _amount The amount of token to be minted
	* @return returns true on success or throw on failure
	*/
	function mintTokens(uint256 _amount) external onlyOwner returns (bool){
		return _mintTokens(_amount);
	}
	/**
	* @notice Burn some tokens
	* @param _amount The amount of token to be burnt
	* @return returns true on success or throw on failure
	*/
	function burnTokens(uint256 _amount) external returns (bool){
		return _burnTokens(_amount);
	}
}

contract Token is ERC20Compatible, Regulatable, BasicToken {
	string private constant NAME = "Crypto USD";
	string private constant SYMBOL = "USDc";
	uint8 private constant DECIMALS = 2;
	uint256 private constant SUPPLY = 201205110 * uint256(10) ** DECIMALS;
	
	function Token() public 
		BasicToken(NAME, SYMBOL, DECIMALS, SUPPLY) {
	}
}