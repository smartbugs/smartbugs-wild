pragma solidity ^0.4.16;

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


contract CreaturesInterface is Permissions {

	mapping (uint8 => uint256) public creatureCosts;

	function CreaturesInterface() public {
		creatureCosts[0] = .10 ether;
		creatureCosts[1] = .25 ether;
		creatureCosts[2] = .12 ether;
		creatureCosts[3] = .50 ether;
		creatureCosts[4] = .10 ether;
		creatureCosts[5] = 2.0 ether;
		creatureCosts[6] = 2.0 ether;
		creatureCosts[7] = 1.0 ether;
		creatureCosts[8] = .01 ether;
		creatureCosts[9] = .025 ether;
	}

	function addCreature(uint16 _species, uint8 _subSpecies, uint8 _eyeColor) external payable {
		require(_species == 0); // only one species available for now
		require(creatureCosts[_subSpecies] > 0);
		require(msg.value >= creatureCosts[_subSpecies]);
		Creatures creatureStorage = Creatures(storageAddress);
		creatureStorage.add(msg.sender, _species, _subSpecies, _eyeColor);
	}
    function withdrawBalance() external onlyOwner {
        ownerAddress.transfer(this.balance);
    }
}