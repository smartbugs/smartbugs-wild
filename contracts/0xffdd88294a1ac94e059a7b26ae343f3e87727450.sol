pragma solidity ^0.4.23;

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

contract EtheremonAdventureSetting is BasicAccessControl {
    struct RewardData {
        uint monster_rate;
        uint monster_id;
        uint shard_rate;
        uint shard_id;
        uint level_rate;
        uint exp_rate;
        uint emont_rate;
    }
    mapping(uint => uint[]) public siteSet; // monster class -> site id
    mapping(uint => uint) public monsterClassSiteSet;
    mapping(uint => RewardData) public siteRewards; // site id => rewards (monster_rate, monster_id, shard_rate, shard_id, level_rate, exp_rate, emont_rate)
    uint public levelItemClass = 200;
    uint public expItemClass = 201;
    uint[4] public levelRewards = [1, 1, 1, 2];
    uint[11] public expRewards = [50, 50, 50, 50, 100, 100, 100, 100, 200, 200, 500];
    uint[6] public emontRewards = [300000000, 300000000, 500000000, 500000000, 1000000000, 150000000];
    
    function setConfig(uint _levelItemClass, uint _expItemClass) onlyModerators public {
        levelItemClass = _levelItemClass;
        expItemClass = _expItemClass;
    }
    
    function addSiteSet(uint _setId, uint _siteId) onlyModerators public {
        uint[] storage siteList = siteSet[_setId];
        for (uint index = 0; index < siteList.length; index++) {
            if (siteList[index] == _siteId) {
                return;
            }
        }
        siteList.push(_siteId);
    }
    
    function removeSiteSet(uint _setId, uint _siteId) onlyModerators public {
        uint[] storage siteList = siteSet[_setId];
        uint foundIndex = 0;
        for (; foundIndex < siteList.length; foundIndex++) {
            if (siteList[foundIndex] == _siteId) {
                break;
            }
        }
        if (foundIndex < siteList.length) {
            siteList[foundIndex] = siteList[siteList.length-1];
            delete siteList[siteList.length-1];
            siteList.length--;
        }
    }
    
    function setMonsterClassSiteSet(uint _monsterId, uint _siteSetId) onlyModerators public {
        monsterClassSiteSet[_monsterId] = _siteSetId;
    }
    
    function setSiteRewards(uint _siteId, uint _monster_rate, uint _monster_id, uint _shard_rate, uint _shard_id, uint _level_rate, uint _exp_rate, uint _emont_rate) onlyModerators public {
        RewardData storage reward = siteRewards[_siteId];
        reward.monster_rate = _monster_rate;
        reward.monster_id = _monster_id;
        reward.shard_rate = _shard_rate;
        reward.shard_id = _shard_id;
        reward.level_rate = _level_rate;
        reward.exp_rate = _exp_rate;
        reward.emont_rate = _emont_rate;
    }
    
    function setLevelRewards(uint _index, uint _value) onlyModerators public {
        levelRewards[_index] = _value;
    }
    
    function setExpRewards(uint _index, uint _value) onlyModerators public {
        expRewards[_index] = _value;
    }
    
    function setEmontRewards(uint _index, uint _value) onlyModerators public {
        emontRewards[_index] = _value;
    }
    
    function initSiteSet(uint _turn) onlyModerators public {
        if (_turn == 1) {
            siteSet[1] = [35, 3, 4, 37, 51, 8, 41, 11, 45, 47, 15, 16, 19, 52, 23, 36, 27, 30, 31];
            siteSet[2] = [35, 3, 4, 49, 39, 8, 41, 11, 13, 15, 48, 43, 18, 19, 53, 23, 27, 30, 31];
            siteSet[3] = [2, 4, 39, 40, 9, 47, 12, 14, 44, 16, 49, 20, 46, 54, 24, 25, 27, 36, 29, 31];
            siteSet[4] = [51, 3, 5, 38, 7, 40, 11, 12, 45, 14, 47, 16, 35, 52, 21, 22, 26, 30, 31];
            siteSet[5] = [33, 3, 4, 54, 38, 8, 10, 43, 45, 14, 50, 18, 35, 21, 22, 46, 26, 28, 42];
            siteSet[6] = [51, 3, 36, 5, 7, 44, 42, 12, 13, 47, 17, 37, 19, 52, 24, 26, 28, 29, 31];
            siteSet[7] = [32, 48, 2, 43, 4, 38, 7, 9, 42, 11, 34, 15, 16, 49, 21, 23, 25, 30, 53];
            siteSet[8] = [1, 34, 54, 6, 33, 8, 44, 39, 12, 13, 46, 17, 50, 20, 22, 40, 24, 25, 29];
            siteSet[9] = [32, 2, 6, 7, 40, 10, 39, 44, 34, 15, 48, 17, 50, 20, 21, 24, 25, 29, 52];
            siteSet[10] = [32, 1, 36, 5, 38, 48, 9, 11, 45, 15, 16, 49, 19, 41, 23, 27, 28, 53, 37];
        } else {
            siteSet[11] = [2, 35, 37, 6, 7, 10, 46, 44, 50, 14, 18, 51, 21, 22, 26, 53, 42, 30, 31];
            siteSet[12] = [1, 34, 5, 51, 33, 9, 10, 45, 14, 47, 16, 18, 19, 52, 41, 23, 27, 29, 37];
            siteSet[13] = [32, 2, 35, 4, 5, 38, 49, 9, 42, 43, 12, 13, 48, 17, 21, 24, 25, 28, 53];
            siteSet[14] = [1, 34, 3, 37, 6, 33, 8, 41, 10, 45, 46, 15, 17, 50, 20, 54, 24, 25, 29];
            siteSet[15] = [33, 2, 34, 6, 7, 40, 42, 11, 13, 47, 50, 43, 18, 20, 22, 39, 26, 30, 52];
            siteSet[16] = [32, 1, 36, 5, 39, 54, 9, 10, 43, 14, 18, 51, 20, 46, 22, 41, 27, 28, 53];
            siteSet[17] = [32, 1, 49, 36, 38, 6, 33, 8, 44, 12, 13, 48, 17, 19, 40, 54, 23, 26, 28];
        }
    }
    
    function initMonsterClassSiteSet() onlyModerators public {
            monsterClassSiteSet[1] = 1;
            monsterClassSiteSet[2] = 2;
            monsterClassSiteSet[3] = 3;
            monsterClassSiteSet[4] = 4;
            monsterClassSiteSet[5] = 5;
            monsterClassSiteSet[6] = 6;
            monsterClassSiteSet[7] = 7;
            monsterClassSiteSet[8] = 8;
            monsterClassSiteSet[9] = 8;
            monsterClassSiteSet[10] = 2;
            monsterClassSiteSet[11] = 9;
            monsterClassSiteSet[12] = 10;
            monsterClassSiteSet[13] = 11;
            monsterClassSiteSet[14] = 12;
            monsterClassSiteSet[15] = 3;
            monsterClassSiteSet[16] = 13;
            monsterClassSiteSet[17] = 3;
            monsterClassSiteSet[18] = 8;
            monsterClassSiteSet[19] = 8;
            monsterClassSiteSet[20] = 14;
            monsterClassSiteSet[21] = 13;
            monsterClassSiteSet[22] = 4;
            monsterClassSiteSet[23] = 9;
            monsterClassSiteSet[24] = 1;
            monsterClassSiteSet[25] = 1;
            monsterClassSiteSet[26] = 3;
            monsterClassSiteSet[27] = 2;
            monsterClassSiteSet[28] = 6;
            monsterClassSiteSet[29] = 4;
            monsterClassSiteSet[30] = 14;
            monsterClassSiteSet[31] = 10;
            monsterClassSiteSet[32] = 1;
            monsterClassSiteSet[33] = 15;
            monsterClassSiteSet[34] = 3;
            monsterClassSiteSet[35] = 3;
            monsterClassSiteSet[36] = 2;
            monsterClassSiteSet[37] = 8;
            monsterClassSiteSet[38] = 1;
            monsterClassSiteSet[39] = 2;
            monsterClassSiteSet[40] = 3;
            monsterClassSiteSet[41] = 4;
            monsterClassSiteSet[42] = 5;
            monsterClassSiteSet[43] = 6;
            monsterClassSiteSet[44] = 7;
            monsterClassSiteSet[45] = 8;
            monsterClassSiteSet[46] = 8;
            monsterClassSiteSet[47] = 2;
            monsterClassSiteSet[48] = 9;
            monsterClassSiteSet[49] = 10;
            monsterClassSiteSet[50] = 8;
            monsterClassSiteSet[51] = 14;
            monsterClassSiteSet[52] = 1;
            monsterClassSiteSet[53] = 3;
            monsterClassSiteSet[54] = 2;
            monsterClassSiteSet[55] = 6;
            monsterClassSiteSet[56] = 4;
            monsterClassSiteSet[57] = 14;
            monsterClassSiteSet[58] = 10;
            monsterClassSiteSet[59] = 1;
            monsterClassSiteSet[60] = 15;
            monsterClassSiteSet[61] = 3;
            monsterClassSiteSet[62] = 8;
            monsterClassSiteSet[63] = 8;
            monsterClassSiteSet[64] = 1;
            monsterClassSiteSet[65] = 2;
            monsterClassSiteSet[66] = 4;
            monsterClassSiteSet[67] = 5;
            monsterClassSiteSet[68] = 14;
            monsterClassSiteSet[69] = 1;
            monsterClassSiteSet[70] = 3;
            monsterClassSiteSet[71] = 3;
            monsterClassSiteSet[72] = 16;
            monsterClassSiteSet[73] = 17;
            monsterClassSiteSet[74] = 5;
            monsterClassSiteSet[75] = 7;
            monsterClassSiteSet[76] = 1;
            monsterClassSiteSet[77] = 17;
            monsterClassSiteSet[78] = 10;
            monsterClassSiteSet[79] = 1;
            monsterClassSiteSet[80] = 13;
            monsterClassSiteSet[81] = 4;
            monsterClassSiteSet[82] = 17;
            monsterClassSiteSet[83] = 10;
            monsterClassSiteSet[84] = 1;
            monsterClassSiteSet[85] = 13;
            monsterClassSiteSet[86] = 4;
            monsterClassSiteSet[87] = 1;
            monsterClassSiteSet[88] = 4;
            monsterClassSiteSet[89] = 1;
            monsterClassSiteSet[90] = 2;
            monsterClassSiteSet[91] = 2;
            monsterClassSiteSet[92] = 2;
            monsterClassSiteSet[93] = 15;
            monsterClassSiteSet[94] = 15;
            monsterClassSiteSet[95] = 15;
            monsterClassSiteSet[96] = 12;
            monsterClassSiteSet[97] = 12;
            monsterClassSiteSet[98] = 12;
            monsterClassSiteSet[99] = 5;
            monsterClassSiteSet[100] = 5;
            monsterClassSiteSet[101] = 8;
            monsterClassSiteSet[102] = 8;
            monsterClassSiteSet[103] = 2;
            monsterClassSiteSet[104] = 2;
            monsterClassSiteSet[105] = 15;
            monsterClassSiteSet[106] = 1;
            monsterClassSiteSet[107] = 1;
            monsterClassSiteSet[108] = 1;
            monsterClassSiteSet[109] = 9;
            monsterClassSiteSet[110] = 10;
            monsterClassSiteSet[111] = 13;
            monsterClassSiteSet[112] = 11;
            monsterClassSiteSet[113] = 14;
            monsterClassSiteSet[114] = 6;
            monsterClassSiteSet[115] = 8;
            monsterClassSiteSet[116] = 3;
            monsterClassSiteSet[117] = 3;
            monsterClassSiteSet[118] = 3;
            monsterClassSiteSet[119] = 13;
            monsterClassSiteSet[120] = 13;
            monsterClassSiteSet[121] = 13;
            monsterClassSiteSet[122] = 5;
            monsterClassSiteSet[123] = 5;
            monsterClassSiteSet[124] = 5;
            monsterClassSiteSet[125] = 15;
            monsterClassSiteSet[126] = 15;
            monsterClassSiteSet[127] = 15;
            monsterClassSiteSet[128] = 1;
            monsterClassSiteSet[129] = 1;
            monsterClassSiteSet[130] = 1;
            monsterClassSiteSet[131] = 14;
            monsterClassSiteSet[132] = 14;
            monsterClassSiteSet[133] = 14;
            monsterClassSiteSet[134] = 16;
            monsterClassSiteSet[135] = 16;
            monsterClassSiteSet[136] = 13;
            monsterClassSiteSet[137] = 13;
            monsterClassSiteSet[138] = 4;
            monsterClassSiteSet[139] = 4;
            monsterClassSiteSet[140] = 7;
            monsterClassSiteSet[141] = 7;
            monsterClassSiteSet[142] = 4;
            monsterClassSiteSet[143] = 4;
            monsterClassSiteSet[144] = 13;
            monsterClassSiteSet[145] = 13;
            monsterClassSiteSet[146] = 9;
            monsterClassSiteSet[147] = 9;
            monsterClassSiteSet[148] = 14;
            monsterClassSiteSet[149] = 14;
            monsterClassSiteSet[150] = 14;
            monsterClassSiteSet[151] = 1;
            monsterClassSiteSet[152] = 1;
            monsterClassSiteSet[153] = 12;
            monsterClassSiteSet[154] = 9;
            monsterClassSiteSet[155] = 14;
            monsterClassSiteSet[156] = 16;
            monsterClassSiteSet[157] = 16;
            monsterClassSiteSet[158] = 8;
    }
    
    function initSiteRewards(uint _turn) onlyModerators public {
        if (_turn == 1) {
            siteRewards[1] = RewardData(25, 116, 350, 350, 50, 350, 225);
            siteRewards[2] = RewardData(25, 119, 350, 350, 50, 350, 225);
            siteRewards[3] = RewardData(25, 122, 350, 350, 50, 350, 225);
            siteRewards[4] = RewardData(25, 116, 350, 351, 50, 350, 225);
            siteRewards[5] = RewardData(25, 119, 350, 351, 50, 350, 225);
            siteRewards[6] = RewardData(25, 122, 350, 351, 50, 350, 225);
            siteRewards[7] = RewardData(25, 116, 350, 352, 50, 350, 225);
            siteRewards[8] = RewardData(25, 119, 350, 352, 50, 350, 225);
            siteRewards[9] = RewardData(25, 122, 350, 352, 50, 350, 225);
            siteRewards[10] = RewardData(25, 125, 350, 320, 50, 350, 225);
            siteRewards[11] = RewardData(25, 128, 350, 320, 50, 350, 225);
            siteRewards[12] = RewardData(25, 131, 350, 320, 50, 350, 225);
            siteRewards[13] = RewardData(25, 125, 350, 321, 50, 350, 225);
            siteRewards[14] = RewardData(25, 128, 350, 321, 50, 350, 225);
            siteRewards[15] = RewardData(25, 131, 350, 321, 50, 350, 225);
            siteRewards[16] = RewardData(25, 125, 350, 322, 50, 350, 225);
            siteRewards[17] = RewardData(25, 128, 350, 322, 50, 350, 225);
            siteRewards[18] = RewardData(25, 131, 350, 322, 50, 350, 225);
            siteRewards[19] = RewardData(25, 134, 350, 340, 50, 350, 225);
            siteRewards[20] = RewardData(25, 136, 350, 340, 50, 350, 225);
            siteRewards[21] = RewardData(25, 138, 350, 340, 50, 350, 225);
            siteRewards[22] = RewardData(25, 134, 350, 341, 50, 350, 225);
            siteRewards[23] = RewardData(25, 136, 350, 341, 50, 350, 225);
            siteRewards[24] = RewardData(25, 138, 350, 341, 50, 350, 225);
            siteRewards[25] = RewardData(25, 134, 350, 342, 50, 350, 225);
            siteRewards[26] = RewardData(25, 136, 350, 342, 50, 350, 225);
            siteRewards[27] = RewardData(25, 138, 350, 342, 50, 350, 225);
        } else {
            siteRewards[28] = RewardData(25, 140, 350, 300, 50, 350, 225);
            siteRewards[29] = RewardData(25, 142, 350, 300, 50, 350, 225);
            siteRewards[30] = RewardData(25, 144, 350, 300, 50, 350, 225);
            siteRewards[31] = RewardData(25, 140, 350, 301, 50, 350, 225);
            siteRewards[32] = RewardData(25, 142, 350, 301, 50, 350, 225);
            siteRewards[33] = RewardData(25, 144, 350, 301, 50, 350, 225);
            siteRewards[34] = RewardData(25, 140, 350, 302, 50, 350, 225);
            siteRewards[35] = RewardData(25, 142, 350, 302, 50, 350, 225);
            siteRewards[36] = RewardData(25, 144, 350, 302, 50, 350, 225);
            siteRewards[37] = RewardData(25, 153, 350, 310, 50, 350, 225);
            siteRewards[38] = RewardData(25, 154, 350, 310, 50, 350, 225);
            siteRewards[39] = RewardData(25, 155, 350, 310, 50, 350, 225);
            siteRewards[40] = RewardData(25, 146, 350, 311, 50, 350, 225);
            siteRewards[41] = RewardData(25, 148, 350, 311, 50, 350, 225);
            siteRewards[42] = RewardData(25, 151, 350, 311, 50, 350, 225);
            siteRewards[43] = RewardData(25, 146, 350, 312, 50, 350, 225);
            siteRewards[44] = RewardData(25, 148, 350, 312, 50, 350, 225);
            siteRewards[45] = RewardData(25, 151, 350, 312, 50, 350, 225);
            siteRewards[46] = RewardData(25, 151, 350, 330, 50, 350, 225);
            siteRewards[47] = RewardData(25, 146, 350, 330, 50, 350, 225);
            siteRewards[48] = RewardData(25, 148, 350, 330, 50, 350, 225);
            siteRewards[49] = RewardData(5, 153, 350, 331, 50, 350, 245);
            siteRewards[50] = RewardData(5, 154, 350, 331, 50, 350, 245);
            siteRewards[51] = RewardData(5, 155, 350, 331, 50, 350, 245);
            siteRewards[52] = RewardData(25, 151, 350, 332, 50, 350, 225);
            siteRewards[53] = RewardData(25, 146, 350, 332, 50, 350, 225);
            siteRewards[54] = RewardData(25, 148, 350, 332, 50, 350, 225);
        } 
    }
    
    function getSiteRewards(uint _siteId) constant public returns(uint monster_rate, uint monster_id, uint shard_rate, uint shard_id, uint level_rate, uint exp_rate, uint emont_rate) {
        RewardData storage reward = siteRewards[_siteId];
        return (reward.monster_rate, reward.monster_id, reward.shard_rate, reward.shard_id, reward.level_rate, reward.exp_rate, reward.emont_rate);
    }
    
    function getSiteId(uint _classId, uint _seed) constant public returns(uint) {
        uint[] storage siteList = siteSet[monsterClassSiteSet[_classId]];
        if (siteList.length == 0) return 0;
        return siteList[_seed % siteList.length];
    }
    
    function getSiteItem(uint _siteId, uint _seed) constant public returns(uint _monsterClassId, uint _tokenClassId, uint _value) {
        uint value = _seed % 1000;
        RewardData storage reward = siteRewards[_siteId];
        // assign monster
        if (value < reward.monster_rate) {
            return (reward.monster_id, 0, 0);
        }
        value -= reward.monster_rate;
        // shard
        if (value < reward.shard_rate) {
            return (0, reward.shard_id, 0);
        }
        value -= reward.shard_rate;
        // level 
        if (value < reward.level_rate) {
            return (0, levelItemClass, levelRewards[value%4]);
        }
        value -= reward.level_rate;
        // exp
        if (value < reward.exp_rate) {
            return (0, expItemClass, expRewards[value%11]);
        }
        value -= reward.exp_rate;
        return (0, 0, emontRewards[value%6]);
    }
}