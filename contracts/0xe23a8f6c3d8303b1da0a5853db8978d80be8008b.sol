pragma solidity ^0.4.20;

contract SafeMath {
  function mul2(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
       return 0;
     }
     uint256 c = a * b;
     assert(c / a == b);
     return c;
   }

  function div2(uint256 a, uint256 b) internal pure returns (uint256) {
     uint256 c = a / b;
     return c;
  }

  function sub2(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
     return a - b;
   }

  function add2(uint256 a, uint256 b) internal pure returns (uint256) {
     uint256 c = a + b;
    assert(c >= a);
     return c;
   }
}

contract ERC20 {
   uint256 public totalSupply;
   function balanceOf(address who) public view returns (uint256);
   function transfer(address to, uint256 value) public returns (bool);
   event Transfer(address indexed from, address indexed to, uint256 value);
   function allowance(address owner, address spender) public view returns (uint256);
   function transferFrom(address from, address to, uint256 value) public returns (bool);
   function approve(address spender, uint256 value) public returns (bool);
   event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC223 {
    function transfer(address to, uint value, bytes data) public;
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}

contract ERC223ReceivingContract { 
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

contract StandardToken is ERC20, ERC223, SafeMath {

   mapping(address => uint256) balances;
   mapping (address => mapping (address => uint256)) internal allowed;

   function transfer(address _to, uint256 _value) public returns (bool) {
     require(_to != address(0));
     require(_value <= balances[msg.sender]);
     balances[msg.sender] = sub2(balances[msg.sender], _value);
     balances[_to] = add2(balances[_to], _value);
     Transfer(msg.sender, _to, _value);
     return true;
   }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
   }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
     require(_value <= balances[_from]);
     require(_value <= allowed[_from][msg.sender]);

    balances[_from] = sub2(balances[_from], _value);
     balances[_to] = add2(balances[_to], _value);
     allowed[_from][msg.sender] = sub2(allowed[_from][msg.sender], _value);
    Transfer(_from, _to, _value);
     return true;
   }

   function approve(address _spender, uint256 _value) public returns (bool) {
     allowed[msg.sender][_spender] = _value;
     Approval(msg.sender, _spender, _value);
     return true;
   }

  function allowance(address _owner, address _spender) public view returns (uint256) {
     return allowed[_owner][_spender];
   }

   function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
     allowed[msg.sender][_spender] = add2(allowed[msg.sender][_spender], _addedValue);
     Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
     return true;
   }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
     uint oldValue = allowed[msg.sender][_spender];
     if (_subtractedValue > oldValue) {
       allowed[msg.sender][_spender] = 0;
     } else {
       allowed[msg.sender][_spender] = sub2(oldValue, _subtractedValue);
    }
     Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
     return true;
   }
   
    function transfer(address _to, uint _value, bytes _data) public {
        require(_value > 0 );
        if(isContract(_to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        balances[msg.sender] = sub2(balances[msg.sender], _value);
        balances[_to] = add2(balances[_to], _value);
        Transfer(msg.sender, _to, _value, _data);
    }

    function isContract(address _addr) private view returns (bool is_contract) {
      uint length;
      assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
      }
      return (length>0);
    }
    
}

contract CmoudCoin is StandardToken {
   string public name = 'CmoudCoin';
   string public symbol = 'CMD';
   uint public decimals = 0;
   uint public INITIAL_SUPPLY = 1000000000000;

   function CmoudCoin() public {
     totalSupply = INITIAL_SUPPLY;
     balances[msg.sender] = INITIAL_SUPPLY;
   }
}