pragma solidity ^0.4.24;
 
contract IMigrationContract {
    function migrate(address addr, uint256 nas) returns (bool success);
}
 

contract SafeMath {

    function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }
 
    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }
 
    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
        uint256 z = x * y;
        assert((x == 0)||(z/x == y));
        return z;
    }
 
}
 
contract Token {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
 
 
/*  ERC 20 token */
contract StandardToken is Token {
 
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }
 
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }
 
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
 
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
 
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
 
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}
 
contract ACCTToken is StandardToken, SafeMath {
 
    // metadata
    string  public constant name = "ACCTToken";
    string  public constant symbol = "ACCT";
    uint256 public constant decimals = 21;
    string  public version = "1.0";
 
    // contracts
    // ETH Deposit Address
    address public ethFundDeposit;   
    //Token update address
    address public newContractAddr;      
 
    // crowdsale parameters
    //Switch state to true
    bool    public isFunding;               
    uint256 public fundingStartBlock;
    uint256 public fundingStopBlock;
    
    
    //Number of tokens on sale
    uint256 public currentSupply;   
    //Total sales volume token
    uint256 public tokenRaised = 0;  
    //Total traded token
    uint256 public tokenMigrated = 0;  
   
 
    // events
    event IncreaseSupply(uint256 _value);
    event DecreaseSupply(uint256 _value);
    event Migrate(address indexed _to, uint256 _value);
 
    // 转换
    function formatDecimals(uint256 _value) internal returns (uint256 ) {
        return _value * 10 ** decimals;
    }
 
    // constructor
    function ACCTToken(
        address _ethFundDeposit,
        uint256 _currentSupply)
    {
        ethFundDeposit = _ethFundDeposit;
 
        isFunding = false;                           //通过控制预CrowdS ale状态
        fundingStartBlock = 0;
        fundingStopBlock = 0;
 
        currentSupply = formatDecimals(_currentSupply);
        totalSupply = formatDecimals(10000000000);
        balances[msg.sender] = totalSupply;
        if(currentSupply > totalSupply) throw;
    }
 
    modifier isOwner()  { require(msg.sender == ethFundDeposit); _; }

 
    /// @dev 被盗token处理
    function decreaseSupply (uint256 _value) isOwner external {
        uint256 value = formatDecimals(_value);
        if (value + tokenRaised > currentSupply) throw;
 
        currentSupply = safeSubtract(currentSupply, value);
        DecreaseSupply(value);
    }
 
   
    function startFunding (uint256 _fundingStartBlock, uint256 _fundingStopBlock) isOwner external {
        if (isFunding) throw;
        if (_fundingStartBlock >= _fundingStopBlock) throw;
        if (block.number >= _fundingStartBlock) throw;
 
        fundingStartBlock = _fundingStartBlock;
        fundingStopBlock = _fundingStopBlock;
        isFunding = true;
    }
 
   
    function stopFunding() isOwner external {
        if (!isFunding) throw;
        isFunding = false;
    }

   
    function changeOwner(address _newFundDeposit) isOwner() external {
        if (_newFundDeposit == address(0x0)) throw;
        ethFundDeposit = _newFundDeposit;
    }
 
 
    function migrate() external {
        if(isFunding) throw;
        if(newContractAddr == address(0x0)) throw;
 
        uint256 tokens = balances[msg.sender];
        if (tokens == 0) throw;
 
        balances[msg.sender] = 0;
        tokenMigrated = safeAdd(tokenMigrated, tokens);
 
        IMigrationContract newContract = IMigrationContract(newContractAddr);
        if (!newContract.migrate(msg.sender, tokens)) throw;
 
        Migrate(msg.sender, tokens);               // log it
    }
 
}