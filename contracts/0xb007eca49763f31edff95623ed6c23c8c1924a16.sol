pragma solidity ^0.4.24;

// File: contracts/lib/ownership/Ownable.sol

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner,address indexed newOwner);

    /// @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
    constructor() public { owner = msg.sender; }

    /// @dev Throws if called by any contract other than latest designated caller
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// @dev Allows the current owner to transfer control of the contract to a newOwner.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner) public onlyOwner {
       require(newOwner != address(0));
       emit OwnershipTransferred(owner, newOwner);
       owner = newOwner;
    }
}

// File: contracts/lib/ownership/ZapCoordinatorInterface.sol

contract ZapCoordinatorInterface is Ownable {
	function addImmutableContract(string contractName, address newAddress) external;
	function updateContract(string contractName, address newAddress) external;
	function getContractName(uint index) public view returns (string);
	function getContract(string contractName) public view returns (address);
	function updateAllDependencies() external;
}

// File: contracts/lib/ownership/Upgradable.sol

pragma solidity ^0.4.24;

contract Upgradable {

	address coordinatorAddr;
	ZapCoordinatorInterface coordinator;

	constructor(address c) public{
		coordinatorAddr = c;
		coordinator = ZapCoordinatorInterface(c);
	}

    function updateDependencies() external coordinatorOnly {
       _updateDependencies();
    }

    function _updateDependencies() internal;

    modifier coordinatorOnly() {
    	require(msg.sender == coordinatorAddr, "Error: Coordinator Only Function");
    	_;
    }
}

// File: contracts/platform/database/DatabaseInterface.sol

contract DatabaseInterface is Ownable {
	function setStorageContract(address _storageContract, bool _allowed) public;
	/*** Bytes32 ***/
	function getBytes32(bytes32 key) external view returns(bytes32);
	function setBytes32(bytes32 key, bytes32 value) external;
	/*** Number **/
	function getNumber(bytes32 key) external view returns(uint256);
	function setNumber(bytes32 key, uint256 value) external;
	/*** Bytes ***/
	function getBytes(bytes32 key) external view returns(bytes);
	function setBytes(bytes32 key, bytes value) external;
	/*** String ***/
	function getString(bytes32 key) external view returns(string);
	function setString(bytes32 key, string value) external;
	/*** Bytes Array ***/
	function getBytesArray(bytes32 key) external view returns (bytes32[]);
	function getBytesArrayIndex(bytes32 key, uint256 index) external view returns (bytes32);
	function getBytesArrayLength(bytes32 key) external view returns (uint256);
	function pushBytesArray(bytes32 key, bytes32 value) external;
	function setBytesArrayIndex(bytes32 key, uint256 index, bytes32 value) external;
	function setBytesArray(bytes32 key, bytes32[] value) external;
	/*** Int Array ***/
	function getIntArray(bytes32 key) external view returns (int[]);
	function getIntArrayIndex(bytes32 key, uint256 index) external view returns (int);
	function getIntArrayLength(bytes32 key) external view returns (uint256);
	function pushIntArray(bytes32 key, int value) external;
	function setIntArrayIndex(bytes32 key, uint256 index, int value) external;
	function setIntArray(bytes32 key, int[] value) external;
	/*** Address Array ***/
	function getAddressArray(bytes32 key) external view returns (address[]);
	function getAddressArrayIndex(bytes32 key, uint256 index) external view returns (address);
	function getAddressArrayLength(bytes32 key) external view returns (uint256);
	function pushAddressArray(bytes32 key, address value) external;
	function setAddressArrayIndex(bytes32 key, uint256 index, address value) external;
	function setAddressArray(bytes32 key, address[] value) external;
}

// File: contracts/lib/ownership/ZapCoordinator.sol

contract ZapCoordinator is Ownable, ZapCoordinatorInterface {

	event UpdatedContract(string name, address previousAddr, address newAddr);
	event UpdatedDependencies(uint timestamp, string contractName, address contractAddr);

	mapping(string => address) contracts; 

	// names of upgradable contracts
	string[] public loadedContracts;

	DatabaseInterface public db;

	// used for adding contracts like Database and ZapToken
	function addImmutableContract(string contractName, address newAddress) external onlyOwner {
		assert(contracts[contractName] == address(0));
		contracts[contractName] = newAddress;

		// Create DB object when Database is added to Coordinator
		bytes32 hash = keccak256(abi.encodePacked(contractName));
		if(hash == keccak256(abi.encodePacked("DATABASE"))) db = DatabaseInterface(newAddress);
	}

	// used for modifying an existing contract or adding a new contract to the system
	function updateContract(string contractName, address newAddress) external onlyOwner {
		address prev = contracts[contractName];
		if (prev == address(0) ) {
			// First time adding this contract
			loadedContracts.push(contractName);
		} else {
			// Deauth the old contract
			db.setStorageContract(prev, false);
		}
		// give new contract database access permission
		db.setStorageContract(newAddress, true);

		emit UpdatedContract(contractName, prev, newAddress);
		contracts[contractName] = newAddress;
	}

	function getContractName(uint index) public view returns (string) {
		return loadedContracts[index];
	}

	function getContract(string contractName) public view returns (address) {
		return contracts[contractName];
	}

	function updateAllDependencies() external onlyOwner {
		for ( uint i = 0; i < loadedContracts.length; i++ ) {
			address c = contracts[loadedContracts[i]];
			Upgradable(c).updateDependencies();
			emit UpdatedDependencies(block.timestamp, loadedContracts[i], c);
		}
	}

}