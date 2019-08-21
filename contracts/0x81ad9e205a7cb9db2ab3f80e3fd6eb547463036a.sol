pragma solidity ^0.4.24;
contract BasicAccessControl {
    address public owner;
    // address[] public moderators;
    uint16 public totalModerators = 0;
    mapping (address => bool) public moderators;
    bool public isMaintaining = false;

    constructor() public {
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

interface EtheremonDataBase {
    function getMonsterObj(uint64 _objId) constant external returns(uint64 objId, uint32 classId, address trainer, uint32 exp, uint32 createIndex, uint32 lastClaimIndex, uint createTime);
}

interface EtheremonMonsterNFTInterface {
    function burnMonster(uint64 _tokenId) external;
}

interface EtheremonTradeInterface {
    function isOnTrading(uint64 _objId) constant external returns(bool);
}

contract EtheremonBurnReward is BasicAccessControl {
    
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
    
    // address
    mapping(uint => uint) public requests; // mapping burn_id => monster_id
    address public tradeContract;
    address public dataContract;
    address public monsterNFTContract;
    
    function setContract(address _monsterNFTContract, address _dataContract, address _tradeContract) onlyModerators public {
        monsterNFTContract = _monsterNFTContract;
        dataContract = _dataContract;
        tradeContract = _tradeContract;
    }
    
    // public api
    function burnForReward(uint64 _monsterId, uint _burnId) isActive external {
        if (_burnId == 0 || _monsterId == 0 || requests[_burnId] > 0) revert();
        
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, obj.createIndex, obj.lastClaimIndex, obj.createTime) = data.getMonsterObj(_monsterId);
        if (obj.trainer == address(0) || obj.trainer != msg.sender) revert();
        
        EtheremonTradeInterface trade = EtheremonTradeInterface(tradeContract);
        if (trade.isOnTrading(_monsterId)) revert();
        
        EtheremonMonsterNFTInterface monsterNFT = EtheremonMonsterNFTInterface(monsterNFTContract);
        monsterNFT.burnMonster(_monsterId);
        
        requests[_burnId] = _monsterId;
    }
    
    function getBurnInfo(uint _burnId) constant external returns(uint) {
        return requests[_burnId];
    }
}