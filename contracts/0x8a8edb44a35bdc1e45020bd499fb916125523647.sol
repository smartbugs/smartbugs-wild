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

contract SMEToken is StandardToken {

    struct Funder{
        address addr;
        uint amount;
    }
	
    Funder[] funder_list;
	
    // metadata
	uint256 public constant DURATION = 30 days; 
    string public constant name = "SMET";
    string public constant symbol = "SMET";
    uint256 public constant decimals = 0;
    string public version = "1.0";
	
	address account1 = '0xcD4fC8e4DA5B25885c7d80b6C846afb6b170B49b';  //50%   Use Cases and Business Applications
	address account2 = '0x005CD1194C1F088d9bd8BF9e70e5e44D2194C029';  //24%   Blockchain Technology
    address account3 = '0x00d0ACA6D3D07B3546Fc76E60a90ccdccC7c0e0C';  //6%    Mobile APP,SDK Technology
	address account4 = '0x5CA7F20427e4D202777Ea8006dc8f614a289Be2F';  //10%   Mobile Internet Technology
	address account5 = '0x7d49c6a86FDE3dE9c47544c58b7b0F035197415b';  //10%   Marketing


    uint256 val1 = 1 wei;    // 1
    uint256 val2 = 1 szabo;  // 1 * 10 ** 12
    uint256 val3 = 1 finney; // 1 * 10 ** 15
    uint256 val4 = 1 ether;  // 1 * 10 ** 18
	
	address public creator;
	uint256 public sellPrice;
	uint256 public totalSupply;
	uint256 public startTime = 0;   // unix timestamp seconds
	uint256 public endTime = 0;     // unix timestamp seconds
	
    uint256 public constant tokenExchangeRate = 1000; // 1000 SME tokens per 1 ETH

    function setPrices(uint256 newSellPrice) {
        if (msg.sender != creator) throw;
        sellPrice = newSellPrice;
    }
	
	function issue(uint256 amount) {
	    if (msg.sender != creator) throw;
		totalSupply += amount;
	}
	
	function burn(uint256 amount) {
	    if (msg.sender != creator) throw;
		totalSupply -= amount;
	}
	
	function getBalance() returns (uint) {
        return this.balance;
    } 
	
	function getFunder(uint index) public constant returns(address, uint) {
        Funder f = funder_list[index];
        
        return (
            f.addr,
            f.amount
        ); 
    }

    // constructor
    function SMEToken(
	    uint256 initialSupply,
        uint256 initialPrice,
		uint256 initialStartTime
		) {
	    creator = msg.sender;
		totalSupply = initialSupply;
		balances[msg.sender] = initialSupply;
		sellPrice = initialPrice;
		startTime = initialStartTime;
		endTime = initialStartTime + DURATION;
    }

    /// @dev Accepts ether and creates new SME tokens.
    function createTokens() payable {
	    if (now < startTime) throw;
		if (now > endTime) throw;
	    if (msg.value < val4) throw;
		if (msg.value % val4 != 0) throw;
		var new_funder = Funder({addr: msg.sender, amount: msg.value / val4});
		funder_list.push(new_funder);
		
	    uint256 smecAmount = msg.value / sellPrice;
        if (totalSupply < smecAmount) throw;
        if (balances[msg.sender] + smecAmount < balances[msg.sender]) throw; 
        totalSupply -= smecAmount;                     
        balances[msg.sender] += smecAmount;
		
        if(!account1.send(msg.value*50/100)) throw;
		if(!account2.send(msg.value*24/100)) throw;
		if(!account3.send(msg.value*6/100)) throw;
		if(!account4.send(msg.value*10/100)) throw;
		if(!account5.send(msg.value*10/100)) throw;
    }
	
	// fallback
    function() payable {
        createTokens();
    }

}