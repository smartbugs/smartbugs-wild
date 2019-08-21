pragma solidity >=0.4.22 <0.6.0;

contract IMigrationContract {
    function migrate(address addr, uint256 nas) public returns (bool success);
}

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns(uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    function mul(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x * y;
        assert((x == 0)||(z/x == y));
        return z;
    }
}

contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/// ERC 20 token
contract StandardToken is Token {
    using SafeMath for uint256;
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0x0), "_to == 0");
        require(balances[msg.sender] >= _value, "not enough to pay");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_from != address(0x0), "_from == 0");
        require(_to != address(0x0), "_to == 0");
        require((balances[_from] >= _value && allowed[_from][msg.sender] >= _value), "not enough to pay");

        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0x0), "_spender == 0");

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract BitDiskToken is StandardToken {

    // metadata
    string  public constant name = "BitDisk";
    string  public constant symbol = "BTD";
    uint8 public constant decimals = 18;
    string  public version = "1.0";

    // contracts
    address public ethFundDeposit;              // deposit address for ETH for BTD team
    address public newContractAddr;

    uint256 public tokenMigrated = 0;           // total migrated tokens

    // events
    event AllocateToken(address indexed _to, uint256 _value);
    event IssueToken(address indexed _to, uint256 _value);
    event IncreaseSupply(uint256 _value);
    event DecreaseSupply(uint256 _value);
    event Migrate(address indexed _to, uint256 _value);
    event CreateBTD(address indexed _to, uint256 _value);

    function formatDecimals(uint256 _value) internal pure returns (uint256) {
        return _value * (10 ** uint256(decimals));
    }

    // constructor
    constructor() public {
        ethFundDeposit = msg.sender;

        totalSupply = formatDecimals(2800 * (10 ** 6)); // // two billion and one hundred million and never raised
        balances[msg.sender] = totalSupply;
        emit CreateBTD(ethFundDeposit, totalSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == ethFundDeposit, "auth fail"); 
        _;
    }

    /// new owner
    function changeOwner(address _newFundDeposit) external onlyOwner {
        require(_newFundDeposit != address(0x0), "error addr");
        require(_newFundDeposit != ethFundDeposit, "not changed");

        ethFundDeposit = _newFundDeposit;
    }

    /// update token
    function setMigrateContract(address _newContractAddr) external onlyOwner {
        require(_newContractAddr != address(0x0), "error addr");
        require(_newContractAddr != newContractAddr, "not changed");

        newContractAddr = _newContractAddr;
    }

    function migrate() external {
        require(newContractAddr != address(0x0), "no newContractAddr");

        uint256 tokens = balances[msg.sender];
        require(tokens != 0, "no tokens to migrate");

        balances[msg.sender] = 0;
        tokenMigrated = tokenMigrated.add(tokens);

        IMigrationContract newContract = IMigrationContract(newContractAddr);
        require(newContract.migrate(msg.sender, tokens), "migrate fail");

        emit Migrate(msg.sender, tokens);
    }

    function withdrawEther(uint256 amount) external {
        require(msg.sender == ethFundDeposit, "not owner");
        msg.sender.transfer(amount);
    }
	
	// can accept ether
    function() external payable {
    }
}