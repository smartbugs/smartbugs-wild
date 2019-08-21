pragma solidity ^0.4.19;

contract ERC20 {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}


contract MainToken is ERC20{
    string public constant name = "MemRobot";
    string public constant symbol = "ROBOT";
    uint8 public constant decimals = 18;
    
    address founder;
    uint256 public totalAmount;
    
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    function MainToken() public{
        founder = msg.sender;
        uint256 amount = 2 * 10**8 * 10**18;
        
        balances[founder] = amount;
        totalAmount = amount;
    }
    
    function totalSupply() public constant returns (uint){
        return totalAmount;
    }

    function balanceOf(address tokenOwner) public constant returns (uint the_balance){
        return balances[tokenOwner];
    }
    
    function _transfer(address from, address to, uint tokens) private returns (bool success){
        require(tokens <= balances[from]);
        balances[from] -= tokens;
        balances[to] += tokens;
        Transfer(from, to, tokens);
        return true;
    }

    function transfer(address to, uint tokens) public returns (bool success){
        return _transfer(msg.sender, to, tokens);
    }
    
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }
    
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining){
        return allowed[tokenOwner][spender];
    }
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(allowed[from][msg.sender] >= tokens);
        
        allowed[from][msg.sender] -= tokens;
        _transfer(from, to, tokens);
        return true;
    }
}