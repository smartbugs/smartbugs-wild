pragma solidity ^0.4.18;

    contract LitecoinEclipse {
        string public name;
        string public symbol;
        uint8 public decimals;
     
        /* This creates an array with all balances */
        mapping (address => uint256) public balanceOf;
        
        event Transfer(address indexed from, address indexed to, uint256 value);
    
    function LitecoinEclipse(uint256 totalSupply, string tokenName, string tokenSymbol, uint8 decimalUnits) public {
        balanceOf[msg.sender] = totalSupply;              // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
    }

	function transfer(address _to, uint256 _value) public {
	    
	    require(balanceOf[msg.sender] >= _value && balanceOf[_to] + _value >= balanceOf[_to]);
	    
		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;
		
		        /* Notify anyone listening that this transfer took place */
        Transfer(msg.sender, _to, _value);
	}
	
}