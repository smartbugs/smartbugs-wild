pragma solidity 0.4.25;

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

contract Core {
    function isEggOwner(address, uint256) external view returns (bool);
    function createEgg(address, uint8) external returns (uint256);
    function sendToNest(uint256) external returns (bool, uint256, uint256, address);
    function openEgg(address, uint256, uint256) internal returns (uint256);
    function breed(address, uint256, uint256) external returns (uint256);
    function setDragonRemainingHealthAndMana(uint256, uint32, uint32) external;
    function increaseDragonExperience(uint256, uint256) external;
    function upgradeDragonGenes(uint256, uint16[10]) external;
    function increaseDragonWins(uint256) external;
    function increaseDragonDefeats(uint256) external;
    function setDragonTactics(uint256, uint8, uint8) external;
    function setDragonName(uint256, string) external returns (bytes32);
    function setDragonSpecialPeacefulSkill(uint256, uint8) external;
    function useDragonSpecialPeacefulSkill(address, uint256, uint256) external;
    function updateLeaderboardRewardTime() external;
    function getDragonsFromLeaderboard() external view returns (uint256[10]);
    function getLeaderboardRewards(uint256) external view returns (uint256[10]);
}

contract Treasury {
    uint256 public hatchingPrice;
    function giveGold(address, uint256) external;
    function takeGold(uint256) external;
    function burnGold(uint256) external;
    function remainingGold() external view returns (uint256);
}

contract Getter {
    function getDragonsAmount() external view returns (uint256);
    function isDragonBreedingAllowed(uint256) external view returns (bool);
    function getDragonNamePriceByLength(uint256) external view returns (uint256);
    function isEggOnSale(uint256) external view returns (bool);
    function isDragonOnSale(uint256) public view returns (bool);
    function isBreedingOnSale(uint256) public view returns (bool);
    function isDragonOwner(address, uint256) external view returns (bool);
    function ownerOfDragon(uint256) public view returns (address);
    function isDragonInGladiatorBattle(uint256) public view returns (bool);
}

contract Distribution {
    function claim(uint8) external returns (uint256, uint256, uint256);
}




//////////////CONTRACT//////////////




