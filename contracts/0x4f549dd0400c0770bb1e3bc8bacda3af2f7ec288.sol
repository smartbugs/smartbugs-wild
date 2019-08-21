pragma solidity ^0.4.25;

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/AddressUtils.sol

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param _addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address _addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}

// File: contracts/VestingPrivateSale.sol

/**
 * Vesting smart contract for the private sale. Vesting period is 18 months in total.
 * All 6 months 33% percent of the vested tokens will be released - step function.
 */
contract VestingPrivateSale is Ownable {

    uint256 constant public sixMonth = 182 days;  
    uint256 constant public twelveMonth = 365 days;  
    uint256 constant public eighteenMonth = sixMonth + twelveMonth;

    ERC20Basic public erc20Contract;

    struct Locking {
        uint256 bucket1;
        uint256 bucket2;
        uint256 bucket3;
        uint256 startDate;
    }

    mapping(address => Locking) public lockingMap;

    event ReleaseVestingEvent(address indexed to, uint256 value);

    /**
     * @dev Constructor. With the reference to the ERC20 contract
     */
    constructor(address _erc20) public {
        require(AddressUtils.isContract(_erc20), "Address is not a smart contract");

        erc20Contract = ERC20Basic(_erc20);
    }

    /**
     * @dev Adds vested tokens to this contract. ERC20 contract has assigned the tokens. 
     * @param _tokenHolder The token holder.
     * @param _bucket1 The first bucket. Will be available after 6 months.
     * @param _bucket2 The second bucket. Will be available after 12 months.
     * @param _bucket3 The third bucket. Will be available after 18 months.
     * @return True if accepted.
     */
    function addVested(
        address _tokenHolder, 
        uint256 _bucket1, 
        uint256 _bucket2, 
        uint256 _bucket3
    ) 
        public 
        returns (bool) 
    {
        require(msg.sender == address(erc20Contract), "ERC20 contract required");
        require(lockingMap[_tokenHolder].startDate == 0, "Address is already vested");

        lockingMap[_tokenHolder].startDate = block.timestamp;
        lockingMap[_tokenHolder].bucket1 = _bucket1;
        lockingMap[_tokenHolder].bucket2 = _bucket2;
        lockingMap[_tokenHolder].bucket3 = _bucket3;

        return true;
    }

    /**
     * @dev Calculates the amount of the total assigned tokens of a tokenholder.
     * @param _tokenHolder The address to query the balance of.
     * @return The total amount of owned tokens (vested + available). 
     */
    function balanceOf(
        address _tokenHolder
    ) 
        public 
        view 
        returns (uint256) 
    {
        return lockingMap[_tokenHolder].bucket1 + lockingMap[_tokenHolder].bucket2 + lockingMap[_tokenHolder].bucket3;
    }

    /**
     * @dev Calculates the amount of currently available (unlocked) tokens. This amount can be unlocked. 
     * @param _tokenHolder The address to query the balance of.
     * @return The total amount of owned and available tokens.
     */
    function availableBalanceOf(
        address _tokenHolder
    ) 
        public 
        view 
        returns (uint256) 
    {
        uint256 startDate = lockingMap[_tokenHolder].startDate;
        uint256 tokens = 0;
        
        if (startDate + sixMonth <= block.timestamp) {
            tokens = lockingMap[_tokenHolder].bucket1;
        }

        if (startDate + twelveMonth <= block.timestamp) {
            tokens = tokens + lockingMap[_tokenHolder].bucket2;
        }

        if (startDate + eighteenMonth <= block.timestamp) {
            tokens = tokens + lockingMap[_tokenHolder].bucket3;
        }

        return tokens;
    }

    /**
     * @dev Releases unlocked tokens of the transaction sender. 
     * @dev This function will transfer unlocked tokens to the owner.
     * @return The total amount of released tokens.
     */
    function releaseBuckets() 
        public 
        returns (uint256) 
    {
        return _releaseBuckets(msg.sender);
    }

    /**
     * @dev Admin function.
     * @dev Releases unlocked tokens of the _tokenHolder. 
     * @dev This function will transfer unlocked tokens to the _tokenHolder.
     * @param _tokenHolder Address of the token owner to release tokens.
     * @return The total amount of released tokens.
     */
    function releaseBuckets(
        address _tokenHolder
    ) 
        public 
        onlyOwner
        returns (uint256) 
    {
        return _releaseBuckets(_tokenHolder);
    }

    function _releaseBuckets(
        address _tokenHolder
    ) 
        private 
        returns (uint256) 
    {
        require(lockingMap[_tokenHolder].startDate != 0, "Is not a locked address");
        uint256 startDate = lockingMap[_tokenHolder].startDate;
        uint256 tokens = 0;
        
        if (startDate + sixMonth <= block.timestamp) {
            tokens = lockingMap[_tokenHolder].bucket1;
            lockingMap[_tokenHolder].bucket1 = 0;
        }

        if (startDate + twelveMonth <= block.timestamp) {
            tokens = tokens + lockingMap[_tokenHolder].bucket2;
            lockingMap[_tokenHolder].bucket2 = 0;
        }

        if (startDate + eighteenMonth <= block.timestamp) {
            tokens = tokens + lockingMap[_tokenHolder].bucket3;
            lockingMap[_tokenHolder].bucket3 = 0;
        }
        
        require(erc20Contract.transfer(_tokenHolder, tokens), "Transfer failed");
        emit ReleaseVestingEvent(_tokenHolder, tokens);

        return tokens;
    }
}

