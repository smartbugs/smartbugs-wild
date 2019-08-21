pragma solidity ^0.4.18;

interface IERC20 {
	function TotalSupply() constant returns (uint totalSupply);
	function balanceOf(address _owner) constant returns (uint balance);
	function transfer(address _to, uint _value) returns (bool success);
	function transferFrom(address _from, address _to, uint _value) returns (bool success);
	function approve(address _spender, uint _value) returns (bool success);
	function allowance(address _owner, address _spender) constant returns (uint remaining);
	event Transfer(address indexed _from, address indexed _to, uint _value);
	event Approval(address indexed _owner, address indexed _spender, uint _value);
}

library SafeMath {
	function mul(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a / b;
		return c;
	}

	function sub(uint256 a, uint256 b) internal constant returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}



contract ETHACE is IERC20{
	using SafeMath for uint256;

	uint256 public _totalSupply = 0;

	bool public purchasingAllowed = true;
	bool public bonusAllowed = true;	

	string public symbol = "ETA";
	string public constant name = "ETHACE";
	uint256 public constant decimals = 18;

	uint256 public CREATOR_TOKEN = 20000000 * 10**decimals;
	uint256 public constant RATE = 1000;
	uint PERC_BONUS = 30;	
	
	address public owner;

	mapping(address => uint256) balances;
	mapping(address => mapping(address => uint256)) allowed;

	function() payable{
		require(purchasingAllowed);		
		createTokens();
	}
   
	function ETHACE(){
		owner = msg.sender;
		balances[msg.sender] = CREATOR_TOKEN;
	}
   
	function createTokens() payable{
		require(msg.value >= 0);
		uint256 tokens = msg.value.mul(10 ** decimals);
		tokens = tokens.mul(RATE);
		tokens = tokens.div(10 ** 18);
		if (bonusAllowed)
		{
			tokens += tokens.mul(PERC_BONUS).div(100);
		}
		uint256 sum = _totalSupply.add(tokens);		
		balances[msg.sender] = balances[msg.sender].add(tokens);
		balances[owner] = balances[owner].sub(tokens);
		_totalSupply = sum;
		owner.transfer(msg.value);
		Transfer(owner, msg.sender, tokens);
	}
   
	function TotalSupply() constant returns (uint totalSupply){
		return _totalSupply;
	}
   
	function balanceOf(address _owner) constant returns (uint balance){
		return balances[_owner];
	}
	
	function enablePurchasing() {
		require(msg.sender == owner); 
		purchasingAllowed = true;
	}
	
	function disablePurchasing() {
		require(msg.sender == owner);
		purchasingAllowed = false;
	}   
	
	function enableBonus() {
		require(msg.sender == owner); 
		bonusAllowed = true;
	}
	
	function disableBonus() {
		require(msg.sender == owner);
		bonusAllowed = false;
	}   

	function transfer(address _to, uint256 _value) returns (bool success){
		require(balances[msg.sender] >= _value	&& _value > 0);
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
	}
   
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
		require(allowed[_from][msg.sender] >= _value && balances[msg.sender] >= _value	&& _value > 0);
		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		Transfer(_from, _to, _value);
		return true;
	}
   
	function approve(address _spender, uint256 _value) returns (bool success){
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}
   
	function allowance(address _owner, address _spender) constant returns (uint remaining){
		return allowed[_owner][_spender];
	}
	
	function burnAll() public {		
		require(msg.sender == owner);
		address burner = msg.sender;
		uint256 total = balances[burner];
		total = 0;
		balances[burner] = total;
		if (_totalSupply >= total){
			_totalSupply = _totalSupply.sub(total);
		}
		Burn(burner, total);
	}
	
	function burn(uint256 _value) public {
		require(msg.sender == owner);
        require(_value > 0);
        require(_value <= balances[msg.sender]);
		_value = _value.mul(10 ** decimals);
        address burner = msg.sender;
		uint t = balances[burner].sub(_value);
        balances[burner] = balances[burner].sub(_value);
        if (_totalSupply >= _value){
			_totalSupply = _totalSupply.sub(_value);
		}
        Burn(burner, _value);
	}
		
    function mintToken(uint256 _value) public {
		require(msg.sender == owner);
        require(_value > 0);
		_value = _value.mul(10 ** decimals);
        balances[owner] = balances[owner].add(_value);
        _totalSupply = _totalSupply.add(_value);
        Transfer(0, this, _value);
    }
	
	event Transfer(address indexed _from, address indexed _to, uint _value);
	event Approval(address indexed _owner, address indexed _spender, uint _value);
	event Burn(address indexed burner, uint256 value);	   
}