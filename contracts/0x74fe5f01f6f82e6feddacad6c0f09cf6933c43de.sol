pragma solidity ^0.4.16;

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
contract TokenERC20 {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    // total amount of tokens
    uint256 public totalSupply;

	// Send _value amount of tokens to address _to
    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

	// Send _value amount of tokens from address _from to address _to
    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

	// Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not	
    function approve(address _spender, uint256 _value) returns (bool success);

	// Returns the amount which _spender is still allowed to withdraw from _owner
    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent	
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
	
	
	// Get the account balance of another account with address _owner
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
	function balanceOf(address _owner) constant returns (uint256 balance);
	
	 // Triggered when tokens are transferred.
    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not   
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	// Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


interface TokenNotifier {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data);
}

/**
 * @title SafeMath (from https://github.com/OpenZeppelin/zeppelin-solidity/blob/4d91118dd964618863395dcca25a50ff137bf5b6/contracts/math/SafeMath.sol)
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {
    function safeMul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function safeSub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function safeAdd(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract StandardToken is TokenERC20, SafeMath {

	// Balances for each account
    mapping (address => uint256) balances;
    // Owner of account approves the transfer of an amount to another account
	mapping (address => mapping (address => uint256)) allowed;
  

	  // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _value) returns (bool success) {
        require(balances[msg.sender] >= _value);
		balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

 	 // Send _value amount of tokens from address _from to address _to
     // The transferFrom method is used for a withdraw workflow, allowing contracts to send
     // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
     // fees in sub-currencies; the command should fail unless the _from account has
     // deliberately authorized the sender of the message via some mechanism; 
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
		uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] = safeAdd(balances[_to], _value);
        balances[_from] = safeSub(balances[_from], _value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

	// Balance of a specific account
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

	// Returns the amount which _spender is still allowed to withdraw from _owner based on the approve function
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }	
}

//final implementation 
contract COGNXToken is StandardToken {
    uint8 public constant decimals = 18;
    string public constant name = 'COGNX';
    string public constant symbol = 'COGNX';
    string public constant version = '1.0.0';
    uint256 public totalSupply = 15000000 * 10 ** uint256(decimals);
		
	//Constructor
    function COGNXToken() public {
        balances[msg.sender] = totalSupply;
    }

	 /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }

}