pragma solidity 0.4.25;

library SafeMath8 {

    function mul(uint8 a, uint8 b) internal pure returns (uint8) {
        if (a == 0) {
            return 0;
        }
        uint8 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint8 a, uint8 b) internal pure returns (uint8) {
        return a / b;
    }

    function sub(uint8 a, uint8 b) internal pure returns (uint8) {
        assert(b <= a);
        return a - b;
    }

    function add(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a + b;
        assert(c >= a);
        return c;
    }

    function pow(uint8 a, uint8 b) internal pure returns (uint8) {
        if (a == 0) return 0;
        if (b == 0) return 1;

        uint8 c = a ** b;
        assert(c / (a ** (b - 1)) == a);
        return c;
    }
}

library SafeMath16 {

    function mul(uint16 a, uint16 b) internal pure returns (uint16) {
        if (a == 0) {
            return 0;
        }
        uint16 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint16 a, uint16 b) internal pure returns (uint16) {
        return a / b;
    }

    function sub(uint16 a, uint16 b) internal pure returns (uint16) {
        assert(b <= a);
        return a - b;
    }

    function add(uint16 a, uint16 b) internal pure returns (uint16) {
        uint16 c = a + b;
        assert(c >= a);
        return c;
    }

    function pow(uint16 a, uint16 b) internal pure returns (uint16) {
        if (a == 0) return 0;
        if (b == 0) return 1;

        uint16 c = a ** b;
        assert(c / (a ** (b - 1)) == a);
        return c;
    }
}

library SafeMath32 {

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {
        if (a == 0) {
            return 0;
        }
        uint32 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        return a / b;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        assert(b <= a);
        return a - b;
    }

    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        assert(c >= a);
        return c;
    }

    function pow(uint32 a, uint32 b) internal pure returns (uint32) {
        if (a == 0) return 0;
        if (b == 0) return 1;

        uint32 c = a ** b;
        assert(c / (a ** (b - 1)) == a);
        return c;
    }
}

