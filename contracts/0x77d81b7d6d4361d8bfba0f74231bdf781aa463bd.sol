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
    returns (address);

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

// File: contracts/interfaces/IPoaToken.sol

interface IPoaToken {
  function initializeToken
  (
    bytes32 _name32, // bytes32 of name string
    bytes32 _symbol32, // bytes32 of symbol string
    address _issuer,
    address _custodian,
    address _registry,
    address _whitelist,
    uint256 _totalSupply // token total supply
  )
    external
    returns (bool);

  function issuer()
    external
    view
    returns (address);

  function startPreFunding()
    external
    returns (bool);

  function pause()
    external;

  function unpause()
    external;

  function terminate()
    external
    returns (bool);

  function proofOfCustody()
    external
    view
    returns (string);
}

// File: contracts/interfaces/IPoaCrowdsale.sol

interface IPoaCrowdsale {
  function initializeCrowdsale(
    bytes32 _fiatCurrency32,                // fiat currency string, e.g. 'EUR'
    uint256 _startTimeForFundingPeriod,     // future UNIX timestamp
    uint256 _durationForFiatFundingPeriod,  // duration of fiat funding period in seconds
    uint256 _durationForEthFundingPeriod,   // duration of ETH funding period in seconds
    uint256 _durationForActivationPeriod,   // duration of activation period in seconds
    uint256 _fundingGoalInCents             // funding goal in fiat cents
  )
    external
    returns (bool);
}

// File: contracts/PoaProxyCommon.sol

/**
  @title PoaProxyCommon acts as a convention between:
  - PoaCommon (and its inheritants: PoaToken & PoaCrowdsale)
  - PoaProxy

  It dictates where to read and write storage
*/
contract PoaProxyCommon {
  /*****************************
  * Start Proxy Common Storage *
  *****************************/

  // PoaTokenMaster logic contract used by proxies
  address public poaTokenMaster;

  // PoaCrowdsaleMaster logic contract used by proxies
  address public poaCrowdsaleMaster;

  // Registry used for getting other contract addresses
  address public registry;

  /***************************
  * End Proxy Common Storage *
  ***************************/


  /*********************************
  * Start Common Utility Functions *
  *********************************/

  /// @notice Gets a given contract address by bytes32 in order to save gas
  function getContractAddress(string _name)
    public
    view
    returns (address _contractAddress)
  {
    bytes4 _signature = bytes4(keccak256("getContractAddress32(bytes32)"));
    bytes32 _name32 = keccak256(abi.encodePacked(_name));

    assembly {
      let _registry := sload(registry_slot) // load registry address from storage
      let _pointer := mload(0x40)          // Set _pointer to free memory pointer
      mstore(_pointer, _signature)         // Store _signature at _pointer
      mstore(add(_pointer, 0x04), _name32) // Store _name32 at _pointer offset by 4 bytes for pre-existing _signature

      // staticcall(g, a, in, insize, out, outsize) => returns 0 on error, 1 on success
      let result := staticcall(
        gas,       // g = gas: whatever was passed already
        _registry, // a = address: address in storage
        _pointer,  // in = mem in  mem[in..(in+insize): set to free memory pointer
        0x24,      // insize = mem insize  mem[in..(in+insize): size of signature (bytes4) + bytes32 = 0x24
        _pointer,  // out = mem out  mem[out..(out+outsize): output assigned to this storage address
        0x20       // outsize = mem outsize  mem[out..(out+outsize): output should be 32byte slot (address size = 0x14 <  slot size 0x20)
      )

      // revert if not successful
      if iszero(result) {
        revert(0, 0)
      }

      _contractAddress := mload(_pointer) // Assign result to return value
      mstore(0x40, add(_pointer, 0x24))   // Advance free memory pointer by largest _pointer size
    }
  }

  /*******************************
  * End Common Utility Functions *
  *******************************/
}

// File: contracts/PoaProxy.sol

