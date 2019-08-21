pragma solidity 0.4.18;

/**
 * This contract is used to protect the users of Storm4:
 * https://www.storm4.cloud
 * 
 * That is, to ensure the public keys of users are verifiable, auditable & tamper-proof.
 * 
 * Here's the general idea:
 * - We batch the public keys of multiple users into a merkle tree.
 * - We publish the merkle tree root to this contract.
 * - The merkle tree root for any given user can only be assigned once (per hash algorithm).
 * 
 * In order to verify a user:
 * - Use this contract to fetch the merkle tree root value for the userID.
 * - Then use HTTPS to fetch the corresponding merkle file from our server.
 *   For example, if the merkle tree root value is
 *   "0xcd59b7bda6dc1dd82cb173d0cdfa408db30e9a747d4366eb5b60597899eb69c1",
 *   then you could fetch the corresponding JSON file at
 *   https://blockchain.storm4.cloud/cd59b7bda6dc1dd82cb173d0cdfa408db30e9a747d4366eb5b60597899eb69c1.json
 * - The JSON file allows you to independently verify the public key information
 *   by calculating the merkle tree root for yourself.
**/
contract PubKeyTrust {
	address public owner;

	/**
	 * Rather than hard-coding a specific hash algorithm, we allow for upgradeability,
	 * should it become important to do so in the future for security reasons.
	 * 
	 * In order to support this, we keep a "register" of supported hash algorithms.
	 * Every hash algorithm in the system is assigned a unique ID (a uint8),
	 * along with a corresponding short identifier.
	 * 
	 * For example: 0 => "sha256"
	 * 
	 * Note: Since we are expecting there to be very few hash algorithms used
	 * in practice (probably just 1 or 2), we artificially limit the size of
	 * the hashTypes array to 256 entries. This allows us to use uint8 throughout
	 * the rest of the contract.
	**/
	string[] public hashTypes;

	/**
	 * We batch the public keys of multiple users into a single merkle tree,
	 * and then publish the merkle tree root to the blockchain.
	 * 
	 * Note: merkleTreeRoots[0] is initialized in the constructor to store
	 * the block number of when the contract was published.
	**/
	struct MerkleInfo {
		bytes merkleTreeRoot;
		uint blockNumber;
	}
	MerkleInfo[] public merkleTreeRoots;

	/**
	 * users[userID][hashTypeID] => merkleTreeRootsIndex
	 * 
	 * A value of zero indicates that a merkleTreeRoot has not been
	 * published for the <userID, hashTypeID> tuple.
	 * A nonzero value can be used as the index for the merkleTreeRoots array.
	 * 
	 * Note: merkleTreeRoots[0] is initialized in the constructor to store
	 * the block number of when the contract was published.
	 * Thus: merkleTreeRoots[0].merkleTreeRoot.length == 0
	**/
	mapping(bytes20 => mapping(uint8 => uint)) public users;

	event HashTypeAdded(uint8 hashTypeID);
	event MerkleTreeRootAdded(uint8 hashTypeID, bytes merkleTreeRoot);

	function PubKeyTrust() public {
		owner = msg.sender;
		merkleTreeRoots.push(MerkleInfo(new bytes(0), block.number));
	}

	modifier onlyByOwner()
	{
		if (msg.sender != owner)
			require(false);
		else
			_;
	}

	function numHashTypes() public view returns (uint) {

		return hashTypes.length;
	}

	function addHashType(string description) public onlyByOwner returns(bool, uint8) {

		uint hashTypeID = hashTypes.length;

		// Restrictions:
		// - there cannot be more than 256 different hash types
		// - the description cannot be the empty string
		// - the description cannot be over 64 bytes long
		if (hashTypeID >= 256) require(false);
		if (bytes(description).length == 0) require(false);
		if (bytes(description).length > 64) require(false);

		// Ensure the given description doesn't already exist
		for (uint i = 0; i < hashTypeID; i++)
		{
			if (stringsEqual(hashTypes[i], description)) {
				return (false, uint8(0));
			}
		}

		// Go ahead and add the new hash type
		hashTypes.push(description);
		HashTypeAdded(uint8(hashTypeID));

		return (true, uint8(hashTypeID));
	}

	/**
	 * We originally passed the userIDs as: bytes20[] userIDs
	 * But it was discovered that this was inefficiently packed,
	 * and ended up sending 12 bytes of zero's per userID.
	 * Since gtxdatazero is set to 4 gas/bytes, this translated into
	 * 48 gas wasted per user due to inefficient packing.
	**/
	function addMerkleTreeRoot(uint8 hashTypeID, bytes merkleTreeRoot, bytes userIDsPacked) public onlyByOwner {

		if (hashTypeID >= hashTypes.length) require(false);
		if (merkleTreeRoot.length == 0) require(false);

		uint index = merkleTreeRoots.length;
		bool addedIndexForUser = false;

		uint numUserIDs = userIDsPacked.length / 20;
		for (uint i = 0; i < numUserIDs; i++)
		{
			bytes20 userID;
			assembly {
				userID := mload(add(userIDsPacked, add(32, mul(20, i))))
			}

			uint existingIndex = users[userID][hashTypeID];
			if (existingIndex == 0)
			{
				users[userID][hashTypeID] = index;
				addedIndexForUser = true;
			}
		}

		if (addedIndexForUser)
		{
			merkleTreeRoots.push(MerkleInfo(merkleTreeRoot, block.number));
			MerkleTreeRootAdded(hashTypeID, merkleTreeRoot);
		}
	}

	function getMerkleTreeRoot(bytes20 userID, uint8 hashTypeID) public view returns (bytes) {

		uint merkleTreeRootsIndex = users[userID][hashTypeID];
		if (merkleTreeRootsIndex == 0) {
			return new bytes(0);
		}
		else {
			MerkleInfo storage merkleInfo = merkleTreeRoots[merkleTreeRootsIndex];
			return merkleInfo.merkleTreeRoot;
		}
	}

	function getBlockNumber(bytes20 userID, uint8 hashTypeID) public view returns (uint) {

		uint merkleTreeRootsIndex = users[userID][hashTypeID];
		if (merkleTreeRootsIndex == 0) {
			return 0;
		}
		else {
			MerkleInfo storage merkleInfo = merkleTreeRoots[merkleTreeRootsIndex];
			return merkleInfo.blockNumber;
		}
	}

	// Utility function (because string comparison doesn't exist natively in Solidity yet)
	function stringsEqual(string storage _a, string memory _b) internal view returns (bool) {

		bytes storage a = bytes(_a);
		bytes memory b = bytes(_b);
		if (a.length != b.length) {
			return false;
		}
		for (uint i = 0; i < a.length; i++) {
			if (a[i] != b[i]) {
				return false;
			}
		}
		return true;
	}
}