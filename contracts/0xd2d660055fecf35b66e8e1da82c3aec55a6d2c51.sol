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

// File: contracts/bancorx/XTransferRerouter.sol

contract XTransferRerouter is Owned {
    bool public reroutingEnabled;

    // triggered when a rerouteTx is called
    event TxReroute(
        uint256 indexed _txId,
        bytes32 _toBlockchain,
        bytes32 _to
    );

    /**
        @dev constructor

        @param _reroutingEnabled    intializes transactions routing to enabled/disabled   
     */
    constructor(bool _reroutingEnabled) public {
        reroutingEnabled = _reroutingEnabled;
    }
    /**
        @dev allows the owner to disable/enable rerouting

        @param _enable     true to enable, false to disable
     */
    function enableRerouting(bool _enable) public ownerOnly {
        reroutingEnabled = _enable;
    }

    // allows execution only when rerouting enabled
    modifier whenReroutingEnabled {
        require(reroutingEnabled);
        _;
    }

    /**
        @dev    allows a user to reroute a transaction to a new blockchain/target address

        @param _txId        the original transaction id
        @param _blockchain  the new blockchain name
        @param _to          the new target address/account
     */
    function rerouteTx(
        uint256 _txId,
        bytes32 _blockchain,
        bytes32 _to
    )
        public
        whenReroutingEnabled 
    {
        emit TxReroute(_txId, _blockchain, _to);
    }

}