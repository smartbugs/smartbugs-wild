pragma solidity ^0.5.0;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract GasToken is ERC20Interface {
    // Public variables of the token
    string public constant name = "Gas";
    string public constant symbol = "GAS";
    uint8 public constant decimals = 18;
    
    uint256 public _totalSupply;

    mapping (address => uint256) balances;
    
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;

    constructor() public {
        _totalSupply = 0;
    }
    
    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }
    
    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Buy gas at the transaction's gas gasprice.
    // ------------------------------------------------------------------------
    function buy() public payable returns (uint tokens) {
        tokens = msg.value / tx.gasprice;
        balances[msg.sender] += tokens;
        _totalSupply += tokens;
        return tokens;
    }
    
    // ------------------------------------------------------------------------
    // Sell gas at the transaction's gas gasprice.
    // ------------------------------------------------------------------------    
    function sell(uint tokens) public returns (uint revenue) {
        require(balances[msg.sender] >= tokens);           // Check if the sender has enough
        balances[msg.sender] -= tokens;        
        _totalSupply -= tokens;
        revenue = tokens * tx.gasprice;
        msg.sender.transfer(revenue);
        return revenue;
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        require(balances[msg.sender] >= tokens);           // Check if the sender has enough
        require(balances[to] + tokens >= balances[to]);  // Check for overflows
        balances[msg.sender] -= tokens;                    // Subtract from the sender
        balances[to] += tokens;                           // Add the same to the recipient
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    // Send `tokens` amount of tokens from address `from` to address `to`
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(balances[msg.sender] >= tokens);
        require(allowed[from][msg.sender] >= tokens);
        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;
        balances[to] += tokens;
        emit Transfer(from, to, tokens);
        return true;
    }
 
    // Allow `spender` to withdraw from your account, multiple times, up to the `tokens` amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert();
    }
}