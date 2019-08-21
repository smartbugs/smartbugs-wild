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
 * CSCJ ICO contract.
 *
 */
contract CSCJToken is ERC20Token, SafeMath {

    string public name = "CSCJ E-GAMBLE";
    string public symbol = "CSCJ";
    uint public decimals = 9;

    address public tokenIssuer = 0x0;
    
    // Unlock time for MAR
    uint public month6Unlock = 1554854400;
    uint public month12Unlock = 1570665600;
    uint public month24Unlock = 1602288000;
    uint public month36Unlock = 1633824000;
    uint public month48Unlock = 1665360000;

    // Unlock time for DAPP
    uint public month9Unlock = 1562716800;
    uint public month18Unlock = 1586476800;
    uint public month27Unlock = 1610236800;
    uint public month45Unlock = 1657411200;
    
    // Allocated MAR
    bool public month6Allocated = false;
    bool public month12Allocated = false;
    bool public month24Allocated = false;
    bool public month36Allocated = false;
    bool public month48Allocated = false;

    // Allocated DAPP
    bool public month9Allocated = false;
    bool public month18Allocated = false;
    bool public month27Allocated = false;
    bool public month36AllocatedDAPP = false;
    bool public month45Allocated = false;
    

    // Token count
    uint totalTokenSaled = 0;
    uint public totalTokensCrowdSale = 95000000 * 10**decimals;
    uint public totalTokensMAR = 28500000 * 10**decimals;
    uint public totalTokensDAPP = 28500000 * 10**decimals;
    uint public totalTokensReward = 38000000 * 10**decimals;


    event TokenMint(address newTokenHolder, uint amountOfTokens);
    event AllocateMARTokens(address indexed sender);
    event AllocateDAPPTokens(address indexed sender);

    function CSCJToken() {
        tokenIssuer = msg.sender;
    }
    
    /* Change issuer address */
    function changeIssuer(address newIssuer) public {
        require(msg.sender==tokenIssuer);
        tokenIssuer = newIssuer;
    }

    /* Allocate Tokens for MAR */
    function allocateMARTokens() public {
        require(msg.sender==tokenIssuer);
        uint tokens = 0;
     
        if(block.timestamp > month6Unlock && !month6Allocated)
        {
            month6Allocated = true;
            tokens = safeDiv(totalTokensMAR, 5);
            balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
            totalSupply = safeAdd(totalSupply, tokens);
            
        }
        else if(block.timestamp > month12Unlock && !month12Allocated)
        {
            month12Allocated = true;
            tokens = safeDiv(totalTokensMAR, 5);
            balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
            totalSupply = safeAdd(totalSupply, tokens);
            
        }
        else if(block.timestamp > month24Unlock && !month24Allocated)
        {
            month24Allocated = true;
            tokens = safeDiv(totalTokensMAR, 5);
            balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
            totalSupply = safeAdd(totalSupply, tokens);
            
        }
        else if(block.timestamp > month36Unlock && !month36Allocated)
        {
            month36Allocated = true;
            tokens = safeDiv(totalTokensMAR, 5);
            balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
            totalSupply = safeAdd(totalSupply, tokens);
        }
        else if(block.timestamp > month48Unlock && !month48Allocated)
        {
            month48Allocated = true;
            tokens = safeDiv(totalTokensMAR, 5);
            balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
            totalSupply = safeAdd(totalSupply, tokens);
        }
        else revert();

        AllocateMARTokens(msg.sender);
    }

    /* Allocate Tokens for DAPP */
    function allocateDAPPTokens() public {
        require(msg.sender==tokenIssuer);
        uint tokens = 0;
     
        if(block.timestamp > month9Unlock && !month9Allocated)
        {
            month9Allocated = true;
            tokens = safeDiv(totalTokensDAPP, 5);
            balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
            totalSupply = safeAdd(totalSupply, tokens);
        }
        else if(block.timestamp > month18Unlock && !month18Allocated)
        {
            month18Allocated = true;
            tokens = safeDiv(totalTokensDAPP, 5);
            balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
            totalSupply = safeAdd(totalSupply, tokens);
            
        }
        else if(block.timestamp > month27Unlock && !month27Allocated)
        {
            month27Allocated = true;
            tokens = safeDiv(totalTokensDAPP, 5);
            balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
            totalSupply = safeAdd(totalSupply, tokens);
            
        }
        else if(block.timestamp > month36Unlock && !month36AllocatedDAPP)
        {
            month36AllocatedDAPP = true;
            tokens = safeDiv(totalTokensDAPP, 5);
            balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
            totalSupply = safeAdd(totalSupply, tokens);
        }
        else if(block.timestamp > month45Unlock && !month45Allocated)
        {
            month45Allocated = true;
            tokens = safeDiv(totalTokensDAPP, 5);
            balances[tokenIssuer] = safeAdd(balances[tokenIssuer], tokens);
            totalSupply = safeAdd(totalSupply, tokens);
        }
        else revert();

        AllocateDAPPTokens(msg.sender);
    }
    
    /* Mint Token */
    function mintTokens(address tokenHolder, uint256 amountToken) public
    returns (bool success)
    {
        require(msg.sender==tokenIssuer);
        
        if(totalTokenSaled + amountToken <= totalTokensCrowdSale + totalTokensReward)
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