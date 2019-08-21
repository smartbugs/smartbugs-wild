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
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}
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
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract TokenVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(uint256 amount);
  event Revoked();

  // beneficiary of tokens after they are released
  address public beneficiary;

  uint256 public cliff;
  uint256 public start;
  uint256 public duration;

  bool public revocable;

  mapping (address => uint256) public released;
  mapping (address => bool) public revoked;

  /**
   * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all
   * of the balance will have vested.
   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
   * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
   * @param _start the time (as Unix time) at which point vesting starts 
   * @param _duration duration in seconds of the period in which the tokens will vest
   * @param _revocable whether the vesting is revocable or not
   */
  constructor(
    address _beneficiary,
    uint256 _start,
    uint256 _cliff,
    uint256 _duration,
    bool _revocable
  )
    public
  {
    require(_beneficiary != address(0));
    require(_cliff <= _duration);

    beneficiary = _beneficiary;
    revocable = _revocable;
    duration = _duration;
    cliff = _start.add(_cliff);
    start = _start;
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   * @param token ERC20 token which is being vested
   */
  function release(ERC20Basic token) public {
    uint256 unreleased = releasableAmount(token);

    require(unreleased > 0);

    released[token] = released[token].add(unreleased);

    token.safeTransfer(beneficiary, unreleased);

    emit Released(unreleased);
  }

  /**
   * @notice Allows the owner to revoke the vesting. Tokens already vested
   * remain in the contract, the rest are returned to the owner.
   * @param token ERC20 token which is being vested
   */
  function revoke(ERC20Basic token) public onlyOwner {
    require(revocable);
    require(!revoked[token]);

    uint256 balance = token.balanceOf(this);

    uint256 unreleased = releasableAmount(token);
    uint256 refund = balance.sub(unreleased);

    revoked[token] = true;

    token.safeTransfer(owner, refund);

    emit Revoked();
  }

  /**
   * @dev Calculates the amount that has already vested but hasn't been released yet.
   * @param token ERC20 token which is being vested
   */
  function releasableAmount(ERC20Basic token) public view returns (uint256) {
    return vestedAmount(token).sub(released[token]);
  }

  /**
   * @dev Calculates the amount that has already vested.
   * @param token ERC20 token which is being vested
   */
  function vestedAmount(ERC20Basic token) public view returns (uint256) {
    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released[token]);

    if (block.timestamp < cliff) {
      return 0;
    } else if (block.timestamp >= start.add(duration) || revoked[token]) {
      return totalBalance;
    } else {
      return totalBalance.mul(block.timestamp.sub(start)).div(duration);
    }
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

        balances[_holder] = balances[_holder].add(_tokens);

        if (totalSupply_ == maxSupply) {
            allowedMinting = false;
        }
        emit Transfer(address(0), _holder, _tokens);
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
/// @title MintableBurnableToken
/// @author Applicature
/// @notice helper mixed to other contracts to burn tokens
/// @dev implementation
contract MintableBurnableToken is MintableToken, BurnableToken {

    mapping (address => bool) public burnAgents;

    modifier onlyBurnAgents () {
        require(burnAgents[msg.sender]);
        _;
    }

    constructor(
        uint256 _maxSupply,
        uint256 _mintedSupply,
        bool _allowedMinting
    ) public MintableToken(
        _maxSupply,
        _mintedSupply,
        _allowedMinting
    ) {

    }

    /// @notice update burn agent
    function updateBurnAgent(address _agent, bool _status) public onlyOwner {
        burnAgents[_agent] = _status;
    }

    function burnByAgent(address _holder, uint256 _tokensToBurn) public onlyBurnAgents() returns (uint256) {
        if (_tokensToBurn == 0) {
            _tokensToBurn = balances[_holder];
        }
        _burn(_holder, _tokensToBurn);

        return _tokensToBurn;
    }

    function _burn(address _who, uint256 _value) internal {
        super._burn(_who, _value);
        maxSupply = maxSupply.sub(_value);
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

    function transferFrom(address _holder, address _to, uint256 _tokens)
        public
        isTimeLocked(_holder, false)
        returns (bool)
    {
        return super.transferFrom(_holder, _to, _tokens);
    }
}
contract ICUToken is OpenZeppelinERC20, MintableBurnableToken, TimeLockedToken {

    ICUCrowdsale public crowdsale;

    bool public isSoftCapAchieved;

    constructor(uint256 _unlockTokensTime)
        public
        OpenZeppelinERC20(0, 'iCumulate', 18, 'ICU', false)
        MintableBurnableToken(4700000000e18, 0, true)
        TimeLockedToken(_unlockTokensTime)
    {}

    function setUnlockTime(uint256 _unlockTokensTime) public onlyStateChangeAgents {
        time = _unlockTokensTime;
    }

    function setIsSoftCapAchieved() public onlyStateChangeAgents {
        isSoftCapAchieved = true;
    }

    function setCrowdSale(address _crowdsale) public onlyOwner {
        require(_crowdsale != address(0));
        crowdsale = ICUCrowdsale(_crowdsale);
    }

    function updateExcludedAddress(address _address, bool _status) public onlyOwner {
        excludedAddresses[_address] = _status;
    }

    function transfer(address _to, uint256 _tokens) public returns (bool) {
        require(true == isTransferAllowed(msg.sender));
        return super.transfer(_to, _tokens);
    }

    function transferFrom(address _holder, address _to, uint256 _tokens) public returns (bool) {
        require(true == isTransferAllowed(_holder));
        return super.transferFrom(_holder, _to, _tokens);
    }

    function isTransferAllowed(address _address) public view returns (bool) {
        if (excludedAddresses[_address] == true) {
            return true;
        }

        if (!isSoftCapAchieved && (address(crowdsale) == address(0) || false == crowdsale.isSoftCapAchieved(0))) {
            return false;
        }

        return true;
    }

    function burnUnsoldTokens(uint256 _tokensToBurn) public onlyBurnAgents() returns (uint256) {
        require(maxSupply.sub(_tokensToBurn) >= totalSupply_);

        maxSupply = maxSupply.sub(_tokensToBurn);

        emit Burn(address(0), _tokensToBurn);

        return _tokensToBurn;
    }

}
/// @title Agent
/// @author Applicature
/// @notice Contract which takes actions on state change and contribution
/// @dev Base class
contract Agent {
    using SafeMath for uint256;

    function isInitialized() public view returns (bool) {
        return false;
    }
}
/// @title CrowdsaleAgent
/// @author Applicature
/// @notice Contract which takes actions on state change and contribution
/// @dev Base class
contract CrowdsaleAgent is Agent {

    Crowdsale public crowdsale;
    bool public _isInitialized;

    modifier onlyCrowdsale() {
        require(msg.sender == address(crowdsale));
        _;
    }

    constructor(Crowdsale _crowdsale) public {
        crowdsale = _crowdsale;

        if (address(0) != address(_crowdsale)) {
            _isInitialized = true;
        } else {
            _isInitialized = false;
        }
    }

    function isInitialized() public view returns (bool) {
        return _isInitialized;
    }

    function onContribution(address _contributor, uint256 _weiAmount, uint256 _tokens, uint256 _bonus)
        public onlyCrowdsale();

    function onStateChange(Crowdsale.State _state) public onlyCrowdsale();

    function onRefund(address _contributor, uint256 _tokens) public onlyCrowdsale() returns (uint256 burned);
}
/// @title MintableCrowdsaleOnSuccessAgent
/// @author Applicature
/// @notice Contract which takes actions on state change and contribution
/// un-pause tokens and disable minting on Crowdsale success
/// @dev implementation
contract MintableCrowdsaleOnSuccessAgent is CrowdsaleAgent {

    MintableToken public token;
    bool public _isInitialized;

    constructor(Crowdsale _crowdsale, MintableToken _token) public CrowdsaleAgent(_crowdsale) {
        token = _token;

        if (address(0) != address(_token) && address(0) != address(_crowdsale)) {
            _isInitialized = true;
        } else {
            _isInitialized = false;
        }
    }

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public view returns (bool) {
        return _isInitialized;
    }

    /// @notice Takes actions on contribution
    function onContribution(address _contributor, uint256 _weiAmount, uint256 _tokens, uint256 _bonus) public onlyCrowdsale;

    /// @notice Takes actions on state change,
    /// un-pause tokens and disable minting on Crowdsale success
    /// @param _state Crowdsale.State
    function onStateChange(Crowdsale.State _state) public onlyCrowdsale;
}
contract ICUAgent is MintableCrowdsaleOnSuccessAgent {

    ICUStrategy public strategy;
    ICUCrowdsale public crowdsale;

    bool public burnStatus;

    constructor(
        ICUCrowdsale _crowdsale,
        ICUToken _token,
        ICUStrategy _strategy
    ) public MintableCrowdsaleOnSuccessAgent(_crowdsale, _token) {
        require(address(_strategy) != address(0) && address(_crowdsale) != address(0));
        strategy = _strategy;
        crowdsale = _crowdsale;
    }

    /// @notice Takes actions on contribution
    function onContribution(
        address,
        uint256 _tierIndex,
        uint256 _tokens,
        uint256 _bonus
    ) public onlyCrowdsale() {
        strategy.updateTierState(_tierIndex, _tokens, _bonus);
    }

    function onStateChange(Crowdsale.State _state) public onlyCrowdsale() {
        ICUToken icuToken = ICUToken(token);
        if (
            icuToken.isSoftCapAchieved() == false
            && (_state == Crowdsale.State.Success || _state == Crowdsale.State.Finalized)
            && crowdsale.isSoftCapAchieved(0)
        ) {
            icuToken.setIsSoftCapAchieved();
        }

        if (_state > Crowdsale.State.InCrowdsale && burnStatus == false) {
            uint256 unsoldTokensAmount = strategy.getUnsoldTokens();

            burnStatus = true;

            icuToken.burnUnsoldTokens(unsoldTokensAmount);
        }

    }

    function onRefund(address _contributor, uint256 _tokens) public onlyCrowdsale() returns (uint256 burned) {
        burned = ICUToken(token).burnByAgent(_contributor, _tokens);
    }

    function updateLockPeriod(uint256 _time) public {
        require(msg.sender == address(strategy));
        ICUToken(token).setUnlockTime(_time);
    }

}
/// @title TokenAllocator
/// @author Applicature
/// @notice Contract responsible for defining distribution logic of tokens.
/// @dev Base class
contract TokenAllocator is Ownable {


    mapping(address => bool) public crowdsales;

    modifier onlyCrowdsale() {
        require(crowdsales[msg.sender]);
        _;
    }

    function addCrowdsales(address _address) public onlyOwner {
        crowdsales[_address] = true;
    }

    function removeCrowdsales(address _address) public onlyOwner {
        crowdsales[_address] = false;
    }

    function isInitialized() public view returns (bool) {
        return false;
    }

    function allocate(address _holder, uint256 _tokens) public onlyCrowdsale() {
        internalAllocate(_holder, _tokens);
    }

    function tokensAvailable() public view returns (uint256);

    function internalAllocate(address _holder, uint256 _tokens) internal onlyCrowdsale();
}
/// @title MintableTokenAllocator
/// @author Applicature
/// @notice Contract responsible for defining distribution logic of tokens.
/// @dev implementation
contract MintableTokenAllocator is TokenAllocator {

    using SafeMath for uint256;

    MintableToken public token;

    constructor(MintableToken _token) public {
        require(address(0) != address(_token));
        token = _token;
    }

    /// @notice update instance of MintableToken
    function setToken(MintableToken _token) public onlyOwner {
        token = _token;
    }

    function internalAllocate(address _holder, uint256 _tokens) internal {
        token.mint(_holder, _tokens);
    }

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public view returns (bool) {
        return token.mintingAgents(this);
    }

    /// @return available tokens
    function tokensAvailable() public view returns (uint256) {
        return token.availableTokens();
    }

}
/// @title ContributionForwarder
/// @author Applicature
/// @notice Contract is responsible for distributing collected ethers, that are received from CrowdSale.
/// @dev Base class
contract ContributionForwarder {

    using SafeMath for uint256;

    uint256 public weiCollected;
    uint256 public weiForwarded;

    event ContributionForwarded(address receiver, uint256 weiAmount);

    function isInitialized() public view returns (bool) {
        return false;
    }

    /// @notice transfer wei to receiver
    function forward() public payable {
        require(msg.value > 0);

        weiCollected += msg.value;

        internalForward();
    }

    function internalForward() internal;
}
/// @title DistributedDirectContributionForwarder
/// @author Applicature
/// @notice Contract is responsible for distributing collected ethers, that are received from CrowdSale.
/// @dev implementation
contract DistributedDirectContributionForwarder is ContributionForwarder {
    Receiver[] public receivers;
    uint256 public proportionAbsMax;
    bool public isInitialized_;

    struct Receiver {
        address receiver;
        uint256 proportion; // abslolute value in range of 0 - proportionAbsMax
        uint256 forwardedWei;
    }

    constructor(uint256 _proportionAbsMax, address[] _receivers, uint256[] _proportions) public {
        proportionAbsMax = _proportionAbsMax;

        require(_receivers.length == _proportions.length);

        require(_receivers.length > 0);

        uint256 totalProportion;

        for (uint256 i = 0; i < _receivers.length; i++) {
            uint256 proportion = _proportions[i];

            totalProportion = totalProportion.add(proportion);

            receivers.push(Receiver(_receivers[i], proportion, 0));
        }

        require(totalProportion == proportionAbsMax);
        isInitialized_ = true;
    }

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public view returns (bool) {
        return isInitialized_;
    }

    function internalForward() internal {
        uint256 transferred;

        for (uint256 i = 0; i < receivers.length; i++) {
            Receiver storage receiver = receivers[i];

            uint256 value = msg.value.mul(receiver.proportion).div(proportionAbsMax);

            if (i == receivers.length - 1) {
                value = msg.value.sub(transferred);
            }

            transferred = transferred.add(value);

            receiver.receiver.transfer(value);

            emit ContributionForwarded(receiver.receiver, value);
        }

        weiForwarded = weiForwarded.add(transferred);
    }
}
contract Crowdsale {

    uint256 public tokensSold;

    enum State {Unknown, Initializing, BeforeCrowdsale, InCrowdsale, Success, Finalized, Refunding}

    function externalContribution(address _contributor, uint256 _wei) public payable;

    function contribute(uint8 _v, bytes32 _r, bytes32 _s) public payable;

    function getState() public view returns (State);

    function updateState() public;

    function internalContribution(address _contributor, uint256 _wei) internal;

}
/// @title Crowdsale
/// @author Applicature
/// @notice Contract is responsible for collecting, refunding, allocating tokens during different stages of Crowdsale.
contract CrowdsaleImpl is Crowdsale, Ownable {

    using SafeMath for uint256;

    State public currentState;
    TokenAllocator public allocator;
    ContributionForwarder public contributionForwarder;
    PricingStrategy public pricingStrategy;
    CrowdsaleAgent public crowdsaleAgent;
    bool public finalized;
    uint256 public startDate;
    uint256 public endDate;
    bool public allowWhitelisted;
    bool public allowSigned;
    bool public allowAnonymous;
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public signers;
    mapping(address => bool) public externalContributionAgents;

    event Contribution(address _contributor, uint256 _wei, uint256 _tokensExcludingBonus, uint256 _bonus);

    constructor(
        TokenAllocator _allocator,
        ContributionForwarder _contributionForwarder,
        PricingStrategy _pricingStrategy,
        uint256 _startDate,
        uint256 _endDate,
        bool _allowWhitelisted,
        bool _allowSigned,
        bool _allowAnonymous
    ) public {
        allocator = _allocator;
        contributionForwarder = _contributionForwarder;
        pricingStrategy = _pricingStrategy;

        startDate = _startDate;
        endDate = _endDate;

        allowWhitelisted = _allowWhitelisted;
        allowSigned = _allowSigned;
        allowAnonymous = _allowAnonymous;

        currentState = State.Unknown;
    }

    /// @notice default payable function
    function() public payable {
        require(allowWhitelisted || allowAnonymous);

        if (!allowAnonymous) {
            if (allowWhitelisted) {
                require(whitelisted[msg.sender]);
            }
        }

        internalContribution(msg.sender, msg.value);
    }

    /// @notice update crowdsale agent
    function setCrowdsaleAgent(CrowdsaleAgent _crowdsaleAgent) public onlyOwner {
        require(address(_crowdsaleAgent) != address(0));
        crowdsaleAgent = _crowdsaleAgent;
    }

    /// @notice allows external user to do contribution
    function externalContribution(address _contributor, uint256 _wei) public payable {
        require(externalContributionAgents[msg.sender]);
        internalContribution(_contributor, _wei);
    }

    /// @notice update external contributor
    function addExternalContributor(address _contributor) public onlyOwner {
        externalContributionAgents[_contributor] = true;
    }

    /// @notice update external contributor
    function removeExternalContributor(address _contributor) public onlyOwner {
        externalContributionAgents[_contributor] = false;
    }

    /// @notice update whitelisting address
    function updateWhitelist(address _address, bool _status) public onlyOwner {
        whitelisted[_address] = _status;
    }

    /// @notice update signer
    function addSigner(address _signer) public onlyOwner {
        signers[_signer] = true;
    }

    /// @notice update signer
    function removeSigner(address _signer) public onlyOwner {
        signers[_signer] = false;
    }

    /// @notice allows to do signed contributions
    function contribute(uint8 _v, bytes32 _r, bytes32 _s) public payable {
        address recoveredAddress = verify(msg.sender, _v, _r, _s);
        require(signers[recoveredAddress]);
        internalContribution(msg.sender, msg.value);
    }

    /// @notice check sign
    function verify(address _sender, uint8 _v, bytes32 _r, bytes32 _s) public view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(this, _sender));

        bytes memory prefix = '\x19Ethereum Signed Message:\n32';

        return ecrecover(keccak256(abi.encodePacked(prefix, hash)), _v, _r, _s);
    }

    /// @return Crowdsale state
    function getState() public view returns (State) {
        if (finalized) {
            return State.Finalized;
        } else if (allocator.isInitialized() == false) {
            return State.Initializing;
        } else if (contributionForwarder.isInitialized() == false) {
            return State.Initializing;
        } else if (pricingStrategy.isInitialized() == false) {
            return State.Initializing;
        } else if (block.timestamp < startDate) {
            return State.BeforeCrowdsale;
        } else if (block.timestamp >= startDate && block.timestamp <= endDate) {
            return State.InCrowdsale;
        } else if (block.timestamp > endDate) {
            return State.Success;
        }

        return State.Unknown;
    }

    /// @notice Crowdsale state
    function updateState() public {
        State state = getState();

        if (currentState != state) {
            if (crowdsaleAgent != address(0)) {
                crowdsaleAgent.onStateChange(state);
            }

            currentState = state;
        }
    }

    function internalContribution(address _contributor, uint256 _wei) internal {
        require(getState() == State.InCrowdsale);

        uint256 tokensAvailable = allocator.tokensAvailable();
        uint256 collectedWei = contributionForwarder.weiCollected();

        uint256 tokens;
        uint256 tokensExcludingBonus;
        uint256 bonus;

        (tokens, tokensExcludingBonus, bonus) = pricingStrategy.getTokens(
            _contributor, tokensAvailable, tokensSold, _wei, collectedWei);

        require(tokens > 0 && tokens <= tokensAvailable);
        tokensSold = tokensSold.add(tokens);

        allocator.allocate(_contributor, tokens);

        if (msg.value > 0) {
            contributionForwarder.forward.value(msg.value)();
        }

        emit Contribution(_contributor, _wei, tokensExcludingBonus, bonus);
    }

}
/// @title HardCappedCrowdsale
/// @author Applicature
/// @notice Contract is responsible for collecting, refunding, allocating tokens during different stages of Crowdsale.
/// with hard limit
contract HardCappedCrowdsale is CrowdsaleImpl {

    using SafeMath for uint256;

    uint256 public hardCap;

    constructor(
        TokenAllocator _allocator,
        ContributionForwarder _contributionForwarder,
        PricingStrategy _pricingStrategy,
        uint256 _startDate,
        uint256 _endDate,
        bool _allowWhitelisted,
        bool _allowSigned,
        bool _allowAnonymous,
        uint256 _hardCap
    ) public CrowdsaleImpl(
        _allocator,
        _contributionForwarder,
        _pricingStrategy,
        _startDate,
        _endDate,
        _allowWhitelisted,
        _allowSigned,
        _allowAnonymous
    ) {
        hardCap = _hardCap;
    }

    /// @return Crowdsale state
    function getState() public view returns (State) {
        State state = super.getState();

        if (state == State.InCrowdsale) {
            if (isHardCapAchieved(0)) {
                return State.Success;
            }
        }

        return state;
    }

    function isHardCapAchieved(uint256 _value) public view returns (bool) {
        if (hardCap <= tokensSold.add(_value)) {
            return true;
        }
        return false;
    }

    function internalContribution(address _contributor, uint256 _wei) internal {
        require(getState() == State.InCrowdsale);

        uint256 tokensAvailable = allocator.tokensAvailable();
        uint256 collectedWei = contributionForwarder.weiCollected();

        uint256 tokens;
        uint256 tokensExcludingBonus;
        uint256 bonus;

        (tokens, tokensExcludingBonus, bonus) = pricingStrategy.getTokens(
            _contributor, tokensAvailable, tokensSold, _wei, collectedWei);

        require(tokens <= tokensAvailable && tokens > 0 && false == isHardCapAchieved(tokens.sub(1)));

        tokensSold = tokensSold.add(tokens);

        allocator.allocate(_contributor, tokens);

        if (msg.value > 0) {
            contributionForwarder.forward.value(msg.value)();
        }
        crowdsaleAgent.onContribution(_contributor, _wei, tokensExcludingBonus, bonus);
        emit Contribution(_contributor, _wei, tokensExcludingBonus, bonus);
    }
}
/// @title RefundableCrowdsale
/// @author Applicature
/// @notice Contract is responsible for collecting, refunding, allocating tokens during different stages of Crowdsale.
/// with hard and soft limits
contract RefundableCrowdsale is HardCappedCrowdsale {

    using SafeMath for uint256;

    uint256 public softCap;
    mapping(address => uint256) public contributorsWei;
    address[] public contributors;

    event Refund(address _holder, uint256 _wei, uint256 _tokens);

    constructor(
        TokenAllocator _allocator,
        ContributionForwarder _contributionForwarder,
        PricingStrategy _pricingStrategy,
        uint256 _startDate,
        uint256 _endDate,
        bool _allowWhitelisted,
        bool _allowSigned,
        bool _allowAnonymous,
        uint256 _softCap,
        uint256 _hardCap

    ) public HardCappedCrowdsale(
        _allocator, _contributionForwarder, _pricingStrategy,
        _startDate, _endDate,
        _allowWhitelisted, _allowSigned, _allowAnonymous, _hardCap
    ) {
        softCap = _softCap;
    }

    /// @return Crowdsale state
    function getState() public view returns (State) {
        State state = super.getState();

        if (state == State.Success) {
            if (!isSoftCapAchieved(0)) {
                return State.Refunding;
            }
        }

        return state;
    }

    function isSoftCapAchieved(uint256 _value) public view returns (bool) {
        if (softCap <= tokensSold.add(_value)) {
            return true;
        }
        return false;
    }

    /// @notice refund ethers to contributor
    function refund() public {
        internalRefund(msg.sender);
    }

    /// @notice refund ethers to delegate
    function delegatedRefund(address _address) public {
        internalRefund(_address);
    }

    function internalContribution(address _contributor, uint256 _wei) internal {
        require(block.timestamp >= startDate && block.timestamp <= endDate);

        uint256 tokensAvailable = allocator.tokensAvailable();
        uint256 collectedWei = contributionForwarder.weiCollected();

        uint256 tokens;
        uint256 tokensExcludingBonus;
        uint256 bonus;

        (tokens, tokensExcludingBonus, bonus) = pricingStrategy.getTokens(
            _contributor, tokensAvailable, tokensSold, _wei, collectedWei);

        require(tokens <= tokensAvailable && tokens > 0 && hardCap > tokensSold.add(tokens));

        tokensSold = tokensSold.add(tokens);

        allocator.allocate(_contributor, tokens);

        // transfer only if softcap is reached
        if (isSoftCapAchieved(0)) {
            if (msg.value > 0) {
                contributionForwarder.forward.value(address(this).balance)();
            }
        } else {
            // store contributor if it is not stored before
            if (contributorsWei[_contributor] == 0) {
                contributors.push(_contributor);
            }
            contributorsWei[_contributor] = contributorsWei[_contributor].add(msg.value);
        }
        crowdsaleAgent.onContribution(_contributor, _wei, tokensExcludingBonus, bonus);
        emit Contribution(_contributor, _wei, tokensExcludingBonus, bonus);
    }

    function internalRefund(address _holder) internal {
        updateState();
        require(block.timestamp > endDate);
        require(!isSoftCapAchieved(0));
        require(crowdsaleAgent != address(0));

        uint256 value = contributorsWei[_holder];

        require(value > 0);

        contributorsWei[_holder] = 0;
        uint256 burnedTokens = crowdsaleAgent.onRefund(_holder, 0);

        _holder.transfer(value);

        emit Refund(_holder, value, burnedTokens);
    }
}
contract ICUCrowdsale is RefundableCrowdsale {

    uint256 public maxSaleSupply = 2350000000e18;

    uint256 public availableBonusAmount = 447500000e18;

    uint256 public usdCollected;

    mapping(address => uint256) public contributorBonuses;

    constructor(
        MintableTokenAllocator _allocator,
        DistributedDirectContributionForwarder _contributionForwarder,
        ICUStrategy _pricingStrategy,
        uint256 _startTime,
        uint256 _endTime
    ) public RefundableCrowdsale(
        _allocator,
        _contributionForwarder,
        _pricingStrategy,
        _startTime,
        _endTime,
        true,
        true,
        false,
        2500000e5, //softCap
        23500000e5//hardCap
    ) {}

    function updateState() public {
        (startDate, endDate) = ICUStrategy(pricingStrategy).getActualDates();
        super.updateState();
    }

    function claimBonuses() public {
        require(isSoftCapAchieved(0) && contributorBonuses[msg.sender] > 0);

        uint256 bonus = contributorBonuses[msg.sender];
        contributorBonuses[msg.sender] = 0;
        allocator.allocate(msg.sender, bonus);
    }

    function addExternalContributor(address) public onlyOwner {
        require(false);
    }

    function isHardCapAchieved(uint256 _value) public view returns (bool) {
        if (hardCap <= usdCollected.add(_value)) {
            return true;
        }
        return false;
    }

    function isSoftCapAchieved(uint256 _value) public view returns (bool) {
        if (softCap <= usdCollected.add(_value)) {
            return true;
        }
        return false;
    }

    function internalContribution(address _contributor, uint256 _wei) internal {
        updateState();
        require(currentState == State.InCrowdsale);

        ICUStrategy pricing = ICUStrategy(pricingStrategy);
        uint256 usdAmount = pricing.getUSDAmount(_wei);
        require(!isHardCapAchieved(usdAmount.sub(1)));

        uint256 tokensAvailable = allocator.tokensAvailable();
        uint256 collectedWei = contributionForwarder.weiCollected();
        uint256 tierIndex = pricing.getTierIndex();
        uint256 tokens;
        uint256 tokensExcludingBonus;
        uint256 bonus;

        (tokens, tokensExcludingBonus, bonus) = pricing.getTokens(
            _contributor, tokensAvailable, tokensSold, _wei, collectedWei
        );

        require(tokens > 0);
        tokensSold = tokensSold.add(tokens);
        allocator.allocate(_contributor, tokensExcludingBonus);

        if (isSoftCapAchieved(usdAmount)) {
            if (msg.value > 0) {
                contributionForwarder.forward.value(address(this).balance)();
            }
        } else {
            // store contributor if it is not stored before
            if (contributorsWei[_contributor] == 0) {
                contributors.push(_contributor);
            }
            contributorsWei[_contributor] = contributorsWei[_contributor].add(msg.value);
        }

        usdCollected = usdCollected.add(usdAmount);

        if (availableBonusAmount > 0) {
            if (availableBonusAmount >= bonus) {
                availableBonusAmount -= bonus;
            } else {
                bonus = availableBonusAmount;
                availableBonusAmount = 0;
            }
            contributorBonuses[_contributor] = contributorBonuses[_contributor].add(bonus);
        } else {
            bonus = 0;
        }

        crowdsaleAgent.onContribution(pricing, tierIndex, tokensExcludingBonus, bonus);
        emit Contribution(_contributor, _wei, tokensExcludingBonus, bonus);
    }

}
/// @title PricingStrategy
/// @author Applicature
/// @notice Contract is responsible for calculating tokens amount depending on different criterias
/// @dev Base class
contract PricingStrategy {

    function isInitialized() public view returns (bool);

    function getTokens(
        address _contributor,
        uint256 _tokensAvailable,
        uint256 _tokensSold,
        uint256 _weiAmount,
        uint256 _collectedWei
    )
        public
        view
        returns (uint256 tokens, uint256 tokensExludingBonus, uint256 bonus);

    function getWeis(
        uint256 _collectedWei,
        uint256 _tokensSold,
        uint256 _tokens
    )
        public
        view
        returns (uint256 weiAmount, uint256 tokensBonus);
}
/// @title TokenDateCappedTiersPricingStrategy
/// @author Applicature
/// @notice Contract is responsible for calculating tokens amount depending on price in USD
/// @dev implementation
contract TokenDateCappedTiersPricingStrategy is PricingStrategy, Ownable {

    using SafeMath for uint256;

    uint256 public etherPriceInUSD;

    uint256 public capsAmount;

    struct Tier {
        uint256 tokenInUSD;
        uint256 maxTokensCollected;
        uint256 soldTierTokens;
        uint256 bonusTierTokens;
        uint256 discountPercents;
        uint256 minInvestInUSD;
        uint256 startDate;
        uint256 endDate;
        bool unsoldProcessed;
        uint256[] capsData;
    }

    Tier[] public tiers;
    uint256 public decimals;

    constructor(
        uint256[] _tiers,
        uint256[] _capsData,
        uint256 _decimals,
        uint256 _etherPriceInUSD
    )
        public
    {
        decimals = _decimals;
        require(_etherPriceInUSD > 0);
        etherPriceInUSD = _etherPriceInUSD;

        require(_tiers.length % 6 == 0);
        uint256 length = _tiers.length / 6;

        require(_capsData.length % 2 == 0);
        uint256 lengthCaps = _capsData.length / 2;

        uint256[] memory emptyArray;

        for (uint256 i = 0; i < length; i++) {
            tiers.push(
                Tier(
                    _tiers[i * 6],//tokenInUSD
                    _tiers[i * 6 + 1],//maxTokensCollected
                    0,//soldTierTokens
                    0,//bonusTierTokens
                    _tiers[i * 6 + 2],//discountPercents
                    _tiers[i * 6 + 3],//minInvestInUSD
                    _tiers[i * 6 + 4],//startDate
                    _tiers[i * 6 + 5],//endDate
                    false,
                    emptyArray//capsData
                )
            );

            for (uint256 j = 0; j < lengthCaps; j++) {
                tiers[i].capsData.push(_capsData[i * lengthCaps + j]);
            }
        }
    }

    /// @return tier index
    function getTierIndex() public view returns (uint256) {
        for (uint256 i = 0; i < tiers.length; i++) {
            if (
                block.timestamp >= tiers[i].startDate &&
                block.timestamp < tiers[i].endDate &&
                tiers[i].maxTokensCollected > tiers[i].soldTierTokens
            ) {
                return i;
            }
        }

        return tiers.length;
    }

    function getActualTierIndex() public view returns (uint256) {
        for (uint256 i = 0; i < tiers.length; i++) {
            if (
                block.timestamp >= tiers[i].startDate
                && block.timestamp < tiers[i].endDate
                && tiers[i].maxTokensCollected > tiers[i].soldTierTokens
                || block.timestamp < tiers[i].startDate
            ) {
                return i;
            }
        }

        return tiers.length.sub(1);
    }

    /// @return actual dates
    function getActualDates() public view returns (uint256 startDate, uint256 endDate) {
        uint256 tierIndex = getActualTierIndex();
        startDate = tiers[tierIndex].startDate;
        endDate = tiers[tierIndex].endDate;
    }

    function getTokensWithoutRestrictions(uint256 _weiAmount) public view returns (
        uint256 tokens,
        uint256 tokensExcludingBonus,
        uint256 bonus
    ) {
        if (_weiAmount == 0) {
            return (0, 0, 0);
        }

        uint256 tierIndex = getActualTierIndex();

        tokensExcludingBonus = _weiAmount.mul(etherPriceInUSD).div(getTokensInUSD(tierIndex));
        bonus = calculateBonusAmount(tierIndex, tokensExcludingBonus);
        tokens = tokensExcludingBonus.add(bonus);
    }

    /// @return tokens based on sold tokens and wei amount
    function getTokens(
        address,
        uint256 _tokensAvailable,
        uint256,
        uint256 _weiAmount,
        uint256
    ) public view returns (uint256 tokens, uint256 tokensExcludingBonus, uint256 bonus) {
        if (_weiAmount == 0) {
            return (0, 0, 0);
        }

        uint256 tierIndex = getTierIndex();
        if (tierIndex == tiers.length || _weiAmount.mul(etherPriceInUSD).div(1e18) < tiers[tierIndex].minInvestInUSD) {
            return (0, 0, 0);
        }

        tokensExcludingBonus = _weiAmount.mul(etherPriceInUSD).div(getTokensInUSD(tierIndex));

        if (tiers[tierIndex].maxTokensCollected < tiers[tierIndex].soldTierTokens.add(tokensExcludingBonus)) {
            return (0, 0, 0);
        }

        bonus = calculateBonusAmount(tierIndex, tokensExcludingBonus);
        tokens = tokensExcludingBonus.add(bonus);

        if (tokens > _tokensAvailable) {
            return (0, 0, 0);
        }
    }

    /// @return weis based on sold and required tokens
    function getWeis(
        uint256,
        uint256,
        uint256 _tokens
    ) public view returns (uint256 totalWeiAmount, uint256 tokensBonus) {
        if (_tokens == 0) {
            return (0, 0);
        }

        uint256 tierIndex = getTierIndex();
        if (tierIndex == tiers.length) {
            return (0, 0);
        }
        if (tiers[tierIndex].maxTokensCollected < tiers[tierIndex].soldTierTokens.add(_tokens)) {
            return (0, 0);
        }
        uint256 usdAmount = _tokens.mul(getTokensInUSD(tierIndex)).div(1e18);
        totalWeiAmount = usdAmount.mul(1e18).div(etherPriceInUSD);

        if (totalWeiAmount < uint256(1 ether).mul(tiers[tierIndex].minInvestInUSD).div(etherPriceInUSD)) {
            return (0, 0);
        }

        tokensBonus = calculateBonusAmount(tierIndex, _tokens);
    }

    function calculateBonusAmount(uint256 _tierIndex, uint256 _tokens) public view returns (uint256 bonus) {
        uint256 length = tiers[_tierIndex].capsData.length.div(2);

        uint256 remainingTokens = _tokens;
        uint256 newSoldTokens = tiers[_tierIndex].soldTierTokens;

        for (uint256 i = 0; i < length; i++) {
            if (tiers[_tierIndex].capsData[i.mul(2)] == 0) {
                break;
            }
            if (newSoldTokens.add(remainingTokens) <= tiers[_tierIndex].capsData[i.mul(2)]) {
                bonus += remainingTokens.mul(tiers[_tierIndex].capsData[i.mul(2).add(1)]).div(100);
                break;
            } else {
                uint256 diff = tiers[_tierIndex].capsData[i.mul(2)].sub(newSoldTokens);
                remainingTokens -= diff;
                newSoldTokens += diff;
                bonus += diff.mul(tiers[_tierIndex].capsData[i.mul(2).add(1)]).div(100);
            }
        }
    }

    function getTokensInUSD(uint256 _tierIndex) public view returns (uint256) {
        if (_tierIndex < uint256(tiers.length)) {
            return tiers[_tierIndex].tokenInUSD;
        }
    }

    function getDiscount(uint256 _tierIndex) public view returns (uint256) {
        if (_tierIndex < uint256(tiers.length)) {
            return tiers[_tierIndex].discountPercents;
        }
    }

    function getMinEtherInvest(uint256 _tierIndex) public view returns (uint256) {
        if (_tierIndex < uint256(tiers.length)) {
            return tiers[_tierIndex].minInvestInUSD.mul(1 ether).div(etherPriceInUSD);
        }
    }

    function getUSDAmount(uint256 _weiAmount) public view returns (uint256) {
        return _weiAmount.mul(etherPriceInUSD).div(1 ether);
    }

    /// @notice Check whether contract is initialised
    /// @return true if initialized
    function isInitialized() public view returns (bool) {
        return true;
    }

    /// @notice updates tier start/end dates by id
    function updateDates(uint8 _tierId, uint256 _start, uint256 _end) public onlyOwner() {
        if (_start != 0 && _start < _end && _tierId < tiers.length) {
            Tier storage tier = tiers[_tierId];
            tier.startDate = _start;
            tier.endDate = _end;
        }
    }
}
contract ICUStrategy is TokenDateCappedTiersPricingStrategy {

    ICUAgent public agent;

    event UnsoldTokensProcessed(uint256 fromTier, uint256 toTier, uint256 tokensAmount);

    constructor(
        uint256[] _emptyArray,
        uint256 _etherPriceInUSD
    ) public TokenDateCappedTiersPricingStrategy(
        _emptyArray,
        _emptyArray,
        18,
        _etherPriceInUSD
    ) {
        //Pre-ICO
        tiers.push(
            Tier(
                0.01e5,//tokenInUSD
                1000000000e18,//maxTokensCollected
                0,//soldTierTokens
                0,//bonusTierTokens
                0,//discountPercents
                uint256(20).mul(_etherPriceInUSD),//minInvestInUSD | 20 ethers
                1543579200,//startDate | 2018/11/30 12:00:00 PM UTC
                1544184000,//endDate | 2018/12/07 12:00:00 PM UTC
                false,
                _emptyArray
            )
        );
        //ICO
        tiers.push(
            Tier(
                0.01e5,//tokenInUSD
                1350000000e18,//maxTokensCollected
                0,//soldTierTokens
                0,//bonusTierTokens
                0,//discountPercents
                uint256(_etherPriceInUSD).div(10),//minInvestInUSD | 0.1 ether
                1544443200,//startDate | 2018/12/10	12:00:00 PM UTC
                1546257600,//endDate | 2018/12/31 12:00:00 PM UTC
                false,
                _emptyArray
            )
        );

        //Pre-ICO caps data
        tiers[0].capsData.push(1000000000e18);//cap $10,000,000 in tokens
        tiers[0].capsData.push(30);//bonus percents

        //ICO caps data
        tiers[1].capsData.push(400000000e18);//cap $4,000,000 in tokens
        tiers[1].capsData.push(20);//bonus percents

        tiers[1].capsData.push(800000000e18);//cap $4,000,000 in tokens
        tiers[1].capsData.push(10);//bonus percents

        tiers[1].capsData.push(1350000000e18);//cap $5,500,000 in tokens
        tiers[1].capsData.push(5);//bonus percents

    }

    function getArrayOfTiers() public view returns (uint256[14] tiersData) {
        uint256 j = 0;
        for (uint256 i = 0; i < tiers.length; i++) {
            tiersData[j++] = uint256(tiers[i].tokenInUSD);
            tiersData[j++] = uint256(tiers[i].maxTokensCollected);
            tiersData[j++] = uint256(tiers[i].soldTierTokens);
            tiersData[j++] = uint256(tiers[i].discountPercents);
            tiersData[j++] = uint256(tiers[i].minInvestInUSD);
            tiersData[j++] = uint256(tiers[i].startDate);
            tiersData[j++] = uint256(tiers[i].endDate);
        }
    }

    function updateTier(
        uint256 _tierId,
        uint256 _start,
        uint256 _end,
        uint256 _minInvest,
        uint256 _price,
        uint256 _discount,
        uint256[] _capsData,
        bool updateLockNeeded
    ) public onlyOwner() {
        require(
            _start != 0 &&
            _price != 0 &&
            _start < _end &&
            _tierId < tiers.length &&
            _capsData.length > 0 &&
            _capsData.length % 2 == 0
        );

        if (updateLockNeeded) {
            agent.updateLockPeriod(_end);
        }

        Tier storage tier = tiers[_tierId];
        tier.tokenInUSD = _price;
        tier.discountPercents = _discount;
        tier.minInvestInUSD = _minInvest;
        tier.startDate = _start;
        tier.endDate = _end;
        tier.capsData = _capsData;
    }

    function setCrowdsaleAgent(ICUAgent _crowdsaleAgent) public onlyOwner {
        agent = _crowdsaleAgent;
    }

    function updateTierState(uint256 _tierId, uint256 _soldTokens, uint256 _bonusTokens) public {
        require(
            msg.sender == address(agent) &&
            _tierId < tiers.length &&
            _soldTokens > 0
        );

        Tier storage tier = tiers[_tierId];

        if (_tierId > 0 && !tiers[_tierId.sub(1)].unsoldProcessed) {
            Tier storage prevTier = tiers[_tierId.sub(1)];
            prevTier.unsoldProcessed = true;

            uint256 unsold = prevTier.maxTokensCollected.sub(prevTier.soldTierTokens);
            tier.maxTokensCollected = tier.maxTokensCollected.add(unsold);
            tier.capsData[0] = tier.capsData[0].add(unsold);

            emit UnsoldTokensProcessed(_tierId.sub(1), _tierId, unsold);
        }

        tier.soldTierTokens = tier.soldTierTokens.add(_soldTokens);
        tier.bonusTierTokens = tier.bonusTierTokens.add(_bonusTokens);
    }

    function getTierUnsoldTokens(uint256 _tierId) public view returns (uint256) {
        if (_tierId >= tiers.length || tiers[_tierId].unsoldProcessed) {
            return 0;
        }

        return tiers[_tierId].maxTokensCollected.sub(tiers[_tierId].soldTierTokens);
    }

    function getUnsoldTokens() public view returns (uint256 unsoldTokens) {
        for (uint256 i = 0; i < tiers.length; i++) {
            unsoldTokens += getTierUnsoldTokens(i);
        }
    }

    function getCapsData(uint256 _tierId) public view returns (uint256[]) {
        if (_tierId < tiers.length) {
            return tiers[_tierId].capsData;
        }
    }

}
contract Referral is Ownable {

    using SafeMath for uint256;

    MintableTokenAllocator public allocator;
    CrowdsaleImpl public crowdsale;

    uint256 public constant DECIMALS = 18;

    uint256 public totalSupply;
    bool public unLimited;
    bool public sentOnce;

    mapping(address => bool) public claimed;
    mapping(address => uint256) public claimedBalances;

    constructor(
        uint256 _totalSupply,
        address _allocator,
        address _crowdsale,
        bool _sentOnce
    ) public {
        require(_allocator != address(0) && _crowdsale != address(0));
        totalSupply = _totalSupply;
        if (totalSupply == 0) {
            unLimited = true;
        }
        allocator = MintableTokenAllocator(_allocator);
        crowdsale = CrowdsaleImpl(_crowdsale);
        sentOnce = _sentOnce;
    }

    function setAllocator(address _allocator) public onlyOwner {
        require(_allocator != address(0));
        allocator = MintableTokenAllocator(_allocator);
    }

    function setCrowdsale(address _crowdsale) public onlyOwner {
        require(_crowdsale != address(0));
        crowdsale = CrowdsaleImpl(_crowdsale);
    }

    function multivestMint(
        address _address,
        uint256 _amount,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        require(true == crowdsale.signers(verify(msg.sender, _amount, _v, _r, _s)));
        if (true == sentOnce) {
            require(claimed[_address] == false);
            claimed[_address] = true;
        }
        require(
            _address == msg.sender &&
            _amount > 0 &&
            (true == unLimited || _amount <= totalSupply)
        );
        claimedBalances[_address] = claimedBalances[_address].add(_amount);
        if (false == unLimited) {
            totalSupply = totalSupply.sub(_amount);
        }
        allocator.allocate(_address, _amount);
    }

    /// @notice check sign
    function verify(address _sender, uint256 _amount, uint8 _v, bytes32 _r, bytes32 _s) public pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(_sender, _amount));

        bytes memory prefix = '\x19Ethereum Signed Message:\n32';

        return ecrecover(keccak256(abi.encodePacked(prefix, hash)), _v, _r, _s);
    }
}
contract ICUReferral is Referral {

    constructor(
        address _allocator,
        address _crowdsale
    ) public Referral(35000000e18, _allocator, _crowdsale, true) {}

    function multivestMint(
        address _address,
        uint256 _amount,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        ICUCrowdsale icuCrowdsale = ICUCrowdsale(crowdsale);
        icuCrowdsale.updateState();
        require(icuCrowdsale.isSoftCapAchieved(0) && block.timestamp > icuCrowdsale.endDate());
        super.multivestMint(_address, _amount, _v, _r, _s);
    }
}
contract Stats {

    using SafeMath for uint256;

    MintableToken public token;
    MintableTokenAllocator public allocator;
    ICUCrowdsale public crowdsale;
    ICUStrategy public pricing;

    constructor(
        MintableToken _token,
        MintableTokenAllocator _allocator,
        ICUCrowdsale _crowdsale,
        ICUStrategy _pricing
    ) public {
        token = _token;
        allocator = _allocator;
        crowdsale = _crowdsale;
        pricing = _pricing;
    }

    function getTokens(
        uint256,
        uint256 _weiAmount
    ) public view returns (uint256 tokens, uint256 tokensExcludingBonus, uint256 bonus) {
        return pricing.getTokensWithoutRestrictions(_weiAmount);
    }

    function getWeis(
        uint256,
        uint256 _tokenAmount
    ) public view returns (uint256 totalWeiAmount, uint256 tokensBonus) {
        return pricing.getWeis(0, 0, _tokenAmount);
    }

    function getStats(uint256 _userType, uint256[7] _ethPerCurrency) public view returns (
        uint256[8] stats,
        uint256[26] tiersData,
        uint256[21] currencyContr //tokensPerEachCurrency,
    ) {
        stats = getStatsData(_userType);
        tiersData = getTiersData(_userType);
        currencyContr = getCurrencyContrData(_userType, _ethPerCurrency);
    }

    function getTiersData(uint256) public view returns (
        uint256[26] tiersData
    ) {
        uint256[14] memory tiers = pricing.getArrayOfTiers();
        uint256 tierElements = tiers.length.div(2);
        uint256 j = 0;
        for (uint256 i = 0; i <= tierElements; i += tierElements) {
            tiersData[j++] = uint256(1e23).div(tiers[i]);// tokenInUSD;
            tiersData[j++] = 0;// tokenInWei;
            tiersData[j++] = uint256(tiers[i.add(1)]);// maxTokensCollected;
            tiersData[j++] = uint256(tiers[i.add(2)]);// soldTierTokens;
            tiersData[j++] = 0;// discountPercents;
            tiersData[j++] = 0;// bonusPercents;
            tiersData[j++] = uint256(tiers[i.add(4)]);// minInvestInUSD;
            tiersData[j++] = 0;// minInvestInWei;
            tiersData[j++] = 0;// maxInvestInUSD;
            tiersData[j++] = 0;// maxInvestInWei;
            tiersData[j++] = uint256(tiers[i.add(5)]);// startDate;
            tiersData[j++] = uint256(tiers[i.add(6)]);// endDate;
            tiersData[j++] = 1;
        }

        tiersData[25] = 2;
    }

    function getStatsData(uint256 _type) public view returns (
        uint256[8] stats
    ) {
        _type = _type;
        stats[0] = token.maxSupply();
        stats[1] = token.totalSupply();
        stats[2] = crowdsale.maxSaleSupply();
        stats[3] = crowdsale.tokensSold();
        stats[4] = uint256(crowdsale.currentState());
        stats[5] = pricing.getActualTierIndex();
        stats[6] = pricing.getTierUnsoldTokens(stats[5]);
        stats[7] = pricing.getMinEtherInvest(stats[5]);
    }

    function getCurrencyContrData(uint256 _type, uint256[7] _ethPerCurrency) public view returns (
        uint256[21] currencyContr
    ) {
        _type = _type;
        uint256 j = 0;
        for (uint256 i = 0; i < _ethPerCurrency.length; i++) {
            (currencyContr[j++], currencyContr[j++], currencyContr[j++]) = pricing.getTokensWithoutRestrictions(
                _ethPerCurrency[i]
            );
        }
    }

}
contract PeriodicTokenVesting is TokenVesting {
    address public unreleasedHolder;
    uint256 public periods;

    constructor(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _periods,
        bool _revocable,
        address _unreleasedHolder
    )
        public TokenVesting(_beneficiary, _start, _cliff, _duration, _revocable)
    {
        require(_revocable == false || _unreleasedHolder != address(0));
        periods = _periods;
        unreleasedHolder = _unreleasedHolder;
    }

    /**
    * @dev Calculates the amount that has already vested.
    * @param token ERC20 token which is being vested
    */
    function vestedAmount(ERC20Basic token) public view returns (uint256) {
        uint256 currentBalance = token.balanceOf(this);
        uint256 totalBalance = currentBalance.add(released[token]);

        if (now < cliff) {
            return 0;
        } else if (now >= start.add(duration * periods) || revoked[token]) {
            return totalBalance;
        } else {

            uint256 periodTokens = totalBalance.div(periods);

            uint256 periodsOver = now.sub(start).div(duration);

            if (periodsOver >= periods) {
                return totalBalance;
            }

            return periodTokens.mul(periodsOver);
        }
    }

    /**
 * @notice Allows the owner to revoke the vesting. Tokens already vested
 * remain in the contract, the rest are returned to the owner.
 * @param token ERC20 token which is being vested
 */
    function revoke(ERC20Basic token) public onlyOwner {
        require(revocable);
        require(!revoked[token]);

        uint256 balance = token.balanceOf(this);

        uint256 unreleased = releasableAmount(token);
        uint256 refund = balance.sub(unreleased);

        revoked[token] = true;

        token.safeTransfer(unreleasedHolder, refund);

        emit Revoked();
    }
}
contract ICUAllocation is Ownable {

    using SafeERC20 for ERC20Basic;
    using SafeMath for uint256;

    uint256 public constant BOUNTY_TOKENS = 47000000e18;
    uint256 public constant MAX_TREASURY_TOKENS = 2350000000e18;

    uint256 public icoEndTime;

    address[] public vestings;

    address public bountyAddress;

    address public treasuryAddress;

    bool public isBountySent;

    bool public isTeamSent;

    event VestingCreated(
        address _vesting,
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _periods,
        bool _revocable
    );

    event VestingRevoked(address _vesting);

    constructor(address _bountyAddress, address _treasuryAddress) public {
        require(_bountyAddress != address(0) && _treasuryAddress != address(0));
        bountyAddress = _bountyAddress;
        treasuryAddress = _treasuryAddress;
    }

    function setICOEndTime(uint256 _icoEndTime) public onlyOwner {
        icoEndTime = _icoEndTime;
    }

    function allocateBounty(MintableTokenAllocator _allocator, ICUCrowdsale _crowdsale) public onlyOwner {
        require(!isBountySent && icoEndTime < block.timestamp && _crowdsale.isSoftCapAchieved(0));

        isBountySent = true;
        _allocator.allocate(bountyAddress, BOUNTY_TOKENS);
    }

    function allocateTreasury(MintableTokenAllocator _allocator) public onlyOwner {
        require(icoEndTime < block.timestamp, 'ICO is not ended');
        require(isBountySent, 'Bounty is not sent');
        require(isTeamSent, 'Team vesting is not created');
        require(MAX_TREASURY_TOKENS >= _allocator.tokensAvailable(), 'Unsold tokens are not burned');

        _allocator.allocate(treasuryAddress, _allocator.tokensAvailable());
    }

    function createVesting(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _periods,
        bool _revocable,
        address _unreleasedHolder,
        MintableTokenAllocator _allocator,
        uint256 _amount
    ) public onlyOwner returns (PeriodicTokenVesting) {
        require(icoEndTime > 0 && _amount > 0);

        isTeamSent = true;

        PeriodicTokenVesting vesting = new PeriodicTokenVesting(
            _beneficiary, _start, _cliff, _duration, _periods, _revocable, _unreleasedHolder
        );

        vestings.push(vesting);

        emit VestingCreated(vesting, _beneficiary, _start, _cliff, _duration, _periods, _revocable);

        _allocator.allocate(address(vesting), _amount);

        return vesting;
    }

    function revokeVesting(PeriodicTokenVesting _vesting, ERC20Basic token) public onlyOwner() {
        _vesting.revoke(token);

        emit VestingRevoked(_vesting);
    }
}