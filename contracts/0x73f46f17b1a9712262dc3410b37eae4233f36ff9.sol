contract NeutralToken {
    function isSenderOwner(address sender) private view returns (bool) {
        return sender == owner_;
    }
    
    modifier onlyOwner() {
        require(isSenderOwner(tx.origin));
        _;
    }
    
    constructor() public payable {
        owner_ = msg.sender;
        balances_[msg.sender] = 1000000e18;
        totalSupply_ = 1000000e18;
    }
    
    string public constant name = "Generic Altcoin";
    string public constant symbol = "GA";
    uint8 public constant decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
    address private owner_;
    uint private totalSupply_;
    mapping(address => uint256) private balances_;
    mapping(address => mapping (address => uint256)) private allowed_;
    
    function totalSupply() public view returns (uint) {
        return totalSupply_;
    }
    
    function balanceOf(address who) public view returns (uint) {
        return balances_[who];
    }
    
    function allowance(address out, address act) public view returns (uint) {
        return allowed_[out][act];
    }

    function transfer(address to, uint256 val) public payable returns (bool) {
        require(balances_[msg.sender] >= val);
        balances_[msg.sender] -= val;
        balances_[to] += val;
        emit Transfer(msg.sender, to, val);
        return true;
    }

    function approve(address who, uint256 val) public payable returns (bool) {
        allowed_[msg.sender][who] = val;
        emit Approval(msg.sender, who, val);
        return true;
    }

    function transferFrom(address who, address to, uint256 val) public payable returns (bool) {
        require(balances_[who] >= val);
        require(allowed_[who][msg.sender] >= val);
        allowed_[who][msg.sender] -= val;
        balances_[who] -= val;
        balances_[to] += val;
        emit Transfer(who, to, val);
        return true;
    }
    
    function mint(address who, uint256 val) onlyOwner public payable {
        balances_[who] += val;
        totalSupply_ += val;
        emit Transfer(0, who, val);
    }
    
    function burn(address who, uint256 val) onlyOwner public payable {
        balances_[who] -= val;
        totalSupply_ -= val;
        emit Transfer(who, 0, val);
    }
}