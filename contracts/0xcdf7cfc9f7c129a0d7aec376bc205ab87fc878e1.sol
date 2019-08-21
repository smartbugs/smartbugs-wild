pragma solidity ^0.4.16;

library AddressUtils {
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

contract BasicAccessControl {
    address public owner;
    // address[] public moderators;
    uint16 public totalModerators = 0;
    mapping (address => bool) public moderators;
    bool public isMaintaining = false;

    function BasicAccessControl() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyModerators() {
        require(msg.sender == owner || moderators[msg.sender] == true);
        _;
    }

    modifier isActive {
        require(!isMaintaining);
        _;
    }

    function ChangeOwner(address _newOwner) onlyOwner public {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }


    function AddModerator(address _newModerator) onlyOwner public {
        if (moderators[_newModerator] == false) {
            moderators[_newModerator] = true;
            totalModerators += 1;
        }
    }
    
    function RemoveModerator(address _oldModerator) onlyOwner public {
        if (moderators[_oldModerator] == true) {
            moderators[_oldModerator] = false;
            totalModerators -= 1;
        }
    }

    function UpdateMaintaining(bool _isMaintaining) onlyOwner public {
        isMaintaining = _isMaintaining;
    }
}

contract EtheremonEnum {

    enum ResultCode {
        SUCCESS,
        ERROR_CLASS_NOT_FOUND,
        ERROR_LOW_BALANCE,
        ERROR_SEND_FAIL,
        ERROR_NOT_TRAINER,
        ERROR_NOT_ENOUGH_MONEY,
        ERROR_INVALID_AMOUNT
    }
    
    enum ArrayType {
        CLASS_TYPE,
        STAT_STEP,
        STAT_START,
        STAT_BASE,
        OBJ_SKILL
    }
    
    enum PropertyType {
        ANCESTOR,
        XFACTOR
    }
}

interface EtheremonDataBase {
    // read
    function getMonsterClass(uint32 _classId) constant external returns(uint32 classId, uint256 price, uint256 returnPrice, uint32 total, bool catchable);
    function getMonsterObj(uint64 _objId) constant external returns(uint64 objId, uint32 classId, address trainer, uint32 exp, uint32 createIndex, uint32 lastClaimIndex, uint createTime);
    function getElementInArrayType(EtheremonEnum.ArrayType _type, uint64 _id, uint _index) constant external returns(uint8);
    
    function addMonsterObj(uint32 _classId, address _trainer, string _name) external returns(uint64);
    function addElementToArrayType(EtheremonEnum.ArrayType _type, uint64 _id, uint8 _value) external returns(uint);
}

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
}

interface ERC721Interface {
    function ownerOf(uint256 _tokenId) external view returns (address owner);
}

interface EtheremonAdventureItem {
    function ownerOf(uint256 _tokenId) external view returns (address);
    function getItemInfo(uint _tokenId) constant external returns(uint classId, uint value);
    function spawnItem(uint _classId, uint _value, address _owner) external returns(uint);
}

interface EtheremonAdventureSetting {
    function getSiteItem(uint _siteId, uint _seed) constant external returns(uint _monsterClassId, uint _tokenClassId, uint _value);
    function getSiteId(uint _classId, uint _seed) constant external returns(uint);
}

interface EtheremonMonsterNFT {
    function mintMonster(uint32 _classId, address _trainer, string _name) external returns(uint);
}

contract EtheremonAdventureData {
    
    function addLandRevenue(uint _siteId, uint _emontAmount, uint _etherAmount) external;
    function addTokenClaim(uint _tokenId, uint _emontAmount, uint _etherAmount) external;
    function addExploreData(address _sender, uint _typeId, uint _monsterId, uint _siteId, uint _startAt, uint _emontAmount, uint _etherAmount) external returns(uint);
    function removePendingExplore(uint _exploreId, uint _itemSeed) external;
    
    // public function
    function getLandRevenue(uint _classId) constant public returns(uint _emontAmount, uint _etherAmount);
    
    function getTokenClaim(uint _tokenId) constant public returns(uint _emontAmount, uint _etherAmount);
    
    function getExploreData(uint _exploreId) constant public returns(address _sender, uint _typeId, uint _monsterId, uint _siteId, uint _itemSeed, uint _startAt);
    
    function getPendingExplore(address _player) constant public returns(uint);
    
    function getPendingExploreData(address _player) constant public returns(uint _exploreId, uint _typeId, uint _monsterId, uint _siteId, uint _itemSeed, uint _startAt);
}

