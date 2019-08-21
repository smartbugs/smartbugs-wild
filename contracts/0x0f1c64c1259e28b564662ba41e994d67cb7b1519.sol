pragma solidity ^0.4.25; // solium-disable-line linebreak-style

/**
 * @author Anatolii Kucheruk (anatolii@platin.io)
 * @author Platin Limited, platin.io (platin@platin.io)
 */

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

/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param _token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic _token) external onlyOwner {
    uint256 balance = _token.balanceOf(this);
    _token.safeTransfer(owner, balance);
  }

}

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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <remco@2π.com>
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up
 * in the contract, it will allow the owner to reclaim this Ether.
 * @notice Ether can still be sent to this contract by:
 * calling functions labeled `payable`
 * `selfdestruct(contract_address)`
 * mining directly to the contract address
 */
contract HasNoEther is Ownable {

  /**
  * @dev Constructor that rejects incoming Ether
  * The `payable` flag is added so we can access `msg.value` without compiler warning. If we
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
  * we could use assembly to access msg.value.
  */
  constructor() public payable {
    require(msg.value == 0);
  }

  /**
   * @dev Disallows direct send by setting a default function without the `payable` flag.
   */
  function() external {
  }

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
    owner.transfer(address(this).balance);
  }
}

/**
 * @title Contracts that should not own Tokens
 * @author Remco Bloemen <remco@2π.com>
 * @dev This blocks incoming ERC223 tokens to prevent accidental loss of tokens.
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the
 * owner to reclaim the tokens.
 */
contract HasNoTokens is CanReclaimToken {

 /**
  * @dev Reject all ERC223 compatible tokens
  * @param _from address The address that is transferring the tokens
  * @param _value uint256 the amount of the specified token
  * @param _data Bytes The data passed from the caller.
  */
  function tokenFallback(
    address _from,
    uint256 _value,
    bytes _data
  )
    external
    pure
  {
    _from;
    _value;
    _data;
    revert();
  }

}

/**
 * @title Contracts that should not own Contracts
 * @author Remco Bloemen <remco@2π.com>
 * @dev Should contracts (anything Ownable) end up being owned by this contract, it allows the owner
 * of this contract to reclaim ownership of the contracts.
 */
contract HasNoContracts is Ownable {

  /**
   * @dev Reclaim ownership of Ownable contracts
   * @param _contractAddr The address of the Ownable to be reclaimed.
   */
  function reclaimContract(address _contractAddr) external onlyOwner {
    Ownable contractInst = Ownable(_contractAddr);
    contractInst.transferOwnership(owner);
  }
}

/**
 * @title Base contract for contracts that should not own things.
 * @author Remco Bloemen <remco@2π.com>
 * @dev Solves a class of errors where a contract accidentally becomes owner of Ether, Tokens or
 * Owned contracts. See respective base contracts for details.
 */
contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {
}

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

/**
 * @title Authorizable
 * @dev Authorizable contract holds a list of control addresses that authorized to do smth.
 */
contract Authorizable is Ownable {

    // List of authorized (control) addresses
    mapping (address => bool) public authorized;

    // Authorize event logging
    event Authorize(address indexed who);

    // UnAuthorize event logging
    event UnAuthorize(address indexed who);

    // onlyAuthorized modifier, restrict to the owner and the list of authorized addresses
    modifier onlyAuthorized() {
        require(msg.sender == owner || authorized[msg.sender], "Not Authorized.");
        _;
    }

    /**
     * @dev Authorize given address
     * @param _who address Address to authorize 
     */
    function authorize(address _who) public onlyOwner {
        require(_who != address(0), "Address can't be zero.");
        require(!authorized[_who], "Already authorized");

        authorized[_who] = true;
        emit Authorize(_who);
    }

    /**
     * @dev unAuthorize given address
     * @param _who address Address to unauthorize 
     */
    function unAuthorize(address _who) public onlyOwner {
        require(_who != address(0), "Address can't be zero.");
        require(authorized[_who], "Address is not authorized");

        authorized[_who] = false;
        emit UnAuthorize(_who);
    }
}

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

/**
 * @title Holders Token
 * @dev Extension to the OpenZepellin's StandardToken contract to track token holders.
 * Only holders with the non-zero balance are listed.
 */
