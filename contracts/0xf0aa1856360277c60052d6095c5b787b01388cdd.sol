pragma solidity ^0.4.24;

/**
 * @title Interface to be implemented by all permission manager modules
 */
interface IPermissionManager {

    /**
    * @notice Used to check the permission on delegate corresponds to module contract address
    * @param _delegate Ethereum address of the delegate
    * @param _module Ethereum contract address of the module
    * @param _perm Permission flag
    * @return bool
    */
    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns(bool);

    /**
    * @notice Used to add a delegate
    * @param _delegate Ethereum address of the delegate
    * @param _details Details about the delegate i.e `Belongs to financial firm`
    */
    function addDelegate(address _delegate, bytes32 _details) external;

    /**
    * @notice Used to delete a delegate
    * @param _delegate Ethereum address of the delegate
    */
    function deleteDelegate(address _delegate) external;

    /**
    * @notice Used to check if an address is a delegate or not
    * @param _potentialDelegate the address of potential delegate
    * @return bool
    */
    function checkDelegate(address _potentialDelegate) external view returns(bool);

    /**
    * @notice Used to provide/change the permission to the delegate corresponds to the module contract
    * @param _delegate Ethereum address of the delegate
    * @param _module Ethereum contract address of the module
    * @param _perm Permission flag
    * @param _valid Bool flag use to switch on/off the permission
    * @return bool
    */
    function changePermission(
        address _delegate,
        address _module,
        bytes32 _perm,
        bool _valid
    )
    external;

    /**
    * @notice Used to change one or more permissions for a single delegate at once
    * @param _delegate Ethereum address of the delegate
    * @param _modules Multiple module matching the multiperms, needs to be same length
    * @param _perms Multiple permission flag needs to be changed
    * @param _valids Bool array consist the flag to switch on/off the permission
    * @return nothing
    */
    function changePermissionMulti(
        address _delegate,
        address[] _modules,
        bytes32[] _perms,
        bool[] _valids
    )
    external;

    /**
    * @notice Used to return all delegates with a given permission and module
    * @param _module Ethereum contract address of the module
    * @param _perm Permission flag
    * @return address[]
    */
    function getAllDelegatesWithPerm(address _module, bytes32 _perm) external view returns(address[]);

     /**
    * @notice Used to return all permission of a single or multiple module
    * @dev possible that function get out of gas is there are lot of modules and perm related to them
    * @param _delegate Ethereum address of the delegate
    * @param _types uint8[] of types
    * @return address[] the address array of Modules this delegate has permission
    * @return bytes32[] the permission array of the corresponding Modules
    */
    function getAllModulesAndPermsFromTypes(address _delegate, uint8[] _types) external view returns(address[], bytes32[]);

    /**
    * @notice Used to get the Permission flag related the `this` contract
    * @return Array of permission flags
    */
    function getPermissions() external view returns(bytes32[]);

