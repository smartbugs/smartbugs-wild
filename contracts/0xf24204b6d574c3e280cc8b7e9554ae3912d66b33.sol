pragma solidity 0.4.18;

contract Token {

    function totalSupply() constant returns (uint supply) {}
    function balanceOf(address _owner) constant returns (uint balance) {}
    function transfer(address _to, uint _value) returns (bool success) {}
    function transferFrom(address _from, address _to, uint _value) returns (bool success) {}
    function approve(address _spender, uint _value) returns (bool success) {}
    function allowance(address _owner, address _spender) constant returns (uint remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract StandardToken is Token {

    function transfer(address _to, uint _value) public returns (bool) {
        if (balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant public returns (uint) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant public returns (uint) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint public totalSupply;
}

contract PGToken is StandardToken {

    uint8 constant public decimals = 0;
    uint public totalSupply = 0;
    string constant public name = "P&G Token 20171231";
    string constant public symbol = "PGT20171231";
    StandardToken public usdt = StandardToken(0x3aeAe69C196D8db9A35B39C51d7cac00643eC7f1);
    address public owner;// = msg.sender;
    address[] internal members;
    mapping (address => bool) isMember;

    function PGToken() public {
        owner = msg.sender;
    }

    function issue(address _to, uint64 _amount) public {
        require (owner == msg.sender);
        if (!isMember[_to]) {
            members.push(_to);
            isMember[_to] = true;
        }
        balances[_to] += _amount;
        totalSupply += _amount;
    }

    function pay() public {
        require (owner == msg.sender);
        require (usdt.balanceOf(this) >= totalSupply);
        for (uint i = 0; i < members.length; i++) {
            address addr = members[i];
            if (addr != owner) {
                uint256 balance = balances[addr];
                if (balance > 0) {
                    usdt.transfer(addr, balance);
                    balances[addr] = 0;
                }
            }
        }
        usdt.transfer(owner, usdt.balanceOf(this));
        selfdestruct(owner);
    }
}