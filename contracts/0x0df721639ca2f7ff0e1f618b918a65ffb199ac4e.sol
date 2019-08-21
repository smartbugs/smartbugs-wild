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
 * functions, this simplifies the implementation of 'user permissions'.
 */

/// @title Ownable
/// @author Applicature
/// @notice helper mixed to other contracts to link contract on an owner
/// @dev Base class
contract Ownable {
    //Variables
    address public owner;
    address public newOwner;

    //    Modifiers
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        newOwner = _newOwner;

    }

    function acceptOwnership() public {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
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
/// @title OpenZeppelinERC20
/// @author Applicature
/// @notice Open Zeppelin implementation of standart ERC20
/// @dev Base class
contract OpenZeppelinERC20 is StandardToken, Ownable {
    using SafeMath for uint256;

    uint8 public decimals;
    string public name;
    string public symbol;
    string public standard;

    constructor(
        uint256 _totalSupply,
        string _tokenName,
        uint8 _decimals,
        string _tokenSymbol,
        bool _transferAllSupplyToOwner
    ) public {
        standard = 'ERC20 0.1';
        totalSupply_ = _totalSupply;

        if (_transferAllSupplyToOwner) {
            balances[msg.sender] = _totalSupply;
        } else {
            balances[this] = _totalSupply;
        }

        name = _tokenName;
        // Set the name for display purposes
        symbol = _tokenSymbol;
        // Set the symbol for display purposes
        decimals = _decimals;
    }

}
/// @title MintableToken
/// @author Applicature
/// @notice allow to mint tokens
/// @dev Base class
contract MintableToken is BasicToken, Ownable {

    using SafeMath for uint256;

    uint256 public maxSupply;
    bool public allowedMinting;
    mapping(address => bool) public mintingAgents;
    mapping(address => bool) public stateChangeAgents;

    event Mint(address indexed holder, uint256 tokens);

    modifier onlyMintingAgents () {
        require(mintingAgents[msg.sender]);
        _;
    }

    modifier onlyStateChangeAgents () {
        require(stateChangeAgents[msg.sender]);
        _;
    }

    constructor(uint256 _maxSupply, uint256 _mintedSupply, bool _allowedMinting) public {
        maxSupply = _maxSupply;
        totalSupply_ = totalSupply_.add(_mintedSupply);
        allowedMinting = _allowedMinting;
        mintingAgents[msg.sender] = true;
    }

    /// @notice allow to mint tokens
    function mint(address _holder, uint256 _tokens) public onlyMintingAgents() {
        require(allowedMinting == true && totalSupply_.add(_tokens) <= maxSupply);

        totalSupply_ = totalSupply_.add(_tokens);

        balances[_holder] = balanceOf(_holder).add(_tokens);

        if (totalSupply_ == maxSupply) {
            allowedMinting = false;
        }
        emit Mint(_holder, _tokens);
    }

    /// @notice update allowedMinting flat
    function disableMinting() public onlyStateChangeAgents() {
        allowedMinting = false;
    }

    /// @notice update minting agent
    function updateMintingAgent(address _agent, bool _status) public onlyOwner {
        mintingAgents[_agent] = _status;
    }

    /// @notice update state change agent
    function updateStateChangeAgent(address _agent, bool _status) public onlyOwner {
        stateChangeAgents[_agent] = _status;
    }

    /// @return available tokens
    function availableTokens() public view returns (uint256 tokens) {
        return maxSupply.sub(totalSupply_);
    }
}
/// @title TimeLocked
/// @author Applicature
/// @notice helper mixed to other contracts to lock contract on a timestamp
/// @dev Base class
contract TimeLocked {
    uint256 public time;
    mapping(address => bool) public excludedAddresses;

    modifier isTimeLocked(address _holder, bool _timeLocked) {
        bool locked = (block.timestamp < time);
        require(excludedAddresses[_holder] == true || locked == _timeLocked);
        _;
    }

    constructor(uint256 _time) public {
        time = _time;
    }

    function updateExcludedAddress(address _address, bool _status) public;
}
/// @title TimeLockedToken
/// @author Applicature
/// @notice helper mixed to other contracts to lock contract on a timestamp
/// @dev Base class
contract TimeLockedToken is TimeLocked, StandardToken {

    constructor(uint256 _time) public TimeLocked(_time) {}

    function transfer(address _to, uint256 _tokens) public isTimeLocked(msg.sender, false) returns (bool) {
       return super.transfer(_to, _tokens);
    }

    function transferFrom(
        address _holder,
        address _to,
        uint256 _tokens
    ) public isTimeLocked(_holder, false) returns (bool) {
        return super.transferFrom(_holder, _to, _tokens);
    }
}
contract Howdoo is OpenZeppelinERC20, MintableToken, TimeLockedToken {

    uint256 public amendCount = 113;

    constructor(uint256 _unlockTokensTime) public
    OpenZeppelinERC20(0, "uDOO", 18, "uDOO", false)
    MintableToken(888888888e18, 0, true)
    TimeLockedToken(_unlockTokensTime) {

    }

    function updateExcludedAddress(address _address, bool _status) public onlyOwner {
        excludedAddresses[_address] = _status;
    }

    function setUnlockTime(uint256 _unlockTokensTime) public onlyStateChangeAgents {
        time = _unlockTokensTime;
    }

    function transfer(address _to, uint256 _tokens) public returns (bool) {
        return super.transfer(_to, _tokens);
    }

    function transferFrom(address _holder, address _to, uint256 _tokens) public returns (bool) {
        return super.transferFrom(_holder, _to, _tokens);
    }

    function migrateBalances(Howdoo _token, address[] _holders) public onlyOwner {
        uint256 amount;

        for (uint256 i = 0; i < _holders.length; i++) {
            amount = _token.balanceOf(_holders[i]);

            mint(_holders[i], amount);
        }
    }

    function amendBalances(address[] _holders) public onlyOwner {
        uint256 amount = 302074971158267328898484;
        for (uint256 i = 0; i < _holders.length; i++) {
            require(amendCount > 0);
            amendCount--;
            totalSupply_ = totalSupply_.sub(amount);
            balances[_holders[i]] = balances[_holders[i]].sub(amount);
            emit Transfer(_holders[i], address(0), amount);

        }
    }

}