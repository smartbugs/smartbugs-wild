pragma solidity ^0.4.18;

contract OldContract{
  function balanceOf(address _owner) view returns (uint balance) {}
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  mapping(address => bool) transfered;
  OldContract _oldContract;
  
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    
    if(balances[msg.sender] == 0 && transfered[msg.sender] == false){
    	 uint256 oldFromBalance;
  		 
  		 oldFromBalance = CheckOldBalance(msg.sender);
  		 
  		 if (oldFromBalance > 0)
       {
       	  ImportBalance(msg.sender); 
       }
    }
    
    if(balances[_to] == 0 && transfered[_to] == false){
    	 uint256 oldBalance;
  		 
  		 oldBalance = CheckOldBalance(_to);
  		 
  		 if (oldBalance > 0)
       {
       	  ImportBalance(_to); 
       }
    }
    
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
  	if(balances[_owner] == 0 && transfered[_owner] == false){
  		 uint256 oldBalance;
  		 
  		 oldBalance = CheckOldBalance(_owner);
  		 
       if (oldBalance > 0)
       {
       	  return oldBalance;
       }
       else
       {
       		return balances[_owner];
       }
    }
    else
    {
      return balances[_owner];
    }
  }

  
  function ImportBalance(address _owner) internal {
  	uint256 oldBalance;
  	
  	oldBalance = CheckOldBalance(_owner);
    if(balances[_owner] == 0  && (oldBalance > 0) && transfered[_owner] == false){
    	balances[_owner] = oldBalance;
      transfered[_owner] = true;
    }
  }
  
  function CheckOldBalance(address _owner) internal view returns (uint256 balance) {
  	if(balances[_owner] == 0 && transfered[_owner]==false){
  		
  		uint256 oldBalance;
  		
  		_oldContract = OldContract(0x3719dAc5E8aeEb886A0B49f5cbafe2DfA73A16A3);
  		
  		oldBalance = _oldContract.balanceOf(_owner);
  		
  		if (oldBalance > 0)
  		{
        return oldBalance;
      }
      else
      {
      	return balances[_owner];
      }
    }
    else
    {
    return balances[_owner];
    }

  }


}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;
  

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    
    if(balances[_from] == 0 && transfered[_from] == false){
       uint256 oldFromBalance;

       oldFromBalance = CheckOldBalance(_from);

  		 if (oldFromBalance > 0)
       {
       	  ImportBalance(_from); 
       }
    }
    
    if(balances[_to] == 0 && transfered[_to] == false){
    	 uint256 oldBalance;
  		 
  		 oldBalance = CheckOldBalance(_to);
  		 
  		 if (oldBalance > 0)
       {
       	  ImportBalance(_to); 
       }
    }
    
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract BurnableToken is StandardToken, Ownable{
    
    mapping(address => uint256) public exchangequeue;
    
    event PutForExchange(address indexed from, uint256 value);

    function putForExchange(uint256 _value) public {
    
    require(_value > 0);
    address sender = msg.sender;
      
    if(balances[sender] == 0 && transfered[sender] == false){
    	 uint256 oldFromBalance;
  		 
  		 oldFromBalance = CheckOldBalance(sender);
  		 
  		 if (oldFromBalance > 0)
       {
       	  ImportBalance(sender); 
       }
    }
    
	   require(_value <= balances[sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[sender] = balances[sender].sub(_value);
    exchangequeue[sender] = exchangequeue[sender].add(_value);
    totalSupply = totalSupply.sub(_value);
    PutForExchange(sender, _value);
  }
  
    function confirmExchange(address _address,uint256 _value) public onlyOwner {
    
    require(_value > 0);
    require(_value <= exchangequeue[_address]); 
        
   
    exchangequeue[_address] = exchangequeue[_address].sub(_value);
    
  }
  

}

contract GameCoin is Ownable, BurnableToken {

  string public constant name = "GameCoin";
  string public constant symbol = "GMC";
  uint8 public constant decimals = 2;

  uint256 public constant INITIAL_SUPPLY = 25907002099;
  
  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function GameCoin() {
    totalSupply = INITIAL_SUPPLY;
    
  }

}