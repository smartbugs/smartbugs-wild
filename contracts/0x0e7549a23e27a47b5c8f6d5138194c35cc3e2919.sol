pragma solidity ^ 0.4 .16;



// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

// Sample fixed supply token contract

// Enjoy. (c) BokkyPooBah 2017. The MIT Licence.

// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns(uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


// ERC Token Standard #20 Interface

//https://github.com/ethereum/EIPs/issues/20

contract ERC20Interface {

     // Get the total token supply

    
    function totalSupply() constant returns(uint256 _totalSupply);

    

    // Get the account balance of another account with address _owner

    
    function balanceOf(address _owner) constant returns(uint256 balance);

    

     // Send _value amount of tokens to address _to

    
    function transfer(address _to, uint256 _value) returns(bool success);

     // Send _value amount of tokens from address _from to address _to


    function transferFrom(address _from, address _to, uint256 _value) returns(bool success);

 // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
 // If this function is called again it overwrites the current allowance with _value.

// this function is required for some DEX functionality

 
    function approve(address _spender, uint256 _value) returns(bool success);

   // Returns the amount which _spender is still allowed to withdraw from _owner


    function allowance(address _owner, address _spender) constant returns(uint256 remaining);

   // Triggered when tokens are transferred.

   
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.

    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract FreeCatalugnaCoin is ERC20Interface {
    using SafeMath
    for uint256;

    
    string public constant name = "Free Catalugna Coin";  // Name of Token
    
    string public constant symbol = "FCC";     // Symbol of Token

  uint8 public constant decimals = 18;    // Amount of decimals for display purposes  

 uint256 _totalSupply = 10000000 * 10 **18;  // 10 Million token total supply......muliplied with 10 power 18 because of decimals of 4 precision

    
    uint256 public constant RATE = 1000;        // 1 Ether = 1000 tokens

    // Owner of this contract
    address public owner;

   // Balances for each account
   mapping(address => uint256) balances;
   
   // Owner of account approves the transfer of an amount to another account

   mapping(address => mapping(address => uint256)) allowed;

// Functions with this modifier can only be executed by the owner

    modifier onlyOwner() {
     if (msg.sender != owner) {
         revert();
            }
            _;
         }
    uint256 tokens;
   
    // This is the Constructor
    
    function FreeCatalugnaCoin() {
       
        owner = msg.sender;
        balances[owner] = _totalSupply;
    }
    
     function() payable {
        buyTokens();
    }
    
    function buyTokens() payable {

        require(msg.value > 0 );
         tokens = msg.value.mul(RATE);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        balances[owner] = balances[owner].sub(tokens);
        
        owner.transfer(msg.value);
    }

/* 

  function FixedSupplyToken() {

      owner = msg.sender;

     balances[owner] = _totalSupply;
        
    } */

    function totalSupply() constant returns(uint256) {
       return _totalSupply;
    }

// What is the balance of a particular account?

    function balanceOf(address _owner) constant returns(uint256 balance) {

        return balances[_owner];

    }
// Transfer the balance from owner&#39;s account to another account
  /* Send coins during transactions*/

    function transfer(address _to, uint256 _amount) returns(bool success) {

        if (balances[msg.sender] >= _amount &&  balances[_to] + _amount > balances[_to]) {

            balances[msg.sender] -= _amount;

            balances[_to] += _amount;

            Transfer(msg.sender, _to, _amount);

            return true;

        } else {

            return false;

        }

    }
// Send _value amount of tokens from address _from to address _to
 // The transferFrom method is used for a withdraw workflow, allowing contracts to send
 // tokens on your behalf, for example to &quot;deposit&quot; to a contract address and/or to charge

// fees in sub-currencies; the command should fail unless the _from account has
// deliberately authorized the sender of the message via some mechanism; we propose
 // these standardized APIs for approval:

    function transferFrom(

       address _from,

      address _to,

       uint256 _amount

       ) returns(bool success) {

        if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount &&  _amount > 0 && balances[_to] + _amount > balances[_to]) {

            balances[_from] -= _amount;

            allowed[_from][msg.sender] -= _amount;

            balances[_to] += _amount;

            Transfer(_from, _to, _amount);

            return true;
} else 
{
 return false;
        }

         }

    

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.

   // If this function is called again it overwrites the current allowance with _value.

    function approve(address _spender, uint256 _amount) returns(bool success) {

     
        allowed[msg.sender][_spender] = _amount;

        Approval(msg.sender, _spender, _amount);

      
        return true;

    }

    function allowance(address _owner, address _spender) constant returns(uint256 remaining) {

          
            return allowed[_owner][_spender];
    }
    
    // Failsafe drain only owner can call this function
    function drain() onlyOwner {
          owner.transfer(this.balance);
    }
}