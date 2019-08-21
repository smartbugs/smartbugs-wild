pragma solidity 0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
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
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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


contract BBIToken is StandardToken {

    string  public constant name    = "Beluga Banking Infrastructure Token";
    string  public constant symbol  = "BBI";
    uint256 public constant decimals= 18;   
    
    uint  public totalUsed   = 0;
    uint  public etherRaised = 0;

    /*
    *   ICO     : 01-Mar-2018 00:00:00 GMT - 31-Mar-2018 23:59:59 GMT
    */

    uint public icoEndDate        = 1522540799;   // 31-Mar-2018 23:59:59 GMT  
    uint constant SECONDS_IN_YEAR = 31536000;     // 365 * 24 * 60 * 60 secs

    // flag for emergency stop or start 
    bool public halted = false;              
    
    uint  public etherCap               =  30000 * (10 ** uint256(decimals));  // 30,000 Ether

    uint  public maxAvailableForSale    =  29800000 * (10 ** uint256(decimals));      // ( 29.8M ) 
    uint  public tokensPreSale          =  10200000 * (10 ** uint256(decimals));      // ( 10.2M ) 
    uint  public tokensTeam             =  30000000 * (10 ** uint256(decimals));      // ( 30M )
    uint  public tokensCommunity        =   5000000 * (10 ** uint256(decimals));      // ( 5M )
    uint  public tokensMasterNodes      =   5000000 * (10 ** uint256(decimals));      // ( 5M )
    uint  public tokensBankPartners     =   5000000 * (10 ** uint256(decimals));      // ( 5M ) 
    uint  public tokensDataProviders    =   5000000 * (10 ** uint256(decimals));      // ( 5M )

   /* 
   * team classification flag
   * for defining the lock period 
   */ 

   uint constant teamInternal = 1;   // team and community
   uint constant teamPartners = 2;   // bank partner, data providers etc
   uint constant icoInvestors = 3;   // ico investors

    /*  
    *  Addresses  
    */

    address public addressETHDeposit       = 0x0D2b5B427E0Bd97c71D4DF281224540044D279E1;  
    address public addressTeam             = 0x7C898F01e85a5387D58b52C6356B5AE0D5aa48ba;   
    address public addressCommunity        = 0xB7218D5a1f1b304E6bD69ea35C93BA4c1379FA43;  
    address public addressBankPartners     = 0xD5BC3c2894af7CB046398257df7A447F44b0CcA1;  
    address public addressDataProviders    = 0x9f6fce8c014210D823FdFFA274f461BAdC279A42;  
    address public addressMasterNodes      = 0x8ceA6dABB68bc9FCD6982E537A16bC9D219605b0;  
    address public addressPreSale          = 0x2526082305FdB4B999340Db3D53bD2a60F674101;     
    address public addressICOManager       = 0xE5B3eF1fde3761225C9976EBde8D67bb54d7Ae17;


    /*
    * Contract Constructor
    */

    function BBIToken() public {
            
                     totalSupply_ = 90000000 * (10 ** uint256(decimals));    // 90,000,000 - 90M;                 

                     balances[addressTeam] = tokensTeam;
                     balances[addressCommunity] = tokensCommunity;
                     balances[addressBankPartners] = tokensBankPartners;
                     balances[addressDataProviders] = tokensDataProviders;
                     balances[addressMasterNodes] = tokensMasterNodes;
                     balances[addressPreSale] = tokensPreSale;
                     balances[addressICOManager] = maxAvailableForSale;
                     
                     Transfer(this, addressTeam, tokensTeam);
                     Transfer(this, addressCommunity, tokensCommunity);
                     Transfer(this, addressBankPartners, tokensBankPartners);
                     Transfer(this, addressDataProviders, tokensDataProviders);
                     Transfer(this, addressMasterNodes, tokensMasterNodes);
                     Transfer(this, addressPreSale, tokensPreSale);
                     Transfer(this, addressICOManager, maxAvailableForSale);
                 
            }
    
    /*
    *   Emergency Stop or Start ICO.
    */

    function  halt() onlyManager public{
        require(msg.sender == addressICOManager);
        halted = true;
    }

    function  unhalt() onlyManager public {
        require(msg.sender == addressICOManager);
        halted = false;
    }

    /*
    *   Check whether ICO running or not.
    */

    modifier onIcoRunning() {
        // Checks, if ICO is running and has not been stopped
        require( halted == false);
        _;
    }
   
    modifier onIcoStopped() {
        // Checks if ICO was stopped or deadline is reached
      require( halted == true);
        _;
    }

    modifier onlyManager() {
        // only ICO manager can do this action
        require(msg.sender == addressICOManager);
        _;
    }

    /*
     * ERC 20 Standard Token interface transfer function
     * Prevent transfers until ICO period is over.
     * 
     * Transfer 
     *    - Allow 50% after six months for Community and Team
     *    - Allow all including (Dataproviders, MasterNodes, Bank) after one year
     *    - Allow Investors after ICO end date 
     */


   function transfer(address _to, uint256 _value) public returns (bool success) 
    {
           if ( msg.sender == addressICOManager) { return super.transfer(_to, _value); }           

           // Team can transfer upto 50% of tokens after six months of ICO end date 
           if ( !halted &&  msg.sender == addressTeam &&  SafeMath.sub(balances[msg.sender], _value) >= tokensTeam/2 && (now > icoEndDate + SECONDS_IN_YEAR/2) ) 
                { return super.transfer(_to, _value); }         

           // Community can transfer upto 50% of tokens after six months of ICO end date
           if ( !halted &&  msg.sender == addressCommunity &&  SafeMath.sub(balances[msg.sender], _value) >= tokensCommunity/2 && (now > icoEndDate + SECONDS_IN_YEAR/2) )
                { return super.transfer(_to, _value); }            
           
           // ICO investors can transfer after the ICO period
           if ( !halted && identifyAddress(msg.sender) == icoInvestors && now > icoEndDate ) { return super.transfer(_to, _value); }
           
           // All can transfer after a year from ICO end date 
           if ( !halted && now > icoEndDate + SECONDS_IN_YEAR) { return super.transfer(_to, _value); }

        return false;
         
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) 
    {
           if ( msg.sender == addressICOManager) { return super.transferFrom(_from,_to, _value); }

           // Team can transfer upto 50% of tokens after six months of ICO end date 
           if ( !halted &&  msg.sender == addressTeam &&  SafeMath.sub(balances[msg.sender], _value) >= tokensTeam/2 && (now > icoEndDate + SECONDS_IN_YEAR/2) ) 
                { return super.transferFrom(_from,_to, _value); }
           
           // Community can transfer upto 50% of tokens after six months of ICO end date
           if ( !halted &&  msg.sender == addressCommunity &&  SafeMath.sub(balances[msg.sender], _value) >= tokensCommunity/2 && (now > icoEndDate + SECONDS_IN_YEAR/2)) 
                { return super.transferFrom(_from,_to, _value); }      

           // ICO investors can transfer after the ICO period
           if ( !halted && identifyAddress(msg.sender) == icoInvestors && now > icoEndDate ) { return super.transferFrom(_from,_to, _value); }

           // All can transfer after a year from ICO end date 
           if ( !halted && now > icoEndDate + SECONDS_IN_YEAR) { return super.transferFrom(_from,_to, _value); }

        return false;
    }

   function identifyAddress(address _buyer) constant public returns(uint) {
        if (_buyer == addressTeam || _buyer == addressCommunity) return teamInternal;
        if (_buyer == addressMasterNodes || _buyer == addressBankPartners || _buyer == addressDataProviders) return teamPartners;
             return icoInvestors;
    }

    /**
     * Destroy tokens
     * Remove _value tokens from the system irreversibly
     */

    function  burn(uint256 _value)  onlyManager public returns (bool success) {
        require(balances[msg.sender] >= _value);   // Check if the sender has enough BBI
        balances[msg.sender] -= _value;            // Subtract from the sender
        totalSupply_ -= _value;                    // Updates totalSupply
        return true;
    }


    /*  
     *  main function for receiving the ETH from the investors 
     *  and transferring tokens after calculating the price 
     */    
    
    function buyBBITokens(address _buyer, uint256 _value) internal  {
            // prevent transfer to 0x0 address
            require(_buyer != 0x0);

            // msg value should be more than 0
            require(_value > 0);

            // if not halted
            require(!halted);

            // Now is before ICO end date 
            require(now < icoEndDate);

            // total tokens is price (1ETH = 960 tokens) multiplied by the ether value provided 
            uint tokens = (SafeMath.mul(_value, 960));

            // total used + tokens should be less than maximum available for sale
            require(SafeMath.add(totalUsed, tokens) < balances[addressICOManager]);

            // Ether raised + new value should be less than the Ether cap
            require(SafeMath.add(etherRaised, _value) < etherCap);
            
            balances[_buyer] = SafeMath.add( balances[_buyer], tokens);
            balances[addressICOManager] = SafeMath.sub(balances[addressICOManager], tokens);
            totalUsed += tokens;            
            etherRaised += _value;  
      
            addressETHDeposit.transfer(_value);
            Transfer(this, _buyer, tokens );
        }

     /*
     *  default fall back function      
     */
    function () payable onIcoRunning public {
                buyBBITokens(msg.sender, msg.value);           
            }
}