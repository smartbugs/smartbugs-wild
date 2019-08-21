// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
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
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

// File: contracts/interfaces/IWhitelistable.sol

pragma solidity 0.5.4;


interface IWhitelistable {
    event Whitelisted(address account);
    event Unwhitelisted(address account);

    function isWhitelisted(address account) external returns (bool);
    function whitelist(address account) external;
    function unwhitelist(address account) external;
    function isModerator(address account) external view returns (bool);
    function renounceModerator() external;
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

// File: contracts/rewards/BatchWhitelister.sol

pragma solidity 0.5.4;





/**
 * @notice Enables batching transactions for Rewards whitelisting
 */
contract BatchWhitelister is ModeratorRole, Ownable {
  event BatchWhitelisted(address indexed from, uint accounts);
  event BatchUnwhitelisted(address indexed from, uint accounts);

  IWhitelistable public rewards; // The contract which implements IWhitelistable

  constructor(IWhitelistable _contract) public {
      rewards = _contract;
  }

  function batchWhitelist(address[] memory accounts) public onlyModerator {
    bool isModerator = rewards.isModerator(address(this));
    require(isModerator, 'This contract is not a moderator.');

    emit BatchWhitelisted(msg.sender, accounts.length);
    for (uint i = 0; i < accounts.length; i++) {
      rewards.whitelist(accounts[i]);
    }
  }

  function batchUnwhitelist(address[] memory accounts) public onlyModerator {
    bool isModerator = rewards.isModerator(address(this));
    require(isModerator, 'This contract is not a moderator.');

    emit BatchUnwhitelisted(msg.sender, accounts.length);
    for (uint i = 0; i < accounts.length; i++) {
      rewards.unwhitelist(accounts[i]);
    }
  }

  function disconnect() public onlyOwner {
    rewards.renounceModerator();
  }
}