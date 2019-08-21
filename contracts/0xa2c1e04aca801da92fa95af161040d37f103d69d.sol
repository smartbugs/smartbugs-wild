pragma solidity 0.4.24;

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\ERC20Basic.sol

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

// File: node_modules\openzeppelin-solidity\contracts\math\SafeMath.sol

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

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\BasicToken.sol

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

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\ERC20.sol

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

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\StandardToken.sol

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

// File: node_modules\openzeppelin-solidity\contracts\ownership\Ownable.sol

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

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\MintableToken.sol

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

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\CappedToken.sol

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

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\BurnableToken.sol

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

// File: node_modules\openzeppelin-solidity\contracts\token\ERC20\DetailedERC20.sol

/**
 * @title DetailedERC20 token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}

// File: node_modules\openzeppelin-solidity\contracts\lifecycle\Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

// File: contracts\CoyToken.sol

/**
 * @title COYToken
 * @dev CoinAnalyst's ERC20 Token.
 * Besides the standard ERC20 functionality, the token allows minting, batch minting, 
 * burning, and assigning. Furthermore, it is a pausable capped token.
 * When paused, transfers are impossible.
 *
 * This contract is heavily based on the Open Zeppelin classes:
 * - CappedToken
 * - BurnableToken
 * - Pausable
 * - SafeMath
 */
