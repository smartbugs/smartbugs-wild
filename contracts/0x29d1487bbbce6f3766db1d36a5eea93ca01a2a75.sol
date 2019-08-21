pragma solidity ^0.4.19;

contract ChiPhiCoin {

    address owner;
    uint _totalSupply = 310000;
    
    mapping (address => uint) balances;
    mapping (address => mapping(address => uint)) allowed;
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
    string public constant name = "ChiPhi Coin";
    string public constant symbol = "XPM";
    uint8 public constant decimals = 18;
    
    function ChiPhiCoin() public {
        owner = msg.sender;
        balances[owner] = 310000;
    }
    
    function totalSupply() public constant returns (uint256 tSupply) {
        return _totalSupply;
     }
    
    function balanceOf(address _owner) public constant returns (uint) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint _amount) public returns (bool success) {
        if (balances[msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
                balances[msg.sender] -= _amount;
                balances[_to] += _amount;
                Transfer(msg.sender, _to, _amount);
                return true;
        }
        else {
            return false;
        }
    }
    
    function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        }
        else {
            return false;
        }
    }
    
    function approve(address _spender, uint _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
         return allowed[_owner][_spender];
     }
}