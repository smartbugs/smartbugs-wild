pragma solidity 0.5.8;

/**
 * @title Graceful
 *
 * This contract provides informative `require` with optional ability to `revert`.
 *
 * _softRequire is used when it's enough to return `false` in case if condition isn't fulfilled.
 * _hardRequire is used when it's necessary to make revert in case if condition isn't fulfilled.
 */
contract Graceful {
    event Error(bytes32 message);

    // Only for functions that return bool success before any changes made.
    function _softRequire(bool _condition, bytes32 _message) internal {
        if (_condition) {
            return;
        }
        emit Error(_message);
        // Return bytes32(0).
        assembly {
            mstore(0, 0)
            return(0, 32)
        }
    }

    // Generic substitution for require().
    function _hardRequire(bool _condition, bytes32 _message) internal pure {
        if (_condition) {
            return;
        }
        // Revert with bytes32(_message).
        assembly {
            mstore(0, _message)
            revert(0, 32)
        }
    }

    function _not(bool _condition) internal pure returns(bool) {
        return !_condition;
    }
}


/**
 * @title Owned
 *
 * This contract keeps and transfers contract ownership.
 *
 * After deployment msg.sender becomes an owner which is checked in modifier onlyContractOwner().
 *
 * Features:
 * Modifier onlyContractOwner() restricting access to function for all callers except the owner.
 * Functions of transferring ownership to another address.
 *
 * Note:
 * Function forceChangeContractOwnership allows to
 * transfer the ownership to an address without confirmation.
 * Which is very convenient in case the ownership transfers to a contract.
 * But when using this function, it's important to be very careful when entering the address.
 * Check address three times to make sure that this is the address that you need
 * because you can't cancel this operation.
 */
contract Owned is Graceful {
    bool public isConstructedOwned;
    address public contractOwner;
    address public pendingContractOwner;

    event ContractOwnerChanged(address newContractOwner);
    event PendingContractOwnerChanged(address newPendingContractOwner);

    constructor() public {
        constructOwned();
    }

    function constructOwned() public returns(bool) {
        if (isConstructedOwned) {
            return false;
        }
        isConstructedOwned = true;
        contractOwner = msg.sender;
        emit ContractOwnerChanged(msg.sender);
        return true;
    }

    modifier onlyContractOwner() {
        _softRequire(contractOwner == msg.sender, 'Not a contract owner');
        _;
    }

    function changeContractOwnership(address _to) public onlyContractOwner() returns(bool) {
        pendingContractOwner = _to;
        emit PendingContractOwnerChanged(_to);
        return true;
    }

    function claimContractOwnership() public returns(bool) {
        _softRequire(pendingContractOwner == msg.sender, 'Not a pending contract owner');
        contractOwner = pendingContractOwner;
        delete pendingContractOwner;
        emit ContractOwnerChanged(contractOwner);
        return true;
    }

    function forceChangeContractOwnership(address _to) public onlyContractOwner() returns(bool) {
        contractOwner = _to;
        emit ContractOwnerChanged(contractOwner);
        return true;
    }
}


contract AddressList is Owned {
    string public name;

    mapping (address => bool) public onList;

    constructor(string memory _name, bool nullValue) public {
        name = _name;
        onList[address(0x0)] = nullValue;
    }

    event ChangeWhiteList(address indexed to, bool onList);

    // Set whether _to is on the list or not. Whether 0x0 is on the list
    // or not cannot be set here - it is set once and for all by the constructor.
    function changeList(address _to, bool _onList) public onlyContractOwner returns (bool success) {
        _softRequire(_to != address(0x0), 'Cannot set zero address');
        if (onList[_to] != _onList) {
            onList[_to] = _onList;
            emit ChangeWhiteList(_to, _onList);
        }
        return true;
    }
}