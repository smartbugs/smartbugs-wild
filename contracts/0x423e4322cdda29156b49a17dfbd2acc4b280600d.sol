pragma solidity ^0.4.11;

contract SafeMath {
    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        require(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        require(c>=a && c>=b);
        return c;
    }

    function safeDiv(uint a, uint b) internal returns (uint) {
        require(b > 0);
        uint c = a / b;
        require(a == b * c + a % b);
        return c;
    }
}

contract Token {
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/* ERC 20 token */
contract ERC20Token is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
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

    mapping(address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    uint256 public totalSupply;
}


/**
 * CAR ICO contract.
 *
 */
contract CARToken is ERC20Token, SafeMath {

    string public name = "CAR SHARING";
    string public symbol = "CAR";
	uint public decimals = 9;

    address public tokenIssuer = 0x0;
	
    // Unlock time
	uint public month12Unlock = 1546387199;
	uint public month24Unlock = 1577923199;
	uint public month30Unlock = 1593647999;
    uint public month48Unlock = 1641081599;
	uint public month60Unlock = 1672617599;
	
	// End token sale
	uint public endTokenSale = 1577836799;
	
	// Allocated
    bool public month12Allocated = false;
	bool public month24Allocated = false;
	bool public month30Allocated = false;
    bool public month48Allocated = false;
	bool public month60Allocated = false;
	

    // Token count
	uint totalTokenSaled = 0;
    uint public totalTokensCrowdSale = 95000000 * 10**decimals;
    uint public totalTokensReserve = 95000000 * 10**decimals;

	event TokenMint(address newTokenHolder, uint amountOfTokens);
    event AllocateTokens(address indexed sender);

    function CARToken() {
        tokenIssuer = msg.sender;
    }
	
	/* Change issuer address */
    function changeIssuer(address newIssuer) {
        require(msg.sender==tokenIssuer);
        tokenIssuer = newIssuer;
    }

    /* Allocate Tokens */
    function allocateTokens()
    {
        require(msg.sender==tokenIssuer);
        uint tokens = 0;
     
		if(block.timestamp > month12Unlock && !month12Allocated)
        {
			month12Allocated = true;
			tokens = safeDiv(totalTokensReserve, 5);
			balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
			totalSupply = safeAdd(totalSupply, tokens);
            
        }
        else if(block.timestamp > month24Unlock && !month24Allocated)
        {
			month24Allocated = true;
			tokens = safeDiv(totalTokensReserve, 5);
			balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
			totalSupply = safeAdd(totalSupply, tokens);
			
        }
		if(block.timestamp > month30Unlock && !month30Allocated)
        {
			month30Allocated = true;
			tokens = safeDiv(totalTokensReserve, 5);
			balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
			totalSupply = safeAdd(totalSupply, tokens);
            
        }
        else if(block.timestamp > month48Unlock && !month48Allocated)
        {
			month48Allocated = true;
			tokens = safeDiv(totalTokensReserve, 5);
			balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
			totalSupply = safeAdd(totalSupply, tokens);
        }
		else if(block.timestamp > month60Unlock && !month60Allocated)
        {
            month60Allocated = true;
            tokens = safeDiv(totalTokensReserve, 5);
            balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
            totalSupply = safeAdd(totalSupply, tokens);
        }
        else revert();

        AllocateTokens(msg.sender);
    }
    
	/* Mint Token */
    function mintTokens(address tokenHolder, uint256 amountToken) 
    returns (bool success) 
    {
		require(msg.sender==tokenIssuer);
		
		if(totalTokenSaled + amountToken <= totalTokensCrowdSale && block.timestamp <= endTokenSale)
		{
			balances[tokenHolder] = safeAdd(balances[tokenHolder], amountToken);
			totalTokenSaled = safeAdd(totalTokenSaled, amountToken);
			totalSupply = safeAdd(totalSupply, amountToken);
			TokenMint(tokenHolder, amountToken);
			return true;
		}
		else
		{
		    return false;
		}
    }
}