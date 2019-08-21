pragma solidity ^0.4.18;

library SafeMath {
    function add(uint a, uint b) pure internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }

    function sub(uint a, uint b) pure internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function mul(uint a, uint b) pure internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) pure internal returns (uint) {
        uint c = a / b;
        return c;
    }
}

//ECR20 standard interface
contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address account) public constant returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function allowance(address owner, address spender) public constant returns (uint remaining);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed tokenOwner, address indexed spender, uint value);
}

contract Owned {
    address public owner = 0x0;
    address public parentContract = 0x0;
    address public thisContract = 0x0;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }        
}

// ------------------------------------------------------------------------
// RARTokens is the base contract for RAX, AVY and RAZ tokens
// ------------------------------------------------------------------------
contract RARTokens is ERC20, Owned  {
    using SafeMath for uint;
    
    uint private _totalSupply;
    
    string public symbol;
    string public name;
    uint public decimals;  
    
    mapping(address => uint) balances;
    
    mapping(address => mapping (address => uint)) allowed;

    //Constructor receiving the parrent address and the total supply 
    function RARTokens(address parent, uint maxSupply) public {
        _totalSupply = maxSupply;  
        balances[msg.sender] = maxSupply;  
        owner = msg.sender;  
        parentContract= parent;
        thisContract = this;        
    }

    //token total supply
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }
    
    //Gets the balance of the specified address.
    function balanceOf(address account) public constant returns (uint balance) {
        return balances[account];
    }

    //transfer token for a specified address
    function transfer(address to, uint tokens) public returns (bool success) {
        require(to != address(0));
        require(tokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }

    //Transfer tokens from one address to another
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(to != address(0));
        require(tokens <= balances[from]);
        require(tokens <= allowed[from][msg.sender]);
        
        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        Transfer(from, to, tokens);
        return true;
    }    

    //Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }
    
    //Function to check the amount of tokens that an owner allowed to a spender.
    function allowance(address owner, address spender ) public constant returns (uint remaining)
    {
        return allowed[owner][spender];
    }
    
    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // Borrowed from BokkyPooBah   
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20(tokenAddress).transfer(owner, tokens);
    }
}

// ------------------------------------------------------------------------
// RAX Token is on the top of RAR Tokens family.
// ------------------------------------------------------------------------ 
contract RAXToken is RARTokens{
    
    //set the max supply for RAX Token
    uint private  _maxSupply =  23600000 * 10**18;    
    
    //Constructor passing the parent address and the total supply 
    function RAXToken() RARTokens (this, _maxSupply) public {
        
         symbol = "RAX";
         name = "RAX Token";
         decimals = 18;
    }
}

// ------------------------------------------------------------------------
// AVY Token sit in between RAX and RAZ Tokens. 
// ------------------------------------------------------------------------ 
contract AVYToken is RARTokens{

    //set the max supply for AVY Tokens
    uint private  _maxSupply =  38200000 * 10**18;    
    
    //Constructor passing the parent address and the total supply 
    //parent here is RAX Token
    function AVYToken(address parent) RARTokens (parent, _maxSupply) public {
        
        symbol = "AVY";
        name = "AVY Token";
        decimals = 18; 
    } 
}


// ------------------------------------------------------------------------
// RAZ Token is at the bottom of RAR Tokens family.
// ------------------------------------------------------------------------ 
contract RAZToken is RARTokens{

    //set the max supply for RAZ Token
    uint private  _maxSupply =  61800000 * 10**18;    

    //Constructor passing the parent address and the total supply 
    //parent here is AVY Token
    function RAZToken(address parent) RARTokens (parent, _maxSupply) public {
        
        symbol = "RAZ";
        name = "RAZ Token";
        decimals = 18;   
    }
}