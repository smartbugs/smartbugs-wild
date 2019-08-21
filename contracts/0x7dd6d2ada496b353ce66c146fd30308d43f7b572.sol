pragma solidity ^0.4.24;

// File: node_modules/zos-lib/contracts/application/versioning/ImplementationProvider.sol

/**
 * @title ImplementationProvider
 * @dev Interface for providing implementation addresses for other contracts by name.
 */
interface ImplementationProvider {
  /**
   * @dev Abstract function to return the implementation address of a contract.
   * @param contractName Name of the contract.
   * @return Implementation address of the contract.
   */
  function getImplementation(string contractName) public view returns (address);
}

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

// File: node_modules/zos-lib/contracts/application/versioning/Package.sol

/**
 * @title Package
 * @dev Collection of contracts grouped into versions.
 * Contracts with the same name can have different implementation addresses in different versions.
 */
contract Package is Ownable {
  /**
   * @dev Emitted when a version is added to the package.
   * XXX The version is not indexed due to truffle testing constraints.
   * @param version Name of the added version.
   * @param provider ImplementationProvider associated with the version.
   */
  event VersionAdded(string version, ImplementationProvider provider);

  /*
   * @dev Mapping associating versions and their implementation providers.
   */
  mapping (string => ImplementationProvider) internal versions;

  /**
   * @dev Returns the implementation provider of a version.
   * @param version Name of the version.
   * @return The implementation provider of the version.
   */
  function getVersion(string version) public view returns (ImplementationProvider) {
    ImplementationProvider provider = versions[version];
    return provider;
  }

  /**
   * @dev Adds the implementation provider of a new version to the package.
   * @param version Name of the version.
   * @param provider ImplementationProvider associated with the version.
   */
  function addVersion(string version, ImplementationProvider provider) public onlyOwner {
    require(!hasVersion(version), "Given version is already registered in package");
    versions[version] = provider;
    emit VersionAdded(version, provider);
  }

  /**
   * @dev Checks whether a version is present in the package.
   * @param version Name of the version.
   * @return true if the version is already in the package, false otherwise.
   */
  function hasVersion(string version) public view returns (bool) {
    return address(versions[version]) != address(0);
  }

  /**
   * @dev Returns the implementation address for a given version and contract name.
   * @param version Name of the version.
   * @param contractName Name of the contract.
   * @return Address where the contract is implemented.
   */
  function getImplementation(string version, string contractName) public view returns (address) {
    ImplementationProvider provider = getVersion(version);
    return provider.getImplementation(contractName);
  }
}