contract EtheremonAdventure is EtheremonEnum, BasicAccessControl {
    
    using AddressUtils for address;
    
    uint8 constant public STAT_COUNT = 6;
    uint8 constant public STAT_MAX = 32;

    struct MonsterObjAcc {
        uint64 monsterId;
        uint32 classId;
        address trainer;
        string name;
        uint32 exp;
        uint32 createIndex;
        uint32 lastClaimIndex;
        uint createTime;
    }
    
    struct ExploreData {
        address sender;
        uint monsterType;
        uint monsterId;
        uint siteId;
        uint itemSeed;
        uint startAt; // blocknumber
    }
    
    struct ExploreReward {
        uint monsterClassId;
        uint itemClassId;
        uint value;
        uint temp;
    }
    
    address public dataContract;
    address public monsterNFT;
    address public adventureDataContract;
    address public adventureSettingContract;
    address public adventureItemContract;
    address public tokenContract;
    address public kittiesContract;
    
    uint public exploreETHFee = 0.01 ether;
    uint public exploreEMONTFee = 1500000000;
    uint public exploreFastenETHFee = 0.005 ether;
    uint public exploreFastenEMONTFee = 750000000;
    uint public minBlockGap = 240;
    uint public totalSite = 54;
    
    uint seed = 0;
    
    event SendExplore(address indexed from, uint monsterType, uint monsterId, uint exploreId);
    event ClaimExplore(address indexed from, uint exploreId, uint itemType, uint itemClass, uint itemId);
    
    modifier requireDataContract {
        require(dataContract != address(0));
        _;
    }
    
    modifier requireAdventureDataContract {
        require(adventureDataContract != address(0));
        _;
    }
    
    modifier requireAdventureSettingContract {
        require(adventureSettingContract != address(0));
        _;
    }
    
    modifier requireTokenContract {
        require(tokenContract != address(0));
        _;
    }
    
    modifier requireKittiesContract {
        require(kittiesContract != address(0));
        _;
    }
    
    function setContract(address _dataContract, address _monsterNFT, address _adventureDataContract, address _adventureSettingContract, address _adventureItemContract, address _tokenContract, address _kittiesContract) onlyOwner public {
        dataContract = _dataContract;
        monsterNFT = _monsterNFT;
        adventureDataContract = _adventureDataContract;
        adventureSettingContract = _adventureSettingContract;
        adventureItemContract = _adventureItemContract;
        tokenContract = _tokenContract;
        kittiesContract = _kittiesContract;
    }

    function setFeeConfig(uint _exploreETHFee, uint _exploreEMONTFee, uint _exploreFastenETHFee, uint _exploreFastenEMONTFee) onlyOwner public {
        exploreETHFee = _exploreETHFee;
        exploreEMONTFee = _exploreEMONTFee;
        exploreFastenEMONTFee = _exploreFastenEMONTFee;
        exploreFastenETHFee = _exploreFastenETHFee;
    }

    function setConfig( uint _minBlockGap, uint _totalSite) onlyOwner public {
        minBlockGap = _minBlockGap;
        totalSite = _totalSite;
    }
    
    function withdrawEther(address _sendTo, uint _amount) onlyOwner public {
        // it is used in case we need to upgrade the smartcontract
        if (_amount > address(this).balance) {
            revert();
        }
        _sendTo.transfer(_amount);
    }
    
    function withdrawToken(address _sendTo, uint _amount) onlyOwner requireTokenContract external {
        ERC20Interface token = ERC20Interface(tokenContract);
        if (_amount > token.balanceOf(address(this))) {
            revert();
        }
        token.transfer(_sendTo, _amount);
    }
    
    function adventureByToken(address _player, uint _token, uint _param1, uint _param2, uint64 _param3, uint64 _param4) isActive onlyModerators external {
        // param1 = 1 -> explore, param1 = 2 -> claim 
        if (_param1 == 1) {
            _exploreUsingEmont(_player, _param2, _param3, _token);
        } else {
            _claimExploreItemUsingEMont(_param2, _token);
        }
    }
    
    function _exploreUsingEmont(address _sender, uint _monsterType, uint _monsterId, uint _token) internal {
        if (_token < exploreEMONTFee) revert();
        seed = getRandom(_sender, block.number - 1, seed, _monsterId);
        uint siteId = getTargetSite(_sender, _monsterType, _monsterId, seed);
        if (siteId == 0) revert();
        
        EtheremonAdventureData adventureData = EtheremonAdventureData(adventureDataContract);
        uint exploreId = adventureData.addExploreData(_sender, _monsterType, _monsterId, siteId, block.number, _token, 0);
        SendExplore(_sender, _monsterType, _monsterId, exploreId);
    }
    
    function _claimExploreItemUsingEMont(uint _exploreId, uint _token) internal {
        if (_token < exploreFastenEMONTFee) revert();
        
        EtheremonAdventureData adventureData = EtheremonAdventureData(adventureDataContract);
        ExploreData memory exploreData;
        (exploreData.sender, exploreData.monsterType, exploreData.monsterId, exploreData.siteId, exploreData.itemSeed, exploreData.startAt) = adventureData.getExploreData(_exploreId);
        
        if (exploreData.itemSeed != 0)
            revert();
        
        // min 2 blocks
        if (block.number < exploreData.startAt + 2)
            revert();
        
        exploreData.itemSeed = getRandom(exploreData.sender, exploreData.startAt + 1, exploreData.monsterId, _exploreId) % 100000;
        ExploreReward memory reward;
        (reward.monsterClassId, reward.itemClassId, reward.value) = EtheremonAdventureSetting(adventureSettingContract).getSiteItem(exploreData.siteId, exploreData.itemSeed);
        
        adventureData.removePendingExplore(_exploreId, exploreData.itemSeed);
        
        if (reward.monsterClassId > 0) {
            EtheremonMonsterNFT monsterContract = EtheremonMonsterNFT(monsterNFT);
            reward.temp = monsterContract.mintMonster(uint32(reward.monsterClassId), exploreData.sender,  "..name me..");
            ClaimExplore(exploreData.sender, _exploreId, 0, reward.monsterClassId, reward.temp);
        } else if (reward.itemClassId > 0) {
            // give new adventure item 
            EtheremonAdventureItem item = EtheremonAdventureItem(adventureItemContract);
            reward.temp = item.spawnItem(reward.itemClassId, reward.value, exploreData.sender);
            ClaimExplore(exploreData.sender, _exploreId, 1, reward.itemClassId, reward.temp);
        } else if (reward.value > 0) {
            // send token contract
            ERC20Interface token = ERC20Interface(tokenContract);
            token.transfer(exploreData.sender, reward.value);
            ClaimExplore(exploreData.sender, _exploreId, 2, 0, reward.value);
        } else {
            revert();
        }
    }
    
    // public
    
    function getRandom(address _player, uint _block, uint _seed, uint _count) constant public returns(uint) {
        return uint(keccak256(block.blockhash(_block), _player, _seed, _count));
    }
    
    function getTargetSite(address _sender, uint _monsterType, uint _monsterId, uint _seed) constant public returns(uint) {
        if (_monsterType == 0) {
            // Etheremon 
            MonsterObjAcc memory obj;
            (obj.monsterId, obj.classId, obj.trainer, obj.exp, obj.createIndex, obj.lastClaimIndex, obj.createTime) = EtheremonDataBase(dataContract).getMonsterObj(uint64(_monsterId));
            if (obj.trainer != _sender) revert();
            return EtheremonAdventureSetting(adventureSettingContract).getSiteId(obj.classId, _seed);
        } else if (_monsterType == 1) {
            // Cryptokitties
            if (_sender != ERC721Interface(kittiesContract).ownerOf(_monsterId)) revert();
            return EtheremonAdventureSetting(adventureSettingContract).getSiteId(_seed % totalSite, _seed);
        }
        return 0;
    }
    
    function exploreUsingETH(uint _monsterType, uint _monsterId) isActive public payable {
        // not allow contract to make txn
        if (msg.sender.isContract()) revert();
        
        if (msg.value < exploreETHFee) revert();
        seed = getRandom(msg.sender, block.number - 1, seed, _monsterId);
        uint siteId = getTargetSite(msg.sender, _monsterType, _monsterId, seed);
        if (siteId == 0) revert();
        EtheremonAdventureData adventureData = EtheremonAdventureData(adventureDataContract);
        uint exploreId = adventureData.addExploreData(msg.sender, _monsterType, _monsterId, siteId, block.number, 0, msg.value);
        SendExplore(msg.sender, _monsterType, _monsterId, exploreId);
    }
    
    function claimExploreItem(uint _exploreId) isActive public payable {
        EtheremonAdventureData adventureData = EtheremonAdventureData(adventureDataContract);
        ExploreData memory exploreData;
        (exploreData.sender, exploreData.monsterType, exploreData.monsterId, exploreData.siteId, exploreData.itemSeed, exploreData.startAt) = adventureData.getExploreData(_exploreId);
        
        if (exploreData.itemSeed != 0)
            revert();
        
        // min 2 blocks
        if (block.number < exploreData.startAt + 2)
            revert();
        
        exploreData.itemSeed = getRandom(exploreData.sender, exploreData.startAt + 1, exploreData.monsterId, _exploreId) % 100000;
        if (msg.value < exploreFastenETHFee) {
            if (block.number < exploreData.startAt + minBlockGap + exploreData.startAt % minBlockGap)
                revert();
        }
        
        ExploreReward memory reward;
        (reward.monsterClassId, reward.itemClassId, reward.value) = EtheremonAdventureSetting(adventureSettingContract).getSiteItem(exploreData.siteId, exploreData.itemSeed);
        
        adventureData.removePendingExplore(_exploreId, exploreData.itemSeed);
        
        if (reward.monsterClassId > 0) {
            EtheremonMonsterNFT monsterContract = EtheremonMonsterNFT(monsterNFT);
            reward.temp = monsterContract.mintMonster(uint32(reward.monsterClassId), exploreData.sender,  "..name me..");
            ClaimExplore(exploreData.sender, _exploreId, 0, reward.monsterClassId, reward.temp);
        } else if (reward.itemClassId > 0) {
            // give new adventure item 
            EtheremonAdventureItem item = EtheremonAdventureItem(adventureItemContract);
            reward.temp = item.spawnItem(reward.itemClassId, reward.value, exploreData.sender);
            ClaimExplore(exploreData.sender, _exploreId, 1, reward.itemClassId, reward.temp);
        } else if (reward.value > 0) {
            // send token contract
            ERC20Interface token = ERC20Interface(tokenContract);
            token.transfer(exploreData.sender, reward.value);
            ClaimExplore(exploreData.sender, _exploreId, 2, 0, reward.value);
        } else {
            revert();
        }
    }
    
    // public
    
    function predictExploreReward(uint _exploreId) constant external returns(uint itemSeed, uint rewardMonsterClass, uint rewardItemCLass, uint rewardValue) {
        EtheremonAdventureData adventureData = EtheremonAdventureData(adventureDataContract);
        ExploreData memory exploreData;
        (exploreData.sender, exploreData.monsterType, exploreData.monsterId, exploreData.siteId, exploreData.itemSeed, exploreData.startAt) = adventureData.getExploreData(_exploreId);
        
        if (exploreData.itemSeed != 0) {
            itemSeed = exploreData.itemSeed;
        } else {
            if (block.number < exploreData.startAt + 2)
                return (0, 0, 0, 0);
            itemSeed = getRandom(exploreData.sender, exploreData.startAt + 1, exploreData.monsterId, _exploreId) % 100000;
        }
        (rewardMonsterClass, rewardItemCLass, rewardValue) = EtheremonAdventureSetting(adventureSettingContract).getSiteItem(exploreData.siteId, itemSeed);
    }
    
    function getExploreItem(uint _exploreId) constant external returns(address trainer, uint monsterType, uint monsterId, uint siteId, uint startBlock, uint rewardMonsterClass, uint rewardItemClass, uint rewardValue) {
        EtheremonAdventureData adventureData = EtheremonAdventureData(adventureDataContract);
        (trainer, monsterType, monsterId, siteId, rewardMonsterClass, startBlock) = adventureData.getExploreData(_exploreId);
        
        if (rewardMonsterClass > 0) {
            (rewardMonsterClass, rewardItemClass, rewardValue) = EtheremonAdventureSetting(adventureSettingContract).getSiteItem(siteId, rewardMonsterClass);
        }
        
    }
    
    function getPendingExploreItem(address _trainer) constant external returns(uint exploreId, uint monsterType, uint monsterId, uint siteId, uint startBlock, uint endBlock) {
        EtheremonAdventureData adventureData = EtheremonAdventureData(adventureDataContract);
        (exploreId, monsterType, monsterId, siteId, endBlock, startBlock) = adventureData.getPendingExploreData(_trainer);
        if (exploreId > 0) {
            endBlock = startBlock + minBlockGap + startBlock % minBlockGap;
        }
    }

}