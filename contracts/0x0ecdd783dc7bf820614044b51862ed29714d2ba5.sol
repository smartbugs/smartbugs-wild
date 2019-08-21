pragma solidity ^0.4.24;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
// input  D:\MDZA-TESTNET1\solidity-flattener\SolidityFlatteryGo\zos-lib\contracts\application\App.sol
// flattened :  Tuesday, 09-Apr-19 18:16:04 UTC
contract Proxy {
  /**
   * @dev Fallback function.
   * Implemented entirely in `_fallback`.
   */
  function () payable external {
    _fallback();
  }

  /**
   * @return The Address of the implementation.
   */
  function _implementation() internal view returns (address);

  /**
   * @dev Delegates execution to an implementation contract.
   * This is a low level function that doesn't return to its internal call site.
   * It will return to the external caller whatever the implementation returns.
   * @param implementation Address to delegate.
   */
  function _delegate(address implementation) internal {
    assembly {
      // Copy msg.data. We take full control of memory in this inline assembly
      // block because it will not return to Solidity code. We overwrite the
      // Solidity scratch pad at memory position 0.
      calldatacopy(0, 0, calldatasize)

      // Call the implementation.
      // out and outsize are 0 because we don't know the size yet.
      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      // Copy the returned data.
      returndatacopy(0, 0, returndatasize)

      switch result
      // delegatecall returns 0 on error.
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  /**
   * @dev Function that is run as the first thing in the fallback function.
   * Can be redefined in derived contracts to add functionality.
   * Redefinitions must call super._willFallback().
   */
  function _willFallback() internal {
  }

  /**
   * @dev fallback implementation.
   * Extracted to enable manual triggering.
   */
  function _fallback() internal {
    _willFallback();
    _delegate(_implementation());
  }
}

library ZOSLibAddress {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param account address of the account to check
   * @return whether the target address is a contract
   */
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(account) }
    return size > 0;
  }

}
interface ImplementationProvider {
  /**
   * @dev Abstract function to return the implementation address of a contract.
   * @param contractName Name of the contract.
   * @return Implementation address of the contract.
   */
  function getImplementation(string contractName) public view returns (address);
}


contract ZOSLibOwnable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
contract Package is ZOSLibOwnable {
  /**
   * @dev Emitted when a version is added to the package.
   * @param semanticVersion Name of the added version.
   * @param contractAddress Contract associated with the version.
   * @param contentURI Optional content URI with metadata of the version.
   */
  event VersionAdded(uint64[3] semanticVersion, address contractAddress, bytes contentURI);

  struct Version {
    uint64[3] semanticVersion;
    address contractAddress;
    bytes contentURI; 
  }

  mapping (bytes32 => Version) internal versions;
  mapping (uint64 => bytes32) internal majorToLatestVersion;
  uint64 internal latestMajor;

  /**
   * @dev Returns a version given its semver identifier.
   * @param semanticVersion Semver identifier of the version.
   * @return Contract address and content URI for the version, or zero if not exists.
   */
  function getVersion(uint64[3] semanticVersion) public view returns (address contractAddress, bytes contentURI) {
    Version storage version = versions[semanticVersionHash(semanticVersion)];
    return (version.contractAddress, version.contentURI); 
  }

  /**
   * @dev Returns a contract for a version given its semver identifier.
   * This method is equivalent to `getVersion`, but returns only the contract address.
   * @param semanticVersion Semver identifier of the version.
   * @return Contract address for the version, or zero if not exists.
   */
  function getContract(uint64[3] semanticVersion) public view returns (address contractAddress) {
    Version storage version = versions[semanticVersionHash(semanticVersion)];
    return version.contractAddress;
  }

  /**
   * @dev Adds a new version to the package. Only the Owner can add new versions.
   * Reverts if the specified semver identifier already exists. 
   * Emits a `VersionAdded` event if successful.
   * @param semanticVersion Semver identifier of the version.
   * @param contractAddress Contract address for the version, must be non-zero.
   * @param contentURI Optional content URI for the version.
   */
  function addVersion(uint64[3] semanticVersion, address contractAddress, bytes contentURI) public onlyOwner {
    require(contractAddress != address(0), "Contract address is required");
    require(!hasVersion(semanticVersion), "Given version is already registered in package");
    require(!semanticVersionIsZero(semanticVersion), "Version must be non zero");

    // Register version
    bytes32 versionId = semanticVersionHash(semanticVersion);
    versions[versionId] = Version(semanticVersion, contractAddress, contentURI);
    
    // Update latest major
    uint64 major = semanticVersion[0];
    if (major > latestMajor) {
      latestMajor = semanticVersion[0];
    }

    // Update latest version for this major
    uint64 minor = semanticVersion[1];
    uint64 patch = semanticVersion[2];
    uint64[3] latestVersionForMajor = versions[majorToLatestVersion[major]].semanticVersion;
    if (semanticVersionIsZero(latestVersionForMajor) // No latest was set for this major
       || (minor > latestVersionForMajor[1]) // Or current minor is greater 
       || (minor == latestVersionForMajor[1] && patch > latestVersionForMajor[2]) // Or current patch is greater
       ) { 
      majorToLatestVersion[major] = versionId;
    }

    emit VersionAdded(semanticVersion, contractAddress, contentURI);
  }

  /**
   * @dev Checks whether a version is present in the package.
   * @param semanticVersion Semver identifier of the version.
   * @return true if the version is registered in this package, false otherwise.
   */
  function hasVersion(uint64[3] semanticVersion) public view returns (bool) {
    Version storage version = versions[semanticVersionHash(semanticVersion)];
    return address(version.contractAddress) != address(0);
  }

  /**
   * @dev Returns the version with the highest semver identifier registered in the package.
   * For instance, if `1.2.0`, `1.3.0`, and `2.0.0` are present, will always return `2.0.0`, regardless 
   * of the order in which they were registered. Returns zero if no versions are registered.
   * @return Semver identifier, contract address, and content URI for the version, or zero if not exists.
   */
  function getLatest() public view returns (uint64[3] semanticVersion, address contractAddress, bytes contentURI) {
    return getLatestByMajor(latestMajor);
  }

  /**
   * @dev Returns the version with the highest semver identifier for the given major.
   * For instance, if `1.2.0`, `1.3.0`, and `2.0.0` are present, will return `1.3.0` for major `1`, 
   * regardless of the order in which they were registered. Returns zero if no versions are registered
   * for the specified major.
   * @param major Major identifier to query
   * @return Semver identifier, contract address, and content URI for the version, or zero if not exists.
   */
  function getLatestByMajor(uint64 major) public view returns (uint64[3] semanticVersion, address contractAddress, bytes contentURI) {
    Version storage version = versions[majorToLatestVersion[major]];
    return (version.semanticVersion, version.contractAddress, version.contentURI); 
  }

  function semanticVersionHash(uint64[3] version) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(version[0], version[1], version[2]));
  }

  function semanticVersionIsZero(uint64[3] version) internal pure returns (bool) {
    return version[0] == 0 && version[1] == 0 && version[2] == 0;
  }
}

