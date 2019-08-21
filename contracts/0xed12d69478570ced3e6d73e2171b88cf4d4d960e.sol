pragma solidity 0.4.18;

contract SafeMath {
    function safeMul(uint a, uint b) pure internal returns(uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint a, uint b) pure  internal returns(uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) pure internal returns(uint) {
        uint c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
    
    
}


contract ERC20 {

    uint public totalSupply;

    function balanceOf(address who) public constant returns(uint256);

    function allowance(address owner, address spender) public constant returns(uint);

    function transferFrom(address from, address to, uint value) public  returns(bool ok);

    function approve(address spender, uint value) public returns(bool ok);

    function transfer(address to, uint value) public returns(bool ok);

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);

}
contract BeefLedger is ERC20, SafeMath
{
      string public constant name = "BeefLedger";
  
    	// Symbol of token
      string public constant symbol = "BLT"; 
      uint8 public constant decimals = 6;  // decimal places
    
      uint public totalSupply = 888888888 * 10**6 ; // total supply includes decimal upto 6 places
      
      mapping(address => uint) balances;
     
      mapping (address => mapping (address => uint)) allowed;
      address owner;
      // ico dates
      uint256 pre_date;
      uint256 ico_first;
      uint256 ico_second;
      uint token_supply_forperiod;
      bool ico_status = false;
       bool stopped = false;
      uint256 price_token;
      event MESSAGE(string m);
       event ADDRESS(address addres, uint balance);
      
       // Functions with this modifier can only be executed by the owner
      modifier onlyOwner() {
         if (msg.sender != owner) {
           revert();
          }
         _;
        }
      
      function BeefLedger() public
      {
          owner = msg.sender;
       }
      
       // Emergency Pause and Release is called by Owner in case of Emergency
    
    function emergencyPause() external onlyOwner{
        stopped = true;
    }
     
     function releasePause() external onlyOwner{
         stopped = false;
     }
     
      function start_ICO() public onlyOwner
      {
          ico_status = true;
          stopped = false;
          pre_date = now + 1 days;
          ico_first = pre_date + 70 days;
          ico_second = ico_first + 105 days;
          token_supply_forperiod = 488888889 *10**6; 
          balances[address(this)] = token_supply_forperiod;
      }
      function endICOs() public onlyOwner
      {
           ico_status = false;
          uint256 balowner = 399999999 * 10 **6;
           balances[owner] = balances[address(this)] + balowner;
           balances[address(this)] = 0;
         Transfer(address(this), msg.sender, balances[owner]);
      }


    function () public payable{ 
      require (!stopped && msg.sender != owner && ico_status);
       if(now <= pre_date)
         {
             
             price_token =  .0001167 ether;
         }
         else if(now > pre_date && now <= ico_first)
         {
             
             price_token =  .0001667 ether;
         }
         else if(now > ico_first && now <= ico_second)
         {
             
             price_token =  .0002167 ether;
         }
       
else {
    revert();
}
       
         uint no_of_tokens = (msg.value * 10 **6 ) / price_token ;
          require(balances[address(this)] >= no_of_tokens);
              
          balances[address(this)] = safeSub(balances[address(this)], no_of_tokens);
          balances[msg.sender] = safeAdd(balances[msg.sender], no_of_tokens);
        Transfer(address(this), msg.sender, no_of_tokens);
              owner.transfer(this.balance);

    }
   
   
   
    // erc20 function to return total supply
    function totalSupply() public constant returns(uint) {
       return totalSupply;
    }
    
    // erc20 function to return balance of give address
    function balanceOf(address sender) public constant returns(uint256 balance) {
        return balances[sender];
    }

    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount) public returns(bool success) {
        if (_to == 0x0) revert(); // Prevent transfer to 0x0 address. Use burn() instead
        if (balances[msg.sender] < _amount) revert(); // Check if the sender has enough

        if (safeAdd(balances[_to], _amount) < balances[_to]) revert(); // Check for overflows
       
        balances[msg.sender] = safeSub(balances[msg.sender], _amount); // Subtract from the sender
        balances[_to] = safeAdd(balances[_to], _amount); // Add the same to the recipient
        Transfer(msg.sender, _to, _amount); // Notify anyone listening that this transfer took place
        
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
    ) public returns(bool success) {
        if (balances[_from] >= _amount &&
            allowed[_from][msg.sender] >= _amount &&
            _amount > 0 &&
            safeAdd(balances[_to], _amount) > balances[_to]) {
            balances[_from] = safeSub(balances[_from], _amount);
            allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _amount);
            balances[_to] = safeAdd(balances[_to], _amount);
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount) public returns(bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns(uint256 remaining) {
        return allowed[_owner][_spender];
    }

function transferOwnership(address _newowner) external onlyOwner{
    uint new_bal = balances[msg.sender];
    owner = _newowner;
    balances[owner]= new_bal;
    balances[msg.sender] = 0;
}
   function drain() external onlyOwner {
       
        owner.transfer(this.balance);
    }
    
  }