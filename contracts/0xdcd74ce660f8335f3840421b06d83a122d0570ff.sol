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

library SafeConvert {

    function toUint8(uint256 _value) internal pure returns (uint8) {
        assert(_value <= 255);
        return uint8(_value);
    }

    function toUint16(uint256 _value) internal pure returns (uint16) {
        assert(_value <= 2**16 - 1);
        return uint16(_value);
    }

    function toUint32(uint256 _value) internal pure returns (uint32) {
        assert(_value <= 2**32 - 1);
        return uint32(_value);
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

contract DragonParams {
    function dragonTypesFactors(uint8) external view returns (uint8[5]) {}
    function bodyPartsFactors(uint8) external view returns (uint8[5]) {}
    function geneTypesFactors(uint8) external view returns (uint8[5]) {}
    function experienceToNextLevel(uint8) external view returns (uint8) {}
    function dnaPoints(uint8) external view returns (uint16) {}
    function geneUpgradeDNAPoints(uint8) external view returns (uint8) {}
    function battlePoints() external view returns (uint8) {}
}

contract Name {
    using SafeMath256 for uint256;

    uint8 constant MIN_NAME_LENGTH = 2;
    uint8 constant MAX_NAME_LENGTH = 32;

    function _convertName(string _input) internal pure returns(bytes32 _initial, bytes32 _lowercase) {
        bytes memory _initialBytes = bytes(_input);
        assembly {
            _initial := mload(add(_initialBytes, 32))
        }
        _lowercase = _toLowercase(_input);
    }


    function _toLowercase(string _input) internal pure returns(bytes32 result) {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        //sorry limited to 32 characters
        require (_length <= 32 && _length >= 2, "string must be between 2 and 32 characters");
        // make sure it doesnt start with or end with space
        require(_temp[0] != 0x20 && _temp[_length.sub(1)] != 0x20, "string cannot start or end with space");
        // make sure first two characters are not 0x
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

        // create a bool to track if we have a non number character
        bool _hasNonNumber;

        // convert & check
        for (uint256 i = 0; i < _length; i = i.add(1))
        {
            // if its uppercase A-Z
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                // convert to lower case a-z
                _temp[i] = byte(uint256(_temp[i]).add(32));

                // we have a non number
                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                    // require character is a space
                    _temp[i] == 0x20 ||
                    // OR lowercase a-z
                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                    // or 0-9
                    (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                // make sure theres not 2x spaces in a row
                if (_temp[i] == 0x20)
                    require(_temp[i.add(1)] != 0x20, "string cannot contain consecutive spaces");

                // see if we have a character other than a number
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;
            }
        }

        require(_hasNonNumber == true, "string cannot be only numbers");

        assembly {
            result := mload(add(_temp, 32))
        }
    }
}

contract DragonUtils {
    using SafeMath8 for uint8;
    using SafeMath256 for uint256;

    using SafeConvert for uint256;


    function _getActiveGene(uint8[16] _gene) internal pure returns (uint8[3] gene) {
        uint8 _index = _getActiveGeneIndex(_gene); // find active gene
        for (uint8 i = 0; i < 3; i++) {
            gene[i] = _gene[i + (_index * 4)]; // get all data for this gene
        }
    }

    function _getActiveGeneIndex(uint8[16] _gene) internal pure returns (uint8) {
        return _gene[3] >= _gene[7] ? 0 : 1;
    }

    // returns 10 active genes (one for each part of the body) with the next structure:
    // each gene is an array of 3 elements:
    // 0 - type of dragon
    // 1 - gene type
    // 2 - gene level
    function _getActiveGenes(uint8[16][10] _genome) internal pure returns (uint8[30] genome) {
        uint8[3] memory _activeGene;
        for (uint8 i = 0; i < 10; i++) {
            _activeGene = _getActiveGene(_genome[i]);
            genome[i * 3] = _activeGene[0];
            genome[i * 3 + 1] = _activeGene[1];
            genome[i * 3 + 2] = _activeGene[2];
        }
    }

    function _getIndexAndFactor(uint8 _counter) internal pure returns (uint8 index, uint8 factor) {
        if (_counter < 44) index = 0;
        else if (_counter < 88) index = 1;
        else if (_counter < 132) index = 2;
        else index = 3;
        factor = _counter.add(1) % 4 == 0 ? 10 : 100;
    }

    function _parseGenome(uint256[4] _composed) internal pure returns (uint8[16][10] parsed) {
        uint8 counter = 160; // 40 genes with 4 values in each one
        uint8 _factor;
        uint8 _index;

        for (uint8 i = 0; i < 10; i++) {
            for (uint8 j = 0; j < 16; j++) {
                counter = counter.sub(1);
                // _index - index of value in genome array where current gene is stored
                // _factor - denominator that determines the number of digits
                (_index, _factor) = _getIndexAndFactor(counter);
                parsed[9 - i][15 - j] = (_composed[_index] % _factor).toUint8();
                _composed[_index] /= _factor;
            }
        }
    }

    function _composeGenome(uint8[16][10] _parsed) internal pure returns (uint256[4] composed) {
        uint8 counter = 0;
        uint8 _index;
        uint8 _factor;

        for (uint8 i = 0; i < 10; i++) {
            for (uint8 j = 0; j < 16; j++) {
                (_index, _factor) = _getIndexAndFactor(counter);
                composed[_index] = composed[_index].mul(_factor);
                composed[_index] = composed[_index].add(_parsed[i][j]);
                counter = counter.add(1);
            }
        }
    }
}

contract DragonCoreHelper is Upgradable, DragonUtils, Name {
    using SafeMath16 for uint16;
    using SafeMath32 for uint32;
    using SafeMath256 for uint256;
    using SafeConvert for uint32;
    using SafeConvert for uint256;

    DragonParams params;

    uint8 constant PERCENT_MULTIPLIER = 100;
    uint8 constant MAX_PERCENTAGE = 100;

    uint8 constant MAX_GENE_LVL = 99;

    uint8 constant MAX_LEVEL = 10;

    function _min(uint32 lth, uint32 rth) internal pure returns (uint32) {
        return lth > rth ? rth : lth;
    }

    function _calculateSkillWithBuff(uint32 _skill, uint32 _buff) internal pure returns (uint32) {
        return _buff > 0 ? _skill.mul(_buff).div(100) : _skill; // buff is multiplied by 100
    }

    function _calculateRegenerationSpeed(uint32 _max) internal pure returns (uint32) {
        // because HP/mana is multiplied by 100 so we need to have step multiplied by 100 too
        return _sqrt(_max.mul(100)).div(2).div(1 minutes); // hp/mana in second
    }

    function calculateFullRegenerationTime(uint32 _max) external pure returns (uint32) { // in seconds
        return _max.div(_calculateRegenerationSpeed(_max));
    }

    function calculateCurrent(
        uint256 _pastTime,
        uint32 _max,
        uint32 _remaining
    ) external pure returns (
        uint32 current,
        uint8 percentage
    ) {
        if (_remaining >= _max) {
            return (_max, MAX_PERCENTAGE);
        }
        uint32 _speed = _calculateRegenerationSpeed(_max); // points per second
        uint32 _secondsToFull = _max.sub(_remaining).div(_speed); // seconds to full
        uint32 _secondsPassed = _pastTime.toUint32(); // seconds that already passed
        if (_secondsPassed >= _secondsToFull.add(1)) {
            return (_max, MAX_PERCENTAGE); // return full if passed more or equal to needed
        }
        current = _min(_max, _remaining.add(_speed.mul(_secondsPassed)));
        percentage = _min(MAX_PERCENTAGE, current.mul(PERCENT_MULTIPLIER).div(_max)).toUint8();
    }

    function calculateHealthAndMana(
        uint32 _initStamina,
        uint32 _initIntelligence,
        uint32 _staminaBuff,
        uint32 _intelligenceBuff
    ) external pure returns (uint32 health, uint32 mana) {
        uint32 _stamina = _initStamina;
        uint32 _intelligence = _initIntelligence;

        _stamina = _calculateSkillWithBuff(_stamina, _staminaBuff);
        _intelligence = _calculateSkillWithBuff(_intelligence, _intelligenceBuff);

        health = _stamina.mul(5);
        mana = _intelligence.mul(5);
    }

    function _sqrt(uint32 x) internal pure returns (uint32 y) {
        uint32 z = x.add(1).div(2);
        y = x;
        while (z < y) {
            y = z;
            z = x.div(z).add(z).div(2);
        }
    }

    // _dragonTypes[i] in [0..39] range, sum of all _dragonTypes items = 40 (number of genes)
    // _random in [0..39] range
    function getSpecialBattleSkillDragonType(uint8[11] _dragonTypes, uint256 _random) external pure returns (uint8 skillDragonType) {
        uint256 _currentChance;
        for (uint8 i = 0; i < 11; i++) {
            _currentChance = _currentChance.add(_dragonTypes[i]);
            if (_random < _currentChance) {
                skillDragonType = i;
                break;
            }
        }
    }

    function _getBaseSkillIndex(uint8 _dragonType) internal pure returns (uint8) {
        // 2 - stamina
        // 0 - attack
        // 3 - speed
        // 1 - defense
        // 4 - intelligence
        uint8[5] memory _skills = [2, 0, 3, 1, 4];
        return _skills[_dragonType];
    }

    function calculateSpecialBattleSkill(
        uint8 _dragonType,
        uint32[5] _skills
    ) external pure returns (
        uint32 cost,
        uint8 factor,
        uint8 chance
    ) {
        uint32 _baseSkill = _skills[_getBaseSkillIndex(_dragonType)];
        uint32 _intelligence = _skills[4];

        cost = _baseSkill.mul(3);
        factor = _sqrt(_baseSkill.div(3)).add(10).toUint8(); // factor is increased by 10
        // skill is multiplied by 100 so we divide the result by sqrt(100) = 10
        chance = _sqrt(_intelligence).div(10).add(10).toUint8();
    }

    function _getSkillIndexBySpecialPeacefulSkillClass(
        uint8 _class
    ) internal pure returns (uint8) {
        // 0 - attack
        // 1 - defense
        // 2 - stamina
        // 3 - speed
        // 4 - intelligence
        uint8[8] memory _buffsIndexes = [0, 0, 1, 2, 3, 4, 2, 4]; // 0 item - no such class
        return _buffsIndexes[_class];
    }

    function calculateSpecialPeacefulSkill(
        uint8 _class,
        uint32[5] _skills,
        uint32[5] _buffs
    ) external pure returns (uint32 cost, uint32 effect) {
        uint32 _index = _getSkillIndexBySpecialPeacefulSkillClass(_class);
        uint32 _skill = _calculateSkillWithBuff(_skills[_index], _buffs[_index]);
        if (_class == 6 || _class == 7) { // healing or mana recharge
            effect = _skill.mul(2);
        } else {
            // sqrt(skill / 30) + 1
            effect = _sqrt(_skill.mul(10).div(3)).add(100); // effect is increased by 100 as skills
        }
        cost = _skill.mul(3);
    }

    function _getGeneVarietyFactor(uint8 _type) internal pure returns (uint32 value) {
        // multiplied by 10
        if (_type == 0) value = 5;
        else if (_type < 5) value = 12;
        else if (_type < 8) value = 16;
        else value = 28;
    }

    function calculateCoolness(uint256[4] _composedGenome) external pure returns (uint32 coolness) {
        uint8[16][10] memory _genome = _parseGenome(_composedGenome);
        uint32 _geneVarietyFactor; // multiplied by 10
        uint8 _strengthCoefficient; // multiplied by 10
        uint8 _geneLevel;
        for (uint8 i = 0; i < 10; i++) {
            for (uint8 j = 0; j < 4; j++) {
                _geneVarietyFactor = _getGeneVarietyFactor(_genome[i][(j * 4) + 1]);
                _strengthCoefficient = (_genome[i][(j * 4) + 3] == 0) ? 7 : 10; // recessive or dominant
                _geneLevel = _genome[i][(j * 4) + 2];
                coolness = coolness.add(_geneVarietyFactor.mul(_geneLevel).mul(_strengthCoefficient));
            }
        }
    }

    function calculateSkills(
        uint256[4] _composed
    ) external view returns (
        uint32, uint32, uint32, uint32, uint32
    ) {
        uint8[30] memory _activeGenes = _getActiveGenes(_parseGenome(_composed));
        uint8[5] memory _dragonTypeFactors;
        uint8[5] memory _bodyPartFactors;
        uint8[5] memory _geneTypeFactors;
        uint8 _level;
        uint32[5] memory _skills;

        for (uint8 i = 0; i < 10; i++) {
            _bodyPartFactors = params.bodyPartsFactors(i);
            _dragonTypeFactors = params.dragonTypesFactors(_activeGenes[i * 3]);
            _geneTypeFactors = params.geneTypesFactors(_activeGenes[i * 3 + 1]);
            _level = _activeGenes[i * 3 + 2];

            for (uint8 j = 0; j < 5; j++) {
                _skills[j] = _skills[j].add(uint32(_dragonTypeFactors[j]).mul(_bodyPartFactors[j]).mul(_geneTypeFactors[j]).mul(_level));
            }
        }
        return (_skills[0], _skills[1], _skills[2], _skills[3], _skills[4]);
    }

    function calculateExperience(
        uint8 _level,
        uint256 _experience,
        uint16 _dnaPoints,
        uint256 _factor
    ) external view returns (
        uint8 level,
        uint256 experience,
        uint16 dnaPoints
    ) {
        level = _level;
        experience = _experience;
        dnaPoints = _dnaPoints;

        uint8 _expToNextLvl;
        // _factor is multiplied by 10
        experience = experience.add(uint256(params.battlePoints()).mul(_factor).div(10));
        _expToNextLvl = params.experienceToNextLevel(level);
        while (experience >= _expToNextLvl && level < MAX_LEVEL) {
            experience = experience.sub(_expToNextLvl);
            level = level.add(1);
            dnaPoints = dnaPoints.add(params.dnaPoints(level));
            if (level < MAX_LEVEL) {
                _expToNextLvl = params.experienceToNextLevel(level);
            }
        }
    }

    function checkAndConvertName(string _input) external pure returns(bytes32, bytes32) {
        return _convertName(_input);
    }

    function _checkIfEnoughDNAPoints(bool _isEnough) internal pure {
        require(_isEnough, "not enough DNA points for upgrade");
    }

    function upgradeGenes(
        uint256[4] _composedGenome,
        uint16[10] _dnaPoints,
        uint16 _availableDNAPoints
    ) external view returns (
        uint256[4],
        uint16
    ) {
        uint16 _sum;
        uint8 _i;
        for (_i = 0; _i < 10; _i++) {
            _checkIfEnoughDNAPoints(_dnaPoints[_i] <= _availableDNAPoints);
            _sum = _sum.add(_dnaPoints[_i]);
        }
        _checkIfEnoughDNAPoints(_sum <= _availableDNAPoints);
        _sum = 0;

        uint8[16][10] memory _genome = _parseGenome(_composedGenome);
        uint8 _geneLevelIndex;
        uint8 _geneLevel;
        uint16 _geneUpgradeDNAPoints;
        uint8 _levelsToUpgrade;
        uint16 _specificDNAPoints;
        for (_i = 0; _i < 10; _i++) { // 10 active genes
            _specificDNAPoints = _dnaPoints[_i]; // points to upgrade current gene
            if (_specificDNAPoints > 0) {
                _geneLevelIndex = _getActiveGeneIndex(_genome[_i]).mul(4).add(2); // index of main gene level in genome
                _geneLevel = _genome[_i][_geneLevelIndex]; // current level of gene
                if (_geneLevel < MAX_GENE_LVL) {
                    // amount of points to upgrade to next level
                    _geneUpgradeDNAPoints = params.geneUpgradeDNAPoints(_geneLevel);
                    // while enough points and gene level is lower than max gene level
                    while (_specificDNAPoints >= _geneUpgradeDNAPoints && _geneLevel.add(_levelsToUpgrade) < MAX_GENE_LVL) {
                        _levelsToUpgrade = _levelsToUpgrade.add(1);
                        _specificDNAPoints = _specificDNAPoints.sub(_geneUpgradeDNAPoints);
                        _sum = _sum.add(_geneUpgradeDNAPoints); // the sum of used points
                        if (_geneLevel.add(_levelsToUpgrade) < MAX_GENE_LVL) {
                            _geneUpgradeDNAPoints = params.geneUpgradeDNAPoints(_geneLevel.add(_levelsToUpgrade));
                        }
                    }
                    _genome[_i][_geneLevelIndex] = _geneLevel.add(_levelsToUpgrade); // add levels to current gene
                    _levelsToUpgrade = 0;
                }
            }
        }
        return (_composeGenome(_genome), _sum);
    }

    function getActiveGenes(uint256[4] _composed) external pure returns (uint8[30]) {
        uint8[16][10] memory _genome = _parseGenome(_composed);
        return _getActiveGenes(_genome);
    }

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        params = DragonParams(_newDependencies[0]);
    }
}