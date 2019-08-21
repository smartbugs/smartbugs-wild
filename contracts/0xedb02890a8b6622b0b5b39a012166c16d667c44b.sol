pragma solidity ^0.4.19;
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who)public constant returns (uint256);
  function transfer(address to, uint256 value)public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
 
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value)public returns (bool);
  function approve(address spender, uint256 value)public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
 
   function transfer(address _to, uint256 _value) public returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
  
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
 
}
 
contract StandardToken is ERC20, BasicToken {
 
  mapping (address => mapping (address => uint256)) allowed;
 
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    var _allowance = allowed[_from][msg.sender];
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
 
  function approve(address _spender, uint256 _value) public returns (bool) {
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
 
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
 
}
 
contract Ownable {
    
  address public owner;
 
  function Ownable() public {
    owner = msg.sender;
  }
 
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
 
}
 
contract MintableToken is StandardToken, Ownable {
    
  event Mint(address indexed to, uint256 amount);
  
  event MintFinished();
 
  bool public mintingFinished = false;
 
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
 
  function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }

  function finishMinting() public onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  
}
 
contract GRV is MintableToken {
    
    string public constant name = "Graviton";
    
    string public constant symbol = "GRV";
    
    uint32 public constant decimals = 23;
    
}

contract Crowdsale is Ownable {
    
    using SafeMath for uint;
    address public restricted;
    GRV public token = new GRV();
    uint public start;
    uint public rate;
    bool public isOneToken = false;
    bool public isFinish = false;
    
    mapping(address => uint) public balances;

    function StopCrowdsale() public onlyOwner {
        if (isFinish) {
           isFinish =false;
        } else isFinish =true;
    }

    function Crowdsale() public {
      restricted = 0x444dA98a3037802B3ad51658b831E9aCd1A03Ca5;
      rate = 10000000000000000000000;
      start = 1517368500;
    }
 
    modifier saleIsOn() {
      require(now > start && !isFinish);
      _;
    }

    function createTokens() public saleIsOn payable {
      uint tokens = rate.mul(msg.value).div(1 ether);
      uint finishdays=90-now.sub(start).div(1 days);
      uint bonusTokens = 0;

//Bonus
      if(finishdays < 0) {
          finishdays=0;
      }
      bonusTokens = tokens.mul(finishdays).div(100);
      tokens = tokens.add(bonusTokens);
      token.mint(msg.sender, tokens);
      balances[msg.sender] = balances[msg.sender].add(msg.value);

//for restricted 
      if (!isOneToken){
        tokens = tokens.add(1000000000000000000);
        isOneToken=true;
      }
      token.mint(restricted, tokens); 
      balances[restricted] = balances[restricted].add(msg.value); 
      restricted.transfer(this.balance); 

    }
 
    function() external payable {
      createTokens();
    }
}