// File: src/main/solidity/zeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: src/main/solidity/zeppelin-solidity/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.0;


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: src/main/solidity/zeppelin-solidity/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: src/main/solidity/zeppelin-solidity/contracts/access/roles/WhitelistAdminRole.sol

pragma solidity ^0.5.0;


/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender), "WhitelistAdminRole: caller does not have the WhitelistAdmin role");
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

// File: src/main/solidity/CrowdliKYCProvider.sol

pragma solidity 0.5.0;



contract CrowdliKYCProvider is Pausable, WhitelistAdminRole {

	/**
	 * The verification levels supported by this ICO
	 */
	enum VerificationTier { None, KYCAccepted, VideoVerified, ExternalTokenAgent } 
    
    /**
     * Defines the max. amount of tokens an investor can purchase for a given verification level (tier)
     */
	mapping (uint => uint) public maxTokenAmountPerTier; 
    
    /**
    * Dictionary that maps addresses to investors which have successfully been verified by the external KYC process
    */
    mapping (address => VerificationTier) public verificationTiers;

    /**
    * This event is fired when a user has been successfully verified by the external KYC verification process
    */
    event LogKYCConfirmation(address indexed sender, VerificationTier verificationTier);

	/**
	 * This constructor initializes a new  CrowdliKYCProvider initializing the provided token amount threshold for the supported verification tiers
	 */
    constructor(address _kycConfirmer, uint _maxTokenForKYCAcceptedTier, uint _maxTokensForVideoVerifiedTier, uint _maxTokensForExternalTokenAgent) public {
        addWhitelistAdmin(_kycConfirmer);
        // Max token amount for non-verified investors
        maxTokenAmountPerTier[uint(VerificationTier.None)] = 0;
        
        // Max token amount for auto KYC auto verified investors
        maxTokenAmountPerTier[uint(VerificationTier.KYCAccepted)] = _maxTokenForKYCAcceptedTier;
        
        // Max token amount for auto KYC video verified investors
        maxTokenAmountPerTier[uint(VerificationTier.VideoVerified)] = _maxTokensForVideoVerifiedTier;
        
        // Max token amount for external token sell providers
        maxTokenAmountPerTier[uint(VerificationTier.ExternalTokenAgent)] = _maxTokensForExternalTokenAgent;
    }

    function confirmKYC(address _addressId, VerificationTier _verificationTier) public onlyWhitelistAdmin whenNotPaused {
        emit LogKYCConfirmation(_addressId, _verificationTier);
        verificationTiers[_addressId] = _verificationTier;
    }

    function hasVerificationLevel(address _investor, VerificationTier _verificationTier) public view returns (bool) {
        return (verificationTiers[_investor] == _verificationTier);
    }
    
    function getMaxChfAmountForInvestor(address _investor) public view returns (uint) {
        return maxTokenAmountPerTier[uint(verificationTiers[_investor])];
    }    
}