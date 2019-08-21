pragma solidity ^0.4.19;


contract BitcoinQuick {

    string public constant name = "Bitcoin Quick";

    string public constant symbol = "BTCQ";

    uint public constant decimals = 8;

    uint public constant totalSupply = 8500000 * 10 ** decimals;

    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;

    event Transfer(address indexed _from, address indexed _to, uint _value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

    function BitcoinQuick() public {
        balances[msg.sender] = totalSupply;
        Transfer(address(this), msg.sender, totalSupply);
    }

    function balanceOf(address _owner) public constant returns (uint balance)  {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint _amount) public returns (bool success)  {
        require(balances[msg.sender] >= _amount && _amount > 0);
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
        require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0);
        balances[_to] += _amount;
        balances[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;
        Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
}