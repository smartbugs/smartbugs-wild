pragma solidity ^0.4.24;


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}


contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract IOTS is Ownable{
    
    using SafeMath for uint256;
    
    string public constant name       = "IOTS Token";
    string public constant symbol     = "IOTS";
    uint32 public constant decimals   = 18;
    uint256 public constant totalSupply        = 12000000000  * (10 ** uint256(decimals));
 
    uint256 public constant lockSupply        =   4000000000  * (10 ** uint256(decimals));
   
    uint256 public constant teamSupply        =   8000000000  * (10 ** uint256(decimals));

 
    
    uint public lockAtTime;
    
 
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    address constant teamAddr = 0xf65EDCb3B229bCE3c1909C60dDd0885F610D97BC;

    constructor() public {
      
      lockAtTime = now;
      balances[teamAddr] = teamSupply;
      emit Transfer(0x0, teamAddr, teamSupply);

      balances[address(this)] = lockSupply;
      emit Transfer(0x0, address(this), lockSupply);
 
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        //require(checkLocked(msg.sender, _value));
 
        require(_value <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
    
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
  

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        //require(checkLocked(_from, _value));
        
        require(_value <= allowed[_from][msg.sender]);
 
        require(_value <= balances[_from]);
        
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
     }


    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }


    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
          allowed[msg.sender][_spender] = 0;
        } else {
          allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
     }
    
 

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
 
   function checkLocked(address _addr, uint256 _value) internal view returns (bool) {
         if (now > lockAtTime  + 4 years) {  
             return true;
         } else if (now > lockAtTime + 3 years)   {
             return (balances[_addr] - _value >= lockSupply / 5 );
         } else if (now > lockAtTime + 2 years)   {
             return (balances[_addr] - _value >= lockSupply / 5 * 2);    
         } else if (now > lockAtTime + 1 years)   {
             return (balances[_addr] - _value >= lockSupply / 5 * 3);      
         }  else {
             return (balances[_addr] - _value >= lockSupply / 5 * 4);     
         }  
 
   } 

    function withdrawal( ) onlyOwner public {
        uint256 _value = getFreeBalances();
        require(_value > 0 );
        require(checkLocked(address(this), _value));

        require(_value <= balances[address(this)]);
        
        balances[address(this)] = balances[address(this)].sub(_value);
        balances[teamAddr] = balances[teamAddr].add(_value);
    
        emit Transfer(address(this), teamAddr, _value);
    }
       
   function getFreeBalances( ) public view returns(uint)  {
     if (now > lockAtTime  + 4 years) {  
             return balances[address(this)];
         } else if (now > lockAtTime + 3 years)   {
             return (balances[address(this)] - lockSupply / 5 );
         } else if (now > lockAtTime + 2 years)   {
             return (balances[address(this)] - lockSupply / 5 * 2);    
         } else if (now > lockAtTime + 1 years)   {
             return (balances[address(this)] - lockSupply / 5 * 3);      
         }  else {
             return (balances[address(this)] - lockSupply / 5 * 4);     
      }
   }

 

}