/**
  @title This contract manages the storage of:
  - PoaProxy
  - PoaToken
  - PoaCrowdsale

  @notice PoaProxy uses chained "delegatecall()"s to call functions on
  PoaToken and PoaCrowdsale and sets the resulting storage
  here on PoaProxy.

  @dev `getContractAddress("PoaLogger").call()` does not use the return value
  because we would rather contract functions to continue even if the event
  did not successfully trigger on the logger contract.
*/
contract PoaProxy is PoaProxyCommon {
  uint8 public constant version = 1;

  event ProxyUpgraded(address upgradedFrom, address upgradedTo);

  /**
    @notice Stores addresses of our contract registry
    as well as the PoaToken and PoaCrowdsale master
    contracts to forward calls to.
  */
  constructor(
    address _poaTokenMaster,
    address _poaCrowdsaleMaster,
    address _registry
  )
    public
  {
    // Ensure that none of the given addresses are empty
    require(_poaTokenMaster != address(0));
    require(_poaCrowdsaleMaster != address(0));
    require(_registry != address(0));

    // Set addresses in common storage using deterministic storage slots
    poaTokenMaster = _poaTokenMaster;
    poaCrowdsaleMaster = _poaCrowdsaleMaster;
    registry = _registry;
  }

  /*****************************
   * Start Proxy State Helpers *
   *****************************/

  /**
    @notice Ensures that a given address is a contract by
    making sure it has code. Used during upgrading to make
    sure the new addresses to upgrade to are smart contracts.
   */
  function isContract(address _address)
    private
    view
    returns (bool)
  {
    uint256 _size;
    assembly { _size := extcodesize(_address) }

    return _size > 0;
  }

  /***************************
   * End Proxy State Helpers *
   ***************************/


  /*****************************
   * Start Proxy State Setters *
   *****************************/

  /// @notice Update the stored "poaTokenMaster" address to upgrade the PoaToken master contract
  function proxyChangeTokenMaster(address _newMaster)
    public
    returns (bool)
  {
    require(msg.sender == getContractAddress("PoaManager"));
    require(_newMaster != address(0));
    require(poaTokenMaster != _newMaster);
    require(isContract(_newMaster));
    address _oldMaster = poaTokenMaster;
    poaTokenMaster = _newMaster;

    emit ProxyUpgraded(_oldMaster, _newMaster);
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature(
        "logProxyUpgraded(address,address)",
        _oldMaster,
        _newMaster
      )
    );

    return true;
  }

  /// @notice Update the stored `poaCrowdsaleMaster` address to upgrade the PoaCrowdsale master contract
  function proxyChangeCrowdsaleMaster(address _newMaster)
    public
    returns (bool)
  {
    require(msg.sender == getContractAddress("PoaManager"));
    require(_newMaster != address(0));
    require(poaCrowdsaleMaster != _newMaster);
    require(isContract(_newMaster));
    address _oldMaster = poaCrowdsaleMaster;
    poaCrowdsaleMaster = _newMaster;

    emit ProxyUpgraded(_oldMaster, _newMaster);
    getContractAddress("PoaLogger").call(
      abi.encodeWithSignature(
        "logProxyUpgraded(address,address)",
        _oldMaster,
        _newMaster
      )
    );

    return true;
  }

  /***************************
   * End Proxy State Setters *
   ***************************/

  /**
    @notice Fallback function for all proxied functions using "delegatecall()".
    It will first forward all functions to the "poaTokenMaster" address. If the
    called function isn't found there, then "poaTokenMaster"'s fallback function
    will forward the call to "poaCrowdsale". If the called function also isn't
    found there, it will fail at last.
  */
  function()
    external
    payable
  {
    assembly {
      // Load PoaToken master address from first storage pointer
      let _poaTokenMaster := sload(poaTokenMaster_slot)

      // calldatacopy(t, f, s)
      calldatacopy(
        0x0, // t = mem position to
        0x0, // f = mem position from
        calldatasize // s = size bytes
      )

      // delegatecall(g, a, in, insize, out, outsize) => returns "0" on error, or "1" on success
      let result := delegatecall(
        gas, // g = gas
        _poaTokenMaster, // a = address
        0x0, // in = mem in  mem[in..(in+insize)
        calldatasize, // insize = mem insize  mem[in..(in+insize)
        0x0, // out = mem out  mem[out..(out+outsize)
        0 // outsize = mem outsize  mem[out..(out+outsize)
      )

      // Check if the call was successful
      if iszero(result) {
        // Revert if call failed
        revert(0, 0)
      }

      // returndatacopy(t, f, s)
      returndatacopy(
        0x0, // t = mem position to
        0x0,  // f = mem position from
        returndatasize // s = size bytes
      )
      // Return if call succeeded
      return(
        0x0,
        returndatasize
      )
    }
  }
}