    /**
    * @notice Used to get all delegates
    * @return address[]
    */
    function getAllDelegates() external view returns(address[]);

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
 * @title Permission Manager module for core permissioning functionality
 */
contract GeneralPermissionManager is IPermissionManager, Module {

    // Mapping used to hold the permissions on the modules provided to delegate, module add => delegate add => permission bytes32 => bool 
    mapping (address => mapping (address => mapping (bytes32 => bool))) public perms;
    // Mapping hold the delagate details
    mapping (address => bytes32) public delegateDetails;
    // Array to track all delegates
    address[] public allDelegates;


    // Permission flag
    bytes32 public constant CHANGE_PERMISSION = "CHANGE_PERMISSION";

    /// Event emitted after any permission get changed for the delegate
    event ChangePermission(address indexed _delegate, address _module, bytes32 _perm, bool _valid, uint256 _timestamp);
    /// Used to notify when delegate is added in permission manager contract
    event AddDelegate(address indexed _delegate, bytes32 _details, uint256 _timestamp);


    /// @notice constructor
    constructor (address _securityToken, address _polyAddress) public
    Module(_securityToken, _polyAddress)
    {
    }

    /**
     * @notice Init function i.e generalise function to maintain the structure of the module contract
     * @return bytes4
     */
    function getInitFunction() public pure returns (bytes4) {
        return bytes4(0);
    }

    /**
     * @notice Used to check the permission on delegate corresponds to module contract address
     * @param _delegate Ethereum address of the delegate
     * @param _module Ethereum contract address of the module
     * @param _perm Permission flag
     * @return bool
     */
    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns(bool) {
        if (delegateDetails[_delegate] != bytes32(0)) {
            return perms[_module][_delegate][_perm];
        } else
            return false;
    }

    /**
     * @notice Used to add a delegate
     * @param _delegate Ethereum address of the delegate
     * @param _details Details about the delegate i.e `Belongs to financial firm`
     */
    function addDelegate(address _delegate, bytes32 _details) external withPerm(CHANGE_PERMISSION) {
        require(_delegate != address(0), "Invalid address");
        require(_details != bytes32(0), "0 value not allowed");
        require(delegateDetails[_delegate] == bytes32(0), "Already present");
        delegateDetails[_delegate] = _details;
        allDelegates.push(_delegate);
        /*solium-disable-next-line security/no-block-members*/
        emit AddDelegate(_delegate, _details, now);
    }

    /**
     * @notice Used to delete a delegate
     * @param _delegate Ethereum address of the delegate
     */
    function deleteDelegate(address _delegate) external withPerm(CHANGE_PERMISSION) {
        require(delegateDetails[_delegate] != bytes32(0), "delegate does not exist");
        for (uint256 i = 0; i < allDelegates.length; i++) {
            if (allDelegates[i] == _delegate) {
                allDelegates[i] = allDelegates[allDelegates.length - 1];
                allDelegates.length = allDelegates.length - 1;
            }
        }
        delete delegateDetails[_delegate];
    }

    /**
     * @notice Used to check if an address is a delegate or not
     * @param _potentialDelegate the address of potential delegate
     * @return bool
     */
    function checkDelegate(address _potentialDelegate) external view returns(bool) {
        require(_potentialDelegate != address(0), "Invalid address");

        if (delegateDetails[_potentialDelegate] != bytes32(0)) {
            return true;
        } else
            return false;
    }

    /**
     * @notice Used to provide/change the permission to the delegate corresponds to the module contract
     * @param _delegate Ethereum address of the delegate
     * @param _module Ethereum contract address of the module
     * @param _perm Permission flag
     * @param _valid Bool flag use to switch on/off the permission
     * @return bool
     */
    function changePermission(
        address _delegate,
        address _module,
        bytes32 _perm,
        bool _valid
    )
    public
    withPerm(CHANGE_PERMISSION)
    {
        require(_delegate != address(0), "invalid address");
        _changePermission(_delegate, _module, _perm, _valid);
    }

    /**
     * @notice Used to change one or more permissions for a single delegate at once
     * @param _delegate Ethereum address of the delegate
     * @param _modules Multiple module matching the multiperms, needs to be same length
     * @param _perms Multiple permission flag needs to be changed
     * @param _valids Bool array consist the flag to switch on/off the permission
     * @return nothing
     */
    function changePermissionMulti(
        address _delegate,
        address[] _modules,
        bytes32[] _perms,
        bool[] _valids
    )
    external
    withPerm(CHANGE_PERMISSION)
    {
        require(_delegate != address(0), "invalid address");
        require(_modules.length > 0, "0 length is not allowed");
        require(_modules.length == _perms.length, "Array length mismatch");
        require(_valids.length == _perms.length, "Array length mismatch");
        for(uint256 i = 0; i < _perms.length; i++) {
            _changePermission(_delegate, _modules[i], _perms[i], _valids[i]);
        }
    }

    /**
     * @notice Used to return all delegates with a given permission and module
     * @param _module Ethereum contract address of the module
     * @param _perm Permission flag
     * @return address[]
     */
    function getAllDelegatesWithPerm(address _module, bytes32 _perm) external view returns(address[]) {
        uint256 counter = 0;
        uint256 i = 0;
        for (i = 0; i < allDelegates.length; i++) {
            if (perms[_module][allDelegates[i]][_perm]) {
                counter++;
            }
        }
        address[] memory allDelegatesWithPerm = new address[](counter);
        counter = 0;
        for (i = 0; i < allDelegates.length; i++) {
            if (perms[_module][allDelegates[i]][_perm]){
                allDelegatesWithPerm[counter] = allDelegates[i];
                counter++;
            }
        }
        return allDelegatesWithPerm;
    }

    /**
     * @notice Used to return all permission of a single or multiple module
     * @dev possible that function get out of gas is there are lot of modules and perm related to them
     * @param _delegate Ethereum address of the delegate
     * @param _types uint8[] of types
     * @return address[] the address array of Modules this delegate has permission
     * @return bytes32[] the permission array of the corresponding Modules
     */
    function getAllModulesAndPermsFromTypes(address _delegate, uint8[] _types) external view returns(address[], bytes32[]) {
        uint256 counter = 0;
        // loop through _types and get their modules from securityToken->getModulesByType
        for (uint256 i = 0; i < _types.length; i++) {
            address[] memory _currentTypeModules = ISecurityToken(securityToken).getModulesByType(_types[i]);
            // loop through each modules to get their perms from IModule->getPermissions
            for (uint256 j = 0; j < _currentTypeModules.length; j++){
                bytes32[] memory _allModulePerms = IModule(_currentTypeModules[j]).getPermissions();
                // loop through each perm, if it is true, push results into arrays
                for (uint256 k = 0; k < _allModulePerms.length; k++) {
                    if (perms[_currentTypeModules[j]][_delegate][_allModulePerms[k]]) {
                        counter ++;
                    }
                }
            }
        }

        address[] memory _allModules = new address[](counter);
        bytes32[] memory _allPerms = new bytes32[](counter);
        counter = 0;

        for (i = 0; i < _types.length; i++){
            _currentTypeModules = ISecurityToken(securityToken).getModulesByType(_types[i]);
            for (j = 0; j < _currentTypeModules.length; j++) {
                _allModulePerms = IModule(_currentTypeModules[j]).getPermissions();
                for (k = 0; k < _allModulePerms.length; k++) {
                    if (perms[_currentTypeModules[j]][_delegate][_allModulePerms[k]]) {
                        _allModules[counter] = _currentTypeModules[j];
                        _allPerms[counter] = _allModulePerms[k];
                        counter++;
                    }
                }
            }
        }

        return(_allModules, _allPerms);
    }

    /**
     * @notice Used to provide/change the permission to the delegate corresponds to the module contract
     * @param _delegate Ethereum address of the delegate
     * @param _module Ethereum contract address of the module
     * @param _perm Permission flag
     * @param _valid Bool flag use to switch on/off the permission
     * @return bool
     */
    function _changePermission(
        address _delegate,
        address _module,
        bytes32 _perm,
        bool _valid
    )
     internal
    {
        perms[_module][_delegate][_perm] = _valid;
        /*solium-disable-next-line security/no-block-members*/
        emit ChangePermission(_delegate, _module, _perm, _valid, now);
    }

    /**
     * @notice Used to get all delegates
     * @return address[]
     */
    function getAllDelegates() external view returns(address[]) {
        return allDelegates;
    }
    
    /**
    * @notice Returns the Permission flag related the `this` contract
    * @return Array of permission flags
    */
    function getPermissions() public view returns(bytes32[]) {
        bytes32[] memory allPermissions = new bytes32[](1);
        allPermissions[0] = CHANGE_PERMISSION;
        return allPermissions;
    }

}

/**
 * @title Interface that every module factory contract should implement
 */
interface IModuleFactory {