library SafeMath256 {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function pow(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        if (b == 0) return 1;

        uint256 c = a ** b;
        assert(c / (a ** (b - 1)) == a);
        return c;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function _validateAddress(address _addr) internal pure {
        require(_addr != address(0), "invalid address");
    }

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not a contract owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _validateAddress(newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract Controllable is Ownable {
    mapping(address => bool) controllers;

    modifier onlyController {
        require(_isController(msg.sender), "no controller rights");
        _;
    }

    function _isController(address _controller) internal view returns (bool) {
        return controllers[_controller];
    }

    function _setControllers(address[] _controllers) internal {
        for (uint256 i = 0; i < _controllers.length; i++) {
            _validateAddress(_controllers[i]);
            controllers[_controllers[i]] = true;
        }
    }
}

contract Upgradable is Controllable {
    address[] internalDependencies;
    address[] externalDependencies;

    function getInternalDependencies() public view returns(address[]) {
        return internalDependencies;
    }

    function getExternalDependencies() public view returns(address[]) {
        return externalDependencies;
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        for (uint256 i = 0; i < _newDependencies.length; i++) {
            _validateAddress(_newDependencies[i]);
        }
        internalDependencies = _newDependencies;
    }

    function setExternalDependencies(address[] _newDependencies) public onlyOwner {
        externalDependencies = _newDependencies;
        _setControllers(_newDependencies);
    }
}

contract DragonCore {
    function setRemainingHealthAndMana(uint256, uint32, uint32) external;
    function increaseExperience(uint256, uint256) external;
    function payDNAPointsForBreeding(uint256) external;
    function upgradeGenes(uint256, uint16[10]) external;
    function increaseWins(uint256) external;
    function increaseDefeats(uint256) external;
    function setTactics(uint256, uint8, uint8) external;
    function setSpecialPeacefulSkill(uint256, uint8) external;
    function useSpecialPeacefulSkill(address, uint256, uint256) external;
    function setBuff(uint256, uint8, uint32) external;
    function createDragon(address, uint16, uint256[2], uint256[4], uint8[11]) external returns (uint256);
    function setName(uint256, string) external returns (bytes32);
}

contract DragonGetter {
    function getAmount() external view returns (uint256);
    function getComposedGenome(uint256) external view returns (uint256[4]);
    function getCoolness(uint256) public view returns (uint32);
    function getFullRegenerationTime(uint256) external view returns (uint32);
    function getDragonTypes(uint256) external view returns (uint8[11]);
    function getGeneration(uint256) external view returns (uint16);
    function getParents(uint256) external view returns (uint256[2]);
}

contract DragonGenetics {
    function createGenome(uint256[2], uint256[4], uint256[4], uint256) external view returns (uint256[4], uint8[11]);
    function createGenomeForGenesis(uint8, uint256) external view returns (uint256[4]);
}

contract EggCore {
    function ownerOf(uint256) external view returns (address);
    function get(uint256) external view returns (uint256[2], uint8);
    function isOwner(address, uint256) external view returns (bool);
    function getAllEggs() external view returns (uint256[]);
    function create(address, uint256[2], uint8) external returns (uint256);
    function remove(address, uint256) external;
}

contract DragonLeaderboard {
    function update(uint256, uint32) external;
    function getDragonsFromLeaderboard() external view returns (uint256[10]);
    function updateRewardTime() external;
    function getRewards(uint256) external view returns (uint256[10]);
    function getDate() external view returns (uint256, uint256);
}

contract Nest {
    mapping (uint256 => bool) public inNest;
    function getEggs() external view returns (uint256[2]);
    function add(uint256) external returns (bool, uint256, uint256);
}




//////////////CONTRACT//////////////




contract Core is Upgradable {
    using SafeMath8 for uint8;
    using SafeMath16 for uint16;
    using SafeMath32 for uint32;
    using SafeMath256 for uint256;

    DragonCore dragonCore;
    DragonGetter dragonGetter;
    DragonGenetics dragonGenetics;
    EggCore eggCore;
    DragonLeaderboard leaderboard;
    Nest nest;

    function _max(uint16 lth, uint16 rth) internal pure returns (uint16) {
        if (lth > rth) {
            return lth;
        } else {
            return rth;
        }
    }

    function createEgg(
        address _sender,
        uint8 _dragonType
    ) external onlyController returns (uint256) {
        return eggCore.create(_sender, [uint256(0), uint256(0)], _dragonType);
    }

    function sendToNest(
        uint256 _id
    ) external onlyController returns (
        bool isHatched,
        uint256 newDragonId,
        uint256 hatchedId,
        address owner
    ) {
        uint256 _randomForEggOpening;
        (isHatched, hatchedId, _randomForEggOpening) = nest.add(_id);
        // if any egg was hatched
        if (isHatched) {
            owner = eggCore.ownerOf(hatchedId);
            newDragonId = openEgg(owner, hatchedId, _randomForEggOpening);
        }
    }

    function openEgg(
        address _owner,
        uint256 _eggId,
        uint256 _random
    ) internal returns (uint256 newDragonId) {
        uint256[2] memory _parents;
        uint8 _dragonType;
        (_parents, _dragonType) = eggCore.get(_eggId);

        uint256[4] memory _genome;
        uint8[11] memory _dragonTypesArray;
        uint16 _generation;
        // if genesis
        if (_parents[0] == 0 && _parents[1] == 0) {
            _generation = 0;
            _genome = dragonGenetics.createGenomeForGenesis(_dragonType, _random);
            _dragonTypesArray[_dragonType] = 40; // 40 genes of 1 type
        } else {
            uint256[4] memory _momGenome = dragonGetter.getComposedGenome(_parents[0]);
            uint256[4] memory _dadGenome = dragonGetter.getComposedGenome(_parents[1]);
            (_genome, _dragonTypesArray) = dragonGenetics.createGenome(_parents, _momGenome, _dadGenome, _random);
            _generation = _max(
                dragonGetter.getGeneration(_parents[0]),
                dragonGetter.getGeneration(_parents[1])
            ).add(1);
        }

        newDragonId = dragonCore.createDragon(_owner, _generation, _parents, _genome, _dragonTypesArray);
        eggCore.remove(_owner, _eggId);

        uint32 _coolness = dragonGetter.getCoolness(newDragonId);
        leaderboard.update(newDragonId, _coolness);
    }

    function breed(
        address _sender,
        uint256 _momId,
        uint256 _dadId
    ) external onlyController returns (uint256) {
        dragonCore.payDNAPointsForBreeding(_momId);
        dragonCore.payDNAPointsForBreeding(_dadId);
        return eggCore.create(_sender, [_momId, _dadId], 0);
    }

    function setDragonRemainingHealthAndMana(uint256 _id, uint32 _health, uint32 _mana) external onlyController {
        return dragonCore.setRemainingHealthAndMana(_id, _health, _mana);
    }

    function increaseDragonExperience(uint256 _id, uint256 _factor) external onlyController {
        dragonCore.increaseExperience(_id, _factor);
    }

    function upgradeDragonGenes(uint256 _id, uint16[10] _dnaPoints) external onlyController {
        dragonCore.upgradeGenes(_id, _dnaPoints);

        uint32 _coolness = dragonGetter.getCoolness(_id);
        leaderboard.update(_id, _coolness);
    }

    function increaseDragonWins(uint256 _id) external onlyController {
        dragonCore.increaseWins(_id);
    }

    function increaseDragonDefeats(uint256 _id) external onlyController {
        dragonCore.increaseDefeats(_id);
    }

    function setDragonTactics(uint256 _id, uint8 _melee, uint8 _attack) external onlyController {
        dragonCore.setTactics(_id, _melee, _attack);
    }

    function setDragonName(uint256 _id, string _name) external onlyController returns (bytes32) {
        return dragonCore.setName(_id, _name);
    }

    function setDragonSpecialPeacefulSkill(uint256 _id, uint8 _class) external onlyController {
        dragonCore.setSpecialPeacefulSkill(_id, _class);
    }

    function useDragonSpecialPeacefulSkill(
        address _sender,
        uint256 _id,
        uint256 _target
    ) external onlyController {
        dragonCore.useSpecialPeacefulSkill(_sender, _id, _target);
    }

    function resetDragonBuffs(uint256 _id) external onlyController {
        dragonCore.setBuff(_id, 1, 0); // attack
        dragonCore.setBuff(_id, 2, 0); // defense
        dragonCore.setBuff(_id, 3, 0); // stamina
        dragonCore.setBuff(_id, 4, 0); // speed
        dragonCore.setBuff(_id, 5, 0); // intelligence
    }

    function updateLeaderboardRewardTime() external onlyController {
        return leaderboard.updateRewardTime();
    }

    // GETTERS

    function getDragonFullRegenerationTime(uint256 _id) external view returns (uint32 time) {
        return dragonGetter.getFullRegenerationTime(_id);
    }

    function isEggOwner(address _user, uint256 _tokenId) external view returns (bool) {
        return eggCore.isOwner(_user, _tokenId);
    }

    function isEggInNest(uint256 _id) external view returns (bool) {
        return nest.inNest(_id);
    }

    function getEggsInNest() external view returns (uint256[2]) {
        return nest.getEggs();
    }

    function getEgg(uint256 _id) external view returns (uint16, uint32, uint256[2], uint8[11], uint8[11]) {
        uint256[2] memory parents;
        uint8 _dragonType;
        (parents, _dragonType) = eggCore.get(_id);

        uint8[11] memory momDragonTypes;
        uint8[11] memory dadDragonTypes;
        uint32 coolness;
        uint16 gen;
        // if genesis
        if (parents[0] == 0 && parents[1] == 0) {
            momDragonTypes[_dragonType] = 100;
            dadDragonTypes[_dragonType] = 100;
            coolness = 3600;
        } else {
            momDragonTypes = dragonGetter.getDragonTypes(parents[0]);
            dadDragonTypes = dragonGetter.getDragonTypes(parents[1]);
            coolness = dragonGetter.getCoolness(parents[0]).add(dragonGetter.getCoolness(parents[1])).div(2);
            uint16 _momGeneration = dragonGetter.getGeneration(parents[0]);
            uint16 _dadGeneration = dragonGetter.getGeneration(parents[1]);
            gen = _max(_momGeneration, _dadGeneration).add(1);
        }
        return (gen, coolness, parents, momDragonTypes, dadDragonTypes);
    }

    function getDragonChildren(uint256 _id) external view returns (
        uint256[10] dragonsChildren,
        uint256[10] eggsChildren
    ) {
        uint8 _counter;
        uint256[2] memory _parents;
        uint256 i;
        for (i = _id.add(1); i <= dragonGetter.getAmount() && _counter < 10; i++) {
            _parents = dragonGetter.getParents(i);
            if (_parents[0] == _id || _parents[1] == _id) {
                dragonsChildren[_counter] = i;
                _counter = _counter.add(1);
            }
        }
        _counter = 0;
        uint256[] memory eggs = eggCore.getAllEggs();
        for (i = 0; i < eggs.length && _counter < 10; i++) {
            (_parents, ) = eggCore.get(eggs[i]);
            if (_parents[0] == _id || _parents[1] == _id) {
                eggsChildren[_counter] = eggs[i];
                _counter = _counter.add(1);
            }
        }
    }

    function getDragonsFromLeaderboard() external view returns (uint256[10]) {
        return leaderboard.getDragonsFromLeaderboard();
    }

    function getLeaderboardRewards(
        uint256 _hatchingPrice
    ) external view returns (
        uint256[10]
    ) {
        return leaderboard.getRewards(_hatchingPrice);
    }

    function getLeaderboardRewardDate() external view returns (uint256, uint256) {
        return leaderboard.getDate();
    }

    // UPDATE CONTRACT

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        dragonCore = DragonCore(_newDependencies[0]);
        dragonGetter = DragonGetter(_newDependencies[1]);
        dragonGenetics = DragonGenetics(_newDependencies[2]);
        eggCore = EggCore(_newDependencies[3]);
        leaderboard = DragonLeaderboard(_newDependencies[4]);
        nest = Nest(_newDependencies[5]);
    }
}