// File: contracts/VestingTreasury.sol

/**
 * Treasury vesting smart contract. Vesting period is over 36 months.
 * Tokens are locked for 6 months. After that releasing the tokens over 30 months with a linear function.
 */
contract VestingTreasury {

    using SafeMath for uint256;

    uint256 constant public sixMonths = 182 days;  
    uint256 constant public thirtyMonths = 912 days;  

    ERC20Basic public erc20Contract;

    struct Locking {
        uint256 startDate;      // date when the release process of the vesting will start. 
        uint256 initialized;    // initialized amount of tokens
        uint256 released;       // already released tokens
    }

    mapping(address => Locking) public lockingMap;

    event ReleaseVestingEvent(address indexed to, uint256 value);

    /**
    * @dev Constructor. With the reference to the ERC20 contract
    */
    constructor(address _erc20) public {
        require(AddressUtils.isContract(_erc20), "Address is not a smart contract");

        erc20Contract = ERC20Basic(_erc20);
    }

    /**
     * @dev Adds vested tokens to this contract. ERC20 contract has assigned the tokens. 
     * @param _tokenHolder The token holder.
     * @param _value The amount of tokens to protect.
     * @return True if accepted.
     */
    function addVested(
        address _tokenHolder, 
        uint256 _value
    ) 
        public 
        returns (bool) 
    {
        require(msg.sender == address(erc20Contract), "ERC20 contract required");
        require(lockingMap[_tokenHolder].startDate == 0, "Address is already vested");

        lockingMap[_tokenHolder].startDate = block.timestamp + sixMonths;
        lockingMap[_tokenHolder].initialized = _value;
        lockingMap[_tokenHolder].released = 0;

        return true;
    }

    /**
     * @dev Calculates the amount of the total currently vested and available tokens.
     * @param _tokenHolder The address to query the balance of.
     * @return The total amount of owned tokens (vested + available). 
     */
    function balanceOf(
        address _tokenHolder
    ) 
        public 
        view 
        returns (uint256) 
    {
        return lockingMap[_tokenHolder].initialized.sub(lockingMap[_tokenHolder].released);
    }

    /**
     * @dev Calculates the amount of currently available (unlocked) tokens. This amount can be unlocked. 
     * @param _tokenHolder The address to query the balance of.
     * @return The total amount of owned and available tokens.
     */
    function availableBalanceOf(
        address _tokenHolder
    ) 
        public 
        view 
        returns (uint256) 
    {
        uint256 startDate = lockingMap[_tokenHolder].startDate;
        
        if (block.timestamp <= startDate) {
            return 0;
        }

        uint256 tmpAvailableTokens = 0;
        if (block.timestamp >= startDate + thirtyMonths) {
            tmpAvailableTokens = lockingMap[_tokenHolder].initialized;
        } else {
            uint256 timeDiff = block.timestamp - startDate;
            uint256 totalBalance = lockingMap[_tokenHolder].initialized;

            tmpAvailableTokens = totalBalance.mul(timeDiff).div(thirtyMonths);
        }

        uint256 availableTokens = tmpAvailableTokens.sub(lockingMap[_tokenHolder].released);
        require(availableTokens <= lockingMap[_tokenHolder].initialized, "Max value exceeded");

        return availableTokens;
    }

    /**
     * @dev Releases unlocked tokens of the transaction sender. 
     * @dev This function will transfer unlocked tokens to the owner.
     * @return The total amount of released tokens.
     */
    function releaseTokens() 
        public 
        returns (uint256) 
    {
        require(lockingMap[msg.sender].startDate != 0, "Sender is not a vested address");

        uint256 tokens = availableBalanceOf(msg.sender);

        lockingMap[msg.sender].released = lockingMap[msg.sender].released.add(tokens);
        require(lockingMap[msg.sender].released <= lockingMap[msg.sender].initialized, "Max value exceeded");

        require(erc20Contract.transfer(msg.sender, tokens), "Transfer failed");
        emit ReleaseVestingEvent(msg.sender, tokens);

        return tokens;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
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
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
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
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
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
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/CappedToken.sol

/**
 * @title Capped token
 * @dev Mintable token with a token cap.
 */
contract CappedToken is MintableToken {

  uint256 public cap;

  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    returns (bool)
  {
    require(totalSupply_.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}

// File: contracts/LockedToken.sol

contract LockedToken is CappedToken {
    bool public transferActivated = false;

    event TransferActivatedEvent();

    constructor(uint256 _cap) public CappedToken(_cap) {
    }

    /**
     * @dev Admin function.
     * @dev Activates the token transfer. This action cannot be undone. 
     * @dev This function should be called after the ICO. 
     * @return True if ok. 
     */
    function activateTransfer() 
        public 
        onlyOwner
        returns (bool) 
    {
        require(transferActivated == false, "Already activated");

        transferActivated = true;

        emit TransferActivatedEvent();
        return true;
    }

    /**
     * @dev Transfer token for a specified address.
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(
        address _to, 
        uint256 _value
    ) 
        public 
        returns (bool) 
    {
        require(transferActivated, "Transfer is not activated");
        require(_to != address(this), "Invalid _to address");

        return super.transfer(_to, _value);
    }

    /**
     * @dev Transfer tokens from one address to another.
     * @param _from The address which you want to send tokens from.
     * @param _to The address which you want to transfer to.
     * @param _value The amount of tokens to be transferred.
     */
    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
    ) 
        public 
        returns (bool) 
    {
        require(transferActivated, "TransferFrom is not activated");
        require(_to != address(this), "Invalid _to address");

        return super.transferFrom(_from, _to, _value);
    }
}

// File: contracts/AlprockzToken.sol

/**
 * @title The Alprockz ERC20 Token
 */
contract AlprockzToken is LockedToken {
    
    string public constant name = "AlpRockz";
    string public constant symbol = "APZ";
    uint8 public constant decimals = 18;
    VestingPrivateSale public vestingPrivateSale;
    VestingTreasury public vestingTreasury;

    constructor() public LockedToken(175 * 1000000 * (10 ** uint256(decimals))) {
    }

    /**
     * @dev Admin function.
     * @dev Inits the VestingPrivateSale functionality. 
     * @dev Precondition: VestingPrivateSale smart contract must be deployed!
     * @param _vestingContractAddr The address of the vesting contract for the function 'mintPrivateSale(...)'.
     * @return True if everything is ok.
     */
    function initMintVestingPrivateSale(
        address _vestingContractAddr
    ) 
        external
        onlyOwner
        returns (bool) 
    {
        require(address(vestingPrivateSale) == address(0x0), "Already initialized");
        require(address(this) != _vestingContractAddr, "Invalid address");
        require(AddressUtils.isContract(_vestingContractAddr), "Address is not a smart contract");
        
        vestingPrivateSale = VestingPrivateSale(_vestingContractAddr);
        require(address(this) == address(vestingPrivateSale.erc20Contract()), "Vesting link address not match");
        
        return true;
    }

    /**
     * @dev Admin function.
     * @dev Inits the VestingTreasury functionality. 
     * @dev Precondition: VestingTreasury smart contract must be deployed!
     * @param _vestingContractAddr The address of the vesting contract for the function 'mintTreasury(...)'.
     * @return True if everything is ok.
     */
    function initMintVestingTreasury(
        address _vestingContractAddr
    ) 
        external
        onlyOwner
        returns (bool) 
    {
        require(address(vestingTreasury) == address(0x0), "Already initialized");
        require(address(this) != _vestingContractAddr, "Invalid address");
        require(AddressUtils.isContract(_vestingContractAddr), "Address is not a smart contract");
        
        vestingTreasury = VestingTreasury(_vestingContractAddr);
        require(address(this) == address(vestingTreasury.erc20Contract()), "Vesting link address not match");
        
        return true;
    }

    /**
     * @dev Admin function.
     * @dev Bulk mint function to save gas. 
     * @dev both arrays requires to have the same length.
     * @param _recipients List of recipients.
     * @param _tokens List of tokens to assign to the recipients.
     */
    function mintArray(
        address[] _recipients, 
        uint256[] _tokens
    ) 
        external
        onlyOwner 
        returns (bool) 
    {
        require(_recipients.length == _tokens.length, "Array length not match");
        require(_recipients.length <= 40, "Too many recipients");

        for (uint256 i = 0; i < _recipients.length; i++) {
            require(super.mint(_recipients[i], _tokens[i]), "Mint failed");
        }

        return true;
    }

    /**
     * @dev Admin function.
     * @dev Bulk mintPrivateSale function to save gas. 
     * @dev both arrays are required to have the same length.
     * @dev Vesting: 25% directly available, 25% after 6, 25% after 12 and 25% after 18 months. 
     * @param _recipients List of recipients.
     * @param _tokens List of tokens to assign to the recipients.
     */
    function mintPrivateSale(
        address[] _recipients, 
        uint256[] _tokens
    ) 
        external 
        onlyOwner
        returns (bool) 
    {
        require(address(vestingPrivateSale) != address(0x0), "Init required");
        require(_recipients.length == _tokens.length, "Array length not match");
        require(_recipients.length <= 10, "Too many recipients");


        for (uint256 i = 0; i < _recipients.length; i++) {

            address recipient = _recipients[i];
            uint256 token = _tokens[i];

            uint256 first;
            uint256 second; 
            uint256 third; 
            uint256 fourth;
            (first, second, third, fourth) = splitToFour(token);

            require(super.mint(recipient, first), "Mint failed");

            uint256 totalVested = second + third + fourth;
            require(super.mint(address(vestingPrivateSale), totalVested), "Mint failed");
            require(vestingPrivateSale.addVested(recipient, second, third, fourth), "Vesting failed");
        }

        return true;
    }

    /**
     * @dev Admin function.
     * @dev Bulk mintTreasury function to save gas. 
     * @dev both arrays are required to have the same length.
     * @dev Vesting: Tokens are locked for 6 months. After that the tokens are released in a linear way.
     * @param _recipients List of recipients.
     * @param _tokens List of tokens to assign to the recipients.
     */
    function mintTreasury(
        address[] _recipients, 
        uint256[] _tokens
    ) 
        external 
        onlyOwner
        returns (bool) 
    {
        require(address(vestingTreasury) != address(0x0), "Init required");
        require(_recipients.length == _tokens.length, "Array length not match");
        require(_recipients.length <= 10, "Too many recipients");

        for (uint256 i = 0; i < _recipients.length; i++) {

            address recipient = _recipients[i];
            uint256 token = _tokens[i];

            require(super.mint(address(vestingTreasury), token), "Mint failed");
            require(vestingTreasury.addVested(recipient, token), "Vesting failed");
        }

        return true;
    }

    function splitToFour(
        uint256 _amount
    ) 
        private 
        pure 
        returns (
            uint256 first, 
            uint256 second, 
            uint256 third, 
            uint256 fourth
        ) 
    {
        require(_amount >= 4, "Minimum amount");

        uint256 rest = _amount % 4;

        uint256 quarter = (_amount - rest) / 4;

        first = quarter + rest;
        second = quarter;
        third = quarter;
        fourth = quarter;
    }
}