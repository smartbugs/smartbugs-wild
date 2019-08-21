pragma solidity 0.4.25;

contract MMEToken {
    string public constant name = "MME Token";
    string public constant symbol = "MME";
    uint8 public constant decimals = 18;
    address public owner;
    uint256 public _totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() public {
        owner = msg.sender;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }
   
    function allowance(
        address tokenOwner, 
        address spender
    )
        public 
        view 
        returns (uint256) 
    {
        return allowed[tokenOwner][spender];
    }


    function transfer(address to, uint256 value) public returns (bool) {
        require(balances[msg.sender] >= value);
        require(to != address(0));
        
        balances[msg.sender] -= value;
        balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

   function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        
        allowed[msg.sender][spender] = value; 
        emit Approval(msg.sender, spender, value);
        return true;
    }

    
   function transferFrom(
        address from, 
        address to, 
        uint256 value
    ) 
        public 
        returns (bool) 
    {
        require(allowed[from][msg.sender] >= value);
        require(balances[from] >= value);
        require(to != address(0));
        
        allowed[from][msg.sender] -= value;
        balances[from] -= value;
        balances[to] += value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function mint(address to, uint256 value) public returns(bool) {
        require(msg.sender == owner);
        require(to != address(0));
        
        _totalSupply += value;
        balances[to] += value;
        emit Transfer(address(0), to, value);
        return true;
    }
}

contract Crowdsale {
    address public wallet = 0x11; // placeholder
    uint256 public rate = 1;
    MMEToken public token;
    
    constructor() public {
        token = new MMEToken();
    }
    
    function buyTokens() public payable {
        require(msg.value != 0);
        uint256 tokenAmount = msg.value * rate;
        token.mint(msg.sender, tokenAmount);
        wallet.transfer(msg.value);
    }
}