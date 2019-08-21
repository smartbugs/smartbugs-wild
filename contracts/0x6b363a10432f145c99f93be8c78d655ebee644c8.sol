pragma solidity ^0.4.24;

/**
 * @title Utility contract to allow pausing and unpausing of certain functions
 */
contract Pausable {

    event Pause(uint256 _timestammp);
    event Unpause(uint256 _timestamp);

    bool public paused = false;

    /**
    * @notice Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    /**
    * @notice Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused, "Contract is not paused");
        _;
    }

   /**
    * @notice Called by the owner to pause, triggers stopped state
    */
    function _pause() internal whenNotPaused {
        paused = true;
        /*solium-disable-next-line security/no-block-members*/
        emit Pause(now);
    }

    /**
    * @notice Called by the owner to unpause, returns to normal state
    */
    function _unpause() internal whenPaused {
        paused = false;
        /*solium-disable-next-line security/no-block-members*/
        emit Unpause(now);
    }

}

/**
 * @title Interface that every module contract should implement
 */
interface IModule {

    /**
     * @notice This function returns the signature of configure function
     */
    function getInitFunction() external pure returns (bytes4);

    /**
     * @notice Return the permission flags that are associated with a module
     */
    function getPermissions() external view returns(bytes32[]);

    /**
     * @notice Used to withdraw the fee by the factory owner
     */
    function takeFee(uint256 _amount) external returns(bool);

}

/**
 * @title Interface for all security tokens
 */
interface ISecurityToken {

