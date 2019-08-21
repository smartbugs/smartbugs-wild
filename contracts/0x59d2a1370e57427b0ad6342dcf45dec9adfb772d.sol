pragma solidity 0.4.25;

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

contract ERC721Token {
    function ownerOf(uint256) public view returns (address);
    function exists(uint256) public view returns (bool);
}

contract DragonModel {

    struct HealthAndMana {
        uint256 timestamp; 
        uint32 remainingHealth;
        uint32 remainingMana; 
        uint32 maxHealth;
        uint32 maxMana;
    }

    struct Level {
        uint8 level;
        uint8 experience;
        uint16 dnaPoints;
    }
    
    struct Tactics {
        uint8 melee;
        uint8 attack;
    }

    struct Battles {
        uint16 wins;
        uint16 defeats;
    }

    struct Skills {
        uint32 attack;
        uint32 defense;
        uint32 stamina;
        uint32 speed;
        uint32 intelligence;
    }
    
    struct Dragon {
        uint16 generation;
        uint256[4] genome;
        uint256[2] parents;
        uint8[11] types;
        uint256 birth;
    }

}

contract DragonStorage is DragonModel, ERC721Token {
    Dragon[] public dragons;
    mapping (uint256 => bytes32) public names;
    mapping (uint256 => HealthAndMana) public healthAndMana;
    mapping (uint256 => Tactics) public tactics;
    mapping (uint256 => Battles) public battles;
    mapping (uint256 => Skills) public skills;
    mapping (uint256 => Level) public levels;
    mapping (uint256 => uint32) public coolness;
    mapping (uint256 => uint8) public specialAttacks;
    mapping (uint256 => uint8) public specialDefenses;
    mapping (uint256 => mapping (uint8 => uint32)) public buffs;

    function length() external view returns (uint256) {}
    function getGenome(uint256 _id) external view returns (uint256[4]) {}
    function getParents(uint256 _id) external view returns (uint256[2]) {}
    function getDragonTypes(uint256 _id) external view returns (uint8[11]) {}
}

contract DragonCoreHelper {
    function calculateFullRegenerationTime(uint32) external pure returns (uint32) {}
    function calculateSpecialBattleSkill(uint8, uint32[5]) external pure returns (uint32, uint8, uint8) {}
    function getActiveGenes(uint256[4]) external pure returns (uint8[30]) {}
}

contract DragonCore {
    function isBreedingAllowed(uint8, uint16) public view returns (bool) {}
    function calculateMaxHealthAndManaWithBuffs(uint256) public view returns (uint32, uint32) {}
    function getCurrentHealthAndMana(uint256) public view returns (uint32, uint32, uint8, uint8) {}
    function calculateSpecialPeacefulSkill(uint256) public view returns (uint8, uint32, uint32) {}
}




//////////////CONTRACT//////////////




