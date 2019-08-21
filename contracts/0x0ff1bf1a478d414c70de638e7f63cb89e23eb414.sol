pragma solidity ^0.4.18;

contract LetoCoin{

    string public constant name = 'LetoCoin';
    string public constant symbol = 'LETO';
    uint8 public constant decimals = 10;
    uint256 public constant totalSupply = 8000000 * 10**uint256(decimals);
    
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function LetoCoin() public {
        balances[msg.sender] = totalSupply;
        Transfer(0x0, msg.sender, totalSupply);
    }
    
    function balanceOf(address _owner) constant public returns (uint256 balance){
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (_value != 0){
            require(balances[msg.sender] >= _value);
            require(balances[_to] + _value > balances[_to]);
            balances[msg.sender] -= _value;
            balances[_to] += _value;
        }
        Transfer(msg.sender, _to, _value); 
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        if (_value != 0){
            require(allowed[_from][msg.sender] >= _value);
            require(balances[_from] >= _value);
            require(balances[_to] + _value > balances[_to]);
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            balances[_to] += _value;
        }
        Transfer(_from, _to, _value); 
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success){
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining){
        return allowed[_owner][_spender];
    }
    
    function () public payable {
        revert();
    }
    
}