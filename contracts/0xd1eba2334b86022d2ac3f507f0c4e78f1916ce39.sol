pragma solidity ^0.4.18;

library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint a, uint b) internal pure returns (uint) {
    uint c = a / b;
    return c;
  }
 
  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a); 
    return a - b; 
  } 
  
  function add(uint a, uint b) internal pure returns (uint) { 
    uint c = a + b; assert(c >= a);
    return c;
  }
 
}

contract Own {
    
    address public owner;
    
    function Own() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    
}

contract Tangle is Own {
    
    using SafeMath for uint;
    string public constant name = "Tangle";
    string public constant symbol = "TNC";
    uint32 public constant decimals = 7;
    uint public totalSupply = 10000000;
    mapping (address => uint) balances;
    mapping (address => mapping(address => uint)) allowed;
    
    
    function Tangle() public {
        totalSupply = totalSupply * 10 ** uint(decimals);
        balances[owner] = totalSupply;
    }
    
    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint _value) public returns (bool success) {
        if(balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
            balances[msg.sender] = balances[msg.sender].sub(_value); 
            balances[_to] = balances[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        } 
        return false;
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        if( allowed[_from][msg.sender] >= _value &&
            balances[_from] >= _value 
            && balances[_to] + _value >= balances[_to]) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
            balances[_from] = balances[_from].sub(_value); 
            balances[_to] = balances[_to].add(_value);
            Transfer(_from, _to, _value);
            return true;
        } 
       return false;
    }
    
    function approve(address _spender, uint _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}