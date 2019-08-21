pragma solidity ^0.4.16;

// copyright contact@Etheremon.com

contract SafeMath {

    /* function assert(bool assertion) internal { */
    /*   if (!assertion) { */
    /*     throw; */
    /*   } */
    /* }      // assert no longer needed once solidity is on 0.4.10 */

    function safeAdd(uint256 x, uint256 y) pure internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint256 x, uint256 y) pure internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) pure internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

}

contract BasicAccessControl {
    address public owner;
    // address[] public moderators;
    uint16 public totalModerators = 0;
    mapping (address => bool) public moderators;
    bool public isMaintaining = true;

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
        ERROR_INVALID_AMOUNT,
        ERROR_OBJ_NOT_FOUND,
        ERROR_OBJ_INVALID_OWNERSHIP
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
    
    enum BattleResult {
        CASTLE_WIN,
        CASTLE_LOSE,
        CASTLE_DESTROYED
    }
    
    enum CacheClassInfoType {
        CLASS_TYPE,
        CLASS_STEP,
        CLASS_ANCESTOR
    }
}

contract EtheremonDataBase is EtheremonEnum, BasicAccessControl, SafeMath {
    
    uint64 public totalMonster;
    uint32 public totalClass;
    
    // read
    function getSizeArrayType(ArrayType _type, uint64 _id) constant public returns(uint);
    function getElementInArrayType(ArrayType _type, uint64 _id, uint _index) constant public returns(uint8);
    function getMonsterClass(uint32 _classId) constant public returns(uint32 classId, uint256 price, uint256 returnPrice, uint32 total, bool catchable);
    function getMonsterObj(uint64 _objId) constant public returns(uint64 objId, uint32 classId, address trainer, uint32 exp, uint32 createIndex, uint32 lastClaimIndex, uint createTime);
    function getMonsterName(uint64 _objId) constant public returns(string name);
    function getExtraBalance(address _trainer) constant public returns(uint256);
    function getMonsterDexSize(address _trainer) constant public returns(uint);
    function getMonsterObjId(address _trainer, uint index) constant public returns(uint64);
    function getExpectedBalance(address _trainer) constant public returns(uint256);
    function getMonsterReturn(uint64 _objId) constant public returns(uint256 current, uint256 total);
}

interface EtheremonTradeInterface {
    function isOnTrading(uint64 _objId) constant external returns(bool);
}

interface EtheremonPaymentInterface {
    function giveBattleBonus(address _trainer, uint _amount) public; 
}

contract EtheremonGateway is EtheremonEnum, BasicAccessControl {
    // using for battle contract later
    function increaseMonsterExp(uint64 _objId, uint32 amount) onlyModerators public;
    function decreaseMonsterExp(uint64 _objId, uint32 amount) onlyModerators public;
    
    // read 
    function isGason(uint64 _objId) constant external returns(bool);
    function getObjBattleInfo(uint64 _objId) constant external returns(uint32 classId, uint32 exp, bool isGason, 
        uint ancestorLength, uint xfactorsLength);
    function getClassPropertySize(uint32 _classId, PropertyType _type) constant external returns(uint);
    function getClassPropertyValue(uint32 _classId, PropertyType _type, uint index) constant external returns(uint32);
}

contract EtheremonCastleContract is EtheremonEnum, BasicAccessControl{

    uint32 public totalCastle = 0;
    uint64 public totalBattle = 0;
    
    function getCastleBasicInfo(address _owner) constant external returns(uint32, uint, uint32);
    function getCastleBasicInfoById(uint32 _castleId) constant external returns(uint, address, uint32);
    function countActiveCastle() constant external returns(uint);
    function getCastleObjInfo(uint32 _castleId) constant external returns(uint64, uint64, uint64, uint64, uint64, uint64);
    function getCastleStats(uint32 _castleId) constant external returns(string, address, uint32, uint32, uint32, uint);
    function isOnCastle(uint32 _castleId, uint64 _objId) constant external returns(bool);
    function getCastleWinLose(uint32 _castleId) constant external returns(uint32, uint32, uint32);
    function getTrainerBrick(address _trainer) constant external returns(uint32);

    function addCastle(address _trainer, string _name, uint64 _a1, uint64 _a2, uint64 _a3, uint64 _s1, uint64 _s2, uint64 _s3, uint32 _brickNumber) 
        onlyModerators external returns(uint32 currentCastleId);
    function renameCastle(uint32 _castleId, string _name) onlyModerators external;
    function removeCastleFromActive(uint32 _castleId) onlyModerators external;
    function deductTrainerBrick(address _trainer, uint32 _deductAmount) onlyModerators external returns(bool);
    
    function addBattleLog(uint32 _castleId, address _attacker, 
        uint8 _ran1, uint8 _ran2, uint8 _ran3, uint8 _result, uint32 _castleExp1, uint32 _castleExp2, uint32 _castleExp3) onlyModerators external returns(uint64);
    function addBattleLogMonsterInfo(uint64 _battleId, uint64 _a1, uint64 _a2, uint64 _a3, uint64 _s1, uint64 _s2, uint64 _s3, uint32 _exp1, uint32 _exp2, uint32 _exp3) onlyModerators external;
}

