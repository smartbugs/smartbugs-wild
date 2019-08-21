// File: node_modules\openzeppelin-solidity\contracts\ownership\Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts\LAND\ILANDRegistry.sol

// solium-disable linebreak-style
pragma solidity ^0.5.0;

interface ILANDRegistry {

  // LAND can be assigned by the owner
  function assignNewParcel(int x, int y, address beneficiary) external;
  function assignMultipleParcels(int[] calldata x, int[] calldata y, address beneficiary) external;

  // After one year, LAND can be claimed from an inactive public key
  function ping() external;

  // LAND-centric getters
  function encodeTokenId(int x, int y) external pure returns (uint256);
  function decodeTokenId(uint value) external pure returns (int, int);
  function exists(int x, int y) external view returns (bool);
  function ownerOfLand(int x, int y) external view returns (address);
  function ownerOfLandMany(int[] calldata x, int[] calldata y) external view returns (address[] memory);
  function landOf(address owner) external view returns (int[] memory, int[] memory);
  function landData(int x, int y) external view returns (string memory);

  // Transfer LAND
  function transferLand(int x, int y, address to) external;
  function transferManyLand(int[] calldata x, int[] calldata y, address to) external;

  // Update LAND
  function updateLandData(int x, int y, string calldata data) external;
  function updateManyLandData(int[] calldata x, int[] calldata y, string calldata data) external;

  //operators
  function setUpdateOperator(uint256 assetId, address operator) external;

  // Events

  event Update(
    uint256 indexed assetId,
    address indexed holder,
    address indexed operator,
    string data
  );

  event UpdateOperator(
    uint256 indexed assetId,
    address indexed operator
  );

  event DeployAuthorized(
    address indexed _caller,
    address indexed _deployer
  );

  event DeployForbidden(
    address indexed _caller,
    address indexed _deployer
  );
}

// File: contracts\AetheriaFirstStageProxy.sol

pragma solidity ^0.5.0;



contract AetheriaFirstStageProxy is Ownable {
    ILANDRegistry private landContract;
	address private delegatedSigner;
	mapping(uint256 => uint) private replayProtection;
	uint public currentNonce;

	constructor (address landContractAddress) public {
        landContract = ILANDRegistry(landContractAddress);
		delegatedSigner = owner();
		currentNonce = 1;
    }

	function setDelegatedSigner(address newDelegate) external onlyOwner {
		delegatedSigner = newDelegate;
		emit DelegateChanged(delegatedSigner);
	}

	function getDelegatedSigner() public view returns (address ){
		return delegatedSigner;
	}

	function getMessageHash(address userAddress, uint256[] memory plotIds, uint nonce) public pure returns (bytes32)
	{
		return keccak256(abi.encode(userAddress, plotIds, nonce));
	}

	function buildPrefixedHash(bytes32 msgHash) public pure returns (bytes32)
	{
		bytes memory prefix = "\x19Ethereum Signed Message:\n32";
		return keccak256(abi.encodePacked(prefix, msgHash));
	}

	function verifySender(bytes32 msgHash, uint8 _v, bytes32 _r, bytes32 _s) private view returns (bool)
	{
		bytes32 prefixedHash = buildPrefixedHash(msgHash);
		return ecrecover(prefixedHash, _v, _r, _s) == delegatedSigner;
	}

	function updatePlot(address userAddress, uint256[] calldata plotIds, uint nonce, uint8 _v, bytes32 _r, bytes32 _s) external {
		bytes32 msgHash = getMessageHash(userAddress, plotIds, nonce);
		require(verifySender(msgHash, _v, _r, _s), "Invalid Sig");
        for (uint i = 0; i<plotIds.length; i++) {
			if(replayProtection[plotIds[i]] > nonce) {
				landContract.setUpdateOperator(plotIds[i], userAddress);
				replayProtection[plotIds[i]]++;
			}
        }
        if (currentNonce <= nonce)
        {
            currentNonce = nonce+1;
        }
		emit PlotOwnerUpdate(
			userAddress,
			plotIds
		);
	}

	event DelegateChanged(
		address newDelegatedAddress
	);

	event PlotOwnerUpdate(
		address newOperator,
		uint256[] plotIds
	);
}