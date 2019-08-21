// File: contracts/interfaces/IModerator.sol

pragma solidity 0.5.4;


interface IModerator {
    function verifyIssue(address _tokenHolder, uint256 _value, bytes calldata _data) external view
        returns (bool allowed, byte statusCode, bytes32 applicationCode);

    function verifyTransfer(address _from, address _to, uint256 _amount, bytes calldata _data) external view 
        returns (bool allowed, byte statusCode, bytes32 applicationCode);

    function verifyTransferFrom(address _from, address _to, address _forwarder, uint256 _amount, bytes calldata _data) external view 
        returns (bool allowed, byte statusCode, bytes32 applicationCode);

    function verifyRedeem(address _sender, uint256 _amount, bytes calldata _data) external view 
        returns (bool allowed, byte statusCode, bytes32 applicationCode);

    function verifyRedeemFrom(address _sender, address _tokenHolder, uint256 _amount, bytes calldata _data) external view
        returns (bool allowed, byte statusCode, bytes32 applicationCode);        

    function verifyControllerTransfer(address _controller, address _from, address _to, uint256 _value, bytes calldata _data, bytes calldata _operatorData) external view
        returns (bool allowed, byte statusCode, bytes32 applicationCode);

    function verifyControllerRedeem(address _controller, address _tokenHolder, uint256 _value, bytes calldata _data, bytes calldata _operatorData) external view
        returns (bool allowed, byte statusCode, bytes32 applicationCode);
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.2;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: contracts/roles/ModeratorRole.sol

pragma solidity 0.5.4;



// @notice Moderators are able to modify whitelists and transfer permissions in Moderator contracts.
contract ModeratorRole {
    using Roles for Roles.Role;

    event ModeratorAdded(address indexed account);
    event ModeratorRemoved(address indexed account);

    Roles.Role internal _moderators;

    modifier onlyModerator() {
        require(isModerator(msg.sender), "Only Moderators can execute this function.");
        _;
    }

    constructor() internal {
        _addModerator(msg.sender);
    }

    function isModerator(address account) public view returns (bool) {
        return _moderators.has(account);
    }

    function addModerator(address account) public onlyModerator {
        _addModerator(account);
    }

    function renounceModerator() public {
        _removeModerator(msg.sender);
    }    

    function _addModerator(address account) internal {
        _moderators.add(account);
        emit ModeratorAdded(account);
    }    

    function _removeModerator(address account) internal {
        _moderators.remove(account);
        emit ModeratorRemoved(account);
    }
}

// File: contracts/lib/Blacklistable.sol

pragma solidity 0.5.4;



contract Blacklistable is ModeratorRole {
    event Blacklisted(address account);
    event Unblacklisted(address account);

    mapping (address => bool) public isBlacklisted;

    modifier onlyBlacklisted(address account) {
        require(isBlacklisted[account], "Account is not blacklisted.");
        _;
    }

    modifier onlyNotBlacklisted(address account) {
        require(!isBlacklisted[account], "Account is blacklisted.");
        _;
    }

    function blacklist(address account) external onlyModerator {
        require(account != address(0), "Cannot blacklist zero address.");
        require(account != msg.sender, "Cannot blacklist self.");
        require(!isBlacklisted[account], "Address already blacklisted.");
        isBlacklisted[account] = true;
        emit Blacklisted(account);
    }

    function unblacklist(address account) external onlyModerator {
        require(account != address(0), "Cannot unblacklist zero address.");
        require(account != msg.sender, "Cannot unblacklist self.");
        require(isBlacklisted[account], "Address not blacklisted.");
        isBlacklisted[account] = false;
        emit Unblacklisted(account);
    }
}

// File: contracts/compliance/BlacklistModerator.sol

pragma solidity 0.5.4;




contract BlacklistModerator is IModerator, Blacklistable {
    byte internal constant STATUS_TRANSFER_FAILURE = 0x50; // Uses status codes from ERC-1066
    byte internal constant STATUS_TRANSFER_SUCCESS = 0x51;

    bytes32 internal constant ALLOWED_APPLICATION_CODE = keccak256("org.tenx.allowed");
    bytes32 internal constant FORBIDDEN_APPLICATION_CODE = keccak256("org.tenx.forbidden");

    function verifyIssue(address _account, uint256, bytes calldata) external view
        returns (bool allowed, byte statusCode, bytes32 applicationCode) 
    {
        if (isAllowed(_account)) {
            allowed = true;
            statusCode = STATUS_TRANSFER_SUCCESS;
            applicationCode = ALLOWED_APPLICATION_CODE;
        } else {
            allowed = false;
            statusCode = STATUS_TRANSFER_FAILURE;
            applicationCode = FORBIDDEN_APPLICATION_CODE;
        }
    }

    function verifyTransfer(address _from, address _to, uint256, bytes calldata) external view 
        returns (bool allowed, byte statusCode, bytes32 applicationCode) 
    {
        if (isAllowed(_from) && isAllowed(_to)) {
            allowed = true;
            statusCode = STATUS_TRANSFER_SUCCESS;
            applicationCode = ALLOWED_APPLICATION_CODE;
        } else {
            allowed = false;
            statusCode = STATUS_TRANSFER_FAILURE;
            applicationCode = FORBIDDEN_APPLICATION_CODE;
        }
    }

    function verifyTransferFrom(address _from, address _to, address _sender, uint256, bytes calldata) external view 
        returns (bool allowed, byte statusCode, bytes32 applicationCode) 
    {
        if (isAllowed(_from) && isAllowed(_to) && isAllowed(_sender)) {
            allowed = true;
            statusCode = STATUS_TRANSFER_SUCCESS;
            applicationCode = ALLOWED_APPLICATION_CODE;
        } else {
            allowed = false;
            statusCode = STATUS_TRANSFER_FAILURE;
            applicationCode = FORBIDDEN_APPLICATION_CODE;
        }
    }

    function verifyRedeem(address _sender, uint256, bytes calldata) external view 
        returns (bool allowed, byte statusCode, bytes32 applicationCode) 
    {
        if (isAllowed(_sender)) {
            allowed = true;
            statusCode = STATUS_TRANSFER_SUCCESS;
            applicationCode = ALLOWED_APPLICATION_CODE;
        } else {
            allowed = false;
            statusCode = STATUS_TRANSFER_FAILURE;
            applicationCode = FORBIDDEN_APPLICATION_CODE;
        }
    }

    function verifyRedeemFrom(address _sender, address _tokenHolder, uint256, bytes calldata) external view 
        returns (bool allowed, byte statusCode, bytes32 applicationCode) 
    {
        if (isAllowed(_sender) && isAllowed(_tokenHolder)) {
            allowed = true;
            statusCode = STATUS_TRANSFER_SUCCESS;
            applicationCode = ALLOWED_APPLICATION_CODE;
        } else {
            allowed = false;
            statusCode = STATUS_TRANSFER_FAILURE;
            applicationCode = FORBIDDEN_APPLICATION_CODE;
        }
    }        

    function verifyControllerTransfer(address, address, address, uint256, bytes calldata, bytes calldata) external view 
        returns (bool allowed, byte statusCode, bytes32 applicationCode) 
    {
        allowed = true;
        statusCode = STATUS_TRANSFER_SUCCESS;
        applicationCode = ALLOWED_APPLICATION_CODE;
    }

    function verifyControllerRedeem(address, address, uint256, bytes calldata, bytes calldata) external view 
        returns (bool allowed, byte statusCode, bytes32 applicationCode) 
    {
        allowed = true;
        statusCode = STATUS_TRANSFER_SUCCESS;
        applicationCode = ALLOWED_APPLICATION_CODE;
    }

    function isAllowed(address _account) internal view returns (bool) {
        return !isBlacklisted[_account];
    }
}