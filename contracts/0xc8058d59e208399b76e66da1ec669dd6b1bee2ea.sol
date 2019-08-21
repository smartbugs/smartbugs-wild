pragma solidity 0.4.18;


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
  function balanceOf(address _owner)public view returns (uint256 balance);
  function allowance(address _owner, address _spender)public view returns (uint remaining);
  function transferFrom(address _from, address _to, uint _amount)public returns (bool ok);
  function approve(address _spender, uint _amount)public returns (bool ok);
  function transfer(address _to, uint _amount)public returns (bool ok);
  event Transfer(address indexed _from, address indexed _to, uint _amount);
  event Approval(address indexed _owner, address indexed _spender, uint _amount);
}

contract GOLDBITSCOIN is ERC20
{
    using SafeMath for uint256;
    string public constant symbol = "GBC";
    string public constant name = "Gold Bits Coin";
    uint8 public constant decimals = 10;
    // 100 million total supply // muliplies dues to decimal precision
    uint256 public _totalSupply = 1000000000 * 10 **10;     // 1 billion supply           
    // Balances for each account
    mapping(address => uint256) balances;   
    // Owner of this contract
    address public owner;
    
    uint public perTokenPrice;
    address public central_account;
    bool stopped = true;
    bool ICO_PRE_ICO_STAGE = false;
    uint256 public stage = 0;
    uint256 public one_ether_usd_price = 0;
    
    mapping (address => mapping (address => uint)) allowed;
    
    // ico startdate
    uint256 startdate;

    // for maintaining prices with days
    uint256 first_ten_days;
    uint256 second_ten_days;
    uint256 third_ten_days;
    
    uint256 public supply_increased;
    bool PreICOended = false;
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

    event LOG(string e,uint256 value);
    //ico enddate;
    uint256 enddate;
    
    modifier onlyOwner() {
      if (msg.sender != owner) {
            revert();
        }
        _;
        }
        
    modifier onlycentralAccount {
        require(msg.sender == central_account);
        _;
    }
    
    function GOLDBITSCOIN() public
    {
        owner = msg.sender;
        balances[owner] = 200000000 * 10 **10; // 200 million token with company/owner , multiplied due to decimal precision
    
        supply_increased += balances[owner];
    }
    
    function setCentralAccount(address central_address) public onlyOwner
    {
        central_account = central_address;
    }
    // to be called by owner on 15th jan to start PreICO till 31st january
    function StatPreICO() external onlyOwner
    {
        stage = 1;
        ICO_PRE_ICO_STAGE = true;
        balances[address(this)] = 100000000 * 10 **10; // 100 million token with contract , multiplied due to decimal precision
        startdate = now;
        enddate = now.add(17 days);
        supply_increased += balances[address(this)];
        perTokenPrice = 24; // 24 cents
   
    }
    // to be called by owner on 1st feb to start ICO till 1st march
    function StartICO() external onlyOwner
    {
        require(PreICOended);    
        balances[address(this)] = 100000000 * 10 **10; // 100 million token with contract , multiplied due to decimal precision
        stage = 2;
        ICO_PRE_ICO_STAGE = true;
        stopped = false;
        startdate = now;
        first_ten_days = now.add(10 days);
        second_ten_days = first_ten_days.add(10 days);
        third_ten_days = second_ten_days.add(10 days);
        enddate = now.add(30 days);
        supply_increased += balances[address(this)];
        perTokenPrice = 30; // 30 cents
    }
    // to be called by owner at end of preICO and ICO
    function end_ICO_PreICO() external onlyOwner
    {
        PreICOended = true;
        stage = 0;
        ICO_PRE_ICO_STAGE = false;
        supply_increased -= balances[address(this)];
        balances[address(this)] =0;
    }
    
    
    function getTokenPriceforDapp() public view returns (uint256)
    {
        return perTokenPrice;
    }
    
    function getEtherPriceforDapp() public view returns (uint256)
    {
        return one_ether_usd_price;
    }
    
    function () public payable 
    {
        require(ICO_PRE_ICO_STAGE);
        require(stage > 0);
        require(now <= enddate);
        distributeToken(msg.value,msg.sender);   
    }
    
     
    function distributeToken(uint val, address user_address ) private {
        
        uint tokens = ((one_ether_usd_price * val) )  / (perTokenPrice * 10**14); 

        require(balances[address(this)] >= tokens);
        
        balances[address(this)] = balances[address(this)].sub(tokens);
        balances[user_address] = balances[user_address].add(tokens);
        Transfer(address(this), user_address, tokens);
       
      
        
    }
    
    // need to be called before the ICO to set ether price give to 8 decimal places
    function setconfigurationEtherPrice(uint etherPrice) public onlyOwner
    {
        one_ether_usd_price = etherPrice;
       
        
    }
    // **** need to be called to set  token Price, to be called during ICO to change price every 10 days
    function setconfigurationTokenPrice(uint TokenPrice) public onlyOwner
    {
      
        perTokenPrice = TokenPrice;
        
    }
    
        // **** need to be called to set  token Price, to be called during ICO to change price every 10 days
    function setStage(uint status) public onlyOwner
    {
      
        stage = status;
        
    }
    
    //used by wallet during token buying procedure 
    function transferby(address _from,address _to,uint256 _amount) public onlycentralAccount returns(bool success) {
        if (balances[_from] >= _amount &&
            _amount > 0 &&
            balances[_to] + _amount > balances[_to]) {
                 
            balances[_from] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
    
    // to be called by owner after an year review
    function mineToken(uint256 supply_to_increase) public onlyOwner
    {
        require((supply_increased + supply_to_increase) <= _totalSupply);
        supply_increased += supply_to_increase;
        
        balances[owner] += supply_to_increase;
        Transfer(0, owner, supply_to_increase);
    }
    
    
    // total supply of the tokens
    function totalSupply() public view returns (uint256 total_Supply) {
         total_Supply = _totalSupply;
     }
  
     //  balance of a particular account
     function balanceOf(address _owner)public view returns (uint256 balance) {
         return balances[_owner];
     }
  
     // Transfer the balance from owner's account to another account
     function transfer(address _to, uint256 _amount)public returns (bool success) {
         require( _to != 0x0);
         require(balances[msg.sender] >= _amount 
             && _amount >= 0
             && balances[_to] + _amount >= balances[_to]);
             balances[msg.sender] = balances[msg.sender].sub(_amount);
             balances[_to] = balances[_to].add(_amount);
             Transfer(msg.sender, _to, _amount);
             return true;
     }
  
     // Send _value amount of tokens from address _from to address _to
     // The transferFrom method is used for a withdraw workflow, allowing contracts to send
     // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
     // fees in sub-currencies; the command should fail unless the _from account has
     // deliberately authorized the sender of the message via some mechanism; we propose
     // these standardized APIs for approval:
     function transferFrom(
         address _from,
         address _to,
         uint256 _amount
     )public returns (bool success) {
        require(_to != 0x0); 
         require(balances[_from] >= _amount
             && allowed[_from][msg.sender] >= _amount
             && _amount >= 0
             && balances[_to] + _amount >= balances[_to]);
             balances[_from] = balances[_from].sub(_amount);
             allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
             balances[_to] = balances[_to].add(_amount);
             Transfer(_from, _to, _amount);
             return true;
             }
 
     // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
     // If this function is called again it overwrites the current allowance with _value.
     function approve(address _spender, uint256 _amount)public returns (bool success) {
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
         return true;
     }
  
     function allowance(address _owner, address _spender)public view returns (uint256 remaining) {
         return allowed[_owner][_spender];
   }
   
   	//In case the ownership needs to be transferred
	function transferOwnership(address newOwner)public onlyOwner
	{
	    require( newOwner != 0x0);
	    balances[newOwner] = balances[newOwner].add(balances[owner]);
	    balances[owner] = 0;
	    owner = newOwner;
	}
	
	// drain ether called by only owner
	function drain() external onlyOwner {
        owner.transfer(this.balance);
    }
    
    //Below function will convert string to integer removing decimal
	function stringToUint(string s) private returns (uint) 
	  {
        bytes memory b = bytes(s);
        uint i;
        uint result1 = 0;
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            if(c == 46)
            {
                // Do nothing --this will skip the decimal
            }
          else if (c >= 48 && c <= 57) {
                result1 = result1 * 10 + (c - 48);
              // usd_price=result;
                
            }
        }
            return result1;
      }
    
}