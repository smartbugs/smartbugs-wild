pragma solidity ^0.4.19;

contract SafeMath {

function safeAdd(uint256 x, uint256 y) internal returns(uint256) {
uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

}

contract ERC20 {
    uint256 public totalSupply;
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*  ERC 20 token */
contract StandardToken is ERC20 {

    function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
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

contract UnicornCoin is StandardToken, SafeMath {

    // metadata
    uint256 public totalSupply;
    string public constant name = "Unicorn Coin";
    string public constant symbol = "UCC";
    uint256 public constant decimals = 18;
    string public version = "1.0";
    
    /* 1ETH = 500 UCC */
    uint256 public constant rate= 500;
    address public owner;
    uint256 public totalEth;
    
    function UnicornCoin(){
        balances[msg.sender] = 30000000000000000000000000;
        totalSupply = 30000000000000000000000000;
        owner = msg.sender;
    }
    
    function () payable {
        sendTokens();
    }
    
    function sendTokens() payable {
        require(msg.value > 0);
        totalEth = safeAdd(totalEth, msg.value);
        uint256 tokens = safeMult(msg.value, rate);
        
        if (balances[owner] < tokens) {
            return;
        }

        balances[owner] = safeSubtract(balances[owner], tokens);
        balances[msg.sender] = safeAdd(balances[msg.sender], tokens);

        Transfer(owner, msg.sender, tokens); 

        owner.transfer(msg.value);    
        
    }
}