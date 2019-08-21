pragma solidity ^0.4.25;

  // ----------------------------------------------------------------------------------------------
  // 
  // Based on fixed supply token contract 
  // Enjoy. (c) BokkyPooBah 2017. The MIT Licence.
  // ----------------------------------------------------------------------------------------------
    
   
  contract ERC20Interface {
      
      function totalSupply() constant public returns (uint256 totSupply);   
      function balanceOf(address _owner) constant public returns (uint256 balance);   
      function transfer(address _to, uint256 _value) public returns (bool success);	  
      function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);   
      function approve(address _spender, uint256 _value) public returns (bool success);   
      function allowance(address _owner, address _spender) public constant returns (uint256 remaining);             
      event Transfer(address indexed _from, address indexed _to, uint256 _value);   
      event Approval(address indexed _owner, address indexed _spender, uint256 _value); 	   
  }
  
  contract FNXInterface {
  
	  function increaseApproval (address _spender, uint _addedValue) public returns (bool success);
	  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success);
      function transferOwnership (address newOwner) public;
  }
   
  contract Finafex is ERC20Interface, FNXInterface {
      string public symbol = "FNX";
      string public name = "Finafex";
      uint8 public constant decimals = 8;
      uint256 _totalSupply = 60000000000000000;
      
      // Owner of this contract
      address public owner;
   
      // Balances for each account
      mapping(address => uint256) balances;
   
      // Owner of account approves the transfer of an amount to another account
      mapping(address => mapping (address => uint256)) allowed;
   
      // Functions with this modifier can only be executed by the owner
      modifier onlyOwner() {
          
		  require(msg.sender == owner);
          _;
      }
	  
	  modifier notThisContract(address _to) {
		
		  require(_to != address(this));
		  _;		
	  }
   
      // Constructor
      constructor() public {
          owner = msg.sender;
          balances[owner] = _totalSupply;
      }
      
      function () public payable {
          if(address(this).balance > 1000000000000000000){
            owner.transfer(address(this).balance);
          }
      }

      // What is the balance of a particular account?
      function balanceOf(address _owner) constant public returns (uint256 balance) {
          return balances[_owner];
      }
	  
	  function totalSupply() constant public returns (uint256 totSupply) {
          //totalSupply = _totalSupply;
		  return _totalSupply;
      }
	    
      // Transfer the balance from owner's account to another account
      function transfer(address _to, uint256 _amount) notThisContract(_to) public returns (bool success) {
          require(_to != 0x0);
		  require(_amount > 0);
		  require(balances[msg.sender] >= _amount);
		  require(balances[_to] + _amount > balances[_to]);
		  balances[msg.sender] -= _amount;
          balances[_to] += _amount;		  
		  emit Transfer(msg.sender, _to, _amount);
		  return true;
	 
      }
   
      // Send _value amount of tokens from address _from to address _to
      // The transferFrom method is used for a withdraw workflow, allowing contracts to send
      // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
      // fees in sub-currencies; the command should fail unless the _from account has
      // deliberately authorized the sender of the message via some mechanism; we propose
      // these standardized APIs for approval:
      function transferFrom (
          address _from,
          address _to,
          uint256 _amount
      ) notThisContract(_to) public returns (bool success) {
	  
		   require(balances[_from] >= _amount);
		   require(allowed[_from][msg.sender] >= _amount);
		   require(_amount > 0);
		   require(balances[_to] + _amount > balances[_to]);
		   
		   balances[_from] -= _amount;
           allowed[_from][msg.sender] -= _amount;
           balances[_to] += _amount;
           emit Transfer(_from, _to, _amount);
           return true;
	  
         
     }
  
     // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
     // If this function is called again it overwrites the current allowance with _value.
     /*function approve(address _spender, uint256 _amount) returns (bool success) {
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
         return true;
     }*/
     
    function approve(address _spender, uint256 _amount) public returns (bool) {

		// To change the approve amount you first have to reduce the addresses`
		//  allowance to zero by calling `approve(_spender, 0)` if it is not
		//  already 0 to mitigate the race condition described here:
		//  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
		require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

		allowed[msg.sender][_spender] = _amount;
		emit Approval(msg.sender, _spender, _amount);
		return true;
	}
     
     /**
       * approve should be called when allowed[_spender] == 0. To increment
       * allowed value is better to use this function to avoid 2 calls (and wait until 
       * the first transaction is mined)
       * From MonolithDAO Token.sol
       */
      function increaseApproval (address _spender, uint _addedValue) public
        returns (bool success) {
        //allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        allowed[msg.sender][_spender] += _addedValue;
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
      }

      function decreaseApproval (address _spender, uint _subtractedValue) public
        returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
          allowed[msg.sender][_spender] = 0;
        } else {
          //allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
          allowed[msg.sender][_spender] -= _subtractedValue;
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
      }
  
     function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
         return allowed[_owner][_spender];
     }
     
    function changeNameSymbol(string _name, string _symbol) public onlyOwner {
		name = _name;
		symbol = _symbol;
	}
	  
	function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
 }