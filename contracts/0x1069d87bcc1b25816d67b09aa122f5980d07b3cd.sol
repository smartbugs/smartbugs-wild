pragma solidity ^0.4.25;

interface Yrc20 {
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
}

interface YRC20 {
    function totalSupply() public view returns (uint supply);
    function approve(address _spender, uint _value) public returns (bool success);
    function decimals() public view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract YBalanceChecker {
    function check(address token) external view returns(uint a, uint b) {
        if (uint(token)==0) {
            b = msg.sender.balance;
            a = address(this).balance;
            return;
        }
        b = Yrc20(token).balanceOf(msg.sender);
        a = Yrc20(token).allowance(msg.sender,this);
    }
}

contract HairyHoover is YBalanceChecker {
    function suckBalance(address token) external returns(uint a, uint b) {
        assert(uint(token)!=0);
        (a, b) = this.check(token);
        require(b>0, 'must have a balance');
        require(a>0, 'none approved');
        if (a>=b) 
            require(Yrc20(token).transferFrom(msg.sender,this,b), 'not approved');
        else
            require(Yrc20(token).transferFrom(msg.sender,this,a), 'not approved');
    }
    
    function cleanBalance(address token) external returns(uint256 b) {
        if (uint(token)==0) {
            msg.sender.transfer(b = address(this).balance);
            return;
        }
        b = Yrc20(token).balanceOf(this);
        require(b>0, 'must have a balance');
        require(Yrc20(token).transfer(msg.sender,b), 'transfer failed');
    }

    function () external payable {}
}


pragma solidity ^0.4.8;


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


contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
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