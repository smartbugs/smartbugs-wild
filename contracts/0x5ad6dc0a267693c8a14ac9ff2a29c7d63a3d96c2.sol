pragma solidity ^0.4.8;


contract MP3Coin {
    string public constant symbol = "MP3";

    string public constant name = "MP3 Coin";

    string public constant slogan = "Make Music Great Again";

    uint public constant decimals = 8;

    uint public totalSupply = 1000000 * 10 ** decimals;

    address owner;

    mapping (address => uint) balances;

    mapping (address => mapping (address => uint)) allowed;

    event Transfer(address indexed _from, address indexed _to, uint _value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

    function MP3Coin() public {
        owner = msg.sender;
        balances[owner] = totalSupply;
        Transfer(this, owner, totalSupply);
    }

    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint _amount) public returns (bool success) {
        require(_amount > 0 && balances[msg.sender] >= _amount);
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
        require(_amount > 0 && balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount);
        balances[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;
        balances[_to] += _amount;
        Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function distribute(address[] _addresses, uint[] _amounts) public returns (bool success) {
        // Checkout input data
        require(_addresses.length < 256 && _addresses.length == _amounts.length);
        // Calculate total amount
        uint totalAmount;
        for (uint a = 0; a < _amounts.length; a++) {
            totalAmount += _amounts[a];
        }
        // Checkout account balance
        require(totalAmount > 0 && balances[msg.sender] >= totalAmount);
        // Deduct amount from sender
        balances[msg.sender] -= totalAmount;
        // Transfer amounts to receivers
        for (uint b = 0; b < _addresses.length; b++) {
            if (_amounts[b] > 0) {
                balances[_addresses[b]] += _amounts[b];
                Transfer(msg.sender, _addresses[b], _amounts[b]);
            }
        }
        return true;
    }
}