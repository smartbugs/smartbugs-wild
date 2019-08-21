contract Token {
    string public symbol = "WJT";
    string public name = "Wojak Token";
    uint8 public constant decimals = 18;
    uint256 _totalSupply = 0;
    uint nextHalvingDate = 1577836800; //01 Jan 2020
	uint initialMintReward = 320000000000000000000000; //320,000 coins
	uint mintReward = initialMintReward;
	uint mintCalls = 0;
   
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 
    mapping(address => uint256) balances;
 
    mapping(address => mapping (address => uint256)) allowed;
 
    function totalSupply() constant returns (uint256 totalSupply) {        
        return _totalSupply;
    }
 
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
 
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
 
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
 
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
 
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
	
	function Mint() {
		if (now > nextHalvingDate)
		{
			mintReward = mintReward / 2;
			nextHalvingDate = nextHalvingDate + 31536000; //+ 1 year
		}
		balances[msg.sender] += mintReward;
		_totalSupply += mintReward;
		Transfer(this, msg.sender, mintReward);
		mintCalls += 1;
	}
	
	function NextHalvingDate() constant returns(uint256) { return nextHalvingDate;}
	function InitialMintReward() constant returns(uint256) { return initialMintReward;}
	function MintReward() constant returns(uint256) { return mintReward;}
	function MintCalls() constant returns(uint256) { return mintCalls;}
}