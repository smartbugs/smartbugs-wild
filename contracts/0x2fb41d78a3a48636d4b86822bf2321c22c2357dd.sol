pragma solidity ^0.4.10;

contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*  ERC 20 token */
contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {		
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract UGame is StandardToken {
	
    // metadata
	string public constant name = "UGame";
    string public constant symbol = "UGame";
    uint256 public constant decimals = 18;
    string public version = "1.0";
	
    address public creator;                    
    address account1 = '0xBF1BE11D53BC31E05B471296B14eE66F4C0Fe4dc';  //6000W	
	address account2 = '0x0eA6d81D796F113B2Fc420261DE115eE44B2a888';  //1500W 	
	address account3 = '0xc3c4C1F265dcA870389BE76D1846F2b1c47A5983';  //300W
	address account4 = '0xAa3608ca11fb3168EbaD0c9Aa602008655DbBbeb';  //1000W
	address account5 = '0x008B1850BdAAC42Bc050702eDeAA700BFC56f017';  //1200W
	
    uint256 public amount1 = 6000 * 10000 * 10**decimals;
    uint256 public amount2 = 1500 * 10000 * 10**decimals;
	uint256 public amount3 = 300  * 10000 * 10**decimals;
	uint256 public amount4 = 1000 * 10000 * 10**decimals;
	uint256 public amount5 = 1200 * 10000 * 10**decimals;
	

    // constructor
    function UGame() {
	    creator = msg.sender;
		balances[account1] = amount1;                          
		balances[account2] = amount2;                         
		balances[account3] = amount3;                         
		balances[account4] = amount4;
		balances[account5] = amount5;
    }
	
	function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {	
			balances[msg.sender] -= _value;
			balances[_to] += _value;
			Transfer(msg.sender, _to, _value);
			return true;
      } else {
        return false;
      }
    }

}