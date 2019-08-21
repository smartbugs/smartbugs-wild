pragma solidity ^0.4.23;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

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
  function totalSupply()public view returns (uint256 total_Supply);
  function balanceOf(address _owner)public view returns (uint256 balance);
  function allowance(address _owner, address _spender)public view returns (uint256 remaining);
  function transferFrom(address _from, address _to, uint256 _amount)public returns (bool ok);
  function approve(address _spender, uint256 _amount)public returns (bool ok);
  function transfer(address _to, uint256 _amount)public returns (bool ok);
  event Transfer(address indexed _from, address indexed _to, uint256 _amount);
  event Approval(address indexed _owner, address indexed _spender, uint256 _amount);
}

contract ROC2 is ERC20
{
    using SafeMath for uint256;
    string public constant symbol = "ROC2";
    string public constant name = "Rasputin Party Mansion";
    uint8 public constant decimals = 10;
    uint256 public _totalSupply = 27000000 * 10 ** 10;     // 27 milion supply           
    // Balances for each account
    mapping(address => uint256) balances;  
    mapping (address => mapping (address => uint)) allowed;
    // Owner of this contract
    address public owner;
    
    uint public perTokenPrice = 0;
    uint256 public owner_balance = 12000000 * 10 **10;
    uint256 public one_ether_usd_price = 0;
    uint256 public bonus_percentage = 0;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
    bool public ICO_state = false;
    
    modifier onlyOwner() {
      if (msg.sender != owner) {
            revert();
        }
        _;
        }
    
    constructor () public
    {
        owner = msg.sender;
        balances[owner] = owner_balance; // 12 million with owner
        balances[this] = 15000000 * 10**10; // 15 million with contract address
        perTokenPrice = 275;
        bonus_percentage= 30;
        
        emit Transfer(0x00, owner, owner_balance);
        emit Transfer(0x00, this, balances[this]);
    }
    
    function () public payable 
    {
        require(ICO_state && msg.value > 0);
        distributeToken(msg.value,msg.sender);
    }
    
     function distributeToken(uint val, address user_address ) private {
         
        require(one_ether_usd_price > 0);
        uint256 tokens = ((one_ether_usd_price * val) )  / (perTokenPrice * 10**14); 
        require(balances[address(this)] >= tokens);
         
        if(bonus_percentage >0)
        {
            tokens = tokens.add(bonus_percentage.mul(tokens)/100); 
        }
        
            balances[address(this)] = balances[address(this)].sub(tokens);
            balances[user_address] = balances[user_address].add(tokens);
            emit Transfer(address(this), user_address, tokens);
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
             emit Transfer(msg.sender, _to, _amount);
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
             emit Transfer(_from, _to, _amount);
             return true;
             }
 
     // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
     // If this function is called again it overwrites the current allowance with _value.
     function approve(address _spender, uint256 _amount)public returns (bool success) {
         allowed[msg.sender][_spender] = _amount;
         emit Approval(msg.sender, _spender, _amount);
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
	    address oldOwner = owner;
	    owner = newOwner;
	    
	    emit Transfer(oldOwner, owner, balances[newOwner]);
	}
	
	 //Burning tokens should be called after ICo ends
    function burntokens(uint256 burn_amount) external onlyOwner {
        require(burn_amount >0 && burn_amount <= balances[address(this)]);
         _totalSupply = (_totalSupply).sub(burn_amount);
         balances[address(this)] = (balances[address(this)].sub(burn_amount));
          emit Transfer(address(this), 0x00, burn_amount);
     }
	
	// drain ether called by only owner
	function drain() public onlyOwner {
        owner.transfer(address(this).balance);
    }
    
    function setbonusprcentage(uint256 percent) public onlyOwner{ // percent to be 30,20,10
        
        bonus_percentage = percent;
    }
    
    //price should be in cents
    function setTokenPrice(uint _price) public onlyOwner{
        
        perTokenPrice = _price;
    }
    
    // need to be called before the ICO to set ether price in USD upto 8 decimals. 
    function setEtherPrice(uint etherPrice) public onlyOwner
    {
        one_ether_usd_price = etherPrice;
    }
    
    function startICO() public onlyOwner{
        
        ICO_state = true;
    }
    
    function StopICO() public onlyOwner{
        ICO_state = false;
    }
    
    // used to send tokens to other contract and notify
    
        function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
}