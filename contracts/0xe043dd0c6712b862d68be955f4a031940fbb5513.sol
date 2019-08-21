pragma solidity 0.4.24;

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

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
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

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

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

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
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

// File: contracts/interfaces/IRegistry.sol

// limited ContractRegistry definition
interface IRegistry {
  function owner()
    external
    returns(address);

  function updateContractAddress(
    string _name,
    address _address
  )
    external
    returns (address);

  function getContractAddress(
    string _name
  )
    external
    view
    returns (address);
}

// File: contracts/interfaces/IBrickblockToken.sol

// limited BrickblockToken definition
interface IBrickblockToken {
  function transfer(
    address _to,
    uint256 _value
  )
    external
    returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (bool);

  function balanceOf(
    address _address
  )
    external
    view
    returns (uint256);

  function approve(
    address _spender,
    uint256 _value
  )
    external
    returns (bool);
}

// File: contracts/AccessToken.sol

/// @title The utility token used for paying fees in the Brickblock ecosystem

/** @dev Explanation of terms and patterns:
    General:
      * Units of account: All per-token balances are stored in wei (1e18), for the greatest possible accuracy
      * ERC20 "balances":
        * "balances" per default is not updated unless a transfer/transferFrom happens
        * That's why it's set to "internal" because we can't guarantee its accuracy

    Current Lock Period Balance Sheet:
      * The balance sheet for tracking ACT balances for the _current_ lock period is 'mintedActFromCurrentLockPeriodPerUser'
      * Formula:
        * "totalLockedBBK * (totalMintedActPerLockedBbkToken - mintedActPerUser) / 1e18"
      * The period in which a BBK token has been locked uninterruptedly
      * For example, if a token has been locked for 30 days, then unlocked for 13 days, then locked again
        for 5 days, the current lock period would be 5 days
      * When a BBK is locked or unlocked, the ACT balance for the respective BBK holder
        is transferred to a separate balance sheet, called 'mintedActFromPastLockPeriodsPerUser'
        * Upon migrating this balance to 'mintedActFromPastLockPeriodsPerUser', this balance sheet is essentially
          zeroed out by setting 'mintedActPerUser' to 'totalMintedActPerLockedBbkToken'
        * ie. "42 totalLockedBBK * (100 totalMintedActPerLockedBbkToken - 100 mintedActPerUser) === 0"
      * All newly minted ACT per user are tracked through this until an unlock event occurs

    Past Lock Periods Balance Sheet:
      * The balance sheet for tracking ACT balances for the _past_ lock periods is 'mintedActFromPastLockPeriodsPerUser'
      * Formula:
        * The sum of all minted ACT from all past lock periods
      * All periods in which a BBK token has been locked _before_ the current lock period
      * For example, if a token has been locked for 10 days, then unlocked for 13 days, then locked again for 5 days,
        then unlocked for 7 days, then locked again for 30 days, the past lock periods would add up to 15 days
      * So essentially we're summing all locked periods that happened _before_ the current lock period
      * Needed to track ACT balance per user after a lock or unlock event occurred

    Transfers Balance Sheet:
      * The balance sheet for tracking balance changes caused by transfer() and transferFrom()
      * Needed to accurately track balanceOf after transfers
      * Formula:
        * "receivedAct[address] - spentAct[address]"
      * receivedAct is incremented after an address receives ACT via a transfer() or transferFrom()
        * increments balanceOf
      * spentAct is incremented after an address spends ACT via a transfer() or transferFrom()
        * decrements balanceOf

    All 3 Above Balance Sheets Combined:
      * When combining the Current Lock Period Balance, the Past Lock Periods Balance and the Transfers Balance:
        * We should get the correct total balanceOf for a given address
        * mintedActFromCurrentLockPeriodPerUser[addr]  // Current Lock Period Balance Sheet
          + mintedActFromPastLockPeriodsPerUser[addr]  // Past Lock Periods Balance Sheet
          + receivedAct[addr] - spentAct[addr]     // Transfers Balance Sheet
*/

