pragma solidity ^0.4.24;

// File: contracts/utility/interfaces/IOwned.sol

/*
    Owned contract interface
*/
contract IOwned {
    // this function isn't abstract since the compiler emits automatically generated getter functions as external
    function owner() public view returns (address) {}

    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
}

// File: contracts/utility/Owned.sol

/*
    Provides support and utilities for contract ownership
*/
contract Owned is IOwned {
    address public owner;
    address public newOwner;

    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    /**
        @dev constructor
    */
    constructor() public {
        owner = msg.sender;
    }

    // allows execution by the owner only
    modifier ownerOnly {
        require(msg.sender == owner);
        _;
    }

    /**
        @dev allows transferring the contract ownership
        the new owner still needs to accept the transfer
        can only be called by the contract owner

        @param _newOwner    new contract owner
    */
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    /**
        @dev used by a new owner to accept an ownership transfer
    */
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// File: contracts/utility/interfaces/IAddressList.sol

/*
    Address list interface
*/
contract IAddressList {
    mapping (address => bool) public listedAddresses;
}

// File: contracts/utility/NonStandardTokenRegistry.sol

/*
    Non standard token registry

    manages tokens who don't return true/false on transfer/transferFrom/approve but revert on failure instead 
*/
contract NonStandardTokenRegistry is IAddressList, Owned {

    mapping (address => bool) public listedAddresses;

    /**
        @dev constructor
    */
    constructor() public {

    }

    function setAddress(address token, bool register) public ownerOnly {
        listedAddresses[token] = register;
    }
}