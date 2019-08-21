pragma solidity ^0.4.15;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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



/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
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

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable{
  event Mint(address indexed to, uint256 amount);
  event MintFinished(); 
  uint256 public tokensMinted = 0; 
  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    /** Modified to handle multiple capped crowdsales */
    _amount = _amount * 1 ether;
    require(tokensMinted.add(_amount)<=totalSupply); 
    tokensMinted = tokensMinted.add(_amount);
    //Zappelin Standard code 
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


/**
 * @title Wand token
 * @dev Customized mintable ERC20 Token  
 * @dev Token to support multiple Capped CrowdSales. i.e. every crowdsale with capped token limit and also
        we will be able to increase total token supply based on requirements
 */
contract WandToken is Ownable, MintableToken { 
  //Event for Presale transfers
  event TokenPreSaleTransfer(address indexed purchaser, address indexed beneficiary, uint256 amount);
  
  // Token details
  string public constant name = "Wand Token";
  string public constant symbol = "WAND";

  // 18 decimal places, the same as ETH.
  uint8 public constant decimals = 18;

  /**
    @dev Constructor. Sets the initial supplies and transfer advisor/founders/presale tokens to the given account
    @param _owner The address the account nto which presale tokens + Advisors/founders tokens transferred
   */
  function WandToken(address _owner) {
      //Total of 75M tokens
      totalSupply = 75 * 10**24;  

      // 17M tokens for Funders+advisors, 3.4M for PreSales
      tokensMinted = tokensMinted.add(20400000 * (1 ether));
      balances[_owner] = 20400000 * 1 ether;
  }   

  /**
    @dev function to handle presale trasnfers manually. Only owner can execute the contract
    @param _accounts buyers accounts that will receive the presale tokens
    @param _tokens   Amount of the tokens to be transferred to each account in _accounts list 
    @return A boolean that indicates if the operation is successful.
   */
  function batchTransfers(address[] _accounts, uint256[] _tokens) onlyOwner public returns (bool) {
    require(_accounts.length > 0);
    require(_accounts.length == _tokens.length); 
    for (uint i = 0; i < _accounts.length; i++) {
      require(_accounts[i] != 0x0);
      require(_tokens[i] > 0); 
      transfer(_accounts[i], _tokens[i] * 1 ether);
      TokenPreSaleTransfer(msg.sender, _accounts[i], _tokens[i]); 
    }
    return true;   
  }
  
  /**
    @dev function to raise the total supply. Method can be executed only by its owner
    @param _supply delta number of tokens to be added to total supply 
    @return A boolean that indicates if the operation is successful.
   */
  function raiseInitialSupply(uint256 _supply) onlyOwner public returns (bool) {
      totalSupply = totalSupply.add(_supply * 1 ether);
      return true;
  }
}

/**
 * @title Wandx CrowSale/ICO contract 
 * @dev It allows multiple Capped CrowdSales. i.e. every crowdsale with capped token limit. 
 * @dev exposes 2 more proxy methods from token contract which can be executed only by this contract owner
 */
contract WandCrowdsale is Ownable
{ 
    using SafeMath for uint256; 
     
    // The token being sold
    WandToken public token;  
    // the account tp which all incoming ether will be transferred
    address public wallet;
    // Flag to track the crowdsale status (Active/InActive)
    bool public crowdSaleOn = false;  

    // Current crowsale sate variables
    uint256 public cap = 0;  // Max allowed tokens to avaialble
    uint256 public startTime; // Crowdsale start time
    uint256 public endTime;  // Crowdsale end time
    uint256 public weiRaised = 0;  // Total amount ether/wei collected
    uint256 public tokensMinted = 0; // Total number of tokens minted/sold so far in this crowdsale
    uint256[] public discountedRates ; // Discount per slot
    uint256[] public crowsaleSlots ; // List of slots
    
    // Event to be registered when a successful token purchase happens
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    
    /** Modifiers to verify the status of the crowdsale*/
    modifier activeCrowdSale() {
        require(crowdSaleOn);
        _;
    } 
    modifier inactiveCrowdSale() {
        require(!crowdSaleOn);
        _;
    } 
    
    /**
        @dev constructor. Intializes the wallets and tokens to be traded using this contract
     */
    function WandCrowdsale() { 
        wallet = msg.sender;  
        token = new WandToken(msg.sender);
    }
    
    /**
      @dev proxy method for Wand Tokens batch transfers method, so that contract owner can call token methods
      @param _accounts buyers accounts that will receive the presale tokens
      @param _tokens   Amount of the tokens to be transferred to each account in _accounts list 
      @return A boolean that indicates if the operation is successful. 
     */
    function batchTransfers(address[] _accounts, uint256[] _tokens) onlyOwner public returns (bool) {
        require(_accounts.length > 0);
        require(_accounts.length == _tokens.length); 
        token.batchTransfers(_accounts,_tokens);
        return true;
    }
    
    /**
      @dev proxy method for Wand Tokens raiseInitialSupply method, so that contract owner can call token methods
      @param _supply delta number of tokens to be added to total supply 
      @return A boolean that indicates if the operation is successful.
     */
    function raiseInitialSupply(uint256 _supply) onlyOwner public returns (bool) {
        require(_supply > 0);
        token.raiseInitialSupply(_supply);
        return true;
    }
    
    /**
      @dev function to start the crowdsale with predefined timeslots and discounts. it will be called once for every crowdsale session and 
           it can be called only its owner
      @param _startTime at which crowdsale begins
      @param _endTime at which crowdsale stops
      @param _cap is number of tokens available during the crowdsale
      @param _crowsaleSlots array of time slots
      @param _discountedRates array of discounts 
      @return A boolean that indicates if the operation is successful
     */
    function startCrowdsale(uint256 _startTime, uint256 _endTime,  uint256 _cap, uint256[] _crowsaleSlots, uint256[] _discountedRates) inactiveCrowdSale onlyOwner public returns (bool) {  
        require(_cap > 0);   
        require(_crowsaleSlots.length > 0); 
        require(_crowsaleSlots.length == _discountedRates.length);
        require(_startTime >= uint256(now));  
        require( _endTime > _startTime); 
        
        //sets the contract state for this crowdsale
        cap = _cap * 1 ether;  //Normalized the cap to operate at wei units level
        startTime = _startTime;
        endTime = _endTime;    
        crowdSaleOn = true;
        weiRaised = 0;
        tokensMinted = 0;
        discountedRates = _discountedRates;
        crowsaleSlots = _crowsaleSlots;
        return true;
    }  

    /**
      @dev function to stop crowdsale session.it will be called once for every crowdsale session and it can be called only its owner
      @return A boolean that indicates if the operation is successful
     */
    function endCrowdsale() activeCrowdSale onlyOwner public returns (bool) {
        endTime = now;  
        if(tokensMinted < cap){
            uint256 leftoverTokens = cap.sub(tokensMinted);
            require(tokensMinted.add(leftoverTokens) <= cap);
            tokensMinted = tokensMinted.add(leftoverTokens);
            token.mint(owner, leftoverTokens.div(1 ether)); 
        }
        crowdSaleOn = false;
        return true;
    }   
    
    /**
      @dev function to calculate and return the discounted token rate based on the current timeslot
      @return _discountedRate for the current timeslot
     */
    function findDiscount() constant private returns (uint256 _discountedRate) {
        uint256 elapsedTime = now.sub(startTime);
        for(uint i=0; i<crowsaleSlots.length; i++){
            if(elapsedTime >= crowsaleSlots[i]) {
                elapsedTime = elapsedTime.sub(crowsaleSlots[i]);
            }
            else {
                _discountedRate = discountedRates[i];
                break;
            }
        } 
    }
    
    /**
      @dev  fallback function can be used to buy tokens
      */
    function () payable {
        buyTokens(msg.sender);
    }
  
    /**
      @dev  low level token purchase function
      */
    function buyTokens(address beneficiary) activeCrowdSale public payable {
        require(beneficiary != 0x0); 
        require(now >= startTime);
        require(now <= endTime);
        require(msg.value != 0);   
        
        // amount ether sent to the contract.. normalized to wei
        uint256 weiAmount = msg.value; 
        weiRaised = weiRaised.add(weiAmount); 
        
        // apply the discount based on timeslot and get the token rate (X tokens per 1 ether)
        var currentRate = findDiscount();
        // Find out Token value in wei ( Y wei per 1 Token)
        uint256 rate = uint256(1 * 1 ether).div(currentRate); 
        require(rate > 0);
        // Find out the number of tokens for given wei and normalize to ether so that tokens can be minted
        // by token contract
        uint256 numTokens = weiAmount.div(rate); 
        require(numTokens > 0); 
        require(tokensMinted.add(numTokens.mul(1 ether)) <= cap);
        tokensMinted = tokensMinted.add(numTokens.mul(1 ether));
        
        // Mint the tokens and trasfer to the buyer
        token.mint(beneficiary, numTokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, numTokens); 
        // Transfer the ether to Wallet and close the purchase
        wallet.transfer(weiAmount);
    } 
}