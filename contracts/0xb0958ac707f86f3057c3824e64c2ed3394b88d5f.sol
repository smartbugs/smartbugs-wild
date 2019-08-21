pragma solidity ^0.4.13;

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  
}

library SafeMath {
    
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
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


contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

}

contract Ownable {
    
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }
  
  address saleAgent = 0x44BA9C2E2d0BbF5aCD4eaF68EA6227C01E37f414;

  modifier onlyOwner() {
    require(msg.sender == owner || msg.sender == saleAgent);
    _;
  }

  

}

contract MintableToken is StandardToken, Ownable {
    
  event Mint(address indexed to, uint256 amount);
  
  event MintFinished();


  

  function mint(address _to, uint256 _amount) onlyOwner returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  
  
  
  
}



contract GPInvestment is MintableToken {
    
    string public constant name = "GPInvestment";
    
    string public constant symbol = "GPI";
    
    uint32 public constant decimals = 18;
    
    uint256 INITIAL_SUPPLY = 10000000 * 1 ether;
    

  function GPInvestment() {
    totalSupply = INITIAL_SUPPLY;
    address multisig = 0x44BA9C2E2d0BbF5aCD4eaF68EA6227C01E37f414;
    balances[multisig] = INITIAL_SUPPLY;
  }
    
}