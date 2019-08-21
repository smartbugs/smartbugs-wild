pragma solidity ^0.4.19;

/**
 * @title Interface to communicate with ICO token contract
 */
 // FRACTAL PRE REALEASE "IOU" TOKEN - FPRT 
 
contract IToken {
   
  function balanceOf(address _address) constant returns (uint balance);
  function transferFromOwner(address _to, uint256 _value) returns (bool success);
}

/**
 * @title Presale token contract
 */
contract TokenEscrow {
	// Token-related properties/description to display in Wallet client / UI
	string public standard = 'FractalPreRelease 1.0';
	string public name = 'FractalPreReleaseToken';
	string public symbol = 'FPRT';
	uint public decimals = 4;
    uint public totalSupply = 50000000000;
   
	
	IToken icoToken;
	
	event Converted(address indexed from, uint256 value); // Event to inform about the fact of token burning/destroying
    	event Transfer(address indexed from, address indexed to, uint256 value);
	event Error(bytes32 error);
	
	mapping (address => uint) balanceFor; // Presale token balance for each of holders
	
	address owner;  // Contract owner
	
	uint public exchangeRate; // preICO -> ICO token exchange rate

	// Token supply and discount policy structure
	struct TokenSupply {
		uint limit;                 // Total amount of tokens
		uint totalSupply;           // Current amount of sold tokens
		uint tokenPriceInWei;  // Number of token per 1 Eth
		
	}
	
	TokenSupply[3] public tokenSupplies;

	// Modifiers
	modifier owneronly { if (msg.sender == owner) _; }

	/**
	 * @dev Set/change contract owner
	 * @param _owner owner address
	 */
	function setOwner(address _owner) owneronly {
		owner = _owner;
	}
	
	function setRate(uint _exchangeRate) owneronly {
		exchangeRate = _exchangeRate;
	}
	
	function setToken(address _icoToken) owneronly {
		icoToken = IToken(_icoToken);
	}
	
	/**
	 * @dev Returns balance/token quanity owned by address
	 * @param _address Account address to get balance for
	 * @return balance value / token quantity
	 */
	function balanceOf(address _address) constant returns (uint balance) {
		return balanceFor[_address];
	}
	
	/**
	 * @dev Transfers tokens from caller/method invoker/message sender to specified recipient
	 * @param _to Recipient address
	 * @param _value Token quantity to transfer
	 * @return success/failure of transfer
	 */	
	function transfer(address _to, uint _value) returns (bool success) {
		if(_to != owner) {
			if (balanceFor[msg.sender] < _value) return false;           // Check if the sender has enough
			if (balanceFor[_to] + _value < balanceFor[_to]) return false; // Check for overflows
			if (msg.sender == owner) {
				transferByOwner(_value);
			}
			balanceFor[msg.sender] -= _value;                     // Subtract from the sender
			balanceFor[_to] += _value;                            // Add the same to the recipient
			Transfer(owner,_to,_value);
			return true;
		}
		return false;
	}
	
	function transferByOwner(uint _value) private {
		for (uint discountIndex = 0; discountIndex < tokenSupplies.length; discountIndex++) {
			TokenSupply storage tokenSupply = tokenSupplies[discountIndex];
			if(tokenSupply.totalSupply < tokenSupply.limit) {
				if (tokenSupply.totalSupply + _value > tokenSupply.limit) {
					_value -= tokenSupply.limit - tokenSupply.totalSupply;
					tokenSupply.totalSupply = tokenSupply.limit;
				} else {
					tokenSupply.totalSupply += _value;
					break;
				}
			}
		}
	}
	
	/**
	 * @dev Burns/destroys specified amount of Presale tokens for caller/method invoker/message sender
	 * @return success/failure of transfer
	 */	
	function convert() returns (bool success) {
		if (balanceFor[msg.sender] == 0) return false;            // Check if the sender has enough
		if (!exchangeToIco(msg.sender)) return false; // Try to exchange preICO tokens to ICO tokens
		Converted(msg.sender, balanceFor[msg.sender]);
		balanceFor[msg.sender] = 0;                      // Subtract from the sender
		return true;
	} 
	
	/**
	 * @dev Converts/exchanges sold Presale tokens to ICO ones according to provided exchange rate
	 * @param owner address
		 */
	function exchangeToIco(address owner) private returns (bool) {
	    if(icoToken != address(0)) {
		    return icoToken.transferFromOwner(owner, balanceFor[owner] * exchangeRate);
	    }
	    return false;
	}

	/**
	 * @dev Presale contract constructor
	 */
	function TokenEscrow() {
		owner = msg.sender;
		
		balanceFor[msg.sender] = 50000000000; // Give the creator all initial tokens
		
		// Discount policy
		tokenSupplies[0] = TokenSupply(10000000000, 0, 50000000000); // First million of tokens will go 2000 tokens for 1 eth
		tokenSupplies[1] = TokenSupply(20000000000, 0, 50000000000); // Following Two millions of tokens will go 2000 tokens for 1 eth
		tokenSupplies[2] = TokenSupply(20000000000, 0, 50000000000); // Two last millions of tokens will go 2000 tokens for 1 eth
	    
}


	// Incoming transfer from the Presale token buyer
	function() payable {
		
		uint tokenAmount; // Amount of tokens which is possible to buy for incoming transfer/payment
		uint amountToBePaid; // Amount to be paid
		uint amountTransfered = msg.value; // Cost/price in WEI of incoming transfer/payment
		
		
		if (amountTransfered <= 0) {
		      	Error('no eth was transfered');
              		msg.sender.transfer(msg.value);
		  	return;
		}

		if(balanceFor[owner] <= 0) {
		      	Error('all tokens sold');
              		msg.sender.transfer(msg.value);
		      	return;
		}
		
		// Determine amount of tokens can be bought according to available supply and discount policy
		for (uint discountIndex = 0; discountIndex < tokenSupplies.length; discountIndex++) {
			// If it's not possible to buy any tokens at all skip the rest of discount policy
			
			TokenSupply storage tokenSupply = tokenSupplies[discountIndex];
			
			if(tokenSupply.totalSupply < tokenSupply.limit) {
			
				uint tokensPossibleToBuy = amountTransfered / tokenSupply.tokenPriceInWei;

                if (tokensPossibleToBuy > balanceFor[owner]) 
                    tokensPossibleToBuy = balanceFor[owner];

				if (tokenSupply.totalSupply + tokensPossibleToBuy > tokenSupply.limit) {
					tokensPossibleToBuy = tokenSupply.limit - tokenSupply.totalSupply;
				}

				tokenSupply.totalSupply += tokensPossibleToBuy;
				tokenAmount += tokensPossibleToBuy;

				uint delta = tokensPossibleToBuy * tokenSupply.tokenPriceInWei;

				amountToBePaid += delta;
                		amountTransfered -= delta;
			
			}
		}
		
		// Do not waste gas if there is no tokens to buy
		if (tokenAmount == 0) {
		    	Error('no token to buy');
            		msg.sender.transfer(msg.value);
			return;
        	}
		
		// Transfer tokens to buyer
		transferFromOwner(msg.sender, tokenAmount);

		// Transfer money to seller
		owner.transfer(amountToBePaid);
		
		// Refund buyer if overpaid / no tokens to sell
		msg.sender.transfer(msg.value - amountToBePaid);
		
	}
  
	/**
	 * @dev Removes/deletes contract
	 */
	function kill() owneronly {
		selfdestruct(msg.sender);
	}
	
  
	/**
	 * @dev Transfers tokens from owner to specified recipient
	 * @param _to Recipient address
	 * @param _value Token quantity to transfer
	 * @return success/failure of transfer
	 */
	function transferFromOwner(address _to, uint256 _value) private returns (bool success) {
		if (balanceFor[owner] < _value) return false;                 // Check if the owner has enough
		if (balanceFor[_to] + _value < balanceFor[_to]) return false;  // Check for overflows
		balanceFor[owner] -= _value;                          // Subtract from the owner
		balanceFor[_to] += _value;                            // Add the same to the recipient
        	Transfer(owner,_to,_value);
		return true;
	}
  
}