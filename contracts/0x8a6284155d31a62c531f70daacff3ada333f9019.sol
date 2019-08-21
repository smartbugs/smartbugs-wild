pragma solidity ^0.4.24;


library Math {


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        if(a == 0) { return 0; }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract ERC20 {


    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Ownable {
    

    address public owner_;
    mapping(address => bool) locked_;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        
        owner_ = msg.sender;
    }

    modifier onlyOwner() {
        
        require(msg.sender == owner_);
        _;
    }

    modifier locked() {
        require(!locked_[msg.sender]);
        _;
    }    

    function transferOwnership(address newOwner) public onlyOwner {
        
        require(newOwner != address(0));
        emit OwnershipTransferred(owner_, newOwner);
        owner_ = newOwner;
    }

    function lock(address owner) public onlyOwner {
        locked_[owner] = true;
    }

    function unlock(address owner) public onlyOwner {
        locked_[owner] = false;
    }    
}


contract BasicToken is ERC20 {
    

    using Math for uint256;
    
    event Burn(address indexed burner, uint256 value);

    uint256 totalSupply_;
    mapping(address => uint256) balances_;
    mapping (address => mapping (address => uint256)) internal allowed_;    

    function totalSupply() public view returns (uint256) {
        
        return totalSupply_;
    }

    function transfer(address to, uint256 value) public returns (bool) {

        require(to != address(0));
        require(value <= balances_[msg.sender]);

        balances_[msg.sender] = balances_[msg.sender].sub(value);
        balances_[to] = balances_[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function balanceOf(address owner) public view returns (uint256 balance) {

        return balances_[owner];
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        require(to != address(0));
        require(value <= balances_[from]);
        require(value <= allowed_[from][msg.sender]);

        balances_[from] = balances_[from].sub(value);
        balances_[to] = balances_[to].add(value);
        allowed_[from][msg.sender] = allowed_[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        
        allowed_[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        
        return allowed_[owner][spender];
    }

    function burn(uint256 value) public {

        require(value <= balances_[msg.sender]);
        address burner = msg.sender;
        balances_[burner] = balances_[burner].sub(value);
        totalSupply_ = totalSupply_.sub(value);
        emit Burn(burner, value);
    }    
}



contract DLOToken is BasicToken, Ownable {

    
    using Math for uint;

    string constant public name     = "Delio";
    string constant public symbol   = "DLO";
    uint8 constant public decimals  = 18;
    uint256 constant TOTAL_SUPPLY   = 5000000000e18;
    
    address constant company1 = 0xa4Fb2C681A51e52930467109d990BbB21857EaCE; // 40
    address constant company2 = 0x0Cc7b6c24f5546a4938F67A3C7A8c29Eba2a0f9d; // 20
    address constant company3 = 0x7c0b9BdA7cAaE0015F17F2664B46DFE293C85BAb; // 20
    address constant company4 = 0x5ca06ad3E9141818049e8fDF6731Ab639A8832AD; // 10
    address constant company5 = 0x3444E9FC958e2e0e706f71ACC7F06211E0580CD2; // 10   


    uint constant rate40 = 2000000000e18;
    uint constant rate20 = 1000000000e18;
    uint constant rate10 = 500000000e18;
    
    constructor() public {

        totalSupply_ = TOTAL_SUPPLY;
        allowTo(company1, rate40);
        allowTo(company2, rate20);
        allowTo(company3, rate20);
        allowTo(company4, rate10);
        allowTo(company5, rate10);
    }

    function allowTo(address addr, uint amount) internal returns (bool) {
        
        balances_[addr] = amount;
        emit Transfer(address(0x0), addr, amount);
        return true;
    }

    function transfer(address to, uint256 value) public locked returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public locked returns (bool) {
        return super.transferFrom(from, to, value);
    }
}