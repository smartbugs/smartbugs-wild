pragma solidity ^0.4.8;

 

contract BRUMtoken  {
    string public constant symbol = "BRUM";
    string public constant name = "Brumbum";
    uint8 public constant decimals = 1;
	// Owner of the contract
	address public owner;
	// Total supply of tokens
	uint256 _totalSupply = 1000000;
	// Ledger of the balance of the account
	mapping (address => uint256) balances;
	// Owner of account approuves the transfert of an account to another account
    mapping (address => mapping (address => uint256)) allowed;
    
    // Events can be trigger when certain actions happens
    // Triggered when tokens are transferred
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    // Constructor
    function BRUMtoken() {
         owner = msg.sender;
         balances[owner] = _totalSupply;
     }

    // Transfert the amont _value from the address calling the function to address _to
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

    

     // Transfert 
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

        // if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    // Return the balance of an account
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    // Autorize the address _spender to transfer from the account msg.sender
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    // Return the amont of allowance
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }


}