    event ChangeFactorySetupFee(uint256 _oldSetupCost, uint256 _newSetupCost, address _moduleFactory);
    event ChangeFactoryUsageFee(uint256 _oldUsageCost, uint256 _newUsageCost, address _moduleFactory);
    event ChangeFactorySubscriptionFee(uint256 _oldSubscriptionCost, uint256 _newMonthlySubscriptionCost, address _moduleFactory);
    event GenerateModuleFromFactory(
        address _module,
        bytes32 indexed _moduleName,
        address indexed _moduleFactory,
        address _creator,
        uint256 _setupCost,
        uint256 _timestamp
    );
    event ChangeSTVersionBound(string _boundType, uint8 _major, uint8 _minor, uint8 _patch);

    //Should create an instance of the Module, or throw
    function deploy(bytes _data) external returns(address);

    /**
     * @notice Type of the Module factory
     */
    function getTypes() external view returns(uint8[]);

    /**
     * @notice Get the name of the Module
     */
    function getName() external view returns(bytes32);

    /**
     * @notice Returns the instructions associated with the module
     */
    function getInstructions() external view returns (string);

    /**
     * @notice Get the tags related to the module factory
     */
    function getTags() external view returns (bytes32[]);

    /**
     * @notice Used to change the setup fee
     * @param _newSetupCost New setup fee
     */
    function changeFactorySetupFee(uint256 _newSetupCost) external;