    // Standard ERC20 interface
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);
    function increaseApproval(address _spender, uint _addedValue) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //transfer, transferFrom must respect the result of verifyTransfer
    function verifyTransfer(address _from, address _to, uint256 _value) external returns (bool success);

    /**
     * @notice Mints new tokens and assigns them to the target _investor.
     * Can only be called by the STO attached to the token (Or by the ST owner if there's no STO attached yet)
     * @param _investor Address the tokens will be minted to
     * @param _value is the amount of tokens that will be minted to the investor
     */
    function mint(address _investor, uint256 _value) external returns (bool success);

    /**
     * @notice Mints new tokens and assigns them to the target _investor.
     * Can only be called by the STO attached to the token (Or by the ST owner if there's no STO attached yet)
     * @param _investor Address the tokens will be minted to
     * @param _value is The amount of tokens that will be minted to the investor
     * @param _data Data to indicate validation
     */
    function mintWithData(address _investor, uint256 _value, bytes _data) external returns (bool success);

    /**
     * @notice Used to burn the securityToken on behalf of someone else
     * @param _from Address for whom to burn tokens
     * @param _value No. of tokens to be burned
     * @param _data Data to indicate validation
     */
    function burnFromWithData(address _from, uint256 _value, bytes _data) external;

    /**
     * @notice Used to burn the securityToken
     * @param _value No. of tokens to be burned
     * @param _data Data to indicate validation
     */
    function burnWithData(uint256 _value, bytes _data) external;

    event Minted(address indexed _to, uint256 _value);
    event Burnt(address indexed _burner, uint256 _value);

    // Permissions this to a Permission module, which has a key of 1
    // If no Permission return false - note that IModule withPerm will allow ST owner all permissions anyway
    // this allows individual modules to override this logic if needed (to not allow ST owner all permissions)
    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns (bool);

    /**
     * @notice Returns module list for a module type
     * @param _module Address of the module
     * @return bytes32 Name
     * @return address Module address
     * @return address Module factory address
     * @return bool Module archived
     * @return uint8 Module type
     * @return uint256 Module index
     * @return uint256 Name index

     */
    function getModule(address _module) external view returns(bytes32, address, address, bool, uint8, uint256, uint256);

    /**
     * @notice Returns module list for a module name
     * @param _name Name of the module
     * @return address[] List of modules with this name
     */
    function getModulesByName(bytes32 _name) external view returns (address[]);

    /**
     * @notice Returns module list for a module type
     * @param _type Type of the module
     * @return address[] List of modules with this type
     */
    function getModulesByType(uint8 _type) external view returns (address[]);

    /**
     * @notice Queries totalSupply at a specified checkpoint
     * @param _checkpointId Checkpoint ID to query as of
     */
    function totalSupplyAt(uint256 _checkpointId) external view returns (uint256);

    /**
     * @notice Queries balance at a specified checkpoint
     * @param _investor Investor to query balance for
     * @param _checkpointId Checkpoint ID to query as of
     */
    function balanceOfAt(address _investor, uint256 _checkpointId) external view returns (uint256);

    /**
     * @notice Creates a checkpoint that can be used to query historical balances / totalSuppy
     */
    function createCheckpoint() external returns (uint256);

    /**
     * @notice Gets length of investors array
     * NB - this length may differ from investorCount if the list has not been pruned of zero-balance investors
     * @return Length
     */
    function getInvestors() external view returns (address[]);

    /**
     * @notice returns an array of investors at a given checkpoint
     * NB - this length may differ from investorCount as it contains all investors that ever held tokens
     * @param _checkpointId Checkpoint id at which investor list is to be populated
     * @return list of investors
     */
    function getInvestorsAt(uint256 _checkpointId) external view returns(address[]);

    /**
     * @notice generates subset of investors
     * NB - can be used in batches if investor list is large
     * @param _start Position of investor to start iteration from
     * @param _end Position of investor to stop iteration at
     * @return list of investors
     */
    function iterateInvestors(uint256 _start, uint256 _end) external view returns(address[]);
    
    /**
     * @notice Gets current checkpoint ID
     * @return Id
     */
    function currentCheckpointId() external view returns (uint256);

    /**
    * @notice Gets an investor at a particular index
    * @param _index Index to return address from
    * @return Investor address
    */
    function investors(uint256 _index) external view returns (address);

   /**
    * @notice Allows the owner to withdraw unspent POLY stored by them on the ST or any ERC20 token.
    * @dev Owner can transfer POLY to the ST which will be used to pay for modules that require a POLY fee.
    * @param _tokenContract Address of the ERC20Basic compliance token
    * @param _value Amount of POLY to withdraw
    */
    function withdrawERC20(address _tokenContract, uint256 _value) external;

    /**
    * @notice Allows owner to approve more POLY to one of the modules
    * @param _module Module address
    * @param _budget New budget
    */
    function changeModuleBudget(address _module, uint256 _budget) external;

    /**
     * @notice Changes the tokenDetails
     * @param _newTokenDetails New token details
     */
    function updateTokenDetails(string _newTokenDetails) external;

    /**
    * @notice Allows the owner to change token granularity
    * @param _granularity Granularity level of the token
    */
    function changeGranularity(uint256 _granularity) external;

    /**
    * @notice Removes addresses with zero balances from the investors list
    * @param _start Index in investors list at which to start removing zero balances
    * @param _iters Max number of iterations of the for loop
    * NB - pruning this list will mean you may not be able to iterate over investors on-chain as of a historical checkpoint
    */
    function pruneInvestors(uint256 _start, uint256 _iters) external;

    /**
     * @notice Freezes all the transfers
     */
    function freezeTransfers() external;

    /**
     * @notice Un-freezes all the transfers
     */
    function unfreezeTransfers() external;

    /**
     * @notice Ends token minting period permanently
     */
    function freezeMinting() external;

    /**
     * @notice Mints new tokens and assigns them to the target investors.
     * Can only be called by the STO attached to the token or by the Issuer (Security Token contract owner)
     * @param _investors A list of addresses to whom the minted tokens will be delivered
     * @param _values A list of the amount of tokens to mint to corresponding addresses from _investor[] list
     * @return Success
     */
    function mintMulti(address[] _investors, uint256[] _values) external returns (bool success);

    /**
     * @notice Function used to attach a module to the security token
     * @dev  E.G.: On deployment (through the STR) ST gets a TransferManager module attached to it
     * @dev to control restrictions on transfers.
     * @dev You are allowed to add a new moduleType if:
     * @dev - there is no existing module of that type yet added
     * @dev - the last member of the module list is replacable
     * @param _moduleFactory is the address of the module factory to be added
     * @param _data is data packed into bytes used to further configure the module (See STO usage)
     * @param _maxCost max amount of POLY willing to pay to module. (WIP)
     */
    function addModule(
        address _moduleFactory,
        bytes _data,
        uint256 _maxCost,
        uint256 _budget
    ) external;

    /**
    * @notice Archives a module attached to the SecurityToken
    * @param _module address of module to archive
    */
    function archiveModule(address _module) external;

    /**
    * @notice Unarchives a module attached to the SecurityToken
    * @param _module address of module to unarchive
    */
    function unarchiveModule(address _module) external;

    /**
    * @notice Removes a module attached to the SecurityToken
    * @param _module address of module to archive
    */
    function removeModule(address _module) external;

    /**
     * @notice Used by the issuer to set the controller addresses
     * @param _controller address of the controller
     */
    function setController(address _controller) external;

    /**
     * @notice Used by a controller to execute a forced transfer
     * @param _from address from which to take tokens
     * @param _to address where to send tokens
     * @param _value amount of tokens to transfer
     * @param _data data to indicate validation
     * @param _log data attached to the transfer by controller to emit in event
     */
    function forceTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _log) external;

    /**
     * @notice Used by a controller to execute a foced burn
     * @param _from address from which to take tokens
     * @param _value amount of tokens to transfer
     * @param _data data to indicate validation
     * @param _log data attached to the transfer by controller to emit in event
     */
    function forceBurn(address _from, uint256 _value, bytes _data, bytes _log) external;

    /**
     * @notice Used by the issuer to permanently disable controller functionality
     * @dev enabled via feature switch "disableControllerAllowed"
     */
     function disableController() external;

     /**
     * @notice Used to get the version of the securityToken
     */
     function getVersion() external view returns(uint8[]);

     /**
     * @notice Gets the investor count
     */
     function getInvestorCount() external view returns(uint256);

     /**
      * @notice Overloaded version of the transfer function
      * @param _to receiver of transfer
      * @param _value value of transfer
      * @param _data data to indicate validation
      * @return bool success
      */
     function transferWithData(address _to, uint256 _value, bytes _data) external returns (bool success);

     /**
      * @notice Overloaded version of the transferFrom function
      * @param _from sender of transfer
      * @param _to receiver of transfer
      * @param _value value of transfer
      * @param _data data to indicate validation
      * @return bool success
      */
     function transferFromWithData(address _from, address _to, uint256 _value, bytes _data) external returns(bool);

     /**
      * @notice Provides the granularity of the token
      * @return uint256
      */
     function granularity() external view returns(uint256);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function decreaseApproval(address _spender, uint _subtractedValue) external returns (bool);
    function increaseApproval(address _spender, uint _addedValue) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
 * @title Interface that any module contract should implement
 * @notice Contract is abstract
 */
