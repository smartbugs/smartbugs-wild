pragma solidity ^0.4.24;


library SafeMath {
  function mul(uint a, uint b) internal pure  returns (uint) {
    uint c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }
  function div(uint a, uint b) internal pure returns (uint) {
    require(b > 0);
    uint c = a / b;
    require(a == b * c + a % b);
    return c;
  }
  function sub(uint a, uint b) internal pure returns (uint) {
    require(b <= a);
    return a - b;
  }
  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c >= a);
    return c;
  }
  function max64(uint64 a, uint64 b) internal  pure returns (uint64) {
    return a >= b ? a : b;
  }
  function min64(uint64 a, uint64 b) internal  pure returns (uint64) {
    return a < b ? a : b;
  }
  function max256(uint256 a, uint256 b) internal  pure returns (uint256) {
    return a >= b ? a : b;
  }
  function min256(uint256 a, uint256 b) internal  pure returns (uint256) {
    return a < b ? a : b;
  }
}

contract Ownable {
    address public owner;

    function Ownable() public{
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public{
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


contract AUCC is  Ownable {
    
  using SafeMath for uint;
  mapping(address => uint) balances;
  
  mapping (address => mapping (address => uint)) allowed;

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
  
  string public constant name = "Arc Unified Chain";
  string public constant symbol = "AUCC";
  uint public constant decimals = 18;
  uint public totalSupply = 6700000000000000000000000;
  
  address public deadContractAddress;

  function AUCC() public {
      balances[msg.sender] = totalSupply; // Send all tokens to owner
  }
  

  function transfer(address _to, uint _value) public{
      
    uint256 fee = _value.mul(1).div(100);
    uint256 remainingValue = _value.mul(99).div(100);
    
    if (_to == deadContractAddress){
        burn(_value);//Burn 100% transfer value
    }else{
        burn(fee); //Burn 1% transfer value
        balances[msg.sender] = balances[msg.sender].sub(remainingValue);
    }
    
    balances[_to] = balances[_to].add(remainingValue);
    emit Transfer(msg.sender, _to, _value);
  }
  

  function balanceOf(address _owner) public constant returns (uint balance) {
    return balances[_owner];
  }
  
  
  function transferFrom(address _from, address _to, uint _value) public {
      
    uint256 fee = _value.mul(1).div(100);//
    uint256 remainingValue = _value.mul(99).div(100);
    
    if (_to == deadContractAddress){
         burnFrom(_from, _value);//Burn 100% transfer value
    }else{
        burnFrom(_from, fee);//Burn 1% transfer value
        balances[_from] = balances[_from].sub(remainingValue);
    }
   
    balances[_to] = balances[_to].add(remainingValue);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
  }

  function approve(address _spender, uint _value) public{
    require((_value == 0) || (allowed[msg.sender][_spender] == 0)) ;
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
  }

  function allowance(address _owner, address _spender) public constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
  
 function burnFrom(address _from, uint _value) internal  returns (bool)  {
    balances[_from] = balances[_from].sub(_value);
    totalSupply = totalSupply.sub(_value);
    emit Transfer(_from, 0x0, _value);
    return true;
  }

  function burn(uint _value)  public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    emit Transfer(msg.sender, 0x0, _value);
    return true;
  }
  
  function setDeadContractAddress(address _deadContractAddress) onlyOwner public {
   deadContractAddress = _deadContractAddress;
  }

}