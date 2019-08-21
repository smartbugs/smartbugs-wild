pragma solidity 0.4.19;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20 {
  function totalSupply()public view returns (uint total_Supply);
  function balanceOf(address who)public view returns (uint256);
  function allowance(address owner, address spender)public view returns (uint);
  function transferFrom(address from, address to, uint value)public returns (bool ok);
  function approve(address spender, uint value)public returns (bool ok);
  function transfer(address to, uint value)public returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


contract AussieCoin is ERC20
{ using SafeMath for uint256;
    // Name of the token
    string public constant name = "AussieCoin";

    // Symbol of token
    string public constant symbol = "AUS";
    uint8 public constant decimals = 18;
    uint public _totalsupply = 24000000 * 10 ** 18; // 24 Million inculding decimal precesion
    address public owner;                    // Owner of this contract
    uint256 public _price_tokn = 5000; // 1 Ether = 5000 token
    uint256 no_of_tokens;
     uint256 public startdate;
    bool stopped = false;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    
     enum Stages {
        NOTSTARTED,
        ICO,
        PAUSED,
        ENDED
    }
    Stages public stage;
    
    modifier atStage(Stages _stage) {
        if (stage != _stage)
            // Contract not in expected state
            revert();
        _;
    }
    
     modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    function AussieCoin() public
    {
         owner = msg.sender;
        balances[owner] = 14000000 * 10 **18;
        stage = Stages.NOTSTARTED;
        Transfer(0, owner, balances[owner]);
       
    }
    
    function start_ICO() public onlyOwner atStage(Stages.NOTSTARTED)
      {
          stage = Stages.ICO;
          balances[address(this)] = 10000000 *10**18;
          stopped = false;
          startdate = now;
          Transfer(0, address(this), balances[address(this)]);
          
      }
  
  
    function () public payable atStage(Stages.ICO)
    {
      
        require(!stopped && msg.sender != owner);
        no_of_tokens =((msg.value).mul(_price_tokn));
        transferTokens(msg.sender,no_of_tokens);
    }
     
      
    
    // called by the owner, pause ICO
    function StopICO() external onlyOwner atStage(Stages.ICO)
    {
        stage = Stages.PAUSED;
        stopped = true;
       }

    // called by the owner , resumes ICO
    function releaseICO() external onlyOwner atStage(Stages.PAUSED)
    {
        stage = Stages.ICO;
        stopped = false;
      }
      
      
       function end_ICO() external onlyOwner atStage(Stages.ICO)
     {
          stage = Stages.ENDED;
         balances[owner] = (balances[owner]).add(balances[address(this)]);
         balances[address(this)] = 0;
         Transfer(address(this), owner , balances[address(this)]);
         
         
     }


    // what is the total supply of the ech tokens
     function totalSupply() public view returns (uint256 total_Supply) {
         total_Supply = _totalsupply;
     }
    
    // What is the balance of a particular account?
     function balanceOf(address _owner)public view returns (uint256 balance) {
         return balances[_owner];
     }
    
    // Send _value amount of tokens from address _from to address _to
     // The transferFrom method is used for a withdraw workflow, allowing contracts to send
     // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
     // fees in sub-currencies; the command should fail unless the _from account has
     // deliberately authorized the sender of the message via some mechanism; we propose
     // these standardized APIs for approval:
     function transferFrom( address _from, address _to, uint256 _amount )public returns (bool success) {
     require( _to != 0x0);
     require(balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount >= 0);
     balances[_from] = (balances[_from]).sub(_amount);
     allowed[_from][msg.sender] = (allowed[_from][msg.sender]).sub(_amount);
     balances[_to] = (balances[_to]).add(_amount);
     Transfer(_from, _to, _amount);
     return true;
         }
    
   // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
     // If this function is called again it overwrites the current allowance with _value.
     function approve(address _spender, uint256 _amount)public returns (bool success) {
         require( _spender != 0x0);
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
         return true;
     }
  
     function allowance(address _owner, address _spender)public view returns (uint256 remaining) {
         require( _owner != 0x0 && _spender !=0x0);
         return allowed[_owner][_spender];
   }

     // Transfer the balance from owner's account to another account
     function transfer(address _to, uint256 _amount)public returns (bool success) {
        require( _to != 0x0);
        require(balances[msg.sender] >= _amount && _amount >= 0);
        balances[msg.sender] = (balances[msg.sender]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        Transfer(msg.sender, _to, _amount);
             return true;
         }
    
          // Transfer the balance from owner's account to another account
    function transferTokens(address _to, uint256 _amount) private returns(bool success) {
        require( _to != 0x0);       
        require(balances[address(this)] >= _amount && _amount > 0);
        balances[address(this)] = (balances[address(this)]).sub(_amount);
        balances[_to] = (balances[_to]).add(_amount);
        Transfer(address(this), _to, _amount);
        return true;
        }
    
    
    function drain() external onlyOwner {
        owner.transfer(this.balance);
    }
    
}