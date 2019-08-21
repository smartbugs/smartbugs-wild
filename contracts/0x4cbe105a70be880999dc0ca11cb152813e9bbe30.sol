pragma solidity ^0.5.0;

contract ZoeCoin {
    
	uint public totalSupply;
	
	string public name;
	uint256 public decimals;
	string public symbol;
	
	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	
	constructor() public {
		totalSupply = 10000000000000000;
		name = "ZOE Coin";
		decimals = 8;
		symbol = "ZOE";
		balances[msg.sender] = totalSupply;
	}
	
	//Fix for short address attack against ERC20
	modifier onlyPayloadSize(uint size) {
		assert(msg.data.length == size + 4);
		_;
	} 

	function balanceOf(address _owner) public view returns (uint balance) {
		return balances[_owner];
	}

	function transfer(address _recipient, uint _value) public onlyPayloadSize(2*32) {
		require(balances[msg.sender] >= _value && _value > 0);
	    balances[msg.sender] -= _value;
	    balances[_recipient] += _value;
	    emit Transfer(msg.sender, _recipient, _value);        
    }

	function transferFrom(address _from, address _to, uint _value) public {
		require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
    }
    
    function burn(uint _value) public returns (bool success) {
        require(balances[msg.sender] >= _value &&  _value > 0);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

	function approve(address _spender, uint _value) public {
	    require(_value > 0); 
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
	}

	function allowance(address _spender, address _owner) public view returns (uint balance) {
		return allowed[_owner][_spender];
	}
	
	//Event which is triggered to log all transfers to this contract's event log
	event Transfer(address indexed _from, address indexed _to, uint _value);
		
	//Event which is triggered whenever an owner approves a new allowance for a spender.
	event Approval(address indexed _owner,	address indexed _spender, uint _value);
	
	//Event which is triggered to notifies clients about the amount burnt.
	event Burn(address indexed _from, uint value);
}