pragma solidity 0.4.24;

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol

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

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol

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

contract MonetaToken is StandardToken, Ownable, Pausable {
    using SafeMath for uint256;

    string public constant name = "MonetaPro"; // solium-disable-line uppercase
    string public constant symbol = "MON"; // solium-disable-line uppercase
    uint8 public constant decimals = 9; // solium-disable-line uppercase

    mapping (address => bool) whitelist;
    mapping (address => bool) blacklist;

    uint private unlockTime;

    event AddedToWhitelist(address indexed _addr);
    event RemovedFromWhitelist(address indexed _addr);
    event AddedToBlacklist(address indexed _addr);
    event RemovedFromBlacklist(address indexed _addr);
    event SetNewUnlockTime(uint newUnlockTime);

    event Logging(bool msg);

    constructor(
        uint256 _totalSupply,
        uint256 _unlockTime
    )
        Ownable()
        public
    {
        require(_totalSupply > 0);
        require(_unlockTime > 0 && _unlockTime > getTime());

        totalSupply_ = _totalSupply;
        unlockTime = _unlockTime;
        balances[msg.sender] = totalSupply_;
        emit Transfer(0x0, msg.sender, totalSupply_);
    }

    modifier whenNotPausedOrInWhitelist() {
        emit Logging(true);
        emit Logging(isWhitelisted(msg.sender));
        require(
            !paused || isWhitelisted(msg.sender) || msg.sender == owner, 
            'contract paused and sender is not in whitelist'
        );
        _;
    }

    /**
     * @dev Transfer a token to a specified address
     * transfer
     *
     * transfer conditions:
     *  - the msg.sender address must be valid
     *  - the msg.sender _cannot_ be on the blacklist
     *  - one of the three conditions can be met:
     *      - the token contract is unlocked entirely
     *      - the msg.sender is whitelisted
     *      - the msg.sender is the owner of the contract
     *
     * @param _to address to transfer to
     * @param _value amount to transfer
     */
    function transfer(
        address _to,
        uint _value
    ) 
        public 
        whenNotPausedOrInWhitelist()
        returns (bool) 
    {
        require(_to != address(0));
        require(msg.sender != address(0));

        require(!isBlacklisted(msg.sender));
        require(isUnlocked() ||
                isWhitelisted(msg.sender) ||
                msg.sender == owner);

        return super.transfer(_to, _value);

    }

    /**
     * @dev addToBlacklist
     * @param _addr the address to add the blacklist
     */
    function addToBlacklist(
        address _addr
    ) onlyOwner public returns (bool) {
        require(_addr != address(0));
        require(!isBlacklisted(_addr));

        blacklist[_addr] = true;
        emit AddedToBlacklist(_addr);
        return true;
    }

    /**
     * @dev remove from blacklist
     * @param _addr the address to remove from the blacklist
     */
    function removeFromBlacklist(
        address _addr
    ) onlyOwner public returns (bool) {
        require(_addr != address(0));
        require(isBlacklisted(_addr));

        blacklist[_addr] = false;
        emit RemovedFromBlacklist(_addr);
        return true;
    }

    /**
     * @dev addToWhitelist
     * @param _addr the address to add to the whitelist
     */
    function addToWhitelist(
        address _addr
    ) onlyOwner public returns (bool) {
        require(_addr != address(0));
        require(!isWhitelisted(_addr));

        whitelist[_addr] = true;
        emit AddedToWhitelist(_addr);
        return true;
    }

    /**
     * @dev remove an address from the whitelist
     * @param _addr address to remove from whitelist
     */
    function removeFromWhitelist(
        address _addr
    ) onlyOwner public returns (bool) {
        require(_addr != address(0));
        require(isWhitelisted(_addr));

        whitelist[_addr] = false;
        emit RemovedFromWhitelist(_addr);
        return true;
    }

    function isBlacklisted(address _addr)
        public view returns (bool)
    {
        require(_addr != address(0));
        return blacklist[_addr];
    }

    /**
     * @dev isWhitelisted check if an address is on whitelist
     * @param _addr address to check if on whitelist
     */
    function isWhitelisted(address _addr)
        public view returns (bool)
    {
        require(_addr != address(0));
        return whitelist[_addr];
    }

    /**
     * @dev get the current time
     */
    function getTime() internal view returns (uint) {
        return now;
    }

    /**
     * @dev get the unlock time
     */
    function getUnlockTime() public view returns (uint) {
        return unlockTime;
    }

    /**
     * @dev set a new unlock time
     */
    function setUnlockTime(uint newUnlockTime) onlyOwner public returns (bool)
    {
        // require(newUnlockTime >= getTime());

        unlockTime = newUnlockTime;
        emit SetNewUnlockTime(getUnlockTime());
    }

    /**
     * @dev is the contract unlocked or not
     */
    function isUnlocked() public view returns (bool) {
        return (getUnlockTime() >= getTime());
    }
}