pragma solidity ^0.4.18;

// File: contracts/Core/Manageable.sol

contract Manageable {
  address public manager;


  /**
   * @dev Create a new instance of the Manageable contract.
   * @param _manager address
   */
  function Manageable(address _manager) public {
    require(_manager != 0x0);
    manager = _manager;
  }

  /**
   * @dev Checks if the msg.sender is the manager.
   */
  modifier onlyManager() { 
    require (msg.sender == manager && manager != 0x0);
    _; 
  }
}

// File: contracts/Core/Activatable.sol

contract Activatable is Manageable {
  event ActivatedContract(uint256 activatedAt);
  event DeactivatedContract(uint256 deactivatedAt);

  bool public active;
  
  /**
   * @dev Check if the contract is active. 
   */
  modifier isActive() {
    require(active);
    _;
  }

  /**
   * @dev Check if the contract is not active. 
   */
  modifier isNotActive() {
    require(!active);
    _;
  }

  /**
   * @dev Activate the contract.
   */
  function activate() public onlyManager isNotActive {
    // Set the flag to true.
    active = true;

    // Trigger event.
    ActivatedContract(now);
  }

  /**
   * @dev Deactiate the contract.
   */
  function deactivate() public onlyManager isActive {
    // Set the flag to false.
    active = false;

    // Trigger event.
    DeactivatedContract(now);
  }
}

// File: contracts/Core/Versionable.sol

contract Versionable is Activatable {
  string public name;
  string public version;
  uint256 public identifier;
  uint256 public createdAt;

  /**
   * @dev Create a new intance of a Versionable contract. Sets the
   *      createdAt unix timestamp to current block timestamp.
   */
  function Versionable (string _name, string _version, uint256 _identifier) public {
    require (bytes(_name).length != 0x0 && bytes(_version).length != 0x0 && _identifier > 0);

    // Set variables.
    name = _name;
    version = _version;
    identifier = _identifier;
    createdAt = now;
  }
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/Management/ContractManagementSystem.sol

contract ContractManagementSystem is Ownable {
  event UpgradedContract (uint256 contractIdentifier, address indexed oldContractAddress, address indexed newContractAddress);
  event RollbackedContract (uint256 contractIdentifier, address indexed fromContractAddress, address indexed toContractAddress);

  mapping (uint256 => mapping (address => bool)) public managedContracts;
  mapping (uint256 => address) public activeContracts;
  mapping (uint256 => bool) migrationLocks;

  /**
   * @dev Ensure no locks are in place for the given contract identifier.
   * @param contractIdentifier uint256
   */
  modifier onlyWithoutLock(uint256 contractIdentifier) {
    require(!migrationLocks[contractIdentifier]);
    _;
  }

  /**
   * @dev    Get the address of the active contract for the given identifier.
   * @param  contractIdentifier uint256
   * @return address
   */
  function getActiveContractAddress(uint256 contractIdentifier)
    public
    constant
    onlyWithoutLock(contractIdentifier)
    returns (address activeContract)
  {
    // Validate the function arguments.
    require(contractIdentifier != 0x0);
    
    // Get the active contract for the given identifier.
    activeContract = activeContracts[contractIdentifier];

    // Ensure the address is set and the contract is active.
    require(activeContract != 0x0 && Activatable(activeContract).active());
  }

  /**
   * @dev    Check if the contract for the given address is managed.
   * @param  contractIdentifier uint256
   * @param  contractAddress    address
   * @return bool
   */
  function existsManagedContract(uint256 contractIdentifier, address contractAddress)
    public
    constant
    returns (bool)
  {
    // Validate the function arguments.
    require(contractIdentifier != 0x0 && contractAddress != 0x0);

    return managedContracts[contractIdentifier][contractAddress];
  }

  /**
   * @dev    Upgrade the contract for the given contract identifier to a newer version.
   * @dev    investigate potential race condition
   * @param  contractIdentifier uint256
   * @param  newContractAddress address
   */
  function upgradeContract(uint256 contractIdentifier, address newContractAddress)
    public
    onlyOwner
    onlyWithoutLock(contractIdentifier)
  {
    // Validate the function arguments.
    require(contractIdentifier != 0x0 && newContractAddress != 0x0);
    
    // Lock the contractIdentifier.
    migrationLocks[contractIdentifier] = true;

    // New contract should not be active.
    require(!Activatable(newContractAddress).active());

    // New contract should match the given contractIdentifier.
    require(contractIdentifier == Versionable(newContractAddress).identifier());

    // Ensure the new contract is not already managed.
    require (!existsManagedContract(contractIdentifier, newContractAddress));

    // Get the old contract address.
    address oldContractAddress = activeContracts[contractIdentifier];

    // Ensure the old contract is not deactivated already.
    if (oldContractAddress != 0x0) {
      require(Activatable(oldContractAddress).active());
    }

    // Swap the states.
    swapContractsStates(contractIdentifier, newContractAddress, oldContractAddress);

    // Add it to the managed ones.
    managedContracts[contractIdentifier][newContractAddress] = true;

    // Unlock the contractIdentifier.
    migrationLocks[contractIdentifier] = false;
    
    // Trigger event.
    UpgradedContract(contractIdentifier, oldContractAddress, newContractAddress);
  }

  /**
   * @dev Rollback the contract for the given contract identifier to the provided version.
   * @dev investigate potential race condition
   * @param  contractIdentifier uint256
   * @param  toContractAddress  address
   */
  function rollbackContract(uint256 contractIdentifier, address toContractAddress)
    public
    onlyOwner
    onlyWithoutLock(contractIdentifier)
  {
    // Validate the function arguments.
    require(contractIdentifier != 0x0 && toContractAddress != 0x0);

    // Lock the contractIdentifier.
    migrationLocks[contractIdentifier] = true;

    // To contract should match the given contractIdentifier.
    require(contractIdentifier == Versionable(toContractAddress).identifier());

    // Rollback "to" contract should be managed and inactive.
    require (!Activatable(toContractAddress).active() && existsManagedContract(contractIdentifier, toContractAddress));

    // Get the rollback "from" contract for given identifier. Will fail if there is no active contract.
    address fromContractAddress = activeContracts[contractIdentifier];

    // Swap the states.
    swapContractsStates(contractIdentifier, toContractAddress, fromContractAddress);

    // Unlock the contractIdentifier.
    migrationLocks[contractIdentifier] = false;

    // Trigger event.
    RollbackedContract(contractIdentifier, fromContractAddress, toContractAddress);
  }
  
  /**
   * @dev Swap the given contracts states as defined:
   *        - newContractAddress will be activated
   *        - oldContractAddress will be deactived
   * @param  contractIdentifier uint256
   * @param  newContractAddress address
   * @param  oldContractAddress address
   */
  function swapContractsStates(uint256 contractIdentifier, address newContractAddress, address oldContractAddress) internal {
    // Deactivate the old contract.
    if (oldContractAddress != 0x0) {
      Activatable(oldContractAddress).deactivate();
    }

    // Activate the new contract.
    Activatable(newContractAddress).activate();

     // Set the new contract as the active one for the given identifier.
    activeContracts[contractIdentifier] = newContractAddress;
  }
}