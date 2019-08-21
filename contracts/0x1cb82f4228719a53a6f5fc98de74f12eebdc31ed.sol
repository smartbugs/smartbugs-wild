pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// 'Fusionchain' Token contract
//
// Deployed to : 0xAfa5b5e0C7cd2E1882e710B63EAb0D6f8cbDbf43
// Symbol      : FIX	
// Name        : Fusionchain
// Total supply: 7,300,000,000 FIX
// Decimals    : 7
//
// by Fusionchain Developer Team --- Oct 31,2018.
//
// All-in-One the decentralized financial network.

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------

contract FusionchainSafeMath 
{
	function safeAdd(uint a, uint b) public pure returns (uint c) 
	{
		c = a + b;
		require(c >= a);
	}

	function safeSub(uint a, uint b) public pure returns (uint c) 
	{
		require(b <= a);
		c = a - b;
	}

	function safeMul(uint a, uint b) public pure returns (uint c) 
	{
		c = a * b;
		require(a == 0 || c / a == b);
	}
	
	function safeDiv(uint a, uint b) public pure returns (uint c) 
	{
		require(b > 0);
		c = a / b;
	}
}


// ----------------------------------------------------------------------------
//  Interface
// ----------------------------------------------------------------------------

contract FusionchainInterface 
{
	function totalSupply() public constant returns (uint);
	function balanceOf(address tokenOwner) public constant returns (uint balance);
	function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
	function transfer(address to, uint tokens) public returns (bool success);
	function approve(address spender, uint tokens) public returns (bool success);
	function transferFrom(address from, address to, uint tokens) public returns (bool success);
	function burn(uint _value) returns (bool success);

	// This generates a public event on the blockchain that will notify clients
	event Transfer(address indexed from, address indexed to, uint tokens);

	// This generates a public event on the blockchain that will notify clients
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}


// ----------------------------------------------------------------------------
//
// Contract function to receive approval and execute function in one call
//
// ----------------------------------------------------------------------------

contract FusionchainApproveAndCallFallBack 
{
	function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}

// ----------------------------------------------------------------------------
// FusionchainOwned contract
// ----------------------------------------------------------------------------

contract FusionchainOwned 
{
	address public owner;
	address public newOwner;

	event OwnershipTransferred(address indexed _from, address indexed _to);

	constructor() public 
	{
		owner = msg.sender;
	}

	modifier onlyOwner 
	{
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address _newOwner) public onlyOwner 
	{
		newOwner = _newOwner;
	}

	function acceptOwnership() public 
	{
		require(msg.sender == newOwner);
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
		newOwner = address(0);
	}
}

// ----------------------------------------------------------------------------
// Fusionchain ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------

contract Fusionchain is FusionchainInterface, FusionchainOwned, FusionchainSafeMath
 {
	// Public variables of the token
	string public symbol; 	
	string public name;  	
	uint   public decimals;  
	uint   public _totalSupply;

	// This creates an array with all balances
	mapping(address => uint) balances;
	// Owner of account approves the transfer of an amount to another account    
	mapping(address => mapping(address => uint)) allowed;


	/**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
    */

	function Fusionchain () public 
	{
		symbol = "FIX";       //Token symbol
		name = "Fusionchain";    //Token name
		decimals = 7;        // 7 is the most common number of decimal places
		_totalSupply = 7300000000*10**decimals; // 7,300,000,000 FIX, 7 decimal places 
		balances[0xAfa5b5e0C7cd2E1882e710B63EAb0D6f8cbDbf43] = _totalSupply;
		
		emit Transfer(address(0), 0xAfa5b5e0C7cd2E1882e710B63EAb0D6f8cbDbf43, _totalSupply);
	}

	// ------------------------------------------------------------------------
	// Total supply
	// ------------------------------------------------------------------------

	function totalSupply() public constant returns (uint) 
	{
		return _totalSupply  - balances[address(0)];
	}

	// ------------------------------------------------------------------------
	// Get the token balance for account tokenOwner
	// ------------------------------------------------------------------------

	function balanceOf(address _tokenOwner) public constant returns (uint balance) 
	{
		return balances[_tokenOwner];
	}

	/**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
    */

	function transfer(address _to, uint _value) public returns (bool success)
	{
		balances[msg.sender] = safeSub(balances[msg.sender], _value);
		balances[_to] = safeAdd(balances[_to], _value);

		emit Transfer(msg.sender, _to, _value);

		return true;
	}

	/**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
    */

	function approve(address _spender, uint _value) public returns (bool success) 
	{
		allowed[msg.sender][_spender] = _value;
		
		emit Approval(msg.sender, _spender, _value);

		return true;
	}


	/**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
    */

	function transferFrom(address _from, address _to, uint _value) public returns (bool success) 
	{
		balances[_from] = safeSub(balances[_from], _value);
		allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
		balances[_to] = safeAdd(balances[_to], _value);
		
		emit Transfer(_from, _to, _value);

		return true;
	}

	// ------------------------------------------------------------------------
	// Returns the amount of tokens approved by the owner that can be
	// transferred to the spender's account
	// ------------------------------------------------------------------------

	function allowance(address _tokenOwner, address _spender) public constant returns (uint remaining) 
	{
		return allowed[_tokenOwner][_spender];
	}


	/**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _data some extra information to send to the approved contract
    */

	function approveAndCall(address _spender, uint _value, bytes _data) public returns (bool success) 
	{
		allowed[msg.sender][_spender] = _value;

		emit Approval(msg.sender, _spender, _value);
		FusionchainApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _value, this, _data);

		return true;
	}

	// ------------------------------------------------------------------------
	// Don't accept ETH 
	// ------------------------------------------------------------------------

	function () public payable 
	{
		revert();
	}

	// ------------------------------------------------------------------------
	// Owner can transfer out any accidentally sent ERC20 tokens
	// ------------------------------------------------------------------------

	function transferAnyERC20Token(address _tokenAddress, uint _value) public onlyOwner returns (bool success) 
	{
		return FusionchainInterface(_tokenAddress).transfer(owner, _value);
	}

	/**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
    */

	function burn(uint _value) returns (bool success) 
	{
		//Check if the sender has enough
		if (balances[msg.sender] < _value) 
			throw; 

		if (_value <= 0) 
		    throw; 

		// Subtract from the sender
		balances[msg.sender] = safeSub(balances[msg.sender], _value);

		// Updates totalSupply 
		_totalSupply =safeSub(_totalSupply,_value);
		
		emit Transfer(msg.sender,0x0,_value);
		return true;
	}
}