contract CoyToken is CappedToken, BurnableToken, DetailedERC20, Pausable {
    using SafeMath for uint256;
    using SafeMath for uint8;
    
    string private constant COY_NAME = "CoinAnalyst";
    string private constant COY_SYMBOL = "COY";
    uint8 private constant COY_DECIMALS = 18;
    
    /** 
     * Define cap internally to later use for capped token.
     * Using same number of decimal figures as ETH (i.e. 18).
     * Maximum number of tokens in circulation: 3.75 billion.
     */
    uint256 private constant TOKEN_UNIT = 10 ** uint256(COY_DECIMALS);
    uint256 private constant COY_CAP = (3.75 * 10 ** 9) * TOKEN_UNIT;
    
    // Token roles
    address public minter;
    address public assigner;
    address public burner;

    /**
     * @dev Constructor that initializes the COYToken contract.
     * @param _minter The minter account.
     * @param _assigner The assigner account.
     * @param _burner The burner account.
     */
    constructor(address _minter, address _assigner, address _burner) 
        CappedToken(COY_CAP) 
        DetailedERC20(COY_NAME, COY_SYMBOL, COY_DECIMALS)
        public
    {
        require(_minter != address(0), "Minter must be a valid non-null address");
        require(_assigner != address(0), "Assigner must be a valid non-null address");
        require(_burner != address(0), "Burner must be a valid non-null address");

        minter = _minter;
        assigner = _assigner;
        burner = _burner;
    }

    event MinterTransferred(address indexed _minter, address indexed _newMinter);
    event AssignerTransferred(address indexed _assigner, address indexed _newAssigner);
    event BurnerTransferred(address indexed _burner, address indexed _newBurner);
    event BatchMint(uint256 _totalMintedTokens, uint256 _batchMintId);
    event Assign(address indexed _to, uint256 _amount);
    event BatchAssign(uint256 _totalAssignedTokens, uint256 _batchAssignId);
    event BatchTransfer(uint256 _totalTransferredTokens, uint256 _batchTransferId);
    
    /** 
     * @dev Throws if called by any account other than the minter.
     *      Override from MintableToken
     */
    modifier hasMintPermission() {
        require(msg.sender == minter, "Only the minter can do this.");
        _;
    }
    
    /** 
     * @dev Throws if called by any account other than the assigner.
     */
    modifier hasAssignPermission() {
        require(msg.sender == assigner, "Only the assigner can do this.");
        _;
    }
    
    /**
     *  @dev Throws if called by any account other than the burner.
     */
    modifier hasBurnPermission() {
        require(msg.sender == burner, "Only the burner can do this.");
        _;
    }
    
    /**
     *  @dev Throws if minting period is still ongoing.
     */
    modifier whenMintingFinished() {
        require(mintingFinished, "Minting has to be finished.");
        _;
    }


    /**
     *  @dev Allows the current owner to change the minter.
     *  @param _newMinter The address of the new minter.
     *  @return True if the operation was successful.
     */
    function setMinter(address _newMinter) external 
        canMint
        onlyOwner 
        returns(bool) 
    {
        require(_newMinter != address(0), "New minter must be a valid non-null address");
        require(_newMinter != minter, "New minter has to differ from previous minter");

        emit MinterTransferred(minter, _newMinter);
        minter = _newMinter;
        return true;
    }
    
    /**
     *  @dev Allows the current owner to change the assigner.
     *  @param _newAssigner The address of the new assigner.
     *  @return True if the operation was successful.
     */
    function setAssigner(address _newAssigner) external 
        onlyOwner 
        canMint
        returns(bool) 
    {
        require(_newAssigner != address(0), "New assigner must be a valid non-null address");
        require(_newAssigner != assigner, "New assigner has to differ from previous assigner");

        emit AssignerTransferred(assigner, _newAssigner);
        assigner = _newAssigner;
        return true;
    }
    
    /**
     *  @dev Allows the current owner to change the burner.
     *  @param _newBurner The address of the new burner.
     *  @return True if the operation was successful.
     */
    function setBurner(address _newBurner) external 
        onlyOwner 
        returns(bool) 
    {
        require(_newBurner != address(0), "New burner must be a valid non-null address");
        require(_newBurner != burner, "New burner has to differ from previous burner");

        emit BurnerTransferred(burner, _newBurner);
        burner = _newBurner;
        return true;
    }
    
    /**
     * @dev Function to batch mint tokens.
     * @param _to An array of addresses that will receive the minted tokens.
     * @param _amounts An array with the amounts of tokens each address will get minted.
     * @param _batchMintId Identifier for the batch in order to synchronize with internal (off-chain) processes.
     * @return A boolean that indicates whether the operation was successful.
     */
    function batchMint(address[] _to, uint256[] _amounts, uint256 _batchMintId) external
        canMint
        hasMintPermission
        returns (bool) 
    {
        require(_to.length == _amounts.length, "Input arrays must have the same length");
        
        uint256 totalMintedTokens = 0;
        for (uint i = 0; i < _to.length; i++) {
            mint(_to[i], _amounts[i]);
            totalMintedTokens = totalMintedTokens.add(_amounts[i]);
        }
        
        emit BatchMint(totalMintedTokens, _batchMintId);
        return true;
    }
    
    /**
     * @dev Function to assign any number of tokens to a given address.
     *      Compared to the `mint` function, the `assign` function allows not just to increase but also to decrease
     *      the number of tokens of an address by assigning a lower value than the address current balance.
     *      This function can only be executed during initial token sale.
     * @param _to The address that will receive the assigned tokens.
     * @param _amount The amount of tokens to assign.
     * @return True if the operation was successful.
     */
    function assign(address _to, uint256 _amount) public 
        canMint
        hasAssignPermission 
        returns(bool) 
    {
        // The desired value to assign (`_amount`) can be either higher or lower than the current number of tokens
        // of the address (`balances[_to]`). To calculate the new `totalSupply_` value, the difference between `_amount`
        // and `balances[_to]` (`delta`) is calculated first, and then added or substracted to `totalSupply_` accordingly.
        uint256 delta = 0;
        if (balances[_to] < _amount) {
            // balances[_to] will be increased, so totalSupply_ should be increased
            delta = _amount.sub(balances[_to]);
            totalSupply_ = totalSupply_.add(delta);
            require(totalSupply_ <= cap, "Total supply cannot be higher than cap");
            emit Transfer(address(0), _to, delta); // conformity to mint and burn functions for easier balance retrieval via event logs
        } else {
            // balances[_to] will be decreased, so totalSupply_ should be decreased
            delta = balances[_to].sub(_amount);
            totalSupply_ = totalSupply_.sub(delta);
            emit Transfer(_to, address(0), delta); // conformity to mint and burn functions for easier balance retrieval via event logs
        }
        
        require(delta > 0, "Delta should not be zero");

        balances[_to] = _amount;
        emit Assign(_to, _amount);
        return true;
    }
    
    /**
     * @dev Function to assign a list of numbers of tokens to a given list of addresses.
     * @param _to The addresses that will receive the assigned tokens.
     * @param _amounts The amounts of tokens to assign.
     * @param _batchAssignId Identifier for the batch in order to synchronize with internal (off-chain) processes.
     * @return True if the operation was successful.
     */
    function batchAssign(address[] _to, uint256[] _amounts, uint256 _batchAssignId) external
        canMint
        hasAssignPermission
        returns (bool) 
    {
        require(_to.length == _amounts.length, "Input arrays must have the same length");
        
        uint256 totalAssignedTokens = 0;
        for (uint i = 0; i < _to.length; i++) {
            assign(_to[i], _amounts[i]);
            totalAssignedTokens = totalAssignedTokens.add(_amounts[i]);
        }
        
        emit BatchAssign(totalAssignedTokens, _batchAssignId);
        return true;
    }
    
    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public
        hasBurnPermission
    {
        super.burn(_value);
    }

    /**
     * @dev transfer token for a specified address when minting is finished.
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public
        whenMintingFinished
        whenNotPaused
        returns (bool) 
    {
        return super.transfer(_to, _value);
    }

    /**
     * @dev Transfer tokens from one address to another when minting is finished.
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public
        whenMintingFinished
        whenNotPaused
        returns (bool) 
    {
        return super.transferFrom(_from, _to, _value);
    }
    
    /**
     * @dev Transfer tokens from one address to several others when minting is finished.
     * @param _to addresses The addresses which you want to transfer to
     * @param _amounts uint256 the amounts of tokens to be transferred
     * @param _batchTransferId Identifier for the batch in order to synchronize with internal (off-chain) processes.
     */
    function transferInBatches(address[] _to, uint256[] _amounts, uint256 _batchTransferId) public
        whenMintingFinished
        whenNotPaused
        returns (bool) 
    {
        require(_to.length == _amounts.length, "Input arrays must have the same length");
        
        uint256 totalTransferredTokens = 0;
        for (uint i = 0; i < _to.length; i++) {
            transfer(_to[i], _amounts[i]);
            totalTransferredTokens = totalTransferredTokens.add(_amounts[i]);
        }
        
        emit BatchTransfer(totalTransferredTokens, _batchTransferId);
        return true;
    }
}