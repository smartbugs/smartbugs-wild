pragma solidity 0.4.25;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */

library SafeMath 
{

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */

  function mul(uint256 a, uint256 b) internal pure returns(uint256 c) 
  {
     if (a == 0) 
     {
     	return 0;
     }
     c = a * b;
     require(c / a == b);
     return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */

  function div(uint256 a, uint256 b) internal pure returns(uint256) 
  {
     return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */

  function sub(uint256 a, uint256 b) internal pure returns(uint256) 
  {
     require(b <= a);
     return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */

  function add(uint256 a, uint256 b) internal pure returns(uint256 c) 
  {
     c = a + b;
     require(c >= a);
     return c;
  }
}

contract ERC20
{
    function totalSupply() public view returns (uint256);
    function balanceOf(address _who) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function allowance(address _owner, address _spender) public view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public returns (bool);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

/**
 * @title Basic token
 */

contract GSCP is ERC20
{
    using SafeMath for uint256;
   
    uint256 constant public TOKEN_DECIMALS = 10 ** 18;
    string public constant name            = "Genesis Supply Chain Platform";
    string public constant symbol          = "GSCP";
    uint256 public constant totalTokens    = 999999999;
    uint256 public totalTokenSupply        = totalTokens.mul(TOKEN_DECIMALS);
    uint8 public constant decimals         = 18;
    address public owner;

    struct AdvClaimLimit 
    {
        uint256     time_limit_epoch;
        uint256     last_claim_time;
        uint256[3]  tokens;
        uint8       round;
        bool        limitSet;
    }

    struct TeamClaimLimit 
    {
        uint256     time_limit_epoch;
        uint256     last_claim_time;
        uint256[4]  tokens;
        uint8       round;
        bool        limitSet;
    }

    struct ClaimLimit 
    {
       uint256 time_limit_epoch;
       uint256 last_claim_time;
       uint256 tokens;
       bool    limitSet;
    }

    event Burn(address indexed _burner, uint256 _value);

    /** mappings **/ 
    mapping(address => uint256) public  balances;
    mapping(address => mapping(address => uint256)) internal  allowed;
    mapping(address => AdvClaimLimit)  advClaimLimits;
    mapping(address => TeamClaimLimit) teamClaimLimits;
    mapping(address => ClaimLimit) claimLimits;

    /**
     * @dev Throws if called by any account other than the owner.
     */

    modifier onlyOwner() 
    {
       require(msg.sender == owner);
       _;
    }
    
    /** constructor **/

    constructor() public
    {
       owner = msg.sender;
       balances[address(this)] = totalTokenSupply;
       emit Transfer(address(0x0), address(this), balances[address(this)]);
    }

    /**
     * @dev Burn specified number of GSCP tokens
     * This function will be called once after all remaining tokens are transferred from
     * smartcontract to owner wallet
     */

     function burn(uint256 _value) onlyOwner public returns (bool) 
     {
        require(_value <= balances[msg.sender]);

        address burner = msg.sender;

        balances[burner] = balances[burner].sub(_value);
        totalTokenSupply = totalTokenSupply.sub(_value);

        emit Burn(burner, _value);
        return true;
     }     

     /**
      * @dev total number of tokens in existence
      */

     function totalSupply() public view returns(uint256 _totalSupply) 
     {
        _totalSupply = totalTokenSupply;
        return _totalSupply;
     }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of. 
     * @return An uint256 representing the amount owned by the passed address.
     */

    function balanceOf(address _owner) public view returns (uint256) 
    {
       return balances[_owner];
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amout of tokens to be transfered
     */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool)     
    {
       if (_value == 0) 
       {
           emit Transfer(_from, _to, _value);  // Follow the spec to launch the event when value is equal to 0
           return;
       }

       require(!advClaimLimits[msg.sender].limitSet, "Limit is set and use advClaim");
       require(!teamClaimLimits[msg.sender].limitSet, "Limit is set and use teamClaim");
       require(!claimLimits[msg.sender].limitSet, "Limit is set and use claim");
       require(_to != address(0x0));
       require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value >= 0);

       balances[_from] = balances[_from].sub(_value);
       allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
       balances[_to] = balances[_to].add(_value);
       emit Transfer(_from, _to, _value);
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
    * @param _tokens The amount of tokens to be spent.
    */

    function approve(address _spender, uint256 _tokens) public returns(bool)
    {
       require(_spender != address(0x0));

       allowed[msg.sender][_spender] = _tokens;
       emit Approval(msg.sender, _spender, _tokens);
       return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifing the amount of tokens still avaible for the spender.
     */

    function allowance(address _owner, address _spender) public view returns(uint256)
    {
       require(_owner != address(0x0) && _spender != address(0x0));

       return allowed[_owner][_spender];
    }

    /**
    * @dev transfer token for a specified address
    * @param _address The address to transfer to.
    * @param _tokens The amount to be transferred.
    */

    function transfer(address _address, uint256 _tokens) public returns(bool)
    {
       if (_tokens == 0) 
       {
           emit Transfer(msg.sender, _address, _tokens);  // Follow the spec to launch the event when tokens are equal to 0
           return;
       }

       require(!advClaimLimits[msg.sender].limitSet, "Limit is set and use advClaim");
       require(!teamClaimLimits[msg.sender].limitSet, "Limit is set and use teamClaim");
       require(!claimLimits[msg.sender].limitSet, "Limit is set and use claim");
       require(_address != address(0x0));
       require(balances[msg.sender] >= _tokens);

       balances[msg.sender] = (balances[msg.sender]).sub(_tokens);
       balances[_address] = (balances[_address]).add(_tokens);
       emit Transfer(msg.sender, _address, _tokens);
       return true;
    }
    
    /**
    * @dev transfer token from smart contract to another account, only by owner
    * @param _address The address to transfer to.
    * @param _tokens The amount to be transferred.
    */

    function transferTo(address _address, uint256 _tokens) external onlyOwner returns(bool) 
    {
       require( _address != address(0x0)); 
       require( balances[address(this)] >= _tokens.mul(TOKEN_DECIMALS) && _tokens.mul(TOKEN_DECIMALS) > 0);

       balances[address(this)] = ( balances[address(this)]).sub(_tokens.mul(TOKEN_DECIMALS));
       balances[_address] = (balances[_address]).add(_tokens.mul(TOKEN_DECIMALS));
       emit Transfer(address(this), _address, _tokens.mul(TOKEN_DECIMALS));
       return true;
    }
	
    /**
    * @dev transfer ownership of this contract, only by owner
    * @param _newOwner The address of the new owner to transfer ownership
    */

    function transferOwnership(address _newOwner)public onlyOwner
    {
       require( _newOwner != address(0x0));

       balances[_newOwner] = (balances[_newOwner]).add(balances[owner]);
       balances[owner] = 0;
       owner = _newOwner;
       emit Transfer(msg.sender, _newOwner, balances[_newOwner]);
   }

   /**
   * @dev Increase the amount of tokens that an owner allowed to a spender
   */

   function increaseApproval(address _spender, uint256 _addedValue) public returns (bool success) 
   {
      allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
      emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
   }

   /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender
   */

   function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool success) 
   {
      uint256 oldValue = allowed[msg.sender][_spender];

      if (_subtractedValue > oldValue) 
      {
         allowed[msg.sender][_spender] = 0;
      }
      else 
      {
         allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
      }
      emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
      return true;
   }

   /**
    * @dev Transfer adviser tokens to another account, time and percent limit apply.
    */

   function adviserClaim(address _recipient) public
   {
      require(_recipient != address(0x0), "Invalid recipient");
      require(msg.sender != _recipient, "Self transfer");
      require(advClaimLimits[msg.sender].limitSet, "Limit not set");
      require(advClaimLimits[msg.sender].round < 3, "Claims are over for this adviser wallet");
      
      if (advClaimLimits[msg.sender].last_claim_time > 0) {
        require (now > ((advClaimLimits[msg.sender].last_claim_time).add 
           (advClaimLimits[msg.sender].time_limit_epoch)), "Time limit");
      }
       
       uint256 tokens = advClaimLimits[msg.sender].tokens[advClaimLimits[msg.sender].round];
       if (balances[msg.sender] < tokens)
            tokens = balances[msg.sender];
        
       if (tokens == 0) {
           emit Transfer(msg.sender, _recipient, tokens);
           return;
       }
       
       balances[msg.sender] = (balances[msg.sender]).sub(tokens);
       balances[_recipient] = (balances[_recipient]).add(tokens);
       
       // update last claim time
       advClaimLimits[msg.sender].last_claim_time = now;
       advClaimLimits[msg.sender].round++;
       emit Transfer(msg.sender, _recipient, tokens);
   }
 
   /**
    * @dev Set limit on a claim per adviser address
    */

   function setAdviserClaimLimit(address _addr) public onlyOwner
   {
      uint256 num_days  = 90;  // 3 Months lock-in
      uint256 percent   = 25;  
      uint256 percent1  = 25;  
      uint256 percent2  = 50;  

      require(_addr != address(0x0), "Invalid address");

      advClaimLimits[_addr].time_limit_epoch = (now.add(((num_days).mul(1 minutes)))).sub(now);
      advClaimLimits[_addr].last_claim_time  = 0;

      if (balances[_addr] > 0) 
      {
          advClaimLimits[_addr].tokens[0] = ((balances[_addr]).mul(percent)).div(100);
          advClaimLimits[_addr].tokens[1] = ((balances[_addr]).mul(percent1)).div(100);
          advClaimLimits[_addr].tokens[2] = ((balances[_addr]).mul(percent2)).div(100);
      }    
      else 
      {
          advClaimLimits[_addr].tokens[0] = 0;
   	  advClaimLimits[_addr].tokens[1] = 0;
   	  advClaimLimits[_addr].tokens[2] = 0;
      }    
      
      advClaimLimits[_addr].round = 0;
      advClaimLimits[_addr].limitSet = true;
   }

   /**
    * @dev Transfer team tokens to another account, time and percent limit apply.
    */

   function teamClaim(address _recipient) public
   {
      require(_recipient != address(0x0), "Invalid recipient");
      require(msg.sender != _recipient, "Self transfer");
      require(teamClaimLimits[msg.sender].limitSet, "Limit not set");
      require(teamClaimLimits[msg.sender].round < 4, "Claims are over for this team wallet");
      
      if (teamClaimLimits[msg.sender].last_claim_time > 0) {
        require (now > ((teamClaimLimits[msg.sender].last_claim_time).add 
           (teamClaimLimits[msg.sender].time_limit_epoch)), "Time limit");
      }
       
       uint256 tokens = teamClaimLimits[msg.sender].tokens[teamClaimLimits[msg.sender].round];
       if (balances[msg.sender] < tokens)
            tokens = balances[msg.sender];
        
       if (tokens == 0) {
           emit Transfer(msg.sender, _recipient, tokens);
           return;
       }
       
       balances[msg.sender] = (balances[msg.sender]).sub(tokens);
       balances[_recipient] = (balances[_recipient]).add(tokens);
       
       // update last claim time
       teamClaimLimits[msg.sender].last_claim_time = now;
       teamClaimLimits[msg.sender].round++;
       emit Transfer(msg.sender, _recipient, tokens);
   }
 
   /**
    * @dev Set limit on a claim per team member address
    */

   function setTeamClaimLimit(address _addr) public onlyOwner
   {
      uint256 num_days  = 180;  // 6 Months lock-in
      uint256 percent   = 10;  
      uint256 percent1  = 15;  
      uint256 percent2  = 35;  
      uint256 percent3  = 40;  

      require(_addr != address(0x0), "Invalid address");

      teamClaimLimits[_addr].time_limit_epoch = (now.add(((num_days).mul(1 minutes)))).sub(now);
      teamClaimLimits[_addr].last_claim_time  = 0;

      if (balances[_addr] > 0) 
      {
          teamClaimLimits[_addr].tokens[0] = ((balances[_addr]).mul(percent)).div(100);
          teamClaimLimits[_addr].tokens[1] = ((balances[_addr]).mul(percent1)).div(100);
          teamClaimLimits[_addr].tokens[2] = ((balances[_addr]).mul(percent2)).div(100);
          teamClaimLimits[_addr].tokens[3] = ((balances[_addr]).mul(percent3)).div(100);
      }    
      else 
      {
          teamClaimLimits[_addr].tokens[0] = 0;
   	      teamClaimLimits[_addr].tokens[1] = 0;
   	      teamClaimLimits[_addr].tokens[2] = 0;
   	      teamClaimLimits[_addr].tokens[3] = 0;
      }    
      
      teamClaimLimits[_addr].round = 0;
      teamClaimLimits[_addr].limitSet = true;
    }

    /**
    * @dev Transfer tokens to another account, time and percent limit apply
    */

    function claim(address _recipient) public
    {
       require(_recipient != address(0x0), "Invalid recipient");
       require(msg.sender != _recipient, "Self transfer");
       require(claimLimits[msg.sender].limitSet, "Limit not set");
       
       if (claimLimits[msg.sender].last_claim_time > 0) 
       {
          require (now > ((claimLimits[msg.sender].last_claim_time).
            add(claimLimits[msg.sender].time_limit_epoch)), "Time limit");
       }
       
       uint256 tokens = claimLimits[msg.sender].tokens;

       if (balances[msg.sender] < tokens)
            tokens = balances[msg.sender];
        
       if (tokens == 0) 
       {
            emit Transfer(msg.sender, _recipient, tokens);
            return;
       }
       
       balances[msg.sender] = (balances[msg.sender]).sub(tokens);
       balances[_recipient] = (balances[_recipient]).add(tokens);
       
       // update last claim time
       claimLimits[msg.sender].last_claim_time = now;
       
       emit Transfer(msg.sender, _recipient, tokens);
    }
 

    /**
    * @dev Set limit on a claim per address
    */

    function setClaimLimit(address _address, uint256 _days, uint256 _percent) public onlyOwner
    {
       require(_percent <= 100, "Invalid percent");

       claimLimits[_address].time_limit_epoch = (now.add(((_days).mul(1 minutes)))).sub(now);
       claimLimits[_address].last_claim_time  = 0;
   		
       if (balances[_address] > 0)
   	      claimLimits[_address].tokens = ((balances[_address]).mul(_percent)).div(100);
       else
   	      claimLimits[_address].tokens = 0;
   		    
       claimLimits[_address].limitSet = true;
    }

   

}