contract CoreController is Upgradable {
    using SafeMath256 for uint256;

    Core core;
    Treasury treasury;
    Getter getter;
    Distribution distribution;

    function _isDragonOwner(address _user, uint256 _id) internal view returns (bool) {
        return getter.isDragonOwner(_user, _id);
    }

    function _checkTheDragonIsNotInGladiatorBattle(uint256 _id) internal view {
        require(!getter.isDragonInGladiatorBattle(_id), "dragon participates in gladiator battle");
    }

    function _checkTheDragonIsNotOnSale(uint256 _id) internal view {
        require(!getter.isDragonOnSale(_id), "dragon is on sale");
    }

    function _checkTheDragonIsNotOnBreeding(uint256 _id) internal view {
        require(!getter.isBreedingOnSale(_id), "dragon is on breeding sale");
    }

    function _checkThatEnoughDNAPoints(uint256 _id) internal view {
        require(getter.isDragonBreedingAllowed(_id), "dragon has no enough DNA points for breeding");
    }

    function _checkDragonOwner(address _user, uint256 _id) internal view {
        require(_isDragonOwner(_user, _id), "not an owner");
    }

    function claimEgg(
        address _sender,
        uint8 _dragonType
    ) external onlyController returns (
        uint256 eggId,
        uint256 restAmount,
        uint256 lastBlock,
        uint256 interval
    ) {
        (restAmount, lastBlock, interval) = distribution.claim(_dragonType);
        eggId = core.createEgg(_sender, _dragonType);

        uint256 _goldReward = treasury.hatchingPrice();
        uint256 _goldAmount = treasury.remainingGold();
        if (_goldReward > _goldAmount) _goldReward = _goldAmount;
        treasury.giveGold(_sender, _goldReward);
    }

    // ACTIONS WITH OWN TOKEN

    function sendToNest(
        address _sender,
        uint256 _eggId
    ) external onlyController returns (bool, uint256, uint256, address) {
        require(!getter.isEggOnSale(_eggId), "egg is on sale");
        require(core.isEggOwner(_sender, _eggId), "not an egg owner");

        uint256 _hatchingPrice = treasury.hatchingPrice();
        treasury.takeGold(_hatchingPrice);
        if (getter.getDragonsAmount() > 9997) { // 9997 + 2 (in the nest) + 1 (just sent) = 10000 dragons without gold burning
            treasury.burnGold(_hatchingPrice.div(2));
        }

        return core.sendToNest(_eggId);
    }

    function breed(
        address _sender,
        uint256 _momId,
        uint256 _dadId
    ) external onlyController returns (uint256 eggId) {
        _checkThatEnoughDNAPoints(_momId);
        _checkThatEnoughDNAPoints(_dadId);
        _checkTheDragonIsNotOnBreeding(_momId);
        _checkTheDragonIsNotOnBreeding(_dadId);
        _checkTheDragonIsNotOnSale(_momId);
        _checkTheDragonIsNotOnSale(_dadId);
        _checkTheDragonIsNotInGladiatorBattle(_momId);
        _checkTheDragonIsNotInGladiatorBattle(_dadId);
        _checkDragonOwner(_sender, _momId);
        _checkDragonOwner(_sender, _dadId);
        require(_momId != _dadId, "the same dragon");

        return core.breed(_sender, _momId, _dadId);
    }

    function upgradeDragonGenes(
        address _sender,
        uint256 _id,
        uint16[10] _dnaPoints
    ) external onlyController {
        _checkTheDragonIsNotOnBreeding(_id);
        _checkTheDragonIsNotOnSale(_id);
        _checkTheDragonIsNotInGladiatorBattle(_id);
        _checkDragonOwner(_sender, _id);
        core.upgradeDragonGenes(_id, _dnaPoints);
    }

    function setDragonTactics(
        address _sender,
        uint256 _id,
        uint8 _melee,
        uint8 _attack
    ) external onlyController {
        _checkDragonOwner(_sender, _id);
        core.setDragonTactics(_id, _melee, _attack);
    }

    function setDragonName(
        address _sender,
        uint256 _id,
        string _name
    ) external onlyController returns (bytes32) {
        _checkDragonOwner(_sender, _id);

        uint256 _length = bytes(_name).length;
        uint256 _price = getter.getDragonNamePriceByLength(_length);

        if (_price > 0) {
            treasury.takeGold(_price);
        }

        return core.setDragonName(_id, _name);
    }

    function setDragonSpecialPeacefulSkill(address _sender, uint256 _id, uint8 _class) external onlyController {
        _checkDragonOwner(_sender, _id);
        core.setDragonSpecialPeacefulSkill(_id, _class);
    }

    function useDragonSpecialPeacefulSkill(address _sender, uint256 _id, uint256 _target) external onlyController {
        _checkDragonOwner(_sender, _id);
        _checkTheDragonIsNotInGladiatorBattle(_id);
        _checkTheDragonIsNotInGladiatorBattle(_target);
        core.useDragonSpecialPeacefulSkill(_sender, _id, _target);
    }

    function distributeLeaderboardRewards() external onlyController returns (
        uint256[10] dragons,
        address[10] users
    ) {
        core.updateLeaderboardRewardTime();
        uint256 _hatchingPrice = treasury.hatchingPrice();
        uint256[10] memory _rewards = core.getLeaderboardRewards(_hatchingPrice);

        dragons = core.getDragonsFromLeaderboard();
        uint8 i;
        for (i = 0; i < dragons.length; i++) {
            if (dragons[i] == 0) continue;
            users[i] = getter.ownerOfDragon(dragons[i]);
        }

        uint256 _remainingGold = treasury.remainingGold();
        uint256 _reward;
        for (i = 0; i < users.length; i++) {
            if (_remainingGold == 0) break;
            if (users[i] == address(0)) continue;

            _reward = _rewards[i];
            if (_reward > _remainingGold) {
                _reward = _remainingGold;
            }
            treasury.giveGold(users[i], _reward);
            _remainingGold = _remainingGold.sub(_reward);
        }
    }

    // UPDATE CONTRACT

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        core = Core(_newDependencies[0]);
        treasury = Treasury(_newDependencies[1]);
        getter = Getter(_newDependencies[2]);
        distribution = Distribution(_newDependencies[3]);
    }
}