pragma solidity ^0.4.8;
	contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public ; }

	/*
	 * Standard token contract with ability to hold some amount on some balances before single initially specified deadline
	 * Which is useful for example for holding unsold tokens for a year for next step of project management
	 *
	 * Implements initial supply and allows additional supply based on coordinator agreement
	 * Coordinators list can be altered by owner
	 * Once minimal count of coordinators stated that they're agree for some value, emission is made
	 *
	 * Allows to change name, symbol and owner when in unlocked, can be locked by owner
	 * Once locked, can't be unlocked and reconfigured anymore
	 */ 

	contract MetalExchangeToken {
		/* Public variables of the token */
		string public standard = 'Token 0.1';
		string public name;
		string public symbol;
		address public owner;
		uint8 public decimals;
		uint256 public totalSupply;
		bool public nameLocked=false;
		bool public symbolLocked=false;
		bool public ownerLocked=false;	
		uint256 public unholdTime;//deadline for unhold

		/* This creates an array with all balances */
		mapping (address => uint256) public balanceOf;
		mapping (address => uint256) public holdBalanceOf;
		mapping (address => mapping (address => uint256)) public allowance;
		
		// Holds agreements for emission for Coordinators
		mapping (address => uint256) public coordinatorAgreeForEmission;
		mapping (uint256 => address) public coordinatorAccountIndex;
		uint256 public coordinatorAccountCount;
		
		// Keeps required count of coordinators to perform emission
		uint256 public minCoordinatorCount;

		/* This generates a public event on the blockchain that will notify clients */
		event Transfer(address indexed from, address indexed to, uint256 value);
		event Emission(uint256 value);		
		
		event Hold(address indexed from, uint256 value);
		event Unhold(address indexed from, uint256 value);

		/* This notifies clients about the amount burnt */
		event Burn(address indexed from, uint256 value);
		
		modifier canUnhold() { if (block.timestamp >= unholdTime) _; }
		modifier canHold() { if (block.timestamp < unholdTime) _; }

		/* Initializes contract with initial supply tokens to the creator of the contract */
		function MetalExchangeToken() public {
			owner=msg.sender;
			totalSupply = 40000000000;	 				    // Update total supply
			balanceOf[owner] = totalSupply;				// Give the creator all initial tokens			
			name = 'MetalExchangeToken';				// Set the name for display purposes
			symbol = 'MET';								// Set the symbol for display purposes
			decimals = 4;								// Amount of decimals for display purposes
			unholdTime = 0;								// Time of automatic unhold of hold tokens
			coordinatorAccountCount = 0;
			minCoordinatorCount = 2;
		}
		
		// Adds new coordinator
		function addCoordinator(address newCoordinator) public {
			if (msg.sender!=owner) revert();
			coordinatorAccountIndex[coordinatorAccountCount]=newCoordinator;
			coordinatorAgreeForEmission[newCoordinator]=0;
			coordinatorAccountCount++;
		}
		
		// Removes exist coordinator from list of coordinators
		function removeCoordinator(address coordinator) public {
			if (msg.sender!=owner) revert();
			delete coordinatorAgreeForEmission[coordinator];
			for (uint256 i=0;i<coordinatorAccountCount;i++)
				if (coordinatorAccountIndex[i]==coordinator){
					for (uint256 j=i;j<coordinatorAccountCount-1;j++)
						coordinatorAccountIndex[j]=coordinatorAccountIndex[j+1];
						
					coordinatorAccountCount--;
					delete coordinatorAccountIndex[coordinatorAccountCount];
					i=coordinatorAccountCount;
				}
		}
		
		// Accepts the vote of coordinator for upcoming emission: which amount he or she is agree to emit
		function coordinatorSetAgreeForEmission(uint256 value_) public {
			bool found=false;
			for (uint256 i=0;i<coordinatorAccountCount;i++)
				if (coordinatorAccountIndex[i]==msg.sender){
					found=true;
					i=coordinatorAccountCount;
				}
			if (!found) revert();
			coordinatorAgreeForEmission[msg.sender]=value_;
			emit(value_);
		}
		
		// Attempts to make emission of specified value
		// Emission will be processed if required count of coordinators are agree
		function emit(uint256 value_) private {
			if (value_ <= 0) revert();
			
			bool found=false;
			if (msg.sender==owner) found=true;
			for (uint256 i=0;(!found)&&(i<coordinatorAccountCount);i++)
				if (coordinatorAccountIndex[i]==msg.sender){
					found=true;
					i=coordinatorAccountCount;
				}
			if (!found) revert();
			
			uint256 agree=0;
			for (i=0;i<coordinatorAccountCount;i++)
				if (coordinatorAgreeForEmission[coordinatorAccountIndex[i]]>=value_)
					agree++;
					
			if (agree<minCoordinatorCount) revert();
			
			for (i=0;i<coordinatorAccountCount;i++)
				if (coordinatorAgreeForEmission[coordinatorAccountIndex[i]]>=value_)
					coordinatorAgreeForEmission[coordinatorAccountIndex[i]]-=value_;
			
			balanceOf[owner] += value_;
			totalSupply += value_;
			Emission(value_);
		}
		
		function lockName() public {
			if (msg.sender!=owner) revert();
			if (nameLocked) revert();
			nameLocked=true;
		}
		
		function changeName(string new_name) public {
			if (msg.sender!=owner) revert();
			if (nameLocked) revert();
			name=new_name;
		}
		
		function lockSymbol() public {
			if (msg.sender!=owner) revert();
			if (symbolLocked) revert();
			symbolLocked=true;
		}
		
		function changeSymbol(string new_symbol) public {
			if (msg.sender!=owner) revert();
			if (symbolLocked) revert();
			symbol=new_symbol;
		}
		
		function lockOwner() public {
			if (msg.sender!=owner) revert();
			if (ownerLocked) revert();
			ownerLocked=true;
		}
		
		function changeOwner(address new_owner) public {
			if (msg.sender!=owner) revert();
			if (ownerLocked) revert();
			owner=new_owner;
		}
		
		/* Hold coins */
		function hold(uint256 _value) canHold payable public {
			if (balanceOf[msg.sender] < _value) revert();		   		// Check if the sender has enough to hold
			if (holdBalanceOf[msg.sender] + _value < holdBalanceOf[msg.sender]) revert(); // Check for overflows
				balanceOf[msg.sender] -= _value;					// Subtract from the sender
			holdBalanceOf[msg.sender] += _value;					// Add the same to the sender's hold
			Hold(msg.sender, _value);				   				// Notify anyone listening that this hold took place
		}
		
		/* Unhold coins */
		function unhold(uint256 _value) canUnhold payable public {
			if (holdBalanceOf[msg.sender] < _value) revert();		   	// Check if the sender has enough hold
			if (balanceOf[msg.sender] + _value < balanceOf[msg.sender]) revert(); // Check for overflows
			holdBalanceOf[msg.sender] -= _value;					// Subtract from the sender hold
			balanceOf[msg.sender] += _value;						// Add the same to the sender
			Unhold(msg.sender, _value);				   			 	// Notify anyone listening that this unhold took place
		}

		/* Send coins */
		function transfer(address _to, uint256 _value) payable public {
			if (_to == 0x0) revert();							   		// Prevent transfer to 0x0 address. Use burn() instead
			if (balanceOf[msg.sender] < _value) revert();		   		// Check if the sender has enough
			if (balanceOf[_to] + _value < balanceOf[_to]) revert(); 	// Check for overflows
			balanceOf[msg.sender] -= _value;					 	// Subtract from the sender
			balanceOf[_to] += _value;								// Add the same to the recipient
			Transfer(msg.sender, _to, _value);				   		// Notify anyone listening that this transfer took place
		}

		/* Allow another contract to spend some tokens in your behalf */
		function approve(address _spender, uint256 _value)
			public
			returns (bool success) {
			allowance[msg.sender][_spender] = _value;
			return true;
		}

		/* Approve and then communicate the approved contract in a single tx */
		function approveAndCall(address _spender, uint256 _value, bytes _extraData)
			public
			returns (bool success) {
			tokenRecipient spender = tokenRecipient(_spender);
			if (approve(_spender, _value)) {
				spender.receiveApproval(msg.sender, _value, this, _extraData);
				return true;
			}
		}		

		/* A contract attempts to get the coins */
		function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
			if (_to == 0x0) revert();									// Prevent transfer to 0x0 address. Use burn() instead
			if (balanceOf[_from] < _value) revert();				 	// Check if the sender has enough
			if (balanceOf[_to] + _value < balanceOf[_to]) revert();  	// Check for overflows
			if (_value > allowance[_from][msg.sender]) revert();	 	// Check allowance
			balanceOf[_from] -= _value;						   		// Subtract from the sender
			balanceOf[_to] += _value;							 	// Add the same to the recipient
			allowance[_from][msg.sender] -= _value;
			Transfer(_from, _to, _value);
			return true;
		}

		function burn(uint256 _value) public returns (bool success) {
			if (balanceOf[msg.sender] < _value) revert();				// Check if the sender has enough
			balanceOf[msg.sender] -= _value;					  	// Subtract from the sender
			totalSupply -= _value;									// Updates totalSupply
			Burn(msg.sender, _value);								// Fires the event about token burn
			return true;
		}

		function burnFrom(address _from, uint256 _value) public returns (bool success){
			if (balanceOf[_from] < _value) revert();					// Check if the sender has enough
			if (_value > allowance[_from][msg.sender]) revert();		// Check allowance
			balanceOf[_from] -= _value;						  		// Subtract from the sender
			totalSupply -= _value;							   		// Updates totalSupply
			Burn(_from, _value);									// Fires the event about token burn
			return true;
		}
	}