// File: contracts/PoaManager.sol

contract PoaManager is Ownable {
  using SafeMath for uint256;

  uint256 constant version = 1;

  IRegistry public registry;

  struct EntityState {
    uint256 index;
    bool active;
  }

  // Keeping a list for addresses we track for easy access
  address[] private issuerAddressList;
  address[] private tokenAddressList;

  // A mapping for each address we track
  mapping (address => EntityState) private tokenMap;
  mapping (address => EntityState) private issuerMap;

  event IssuerAdded(address indexed issuer);
  event IssuerRemoved(address indexed issuer);
  event IssuerStatusChanged(address indexed issuer, bool active);

  event TokenAdded(address indexed token);
  event TokenRemoved(address indexed token);
  event TokenStatusChanged(address indexed token, bool active);

  modifier isNewIssuer(address _issuerAddress) {
    require(_issuerAddress != address(0));
    require(issuerMap[_issuerAddress].index == 0);
    _;
  }

  modifier onlyActiveIssuer() {
    EntityState memory entity = issuerMap[msg.sender];
    require(entity.active);
    _;
  }

  constructor(address _registryAddress)
    public
  {
    require(_registryAddress != address(0));
    registry = IRegistry(_registryAddress);
  }

  //
  // Entity functions
  //

  function doesEntityExist(
    address _entityAddress,
    EntityState entity
  )
    private
    pure
    returns (bool)
  {
    return (_entityAddress != address(0) && entity.index != 0);
  }

  function addEntity(
    address _entityAddress,
    address[] storage entityList,
    bool _active
  )
    private
    returns (EntityState)
  {
    entityList.push(_entityAddress);
    // we do not offset by `-1` so that we never have `entity.index = 0` as this is what is
    // used to check for existence in modifier [doesEntityExist]
    uint256 index = entityList.length;
    EntityState memory entity = EntityState(index, _active);

    return entity;
  }

  function removeEntity(
    EntityState _entityToRemove,
    address[] storage _entityList
  )
    private
    returns (address, uint256)
  {
    // we offset by -1 here to account for how `addEntity` marks the `entity.index` value
    uint256 index = _entityToRemove.index.sub(1);

    // swap the entity to be removed with the last element in the list
    _entityList[index] = _entityList[_entityList.length - 1];

    // because we wanted seperate mappings for token and issuer, and we cannot pass a storage mapping
    // as a function argument, this abstraction is leaky; we return the address and index so the
    // caller can update the mapping
    address entityToSwapAddress = _entityList[index];

    // we do not need to delete the element, the compiler should clean up for us
    _entityList.length--;

    return (entityToSwapAddress, _entityToRemove.index);
  }

  function setEntityActiveValue(
    EntityState storage entity,
    bool _active
  )
    private
  {
    require(entity.active != _active);
    entity.active = _active;
  }

  //
  // Issuer functions
  //

  // Return all tracked issuer addresses
  function getIssuerAddressList()
    public
    view
    returns (address[])
  {
    return issuerAddressList;
  }

  // Add an issuer and set active value to true
  function addIssuer(address _issuerAddress)
    public
    onlyOwner
    isNewIssuer(_issuerAddress)
  {
    issuerMap[_issuerAddress] = addEntity(
      _issuerAddress,
      issuerAddressList,
      true
    );

    emit IssuerAdded(_issuerAddress);
  }

  // Remove an issuer
  function removeIssuer(address _issuerAddress)
    public
    onlyOwner
  {
    require(doesEntityExist(_issuerAddress, issuerMap[_issuerAddress]));

    address addressToUpdate;
    uint256 indexUpdate;
    (addressToUpdate, indexUpdate) = removeEntity(issuerMap[_issuerAddress], issuerAddressList);
    issuerMap[addressToUpdate].index = indexUpdate;
    delete issuerMap[_issuerAddress];

    emit IssuerRemoved(_issuerAddress);
  }

  // Set previously delisted issuer to listed
  function listIssuer(address _issuerAddress)
    public
    onlyOwner
  {
    require(doesEntityExist(_issuerAddress, issuerMap[_issuerAddress]));

    setEntityActiveValue(issuerMap[_issuerAddress], true);
    emit IssuerStatusChanged(_issuerAddress, true);
  }

  // Set previously listed issuer to delisted
  function delistIssuer(address _issuerAddress)
    public
    onlyOwner
  {
    require(doesEntityExist(_issuerAddress, issuerMap[_issuerAddress]));

    setEntityActiveValue(issuerMap[_issuerAddress], false);
    emit IssuerStatusChanged(_issuerAddress, false);
  }

  function isActiveIssuer(address _issuerAddress)
    public
    view
    returns (bool)
  {
    require(doesEntityExist(_issuerAddress, issuerMap[_issuerAddress]));

    return issuerMap[_issuerAddress].active;
  }

  function isRegisteredIssuer(address _issuerAddress)
    external
    view
    returns (bool)
  {
    return doesEntityExist(_issuerAddress, issuerMap[_issuerAddress]);
  }

  //
  // Token functions
  //

  // Return all tracked token addresses
  function getTokenAddressList()
    public
    view
    returns (address[])
  {
    return tokenAddressList;
  }

  function createPoaTokenProxy()
    private
    returns (address _proxyContract)
  {
    address _poaTokenMaster = registry.getContractAddress("PoaTokenMaster");
    address _poaCrowdsaleMaster = registry.getContractAddress("PoaCrowdsaleMaster");
    _proxyContract = new PoaProxy(_poaTokenMaster, _poaCrowdsaleMaster, address(registry));
  }

  /**
    @notice Creates a PoaToken contract with given parameters, and set active value to false
    @param _fiatCurrency32 Fiat symbol used in ExchangeRates
    @param _startTimeForFundingPeriod Given as unix time in seconds since 01.01.1970
    @param _durationForFiatFundingPeriod How long fiat funding can last, given in seconds
    @param _durationForEthFundingPeriod How long eth funding can last, given in seconds
    @param _durationForActivationPeriod How long a custodian has to activate token, given in seconds
    @param _fundingGoalInCents Given as fiat cents
   */
  function addNewToken(
    bytes32 _name32,
    bytes32 _symbol32,
    bytes32 _fiatCurrency32,
    address _custodian,
    uint256 _totalSupply,
    uint256 _startTimeForFundingPeriod,
    uint256 _durationForFiatFundingPeriod,
    uint256 _durationForEthFundingPeriod,
    uint256 _durationForActivationPeriod,
    uint256 _fundingGoalInCents,
    address _whitelist
  )
    public
    onlyActiveIssuer
    returns (address)
  {
    address _tokenAddress = createPoaTokenProxy();

    // We use this initialization pattern to avoid the `StackTooDeep` problem
    // StackTooDeep: https://ethereum.stackexchange.com/questions/6061/error-while-compiling-stack-too-deep
    initializePoaToken(
      _tokenAddress,
      _name32,
      _symbol32,
      _custodian,
      _whitelist,
      _totalSupply
    );

    initializePoaCrowdsale(
      _tokenAddress,
      _fiatCurrency32,
      _startTimeForFundingPeriod,
      _durationForFiatFundingPeriod,
      _durationForEthFundingPeriod,
      _durationForActivationPeriod,
      _fundingGoalInCents
    );

    tokenMap[_tokenAddress] = addEntity(
      _tokenAddress,
      tokenAddressList,
      false
    );

    emit TokenAdded(_tokenAddress);

    return _tokenAddress;
  }

  // Initializes a PoaToken contract with given parameters
  function initializePoaToken(
    address _tokenAddress,
    bytes32 _name32,
    bytes32 _symbol32,
    address _custodian,
    address _whitelist,
    uint256 _totalSupply
  )
    private
  {
    IPoaToken(_tokenAddress).initializeToken(
      _name32,
      _symbol32,
      msg.sender,
      _custodian,
      registry,
      _whitelist,
      _totalSupply
    );
  }

  // Initializes a PoaCrowdsale contract with given parameters
  function initializePoaCrowdsale(
    address _tokenAddress,
    bytes32 _fiatCurrency32,
    uint256 _startTimeForFundingPeriod,
    uint256 _durationForFiatFundingPeriod,
    uint256 _durationForEthFundingPeriod,
    uint256 _durationForActivationPeriod,
    uint256 _fundingGoalInCents
  )
    private
  {
    IPoaCrowdsale(_tokenAddress).initializeCrowdsale(
      _fiatCurrency32,
      _startTimeForFundingPeriod,
      _durationForFiatFundingPeriod,
      _durationForEthFundingPeriod,
      _durationForActivationPeriod,
      _fundingGoalInCents
    );
  }

  /**
    @notice Add existing `PoaProxy` contracts when `PoaManager` has been upgraded
    @param _tokenAddress the `PoaProxy` address to address
    @param _isListed if `PoaProxy` should be added as active or inactive
    @dev `PoaProxy` contracts can only be added when the POA's issuer is already listed.
         Furthermore, we use `issuer()` as check if `_tokenAddress` represents a `PoaProxy`.
   */
  function addExistingToken(address _tokenAddress, bool _isListed)
    external
    onlyOwner
  {
    require(!doesEntityExist(_tokenAddress, tokenMap[_tokenAddress]));
    // Issuer address of `_tokenAddress` must be an active Issuer.
    // If `_tokenAddress` is not an instance of PoaProxy, this will fail as desired.
    require(isActiveIssuer(IPoaToken(_tokenAddress).issuer()));

    tokenMap[_tokenAddress] = addEntity(
      _tokenAddress,
      tokenAddressList,
      _isListed
    );
  }

  // Remove a token
  function removeToken(address _tokenAddress)
    public
    onlyOwner
  {
    require(doesEntityExist(_tokenAddress, tokenMap[_tokenAddress]));

    address addressToUpdate;
    uint256 indexUpdate;
    (addressToUpdate, indexUpdate) = removeEntity(tokenMap[_tokenAddress], tokenAddressList);
    tokenMap[addressToUpdate].index = indexUpdate;
    delete tokenMap[_tokenAddress];

    emit TokenRemoved(_tokenAddress);
  }

  // Set previously delisted token to listed
  function listToken(address _tokenAddress)
    public
    onlyOwner
  {
    require(doesEntityExist(_tokenAddress, tokenMap[_tokenAddress]));

    setEntityActiveValue(tokenMap[_tokenAddress], true);
    emit TokenStatusChanged(_tokenAddress, true);
  }

  // Set previously listed token to delisted
  function delistToken(address _tokenAddress)
    public
    onlyOwner
  {
    require(doesEntityExist(_tokenAddress, tokenMap[_tokenAddress]));

    setEntityActiveValue(tokenMap[_tokenAddress], false);
    emit TokenStatusChanged(_tokenAddress, false);
  }

  function isActiveToken(address _tokenAddress)
    public
    view
    returns (bool)
  {
    require(doesEntityExist(_tokenAddress, tokenMap[_tokenAddress]));

    return tokenMap[_tokenAddress].active;
  }

  function isRegisteredToken(address _tokenAddress)
    external
    view
    returns (bool)
  {
    return doesEntityExist(_tokenAddress, tokenMap[_tokenAddress]);
  }

  //
  // Token onlyOwner functions as PoaManger is `owner` of all PoaToken
  //

  // Allow unpausing a listed PoaToken
  function pauseToken(address _tokenAddress)
    public
    onlyOwner
  {
    IPoaToken(_tokenAddress).pause();
  }

  // Allow unpausing a listed PoaToken
  function unpauseToken(IPoaToken _tokenAddress)
    public
    onlyOwner
  {
    _tokenAddress.unpause();
  }

  // Allow terminating a listed PoaToken
  function terminateToken(IPoaToken _tokenAddress)
    public
    onlyOwner
  {
    _tokenAddress.terminate();
  }

  // upgrade an existing PoaToken proxy to what is stored in ContractRegistry
  function upgradeToken(PoaProxy _proxyToken)
    external
    onlyOwner
    returns (bool)
  {
    _proxyToken.proxyChangeTokenMaster(
      registry.getContractAddress("PoaTokenMaster")
    );

    return true;
  }

  // upgrade an existing PoaCrowdsale proxy to what is stored in ContractRegistry
  function upgradeCrowdsale(PoaProxy _proxyToken)
    external
    onlyOwner
    returns (bool)
  {
    _proxyToken.proxyChangeCrowdsaleMaster(
      registry.getContractAddress("PoaCrowdsaleMaster")
    );

    return true;
  }
}