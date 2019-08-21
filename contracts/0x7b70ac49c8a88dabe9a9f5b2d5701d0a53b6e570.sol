pragma solidity ^0.4.18;

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

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint256);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint256 tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract VanityToken is owned, ERC20Interface {
    // Public variables of the token
    string  public name = "Vanity Token";
    string  public symbol = "VNT";
    uint8   public decimals = 18;
    
    uint256 public currentSupply = 0;
    uint256 public maxSupply = 1333337;
    uint256 public bonusAmtThreshold = 20000;
    uint256 public bonusSignalValue = 0.001 ether;
    uint256 public _totalSupply;
    uint256 public tokenXchangeRate ;
    uint    public icoStartTime;
    bool    public purchasingAllowed = false;
    bool    public demo = false;

    uint    public windowBonusMax = 43200 seconds;
    uint    public windowBonusMin = 10800 seconds; 
    uint    public windowBonusStep1 = 21600 seconds;
    uint    public windowBonusStep2 = 28800 seconds;

    // This creates an array with all balances
    mapping (address => uint256) public _balanceOf;
    mapping (address => uint256) public bonusOf;
    mapping (address => uint) public timeBought;
    mapping (address => uint256) public transferredAtSupplyValue;
    mapping (address => mapping (address => uint256)) public _allowance;


    function setBonuses(bool _d) onlyOwner public {
        if (_d == true) {
            windowBonusMax = 20 minutes;
            windowBonusMin = 30 seconds;
            windowBonusStep1 = 60 seconds;
            windowBonusStep2 = 120 seconds;
            bonusAmtThreshold = 500;
            maxSupply = 13337;
        } else {
            windowBonusMax = 12 hours;
            windowBonusMin = 3 hours;
            windowBonusStep1 = 6 hours;
            windowBonusStep2 = 8 hours;
            bonusAmtThreshold = 20000;
            maxSupply = 1333337;
        }
        demo = _d;
    }

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);


    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

     modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4 || msg.data.length == 4);
        _;
    }
 

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function VanityToken() public payable {
        tokenXchangeRate = 300;
        _balanceOf[address(this)] = 0;
        owner = msg.sender;     
        setBonuses(false);      
        //enablePurchasing();              
        _totalSupply = maxSupply * 10 ** uint256(decimals);  
    }

    function totalSupply() public constant returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public constant returns (uint256) { return _balanceOf[_owner] ; }

    function allowance(address tokenOwner, address spender) onlyPayloadSize(2 * 32) public constant returns (uint remaining) {
        return _allowance[tokenOwner][spender];
    }

    function kill() public {
        if (msg.sender == owner) 
            selfdestruct(owner);
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint256 _value, uint256 _bonusValue) onlyPayloadSize(4*32) internal returns (bool) {

        if (_value == 0 && _bonusValue == 0) {return false;}
        if (_value!=0&&_bonusValue!=0) {return false;}  

        require(_to != 0x0);
       
        // Check for overflows[]       
        require(_balanceOf[_to] + _value >= _balanceOf[_to]);
        require(bonusOf[_to] + _bonusValue >= bonusOf[_to]);
        
        if (_value > 0) {
            _balanceOf[_from] += _value;
            _balanceOf[_to] += _value;
            timeBought[_to] = now;
            Transfer(_from, _to, _value);
        } else if (_bonusValue > 0) {
            _balanceOf[_from] += _bonusValue;
            _balanceOf[_to] += _bonusValue;
            bonusOf[_to] += _bonusValue;     
            timeBought[_to] = 0;
            Transfer(_from, _to, _bonusValue);
        }

        return true;
    }


    function buy() public payable {
        require(purchasingAllowed);
        require(msg.value > 0);
        require(msg.value >= 0.01 ether || msg.value == bonusSignalValue);
        _buy(msg.value);
    }

    function() public payable {
        buy();
    }

    function _buy(uint256 value) internal {

        uint tPassed = now - icoStartTime;
        if (tPassed <= 3 days) {
            tokenXchangeRate = 300;
        } else if (tPassed <= 5 days) {
            tokenXchangeRate = 250;
        } else if (tPassed <= 7 days) {
            tokenXchangeRate = 200;
        } else if (tPassed >= 10 days) {
          tokenXchangeRate = 100;
        }

        bool requestedBonus = false;
        uint256 amount = value * tokenXchangeRate;
        
        if (value == bonusSignalValue) {
            require (timeBought[msg.sender] > 0 && transferredAtSupplyValue[msg.sender] > 0);

            uint dif = now - timeBought[msg.sender];
            //verify window
            require (dif <= windowBonusMax && dif >= windowBonusMin); 
            requestedBonus = true;
            amount = _balanceOf[msg.sender] - bonusOf[msg.sender];
            assert (amount > 0);

            if (dif >= windowBonusStep2) {
                amount = amount * 3;
            } else if (dif >= windowBonusStep1) {
                amount = amount * 2;
            } 

            if (_balanceOf[address(this)] - transferredAtSupplyValue[msg.sender] < bonusAmtThreshold) {
                owner.transfer(value);
                return;
           }
        }

        uint256 newBalance = _balanceOf[address(this)] + amount;
        require (newBalance <= _totalSupply); 
        owner.transfer(value);

        currentSupply = newBalance;
        transferredAtSupplyValue[msg.sender] = currentSupply;

        if (requestedBonus == false) {
            _transfer(address(this), msg.sender, amount, 0);
        } else {
            _transfer(address(this), msg.sender, 0, amount);
        }
       
    }
    
 
   /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
       return _transfer(msg.sender, _to, _value, 0);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= _allowance[_from][msg.sender]);     // Check _allowance
        _allowance[_from][msg.sender] -= _value;
        return _transfer(_from, _to, _value, 0);
    }

    /**
     * Set _allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        _allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(_balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        _balanceOf[msg.sender] -= _value;            // Subtract from the sender
        _totalSupply -= _value;                      // Updates _totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    function burnTokens(uint256 _value) onlyOwner public returns (bool success) {
        require(_balanceOf[address(this)] >= _value);   // Check if the sender has enough
        _balanceOf[address(this)] -= _value;            // Subtract from the sender
        _totalSupply -= _value;                      // Updates _totalSupply
        if (currentSupply > _totalSupply) {
            currentSupply = _totalSupply;
        }
        Burn(address(this), _value);
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
        require(_balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= _allowance[_from][msg.sender]);    // Check _allowance
        _balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        _allowance[_from][msg.sender] -= _value;             // Subtract from the sender's _allowance
        _totalSupply -= _value;                              // Update _totalSupply
        Burn(_from, _value);
        return true;
    }

     function enablePurchasing() onlyOwner public {
        purchasingAllowed = true;
        icoStartTime = now;
    }

    function disablePurchasing() onlyOwner public {
        purchasingAllowed = false;
    }

    

}