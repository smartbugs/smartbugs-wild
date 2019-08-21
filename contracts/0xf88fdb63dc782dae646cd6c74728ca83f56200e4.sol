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

contract Core {
    function isEggInNest(uint256) external view returns (bool);
    function getEggsInNest() external view returns (uint256[2]);
    function getDragonsFromLeaderboard() external view returns (uint256[10]);
    function getLeaderboardRewards(uint256) external view returns (uint256[10]);
    function getLeaderboardRewardDate() external view returns (uint256, uint256);
    function getEgg(uint256) external view returns (uint16, uint32, uint256[2], uint8[11], uint8[11]);
    function getDragonChildren(uint256) external view returns (uint256[10], uint256[10]);
}

contract DragonParams {
    function getDragonTypesFactors() external view returns (uint8[55]);
    function getBodyPartsFactors() external view returns (uint8[50]);
    function getGeneTypesFactors() external view returns (uint8[50]);
    function getExperienceToNextLevel() external view returns (uint8[10]);
    function getDNAPoints() external view returns (uint16[11]);
    function battlePoints() external view returns (uint8);
    function getGeneUpgradeDNAPoints() external view returns (uint8[99]);
}

contract DragonGetter {
    function getAmount() external view returns (uint256);
    function isOwner(address, uint256) external view returns (bool);
    function ownerOf(uint256) external view returns (address);
    function getGenome(uint256) public view returns (uint8[30]);
    function getComposedGenome(uint256) external view returns (uint256[4]);
    function getSkills(uint256) external view returns (uint32, uint32, uint32, uint32, uint32);
    function getCoolness(uint256) public view returns (uint32);
    function getLevel(uint256) public view returns (uint8);
    function getHealthAndMana(uint256) external view returns (uint256, uint32, uint32, uint32, uint32);
    function getCurrentHealthAndMana(uint256) external view returns (uint32, uint32, uint8, uint8);
    function getFullRegenerationTime(uint256) external view returns (uint32);
    function getDragonTypes(uint256) external view returns (uint8[11]);
    function getProfile(uint256) external view returns (bytes32, uint16, uint256, uint8, uint8, uint16, bool, uint32);
    function getGeneration(uint256) external view returns (uint16);
    function isBreedingAllowed(uint256) external view returns (bool);
    function getTactics(uint256) external view returns (uint8, uint8);
    function getBattles(uint256) external view returns (uint16, uint16);
    function getParents(uint256) external view returns (uint256[2]);
    function getSpecialAttack(uint256) external view returns (uint8, uint32, uint8, uint8);
    function getSpecialDefense(uint256) external view returns (uint8, uint32, uint8, uint8);
    function getSpecialPeacefulSkill(uint256) external view returns (uint8, uint32, uint32);
    function getBuffs(uint256) external view returns (uint32[5]);
    function getDragonStrength(uint256) external view returns (uint32);
    function getDragonNamePriceByLength(uint256) external pure returns (uint256);
    function getDragonNamePrices() external pure returns (uint8[3], uint256[3]);
}

contract Distribution {
    function getInfo() external view returns (uint256, uint256, uint256, uint256, uint256);
}

contract Treasury {
    uint256 public hatchingPrice;
    function remainingGold() external view returns (uint256);
}

contract GladiatorBattle {
    function isDragonChallenging(uint256) public view returns (bool);
}

contract GladiatorBattleStorage {
    function challengesAmount() external view returns (uint256);
    function getUserChallenges(address) external view returns (uint256[]);
    function getChallengeApplicants(uint256) external view returns (uint256[]);
    function getDragonApplication(uint256) external view returns (uint256, uint8[2], address);
    function getUserApplications(address) external view returns (uint256[]);
    function getChallengeParticipants(uint256) external view returns (address, uint256, address, uint256, address, uint256);
    function getChallengeDetails(uint256) external view returns (bool, uint256, uint16, uint256, bool, uint256, bool, uint256, uint256, uint256);
}

contract SkillMarketplace {
    function getAuction(uint256) external view returns (uint256);
    function getAllTokens() external view returns (uint256[]);
}

