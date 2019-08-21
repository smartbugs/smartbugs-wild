pragma solidity ^0.4.15;

/*********************************************************************************
 *********************************************************************************
 *
 * Name of the project: Alteum Token
 * Contract name: AlteumToken
 * Author: Juan Livingston @ Ethernity.live
 * Developed for: Alteum
 * Alteum is an ERC223 Token
 *
 *********************************************************************************
 ********************************************************************************/

contract ContractReceiver {   
    function tokenFallback(address _from, uint _value, bytes _data){
    }
}



 /* New ERC23 contract interface */

contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  
  function name() constant returns (string _name);
  function symbol() constant returns (string _symbol);
  function decimals() constant returns (uint8 _decimals);
  function totalSupply() constant returns (uint256 _supply);

  function transfer(address to, uint value) returns (bool ok);
  function transfer(address to, uint value, bytes data) returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) returns (bool ok);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}

// The Alteum token ERC223

contract AlteumToken {

    // Token public variables
    string public name;
    string public symbol;
    uint8 public decimals; 
    string public version = 'v0.2';
    uint256 public totalSupply;
    bool locked;

    address rootAddress;
    address Owner;
    uint multiplier = 100000000; // For 8 decimals
    address swapperAddress; // Can bypass a lock

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) freezed; 


  	event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Modifiers

    modifier onlyOwner() {
        if ( msg.sender != rootAddress && msg.sender != Owner ) revert();
        _;
    }

    modifier onlyRoot() {
        if ( msg.sender != rootAddress ) revert();
        _;
    }

    modifier isUnlocked() {
    	if ( locked && msg.sender != rootAddress && msg.sender != Owner ) revert();
		_;    	
    }

    modifier isUnfreezed(address _to) {
    	if ( freezed[msg.sender] || freezed[_to] ) revert();
    	_;
    }


    // Safe math
    function safeAdd(uint x, uint y) internal returns (uint z) {
        require((z = x + y) >= x);
    }
    function safeSub(uint x, uint y) internal returns (uint z) {
        require((z = x - y) <= x);
    }


    // Alteum Token constructor
    function AlteumToken() {        
        locked = true;
        totalSupply = 50000000 * multiplier; // 50,000,000 tokens * 8 decimals
        name = 'Alteum'; 
        symbol = 'AUM'; 
        decimals = 8; 
        rootAddress = 0x803622DE47eACE04e25541496e1ED9216C3c640F;      
        Owner = msg.sender;       
        balances[rootAddress] = totalSupply;
        allowed[rootAddress][swapperAddress] = 37500000 * multiplier; // 37,500,000 tokens for ICO
    }


	// ERC223 Access functions

	function name() constant returns (string _name) {
	      return name;
	  }
	function symbol() constant returns (string _symbol) {
	      return symbol;
	  }
	function decimals() constant returns (uint8 _decimals) {
	      return decimals;
	  }
	function totalSupply() constant returns (uint256 _totalSupply) {
	      return totalSupply;
	  }


    // Only root function

    function changeRoot(address _newrootAddress) onlyRoot returns(bool){
            rootAddress = _newrootAddress;
            allowed[_newrootAddress][swapperAddress] = allowed[rootAddress][swapperAddress]; // Gives allowance to new rootAddress
            allowed[rootAddress][swapperAddress] = 0; // Removes allowance to old rootAddress
            return true;
    }


    // Only owner functions

    function changeOwner(address _newOwner) onlyOwner returns(bool){
            Owner = _newOwner;
            return true;
    }

    function changeSwapperAdd(address _newSwapper) onlyOwner returns(bool){
            swapperAddress = _newSwapper;
            allowed[rootAddress][_newSwapper] = allowed[rootAddress][swapperAddress]; // Gives allowance to new rootAddress
            allowed[rootAddress][swapperAddress] = 0; // Removes allowance to old rootAddress
            return true;
    }
       
    function unlock() onlyOwner returns(bool) {
        locked = false;
        return true;
    }

    function lock() onlyOwner returns(bool) {
        locked = true;
        return true;
    }

    function freeze(address _address) onlyOwner returns(bool) {
        freezed[_address] = true;
        return true;
    }

    function unfreeze(address _address) onlyOwner returns(bool) {
        freezed[_address] = false;
        return true;
    }

    // Public getters
    function isFreezed(address _address) constant returns(bool) {
        return freezed[_address];
    }

    function isLocked() constant returns(bool) {
        return locked;
    }


// To send tokens that were accidentally sent to this contract
function sendToken(address _tokenAddress , address _addressTo , uint256 _amount) onlyOwner returns(bool) {
        ERC223 token_to_send = ERC223( _tokenAddress );
        require( token_to_send.transfer(_addressTo , _amount) );
        return true;
}

  // Public functions (from https://github.com/Dexaran/ERC223-token-standard/tree/Recommended)

  // Function that is called when a user or another contract wants to transfer funds to an address that has a non-standard fallback function
  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) isUnlocked isUnfreezed(_to) returns (bool success) {
      
    if(isContract(_to)) {
        if (balances[msg.sender] < _value) return false;
        balances[msg.sender] = safeSub( balances[msg.sender] , _value );
        balances[_to] = safeAdd( balances[_to] , _value );
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.call.value(0)(bytes4(sha3(_custom_fallback)), msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}

  // Function that is called when a user or another contract wants to transfer funds to an address with tokenFallback function
  function transfer(address _to, uint _value, bytes _data) isUnlocked isUnfreezed(_to) returns (bool success) {
      
    if(isContract(_to)) {
        return transferToContract(_to, _value, _data);
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}


  // Standard function transfer similar to ERC20 transfer with no _data.
  // Added due to backwards compatibility reasons.
  function transfer(address _to, uint _value) isUnlocked isUnfreezed(_to) returns (bool success) {

    bytes memory empty;
    if(isContract(_to)) {
        return transferToContract(_to, _value, empty);
    }
    else {
        return transferToAddress(_to, _value, empty);
    }
}

//assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  function isContract(address _addr) private returns (bool is_contract) {
      uint length;
      assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
      }
      return (length>0);
    }

  //function that is called when transaction target is an address
  function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balances[msg.sender] < _value) return false;
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  
  //function that is called when transaction target is a contract
  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balances[msg.sender] < _value) return false;
    balances[msg.sender] = safeSub(balances[msg.sender] , _value);
    balances[_to] = safeAdd(balances[_to] , _value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(msg.sender, _value, _data);
    Transfer(msg.sender, _to, _value, _data);
    return true;
}


    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {

        if ( locked && msg.sender != swapperAddress ) return false; 
        if ( freezed[_from] || freezed[_to] ) return false; // Check if destination address is freezed
        if ( balances[_from] < _value ) return false; // Check if the sender has enough
		if ( _value > allowed[_from][msg.sender] ) return false; // Check allowance

        balances[_from] = safeSub(balances[_from] , _value); // Subtract from the sender
        balances[_to] = safeAdd(balances[_to] , _value); // Add the same to the recipient

        allowed[_from][msg.sender] = safeSub( allowed[_from][msg.sender] , _value );

        bytes memory empty;

        if ( isContract(_to) ) {
	        ContractReceiver receiver = ContractReceiver(_to);
	    	receiver.tokenFallback(_from, _value, empty);
		}

        Transfer(_from, _to, _value , empty);
        return true;
    }


    function balanceOf(address _owner) constant returns(uint256 balance) {
        return balances[_owner];
    }


    function approve(address _spender, uint _value) returns(bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) constant returns(uint256) {
        return allowed[_owner][_spender];
    }
}