contract DragonGetter is Upgradable {
    using SafeMath32 for uint32;
    using SafeMath256 for uint256;

    DragonStorage _storage_;
    DragonCore dragonCore;
    DragonCoreHelper helper;

    uint256 constant GOLD_DECIMALS = 10 ** 18;

    uint256 constant DRAGON_NAME_2_LETTERS_PRICE = 100000 * GOLD_DECIMALS;
    uint256 constant DRAGON_NAME_3_LETTERS_PRICE = 10000 * GOLD_DECIMALS;
    uint256 constant DRAGON_NAME_4_LETTERS_PRICE = 1000 * GOLD_DECIMALS;

    function _checkExistence(uint256 _id) internal view {
        require(_storage_.exists(_id), "dragon doesn't exist");
    }

    function _min(uint32 lth, uint32 rth) internal pure returns (uint32) {
        return lth > rth ? rth : lth;
    }

    // GETTERS

    function getAmount() external view returns (uint256) {
        return _storage_.length().sub(1);
    }

    function isOwner(address _user, uint256 _tokenId) external view returns (bool) {
        return _user == _storage_.ownerOf(_tokenId);
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return _storage_.ownerOf(_tokenId);
    }

    function getGenome(uint256 _id) public view returns (uint8[30]) {
        _checkExistence(_id);
        return helper.getActiveGenes(_storage_.getGenome(_id));
    }

    function getComposedGenome(uint256 _id) external view returns (uint256[4]) {
        _checkExistence(_id);
        return _storage_.getGenome(_id);
    }

    function getSkills(uint256 _id) external view returns (uint32, uint32, uint32, uint32, uint32) {
        _checkExistence(_id);
        return _storage_.skills(_id);
    }

    // should be divided by 100
    function getCoolness(uint256 _id) public view returns (uint32) {
        _checkExistence(_id);
        return _storage_.coolness(_id);
    }

    function getLevel(uint256 _id) public view returns (uint8 level) {
        _checkExistence(_id);
        (level, , ) = _storage_.levels(_id);
    }

    function getHealthAndMana(uint256 _id) external view returns (
        uint256 timestamp,
        uint32 remainingHealth,
        uint32 remainingMana,
        uint32 maxHealth,
        uint32 maxMana
    ) {
        _checkExistence(_id);
        (
            timestamp,
            remainingHealth,
            remainingMana,
            maxHealth,
            maxMana
        ) = _storage_.healthAndMana(_id);
        (maxHealth, maxMana) = dragonCore.calculateMaxHealthAndManaWithBuffs(_id);

        remainingHealth = _min(remainingHealth, maxHealth);
        remainingMana = _min(remainingMana, maxMana);
    }

    function getCurrentHealthAndMana(uint256 _id) external view returns (
        uint32, uint32, uint8, uint8
    ) {
        _checkExistence(_id);
        return dragonCore.getCurrentHealthAndMana(_id);
    }

    function getFullRegenerationTime(uint256 _id) external view returns (uint32) {
        _checkExistence(_id);
        ( , , , uint32 _maxHealth, ) = _storage_.healthAndMana(_id);
        return helper.calculateFullRegenerationTime(_maxHealth);
    }

    function getDragonTypes(uint256 _id) external view returns (uint8[11]) {
        _checkExistence(_id);
        return _storage_.getDragonTypes(_id);
    }

    function getProfile(uint256 _id) external view returns (
        bytes32 name,
        uint16 generation,
        uint256 birth,
        uint8 level,
        uint8 experience,
        uint16 dnaPoints,
        bool isBreedingAllowed,
        uint32 coolness
    ) {
        _checkExistence(_id);
        name = _storage_.names(_id);
        (level, experience, dnaPoints) = _storage_.levels(_id);
        isBreedingAllowed = dragonCore.isBreedingAllowed(level, dnaPoints);
        (generation, birth) = _storage_.dragons(_id);
        coolness = _storage_.coolness(_id);

    }

    function getGeneration(uint256 _id) external view returns (uint16 generation) {
        _checkExistence(_id);
        (generation, ) = _storage_.dragons(_id);
    }

    function isBreedingAllowed(uint256 _id) external view returns (bool) {
        _checkExistence(_id);
        uint8 _level;
        uint16 _dnaPoints;
        (_level, , _dnaPoints) = _storage_.levels(_id);
        return dragonCore.isBreedingAllowed(_level, _dnaPoints);
    }

    function getTactics(uint256 _id) external view returns (uint8, uint8) {
        _checkExistence(_id);
        return _storage_.tactics(_id);
    }

    function getBattles(uint256 _id) external view returns (uint16, uint16) {
        _checkExistence(_id);
        return _storage_.battles(_id);
    }

    function getParents(uint256 _id) external view returns (uint256[2]) {
        _checkExistence(_id);
        return _storage_.getParents(_id);
    }

    function _getSpecialBattleSkill(uint256 _id, uint8 _dragonType) internal view returns (
        uint32 cost,
        uint8 factor,
        uint8 chance
    ) {
        _checkExistence(_id);
        uint32 _attack;
        uint32 _defense;
        uint32 _stamina;
        uint32 _speed;
        uint32 _intelligence;
        (_attack, _defense, _stamina, _speed, _intelligence) = _storage_.skills(_id);
        return helper.calculateSpecialBattleSkill(_dragonType, [_attack, _defense, _stamina, _speed, _intelligence]);
    }

    function getSpecialAttack(uint256 _id) external view returns (
        uint8 dragonType,
        uint32 cost,
        uint8 factor,
        uint8 chance
    ) {
        _checkExistence(_id);
        dragonType = _storage_.specialAttacks(_id);
        (cost, factor, chance) = _getSpecialBattleSkill(_id, dragonType);
    }

    function getSpecialDefense(uint256 _id) external view returns (
        uint8 dragonType,
        uint32 cost,
        uint8 factor,
        uint8 chance
    ) {
        _checkExistence(_id);
        dragonType = _storage_.specialDefenses(_id);
        (cost, factor, chance) = _getSpecialBattleSkill(_id, dragonType);
    }

    function getSpecialPeacefulSkill(uint256 _id) external view returns (uint8, uint32, uint32) {
        _checkExistence(_id);
        return dragonCore.calculateSpecialPeacefulSkill(_id);
    }

    function getBuffs(uint256 _id) external view returns (uint32[5]) {
        _checkExistence(_id);
        return [
            _storage_.buffs(_id, 1), // attack
            _storage_.buffs(_id, 2), // defense
            _storage_.buffs(_id, 3), // stamina
            _storage_.buffs(_id, 4), // speed
            _storage_.buffs(_id, 5)  // intelligence
        ];
    }

    function getDragonStrength(uint256 _id) external view returns (uint32 sum) {
        _checkExistence(_id);
        uint32 _attack;
        uint32 _defense;
        uint32 _stamina;
        uint32 _speed;
        uint32 _intelligence;
        (_attack, _defense, _stamina, _speed, _intelligence) = _storage_.skills(_id);
        sum = sum.add(_attack.mul(69));
        sum = sum.add(_defense.mul(217));
        sum = sum.add(_stamina.mul(232));
        sum = sum.add(_speed.mul(114));
        sum = sum.add(_intelligence.mul(151));
        sum = sum.div(100);
    }

    function getDragonNamePriceByLength(uint256 _length) external pure returns (uint256) {
        if (_length == 2) {
            return DRAGON_NAME_2_LETTERS_PRICE;
        } else if (_length == 3) {
            return DRAGON_NAME_3_LETTERS_PRICE;
        } else {
            return DRAGON_NAME_4_LETTERS_PRICE;
        }
    }

    function getDragonNamePrices() external pure returns (uint8[3] lengths, uint256[3] prices) {
        lengths = [2, 3, 4];
        prices = [
            DRAGON_NAME_2_LETTERS_PRICE,
            DRAGON_NAME_3_LETTERS_PRICE,
            DRAGON_NAME_4_LETTERS_PRICE
        ];
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        _storage_ = DragonStorage(_newDependencies[0]);
        dragonCore = DragonCore(_newDependencies[1]);
        helper = DragonCoreHelper(_newDependencies[2]);
    }
}