// File: @laborx/solidity-shared-lib/contracts/ERC20Interface.sol

/**
* Copyright 2017–2018, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.23;


/// @title Defines an interface for EIP20 token smart contract
contract ERC20Interface {
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed from, address indexed spender, uint256 value);

    string public symbol;

    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256 supply);

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
}

// File: @laborx/solidity-shared-lib/contracts/Owned.sol

/**
* Copyright 2017–2018, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.23;



/// @title Owned contract with safe ownership pass.
///
/// Note: all the non constant functions return false instead of throwing in case if state change
/// didn't happen yet.
contract Owned {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address public contractOwner;
    address public pendingContractOwner;

    modifier onlyContractOwner {
        if (msg.sender == contractOwner) {
            _;
        }
    }

    constructor()
    public
    {
        contractOwner = msg.sender;
    }

    /// @notice Prepares ownership pass.
    /// Can only be called by current owner.
    /// @param _to address of the next owner.
    /// @return success.
    function changeContractOwnership(address _to)
    public
    onlyContractOwner
    returns (bool)
    {
        if (_to == 0x0) {
            return false;
        }
        pendingContractOwner = _to;
        return true;
    }

    /// @notice Finalize ownership pass.
    /// Can only be called by pending owner.
    /// @return success.
    function claimContractOwnership()
    public
    returns (bool)
    {
        if (msg.sender != pendingContractOwner) {
            return false;
        }

        emit OwnershipTransferred(contractOwner, pendingContractOwner);
        contractOwner = pendingContractOwner;
        delete pendingContractOwner;
        return true;
    }

    /// @notice Allows the current owner to transfer control of the contract to a newOwner.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner)
    public
    onlyContractOwner
    returns (bool)
    {
        if (newOwner == 0x0) {
            return false;
        }

        emit OwnershipTransferred(contractOwner, newOwner);
        contractOwner = newOwner;
        delete pendingContractOwner;
        return true;
    }

    /// @notice Allows the current owner to transfer control of the contract to a newOwner.
    /// @dev Backward compatibility only.
    /// @param newOwner The address to transfer ownership to.
    function transferContractOwnership(address newOwner)
    public
    returns (bool)
    {
        return transferOwnership(newOwner);
    }

    /// @notice Withdraw given tokens from contract to owner.
    /// This method is only allowed for contact owner.
    function withdrawTokens(address[] tokens)
    public
    onlyContractOwner
    {
        address _contractOwner = contractOwner;
        for (uint i = 0; i < tokens.length; i++) {
            ERC20Interface token = ERC20Interface(tokens[i]);
            uint balance = token.balanceOf(this);
            if (balance > 0) {
                token.transfer(_contractOwner, balance);
            }
        }
    }

    /// @notice Withdraw ether from contract to owner.
    /// This method is only allowed for contact owner.
    function withdrawEther()
    public
    onlyContractOwner
    {
        uint balance = address(this).balance;
        if (balance > 0)  {
            contractOwner.transfer(balance);
        }
    }

    /// @notice Transfers ether to another address.
    /// Allowed only for contract owners.
    /// @param _to recepient address
    /// @param _value wei to transfer; must be less or equal to total balance on the contract
    function transferEther(address _to, uint256 _value)
    public
    onlyContractOwner
    {
        require(_to != 0x0, "INVALID_ETHER_RECEPIENT_ADDRESS");
        if (_value > address(this).balance) {
            revert("INVALID_VALUE_TO_TRANSFER_ETHER");
        }

        _to.transfer(_value);
    }
}

// File: @laborx/solidity-eventshistory-lib/contracts/EventsHistorySourceAdapter.sol

/**
* Copyright 2017–2018, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.21;


/**
 * @title EventsHistory Source Adapter.
 */
contract EventsHistorySourceAdapter {

    // It is address of MultiEventsHistory caller assuming we are inside of delegate call.
    function _self()
    internal
    view
    returns (address)
    {
        return msg.sender;
    }
}

// File: @laborx/solidity-eventshistory-lib/contracts/MultiEventsHistoryAdapter.sol

/**
* Copyright 2017–2018, LaborX PTY
* Licensed under the AGPL Version 3 license.
*/

pragma solidity ^0.4.21;



/**
 * @title General MultiEventsHistory user.
 */
