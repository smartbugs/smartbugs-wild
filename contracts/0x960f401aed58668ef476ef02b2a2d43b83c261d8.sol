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

contract ERC721Basic {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function exists(uint256 _tokenId) public view returns (bool _exists);

    function approve(address _to, uint256 _tokenId) public;
    function getApproved(uint256 _tokenId) public view returns (address _operator);

    function setApprovalForAll(address _operator, bool _approved) public;
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public;

    function supportsInterface(bytes4 _interfaceID) external pure returns (bool);
}

contract ERC721Enumerable is ERC721Basic {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
    function tokenByIndex(uint256 _index) public view returns (uint256);
}

contract ERC721Metadata is ERC721Basic {
    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
    function tokenURI(uint256 _tokenId) public view returns (string);
}


contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {}

contract ERC721Receiver {
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes _data
    )
        public
        returns(bytes4);
}

contract ERC721BasicToken is ERC721Basic, Upgradable {

    using SafeMath256 for uint256;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping (uint256 => address) internal tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) internal tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (address => uint256) internal ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) internal operatorApprovals;

    function _checkRights(bool _has) internal pure {
        require(_has, "no rights to manage");
    }

    function _validateAddress(address _addr) internal pure {
        require(_addr != address(0), "invalid address");
    }

    function _checkOwner(uint256 _tokenId, address _owner) internal view {
        require(ownerOf(_tokenId) == _owner, "not an owner");
    }

    function _checkThatUserHasTokens(bool _has) internal pure {
        require(_has, "user has no tokens");
    }

    function balanceOf(address _owner) public view returns (uint256) {
        _validateAddress(_owner);
        return ownedTokensCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = tokenOwner[_tokenId];
        _validateAddress(owner);
        return owner;
    }

    function exists(uint256 _tokenId) public view returns (bool) {
        address owner = tokenOwner[_tokenId];
        return owner != address(0);
    }

    function _approve(address _from, address _to, uint256 _tokenId) internal {
        address owner = ownerOf(_tokenId);
        require(_to != owner, "can't be approved to owner");
        _checkRights(_from == owner || isApprovedForAll(owner, _from));

        if (getApproved(_tokenId) != address(0) || _to != address(0)) {
            tokenApprovals[_tokenId] = _to;
            emit Approval(owner, _to, _tokenId);
        }
    }

    function approve(address _to, uint256 _tokenId) public {
        _approve(msg.sender, _to, _tokenId);
    }

    function remoteApprove(address _to, uint256 _tokenId) external onlyController {
        _approve(tx.origin, _to, _tokenId);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        require(exists(_tokenId), "token doesn't exist");
        return tokenApprovals[_tokenId];
    }

    function setApprovalForAll(address _to, bool _approved) public {
        require(_to != msg.sender, "wrong sender");
        operatorApprovals[msg.sender][_to] = _approved;
        emit ApprovalForAll(msg.sender, _to, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        _checkRights(isApprovedOrOwner(msg.sender, _tokenId));
        _validateAddress(_from);
        _validateAddress(_to);

        clearApproval(_from, _tokenId);
        removeTokenFrom(_from, _tokenId);
        addTokenTo(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    ) public {
        transferFrom(_from, _to, _tokenId);
        require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data), "can't make safe transfer");
    }

    function isApprovedOrOwner(address _spender, uint256 _tokenId) public view returns (bool) {
        address owner = ownerOf(_tokenId);
        return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
    }

    function _mint(address _to, uint256 _tokenId) internal {
        _validateAddress(_to);
        addTokenTo(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
    }

    function _burn(address _owner, uint256 _tokenId) internal {
        clearApproval(_owner, _tokenId);
        removeTokenFrom(_owner, _tokenId);
        emit Transfer(_owner, address(0), _tokenId);
    }

    function clearApproval(address _owner, uint256 _tokenId) internal {
        _checkOwner(_tokenId, _owner);
        if (tokenApprovals[_tokenId] != address(0)) {
            tokenApprovals[_tokenId] = address(0);
            emit Approval(_owner, address(0), _tokenId);
        }
    }

    function addTokenTo(address _to, uint256 _tokenId) internal {
        require(tokenOwner[_tokenId] == address(0), "token already has an owner");
        tokenOwner[_tokenId] = _to;
        ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
    }

    function removeTokenFrom(address _from, uint256 _tokenId) internal {
        _checkOwner(_tokenId, _from);
        _checkThatUserHasTokens(ownedTokensCount[_from] > 0);
        ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
        tokenOwner[_tokenId] = address(0);
    }

    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function checkAndCallSafeTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    ) internal returns (bool) {
        if (!_isContract(_to)) {
            return true;
        }
        bytes4 retval = ERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }
}