contract Module is IModule {

    address public factory;

    address public securityToken;

    bytes32 public constant FEE_ADMIN = "FEE_ADMIN";

    IERC20 public polyToken;

    /**
     * @notice Constructor
     * @param _securityToken Address of the security token
     * @param _polyAddress Address of the polytoken
     */
    constructor (address _securityToken, address _polyAddress) public {
        securityToken = _securityToken;
        factory = msg.sender;
        polyToken = IERC20(_polyAddress);
    }

    //Allows owner, factory or permissioned delegate
    modifier withPerm(bytes32 _perm) {
        bool isOwner = msg.sender == Ownable(securityToken).owner();
        bool isFactory = msg.sender == factory;
        require(isOwner||isFactory||ISecurityToken(securityToken).checkPermission(msg.sender, address(this), _perm), "Permission check failed");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == Ownable(securityToken).owner(), "Sender is not owner");
        _;
    }

    modifier onlyFactory {
        require(msg.sender == factory, "Sender is not factory");
        _;
    }

    modifier onlyFactoryOwner {
        require(msg.sender == Ownable(factory).owner(), "Sender is not factory owner");
        _;
    }

    modifier onlyFactoryOrOwner {
        require((msg.sender == Ownable(securityToken).owner()) || (msg.sender == factory), "Sender is not factory or owner");
        _;
    }

    /**
     * @notice used to withdraw the fee by the factory owner
     */
    function takeFee(uint256 _amount) public withPerm(FEE_ADMIN) returns(bool) {
        require(polyToken.transferFrom(securityToken, Ownable(factory).owner(), _amount), "Unable to take fee");
        return true;
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
 * @title Interface to be implemented by all STO modules
 */
contract ISTO is Module, Pausable  {
    using SafeMath for uint256;

    enum FundRaiseType { ETH, POLY, DAI }
    mapping (uint8 => bool) public fundRaiseTypes;
    mapping (uint8 => uint256) public fundsRaised;

    // Start time of the STO
    uint256 public startTime;
    // End time of the STO
    uint256 public endTime;
    // Time STO was paused
    uint256 public pausedTime;
    // Number of individual investors
    uint256 public investorCount;
    // Address where ETH & POLY funds are delivered
    address public wallet;
     // Final amount of tokens sold
    uint256 public totalTokensSold;

    // Event
    event SetFundRaiseTypes(FundRaiseType[] _fundRaiseTypes);

    /**
    * @notice Reclaims ERC20Basic compatible tokens
    * @dev We duplicate here due to the overriden owner & onlyOwner
    * @param _tokenContract The address of the token contract
    */
    function reclaimERC20(address _tokenContract) external onlyOwner {
        require(_tokenContract != address(0), "Invalid address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(msg.sender, balance), "Transfer failed");
    }

    /**
     * @notice Returns funds raised by the STO
     */
    function getRaised(FundRaiseType _fundRaiseType) public view returns (uint256) {
        return fundsRaised[uint8(_fundRaiseType)];
    }

    /**
     * @notice Returns the total no. of tokens sold
     */
    function getTokensSold() public view returns (uint256);

    /**
     * @notice Pause (overridden function)
     */
    function pause() public onlyOwner {
        /*solium-disable-next-line security/no-block-members*/
        require(now < endTime, "STO has been finalized");
        super._pause();
    }

    /**
     * @notice Unpause (overridden function)
     */
    function unpause() public onlyOwner {
        super._unpause();
    }

    function _setFundRaiseType(FundRaiseType[] _fundRaiseTypes) internal {
        // FundRaiseType[] parameter type ensures only valid values for _fundRaiseTypes
        require(_fundRaiseTypes.length > 0, "Raise type is not specified");
        fundRaiseTypes[uint8(FundRaiseType.ETH)] = false;
        fundRaiseTypes[uint8(FundRaiseType.POLY)] = false;
        fundRaiseTypes[uint8(FundRaiseType.DAI)] = false;
        for (uint8 j = 0; j < _fundRaiseTypes.length; j++) {
            fundRaiseTypes[uint8(_fundRaiseTypes[j])] = true;
        }
        emit SetFundRaiseTypes(_fundRaiseTypes);
    }

}

interface IOracle {

    /**
    * @notice Returns address of oracle currency (0x0 for ETH)
    */
    function getCurrencyAddress() external view returns(address);

    /**
    * @notice Returns symbol of oracle currency (0x0 for ETH)
    */
    function getCurrencySymbol() external view returns(bytes32);

    /**
    * @notice Returns denomination of price
    */
    function getCurrencyDenominated() external view returns(bytes32);

    /**
    * @notice Returns price - should throw if not valid
    */
    function getPrice() external view returns(uint256);

}

/**
 * @title Utility contract to allow owner to retreive any ERC20 sent to the contract
 */
contract ReclaimTokens is Ownable {

    /**
    * @notice Reclaim all ERC20Basic compatible tokens
    * @param _tokenContract The address of the token contract
    */
    function reclaimERC20(address _tokenContract) external onlyOwner {
        require(_tokenContract != address(0), "Invalid address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(owner, balance), "Transfer failed");
    }
}

/**
 * @title Core functionality for registry upgradability
 */
contract PolymathRegistry is ReclaimTokens {

    mapping (bytes32 => address) public storedAddresses;

    event ChangeAddress(string _nameKey, address indexed _oldAddress, address indexed _newAddress);

    /**
     * @notice Gets the contract address
     * @param _nameKey is the key for the contract address mapping
     * @return address
     */
    function getAddress(string _nameKey) external view returns(address) {
        bytes32 key = keccak256(bytes(_nameKey));
        require(storedAddresses[key] != address(0), "Invalid address key");
        return storedAddresses[key];
    }

    /**
     * @notice Changes the contract address
     * @param _nameKey is the key for the contract address mapping
     * @param _newAddress is the new contract address
     */
    function changeAddress(string _nameKey, address _newAddress) external onlyOwner {
        bytes32 key = keccak256(bytes(_nameKey));
        emit ChangeAddress(_nameKey, storedAddresses[key], _newAddress);
        storedAddresses[key] = _newAddress;
    }


}

contract RegistryUpdater is Ownable {

    address public polymathRegistry;
    address public moduleRegistry;
    address public securityTokenRegistry;
    address public featureRegistry;
    address public polyToken;

    constructor (address _polymathRegistry) public {
        require(_polymathRegistry != address(0), "Invalid address");
        polymathRegistry = _polymathRegistry;
    }

    function updateFromRegistry() public onlyOwner {
        moduleRegistry = PolymathRegistry(polymathRegistry).getAddress("ModuleRegistry");
        securityTokenRegistry = PolymathRegistry(polymathRegistry).getAddress("SecurityTokenRegistry");
        featureRegistry = PolymathRegistry(polymathRegistry).getAddress("FeatureRegistry");
        polyToken = PolymathRegistry(polymathRegistry).getAddress("PolyToken");
    }

}

library DecimalMath {

    using SafeMath for uint256;

     /**
     * @notice This function multiplies two decimals represented as (decimal * 10**DECIMALS)
     * @return uint256 Result of multiplication represented as (decimal * 10**DECIMALS)
     */
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = SafeMath.add(SafeMath.mul(x, y), (10 ** 18) / 2) / (10 ** 18);
    }

    /**
     * @notice This function divides two decimals represented as (decimal * 10**DECIMALS)
     * @return uint256 Result of division represented as (decimal * 10**DECIMALS)
     */
    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = SafeMath.add(SafeMath.mul(x, (10 ** 18)), y / 2) / y;
    }

}

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private reentrancyLock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!reentrancyLock);
    reentrancyLock = true;
    _;
    reentrancyLock = false;
  }

}

