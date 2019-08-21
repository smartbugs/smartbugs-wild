pragma solidity ^0.4.16;

contract Permissions {

	address ownerAddress;
	address storageAddress;
	address callerAddress;

	function Permissions() public {
		ownerAddress = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == ownerAddress);
		_;
	}

	modifier onlyCaller() {
		require(msg.sender == callerAddress);
		_;
	}

	function getOwner() view external returns (address) {
		return ownerAddress;
	}

	function getStorageAddress() view external returns (address) {
		return storageAddress;
	}

	function getCaller() view external returns (address) {
		return callerAddress;
	}

	function transferOwnership(address newOwner) external onlyOwner {
		if (newOwner != address(0)) {
				ownerAddress = newOwner;
		}
	}
	function newStorage(address _new) external onlyOwner {
		if (_new != address(0)) {
				storageAddress = _new;
		}
	}
	function newCaller(address _new) external onlyOwner {
		if (_new != address(0)) {
				callerAddress = _new;
		}
	}
}

contract Creatures is Permissions {
	struct Creature {
		uint16 species;
		uint8 subSpecies;
		uint8 eyeColor;
		uint64 timestamp;
	}
	Creature[] creatures;

	mapping (uint256 =>	address) public creatureIndexToOwner;
	mapping (address => uint256) ownershipTokenCount;

	event CreateCreature(uint256 id, address indexed owner);
	event Transfer(address _from, address _to, uint256 creatureID);

	function add(address _owner, uint16 _species, uint8 _subSpecies, uint8 _eyeColor) external onlyCaller {
		// do checks in caller function
		Creature memory _creature = Creature({
			species: _species,
			subSpecies: _subSpecies,
			eyeColor: _eyeColor,
			timestamp: uint64(now)
		});
		uint256 newCreatureID = creatures.push(_creature) - 1;
		transfer(0, _owner, newCreatureID);
		CreateCreature(newCreatureID, _owner);
	}
	function getCreature(uint256 id) external view returns (address, uint16, uint8, uint8, uint64) {
		Creature storage c = creatures[id];
		address owner = creatureIndexToOwner[id];
		return (
			owner,
			c.species,
			c.subSpecies,
			c.eyeColor,
			c.timestamp
		);
	}
	function transfer(address _from, address _to, uint256 _tokenId) public onlyCaller {
		// do checks in caller function
		creatureIndexToOwner[_tokenId] = _to;
		if (_from != address(0)) {
			ownershipTokenCount[_from]--;
		}
		ownershipTokenCount[_to]++;
		Transfer(_from, _to, _tokenId);
	}
}