contract ERC721Token is ERC721, ERC721BasicToken {

    bytes4 internal constant INTERFACE_SIGNATURE_ERC165 = 0x01ffc9a7;
    bytes4 internal constant INTERFACE_SIGNATURE_ERC721 = 0x80ac58cd;
    bytes4 internal constant INTERFACE_SIGNATURE_ERC721TokenReceiver = 0xf0b9e5ba;
    bytes4 internal constant INTERFACE_SIGNATURE_ERC721Metadata = 0x5b5e139f;
    bytes4 internal constant INTERFACE_SIGNATURE_ERC721Enumerable = 0x780e9d63;

    string internal name_;
    string internal symbol_;

    // Mapping from owner to list of owned token IDs
    mapping (address => uint256[]) internal ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) internal ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] internal allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) internal allTokensIndex;

    // Optional mapping for token URIs
    mapping(uint256 => string) internal tokenURIs;

    // The contract owner can change the base URL, in case it becomes necessary. It is needed for Metadata.
    string public url;


    constructor(string _name, string _symbol) public {
        name_ = _name;
        symbol_ = _symbol;
    }

    function name() public view returns (string) {
        return name_;
    }

    function symbol() public view returns (string) {
        return symbol_;
    }

    function _validateIndex(bool _isValid) internal pure {
        require(_isValid, "wrong index");
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
        _validateIndex(_index < balanceOf(_owner));
        return ownedTokens[_owner][_index];
    }

    function tokensOfOwner(address _owner) external view returns (uint256[]) {
        return ownedTokens[_owner];
    }

    function getAllTokens() external view returns (uint256[]) {
        return allTokens;
    }

    function totalSupply() public view returns (uint256) {
        return allTokens.length;
    }

    function tokenByIndex(uint256 _index) public view returns (uint256) {
        _validateIndex(_index < totalSupply());
        return allTokens[_index];
    }

    function addTokenTo(address _to, uint256 _tokenId) internal {
        super.addTokenTo(_to, _tokenId);
        uint256 length = ownedTokens[_to].length;
        ownedTokens[_to].push(_tokenId);
        ownedTokensIndex[_tokenId] = length;
    }

    function removeTokenFrom(address _from, uint256 _tokenId) internal {
        _checkThatUserHasTokens(ownedTokens[_from].length > 0);

        super.removeTokenFrom(_from, _tokenId);

        uint256 tokenIndex = ownedTokensIndex[_tokenId];
        uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
        uint256 lastToken = ownedTokens[_from][lastTokenIndex];

        ownedTokens[_from][tokenIndex] = lastToken;
        ownedTokens[_from][lastTokenIndex] = 0;

        ownedTokens[_from].length--;
        ownedTokensIndex[_tokenId] = 0;
        ownedTokensIndex[lastToken] = tokenIndex;
    }

    function _mint(address _to, uint256 _tokenId) internal {
        super._mint(_to, _tokenId);

        allTokensIndex[_tokenId] = allTokens.length;
        allTokens.push(_tokenId);
    }

    function _burn(address _owner, uint256 _tokenId) internal {
        require(allTokens.length > 0, "no tokens");

        super._burn(_owner, _tokenId);

        uint256 tokenIndex = allTokensIndex[_tokenId];
        uint256 lastTokenIndex = allTokens.length.sub(1);
        uint256 lastToken = allTokens[lastTokenIndex];

        allTokens[tokenIndex] = lastToken;
        allTokens[lastTokenIndex] = 0;

        allTokens.length--;
        allTokensIndex[_tokenId] = 0;
        allTokensIndex[lastToken] = tokenIndex;
    }

    function supportsInterface(bytes4 _interfaceID) external pure returns (bool) {
        return (
            _interfaceID == INTERFACE_SIGNATURE_ERC165 ||
            _interfaceID == INTERFACE_SIGNATURE_ERC721 ||
            _interfaceID == INTERFACE_SIGNATURE_ERC721TokenReceiver ||
            _interfaceID == INTERFACE_SIGNATURE_ERC721Metadata ||
            _interfaceID == INTERFACE_SIGNATURE_ERC721Enumerable
        );
    }

    function tokenURI(uint256 _tokenId) public view returns (string) {
        require(exists(_tokenId), "token doesn't exist");
        return string(abi.encodePacked(url, _uint2str(_tokenId)));
    }

    function setUrl(string _url) external onlyOwner {
        url = _url;
    }

    function _uint2str(uint _i) internal pure returns (string){
        if (i == 0) return "0";
        uint i = _i;
        uint j = _i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
}