contract UpgradeabilityProxy is Proxy {
  /**
   * @dev Emitted when the implementation is upgraded.
   * @param implementation Address of the new implementation.
   */
  event Upgraded(address indexed implementation);

  /**
   * @dev Storage slot with the address of the current implementation.
   * This is the keccak-256 hash of "org.zeppelinos.proxy.implementation", and is
   * validated in the constructor.
   */
  bytes32 private constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;

  /**
   * @dev Contract constructor.
   * @param _implementation Address of the initial implementation.
   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  constructor(address _implementation, bytes _data) public payable {
    assert(IMPLEMENTATION_SLOT == keccak256("org.zeppelinos.proxy.implementation"));
    _setImplementation(_implementation);
    if(_data.length > 0) {
      require(_implementation.delegatecall(_data));
    }
  }

  /**
   * @dev Returns the current implementation.
   * @return Address of the current implementation
   */
  function _implementation() internal view returns (address impl) {
    bytes32 slot = IMPLEMENTATION_SLOT;
    assembly {
      impl := sload(slot)
    }
  }

  /**
   * @dev Upgrades the proxy to a new implementation.
   * @param newImplementation Address of the new implementation.
   */
  function _upgradeTo(address newImplementation) internal {
    _setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }

  /**
   * @dev Sets the implementation address of the proxy.
   * @param newImplementation Address of the new implementation.
   */
  function _setImplementation(address newImplementation) private {
    require(ZOSLibAddress.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}

contract AdminUpgradeabilityProxy is UpgradeabilityProxy {
  /**
   * @dev Emitted when the administration has been transferred.
   * @param previousAdmin Address of the previous admin.
   * @param newAdmin Address of the new admin.
   */
  event AdminChanged(address previousAdmin, address newAdmin);

  /**
   * @dev Storage slot with the admin of the contract.
   * This is the keccak-256 hash of "org.zeppelinos.proxy.admin", and is
   * validated in the constructor.
   */
  bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

  /**
   * @dev Modifier to check whether the `msg.sender` is the admin.
   * If it is, it will run the function. Otherwise, it will delegate the call
   * to the implementation.
   */
  modifier ifAdmin() {
    if (msg.sender == _admin()) {
      _;
    } else {
      _fallback();
    }
  }

  /**
   * Contract constructor.
   * @param _implementation address of the initial implementation.
   * @param _admin Address of the proxy administrator.
   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   */
  constructor(address _implementation, address _admin, bytes _data) UpgradeabilityProxy(_implementation, _data) public payable {
    assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));

    _setAdmin(_admin);
  }

  /**
   * @return The address of the proxy admin.
   */
  function admin() external view ifAdmin returns (address) {
    return _admin();
  }

  /**
   * @return The address of the implementation.
   */
  function implementation() external view ifAdmin returns (address) {
    return _implementation();
  }

  /**
   * @dev Changes the admin of the proxy.
   * Only the current admin can call this function.
   * @param newAdmin Address to transfer proxy administration to.
   */
  function changeAdmin(address newAdmin) external ifAdmin {
    require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  /**
   * @dev Upgrade the backing implementation of the proxy.
   * Only the admin can call this function.
   * @param newImplementation Address of the new implementation.
   */
  function upgradeTo(address newImplementation) external ifAdmin {
    _upgradeTo(newImplementation);
  }

  /**
   * @dev Upgrade the backing implementation of the proxy and call a function
   * on the new implementation.
   * This is useful to initialize the proxied contract.
   * @param newImplementation Address of the new implementation.
   * @param data Data to send as msg.data in the low level call.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   */
  function upgradeToAndCall(address newImplementation, bytes data) payable external ifAdmin {
    _upgradeTo(newImplementation);
    require(newImplementation.delegatecall(data));
  }

  /**
   * @return The admin slot.
   */
  function _admin() internal view returns (address adm) {
    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  /**
   * @dev Sets the address of the proxy admin.
   * @param newAdmin Address of the new proxy admin.
   */
  function _setAdmin(address newAdmin) internal {
    bytes32 slot = ADMIN_SLOT;

    assembly {
      sstore(slot, newAdmin)
    }
  }

  /**
   * @dev Only fall back when the sender is not the admin.
   */
  function _willFallback() internal {
    require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
    super._willFallback();
  }
}

contract App is ZOSLibOwnable {
  /**
   * @dev Emitted when a new proxy is created.
   * @param proxy Address of the created proxy.
   */
  event ProxyCreated(address proxy);

  /**
   * @dev Emitted when a package dependency is changed in the application.
   * @param providerName Name of the package that changed.
   * @param package Address of the package associated to the name.
   * @param version Version of the package in use.
   */
  event PackageChanged(string providerName, address package, uint64[3] version);

  /**
   * @dev Tracks a package in a particular version, used for retrieving implementations
   */
  struct ProviderInfo {
    Package package;
    uint64[3] version;
  }

  /**
   * @dev Maps from dependency name to a tuple of package and version
   */
  mapping(string => ProviderInfo) internal providers;

  /**
   * @dev Constructor function.
   */
  constructor() public { }

  /**
   * @dev Returns the provider for a given package name, or zero if not set.
   * @param packageName Name of the package to be retrieved.
   * @return The provider.
   */
  function getProvider(string packageName) public view returns (ImplementationProvider provider) {
    ProviderInfo storage info = providers[packageName];
    if (address(info.package) == address(0)) return ImplementationProvider(0);
    return ImplementationProvider(info.package.getContract(info.version));
  }

  /**
   * @dev Returns information on a package given its name.
   * @param packageName Name of the package to be queried.
   * @return A tuple with the package address and pinned version given a package name, or zero if not set
   */
  function getPackage(string packageName) public view returns (Package, uint64[3]) {
    ProviderInfo storage info = providers[packageName];
    return (info.package, info.version);
  }

  /**
   * @dev Sets a package in a specific version as a dependency for this application.
   * Requires the version to be present in the package.
   * @param packageName Name of the package to set or overwrite.
   * @param package Address of the package to register.
   * @param version Version of the package to use in this application.
   */
  function setPackage(string packageName, Package package, uint64[3] version) public onlyOwner {
    require(package.hasVersion(version), "The requested version must be registered in the given package");
    providers[packageName] = ProviderInfo(package, version);
    emit PackageChanged(packageName, package, version);
  }

  /**
   * @dev Unsets a package given its name.
   * Reverts if the package is not set in the application.
   * @param packageName Name of the package to remove.
   */
  function unsetPackage(string packageName) public onlyOwner {
    require(address(providers[packageName].package) != address(0), "Package to unset not found");
    delete providers[packageName];
    emit PackageChanged(packageName, address(0), [uint64(0), uint64(0), uint64(0)]);
  }

  /**
   * @dev Returns the implementation address for a given contract name, provided by the `ImplementationProvider`.
   * @param packageName Name of the package where the contract is contained.
   * @param contractName Name of the contract.
   * @return Address where the contract is implemented.
   */
  function getImplementation(string packageName, string contractName) public view returns (address) {
    ImplementationProvider provider = getProvider(packageName);
    if (address(provider) == address(0)) return address(0);
    return provider.getImplementation(contractName);
  }

  /**
   * @dev Creates a new proxy for the given contract and forwards a function call to it.
   * This is useful to initialize the proxied contract.
   * @param packageName Name of the package where the contract is contained.
   * @param contractName Name of the contract.
   * @param admin Address of the proxy administrator.
   * @param data Data to send as msg.data to the corresponding implementation to initialize the proxied contract.
   * It should include the signature and the parameters of the function to be called, as described in
   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.
   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.
   * @return Address of the new proxy.
   */
   function create(string packageName, string contractName, address admin, bytes data) payable public returns (AdminUpgradeabilityProxy) {
     address implementation = getImplementation(packageName, contractName);
     AdminUpgradeabilityProxy proxy = (new AdminUpgradeabilityProxy).value(msg.value)(implementation, admin, data);
     emit ProxyCreated(proxy);
     return proxy;
  }
}