pragma solidity 0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
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


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

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
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
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

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
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
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

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
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
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
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

contract Token is StandardToken, BurnableToken, Ownable {

    /**
    * @dev Use SafeMath library for all uint256 variables
    */
    using SafeMath for uint256;

    /**
    * @dev ERC20 variables
    */
    string public name = "MIMIC";
    string public symbol = "MIMIC";
    uint256 public decimals = 18;

    /**
    * @dev Total token supply
    */
    uint256 public INITIAL_SUPPLY = 900000000 * (10 ** decimals);

    /** 
    * @dev Addresses where the tokens will be stored initially
    */
    address public constant ICO_ADDRESS        = 0x93Fc953BefEF145A92760476d56E45842CE00b2F;
    address public constant PRESALE_ADDRESS    = 0x3be448B6dD35976b58A9935A1bf165d5593F8F27;

    /**
    * @dev Address that can receive the tokens before the end of the ICO
    */
    address public constant BACKUP_ONE     = 0x9146EE4eb69f92b1e59BE9C7b4718d6B75F696bE;
    address public constant BACKUP_TWO     = 0xe12F95964305a00550E1970c3189D6aF7DB9cFdd;
    address public constant BACKUP_FOUR    = 0x2FBF54a91535A5497c2aF3BF5F64398C4A9177a2;
    address public constant BACKUP_THREE   = 0xa41554b1c2d13F10504Cc2D56bF0Ba9f845C78AC;

    /** 
    * @dev Team members has temporally locked token.
    *      Variables used to define how the tokens will be unlocked.
    */
    uint256 public lockStartDate = 0;
    uint256 public lockEndDate = 0;
    uint256 public lockAbsoluteDifference = 0;
    mapping (address => uint256) public initialLockedAmounts;

    /**
    * @dev Defines if tokens arre free to move or not 
    */
    bool public areTokensFree = false;

    /** 
    * @dev Emitted when the token locked amount of an address is set
    */
    event SetLockedAmount(address indexed owner, uint256 amount);

    /** 
    * @dev Emitted when the token locked amount of an address is updated
    */
    event UpdateLockedAmount(address indexed owner, uint256 amount);

    /**
    * @dev Emitted when it will be time to free the unlocked tokens
    */
    event FreeTokens();

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[owner] = totalSupply_;
    }

    /** 
    * @dev Check whenever an address has the power to transfer tokens before the end of the ICO
    * @param _sender Address of the transaction sender
    * @param _to Destination address of the transaction
    */
    modifier canTransferBeforeEndOfIco(address _sender, address _to) {
        require(
            areTokensFree ||
            _sender == owner ||
            _sender == ICO_ADDRESS ||
            _sender == PRESALE_ADDRESS ||
            (
                _to == BACKUP_ONE ||
                _to == BACKUP_TWO ||
                _to == BACKUP_THREE || 
                _to == BACKUP_FOUR
            )
            , "Cannot transfer tokens yet"
        );

        _;
    }

    /** 
    * @dev Check whenever an address can transfer an certain amount of token in the case all or some part
    *      of them are locked
    * @param _sender Address of the transaction sender
    * @param _amount The amount of tokens the address is trying to transfer
    */
    modifier canTransferIfLocked(address _sender, uint256 _amount) {
        uint256 afterTransfer = balances[_sender].sub(_amount);
        require(afterTransfer >= getLockedAmount(_sender), "Not enought unlocked tokens");
        
        _;
    }

    /** 
    * @dev Returns the amount of tokens an address has locked
    * @param _addr The address in question
    */
    function getLockedAmount(address _addr) public view returns (uint256){
        if (now >= lockEndDate || initialLockedAmounts[_addr] == 0x0)
            return 0;

        if (now < lockStartDate) 
            return initialLockedAmounts[_addr];

        uint256 alpha = uint256(now).sub(lockStartDate); // absolute purchase date
        uint256 tokens = initialLockedAmounts[_addr].sub(alpha.mul(initialLockedAmounts[_addr]).div(lockAbsoluteDifference)); // T - (α * T) / β

        return tokens;
    }

    /** 
    * @dev Sets the amount of locked tokens for a specific address. It doesn't transfer tokens!
    * @param _addr The address in question
    * @param _amount The amount of tokens to lock
    */
    function setLockedAmount(address _addr, uint256 _amount) public onlyOwner {
        require(_addr != address(0x0), "Cannot set locked amount to null address");

        initialLockedAmounts[_addr] = _amount;

        emit SetLockedAmount(_addr, _amount);
    }

    /** 
    * @dev Updates (adds to) the amount of locked tokens for a specific address. It doesn't transfer tokens!
    * @param _addr The address in question
    * @param _amount The amount of locked tokens to add
    */
    function updateLockedAmount(address _addr, uint256 _amount) public onlyOwner {
        require(_addr != address(0x0), "Cannot update locked amount to null address");
        require(_amount > 0, "Cannot add 0");

        initialLockedAmounts[_addr] = initialLockedAmounts[_addr].add(_amount);

        emit UpdateLockedAmount(_addr, _amount);
    }

    /**
    * @dev Frees all the unlocked tokens
    */
    function freeTokens() public onlyOwner {
        require(!areTokensFree, "Tokens have already been freed");

        areTokensFree = true;

        lockStartDate = now;
        // lockEndDate = lockStartDate + 365 days;
        lockEndDate = lockStartDate + 1 days;
        lockAbsoluteDifference = lockEndDate.sub(lockStartDate);

        emit FreeTokens();
    }

    /**
    * @dev Override of ERC20's transfer function with modifiers
    * @param _to The address to which tranfer the tokens
    * @param _value The amount of tokens to transfer
    */
    function transfer(address _to, uint256 _value)
        public
        canTransferBeforeEndOfIco(msg.sender, _to) 
        canTransferIfLocked(msg.sender, _value) 
        returns (bool)
    {
        return super.transfer(_to, _value);
    }

    /**
    * @dev Override of ERC20's transfer function with modifiers
    * @param _from The address from which tranfer the tokens
    * @param _to The address to which tranfer the tokens
    * @param _value The amount of tokens to transfer
    */
    function transferFrom(address _from, address _to, uint _value) 
        public
        canTransferBeforeEndOfIco(_from, _to) 
        canTransferIfLocked(_from, _value) 
        returns (bool) 
    {
        return super.transferFrom(_from, _to, _value);
    }

}

