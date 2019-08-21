pragma solidity >=0.4.12 <0.7.0;
 
contract IMigrationContract {
    function migrate(address addr, uint256 nas) public returns (bool success);
}
 

contract SafeMath {
 
 
    function safeAdd(uint256 x, uint256 y) pure internal returns(uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }
 
    function safeSubtract(uint256 x, uint256 y) pure internal returns(uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }
 
    function safeMult(uint256 x, uint256 y) pure internal returns(uint256) {
        uint256 z = x * y;
        assert((x == 0)||(z/x == y));
        return z;
    }
 
}
 
contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) view public returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
 
 
/*  ERC 20 token */
contract StandardToken is Token {
 
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }
 
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }
 
    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }
 
    function approve(address _spender, uint256 _value) public returns (bool success) {
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
 
contract GMCToken is StandardToken, SafeMath {
 
    // metadata
    string  public constant name = "GMCToken";
    string  public constant symbol = "GMC";
    uint256 public constant decimals = 18;
    string  public version = "1.0";
 
    // contracts
    address public ethFundDeposit;
    address public newContractAddr;
 
    // crowdsale parameters
    bool    public isFunding;
    uint256 public fundingStartBlock;
    uint256 public fundingStopBlock;
 
    uint256 public currentSupply;
    uint256 public tokenRaised = 0;
    uint256 public tokenMigrated = 0;
    uint256 public tokenExchangeRate = 6250;
 
    // events
    event AllocateToken(address indexed _to, uint256 _value);
    event IssueToken(address indexed _to, uint256 _value);
    event IncreaseSupply(uint256 _value);
    event DecreaseSupply(uint256 _value);
    event Migrate(address indexed _to, uint256 _value);
 
    function formatDecimals(uint256 _value)pure internal returns (uint256 ) {
        return _value * 10 ** decimals;
    }
 
    // constructor
    constructor (
        address _ethFundDeposit,
        uint256 _currentSupply) public
    {
        ethFundDeposit = _ethFundDeposit;
 
        isFunding = false; 
        fundingStartBlock = 0;
        fundingStopBlock = 0;
 
        currentSupply = formatDecimals(_currentSupply);
        totalSupply = formatDecimals(1000000000); 
        balances[msg.sender] = totalSupply;
        if(currentSupply > totalSupply) revert();
    }
 
    modifier isOwner()  { require(msg.sender == ethFundDeposit); _; }
 
    function setTokenExchangeRate(uint256 _tokenExchangeRate) isOwner external {
        if (_tokenExchangeRate == 0) revert();
        if (_tokenExchangeRate == tokenExchangeRate) revert();
 
        tokenExchangeRate = _tokenExchangeRate;
    }
 
    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) isOwner external {
        if (isFunding) revert();
        if (_fundingStartBlock >= _fundingStopBlock) revert();
        if (block.number >= _fundingStartBlock) revert();
 
        fundingStartBlock = _fundingStartBlock;
        fundingStopBlock = _fundingStopBlock;
        isFunding = true;
    }
 
    function stopFunding() isOwner external {
        if (!isFunding) revert();
        isFunding = false;
    }
 
    function setMigrateContract(address _newContractAddr) isOwner external {
        if (_newContractAddr == newContractAddr) revert();
        newContractAddr = _newContractAddr;
    }
 
    function changeOwner(address _newFundDeposit) isOwner() external {
        if (_newFundDeposit == address(0x0)) revert();
        ethFundDeposit = _newFundDeposit;
    }
 
    function migrate() external {
        if(isFunding) revert();
        if(newContractAddr == address(0x0)) revert();
 
        uint256 tokens = balances[msg.sender];
        if (tokens == 0) revert();
 
        balances[msg.sender] = 0;
        tokenMigrated = safeAdd(tokenMigrated, tokens);
 
        IMigrationContract newContract = IMigrationContract(newContractAddr);
        if (!newContract.migrate(msg.sender, tokens)) revert();
 
        emit Migrate(msg.sender, tokens);               // log it
    }
 
    function allocateToken (address _addr, uint256 _eth) isOwner external {
        if (_eth == 0) revert();
        if (_addr == address(0x0)) revert();
 
        uint256 tokens = safeMult(formatDecimals(_eth), tokenExchangeRate);
        if (tokens + tokenRaised > currentSupply) revert();
 
        tokenRaised = safeAdd(tokenRaised, tokens);
        balances[_addr] += tokens;
 
        emit AllocateToken(_addr, tokens);
    }
 
    function () payable external {
        if (!isFunding) revert();
        if (msg.value == 0) revert();
 
        if (block.number < fundingStartBlock) revert();
        if (block.number > fundingStopBlock) revert();
 
        uint256 tokens = safeMult(msg.value, tokenExchangeRate);
        if (tokens + tokenRaised > currentSupply) revert();
 
        tokenRaised = safeAdd(tokenRaised, tokens);
        balances[msg.sender] += tokens;
 
        emit IssueToken(msg.sender, tokens);
    }
}