contract EtheremonBattle is EtheremonEnum, BasicAccessControl, SafeMath {
    uint8 constant public NO_MONSTER = 3;
    uint8 constant public STAT_COUNT = 6;
    uint8 constant public GEN0_NO = 24;
    
    struct MonsterClassAcc {
        uint32 classId;
        uint256 price;
        uint256 returnPrice;
        uint32 total;
        bool catchable;
    }

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
    
    struct BattleMonsterData {
        uint64 a1;
        uint64 a2;
        uint64 a3;
        uint64 s1;
        uint64 s2;
        uint64 s3;
    }

    struct SupporterData {
        uint32 classId1;
        bool isGason1;
        uint8 type1;
        uint32 classId2;
        bool isGason2;
        uint8 type2;
        uint32 classId3;
        bool isGason3;
        uint8 type3;
    }

    struct AttackData {
        uint64 aa;
        SupporterData asup;
        uint16 aAttackSupport;
        uint64 ba;
        SupporterData bsup;
        uint16 bAttackSupport;
        uint8 index;
    }
    
    struct MonsterBattleLog {
        uint64 objId;
        uint32 exp;
    }
    
    struct BattleLogData {
        address castleOwner;
        uint64 battleId;
        uint32 castleId;
        uint32[3] temp;
        uint castleIndex;
        uint8[6] monsterLevel;
        uint8[3] randoms;
        bool win;
        BattleResult result;
    }
    
    struct CacheClassInfo {
        uint8[] types;
        uint8[] steps;
        uint32[] ancestors;
    }
    
    struct CastleData {
        address trainer;
        string name;
        uint32 brickNumber;
        uint64 a1;
        uint64 a2;
        uint64 a3;
        uint64 s1;
        uint64 s2;
        uint64 s3;
    }

    // event
    event EventCreateCastle(address indexed owner, uint32 castleId);
    event EventAttackCastle(address indexed attacker, uint32 castleId, uint8 result);
    event EventRemoveCastle(uint32 indexed castleId);
    
    // linked smart contract
    address public worldContract;
    address public dataContract;
    address public tradeContract;
    address public castleContract;
    address public paymentContract;
    
    // global variable
    mapping(uint8 => uint8) typeAdvantages;
    mapping(uint32 => CacheClassInfo) cacheClasses;
    mapping(uint8 => uint32) levelExps;
    uint8 public ancestorBuffPercentage = 10;
    uint8 public gasonBuffPercentage = 10;
    uint8 public typeBuffPercentage = 20;
    uint8 public maxLevel = 100;
    uint16 public maxActiveCastle = 30;
    uint8 public maxRandomRound = 4;
    
    uint8 public winBrickReturn = 8;
    uint32 public castleMinBrick = 5;
    uint8 public castleExpAdjustment = 150; // percentage
    uint8 public attackerExpAdjustment = 50; // percentage
    uint8 public levelExpAdjustment = 3; // level
    uint8 public castleMaxLevelGap = 5;
    uint public brickETHPrice = 0.004 ether;
    uint8 public minHpDeducted = 10;
    uint public winTokenReward = 10 ** 8;
    
    uint256 public totalEarn = 0;
    uint256 public totalWithdraw = 0;
    
    address private lastAttacker = address(0x0);
    
    // modifier
    modifier requireDataContract {
        require(dataContract != address(0));
        _;
    }
    
    modifier requireTradeContract {
        require(tradeContract != address(0));
        _;
    }
    
    modifier requireCastleContract {
        require(castleContract != address(0));
        _;
    }
    
    modifier requireWorldContract {
        require(worldContract != address(0));
        _;
    }
    
    modifier requirePaymentContract {
        require(paymentContract != address(0));
        _;
    }


    function EtheremonBattle(address _dataContract, address _worldContract, address _tradeContract, address _castleContract, address _paymentContract) public {
        dataContract = _dataContract;
        worldContract = _worldContract;
        tradeContract = _tradeContract;
        castleContract = _castleContract;
        paymentContract = _paymentContract;
    }
    
     // admin & moderators
    function setTypeAdvantages() onlyModerators external {
        typeAdvantages[1] = 14;
        typeAdvantages[2] = 16;
        typeAdvantages[3] = 8;
        typeAdvantages[4] = 9;
        typeAdvantages[5] = 2;
        typeAdvantages[6] = 11;
        typeAdvantages[7] = 3;
        typeAdvantages[8] = 5;
        typeAdvantages[9] = 15;
        typeAdvantages[11] = 18;
        // skipp 10
        typeAdvantages[12] = 7;
        typeAdvantages[13] = 6;
        typeAdvantages[14] = 17;
        typeAdvantages[15] = 13;
        typeAdvantages[16] = 12;
        typeAdvantages[17] = 1;
        typeAdvantages[18] = 4;
    }
    
    function setTypeAdvantage(uint8 _type1, uint8 _type2) onlyModerators external {
        typeAdvantages[_type1] = _type2;
    }
    
    function setCacheClassInfo(uint32 _classId) onlyModerators requireDataContract requireWorldContract public {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
         EtheremonGateway gateway = EtheremonGateway(worldContract);
        uint i = 0;
        CacheClassInfo storage classInfo = cacheClasses[_classId];

        // add type
        i = data.getSizeArrayType(ArrayType.CLASS_TYPE, uint64(_classId));
        uint8[] memory aTypes = new uint8[](i);
        for(; i > 0 ; i--) {
            aTypes[i-1] = data.getElementInArrayType(ArrayType.CLASS_TYPE, uint64(_classId), i-1);
        }
        classInfo.types = aTypes;

        // add steps
        i = data.getSizeArrayType(ArrayType.STAT_STEP, uint64(_classId));
        uint8[] memory steps = new uint8[](i);
        for(; i > 0 ; i--) {
            steps[i-1] = data.getElementInArrayType(ArrayType.STAT_STEP, uint64(_classId), i-1);
        }
        classInfo.steps = steps;
        
        // add ancestor
        i = gateway.getClassPropertySize(_classId, PropertyType.ANCESTOR);
        uint32[] memory ancestors = new uint32[](i);
        for(; i > 0 ; i--) {
            ancestors[i-1] = gateway.getClassPropertyValue(_classId, PropertyType.ANCESTOR, i-1);
        }
        classInfo.ancestors = ancestors;
    }
    
    function fastSetCacheClassInfo(uint32 _classId1, uint32 _classId2, uint32 _classId3, uint32 _classId4, uint32 _classId5, uint32 _classId6, uint32 _classId7, uint32 _classId8) 
        onlyModerators requireDataContract requireWorldContract public {
        setCacheClassInfo(_classId1);
        setCacheClassInfo(_classId2);
        setCacheClassInfo(_classId3);
        setCacheClassInfo(_classId4);
        setCacheClassInfo(_classId5);
        setCacheClassInfo(_classId6);
        setCacheClassInfo(_classId7);
        setCacheClassInfo(_classId8);
    }    
     
    function withdrawEther(address _sendTo, uint _amount) onlyModerators external {
        if (_amount > this.balance) {
            revert();
        }
        uint256 validAmount = safeSubtract(totalEarn, totalWithdraw);
        if (_amount > validAmount) {
            revert();
        }
        totalWithdraw += _amount;
        _sendTo.transfer(_amount);
    }
    
    function setContract(address _dataContract, address _worldContract, address _tradeContract, address _castleContract, address _paymentContract) onlyModerators external {
        dataContract = _dataContract;
        worldContract = _worldContract;
        tradeContract = _tradeContract;
        castleContract = _castleContract;
        paymentContract = _paymentContract;
    }
    
    function setConfig(uint8 _ancestorBuffPercentage, uint8 _gasonBuffPercentage, uint8 _typeBuffPercentage, 
        uint8 _maxLevel, uint8 _maxRandomRound, uint8 _minHpDeducted, uint _winTokenReward) onlyModerators external{
        ancestorBuffPercentage = _ancestorBuffPercentage;
        gasonBuffPercentage = _gasonBuffPercentage;
        typeBuffPercentage = _typeBuffPercentage;
        maxLevel = _maxLevel;
        maxRandomRound = _maxRandomRound;
        minHpDeducted = _minHpDeducted;
        winTokenReward = _winTokenReward;
    }
    
    function setCastleConfig(uint8 _castleMaxLevelGap, uint16 _maxActiveCastle, uint _brickETHPrice, uint8 _castleExpAdjustment, uint8 _attackerExpAdjustment, uint8 _levelExpAdjustment, uint32 _castleMinBrick) onlyModerators external {
        castleMaxLevelGap = _castleMaxLevelGap;
        maxActiveCastle = _maxActiveCastle;
        brickETHPrice = _brickETHPrice;
        castleExpAdjustment = _castleExpAdjustment;
        attackerExpAdjustment = _attackerExpAdjustment;
        levelExpAdjustment = _levelExpAdjustment;
        castleMinBrick = _castleMinBrick;
    }
    
    function genLevelExp() onlyModerators external {
        uint8 level = 1;
        uint32 requirement = 100;
        uint32 sum = requirement;
        while(level <= 100) {
            levelExps[level] = sum;
            level += 1;
            requirement = (requirement * 11) / 10 + 5;
            sum += requirement;
        }
    }
    
    // public 
    function getCacheClassSize(uint32 _classId) constant public returns(uint, uint, uint) {
        CacheClassInfo storage classInfo = cacheClasses[_classId];
        return (classInfo.types.length, classInfo.steps.length, classInfo.ancestors.length);
    }
    
    function getRandom(uint8 maxRan, uint8 index, address priAddress) constant public returns(uint8) {
        uint256 genNum = uint256(block.blockhash(block.number-1)) + uint256(priAddress);
        for (uint8 i = 0; i < index && i < 6; i ++) {
            genNum /= 256;
        }
        return uint8(genNum % maxRan);
    }
    
    function getLevel(uint32 exp) view public returns (uint8) {
        uint8 minIndex = 1;
        uint8 maxIndex = 100;
        uint8 currentIndex;
     
        while (minIndex < maxIndex) {
            currentIndex = (minIndex + maxIndex) / 2;
            if (exp < levelExps[currentIndex])
                maxIndex = currentIndex;
            else
                minIndex = currentIndex + 1;
        }

        return minIndex;
    }
    
    function getGainExp(uint8 level2, uint8 level, bool _win) constant public returns(uint32){
        uint8 halfLevel1 = level;
        if (level > level2 + 3) {
            halfLevel1 = (level2 + 3) / 2;
        } else {
            halfLevel1 = level / 2;
        }
        uint32 gainExp = 1;
        uint256 rate = (21 ** uint256(halfLevel1)) * 1000 / (20 ** uint256(halfLevel1));
        rate = rate * rate;
        if ((level > level2 + 3 && level2 + 3 > 2 * halfLevel1) || (level <= level2 + 3 && level > 2 * halfLevel1)) rate = rate * 21 / 20;
        if (_win) {
            gainExp = uint32(30 * rate / 1000000);
        } else {
            gainExp = uint32(10 * rate / 1000000);
        }
        
        if (level2 >= level + levelExpAdjustment) {
            gainExp /= uint32(2) ** ((level2 - level) / levelExpAdjustment);
        }
        return gainExp;
    }
    
    function getMonsterLevel(uint64 _objId) constant external returns(uint32, uint8) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        uint32 _ = 0;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, _, _, obj.createTime) = data.getMonsterObj(_objId);
     
        return (obj.exp, getLevel(obj.exp));
    }
    
    function getMonsterCP(uint64 _objId) constant external returns(uint64) {
        uint16[6] memory stats;
        uint32 classId = 0;
        uint32 exp = 0;
        (classId, exp, stats) = getCurrentStats(_objId);
        
        uint256 total;
        for(uint i=0; i < STAT_COUNT; i+=1) {
            total += stats[i];
        }
        return uint64(total/STAT_COUNT);
    }
    
    function isOnBattle(uint64 _objId) constant external returns(bool) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        EtheremonCastleContract castle = EtheremonCastleContract(castleContract);
        uint32 castleId;
        uint castleIndex = 0;
        uint256 price = 0;
        MonsterObjAcc memory obj;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, obj.createIndex, obj.lastClaimIndex, obj.createTime) = data.getMonsterObj(_objId);
        (castleId, castleIndex, price) = castle.getCastleBasicInfo(obj.trainer);
        if (castleId > 0 && castleIndex > 0)
            return castle.isOnCastle(castleId, _objId);
        return false;
    }
    
    function isValidOwner(uint64 _objId, address _owner) constant public returns(bool) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, obj.createIndex, obj.lastClaimIndex, obj.createTime) = data.getMonsterObj(_objId);
        return (obj.trainer == _owner && obj.classId != 21);
    }
    
    function getObjExp(uint64 _objId) constant public returns(uint32, uint32) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        uint32 _ = 0;
        (_objId, obj.classId, obj.trainer, obj.exp, _, _, obj.createTime) = data.getMonsterObj(_objId);
        return (obj.classId, obj.exp);
    }
    
    function getCurrentStats(uint64 _objId) constant public returns(uint32, uint8, uint16[6]){
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        uint16[6] memory stats;
        uint32 classId;
        uint32 exp;
        (classId, exp) = getObjExp(_objId);
        if (classId == 0)
            return (classId, 0, stats);
        
        uint i = 0;
        uint8 level = getLevel(exp);
        for(i=0; i < STAT_COUNT; i+=1) {
            stats[i] = data.getElementInArrayType(ArrayType.STAT_BASE, _objId, i);
        }
        for(i=0; i < cacheClasses[classId].steps.length; i++) {
            stats[i] += uint16(safeMult(cacheClasses[classId].steps[i], level*3));
        }
        return (classId, level, stats);
    }
    
    function safeDeduct(uint16 a, uint16 b) pure private returns(uint16){
        if (a > b) {
            return a - b;
        }
        return 0;
    }
    
    function calHpDeducted(uint16 _attack, uint16 _specialAttack, uint16 _defense, uint16 _specialDefense, bool _lucky) view public returns(uint16){
        if (_lucky) {
            _attack = _attack * 13 / 10;
            _specialAttack = _specialAttack * 13 / 10;
        }
        uint16 hpDeducted = safeDeduct(_attack, _defense * 3 /4);
        uint16 hpSpecialDeducted = safeDeduct(_specialAttack, _specialDefense* 3 / 4);
        if (hpDeducted < minHpDeducted && hpSpecialDeducted < minHpDeducted)
            return minHpDeducted;
        if (hpDeducted > hpSpecialDeducted)
            return hpDeducted;
        return hpSpecialDeducted;
    }
    
    function getAncestorBuff(uint32 _classId, SupporterData _support) constant private returns(uint16){
        // check ancestors
        uint i =0;
        uint8 countEffect = 0;
        uint ancestorSize = cacheClasses[_classId].ancestors.length;
        if (ancestorSize > 0) {
            uint32 ancestorClass = 0;
            for (i=0; i < ancestorSize; i ++) {
                ancestorClass = cacheClasses[_classId].ancestors[i];
                if (ancestorClass == _support.classId1 || ancestorClass == _support.classId2 || ancestorClass == _support.classId3) {
                    countEffect += 1;
                }
            }
        }
        return countEffect * ancestorBuffPercentage;
    }
    
    function getGasonSupport(uint32 _classId, SupporterData _sup) constant private returns(uint16 defenseSupport) {
        uint i = 0;
        uint8 classType = 0;
        defenseSupport = 0;
        for (i = 0; i < cacheClasses[_classId].types.length; i++) {
            classType = cacheClasses[_classId].types[i];
             if (_sup.isGason1) {
                if (classType == _sup.type1) {
                    defenseSupport += gasonBuffPercentage;
                    continue;
                }
            }
            if (_sup.isGason2) {
                if (classType == _sup.type2) {
                    defenseSupport += gasonBuffPercentage;
                    continue;
                }
            }
            if (_sup.isGason3) {
                if (classType == _sup.type3) {
                    defenseSupport += gasonBuffPercentage;
                    continue;
                }
            }
        }
    }
    
    function getTypeSupport(uint32 _aClassId, uint32 _bClassId) constant private returns (uint16 aAttackSupport, uint16 bAttackSupport) {
        // check types 
        bool aHasAdvantage;
        bool bHasAdvantage;
        for (uint i = 0; i < cacheClasses[_aClassId].types.length; i++) {
            for (uint j = 0; j < cacheClasses[_bClassId].types.length; j++) {
                if (typeAdvantages[cacheClasses[_aClassId].types[i]] == cacheClasses[_bClassId].types[j]) {
                    aHasAdvantage = true;
                }
                if (typeAdvantages[cacheClasses[_bClassId].types[j]] == cacheClasses[_aClassId].types[i]) {
                    bHasAdvantage = true;
                }
            }
        }
        
        if (aHasAdvantage)
            aAttackSupport += typeBuffPercentage;
        if (bHasAdvantage)
            bAttackSupport += typeBuffPercentage;
    }
    
    function calculateBattleStats(AttackData att) constant private returns(uint8 aLevel, uint16[6] aStats, uint8 bLevel, uint16[6] bStats) {
        uint32 aClassId = 0;
        (aClassId, aLevel, aStats) = getCurrentStats(att.aa);
        uint32 bClassId = 0;
        (bClassId, bLevel, bStats) = getCurrentStats(att.ba);
        
        // check gasonsupport
        (att.aAttackSupport, att.bAttackSupport) = getTypeSupport(aClassId, bClassId);
        att.aAttackSupport += getAncestorBuff(aClassId, att.asup);
        att.bAttackSupport += getAncestorBuff(bClassId, att.bsup);
        
        uint16 aDefenseBuff = getGasonSupport(aClassId, att.asup);
        uint16 bDefenseBuff = getGasonSupport(bClassId, att.bsup);
        
        // add attack
        aStats[1] += aStats[1] * att.aAttackSupport / 100;
        aStats[3] += aStats[3] * att.aAttackSupport / 100;
        bStats[1] += bStats[1] * att.bAttackSupport / 100;
        bStats[3] += bStats[3] * att.bAttackSupport / 100;
        
        // add offense
        aStats[2] += aStats[2] * aDefenseBuff / 100;
        aStats[4] += aStats[4] * aDefenseBuff / 100;
        bStats[2] += bStats[2] * bDefenseBuff / 100;
        bStats[4] += bStats[4] * bDefenseBuff / 100;
        
    }
    
    function attack(AttackData att) constant private returns(uint8 aLevel, uint8 bLevel, uint8 ran, bool win) {
        uint16[6] memory aStats;
        uint16[6] memory bStats;
        (aLevel, aStats, bLevel, bStats) = calculateBattleStats(att);
        
        ran = getRandom(maxRandomRound+2, att.index, lastAttacker);
        uint16 round = 0;
        while (round < maxRandomRound && aStats[0] > 0 && bStats[0] > 0) {
            if (aStats[5] > bStats[5]) {
                if (round % 2 == 0) {
                    // a attack 
                    bStats[0] = safeDeduct(bStats[0], calHpDeducted(aStats[1], aStats[3], bStats[2], bStats[4], round==ran));
                } else {
                    aStats[0] = safeDeduct(aStats[0], calHpDeducted(bStats[1], bStats[3], aStats[2], aStats[4], round==ran));
                }
                
            } else {
                if (round % 2 != 0) {
                    bStats[0] = safeDeduct(bStats[0], calHpDeducted(aStats[1], aStats[3], bStats[2], bStats[4], round==ran));
                } else {
                    aStats[0] = safeDeduct(aStats[0], calHpDeducted(bStats[1], bStats[3], aStats[2], aStats[4], round==ran));
                }
            }
            round+= 1;
        }
        
        win = aStats[0] >= bStats[0];
    }
    
    function updateCastle(uint32 _castleId, address _castleOwner, bool win) requireCastleContract private{
        EtheremonCastleContract castle = EtheremonCastleContract(castleContract);
        uint32 totalWin;
        uint32 totalLose;
        uint32 brickNumber;
        (totalWin, totalLose, brickNumber) = castle.getCastleWinLose(_castleId);
        EtheremonPaymentInterface payment = EtheremonPaymentInterface(paymentContract);
        
        // if castle win, ignore
        if (win) {
            if (totalWin < brickNumber) {
                 payment.giveBattleBonus(_castleOwner, winTokenReward);
            }
        } else {
            if (totalWin/winBrickReturn > brickNumber) {
                brickNumber = 2 * brickNumber;
            } else {
                brickNumber += totalWin/winBrickReturn;
            }
            if (brickNumber <= totalLose + 1) {
                castle.removeCastleFromActive(_castleId);
                // destroy
            }
            payment.giveBattleBonus(msg.sender, winTokenReward);
        }
    }
    
    function hasValidParam(address _trainer, uint64 _a1, uint64 _a2, uint64 _a3, uint64 _s1, uint64 _s2, uint64 _s3) constant public returns(bool) {
        if (_a1 == 0 || _a2 == 0 || _a3 == 0)
            return false;
        if (_a1 == _a2 || _a1 == _a3 || _a1 == _s1 || _a1 == _s2 || _a1 == _s3)
            return false;
        if (_a2 == _a3 || _a2 == _s1 || _a2 == _s2 || _a2 == _s3)
            return false;
        if (_a3 == _s1 || _a3 == _s2 || _a3 == _s3)
            return false;
        if (_s1 > 0 && (_s1 == _s2 || _s1 == _s3))
            return false;
        if (_s2 > 0 && (_s2 == _s3))
            return false;
        
        if (!isValidOwner(_a1, _trainer) || !isValidOwner(_a2, _trainer) || !isValidOwner(_a3, _trainer))
            return false;
        if (_s1 > 0 && !isValidOwner(_s1, _trainer))
            return false;
        if (_s2 > 0 && !isValidOwner(_s2, _trainer))
            return false;
        if (_s3 > 0 && !isValidOwner(_s3, _trainer))
            return false;
        return true;
    }
    
    function createCastleInternal(CastleData _castleData) private {
        EtheremonCastleContract castle = EtheremonCastleContract(castleContract);
        uint32 castleId;
        uint castleIndex = 0;
        uint32 numberBrick = 0;
        (castleId, castleIndex, numberBrick) = castle.getCastleBasicInfo(_castleData.trainer);
        if (castleId > 0 || castleIndex > 0)
            revert();

        if (castle.countActiveCastle() >= uint(maxActiveCastle))
            revert();
        castleId = castle.addCastle(_castleData.trainer, _castleData.name, _castleData.a1, _castleData.a2, _castleData.a3, 
            _castleData.s1, _castleData.s2, _castleData.s3, _castleData.brickNumber);
        EventCreateCastle(_castleData.trainer, castleId);
    }
    
    // public
    
    function createCastle(string _name, uint64 _a1, uint64 _a2, uint64 _a3, uint64 _s1, uint64 _s2, uint64 _s3) isActive requireDataContract 
        requireTradeContract requireCastleContract payable external {
        
        if (!hasValidParam(msg.sender, _a1, _a2, _a3, _s1, _s2, _s3))
            revert();
        
        EtheremonTradeInterface trade = EtheremonTradeInterface(tradeContract);
        if (trade.isOnTrading(_a1) || trade.isOnTrading(_a2) || trade.isOnTrading(_a3) || 
            trade.isOnTrading(_s1) || trade.isOnTrading(_s2) || trade.isOnTrading(_s3))
            revert();
        
        uint32 numberBrick = uint32(msg.value / brickETHPrice);
        if (numberBrick < castleMinBrick) {
            revert();
        }
        
        CastleData memory castleData;
        castleData.trainer = msg.sender;
        castleData.name = _name;
        castleData.brickNumber = numberBrick;
        castleData.a1 = _a1;
        castleData.a2 = _a2;
        castleData.a3 = _a3;
        castleData.s1 = _s1;
        castleData.s2 = _s2;
        castleData.s3 = _s3;
        createCastleInternal(castleData);
        totalEarn += msg.value;
    }
    
    function createCastleWithToken(address _trainer, uint32 _noBrick, string _name, uint64 _a1, uint64 _a2, uint64 _a3, uint64 _s1, uint64 _s2, uint64 _s3) isActive requireDataContract
        requireTradeContract requireCastleContract requirePaymentContract external {
        // only accept request from payment contract
        if (msg.sender != paymentContract)
            revert();
    
        if (!hasValidParam(_trainer, _a1, _a2, _a3, _s1, _s2, _s3))
            revert();
        
        EtheremonTradeInterface trade = EtheremonTradeInterface(tradeContract);
        if (trade.isOnTrading(_a1) || trade.isOnTrading(_a2) || trade.isOnTrading(_a3) || 
            trade.isOnTrading(_s1) || trade.isOnTrading(_s2) || trade.isOnTrading(_s3))
            revert();
        
        if (_noBrick < castleMinBrick) {
            revert();
        }
        
        CastleData memory castleData;
        castleData.trainer = _trainer;
        castleData.name = _name;
        castleData.brickNumber = _noBrick;
        castleData.a1 = _a1;
        castleData.a2 = _a2;
        castleData.a3 = _a3;
        castleData.s1 = _s1;
        castleData.s2 = _s2;
        castleData.s3 = _s3;
        createCastleInternal(castleData);
    }
    
    function renameCastle(uint32 _castleId, string _name) isActive requireCastleContract external {
        EtheremonCastleContract castle = EtheremonCastleContract(castleContract);
        uint index;
        address owner;
        uint256 price;
        (index, owner, price) = castle.getCastleBasicInfoById(_castleId);
        if (owner != msg.sender)
            revert();
        castle.renameCastle(_castleId, _name);
    }
    
    function removeCastle(uint32 _castleId) isActive requireCastleContract external {
        EtheremonCastleContract castle = EtheremonCastleContract(castleContract);
        uint index;
        address owner;
        uint256 price;
        (index, owner, price) = castle.getCastleBasicInfoById(_castleId);
        if (owner != msg.sender)
            revert();
        if (index > 0) {
            castle.removeCastleFromActive(_castleId);
        }
        EventRemoveCastle(_castleId);
    }
    
    function getSupporterInfo(uint64 s1, uint64 s2, uint64 s3) constant public returns(SupporterData sData) {
        uint temp;
        uint32 __;
        EtheremonGateway gateway = EtheremonGateway(worldContract);
        if (s1 > 0)
            (sData.classId1, __, sData.isGason1, temp, temp) = gateway.getObjBattleInfo(s1);
        if (s2 > 0)
            (sData.classId2, __, sData.isGason2, temp, temp) = gateway.getObjBattleInfo(s2);
        if (s3 > 0)
            (sData.classId3, __, sData.isGason3, temp, temp) = gateway.getObjBattleInfo(s3);

        EtheremonDataBase data = EtheremonDataBase(dataContract);
        if (sData.isGason1) {
            sData.type1 = data.getElementInArrayType(ArrayType.CLASS_TYPE, uint64(sData.classId1), 0);
        }
        
        if (sData.isGason2) {
            sData.type2 = data.getElementInArrayType(ArrayType.CLASS_TYPE, uint64(sData.classId2), 0);
        }
        
        if (sData.isGason3) {
            sData.type3 = data.getElementInArrayType(ArrayType.CLASS_TYPE, uint64(sData.classId3), 0);
        }
    }
    
    function attackCastle(uint32 _castleId, uint64 _aa1, uint64 _aa2, uint64 _aa3, uint64 _as1, uint64 _as2, uint64 _as3) isActive requireDataContract 
        requireTradeContract requireCastleContract requirePaymentContract external {
        if (!hasValidParam(msg.sender, _aa1, _aa2, _aa3, _as1, _as2, _as3))
            revert();
        
        EtheremonCastleContract castle = EtheremonCastleContract(castleContract);
        BattleLogData memory log;
        (log.castleIndex, log.castleOwner, log.temp[0]) = castle.getCastleBasicInfoById(_castleId);
        if (log.castleIndex == 0 || log.castleOwner == msg.sender)
            revert();
        
        EtheremonGateway gateway = EtheremonGateway(worldContract);
        BattleMonsterData memory b;
        (b.a1, b.a2, b.a3, b.s1, b.s2, b.s3) = castle.getCastleObjInfo(_castleId);
        lastAttacker = msg.sender;

        // init data
        uint8 countWin = 0;
        AttackData memory att;
        att.asup = getSupporterInfo(b.s1, b.s2, b.s3);
        att.bsup = getSupporterInfo(_as1, _as2, _as3);
        
        att.index = 0;
        att.aa = b.a1;
        att.ba = _aa1;
        (log.monsterLevel[0], log.monsterLevel[3], log.randoms[0], log.win) = attack(att);
        gateway.increaseMonsterExp(att.aa, getGainExp(log.monsterLevel[0], log.monsterLevel[3], log.win)*castleExpAdjustment/100);
        gateway.increaseMonsterExp(att.ba, getGainExp(log.monsterLevel[3], log.monsterLevel[0], !log.win)*attackerExpAdjustment/100);
        if (log.win)
            countWin += 1;
        
        
        att.index = 1;
        att.aa = b.a2;
        att.ba = _aa2;
        (log.monsterLevel[1], log.monsterLevel[4], log.randoms[1], log.win) = attack(att);
        gateway.increaseMonsterExp(att.aa, getGainExp(log.monsterLevel[1], log.monsterLevel[4], log.win)*castleExpAdjustment/100);
        gateway.increaseMonsterExp(att.ba, getGainExp(log.monsterLevel[4], log.monsterLevel[1], !log.win)*attackerExpAdjustment/100);
        if (log.win)
            countWin += 1;   

        att.index = 2;
        att.aa = b.a3;
        att.ba = _aa3;
        (log.monsterLevel[2], log.monsterLevel[5], log.randoms[2], log.win) = attack(att);
        gateway.increaseMonsterExp(att.aa, getGainExp(log.monsterLevel[2], log.monsterLevel[5], log.win)*castleExpAdjustment/100);
        gateway.increaseMonsterExp(att.ba, getGainExp(log.monsterLevel[5], log.monsterLevel[2], !log.win)*attackerExpAdjustment/100);
        if (log.win)
            countWin += 1; 
        
        if ((log.monsterLevel[0] + log.monsterLevel[1] + log.monsterLevel[2])/3 + castleMaxLevelGap < (log.monsterLevel[3] + log.monsterLevel[4] + log.monsterLevel[5])/3)
            revert();
        
        updateCastle(_castleId, log.castleOwner, countWin>1);
        if (countWin>1) {
            log.result = BattleResult.CASTLE_WIN;
        } else {
            log.result = BattleResult.CASTLE_LOSE;
        }
        
        log.temp[0] = levelExps[log.monsterLevel[0]]-1;
        log.temp[1] = levelExps[log.monsterLevel[1]]-1;
        log.temp[2] = levelExps[log.monsterLevel[2]]-1;
        log.battleId = castle.addBattleLog(_castleId, msg.sender, log.randoms[0], log.randoms[1], log.randoms[2], 
            uint8(log.result), log.temp[0], log.temp[1], log.temp[2]);
        
        log.temp[0] = levelExps[log.monsterLevel[3]]-1;
        log.temp[1] = levelExps[log.monsterLevel[4]]-1;
        log.temp[2] = levelExps[log.monsterLevel[5]]-1;
        castle.addBattleLogMonsterInfo(log.battleId, _aa1, _aa2, _aa3, _as1, _as2, _as3, log.temp[0], log.temp[1], log.temp[2]);
    
        EventAttackCastle(msg.sender, _castleId, uint8(log.result));
    }
    
}