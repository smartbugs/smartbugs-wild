/**
  * Legenrich LeRT token 
  *
  * More at https://legenrich.com
  *
  * Smart contract and payment gateway developed by https://smart2be.com, 
  * Premium ICO campaign managing company
  *
  **/

pragma solidity ^0.4.19;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}


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

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }


contract TokenERC20 is owned {
    using SafeMath for uint256;
 
    bool public mintingFinished = false;

     modifier canMint {
        require(!mintingFinished);
        _;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowed;
     // List of Team and Founders account's frozen till 15 November 2018
    mapping (address => uint256) public frozenAccount;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed spender, uint256 value);
    event Frozen(address indexed from, uint256 till);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    // Minting 
    event Mint(address indexed to, uint256 amount);
    event MintStarted();
    event MintFinished();

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);      // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                        // Give the creator all initial tokens
        name = tokenName;                                           // Set the name for display purposes
        symbol = tokenSymbol;                                       // Set the symbol for display purposes
    }

    /* Returns total supply of issued tokens */
    function totalSupply() constant public returns (uint256 supply) {
        return totalSupply;
    }
    /* Returns balance of  _owner 
     *   
     * @param _owner Address to check balance   
     *   
     */
    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balanceOf[_owner];
    }

    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    /**
      * Transfer tokens
      *
      * Send `_value` tokens to `_to` from your account
      *
      * @param _to The address of the recipient
      * @param _value the amount to send
      */   
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balanceOf[msg.sender]);
        require(frozenAccount[msg.sender] < now);                   // Check if sender is frozen
        if (frozenAccount[msg.sender] < now) frozenAccount[msg.sender] = 0;
        // SafeMath.sub will throw if there is not enough balance.
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
   
    /**
      * @dev Transfer tokens from one address to another
      * @param _from address The address which you want to send tokens from
      * @param _to address The address which you want to transfer to
      * @param _value uint256 the amount of tokens to be transferred
      */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balanceOf[_from]);
        require(_value <= allowed[_from][msg.sender]);
        require(frozenAccount[_from] < now);                   // Check if sender is frozen
        if (frozenAccount[_from] < now) frozenAccount[_from] = 0;
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowed for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
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

    /**
     * Burns tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowed[_from][msg.sender]);    // Check allowed
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowed[_from][msg.sender] -= _value;             // Subtract from the sender's allowed
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
    /**
     * Create new tokens
     *
     * Create `_value` tokens on behalf of Owner.
     *
     * @param _value the amount of money to burn
     */
    function _mint(uint256 _value) canMint internal  {
        totalSupply = totalSupply.add(_value);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_value);
    }
    
    /**
      * @dev Function to stop minting new tokens.
      * @return True if the operation was successful.
      */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        MintFinished();
        return true;
    }
    /**
      * @dev Function to start minting new tokens.
      * @return True if the operation was successful.
      */
    function startMinting() onlyOwner  public returns (bool) {
        mintingFinished = false;
        MintStarted();
        return true;
    }  

    /**
      * @notice Freezes from sending & receiving tokens. For users protection can't be used after 1542326399
      * and will not allow corrections.
      *           
      * @param _from  Founders and Team account we are freezing from sending
      * @param _till Timestamp till the end of freeze
      *
      */
   function freezeAccount(address _from, uint256 _till) onlyOwner public {
        require(frozenAccount[_from] == 0);
        frozenAccount[_from] = _till;                  
    }

}


contract LeRT is TokenERC20 {

 

    // This is time for next Profit Equivalent
    struct periodTerms { 
        uint256 periodTime;
        uint periodBonus;   // In Procents
    }
    
    uint256 public priceLeRT = 100000000000000; // Starting Price 1 ETH = 10000 LeRT

    uint public currentPeriod = 0;
    
    mapping (uint => periodTerms) public periodTable;

    // List of Team and Founders account's frozen till 01 May 2019
    mapping (address => uint256) public frozenAccount;

    
    /* Handles incoming payments to contract's address */
    function() payable canMint public {
        if (now > periodTable[currentPeriod].periodTime) currentPeriod++;
        require(currentPeriod != 7);
        
        uint256 newTokens;
        require(priceLeRT > 0);
        // calculate new tokens
        newTokens = msg.value / priceLeRT * 10 ** uint256(decimals);
        // calculate bonus tokens
        newTokens += newTokens/100 * periodTable[currentPeriod].periodBonus; 
        _mint(newTokens);
        owner.transfer(msg.value); 
    }

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function LeRT(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {
        // set periods on startup
        periodTable[0].periodTime = 1519084800;
        periodTable[0].periodBonus = 50;
        periodTable[1].periodTime = 1519343999;
        periodTable[1].periodBonus = 45;
        periodTable[2].periodTime = 1519689599;
        periodTable[2].periodBonus = 40;
        periodTable[3].periodTime = 1520294399;
        periodTable[3].periodBonus = 35;
        periodTable[4].periodTime = 1520899199;
        periodTable[4].periodBonus = 30;
        periodTable[5].periodTime = 1522108799;
        periodTable[5].periodBonus = 20;
        periodTable[6].periodTime = 1525132799;
        periodTable[6].periodBonus = 15;
        periodTable[7].periodTime = 1527811199;
        periodTable[7].periodBonus = 0;}

    function setPrice(uint256 _value) public onlyOwner {
        priceLeRT = _value;
    }
    function setPeriod(uint _period, uint256 _periodTime, uint256 _periodBouns) public onlyOwner {
        periodTable[_period].periodTime = _periodTime;
        periodTable[_period].periodBonus = _periodBouns;
    }
    
    function setCurrentPeriod(uint _period) public onlyOwner {
        currentPeriod = _period;
    }
    
    function mintOther(address _to, uint256 _value) public onlyOwner {
        uint256 newTokens;
        newTokens = _value + _value/100 * periodTable[currentPeriod].periodBonus; 
        balanceOf[_to] += newTokens;
        totalSupply += newTokens;
    }
}