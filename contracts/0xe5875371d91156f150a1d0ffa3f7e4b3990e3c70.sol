pragma solidity ^0.4.21;

// File: contracts/AddressRegistry.sol

contract AddressRegistry {
    mapping (address => address) public mainnetAddressFor;

    event AddressRegistration(address registrant, address registeredMainnetAddress);

    function register(address mainnetAddress) public {
        emit AddressRegistration(msg.sender, mainnetAddress);
        mainnetAddressFor[msg.sender] = mainnetAddress;
    }
}