contract DragonModel {

    // ** multiplying is necessary for more accurate calculations

    // health and mana are multiplied by 100
    struct HealthAndMana {
        uint256 timestamp; // timestamp of last update
        uint32 remainingHealth; // remaining at last update
        uint32 remainingMana; // remaining at last update
        uint32 maxHealth;
        uint32 maxMana;
    }

    struct Level {
        uint8 level; // current level of dragon
        uint8 experience; // exp at current level
        uint16 dnaPoints; // DNA points
    }

    struct Tactics {
        uint8 melee; // ranged/melee tactics in percentages
        uint8 attack; // defense/attack tactics in percentages
    }

    struct Battles {
        uint16 wins;
        uint16 defeats;
    }

    // multilpied by 100
    struct Skills {
        uint32 attack;
        uint32 defense;
        uint32 stamina;
        uint32 speed;
        uint32 intelligence;
    }

    // types:
    // 0 - water
    // 1 - fire
    // 2 - air
    // 3 - earth
    // 4 - magic

    struct Dragon {
        uint16 generation;
        uint256[4] genome; // composed genome
        uint256[2] parents;
        uint8[11] types; // array of weights of dragon's types
        uint256 birth; // timestamp
    }

}

contract DragonStorage is DragonModel, ERC721Token {
    Dragon[] public dragons;
    // existing names
    mapping (bytes32 => bool) public existingNames;
    mapping (uint256 => bytes32) public names;

    mapping (uint256 => HealthAndMana) public healthAndMana;
    mapping (uint256 => Tactics) public tactics;
    mapping (uint256 => Battles) public battles;
    mapping (uint256 => Skills) public skills;
    mapping (uint256 => Level) public levels;
    mapping (uint256 => uint32) public coolness; // Dragon Skillfulness Index in the WP

    // id -> type of skill (dragon type)
    mapping (uint256 => uint8) public specialAttacks;
    mapping (uint256 => uint8) public specialDefenses;


    // classes:
    // 0 - no skill
    // 1 - attack boost
    // 2 - defense boost
    // 3 - stamina boost
    // 4 - speed boost
    // 5 - intelligence boost
    // 6 - healing
    // 7 - mana recharge

    // id -> class
    mapping (uint256 => uint8) public specialPeacefulSkills;


    // classes:
    // 1 - attack
    // 2 - defense
    // 3 - stamina
    // 4 - speed
    // 5 - intelligence
    //
    // id -> class -> effect
    mapping (uint256 => mapping (uint8 => uint32)) public buffs;



    constructor(string _name, string _symbol) public ERC721Token(_name, _symbol) {
        dragons.length = 1; // to avoid some issues with 0
    }

    // GETTERS

    function length() external view returns (uint256) {
        return dragons.length;
    }

    function getGenome(uint256 _id) external view returns (uint256[4]) {
        return dragons[_id].genome;
    }

    function getParents(uint256 _id) external view returns (uint256[2]) {
        return dragons[_id].parents;
    }

    function getDragonTypes(uint256 _id) external view returns (uint8[11]) {
        return dragons[_id].types;
    }

    // SETTERS

    function push(
        address _sender,
        uint16 _generation,
        uint256[4] _genome,
        uint256[2] _parents,
        uint8[11] _types
    ) public onlyController returns (uint256 id) {
        id = dragons.push(Dragon({
            generation: _generation,
            genome: _genome,
            parents: _parents,
            types: _types,
            birth: now
        })).sub(1);
        _mint(_sender, id);
    }

    function setName(
        uint256 _id,
        bytes32 _name,
        bytes32 _lowercase
    ) external onlyController {
        names[_id] = _name;
        existingNames[_lowercase] = true;
    }

    function setTactics(uint256 _id, uint8 _melee, uint8 _attack) external onlyController {
        tactics[_id].melee = _melee;
        tactics[_id].attack = _attack;
    }

    function setWins(uint256 _id, uint16 _value) external onlyController {
        battles[_id].wins = _value;
    }

    function setDefeats(uint256 _id, uint16 _value) external onlyController {
        battles[_id].defeats = _value;
    }

    function setMaxHealthAndMana(
        uint256 _id,
        uint32 _maxHealth,
        uint32 _maxMana
    ) external onlyController {
        healthAndMana[_id].maxHealth = _maxHealth;
        healthAndMana[_id].maxMana = _maxMana;
    }

    function setRemainingHealthAndMana(
        uint256 _id,
        uint32 _remainingHealth,
        uint32 _remainingMana
    ) external onlyController {
        healthAndMana[_id].timestamp = now;
        healthAndMana[_id].remainingHealth = _remainingHealth;
        healthAndMana[_id].remainingMana = _remainingMana;
    }

    function resetHealthAndManaTimestamp(uint256 _id) external onlyController {
        healthAndMana[_id].timestamp = 0;
    }

    function setSkills(
        uint256 _id,
        uint32 _attack,
        uint32 _defense,
        uint32 _stamina,
        uint32 _speed,
        uint32 _intelligence
    ) external onlyController {
        skills[_id].attack = _attack;
        skills[_id].defense = _defense;
        skills[_id].stamina = _stamina;
        skills[_id].speed = _speed;
        skills[_id].intelligence = _intelligence;
    }

    function setLevel(uint256 _id, uint8 _level, uint8 _experience, uint16 _dnaPoints) external onlyController {
        levels[_id].level = _level;
        levels[_id].experience = _experience;
        levels[_id].dnaPoints = _dnaPoints;
    }

    function setCoolness(uint256 _id, uint32 _coolness) external onlyController {
        coolness[_id] = _coolness;
    }

    function setGenome(uint256 _id, uint256[4] _genome) external onlyController {
        dragons[_id].genome = _genome;
    }

    function setSpecialAttack(
        uint256 _id,
        uint8 _dragonType
    ) external onlyController {
        specialAttacks[_id] = _dragonType;
    }

    function setSpecialDefense(
        uint256 _id,
        uint8 _dragonType
    ) external onlyController {
        specialDefenses[_id] = _dragonType;
    }

    function setSpecialPeacefulSkill(
        uint256 _id,
        uint8 _class
    ) external onlyController {
        specialPeacefulSkills[_id] = _class;
    }

    function setBuff(uint256 _id, uint8 _class, uint32 _effect) external onlyController {
        buffs[_id][_class] = _effect;
    }
}