pragma solidity ^0.4.19;

/**
    Wałęsa, dawaj moje sto milionów!
    https://www.youtube.com/watch?v=ZBK_nZ1aGlA
    
    100 million of this token can be claimed by first 12197466 users,
    who make a transfer or call walesaDawajMojeStoMilionow() function.
 */
contract WalesaToken {
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    uint256 constant private STO_MILIONOW = 10000000000;
    
    string constant public symbol = "WLST";
    string constant public name = "Wałęsa Token";
    uint8 constant public decimals = 2;
    
    uint256 public totalSupply;
    uint256 private claimedSupply;
    
    mapping (address => bool) private claimed;
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;
    
    function WalesaToken() public {
        totalSupply = 0xBA1E5A * STO_MILIONOW;
    }
    
    function balanceOf(address owner) public view returns (uint256) {
        if (!claimed[owner] && claimedSupply < totalSupply) {
            return STO_MILIONOW;
        }
        return balances[owner];
    }
    
    function transfer(address to, uint256 value) public returns (bool) {
        walesaDawajNaszeStoMilionow(msg.sender);
        walesaDawajNaszeStoMilionow(to);
        require(balances[msg.sender] >= value);
        balances[msg.sender] -= value;
        balances[to] += value;
        Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(allowed[from][msg.sender] >= value);
        if (allowed[from][msg.sender] < MAX_UINT256) {
            allowed[from][msg.sender] -= value;
        }
        walesaDawajNaszeStoMilionow(from);
        walesaDawajNaszeStoMilionow(to);
        require(balances[from] >= value);
        balances[from] -= value;
        balances[to] += value;
        Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint256 value) public returns (bool) {
        require(allowed[msg.sender][spender] == 0 || value == 0);
        allowed[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }
    
    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }
    
    function walesaDawajMojeStoMilionow() public {
        walesaDawajNaszeStoMilionow(msg.sender);
    }
    
    function walesaDawajNaszeStoMilionow(address owner) private {
        if (!claimed[owner] && claimedSupply < totalSupply) {
            claimed[owner] = true;
            balances[owner] = STO_MILIONOW;
            claimedSupply += STO_MILIONOW;
        }
    }
}