pragma solidity 0.4.24;

/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}











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
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
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









/**
* @dev Contract Version Manager for non-upgradeable contracts
*/
contract ContractManager is Ownable {

    event VersionAdded(
        string contractName,
        string versionName,
        address indexed implementation
    );

    event VersionUpdated(
        string contractName,
        string versionName,
        Status status,
        BugLevel bugLevel
    );

    event VersionRecommended(string contractName, string versionName);

    event RecommendedVersionRemoved(string contractName);

    /**
    * @dev Signifies the status of a version
    */
    enum Status {BETA, RC, PRODUCTION, DEPRECATED}

    /**
    * @dev Indicated the highest level of bug found in the version
    */
    enum BugLevel {NONE, LOW, MEDIUM, HIGH, CRITICAL}

    /**
    * @dev A struct to encode version details
    */
    struct Version {
        // the version number string ex. "v1.0"
        string versionName;

        Status status;

        BugLevel bugLevel;
        // the address of the instantiation of the version
        address implementation;
        // the date when this version was registered with the contract
        uint256 dateAdded;
    }

    /**
    * @dev List of all contracts registered (append-only)
    */
    string[] internal contracts;

    /**
    * @dev Mapping to keep track which contract names have been registered.
    * Used to save gas when checking for redundant contract names
    */
    mapping(string=>bool) internal contractExists;

    /**
    * @dev Mapping to keep track of all version names for easch contract name
    */
    mapping(string=>string[]) internal contractVsVersionString;

    /**
    * @dev Mapping from contract names to version names to version structs
    */
    mapping(string=>mapping(string=>Version)) internal contractVsVersions;

    /**
    * @dev Mapping from contract names to the version names of their
    * recommended versions
    */
    mapping(string=>string) internal contractVsRecommendedVersion;

    modifier nonZeroAddress(address _address) {
        require(
            _address != address(0),
            "The provided address is the 0 address"
        );
        _;
    }

    modifier contractRegistered(string contractName) {

        require(contractExists[contractName], "Contract does not exists");
        _;
    }

    modifier versionExists(string contractName, string versionName) {
        require(
            contractVsVersions[contractName][versionName].implementation != address(0),
            "Version does not exists for contract"
        );
        _;
    }

    /**
    * @dev Allows owner to register a new version of a contract
    * @param contractName The contract name of the contract to be added
    * @param versionName The name of the version to be added
    * @param status Status of the version to be added
    * @param implementation The address of the implementation of the version
    */
    function addVersion(
        string contractName,
        string versionName,
        Status status,
        address implementation
    )
        external
        onlyOwner
        nonZeroAddress(implementation)
    {
        // version name must not be the empty string
        require(bytes(versionName).length>0, "Empty string passed as version");

        // contract name must not be the empty string
        require(
            bytes(contractName).length>0,
            "Empty string passed as contract name"
        );

        // implementation must be a contract
        require(
            Address.isContract(implementation),
            "Cannot set an implementation to a non-contract address"
        );

        if (!contractExists[contractName]) {
            contracts.push(contractName);
            contractExists[contractName] = true;
        }

        // the version name should not already be registered for
        // the given contract
        require(
            contractVsVersions[contractName][versionName].implementation == address(0),
            "Version already exists for contract"
        );
        contractVsVersionString[contractName].push(versionName);

        contractVsVersions[contractName][versionName] = Version({
            versionName:versionName,
            status:status,
            bugLevel:BugLevel.NONE,
            implementation:implementation,
            dateAdded:block.timestamp
        });

        emit VersionAdded(contractName, versionName, implementation);
    }

    /**
    * @dev Allows owner to update a contract version
    * @param contractName Name of the contract
    * @param versionName Version of the contract
    * @param status Status of the contract
    * @param bugLevel New bug level for the contract
    */
    function updateVersion(
        string contractName,
        string versionName,
        Status status,
        BugLevel bugLevel
    )
        external
        onlyOwner
        contractRegistered(contractName)
        versionExists(contractName, versionName)
    {

        contractVsVersions[contractName][versionName].status = status;
        contractVsVersions[contractName][versionName].bugLevel = bugLevel;

        emit VersionUpdated(
            contractName,
            versionName,
            status,
            bugLevel
        );
    }

    /**
    * @dev Allows owner to set the recommended version
    * @param contractName Name of the contract
    * @param versionName Version of the contract
    */
    function markRecommendedVersion(
        string contractName,
        string versionName
    )
        external
        onlyOwner
        contractRegistered(contractName)
        versionExists(contractName, versionName)
    {
        // set the version name as the recommended version
        contractVsRecommendedVersion[contractName] = versionName;

        emit VersionRecommended(contractName, versionName);
    }

    /**
    * @dev Get recommended version for the contract.
    * @return Details of recommended version
    */
    function getRecommendedVersion(
        string contractName
    )
        external
        view
        contractRegistered(contractName)
        returns (
            string versionName,
            Status status,
            BugLevel bugLevel,
            address implementation,
            uint256 dateAdded
        )
    {
        versionName = contractVsRecommendedVersion[contractName];

        Version storage recommendedVersion = contractVsVersions[
            contractName
        ][
            versionName
        ];

        status = recommendedVersion.status;
        bugLevel = recommendedVersion.bugLevel;
        implementation = recommendedVersion.implementation;
        dateAdded = recommendedVersion.dateAdded;

        return (
            versionName,
            status,
            bugLevel,
            implementation,
            dateAdded
        );
    }

    /**
    * @dev Allows owner to remove a version from being recommended
    * @param contractName Name of the contract
    */
    function removeRecommendedVersion(string contractName)
        external
        onlyOwner
        contractRegistered(contractName)
    {
        // delete the recommended version name from the mapping
        delete contractVsRecommendedVersion[contractName];

        emit RecommendedVersionRemoved(contractName);
    }

    /**
    * @dev Get total count of contracts registered
    */
    function getTotalContractCount() external view returns (uint256 count) {
        count = contracts.length;
        return count;
    }

    /**
    * @dev Get total count of versions for the contract
    * @param contractName Name of the contract
    */
    function getVersionCountForContract(string contractName)
        external
        view
        returns (uint256 count)
    {
        count = contractVsVersionString[contractName].length;
        return count;
    }

    /**
    * @dev Returns the contract at a given index in the contracts array
    * @param index The index to be searched for
    */
    function getContractAtIndex(uint256 index)
        external
        view
        returns (string contractName)
    {
        contractName = contracts[index];
        return contractName;
    }

    /**
    * @dev Returns the version name of a contract at specific index in a
    * contractVsVersionString[contractName] array
    * @param contractName Name of the contract
    * @param index The index to be searched for
    */
    function getVersionAtIndex(string contractName, uint256 index)
        external
        view
        returns (string versionName)
    {
        versionName = contractVsVersionString[contractName][index];
        return versionName;
    }

    /**
    * @dev Returns the version details for the given contract and version name
    * @param contractName Name of the contract
    * @param versionName Version string for the contract
    */
    function getVersionDetails(string contractName, string versionName)
        external
        view
        returns (
            string versionString,
            Status status,
            BugLevel bugLevel,
            address implementation,
            uint256 dateAdded
        )
    {
        Version storage v = contractVsVersions[contractName][versionName];

        versionString = v.versionName;
        status = v.status;
        bugLevel = v.bugLevel;
        implementation = v.implementation;
        dateAdded = v.dateAdded;

        return (
            versionString,
            status,
            bugLevel,
            implementation,
            dateAdded
        );
    }
}