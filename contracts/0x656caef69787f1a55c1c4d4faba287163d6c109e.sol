// File: zos-lib/contracts/application/ImplementationProvider.sol

pragma solidity ^0.5.0;

/**
 * @title ImplementationProvider
 * @dev Abstract contract for providing implementation addresses for other contracts by name.
 */
contract ImplementationProvider {
  /**
   * @dev Abstract function to return the implementation address of a contract.
   * @param contractName Name of the contract.
   * @return Implementation address of the contract.
   */
  function getImplementation(string memory contractName) public view returns (address);
}

// File: zos-lib/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 *
 * Source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.1.3/contracts/ownership/Ownable.sol
 * This contract is copied here and renamed from the original to avoid clashes in the compiled artifacts
 * when the user imports a zos-lib contract (that transitively causes this contract to be compiled and added to the
 * build/artifacts folder) as well as the vanilla Ownable implementation from an openzeppelin version.
 */
contract ZOSLibOwnable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
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
    function isOwner() public view returns (bool) {
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

// File: zos-lib/contracts/utils/Address.sol

pragma solidity ^0.5.0;

/**
 * Utility library of inline functions on addresses
 *
 * Source https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-solidity/v2.1.3/contracts/utils/Address.sol
 * This contract is copied here and renamed from the original to avoid clashes in the compiled artifacts
 * when the user imports a zos-lib contract (that transitively causes this contract to be compiled and added to the
 * build/artifacts folder) as well as the vanilla Address implementation from an openzeppelin version.
 */
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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

// File: zos-lib/contracts/application/ImplementationDirectory.sol

pragma solidity ^0.5.0;




/**
 * @title ImplementationDirectory
 * @dev Implementation provider that stores contract implementations in a mapping.
 */
contract ImplementationDirectory is ImplementationProvider, ZOSLibOwnable {
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
  function getImplementation(string memory contractName) public view returns (address) {
    return implementations[contractName];
  }

  /**
   * @dev Sets the address of the implementation of a contract in the directory.
   * @param contractName Name of the contract.
   * @param implementation Address of the implementation.
   */
  function setImplementation(string memory contractName, address implementation) public onlyOwner whenNotFrozen {
    require(ZOSLibAddress.isContract(implementation), "Cannot set implementation in directory with a non-contract address");
    implementations[contractName] = implementation;
    emit ImplementationChanged(contractName, implementation);
  }

  /**
   * @dev Removes the address of a contract implementation from the directory.
   * @param contractName Name of the contract.
   */
  function unsetImplementation(string memory contractName) public onlyOwner whenNotFrozen {
    implementations[contractName] = address(0);
    emit ImplementationChanged(contractName, address(0));
  }
}