contract Marketplace {
    function getAuction(uint256 _id) external view returns (address, uint256, uint256, uint256, uint16, uint256, bool);
}

contract BreedingMarketplace is Marketplace {}
contract EggMarketplace is Marketplace {}
contract DragonMarketplace is Marketplace {}




//////////////CONTRACT//////////////




contract Getter is Upgradable {

    Core core;
    DragonParams dragonParams;
    DragonGetter dragonGetter;
    SkillMarketplace skillMarketplace;
    Distribution distribution;
    Treasury treasury;
    GladiatorBattle gladiatorBattle;
    GladiatorBattleStorage gladiatorBattleStorage;

    BreedingMarketplace public breedingMarketplace;
    EggMarketplace public eggMarketplace;
    DragonMarketplace public dragonMarketplace;


    function _isValidAddress(address _addr) internal pure returns (bool) {
        return _addr != address(0);
    }

    // MODEL

    function getEgg(uint256 _id) external view returns (
        uint16 gen,
        uint32 coolness,
        uint256[2] parents,
        uint8[11] momDragonTypes,
        uint8[11] dadDragonTypes
    ) {
        return core.getEgg(_id);
    }

    function getDragonGenome(uint256 _id) external view returns (uint8[30]) {
        return dragonGetter.getGenome(_id);
    }

    function getDragonTypes(uint256 _id) external view returns (uint8[11]) {
        return dragonGetter.getDragonTypes(_id);
    }

    function getDragonProfile(uint256 _id) external view returns (
        bytes32 name,
        uint16 generation,
        uint256 birth,
        uint8 level,
        uint8 experience,
        uint16 dnaPoints,
        bool isBreedingAllowed,
        uint32 coolness
    ) {
        return dragonGetter.getProfile(_id);
    }

    function getDragonTactics(uint256 _id) external view returns (uint8 melee, uint8 attack) {
        return dragonGetter.getTactics(_id);
    }

    function getDragonBattles(uint256 _id) external view returns (uint16 wins, uint16 defeats) {
        return dragonGetter.getBattles(_id);
    }

    function getDragonSkills(uint256 _id) external view returns (
        uint32 attack,
        uint32 defense,
        uint32 stamina,
        uint32 speed,
        uint32 intelligence
    ) {
        return dragonGetter.getSkills(_id);
    }

    function getDragonStrength(uint256 _id) external view returns (uint32) {
        return dragonGetter.getDragonStrength(_id);
    }

    function getDragonCurrentHealthAndMana(uint256 _id) external view returns (
        uint32 health,
        uint32 mana,
        uint8 healthPercentage,
        uint8 manaPercentage
    ) {
        return dragonGetter.getCurrentHealthAndMana(_id);
    }

    function getDragonMaxHealthAndMana(uint256 _id) external view returns (uint32 maxHealth, uint32 maxMana) {
        ( , , , maxHealth, maxMana) = dragonGetter.getHealthAndMana(_id);
    }

    function getDragonHealthAndMana(uint256 _id) external view returns (
        uint256 timestamp,
        uint32 remainingHealth,
        uint32 remainingMana,
        uint32 maxHealth,
        uint32 maxMana
    ) {
        return dragonGetter.getHealthAndMana(_id);
    }

    function getDragonParents(uint256 _id) external view returns (uint256[2]) {
        return dragonGetter.getParents(_id);
    }

    function getDragonSpecialAttack(uint256 _id) external view returns (
        uint8 dragonType,
        uint32 cost,
        uint8 factor,
        uint8 chance
    ) {
        return dragonGetter.getSpecialAttack(_id);
    }

    function getDragonSpecialDefense(uint256 _id) external view returns (
        uint8 dragonType,
        uint32 cost,
        uint8 factor,
        uint8 chance
    ) {
        return dragonGetter.getSpecialDefense(_id);
    }

    function getDragonSpecialPeacefulSkill(uint256 _id) external view returns (
        uint8 class,
        uint32 cost,
        uint32 effect
    ) {
        return dragonGetter.getSpecialPeacefulSkill(_id);
    }

    function getDragonsAmount() external view returns (uint256) {
        return dragonGetter.getAmount();
    }

    function getDragonChildren(uint256 _id) external view returns (uint256[10] dragons, uint256[10] eggs) {
        return core.getDragonChildren(_id);
    }

    function getDragonBuffs(uint256 _id) external view returns (uint32[5]) {
        return dragonGetter.getBuffs(_id);
    }

    function isDragonBreedingAllowed(uint256 _id) external view returns (bool) {
        return dragonGetter.isBreedingAllowed(_id);
    }

    function isDragonUsed(uint256 _id) external view returns (
        bool isOnSale,
        bool isOnBreeding,
        bool isInGladiatorBattle
    ) {
        return (
            isDragonOnSale(_id),
            isBreedingOnSale(_id),
            isDragonInGladiatorBattle(_id)
        );
    }

    // CONSTANTS

    function getDragonExperienceToNextLevel() external view returns (uint8[10]) {
        return dragonParams.getExperienceToNextLevel();
    }

    function getDragonGeneUpgradeDNAPoints() external view returns (uint8[99]) {
        return dragonParams.getGeneUpgradeDNAPoints();
    }

    function getDragonLevelUpDNAPoints() external view returns (uint16[11]) {
        return dragonParams.getDNAPoints();
    }

    function getDragonTypesFactors() external view returns (uint8[55]) {
        return dragonParams.getDragonTypesFactors();
    }

    function getDragonBodyPartsFactors() external view returns (uint8[50]) {
        return dragonParams.getBodyPartsFactors();
    }

    function getDragonGeneTypesFactors() external view returns (uint8[50]) {
        return dragonParams.getGeneTypesFactors();
    }

    function getHatchingPrice() external view returns (uint256) {
        return treasury.hatchingPrice();
    }

    function getDragonNamePrices() external view returns (uint8[3] lengths, uint256[3] prices) {
        return dragonGetter.getDragonNamePrices();
    }

    function getDragonNamePriceByLength(uint256 _length) external view returns (uint256 price) {
        return dragonGetter.getDragonNamePriceByLength(_length);
    }

    // MARKETPLACE

    function getDragonOnSaleInfo(uint256 _id) public view returns (
        address seller,
        uint256 currentPrice,
        uint256 startPrice,
        uint256 endPrice,
        uint16 period,
        uint256 created,
        bool isGold
    ) {
        return dragonMarketplace.getAuction(_id);
    }

    function getBreedingOnSaleInfo(uint256 _id) public view returns (
        address seller,
        uint256 currentPrice,
        uint256 startPrice,
        uint256 endPrice,
        uint16 period,
        uint256 created,
        bool isGold
    ) {
        return breedingMarketplace.getAuction(_id);
    }

    function getEggOnSaleInfo(uint256 _id) public view returns (
        address seller,
        uint256 currentPrice,
        uint256 startPrice,
        uint256 endPrice,
        uint16 period,
        uint256 created,
        bool isGold
    ) {
        return eggMarketplace.getAuction(_id);
    }

    function getSkillOnSaleInfo(uint256 _id) public view returns (address seller, uint256 price) {
        seller = ownerOfDragon(_id);
        price = skillMarketplace.getAuction(_id);
    }

    function isEggOnSale(uint256 _tokenId) external view returns (bool) {
        (address _seller, , , , , , ) = getEggOnSaleInfo(_tokenId);

        return _isValidAddress(_seller);
    }

    function isDragonOnSale(uint256 _tokenId) public view returns (bool) {
        (address _seller, , , , , , ) = getDragonOnSaleInfo(_tokenId);

        return _isValidAddress(_seller);
    }

    function isBreedingOnSale(uint256 _tokenId) public view returns (bool) {
        (address _seller, , , , , , ) = getBreedingOnSaleInfo(_tokenId);

        return _isValidAddress(_seller);
    }

    function isSkillOnSale(uint256 _tokenId) external view returns (bool) {
        (address _seller, ) = getSkillOnSaleInfo(_tokenId);

        return _isValidAddress(_seller);
    }

    function getSkillsOnSale() public view returns (uint256[]) {
        return skillMarketplace.getAllTokens();
    }

    // OWNER

    function isDragonOwner(address _user, uint256 _tokenId) external view returns (bool) {
        return dragonGetter.isOwner(_user, _tokenId);
    }

    function ownerOfDragon(uint256 _tokenId) public view returns (address) {
        return dragonGetter.ownerOf(_tokenId);
    }

    // NEST

    function isEggInNest(uint256 _id) external view returns (bool) {
        return core.isEggInNest(_id);
    }

    function getEggsInNest() external view returns (uint256[2]) {
        return core.getEggsInNest();
    }

    // LEADERBOARD

    function getDragonsFromLeaderboard() external view returns (uint256[10]) {
        return core.getDragonsFromLeaderboard();
    }

    function getLeaderboardRewards() external view returns (uint256[10]) {
        return core.getLeaderboardRewards(treasury.hatchingPrice());
    }

    function getLeaderboardRewardDate() external view returns (uint256 lastRewardDate, uint256 rewardPeriod) {
        return core.getLeaderboardRewardDate();
    }

    // GEN 0 DISTRIBUTION

    function getDistributionInfo() external view returns (
        uint256 restAmount,
        uint256 releasedAmount,
        uint256 lastBlock,
        uint256 intervalInBlocks,
        uint256 numberOfTypes
    ) {
        return distribution.getInfo();
    }

    // GLADIATOR BATTLE

    function gladiatorBattlesAmount() external view returns (uint256) {
        return gladiatorBattleStorage.challengesAmount();
    }

    function getUserGladiatorBattles(address _user) external view returns (uint256[]) {
        return gladiatorBattleStorage.getUserChallenges(_user);
    }

    function getGladiatorBattleApplicants(uint256 _challengeId) external view returns (uint256[]) {
        return gladiatorBattleStorage.getChallengeApplicants(_challengeId);
    }

    function getDragonApplicationForGladiatorBattle(
        uint256 _dragonId
    ) external view returns (
        uint256 gladiatorBattleId,
        uint8[2] tactics,
        address owner
    ) {
        return gladiatorBattleStorage.getDragonApplication(_dragonId);
    }

    function getUserApplicationsForGladiatorBattles(address _user) external view returns (uint256[]) {
        return gladiatorBattleStorage.getUserApplications(_user);
    }

    function getGladiatorBattleDetails(
        uint256 _challengeId
    ) external view returns (
        bool isGold, uint256 bet, uint16 counter,
        uint256 blockNumber, bool active,
        uint256 autoSelectBlock, bool cancelled,
        uint256 compensation, uint256 extensionTimePrice,
        uint256 battleId
    ) {
        return gladiatorBattleStorage.getChallengeDetails(_challengeId);
    }

    function getGladiatorBattleParticipants(
        uint256 _challengeId
    ) external view returns (
        address firstUser, uint256 firstDragonId,
        address secondUser, uint256 secondDragonId,
        address winnerUser, uint256 winnerDragonId
    ) {
        return gladiatorBattleStorage.getChallengeParticipants(_challengeId);
    }

    function isDragonInGladiatorBattle(uint256 _battleId) public view returns (bool) {
        return gladiatorBattle.isDragonChallenging(_battleId);
    }

    // UPDATE CONTRACT

    function setInternalDependencies(address[] _newDependencies) public onlyOwner {
        super.setInternalDependencies(_newDependencies);

        core = Core(_newDependencies[0]);
        dragonParams = DragonParams(_newDependencies[1]);
        dragonGetter = DragonGetter(_newDependencies[2]);
        dragonMarketplace = DragonMarketplace(_newDependencies[3]);
        breedingMarketplace = BreedingMarketplace(_newDependencies[4]);
        eggMarketplace = EggMarketplace(_newDependencies[5]);
        skillMarketplace = SkillMarketplace(_newDependencies[6]);
        distribution = Distribution(_newDependencies[7]);
        treasury = Treasury(_newDependencies[8]);
        gladiatorBattle = GladiatorBattle(_newDependencies[9]);
        gladiatorBattleStorage = GladiatorBattleStorage(_newDependencies[10]);
    }
}