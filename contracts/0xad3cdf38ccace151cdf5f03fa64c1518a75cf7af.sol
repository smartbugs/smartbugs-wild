pragma solidity 0.4.25;


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

contract HumanOriented {
    modifier onlyHuman() {
        require(msg.sender == tx.origin, "not a human");
        _;
    }
}


contract Events {
    function emitEggClaimed(address, uint256) external {}
    function emitEggSentToNest(address, uint256) external {}
    function emitDragonUpgraded(uint256) external {}
    function emitEggHatched(address, uint256, uint256) external {}
    function emitEggCreated(address, uint256) external {}
    function emitDistributionUpdated(uint256, uint256, uint256) external {}
    function emitSkillSet(uint256) external {}
    function emitSkillUsed(uint256, uint256) external {}
    function emitDragonNameSet(uint256, bytes32) external {}
    function emitDragonTacticsSet(uint256, uint8, uint8) external {}
    function emitUserNameSet(address, bytes32) external {}
    function emitLeaderboardRewardsDistributed(uint256[10], address[10]) external {}
}

contract User {
    mapping (bytes32 => bool) public existingNames;
    mapping (address => bytes32) public names;

    function getName(address) external view returns (bytes32) {}
    function setName(address, string) external returns (bytes32) {}
}

contract CoreController {
    function claimEgg(address, uint8) external returns (uint256, uint256, uint256, uint256) {}
    function sendToNest(address, uint256) external returns (bool, uint256, uint256, address) {}
    function breed(address, uint256, uint256) external returns (uint256) {}
    function upgradeDragonGenes(address, uint256, uint16[10]) external {}
    function setDragonTactics(address, uint256, uint8, uint8) external {}
    function setDragonName(address, uint256, string) external returns (bytes32) {}
    function setDragonSpecialPeacefulSkill(address, uint256, uint8) external {}
    function useDragonSpecialPeacefulSkill(address, uint256, uint256) external {}
    function distributeLeaderboardRewards() external returns (uint256[10], address[10]) {}
}




//////////////CONTRACT//////////////




contract MainBase is Pausable, Upgradable, HumanOriented {
    CoreController coreController;
    User user;
    Events events;

    function claimEgg(uint8 _dragonType) external onlyHuman whenNotPaused {
        (
            uint256 _eggId,
            uint256 _restAmount,
            uint256 _lastBlock,
            uint256 _interval
        ) = coreController.claimEgg(msg.sender, _dragonType);

        events.emitEggClaimed(msg.sender, _eggId);
        events.emitDistributionUpdated(_restAmount, _lastBlock, _interval);
    }

    // ACTIONS WITH OWN TOKENS

    function sendToNest(
        uint256 _eggId
    ) external onlyHuman whenNotPaused {
        (
            bool _isHatched,
            uint256 _newDragonId,
            uint256 _hatchedId,
            address _owner
        ) = coreController.sendToNest(msg.sender, _eggId);

        events.emitEggSentToNest(msg.sender, _eggId);

        if (_isHatched) {
            events.emitEggHatched(_owner, _newDragonId, _hatchedId);
        }
    }

    function breed(uint256 _momId, uint256 _dadId) external onlyHuman whenNotPaused {
        uint256 eggId = coreController.breed(msg.sender, _momId, _dadId);
        events.emitEggCreated(msg.sender, eggId);
    }

    function upgradeDragonGenes(uint256 _id, uint16[10] _dnaPoints) external onlyHuman whenNotPaused {
        coreController.upgradeDragonGenes(msg.sender, _id, _dnaPoints);
        events.emitDragonUpgraded(_id);
    }

    function setDragonTactics(uint256 _id, uint8 _melee, uint8 _attack) external onlyHuman whenNotPaused {
        coreController.setDragonTactics(msg.sender, _id, _melee, _attack);
        events.emitDragonTacticsSet(_id, _melee, _attack);
    }

    function setDragonName(uint256 _id, string _name) external onlyHuman whenNotPaused returns (bytes32 name) {
        name = coreController.setDragonName(msg.sender, _id, _name);
        events.emitDragonNameSet(_id, name);
    }

    function setDragonSpecialPeacefulSkill(uint256 _id, uint8 _class) external onlyHuman whenNotPaused {
        coreController.setDragonSpecialPeacefulSkill(msg.sender, _id, _class);
        events.emitSkillSet(_id);
    }

    function useDragonSpecialPeacefulSkill(uint256 _id, uint256 _target) external onlyHuman whenNotPaused {
        coreController.useDragonSpecialPeacefulSkill(msg.sender, _id, _target);
        events.emitSkillUsed(_id, _target);
    }

    // LEADERBOARD

    function distributeLeaderboardRewards() external onlyHuman whenNotPaused {
        (
            uint256[10] memory _dragons,
            address[10] memory _users
        ) = coreController.distributeLeaderboardRewards();
        events.emitLeaderboardRewardsDistributed(_dragons, _users);
    }

    // USER

    function setName(string _name) external onlyHuman whenNotPaused returns (bytes32 name) {
        name = user.setName(msg.sender, _name);
        events.emitUserNameSet(msg.sender, name);
    }

    function getName(address _user) external view returns (bytes32) {
        return user.getName(_user);
    }

    // UPDATE CONTRACT

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        coreController = CoreController(_newDependencies[0]);
        user = User(_newDependencies[1]);
        events = Events(_newDependencies[2]);
    }
}