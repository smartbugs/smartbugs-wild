pragma solidity 0.4.25;

/**
 * @title Homburger Token
 * @author Homburger Team
 *
 */
contract HomburgerToken {
    string public constant name = "Homburger Token";
    string public constant symbol = "HOM2";
    uint256 public constant decimal = 18;
    
    address public owner;
    uint256 private _totalSupply;
    bool private _paused;
    
    mapping(address=>uint256) private balances;
    mapping(address=>mapping(address=>uint256)) private allowed;
    
    event Transfer(address from, address to, uint256 value);
    event Approval(address tokenHolder, address spender, uint256 value);
    
    constructor() public {
        owner = msg.sender;
        _paused = true;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }
    
    modifier whenPaused() {
        require(_paused);
        _;
    }
    
    function balanceOf(address tokenHolder) public view returns (uint256) {
        return balances[tokenHolder];
    }
    
    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }
    
    function transfer(address to, uint256 value) public whenNotPaused returns(bool) {
        require(balances[msg.sender] >= value);
        require(to != address(0));
        
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function allowance(address tokenHolder, address spender) public view returns(uint256) {
        return allowed[tokenHolder][spender];
    }
    
    function approve(address spender, uint256 value) public whenNotPaused returns(bool) {
        require(spender != address(0));
        
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns(bool) {
        require(allowed[from][msg.sender] >= value);
        require(balances[from] >= value);
        require(to != address(0));
        
        allowed[from][msg.sender] -= value;
        balances[from] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function mint(address to, uint256 value) public onlyOwner returns(bool) {
        require(to != address(0));
        
        _totalSupply += value; // totalSupply = totalSupply + value
        balances[to] += value;
        emit Transfer(address(0), to , value);
        return true;
    }
    
    function paused() public view returns(bool) {
        return _paused;
    }
    
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
    }
    
    function unpause() public onlyOwner whenPaused {
        _paused = false;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        
        owner = newOwner;
    }
}