/**
 * @title STO module for standard capped crowdsale
 */
contract USDTieredSTO is ISTO, ReentrancyGuard {
    using SafeMath for uint256;

    /////////////
    // Storage //
    /////////////

    string public POLY_ORACLE = "PolyUsdOracle";
    string public ETH_ORACLE = "EthUsdOracle";
    mapping (bytes32 => mapping (bytes32 => string)) oracleKeys;

    IERC20 public usdToken;

    // Determine whether users can invest on behalf of a beneficiary
    bool public allowBeneficialInvestments = false;

    // Address where ETH, POLY & DAI funds are delivered
    address public wallet;

    // Address of issuer reserve wallet for unsold tokens
    address public reserveWallet;

    // How many token units a buyer gets per USD per tier (multiplied by 10**18)
    uint256[] public ratePerTier;

    // How many token units a buyer gets per USD per tier (multiplied by 10**18) when investing in POLY up to tokensPerTierDiscountPoly
    uint256[] public ratePerTierDiscountPoly;

    // How many tokens are available in each tier (relative to totalSupply)
    uint256[] public tokensPerTierTotal;

    // How many token units are available in each tier (relative to totalSupply) at the ratePerTierDiscountPoly rate
    uint256[] public tokensPerTierDiscountPoly;

    // How many tokens have been minted in each tier (relative to totalSupply)
    uint256[] public mintedPerTierTotal;

    // How many tokens have been minted in each tier (relative to totalSupply) for each fund raise type
    mapping (uint8 => uint256[]) public mintedPerTier;

    // How many tokens have been minted in each tier (relative to totalSupply) at discounted POLY rate
    uint256[] public mintedPerTierDiscountPoly;

    // Current tier
    uint8 public currentTier;

    // Amount of USD funds raised
    uint256 public fundsRaisedUSD;

    // Amount in USD invested by each address
    mapping (address => uint256) public investorInvestedUSD;

    // Amount in fund raise type invested by each investor
    mapping (address => mapping (uint8 => uint256)) public investorInvested;

    // List of accredited investors
    mapping (address => bool) public accredited;

    // Default limit in USD for non-accredited investors multiplied by 10**18
    uint256 public nonAccreditedLimitUSD;

    // Overrides for default limit in USD for non-accredited investors multiplied by 10**18
    mapping (address => uint256) public nonAccreditedLimitUSDOverride;

    // Minimum investable amount in USD
    uint256 public minimumInvestmentUSD;

    // Whether or not the STO has been finalized
    bool public isFinalized;

    // Final amount of tokens returned to issuer
    uint256 public finalAmountReturned;

    ////////////
    // Events //
    ////////////

    event SetAllowBeneficialInvestments(bool _allowed);
    event SetNonAccreditedLimit(address _investor, uint256 _limit);
    event SetAccredited(address _investor, bool _accredited);
    event TokenPurchase(
        address indexed _purchaser,
        address indexed _beneficiary,
        uint256 _tokens,
        uint256 _usdAmount,
        uint256 _tierPrice,
        uint8 _tier
    );
    event FundsReceived(
        address indexed _purchaser,
        address indexed _beneficiary,
        uint256 _usdAmount,
        FundRaiseType _fundRaiseType,
        uint256 _receivedValue,
        uint256 _spentValue,
        uint256 _rate
    );
    event FundsReceivedPOLY(
        address indexed _purchaser,
        address indexed _beneficiary,
        uint256 _usdAmount,
        uint256 _receivedValue,
        uint256 _spentValue,
        uint256 _rate
    );
    event ReserveTokenMint(address indexed _owner, address indexed _wallet, uint256 _tokens, uint8 _latestTier);

    event SetAddresses(
        address indexed _wallet,
        address indexed _reserveWallet,
        address indexed _usdToken
    );
    event SetLimits(
        uint256 _nonAccreditedLimitUSD,
        uint256 _minimumInvestmentUSD
    );
    event SetTimes(
        uint256 _startTime,
        uint256 _endTime
    );
    event SetTiers(
        uint256[] _ratePerTier,
        uint256[] _ratePerTierDiscountPoly,
        uint256[] _tokensPerTierTotal,
        uint256[] _tokensPerTierDiscountPoly
    );

    ///////////////
    // Modifiers //
    ///////////////

    modifier validETH {
        require(_getOracle(bytes32("ETH"), bytes32("USD")) != address(0), "Invalid ETHUSD Oracle");
        require(fundRaiseTypes[uint8(FundRaiseType.ETH)], "Fund raise in ETH should be allowed");
        _;
    }

    modifier validPOLY {
        require(_getOracle(bytes32("POLY"), bytes32("USD")) != address(0), "Invalid POLYUSD Oracle");
        require(fundRaiseTypes[uint8(FundRaiseType.POLY)], "Fund raise in POLY should be allowed");
        _;
    }

    modifier validDAI {
        require(fundRaiseTypes[uint8(FundRaiseType.DAI)], "Fund raise in DAI should be allowed");
        _;
    }

    ///////////////////////
    // STO Configuration //
    ///////////////////////

    constructor (address _securityToken, address _polyAddress, address _factory) public Module(_securityToken, _polyAddress) {
        oracleKeys[bytes32("ETH")][bytes32("USD")] = ETH_ORACLE;
        oracleKeys[bytes32("POLY")][bytes32("USD")] = POLY_ORACLE;
        require(_factory != address(0), "In-valid address");
        factory = _factory;
    }

    /**
     * @notice Function used to intialize the contract variables
     * @param _startTime Unix timestamp at which offering get started
     * @param _endTime Unix timestamp at which offering get ended
     * @param _ratePerTier Rate (in USD) per tier (* 10**18)
     * @param _tokensPerTierTotal Tokens available in each tier
     * @param _nonAccreditedLimitUSD Limit in USD (* 10**18) for non-accredited investors
     * @param _minimumInvestmentUSD Minimun investment in USD (* 10**18)
     * @param _fundRaiseTypes Types of currency used to collect the funds
     * @param _wallet Ethereum account address to hold the funds
     * @param _reserveWallet Ethereum account address to receive unsold tokens
     * @param _usdToken Contract address of the stable coin
     */
    function configure(
        uint256 _startTime,
        uint256 _endTime,
        uint256[] _ratePerTier,
        uint256[] _ratePerTierDiscountPoly,
        uint256[] _tokensPerTierTotal,
        uint256[] _tokensPerTierDiscountPoly,
        uint256 _nonAccreditedLimitUSD,
        uint256 _minimumInvestmentUSD,
        FundRaiseType[] _fundRaiseTypes,
        address _wallet,
        address _reserveWallet,
        address _usdToken
    ) public onlyFactory {
        modifyTimes(_startTime, _endTime);
        // NB - modifyTiers must come before modifyFunding
        modifyTiers(_ratePerTier, _ratePerTierDiscountPoly, _tokensPerTierTotal, _tokensPerTierDiscountPoly);
        // NB - modifyFunding must come before modifyAddresses
        modifyFunding(_fundRaiseTypes);
        modifyAddresses(_wallet, _reserveWallet, _usdToken);
        modifyLimits(_nonAccreditedLimitUSD, _minimumInvestmentUSD);
    }

    function modifyFunding(FundRaiseType[] _fundRaiseTypes) public onlyFactoryOrOwner {
        /*solium-disable-next-line security/no-block-members*/
        require(now < startTime, "STO shouldn't be started");
        _setFundRaiseType(_fundRaiseTypes);
        uint256 length = getNumberOfTiers();
        mintedPerTierTotal = new uint256[](length);
        mintedPerTierDiscountPoly = new uint256[](length);
        for (uint8 i = 0; i < _fundRaiseTypes.length; i++) {
            mintedPerTier[uint8(_fundRaiseTypes[i])] = new uint256[](length);
        }
    }

    function modifyLimits(
        uint256 _nonAccreditedLimitUSD,
        uint256 _minimumInvestmentUSD
    ) public onlyFactoryOrOwner {
        /*solium-disable-next-line security/no-block-members*/
        require(now < startTime, "STO shouldn't be started");
        minimumInvestmentUSD = _minimumInvestmentUSD;
        nonAccreditedLimitUSD = _nonAccreditedLimitUSD;
        emit SetLimits(minimumInvestmentUSD, nonAccreditedLimitUSD);
    }

    function modifyTiers(
        uint256[] _ratePerTier,
        uint256[] _ratePerTierDiscountPoly,
        uint256[] _tokensPerTierTotal,
        uint256[] _tokensPerTierDiscountPoly
    ) public onlyFactoryOrOwner {
        /*solium-disable-next-line security/no-block-members*/
        require(now < startTime, "STO shouldn't be started");
        require(_tokensPerTierTotal.length > 0, "Length should be > 0");
        require(_ratePerTier.length == _tokensPerTierTotal.length, "Mismatch b/w rates & tokens / tier");
        require(_ratePerTierDiscountPoly.length == _tokensPerTierTotal.length, "Mismatch b/w discount rates & tokens / tier");
        require(_tokensPerTierDiscountPoly.length == _tokensPerTierTotal.length, "Mismatch b/w discount tokens / tier & tokens / tier");
        for (uint8 i = 0; i < _ratePerTier.length; i++) {
            require(_ratePerTier[i] > 0, "Rate > 0");
            require(_tokensPerTierTotal[i] > 0, "Tokens per tier > 0");
            require(_tokensPerTierDiscountPoly[i] <= _tokensPerTierTotal[i], "Discounted tokens / tier <= tokens / tier");
            require(_ratePerTierDiscountPoly[i] <= _ratePerTier[i], "Discounted rate / tier <= rate / tier");
        }
        ratePerTier = _ratePerTier;
        ratePerTierDiscountPoly = _ratePerTierDiscountPoly;
        tokensPerTierTotal = _tokensPerTierTotal;
        tokensPerTierDiscountPoly = _tokensPerTierDiscountPoly;
        emit SetTiers(_ratePerTier, _ratePerTierDiscountPoly, _tokensPerTierTotal, _tokensPerTierDiscountPoly);
    }

    function modifyTimes(
        uint256 _startTime,
        uint256 _endTime
    ) public onlyFactoryOrOwner {
        /*solium-disable-next-line security/no-block-members*/
        require((startTime == 0) || (now < startTime), "Invalid startTime");
        /*solium-disable-next-line security/no-block-members*/
        require((_endTime > _startTime) && (_startTime > now), "Invalid times");
        startTime = _startTime;
        endTime = _endTime;
        emit SetTimes(_startTime, _endTime);
    }

    function modifyAddresses(
        address _wallet,
        address _reserveWallet,
        address _usdToken
    ) public onlyFactoryOrOwner {
        /*solium-disable-next-line security/no-block-members*/
        require(now < startTime, "STO shouldn't be started");
        require(_wallet != address(0) && _reserveWallet != address(0), "Invalid address");
        if (fundRaiseTypes[uint8(FundRaiseType.DAI)]) {
            require(_usdToken != address(0), "Invalid address");
        }
        wallet = _wallet;
        reserveWallet = _reserveWallet;
        usdToken = IERC20(_usdToken);
        emit SetAddresses(_wallet, _reserveWallet, _usdToken);
    }

    ////////////////////
    // STO Management //
    ////////////////////

    /**
     * @notice Finalizes the STO and mint remaining tokens to reserve address
     * @notice Reserve address must be whitelisted to successfully finalize
     */
    function finalize() public onlyOwner {
        require(!isFinalized, "STO is already finalized");
        isFinalized = true;
        uint256 tempReturned;
        uint256 tempSold;
        uint256 remainingTokens;
        for (uint8 i = 0; i < tokensPerTierTotal.length; i++) {
            remainingTokens = tokensPerTierTotal[i].sub(mintedPerTierTotal[i]);
            tempReturned = tempReturned.add(remainingTokens);
            tempSold = tempSold.add(mintedPerTierTotal[i]);
            if (remainingTokens > 0) {
                mintedPerTierTotal[i] = tokensPerTierTotal[i];
            }
        }
        require(ISecurityToken(securityToken).mint(reserveWallet, tempReturned), "Error in minting");
        emit ReserveTokenMint(msg.sender, reserveWallet, tempReturned, currentTier);
        finalAmountReturned = tempReturned;
        totalTokensSold = tempSold;
    }

    /**
     * @notice Modifies the list of accredited addresses
     * @param _investors Array of investor addresses to modify
     * @param _accredited Array of bools specifying accreditation status
     */
    function changeAccredited(address[] _investors, bool[] _accredited) public onlyOwner {
        require(_investors.length == _accredited.length, "Array length mismatch");
        for (uint256 i = 0; i < _investors.length; i++) {
            accredited[_investors[i]] = _accredited[i];
            emit SetAccredited(_investors[i], _accredited[i]);
        }
    }

    /**
     * @notice Modifies the list of overrides for non-accredited limits in USD
     * @param _investors Array of investor addresses to modify
     * @param _nonAccreditedLimit Array of uints specifying non-accredited limits
     */
    function changeNonAccreditedLimit(address[] _investors, uint256[] _nonAccreditedLimit) public onlyOwner {
        //nonAccreditedLimitUSDOverride
        require(_investors.length == _nonAccreditedLimit.length, "Array length mismatch");
        for (uint256 i = 0; i < _investors.length; i++) {
            require(_nonAccreditedLimit[i] > 0, "Limit can not be 0");
            nonAccreditedLimitUSDOverride[_investors[i]] = _nonAccreditedLimit[i];
            emit SetNonAccreditedLimit(_investors[i], _nonAccreditedLimit[i]);
        }
    }

    /**
     * @notice Function to set allowBeneficialInvestments (allow beneficiary to be different to funder)
     * @param _allowBeneficialInvestments Boolean to allow or disallow beneficial investments
     */
    function changeAllowBeneficialInvestments(bool _allowBeneficialInvestments) public onlyOwner {
        require(_allowBeneficialInvestments != allowBeneficialInvestments, "Value unchanged");
        allowBeneficialInvestments = _allowBeneficialInvestments;
        emit SetAllowBeneficialInvestments(allowBeneficialInvestments);
    }

    //////////////////////////
    // Investment Functions //
    //////////////////////////

    /**
    * @notice fallback function - assumes ETH being invested
    */
    function () external payable {
        buyWithETH(msg.sender);
    }

    /**
      * @notice Purchase tokens using ETH
      * @param _beneficiary Address where security tokens will be sent
      */
    function buyWithETH(address _beneficiary) public payable validETH {
        uint256 rate = getRate(FundRaiseType.ETH);
        (uint256 spentUSD, uint256 spentValue) = _buyTokens(_beneficiary, msg.value, rate, FundRaiseType.ETH);
        // Modify storage
        investorInvested[_beneficiary][uint8(FundRaiseType.ETH)] = investorInvested[_beneficiary][uint8(FundRaiseType.ETH)].add(spentValue);
        fundsRaised[uint8(FundRaiseType.ETH)] = fundsRaised[uint8(FundRaiseType.ETH)].add(spentValue);
        // Forward ETH to issuer wallet
        wallet.transfer(spentValue);
        // Refund excess ETH to investor wallet
        msg.sender.transfer(msg.value.sub(spentValue));
        emit FundsReceived(msg.sender, _beneficiary, spentUSD, FundRaiseType.ETH, msg.value, spentValue, rate);
    }

    /**
      * @notice Purchase tokens using POLY
      * @param _beneficiary Address where security tokens will be sent
      * @param _investedPOLY Amount of POLY invested
      */
    function buyWithPOLY(address _beneficiary, uint256 _investedPOLY) public validPOLY {
        _buyWithTokens(_beneficiary, _investedPOLY, FundRaiseType.POLY);
    }

    /**
      * @notice Purchase tokens using POLY
      * @param _beneficiary Address where security tokens will be sent
      * @param _investedDAI Amount of POLY invested
      */
    function buyWithUSD(address _beneficiary, uint256 _investedDAI) public validDAI {
        _buyWithTokens(_beneficiary, _investedDAI, FundRaiseType.DAI);
    }

    function _buyWithTokens(address _beneficiary, uint256 _tokenAmount, FundRaiseType _fundRaiseType) internal {
        require(_fundRaiseType == FundRaiseType.POLY || _fundRaiseType == FundRaiseType.DAI, "POLY & DAI supported");
        uint256 rate = getRate(_fundRaiseType);
        (uint256 spentUSD, uint256 spentValue) = _buyTokens(_beneficiary, _tokenAmount, rate, _fundRaiseType);
        // Modify storage
        investorInvested[_beneficiary][uint8(_fundRaiseType)] = investorInvested[_beneficiary][uint8(_fundRaiseType)].add(spentValue);
        fundsRaised[uint8(_fundRaiseType)] = fundsRaised[uint8(_fundRaiseType)].add(spentValue);
        // Forward DAI to issuer wallet
        IERC20 token = _fundRaiseType == FundRaiseType.POLY ? polyToken : usdToken;
        require(token.transferFrom(msg.sender, wallet, spentValue), "Transfer failed");
        emit FundsReceived(msg.sender, _beneficiary, spentUSD, _fundRaiseType, _tokenAmount, spentValue, rate);
    }

    /**
      * @notice Low level token purchase
      * @param _beneficiary Address where security tokens will be sent
      * @param _investmentValue Amount of POLY, ETH or DAI invested
      * @param _fundRaiseType Fund raise type (POLY, ETH, DAI)
      */
    function _buyTokens(
        address _beneficiary,
        uint256 _investmentValue,
        uint256 _rate,
        FundRaiseType _fundRaiseType
    )
        internal
        nonReentrant
        whenNotPaused
        returns(uint256, uint256)
    {
        if (!allowBeneficialInvestments) {
            require(_beneficiary == msg.sender, "Beneficiary does not match funder");
        }

        require(isOpen(), "STO is not open");
        require(_investmentValue > 0, "No funds were sent");

        uint256 investedUSD = DecimalMath.mul(_rate, _investmentValue);
        uint256 originalUSD = investedUSD;

        // Check for minimum investment
        require(investedUSD.add(investorInvestedUSD[_beneficiary]) >= minimumInvestmentUSD, "Total investment < minimumInvestmentUSD");

        // Check for non-accredited cap
        if (!accredited[_beneficiary]) {
            uint256 investorLimitUSD = (nonAccreditedLimitUSDOverride[_beneficiary] == 0) ? nonAccreditedLimitUSD : nonAccreditedLimitUSDOverride[_beneficiary];
            require(investorInvestedUSD[_beneficiary] < investorLimitUSD, "Non-accredited investor has reached limit");
            if (investedUSD.add(investorInvestedUSD[_beneficiary]) > investorLimitUSD)
                investedUSD = investorLimitUSD.sub(investorInvestedUSD[_beneficiary]);
        }
        uint256 spentUSD;
        // Iterate over each tier and process payment
        for (uint8 i = currentTier; i < ratePerTier.length; i++) {
            // Update current tier if needed
            if (currentTier != i)
                currentTier = i;
            // If there are tokens remaining, process investment
            if (mintedPerTierTotal[i] < tokensPerTierTotal[i])
                spentUSD = spentUSD.add(_calculateTier(_beneficiary, i, investedUSD.sub(spentUSD), _fundRaiseType));
            // If all funds have been spent, exit the loop
            if (investedUSD == spentUSD)
                break;
        }

        // Modify storage
        if (spentUSD > 0) {
            if (investorInvestedUSD[_beneficiary] == 0)
                investorCount = investorCount + 1;
            investorInvestedUSD[_beneficiary] = investorInvestedUSD[_beneficiary].add(spentUSD);
            fundsRaisedUSD = fundsRaisedUSD.add(spentUSD);
        }

        // Calculate spent in base currency (ETH, DAI or POLY)
        uint256 spentValue;
        if (spentUSD == 0) {
            spentValue = 0;
        } else {
            spentValue = DecimalMath.mul(DecimalMath.div(spentUSD, originalUSD), _investmentValue);
        }

        // Return calculated amounts
        return (spentUSD, spentValue);
    }

    function _calculateTier(
        address _beneficiary,
        uint8 _tier,
        uint256 _investedUSD,
        FundRaiseType _fundRaiseType
    ) 
        internal
        returns(uint256)
     {
        // First purchase any discounted tokens if POLY investment
        uint256 spentUSD;
        uint256 tierSpentUSD;
        uint256 tierPurchasedTokens;
        uint256 investedUSD = _investedUSD;
        // Check whether there are any remaining discounted tokens
        if ((_fundRaiseType == FundRaiseType.POLY) && (tokensPerTierDiscountPoly[_tier] > mintedPerTierDiscountPoly[_tier])) {
            uint256 discountRemaining = tokensPerTierDiscountPoly[_tier].sub(mintedPerTierDiscountPoly[_tier]);
            uint256 totalRemaining = tokensPerTierTotal[_tier].sub(mintedPerTierTotal[_tier]);
            if (totalRemaining < discountRemaining)
                (spentUSD, tierPurchasedTokens) = _purchaseTier(_beneficiary, ratePerTierDiscountPoly[_tier], totalRemaining, investedUSD, _tier);
            else
                (spentUSD, tierPurchasedTokens) = _purchaseTier(_beneficiary, ratePerTierDiscountPoly[_tier], discountRemaining, investedUSD, _tier);
            investedUSD = investedUSD.sub(spentUSD);
            mintedPerTierDiscountPoly[_tier] = mintedPerTierDiscountPoly[_tier].add(tierPurchasedTokens);
            mintedPerTier[uint8(FundRaiseType.POLY)][_tier] = mintedPerTier[uint8(FundRaiseType.POLY)][_tier].add(tierPurchasedTokens);
            mintedPerTierTotal[_tier] = mintedPerTierTotal[_tier].add(tierPurchasedTokens);
        }
        // Now, if there is any remaining USD to be invested, purchase at non-discounted rate
        if ((investedUSD > 0) && (tokensPerTierTotal[_tier].sub(mintedPerTierTotal[_tier]) > 0)) {
            (tierSpentUSD, tierPurchasedTokens) = _purchaseTier(_beneficiary, ratePerTier[_tier], tokensPerTierTotal[_tier].sub(mintedPerTierTotal[_tier]), investedUSD, _tier);
            spentUSD = spentUSD.add(tierSpentUSD);
            mintedPerTier[uint8(_fundRaiseType)][_tier] = mintedPerTier[uint8(_fundRaiseType)][_tier].add(tierPurchasedTokens);
            mintedPerTierTotal[_tier] = mintedPerTierTotal[_tier].add(tierPurchasedTokens);
        }
        return spentUSD;
    }

    function _purchaseTier(
        address _beneficiary,
        uint256 _tierPrice,
        uint256 _tierRemaining,
        uint256 _investedUSD,
        uint8 _tier
    )
        internal
        returns(uint256, uint256)
    {
        uint256 maximumTokens = DecimalMath.div(_investedUSD, _tierPrice);
        uint256 spentUSD;
        uint256 purchasedTokens;
        if (maximumTokens > _tierRemaining) {
            spentUSD = DecimalMath.mul(_tierRemaining, _tierPrice);
            // In case of rounding issues, ensure that spentUSD is never more than investedUSD
            if (spentUSD > _investedUSD) {
                spentUSD = _investedUSD;
            }
            purchasedTokens = _tierRemaining;
        } else {
            spentUSD = _investedUSD;
            purchasedTokens = maximumTokens;
        }
        require(ISecurityToken(securityToken).mint(_beneficiary, purchasedTokens), "Error in minting");
        emit TokenPurchase(msg.sender, _beneficiary, purchasedTokens, spentUSD, _tierPrice, _tier);
        return (spentUSD, purchasedTokens);
    }

    /////////////
    // Getters //
    /////////////

    /**
     * @notice This function returns whether or not the STO is in fundraising mode (open)
     * @return bool Whether the STO is accepting investments
     */
    function isOpen() public view returns(bool) {
        if (isFinalized)
            return false;
        /*solium-disable-next-line security/no-block-members*/
        if (now < startTime)
            return false;
        /*solium-disable-next-line security/no-block-members*/
        if (now >= endTime)
            return false;
        if (capReached())
            return false;
        return true;
    }

    /**
     * @notice Checks whether the cap has been reached.
     * @return bool Whether the cap was reached
     */
    function capReached() public view returns (bool) {
        if (isFinalized) {
            return (finalAmountReturned == 0);
        }
        return (mintedPerTierTotal[mintedPerTierTotal.length - 1] == tokensPerTierTotal[tokensPerTierTotal.length - 1]);
    }

    function getRate(FundRaiseType _fundRaiseType) public view returns (uint256) {
        if (_fundRaiseType == FundRaiseType.ETH) {
            return IOracle(_getOracle(bytes32("ETH"), bytes32("USD"))).getPrice();
        } else if (_fundRaiseType == FundRaiseType.POLY) {
            return IOracle(_getOracle(bytes32("POLY"), bytes32("USD"))).getPrice();
        } else if (_fundRaiseType == FundRaiseType.DAI) {
            return 1 * 10**18;
        } else {
            revert("Incorrect funding");
        }
    }

    /**
     * @notice This function converts from ETH or POLY to USD
     * @param _fundRaiseType Currency key
     * @param _amount Value to convert to USD
     * @return uint256 Value in USD
     */
    function convertToUSD(FundRaiseType _fundRaiseType, uint256 _amount) public view returns(uint256) {
        uint256 rate = getRate(_fundRaiseType);
        return DecimalMath.mul(_amount, rate);
    }

    /**
     * @notice This function converts from USD to ETH or POLY
     * @param _fundRaiseType Currency key
     * @param _amount Value to convert from USD
     * @return uint256 Value in ETH or POLY
     */
    function convertFromUSD(FundRaiseType _fundRaiseType, uint256 _amount) public view returns(uint256) {
        uint256 rate = getRate(_fundRaiseType);
        return DecimalMath.div(_amount, rate);
    }

    /**
     * @notice Return the total no. of tokens sold
     * @return uint256 Total number of tokens sold
     */
    function getTokensSold() public view returns (uint256) {
        if (isFinalized)
            return totalTokensSold;
        else
            return getTokensMinted();
    }

    /**
     * @notice Return the total no. of tokens minted
     * @return uint256 Total number of tokens minted
     */
    function getTokensMinted() public view returns (uint256) {
        uint256 tokensMinted;
        for (uint8 i = 0; i < mintedPerTierTotal.length; i++) {
            tokensMinted = tokensMinted.add(mintedPerTierTotal[i]);
        }
        return tokensMinted;
    }

    /**
     * @notice Return the total no. of tokens sold for ETH
     * @return uint256 Total number of tokens sold for ETH
     */
    function getTokensSoldFor(FundRaiseType _fundRaiseType) public view returns (uint256) {
        uint256 tokensSold;
        for (uint8 i = 0; i < mintedPerTier[uint8(_fundRaiseType)].length; i++) {
            tokensSold = tokensSold.add(mintedPerTier[uint8(_fundRaiseType)][i]);
        }
        return tokensSold;
    }

    /**
     * @notice Return the total no. of tiers
     * @return uint256 Total number of tiers
     */
    function getNumberOfTiers() public view returns (uint256) {
        return tokensPerTierTotal.length;
    }

    /**
     * @notice Return the permissions flag that are associated with STO
     */
    function getPermissions() public view returns(bytes32[]) {
        bytes32[] memory allPermissions = new bytes32[](0);
        return allPermissions;
    }

    /**
     * @notice This function returns the signature of configure function
     * @return bytes4 Configure function signature
     */
    function getInitFunction() public pure returns (bytes4) {
        return 0xb0ff041e;
    }

    function _getOracle(bytes32 _currency, bytes32 _denominatedCurrency) internal view returns (address) {
        return PolymathRegistry(RegistryUpdater(securityToken).polymathRegistry()).getAddress(oracleKeys[_currency][_denominatedCurrency]);
    }

}