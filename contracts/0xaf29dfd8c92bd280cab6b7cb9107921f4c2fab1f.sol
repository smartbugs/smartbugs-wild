pragma solidity ^0.4.18;

// https://www.storm4.cloud

contract PubKeyTrust {
	address owner;

	uint8[] public allHashTypes;
	mapping(uint8 => string) public hashTypes;

	struct HashInfo {
		bytes pubKeyHash;
		bytes keyID;
		uint blockNumber;
	}
	struct UserHashes {
		mapping(uint8 => HashInfo) hashes;
		bool initialized;
	}
	mapping(bytes20 => UserHashes) hashes;

	event UserAdded(bytes20 indexed userID);
	event PubKeyHashAdded(bytes20 indexed userID, uint8 indexed hashType);
	event PubKeyHashTypeAdded(uint8 indexed hashType);

	function PubKeyTrust() public {
		owner = msg.sender;
	}

	modifier onlyByOwner()
	{
		if (msg.sender != owner)
			require(false);
		else
			_;
	}

	function numHashTypes() public view returns (uint) {

		return allHashTypes.length;
	}

	function addHashType(uint8 hashType, string description) public onlyByOwner {

		// Strings must be non-empty
		if (hashType == 0) require(false);
		if (bytes(description).length == 0) require(false);
		if (bytes(description).length > 64) require(false);

		string storage prvDescription = hashTypes[hashType];
		if (bytes(prvDescription).length == 0)
		{
			allHashTypes.push(hashType);
			hashTypes[hashType] = description;
			PubKeyHashTypeAdded(hashType);
		}
	}

	function isValidHashType(uint8 hashType) public view returns (bool) {

		string storage description = hashTypes[hashType];
		return (bytes(description).length > 0);
	}

	function addPubKeyHash(bytes20 userID, uint8 hashType, bytes pubKeyHash, bytes keyID) public onlyByOwner {

		if (!isValidHashType(hashType)) require(false);
		if (pubKeyHash.length == 0) require(false);
		if (keyID.length == 0) require(false);

		UserHashes storage userHashes = hashes[userID];
		if (!userHashes.initialized) {
			userHashes.initialized = true;
			UserAdded(userID);
		}

		HashInfo storage hashInfo = userHashes.hashes[hashType];
		if (hashInfo.blockNumber == 0)
		{
			hashInfo.pubKeyHash = pubKeyHash;
			hashInfo.keyID = keyID;
			hashInfo.blockNumber = block.number;
			PubKeyHashAdded(userID, hashType);
		}
	}

	function getPubKeyHash(bytes20 userID, uint8 hashType) public view returns (bytes) {

		UserHashes storage userHashes = hashes[userID];
		HashInfo storage hashInfo = userHashes.hashes[hashType];

		return hashInfo.pubKeyHash;
	}

	function getKeyID(bytes20 userID, uint8 hashType) public view returns (bytes) {

		UserHashes storage userHashes = hashes[userID];
		HashInfo storage hashInfo = userHashes.hashes[hashType];

		return hashInfo.keyID;
	}

	function getBlockNumber(bytes20 userID, uint8 hashType) public view returns (uint) {

		UserHashes storage userHashes = hashes[userID];
		HashInfo storage hashInfo = userHashes.hashes[hashType];

		return hashInfo.blockNumber;
	}
}