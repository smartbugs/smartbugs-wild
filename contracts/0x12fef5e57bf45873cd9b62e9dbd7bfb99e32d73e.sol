pragma solidity ^0.4.11;

contract owned {

	address public owner;

	function owned() {
		owner = msg.sender;
	}

	modifier onlyOwner {
		if (msg.sender != owner) throw;
		_;
	}

	function transferOwnership(address newOwner) onlyOwner {
		owner = newOwner;
	}
}

contract tokenRecipient { 
	function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); 
} 

contract IERC20Token {     

	/// @return total amount of tokens     
	function totalSupply() constant returns (uint256 totalSupply);     

	/// @param _owner The address from which the balance will be retrieved     
	/// @return The balance     
	function balanceOf(address _owner) constant returns (uint256 balance) {}     

	/// @notice send `_value` token to `_to` from `msg.sender`     
	/// @param _to The address of the recipient     
	/// @param _value The amount of token to be transferred     
	/// @return Whether the transfer was successful or not     
	function transfer(address _to, uint256 _value) returns (bool success) {}     

	/// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`     
	/// @param _from The address of the sender     
	/// @param _to The address of the recipient     
	/// @param _value The amount of token to be transferred     
	/// @return Whether the transfer was successful or not     
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}     

	/// @notice `msg.sender` approves `_addr` to spend `_value` tokens     
	/// @param _spender The address of the account able to transfer the tokens     
	/// @param _value The amount of wei to be approved for transfer     
	/// @return Whether the approval was successful or not     
	function approve(address _spender, uint256 _value) returns (bool success) {}     

	/// @param _owner The address of the account owning tokens     
	/// @param _spender The address of the account able to transfer the tokens     
	/// @return Amount of remaining tokens allowed to spent     
	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}       

	event Transfer(address indexed _from, address indexed _to, uint256 _value);     
	event Approval(address indexed _owner, address indexed _spender, uint256 _value); 
} 

contract CofounditToken is IERC20Token, owned{         

	/* Public variables of the token */     
	string public standard = "Cofoundit token v1.0";     
	string public name = "Cofoundit";     
	string public symbol = "CFI";     
	uint8 public decimals = 18;     
	address public icoContractAddress;     
	uint256 public tokenFrozenUntilBlock;     

	/* Private variables of the token */     
	uint256 supply = 0;     
	mapping (address => uint256) balances;     
	mapping (address => mapping (address => uint256)) allowances;     
	mapping (address => bool) restrictedAddresses;     

	/* Events */       
	event Mint(address indexed _to, uint256 _value);     
	event TokenFrozen(uint256 _frozenUntilBlock, string _reason);     

	/* Initializes contract and  sets restricted addresses */     
	function CofounditToken(address _icoAddress) {         
		restrictedAddresses[0x0] = true;			// Users cannot send tokens to 0x0 address         
		restrictedAddresses[_icoAddress] = true;	// Users cannot send tokens to ico contract         
		restrictedAddresses[address(this)] = true;	// Users cannot sent tokens to this contracts address                 
		icoContractAddress = _icoAddress;			// Sets ico contract address from where mints will happen     
	}         

	/* Get total supply of issued coins */     
	function totalSupply() constant returns (uint256 totalSupply) {         
		return supply;     
	}         

	/* Get balance of specific address */     
	function balanceOf(address _owner) constant returns (uint256 balance) {         
		return balances[_owner];     
	}     

	/* Send coins */     
	function transfer(address _to, uint256 _value) returns (bool success) {     	
		if (block.number < tokenFrozenUntilBlock) throw;	// Throw is token is frozen in case of emergency         
		if (restrictedAddresses[_to]) throw;                // Prevent transfer to restricted addresses         
		if (balances[msg.sender] < _value) throw;           // Check if the sender has enough         
		if (balances[_to] + _value < balances[_to]) throw;  // Check for overflows         
		balances[msg.sender] -= _value;                     // Subtract from the sender         
		balances[_to] += _value;                            // Add the same to the recipient         
		Transfer(msg.sender, _to, _value);                  // Notify anyone listening that this transfer took place         
		return true;     
	}     

	/* Allow another contract to spend some tokens in your behalf */     
	function approve(address _spender, uint256 _value) returns (bool success) {     	
		if (block.number < tokenFrozenUntilBlock) throw;	// Throw is token is frozen in case of emergency         
		allowances[msg.sender][_spender] = _value;          // Set allowance         
		Approval(msg.sender, _spender, _value);             // Raise Approval event         
		return true;     
	}     

	/* Approve and then comunicate the approved contract in a single tx */     
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {            
		tokenRecipient spender = tokenRecipient(_spender);              // Cast spender to tokenRecipient contract         
		approve(_spender, _value);                                      // Set approval to contract for _value         
		spender.receiveApproval(msg.sender, _value, this, _extraData);  // Raise method on _spender contract         
		return true;     
	}     

	/* A contract attempts to get the coins */     
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {     	
		if (block.number < tokenFrozenUntilBlock) throw;	// Throw is token is frozen in case of emergency         
		if (restrictedAddresses[_to]) throw;                // Prevent transfer to restricted addresses         
		if (balances[_from] < _value) throw;                // Check if the sender has enough         
		if (balances[_to] + _value < balances[_to]) throw;  // Check for overflows         
		if (_value > allowances[_from][msg.sender]) throw;  // Check allowance         
		balances[_from] -= _value;                          // Subtract from the sender         
		balances[_to] += _value;                            // Add the same to the recipient         
		allowances[_from][msg.sender] -= _value;            // Deduct allowance for this address         
		Transfer(_from, _to, _value);                       // Notify anyone listening that this transfer took place         
		return true;     
	}         

	/* Get the ammount of remaining tokens to spend */     
	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {         
		return allowances[_owner][_spender];     
	}         

	/* Create new tokens*/     
	function mintTokens(address _to, uint256 _amount, string _reason) {         
		if (msg.sender != icoContractAddress) throw;			// Check if minter is ico Contract address         
		if (restrictedAddresses[_to]) throw;                    // Prevent transfer to restricted addresses         
		if (_amount == 0 || sha3(_reason) == sha3("")) throw;   // Check if values are not null;         
		if (balances[_to] + _amount < balances[_to]) throw;     // Check for overflows         
		supply += _amount;                                      // Update total supply         
		balances[_to] += _amount;                    		    // Set minted coins to target         
		Mint(_to, _amount);                          		    // Create Mint event         
		Transfer(0x0, _to, _amount);                            // Create Transfer event from 0x     
	}     

	/* Stops all token transfers in case of emergency */     
	function freezeTransfersUntil(uint256 _frozenUntilBlock, string _reason) onlyOwner {     	
		tokenFrozenUntilBlock = _frozenUntilBlock;     	
		TokenFrozen(_frozenUntilBlock, _reason);     
	}     
	
	/* Owner can add new restricted address or removes one */
	function editRestrictedAddress(address _newRestrictedAddress) onlyOwner {
		restrictedAddresses[_newRestrictedAddress] = !restrictedAddresses[_newRestrictedAddress];
	}

	function isRestrictedAddress(address _querryAddress) constant returns (bool answer){
		return restrictedAddresses[_querryAddress];
	}

	/* This unnamed function is called whenever someone tries to send ether to it */     

	function () {         
		throw;     // Prevents accidental sending of ether     
	} 

	//
	/* This part is here only for testing and will not be included into final version */
	//

	//function changeICOAddress(address _newAddress) onlyOwner{
	//	icoContractAddress = _newAddress;
	//}

	//function killContract() onlyOwner{
	//	selfdestruct(msg.sender);
	//}
}