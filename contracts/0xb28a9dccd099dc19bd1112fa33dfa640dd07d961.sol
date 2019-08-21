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

// File: contracts/utils/Utils.sol

/**
 * @title Manageable Contract
 * @author Validity Labs AG <info@validitylabs.org>
 */
 
pragma solidity 0.5.7;


contract Utils {
    /** MODIFIERS **/
    modifier onlyValidAddress(address _address) {
        require(_address != address(0), "invalid address");
        _;
    }
}

// File: contracts/management/Manageable.sol

/**
 * @title Manageable Contract
 * @author Validity Labs AG <info@validitylabs.org>
 */
 
 pragma solidity 0.5.7;



contract Manageable is Ownable, Utils {
    mapping(address => bool) public isManager;     // manager accounts

    /** EVENTS **/
    event ChangedManager(address indexed manager, bool active);

    /** MODIFIERS **/
    modifier onlyManager() {
        require(isManager[msg.sender], "is not manager");
        _;
    }

    /**
    * @notice constructor sets the deployer as a manager
    */
    constructor() public {
        setManager(msg.sender, true);
    }

    /**
     * @notice enable/disable an account to be a manager
     * @param _manager address address of the manager to create/alter
     * @param _active bool flag that shows if the manager account is active
     */
    function setManager(address _manager, bool _active) public onlyOwner onlyValidAddress(_manager) {
        isManager[_manager] = _active;
        emit ChangedManager(_manager, _active);
    }

    /** OVERRIDE 
    * @notice does not allow owner to give up ownership
    */
    function renounceOwnership() public onlyOwner {
        revert("Cannot renounce ownership");
    }
}

// File: contracts/whitelist/GlobalWhitelist.sol

/**
 * @title Global Whitelist Contract
 * @author Validity Labs AG <info@validitylabs.org>
 */

pragma solidity 0.5.7;




contract GlobalWhitelist is Ownable, Manageable {
    mapping(address => bool) public isWhitelisted; // addresses of who's whitelisted
    bool public isWhitelisting = true;             // whitelisting enabled by default

    /** EVENTS **/
    event ChangedWhitelisting(address indexed registrant, bool whitelisted);
    event GlobalWhitelistDisabled(address indexed manager);
    event GlobalWhitelistEnabled(address indexed manager);

    /**
    * @dev add an address to the whitelist
    * @param _address address
    */
    function addAddressToWhitelist(address _address) public onlyManager onlyValidAddress(_address) {
        isWhitelisted[_address] = true;
        emit ChangedWhitelisting(_address, true);
    }

    /**
    * @dev add addresses to the whitelist
    * @param _addresses addresses array
    */
    function addAddressesToWhitelist(address[] calldata _addresses) external {
        for (uint256 i = 0; i < _addresses.length; i++) {
            addAddressToWhitelist(_addresses[i]);
        }
    }

    /**
    * @dev remove an address from the whitelist
    * @param _address address
    */
    function removeAddressFromWhitelist(address _address) public onlyManager onlyValidAddress(_address) {
        isWhitelisted[_address] = false;
        emit ChangedWhitelisting(_address, false);
    }

    /**
    * @dev remove addresses from the whitelist
    * @param _addresses addresses
    */
    function removeAddressesFromWhitelist(address[] calldata _addresses) external {
        for (uint256 i = 0; i < _addresses.length; i++) {
            removeAddressFromWhitelist(_addresses[i]);
        }
    }

    /** 
    * @notice toggle the whitelist by the parent contract; ExporoTokenFactory
    */
    function toggleWhitelist() external onlyOwner {
        isWhitelisting = isWhitelisting ? false : true;

        if (isWhitelisting) {
            emit GlobalWhitelistEnabled(msg.sender);
        } else {
            emit GlobalWhitelistDisabled(msg.sender);
        }
    }
}