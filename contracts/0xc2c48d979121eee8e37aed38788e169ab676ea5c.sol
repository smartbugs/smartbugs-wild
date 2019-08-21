pragma solidity ^0.4.18;

contract ERC20Interface {
	function totalSupply() public constant returns (uint256 supply);
	function balanceOf(address _owner) public constant returns (uint256 balance);
	function transfer(address _to, uint256 _value) public returns (bool success);
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
	function approve(address _spender, uint256 _value) public returns (bool success);
	function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



contract StandardToken is ERC20Interface {

	function transfer(address _to, uint256 _value) public returns (bool) {
		require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
		balances[msg.sender] -= _value;
		balances[_to] += _value;
		Transfer(msg.sender, _to, _value);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
		require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
		balances[_to] += _value;
		balances[_from] -= _value;
		allowed[_from][msg.sender] -= _value;
		Transfer(_from, _to, _value);
		return true;
	}

	function balanceOf(address _owner) public constant returns (uint256) {
		return balances[_owner];
	}

	function approve(address _spender, uint256 _value) public returns (bool) {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}

	function allowance(address _owner, address _spender) public constant returns (uint256) {
	  return allowed[_owner][_spender];
	}
	
	function totalSupply() public constant returns (uint256 supply) {
		return totalTokens;
	}

	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;
	uint256 public totalTokens;
	
	// Optional vanity variables
	uint8 public decimals;
	string public name;
	string public symbol;
	string public version = '0.1';
}







contract TimCoin is StandardToken {

	address private owner;
	uint256 etherBalance;
	
	function() public payable {
		uint256 amount = msg.value;
		require(amount > 0 && etherBalance + amount > etherBalance);
		etherBalance += amount;
	}
	
	function collect(uint256 amount) public {
		require(msg.sender == owner && amount <= etherBalance);
		owner.transfer(amount);
		etherBalance -= amount;
	}



	function TimCoin() public {
		owner = msg.sender;
		decimals = 18;
		totalTokens = uint(10)**(decimals + 9);
		balances[owner] = totalTokens;
		name = "Tim Coin";
		symbol = "TIM";
	}
	
	function increaseSupply(uint value, address to) public returns (bool) {
		require(value > 0 && totalTokens + value > totalTokens && msg.sender == owner);
		totalTokens += value;
		balances[to] += value;
		Transfer(0, to, value);
		return true;
	}
	
	function decreaseSupply(uint value, address from) public returns (bool) {
		require(value > 0 && balances[from] >= value && msg.sender == owner);
		balances[from] -= value;
		totalTokens -= value;
		Transfer(from, 0, value);
		return true;
	}
}