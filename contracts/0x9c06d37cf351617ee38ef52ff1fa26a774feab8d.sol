pragma solidity ^0.4.15;

 

contract SAUBAERtoken  {
    string public constant symbol = "SAUBAER";
    string public constant name = "SAUBAER";
    uint8 public constant decimals = 1;
	// Owner of the contract
	address public owner;
	// Total supply of tokens
	uint256 _totalSupply = 100000;
	// Ledger of the balance of the account
	mapping (address => uint256) balances;
	// Owner of account approuves the transfert of an account to another account
    mapping (address => mapping (address => uint256)) allowed;
    
     
    // Triggered when tokens are transferred
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    // Constructor
    function SAUBAERtoken() {
         owner = msg.sender;
         balances[owner] = _totalSupply;
     }


    
    // SEND TOKEN: Transfer amount _value from the addr calling function to address _to
    function transfer(address _to, uint256 _value) returns (bool success) {
        // Check if the value is autorized
        if (balances[msg.sender] >= _value && _value > 0) {
            // Decrease the sender balance
            balances[msg.sender] -= _value;
            // Increase the sender balance
            balances[_to] += _value;
            // Trigger the Transfer event
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
 
   


}