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

contract EtheremonGym is EtheremonEnum, BasicAccessControl, SafeMath {
    uint8 constant public STAT_COUNT = 6;
    
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
    
    struct AttackData {
        uint32 objClassId;
        address trainee;
        uint8 objLevel;
        uint8 winCount;
        uint32 winExp;
        uint32 loseExp;
    }
    
    struct HpData {
        uint16 aHpAttack;
        uint16 aHpAttackCritical;
        uint16 bHpAttack;
        uint16 bHpAttackCritical;        
    }
    
    struct GymTrainer {
        uint32 classId;
        uint8[6] statBases;
    }
    
    struct TrainingLog {
        uint8[3] trainers;
        uint8 trainerLevel;
        uint64 objId;
        uint8 objLevel;
        uint8 ran;
    }
    
    struct CacheClassInfo {
        uint8[] types;
        uint8[] steps;
        uint32[] ancestors;
    }
    
    mapping(uint8 => GymTrainer) public gymTrainers;
    mapping(address => TrainingLog) public trainees;
    mapping(uint8 => uint8) typeAdvantages;
    mapping(uint32 => CacheClassInfo) cacheClasses;
    mapping(uint8 => uint32) levelExps;
    mapping(uint8 => uint32) levelExpGains;
    uint256 public gymFee = 0.001 ether;
    uint8 public maxTrainerLevel = 5;
    uint8 public totalTrainer = 0;
    uint8 public maxRandomRound = 4;
    uint8 public typeBuffPercentage = 20;
    uint8 public minHpDeducted = 10;
    uint8 public expPercentage = 70;
    
    // contract
    address public worldContract;
    address public dataContract;

   // modifier
    modifier requireDataContract {
        require(dataContract != address(0));
        _;
    }
    
    modifier requireWorldContract {
        require(worldContract != address(0));
        _;
    }
    
    // constructor
    function EtheremonGym(address _dataContract, address _worldContract) public {
        dataContract = _dataContract;
        worldContract = _worldContract;
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
    
    function fastSetCacheClassInfo(uint32 _classId1, uint32 _classId2, uint32 _classId3, uint32 _classId4) onlyModerators requireDataContract requireWorldContract external {
        setCacheClassInfo(_classId1);
        setCacheClassInfo(_classId2);
        setCacheClassInfo(_classId3);
        setCacheClassInfo(_classId4);
    }
    
    function presetGymTrainer() onlyModerators external {
        GymTrainer storage trainer1 = gymTrainers[1];
        trainer1.classId = 12;
        trainer1.statBases[0] = 85;
        trainer1.statBases[1] = 95;
        trainer1.statBases[2] = 65;
        trainer1.statBases[3] = 50;
        trainer1.statBases[4] = 50;
        trainer1.statBases[5] = 50;
        GymTrainer storage trainer2 = gymTrainers[2];
        trainer2.classId = 15;
        trainer2.statBases[0] = 50;
        trainer2.statBases[1] = 55;
        trainer2.statBases[2] = 85;
        trainer2.statBases[3] = 85;
        trainer2.statBases[4] = 40;
        trainer2.statBases[5] = 75;
        GymTrainer storage trainer3 = gymTrainers[3];
        trainer3.classId = 8;
        trainer3.statBases[0] = 110;
        trainer3.statBases[1] = 60;
        trainer3.statBases[2] = 40;
        trainer3.statBases[3] = 60;
        trainer3.statBases[4] = 40;
        trainer3.statBases[5] = 40;
        GymTrainer storage trainer4 = gymTrainers[4];
        trainer4.classId = 4;
        trainer4.statBases[0] = 54;
        trainer4.statBases[1] = 69;
        trainer4.statBases[2] = 58;
        trainer4.statBases[3] = 75;
        trainer4.statBases[4] = 75;
        trainer4.statBases[5] = 70;
        GymTrainer storage trainer5 = gymTrainers[5];
        trainer5.classId = 6;
        trainer5.statBases[0] = 50;
        trainer5.statBases[1] = 50;
        trainer5.statBases[2] = 50;
        trainer5.statBases[3] = 105;
        trainer5.statBases[4] = 55;
        trainer5.statBases[5] = 95;
        GymTrainer storage trainer6 = gymTrainers[6];
        trainer6.classId = 13;
        trainer6.statBases[0] = 55;
        trainer6.statBases[1] = 90;
        trainer6.statBases[2] = 95;
        trainer6.statBases[3] = 45;
        trainer6.statBases[4] = 35;
        trainer6.statBases[5] = 35;
        GymTrainer storage trainer7 = gymTrainers[7];
        trainer7.classId = 7;
        trainer7.statBases[0] = 85;
        trainer7.statBases[1] = 60;
        trainer7.statBases[2] = 73;
        trainer7.statBases[3] = 75;
        trainer7.statBases[4] = 80;
        trainer7.statBases[5] = 50;
        GymTrainer storage trainer8 = gymTrainers[8];
        trainer8.classId = 24;
        trainer8.statBases[0] = 140;
        trainer8.statBases[1] = 135;
        trainer8.statBases[2] = 70;
        trainer8.statBases[3] = 77;
        trainer8.statBases[4] = 90;
        trainer8.statBases[5] = 50;
        GymTrainer storage trainer9 = gymTrainers[9];
        trainer9.classId = 16;
        trainer9.statBases[0] = 70;
        trainer9.statBases[1] = 105;
        trainer9.statBases[2] = 80;
        trainer9.statBases[3] = 60;
        trainer9.statBases[4] = 80;
        trainer9.statBases[5] = 90;
        totalTrainer = 9;
    }
    
    function setGymTrainer(uint8 _trainerId, uint32 _classId, uint8 _s0, uint8 _s1, uint8 _s2, uint8 _s3, uint8 _s4, uint8 _s5) onlyModerators external {
        GymTrainer storage trainer = gymTrainers[_trainerId];
        if (trainer.classId == 0)
            totalTrainer += 1;
        trainer.classId = _classId;
        trainer.statBases[0] = _s0;
        trainer.statBases[1] = _s1;
        trainer.statBases[2] = _s2;
        trainer.statBases[3] = _s3;
        trainer.statBases[4] = _s4;
        trainer.statBases[5] = _s5;
    }
    
    function setContract(address _dataContract, address _worldContract) onlyModerators external {
        dataContract = _dataContract;
        worldContract = _worldContract;
    }
    
    function setConfig(uint256 _gymFee, uint8 _maxTrainerLevel, uint8 _maxRandomRound, uint8 _typeBuffPercentage, 
        uint8 _minHpDeducted, uint8 _expPercentage) onlyModerators external {
        gymFee = _gymFee;
        maxTrainerLevel = _maxTrainerLevel;
        maxRandomRound = _maxRandomRound;
        typeBuffPercentage = _typeBuffPercentage;
        minHpDeducted = _minHpDeducted;
        expPercentage = _expPercentage;
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
    
    function genLevelExpGain() onlyModerators external {
        levelExpGains[1] = 31;
        levelExpGains[2] = 33;
        levelExpGains[3] = 34;
        levelExpGains[4] = 36;
        levelExpGains[5] = 38;
        levelExpGains[6] = 40;
        levelExpGains[7] = 42;
        levelExpGains[8] = 44;
        levelExpGains[9] = 46;
        levelExpGains[10] = 48;
    }
    
    function setLevelExpGain(uint8 _level, uint32 _exp) onlyModerators external {
        levelExpGains[_level] = _exp;
    }
    
    function withdrawEther(address _sendTo, uint _amount) onlyModerators external {
        if (_amount > this.balance) {
            revert();
        }
        _sendTo.transfer(_amount);
    }
    
    // public
    function getCacheClassSize(uint32 _classId) constant public returns(uint, uint, uint) {
        CacheClassInfo storage classInfo = cacheClasses[_classId];
        return (classInfo.types.length, classInfo.steps.length, classInfo.ancestors.length);
    }
    
    function getTrainerInfo(uint8 _trainerId) constant external returns(uint32, uint8, uint8, uint8, uint8, uint8, uint8) {
        GymTrainer memory trainer = gymTrainers[_trainerId];
        return (trainer.classId, trainer.statBases[0], trainer.statBases[1], trainer.statBases[2], trainer.statBases[3],
            trainer.statBases[4], trainer.statBases[5]);
    }
    
    function getRandom(uint8 maxRan, uint8 index) constant public returns(uint8) {
        uint256 genNum = uint256(block.blockhash(block.number-1));
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
    
    function getGainExp(uint8 xLevel, uint8 yLevel) constant public returns(uint32 winExp, uint32 loseExp){
        winExp = levelExpGains[yLevel] * expPercentage / 100;
        if (xLevel > yLevel) {
            if (xLevel > yLevel + 10) {
                winExp = 5;
            } else {
                winExp /= uint32(3) ** (xLevel - yLevel) / uint32(2) ** (xLevel - yLevel);
                if (winExp < 5)
                    winExp = 5;
            }
        }
        loseExp = winExp / 3;
    }
    
    function safeDeduct(uint16 a, uint16 b) pure private returns(uint16){
        if (a > b) {
            return a - b;
        }
        return 0;
    }
    
    function getTypeSupport(uint32 _aClassId, uint32 _bClassId) constant private returns (bool aHasAdvantage, bool bHasAdvantage) {
        // check types 
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
    
    function attack(uint8 _index, uint8 _ran, uint16[6] _aStats, uint16[6] _bStats) constant public returns(bool win) {
        if (_ran < _index * maxRandomRound)
            _ran = maxRandomRound;
        else
            _ran = _ran - _index * maxRandomRound;
            
        uint16 round = 0;
        uint16 aHp = _aStats[0];
        uint16 bHp = _bStats[0];
        if (_aStats[5] > _bStats[5]) {
            while (round < maxRandomRound && aHp > 0 && bHp > 0) {
                if (round % 2 == 0) {
                    // a attack 
                    bHp = safeDeduct(bHp, calHpDeducted(_aStats[1], _aStats[3], _bStats[2], _bStats[4], round==_ran));
                } else {
                    aHp = safeDeduct(aHp, calHpDeducted(_bStats[1], _bStats[3], _aStats[2], _aStats[4], round==_ran));
                }
                round++;
            }
        } else {
            while (round < maxRandomRound && aHp > 0 && bHp > 0) {
                if (round % 2 != 0) {
                    bHp = safeDeduct(bHp, calHpDeducted(_aStats[1], _aStats[3], _bStats[2], _bStats[4], round==_ran));
                } else {
                    aHp = safeDeduct(aHp, calHpDeducted(_bStats[1], _bStats[3], _aStats[2], _aStats[4], round==_ran));
                }
                round++;
            }
        }
        
        win = aHp >= bHp;
    }
    
    function attackTrainer(uint8 _index, uint8 _ran, uint8 _trainerId, uint8 _trainerLevel, uint32 _objClassId, uint16[6] _objStats) constant public returns(bool result) {
        GymTrainer memory trainer = gymTrainers[_trainerId];
        uint16[6] memory trainerStats;
        uint i = 0;
        for (i=0; i < STAT_COUNT; i+=1) {
            trainerStats[i] = trainer.statBases[i];
        }
        for (i=0; i < cacheClasses[trainer.classId].steps.length; i++) {
            trainerStats[i] += uint16(safeMult(cacheClasses[trainer.classId].steps[i], _trainerLevel*3));
        }
        
        bool objHasAdvantage;
        bool trainerHasAdvantage;
        (objHasAdvantage, trainerHasAdvantage) = getTypeSupport(_objClassId, trainer.classId);
        uint16 originAttack = _objStats[1];
        uint16 originAttackSpecial = _objStats[3];
        if (objHasAdvantage) {
            _objStats[1] += _objStats[1] * typeBuffPercentage / 100;
            _objStats[3] += _objStats[3] * typeBuffPercentage / 100;
        }
        if (trainerHasAdvantage) {
            trainerStats[1] += trainerStats[1] * typeBuffPercentage / 100;
            trainerStats[3] += trainerStats[3] * typeBuffPercentage / 100;
        }
        result = attack(_index, _ran, _objStats, trainerStats);
        _objStats[1] = originAttack;
        _objStats[3] = originAttackSpecial;
    }
    
    function getObjInfo(uint64 _objId) constant public returns(uint32 classId, address trainee, uint8 level) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        (obj.monsterId, classId, trainee, obj.exp, obj.createIndex, obj.lastClaimIndex, obj.createTime) = data.getMonsterObj(_objId);
        level = getLevel(obj.exp);
    }
    
    function startTraining(uint64 _objId, uint8 _trainerLevel, uint8 _t1, uint8 _t2, uint8 _t3) isActive requireDataContract requireWorldContract payable external {
        if (_trainerLevel > maxTrainerLevel)
            revert();
        if (msg.value != gymFee)
            revert();
        if (_t1 == _t2 || _t1 == _t3 || _t2 == _t3)
            revert();
        if (_t1 == 0 || _t2 == 0 || _t3 == 0 || _t1 > totalTrainer || _t2 > totalTrainer || _t3 > totalTrainer)
            revert();

        AttackData memory att;
        (att.objClassId, att.trainee, att.objLevel) = getObjInfo(_objId);
        if (msg.sender != att.trainee)
            revert();

        uint i = 0;
        uint16[6] memory objStats;
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        for (i=0; i < STAT_COUNT; i+=1) {
            objStats[i] = data.getElementInArrayType(ArrayType.STAT_BASE, _objId, i);
        }
        for (i=0; i < cacheClasses[att.objClassId].steps.length; i++) {
            objStats[i] += uint16(safeMult(cacheClasses[att.objClassId].steps[i], att.objLevel*3));
        }
        
        att.winCount = 0;
        uint8 ran = getRandom(maxRandomRound*3, 0);
        if (attackTrainer(0, ran, _t1, _trainerLevel, att.objClassId, objStats))
            att.winCount += 1;
        if (attackTrainer(1, ran, _t2, _trainerLevel, att.objClassId, objStats))
            att.winCount += 1;
        if (attackTrainer(2, ran, _t3, _trainerLevel, att.objClassId, objStats))
            att.winCount += 1;

        (att.winExp, att.loseExp) = getGainExp(att.objLevel, _trainerLevel);
        EtheremonGateway gateway = EtheremonGateway(worldContract);
        gateway.increaseMonsterExp(_objId, att.winCount * att.winExp + (3 - att.winCount) * att.loseExp);
        
        TrainingLog storage trainingLog = trainees[msg.sender];
        trainingLog.trainers[0] = _t1;
        trainingLog.trainers[1] = _t2;
        trainingLog.trainers[2] = _t3;
        trainingLog.trainerLevel = _trainerLevel;
        trainingLog.objId = _objId;
        trainingLog.objLevel = att.objLevel;
        trainingLog.ran = ran;
    }
    
    function getTrainingLog(address _trainee) constant external returns(uint8, uint8, uint8, uint64, uint8, uint8, uint8) {
        TrainingLog memory trainingLog = trainees[_trainee];
        return (trainingLog.trainers[0], trainingLog.trainers[1], trainingLog.trainers[2], 
            trainingLog.objId, trainingLog.trainerLevel, trainingLog.objLevel, trainingLog.ran);
    }
}