contract AccessToken is PausableToken {
  uint8 public constant version = 1;

  // Instance of registry contract to get contract addresses
  IRegistry internal registry;
  string public constant name = "AccessToken";
  string public constant symbol = "ACT";
  uint8 public constant decimals = 18;

  // Total amount of minted ACT that a single locked BBK token is entitled to
  uint256 internal totalMintedActPerLockedBbkToken;

  // Total amount of BBK that is currently locked into the ACT contract
  uint256 public totalLockedBBK;

  // Amount of locked BBK per user
  mapping(address => uint256) internal lockedBbkPerUser;

  /*
   * Total amount of minted ACT per user
   * Used to decrement totalMintedActPerLockedBbkToken by amounts that have already been moved to mintedActFromPastLockPeriodsPerUser
   */
  mapping(address => uint256) internal mintedActPerUser;

  // Track minted ACT tokens per user for the current BBK lock period
  mapping(address => uint256) internal mintedActFromCurrentLockPeriodPerUser;

  // Track minted ACT tokens per user for past BBK lock periods
  mapping(address => uint256) internal mintedActFromPastLockPeriodsPerUser;

  // ERC20 override to keep balances private and use balanceOf instead
  mapping(address => uint256) internal balances;

  // Track received ACT via transfer or transferFrom in order to calculate the correct balanceOf
  mapping(address => uint256) public receivedAct;

  // Track spent ACT via transfer or transferFrom in order to calculate the correct balanceOf
  mapping(address => uint256) public spentAct;


  event Mint(uint256 amount);
  event Burn(address indexed burner, uint256 value);
  event BbkLocked(
    address indexed locker,
    uint256 lockedAmount,
    uint256 totalLockedAmount
  );
  event BbkUnlocked(
    address indexed locker,
    uint256 unlockedAmount,
    uint256 totalLockedAmount
  );

  modifier onlyContract(string _contractName)
  {
    require(
      msg.sender == registry.getContractAddress(_contractName)
    );
    _;
  }

  constructor (
    address _registryAddress
  )
    public
  {
    require(_registryAddress != address(0));
    registry = IRegistry(_registryAddress);
  }

  /// @notice Check an address for amount of currently locked BBK
  /// works similar to basic ERC20 balanceOf
  function lockedBbkOf(
    address _address
  )
    external
    view
    returns (uint256)
  {
    return lockedBbkPerUser[_address];
  }

  /** @notice Transfers BBK from an account owning BBK to this contract.
    1. Uses settleCurrentLockPeriod to transfer funds from the "Current Lock Period"
       balance sheet to the "Past Lock Periods" balance sheet.
    2. Keeps a record of BBK transfers via events
    @param _amount BBK token amount to lock
  */
  function lockBBK(
    uint256 _amount
  )
    external
    returns (bool)
  {
    require(_amount > 0);
    IBrickblockToken _bbk = IBrickblockToken(
      registry.getContractAddress("BrickblockToken")
    );

    require(settleCurrentLockPeriod(msg.sender));
    lockedBbkPerUser[msg.sender] = lockedBbkPerUser[msg.sender].add(_amount);
    totalLockedBBK = totalLockedBBK.add(_amount);
    require(_bbk.transferFrom(msg.sender, this, _amount));
    emit BbkLocked(msg.sender, _amount, totalLockedBBK);
    return true;
  }

  /** @notice Transfers BBK from this contract to an account
    1. Uses settleCurrentLockPeriod to transfer funds from the "Current Lock Period"
       balance sheet to the "Past Lock Periods" balance sheet.
    2. Keeps a record of BBK transfers via events
    @param _amount BBK token amount to unlock
  */
  function unlockBBK(
    uint256 _amount
  )
    external
    returns (bool)
  {
    require(_amount > 0);
    IBrickblockToken _bbk = IBrickblockToken(
      registry.getContractAddress("BrickblockToken")
    );
    require(_amount <= lockedBbkPerUser[msg.sender]);
    require(settleCurrentLockPeriod(msg.sender));
    lockedBbkPerUser[msg.sender] = lockedBbkPerUser[msg.sender].sub(_amount);
    totalLockedBBK = totalLockedBBK.sub(_amount);
    require(_bbk.transfer(msg.sender, _amount));
    emit BbkUnlocked(msg.sender, _amount, totalLockedBBK);
    return true;
  }

  /**
    @notice Distribute ACT tokens to all BBK token holders, that have currently locked their BBK tokens into this contract.
    Adds the tiny delta, caused by integer division remainders, to the owner's mintedActFromPastLockPeriodsPerUser balance.
    @param _amount Amount of fee to be distributed to ACT holders
    @dev Accepts calls only from our `FeeManager` contract
  */
  function distribute(
    uint256 _amount
  )
    external
    onlyContract("FeeManager")
    returns (bool)
  {
    totalMintedActPerLockedBbkToken = totalMintedActPerLockedBbkToken
      .add(
        _amount
          .mul(1e18)
          .div(totalLockedBBK)
      );

    uint256 _delta = (_amount.mul(1e18) % totalLockedBBK).div(1e18);
    mintedActFromPastLockPeriodsPerUser[owner] = mintedActFromPastLockPeriodsPerUser[owner].add(_delta);
    totalSupply_ = totalSupply_.add(_amount);
    emit Mint(_amount);
    return true;
  }

  /**
    @notice Calculates minted ACT from "Current Lock Period" for a given address
    @param _address ACT holder address
   */
  function getMintedActFromCurrentLockPeriod(
    address _address
  )
    private
    view
    returns (uint256)
  {
    return lockedBbkPerUser[_address]
      .mul(totalMintedActPerLockedBbkToken.sub(mintedActPerUser[_address]))
      .div(1e18);
  }

  /**
    @notice Transfers "Current Lock Period" balance sheet to "Past Lock Periods" balance sheet.
    Ensures that BBK transfers won't affect accrued ACT balances.
   */
  function settleCurrentLockPeriod(
    address _address
  )
    private
    returns (bool)
  {
    mintedActFromCurrentLockPeriodPerUser[_address] = getMintedActFromCurrentLockPeriod(_address);
    mintedActFromPastLockPeriodsPerUser[_address] = mintedActFromPastLockPeriodsPerUser[_address]
      .add(mintedActFromCurrentLockPeriodPerUser[_address]);
    mintedActPerUser[_address] = totalMintedActPerLockedBbkToken;

    return true;
  }

  /************************
  * Start ERC20 overrides *
  ************************/

  /** @notice Combines all balance sheets to calculate the correct balance (see explanation on top)
    @param _address Sender address
    @return uint256
  */
  function balanceOf(
    address _address
  )
    public
    view
    returns (uint256)
  {
    mintedActFromCurrentLockPeriodPerUser[_address] = getMintedActFromCurrentLockPeriod(_address);

    return totalMintedActPerLockedBbkToken == 0
      ? 0
      : mintedActFromCurrentLockPeriodPerUser[_address]
      .add(mintedActFromPastLockPeriodsPerUser[_address])
      .add(receivedAct[_address])
      .sub(spentAct[_address]);
  }

  /**
    @notice Same as the default ERC20 transfer() with two differences:
    1. Uses "balanceOf(address)" rather than "balances[address]" to check the balance of msg.sender
       ("balances" is inaccurate, see above).
    2. Updates the Transfers Balance Sheet.

    @param _to Receiver address
    @param _value Amount
    @return bool
  */
  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balanceOf(msg.sender));
    spentAct[msg.sender] = spentAct[msg.sender].add(_value);
    receivedAct[_to] = receivedAct[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
    @notice Same as the default ERC20 transferFrom() with two differences:
    1. Uses "balanceOf(address)" rather than "balances[address]" to check the balance of msg.sender
       ("balances" is inaccurate, see above).
    2. Updates the Transfers Balance Sheet.

    @param _from Sender Address
    @param _to Receiver address
    @param _value Amount
    @return bool
  */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balanceOf(_from));
    require(_value <= allowed[_from][msg.sender]);
    spentAct[_from] = spentAct[_from].add(_value);
    receivedAct[_to] = receivedAct[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**********************
  * End ERC20 overrides *
  ***********************/

  /**
    @notice Burns tokens through decrementing "totalSupply" and incrementing "spentAct[address]"
    @dev Callable only by FeeManager contract
    @param _address Sender Address
    @param _value Amount
    @return bool
  */
  function burn(
    address _address,
    uint256 _value
  )
    external
    onlyContract("FeeManager")
    returns (bool)
  {
    require(_value <= balanceOf(_address));
    spentAct[_address] = spentAct[_address].add(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_address, _value);
    return true;
  }
}