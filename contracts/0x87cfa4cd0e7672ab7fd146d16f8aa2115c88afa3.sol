pragma solidity ^0.4.16;

contract SafeMath {
    function safeMul(uint a, uint b) pure internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) pure internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) pure internal returns (uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}

contract HXC is SafeMath {

    string public name = "HXC";        //  token name
    string public symbol = "HXC";      //  token symbol
    uint public decimals = 18;           //  token digit

    address public admin = 0x0;
    uint256 public dailyRelease = 6000 * 10 ** 18;
    uint256 public totalRelease = 0;
    uint256 constant totalValue = 1000 * 10000 * 10 ** 18;


    uint256 public totalSupply = 0;
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;

    modifier isAdmin 
    {
        assert(admin == msg.sender);
        _;
    }

    modifier validAddress(address _address) 
    {
        assert(0x0 != _address);
        _;
    }

    function HXC(address _addressFounder)
        public
    {
        admin = msg.sender;
        totalSupply = totalValue;
        balances[_addressFounder] = totalValue;
        Transfer(0x0, _addressFounder, totalValue); 
    }

    function releaseSupply()
        isAdmin
        returns (bool)
    {
        totalRelease = safeAdd(totalRelease,dailyRelease);
        return true;
    }

    function updateRelease(uint256 amount)
        isAdmin
        returns (bool)
    {
        totalRelease = safeAdd(totalRelease,amount);
        return true;
    }

    function transfer(address _to, uint256 _value) 
        public 
        validAddress(_to) 
        returns (bool success)
    {
        require(balances[msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) 
        public
        validAddress(_from)
        validAddress(_to)
        returns (bool success) 
    {
        require(balances[_from] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        require(allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value)
        public
        validAddress(_spender)
        returns (bool success)
    {
        require(_value == 0 || allowed[msg.sender][_spender] == 0);
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }   

    function balanceOf(address _owner) constant returns (uint256 balance) 
    {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) 
    {
        return allowed[_owner][_spender];
    }


    function() 
    {
        throw;
    }

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}