contract Presale is Ownable {

    /**
    * @dev Use SafeMath library for all uint256 variables
    */
    using SafeMath for uint256;

    /**
    * @dev Our previously deployed Token (ERC20) contract
    */
    Token public token;

    /**
    * @dev How many tokens a buyer takes per wei
    */
    uint256 public rate;

    /**
    * @dev The address where all the funds will be stored
    */
    address public wallet;

    /**
    * @dev The address where all the tokens are stored
    */
    address public holder;

    /**
    * @dev The amount of wei raised during the ICO
    */
    uint256 public weiRaised;

    /**
    * @dev The amount of tokens purchased by the buyers
    */
    uint256 public tokenPurchased;

    /**
    * @dev Crowdsale start date
    */
    uint256 public constant startDate = 1535994000; // 2018-09-03 17:00:00 (UTC)

    /**
    * @dev Crowdsale end date
    */
    uint256 public constant endDate = 1541264400; // 2018-10-01 10:00:00 (UTC)

    /**
    * @dev The minimum amount of ethereum that we accept as a contribution
    */
    uint256 public minimumAmount = 40 ether;

    /**
    * @dev The maximum amount of ethereum that an address can contribute
    */
    uint256 public maximumAmount = 200 ether;

    /**
    * @dev Mapping tracking how much an address has contribuited
    */
    mapping (address => uint256) public contributionAmounts;

    /**
    * @dev Mapping containing which addresses are whitelisted
    */
    mapping (address => bool) public whitelist;

    /**
    * @dev Emitted when an amount of tokens is beign purchased
    */
    event Purchase(address indexed sender, address indexed beneficiary, uint256 value, uint256 amount);

    /**
    * @dev Emitted when we change the conversion rate 
    */
    event ChangeRate(uint256 rate);

    /**
    * @dev Emitted when we change the minimum contribution amount
    */
    event ChangeMinimumAmount(uint256 amount);

    /**
    * @dev Emitted when we change the maximum contribution amount
    */
    event ChangeMaximumAmount(uint256 amount);

    /**
    * @dev Emitted when the whitelisted state of and address is changed
    */
    event Whitelist(address indexed beneficiary, bool indexed whitelisted);

    /**
    * @dev Contract constructor
    * @param _tokenAddress The address of the previously deployed Token contract
    */
    constructor(address _tokenAddress, uint256 _rate, address _wallet, address _holder) public {
        require(_tokenAddress != address(0), "Token Address cannot be a null address");
        require(_rate > 0, "Conversion rate must be a positive integer");
        require(_wallet != address(0), "Wallet Address cannot be a null address");
        require(_holder != address(0), "Holder Address cannot be a null address");

        token = Token(_tokenAddress);
        rate = _rate;
        wallet = _wallet;
        holder = _holder;
    }

    /**
    * @dev Modifier used to verify if an address can purchase
    */
    modifier canPurchase(address _beneficiary) {
        require(now >= startDate, "Presale has not started yet");
        require(now <= endDate, "Presale has finished");

        require(whitelist[_beneficiary] == true, "Your address is not whitelisted");

        uint256 amount = uint256(contributionAmounts[_beneficiary]).add(msg.value);

        require(msg.value >= minimumAmount, "Cannot contribute less than the minimum amount");
        require(amount <= maximumAmount, "Cannot contribute more than the maximum amount");
        
        _;
    }

    /**
    * @dev Fallback function, called when someone tryes to pay send ether to the contract address
    */
    function () external payable {
        purchase(msg.sender);
    }

    /**
    * @dev General purchase function, used by the fallback function and from buyers who are buying for other addresses
    * @param _beneficiary The Address that will receive the tokens
    */
    function purchase(address _beneficiary) internal canPurchase(_beneficiary) {
        uint256 weiAmount = msg.value;

        // Validate beneficiary and wei amount
        require(_beneficiary != address(0), "Beneficiary Address cannot be a null address");
        require(weiAmount > 0, "Wei amount must be a positive integer");

        // Calculate token amount
        uint256 tokenAmount = _getTokenAmount(weiAmount);

        // Update totals
        weiRaised = weiRaised.add(weiAmount);
        tokenPurchased = tokenPurchased.add(tokenAmount);
        contributionAmounts[_beneficiary] = contributionAmounts[_beneficiary].add(weiAmount);

        _transferEther(weiAmount);

        // Make the actual purchase and send the tokens to the contributor
        _purchaseTokens(_beneficiary, tokenAmount);

        // Emit purchase event
        emit Purchase(msg.sender, _beneficiary, weiAmount, tokenAmount);
    }

    /**
    * @dev Updates the conversion rate to a new value
    * @param _rate The new conversion rate
    */
    function updateConversionRate(uint256 _rate) public onlyOwner {
        require(_rate > 0, "Conversion rate must be a positive integer");

        rate = _rate;

        emit ChangeRate(_rate);
    }

    /**
    * @dev Updates the minimum contribution amount to a new value
    * @param _amount The new minimum contribution amount expressed in wei
    */
    function updateMinimumAmount(uint256 _amount) public onlyOwner {
        require(_amount > 0, "Minimum amount must be a positive integer");

        minimumAmount = _amount;

        emit ChangeMinimumAmount(_amount);
    }

    /**
    * @dev Updates the maximum contribution amount to a new value
    * @param _amount The new maximum contribution amount expressed in wei
    */
    function updateMaximumAmount(uint256 _amount) public onlyOwner {
        require(_amount > 0, "Maximum amount must be a positive integer");

        maximumAmount = _amount;

        emit ChangeMaximumAmount(_amount);
    }

    /**
    * @dev Updates the whitelisted status of an address
    * @param _addr The address in question
    * @param _whitelist The new whitelist status
    */
    function setWhitelist(address _addr, bool _whitelist) public onlyOwner {
        require(_addr != address(0x0), "Whitelisted address must be valid");

        whitelist[_addr] = _whitelist;

        emit Whitelist(_addr, _whitelist);
    }

    /**
    * @dev Processes the actual purchase (token transfer)
    * @param _beneficiary The Address that will receive the tokens
    * @param _amount The amount of tokens to transfer
    */
    function _purchaseTokens(address _beneficiary, uint256 _amount) internal {
        token.transferFrom(holder, _beneficiary, _amount);
    }

    /**
    * @dev Transfers the ethers recreived from the contributor to the Presale wallet
    * @param _amount The amount of ethers to transfer
    */
    function _transferEther(uint256 _amount) internal {
        // this should throw an exeption if it fails
        wallet.transfer(_amount);
    }

    /**
    * @dev Returns an amount of wei converted in tokens
    * @param _wei Value in wei to be converted
    * @return Amount of tokens 
    */
    function _getTokenAmount(uint256 _wei) internal view returns (uint256) {
        // wei * ((rate * (30 + 100)) / 100)
        return _wei.mul(rate.mul(130).div(100));
    }

}