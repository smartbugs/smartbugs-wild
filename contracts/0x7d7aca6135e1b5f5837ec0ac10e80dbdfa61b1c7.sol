pragma solidity ^0.4.15;

/*********************************************************************************
 *********************************************************************************
 *
 * Name of the project: ERC20 Basic Token
 * Author: Juan Livingston 
 *
 *********************************************************************************
 ********************************************************************************/

 /* New ERC20 contract interface */

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) constant returns (uint256);
    function transfer(address to, uint256 value) returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// The Token

contract Token {

    // Token public variables
    string public name;
    string public symbol;
    uint8 public decimals; 
    string public version = 'v1';
    uint256 public totalSupply;
    uint public price;
    bool locked;

    address rootAddress;
    address Owner;
    uint multiplier; // For 0 decimals

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) freezed;


    event Transfer(address indexed from, address indexed to, uint256 value);
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


    // Token constructor
    function Token() {        
        locked = false;
        name = 'Token name'; 
        symbol = 'SYMBOL'; 
        decimals = 18; 
        multiplier = 10 ** uint(decimals);
        totalSupply = 1000000 * multiplier; // 1,000,000 tokens
        rootAddress = msg.sender;        
        Owner = msg.sender;
        balances[rootAddress] = totalSupply; 
    }


    // Only root function

    function changeRoot(address _newrootAddress) onlyRoot returns(bool){
        rootAddress = _newrootAddress;
        return true;
    }

    // Only owner functions

    // To send ERC20 tokens sent accidentally
    function sendToken(address _token,address _to , uint _value) onlyOwner returns(bool) {
        ERC20Basic Token = ERC20Basic(_token);
        require(Token.transfer(_to, _value));
        return true;
    }

    function changeOwner(address _newOwner) onlyOwner returns(bool) {
        Owner = _newOwner;
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


    function burn(uint256 _value) onlyOwner returns(bool) {
        if ( balances[rootAddress] < _value ) revert();
        balances[rootAddress] = safeSub( balances[rootAddress] , _value );
        totalSupply = safeSub( totalSupply,  _value );
        Transfer(rootAddress, 0x0,_value);
        return true;
    }


    // Public getters

    function isLocked() constant returns(bool) {
        return locked;
    }


    // Standard function transfer
    function transfer(address _to, uint _value) isUnlocked returns (bool success) {
        if (balances[msg.sender] < _value) return false;
        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        Transfer(msg.sender,_to,_value);
        return true;
        }


    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {

        if ( locked && msg.sender != Owner && msg.sender != rootAddress ) return false; 
        if ( freezed[_from] || freezed[_to] ) return false; // Check if destination address is freezed
        if ( balances[_from] < _value ) return false; // Check if the sender has enough
    	if ( _value > allowed[_from][msg.sender] ) return false; // Check allowance

        balances[_from] = safeSub(balances[_from] , _value); // Subtract from the sender
        balances[_to] = safeAdd(balances[_to] , _value); // Add the same to the recipient

        allowed[_from][msg.sender] = safeSub( allowed[_from][msg.sender] , _value );

        Transfer(_from,_to,_value);
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