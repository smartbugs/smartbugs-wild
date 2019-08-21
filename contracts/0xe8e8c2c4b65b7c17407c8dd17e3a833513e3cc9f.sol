pragma solidity ^0.4.18;

contract BurnableERC20Token {
	uint256 public totalSupply;
	string public name;
	uint8 public decimals;
	string public symbol;
	address public owner;
	
	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	event Burn(address indexed _from, uint256 _value);
	event SetOwner(address indexed _prevOwner, address indexed _owner);
	
	constructor(uint256 _totalSupply, uint8 _decimals, string _symbol, string _name) public {
		decimals = _decimals;
		symbol = _symbol;
		name = _name;
		owner = msg.sender;
		totalSupply = _totalSupply * (10 ** uint256(decimals));
		balances[msg.sender] = totalSupply;
	}
	
	function balanceOf(address _owner) constant public returns (uint256) {
		return balances[_owner];
	}
	
	function transfer(address _to, uint256 _value) public {
		require(_to != 0x0 && balances[msg.sender] >= _value && _value > 0);
		balances[msg.sender] -= _value;
		balances[_to] += _value;
		Transfer(msg.sender, _to, _value);
	}
	
	function transferFrom(address _from, address _to, uint256 _value) public {
		require(_to != 0x0 && balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
		balances[_to] += _value;
		balances[_from] -= _value;
		allowed[_from][msg.sender] -= _value;
		Transfer(_from, _to, _value);
	}
	
	function approve(address _spender, uint256 _value) public {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
	}
	
	function allowance(address _owner, address _spender) constant public returns (uint256) {
		return allowed[_owner][_spender];
	}
	
	function burn(uint256 _value) public returns (bool _success) {
	    require(msg.sender == owner && balances[msg.sender] >= _value);
	    balances[msg.sender] -= _value;
	    totalSupply -= _value;
	    Burn(msg.sender, _value);
	    _success = true;
	}
	
	function setOwner(address _owner) public returns(bool _success) {
	    require(_owner != 0x0 && msg.sender == owner);
	    address prevOwner = owner;
	    owner = _owner;
	    SetOwner(prevOwner, owner);
	    _success = true;
	}
}