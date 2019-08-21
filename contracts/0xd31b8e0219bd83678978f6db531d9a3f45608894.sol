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




//////////////CONTRACT//////////////




contract Events is Upgradable {
    event EggClaimed(address indexed user, uint256 indexed id);
    event EggSentToNest(address indexed user, uint256 indexed id);
    event EggHatched(address indexed user, uint256 indexed dragonId, uint256 indexed eggId);
    event DragonUpgraded(uint256 indexed id);
    event EggCreated(address indexed user, uint256 indexed id);
    event DragonOnSale(address indexed seller, uint256 indexed id);
    event DragonRemovedFromSale(address indexed seller, uint256 indexed id);
    event DragonRemovedFromBreeding(address indexed seller, uint256 indexed id);
    event DragonOnBreeding(address indexed seller, uint256 indexed id);
    event DragonBought(address indexed buyer, address indexed seller, uint256 indexed id, uint256 price);
    event DragonBreedingBought(address indexed buyer, address indexed seller, uint256 indexed id, uint256 price);
    event DistributionUpdated(uint256 restAmount, uint256 lastBlock, uint256 interval);
    event EggOnSale(address indexed seller, uint256 indexed id);
    event EggRemovedFromSale(address indexed seller, uint256 indexed id);
    event EggBought(address indexed buyer, address indexed seller, uint256 indexed id, uint256 price);
    event GoldSellOrderCreated(address indexed seller, uint256 price, uint256 amount);
    event GoldSellOrderCancelled(address indexed seller);
    event GoldSold(address indexed buyer, address indexed seller, uint256 amount, uint256 price);
    event GoldBuyOrderCreated(address indexed buyer, uint256 price, uint256 amount);
    event GoldBuyOrderCancelled(address indexed buyer);
    event GoldBought(address indexed seller, address indexed buyer, uint256 amount, uint256 price);
    event SkillOnSale(address indexed seller, uint256 indexed id);
    event SkillRemovedFromSale(address indexed seller, uint256 indexed id);
    event SkillBought(address indexed buyer, address indexed seller, uint256 id, uint256 indexed target, uint256 price);
    event SkillSet(uint256 indexed id);
    event SkillUsed(uint256 indexed id, uint256 indexed target);
    event DragonNameSet(uint256 indexed id, bytes32 name);
    event DragonTacticsSet(uint256 indexed id, uint8 melee, uint8 attack);
    event UserNameSet(address indexed user, bytes32 name);
    event BattleEnded(
        uint256 indexed battleId,
        uint256 date,
        uint256 seed,
        uint256 attackerId,
        uint256 indexed winnerId,
        uint256 indexed looserId,
        bool isGladiator,
        uint256 gladiatorBattleId
    );
    event BattleDragonsDetails(
        uint256 indexed battleId,
        uint8 winnerLevel,
        uint32 winnerCoolness,
        uint8 looserLevel,
        uint32 looserCoolness
    );
    event BattleHealthAndMana(
        uint256 indexed battleId,
        uint32 attackerMaxHealth,
        uint32 attackerMaxMana,
        uint32 attackerInitHealth,
        uint32 attackerInitMana,
        uint32 opponentMaxHealth,
        uint32 opponentMaxMana,
        uint32 opponentInitHealth,
        uint32 opponentInitMana
    );
    event BattleSkills(
        uint256 indexed battleId,
        uint32 attackerAttack,
        uint32 attackerDefense,
        uint32 attackerStamina,
        uint32 attackerSpeed,
        uint32 attackerIntelligence,
        uint32 opponentAttack,
        uint32 opponentDefense,
        uint32 opponentStamina,
        uint32 opponentSpeed,
        uint32 opponentIntelligence
    );
    event BattleTacticsAndBuffs(
        uint256 indexed battleId,
        uint8 attackerMeleeChance,
        uint8 attackerAttackChance,
        uint8 opponentMeleeChance,
        uint8 opponentAttackChance,
        uint32[5] attackerBuffs,
        uint32[5] opponentBuffs
    );
    event GladiatorBattleEnded(
        uint256 indexed id,
        uint256 battleId,
        address indexed winner,
        address indexed looser,
        uint256 reward,
        bool isGold
    );
    event GladiatorBattleCreated(
        uint256 indexed id,
        address indexed user,
        uint256 indexed dragonId,
        uint256 bet,
        bool isGold
    );
    event GladiatorBattleApplicantAdded(
        uint256 indexed id,
        address indexed user,
        uint256 indexed dragonId
    );
    event GladiatorBattleOpponentSelected(
        uint256 indexed id,
        uint256 indexed dragonId
    );
    event GladiatorBattleCancelled(uint256 indexed id);
    event GladiatorBattleBetReturned(uint256 indexed id, address indexed user);
    event GladiatorBattleOpponentSelectTimeUpdated(uint256 indexed id, uint256 blockNumber);
    event GladiatorBattleBlockNumberUpdated(uint256 indexed id, uint256 blockNumber);
    event GladiatorBattleSpectatorBetPlaced(
        uint256 indexed id,
        address indexed user,
        bool indexed willCreatorWin,
        uint256 bet,
        bool isGold
    );
    event GladiatorBattleSpectatorBetRemoved(uint256 indexed id, address indexed user);
    event GladiatorBattleSpectatorRewardPaidOut(
        uint256 indexed id,
        address indexed user,
        uint256 reward,
        bool isGold
    );
    event LeaderboardRewardsDistributed(uint256[10] dragons, address[10] users);

    function emitEggClaimed(
        address _user,
        uint256 _id
    ) external onlyController {
        emit EggClaimed(_user, _id);
    }

    function emitEggSentToNest(
        address _user,
        uint256 _id
    ) external onlyController {
        emit EggSentToNest(_user, _id);
    }

    function emitDragonUpgraded(
        uint256 _id
    ) external onlyController {
        emit DragonUpgraded(_id);
    }

    function emitEggHatched(
        address _user,
        uint256 _dragonId,
        uint256 _eggId
    ) external onlyController {
        emit EggHatched(_user, _dragonId, _eggId);
    }

    function emitEggCreated(
        address _user,
        uint256 _id
    ) external onlyController {
        emit EggCreated(_user, _id);
    }

    function emitDragonOnSale(
        address _user,
        uint256 _id
    ) external onlyController {
        emit DragonOnSale(_user, _id);
    }

    function emitDragonRemovedFromSale(
        address _user,
        uint256 _id
    ) external onlyController {
        emit DragonRemovedFromSale(_user, _id);
    }

    function emitDragonRemovedFromBreeding(
        address _user,
        uint256 _id
    ) external onlyController {
        emit DragonRemovedFromBreeding(_user, _id);
    }

    function emitDragonOnBreeding(
        address _user,
        uint256 _id
    ) external onlyController {
        emit DragonOnBreeding(_user, _id);
    }

    function emitDragonBought(
        address _buyer,
        address _seller,
        uint256 _id,
        uint256 _price
    ) external onlyController {
        emit DragonBought(_buyer, _seller, _id, _price);
    }

    function emitDragonBreedingBought(
        address _buyer,
        address _seller,
        uint256 _id,
        uint256 _price
    ) external onlyController {
        emit DragonBreedingBought(_buyer, _seller, _id, _price);
    }

    function emitDistributionUpdated(
        uint256 _restAmount,
        uint256 _lastBlock,
        uint256 _interval
    ) external onlyController {
        emit DistributionUpdated(_restAmount, _lastBlock, _interval);
    }

    function emitEggOnSale(
        address _user,
        uint256 _id
    ) external onlyController {
        emit EggOnSale(_user, _id);
    }

    function emitEggRemovedFromSale(
        address _user,
        uint256 _id
    ) external onlyController {
        emit EggRemovedFromSale(_user, _id);
    }

    function emitEggBought(
        address _buyer,
        address _seller,
        uint256 _id,
        uint256 _price
    ) external onlyController {
        emit EggBought(_buyer, _seller, _id, _price);
    }

    function emitGoldSellOrderCreated(
        address _user,
        uint256 _price,
        uint256 _amount
    ) external onlyController {
        emit GoldSellOrderCreated(_user, _price, _amount);
    }

    function emitGoldSellOrderCancelled(
        address _user
    ) external onlyController {
        emit GoldSellOrderCancelled(_user);
    }

    function emitGoldSold(
        address _buyer,
        address _seller,
        uint256 _amount,
        uint256 _price
    ) external onlyController {
        emit GoldSold(_buyer, _seller, _amount, _price);
    }

    function emitGoldBuyOrderCreated(
        address _user,
        uint256 _price,
        uint256 _amount
    ) external onlyController {
        emit GoldBuyOrderCreated(_user, _price, _amount);
    }

    function emitGoldBuyOrderCancelled(
        address _user
    ) external onlyController {
        emit GoldBuyOrderCancelled(_user);
    }

    function emitGoldBought(
        address _buyer,
        address _seller,
        uint256 _amount,
        uint256 _price
    ) external onlyController {
        emit GoldBought(_buyer, _seller, _amount, _price);
    }

    function emitSkillOnSale(
        address _user,
        uint256 _id
    ) external onlyController {
        emit SkillOnSale(_user, _id);
    }

    function emitSkillRemovedFromSale(
        address _user,
        uint256 _id
    ) external onlyController {
        emit SkillRemovedFromSale(_user, _id);
    }

    function emitSkillBought(
        address _buyer,
        address _seller,
        uint256 _id,
        uint256 _target,
        uint256 _price
    ) external onlyController {
        emit SkillBought(_buyer, _seller, _id, _target, _price);
    }

    function emitSkillSet(
        uint256 _id
    ) external onlyController {
        emit SkillSet(_id);
    }

    function emitSkillUsed(
        uint256 _id,
        uint256 _target
    ) external onlyController {
        emit SkillUsed(_id, _target);
    }

    function emitDragonNameSet(
        uint256 _id,
        bytes32 _name
    ) external onlyController {
        emit DragonNameSet(_id, _name);
    }

    function emitDragonTacticsSet(
        uint256 _id,
        uint8 _melee,
        uint8 _attack
    ) external onlyController {
        emit DragonTacticsSet(_id, _melee, _attack);
    }

    function emitUserNameSet(
        address _user,
        bytes32 _name
    ) external onlyController {
        emit UserNameSet(_user, _name);
    }

    function emitBattleEnded(
        uint256 _battleId,
        uint256 _date,
        uint256 _seed,
        uint256 _attackerId,
        uint256 _winnerId,
        uint256 _looserId,
        bool _isGladiator,
        uint256 _gladiatorBattleId
    ) external onlyController {
        emit BattleEnded(
            _battleId,
            _date,
            _seed,
            _attackerId,
            _winnerId,
            _looserId,
            _isGladiator,
            _gladiatorBattleId
        );
    }

    function emitBattleDragonsDetails(
        uint256 _battleId,
        uint8 _winnerLevel,
        uint32 _winnerCoolness,
        uint8 _looserLevel,
        uint32 _looserCoolness
    ) external onlyController {
        emit BattleDragonsDetails(
            _battleId,
            _winnerLevel,
            _winnerCoolness,
            _looserLevel,
            _looserCoolness
        );
    }

    function emitBattleHealthAndMana(
        uint256 _battleId,
        uint32 _attackerMaxHealth,
        uint32 _attackerMaxMana,
        uint32 _attackerInitHealth,
        uint32 _attackerInitMana,
        uint32 _opponentMaxHealth,
        uint32 _opponentMaxMana,
        uint32 _opponentInitHealth,
        uint32 _opponentInitMana
    ) external onlyController {
        emit BattleHealthAndMana(
            _battleId,
            _attackerMaxHealth,
            _attackerMaxMana,
            _attackerInitHealth,
            _attackerInitMana,
            _opponentMaxHealth,
            _opponentMaxMana,
            _opponentInitHealth,
            _opponentInitMana
        );
    }

    function emitBattleSkills(
        uint256 _battleId,
        uint32 _attackerAttack,
        uint32 _attackerDefense,
        uint32 _attackerStamina,
        uint32 _attackerSpeed,
        uint32 _attackerIntelligence,
        uint32 _opponentAttack,
        uint32 _opponentDefense,
        uint32 _opponentStamina,
        uint32 _opponentSpeed,
        uint32 _opponentIntelligence
    ) external onlyController {
        emit BattleSkills(
            _battleId,
            _attackerAttack,
            _attackerDefense,
            _attackerStamina,
            _attackerSpeed,
            _attackerIntelligence,
            _opponentAttack,
            _opponentDefense,
            _opponentStamina,
            _opponentSpeed,
            _opponentIntelligence
        );
    }

    function emitBattleTacticsAndBuffs(
        uint256 _battleId,
        uint8 _attackerMeleeChance,
        uint8 _attackerAttackChance,
        uint8 _opponentMeleeChance,
        uint8 _opponentAttackChance,
        uint32[5] _attackerBuffs,
        uint32[5] _opponentBuffs
    ) external onlyController {
        emit BattleTacticsAndBuffs(
            _battleId,
            _attackerMeleeChance,
            _attackerAttackChance,
            _opponentMeleeChance,
            _opponentAttackChance,
            _attackerBuffs,
            _opponentBuffs
        );
    }

    function emitGladiatorBattleEnded(
        uint256 _id,
        uint256 _battleId,
        address _winner,
        address _looser,
        uint256 _reward,
        bool _isGold
    ) external onlyController {
        emit GladiatorBattleEnded(
            _id,
            _battleId,
            _winner,
            _looser,
            _reward,
            _isGold
        );
    }

    function emitGladiatorBattleCreated(
        uint256 _id,
        address _user,
        uint256 _dragonId,
        uint256 _bet,
        bool _isGold
    ) external onlyController {
        emit GladiatorBattleCreated(
            _id,
            _user,
            _dragonId,
            _bet,
            _isGold
        );
    }

    function emitGladiatorBattleApplicantAdded(
        uint256 _id,
        address _user,
        uint256 _dragonId
    ) external onlyController {
        emit GladiatorBattleApplicantAdded(
            _id,
            _user,
            _dragonId
        );
    }

    function emitGladiatorBattleOpponentSelected(
        uint256 _id,
        uint256 _dragonId
    ) external onlyController {
        emit GladiatorBattleOpponentSelected(
            _id,
            _dragonId
        );
    }

    function emitGladiatorBattleCancelled(
        uint256 _id
    ) external onlyController {
        emit GladiatorBattleCancelled(
            _id
        );
    }

    function emitGladiatorBattleBetReturned(
        uint256 _id,
        address _user
    ) external onlyController {
        emit GladiatorBattleBetReturned(
            _id,
            _user
        );
    }

    function emitGladiatorBattleOpponentSelectTimeUpdated(
        uint256 _id,
        uint256 _blockNumber
    ) external onlyController {
        emit GladiatorBattleOpponentSelectTimeUpdated(
            _id,
            _blockNumber
        );
    }

    function emitGladiatorBattleBlockNumberUpdated(
        uint256 _id,
        uint256 _blockNumber
    ) external onlyController {
        emit GladiatorBattleBlockNumberUpdated(
            _id,
            _blockNumber
        );
    }

    function emitGladiatorBattleSpectatorBetPlaced(
        uint256 _id,
        address _user,
        bool _willCreatorWin,
        uint256 _value,
        bool _isGold
    ) external onlyController {
        emit GladiatorBattleSpectatorBetPlaced(
            _id,
            _user,
            _willCreatorWin,
            _value,
            _isGold
        );
    }

    function emitGladiatorBattleSpectatorBetRemoved(
        uint256 _id,
        address _user
    ) external onlyController {
        emit GladiatorBattleSpectatorBetRemoved(
            _id,
            _user
        );
    }

    function emitGladiatorBattleSpectatorRewardPaidOut(
        uint256 _id,
        address _user,
        uint256 _value,
        bool _isGold
    ) external onlyController {
        emit GladiatorBattleSpectatorRewardPaidOut(
            _id,
            _user,
            _value,
            _isGold
        );
    }

    function emitLeaderboardRewardsDistributed(
        uint256[10] _dragons,
        address[10] _users
    ) external onlyController {
        emit LeaderboardRewardsDistributed(
            _dragons,
            _users
        );
    }
}