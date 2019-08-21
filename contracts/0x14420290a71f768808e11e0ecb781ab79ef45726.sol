pragma solidity ^0.4.11;

  contract ERC20Interface {
      function totalSupply() constant returns (uint256 totalSupply);
   
      function balanceOf(address _owner) constant returns (uint256 balance);
   
      function transfer(address _to, uint256 _value) returns (bool success);
   
      function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
   
      function approve(address _spender, uint256 _value) returns (bool success);
   
      function allowance(address _owner, address _spender) constant returns (uint256 remaining);
   
      event Transfer(address indexed _from, address indexed _to, uint256 _value);
   
      event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  }

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
     // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
   
  contract PostbaseToken is ERC20Interface {
       using SafeMath for uint256;

      string public constant symbol = "PB2";
      string public constant name = "Postbase PB2";
      uint8 public constant decimals = 8;
      uint256 _totalSupply = 10000000000000000;
      
      address public owner;
      mapping(address => uint256) balances;
      mapping(address => mapping (address => uint256)) allowed;
   
      // Constructor
      function PostbaseToken() {
          owner = msg.sender;
          balances[owner] = _totalSupply;
      }
   
      function totalSupply() constant returns (uint256 totalSupply) {
          totalSupply = _totalSupply;
      }
   
      function balanceOf(address _owner) constant returns (uint256 balance) {
          return balances[_owner];
      }
   
      function transfer(address _to, uint256 _amount) returns (bool success) {
          
              balances[msg.sender] = balances[msg.sender].sub(_amount);
              balances[_to] = balances[_to].add(_amount);
              Transfer(msg.sender, _to, _amount);
              return true;
          
      }
   
      function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) {
         
          var _allowance = allowed[_from][msg.sender];
	        balances[_to] = balances[_to].add(_amount);
    	    balances[_from] = balances[_from].sub(_amount);
	        allowed[_from][msg.sender] = _allowance.sub(_amount);
	        Transfer(_from, _to, _amount);
          return true;
     }
  
     function approve(address _spender, uint256 _amount) returns (bool success) {
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
         return true;
     }
  
     function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
         return allowed[_owner][_spender];
     }
 }