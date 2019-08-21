/*
  live: 0x89d64bc7e46bdc49a89652ae9bb167418cbad62e
morden: 0xe379e36671acbcc87ec7b760c07e6e45a1294944
  solc: v0.3.1-2016-04-12-3ad5e82 (optimization)
*/

contract tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token);
}

contract Token {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function totalSupply() constant returns (uint256 supply);
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function approveAndCall(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
}

contract SafeAddSub {
    function safeToAdd(uint a, uint b) internal returns (bool) {
        return (a + b > a);
    }

    function safeToSubtract(uint a, uint b) internal returns (bool) {
        return (a >= b);
    }

    function safeAdd(uint a, uint b) internal returns (uint256) {
        if (!safeToAdd(a, b)) throw;
        return a + b;
    }

    function safeSubtract(uint a, uint b) internal returns (uint256) {
        if (!safeToSubtract(a, b)) throw;
        return a - b;
    }
}

contract EthToken is Token, SafeAddSub {
    string public constant name = "Ether Token Proxy";
    string public constant symbol = "ETH";
    uint8   public constant decimals = 18;
    uint256 public constant baseUnit = 10**18;
    
    mapping (address => uint256) _balanceOf;
    mapping (address => mapping (address => uint256)) _allowance;

    event Deposit(address indexed owner, uint256 amount);
    event Withdrawal(address indexed owner, uint256 amount);

    function totalSupply() constant returns (uint256 supply) {
        return this.balance;
    }
    
    function () {
        deposit();
    }
    
    function deposit() {
        _balanceOf[msg.sender] = safeAdd(_balanceOf[msg.sender], msg.value);
        Deposit(msg.sender, msg.value);
    }
    
    function redeem() {
        withdraw(_balanceOf[msg.sender]);
    }
    
    function withdraw(uint256 _value) returns (bool success) {
        _balanceOf[msg.sender] = safeSubtract(_balanceOf[msg.sender], _value);
        if (!msg.sender.send(_value)) {
            if (!msg.sender.call.gas(msg.gas).value(_value)()) throw;
        }
        Withdrawal(msg.sender, _value);
        return true;
    }
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return _balanceOf[_owner];
    }
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (_to == address(this) || _to == 0) {
            return withdraw(_value);
        } else {
            _balanceOf[msg.sender] = safeSubtract(_balanceOf[msg.sender], _value);
            _balanceOf[_to] = safeAdd(_balanceOf[_to], _value);
            Transfer(msg.sender, _to, _value);
        }
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (!safeToSubtract(_allowance[_from][msg.sender], _value)) throw;
        if (_to == address(this) || _to == 0) {
            if (!transferFrom(_from, msg.sender, _value)) throw;
            withdraw(_value);
        } else {
            _balanceOf[_from] = safeSubtract(_balanceOf[_from], _value);
            _balanceOf[_to] = safeAdd(_balanceOf[_to], _value);
            _allowance[_from][msg.sender] = safeSubtract(_allowance[_from][msg.sender], _value);
            Transfer(_from, _to, _value);
        }
        return true;
    }
    
    function approve(address _spender, uint256 _value) returns (bool success) {
        _allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function approveAndCall(address _spender, uint256 _value) returns (bool success) {
        if (approve(_spender, _value)) {
            tokenRecipient(_spender).receiveApproval(msg.sender, _value, this);
            return true;
        }
        throw;
    }
    
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return _allowance[_owner][_spender];
    }
}