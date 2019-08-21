// File: zeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.4.24;


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

// File: zeppelin-solidity/contracts/lifecycle/Destructible.sol

pragma solidity ^0.4.24;



/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {
  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() public onlyOwner {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) public onlyOwner {
    selfdestruct(_recipient);
  }
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

pragma solidity ^0.4.24;


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

// File: zeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.4.24;


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

// File: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol

pragma solidity ^0.4.24;




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

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.4.24;



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

// File: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol

pragma solidity ^0.4.24;




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

// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol

pragma solidity ^0.4.24;



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

// File: zeppelin-solidity/contracts/token/ERC20/PausableToken.sol

pragma solidity ^0.4.24;




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

// File: zeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol

pragma solidity ^0.4.24;



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

// File: zeppelin-solidity/contracts/token/ERC20/MintableToken.sol

pragma solidity ^0.4.24;




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

// File: zeppelin-solidity/contracts/token/ERC20/CappedToken.sol

pragma solidity ^0.4.24;



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

// File: contracts/InsightsNetwork1.sol

pragma solidity ^0.4.4;

contract InsightsNetwork1 {
  address public owner; // Creator
  address public successor; // May deactivate contract
  mapping (address => uint) public balances;    // Who has what
  mapping (address => uint) public unlockTimes; // When balances unlock
  bool public active;
  uint256 _totalSupply; // Sum of minted tokens

  string public constant name = "INS";
  string public constant symbol = "INS";
  uint8 public constant decimals = 0;

  function InsightsNetwork1() {
    owner = msg.sender;
    active = true;
  }

  function register(address newTokenHolder, uint issueAmount) { // Mint tokens and assign to new owner
    require(active);
    require(msg.sender == owner);   // Only creator can register
    require(balances[newTokenHolder] == 0); // Accounts can only be registered once

    _totalSupply += issueAmount;
    Mint(newTokenHolder, issueAmount);  // Trigger event

    require(balances[newTokenHolder] < (balances[newTokenHolder] + issueAmount));   // Overflow check
    balances[newTokenHolder] += issueAmount;
    Transfer(address(0), newTokenHolder, issueAmount);  // Trigger event

    uint currentTime = block.timestamp; // seconds since the Unix epoch
    uint unlockTime = currentTime + 365*24*60*60; // one year out from the current time
    assert(unlockTime > currentTime); // check for overflow
    unlockTimes[newTokenHolder] = unlockTime;
  }

  function totalSupply() constant returns (uint256) {   // ERC20 compliance
    return _totalSupply;
  }

  function transfer(address _to, uint256 _value) returns (bool success) {   // ERC20 compliance
    return false;
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {    // ERC20 compliance
    return false;
  }

  function approve(address _spender, uint256 _value) returns (bool success) {   // ERC20 compliance
    return false;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {   // ERC20 compliance
    return 0;   // No transfer allowance
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {   // ERC20 compliance
    return balances[_owner];
  }

  function getUnlockTime(address _accountHolder) constant returns (uint256) {
    return unlockTimes[_accountHolder];
  }

  event Mint(address indexed _to, uint256 _amount);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  function makeSuccessor(address successorAddr) {
    require(active);
    require(msg.sender == owner);
    //require(successorAddr == address(0));
    successor = successorAddr;
  }

  function deactivate() {
    require(active);
    require(msg.sender == owner || (successor != address(0) && msg.sender == successor));   // Called by creator or successor
    active = false;
  }
}

// File: contracts/InsightsNetwork2Base.sol

pragma solidity ^0.4.18;






contract InsightsNetwork2Base is DetailedERC20("Insights Network", "INSTAR", 18), PausableToken, CappedToken{

    uint256 constant ATTOTOKEN_FACTOR = 10**18;

    address public predecessor;
    address public successor;

    uint constant MAX_LENGTH = 1024;
    uint constant MAX_PURCHASES = 64;
    
    mapping (address => uint256[]) public lockedBalances;
    mapping (address => uint256[]) public unlockTimes;
    mapping (address => bool) public imported;

    event Import(address indexed account, uint256 amount, uint256 unlockTime);    

    function InsightsNetwork2Base() public CappedToken(300*1000000*ATTOTOKEN_FACTOR) {
        paused = true;
        mintingFinished = true;
    }

    function activate(address _predecessor) public onlyOwner {
        require(predecessor == 0);
        require(_predecessor != 0);
        require(predecessorDeactivated(_predecessor));
        predecessor = _predecessor;
        unpause();
        mintingFinished = false;
    }

    function lockedBalanceOf(address account) public view returns (uint256 balance) {
        uint256 amount;
        for (uint256 index = 0; index < lockedBalances[account].length; index++)
            if (unlockTimes[account][index] > now)
                amount += lockedBalances[account][index];
        return amount;
    }

    function mintBatch(address[] accounts, uint256[] amounts) public onlyOwner canMint returns (bool) {
        require(accounts.length == amounts.length);
        require(accounts.length <= MAX_LENGTH);
        for (uint index = 0; index < accounts.length; index++)
            require(mint(accounts[index], amounts[index]));
        return true;
    }

    function mintUnlockTime(address account, uint256 amount, uint256 unlockTime) public onlyOwner canMint returns (bool) {
        require(unlockTime > now);
        require(lockedBalances[account].length < MAX_PURCHASES);
        lockedBalances[account].push(amount);
        unlockTimes[account].push(unlockTime);
        return super.mint(account, amount);
    }

    function mintUnlockTimeBatch(address[] accounts, uint256[] amounts, uint256 unlockTime) public onlyOwner canMint returns (bool) {
        require(accounts.length == amounts.length);
        require(accounts.length <= MAX_LENGTH);
        for (uint index = 0; index < accounts.length; index++)
            require(mintUnlockTime(accounts[index], amounts[index], unlockTime));
        return true;
    }

    function mintLockPeriod(address account, uint256 amount, uint256 lockPeriod) public onlyOwner canMint returns (bool) {
        return mintUnlockTime(account, amount, now + lockPeriod);
    }

    function mintLockPeriodBatch(address[] accounts, uint256[] amounts, uint256 lockPeriod) public onlyOwner canMint returns (bool) {
        return mintUnlockTimeBatch(accounts, amounts, now + lockPeriod);
    }

    function importBalance(address account) public onlyOwner canMint returns (bool);

    function importBalanceBatch(address[] accounts) public onlyOwner canMint returns (bool) {
        require(accounts.length <= MAX_LENGTH);
        for (uint index = 0; index < accounts.length; index++)
            require(importBalance(accounts[index]));
        return true;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= balances[msg.sender] - lockedBalanceOf(msg.sender));
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= balances[from] - lockedBalanceOf(from));
        return super.transferFrom(from, to, value);
    }

    function selfDestruct(address _successor) public onlyOwner whenPaused {
        require(mintingFinished);
        successor = _successor;
        selfdestruct(owner);
    }

    function predecessorDeactivated(address _predecessor) internal view onlyOwner returns (bool);

}

// File: contracts/InsightsNetwork3.sol

pragma solidity ^0.4.18;



contract InsightsNetwork3 is InsightsNetwork2Base {

    function importBalance(address account) public onlyOwner canMint returns (bool) {
        require(!imported[account]);
        InsightsNetwork2Base source = InsightsNetwork2Base(predecessor);
        uint256 amount = source.balanceOf(account);
        require(amount > 0);
        imported[account] = true;
        uint256 mintAmount = amount - source.lockedBalanceOf(account);
        if (mintAmount > 0) {
            Import(account, mintAmount, now);
            assert(mint(account, mintAmount));
            amount -= mintAmount;
        }
        for (uint index = 0; amount > 0; index++) {
            uint256 unlockTime = source.unlockTimes(account, index);
            if ( unlockTime > now ) {
                mintAmount = source.lockedBalances(account, index);
                Import(account, mintAmount, unlockTime);
                assert(mintUnlockTime(account, mintAmount, unlockTime));
                amount -= mintAmount;
            }
        }
        return true;
    }

    function predecessorDeactivated(address _predecessor) internal view onlyOwner returns (bool) {
        return InsightsNetwork2Base(_predecessor).paused() && InsightsNetwork2Base(_predecessor).mintingFinished();
    }

}

// File: contracts/InsightsNetworkMigrationToEOS.sol

pragma solidity ^0.4.24;




contract InsightsNetworkMigrationToEOS is Destructible, Pausable {

    InsightsNetwork3 public tokenContract;

    mapping(address => string) public eosPublicKeys;
    mapping(address => uint256) public changeTime;

    uint256 public constant gracePeriod = 24 * 60 * 60;

    event Register(address indexed account);
    event Reject(address indexed account);

    constructor(address _tokenContractAddr) public {
        tokenContract = InsightsNetwork3(_tokenContractAddr);
        paused = true;
    }

    function register(string eosPublicKey) public whenNotPaused {
        require(tokenContract.balanceOf(msg.sender) > 0);

        require(bytes(eosPublicKey).length == 53 && bytes(eosPublicKey)[0] == "E" && bytes(eosPublicKey)[1] == "O" && bytes(eosPublicKey)[2] == "S");
        require(bytes(eosPublicKeys[msg.sender]).length == 0);

        eosPublicKeys[msg.sender] = eosPublicKey;
        changeTime[msg.sender] = block.timestamp;

        emit Register(msg.sender);
    }

    function reject() public whenNotPaused {
        require(bytes(eosPublicKeys[msg.sender]).length > 0);
        require((changeTime[msg.sender] + gracePeriod) > block.timestamp);

        delete eosPublicKeys[msg.sender];
        delete changeTime[msg.sender];

        emit Reject(msg.sender);
    }
}