pragma solidity 0.4.18;

/**
 * Contract "Math"
 * Purpose: Math operations with safety checks
 * Status : Complete
 * 
 */
contract Math {

    /**
    * Multiplication with safety check
    */
    function Mul(uint a, uint b) pure internal returns (uint) {
      uint c = a * b;
      //check result should not be other wise until a=0
      assert(a == 0 || c / a == b);
      return c;
    }

    /**
    * Division with safety check
    */
    function Div(uint a, uint b) pure internal returns (uint) {
      //overflow check; b must not be 0
      assert(b > 0);
      uint c = a / b;
      assert(a == b * c + a % b);
      return c;
    }

    /**
    * Subtraction with safety check
    */
    function Sub(uint a, uint b) pure internal returns (uint) {
      //b must be greater that a as we need to store value in unsigned integer
      assert(b <= a);
      return a - b;
    }

    /**
    * Addition with safety check
    */
    function Add(uint a, uint b) pure internal returns (uint) {
      uint c = a + b;
      //result must be greater as a or b can not be negative
      assert(c>=a && c>=b);
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


contract etherecash is ERC20,Math
{
   string public constant symbol = "ECH";
     string public constant name = "EtherEcash";
     uint public constant decimals = 18;
     uint256 _totalSupply = Mul(360000000,(10 **decimals));
     
     // Owner of this contract
     address public owner;
  
     // Balances for each account
     mapping(address => uint256) balances;
  
     // Owner of account approves the transfer of an amount to another account
     mapping(address => mapping (address => uint256)) allowed;
  
     // Functions with this modifier can only be executed by the owner
     modifier onlyOwner() {
         if (msg.sender != owner) {
             revert();
         }
         _;
     }
  
     // Constructor
     function etherecash() public {
         owner = msg.sender;
         balances[owner] = _totalSupply;
     }
  
    // what is the total supply of the ech tokens
     function totalSupply() public view returns (uint256 total_Supply) {
         total_Supply = _totalSupply;
     }
  
     // What is the balance of a particular account?
     function balanceOf(address _owner)public view returns (uint256 balance) {
         return balances[_owner];
     }
  
     // Transfer the balance from owner's account to another account
     function transfer(address _to, uint256 _amount)public returns (bool success) {
         if (balances[msg.sender] >= _amount 
             && _amount > 0
             && balances[_to] + _amount > balances[_to]) {
             balances[msg.sender] = Sub(balances[msg.sender], _amount);
             balances[_to] = Add(balances[_to], _amount);
             Transfer(msg.sender, _to, _amount);
             return true;
         } else {
             return false;
         }
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
         if (balances[_from] >= _amount
             && allowed[_from][msg.sender] >= _amount
             && _amount > 0
             && balances[_to] + _amount > balances[_to]) {
             balances[_from] = Sub(balances[_from], _amount);
             allowed[_from][msg.sender] = Sub(allowed[_from][msg.sender], _amount);
             balances[_to] = Add(balances[_to], _amount);
             Transfer(_from, _to, _amount);
             return true;
         } else {
             return false;
         }
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
	    balances[newOwner] = Add(balances[newOwner],balances[owner]);
	    balances[owner] = 0;
	    owner = newOwner;
	}

}