contract HoldersToken is StandardToken {
    using SafeMath for uint256;    

    // holders list
    address[] public holders;

    // holder number in the list
    mapping (address => uint256) public holderNumber;

    /**
     * @dev Get the holders count
     * @return uint256 Holders count
     */
    function holdersCount() public view returns (uint256) {
        return holders.length;
    }

    /**
     * @dev Transfer tokens from one address to another preserving token holders
     * @param _to address The address which you want to transfer to
     * @param _value uint256 The amount of tokens to be transferred
     * @return bool Returns true if the transfer was succeeded
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        _preserveHolders(msg.sender, _to, _value);
        return super.transfer(_to, _value);
    }

    /**
     * @dev Transfer tokens from one address to another preserving token holders
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 The amount of tokens to be transferred
     * @return bool Returns true if the transfer was succeeded
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        _preserveHolders(_from, _to, _value);
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Remove holder from the holders list
     * @param _holder address Address of the holder to remove
     */
    function _removeHolder(address _holder) internal {
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

    /**
     * @dev Add holder to the holders list
     * @param _holder address Address of the holder to add   
     */
    function _addHolder(address _holder) internal {
        if (holderNumber[_holder] == 0) {
            holders.push(_holder);
            holderNumber[_holder] = holders.length;
        }
    }

    /**
     * @dev Preserve holders during transfers
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function _preserveHolders(address _from, address _to, uint256 _value) internal {
        _addHolder(_to);   
        if (balanceOf(_from).sub(_value) == 0) 
            _removeHolder(_from);
    }
}

/**
 * @title PlatinTGE
 * @dev Platin Token Generation Event contract. It holds token economic constants and makes initial token allocation.
 * Initial token allocation function should be called outside the blockchain at the TGE moment of time, 
 * from here on out, Platin Token and other Platin contracts become functional.
 */
contract PlatinTGE {
    using SafeMath for uint256;
    
    // Token decimals
    uint8 public constant decimals = 18; // solium-disable-line uppercase

    // Total Tokens Supply
    uint256 public constant TOTAL_SUPPLY = 1000000000 * (10 ** uint256(decimals)); // 1,000,000,000 PTNX

    // SUPPLY
    // TOTAL_SUPPLY = 1,000,000,000 PTNX, is distributed as follows:
    uint256 public constant SALES_SUPPLY = 300000000 * (10 ** uint256(decimals)); // 300,000,000 PTNX - 30%
    uint256 public constant MINING_POOL_SUPPLY = 200000000 * (10 ** uint256(decimals)); // 200,000,000 PTNX - 20%
    uint256 public constant FOUNDERS_AND_EMPLOYEES_SUPPLY = 200000000 * (10 ** uint256(decimals)); // 200,000,000 PTNX - 20%
    uint256 public constant AIRDROPS_POOL_SUPPLY = 100000000 * (10 ** uint256(decimals)); // 100,000,000 PTNX - 10%
    uint256 public constant RESERVES_POOL_SUPPLY = 100000000 * (10 ** uint256(decimals)); // 100,000,000 PTNX - 10%
    uint256 public constant ADVISORS_POOL_SUPPLY = 70000000 * (10 ** uint256(decimals)); // 70,000,000 PTNX - 7%
    uint256 public constant ECOSYSTEM_POOL_SUPPLY = 30000000 * (10 ** uint256(decimals)); // 30,000,000 PTNX - 3%

    // HOLDERS
    address public PRE_ICO_POOL; // solium-disable-line mixedcase
    address public LIQUID_POOL; // solium-disable-line mixedcase
    address public ICO; // solium-disable-line mixedcase
    address public MINING_POOL; // solium-disable-line mixedcase 
    address public FOUNDERS_POOL; // solium-disable-line mixedcase
    address public EMPLOYEES_POOL; // solium-disable-line mixedcase 
    address public AIRDROPS_POOL; // solium-disable-line mixedcase 
    address public RESERVES_POOL; // solium-disable-line mixedcase 
    address public ADVISORS_POOL; // solium-disable-line mixedcase
    address public ECOSYSTEM_POOL; // solium-disable-line mixedcase 

    // HOLDER AMOUNT AS PART OF SUPPLY
    // SALES_SUPPLY = PRE_ICO_POOL_AMOUNT + LIQUID_POOL_AMOUNT + ICO_AMOUNT
    uint256 public constant PRE_ICO_POOL_AMOUNT = 20000000 * (10 ** uint256(decimals)); // 20,000,000 PTNX
    uint256 public constant LIQUID_POOL_AMOUNT = 100000000 * (10 ** uint256(decimals)); // 100,000,000 PTNX
    uint256 public constant ICO_AMOUNT = 180000000 * (10 ** uint256(decimals)); // 180,000,000 PTNX
    // FOUNDERS_AND_EMPLOYEES_SUPPLY = FOUNDERS_POOL_AMOUNT + EMPLOYEES_POOL_AMOUNT
    uint256 public constant FOUNDERS_POOL_AMOUNT = 190000000 * (10 ** uint256(decimals)); // 190,000,000 PTNX
    uint256 public constant EMPLOYEES_POOL_AMOUNT = 10000000 * (10 ** uint256(decimals)); // 10,000,000 PTNX

    // Unsold tokens reserve address
    address public UNSOLD_RESERVE; // solium-disable-line mixedcase

    // Tokens ico sale with lockup period
    uint256 public constant ICO_LOCKUP_PERIOD = 182 days;
    
    // Platin Token ICO rate, regular
    uint256 public constant TOKEN_RATE = 1000; 

    // Platin Token ICO rate with lockup, 20% bonus
    uint256 public constant TOKEN_RATE_LOCKUP = 1200;

    // Platin ICO min purchase amount
    uint256 public constant MIN_PURCHASE_AMOUNT = 1 ether;

    // Platin Token contract
    PlatinToken public token;

    // TGE time
    uint256 public tgeTime;


    /**
     * @dev Constructor
     * @param _tgeTime uint256 TGE moment of time
     * @param _token address Address of the Platin Token contract       
     * @param _preIcoPool address Address of the Platin PreICO Pool
     * @param _liquidPool address Address of the Platin Liquid Pool
     * @param _ico address Address of the Platin ICO contract
     * @param _miningPool address Address of the Platin Mining Pool
     * @param _foundersPool address Address of the Platin Founders Pool
     * @param _employeesPool address Address of the Platin Employees Pool
     * @param _airdropsPool address Address of the Platin Airdrops Pool
     * @param _reservesPool address Address of the Platin Reserves Pool
     * @param _advisorsPool address Address of the Platin Advisors Pool
     * @param _ecosystemPool address Address of the Platin Ecosystem Pool  
     * @param _unsoldReserve address Address of the Platin Unsold Reserve                                 
     */  
    constructor(
        uint256 _tgeTime,
        PlatinToken _token, 
        address _preIcoPool,
        address _liquidPool,
        address _ico,
        address _miningPool,
        address _foundersPool,
        address _employeesPool,
        address _airdropsPool,
        address _reservesPool,
        address _advisorsPool,
        address _ecosystemPool,
        address _unsoldReserve
    ) public {
        require(_tgeTime >= block.timestamp, "TGE time should be >= current time."); // solium-disable-line security/no-block-members
        require(_token != address(0), "Token address can't be zero.");
        require(_preIcoPool != address(0), "PreICO Pool address can't be zero.");
        require(_liquidPool != address(0), "Liquid Pool address can't be zero.");
        require(_ico != address(0), "ICO address can't be zero.");
        require(_miningPool != address(0), "Mining Pool address can't be zero.");
        require(_foundersPool != address(0), "Founders Pool address can't be zero.");
        require(_employeesPool != address(0), "Employees Pool address can't be zero.");
        require(_airdropsPool != address(0), "Airdrops Pool address can't be zero.");
        require(_reservesPool != address(0), "Reserves Pool address can't be zero.");
        require(_advisorsPool != address(0), "Advisors Pool address can't be zero.");
        require(_ecosystemPool != address(0), "Ecosystem Pool address can't be zero.");
        require(_unsoldReserve != address(0), "Unsold reserve address can't be zero.");

        // Setup tge time
        tgeTime = _tgeTime;

        // Setup token address
        token = _token;

        // Setup holder addresses
        PRE_ICO_POOL = _preIcoPool;
        LIQUID_POOL = _liquidPool;
        ICO = _ico;
        MINING_POOL = _miningPool;
        FOUNDERS_POOL = _foundersPool;
        EMPLOYEES_POOL = _employeesPool;
        AIRDROPS_POOL = _airdropsPool;
        RESERVES_POOL = _reservesPool;
        ADVISORS_POOL = _advisorsPool;
        ECOSYSTEM_POOL = _ecosystemPool;

        // Setup unsold reserve address
        UNSOLD_RESERVE = _unsoldReserve; 
    }

    /**
     * @dev Allocate function. Token Generation Event entry point.
     * It makes initial token allocation according to the initial token supply constants.
     */
    function allocate() public {

        // Should be called just after tge time
        require(block.timestamp >= tgeTime, "Should be called just after tge time."); // solium-disable-line security/no-block-members

        // Should not be allocated already
        require(token.totalSupply() == 0, "Allocation is already done.");

        // SALES          
        token.allocate(PRE_ICO_POOL, PRE_ICO_POOL_AMOUNT);
        token.allocate(LIQUID_POOL, LIQUID_POOL_AMOUNT);
        token.allocate(ICO, ICO_AMOUNT);
      
        // MINING POOL
        token.allocate(MINING_POOL, MINING_POOL_SUPPLY);

        // FOUNDERS AND EMPLOYEES
        token.allocate(FOUNDERS_POOL, FOUNDERS_POOL_AMOUNT);
        token.allocate(EMPLOYEES_POOL, EMPLOYEES_POOL_AMOUNT);

        // AIRDROPS POOL
        token.allocate(AIRDROPS_POOL, AIRDROPS_POOL_SUPPLY);

        // RESERVES POOL
        token.allocate(RESERVES_POOL, RESERVES_POOL_SUPPLY);

        // ADVISORS POOL
        token.allocate(ADVISORS_POOL, ADVISORS_POOL_SUPPLY);

        // ECOSYSTEM POOL
        token.allocate(ECOSYSTEM_POOL, ECOSYSTEM_POOL_SUPPLY);

        // Check Token Total Supply
        require(token.totalSupply() == TOTAL_SUPPLY, "Total supply check error.");   
    }
}

/**
 * @title PlatinToken
 * @dev Platin PTNX Token contract. Tokens are allocated during TGE.
 * Token contract is a standard ERC20 token with additional capabilities: TGE allocation, holders tracking and lockup.
 * Initial allocation should be invoked by the TGE contract at the TGE moment of time.
 * Token contract holds list of token holders, the list includes holders with positive balance only.
 * Authorized holders can transfer token with lockup(s). Lockups can be refundable. 
 * Lockups is a list of releases dates and releases amounts.
 * In case of refund previous holder can get back locked up tokens. Only still locked up amounts can be transferred back.
 */
contract PlatinToken is HoldersToken, NoOwner, Authorizable, Pausable {
    using SafeMath for uint256;

    string public constant name = "Platin Token"; // solium-disable-line uppercase
    string public constant symbol = "PTNX"; // solium-disable-line uppercase
    uint8 public constant decimals = 18; // solium-disable-line uppercase
 
    // lockup sruct
    struct Lockup {
        uint256 release; // release timestamp
        uint256 amount; // amount of tokens to release
    }

    // list of lockups
    mapping (address => Lockup[]) public lockups;

    // list of lockups that can be refunded
    mapping (address => mapping (address => Lockup[])) public refundable;

    // idexes mapping from refundable to lockups lists 
    mapping (address => mapping (address => mapping (uint256 => uint256))) public indexes;    

    // Platin TGE contract
    PlatinTGE public tge;

    // allocation event logging
    event Allocate(address indexed to, uint256 amount);

    // lockup event logging
    event SetLockups(address indexed to, uint256 amount, uint256 fromIdx, uint256 toIdx);

    // refund event logging
    event Refund(address indexed from, address indexed to, uint256 amount);

    // spotTransfer modifier, check balance spot on transfer
    modifier spotTransfer(address _from, uint256 _value) {
        require(_value <= balanceSpot(_from), "Attempt to transfer more than balance spot.");
        _;
    }

    // onlyTGE modifier, restrict to the TGE contract only
    modifier onlyTGE() {
        require(msg.sender == address(tge), "Only TGE method.");
        _;
    }

    /**
     * @dev Set TGE contract
     * @param _tge address PlatinTGE contract address    
     */
    function setTGE(PlatinTGE _tge) external onlyOwner {
        require(tge == address(0), "TGE is already set.");
        require(_tge != address(0), "TGE address can't be zero.");
        tge = _tge;
        authorize(_tge);
    }        

    /**
     * @dev Allocate tokens during TGE
     * @param _to address Address gets the tokens
     * @param _amount uint256 Amount to allocate
     */ 
    function allocate(address _to, uint256 _amount) external onlyTGE {
        require(_to != address(0), "Allocate To address can't be zero");
        require(_amount > 0, "Allocate amount should be > 0.");
       
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        _addHolder(_to);

        require(totalSupply_ <= tge.TOTAL_SUPPLY(), "Can't allocate more than TOTAL SUPPLY.");

        emit Allocate(_to, _amount);
        emit Transfer(address(0), _to, _amount);
    }  

    /**
     * @dev Transfer tokens from one address to another
     * @param _to address The address which you want to transfer to
     * @param _value uint256 The amount of tokens to be transferred
     * @return bool Returns true if the transfer was succeeded
     */
    function transfer(address _to, uint256 _value) public whenNotPaused spotTransfer(msg.sender, _value) returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 The amount of tokens to be transferred
     * @return bool Returns true if the transfer was succeeded
     */
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused spotTransfer(_from, _value) returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Transfer tokens from one address to another with lockup
     * @param _to address The address which you want to transfer to
     * @param _value uint256 The amount of tokens to be transferred
     * @param _lockupReleases uint256[] List of lockup releases
     * @param _lockupAmounts uint256[] List of lockup amounts
     * @param _refundable bool Is locked up amount refundable
     * @return bool Returns true if the transfer was succeeded     
     */
    function transferWithLockup(
        address _to, 
        uint256 _value, 
        uint256[] _lockupReleases,
        uint256[] _lockupAmounts,
        bool _refundable
    ) 
    public onlyAuthorized returns (bool)
    {        
        transfer(_to, _value);
        _lockup(_to, _value, _lockupReleases, _lockupAmounts, _refundable); // solium-disable-line arg-overflow     
    }       

    /**
     * @dev Transfer tokens from one address to another with lockup
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 The amount of tokens to be transferred
     * @param _lockupReleases uint256[] List of lockup releases
     * @param _lockupAmounts uint256[] List of lockup amounts
     * @param _refundable bool Is locked up amount refundable      
     * @return bool Returns true if the transfer was succeeded     
     */
    function transferFromWithLockup(
        address _from, 
        address _to, 
        uint256 _value, 
        uint256[] _lockupReleases,
        uint256[] _lockupAmounts,
        bool _refundable
    ) 
    public onlyAuthorized returns (bool)
    {
        transferFrom(_from, _to, _value);
        _lockup(_to, _value, _lockupReleases, _lockupAmounts, _refundable); // solium-disable-line arg-overflow  
    }     

    /**
     * @dev Refund refundable locked up amount
     * @param _from address The address which you want to refund tokens from
     * @return uint256 Returns amount of refunded tokens   
     */
    function refundLockedUp(
        address _from
    )
    public onlyAuthorized returns (uint256)
    {
        address _sender = msg.sender;
        uint256 _balanceRefundable = 0;
        uint256 _refundableLength = refundable[_from][_sender].length;
        if (_refundableLength > 0) {
            uint256 _lockupIdx;
            for (uint256 i = 0; i < _refundableLength; i++) {
                if (refundable[_from][_sender][i].release > block.timestamp) { // solium-disable-line security/no-block-members
                    _balanceRefundable = _balanceRefundable.add(refundable[_from][_sender][i].amount);
                    refundable[_from][_sender][i].release = 0;
                    refundable[_from][_sender][i].amount = 0;
                    _lockupIdx = indexes[_from][_sender][i];
                    lockups[_from][_lockupIdx].release = 0;
                    lockups[_from][_lockupIdx].amount = 0;       
                }    
            }

            if (_balanceRefundable > 0) {
                _preserveHolders(_from, _sender, _balanceRefundable);
                balances[_from] = balances[_from].sub(_balanceRefundable);
                balances[_sender] = balances[_sender].add(_balanceRefundable);
                emit Refund(_from, _sender, _balanceRefundable);
                emit Transfer(_from, _sender, _balanceRefundable);
            }
        }
        return _balanceRefundable;
    }

    /**
     * @dev Get the lockups list count
     * @param _who address Address owns locked up list
     * @return uint256 Lockups list count
     */
    function lockupsCount(address _who) public view returns (uint256) {
        return lockups[_who].length;
    }

    /**
     * @dev Find out if the address has lockups
     * @param _who address Address checked for lockups
     * @return bool Returns true if address has lockups
     */
    function hasLockups(address _who) public view returns (bool) {
        return lockups[_who].length > 0;
    }

    /**
     * @dev Get balance locked up at the current moment of time
     * @param _who address Address owns locked up amounts
     * @return uint256 Balance locked up at the current moment of time
     */
    function balanceLockedUp(address _who) public view returns (uint256) {
        uint256 _balanceLokedUp = 0;
        uint256 _lockupsLength = lockups[_who].length;
        for (uint256 i = 0; i < _lockupsLength; i++) {
            if (lockups[_who][i].release > block.timestamp) // solium-disable-line security/no-block-members
                _balanceLokedUp = _balanceLokedUp.add(lockups[_who][i].amount);
        }
        return _balanceLokedUp;
    }

    /**
     * @dev Get refundable locked up balance at the current moment of time
     * @param _who address Address owns locked up amounts
     * @param _sender address Address owned locked up amounts
     * @return uint256 Locked up refundable balance at the current moment of time
     */
    function balanceRefundable(address _who, address _sender) public view returns (uint256) {
        uint256 _balanceRefundable = 0;
        uint256 _refundableLength = refundable[_who][_sender].length;
        if (_refundableLength > 0) {
            for (uint256 i = 0; i < _refundableLength; i++) {
                if (refundable[_who][_sender][i].release > block.timestamp) // solium-disable-line security/no-block-members
                    _balanceRefundable = _balanceRefundable.add(refundable[_who][_sender][i].amount);
            }
        }
        return _balanceRefundable;
    }

    /**
     * @dev Get balance spot for the current moment of time
     * @param _who address Address owns balance spot
     * @return uint256 Balance spot for the current moment of time
     */
    function balanceSpot(address _who) public view returns (uint256) {
        uint256 _balanceSpot = balanceOf(_who);
        _balanceSpot = _balanceSpot.sub(balanceLockedUp(_who));
        return _balanceSpot;
    }

    /**
     * @dev Lockup amount till release time
     * @param _who address Address gets the locked up amount
     * @param _amount uint256 Amount to lockup
     * @param _lockupReleases uint256[] List of lockup releases
     * @param _lockupAmounts uint256[] List of lockup amounts
     * @param _refundable bool Is locked up amount refundable     
     */     
    function _lockup(
        address _who, 
        uint256 _amount, 
        uint256[] _lockupReleases,
        uint256[] _lockupAmounts,
        bool _refundable) 
    internal 
    {
        require(_lockupReleases.length == _lockupAmounts.length, "Length of lockup releases and amounts lists should be equal.");
        require(_lockupReleases.length.add(lockups[_who].length) <= 1000, "Can't be more than 1000 lockups per address.");
        if (_lockupReleases.length > 0) {
            uint256 _balanceLokedUp = 0;
            address _sender = msg.sender;
            uint256 _fromIdx = lockups[_who].length;
            uint256 _toIdx = _fromIdx + _lockupReleases.length - 1;
            uint256 _lockupIdx;
            uint256 _refundIdx;
            for (uint256 i = 0; i < _lockupReleases.length; i++) {
                if (_lockupReleases[i] > block.timestamp) { // solium-disable-line security/no-block-members
                    lockups[_who].push(Lockup(_lockupReleases[i], _lockupAmounts[i]));
                    _balanceLokedUp = _balanceLokedUp.add(_lockupAmounts[i]);
                    if (_refundable) {
                        refundable[_who][_sender].push(Lockup(_lockupReleases[i], _lockupAmounts[i]));
                        _lockupIdx = lockups[_who].length - 1;
                        _refundIdx = refundable[_who][_sender].length - 1;
                        indexes[_who][_sender][_refundIdx] = _lockupIdx;
                    }
                }
            }

            require(_balanceLokedUp <= _amount, "Can't lockup more than transferred amount.");
            emit SetLockups(_who, _amount, _fromIdx, _toIdx); // solium-disable-line arg-overflow
        }            
    }      
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate
 * behavior.
 */
contract Crowdsale {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei.
  // The rate is the conversion between wei and the smallest and indivisible token unit.
  // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK
  // 1 wei will give you 1 unit, or 0.001 TOK.
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  constructor(uint256 _rate, address _wallet, ERC20 _token) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
   * Example from CappedCrowdsale.sol's _preValidatePurchase method: 
   *   super._preValidatePurchase(_beneficiary, _weiAmount);
   *   require(weiRaised.add(_weiAmount) <= cap);
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.safeTransfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param _openingTime Crowdsale opening time
   * @param _closingTime Crowdsale closing time
   */
  constructor(uint256 _openingTime, uint256 _closingTime) public {
    // solium-disable-next-line security/no-block-members
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > closingTime;
  }

  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    onlyWhileOpen
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Ownable, TimedCrowdsale {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() public onlyOwner {
    require(!isFinalized);
    require(hasClosed());

    finalization();
    emit Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }

}

/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 * See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage _role, address _addr)
    internal
  {
    _role.bearer[_addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage _role, address _addr)
    internal
    view
  {
    require(has(_role, _addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage _role, address _addr)
    internal
    view
    returns (bool)
  {
    return _role.bearer[_addr];
  }
}

/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 * Supports unlimited numbers of roles and addresses.
 * See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 * for you to write your own implementation of this interface using Enums or similar.
 */
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);

  /**
   * @dev reverts if addr does not have role
   * @param _operator address
   * @param _role the name of the role
   * // reverts
   */
  function checkRole(address _operator, string _role)
    public
    view
  {
    roles[_role].check(_operator);
  }

  /**
   * @dev determine if addr has role
   * @param _operator address
   * @param _role the name of the role
   * @return bool
   */
  function hasRole(address _operator, string _role)
    public
    view
    returns (bool)
  {
    return roles[_role].has(_operator);
  }

  /**
   * @dev add a role to an address
   * @param _operator address
   * @param _role the name of the role
   */
  function addRole(address _operator, string _role)
    internal
  {
    roles[_role].add(_operator);
    emit RoleAdded(_operator, _role);
  }

  /**
   * @dev remove a role from an address
   * @param _operator address
   * @param _role the name of the role
   */
  function removeRole(address _operator, string _role)
    internal
  {
    roles[_role].remove(_operator);
    emit RoleRemoved(_operator, _role);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param _role the name of the role
   * // reverts
   */
  modifier onlyRole(string _role)
  {
    checkRole(msg.sender, _role);
    _;
  }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param _roles the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] _roles) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < _roles.length; i++) {
  //         if (hasRole(msg.sender, _roles[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
}

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable, RBAC {
  string public constant ROLE_WHITELISTED = "whitelist";

  /**
   * @dev Throws if operator is not whitelisted.
   * @param _operator address
   */
  modifier onlyIfWhitelisted(address _operator) {
    checkRole(_operator, ROLE_WHITELISTED);
    _;
  }

  /**
   * @dev add an address to the whitelist
   * @param _operator address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
  function addAddressToWhitelist(address _operator)
    public
    onlyOwner
  {
    addRole(_operator, ROLE_WHITELISTED);
  }

  /**
   * @dev getter to determine if address is in whitelist
   */
  function whitelist(address _operator)
    public
    view
    returns (bool)
  {
    return hasRole(_operator, ROLE_WHITELISTED);
  }

  /**
   * @dev add addresses to the whitelist
   * @param _operators addresses
   * @return true if at least one address was added to the whitelist,
   * false if all addresses were already in the whitelist
   */
  function addAddressesToWhitelist(address[] _operators)
    public
    onlyOwner
  {
    for (uint256 i = 0; i < _operators.length; i++) {
      addAddressToWhitelist(_operators[i]);
    }
  }

  /**
   * @dev remove an address from the whitelist
   * @param _operator address
   * @return true if the address was removed from the whitelist,
   * false if the address wasn't in the whitelist in the first place
   */
  function removeAddressFromWhitelist(address _operator)
    public
    onlyOwner
  {
    removeRole(_operator, ROLE_WHITELISTED);
  }

  /**
   * @dev remove addresses from the whitelist
   * @param _operators addresses
   * @return true if at least one address was removed from the whitelist,
   * false if all addresses weren't in the whitelist in the first place
   */
  function removeAddressesFromWhitelist(address[] _operators)
    public
    onlyOwner
  {
    for (uint256 i = 0; i < _operators.length; i++) {
      removeAddressFromWhitelist(_operators[i]);
    }
  }

}

/**
 * @title WhitelistedCrowdsale
 * @dev Crowdsale in which only whitelisted users can contribute.
 */
contract WhitelistedCrowdsale is Whitelist, Crowdsale {
  /**
   * @dev Extend parent behavior requiring beneficiary to be in whitelist.
   * @param _beneficiary Token beneficiary
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    onlyIfWhitelisted(_beneficiary)
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

/**
 * @title PlatinICO
 * @dev Platin public sales contract. Before purchase customers should be whitelisted
 * during KYC/AML procedure. Tokens can be purchased with and without lockup.
 * Locked up tokens purchase has special token rate. Locked up tokens purchase can be performed
 * not more than 1000 times due to the limitation of lockups per one address.
 * When ICO ends, unsold tokens are distributed to the unsold token reserve.
 * All constants for processing purchases and for finalization are stored in the TGE contract.
 */
contract PlatinICO is FinalizableCrowdsale, WhitelistedCrowdsale, Pausable {
    using SafeMath for uint256;

    // Lockup purchase
    bool lockup;

    // Amount of sold tokens 
    uint256 public sold;

    // Platin TGE contract
    PlatinTGE public tge;

    /**
     * @dev Constructor
     * @param _rate uint256 Number of token units a buyer gets per wei
     * @param _wallet address Address where collected funds will be forwarded to
     * @param _token address Address of the token being sold  
     * @param _openingTime uint256 Crowdsale opening time
     * @param _closingTime uint256 Crowdsale closing time        
     */  
    constructor(
        uint256 _rate, 
        address _wallet, 
        ERC20 _token, 
        uint256 _openingTime, 
        uint256 _closingTime
    )
    Crowdsale(_rate, _wallet, _token) 
    TimedCrowdsale(_openingTime, _closingTime)
    public 
    {}

    /**
     * @dev Set TGE contract
     * @param _tge address PlatinTGE contract address    
     */
    function setTGE(PlatinTGE _tge) external onlyOwner {
        require(tge == address(0), "TGE is already set.");
        require(_tge != address(0), "TGE address can't be zero.");
        tge = _tge;
        rate = tge.TOKEN_RATE();
    }

    /**
     * @dev Purchase and lockup purchased tokens
     */
    function buyLockupTokens(address _beneficiary) external payable {
        lockup = true;
        if (_beneficiary == address(0x0))
            buyTokens(msg.sender);
        else
            buyTokens(_beneficiary);
    }

    /**
     * @dev Extend parent behavior to deliver purchase
     * @param _beneficiary address Address performing the token purchase
     * @param _tokenAmount uint256 Number of tokens to be emitted
     */
    function _deliverTokens(
        address _beneficiary,
        uint256 _tokenAmount
    )
        internal
    {
        if (lockup) {
            uint256[] memory _lockupReleases = new uint256[](1);
            uint256[] memory _lockupAmounts = new uint256[](1);
            _lockupReleases[0] = block.timestamp + tge.ICO_LOCKUP_PERIOD(); // solium-disable-line security/no-block-members
            _lockupAmounts[0] = _tokenAmount;
            PlatinToken(token).transferWithLockup(
                _beneficiary, 
                _tokenAmount,
                _lockupReleases,
                _lockupAmounts,
                false);
            lockup = false;   
        } else {
            PlatinToken(token).transfer(
                _beneficiary, 
                _tokenAmount);
        }
    }

    /**
     * @dev Extend parent behavior to process purchase
     * @param _beneficiary address Address receiving the tokens
     * @param _tokenAmount uint256 Number of tokens to be purchased
     */
    function _processPurchase(
        address _beneficiary,
        uint256 _tokenAmount
    )
        internal
    {
        require(sold.add(_tokenAmount) <= tge.ICO_AMOUNT(), "Can't be sold more than ICO amount.");
        sold = sold.add(_tokenAmount);
        super._processPurchase(_beneficiary, _tokenAmount);
    }  

    /**
     * @dev Finalization, transfer unsold tokens to the reserve address with lockup
     */    
    function finalization() internal {
        uint256 _unsold = token.balanceOf(this);
        if (_unsold > 0) {         
            PlatinToken(token).transfer(
                tge.UNSOLD_RESERVE(),
                _unsold);
        }
    }

    /**
     * @dev Extend parent behavior requiring contract to be not paused and the min purchase amount is received.
     * @param _beneficiary address Token beneficiary
     * @param _weiAmount uint256 Amount of wei contributed
     */
    function _preValidatePurchase(
        address _beneficiary,
        uint256 _weiAmount
    )
        internal
        whenNotPaused
    {
        require(_weiAmount >= tge.MIN_PURCHASE_AMOUNT(), "Insufficient funds to make the purchase.");
        super._preValidatePurchase(_beneficiary, _weiAmount);
    } 

    /**
     * @dev Override parent behavior to process lockup purchase if needed
     * @param _weiAmount uint256 Value in wei to be converted into tokens
     * @return uint256 Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 _weiAmount)
        internal view returns (uint256)
    {
        uint256 _rate = rate;
        if (lockup)
            _rate = tge.TOKEN_RATE_LOCKUP();
        return _weiAmount.mul(_rate);
    }    
} 

/**
 * @title PlatinICO Regular Purchase Proxy
 * @dev Proxy contract that calls payable buyTokens function in PlatinICO contract
 */
contract PlatinICORegular {

    // Platin ICO contract
    PlatinICO public ico;


    /**
     * @dev Constructor
     * @param _ico address Address of the Platin ICO contract                              
     */  
    constructor(PlatinICO _ico) public {
        require(_ico != address(0), "ICO address can't be zero.");
        ico = _ico;
    }

   /**
    * @dev fallback function, receives ether and sends it to the ICO contract calling payable buyTokens function
    */
    function () external payable {
        ico.buyTokens.value(msg.value)(msg.sender);
    }
}