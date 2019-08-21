pragma solidity ^0.4.19;

// ----------------------------------------------------------------------------
// (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
// modified by team garry, thanks heaps BokkyPooBah!
//
// massive shoutout to https://cryptozombies.io
// best solidity learning series out there!
// wait what's to come after Garrys coin :) there must be a Garrys game
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


// ----------------------------------------------------------------------------
// Contract owner and transfer functions
// just in case someone wants to get my bacon
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 compliant Garry token :)
// Receives ETH and generates Garrys, the world needs more Garrys
// Limited to 10000 on this planet, yup
// 1 Garry can be exchanged for 1 creature in our upcoming game
// ----------------------------------------------------------------------------
contract Garrys is ERC20Interface, Owned {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    uint public _maxSupply;
    uint public _ratio;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    address GameContract;
    
    // ------------------------------------------------------------------------
    // Launched once when contract starts
    // ------------------------------------------------------------------------
    function Garrys() public {
        symbol = "GAR";
        name = "Garrys";
        decimals = 18;
        // the first coin goes to Garry cause, it's a Garry :P, adding it to total supply here
        _totalSupply = 1 * 10**uint(decimals);      
        // set ratio, get 100 Garrys for 1 Ether
        _ratio = 100;
        // there can never be more than 10000 Garrys in existence, doubt the world can handle 2 :D
        _maxSupply = 10000 * 10**uint(decimals);    
        balances[owner] = _totalSupply;
        // transfer inital coin to Garry, which is 1
        Transfer(address(0), owner, _totalSupply);
    }


    // ------------------------------------------------------------------------
    // Total supply
    // to safe gas, address(0) is removed since it never holds Garrys
    // they are minted and not initially transferred to address(0)
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }
    

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        require(balances[msg.sender] >= tokens);
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        Transfer(msg.sender, to, tokens);
        return true;
    }
    

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    // 
    // The calling account must already have sufficient tokens approve(...)
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require (allowed[from][msg.sender] >= tokens);
        require (balances[from] >= tokens);
        
        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;
        balances[to] += tokens;
        Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Tokens per Ethererum at a ratio of 100:1
    // But you need to buy at least 0.0001 Garrys to avoid spamming (currently 5 $cent)
    // ------------------------------------------------------------------------
    function () public payable {
        require(msg.value >= 1000000000000);
        require(_totalSupply+(msg.value*_ratio)<=_maxSupply);
        
        uint tokens;
        tokens = msg.value*_ratio;

        balances[msg.sender] += tokens;
        _totalSupply += tokens;
        Transfer(address(0), msg.sender, tokens);
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // Only if he is in the mood though, I won't give a damn if you are an annoying bot
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }


    // ------------------------------------------------------------------------
    // Query Ethereum of contract
    // ------------------------------------------------------------------------
    function weiBalance() public constant returns (uint weiBal) {
        return this.balance;
    }


    // ------------------------------------------------------------------------
    // Send Contracts Ethereum to address owner
    // ------------------------------------------------------------------------
    function weiToOwner(address _address, uint amount) public onlyOwner {
        require(amount <= this.balance);
        _address.transfer(amount);
    }
}