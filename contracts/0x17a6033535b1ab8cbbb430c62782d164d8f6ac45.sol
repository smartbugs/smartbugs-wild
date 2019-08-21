pragma solidity ^0.4.24;

/**
 * @title AraProxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract AraProxy {

  bytes32 private constant registryPosition_ = keccak256("io.ara.proxy.registry");
  bytes32 private constant implementationPosition_ = keccak256("io.ara.proxy.implementation");

  modifier restricted() {
    bytes32 registryPosition = registryPosition_;
    address registryAddress;
    assembly {
      registryAddress := sload(registryPosition)
    }
    require(
      msg.sender == registryAddress,
      "Only the AraRegistry can upgrade this proxy."
    );
    _;
  }

  /**
  * @dev the constructor sets the AraRegistry address
  */
  constructor(address _registryAddress, address _implementationAddress) public {
    bytes32 registryPosition = registryPosition_;
    bytes32 implementationPosition = implementationPosition_;
    assembly {
      sstore(registryPosition, _registryAddress)
      sstore(implementationPosition, _implementationAddress)
    }
  }

  function setImplementation(address _newImplementation) public restricted {
    require(_newImplementation != address(0));
    bytes32 implementationPosition = implementationPosition_;
    assembly {
      sstore(implementationPosition, _newImplementation)
    }
  }

  /**
  * @dev Fallback function allowing to perform a delegatecall to the given implementation.
  * This function will return whatever the implementation call returns
  */
  function () payable public {
    bytes32 implementationPosition = implementationPosition_;
    address _impl;
    assembly {
      _impl := sload(implementationPosition)
    }

    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize)
      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
      let size := returndatasize
      returndatacopy(ptr, 0, size)

      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}