pragma solidity 0.4.24;

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

// File: contracts/interfaces/IExchangeRateProvider.sol

interface IExchangeRateProvider {
  function sendQuery(
    string _queryString,
    uint256 _callInterval,
    uint256 _callbackGasLimit,
    string _queryType
  )
    external
    payable
    returns (bool);

  function setCallbackGasPrice(uint256 _gasPrice)
    external
    returns (bool);

  function selfDestruct(address _address)
    external;
}

// File: contracts/ExchangeRates.sol

/*
Q/A
Q: Why are there two contracts for ExchangeRates?
A: Testing Oraclize seems to be a bit difficult especially considering the
bridge requires node v6... With that in mind, it was decided that the best way
to move forward was to isolate the oraclize functionality and replace with
a stub in order to facilitate effective tests.

Q: Why are rates private?
A: So that they can be returned through custom getters getRate and
getRateReadable. This is so that we can revert when a rate has not been
initialized or an error happened when fetching. Oraclize returns '' when
erroring which we parse as a uint256 which turns to 0.
*/

// main contract
contract ExchangeRates is Ownable {
  using SafeMath for uint256;

  uint8 public constant version = 1;
  uint256 public constant permilleDenominator = 1000;
  // instance of Registry to be used for getting other contract addresses
  IRegistry private registry;
  // flag used to tell recursive rate fetching to stop
  bool public ratesActive = true;

  struct Settings {
    string queryString;
    uint256 callInterval;
    uint256 callbackGasLimit;
    // Rate penalty that is applied on fetched fiat rates. The penalty
    // is specified at permille-accuracy. Example: 18 => 18/1000 = 1.8% penalty.
    uint256 ratePenalty;
  }

  // the actual exchange rate for each currency
  // private so that when rate is 0 (error or unset) we can revert through
  // getter functions getRate and getRateReadable
  mapping (bytes32 => uint256) private rates;
  // points to currencySettings from callback
  // is used to validate queryIds from ExchangeRateProvider
  mapping (bytes32 => string) public queryTypes;
  // storage for query settings... modifiable for each currency
  // accessed and used by ExchangeRateProvider
  mapping (string => Settings) private currencySettings;

  event RateUpdated(string currency, uint256 rate);
  event NotEnoughBalance();
  event QuerySent(string currency);
  event SettingsUpdated(string currency);

  // used to only allow specific contract to call specific functions
  modifier onlyContract(string _contractName)
  {
    require(
      msg.sender == registry.getContractAddress(_contractName)
    );
    _;
  }

  // sets registry for talking to ExchangeRateProvider
  constructor(
    address _registryAddress
  )
    public
    payable
  {
    require(_registryAddress != address(0));
    registry = IRegistry(_registryAddress);
    owner = msg.sender;
  }

  // start rate fetching for a specific currency. Kicks off the first of
  // possibly many recursive query calls on ExchangeRateProvider to get rates.
  function fetchRate(string _queryType)
    external
    onlyOwner
    payable
    returns (bool)
  {
    // get the ExchangeRateProvider from registry
    IExchangeRateProvider provider = IExchangeRateProvider(
      registry.getContractAddress("ExchangeRateProvider")
    );

    // get settings to use in query on ExchangeRateProvider
    uint256 _callInterval;
    uint256 _callbackGasLimit;
    string memory _queryString;
    uint256 _ratePenalty;
    (
      _callInterval,
      _callbackGasLimit,
      _queryString,
      _ratePenalty // not used in this function
    ) = getCurrencySettings(_queryType);

    // check that queryString isn't empty before making the query
    require(bytes(_queryString).length > 0);

    // make query on ExchangeRateProvider
    // forward any ether value sent on to ExchangeRateProvider
    // setQuery is called from ExchangeRateProvider to trigger an event
    // whether there is enough balance or not
    provider.sendQuery.value(msg.value)(
      _queryString,
      _callInterval,
      _callbackGasLimit,
      _queryType
    );
    return true;
  }

  //
  // start exchange rate provider only functions
  //

  // set a pending queryId callable only by ExchangeRateProvider
  // set from sendQuery on ExchangeRateProvider
  // used to check that correct query is being matched to correct values
  function setQueryId(
    bytes32 _queryId,
    string _queryType
  )
    external
    onlyContract("ExchangeRateProvider")
    returns (bool)
  {
    if (_queryId[0] != 0x0 && bytes(_queryType)[0] != 0x0) {
      emit QuerySent(_queryType);
      queryTypes[_queryId] = _queryType;
    } else {
      emit NotEnoughBalance();
    }
    return true;
  }

  // called only by ExchangeRateProvider
  // sets the rate for a given currency when query __callback occurs.
  // checks that the queryId returned is correct.
  function setRate(
    bytes32 _queryId,
    uint256 _rateInCents
  )
    external
    onlyContract("ExchangeRateProvider")
    returns (bool)
  {
    // get the query type (usd, eur, etc)
    string memory _currencyName = queryTypes[_queryId];
    // check that first byte of _queryType is not 0 (something wrong or empty)
    // if the queryType is 0 then the queryId is incorrect
    require(bytes(_currencyName).length > 0);
    // get and apply penalty on fiat rate to compensate for fees
    uint256 _penaltyInPermille = currencySettings[toUpperCase(_currencyName)].ratePenalty;
    uint256 _penalizedRate = _rateInCents
      .mul(permilleDenominator.sub(_penaltyInPermille))
      .div(permilleDenominator);
    // set _queryId to empty (uninitialized, to prevent from being called again)
    delete queryTypes[_queryId];
    // set currency rate depending on _queryType (USD, EUR, etc.)
    rates[keccak256(abi.encodePacked(_currencyName))] = _penalizedRate;
    // event for particular rate that was updated
    emit RateUpdated(
      _currencyName,
      _penalizedRate
    );

    return true;
  }

  //
  // end exchange rate provider only settings
  //

  /*
  set setting for a given currency:
  currencyName: used as identifier to store settings (stored as bytes8)
  queryString: the http endpoint to hit to get data along with format
    example: "json(https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD).USD"
  callInterval: used to specifiy how often (if at all) the rate should refresh
  callbackGasLimit: used to specify how much gas to give the oraclize callback
  */
  function setCurrencySettings(
    string _currencyName,
    string _queryString,
    uint256 _callInterval,
    uint256 _callbackGasLimit,
    uint256 _ratePenalty
  )
    external
    onlyOwner
    returns (bool)
  {
    // check that the permille value doesn't exceed 999.
    require(_ratePenalty < 1000);
    // store settings by bytes8 of string, convert queryString to bytes array
    currencySettings[toUpperCase(_currencyName)] = Settings(
      _queryString,
      _callInterval,
      _callbackGasLimit,
      _ratePenalty
    );
    emit SettingsUpdated(_currencyName);
    return true;
  }

  // set only query string in settings for a given currency
  function setCurrencySettingQueryString(
    string _currencyName,
    string _queryString
  )
    external
    onlyOwner
    returns (bool)
  {
    Settings storage _settings = currencySettings[toUpperCase(_currencyName)];
    _settings.queryString = _queryString;
    emit SettingsUpdated(_currencyName);
    return true;
  }

  // set only callInterval in settings for a given currency
  function setCurrencySettingCallInterval(
    string _currencyName,
    uint256 _callInterval
  )
    external
    onlyOwner
    returns (bool)
  {
    Settings storage _settings = currencySettings[toUpperCase(_currencyName)];
    _settings.callInterval = _callInterval;
    emit SettingsUpdated(_currencyName);
    return true;
  }

  // set only callbackGasLimit in settings for a given currency
  function setCurrencySettingCallbackGasLimit(
    string _currencyName,
    uint256 _callbackGasLimit
  )
    external
    onlyOwner
    returns (bool)
  {
    Settings storage _settings = currencySettings[toUpperCase(_currencyName)];
    _settings.callbackGasLimit = _callbackGasLimit;
    emit SettingsUpdated(_currencyName);
    return true;
  }

  // set only ratePenalty in settings for a given currency
  function setCurrencySettingRatePenalty(
    string _currencyName,
    uint256 _ratePenalty
  )
    external
    onlyOwner
    returns (bool)
  {
    // check that the permille value doesn't exceed 999.
    require(_ratePenalty < 1000);

    Settings storage _settings = currencySettings[toUpperCase(_currencyName)];
    _settings.ratePenalty = _ratePenalty;
    emit SettingsUpdated(_currencyName);
    return true;
  }

  // set callback gasPrice for all currencies
  function setCallbackGasPrice(uint256 _gasPrice)
    external
    onlyOwner
    returns (bool)
  {
    // get the ExchangeRateProvider from registry
    IExchangeRateProvider provider = IExchangeRateProvider(
      registry.getContractAddress("ExchangeRateProvider")
    );
    provider.setCallbackGasPrice(_gasPrice);
    emit SettingsUpdated("ALL");
    return true;
  }

  // set to active or inactive in order to stop recursive rate fetching
  // rate needs to be fetched once in order for it to stop.
  function toggleRatesActive()
    external
    onlyOwner
    returns (bool)
  {
    ratesActive = !ratesActive;
    emit SettingsUpdated("ALL");
    return true;
  }

  //
  // end setter functions
  //

  //
  // start getter functions
  //

  // retrieve settings for a given currency (queryType)
  function getCurrencySettings(string _queryTypeString)
    public
    view
    returns (uint256, uint256, string, uint256)
  {
    Settings memory _settings = currencySettings[_queryTypeString];
    return (
      _settings.callInterval,
      _settings.callbackGasLimit,
      _settings.queryString,
      _settings.ratePenalty
    );
  }

  // get rate with string for easy use by regular accounts
  function getRate(string _queryTypeString)
    external
    view
    returns (uint256)
  {
    uint256 _rate = rates[keccak256(abi.encodePacked(toUpperCase(_queryTypeString)))];
    require(_rate > 0);
    return _rate;
  }

  // get rate with bytes32 for easier assembly calls
  // uppercase protection not provided...
  function getRate32(bytes32 _queryType32)
    external
    view
    returns (uint256)
  {
    uint256 _rate = rates[_queryType32];
    require(_rate > 0);
    return _rate;
  }

  //
  // end getter functions
  //

  //
  // start utility functions
  //

  // convert string to uppercase to ensure that there are not multiple
  // instances of same currencies
  function toUpperCase(string _base)
    public
    pure
    returns (string)
  {
    bytes memory _stringBytes = bytes(_base);
    for (
      uint _byteCounter = 0;
      _byteCounter < _stringBytes.length;
      _byteCounter++
    ) {
      if (
        _stringBytes[_byteCounter] >= 0x61 &&
        _stringBytes[_byteCounter] <= 0x7A
      ) {
        _stringBytes[_byteCounter] = bytes1(
          uint8(_stringBytes[_byteCounter]) - 32
        );
      }
    }
    return string(_stringBytes);
  }

  //
  // end utility functions
  //

  // used for selfdestructing the provider in order to get back any unused ether
  // useful for upgrades where we want to get money back from contract
  function killProvider(address _address)
    public
    onlyOwner
  {
    // get the ExchangeRateProvider from registry
    IExchangeRateProvider provider = IExchangeRateProvider(
      registry.getContractAddress("ExchangeRateProvider")
    );
    provider.selfDestruct(_address);
  }
}