    /**
     * @notice Used to change the usage fee
     * @param _newUsageCost New usage fee
     */
    function changeFactoryUsageFee(uint256 _newUsageCost) external;

    /**
     * @notice Used to change the subscription fee
     * @param _newSubscriptionCost New subscription fee
     */
    function changeFactorySubscriptionFee(uint256 _newSubscriptionCost) external;

    /**
     * @notice Function use to change the lower and upper bound of the compatible version st
     * @param _boundType Type of bound
     * @param _newVersion New version array
     */
    function changeSTVersionBounds(string _boundType, uint8[] _newVersion) external;

   /**
     * @notice Get the setup cost of the module
     */
    function getSetupCost() external view returns (uint256);

    /**
     * @notice Used to get the lower bound
     * @return Lower bound
     */
    function getLowerSTVersionBounds() external view returns(uint8[]);

     /**
     * @notice Used to get the upper bound
     * @return Upper bound
     */
    function getUpperSTVersionBounds() external view returns(uint8[]);

}

/**
 * @title Helper library use to compare or validate the semantic versions
 */

library VersionUtils {

    /**
     * @notice This function is used to validate the version submitted
     * @param _current Array holds the present version of ST
     * @param _new Array holds the latest version of the ST
     * @return bool
     */
    function isValidVersion(uint8[] _current, uint8[] _new) internal pure returns(bool) {
        bool[] memory _temp = new bool[](_current.length);
        uint8 counter = 0;
        for (uint8 i = 0; i < _current.length; i++) {
            if (_current[i] < _new[i])
                _temp[i] = true;
            else
                _temp[i] = false;
        }

        for (i = 0; i < _current.length; i++) {
            if (i == 0) {
                if (_current[i] <= _new[i])
                    if(_temp[0]) {
                        counter = counter + 3;
                        break;
                    } else
                        counter++;
                else
                    return false;
            } else {
                if (_temp[i-1])
                    counter++;
                else if (_current[i] <= _new[i])
                    counter++;
                else
                    return false;
            }
        }
        if (counter == _current.length)
            return true;
    }

    /**
     * @notice Used to compare the lower bound with the latest version
     * @param _version1 Array holds the lower bound of the version
     * @param _version2 Array holds the latest version of the ST
     * @return bool
     */
    function compareLowerBound(uint8[] _version1, uint8[] _version2) internal pure returns(bool) {
        require(_version1.length == _version2.length, "Input length mismatch");
        uint counter = 0;
        for (uint8 j = 0; j < _version1.length; j++) {
            if (_version1[j] == 0)
                counter ++;
        }
        if (counter != _version1.length) {
            counter = 0;
            for (uint8 i = 0; i < _version1.length; i++) {
                if (_version2[i] > _version1[i])
                    return true;
                else if (_version2[i] < _version1[i])
                    return false;
                else
                    counter++;
            }
            if (counter == _version1.length - 1)
                return true;
            else
                return false;
        } else
            return true;
    }

    /**
     * @notice Used to compare the upper bound with the latest version
     * @param _version1 Array holds the upper bound of the version
     * @param _version2 Array holds the latest version of the ST
     * @return bool
     */
    function compareUpperBound(uint8[] _version1, uint8[] _version2) internal pure returns(bool) {
        require(_version1.length == _version2.length, "Input length mismatch");
        uint counter = 0;
        for (uint8 j = 0; j < _version1.length; j++) {
            if (_version1[j] == 0)
                counter ++;
        }
        if (counter != _version1.length) {
            counter = 0;
            for (uint8 i = 0; i < _version1.length; i++) {
                if (_version1[i] > _version2[i])
                    return true;
                else if (_version1[i] < _version2[i])
                    return false;
                else
                    counter++;
            }
            if (counter == _version1.length - 1)
                return true;
            else
                return false;
        } else
            return true;
    }


    /**
     * @notice Used to pack the uint8[] array data into uint24 value
     * @param _major Major version
     * @param _minor Minor version
     * @param _patch Patch version
     */
    function pack(uint8 _major, uint8 _minor, uint8 _patch) internal pure returns(uint24) {
        return (uint24(_major) << 16) | (uint24(_minor) << 8) | uint24(_patch);
    }

    /**
     * @notice Used to convert packed data into uint8 array
     * @param _packedVersion Packed data
     */
    function unpack(uint24 _packedVersion) internal pure returns (uint8[]) {
        uint8[] memory _unpackVersion = new uint8[](3);
        _unpackVersion[0] = uint8(_packedVersion >> 16);
        _unpackVersion[1] = uint8(_packedVersion >> 8);
        _unpackVersion[2] = uint8(_packedVersion);
        return _unpackVersion;
    }


}

/**
 * @title Interface that any module factory contract should implement
 * @notice Contract is abstract
 */
contract ModuleFactory is IModuleFactory, Ownable {

    IERC20 public polyToken;
    uint256 public usageCost;
    uint256 public monthlySubscriptionCost;

    uint256 public setupCost;
    string public description;
    string public version;
    bytes32 public name;
    string public title;

    // @notice Allow only two variables to be stored
    // 1. lowerBound 
    // 2. upperBound
    // @dev (0.0.0 will act as the wildcard) 
    // @dev uint24 consists packed value of uint8 _major, uint8 _minor, uint8 _patch
    mapping(string => uint24) compatibleSTVersionRange;

    event ChangeFactorySetupFee(uint256 _oldSetupCost, uint256 _newSetupCost, address _moduleFactory);
    event ChangeFactoryUsageFee(uint256 _oldUsageCost, uint256 _newUsageCost, address _moduleFactory);
    event ChangeFactorySubscriptionFee(uint256 _oldSubscriptionCost, uint256 _newMonthlySubscriptionCost, address _moduleFactory);
    event GenerateModuleFromFactory(
        address _module,
        bytes32 indexed _moduleName,
        address indexed _moduleFactory,
        address _creator,
        uint256 _timestamp
    );
    event ChangeSTVersionBound(string _boundType, uint8 _major, uint8 _minor, uint8 _patch);

    /**
     * @notice Constructor
     * @param _polyAddress Address of the polytoken
     */
    constructor (address _polyAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost) public {
        polyToken = IERC20(_polyAddress);
        setupCost = _setupCost;
        usageCost = _usageCost;
        monthlySubscriptionCost = _subscriptionCost;
    }

    /**
     * @notice Used to change the fee of the setup cost
     * @param _newSetupCost new setup cost
     */
    function changeFactorySetupFee(uint256 _newSetupCost) public onlyOwner {
        emit ChangeFactorySetupFee(setupCost, _newSetupCost, address(this));
        setupCost = _newSetupCost;
    }

    /**
     * @notice Used to change the fee of the usage cost
     * @param _newUsageCost new usage cost
     */
    function changeFactoryUsageFee(uint256 _newUsageCost) public onlyOwner {
        emit ChangeFactoryUsageFee(usageCost, _newUsageCost, address(this));
        usageCost = _newUsageCost;
    }

    /**
     * @notice Used to change the fee of the subscription cost
     * @param _newSubscriptionCost new subscription cost
     */
    function changeFactorySubscriptionFee(uint256 _newSubscriptionCost) public onlyOwner {
        emit ChangeFactorySubscriptionFee(monthlySubscriptionCost, _newSubscriptionCost, address(this));
        monthlySubscriptionCost = _newSubscriptionCost;

    }

    /**
     * @notice Updates the title of the ModuleFactory
     * @param _newTitle New Title that will replace the old one.
     */
    function changeTitle(string _newTitle) public onlyOwner {
        require(bytes(_newTitle).length > 0, "Invalid title");
        title = _newTitle;
    }

    /**
     * @notice Updates the description of the ModuleFactory
     * @param _newDesc New description that will replace the old one.
     */
    function changeDescription(string _newDesc) public onlyOwner {
        require(bytes(_newDesc).length > 0, "Invalid description");
        description = _newDesc;
    }

    /**
     * @notice Updates the name of the ModuleFactory
     * @param _newName New name that will replace the old one.
     */
    function changeName(bytes32 _newName) public onlyOwner {
        require(_newName != bytes32(0),"Invalid name");
        name = _newName;
    }

    /**
     * @notice Updates the version of the ModuleFactory
     * @param _newVersion New name that will replace the old one.
     */
    function changeVersion(string _newVersion) public onlyOwner {
        require(bytes(_newVersion).length > 0, "Invalid version");
        version = _newVersion;
    }

    /**
     * @notice Function use to change the lower and upper bound of the compatible version st
     * @param _boundType Type of bound
     * @param _newVersion new version array
     */
    function changeSTVersionBounds(string _boundType, uint8[] _newVersion) external onlyOwner {
        require(
            keccak256(abi.encodePacked(_boundType)) == keccak256(abi.encodePacked("lowerBound")) ||
            keccak256(abi.encodePacked(_boundType)) == keccak256(abi.encodePacked("upperBound")),
            "Must be a valid bound type"
        );
        require(_newVersion.length == 3);
        if (compatibleSTVersionRange[_boundType] != uint24(0)) { 
            uint8[] memory _currentVersion = VersionUtils.unpack(compatibleSTVersionRange[_boundType]);
            require(VersionUtils.isValidVersion(_currentVersion, _newVersion), "Failed because of in-valid version");
        }
        compatibleSTVersionRange[_boundType] = VersionUtils.pack(_newVersion[0], _newVersion[1], _newVersion[2]);
        emit ChangeSTVersionBound(_boundType, _newVersion[0], _newVersion[1], _newVersion[2]);
    }

    /**
     * @notice Used to get the lower bound
     * @return lower bound
     */
    function getLowerSTVersionBounds() external view returns(uint8[]) {
        return VersionUtils.unpack(compatibleSTVersionRange["lowerBound"]);
    }

    /**
     * @notice Used to get the upper bound
     * @return upper bound
     */
    function getUpperSTVersionBounds() external view returns(uint8[]) {
        return VersionUtils.unpack(compatibleSTVersionRange["upperBound"]);
    }

    /**
     * @notice Get the setup cost of the module
     */
    function getSetupCost() external view returns (uint256) {
        return setupCost;
    }

   /**
    * @notice Get the name of the Module
    */
    function getName() public view returns(bytes32) {
        return name;
    }

}

/**
 * @title Factory for deploying GeneralPermissionManager module
 */
contract GeneralPermissionManagerFactory is ModuleFactory {

    /**
     * @notice Constructor
     * @param _polyAddress Address of the polytoken
     */
    constructor (address _polyAddress, uint256 _setupCost, uint256 _usageCost, uint256 _subscriptionCost) public
    ModuleFactory(_polyAddress, _setupCost, _usageCost, _subscriptionCost)
    {
        version = "1.0.0";
        name = "GeneralPermissionManager";
        title = "General Permission Manager";
        description = "Manage permissions within the Security Token and attached modules";
        compatibleSTVersionRange["lowerBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));
        compatibleSTVersionRange["upperBound"] = VersionUtils.pack(uint8(0), uint8(0), uint8(0));
    }

    /**
     * @notice Used to launch the Module with the help of factory
     * @return address Contract address of the Module
     */
    function deploy(bytes /* _data */) external returns(address) {
        if(setupCost > 0)
            require(polyToken.transferFrom(msg.sender, owner, setupCost), "Failed transferFrom due to insufficent Allowance provided");
        address permissionManager = new GeneralPermissionManager(msg.sender, address(polyToken));
        /*solium-disable-next-line security/no-block-members*/
        emit GenerateModuleFromFactory(address(permissionManager), getName(), address(this), msg.sender, setupCost, now);
        return permissionManager;
    }

    /**
     * @notice Type of the Module factory
     */
    function getTypes() external view returns(uint8[]) {
        uint8[] memory res = new uint8[](1);
        res[0] = 1;
        return res;
    }

    /**
     * @notice Returns the instructions associated with the module
     */
    function getInstructions() external view returns(string) {
        /*solium-disable-next-line max-len*/
        return "Add and remove permissions for the SecurityToken and associated modules. Permission types should be encoded as bytes32 values and attached using withPerm modifier to relevant functions. No initFunction required.";
    }

    /**
     * @notice Get the tags related to the module factory
     */
    function getTags() external view returns(bytes32[]) {
        bytes32[] memory availableTags = new bytes32[](0);
        return availableTags;
    }
}