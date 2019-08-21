contract SafeMath{
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }
	
	function safeSub(uint a, uint b) internal returns (uint) {
    	assert(b <= a);
    	return a - b;
  }

	function safeAdd(uint a, uint b) internal returns (uint) {
    	uint c = a + b;
    	assert(c >= a);
    	return c;
  }
	function assert(bool assertion) internal {
	    if (!assertion) {
	      throw;
	    }
	}
}


contract ERC20{

 	function totalSupply() constant returns (uint256 totalSupply) {}
	function balanceOf(address _owner) constant returns (uint256 balance) {}
	function transfer(address _recipient, uint256 _value) returns (bool success) {}
	function transferFrom(address _from, address _recipient, uint256 _value) returns (bool success) {}
	function approve(address _spender, uint256 _value) returns (bool success) {}
	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

	event Transfer(address indexed _from, address indexed _recipient, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burn(address indexed _owner,  uint256 _value);

}

contract GSD is ERC20, SafeMath{
	
	mapping(address => uint256) balances;
	address public owner = msg.sender;

	uint256 public totalSupply;


	function balanceOf(address _owner) constant returns (uint256 balance) {
	    return balances[_owner];
	}

	function transfer(address _to, uint256 _value) returns (bool success){
	    balances[msg.sender] = safeSub(balances[msg.sender], _value);
	    balances[_to] = safeAdd(balances[_to], _value);
	    Transfer(msg.sender, _to, _value);
	    return true;
	}

	mapping (address => mapping (address => uint256)) allowed;

	function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
	    var _allowance = allowed[_from][msg.sender];
	    
	    balances[_to] = safeAdd(balances[_to], _value);
	    balances[_from] = safeSub(balances[_from], _value);
	    allowed[_from][msg.sender] = safeSub(_allowance, _value);
	    Transfer(_from, _to, _value);
	    return true;
	}

	function approve(address _spender, uint256 _value) returns (bool success) {
	    allowed[msg.sender][_spender] = _value;
	    Approval(msg.sender, _spender, _value);
	    return true;
	}

	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
	    return allowed[_owner][_spender];
	}
	
	function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
    address burner = msg.sender;
    balances[burner] = safeSub(balances[burner],_value);
    totalSupply=safeSub(totalSupply,_value);
    Burn(burner, _value);
  }
	
	function recycle (uint256 _value) returns (bool success){
	    balances[msg.sender] = safeSub(balances[msg.sender], _value);
	    balances[address(this)] = safeAdd(balances[address(this)], _value);
	    Transfer(msg.sender, address(this), _value);
	    return true;
	}
	
	function harvest () returns (bool success) {
	    require(msg.sender == owner);
	  
	  uint256[] times;
	  times[0]=1516746600; //10:30 1516747200
	  times[1]=1516748400; //11:00
	  
	  bool itsTime=false;
	  //uint256 starttime = 1518566400; //2018
	  
	  for (uint i=0; i<times.length;i++){
	      if ( now >= times[i] && now <=(times[i]+600) ) 
	      {itsTime=true; break;}
	  }
	  
	 
	 require(itsTime);
	 
	 uint256 Bal=balances[address(this)];
	 balances[owner] = safeAdd(Bal, balances[owner]);
	 balances[address(this)]=0;
	 Transfer(address(this),owner,Bal);
	 return true;
	  
	}
	
	string 	public name = "GSD";
	string 	public symbol = "GSD";
	uint 	public decimals = 18;
	uint 	public INITIAL_SUPPLY = 20000000000;

	function GSD() {
	  totalSupply = INITIAL_SUPPLY;
	  balances[msg.sender] = INITIAL_SUPPLY;  // Give all of the initial tokens to the contract deployer.
	}
}