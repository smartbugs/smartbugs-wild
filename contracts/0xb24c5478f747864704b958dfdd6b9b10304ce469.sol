pragma solidity ^0.4.13;
contract owned { 
    
 address public owner;

  function owned() {
      owner = msg.sender;
  }

  modifier onlyOwner {
      require(msg.sender == owner);
      _;
  }

  function transferOwnership(address newOwner) onlyOwner {
      owner = newOwner;
  }
}

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
	      revert();
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
contract PotatoCoin is ERC20, SafeMath, owned{
	
	mapping(address => uint256) balances;

	uint256 public totalSupply;
    uint256 public mulFactor;

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
	
	    balances[_from] = safeSub(balances[_from], _value);
	    balances[_to] = safeAdd(balances[_to], _value);
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
	
	
    function buy() payable { // makes the transfers
        uint amount=safeDiv(safeMul(msg.value,mulFactor),1 ether);
        allowed[this][msg.sender] = amount;
        transferFrom(this,msg.sender,amount);
	    
   
    }
    
    function setMulFactor(uint256 newMulFactor) onlyOwner {
        mulFactor = newMulFactor;
    }
    function addNewPotatoCoinsForSale (uint newTokens) onlyOwner {
        balances[owner] -= newTokens;
        balances[this] += newTokens;
    }
    function destroy() onlyOwner { // so funds not locked in contract forever
      suicide(owner);
    }
    function transferFunds(address _beneficiary, uint amount) onlyOwner {
         transfer(_beneficiary,amount);
    }
    function () payable {
        uint amount=safeDiv(safeMul(msg.value,mulFactor),1 ether);
        allowed[this][msg.sender] = amount;
        transferFrom(this,msg.sender,amount);
    }

	
	string 	public name = "Potato Coin";
	string 	public symbol = "PTCN";
	uint 	public decimals = 0;
	uint 	public INITIAL_SUPPLY = 50000000;
	uint    public INITIAL_mulFactor=280;

	function PotatoCoin() {
	  totalSupply = INITIAL_SUPPLY;
	  mulFactor = INITIAL_mulFactor;
	  balances[msg.sender] = INITIAL_SUPPLY;  // Give all of the initial tokens to the contract deployer.
	  addNewPotatoCoinsForSale (50000);
	    
	}
}