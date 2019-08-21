pragma solidity ^0.4.16; //YourMomToken

contract owned {	//Defines contract Owner
	address public owner;

	//Events
	event TransferOwnership (address indexed _owner, address indexed _newOwner);	//Notifies about the ownership transfer

	//Constrctor function
	function owned() public {
		owner = msg.sender;
	}

	function transferOwnership(address newOwner) onlyOwner() public {
		TransferOwnership (owner, newOwner);
		owner = newOwner;
	}
	
	//Modifiers
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	modifier onlyPayloadSize(uint size) {		//Mitigates ERC20 Short Address Attack
		assert(msg.data.length >= size + 4);
		_;
	}
}


contract YourMomToken is owned {
	mapping (address => uint256) public balanceOf;		//This creates an array with all balances
	mapping (address => mapping (address => uint256)) public allowance;	//This creates an array of arrays with adress->adress=value
	uint256 public totalSupply;
	string public name;
	string public symbol;
	uint8 public decimals;

	//Events
	event Transfer(address indexed from, address indexed to, uint256 value);		//Declaring the event function to help clients like the Ethereum Wallet keep track of activities happening in the contract
	event Approval(address indexed _owner, address indexed _spender, uint _value);	//Notifies clients about the Approval
	event Burn(address indexed from, uint256 value);								//This notifies clients about the amount burnt

	//Constructor function
	function YourMomToken(string tokenName, string tokenSymbol, uint256 initialSupplyInEther) public {
		name = tokenName;								//Set the name for display purposes
		symbol = tokenSymbol;							//Set the symbol for display purposes
		decimals = 18;									//Amount of decimals for display purposes
		totalSupply = initialSupplyInEther * 10**18;	//Defines the initial supply as the total supply (in wei)
		balanceOf[msg.sender] = totalSupply;			//Give the creator all initial tokens
	}

	//Call functions
	function name() public constant returns (string) { return name; }
	function symbol() public constant returns (string) { return symbol; }
	function decimals() public constant returns (uint8) { return decimals; }
	function totalSupply() public constant returns (uint256) { return totalSupply; }
	function balanceOf(address _owner) public constant returns (uint256 balance) { return balanceOf[_owner]; }
	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { return allowance[_owner][_spender]; }

	function transfer(address _to, uint256 _value) onlyPayloadSize (2 * 32) public returns (bool success) {	//Transfer _value tokens from msg.sender to '_to'
		_transfer(msg.sender, _to, _value);		//Call the _transfer function (internal). Calling it it's cleaner than write two identical functions for 'transfer' and 'transferFrom'
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize (3 * 32) public returns (bool success) {	//Transfer tokens from other address
		require(_value <= allowance[_from][msg.sender]);	//Check allowance array, if '_from' has authorized 'msg.sender' spend <= _value
		_transfer(_from, _to, _value);						//Send '_value' tokens to '_to' in behalf of '_from'
		allowance[_from][msg.sender] -= _value;				//Reduce msg.sender's allowance to spend '_from's tokens in '_value'
		return true;
	}
	
	function _transfer(address _from, address _to, uint _value) internal returns (bool success) {
		require(_to != 0x0);									//Prevent transfer to 0x0 address. Use burn() instead
		require(balanceOf[_from] >= _value);					//Check if the sender has enough
		require(balanceOf[_to] + _value >= balanceOf[_to]);		//Check for overflows
		require(_value != 0);									//Prevents a transaction of '0' to be executed
		require(_from != _to);									//Prevents sending a transaction to yourself
		balanceOf[_from] -= _value;								//Subtract from the sender
		balanceOf[_to] += _value;								//Add the same to the recipient
		Transfer(_from, _to, _value);							//Notify anyone listening that this transfer took place
		return true;
	}

	function approve(address _spender, uint256 _value) public returns (bool success) {	//Set allowance for other address
		require((_value == 0) || (allowance[msg.sender][_spender] == 0));		//Mitigates the approve/transfer attack (race condition)
		require(_value != allowance[msg.sender][_spender]);	//Prevents setting allowance for the already setted value
		allowance[msg.sender][_spender] = _value;			//Set allowance array
		Approval(msg.sender, _spender, _value);				//Call the Approval event
		return true;
	}

	function burn(uint256 _value) public returns (bool success) {	//Function to destroy tokens
		require(balanceOf[msg.sender] >= _value);			//Check if the targeted balance has enough
		require(_value != 0);								//Prevents a transaction of '0' to be executed
		balanceOf[msg.sender] -= _value;					//Subtract from the targeted balance
		totalSupply -= _value;								//Update totalSupply
		Burn(msg.sender, _value);							//Call the Event to notice about the burn
		return true;
	}
}