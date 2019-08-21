pragma solidity ^0.4.24;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
// input  D:\MDZA-TESTNET1\solidity-flattener\SolidityFlatteryGo\contract\MDZAToken.sol
// flattened :  Sunday, 30-Dec-18 09:30:12 UTC
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}
contract ERCInterface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    event Burn(address indexed from, uint256 value);
    event FrozenFunds(address target, bool frozen);
}
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
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
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract MDZAToken is ERCInterface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;
    bool transactionLock;

    // Balances for each account
    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;

    mapping (address => bool) public frozenAccount;

    // Constructor . Please change the values 
    constructor() public {
        symbol = "MDZA";
        name = "MEDOOZA Ecosystem v1.1";
        decimals = 10;
        _totalSupply = 1200000000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        transactionLock = false;
        emit Transfer(address(0), owner, _totalSupply);
    }

    // Get total supply
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }

    // Get the token balance for specific account
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    // Transfer the balance from token owner account to receiver account
    function transfer(address to, uint tokens) public returns (bool success) {
        require(to != 0x0); // Prevent transfer to 0x0 address. Use burn() instead
        require(!transactionLock);  // Check for transaction lock
        require(!frozenAccount[to]);// Check if recipient is frozen
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    // Token owner can approve for spender to transferFrom(...) tokens from the token owner's account
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // Transfer token from spender account to receiver account
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(to != 0x0); // Prevent transfer to 0x0 address. Use burn() instead
        require(!transactionLock);         // Check for transaction lock
        require(!frozenAccount[from]);     // Check if sender is frozen
        require(!frozenAccount[to]);       // Check if recipient is frozen
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    // Get tokens that are approved by the owner 
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // Token owner can approve for spender to transferFrom(...) tokens
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    // Don't accept ETH 
    function () public payable {
        revert();
    }

    // Transfer any ERC Token
    function transferAnyERCToken(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERCInterface(tokenAddress).transfer(owner, tokens);
    }

    // Burn specific amount token
    function burn(uint256 tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        _totalSupply = _totalSupply.sub(tokens);
        emit Burn(msg.sender, tokens);
        return true;
    }

    // Burn token from specific account and with specific value
    function burnFrom(address from, uint256 tokens) public  returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        _totalSupply = _totalSupply.sub(tokens);
        emit Burn(from, tokens);
        return true;
    }

    // Freeze and unFreeze account from sending and receiving tokens
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    // Get status of a locked account
    function freezeAccountStatus(address target) onlyOwner public view returns (bool response){
        return frozenAccount[target];
    }

    // Lock and unLock all transactions
    function lockTransactions(bool lock) public onlyOwner returns (bool response){
        transactionLock = lock;
        return lock;
    }

    // Get status of global transaction lock
    function transactionLockStatus() public onlyOwner view returns (bool response){
        return transactionLock;
    }
}