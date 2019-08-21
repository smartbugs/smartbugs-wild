pragma solidity ^0.4.4;


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


}

contract Snbtoken is ERC20, SafeMath{
	
	mapping(address => uint256) balances;

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
	string 	public name = "SNB - Network for the Blind";
	string 	public symbol = "SNB";
	uint 	public decimals = 0;
	uint 	public INITIAL_SUPPLY = 70000000;

	function Snbtoken() {
	  totalSupply = INITIAL_SUPPLY;
	  balances[msg.sender] = INITIAL_SUPPLY;
	}
}

contract SnbtokenICO is ERC20, SafeMath{

	
	mapping(address => uint256) balances;

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




	uint256 public endTime;
	uint256 public price;

	modifier during_offering_time(){

	    
	    
	    if(now>1513911600)
		{
				price 	= 2231;
		}
		else if(now>1513306800)
		{
		    	price 	= 2491;
		}
		else if(now>1512702000)
		{
		    	price 	= 2708;
		}
		else if(now>1512025200)
		{
		    	price 	= 3032;
		}
        else if(now>1511589600) ///1511589600 ///1511938800
		{
		    	price 	= 3249;
		}
		else
		{
		        price 	= 500;
		}
	    
	    
	    
		if (now >= endTime){
			throw;
		}else{
			_;
		}
	}

	function () payable during_offering_time {
		createTokens(msg.sender);
	}

	function createTokens(address recipient) payable {
		if (msg.value == 0) {
		  throw;
		}


		uint tokens = safeDiv(safeMul(msg.value, price), 1 ether);
		totalSupply = safeAdd(totalSupply, tokens);

		balances[recipient] = safeAdd(balances[recipient], tokens);

		if (!owner.send(msg.value)) {
		  throw;
		}
	}




	string 	public name = "SNB - Network for the Blind";
	string 	public symbol = "SNB";
	uint 	public decimals = 0;
	uint256 public INITIAL_SUPPLY = 70000000;
	uint256 public SALES_SUPPLY = 130000000;
	address public owner;

	function SnbtokenICO() {
		totalSupply = INITIAL_SUPPLY;
		balances[msg.sender] = INITIAL_SUPPLY;

		owner 	= msg.sender;

		price 	= 500;
				


		endTime = 1514617200;
	}

}