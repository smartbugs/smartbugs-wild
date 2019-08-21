pragma solidity ^0.4.24;

// File: /home/blackjak/Projects/winding-tree/wt-contracts/node_modules/zos-lib/contracts/application/ImplementationProvider.sol

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

// File: openzeppelin-solidity/contracts/AddressUtils.sol

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param _addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address _addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}

// File: node_modules/zos-lib/contracts/application/ImplementationDirectory.sol

/**
 * @title ImplementationDirectory
 * @dev Implementation provider that stores contract implementations in a mapping.
 */
contract ImplementationDirectory is ImplementationProvider, Ownable {
  /**
   * @dev Emitted when the implementation of a contract is changed.
   * @param contractName Name of the contract.
   * @param implementation Address of the added implementation.
   */
  event ImplementationChanged(string contractName, address indexed implementation);

  /**
   * @dev Emitted when the implementation directory is frozen.
   */
  event Frozen();

  /// @dev Mapping where the addresses of the implementations are stored.
  mapping (string => address) internal implementations;

  /// @dev Mutability state of the directory.
  bool public frozen;

  /**
   * @dev Modifier that allows functions to be called only before the contract is frozen.
   */
  modifier whenNotFrozen() {
    require(!frozen, "Cannot perform action for a frozen implementation directory");
    _;
  }

  /**
   * @dev Makes the directory irreversibly immutable.
   * It can only be called once, by the owner.
   */
  function freeze() onlyOwner whenNotFrozen public {
    frozen = true;
    emit Frozen();
  }

  /**
   * @dev Returns the implementation address of a contract.
   * @param contractName Name of the contract.
   * @return Address of the implementation.
   */
  function getImplementation(string contractName) public view returns (address) {
    return implementations[contractName];
  }

  /**
   * @dev Sets the address of the implementation of a contract in the directory.
   * @param contractName Name of the contract.
   * @param implementation Address of the implementation.
   */
  function setImplementation(string contractName, address implementation) public onlyOwner whenNotFrozen {
    require(AddressUtils.isContract(implementation), "Cannot set implementation in directory with a non-contract address");
    implementations[contractName] = implementation;
    emit ImplementationChanged(contractName, implementation);
  }

  /**
   * @dev Removes the address of a contract implementation from the directory.
   * @param contractName Name of the contract.
   */
  function unsetImplementation(string contractName) public onlyOwner whenNotFrozen {
    implementations[contractName] = address(0);
    emit ImplementationChanged(contractName, address(0));
  }
}