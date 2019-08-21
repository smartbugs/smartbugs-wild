pragma solidity ^0.4.25;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function balanceOf(address _owner) external view returns (uint256);
  function allowance(address _owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner=0xE2d9b8259F74a46b5E3f74A30c7867be0a5f5185;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
 constructor() internal {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
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
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /// @dev counter to allow mutex lock with only one SSTORE operation
  uint256 private _guardCounter;

  constructor() internal {
    // The counter starts at one to prevent changing it from zero to a non-zero
    // value, which is a more expensive operation.
    _guardCounter = 1;
  }

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * Calling a `nonReentrant` function from another `nonReentrant`
   * function is not supported. It is possible to prevent this from happening
   * by making the `nonReentrant` function external, and make it call a
   * `private` function that does the actual work.
   */
  modifier nonReentrant() {
    _guardCounter += 1;
    uint256 localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter);
  }

}
contract Haltable is Ownable  {
    
  bool public halted;
  
   modifier stopInEmergency {
    if (halted) revert();
    _;
  }

  modifier stopNonOwnersInEmergency {
    if (halted && msg.sender != owner) revert();
    _;
  }

  modifier onlyInEmergency {
    if (!halted) revert();
    _;
  }

  // called by the owner on emergency, triggers stopped state
  function halt() external onlyOwner {
    halted = true;
  }

  // called by the owner on end of emergency, returns to normal state
  function unhalt() external onlyOwner onlyInEmergency {
    halted = false;
  }

}
contract Ubricoin is IERC20,Ownable,ReentrancyGuard,Haltable{
  
  using SafeMath for uint256;

  // UBN Token parameters
  string public name = 'Ubricoin';
  string public symbol = 'UBN';
  string public version = '2.0';
  uint256 public constant RATE = 1000;  //1 ether = 1000 Ubricoins tokens
  
  // min tokens to be a holder, 0.1
  uint256 public constant MIN_HOLDER_TOKENS = 10 ** uint256(decimals - 1);
  
  // 18 decimals is the strongly suggested default, avoid changing it
  uint8   public constant decimals = 18;
  uint256 public constant decimalFactor = 10 ** uint256(decimals);
  uint256 public totalSupply_;           // amount of tokens already sold/supply                                 
  uint256 public constant TOTAL_SUPPLY = 10000000000 * decimalFactor; // The initialSupply or totalSupply of  100% Released at Token Distribution (TD)
  uint256 public constant SALES_SUPPLY =  1300000000 * decimalFactor; // 2.30% Released at Token Distribution (TD)
  
  // Funds supply constants // tokens to be Distributed at every stage 
  uint256 public AVAILABLE_FOUNDER_SUPPLY  =  1500000000 * decimalFactor; // 17.3% Released at TD 
  uint256 public AVAILABLE_AIRDROP_SUPPLY  =  2000000000 * decimalFactor; // 22.9% Released at TD/Eco System Allocated
  uint256 public AVAILABLE_OWNER_SUPPLY    =  2000000000 * decimalFactor; // 22.9% Released at TD 
  uint256 public AVAILABLE_TEAMS_SUPPLY    =  3000000000 * decimalFactor; // 34.5% Released at TD 
  uint256 public AVAILABLE_BONUS_SUPPLY    =   200000000 * decimalFactor; // 0.10% Released at TD 
  uint256 public claimedTokens = 0;
  
  // Funds supply addresses constants // tokens distribution
  address public constant AVAILABLE_FOUNDER_SUPPLY_ADDRESS = 0xAC762012330350DDd97Cc64B133536F8E32193a8; //AVAILABLE_FOUNDER_SUPPLY_ADDRESS 1
  address public constant AVAILABLE_AIRDROP_SUPPLY_ADDRESS = 0x28970854Bfa61C0d6fE56Cc9daAAe5271CEaEC09; //AVAILABLE_AIRDROP_SUPPLY_ADDRESS 2 Eco system Allocated
  address public constant AVAILABLE_OWNER_SUPPLY_ADDRESS = 0xE2d9b8259F74a46b5E3f74A30c7867be0a5f5185;   //AVAILABLE_OWNER_SUPPLY_ADDRESS   3
  address public constant AVAILABLE_BONUS_SUPPLY_ADDRESS = 0xDE59297Bf5D1D1b9d38D8F50e55A270eb9aE136e;   //AVAILABLE_BONUS1_SUPPLY_ADDRESS  4
  address public constant AVAILABLE_TEAMS_SUPPLY_ADDRESS = 0x9888375f4663891770DaaaF9286d97d44FeFC82E;   //AVAILABLE_RESERVE_TEAM_SUPPLY_ADDRESS 5

  // Token holders
  address[] public holders;
  

  // ICO address
  address public icoAddress;
  mapping (address => uint256) balances;  // This creates an array with all balances
  mapping (address => mapping (address => uint256)) internal allowed;
  
  // Keeps track of whether or not an Ubricoin airdrop has been made to a particular address
  mapping (address => bool) public airdrops;
  
  mapping (address => uint256) public holderNumber; // Holders number
  
  // This generates a public event on the blockchain that will notify clients
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event TransferredToken(address indexed to, uint256 value);
  event FailedTransfer(address indexed to, uint256 value);
  // This notifies clients about the amount burnt , only admin is able to burn the contract
  event Burn(address from, uint256 value); 
  event AirDropped ( address[] _recipient, uint256 _amount, uint256 claimedTokens);
  event AirDrop_many ( address[] _recipient, uint256[] _amount, uint256 claimedTokens);
  
 
    /**
     * @dev Constructor that gives a portion of all existing tokens to various addresses.
     * @dev Distribute founder, airdrop,owner, reserve_team and bonus_supply tokens
     * @dev and Ico address for the remaining tokens
     */
  constructor () public  { 
      
        // Allocate tokens to the available_founder_supply_address fund 1
        balances[AVAILABLE_FOUNDER_SUPPLY_ADDRESS] = AVAILABLE_FOUNDER_SUPPLY;
        holders.push(AVAILABLE_FOUNDER_SUPPLY_ADDRESS);
        emit Transfer(0x0, AVAILABLE_FOUNDER_SUPPLY_ADDRESS, AVAILABLE_FOUNDER_SUPPLY);

        // Allocate tokens to the available_airdrop_supply_address fund 2 eco system allocated
        balances[AVAILABLE_AIRDROP_SUPPLY_ADDRESS] = AVAILABLE_AIRDROP_SUPPLY;
        holders.push(AVAILABLE_AIRDROP_SUPPLY_ADDRESS);
        emit Transfer(0x0, AVAILABLE_AIRDROP_SUPPLY_ADDRESS, AVAILABLE_AIRDROP_SUPPLY);

        // Allocate tokens to the available_owner_supply_address fund 3
        balances[AVAILABLE_OWNER_SUPPLY_ADDRESS] = AVAILABLE_OWNER_SUPPLY;
        holders.push(AVAILABLE_OWNER_SUPPLY_ADDRESS);
        emit Transfer(0x0, AVAILABLE_OWNER_SUPPLY_ADDRESS, AVAILABLE_OWNER_SUPPLY);

        // Allocate tokens to the available_reserve_team_supply_address fund 4
        balances[AVAILABLE_TEAMS_SUPPLY_ADDRESS] = AVAILABLE_TEAMS_SUPPLY;
        holders.push(AVAILABLE_TEAMS_SUPPLY_ADDRESS);
        emit Transfer(0x0, AVAILABLE_TEAMS_SUPPLY_ADDRESS, AVAILABLE_TEAMS_SUPPLY);
        
        // Allocate tokens to the available_reserve_team_supply_address fund 5
        balances[AVAILABLE_BONUS_SUPPLY_ADDRESS] = AVAILABLE_BONUS_SUPPLY;
        holders.push(AVAILABLE_BONUS_SUPPLY_ADDRESS);
        emit Transfer(0x0, AVAILABLE_BONUS_SUPPLY_ADDRESS, AVAILABLE_BONUS_SUPPLY);

        totalSupply_ = TOTAL_SUPPLY.sub(SALES_SUPPLY);
        
    }
    
   /**
     * @dev Function fallback/payable to buy tokens from contract by sending ether.
     * @notice Buy tokens from contract by sending ether
     * @dev This are the tokens allocated for sale's supply
     */
  function () payable nonReentrant external  {
      
    require(msg.data.length == 0);
    require(msg.value > 0);
    
      uint256 tokens = msg.value.mul(RATE); // calculates the aamount
      balances[msg.sender] = balances[msg.sender].add(tokens);
      totalSupply_ = totalSupply_.add(tokens);
      owner.transfer(msg.value);  //make transfer
      
    }

    /**
     * @dev set ICO address and allocate sale supply to it
     *      Tokens left for payment using ethers
     */
  function setICO(address _icoAddress) public onlyOwner {
      
    require(_icoAddress != address(0));
    require(icoAddress  == address(0));
    require(totalSupply_ == TOTAL_SUPPLY.sub(SALES_SUPPLY));
      
       // Allocate tokens to the ico contract
       balances[_icoAddress] = SALES_SUPPLY;
       emit Transfer(0x0, _icoAddress, SALES_SUPPLY);

       icoAddress = _icoAddress;
       totalSupply_ = TOTAL_SUPPLY;
       
    }

    /**
     * @dev total number of tokens in existence
     */
  function totalSupply() public view returns (uint256) {
      
      return totalSupply_;
      
    }
    
    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
  function balanceOf(address _owner) public view returns (uint256 balance) {
      
      return balances[_owner];
      
    }
  

   /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
  function allowance(address _owner, address _spender) public view returns (uint256 remaining ) {
      
      return allowed[_owner][_spender];
      
    }
    
    /**
     * Internal transfer, only can be called by this contract
     */
  function _transfer(address _from, address _to, uint256 _value) internal {
      
    require(_to != 0x0);                 // Prevent transfer to 0x0 address. Use burn() instead
    require(balances[_from] >= _value);  // Check if the sender has enough
    require(balances[_to] + _value >= balances[_to]);             // Check for overflows
     
      uint256 previousBalances = balances[_from] + balances[_to];   // Save this for an assertion in the future
      balances[_from] -= _value;   // Subtract from the sender
      balances[_to] += _value;     // Add the same to the recipient
      emit Transfer(_from, _to, _value);
      
      // Asserts are used to use static analysis to find bugs in your code. They should never fail
      assert(balances[_from] + balances[_to] == previousBalances);  
      
    }
    
   
    /**
     * Standard transfer function 
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
  function transfer(address _to, uint256 _value) public returns (bool success) {
      
       require(balances[msg.sender] > 0);                     
       require(balances[msg.sender] >= _value);  // Check if the sender has enough  
       require(_to != address(0x0));             // Prevent transfer to 0x0 address. Use burn() instead
       
       require(_value > 0);	
       require(_to != msg.sender);               // Check if sender and receiver is not same
       require(_value <= balances[msg.sender]);

       // SafeMath.sub will throw if there is not enough balance.
       balances[msg.sender] = balances[msg.sender].sub(_value); // Subtract value from sender
       balances[_to] = balances[_to].add(_value);               // Add the value to the receiver
       emit Transfer(msg.sender, _to, _value);                  // Notify all clients about the transfer events
       return true;
       
    }
    
    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
      
    require(_to != address(0x0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);  // Check allowance

      balances[_from] = balances[_from].sub(_value);
      balances[_to] = balances[_to].add(_value);
      allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
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
     * @param _value The amount of tokens to be spent.
    */
  function approve(address _spender, uint256 _value) public returns (bool success) {
      
      allowed[msg.sender][_spender] = _value;
      emit  Approval(msg.sender, _spender, _value);
      return true;
      
    }
    
  // get holders count
  function getHoldersCount() public view returns (uint256) {
      
        return holders.length;
    }
    
  // preserve holders list
  function preserveHolders(address _from, address _to, uint256 _value) internal {
      
        if (balances[_from].sub(_value) < MIN_HOLDER_TOKENS) 
            removeHolder(_from);
        if (balances[_to].add(_value) >= MIN_HOLDER_TOKENS) 
            addHolder(_to);   
    }

  // remove holder from the holders list
  function removeHolder(address _holder) internal {
      
        uint256 _number = holderNumber[_holder];

        if (_number == 0 || holders.length == 0 || _number > holders.length)
            return;

        uint256 _index = _number.sub(1);
        uint256 _lastIndex = holders.length.sub(1);
        address _lastHolder = holders[_lastIndex];

        if (_index != _lastIndex) {
            holders[_index] = _lastHolder;
            holderNumber[_lastHolder] = _number;
        }

        holderNumber[_holder] = 0;
        holders.length = _lastIndex;
    } 

  // add holder to the holders list
  function addHolder(address _holder) internal {
      
        if (holderNumber[_holder] == 0) {
            holders.push(_holder);
            holderNumber[_holder] = holders.length;
            
        }
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
 function _burn(address account, uint256 value) external onlyOwner {
     
      require(balances[msg.sender] >= value);   // Check if the sender has enough
      balances[msg.sender] -= value;            // Subtract from the sender
      totalSupply_ -= value;                    // Updates totalSupply
      emit Burn(msg.sender, value);
      //return true;
      
      require(account != address(0x0));

      totalSupply_ = totalSupply_.sub(value);
      balances[account] = balances[account].sub(value);
      emit Transfer(account, address(0X0), value);
     
    }
    
    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
  function _burnFrom(address account, uint256 value) external onlyOwner {
      
      require(balances[account] >= value);               // Check if the targeted balance is enough
      require(value <= allowed[account][msg.sender]);    // Check allowance
      balances[account] -= value;                        // Subtract from the targeted balance
      allowed[account][msg.sender] -= value;             // Subtract from the sender's allowance
      totalSupply_ -= value;                             // Update totalSupply
      emit Burn(account, value);
      // return true; 
      
      allowed[account][msg.sender] = allowed[account][msg.sender].sub(value);
      emit Burn(account, value);
      emit Approval(account, msg.sender, allowed[account][msg.sender]);
      
    }
    
  function validPurchase() internal returns (bool) {
      
      bool lessThanMaxInvestment = msg.value <= 1000 ether; // change the value to whatever you need
      return validPurchase() && lessThanMaxInvestment;
      
    }
    
    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param target The account that will receive the created tokens.
     * @param mintedAmount The amount that will be created.
     * @dev  perform a minting/create new UBN's for new allocations
     * @param  target is the address to mint tokens to
     * 
     */
  function mintToken(address target, uint256 mintedAmount) public onlyOwner {
      
      balances[target] += mintedAmount;
      totalSupply_ += mintedAmount;
      
      emit Transfer(0, owner, mintedAmount);
      emit Transfer(owner, target, mintedAmount);
      
    }
    
    /**
    * @dev perform a transfer of allocations
    * @param _recipient is a list of recipients
    * 
    * Below function can be used when you want to send every recipeint with different number of tokens
    * 
    */
  function airDrop_many(address[] _recipient, uint256[] _amount) public onlyOwner {
        
        require(msg.sender == owner);
        require(_recipient.length == _amount.length);
        uint256 amount = _amount[i] * uint256(decimalFactor);
        uint256 airdropped;
    
        for (uint i=0; i < _recipient.length; i++) {
           if (!airdrops[_recipient[i]]) {
                airdrops[_recipient[i]] = true;
                require(Ubricoin.transfer(_recipient[i], _amount[i] * decimalFactor));
                //Ubricoin.transfer(_recipient[i], _amount[i]);
                airdropped = airdropped.add(amount );
            } else{
                
                 emit FailedTransfer(_recipient[i], airdropped); 
        }
        
    AVAILABLE_AIRDROP_SUPPLY = AVAILABLE_AIRDROP_SUPPLY.sub(airdropped);
    //totalSupply_ = totalSupply_.sub(airdropped);
    claimedTokens = claimedTokens.add(airdropped);
    emit AirDrop_many(_recipient, _amount, claimedTokens);
    
        }
    }
    
   /**
    * @dev perform a transfer of allocations
    * @param _recipient is a list of recipients
    * 
    * this function can be used when you want to send same number of tokens to all the recipients
    * 
    */
  function airDrop(address[] _recipient, uint256 _amount) public onlyOwner {
      
        require(_amount > 0);
        uint256 airdropped;
        uint256 amount = _amount * uint256(decimalFactor);
        for (uint256 index = 0; index < _recipient.length; index++) {
            if (!airdrops[_recipient[index]]) {
                airdrops[_recipient[index]] = true;
                require(Ubricoin.transfer(_recipient[index], amount * decimalFactor ));
                airdropped = airdropped.add(amount );
            }else{
            
            emit FailedTransfer(_recipient[index], airdropped); 
        }
    }
        
    AVAILABLE_AIRDROP_SUPPLY = AVAILABLE_AIRDROP_SUPPLY.sub(airdropped);
    //totalSupply_ = totalSupply_.sub(airdropped);
    claimedTokens = claimedTokens.add(airdropped);
    emit AirDropped(_recipient, _amount, claimedTokens);
    
    }
    

}