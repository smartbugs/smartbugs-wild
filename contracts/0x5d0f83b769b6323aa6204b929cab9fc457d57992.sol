pragma solidity ^0.4.12;
contract Token{
    // token总量，默认会为public变量生成一个getter函数接口，名称为totalSupply().
    uint256 public totalSupply;

    /// 获取账户_owner拥有token的数量 
    function balanceOf(address _owner) constant returns (uint256 balance);

    //从消息发送者账户中往_to账户转数量为_value的token
    function transfer(address _to, uint256 _value) returns (bool success);

    //从账户_from中往账户_to转数量为_value的token，与approve方法配合使用
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    //消息发送账户设置账户_spender能从发送账户中转出数量为_value的token
    function approve(address _spender, uint256 _value) returns (bool success);

    //获取账户_spender可以从账户_owner中转出token的数量
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    //发生转账时必须要触发的事件 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    //当函数approve(address _spender, uint256 _value)成功执行时必须触发的事件
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract QFBToken is Token {
    address manager;
//    mapping(address => bool) accountFrozen;
    mapping(address => uint) frozenTime;

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    function freeze(address account, bool frozen) public onlyManager {
        frozenTime[account] = now + 10 minutes;
//        accountFrozen[account] = frozen;
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if(balances[msg.sender] >= _value && _value > 0) {
            require(balances[msg.sender] >= _value);
            balances[msg.sender] -= _value;//从消息发送者账户中减去token数量_value
            balances[_to] += _value;//往接收账户增加token数量_value
            Transfer(msg.sender, _to, _value);//触发转币交易事件
            freeze(_to, true);
            return true;
        }
        
    }


    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(frozenTime[_from] <= now);
        
        if(balances[_from] >= _value  && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            Transfer(_from, _to, _value);

            return true;
        } else {
            return false;
        }
    }
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }


    function approve(address _spender, uint256 _value) returns (bool success)   
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];//允许_spender从_owner中转出的token数
    }
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    string public constant name = "QFBCOIN";                   //名称: eg Simon Bucks
    uint256 public constant decimals = 18;               //最多的小数位数，How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public constant symbol = "QFB";               //token简称: eg SBX
    string public version = 'QF1.0';    //版本

    // contracts
    address public ethFundDeposit;          // ETH存放地址
    address public newContractAddr;         // token更新地址

    // crowdsale parameters
    bool    public isFunding;                // 状态切换到true
    uint256 public fundingStartBlock;
    uint256 public fundingStopBlock;

    uint256 public currentSupply;           // 正在售卖中的tokens数量
    uint256 public tokenRaised = 0;         // 总的售卖数量token
    uint256 public tokenMigrated = 0;     // 总的已经交易的 token
    uint256 public tokenExchangeRate = 625;             // 625 BILIBILI 兑换 1 ETH

    // events
    event AllocateToken(address indexed _to, uint256 _value);   // 分配的私有交易token;
    event IssueToken(address indexed _to, uint256 _value);      // 公开发行售卖的token;
    event IncreaseSupply(uint256 _value);
    event DecreaseSupply(uint256 _value);
    event Migrate(address indexed _to, uint256 _value);

     // 转换
    function formatDecimals(uint256 _value) internal returns (uint256) {
        return _value * 10 ** decimals;
    }

    // constructor
    function QFBToken( address _ethFundDeposit, uint256 _currentSupply) {
        ethFundDeposit = _ethFundDeposit;

        isFunding = false;
        //通过控制预CrowdS ale状态
        fundingStartBlock = 0;
        fundingStopBlock = 0;
        currentSupply = formatDecimals(_currentSupply);
        totalSupply = formatDecimals(10000);
        balances[msg.sender] = totalSupply;
        manager = msg.sender;
        if (currentSupply > totalSupply) throw;
    }
}