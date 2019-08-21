pragma solidity 0.4.24;

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

contract ComponentContainerInterface {
    mapping (bytes32 => address) components;

    event ComponentUpdated (bytes32 _name, address _componentAddress);

    function setComponent(bytes32 _name, address _providerAddress) internal returns (bool success);
    function setComponents(bytes32[] _names, address[] _providerAddresses) internal returns (bool success);
    function getComponentByName(bytes32 name) public view returns (address);
    function getComponents(bytes32[] _names) internal view returns (address[]);

}

contract DerivativeInterface is  Ownable, ComponentContainerInterface {

    enum DerivativeStatus { New, Active, Paused, Closed }
    enum DerivativeType { Index, Fund, Future, BinaryFuture }

    string public description;
    bytes32 public category;

    bytes32 public version;
    DerivativeType public fundType;
    DerivativeStatus public status;


    function _initialize (address _componentList) internal;
    function updateComponent(bytes32 _name) public returns (address);
    function approveComponent(bytes32 _name) internal;


}

contract ComponentContainer is ComponentContainerInterface {

    function setComponent(bytes32 _name, address _componentAddress) internal returns (bool success) {
        require(_componentAddress != address(0));
        components[_name] = _componentAddress;
        return true;
    }

    function getComponentByName(bytes32 _name) public view returns (address) {
        return components[_name];
    }

    function getComponents(bytes32[] _names) internal view returns (address[]) {
        address[] memory addresses = new address[](_names.length);
        for (uint i = 0; i < _names.length; i++) {
            addresses[i] = getComponentByName(_names[i]);
        }

        return addresses;
    }

    function setComponents(bytes32[] _names, address[] _providerAddresses) internal returns (bool success) {
        require(_names.length == _providerAddresses.length);
        require(_names.length > 0);

        for (uint i = 0; i < _names.length; i++ ) {
            setComponent(_names[i], _providerAddresses[i]);
        }

        return true;
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

contract ERC20Extended is ERC20 {
    uint256 public decimals;
    string public name;
    string public symbol;

}

contract ComponentListInterface {
    event ComponentUpdated (bytes32 _name, string _version, address _componentAddress);
    function setComponent(bytes32 _name, address _componentAddress) public returns (bool);
    function getComponent(bytes32 _name, string _version) public view returns (address);
    function getLatestComponent(bytes32 _name) public view returns(address);
    function getLatestComponents(bytes32[] _names) public view returns(address[]);
}

contract ERC20NoReturn {
    uint256 public decimals;
    string public name;
    string public symbol;
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public;
    function approve(address spender, uint tokens) public;
    function transferFrom(address from, address to, uint tokens) public;

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract FeeChargerInterface {
    // TODO: change this to mainnet MOT address before deployment.
    // solhint-disable-next-line
    ERC20Extended public MOT = ERC20Extended(0x263c618480DBe35C300D8d5EcDA19bbB986AcaeD);
    // kovan MOT: 0x41Dee9F481a1d2AA74a3f1d0958C1dB6107c686A
    function setMotAddress(address _motAddress) external returns (bool success);
}

contract ComponentInterface {
    string public name;
    string public description;
    string public category;
    string public version;
}

contract WhitelistInterface is ComponentInterface {

    // sender -> category -> user -> allowed
    mapping (address => mapping(uint => mapping(address => bool))) public whitelist;
    // sender -> category -> enabled
    mapping (address => mapping(uint => bool)) public enabled;

    function setStatus(uint _key, bool enable) external;
    function isAllowed(uint _key, address _account) external view returns(bool);
    function setAllowed(address[] accounts, uint _key, bool allowed) external returns(bool);
}

contract RiskControlInterface is ComponentInterface {
    function hasRisk(address _sender, address _receiver, address _tokenAddress, uint _amount, uint _rate)
        external returns(bool isRisky);
}

contract LockerInterface {
    // Inside a require shall be performed
    function checkLockByBlockNumber(bytes32 _lockerName) external;

    function setBlockInterval(bytes32 _lockerName, uint _blocks) external;
    function setMultipleBlockIntervals(bytes32[] _lockerNames, uint[] _blocks) external;

    // Inside a require shall be performed
    function checkLockerByTime(bytes32 _timerName) external;

    function setTimeInterval(bytes32 _timerName, uint _seconds) external;
    function setMultipleTimeIntervals(bytes32[] _timerNames, uint[] _hours) external;

}

interface StepInterface {
    // Get number of max calls
    function getMaxCalls(bytes32 _category) external view returns(uint _maxCall);
    // Set the number of calls that one category can perform in a single transaction
    function setMaxCalls(bytes32 _category, uint _maxCallsList) external;
    // Set several max calls in a single transaction, saving trasnaction cost gas
    function setMultipleMaxCalls(bytes32[] _categories, uint[] _maxCalls) external;
    // This function initializes the piecemeal function. If it is already initialized, it will continue and return the currentFunctionStep of the status.
    function initializeOrContinue(bytes32 _category) external returns (uint _currentFunctionStep);
    // Return the current status of the piecemeal function. This status can be used to decide what can be done
    function getStatus(bytes32 _category) external view returns (uint _status);
    // Update the status to the following phase
    function updateStatus(bytes32 _category) external returns (uint _newStatus);
    // This function should always be called for each operation which is deemed to cost the gas.
    function goNextStep(bytes32 _category) external returns (bool _shouldCallAgain);
    // This function should always be called at the end of the function, when everything is done. This resets the variables to default state.
    function finalize(bytes32 _category) external returns (bool _success);
}

// Abstract class that implements the common functions to all our derivatives
contract Derivative is DerivativeInterface, ERC20Extended, ComponentContainer, PausableToken {

    ERC20Extended internal constant ETH = ERC20Extended(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    ComponentListInterface public componentList;
    bytes32 public constant MARKET = "MarketProvider";
    bytes32 public constant PRICE = "PriceProvider";
    bytes32 public constant EXCHANGE = "ExchangeProvider";
    bytes32 public constant WITHDRAW = "WithdrawProvider";
    bytes32 public constant WHITELIST = "WhitelistProvider";
    bytes32 public constant FEE = "FeeProvider";
    bytes32 public constant REIMBURSABLE = "Reimbursable";
    bytes32 public constant REBALANCE = "RebalanceProvider";
    bytes32 public constant STEP = "StepProvider";
    bytes32 public constant LOCKER = "LockerProvider";

    bytes32 public constant GETETH = "GetEth";

    uint public pausedTime;
    uint public pausedCycle;

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        pausedTime = now;
    }

    enum WhitelistKeys { Investment, Maintenance, Admin }

    mapping(bytes32 => bool) internal excludedComponents;

    modifier OnlyOwnerOrPausedTimeout() {
        require( (msg.sender == owner) || ( paused == true && (pausedTime+pausedCycle) <= now ) );
        _;
    }

    // If whitelist is disabled, that will become onlyOwner
    modifier onlyOwnerOrWhitelisted(WhitelistKeys _key) {
        WhitelistInterface whitelist = WhitelistInterface(getComponentByName(WHITELIST));
        require(
            msg.sender == owner ||
            (whitelist.enabled(address(this), uint(_key)) && whitelist.isAllowed(uint(_key), msg.sender) )
        );
        _;
    }

    // If whitelist is disabled, anyone can do this
    modifier whitelisted(WhitelistKeys _key) {
        require(WhitelistInterface(getComponentByName(WHITELIST)).isAllowed(uint(_key), msg.sender));
        _;
    }

    function _initialize (address _componentList) internal {
        require(_componentList != 0x0);
        componentList = ComponentListInterface(_componentList);
        excludedComponents[MARKET] = true;
        excludedComponents[STEP] = true;
        excludedComponents[LOCKER] = true;
    }

    function updateComponent(bytes32 _name) public onlyOwner returns (address) {
        // still latest.
        if (super.getComponentByName(_name) == componentList.getLatestComponent(_name)) {
            return super.getComponentByName(_name);
        }
        // Changed.
        require(super.setComponent(_name, componentList.getLatestComponent(_name)));
        // Check if approval is required
        if(!excludedComponents[_name]) {
            approveComponent(_name);
        }
        return super.getComponentByName(_name);
    }

    function approveComponent(bytes32 _name) internal {
        address componentAddress = getComponentByName(_name);
        ERC20NoReturn mot = ERC20NoReturn(FeeChargerInterface(componentAddress).MOT());
        mot.approve(componentAddress, 0);
        mot.approve(componentAddress, 2 ** 256 - 1);
    }

    function () public payable {

    }

    function setMultipleTimeIntervals(bytes32[] _timerNames, uint[] _secondsList) public onlyOwner{
        LockerInterface(getComponentByName(LOCKER)).setMultipleTimeIntervals(_timerNames, _secondsList);
    }

    function setMaxSteps(bytes32 _category, uint _maxSteps) public onlyOwner {
        StepInterface(getComponentByName(STEP)).setMaxCalls(_category, _maxSteps);
    }
}

contract ERC20PriceInterface {
    function getPrice() public view returns(uint);
    function getETHBalance() public view returns(uint);
}

contract IndexInterface is DerivativeInterface,  ERC20PriceInterface {

    address[] public tokens;
    uint[] public weights;
    bool public supportRebalance;


    function invest() public payable returns(bool success);

    // this should be called until it returns true.
    function rebalance() public returns (bool success);
    function getTokens() public view returns (address[] _tokens, uint[] _weights);
    function buyTokens() external returns(bool);
}

contract ExchangeInterface is ComponentInterface {
    /*
     * @dev Checks if a trading pair is available
     * For ETH, use 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
     * @param address _sourceAddress The token to sell for the destAddress.
     * @param address _destAddress The token to buy with the source token.
     * @param bytes32 _exchangeId The exchangeId to choose. If it's an empty string, then the exchange will be chosen automatically.
     * @return boolean whether or not the trading pair is supported by this exchange provider
     */
    function supportsTradingPair(address _srcAddress, address _destAddress, bytes32 _exchangeId)
        external view returns(bool supported);

    /*
     * @dev Buy a single token with ETH.
     * @param ERC20Extended _token The token to buy, should be an ERC20Extended address.
     * @param uint _amount Amount of ETH used to buy this token. Make sure the value sent to this function is the same as the _amount.
     * @param uint _minimumRate The minimum amount of tokens to receive for 1 ETH.
     * @param address _depositAddress The address to send the bought tokens to.
     * @param bytes32 _exchangeId The exchangeId to choose. If it's an empty string, then the exchange will be chosen automatically.
     * @return boolean whether or not the trade succeeded.
     */
    function buyToken
        (
        ERC20Extended _token, uint _amount, uint _minimumRate,
        address _depositAddress, bytes32 _exchangeId
        ) external payable returns(bool success);

    /*
     * @dev Sell a single token for ETH. Make sure the token is approved beforehand.
     * @param ERC20Extended _token The token to sell, should be an ERC20Extended address.
     * @param uint _amount Amount of tokens to sell.
     * @param uint _minimumRate The minimum amount of ETH to receive for 1 ERC20Extended token.
     * @param address _depositAddress The address to send the bought tokens to.
     * @param bytes32 _exchangeId The exchangeId to choose. If it's an empty string, then the exchange will be chosen automatically.
     * @return boolean boolean whether or not the trade succeeded.
     */
    function sellToken
        (
        ERC20Extended _token, uint _amount, uint _minimumRate,
        address _depositAddress, bytes32 _exchangeId
        ) external returns(bool success);
}

contract PriceProviderInterface is ComponentInterface {
    /*
     * @dev Returns the expected price for 1 of sourceAddress.
     * For ETH, use 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
     * @param address _sourceAddress The token to sell for the destAddress.
     * @param address _destAddress The token to buy with the source token.
     * @param uint _amount The amount of tokens which is wanted to buy.
     * @param bytes32 _exchangeId The exchangeId to choose. If it's an empty string, then the exchange will be chosen automatically.
     * @return returns the expected and slippage rate for the specified conversion
     */
    function getPrice(ERC20Extended _sourceAddress, ERC20Extended _destAddress, uint _amount, bytes32 _exchangeId)
        external view returns(uint expectedRate, uint slippageRate);

    /*
     * @dev Returns the expected price for 1 of sourceAddress. If it's currently not available, the last known price will be returned from cache.
     * Note: when the price comes from cache, this should only be used as a backup, when there are no alternatives
     * For ETH, use 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
     * @param address _sourceAddress The token to sell for the destAddress.
     * @param address _destAddress The token to buy with the source token.
     * @param uint _amount The amount of tokens which is wanted to buy.
     * @param bytes32 _exchangeId The exchangeId to choose. If it's an empty string, then the exchange will be chosen automatically.
     * @param uint _maxPriceAgeIfCache If the price is not available at the moment, choose the maximum age in seconds of the cached price to return.
     * @return returns the expected and slippage rate for the specified conversion and whether or not the price comes from cache
     */
    function getPriceOrCacheFallback(
        ERC20Extended _sourceAddress, ERC20Extended _destAddress, uint _amount, bytes32 _exchangeId, uint _maxPriceAgeIfCache)
        external returns(uint expectedRate, uint slippageRate, bool isCached);

    /*
     * @dev Returns the prices for multiple tokens in the form of ETH to token rates. If their prices are currently not available, the last known prices will be returned from cache.
     * Note: when the price comes from cache, this should only be used as a backup, when there are no alternatives
     * @param address _destAddress The token for which to get the ETH to token rate.
     * @param uint _maxPriceAgeIfCache If any price is not available at the moment, choose the maximum age in seconds of the cached price to return.
     * @return returns an array of the expected and slippage rates for the specified tokens and whether or not the price comes from cache
     */
    function getMultiplePricesOrCacheFallback(ERC20Extended[] _destAddresses, uint _maxPriceAgeIfCache)
        external returns(uint[] expectedRates, uint[] slippageRates, bool[] isCached);
}

contract OlympusExchangeInterface is ExchangeInterface, PriceProviderInterface, Ownable {
    /*
     * @dev Buy multiple tokens at once with ETH.
     * @param ERC20Extended[] _tokens The tokens to buy, should be an array of ERC20Extended addresses.
     * @param uint[] _amounts Amount of ETH used to buy this token. Make sure the value sent to this function is the same as the sum of this array.
     * @param uint[] _minimumRates The minimum amount of tokens to receive for 1 ETH.
     * @param address _depositAddress The address to send the bought tokens to.
     * @param bytes32 _exchangeId The exchangeId to choose. If it's an empty string, then the exchange will be chosen automatically.
     * @return boolean boolean whether or not the trade succeeded.
     */
    function buyTokens
        (
        ERC20Extended[] _tokens, uint[] _amounts, uint[] _minimumRates,
        address _depositAddress, bytes32 _exchangeId
        ) external payable returns(bool success);

    /*
     * @dev Sell multiple tokens at once with ETH, make sure all of the tokens are approved to be transferred beforehand with the Olympus Exchange address.
     * @param ERC20Extended[] _tokens The tokens to sell, should be an array of ERC20Extended addresses.
     * @param uint[] _amounts Amount of tokens to sell this token. Make sure the value sent to this function is the same as the sum of this array.
     * @param uint[] _minimumRates The minimum amount of ETH to receive for 1 specified ERC20Extended token.
     * @param address _depositAddress The address to send the bought tokens to.
     * @param bytes32 _exchangeId The exchangeId to choose. If it's an empty string, then the exchange will be chosen automatically.
     * @return boolean boolean whether or not the trade succeeded.
     */
    function sellTokens
        (
        ERC20Extended[] _tokens, uint[] _amounts, uint[] _minimumRates,
        address _depositAddress, bytes32 _exchangeId
        ) external returns(bool success);
    function tokenExchange
        (
        ERC20Extended _src, ERC20Extended _dest, uint _amount, uint _minimumRate,
        address _depositAddress, bytes32 _exchangeId
        ) external returns(bool success);
    function getFailedTrade(address _token) public view returns (uint failedTimes);
    function getFailedTradesArray(ERC20Extended[] _tokens) public view returns (uint[] memory failedTimes);
}

contract RebalanceInterface is ComponentInterface {
    function recalculateTokensToBuyAfterSale(uint _receivedETHFromSale) external
        returns(uint[] _recalculatedAmountsToBuy);
    function rebalanceGetTokensToSellAndBuy(uint _rebalanceDeltaPercentage) external returns
        (address[] _tokensToSell, uint[] _amountsToSell, address[] _tokensToBuy, uint[] _amountsToBuy, address[] _tokensWithPriceIssues);
    function finalize() public returns(bool success);
    function getRebalanceInProgress() external returns (bool inProgress);
    function needsRebalance(uint _rebalanceDeltaPercentage, address _targetAddress) external view returns (bool _needsRebalance);
    function getTotalIndexValueWithoutCache(address _indexAddress) public view returns (uint totalValue);
}

contract WithdrawInterface is ComponentInterface {

    function request(address _requester, uint amount) external returns(bool);
    function withdraw(address _requester) external returns(uint eth, uint tokens);
    function freeze() external;
    // TODO remove in progress
    function isInProgress() external view returns(bool);
    function finalize() external;
    function getUserRequests() external view returns(address[]);
    function getTotalWithdrawAmount() external view returns(uint);

    event WithdrawRequest(address _requester, uint amountOfToken);
    event Withdrawed(address _requester,  uint amountOfToken , uint amountOfEther);
}

contract MarketplaceInterface is Ownable {

    address[] public products;
    mapping(address => address[]) public productMappings;

    function getAllProducts() external view returns (address[] allProducts);
    function registerProduct() external returns(bool success);
    function getOwnProducts() external view returns (address[] addresses);

    event Registered(address product, address owner);
}

contract ChargeableInterface is ComponentInterface {

    uint public DENOMINATOR;
    function calculateFee(address _caller, uint _amount) external returns(uint totalFeeAmount);
    function setFeePercentage(uint _fee) external returns (bool succes);
    function getFeePercentage() external view returns (uint feePercentage);

 }

contract ReimbursableInterface is ComponentInterface {

    // this should be called at the beginning of a function.
    // such as rebalance and withdraw.
    function startGasCalculation() external;
    // this should be called at the last moment of the function.
    function reimburse() external returns (uint);

}

library Converter {
    function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function bytes32ToString(bytes32 x) internal pure returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}

contract OlympusIndex is IndexInterface, Derivative {
    using SafeMath for uint256;

    bytes32 public constant BUYTOKENS = "BuyTokens";
    enum Status { AVAILABLE, WITHDRAWING, REBALANCING, BUYING, SELLINGTOKENS }
    Status public productStatus = Status.AVAILABLE;
    // event ChangeStatus(DerivativeStatus status);

    uint public constant INITIAL_VALUE =  10**18;
    uint public constant INITIAL_FEE = 10**17;
    uint public constant TOKEN_DENOMINATOR = 10**18; // Apply % to a denominator, 18 is the minimum highetst precision required
    uint[] public weights;
    uint public accumulatedFee = 0;
    uint public rebalanceDeltaPercentage = 0; // by default, can be 30, means 0.3%.
    uint public rebalanceReceivedETHAmountFromSale;
    uint public freezeBalance; // For operations (Buy tokens and sellTokens)
    ERC20Extended[]  freezeTokens;
    enum RebalancePhases { Initial, SellTokens, BuyTokens }

    constructor (
      string _name,
      string _symbol,
      string _description,
      bytes32 _category,
      uint _decimals,
      address[] _tokens,
      uint[] _weights)
      public {
        require(0<=_decimals&&_decimals<=18);
        require(_tokens.length == _weights.length);
        uint _totalWeight;
        uint i;

        for (i = 0; i < _weights.length; i++) {
            _totalWeight = _totalWeight.add(_weights[i]);
            // Check all tokens are ERC20Extended
            ERC20Extended(_tokens[i]).balanceOf(address(this));
            require( ERC20Extended(_tokens[i]).decimals() <= 18);
        }
        require(_totalWeight == 100);

        name = _name;
        symbol = _symbol;
        totalSupply_ = 0;
        decimals = _decimals;
        description = _description;
        category = _category;
        version = "1.1-20181228";
        fundType = DerivativeType.Index;
        tokens = _tokens;
        weights = _weights;
        status = DerivativeStatus.New;


    }

    // ----------------------------- CONFIG -----------------------------
    // solhint-disable-next-line
    function initialize(
        address _componentList,
        uint _initialFundFee,
        uint _rebalanceDeltaPercentage
   )
   public onlyOwner payable {
        require(status == DerivativeStatus.New);
        require(msg.value >= INITIAL_FEE); // Require some balance for internal opeations as reimbursable. 0.1ETH
        require(_componentList != 0x0);
        require(_rebalanceDeltaPercentage <= (10 ** decimals));

        pausedCycle = 365 days;

        rebalanceDeltaPercentage = _rebalanceDeltaPercentage;
        super._initialize(_componentList);
        bytes32[9] memory names = [
            MARKET, EXCHANGE, REBALANCE, WHITELIST, FEE, REIMBURSABLE, WITHDRAW, LOCKER, STEP
        ];

        for (uint i = 0; i < names.length; i++) {
            updateComponent(names[i]);
        }

        MarketplaceInterface(getComponentByName(MARKET)).registerProduct();
        setManagementFee(_initialFundFee);

        uint[] memory _maxSteps = new uint[](4);
        bytes32[] memory _categories = new bytes32[](4);
        _maxSteps[0] = 3;
        _maxSteps[1] = 10;
        _maxSteps[2] = 5;
        _maxSteps[3] = 3;

        _categories[0] = REBALANCE;
        _categories[1] = WITHDRAW;
        _categories[2] = BUYTOKENS;
        _categories[3] = GETETH;

        StepInterface(getComponentByName(STEP)).setMultipleMaxCalls(_categories, _maxSteps);
        status = DerivativeStatus.Active;

        // emit ChangeStatus(status);

        accumulatedFee = accumulatedFee.add(msg.value);
    }


    // Return tokens and weights
    // solhint-disable-next-line
    function getTokens() public view returns (address[] _tokens, uint[] _weights) {
        return (tokens, weights);
    }

    // solhint-disable-next-line
    function close() OnlyOwnerOrPausedTimeout public returns(bool success) {
        require(status != DerivativeStatus.New);
        require(productStatus == Status.AVAILABLE);

        status = DerivativeStatus.Closed;
        return true;
    }

    function sellAllTokensOnClosedFund() onlyOwnerOrWhitelisted(WhitelistKeys.Maintenance) public returns (bool) {
        require(status == DerivativeStatus.Closed );
        require(productStatus == Status.AVAILABLE || productStatus == Status.SELLINGTOKENS);
        startGasCalculation();
        productStatus = Status.SELLINGTOKENS;
        bool result = getETHFromTokens(TOKEN_DENOMINATOR);
        if(result) {
            productStatus = Status.AVAILABLE;
        }
        reimburse();
        return result;
    }
    // ----------------------------- DERIVATIVE -----------------------------
    // solhint-disable-next-line
    function invest() public payable
     whenNotPaused
     whitelisted(WhitelistKeys.Investment)
      returns(bool) {
        require(status == DerivativeStatus.Active, "The Fund is not active");
        require(msg.value >= 10**15, "Minimum value to invest is 0.001 ETH");
         // Current value is already added in the balance, reduce it
        uint _sharePrice  = INITIAL_VALUE;

        if (totalSupply_ > 0) {
            _sharePrice = getPrice().sub((msg.value.mul(10 ** decimals)).div(totalSupply_));
        }

        uint fee =  ChargeableInterface(getComponentByName(FEE)).calculateFee(msg.sender, msg.value);
        uint _investorShare = (msg.value.sub(fee)).mul(10 ** decimals).div(_sharePrice);

        accumulatedFee = accumulatedFee.add(fee);
        balances[msg.sender] = balances[msg.sender].add(_investorShare);
        totalSupply_ = totalSupply_.add(_investorShare);

        // emit Invested(msg.sender, _investorShare);
        emit Transfer(0x0, msg.sender, _investorShare); // ERC20 Required event
        return true;
    }

    function getPrice() public view returns(uint) {
        if (totalSupply_ == 0) {
            return INITIAL_VALUE;
        }
        uint valueETH = getAssetsValue().add(getETHBalance()).mul(10 ** decimals);
        // Total Value in ETH among its tokens + ETH new added value
        return valueETH.div(totalSupply_);

    }

    function getETHBalance() public view returns(uint) {
        return address(this).balance.sub(accumulatedFee);
    }

    function getAssetsValue() public view returns (uint) {
        // TODO cast to OlympusExchangeInterface
        OlympusExchangeInterface exchangeProvider = OlympusExchangeInterface(getComponentByName(EXCHANGE));
        uint _totalTokensValue = 0;
        // Iterator
        uint _expectedRate;
        uint _balance;
        uint _decimals;
        ERC20Extended token;

        for (uint i = 0; i < tokens.length; i++) {
            token = ERC20Extended(tokens[i]);
            _decimals = token.decimals();
            _balance = token.balanceOf(address(this));

            if (_balance == 0) {continue;}
            (_expectedRate, ) = exchangeProvider.getPrice(token, ETH, 10**_decimals, 0x0);
            if (_expectedRate == 0) {continue;}
            _totalTokensValue = _totalTokensValue.add(_balance.mul(_expectedRate).div(10**_decimals));
        }
        return _totalTokensValue;
    }

    // ----------------------------- FEES  -----------------------------
    // Owner can send ETH to the Index, to perform some task, this eth belongs to him
    // solhint-disable-next-line
    function addOwnerBalance() external payable {
        accumulatedFee = accumulatedFee.add(msg.value);
    }

  // solhint-disable-next-line
    function withdrawFee(uint _amount) external onlyOwner whenNotPaused returns(bool) {
        require(_amount > 0 );
        require((
            status == DerivativeStatus.Closed && getAssetsValue() == 0 && getWithdrawAmount() == 0 ) ? // everything is done, take all.
            (_amount <= accumulatedFee)
            :
            (_amount.add(INITIAL_FEE) <= accumulatedFee) // else, the initial fee stays.
        );
        accumulatedFee = accumulatedFee.sub(_amount);
        // Exchange to MOT
        OlympusExchangeInterface exchange = OlympusExchangeInterface(getComponentByName(EXCHANGE));
        ERC20Extended MOT = ERC20Extended(FeeChargerInterface(address(exchange)).MOT());
        uint _rate;
        (, _rate ) = exchange.getPrice(ETH, MOT, _amount, 0x0);
        exchange.buyToken.value(_amount)(MOT, _amount, _rate, owner, 0x0);
        return true;
    }

    // solhint-disable-next-line
    function setManagementFee(uint _fee) public onlyOwner {
        ChargeableInterface(getComponentByName(FEE)).setFeePercentage(_fee);
    }

    // ----------------------------- WITHDRAW -----------------------------
    // solhint-disable-next-line
    function requestWithdraw(uint amount) external
      whenNotPaused
     {
        WithdrawInterface withdrawProvider = WithdrawInterface(getComponentByName(WITHDRAW));
        withdrawProvider.request(msg.sender, amount);
        if(status == DerivativeStatus.Closed && getAssetsValue() == 0 && getWithdrawAmount() == amount) {
            withdrawProvider.freeze();
            handleWithdraw(withdrawProvider, msg.sender);
            withdrawProvider.finalize();
            return;
        }
     }

    function guaranteeLiquidity(uint tokenBalance) internal returns(bool success){

        if(getStatusStep(GETETH) == 0) {
            uint _totalETHToReturn = tokenBalance.mul(getPrice()).div(10**decimals);
            if (_totalETHToReturn <= getETHBalance()) {
                return true;
            }

            // tokenPercentToSell must be freeze as class variable.
            // 10**18 is the highest preccision for all possible tokens
            freezeBalance = _totalETHToReturn.sub(getETHBalance()).mul(TOKEN_DENOMINATOR).div(getAssetsValue());
        }
        return getETHFromTokens(freezeBalance);
    }

    // solhint-disable-next-line
    function withdraw() external onlyOwnerOrWhitelisted(WhitelistKeys.Maintenance) whenNotPaused returns(bool) {
        startGasCalculation();

        require(productStatus == Status.AVAILABLE || productStatus == Status.WITHDRAWING);
        productStatus = Status.WITHDRAWING;

        WithdrawInterface withdrawProvider = WithdrawInterface(getComponentByName(WITHDRAW));

        // Check if there is request
        address[] memory _requests = withdrawProvider.getUserRequests();
        uint _withdrawStatus = getStatusStep(WITHDRAW);



        if (_withdrawStatus == 0 && getStatusStep(GETETH) == 0) {
            checkLocker(WITHDRAW);
            if (_requests.length == 0) {
                productStatus = Status.AVAILABLE;
                reimburse();
                return true;
            }
        }

        if (_withdrawStatus == 0) {
            if(!guaranteeLiquidity(getWithdrawAmount())) {
                reimburse();
                return false;
            }
            withdrawProvider.freeze();
        }

        uint _transfers = initializeOrContinueStep(WITHDRAW);
        uint i;

        for (i = _transfers; i < _requests.length && goNextStep(WITHDRAW); i++) {
            if(!handleWithdraw(withdrawProvider, _requests[i])){ continue; }
        }

        if (i == _requests.length) {
            withdrawProvider.finalize();
            finalizeStep(WITHDRAW);
            productStatus = Status.AVAILABLE;
        }
        reimburse();
        return i == _requests.length; // True if completed
    }

    function handleWithdraw(WithdrawInterface _withdrawProvider, address _investor) private returns (bool) {
        uint _eth;
        uint _tokenAmount;

        (_eth, _tokenAmount) = _withdrawProvider.withdraw(_investor);
        if (_tokenAmount == 0) {return false;}

        balances[_investor] =  balances[_investor].sub(_tokenAmount);
        emit Transfer(_investor, 0x0, _tokenAmount); // ERC20 Required event

        totalSupply_ = totalSupply_.sub(_tokenAmount);
        address(_investor).transfer(_eth);

        return true;
    }

    function checkLocker(bytes32 category) internal {
        LockerInterface(getComponentByName(LOCKER)).checkLockerByTime(category);
    }

    function startGasCalculation() internal {
        ReimbursableInterface(getComponentByName(REIMBURSABLE)).startGasCalculation();
    }

    // solhint-disable-next-line
    function reimburse() private {
        uint reimbursedAmount = ReimbursableInterface(getComponentByName(REIMBURSABLE)).reimburse();
        accumulatedFee = accumulatedFee.sub(reimbursedAmount);
        // emit Reimbursed(reimbursedAmount);
        msg.sender.transfer(reimbursedAmount);
    }

    // solhint-disable-next-line
    function tokensWithAmount() public view returns( ERC20Extended[] memory) {
        // First check the length
        uint length = 0;
        uint[] memory _amounts = new uint[](tokens.length);
        for (uint i = 0; i < tokens.length; i++) {
            _amounts[i] = ERC20Extended(tokens[i]).balanceOf(address(this));
            if (_amounts[i] > 0) {length++;}
        }

        ERC20Extended[] memory _tokensWithAmount = new ERC20Extended[](length);
        // Then create they array
        uint index = 0;
        for (uint j = 0; j < tokens.length; j++) {
            if (_amounts[j] > 0) {
                _tokensWithAmount[index] = ERC20Extended(tokens[j]);
                index++;
            }
        }
        return _tokensWithAmount;
    }

    // _tokenPercentage must come in TOKEN_DENOMIANTOR
    function getETHFromTokens(uint _tokenPercentage) internal returns(bool success) {
        OlympusExchangeInterface exchange = OlympusExchangeInterface(getComponentByName(EXCHANGE));

        uint currentStep = initializeOrContinueStep(GETETH);
        uint i; // Current step to tokens.length
        uint arrayLength = getNextArrayLength(GETETH, currentStep);
        if(currentStep == 0) {
            freezeTokens = tokensWithAmount();
        }

        ERC20Extended[] memory _tokensThisStep = new ERC20Extended[](arrayLength);
        uint[] memory _amounts = new uint[](arrayLength);
        uint[] memory _sellRates = new uint[](arrayLength);

        for(i = currentStep;i < freezeTokens.length && goNextStep(GETETH); i++){
            uint sellIndex = i.sub(currentStep);
            _tokensThisStep[sellIndex] = freezeTokens[i];
            _amounts[sellIndex] = _tokenPercentage.mul(freezeTokens[i].balanceOf(address(this))).div(TOKEN_DENOMINATOR);
            (, _sellRates[sellIndex] ) = exchange.getPrice(freezeTokens[i], ETH, _amounts[sellIndex], 0x0);
            approveExchange(address(_tokensThisStep[sellIndex]), _amounts[sellIndex]);
        }
        require(exchange.sellTokens(_tokensThisStep, _amounts, _sellRates, address(this), 0x0));

        if(i == freezeTokens.length) {
            finalizeStep(GETETH);
            return true;
        }
        return false;
    }

    // ----------------------------- REBALANCE -----------------------------
    // solhint-disable-next-line
    function buyTokens() external onlyOwnerOrWhitelisted(WhitelistKeys.Maintenance) whenNotPaused returns(bool) {
        startGasCalculation();

        require(productStatus == Status.AVAILABLE || productStatus == Status.BUYING);
        productStatus = Status.BUYING;

        OlympusExchangeInterface exchange = OlympusExchangeInterface(getComponentByName(EXCHANGE));

        // Start?
        if (getStatusStep(BUYTOKENS) == 0) {
            checkLocker(BUYTOKENS);
            if (tokens.length == 0 || getETHBalance() == 0) {
                productStatus = Status.AVAILABLE;
                reimburse();
                return true;
            }
            freezeBalance = getETHBalance();
        }
        uint currentStep = initializeOrContinueStep(BUYTOKENS);

        // Check the length of the array
        uint arrayLength = getNextArrayLength(BUYTOKENS, currentStep);

        uint[] memory _amounts = new uint[](arrayLength);
        // Initialize to 0, making sure any rate is fine
        uint[] memory _rates = new uint[](arrayLength);
        // Initialize to 0, making sure any rate is fine
        ERC20Extended[] memory _tokensErc20 = new ERC20Extended[](arrayLength);
        uint _totalAmount = 0;
        uint i; // Current step to tokens.length
        uint _buyIndex; // 0 to currentStepLength
        for (i = currentStep; i < tokens.length && goNextStep(BUYTOKENS); i++) {
            _buyIndex = i - currentStep;
            _amounts[_buyIndex] = freezeBalance.mul(weights[i]).div(100);
            _tokensErc20[_buyIndex] = ERC20Extended(tokens[i]);
            (, _rates[_buyIndex] ) = exchange.getPrice(ETH, _tokensErc20[_buyIndex], _amounts[_buyIndex], 0x0);
            _totalAmount = _totalAmount.add(_amounts[_buyIndex]);
        }

        require(exchange.buyTokens.value(_totalAmount)(_tokensErc20, _amounts, _rates, address(this), 0x0));

        if(i == tokens.length) {
            finalizeStep(BUYTOKENS);
            freezeBalance = 0;
            productStatus = Status.AVAILABLE;
            reimburse();
            return true;
        }
        reimburse();
        return false;
    }

    // solhint-disable-next-line
    function rebalance() public onlyOwnerOrWhitelisted(WhitelistKeys.Maintenance) whenNotPaused returns (bool success) {
        startGasCalculation();

        require(productStatus == Status.AVAILABLE || productStatus == Status.REBALANCING);

        RebalanceInterface rebalanceProvider = RebalanceInterface(getComponentByName(REBALANCE));
        OlympusExchangeInterface exchangeProvider = OlympusExchangeInterface(getComponentByName(EXCHANGE));
        if (!rebalanceProvider.getRebalanceInProgress()) {
            checkLocker(REBALANCE);
        }

        address[] memory _tokensToSell;
        uint[] memory _amounts;
        address[] memory _tokensToBuy;
        uint i;

        (_tokensToSell, _amounts, _tokensToBuy,,) = rebalanceProvider.rebalanceGetTokensToSellAndBuy(rebalanceDeltaPercentage);
        if(_tokensToSell.length == 0) {
            reimburse(); // Completed case
            return true;
        }
        // solhint-disable-next-line
        uint ETHBalanceBefore = getETHBalance();

        uint currentStep = initializeOrContinueStep(REBALANCE);
        uint stepStatus = getStatusStep(REBALANCE);
        // solhint-disable-next-line

        productStatus = Status.REBALANCING;

        // Sell Tokens
        if ( stepStatus == uint(RebalancePhases.SellTokens)) {
            for (i = currentStep; i < _tokensToSell.length && goNextStep(REBALANCE) ; i++) {
                approveExchange(_tokensToSell[i], _amounts[i]);
                // solhint-disable-next-line

                require(exchangeProvider.sellToken(ERC20Extended(_tokensToSell[i]), _amounts[i], 0, address(this), 0x0));
            }

            rebalanceReceivedETHAmountFromSale = rebalanceReceivedETHAmountFromSale.add(getETHBalance()).sub(ETHBalanceBefore) ;
            if (i ==  _tokensToSell.length) {
                updateStatusStep(REBALANCE);
                currentStep = 0;
            }
        }
        // Buy Tokens
        if (stepStatus == uint(RebalancePhases.BuyTokens)) {
            _amounts = rebalanceProvider.recalculateTokensToBuyAfterSale(rebalanceReceivedETHAmountFromSale);
            for (i = currentStep; i < _tokensToBuy.length && goNextStep(REBALANCE); i++) {
                require(
                    // solhint-disable-next-line
                    exchangeProvider.buyToken.value(_amounts[i])(ERC20Extended(_tokensToBuy[i]), _amounts[i], 0, address(this), 0x0)
                );
            }

            if(i == _tokensToBuy.length) {
                finalizeStep(REBALANCE);
                rebalanceProvider.finalize();
                rebalanceReceivedETHAmountFromSale = 0;
                productStatus = Status.AVAILABLE;
                reimburse();   // Completed case
                return true;
            }
        }
        reimburse(); // Not complete case
        return false;
    }
    // ----------------------------- STEP PROVIDER -----------------------------
    function initializeOrContinueStep(bytes32 category) internal returns(uint) {
        return  StepInterface(getComponentByName(STEP)).initializeOrContinue(category);
    }

    function getStatusStep(bytes32 category) internal view returns(uint) {
        return  StepInterface(getComponentByName(STEP)).getStatus(category);
    }

    function finalizeStep(bytes32 category) internal returns(bool) {
        return  StepInterface(getComponentByName(STEP)).finalize(category);
    }

    function goNextStep(bytes32 category) internal returns(bool) {
        return StepInterface(getComponentByName(STEP)).goNextStep(category);
    }

    function updateStatusStep(bytes32 category) internal returns(uint) {
        return StepInterface(getComponentByName(STEP)).updateStatus(category);
    }

    function getWithdrawAmount() internal view returns(uint) {
        return WithdrawInterface(getComponentByName(WITHDRAW)).getTotalWithdrawAmount();
    }

    function getNextArrayLength(bytes32 stepCategory, uint currentStep) internal view returns(uint) {
        uint arrayLength = StepInterface(getComponentByName(STEP)).getMaxCalls(stepCategory);
        if(arrayLength.add(currentStep) >= tokens.length ) {
            arrayLength = tokens.length.sub(currentStep);
        }
        return arrayLength;
    }

    function approveExchange(address _token, uint amount) internal {
        OlympusExchangeInterface exchange = OlympusExchangeInterface(getComponentByName(EXCHANGE));
        ERC20NoReturn(_token).approve(exchange, 0);
        ERC20NoReturn(_token).approve(exchange, amount);
    }

    // ----------------------------- WHITELIST -----------------------------
    // solhint-disable-next-line
    function enableWhitelist(WhitelistKeys _key, bool enable) public onlyOwner returns(bool) {
        WhitelistInterface(getComponentByName(WHITELIST)).setStatus(uint(_key), enable);
        return true;
    }

    // solhint-disable-next-line
    function setAllowed(address[] accounts, WhitelistKeys _key, bool allowed) public onlyOwner returns(bool) {
        WhitelistInterface(getComponentByName(WHITELIST)).setAllowed(accounts, uint(_key), allowed);
        return true;
    }
}