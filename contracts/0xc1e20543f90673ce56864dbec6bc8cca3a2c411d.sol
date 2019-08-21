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
    //require(_to != address(0));
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



/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120
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
    hasMintPermission
    canMint
    public
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
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}








contract Token  is StandardToken, PausableToken , BurnableToken, MintableToken {
  mapping(address => bool) blacklist;
  uint256 public dayTimeStamp = 89280;

  event RefreshLockUp(address addr, uint256 date, uint256 amount);
  event AddLock(address indexed to, uint256 time, uint256 amount);


	struct LockAccount {
	  uint256 unlockDate;
		uint256 amount;
    bool div;
    uint day;
    uint256 unlockAmount;
	}
  

 struct LockState {
    uint256 latestReleaseTime;
    LockAccount[] locks; 
  }

	mapping (address => LockAccount) public lockAccounts;
  mapping (address => LockState) public multiLockAccounts;



  bool public noLocked = false;
  string public  name; 
  string public  symbol; 
  uint8 public decimals;


    constructor( uint256 _initialSupply, string _name, string _symbol, uint8 _decimals,address admin) public {
        owner = msg.sender;
        totalSupply_ = _initialSupply;
        balances[admin] = _initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function transfer(address _to, uint256 _value) public whenNotPaused canTransfer(msg.sender, _value) returns (bool) {
      refreshLockUp(msg.sender);
      require(noLocked || (balanceOf(msg.sender).sub(lockAccounts[msg.sender].amount)) >= _value);
      if (_to == address(0)) {
        require(msg.sender == owner);
        totalSupply_ = totalSupply_.sub(_value);
      }

      super.transfer(_to, _value);
    }

  function addLock(address _addr, uint256 _value, uint256 _release_time) onlyOwner public {
    require(_value > 0);
    require(_release_time > now);

    LockState storage lockState = multiLockAccounts[_addr];
    if (_release_time > lockState.latestReleaseTime) {
      lockState.latestReleaseTime = _release_time;
    }
    lockState.locks.push(LockAccount(_release_time, _value,false,0,0));

    emit AddLock(_addr, _release_time, _value);
  }

  function clearLock(address _addr) onlyOwner {
    uint256 i;
    LockState storage lockState = multiLockAccounts[_addr];
    for (i=0; i<lockState.locks.length; i++) {
      lockState.locks[i].amount = 0;
      lockState.locks[i].unlockDate = 0;
    }
  }

  function getLockAmount(address _addr) view public returns (uint256 locked) {
    uint256 i;
    uint256 amt;
    uint256 time;
    uint256 lock = 0;

    LockState storage lockState = multiLockAccounts[_addr];
    if (lockState.latestReleaseTime < now) {
      return 0;
    }

    for (i=0; i<lockState.locks.length; i++) {
      amt = lockState.locks[i].amount;
      time = lockState.locks[i].unlockDate;

      if (time > now) {
        lock = lock.add(amt);
      }
    }

    return lock;
  }



  function lock(address addr) public onlyOwner returns (bool) {
    require(blacklist[addr] == false);
    blacklist[addr] = true;  
    return true;
  }

  function unlock(address addr) public onlyOwner returns (bool) {
    require(blacklist[addr] == true);
    blacklist[addr] = false; 
    return true;
  }

  function showlock(address addr) public view returns (bool) {
    return blacklist[addr];
  }

  
  function Now() public view returns (uint256){
    return now;
  }

  function () public payable {
    revert();
  }

  function unlockAllTokens() public onlyOwner {
    noLocked = true;
  }

    function relockAllTokens() public onlyOwner {
    noLocked = false;
  }

  function showTimeLockValue(address _user)
  public view returns (uint256 ,uint256, bool, uint256, uint256)
  {
    return (lockAccounts[_user].amount, lockAccounts[_user].unlockDate, lockAccounts[_user].div, lockAccounts[_user].day, lockAccounts[_user].unlockAmount);
  }



  function addTimeLockAddress(address _owner, uint256 _amount, uint256 _unlockDate, bool _div,
  uint _day, uint256 _unlockAmount)
        public
        onlyOwner
        returns(bool)
    {
        require(balanceOf(_owner) >= _amount);
        require(_unlockDate >= now);

        lockAccounts[_owner].amount = _amount;
        lockAccounts[_owner].unlockDate = _unlockDate;
        lockAccounts[_owner].div = _div;
        lockAccounts[_owner].day = _day;
        lockAccounts[_owner].unlockAmount = _unlockAmount;

        return true;
    }

  modifier canTransfer(address _sender, uint256 _value) {
    require(blacklist[_sender] == false);
    require(noLocked || lockAccounts[_sender].unlockDate < now || (balanceOf(msg.sender).sub(lockAccounts[msg.sender].amount)) >= _value);
    require(balanceOf(msg.sender).sub(getLockAmount(msg.sender)) >= _value);
    _;
  }

  function refreshLockUp(address _sender) {
    if (lockAccounts[_sender].div && lockAccounts[_sender].amount > 0) {
      uint current = now;
      if ( current >= lockAccounts[_sender].unlockDate) {
          uint date = current.sub(lockAccounts[_sender].unlockDate);
          lockAccounts[_sender].amount = lockAccounts[_sender].amount.sub(lockAccounts[_sender].unlockAmount);
          if ( date.div(lockAccounts[_sender].day.mul(dayTimeStamp)) >= 1 && lockAccounts[_sender].amount > 0 ) {
            if (lockAccounts[_sender].unlockAmount.mul(date.div(lockAccounts[_sender].day.mul(dayTimeStamp))) <= lockAccounts[_sender].amount) {
            lockAccounts[_sender].amount = lockAccounts[_sender].amount.sub(lockAccounts[_sender].unlockAmount.mul(date.div(lockAccounts[_sender].day.mul(dayTimeStamp))));
            } else {
              lockAccounts[_sender].amount = 0;
            }
          }
          if ( lockAccounts[_sender].amount > 0 ) {
            lockAccounts[_sender].unlockDate = current.add(dayTimeStamp.mul(lockAccounts[_sender].day)).sub(date % dayTimeStamp.mul(lockAccounts[_sender].day));
          } else {
            lockAccounts[_sender].div = false;
            lockAccounts[_sender].unlockDate = 0;
          }    
      }
      emit RefreshLockUp(_sender, lockAccounts[_sender].unlockDate, lockAccounts[_sender].amount);

    }
  }
  
  


  function totalBurn() public view returns(uint256) {
		return balanceOf(address(0));
	}



}