contract MultiEventsHistoryAdapter is EventsHistorySourceAdapter {

    address internal localEventsHistory;

    event ErrorCode(address indexed self, uint errorCode);

    function getEventsHistory()
    public
    view
    returns (address)
    {
        address _eventsHistory = localEventsHistory;
        return _eventsHistory != 0x0 ? _eventsHistory : this;
    }

    function emitErrorCode(uint _errorCode) public {
        emit ErrorCode(_self(), _errorCode);
    }

    function _setEventsHistory(address _eventsHistory) internal returns (bool) {
        localEventsHistory = _eventsHistory;
        return true;
    }
    
    function _emitErrorCode(uint _errorCode) internal returns (uint) {
        MultiEventsHistoryAdapter(getEventsHistory()).emitErrorCode(_errorCode);
        return _errorCode;
    }
}

// File: contracts/StorageManager.sol

/**
 * Copyright 2017–2018, LaborX PTY
 * Licensed under the AGPL Version 3 license.
 */

pragma solidity ^0.4.23;




contract StorageManager is Owned, MultiEventsHistoryAdapter {

    uint constant OK = 1;

    event AccessGiven(address indexed self, address indexed actor, bytes32 role);
    event AccessBlocked(address indexed self, address indexed actor, bytes32 role);
    event AuthorizationGranted(address indexed self, address indexed account);
    event AuthorizationRevoked(address indexed self, address indexed account);

    mapping (address => uint) public authorised;
    mapping (bytes32 => bool) public accessRights;
    mapping (address => bool) public acl;

    modifier onlyAuthorized {
        if (msg.sender == contractOwner || acl[msg.sender]) {
            _;
        }
    }

    function setupEventsHistory(address _eventsHistory)
    external
    onlyContractOwner
    returns (uint)
    {
        _setEventsHistory(_eventsHistory);
        return OK;
    }

    function authorize(address _address)
    external
    onlyAuthorized
    returns (uint)
    {
        require(_address != 0x0, "STORAGE_MANAGER_INVALID_ADDRESS");
        acl[_address] = true;

        _emitter().emitAuthorizationGranted(_address);
        return OK;
    }

    function revoke(address _address)
    external
    onlyContractOwner
    returns (uint)
    {
        require(acl[_address], "STORAGE_MANAGER_ADDRESS_SHOULD_EXIST");
        delete acl[_address];

        _emitter().emitAuthorizationRevoked(_address);
        return OK;
    }

    function giveAccess(address _actor, bytes32 _role)
    external
    onlyAuthorized
    returns (uint)
    {
        if (!accessRights[_getKey(_actor, _role)]) {
            accessRights[_getKey(_actor, _role)] = true;
            authorised[_actor] += 1;
            _emitter().emitAccessGiven(_actor, _role);
        }

        return OK;
    }

    function blockAccess(address _actor, bytes32 _role)
    external
    onlyAuthorized
    returns (uint)
    {
        if (accessRights[_getKey(_actor, _role)]) {
            delete accessRights[_getKey(_actor, _role)];
            authorised[_actor] -= 1;
            if (authorised[_actor] == 0) {
                delete authorised[_actor];
            }
            _emitter().emitAccessBlocked(_actor, _role);
        }

        return OK;
    }

    function isAllowed(address _actor, bytes32 _role)
    public
    view
    returns (bool)
    {
        return accessRights[keccak256(abi.encodePacked(_actor, _role))] || (this == _actor);
    }

    function hasAccess(address _actor)
    public
    view
    returns (bool)
    {
        return (authorised[_actor] > 0) || (address(this) == _actor);
    }

    function emitAccessGiven(address _user, bytes32 _role) public {
        emit AccessGiven(_self(), _user, _role);
    }

    function emitAccessBlocked(address _user, bytes32 _role) public {
        emit AccessBlocked(_self(), _user, _role);
    }

    function emitAuthorizationGranted(address _account) public {
        emit AuthorizationGranted(_self(), _account);
    }

    function emitAuthorizationRevoked(address _account) public {
        emit AuthorizationRevoked(_self(), _account);
    }

    function _emitter() internal view returns (StorageManager) {
        return StorageManager(getEventsHistory());
    }

    function _getKey(address _actor, bytes32 _role) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_actor, _role));
    }
}