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

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused, "contract is paused");
        _;
    }

    modifier whenPaused() {
        require(paused, "contract is not paused");
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
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

contract Getter {
    function getDragonProfile(uint256) external view returns (bytes32, uint16, uint256, uint8, uint8, uint16, bool, uint32);
    function getDragonStrength(uint256) external view returns (uint32);
    function getDragonCurrentHealthAndMana(uint256) external view returns (uint32, uint32, uint8, uint8);
    function getDragonHealthAndMana(uint256) external view returns (uint256, uint32, uint32, uint32, uint32);
    function getDragonsAmount() external view returns (uint256);
    function isDragonOwner(address, uint256) external view returns (bool);
    function ownerOfDragon(uint256) public view returns (address);
    function isDragonInGladiatorBattle(uint256) public view returns (bool);
}

contract Core is Upgradable {
    function setDragonRemainingHealthAndMana(uint256, uint32, uint32) external;
    function increaseDragonExperience(uint256, uint256) external;
    function increaseDragonWins(uint256) external;
    function increaseDragonDefeats(uint256) external;
    function resetDragonBuffs(uint256) external;
    function getDragonFullRegenerationTime(uint256) external view returns (uint32);
}

contract Battle {
    function start(uint256, uint256, uint8[2], uint8[2], uint256, bool) external returns (uint256[2], uint32, uint32, uint32, uint32, uint256);
}

contract Treasury {
    uint256 public hatchingPrice;
    function giveGold(address, uint256) external;
    function remainingGold() external view returns (uint256);
}

contract Random {
    function random(uint256) external view returns (uint256);
}




//////////////CONTRACT//////////////




contract BattleController is Upgradable {
    using SafeMath8 for uint8;
    using SafeMath16 for uint16;
    using SafeMath32 for uint32;
    using SafeMath256 for uint256;

    Core core;
    Battle battle;
    Treasury treasury;
    Getter getter;
    Random random;

    // stores date to which dragon is untouchable as opponent for the battle
    mapping (uint256 => uint256) lastBattleDate;

    uint8 constant MAX_PERCENTAGE = 100;
    uint8 constant MIN_HEALTH_PERCENTAGE = 50;
    uint8 constant MAX_TACTICS_PERCENTAGE = 80;
    uint8 constant MIN_TACTICS_PERCENTAGE = 20;
    uint8 constant PERCENT_MULTIPLIER = 100;
    uint8 constant DRAGON_STRENGTH_DIFFERENCE_PERCENTAGE = 10;

    uint256 constant GOLD_REWARD_MULTIPLIER = 10 ** 18;

    function _min(uint256 lth, uint256 rth) internal pure returns (uint256) {
        return lth > rth ? rth : lth;
    }

    function _isTouchable(uint256 _id) internal view returns (bool) {
        uint32 _regenerationTime = core.getDragonFullRegenerationTime(_id);
        return lastBattleDate[_id].add(_regenerationTime.mul(4)) < now;
    }

    function _checkBattlePossibility(
        address _sender,
        uint256 _id,
        uint256 _opponentId,
        uint8[2] _tactics
    ) internal view {
        require(getter.isDragonOwner(_sender, _id), "not an owner");
        require(!getter.isDragonOwner(_sender, _opponentId), "can't be owner of opponent dragon");
        require(!getter.isDragonOwner(address(0), _opponentId), "opponent dragon has no owner");

        require(!getter.isDragonInGladiatorBattle(_id), "your dragon participates in gladiator battle");
        require(!getter.isDragonInGladiatorBattle(_opponentId), "opponent dragon participates in gladiator battle");

        require(_isTouchable(_opponentId), "opponent dragon is untouchable");

        require(
            _tactics[0] >= MIN_TACTICS_PERCENTAGE &&
            _tactics[0] <= MAX_TACTICS_PERCENTAGE &&
            _tactics[1] >= MIN_TACTICS_PERCENTAGE &&
            _tactics[1] <= MAX_TACTICS_PERCENTAGE,
            "tactics value must be between 20 and 80"
        );

        uint8 _attackerHealthPercentage;
        uint8 _attackerManaPercentage;
        ( , , _attackerHealthPercentage, _attackerManaPercentage) = getter.getDragonCurrentHealthAndMana(_id);
        require(
            _attackerHealthPercentage >= MIN_HEALTH_PERCENTAGE,
            "dragon's health less than 50%"
        );
        uint8 _opponentHealthPercentage;
        uint8 _opponentManaPercentage;
        ( , , _opponentHealthPercentage, _opponentManaPercentage) = getter.getDragonCurrentHealthAndMana(_opponentId);
        require(
            _opponentHealthPercentage == MAX_PERCENTAGE &&
            _opponentManaPercentage == MAX_PERCENTAGE,
            "opponent health and/or mana is not full"
        );
    }

    function startBattle(
        address _sender,
        uint256 _id,
        uint256 _opponentId,
        uint8[2] _tactics
    ) external onlyController returns (
        uint256 battleId,
        uint256 seed,
        uint256[2] winnerLooserIds
    ) {
        _checkBattlePossibility(_sender, _id, _opponentId, _tactics);

        seed = random.random(2**256 - 1);

        uint32 _winnerHealth;
        uint32 _winnerMana;
        uint32 _looserHealth;
        uint32 _looserMana;

        (
            winnerLooserIds,
            _winnerHealth, _winnerMana,
            _looserHealth, _looserMana,
            battleId
        ) = battle.start(
            _id,
            _opponentId,
            _tactics,
            [0, 0],
            seed,
            false
        );

        core.setDragonRemainingHealthAndMana(winnerLooserIds[0], _winnerHealth, _winnerMana);
        core.setDragonRemainingHealthAndMana(winnerLooserIds[1], _looserHealth, _looserMana);

        core.increaseDragonWins(winnerLooserIds[0]);
        core.increaseDragonDefeats(winnerLooserIds[1]);

        lastBattleDate[_opponentId] = now;

        _payBattleRewards(
            _sender,
            _id,
            _opponentId,
            winnerLooserIds[0]
        );
    }

    function _payBattleRewards(
        address _sender,
        uint256 _id,
        uint256 _opponentId,
        uint256 _winnerId
    ) internal {
        uint32 _strength = getter.getDragonStrength(_id);
        uint32 _opponentStrength = getter.getDragonStrength(_opponentId);
        bool _isAttackerWinner = _id == _winnerId;

        uint256 _xpFactor = _calculateExperience(_isAttackerWinner, _strength, _opponentStrength);
        core.increaseDragonExperience(_winnerId, _xpFactor);

        if (_isAttackerWinner) {
            uint256 _factor = _calculateGoldRewardFactor(_strength, _opponentStrength);
            _payGoldReward(_sender, _id, _factor);
        }
    }

    function _calculateExperience(
        bool _isAttackerWinner,
        uint32 _attackerStrength,
        uint32 _opponentStrength
    ) internal pure returns (uint256) {

        uint8 _attackerFactor;
        uint256 _winnerStrength;
        uint256 _looserStrength;

        uint8 _degree;

        if (_isAttackerWinner) {
            _attackerFactor = 10;
            _winnerStrength = _attackerStrength;
            _looserStrength = _opponentStrength;
            _degree = _winnerStrength <= _looserStrength ? 2 : 5;
        } else {
            _attackerFactor = 5;
            _winnerStrength = _opponentStrength;
            _looserStrength = _attackerStrength;
            _degree = _winnerStrength <= _looserStrength ? 1 : 5;
        }

        uint256 _factor = _looserStrength.pow(_degree).mul(_attackerFactor).div(_winnerStrength.pow(_degree));

        if (_isAttackerWinner) {
            return _factor;
        }
        return _min(_factor, 10); // 1
    }

    function _calculateGoldRewardFactor(
        uint256 _winnerStrength,
        uint256 _looserStrength
    ) internal pure returns (uint256) {
        uint8 _degree = _winnerStrength <= _looserStrength ? 1 : 8;
        return _looserStrength.pow(_degree).mul(GOLD_REWARD_MULTIPLIER).div(_winnerStrength.pow(_degree));
    }

    function _getMaxGoldReward(
        uint256 _hatchingPrice,
        uint256 _dragonsAmount
    ) internal pure returns (uint256) {
        uint8 _factor;

        if (_dragonsAmount < 15000) _factor = 20;
        else if (_dragonsAmount < 30000) _factor = 10;
        else _factor = 5;

        return _hatchingPrice.mul(_factor).div(PERCENT_MULTIPLIER);
    }

    function _payGoldReward(
        address _sender,
        uint256 _id,
        uint256 _factor
    ) internal {
        uint256 _goldRemain = treasury.remainingGold();
        uint256 _dragonsAmount = getter.getDragonsAmount();
        uint32 _coolness;
        (, , , , , , , _coolness) = getter.getDragonProfile(_id);
        uint256 _hatchingPrice = treasury.hatchingPrice();
        // dragon coolness is multyplied by 100
        uint256 _value = _goldRemain.mul(_coolness).mul(10).div(_dragonsAmount.pow(2)).div(100);
        _value = _value.mul(_factor).div(GOLD_REWARD_MULTIPLIER);

        uint256 _maxReward = _getMaxGoldReward(_hatchingPrice, _dragonsAmount);
        if (_value > _maxReward) _value = _maxReward;
        if (_value > _goldRemain) _value = _goldRemain;
        treasury.giveGold(_sender, _value);
    }

    struct Opponent {
        uint256 id;
        uint256 timestamp;
        uint32 strength;
    }

    function _iterateTimestampIndex(uint8 _index) internal pure returns (uint8) {
        return _index < 5 ? _index.add(1) : 0;
    }

    function _getPercentOfValue(uint32 _value, uint8 _percent) internal pure returns (uint32) {
        return _value.mul(_percent).div(PERCENT_MULTIPLIER);
    }

    function matchOpponents(uint256 _attackerId) external view returns (uint256[6]) {
        uint32 _attackerStrength = getter.getDragonStrength(_attackerId);
        uint32 _strengthDiff = _getPercentOfValue(_attackerStrength, DRAGON_STRENGTH_DIFFERENCE_PERCENTAGE);
        uint32 _minStrength = _attackerStrength.sub(_strengthDiff);
        uint32 _maxStrength = _attackerStrength.add(_strengthDiff);
        uint32 _strength;
        uint256 _timestamp; // usually the date of the last battle
        uint8 _timestampIndex;
        uint8 _healthPercentage;
        uint8 _manaPercentage;

        address _owner = getter.ownerOfDragon(_attackerId);

        Opponent[6] memory _opponents;
        _opponents[0].timestamp =
        _opponents[1].timestamp =
        _opponents[2].timestamp =
        _opponents[3].timestamp =
        _opponents[4].timestamp =
        _opponents[5].timestamp = now;

        for (uint256 _id = 1; _id <= getter.getDragonsAmount(); _id++) { // no dragon with id = 0

            if (
                _attackerId != _id
                && !getter.isDragonOwner(_owner, _id)
                && !getter.isDragonInGladiatorBattle(_id)
                && _isTouchable(_id)
            ) {
                _strength = getter.getDragonStrength(_id);
                if (_strength >= _minStrength && _strength <= _maxStrength) {

                    ( , , _healthPercentage, _manaPercentage) = getter.getDragonCurrentHealthAndMana(_id);
                    if (_healthPercentage == MAX_PERCENTAGE && _manaPercentage == MAX_PERCENTAGE) {

                        (_timestamp, , , , ) = getter.getDragonHealthAndMana(_id);
                        if (_timestamp < _opponents[_timestampIndex].timestamp) {

                            _opponents[_timestampIndex] = Opponent(_id, _timestamp, _strength);
                            _timestampIndex = _iterateTimestampIndex(_timestampIndex);
                        }
                    }
                }
            }
        }
        return [
            _opponents[0].id,
            _opponents[1].id,
            _opponents[2].id,
            _opponents[3].id,
            _opponents[4].id,
            _opponents[5].id
        ];
    }

    function resetDragonBuffs(uint256 _id) external onlyController {
        core.resetDragonBuffs(_id);
    }

    // UPDATE CONTRACT

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        core = Core(_newDependencies[0]);
        battle = Battle(_newDependencies[1]);
        treasury = Treasury(_newDependencies[2]);
        getter = Getter(_newDependencies[3]);
        random = Random(_newDependencies[4]);
    }
}